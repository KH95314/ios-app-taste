import SwiftUI

// Pattern: sectioned list without cards
// Direction 01 Quiet Native Minimalism · kind: list · look: QuietLook.swift
// Sample product (invented): a chore list shared by three flatmates.

struct Chore: Identifiable, Equatable {
    let id: Int
    var title: String
    var person: String
    var due: String
    var isOverdue = false
    var isDone = false
}

struct ChoreGroup: Identifiable, Equatable {
    var id: String { title }
    var title: String
    var chores: [Chore]
}

struct SectionedListScreen: View {
    @State private var phase: Phase<[ChoreGroup]>
    @State private var isAdding = false
    @State private var doneCount = 0

    init(phase: Phase<[ChoreGroup]>) {
        _phase = State(initialValue: phase)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Flat chores")
                .toolbar {
                    // One way to add per state: this button whenever a list is
                    // showing, the button inside the empty state when it isn't.
                    if showsAddButton {
                        ToolbarSpacer(.flexible, placement: .bottomBar)
                        ToolbarItem(placement: .bottomBar) {
                            Button { isAdding = true } label: { AddButtonFace() }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Add chore")
                                .disabled(!canAdd)
                        }
                        // The button brings its own filled disc, so the bar's
                        // glass behind it is switched off.
                        .sharedBackgroundVisibility(.hidden)
                    }
                }
                .sheet(isPresented: $isAdding) { AddChoreSheet(add: add) }
                .sensoryFeedback(.success, trigger: doneCount)
        }
        // The direction's one hue, set once for everything people can act on.
        .tint(QuietLook.accent)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            // Same layout as the loaded list, so nothing jumps when data arrives.
            list(groups: .placeholder, notice: nil)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading chores")
        case .empty:
            ScrollsIfNeeded {
                // No sentence under the title: the two buttons already say
                // what can be done, and a caption would only repeat them.
                ContentUnavailableView {
                    Label("No chores this week", systemImage: "checklist")
                } actions: {
                    Button("Add a chore") { isAdding = true }
                        .buttonStyle(QuietFilledButtonStyle())
                        .padding(.top, 8)
                    Button("Copy last week") { phase = .loaded(.sample) }
                        .fontWeight(.semibold)
                        .frame(minHeight: 44)
                }
            }
        case .loaded(let groups):
            list(groups: groups, notice: nil)
        case .failed(let message, let stale?):
            list(groups: stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't load chores", systemImage: "wifi.slash")
                } description: {
                    // The system's grey for this line is about 3.5:1. The look's
                    // second ink holds 4.5:1.
                    Text(message)
                        .foregroundStyle(QuietLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(QuietFilledButtonStyle())
                }
            }
        }
    }

    private func list(groups: [ChoreGroup], notice: String?) -> some View {
        List {
            Section {
                // The whole dashboard is one sentence, not a row of stat cards.
                summary(of: groups)
                    .foregroundStyle(QuietLook.ink2)
                    .listRowInsets(.top, 0)
                if let notice {
                    QuietNotice(title: "You're offline", message: notice, retry: retry)
                }
            }
            .listRowSeparator(.hidden)

            ForEach(groups) { group in
                Section {
                    ForEach(group.chores) { chore in
                        ChoreRow(chore: chore) { toggle(chore) }
                    }
                    .listRowSeparator(.hidden)
                    // The tick keeps its 44 pt target; the row adds almost nothing
                    // around it, so a screen holds a day's worth of chores.
                    .listRowInsets(.vertical, 2)
                } header: {
                    GroupHeading(title: group.title, showsRule: group.id != groups.first?.id)
                }
            }
        }
        .listStyle(.plain)
    }

    private var groups: [ChoreGroup]? {
        switch phase {
        case .loaded(let groups), .failed(_, let groups?): groups
        default: nil
        }
    }

    private var showsAddButton: Bool {
        if case .empty = phase { false } else { true }
    }

    private var canAdd: Bool {
        switch phase {
        case .loading, .failed(_, nil): false
        default: true
        }
    }

    private func summary(of groups: [ChoreGroup]) -> Text {
        let today = groups.first?.chores.filter { !$0.isDone }.count ?? 0
        let overdue = groups.flatMap(\.chores).filter { $0.isOverdue && !$0.isDone }.count
        let left = Text(today == 0 ? "Nothing left today" : "\(today) left today")
        guard overdue > 0 else { return left }
        // Red appears twice on this screen: here and on the overdue row itself.
        let late = Text("\(overdue) overdue")
            .fontWeight(.semibold)
            .foregroundStyle(QuietLook.late)
        return Text("\(left) · \(late)")
    }

    private func store(_ groups: [ChoreGroup]) {
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: groups)
        } else {
            phase = .loaded(groups)
        }
    }

    private func toggle(_ chore: Chore) {
        guard var groups else { return }
        for section in groups.indices {
            guard let row = groups[section].chores.firstIndex(of: chore) else { continue }
            groups[section].chores[row].isDone.toggle()
            if groups[section].chores[row].isDone { doneCount += 1 }
        }
        withAnimation { store(groups) }
    }

    private func add(_ title: String) {
        var groups = groups ?? []
        let nextID = (groups.flatMap(\.chores).map(\.id).max() ?? 0) + 1
        let chore = Chore(id: nextID, title: title, person: "Unassigned", due: "no date")
        if let index = groups.firstIndex(where: { $0.title == "Whenever" }) {
            groups[index].chores.append(chore)
        } else {
            groups.append(ChoreGroup(title: "Whenever", chores: [chore]))
        }
        withAnimation { store(groups) }
    }

    /// Sample only: a real app would refetch here.
    private func retry() {
        phase = .loaded(groups ?? .sample)
    }
}

