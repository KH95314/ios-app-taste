import SwiftUI

// The parts of look 01 in use, for an invented product: the chores of a
// shared flat. Each screen is built only from the look's parts, one thing
// leads it, and nothing on it names a part or a state: a picture that is
// waiting looks like one, and a button that is off looks off. `parts.md`
// says which part is which and where it is in code.

struct QuietPartsScreen: View {
    /// The screen to open: `home` (the default), `week`, `flat`, `plants`,
    /// `plants-waiting`, `plants-failed`, `empty`, `new`, `new-error`,
    /// `new-busy`, `offline`, `loading`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "week": QuietWeekList()
            case "flat": QuietFlat()
            case "plants": QuietPlants(arrival: .loaded)
            case "plants-waiting": QuietPlants(arrival: .waiting)
            case "plants-failed": QuietPlants(arrival: .failed)
            default: QuietHome(opens: screen)
            }
        }
        // The look's one hue, set once for everything people can act on.
        .tint(QuietLook.accent)
    }
}

// MARK: Sample content

private struct FlatChore: Identifiable, Equatable {
    var id: String { name }
    let name: String
    let detail: String
    let day: Int
    var isLate = false
    /// An initial, or `nil` for nobody yet. Mina has a photograph.
    var person: String?
    var isDone = false

    static let today = 13
    static let weekdays = [
        11: "Monday", 12: "Tuesday", 13: "Wednesday", 14: "Thursday", 15: "Friday", 16: "Saturday", 17: "Sunday",
    ]

    static let sample: [FlatChore] = [
        FlatChore(name: "Water the monstera and the balcony herbs", detail: "since yesterday", day: 13, isLate: true, person: "Y"),
        FlatChore(name: "Empty the dishwasher", detail: "tonight", day: 13, person: "J"),
        FlatChore(name: "Take out the recycling", detail: "before 7 PM", day: 13, person: "M", isDone: true),
        FlatChore(name: "Pay the internet bill", detail: "by noon", day: 14, person: "Y"),
        FlatChore(name: "Replace the bathroom bulb", detail: "any time", day: 14),
        FlatChore(name: "Vacuum the hallway", detail: "morning", day: 16, person: "M"),
        FlatChore(name: "Wash the towels", detail: "any time", day: 16, person: "J"),
    ]
}

/// The person a chore belongs to, at the end of its row.
private struct ChorePerson: View {
    let initial: String?

    var body: some View {
        if initial == "M" {
            QuietPersonMark(photo: SampleFace(person: .mina))
        } else {
            QuietPersonMark(initial: initial)
        }
    }
}

// MARK: Home: one day

/// The summary sentence leads. The week under it chooses the day, and the
/// day's chores follow with no head: the sentence has already named the day.
private struct QuietHome: View {
    private enum Phase { case loaded, loading, offline }

    @State private var chores: [FlatChore]
    @State private var day = FlatChore.today
    @State private var phase: Phase
    @State private var isAdding: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _chores = State(initialValue: screen == "empty" ? [] : FlatChore.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isAdding = State(initialValue: screen?.hasPrefix("new") == true)
    }

