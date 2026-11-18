import SwiftUI

// Pattern: a wait with a picture that shows it
// Direction 08 Warm Organic · kind: session · look: WarmLook.swift
// Sample product (invented): a timer for proofing bread dough.
//
// The kitchen picture is the sample's own, drawn in code.

struct Proof: Equatable {
    var bake: String
    var step: String
    /// Steps in the whole bake, and which one this is.
    var stepCount: Int
    var stepIndex: Int
    /// Minutes planned for this step, and minutes gone.
    var total: Int
    var elapsed: Int
    /// Minutes after midnight. The sample holds the time so that its
    /// screenshots are stable; a real app reads the clock.
    var now: Int
    var isPaused = false
    /// How long the step took, once it is over.
    var finishedAfter: Int?
    var nextLine: String
    var nextAction: String
    var laterLine: String

    var remaining: Int { max(0, total - elapsed) }
    var isReady: Bool { finishedAfter != nil }
    /// 0 when the dough has just gone in, 1 when it has doubled.
    var rise: Double { isReady ? 1 : min(1, Double(elapsed) / Double(max(total, 1))) }
}

struct ProofTimerScreen: View {
    @State private var phase: Phase<Proof>
    @Environment(\.dismiss) private var dismiss

    init(phase: Phase<Proof>) {
        _phase = State(initialValue: phase)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                content(height: proxy.size.height)
            }
            .background(WarmLook.ground)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { WarmDiscFace(symbol: "chevron.backward") }
                        .buttonStyle(.plain)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            // The picture's field is the same in light and dark, so the status
            // bar keeps dark figures in both.
            .toolbarColorScheme(.light, for: .navigationBar)
            .task(id: isRunning) { await run() }
            .sensoryFeedback(.success, trigger: proof?.isReady)
        }
    }

    @ViewBuilder private func content(height: Double) -> some View {
        switch phase {
        case .loading:
            page(.placeholder, shows: nil, notice: nil, height: height)
                .redacted(reason: .placeholder)
                .disabled(true)
        case .empty:
            // Nothing on the go: the jar stands empty, and one button starts.
            VStack(alignment: .leading, spacing: 0) {
                picture(KitchenPicture(rise: nil), height: height, reserve: 220)
                Text("Nothing rising")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(WarmLook.ink)
                    .padding(.horizontal, WarmLook.margin)
                    .padding(.top, 16)
                Spacer(minLength: 8)
                Button("Start a first rise") { phase = .loaded(.sample) }
                    .buttonStyle(WarmFilledButtonStyle())
                    .padding(.horizontal, WarmLook.margin)
                    .padding(.bottom, 16)
            }
        case .loaded(let proof):
            page(proof, shows: proof.rise, notice: nil, height: height)
        case .failed(let message, let stale?):
            page(stale, shows: stale.rise, notice: message, height: height)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(WarmLook.ink2)
                    Text("Couldn't open this bake")
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(WarmLook.ink)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(WarmLook.ink2)
                    Button("Try again", action: retry)
                        .buttonStyle(WarmFilledButtonStyle())
                        .padding(.top, 12)
                }
                .multilineTextAlignment(.center)
                .padding(32)
            }
        }
    }

    private func page(_ proof: Proof, shows rise: Double?, notice: String?, height: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // The picture moves with the proof: the dough glides to each new
            // height, its bubbles drift while the timer runs and hold still
            // when it does not, and the tag fills when the dough gets there.
            picture(
                KitchenPicture(rise: rise, isDone: rise != nil && proof.isReady, isWorking: rise != nil && !proof.isPaused && !proof.isReady),
                height: height, reserve: notice == nil ? 350 : 398)
                // A soft spring: the dough swells a little past the band
                // and settles.
                .animation(.spring(duration: 1.1, bounce: 0.38), value: proof.isReady)
            VStack(alignment: .leading, spacing: 0) {
                if let notice {
                    // One line: what is off, and the way to turn it on.
                    HStack(spacing: 8) {
                        Label(notice, systemImage: "bell.slash")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(WarmLook.ink)
                        Spacer(minLength: 8)
                        Button("Turn on", action: retry)
                            .buttonStyle(WarmTextButtonStyle())
                    }
                    .padding(.bottom, 4)
                }
                Text(proof.bake)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(WarmLook.ink2)
                Text(proof.step)
                    .font(.system(.largeTitle, design: .serif, weight: .bold).scaled(by: 1.18))
                    .foregroundStyle(WarmLook.ink)
                timeBlock(proof)
                    .padding(.top, 12)
                // Where this step sits in the whole bake, and what follows.
                // The button names the very next thing once it is time for
                // it, so the line then looks one step further on.
                // On a narrow phone the words go under the pebbles instead
                // of being cut short.
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) {
                        pebbles(for: proof)
                        following(proof)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        pebbles(for: proof)
                        following(proof)
                    }
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, WarmLook.margin)
            .padding(.top, 8)
            Spacer(minLength: 8)
            VStack(spacing: 0) {
                if proof.isReady {
                    Button(proof.nextAction, action: finish)
                        .buttonStyle(WarmFilledButtonStyle())
                    Button("Give it 10 more min") { addTime() }
                        .buttonStyle(WarmTextButtonStyle())
                } else {
                    Button(proof.isPaused ? "Resume" : "Pause", systemImage: proof.isPaused ? "play.fill" : "pause.fill", action: togglePause)
                        .buttonStyle(WarmFilledButtonStyle())
                    Button("It’s ready now", action: markReady)
                        .buttonStyle(WarmTextButtonStyle())
                }
            }
            .padding(.horizontal, WarmLook.margin)
            .padding(.bottom, 4)
        }
        // The picture takes its time over the change. The words and the
        // buttons do not: they swap at once, so two never show together.
        .transaction(value: proof.isReady) { $0.animation = $0.animation == nil ? nil : .easeOut(duration: 0.18) }
    }

    private func pebbles(for proof: Proof) -> some View {
        StepPebbles(count: proof.stepCount, done: proof.isReady ? proof.stepIndex + 1 : proof.stepIndex)
    }

    private func following(_ proof: Proof) -> some View {
        Text(proof.isReady ? proof.laterLine : proof.nextLine)
            .foregroundStyle(WarmLook.ink2)
            .lineLimit(1)
    }

    /// The time left and when that is on the clock; or, once it is over, one
    /// word and how long it took. Nothing celebrates.
    @ViewBuilder private func timeBlock(_ proof: Proof) -> some View {
        if let took = proof.finishedAfter {
            VStack(alignment: .leading, spacing: 0) {
                Text("Ready")
                    .font(.system(.largeTitle, design: .serif, weight: .semibold).scaled(by: 1.75))
                    .foregroundStyle(WarmLook.ink)
                Text("Doubled in \(ProofClock.length(took))")
                    .foregroundStyle(WarmLook.ink2)
            }
            .transition(.blurReplace)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(proof.remaining, format: .number)
                        .font(.system(.largeTitle, design: .serif, weight: .semibold).scaled(by: 1.75))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("min left")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer(minLength: 8)
                    // Beside the time, because the time is what it changes.
                    Button("+10 min") { addTime() }
                        .buttonStyle(WarmPillButtonStyle())
                }
                .foregroundStyle(WarmLook.ink)
                Text(proof.isPaused ? "Paused" : "Ready about \(ProofClock.time(proof.now + proof.remaining))")
                    .foregroundStyle(WarmLook.ink2)
            }
            .transition(.blurReplace)
        }
    }

    /// The picture takes what the words and the buttons leave, up to a little
    /// under half the screen, and runs up under the status bar.
    private func picture(_ picture: KitchenPicture, height: Double, reserve: Double) -> some View {
        // The order matters: the picture grows into the top safe area first,
        // and the frame then fixes how far it comes down the page. The other
        // way round, the picture keeps its height and slides up instead.
        picture
            .ignoresSafeArea(edges: .top)
            .frame(height: max(160, min(height * 0.45, height - reserve)))
    }

    private var proof: Proof? {
        switch phase {
        case .loaded(let proof), .failed(_, let proof?): proof
        default: nil
        }
    }

    private var isRunning: Bool {
        guard let proof else { return false }
        return !proof.isPaused && !proof.isReady
    }

    private func change(_ edit: (inout Proof) -> Void) {
        guard var proof else { return }
        edit(&proof)
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: proof)
        } else {
            phase = .loaded(proof)
        }
    }

    /// Sample only: a minute passes every minute while the timer runs.
    private func run() async {
        while isRunning {
            try? await Task.sleep(for: .seconds(60))
            guard !Task.isCancelled, isRunning else { return }
            withAnimation(.smooth) {
                change { proof in
                    proof.elapsed += 1
                    proof.now += 1
                    if proof.elapsed >= proof.total { proof.finishedAfter = proof.elapsed }
                }
            }
        }
    }

    private func togglePause() {
        change { $0.isPaused.toggle() }
    }

    private func addTime() {
        withAnimation(.smooth) {
            change { proof in
                proof.total = max(proof.total, proof.elapsed) + 10
                proof.finishedAfter = nil
            }
        }
    }

    private func markReady() {
        // A soft spring: the dough swells a little past the band and settles.
        withAnimation(.spring(duration: 1.1, bounce: 0.38)) {
            change { $0.finishedAfter = $0.elapsed }
        }
    }

    /// Sample only: the next step has no timer, so the screen goes back to idle.
    private func finish() {
        phase = .empty
    }

    /// Sample only: a real app would ask for permission, or reopen the bake.
    private func retry() {
        phase = .loaded(proof ?? .sample)
    }
}

