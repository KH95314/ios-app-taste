import SwiftUI

// The parts of look 09 in use, for an invented product: the air in the rooms
// of a home. Each screen is built only from the look's parts, one plate leads
// it, and nothing on it names a part or a state. `parts.md` says which part
// is which and where it is in code.

struct MetricPartsScreen: View {
    /// The screen to open: `home` (the default), `home-waiting`,
    /// `home-failed`, `empty`, `loading`, `offline`, `room`, `alert`,
    /// `alert-error`, `alert-busy`, `household`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "room", "alert", "alert-error", "alert-busy": MetricRoom(room: .bedroom, opens: screen)
            case "household": MetricHousehold()
            default: MetricHome(opens: screen)
            }
        }
        // This look's hue belongs to the plates: what can be pressed is ink.
        .tint(MetricLook.ink)
    }
}

// MARK: Sample content

private struct AirRoom: Identifiable {
    var id: String { name }
    let name: String
    let co2: Int?
    var picture: String?
    var symbol = "bed.double.fill"

    var state: MetricState {
        guard let co2 else { return .idle }
        return co2 < 800 ? .fresh : co2 < 1200 ? .stuffy : .poor
    }

    var reading: String? { co2.map { $0.formatted() } }

    static let bedroom = AirRoom(name: "Bedroom", co2: 842)
    static let sample = [
        bedroom,
        AirRoom(name: "Study", co2: 612, picture: "plant-on-a-desk"),
        AirRoom(name: "Living room", co2: 540, picture: "succulent"),
        AirRoom(name: "Hallway", co2: nil, symbol: "door.left.hand.open"),
    ]
}

// MARK: Home: every room

/// The room that most needs air leads, as the plate. Every other room is one
/// row that ends in a small plate of the same colours.
private struct MetricHome: View {
    private enum Phase { case loaded, loading, offline }

    @State private var rooms: [AirRoom]
    @State private var phase: Phase
    @State private var isPairing = false
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _rooms = State(initialValue: screen == "empty" ? [] : AirRoom.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
    }