    var body: some View {
        Group {
            if chores.isEmpty { empty } else { list }
        }
        .background(QuietLook.ground)
        .navigationTitle("Flat chores")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            // One way to add in each state: this button while a list shows,
            // the button inside the empty state when none does.
            if !chores.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add a chore", systemImage: "plus") { isAdding = true }
                }
            }
        }
        .sheet(isPresented: $isAdding) {
            QuietNewChore(taken: shown.map { $0.name.lowercased() }, opens: opens) { chore in
                day = FlatChore.today
                withAnimation { chores.append(chore) }
            }
        }
    }

    private var shown: [FlatChore] { chores.filter { $0.day == day } }

    private var summary: (left: String, late: String?) {
        let left = shown.filter { !$0.isDone }
        let isToday = day == FlatChore.today
        let weekday = FlatChore.weekdays[day] ?? ""
        let late = left.filter(\.isLate).count
        if left.isEmpty {
            return (shown.isEmpty ? "Nothing on \(weekday)" : isToday ? "All done today" : "All done on \(weekday)", nil)
        }
        return (isToday ? "\(left.count) left today" : "\(left.count) on \(weekday)", late > 0 ? "\(late) overdue" : nil)
    }

    private var week: [QuietDay] {
        zip([11, 12, 13, 14, 15, 16, 17], ["M", "T", "W", "T", "F", "S", "S"]).map { id, letter in
            QuietDay(id: id, letter: letter, due: phase == .loading ? 0 : chores.filter { $0.day == id && !$0.isDone }.count)
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    QuietNotice(
                        title: isTrying ? "Trying…" : "You’re offline",
                        message: "This is the last saved list. Changes sync when you reconnect.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 20)
                }
                if phase == .loading {
                    // The sentence's own line, so nothing moves when it comes.
                    RoundedRectangle(cornerRadius: 4).fill(QuietLook.fill)
                        .frame(width: 150, height: 12)
                        .frame(height: 22)
                } else {
                    QuietSummary(left: summary.left, late: summary.late)
                }
                QuietWeek(days: week, selection: $day)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                if phase == .loading {
                    ForEach(0..<3, id: \.self) { _ in QuietGhostRow() }
                } else {
                    ForEach(shown) { chore in
                        QuietTaskRow(name: chore.name, detail: chore.detail, isLate: chore.isLate, isDone: chore.isDone) {
                            toggle(chore)
                        } person: {
                            ChorePerson(initial: chore.person)
                        }
                    }
                }
            }
            .padding(.horizontal, QuietLook.margin)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            QuietGhostList()
            Text("No chores this week")
                .font(QuietLook.emptyTitle)
                .padding(.top, 20)
            Button("Add a chore") { isAdding = true }
                .buttonStyle(QuietFilledButtonStyle())
                .padding(.top, 20)
            Button("Copy last week") {
                withAnimation { chores = FlatChore.sample }
            }
            .buttonStyle(QuietTextButtonStyle())
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private func toggle(_ chore: FlatChore) {
        guard let index = chores.firstIndex(of: chore) else { return }
        chores[index].isDone.toggle()
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

// MARK: New chore: a sheet

/// The field leads and the filled button ends the sheet. The button is off
/// until there is a name, and keeps its fill while the chore is on its way.
private struct QuietNewChore: View {
    let taken: [String]
    let add: (FlatChore) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var error: String?
    @State private var isAdding: Bool
    @State private var owner = "You"
    @State private var repeats = true
    @State private var remindsEveryone = false
    private let staysBusy: Bool

    init(taken: [String], opens screen: String?, add: @escaping (FlatChore) -> Void) {
        self.taken = taken
        self.add = add
        staysBusy = screen == "new-busy"
        _name = State(initialValue: screen == "new-error" ? "Empty the dishwasher" : screen == "new-busy" ? "Descale the kettle" : "")
        _error = State(initialValue: screen == "new-error" ? Self.takenReason : nil)
        _isAdding = State(initialValue: screen == "new-busy")
    }

    private static let takenReason = "Already on today’s list"
    private var trimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // The sheet's title names the field, so the field does not.
                    QuietField(name: "Chore", text: $name, prompt: "What needs doing?", error: error, showsName: false, onSubmit: submit)
                    QuietGroupHead(title: "Who")
                        .padding(.top, QuietLook.groupGap)
                        .padding(.bottom, 4)
                    ForEach(["Mina", "Jonas", "You"], id: \.self) { person in
                        QuietChoiceRow(name: person, isChosen: owner == person) { owner = person }
                    }
                    Rectangle().fill(QuietLook.rule).frame(height: 1)
                        .padding(.vertical, 8)
                    Toggle("Repeat every week", isOn: $repeats)
                        .frame(minHeight: QuietLook.rowMin)
                    Toggle("Remind everyone", isOn: $remindsEveryone)
                        .frame(minHeight: QuietLook.rowMin)
                }
                .padding(.horizontal, QuietLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(action: submit) {
                    if isAdding {
                        HStack(spacing: 8) {
                            ProgressView().tint(QuietLook.onAccent)
                            Text("Adding…")
                        }
                    } else {
                        Text("Add chore")
                    }
                }
                .buttonStyle(QuietFilledButtonStyle())
                .disabled(trimmed.isEmpty)
                .allowsHitTesting(!isAdding)
                .padding(.bottom, 8)
            }
            .background(QuietLook.ground)
            .navigationTitle("New chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: name) { error = nil }
        }
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
            add(FlatChore(
                name: trimmed, detail: repeats ? "every week" : "once", day: FlatChore.today,
                person: String(owner.prefix(1))))
            dismiss()
        }
    }
}

// MARK: This week: days in one list