/// Groups are told apart by a heavier heading, a hairline and a gap. There is
/// no box around a group and no tinted band behind its heading.
private struct GroupHeading: View {
    let title: String
    let showsRule: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showsRule {
                Rectangle()
                    .fill(QuietLook.rule)
                    .frame(height: 1)
            }
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
                .textCase(nil)
        }
        .padding(.top, showsRule ? 16 : 0)
    }
}

/// The add button draws its own disc and glyph. On the system's tinted glass
/// button the glyph colour could not be set, and on this direction's lighter
/// accent in the dark appearance it was too faint to see.
private struct AddButtonFace: View {
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var size = 52.0

    var body: some View {
        Image(systemName: "plus")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(isEnabled ? QuietLook.onAccent : QuietLook.mark)
            .frame(width: size, height: size)
            .background(isEnabled ? QuietLook.accent : QuietLook.fill, in: .circle)
            .contentShape(.circle)
    }
}

private struct ChoreRow: View {
    let chore: Chore
    let toggle: () -> Void
    @ScaledMetric(relativeTo: .title2) private var tickSize = 24.0

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Button(action: toggle) {
                Label(chore.isDone ? "Mark as not done" : "Mark as done",
                      systemImage: chore.isDone ? "checkmark.circle.fill" : "circle")
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    // The hue means "you can act on this" or "you did".
                    .foregroundStyle(chore.isDone ? QuietLook.accent : QuietLook.mark)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                Text(chore.title)
                    .strikethrough(chore.isDone)
                    .foregroundStyle(chore.isDone ? QuietLook.ink2 : Color.primary)
                meta
                    .font(.footnote)
            }
        }
        // The tick's 44 pt target hangs into the margin, so the circle itself
        // lines up with the heading above it. At very large text sizes the
        // circle fills its target and there is nothing left to hang.
        .padding(.leading, -max(0, (44 - tickSize) / 2))
        .accessibilityElement(children: .combine)
    }

    /// One wrapping line. Overdue is an icon plus a word, never colour alone,
    /// and the red stays on that word: the row is not tinted.
    private var meta: Text {
        let who = Text("\(chore.person) · \(chore.due)")
        guard chore.isOverdue, !chore.isDone else { return who.foregroundStyle(QuietLook.ink2) }
        let late = Text("\(Image(systemName: "exclamationmark.circle.fill")) Overdue")
            .fontWeight(.semibold)
            .foregroundStyle(QuietLook.late)
        return Text("\(late) · \(who)").foregroundStyle(QuietLook.ink2)
    }
}

private struct AddChoreSheet: View {
    let add: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @FocusState private var isFocused: Bool

    private var trimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                TextField("What needs doing?", text: $title, axis: .vertical)
                    .focused($isFocused)
            }
            .navigationTitle("New chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        add(trimmed)
                        dismiss()
                    }
                    .disabled(trimmed.isEmpty)
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium])
    }
}

extension [ChoreGroup] {
    static let sample: [ChoreGroup] = [
        ChoreGroup(title: "Today", chores: [
            Chore(id: 1, title: "Take out the recycling", person: "Mina", due: "before 7 PM"),
            Chore(id: 2, title: "Water the monstera and the balcony herbs", person: "You", due: "since yesterday", isOverdue: true),
            Chore(id: 3, title: "Empty the dishwasher", person: "Jonas", due: "tonight"),
        ]),
        ChoreGroup(title: "This week", chores: [
            Chore(id: 4, title: "Pay the internet bill", person: "You", due: "Thursday"),
            Chore(id: 5, title: "Descale the kettle", person: "Mina", due: "Friday"),
            Chore(id: 6, title: "Vacuum the hallway and the stairs down to the front door", person: "Jonas", due: "Saturday"),
        ]),
        ChoreGroup(title: "Whenever", chores: [
            Chore(id: 7, title: "Replace the bathroom bulb", person: "Unassigned", due: "no date"),
        ]),
    ]

    /// The sample with the first chore just ticked off.
    static let sampleWithOneDone: [ChoreGroup] = {
        var groups = sample
        groups[0].chores[0].isDone = true
        return groups
    }()

    static let placeholder: [ChoreGroup] = [
        ChoreGroup(title: "Today", chores: (1...3).map {
            Chore(id: $0, title: "Placeholder chore title", person: "Someone", due: "sometime")
        }),
        ChoreGroup(title: "This week", chores: (4...6).map {
            Chore(id: $0, title: "Placeholder chore title", person: "Someone", due: "sometime")
        }),
    ]
}
