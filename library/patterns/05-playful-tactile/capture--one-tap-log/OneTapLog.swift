import SwiftUI

// Pattern: a one-tap log that stacks up
// Direction 05 Playful & Tactile · kind: capture · look: TactileLook.swift
// Sample product (invented): a practice log for someone learning the cello.

struct PracticeLog: Equatable {
    /// One block on the stack is this many minutes.
    static let step = 10

    var name: String
    var goal: Int
    var minutes: Int
    /// Days this week on which the goal was met, Monday first, not counting today.
    var metDays: Set<Int>
    var today: Int
    /// The last amount logged, so that it can be undone.
    var lastAdded: Int?

    var slots: Int { max(1, goal / Self.step) }
    var filled: Int { min(minutes / Self.step, slots) }
    var isGoalMet: Bool { minutes >= goal }
}

struct OneTapLogScreen: View {
    @State private var phase: Phase<PracticeLog>
    @State private var isEditingGoal = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(phase: Phase<PracticeLog>) {
        _phase = State(initialValue: phase)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(TactileLook.ground)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { dismiss() } label: { TactileDiscFace(symbol: "chevron.backward") }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Back")
                    }
                    .sharedBackgroundVisibility(.hidden)
                    if log != nil {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button { isEditingGoal = true } label: { TactileDiscFace(symbol: "gearshape.fill") }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Change the goal")
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                }
                // The ground is dark enough in both appearances that the bar
                // and the status bar need light content.
                .toolbarColorScheme(.dark, for: .navigationBar)
                .sheet(isPresented: $isEditingGoal) {
                    GoalSheet(goal: log?.goal ?? 60, save: setGoal)
                }
                // A press is felt as well as seen, and reaching the goal feels different.
                .sensoryFeedback(.impact(weight: .medium), trigger: log?.minutes)
                .sensoryFeedback(trigger: log?.isGoalMet) { old, new in
                    old == false && new == true ? .success : nil
                }
        }
        // The rounded design, set once for every text style on the screen.
        .fontDesign(.rounded)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            logView(.placeholder, notice: nil)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading your practice")
        case .empty:
            TactileUnavailable(symbol: "music.note", title: "No practice goal yet") {
                Button("Set a goal") { phase = .loaded(.fresh) }
                    .buttonStyle(TactileKeyStyle())
            }
        case .loaded(let log):
            logView(log, notice: nil)
        case .failed(let message, let stale?):
            logView(stale, notice: message)
        case .failed(let message, nil):
            TactileUnavailable(symbol: "wifi.slash", title: "Couldn't load your practice", message: message) {
                Button("Try again", action: retry)
                    .buttonStyle(TactileKeyStyle())
            }
        }
    }

    @ViewBuilder private func logView(_ log: PracticeLog, notice: String?) -> some View {
        if typeSize.isAccessibilitySize {
            // At the largest sizes everything is one scrolling column, and the
            // keys come straight after the count so they are not far to reach.
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    title(log)
                    if let notice { self.notice(notice) }
                    count(log)
                    keys(log)
                    StackTray(log: log, blockHeight: 47)
                        .frame(maxWidth: .infinity)
                    WeekSummary(log: log)
                }
                .padding()
            }
        } else {
            // The stack gives up height before anything scrolls: its blocks
            // go from full height down to the shortest, then the column
            // scrolls. The blocks stretch inside one stack, so the stack is
            // the same view at every height, and a block can fall into it
            // while the Undo key takes its room below.
            ViewThatFits(in: .vertical) {
                summary(log, notice: notice, blockHeight: nil)
                ScrollView { summary(log, notice: notice, blockHeight: TactileLook.blockHeights.lowerBound) }
            }
            // Keys sit at the bottom edge, in reach of a thumb.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                keys(log)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(TactileLook.ground)
            }
        }
    }

    private func summary(_ log: PracticeLog, notice: String?, blockHeight: Double?) -> some View {
        VStack(spacing: 0) {
            title(log)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let notice {
                self.notice(notice)
                    .padding(.top, 12)
            }
            StackTray(log: log, blockHeight: blockHeight)
                .padding(.top, 16)
            count(log)
                .padding(.top, 16)
            WeekRow(log: log)
                .padding(.top, 20)
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 16)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func title(_ log: PracticeLog) -> some View {
        Text(log.name)
            .font(.system(.largeTitle, design: .rounded, weight: .heavy))
            .foregroundStyle(TactileLook.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private func notice(_ message: String) -> some View {
        TactileNotice(title: "Not synced yet", message: message, retry: retry)
    }

    /// The same thing the stack shows, in numbers. The stack is hidden from
    /// VoiceOver, which reads this line instead.
    private func count(_ log: PracticeLog) -> some View {
        Text("\(log.minutes) of \(log.goal) min")
            .font(.title)
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundStyle(TactileLook.ink)
            .contentTransition(.numericText())
            .accessibilityLabel("\(log.minutes) of \(log.goal) minutes today")
    }

    private func keys(_ log: PracticeLog) -> some View {
        VStack(spacing: 8) {
            if let last = log.lastAdded {
                // The key names what it undoes, so no message is needed after a press.
                Button { undo() } label: {
                    Label("Undo +\(last) min", systemImage: "arrow.uturn.backward")
                }
                .buttonStyle(TactileKeyStyle(kind: .second))
                .accessibilityLabel("Undo \(last) minutes")
            }
            // Three across when they fit, one above the other when they don't.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { amountKeys }
                VStack(spacing: 8) { amountKeys }
            }
        }
    }

    private var amountKeys: some View {
        ForEach([10, 20, 30], id: \.self) { amount in
            Button("+\(amount) min") { add(amount) }
                .buttonStyle(TactileKeyStyle())
                .accessibilityLabel("Add \(amount) minutes")
        }
    }

    private var log: PracticeLog? {
        switch phase {
        case .loaded(let log), .failed(_, let log?): log
        default: nil
        }
    }

    private func store(_ log: PracticeLog) {
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: log)
        } else {
            phase = .loaded(log)
        }
    }

    private func change(_ edit: (inout PracticeLog) -> Void) {
        guard var log else { return }
        edit(&log)
        withAnimation(reduceMotion ? nil : .bouncy(duration: 0.35)) { store(log) }
    }

    private func add(_ amount: Int) {
        change { log in
            log.minutes += amount
            log.lastAdded = amount
        }
    }

    private func undo() {
        change { log in
            log.minutes = max(0, log.minutes - (log.lastAdded ?? 0))
            log.lastAdded = nil
        }
    }

    private func setGoal(_ goal: Int) {
        change { $0.goal = goal }
    }

    /// Sample only: a real app would sync or refetch here.
    private func retry() {
        phase = .loaded(log ?? .sample)
    }
}

