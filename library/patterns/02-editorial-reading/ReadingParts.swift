import SwiftUI

// The parts of look 02 in use, for an invented product: a weekly magazine of
// long reads. Each screen is built only from the look's parts, type does the
// work on it, and nothing on it names a part or a state. `parts.md` says
// which part is which and where it is in code.

struct ReadingPartsScreen: View {
    /// The screen to open: `issue` (the default), `issue-waiting`,
    /// `issue-failed`, `empty`, `loading`, `offline`, `masthead`, `letter`,
    /// `letter-error`, `letter-busy`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "masthead", "letter", "letter-error", "letter-busy": ReadingMasthead(opens: screen)
            default: ReadingIssue(opens: screen)
            }
        }
        // The look's one hue, for links and for what can be pressed.
        .tint(ReadingLook.accent)
    }
}

// MARK: Sample content

private struct Story: Identifiable {
    var id: String { title }
    let title: String
    let byline: String

    static let lead = Story(title: "The Bridge That Counts Bicycles", byline: "Ines Okafor · 9 min")
    static let more = [
        Story(title: "A Cello Older Than the Country", byline: "Tomas Reyes · 14 min"),
        Story(title: "What the Rain Did to the Timetable", byline: "Mina Sato · 6 min"),
        Story(title: "Bread, Proved Twice", byline: "Jonas Berg · 11 min"),
    ]
}

// MARK: This week's issue

/// One story leads, with its picture. The rest are titles. A story is kept
/// with the bookmark at the end of its row, which fills.
private struct ReadingIssue: View {
    private enum Phase { case loaded, loading, offline }

    @State private var stories: [Story]
    @State private var kept: Set<String> = ["Bread, Proved Twice"]
    @State private var phase: Phase
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _stories = State(initialValue: screen == "empty" ? [] : Story.more)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
    }

    private var picture: PictureForm {
        switch opens {
        case "issue-waiting": .waiting
        case "issue-failed": .failed
        default: .loaded(.sample("bicycle-by-a-bridge"))
        }
    }

    var body: some View {
        Group {
            if stories.isEmpty { empty } else { page }
        }
        .background(ReadingLook.paper)
        .navigationTitle("This week")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var page: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    ReadingNotice(
                        title: isTrying ? "Trying…" : "You’re offline",
                        message: "This is last week’s issue, which is saved on this iPhone.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 20)
                }
                if phase == .loading {
                    ReadingPicture(form: .waiting)
                        .padding(.bottom, 20)
                    ForEach(0..<4, id: \.self) { _ in ReadingGhostRow() }
                } else {
                    ReadingLead(kicker: "The long way round", title: Story.lead.title, byline: Story.lead.byline, picture: picture)
                        .padding(.bottom, 24)
                    ForEach(stories) { story in
                        ReadingStoryRow(title: story.title, byline: story.byline) {
                            Button {
                                if kept.contains(story.id) { kept.remove(story.id) } else { kept.insert(story.id) }
                            } label: {
                                Image(systemName: kept.contains(story.id) ? "bookmark.fill" : "bookmark")
                                    .font(.body)
                                    .foregroundStyle(kept.contains(story.id) ? ReadingLook.accent : ReadingLook.ink2)
                                    .frame(width: 44, height: 44)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("keep")
                        }
                    }
                    Rectangle().fill(ReadingLook.rule).frame(height: 1)
                }
            }
            .padding(.horizontal, ReadingLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            ReadingEmptyPage()
            Text("No issue this week")
                .font(ReadingLook.emptyTitle)
                .foregroundStyle(ReadingLook.ink)
                .padding(.top, 24)
            Button("Read last week’s") {
                withAnimation { stories = Story.more }
            }
            .buttonStyle(ReadingActionStyle())
            .padding(.top, 8)
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

// MARK: Masthead: people, the printer's logo, the app's own mark, letters

private struct ReadingMasthead: View {
    @State private var letters: [String] = []
    @State private var isWriting: Bool
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _isWriting = State(initialValue: screen?.hasPrefix("letter") == true)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ReadingGroupHead(title: "Writers")
                ReadingNameRow(name: "Mina Sato") {
                    ReadingPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                ReadingNameRow(name: "Ines Okafor") {
                    ReadingPersonMark(initial: "I")
                } end: {}
                ReadingNameRow(name: "Next week’s guest", isQuiet: true) {
                    ReadingPersonMark(initial: nil)
                } end: {}

                ReadingGroupHead(title: "Letters")
                    .padding(.top, ReadingLook.groupGap)
                ForEach(letters, id: \.self) { letter in
                    ReadingNameRow(name: letter) {
                        Image(systemName: "envelope")
                            .foregroundStyle(ReadingLook.ink2)
                    } end: {
                        Text("Sent")
                            .font(ReadingLook.byline)
                            .foregroundStyle(ReadingLook.ink2)
                    }
                }
                Button("Write to the editor") { isWriting = true }
                    .buttonStyle(ReadingActionStyle())

                ReadingGroupHead(title: "Printed by")
                    .padding(.top, ReadingLook.groupGap)
                ReadingNameRow(name: "Northline Press") {
                    ReadingLogoTile { SampleLogo(company: .northline) }
                } end: {}

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    Text("L")
                        .font(ReadingLook.rowTitle)
                        .foregroundStyle(ReadingLook.paper)
                        .frame(width: ReadingLook.rowLead, height: ReadingLook.rowLead)
                        .background(ReadingLook.ink, in: .rect(cornerRadius: ReadingLook.pictureRadius))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("The Long Way Round")
                            .font(ReadingLook.name)
                            .foregroundStyle(ReadingLook.ink)
                        Text("Version 5.1")
                            .font(ReadingLook.byline)
                            .foregroundStyle(ReadingLook.ink2)
                    }
                }
                .padding(.top, ReadingLook.groupGap)
            }
            .padding(.horizontal, ReadingLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(ReadingLook.paper)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Masthead")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isWriting) {
            ReadingLetter(opens: opens) { about in
                withAnimation { letters.append(about) }
            }
        }
    }
}

