import SwiftUI

// The parts of look 14 in use, for an invented product: a library that lends
// art prints. Each screen is built only from the look's parts, the pictures
// are the only colour on it, and nothing on it names a part or a state.
// `parts.md` says which part is which and where it is in code.
//
// The four prints are woodblock prints by Utagawa Hiroshige from The Met's
// open collection, CC0: `../../pictures/CREDITS.md`.

struct MediaPartsScreen: View {
    /// The screen to open: `shelf` (the default), `shelf-waiting`,
    /// `shelf-failed`, `empty`, `loading`, `offline`, `print`,
    /// `print-waiting`, `print-failed`, `print-busy`, `print-done`,
    /// `request`, `request-error`, `request-busy`, `members`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "print", "print-waiting", "print-failed", "print-busy", "print-done":
                MediaPrint(print: .bridge, opens: screen)
            case "members": MediaMembers()
            default: MediaShelf(opens: screen)
            }
        }
        // Controls are black or white and never borrow a colour from a picture.
        .tint(MediaLook.ink)
    }
}

// MARK: Sample content

private struct LentPrint: Identifiable {
    var id: String { title }
    let title: String
    let year: String
    /// A file in the library's pictures, or `nil` for a print not yet in.
    let picture: String?
    /// Width over height.
    let shape: Double
    var due: String

    static let bridge = LentPrint(title: "Sudden Shower", year: "1857", picture: "print-sudden-shower-bridge", shape: 429.0 / 625, due: "collect by Friday")
    static let sample = [
        LentPrint(title: "Twilight Moon", year: "about 1831", picture: "print-twilight-moon", shape: 599.0 / 384, due: "back by Friday"),
        LentPrint(title: "A Snowy Evening", year: "about 1833", picture: "print-snowy-evening", shape: 599.0 / 407, due: "back by 4 December"),
        LentPrint(title: "Shower at Shōno", year: "about 1834", picture: "print-sudden-shower-shono", shape: 599.0 / 406, due: "back by 4 December"),
    ]
}

// MARK: Your shelf: rows that start with a picture

private struct MediaShelf: View {
    private enum Phase { case loaded, loading, offline }

    @State private var prints: [LentPrint]
    @State private var phase: Phase
    @State private var isAsking: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _prints = State(initialValue: screen == "empty" ? [] : LentPrint.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isAsking = State(initialValue: screen?.hasPrefix("request") == true)
    }

