import SwiftUI

// The parts of look 11 in use, for an invented product: a finder for public
// drinking-water refill points, the product of the look's accepted entry.
// Each screen is built only from the look's parts, one thing leads it, and
// nothing on it names a part or a state. `parts.md` says which part is which
// and where it is in code.
//
// The layer underneath is drawn here, not Apple's map: map tiles cannot be
// in the library's pictures, and a live map does not hold still.

struct LayerPartsScreen: View {
    /// The screen to open: `map` (the default), `empty`, `loading`,
    /// `offline`, `add`, `add-error`, `add-busy`, `point`, `point-waiting`,
    /// `point-failed`, `point-plain`, `keepers`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "keepers": LayerKeepers()
            case let screen? where screen.hasPrefix("point"): LayerPointAlone(opens: screen)
            default: LayerMapScreen(opens: screen)
            }
        }
        // A surface's controls are ink. Colour stays with the layer underneath.
        .tint(LayerLook.ink)
    }
}

// MARK: Sample content

private struct LayerSpot: Identifiable, Equatable {
    let id: Int
    var name: String
    var distance: String
    var walk: String
    var isWorking = true
    var isReported = false
    var checked: String
    var features: [String]
    /// Where its pin stands on the plan, as shares of the clear part.
    var x: Double
    var y: Double
    var hasPicture = true

    var isUsable: Bool { isWorking && !isReported }

    var state: String {
        if isReported { return "Problem reported" }
        return isWorking ? "Working · checked \(checked)" : "Reported not working · \(checked)"
    }

    var tone: StatusBadge.Tone { isUsable ? .ok : .warning }

    /// Invented points in an invented park.
    static let sample = [
        LayerSpot(id: 1, name: "North gate fountain", distance: "350 m", walk: "5 min walk", checked: "2 days ago",
                  features: ["Bottle filler", "Step-free access", "Dog bowl at ground level"], x: 0.5, y: 0.2),
        LayerSpot(id: 2, name: "Playground refill point", distance: "520 m", walk: "7 min walk", checked: "today",
                  features: ["Bottle filler", "Low spout for children"], x: 0.36, y: 0.47),
        LayerSpot(id: 3, name: "Pond-side tap", distance: "700 m", walk: "9 min walk", isWorking: false, checked: "yesterday",
                  features: ["Hand tap only"], x: 0.74, y: 0.6),
        LayerSpot(id: 4, name: "Amphitheatre fountain", distance: "900 m", walk: "12 min walk", checked: "5 days ago",
                  features: ["Bottle filler", "Step-free access"], x: 0.48, y: 0.86),
    ]
}

// MARK: Nearby: the plan, and a surface over it

/// The nearest point leads the surface and has the large pin. Every other
/// point is one row that starts with its own pin, small.
private struct LayerMapScreen: View {
    private enum Phase { case loaded, loading, offline }

    @State private var spots: [LayerSpot]
    @State private var phase: Phase
    @State private var isAdding: Bool
    @State private var isSearching = false
    @State private var isTrying = false
    @State private var surfaceHeight = 320.0
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _spots = State(initialValue: screen == "empty" ? [] : LayerSpot.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isAdding = State(initialValue: screen?.hasPrefix("add") == true)
    }

    private var pins: [LayerPlan.Pin] {
        guard phase != .loading else { return [] }
        return spots.map {
            LayerPlan.Pin(id: $0.id, x: $0.x, y: $0.y, isWorking: $0.isUsable, leads: $0.id == spots.first?.id)
        }
    }

