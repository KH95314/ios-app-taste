import SwiftUI

// The parts of look 12 in use, for an invented product: drafts of short
// speeches. Each screen is built only from the look's parts, every line on
// it is monospaced text with a quiet mark, and nothing on it names a part or
// a state. `parts.md` says which part is which and where it is in code.

struct FocusPartsScreen: View {
    /// The screen to open: `drafts` (the default), `empty`, `loading`,
    /// `offline`, `new`, `new-error`, `new-busy`, `shared`, `shared-waiting`,
    /// `shared-failed`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "shared", "shared-waiting", "shared-failed": FocusShared(opens: screen)
            default: FocusDrafts(opens: screen)
            }
        }
        // Controls are ink. The caret keeps the one hue to itself.
        .tint(FocusLook.ink)
    }
}

// MARK: Sample content

private struct SpeechNote: Identifiable {
    var id: String { title }
    let title: String
    let length: String

    static let sample = [
        SpeechNote(title: "Toast for Hana and Ilya", length: "1:50"),
        SpeechNote(title: "Thanks at the allotment", length: "0:45"),
        SpeechNote(title: "Opening the book fair", length: "3:10"),
    ]
}

// MARK: Drafts

/// The draft last worked on leads, a step larger. The rest are lines. Each
/// line ends in how long it takes to say.
private struct FocusDrafts: View {
    private enum Phase { case loaded, loading, offline }

    @State private var drafts: [SpeechNote]
    @State private var phase: Phase
    @State private var isAdding: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _drafts = State(initialValue: screen == "empty" ? [] : SpeechNote.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isAdding = State(initialValue: screen?.hasPrefix("new") == true)
    }

    var body: some View {
        Group {
            if drafts.isEmpty { empty } else { list }
        }
        .background(FocusLook.ground)
        .navigationTitle("Drafts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !drafts.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("New draft", systemImage: "plus") { isAdding = true }
                }
            }
        }
        .sheet(isPresented: $isAdding) {
            FocusNewDraft(taken: drafts.map { $0.title.lowercased() }, opens: opens) { title, length in
                withAnimation { drafts.insert(SpeechNote(title: title, length: length), at: 0) }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    FocusNotice(
                        title: isTrying ? "Trying…" : "Not synced",
                        message: "Your drafts are saved on this iPhone.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 12)
                }
                if phase == .loading {
                    FocusGhostLine(width: 230)
                    FocusGhostLine(width: 190)
                    FocusGhostLine(width: 210)
                } else {
                    ForEach(Array(drafts.enumerated()), id: \.element.id) { index, draft in
                        FocusLine(words: draft.title, isLead: index == 0) {
                            Text("#")
                        } end: {
                            Text(draft.length)
                        }
                    }
                }
            }
            .padding(.horizontal, FocusLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            FocusEmptyPage()
            Text("No drafts")
                .font(FocusLook.emptyTitle)
                .foregroundStyle(FocusLook.ink)
                .padding(.top, 20)
            Button("New draft") { isAdding = true }
                .buttonStyle(FocusMainKeyStyle())
                .frame(width: 200)
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

// MARK: New draft: a sheet

private struct FocusNewDraft: View {
    let taken: [String]
    let add: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var length = "2 min"
    @State private var countsAloud = true
    @State private var error: String?
    @State private var isAdding: Bool
    private let staysBusy: Bool

    init(taken: [String], opens screen: String?, add: @escaping (String, String) -> Void) {
        self.taken = taken
        self.add = add
        staysBusy = screen == "new-busy"
        _title = State(initialValue: screen == "new-error" ? "Opening the book fair" : screen == "new-busy" ? "Leaving do for Marek" : "")
        _error = State(initialValue: screen == "new-error" ? Self.takenReason : nil)
        _isAdding = State(initialValue: screen == "new-busy")
    }

    private static let takenReason = "a draft already has this title"
    private var trimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FocusField(mark: "#", name: "Title", text: $title, prompt: "Title", error: error, onSubmit: submit)
                    FocusGroupHead(title: "aim for")
                        .padding(.top, FocusLook.groupGap)
                    FocusKeys(options: ["1 min", "2 min", "5 min"], selection: $length)
                    Toggle("Count the seconds as I type", isOn: $countsAloud)
                        .font(FocusLook.line)
                        .foregroundStyle(FocusLook.ink)
                        .tint(FocusLook.ink)
                        .frame(minHeight: FocusLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, FocusLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isAdding ? "Starting…" : "Start draft", action: submit)
                    .buttonStyle(FocusMainKeyStyle(isBusy: isAdding))
                    .disabled(trimmed.isEmpty)
                    .allowsHitTesting(!isAdding)
                    .padding(.horizontal, FocusLook.margin)
                    .padding(.bottom, 8)
            }
            .background(FocusLook.ground)
            .navigationTitle("New draft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: title) { error = nil }
        }
        .tint(FocusLook.ink)
        .presentationBackground(FocusLook.ground)
    }

    private func submit() {
        guard !trimmed.isEmpty, !isAdding else { return }
        guard !taken.contains(trimmed.lowercased()) else {
            error = Self.takenReason
            return
        }
        isAdding = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            add(trimmed, "0:00")
            dismiss()
        }
    }
}

// MARK: Shared: a picture, people, another company's logo, the app's mark

private struct FocusShared: View {
    let opens: String?
    @State private var invited = false

    private var picture: PictureForm {
        switch opens {
        case "shared-waiting": .waiting
        case "shared-failed": .failed
        default: .loaded(.sample("dough-in-hands"))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                FocusLine(words: "Thanks at the allotment", isLead: true) {
                    Text("#")
                } end: {
                    Text("0:45")
                }
                FocusPicture(form: picture)
                    .padding(.leading, FocusLook.rowLead)
                    .padding(.top, 4)

                FocusGroupHead(title: "can read it")
                    .padding(.top, FocusLook.groupGap)
                FocusLine(words: "Mina") {
                    FocusPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                FocusLine(words: "Jonas") {
                    FocusPersonMark(initial: "J")
                } end: {}
                FocusLine(words: invited ? "Marek" : "nobody else yet", isQuiet: !invited) {
                    FocusPersonMark(initial: invited ? "M" : nil)
                } end: {
                    if !invited {
                        Button("add Marek") { withAnimation { invited = true } }
                            .buttonStyle(FocusBracketButtonStyle())
                    }
                }

                FocusGroupHead(title: "synced with")
                    .padding(.top, FocusLook.groupGap)
                FocusLine(words: "Northline Drive") {
                    FocusLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("09:12")
                }

                // The app's own mark belongs here and on the first run, not in a bar.
                FocusLine(words: "Plain") {
                    Text("¶").foregroundStyle(FocusLook.ink)
                } end: {
                    Text("v 1.6")
                }
                .padding(.top, FocusLook.groupGap)
            }
            .padding(.horizontal, FocusLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(FocusLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Shared")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FocusPartsScreen()
}