// MARK: - Parts

/// Where this step sits in the whole job: filled when done, wide and clay
/// when current, a ring when still to come.
private struct StepPebbles: View {
    let count: Int
    let done: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { index in
                if index < done {
                    Ellipse().fill(WarmLook.ink).frame(width: 14, height: 12)
                } else if index == done {
                    Ellipse().fill(WarmLook.accent).frame(width: 26, height: 12)
                } else {
                    Ellipse().strokeBorder(WarmLook.ink2, lineWidth: 2).frame(width: 14, height: 12)
                }
            }
        }
    }
}

/// A kitchen counter: a jar of dough with a band at twice its starting
/// height, a cup and a plant. The dough climbs toward the band as `rise`
/// goes from 0 to 1. With no `rise` the jar stands empty.
struct KitchenPicture: View, Animatable {
    /// 0 when the dough has just gone in, 1 when it has doubled.
    private var level: Double
    /// 0 while it rises, 1 once it is there. The tag fills as it goes.
    private var done: Double
    private let hasDough: Bool
    private let isWorking: Bool

    init(rise: Double?, isDone: Bool = false, isWorking: Bool = false) {
        level = rise ?? 0
        done = isDone ? 1 : 0
        hasDough = rise != nil
        self.isWorking = isWorking
    }

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(level, done) }
        set {
            level = newValue.first
            done = newValue.second
        }
    }

    var body: some View {
        // Redrawn a few times a second while the dough is working, so its
        // bubbles drift. Paused or done, the picture holds still.
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: !isWorking)) { timeline in
            scene(time: timeline.date.timeIntervalSinceReferenceDate)
        }
    }

    private func scene(time: Double) -> some View {
        let rise: Double? = hasDough ? level : nil
        let done = min(max(done, 0), 1)
        return Canvas { context, size in
            // Drawn on a 402 by 420 sheet, scaled to cover, and held to the
            // bottom edge so the counter is never cut off. In a short frame
            // the drawing shrinks instead, so the jar keeps clear of the bar
            // above it; the field runs on past the sheet at both sides.
            let scale = min(max(size.width / 402, size.height / 420), size.height / 340)
            context.translateBy(x: (size.width - 402 * scale) / 2, y: size.height - 420 * scale)
            context.scaleBy(x: scale, y: scale)

            // The field, with a soft uneven lower edge, and the counter on it.
            context.fill(Self.ground(top: -600), with: .color(WarmLook.clay))
            context.fill(Path(ellipseIn: CGRect(x: 204, y: 64, width: 192, height: 192)), with: .color(WarmLook.sun))
            context.fill(Self.ground(top: 372), with: .color(WarmLook.clay2))

            // A plant, in front of the sun so the leaves read.
            for leaf in Self.leaves { context.fill(leaf, with: .color(WarmLook.leaf)) }
            context.fill(Self.polygon([(300, 372), (306, 322), (354, 322), (360, 372)]), with: .color(WarmLook.berry))

            // A cup.
            var handle = Path()
            handle.move(to: CGPoint(x: 70, y: 336))
            handle.addCurve(to: CGPoint(x: 70, y: 358), control1: CGPoint(x: 86, y: 334), control2: CGPoint(x: 90, y: 358))
            context.stroke(handle, with: .color(WarmLook.cream), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            var cup = Path()
            cup.move(to: CGPoint(x: 28, y: 322))
            cup.addLine(to: CGPoint(x: 74, y: 322))
            cup.addLine(to: CGPoint(x: 74, y: 358))
            cup.addQuadCurve(to: CGPoint(x: 60, y: 372), control: CGPoint(x: 74, y: 372))
            cup.addLine(to: CGPoint(x: 42, y: 372))
            cup.addQuadCurve(to: CGPoint(x: 28, y: 358), control: CGPoint(x: 28, y: 372))
            cup.closeSubpath()
            context.fill(cup, with: .color(WarmLook.cream))
            context.fill(Path(CGRect(x: 28, y: 334, width: 46, height: 9)), with: .color(WarmLook.leaf))

            // The jar and what is in it.
            let jar = Path(roundedRect: CGRect(x: 104, y: 166, width: 136, height: 206), cornerRadius: 22)
            context.fill(jar, with: .color(WarmLook.cream.opacity(0.3)))
            if let rise {
                // A spring may carry the dough a little past the band.
                let level = 300 - min(max(rise, 0), 1.12) * 74
                var dough = Path()
                dough.move(to: CGPoint(x: 110, y: level + 20))
                dough.addCurve(to: CGPoint(x: 234, y: level + 20), control1: CGPoint(x: 110, y: level - 8), control2: CGPoint(x: 234, y: level - 8))
                dough.addLine(to: CGPoint(x: 234, y: 348))
                dough.addQuadCurve(to: CGPoint(x: 216, y: 366), control: CGPoint(x: 234, y: 366))
                dough.addLine(to: CGPoint(x: 128, y: 366))
                dough.addQuadCurve(to: CGPoint(x: 110, y: 348), control: CGPoint(x: 110, y: 366))
                dough.closeSubpath()
                context.fill(dough, with: .color(WarmLook.cream))
                // Bubbles climb from the bottom of the jar to just under the
                // dough's top, fading in and out at the two ends.
                // Each is a share of the way up, so when the dough's height
                // changes they move with it and do not jump.
                let floor = 358.0
                let span = max(floor - (level + 24), 1)
                for (index, bubble) in Self.bubbles.enumerated() {
                    let turn = time / bubble.seconds + bubble.start
                    let share = turn - turn.rounded(.down)
                    let y = floor - share * span
                    let x = bubble.x + sin(time * 0.7 + Double(index) * 1.9) * 2.5
                    let fade = min(share / 0.12, (1 - share) / 0.15, 1)
                    let dot = CGRect(x: x - bubble.radius, y: y - bubble.radius, width: bubble.radius * 2, height: bubble.radius * 2)
                    context.fill(Path(ellipseIn: dot), with: .color(WarmLook.clay.opacity(0.22 * max(fade, 0))))
                }
            }
            context.stroke(jar, with: .color(WarmLook.cream), lineWidth: 4)

            // The band marks twice the starting height. It is the one mark
            // that says where done is, so it also gets the one word.
            // When the dough gets there the tag turns over: berry, with the
            // word in cream.
            if rise != nil {
                context.fill(Path(roundedRect: CGRect(x: 98, y: 222, width: 148, height: 9), cornerRadius: 4.5), with: .color(WarmLook.berry))
                let tag = Path(roundedRect: CGRect(x: 252, y: 213, width: 78, height: 27), cornerRadius: 13.5)
                context.fill(tag, with: .color(WarmLook.cream.mix(with: WarmLook.berry, by: done)))
                let word = Text("Doubled").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WarmLook.berry.mix(with: WarmLook.cream, by: done))
                context.draw(word, at: CGPoint(x: 291, y: 226.5), anchor: .center)
            }
        }
    }

    /// Each bubble's place across the jar, its size, how many seconds it
    /// takes to climb, and how far up it is when the clock reads zero.
    private static let bubbles: [(x: Double, radius: Double, seconds: Double, start: Double)] = [
        (146, 5, 26, 0.15), (196, 6.5, 34, 0.55), (170, 3.5, 19, 0.8), (214, 4, 23, 0.35), (132, 3, 16, 0.65),
    ]

    /// Everything from `top` down to the soft lower edge.
    private static func ground(top: Double) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: -200, y: top))
        path.addLine(to: CGPoint(x: 602, y: top))
        // Past the sheet's sides the edge carries on in the same direction and
        // then levels, so a frame wider than the sheet shows no corner.
        path.addLine(to: CGPoint(x: 602, y: 384))
        path.addCurve(to: CGPoint(x: 402, y: 388), control1: CGPoint(x: 480, y: 384), control2: CGPoint(x: 417, y: 380.8))
        path.addCurve(to: CGPoint(x: 236, y: 404), control1: CGPoint(x: 352, y: 412), control2: CGPoint(x: 300, y: 394))
        path.addCurve(to: CGPoint(x: 0, y: 410), control1: CGPoint(x: 160, y: 416), control2: CGPoint(x: 84, y: 392))
        path.addCurve(to: CGPoint(x: -200, y: 414), control1: CGPoint(x: -25, y: 415.4), control2: CGPoint(x: -100, y: 414))
        path.closeSubpath()
        return path
    }

    private static let leaves: [Path] = [
        leaf(to: (312, 232), out: ((300, 304), (294, 262)), back: ((334, 262), (340, 298))),
        leaf(to: (384, 244), out: ((332, 286), (352, 254)), back: ((386, 282), (364, 312))),
        leaf(to: (346, 196), out: ((318, 278), (324, 226)), back: ((358, 236), (352, 290))),
    ]

    private static func leaf(to tip: (Double, Double), out: ((Double, Double), (Double, Double)), back: ((Double, Double), (Double, Double))) -> Path {
        let stem = CGPoint(x: 330, y: 326)
        var path = Path()
        path.move(to: stem)
        path.addCurve(to: CGPoint(x: tip.0, y: tip.1), control1: CGPoint(x: out.0.0, y: out.0.1), control2: CGPoint(x: out.1.0, y: out.1.1))
        path.addCurve(to: stem, control1: CGPoint(x: back.0.0, y: back.0.1), control2: CGPoint(x: back.1.0, y: back.1.1))
        path.closeSubpath()
        return path
    }

    private static func polygon(_ points: [(Double, Double)]) -> Path {
        var path = Path()
        path.addLines(points.map { CGPoint(x: $0.0, y: $0.1) })
        path.closeSubpath()
        return path
    }
}