// MARK: - The stack

/// Progress as a count of objects: one block per step, empty steps as dashed
/// slots. Reaching the goal fills it and marks the top block.
private struct StackTray: View {
    let log: PracticeLog
    /// The height of a block, or nil to let the blocks share what room
    /// there is.
    let blockHeight: Double?
    /// How many blocks were on the stack before the last press, so that new
    /// ones fall one after another.
    @State private var landed: Int
    /// 1 at rest. A landing block presses the stack down to a little less.
    @State private var press = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(log: PracticeLog, blockHeight: Double?) {
        self.log = log
        self.blockHeight = blockHeight
        _landed = State(initialValue: log.filled)
    }

    var body: some View {
        let filled = log.filled
        let slots = log.slots
        let isGoalMet = log.isGoalMet
        let height = blockHeight
        let before = landed
        VStack(spacing: 8) {
            // In Swift 6 language mode SwiftUI can call this closure away
            // from the main thread while the stack animates, and a closure
            // that belongs to the main actor stops the app there (see the
            // library's README). So it only hands values on, and the row
            // does the work in its own body.
            ForEach((0..<slots).reversed(), id: \.self) { @Sendable index in
                StackRow(index: index, filled: filled, slots: slots, isGoalMet: isGoalMet, blockHeight: height, landed: before)
            }
        }
        // The stack takes the weight: pressed down for a moment as the block
        // lands, then back.
        .scaleEffect(x: 1 + (1 - press) * 0.5, y: press, anchor: .bottom)
        .padding(12)
        .frame(maxWidth: 240)
        .background(TactileLook.tray)
        .clipShape(.rect(cornerRadius: TactileLook.radius + 6))
        .onChange(of: log.filled) { old, new in
            landed = new
            guard new > old, !reduceMotion else { return }
            // Timed to the first block's landing.
            withAnimation(.snappy(duration: 0.1).delay(0.2)) {
                press = 0.94
            } completion: {
                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.1)) { press = 1 }
            }
        }
        .accessibilityHidden(true)
    }
}

/// One place on the stack: a block if it has been earned, a slot if not.
private struct StackRow: View {
    let index: Int
    let filled: Int
    let slots: Int
    let isGoalMet: Bool
    let blockHeight: Double?
    let landed: Int

