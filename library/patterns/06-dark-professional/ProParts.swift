import SwiftUI

// The parts of look 06 in use, for an invented product: a field recorder's
// takes. Each screen is built only from the look's parts, the selected take
// is the only lit thing on it, and nothing on it names a part or a state.
// `parts.md` says which part is which and where it is in code.

struct ProPartsScreen: View {
    /// The screen to open: `takes` (the default), `empty`, `loading`,
    /// `offline`, `export`, `export-error`, `export-busy`, `session`,
    /// `session-waiting`, `session-failed`.
    var screen: String?

    var body: some View {
        NavigationStack {
            Group {
                switch screen {
                case "session", "session-waiting", "session-failed": ProSession(opens: screen)
                default: ProTakes(opens: screen)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(ProLook.ink)
        // The look is black in both appearances.
        .preferredColorScheme(.dark)
    }
}

// MARK: Sample content

private struct RecordedTake: Identifiable {
    var id: String { name }
    var name: String
    let length: String
    var format: String?
    let seed: Int

    /// A fixed shape for each take, so screenshots match.
    var levels: [Double] {
        (0..<64).map { index in
            let wave = sin(Double(index + seed * 7) * 0.45) * 0.3 + sin(Double(index * seed + 3) * 0.17) * 0.25
            return min(1, max(0.06, 0.42 + wave))
        }
    }

    static let sample = [
        RecordedTake(name: "cello_take_03", length: "04:12", seed: 3),
        RecordedTake(name: "cello_take_02", length: "03:58", format: "WAV", seed: 2),
        RecordedTake(name: "cello_take_01", length: "01:07", seed: 5),
        RecordedTake(name: "room_tone", length: "00:30", seed: 8),
    ]
}

// MARK: Takes

/// The selected take leads as its sound, with its figures under it. Every
/// other take is one row. Selecting a row moves the light to it.
private struct ProTakes: View {
    private enum Phase { case loaded, loading, offline }

    @State private var takes: [RecordedTake]
    @State private var selected: String
    @State private var phase: Phase
    @State private var isExporting: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _takes = State(initialValue: screen == "empty" ? [] : RecordedTake.sample)
        _selected = State(initialValue: RecordedTake.sample[0].id)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isExporting = State(initialValue: screen?.hasPrefix("export") == true)
    }

    private var lead: RecordedTake? { takes.first { $0.id == selected } ?? takes.first }

    var body: some View {
        Group {
            if takes.isEmpty { empty } else { list }
        }
        .background(ProLook.ground)
        .navigationTitle("Takes")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isExporting) {
            if let lead {
                ProExport(take: lead, taken: takes.map(\.name), opens: opens) { name, format in
                    guard let index = takes.firstIndex(where: { $0.id == lead.id }) else { return }
                    takes[index].name = name
                    takes[index].format = format
                    selected = name
                }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    ProNotice(title: isTrying ? "Trying…" : "Recorder not connected") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 16)
                }
                if phase == .loading {
                    ProWave(levels: RecordedTake.sample[0].levels, isQuiet: true)
                        .frame(height: 96)
                    ForEach(0..<4, id: \.self) { _ in ProGhostRow() }
                        .padding(.top, 0)
                } else if let lead {
                    ProWave(levels: lead.levels, played: 0.38)
                        .frame(height: 96)
                    HStack(alignment: .top) {
                        ProReadout(label: "Length", value: lead.length)
                        ProReadout(label: "Format", value: lead.format ?? "raw")
                        Button("Export") { isExporting = true }
                            .buttonStyle(ProSideButtonStyle())
                            .frame(width: 110)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    ForEach(takes) { take in
                        Button {
                            selected = take.id
                        } label: {
                            ProRow(name: take.name, isSelected: take.id == lead.id) {
                                ProGlyphTile(symbol: take.id == lead.id ? "waveform" : "play.fill")
                            } end: {
                                Text(take.length)
                            }
                            .overlay(alignment: .leading) {
                                if take.id == lead.id {
                                    Rectangle().fill(ProLook.accent).frame(width: 3).padding(.vertical, 10).offset(x: -ProLook.margin)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    Rectangle().fill(ProLook.rule).frame(height: 1)
                }
            }
            .padding(.horizontal, ProLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            ProWave(levels: Array(repeating: 0.04, count: 40), isQuiet: true)
                .frame(width: 200, height: 40)
            Text("No takes yet")
                .font(ProLook.emptyTitle)
                .foregroundStyle(ProLook.ink)
                .padding(.top, 20)
            Button("Import from the recorder") {
                withAnimation { takes = RecordedTake.sample }
            }
            .buttonStyle(ProSideButtonStyle())
            .frame(width: 250)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

// MARK: Export: a sheet

private struct ProExport: View {
    let taken: [String]
    let original: String
    let export: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var format = "WAV"
    @State private var normalise = false
    @State private var error: String?
    @State private var isExporting: Bool
    private let staysBusy: Bool

    init(take: RecordedTake, taken: [String], opens screen: String?, export: @escaping (String, String) -> Void) {
        self.taken = taken
        self.export = export
        original = take.name
        staysBusy = screen == "export-busy"
        _name = State(initialValue: screen == "export-error" ? "room_tone" : take.name)
        _error = State(initialValue: screen == "export-error" ? Self.takenReason : nil)
        _isExporting = State(initialValue: screen == "export-busy")
    }

    private static let takenReason = "Another take has this name"
    private var trimmed: String { name.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ProField(label: "Name", text: $name, error: error)
                    ProGroupHead(title: "Format")
                        .padding(.top, ProLook.groupGap)
                    ProKeys(options: ["WAV", "FLAC", "MP3"], selection: $format)
                    Toggle("Normalise to −1 dB", isOn: $normalise)
                        .font(.body)
                        .foregroundStyle(ProLook.ink)
                        .tint(ProLook.accent)
                        .frame(minHeight: ProLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, ProLook.margin)
                .padding(.top, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isExporting ? "Exporting…" : "Export", action: submit)
                    .buttonStyle(ProMainButtonStyle(isBusy: isExporting))
                    .disabled(trimmed.isEmpty)
                    .allowsHitTesting(!isExporting)
                    .padding(.horizontal, ProLook.margin)
                    .padding(.bottom, 8)
            }
            .background(ProLook.panel)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: name) { error = nil }
        }
        .tint(ProLook.ink)
        .preferredColorScheme(.dark)
        .presentationBackground(ProLook.panel)
    }

    private func submit() {
        guard !trimmed.isEmpty, !isExporting else { return }
        guard trimmed == original || !taken.contains(trimmed) else {
            error = Self.takenReason
            return
        }
        isExporting = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            export(trimmed, format)
            dismiss()
        }
    }
}

// MARK: Session: a picture, people, another company's logo, the app's mark

private struct ProSession: View {
    let opens: String?
    @State private var hasSecond = false

    private var picture: PictureForm {
        switch opens {
        case "session-waiting": .waiting
        case "session-failed": .failed
        default: .loaded(.sample("cello"))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    ProPicture(form: picture)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cello, hall B")
                            .font(ProLook.title)
                            .foregroundStyle(ProLook.ink)
                        ProReadout(label: "Recorded", value: "09:47")
                    }
                }
                ProGroupHead(title: "Crew")
                    .padding(.top, ProLook.groupGap)
                ProRow(name: "Mina Sato") {
                    ProPersonMark(photo: SampleFace(person: .mina))
                } end: {
                    Text("ENG")
                }
                ProRow(name: "Jonas Berg") {
                    ProPersonMark(initials: "JB")
                } end: {
                    Text("CELLO")
                }
                ProRow(name: hasSecond ? "You" : "Nobody yet", isQuiet: !hasSecond) {
                    ProPersonMark(initials: hasSecond ? "YO" : nil)
                } end: {
                    if !hasSecond {
                        Button("Take it") { withAnimation { hasSecond = true } }
                            .buttonStyle(ProTextButtonStyle())
                    }
                    Text("2ND")
                }
                Rectangle().fill(ProLook.rule).frame(height: 1)

                ProGroupHead(title: "Interface")
                    .padding(.top, ProLook.groupGap)
                ProRow(name: "Tempo 4i") {
                    ProLogoTile { SampleLogo(company: .tempo) }
                } end: {
                    Text("48 kHz")
                }
                Rectangle().fill(ProLook.rule).frame(height: 1)

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(ProLook.ground)
                        .frame(width: ProLook.rowLead, height: ProLook.rowLead)
                        .background(ProLook.ink, in: .rect(cornerRadius: ProLook.leadRadius))
                    ProReadout(label: "Fieldnote", value: "2.4.1")
                }
                .padding(.top, ProLook.groupGap)
            }
            .padding(.horizontal, ProLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(ProLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProPartsScreen()
}