    var body: some View {
        Group {
            if rooms.isEmpty { empty } else { list }
        }
        .background(MetricLook.ground)
        .navigationTitle("Air")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    MetricNotice(
                        title: isTrying ? "Trying…" : "Can’t reach the sensors",
                        message: "These are the last readings, from 9:12.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 16)
                }
                if phase == .loading {
                    RoundedRectangle(cornerRadius: MetricLook.plateRadius).fill(MetricLook.idle.fill)
                        .frame(height: 196)
                    ForEach(0..<3, id: \.self) { _ in MetricGhostRow() }
                        .padding(.top, 0)
                } else if let lead = rooms.first {
                    NavigationLink {
                        MetricRoom(room: lead, opens: nil)
                    } label: {
                        MetricHeroPlate(
                            label: "\(lead.name) · CO₂", value: lead.reading ?? "–", unit: "ppm",
                            state: phase == .offline ? .idle : lead.state)
                    }
                    .buttonStyle(MetricPressStyle())
                    VStack(spacing: 0) {
                        ForEach(rooms.dropFirst()) { room in
                            NavigationLink {
                                MetricRoom(room: room, opens: nil)
                            } label: {
                                MetricPartRow(name: room.name) {
                                    if let picture = room.picture {
                                        MetricPicture(form: form(picture))
                                    } else {
                                        MetricGlyphTile(symbol: room.symbol)
                                    }
                                } end: {
                                    MetricChip(value: room.reading, state: phase == .offline ? .idle : room.state)
                                }
                            }
                            .buttonStyle(MetricPressStyle())
                        }
                        Rectangle().fill(MetricLook.rule).frame(height: 1)
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal, MetricLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            MetricEmptyPlate()
            Text("No sensor yet")
                .font(MetricLook.emptyTitle)
                .foregroundStyle(MetricLook.ink)
                .padding(.top, 20)
            Button {
                Task { await pair() }
            } label: {
                if isPairing {
                    HStack(spacing: 8) {
                        ProgressView().tint(MetricLook.ground)
                        Text("Looking nearby…")
                    }
                } else {
                    Text("Pair a sensor")
                }
            }
            .buttonStyle(MetricMainButtonStyle(isBusy: isPairing))
            .allowsHitTesting(!isPairing)
            .frame(maxWidth: 260)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private func form(_ picture: String) -> PictureForm {
        switch opens {
        case "home-waiting": .waiting
        case "home-failed": .failed
        default: .loaded(.sample(picture))
        }
    }

    private func pair() async {
        isPairing = true
        try? await Task.sleep(for: .seconds(2.5))
        isPairing = false
        withAnimation { rooms = [AirRoom(name: "New sensor", co2: 498)] }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

/// A plate or a row that opens something dims while it is pressed, and
/// shows no chevron: every one of them opens.
private struct MetricPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: One room, and its alert

private struct MetricRoom: View {
    let room: AirRoom

    @State private var limit = 1000
    @State private var repeats = "Once"
    @State private var isSetting: Bool
    private let opens: String?

    init(room: AirRoom, opens screen: String?) {
        self.room = room
        opens = screen
        _isSetting = State(initialValue: screen?.hasPrefix("alert") == true)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MetricHeroPlate(label: "CO₂", value: room.reading ?? "–", unit: "ppm", state: room.state)
                MetricGroupHead(title: "Alert")
                    .padding(.top, MetricLook.groupGap)
                MetricPartRow(name: "Above \(limit.formatted()) ppm", detail: repeats == "Once" ? "once" : repeats.lowercased()) {
                    MetricGlyphTile(symbol: "bell.fill")
                } end: {
                    Button("Change") { isSetting = true }
                        .buttonStyle(MetricTextButtonStyle())
                }
                Rectangle().fill(MetricLook.rule).frame(height: 1)
            }
            .padding(.horizontal, MetricLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(MetricLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSetting) {
            MetricAlertSheet(limit: limit, repeats: repeats, opens: opens) { newLimit, newRepeats in
                limit = newLimit
                repeats = newRepeats
            }
        }
    }
}

/// One number leads the sheet. The button's words say where the action stands.
private struct MetricAlertSheet: View {
    let save: (Int, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var repeats: String
    @State private var atNight = false
    @State private var error: String?
    @State private var isSaving: Bool
    private let staysBusy: Bool

    init(limit: Int, repeats: String, opens screen: String?, save: @escaping (Int, String) -> Void) {
        self.save = save
        staysBusy = screen == "alert-busy"
        _text = State(initialValue: screen == "alert-error" ? "300" : String(limit))
        _repeats = State(initialValue: repeats)
        _error = State(initialValue: screen == "alert-error" ? Self.lowReason : nil)
        _isSaving = State(initialValue: screen == "alert-busy")
    }

    private static let lowReason = "Outdoor air is about 420. Enter 500 or more"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MetricNumberField(name: "Alert above", text: $text, unit: "ppm", error: error)
                    MetricGroupHead(title: "Tell me")
                        .padding(.top, MetricLook.groupGap)
                    MetricSegments(options: ["Once", "Hourly", "Daily"], selection: $repeats)
                    Toggle("At night too", isOn: $atNight)
                        .font(MetricLook.row)
                        .foregroundStyle(MetricLook.ink)
                        .frame(minHeight: MetricLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, MetricLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isSaving ? "Saving…" : "Save alert", action: submit)
                    .buttonStyle(MetricMainButtonStyle(isBusy: isSaving))
                    .allowsHitTesting(!isSaving)
                    .padding(.horizontal, MetricLook.margin)
                    .padding(.bottom, 8)
            }
            .background(MetricLook.ground)
            .navigationTitle("Alert above")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: text) { error = nil }
        }
        .tint(MetricLook.ink)
        .presentationBackground(MetricLook.ground)
    }

    private func submit() {
        guard !isSaving else { return }
        guard let value = Int(text), value >= 500 else {
            error = Self.lowReason
            return
        }
        isSaving = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            save(value, repeats)
            dismiss()
        }
    }
}

// MARK: Household: people, another company's logo, the app's own mark

private struct MetricHousehold: View {
    @State private var link = Link.none
    private enum Link { case none, linking, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MetricGroupHead(title: "People")
                MetricPartRow(name: "Mina") {
                    MetricPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                MetricPartRow(name: "Jonas") {
                    MetricPersonMark(initial: "J")
                } end: {}
                ShareLink(item: "See the air at home: https://example.com/air/join/2207") {
                    MetricPartRow(name: "Invite someone") {
                        MetricPersonMark(initial: nil)
                    } end: {}
                }
                .buttonStyle(MetricPressStyle())
                Rectangle().fill(MetricLook.rule).frame(height: 1)

                MetricGroupHead(title: "Sensors")
                    .padding(.top, MetricLook.groupGap)
                MetricPartRow(name: "Northline") {
                    MetricLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("Linked").foregroundStyle(MetricLook.ink2)
                }
                MetricPartRow(name: "Tempo") {
                    MetricLogoTile { SampleLogo(company: .tempo) }
                } end: {
                    if link == .linked {
                        Text("Linked").foregroundStyle(MetricLook.ink2)
                    } else {
                        Button(link == .linking ? "Linking…" : "Link") { Task { await connect() } }
                            .buttonStyle(MetricTextButtonStyle())
                            .allowsHitTesting(link == .none)
                    }
                }
                Rectangle().fill(MetricLook.rule).frame(height: 1)

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    Image(systemName: "wind")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(MetricLook.ground)
                        .frame(width: MetricLook.rowLead, height: MetricLook.rowLead)
                        .background(MetricLook.ink, in: .rect(cornerRadius: MetricLook.leadRadius))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Air")
                            .font(MetricLook.rowStrong)
                            .foregroundStyle(MetricLook.ink)
                        Text("Version 3.0")
                            .font(MetricLook.detail)
                            .foregroundStyle(MetricLook.ink2)
                    }
                }
                .padding(.top, MetricLook.groupGap)
            }
            .padding(.horizontal, MetricLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(MetricLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Home")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func connect() async {
        link = .linking
        try? await Task.sleep(for: .seconds(1.2))
        link = .linked
    }
}

#Preview {
    MetricPartsScreen()
}