/// The words lead the sheet. The action is a link, off until there are words.
private struct ReadingLetter: View {
    let send: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var words: String
    @State private var about = Story.lead.title
    @State private var printName = true
    @State private var error: String?
    @State private var isSending: Bool
    private let staysBusy: Bool

    init(opens screen: String?, send: @escaping (String) -> Void) {
        self.send = send
        staysBusy = screen == "letter-busy"
        _words = State(initialValue: screen == "letter-error" ? "Lovely." : screen == "letter-busy" ? "The counter on Mill Street has been wrong since March." : "")
        _error = State(initialValue: screen == "letter-error" ? Self.shortReason : nil)
        _isSending = State(initialValue: screen == "letter-busy")
    }

    private static let shortReason = "The editor reads letters of ten words or more"
    private var trimmed: String { words.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ReadingField(name: "Letter", text: $words, prompt: "Dear editor", error: error)
                    ReadingGroupHead(title: "About")
                        .padding(.top, ReadingLook.groupGap)
                    ForEach([Story.lead] + Story.more.prefix(2)) { story in
                        ReadingChoiceRow(name: story.title, isChosen: about == story.title) { about = story.title }
                    }
                    Rectangle().fill(ReadingLook.rule).frame(height: 1)
                        .padding(.vertical, 8)
                    Toggle("Print my name", isOn: $printName)
                        .font(.body)
                        .foregroundStyle(ReadingLook.ink)
                        .frame(minHeight: 48)
                }
                .padding(.horizontal, ReadingLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ReadingLook.paper)
            .navigationTitle("To the editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSending ? "Sending…" : "Send", action: submit)
                        .buttonStyle(ReadingActionStyle(isBusy: isSending))
                        .disabled(trimmed.isEmpty)
                        .allowsHitTesting(!isSending)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .onChange(of: words) { error = nil }
        }
        .tint(ReadingLook.accent)
        .presentationBackground(ReadingLook.paper)
    }

    private func submit() {
        guard !trimmed.isEmpty, !isSending else { return }
        guard trimmed.split(separator: " ").count >= 10 else {
            error = Self.shortReason
            return
        }
        isSending = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            send(about)
            dismiss()
        }
    }
}

#Preview {
    ReadingPartsScreen()
}