/// A list over several days. Today's head carries the pie and the count; a
/// later day's head is its date.
private struct QuietWeekList: View {
    @State private var chores = FlatChore.sample

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                let today = chores.filter { $0.day == FlatChore.today }
                QuietGroupHead(title: "Today", done: today.filter(\.isDone).count, total: today.count)
                rows(today)
                ForEach([14, 16], id: \.self) { day in
                    QuietDateHead(day: day, weekday: FlatChore.weekdays[day] ?? "")
                    rows(chores.filter { $0.day == day })
                }
            }
            .padding(.horizontal, QuietLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(QuietLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("This week")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func rows(_ chores: [FlatChore]) -> some View {
        ForEach(chores) { chore in
            QuietTaskRow(name: chore.name, detail: chore.detail, isLate: chore.isLate, isDone: chore.isDone) {
                guard let index = self.chores.firstIndex(of: chore) else { return }
                self.chores[index].isDone.toggle()
            } person: {
                ChorePerson(initial: chore.person)
            }
        }
    }
}

// MARK: Flat: people, another company's logo, the app's own mark

private struct QuietFlat: View {
    @State private var paywell = Link.none
    private enum Link { case none, linking, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                QuietGroupHead(title: "Flatmates")
                    .padding(.bottom, 4)
                QuietValueRow(name: "Mina") {
                    QuietPersonMark(photo: SampleFace(person: .mina), size: QuietLook.rowLead)
                }
                QuietValueRow(name: "Jonas") {
                    QuietPersonMark(initial: "J", size: QuietLook.rowLead)
                }
                ShareLink(item: "Join our flat on Flat chores: https://example.com/join/4821") {
                    HStack(spacing: 10) {
                        QuietPersonMark(initial: nil, size: QuietLook.rowLead)
                        Text("Invite a flatmate")
                            .font(QuietLook.row)
                            .foregroundStyle(QuietLook.accent)
                        Spacer()
                    }
                    .frame(minHeight: QuietLook.rowMin)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)

                QuietGroupHead(title: "Bills")
                    .padding(.top, QuietLook.groupGap)
                    .padding(.bottom, 4)
                QuietValueRow(name: "Northline Internet", value: "Linked") {
                    QuietLogoTile { SampleLogo(company: .northline) }
                        .frame(width: QuietLook.rowLead, alignment: .leading)
                }
                HStack(spacing: 10) {
                    QuietLogoTile { SampleLogo(company: .paywell) }
                        .frame(width: QuietLook.rowLead, alignment: .leading)
                    Text("Paywell")
                        .font(QuietLook.row)
                    Spacer(minLength: 12)
                    if paywell == .linked {
                        Text("Linked")
                            .foregroundStyle(QuietLook.ink2)
                    } else {
                        Button(paywell == .linking ? "Linking…" : "Link") {
                            Task { await link() }
                        }
                        .buttonStyle(QuietTextButtonStyle())
                        .allowsHitTesting(paywell == .none)
                    }
                }
                .frame(minHeight: QuietLook.rowMin)

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(QuietLook.onAccent)
                        .frame(width: QuietLook.rowLead, height: QuietLook.rowLead)
                        .background(QuietLook.accent, in: .rect(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Flat chores")
                            .font(QuietLook.heading)
                        Text("Version 2.1")
                            .font(QuietLook.detail)
                            .foregroundStyle(QuietLook.ink2)
                    }
                }
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) {
                    Rectangle().fill(QuietLook.rule).frame(height: 1)
                }
                .padding(.top, QuietLook.groupGap)
            }
            .padding(.horizontal, QuietLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(QuietLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Flat")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func link() async {
        paywell = .linking
        try? await Task.sleep(for: .seconds(1.2))
        paywell = .linked
    }
}

// MARK: Plants: a picture at the end of a row

/// A picture has four forms, and a row shows whichever it is in with no word
/// about it: loaded, waiting, could not load, and no picture at all.
private struct QuietPlants: View {
    enum Arrival { case loaded, waiting, failed }
    let arrival: Arrival

    @State private var done: Set<String> = []

    private static let plants: [(name: String, detail: String, picture: String?)] = [
        ("Water the monstera", "every Wednesday", "plant-on-a-desk"),
        ("Water the jade plant", "every other Sunday", "succulent"),
        ("Mist the balcony herbs", "every morning", nil),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Self.plants, id: \.name) { plant in
                    QuietTaskRow(name: plant.name, detail: plant.detail, isDone: done.contains(plant.name)) {
                        if done.contains(plant.name) { done.remove(plant.name) } else { done.insert(plant.name) }
                    } person: {
                        if let picture = plant.picture {
                            QuietPicture(form: form(picture))
                        }
                    }
                }
            }
            .padding(.horizontal, QuietLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(QuietLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Plants")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func form(_ picture: String) -> PictureForm {
        switch arrival {
        case .loaded: .loaded(.sample(picture))
        case .waiting: .waiting
        case .failed: .failed
        }
    }
}

#Preview {
    QuietPartsScreen()
}
