import SwiftUI

// The parts of look 05 in use, for an invented product: a log of minutes
// practised on an instrument. Each screen is built only from the look's
// parts, one thing leads it, and nothing on it names a part or a state: a
// key that is busy stays down, and a picture that is waiting is a slot.
// `parts.md` says which part is which and where it is in code.

struct TactilePartsScreen: View {
    /// The screen to open: `today` (the default), `today-busy`, `offline`,
    /// `loading`, `empty`, `week`, `instrument`, `instrument-error`, `goal`,
    /// `goal-daily`, `studio`, `studio-waiting`, `studio-failed`.
    var screen: String?

    @State private var goal: Int? = 60

    var body: some View {
        NavigationStack {
            Group {
                switch screen {
                case "week", "instrument", "instrument-error": TactileWeekScreen(opens: screen)
                case "goal": TactileGoal(goal: $goal)
                case "goal-daily": TactileDailyGoal(goal: $goal)
                case "studio": TactileStudio(arrival: .loaded)
                case "studio-waiting": TactileStudio(arrival: .waiting)
                case "studio-failed": TactileStudio(arrival: .failed)
                default: TactileToday(opens: screen)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

/// The frame every screen of this look sits in: its ground, an inline title,
/// and a hard edge under the bar so that keys do not pass under the clock.
private struct TactileFrame: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .background(TactileLook.ground)
            .scrollEdgeEffectStyle(.hard, for: .top)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: Today: the stack, the count and the one key

/// The count leads, beside the stack that makes it a thing. One key logs.
/// The undo key keeps its place while it is hidden, so nothing above moves
/// when it comes.
private struct TactileToday: View {
    private enum Phase { case loaded, loading, offline }

    @State private var goal: Int?
    @State private var blocks = 4
    @State private var canUndo = false
    @State private var isSaving: Bool
    @State private var isTrying = false
    @State private var isSettingGoal = false
    @State private var phase: Phase
    private let staysBusy: Bool

    init(opens screen: String?) {
        staysBusy = screen == "today-busy"
        _goal = State(initialValue: screen == "empty" ? nil : 60)
        _isSaving = State(initialValue: screen == "today-busy")
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
    }

    var body: some View {
        Group {
            if let goal { log(goal: goal) } else { empty }
        }
        .modifier(TactileFrame(title: "Today"))
        // Opened from the screen, not from the empty state: choosing a goal
        // takes the empty state away, and a link inside it would go with it.
        .navigationDestination(isPresented: $isSettingGoal) {
            TactileDailyGoal(goal: $goal)
        }
        .toolbar {
            if goal != nil {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        TactileGoal(goal: $goal)
                    } label: {
                        TactileDiscFace(symbol: "gearshape.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("disc")
                }
                // The disc is the look's own, so the bar's glass is switched off.
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }

    private func log(goal: Int) -> some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 28) {
                    if phase == .offline {
                        TactileNotice(
                            title: isTrying ? "Trying…" : "Not synced yet",
                            message: "Today’s \(blocks * 10) min is kept on this iPhone.") {
                            Task { await retry() }
                        }
                    }
                    HStack(spacing: 24) {
                        TactileStack(
                            filled: phase == .loading ? 0 : blocks, total: goal / 10,
                            blockHeight: proxy.size.height - (phase == .offline ? 124 : 0) < 520 ? 30 : 47)
                        if phase == .loading {
                            RoundedRectangle(cornerRadius: 12).fill(TactileLook.tray)
                                .frame(width: 96, height: 64)
                        } else {
                            TactileCount(value: blocks * 10, total: "of \(goal) min")
                        }
                    }
                    TactileWeek(done: blocks >= goal / 10 ? [0, 1, 3, 4] : [0, 1, 3], today: 4)
                }
                .padding(.horizontal, TactileLook.margin)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { keys }
    }

    private var keys: some View {
        VStack(spacing: 10) {
            Button {
                blocks = max(blocks - 1, 0)
                canUndo = false
            } label: {
                Label("Undo +10 min", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(TactileKeyStyle(kind: .second))
            .opacity(canUndo ? 1 : 0)
            .allowsHitTesting(canUndo)
            Button {
                Task { await logTen() }
            } label: {
                if isSaving {
                    HStack(spacing: 8) {
                        ProgressView().tint(TactileLook.onKey)
                        Text("Saving…")
                    }
                } else {
                    Text("+10 min")
                }
            }
            .buttonStyle(TactileKeyStyle(isHeld: isSaving))
            .allowsHitTesting(!isSaving)
            .disabled(phase == .loading)
        }
        .padding(.horizontal, TactileLook.margin)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(TactileLook.ground)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            TactileEmptyDrawing()
            Text("No practice goal yet")
                .font(TactileLook.keyLabel)
                .foregroundStyle(TactileLook.ink)
                .padding(.top, 20)
            Button("Set a goal") { isSettingGoal = true }
                .buttonStyle(TactileKeyStyle())
            .padding(.top, 20)
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, TactileLook.margin)
        .padding(.bottom, 60)
    }

    private func logTen() async {
        isSaving = true
        try? await Task.sleep(for: .seconds(1.2))
        guard !staysBusy else { return }
        blocks += 1
        isSaving = false
        withAnimation { canUndo = true }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

// MARK: This week: a bar and rows

private struct Instrument: Identifiable {
    var id: String { name }
    let name: String
    let symbol: String
    let blocks: Int
    let target: Int

    static let sample = [
        Instrument(name: "Cello", symbol: "music.note", blocks: 4, target: 6),
        Instrument(name: "Piano", symbol: "pianokeys", blocks: 2, target: 4),
        Instrument(name: "Voice", symbol: "mic.fill", blocks: 0, target: 3),
    ]
}

/// The week's count leads, over a bar: a stack of thirteen blocks would not
/// fit. Each instrument is a row that ends in its own pips.
private struct TactileWeekScreen: View {
    @State private var instruments = Instrument.sample
    @State private var isAdding: Bool
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _isAdding = State(initialValue: screen?.hasPrefix("instrument") == true)
    }

    private var done: Int { instruments.reduce(0) { $0 + $1.blocks } * 10 }
    private var target: Int { instruments.reduce(0) { $0 + $1.target } * 10 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(done, format: .number)
                        .font(TactileLook.title)
                        .monospacedDigit()
                        .foregroundStyle(TactileLook.ink)
                    Text("of \(target) min")
                        .font(TactileLook.note)
                        .foregroundStyle(TactileLook.ink2)
                }
                TactileBar(fraction: Double(done) / Double(max(target, 1)))
                    .padding(.top, 8)
                TactileRows {
                    ForEach(instruments) { instrument in
                        TactileRow(name: instrument.name) {
                            TactileGlyphTile(symbol: instrument.symbol)
                        } end: {
                            TactilePips(filled: instrument.blocks, total: instrument.target)
                            Text("\(instrument.blocks * 10) min").monospacedDigit()
                        }
                    }
                    // The way to add is the last row, with the small key of
                    // a row that opens. A full key here would outweigh the count.
                    TactileRow(name: "Add an instrument") {
                        Button {
                            isAdding = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(TactileSmallKeyStyle())
                        .accessibilityIdentifier("add")
                    }
                }
                .padding(.top, 28)
            }
            .padding(.horizontal, TactileLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .modifier(TactileFrame(title: "This week"))
        .sheet(isPresented: $isAdding) {
            TactileNewInstrument(taken: instruments.map { $0.name.lowercased() }, opens: opens) { name in
                withAnimation { instruments.append(Instrument(name: name, symbol: "music.quarternote.3", blocks: 0, target: 3)) }
            }
        }
    }
}

/// A sheet with one field and one key. The key is off until there is a name.
private struct TactileNewInstrument: View {
    let taken: [String]
    let add: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var error: String?

    init(taken: [String], opens screen: String?, add: @escaping (String) -> Void) {
        self.taken = taken
        self.add = add
        _name = State(initialValue: screen == "instrument-error" ? "Cello" : "")
        _error = State(initialValue: screen == "instrument-error" ? "Cello is already here" : nil)
    }

    private var trimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // The sheet's title names the field, so the field does not.
                TactileField(name: "Instrument", text: $name, prompt: "Viola, flute, drums", error: error, showsName: false, onSubmit: submit)
                Button("Add", action: submit)
                    .buttonStyle(TactileKeyStyle())
                    .disabled(trimmed.isEmpty)
                    .accessibilityIdentifier("add-key")
                Spacer(minLength: 0)
            }
            .padding(.horizontal, TactileLook.margin)
            .padding(.top, 16)
            .modifier(TactileFrame(title: "New instrument"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { TactileDiscFace(symbol: "xmark") }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("close")
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .onChange(of: name) { error = nil }
        }
        .presentationDetents([.medium])
        .presentationBackground(TactileLook.ground)
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        guard !taken.contains(trimmed.lowercased()) else {
            error = "\(trimmed) is already here"
            return
        }
        add(trimmed)
        dismiss()
    }
}

// MARK: Goal: rows that open, and switches

private struct TactileGoal: View {
    @Binding var goal: Int?
    @State private var remindsMe = true
    @State private var countsWeekends = false

    var body: some View {
        ScrollView {
            TactileRows {
                TactileRow(name: "Every day") {
                    Text("\(goal ?? 0) min").monospacedDigit()
                    // A row that opens something ends in a small second key.
                    NavigationLink {
                        TactileDailyGoal(goal: $goal)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(TactileSmallKeyStyle())
                    .accessibilityIdentifier("go")
                }
                Group {
                    Toggle("Remind me", isOn: $remindsMe)
                    Toggle("Count weekends", isOn: $countsWeekends)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: TactileLook.rowMin)
                .background(TactileLook.tray)
                .font(TactileLook.row)
                .foregroundStyle(TactileLook.ink)
                // The system's switch, with the key's colour as its tint.
                .tint(TactileLook.key)
            }
            .padding(.horizontal, TactileLook.margin)
            .padding(.top, 12)
        }
        .modifier(TactileFrame(title: "Goal"))
    }
}

/// One of a few: a row of keys, and the chosen one stays down. The slots
/// under them show what was chosen as the thing it will be.
private struct TactileDailyGoal: View {
    @Binding var goal: Int?

    private static let options = [30, 40, 60]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                TactileChoiceKeys(
                    options: Self.options.map { "\($0) min" },
                    selection: Binding(
                        get: { goal.map { "\($0) min" } ?? "" },
                        set: { chosen in goal = Self.options.first { "\($0) min" == chosen } }))
                if let goal {
                    TactileStack(filled: 0, total: goal / 10, blockHeight: 30)
                }
            }
            .padding(.horizontal, TactileLook.margin)
            .padding(.top, 12)
        }
        .modifier(TactileFrame(title: "Every day"))
    }
}

// MARK: Studio: a picture, people, another company's logo, the app's own mark

/// A picture has four forms, and the screen shows whichever it is in with no
/// word about it. A person has three: a photograph, an initial, nobody yet.
private struct TactileStudio: View {
    enum Arrival { case loaded, waiting, failed }
    let arrival: Arrival

    private var picture: PictureForm {
        switch arrival {
        case .loaded: .loaded(.sample("cello"))
        case .waiting: .waiting
        case .failed: .failed
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    TactilePicture(form: picture)
                    Text("Cello")
                        .font(TactileLook.title)
                        .foregroundStyle(TactileLook.ink)
                }
                TactileRows {
                    TactileRow(name: "Jonas Berg") {
                        TactilePersonMark(photo: SampleFace(person: .jonas))
                    } end: {
                        Text("Teacher")
                    }
                    TactileRow(name: "Mina") {
                        TactilePersonMark(initial: "M", isInRow: true)
                    } end: {
                        Text("Duet")
                    }
                    TactileRow(name: "Nobody yet") {
                        TactilePersonMark(initial: nil, isInRow: true)
                    } end: {
                        Text("Trio")
                    }
                }
                TactileRows {
                    TactileRow(name: "Tempo metronome") {
                        // The room a person's mark takes, so the names line up.
                        TactileLogoTile { SampleLogo(company: .tempo) }
                            .frame(width: TactileLook.person)
                    } end: {
                        Text("Linked")
                    }
                }
                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(TactileLook.onKey)
                        .frame(width: TactileLook.person, height: TactileLook.person)
                        .background(TactileLook.key, in: .rect(cornerRadius: 11))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Practice")
                            .font(TactileLook.keyLabel)
                            .foregroundStyle(TactileLook.ink)
                        Text("Version 1.4")
                            .font(TactileLook.small)
                            .foregroundStyle(TactileLook.ink2)
                    }
                }
                // Inset as far as a row's content, so the mark and the name
                // stand under the marks and the names above.
                .padding(.leading, 16)
                .padding(.top, 12)
            }
            .padding(.horizontal, TactileLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .modifier(TactileFrame(title: "Studio"))
    }
}

#Preview {
    TactilePartsScreen()
}