// MARK: - Words and sample data

enum ProofClock {
    /// A clock time in the reader's own format.
    static func time(_ minutes: Int) -> String {
        let clock = ((minutes % 1440) + 1440) % 1440
        let date = Calendar.current.date(bySettingHour: clock / 60, minute: clock % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }

    static func length(_ minutes: Int) -> String {
        minutes < 60 ? "\(minutes) min" : "\(minutes / 60) h \(minutes % 60) min"
    }
}

extension Proof {
    /// 1:32 PM, 74 minutes into a rise planned for 112.
    static let sample = Proof(
        bake: "Country loaf", step: "First rise", stepCount: 5, stepIndex: 1,
        total: 112, elapsed: 74, now: 812,
        nextLine: "Next: shape the loaf", nextAction: "Shape the loaf", laterLine: "Then a second rise, 45 min")

    static let paused: Proof = {
        var proof = sample
        proof.isPaused = true
        return proof
    }()

    /// The rise is over: the dough has reached the band.
    static let ready: Proof = {
        var proof = sample
        proof.elapsed = 112
        proof.now = 850
        proof.finishedAfter = 112
        return proof
    }()

    static let placeholder = Proof(
        bake: "Name of the bake", step: "Step name", stepCount: 5, stepIndex: 1,
        total: 100, elapsed: 50, now: 720,
        nextLine: "Next: the next step", nextAction: "Next step", laterLine: "Then another step")
}