    var body: some View {
        Group {
            if prints.isEmpty { empty } else { list }
        }
        .background(MediaLook.ground)
        .navigationTitle("Your shelf")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            if !prints.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Suggest a print", systemImage: "plus") { isAsking = true }
                }
            }
        }
        .sheet(isPresented: $isAsking) {
            MediaRequest(opens: opens) { title in
                withAnimation {
                    prints.append(LentPrint(title: title, year: "", picture: nil, shape: 1, due: "suggested today"))
                }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    MediaNotice(
                        title: isTrying ? "Trying…" : "You’re offline",
                        message: "This is your shelf as of this morning.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 12)
                }
                if phase == .loading {
                    ForEach(0..<3, id: \.self) { _ in MediaGhostRow() }
                } else {
                    ForEach(prints) { print in
                        NavigationLink {
                            MediaPrint(print: print, opens: nil)
                        } label: {
                            MediaRow(name: print.title, detail: print.due) {
                                MediaThumb(form: form(print.picture))
                            } end: {}
                        }
                        .buttonStyle(MediaPressStyle())
                        .disabled(print.picture == nil)
                    }
                }
            }
            .padding(.horizontal, MediaLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            MediaEmptyFrames()
            Text("Nothing on your shelf")
                .font(MediaLook.emptyTitle)
                .foregroundStyle(MediaLook.ink)
                .padding(.top, 20)
            NavigationLink("See this week’s print") {
                MediaPrint(print: .bridge, opens: nil)
            }
            .buttonStyle(MediaMainButtonStyle())
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private func form(_ picture: String?) -> PictureForm {
        guard let picture else { return .waiting }
        switch opens {
        case "shelf-waiting": return .waiting
        case "shelf-failed": return .failed
        default: return .loaded(.sample(picture))
        }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

/// A row that opens something dims while it is pressed and shows no chevron.
private struct MediaPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: One print: the picture leads

/// The picture is most of the screen, at its own shape. Its one action is on
/// it, and the action's words say where it stands.
private struct MediaPrint: View {
    private enum Step { case free, reserving, reserved }

    let print: LentPrint
    @State private var step: Step
    @State private var size = "36 × 50 cm"
    private let opens: String?

    init(print: LentPrint, opens screen: String?) {
        self.print = print
        opens = screen
        _step = State(initialValue: screen == "print-busy" ? .reserving : screen == "print-done" ? .reserved : .free)
    }

    private var form: PictureForm {
        switch opens {
        case "print-waiting": .waiting
        case "print-failed": .failed
        default: .loaded(.sample(print.picture ?? ""))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MediaHero(
                    form: form, shape: print.shape, title: print.title, facts: "Utagawa Hiroshige · \(print.year)",
                    badge: step == .reserved ? "Reserved · collect by Friday" : nil, badgeSymbol: "checkmark") {
                    Button {
                        Task { await press() }
                    } label: {
                        switch step {
                        case .free: Text("Reserve")
                        case .reserving: Text("Reserving…")
                        case .reserved: Text("Cancel")
                        }
                    }
                    .buttonStyle(MediaOnPictureButtonStyle(isOutline: step == .reserved))
                    .allowsHitTesting(step != .reserving)
                    .fixedSize()
                }
                HStack(spacing: 8) {
                    ForEach(["24 × 36 cm", "36 × 50 cm"], id: \.self) { option in
                        Button(option) { size = option }
                            .buttonStyle(MediaChipStyle(isOn: size == option))
                    }
                }
                .padding(.top, 12)
                MediaRow(name: "Northline Framing") {
                    MediaLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("Frames it").foregroundStyle(MediaLook.ink2)
                }
            }
            .padding(.horizontal, MediaLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(MediaLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func press() async {
        if step == .reserved {
            step = .free
            return
        }
        step = .reserving
        try? await Task.sleep(for: .seconds(1.2))
        guard opens != "print-busy" else { return }
        withAnimation { step = .reserved }
    }
}

// MARK: Suggest a print: a sheet

private struct MediaRequest: View {
    let send: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var kind = "Woodblock"
    @State private var tellMe = true
    @State private var error: String?
    @State private var isSending: Bool
    private let staysBusy: Bool

    init(opens screen: String?, send: @escaping (String) -> Void) {
        self.send = send
        staysBusy = screen == "request-busy"
        _title = State(initialValue: screen == "request-error" ? "Twilight Moon" : screen == "request-busy" ? "The Great Wave" : "")
        _error = State(initialValue: screen == "request-error" ? Self.heldReason : nil)
        _isSending = State(initialValue: screen == "request-busy")
    }

    private static let heldReason = "The library already has this one"
    private var trimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MediaField(name: "Title", text: $title, prompt: "Its title, or what it shows", error: error, onSubmit: submit)
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(["Woodblock", "Photograph", "Poster", "Drawing"], id: \.self) { option in
                                Button(option) { kind = option }
                                    .buttonStyle(MediaChipStyle(isOn: kind == option))
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.top, 16)
                    Toggle("Tell me when it arrives", isOn: $tellMe)
                        .font(MediaLook.row)
                        .foregroundStyle(MediaLook.ink)
                        .frame(minHeight: 56)
                        .padding(.top, 8)
                }
                .padding(.horizontal, MediaLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isSending ? "Sending…" : "Send suggestion", action: submit)
                    .buttonStyle(MediaMainButtonStyle(isBusy: isSending, isWide: true))
                    .disabled(trimmed.isEmpty)
                    .allowsHitTesting(!isSending)
                    .padding(.horizontal, MediaLook.margin)
                    .padding(.bottom, 8)
            }
            .background(MediaLook.ground)
            .navigationTitle("Suggest a print")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: title) { error = nil }
        }
        .tint(MediaLook.ink)
        .presentationBackground(MediaLook.ground)
    }

    private func submit() {
        guard !trimmed.isEmpty, !isSending else { return }
        guard !LentPrint.sample.contains(where: { $0.title.lowercased() == trimmed.lowercased() }) else {
            error = Self.heldReason
            return
        }
        isSending = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            send(trimmed)
            dismiss()
        }
    }
}

// MARK: Members: people, another company's logo, the app's own mark

private struct MediaMembers: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MediaGroupHead(title: "On this card")
                MediaRow(name: "Mina") {
                    MediaPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                MediaRow(name: "Jonas") {
                    MediaPersonMark(initial: "J")
                } end: {}
                ShareLink(item: "Share my Paper Room card: https://example.com/paper-room/card/5530") {
                    MediaRow(name: "Add someone") {
                        MediaPersonMark(initial: nil)
                    } end: {}
                }
                .buttonStyle(MediaPressStyle())

                MediaGroupHead(title: "Framing")
                    .padding(.top, MediaLook.groupGap)
                MediaRow(name: "Northline Framing", detail: "Mill Street, open until 6") {
                    MediaLogoTile { SampleLogo(company: .northline) }
                } end: {}

                // The app's own mark belongs here and on the first run, not in a bar.
                MediaRow(name: "Paper Room", detail: "Version 4.2") {
                    Image(systemName: "photo.artframe")
                        .font(.headline)
                        .foregroundStyle(MediaLook.ground)
                        .frame(width: 44, height: 44)
                        .background(MediaLook.ink, in: .rect(cornerRadius: MediaLook.leadRadius))
                } end: {}
                .padding(.top, MediaLook.groupGap)
            }
            .padding(.horizontal, MediaLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(MediaLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Card")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

#Preview {
    MediaPartsScreen()
}