    var body: some View {
        LayerPlan(pins: pins, covered: surfaceHeight)
            .overlay(alignment: .bottom) {
                LayerSurface { surface }
                    .onGeometryChange(for: Double.self) { $0.size.height } action: { surfaceHeight = $0 }
            }
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
            // The plan has no place for a title, and the surface's lead says
            // what the screen is for.
            .toolbar(removing: .title)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        LayerKeepers()
                    } label: {
                        Label("Keepers", systemImage: "person.2")
                    }
                    Button("Add a point", systemImage: "plus") { isAdding = true }
                }
            }
            .sheet(isPresented: $isAdding) {
                LayerAddSheet(taken: spots.map(\.name), opens: opens) { name, kind, isStepFree in
                    withAnimation(.snappy) {
                        spots.append(LayerSpot(
                            id: (spots.map(\.id).max() ?? 0) + 1, name: name, distance: "1.1 km", walk: "14 min walk",
                            checked: "just now", features: [kind] + (isStepFree ? ["Step-free access"] : []),
                            x: 0.82, y: 0.3, hasPicture: false))
                    }
                }
            }
    }

    @ViewBuilder private var surface: some View {
        VStack(alignment: .leading, spacing: 0) {
            if phase == .offline {
                LayerNotice(
                    symbol: "wifi.slash", title: isTrying ? "Trying…" : "You’re offline",
                    message: "Checked at 9:12", actionTitle: "Try again") {
                    Task { await retry() }
                }
                .padding(.bottom, 20)
            }
            if phase == .loading {
                LayerGhostLead()
                    .padding(.bottom, 16)
                ForEach(0..<3, id: \.self) { _ in LayerGhostRow() }
            } else if spots.isEmpty {
                empty
            } else {
                ForEach($spots) { $spot in
                    NavigationLink {
                        LayerPointScreen(spot: $spot, opens: nil)
                    } label: {
                        if spot.id == spots.first?.id {
                            LayerLead(name: spot.name, distance: spot.distance, walk: spot.walk, state: spot.state, tone: spot.tone)
                                .padding(.bottom, 16)
                        } else {
                            LayerPartRow(name: spot.name, detail: spot.isUsable ? nil : "not working") {
                                LayerPin(isWorking: spot.isUsable)
                            } end: {
                                Text(spot.distance)
                                    .font(LayerLook.detail)
                                    .foregroundStyle(LayerLook.ink2)
                            }
                        }
                    }
                    .buttonStyle(LayerPressStyle())
                }
            }
        }
    }

    private var empty: some View {
        VStack(spacing: 0) {
            LayerEmptyPin()
            Text("No refill points within 2 km")
                .font(LayerLook.title)
                .foregroundStyle(LayerLook.ink)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
            Button(isSearching ? "Searching…" : "Search a wider area") {
                Task { await widen() }
            }
            .buttonStyle(LayerMainButtonStyle(isBusy: isSearching))
            .allowsHitTesting(!isSearching)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private func widen() async {
        isSearching = true
        try? await Task.sleep(for: .seconds(2.5))
        isSearching = false
        withAnimation(.snappy) { spots = LayerSpot.sample }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

/// A lead or a row that opens something dims while it is pressed, and shows
/// no chevron: every one of them opens.
private struct LayerPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: Add a point: a sheet with a form

/// The name leads the sheet. The button's words say where the action stands,
/// and a point that was added shows as a new pin and a new row behind it.
private struct LayerAddSheet: View {
    let taken: [String]
    let add: (String, String, Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var kind = "Fountain"
    @State private var isStepFree = false
    @State private var error: String?
    @State private var isSaving: Bool
    private let staysBusy: Bool

    init(taken: [String], opens screen: String?, add: @escaping (String, String, Bool) -> Void) {
        self.taken = taken
        self.add = add
        staysBusy = screen == "add-busy"
        _name = State(initialValue: screen == "add-error" ? "Pond-side tap" : screen == "add-busy" ? "Library steps tap" : "")
        _error = State(initialValue: screen == "add-error" ? Self.takenReason : nil)
        _isSaving = State(initialValue: screen == "add-busy")
    }

    private static let takenReason = "A point with this name is already on the map"

    private var trimmed: String { name.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    LayerField(name: "Name", text: $name, error: error)
                    LayerChoice(options: ["Fountain", "Tap", "Bottle filler"], selection: $kind)
                        .padding(.top, 16)
                    Toggle("Step-free access", isOn: $isStepFree)
                        .font(LayerLook.row)
                        .foregroundStyle(LayerLook.ink)
                        // On, a switch takes the subject's hue, as a pin does.
                        // Ink would lose the knob in dark.
                        .tint(LayerLook.pin)
                        .frame(minHeight: LayerLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, LayerLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollEdgeEffectStyle(.hard, for: .top)
            .safeAreaInset(edge: .bottom) {
                Button(isSaving ? "Adding…" : "Add point", action: submit)
                    .buttonStyle(LayerMainButtonStyle(isBusy: isSaving))
                    .allowsHitTesting(!isSaving)
                    .disabled(trimmed.isEmpty)
                    .padding(.horizontal, LayerLook.margin)
                    .padding(.bottom, 8)
            }
            .background(LayerLook.surface)
            .navigationTitle("New refill point")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: name) { error = nil }
        }
        .tint(LayerLook.ink)
        // A solid ground, so the words are measured on one colour.
        .presentationBackground(LayerLook.surface)
    }

    private func submit() {
        guard !isSaving else { return }
        guard !taken.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            error = Self.takenReason
            return
        }
        isSaving = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            add(trimmed, kind, isStepFree)
            dismiss()
        }
    }
}

// MARK: One point: a picture underneath, a surface over its lower edge

private struct LayerPointAlone: View {
    @State private var spot: LayerSpot
    private let opens: String

    init(opens screen: String) {
        opens = screen
        var spot = LayerSpot.sample[0]
        spot.hasPicture = screen != "point-plain"
        _spot = State(initialValue: spot)
    }

    var body: some View {
        LayerPointScreen(spot: $spot, opens: opens)
    }
}

/// The point's name leads the surface. Its picture is the layer underneath;
/// a point with no picture gets the plan there, with its own pin.
private struct LayerPointScreen: View {
    @Binding var spot: LayerSpot
    let opens: String?

    @State private var isSaving = false
    @State private var isReporting = false

    private var form: PictureForm {
        switch opens {
        case "point-waiting": .waiting
        case "point-failed": .failed
        default: .loaded(SampleFountain.picture)
        }
    }

    private var isFresh: Bool { spot.isUsable && spot.checked == "just now" }

    var body: some View {
        // The surface lies over the layer's lower edge by its own corner.
        VStack(spacing: -LayerLook.surfaceRadius) {
            if spot.hasPicture {
                LayerPicture(form: form)
                    .ignoresSafeArea(edges: .top)
            } else {
                LayerPlan(
                    pins: [LayerPlan.Pin(id: spot.id, x: 0.5, y: 0.5, isWorking: spot.isUsable, leads: true)],
                    covered: LayerLook.surfaceRadius)
            }
            LayerSurface {
                VStack(alignment: .leading, spacing: 0) {
                    LayerLead(name: spot.name, distance: spot.distance, walk: spot.walk, state: spot.state, tone: spot.tone)
                    LayerGroupHead(title: "At this point")
                        .padding(.top, LayerLook.groupGap)
                    ForEach(spot.features, id: \.self) { feature in
                        LayerPartRow(name: feature) {
                            LayerGlyph(symbol: "checkmark")
                        } end: {}
                    }
                    HStack(spacing: 8) {
                        Button(isSaving ? "Saving…" : "Still working") {
                            Task { await confirm() }
                        }
                        .buttonStyle(LayerMainButtonStyle(isBusy: isSaving))
                        .allowsHitTesting(!isSaving)
                        .disabled(isFresh)
                        Button("Report a problem") { isReporting = true }
                            .buttonStyle(LayerButtonStyle(kind: .second))
                            .fixedSize()
                            .disabled(spot.isReported)
                            .confirmationDialog("What’s wrong with this refill point?", isPresented: $isReporting, titleVisibility: .visible) {
                                Button("Not working") { spot.isReported = true }
                                Button("Dirty or blocked") { spot.isReported = true }
                            }
                    }
                    .padding(.top, 16)
                }
                // The badge changes its words in place, at once.
                .animation(nil, value: spot)
            }
        }
        .background(LayerLook.surface)
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
        // The drawn picture is light at its top in both appearances.
        .toolbarColorScheme(spot.hasPicture && opens == nil || opens == "point" ? .light : nil, for: .navigationBar)
    }

    private func confirm() async {
        isSaving = true
        try? await Task.sleep(for: .seconds(2.5))
        isSaving = false
        spot.isWorking = true
        spot.isReported = false
        spot.checked = "just now"
    }
}

/// A drawing of a drinking fountain in a park, standing in for a photograph.
/// Its colours are its own. A real product shows its own pictures here.
private struct SampleFountain: View {
    static let picture: Image = {
        let renderer = ImageRenderer(content: SampleFountain().frame(width: 400, height: 500))
        renderer.scale = 2
        return renderer.uiImage.map(Image.init(uiImage:)) ?? Image(systemName: "photo")
    }()

    var body: some View {
        Canvas { context, size in
            let w = size.width / 40
            let h = size.height / 50
            func box(_ x: Double, _ y: Double, _ width: Double, _ height: Double, _ hex: UInt32, radius: Double = 0) {
                context.fill(
                    Path(roundedRect: CGRect(x: x * w, y: y * h, width: width * w, height: height * h), cornerRadius: radius * w),
                    with: .color(Color(fixed: hex)))
            }
            func oval(_ x: Double, _ y: Double, _ width: Double, _ height: Double, _ hex: UInt32) {
                context.fill(
                    Path(ellipseIn: CGRect(x: x * w, y: y * h, width: width * w, height: height * h)),
                    with: .color(Color(fixed: hex)))
            }
            box(0, 0, 40, 50, 0xCFE4F2)
            oval(-8, 10, 30, 20, 0x8DB58A)
            oval(16, 8, 34, 24, 0x7BA87C)
            box(0, 24, 40, 26, 0xA9CC8E)
            oval(4, 34, 32, 9, 0xD9D2C2)
            // The fountain: a stone post, a bowl and an arc of water.
            box(17, 20, 6, 18, 0x9A9FA6, radius: 1)
            box(13.5, 18, 13, 3.4, 0xB4B9BF, radius: 1.5)
            box(21.5, 15.6, 1.6, 2.6, 0x6F757D, radius: 0.4)
            var water = Path()
            water.move(to: CGPoint(x: 22.2 * w, y: 15.6 * h))
            water.addQuadCurve(to: CGPoint(x: 16.5 * w, y: 18 * h), control: CGPoint(x: 18.5 * w, y: 11.5 * h))
            context.stroke(water, with: .color(Color(fixed: 0xFFFFFF)), style: StrokeStyle(lineWidth: 0.7 * w, lineCap: .round))
        }
    }
}

// MARK: Keepers: people, another company's logo, the app's own mark

/// A surface with no layer under it: a plain screen on the surface's ground.
private struct LayerKeepers: View {
    @State private var tookIt = false
    @State private var link = Link.none
    private enum Link { case none, linking, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                LayerPartRow(name: "Mina", detail: "North gate fountain") {
                    LayerPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                LayerPartRow(name: "Jonas", detail: "Playground refill point") {
                    LayerPersonMark(initial: "J")
                } end: {}
                LayerPartRow(name: tookIt ? "You" : "Nobody yet", detail: "Amphitheatre fountain") {
                    LayerPersonMark(initial: tookIt ? "Y" : nil)
                } end: {
                    if !tookIt {
                        Button("Take it") { tookIt = true }
                            .buttonStyle(LayerSmallButtonStyle())
                    }
                }
                Rectangle().fill(LayerLook.rule).frame(height: 1)

                LayerGroupHead(title: "Water data")
                    .padding(.top, LayerLook.groupGap)
                LayerPartRow(name: "Northline") {
                    LayerLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("Linked")
                        .font(LayerLook.detail)
                        .foregroundStyle(LayerLook.ink2)
                }
                LayerPartRow(name: "Tempo") {
                    LayerLogoTile { SampleLogo(company: .tempo) }
                } end: {
                    if link == .linked {
                        Text("Linked")
                            .font(LayerLook.detail)
                            .foregroundStyle(LayerLook.ink2)
                    } else {
                        Button(link == .linking ? "Linking…" : "Link") { Task { await connect() } }
                            .buttonStyle(LayerSmallButtonStyle())
                            .allowsHitTesting(link == .none)
                    }
                }
                Rectangle().fill(LayerLook.rule).frame(height: 1)

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    Image(systemName: "drop.fill")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(LayerLook.onAction)
                        .frame(width: LayerLook.rowLead, height: LayerLook.rowLead)
                        .background(LayerLook.action, in: .rect(cornerRadius: LayerLook.leadRadius))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Refill")
                            .font(LayerLook.rowStrong)
                            .foregroundStyle(LayerLook.ink)
                        Text("Version 2.1")
                            .font(LayerLook.detail)
                            .foregroundStyle(LayerLook.ink2)
                    }
                }
                .padding(.top, LayerLook.groupGap)
            }
            .padding(.horizontal, LayerLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(LayerLook.surface)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Keepers")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func connect() async {
        link = .linking
        try? await Task.sleep(for: .seconds(1.2))
        link = .linked
    }
}

#Preview {
    LayerPartsScreen()
}