    // Callable from anywhere, for the reason given in `StackTray`.
    nonisolated init(index: Int, filled: Int, slots: Int, isGoalMet: Bool, blockHeight: Double?, landed: Int) {
        self.index = index
        self.filled = filled
        self.slots = slots
        self.isGoalMet = isGoalMet
        self.blockHeight = blockHeight
        self.landed = landed
    }

    var body: some View {
        if index < filled {
            TactileBlock(
                height: blockHeight,
                symbol: isGoalMet && index == slots - 1 ? "star.fill" : nil)
                // A new block falls in from the top of the tray. An undone
                // one shrinks away.
                .transition(AsymmetricTransition(
                    insertion: TactileFall(distance: fall)
                        .animation(.bouncy(duration: 0.42, extraBounce: 0.12).delay(Double(max(0, index - landed)) * 0.11)),
                    removal: .scale(0.6).combined(with: .opacity)))
        } else {
            TactileSlot(height: blockHeight)
        }
    }

    /// From its slot up to just above the tray's top edge, at the tallest
    /// the blocks can be.
    private var fall: Double {
        let row = (blockHeight ?? TactileLook.blockHeights.upperBound) + TactileLook.edge + 8
        return Double(slots - index) * row + 12
    }
}

// MARK: - The week

/// One disc per day. A met goal is a filled disc with a tick; the tick, not
/// the colour, says done. Today has a ring.
private struct WeekRow: View {
    let log: PracticeLog
    @ScaledMetric(relativeTo: .footnote) private var disc = 36.0

    private static let letters = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { day in
                let isMet = log.met(day)
                let isToday = day == log.today
                VStack(spacing: 4) {
                    Circle()
                        .fill(isMet ? TactileLook.key : TactileLook.tray)
                        .frame(width: disc, height: disc)
                        .overlay {
                            if isMet {
                                Image(systemName: "checkmark")
                                    .font(.system(.footnote, weight: .heavy))
                                    .foregroundStyle(TactileLook.onKey)
                                    .transition(.scale(scale: 0.2).combined(with: .opacity))
                            }
                        }
                        .padding(5)
                        .overlay {
                            if isToday {
                                Circle().strokeBorder(TactileLook.ink, lineWidth: 2.5)
                            }
                        }
                    Text(Self.letters[day])
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(isToday ? TactileLook.ink : TactileLook.ink2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("This week")
        .accessibilityValue(log.weekSummary)
    }
}

/// The week as a sentence, for text sizes where seven discs do not fit.
private struct WeekSummary: View {
    let log: PracticeLog

    var body: some View {
        Label(log.weekSummary, systemImage: "calendar")
            .font(.headline)
            .foregroundStyle(TactileLook.ink)
    }
}

// MARK: - Empty and failed

/// A full-screen message in this direction's own colours and type. The
/// system's unavailable view draws its details in a grey that fails on this
/// ground.
private struct TactileUnavailable<Action: View>: View {
    let symbol: String
    let title: String
    var message: String?
    @ViewBuilder var action: Action

    var body: some View {
        ScrollsIfNeeded {
            VStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundStyle(TactileLook.ink2)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(TactileLook.ink)
                if let message {
                    Text(message)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(TactileLook.ink2)
                }
                action
                    .padding(.top, 12)
            }
            .multilineTextAlignment(.center)
            .padding(32)
        }
    }
}

private struct GoalSheet: View {
    @State var goal: Int
    let save: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Stepper("\(goal) min a day", value: $goal, in: 10...120, step: PracticeLog.step)
            }
            .navigationTitle("Daily goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save(goal)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(220)])
    }
}

// MARK: - Sample data

extension PracticeLog {
    func met(_ day: Int) -> Bool {
        day == today ? isGoalMet : metDays.contains(day)
    }

    var weekSummary: String {
        let count = (0..<7).filter(met).count
        return count == 1 ? "Goal met 1 day this week" : "Goal met \(count) days this week"
    }

    static let sample = PracticeLog(name: "Cello", goal: 60, minutes: 40, metDays: [0, 1, 3, 4], today: 5)

    /// The sample after one more press: the goal is met and the press can be undone.
    static let goalReached = PracticeLog(name: "Cello", goal: 60, minutes: 60, metDays: [0, 1, 3, 4], today: 5, lastAdded: 20)

    /// What "Set a goal" starts with.
    static let fresh = PracticeLog(name: "Cello", goal: 30, minutes: 0, metDays: [], today: 5)

    static let placeholder = PracticeLog(name: "Name", goal: 60, minutes: 0, metDays: [], today: 5)
}
