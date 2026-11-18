import SwiftUI

// Pattern: a take in progress
// Direction 06 Dark Professional · kind: session · look: ProLook.swift
// Sample product (invented): a field recorder, part-way through its third take.
//
// The sample's levels and waveform are fixed data. A real recorder reads them
// from the audio engine many times a second.

struct Take: Equatable {
    enum Status: Equatable { case opening, ready, recording, paused, inputLost }

    var number: Int
    var status: Status
    /// Seconds recorded so far.
    var elapsed = 0
    /// Levels from 0 to 1. At 1 the input is clipping.
    var left = 0.0
    var right = 0.0
    var input: String?
    var spaceLeft = "5 h 12 min"
    var rate = "48 kHz"
    var format = "24-bit WAV"
    /// Input gain in decibels.
    var gain = 12
    /// One bar per moment recorded, 0 to 1.
    var bars: [Double] = []
    /// Positions in `bars` the operator has marked.
    var marks: [Int] = []
    /// The take that was just saved, once there is one.
    var lastTake: String?

    var timecode: String {
        String(format: "%02d:%02d:%02d", elapsed / 3600, elapsed / 60 % 60, elapsed % 60)
    }
}

struct AudioTakeScreen: View {
    @State private var phase: Phase<Take>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    init(phase: Phase<Take>) {
        _phase = State(initialValue: phase)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ProLook.ground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                    if let take {
                        ToolbarItem(placement: .principal) {
                            Text("Take \(take.number)")
                                .proLabel()
                                .foregroundStyle(ProLook.ink2)
                        }
                        // Input, rate and format are set here, not during a take.
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Recorder settings", systemImage: "gearshape", action: {})
                                .disabled(take.status == .recording || take.status == .paused)
                        }
                    }
                }
                .task(id: take?.status) { await run() }
                .sensoryFeedback(.impact(weight: .heavy), trigger: take?.status == .recording)
                .sensoryFeedback(.selection, trigger: take?.marks.count)
        }
        .tint(ProLook.ink)
        // One appearance. A tool used on live material in a dark room, or in
        // sunlight, should not change under the operator.
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            session(.opening)
        case .empty:
            ProUnavailable(symbol: "mic.slash", title: "Microphone access is off") {
                Button("Open Settings", action: {})
                    .buttonStyle(ProAccentButtonStyle())
            }
        case .loaded(let take):
            session(take)
        case .failed(let message, let stale?):
            session(stale, note: message)
        case .failed(let message, nil):
            ProUnavailable(symbol: "exclamationmark.triangle", title: "Couldn't open the recorder", message: message) {
                Button("Try again", action: retry)
                    .buttonStyle(ProAccentButtonStyle())
            }
        }
    }

    private func session(_ take: Take, note: String? = nil) -> some View {
        // The work and its readings scroll only when they must. The transport
        // stays under the thumb in every case.
        ViewThatFits(in: .vertical) {
            readings(take, note: note, waveHeight: 220)
            readings(take, note: note, waveHeight: 150)
            ScrollView { readings(take, note: note, waveHeight: 150) }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Transport(take: take, record: toggleRecording, mark: mark, pause: togglePause, reconnect: retry)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(ProLook.panel)
        }
    }

    private func readings(_ take: Take, note: String?, waveHeight: Double) -> some View {
        VStack(spacing: 0) {
            Waveform(bars: take.bars, marks: take.marks)
                .frame(height: waveHeight)
            StatusLabel(status: take.status)
                .padding(.top, 12)
            Text(take.status == .opening ? "--:--:--" : take.timecode)
                .font(.system(.largeTitle, design: .monospaced, weight: .medium).scaled(by: 1.4))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(ProLook.ink)
                .padding(.horizontal)
                .accessibilityLabel("Elapsed \(take.timecode)")
            if let note {
                // What was kept is the one thing the screen cannot show.
                Text(note)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ProLook.ink2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
            Meters(left: take.left, right: take.right)
                .padding(.horizontal)
                .padding(.top, 16)
            if let last = take.lastTake {
                // The saved take appears as a thing on the screen. That is
                // the confirmation; no message follows a stop.
                LastTake(name: last)
                    .padding(.horizontal)
                    .padding(.top, 16)
            }
            Spacer(minLength: 16)
            Panel(take: take, setGain: setGain)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var take: Take? {
        switch phase {
        case .loaded(let take), .failed(_, let take?): take
        default: nil
        }
    }

    private func change(_ edit: (inout Take) -> Void) {
        guard var take else { return }
        edit(&take)
        phase = .loaded(take)
    }

    /// Sample only: while recording, the clock runs and the waveform grows.
    private func run() async {
        while take?.status == .recording {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled, take?.status == .recording else { return }
            change { take in
                take.elapsed += 1
                take.bars.append(Take.sampleBars[take.bars.count % Take.sampleBars.count])
            }
        }
    }

    private func toggleRecording() {
        change { take in
            switch take.status {
            case .ready:
                take.status = .recording
                take.left = 0.74
                take.right = 0.68
            case .recording, .paused:
                take.lastTake = "Take \(take.number) · \(take.timecode)"
                take.number += 1
                take.status = .ready
                take.elapsed = 0
                take.bars = []
                take.marks = []
                take.left = 0.32
                take.right = 0.26
            case .opening, .inputLost:
                break
            }
        }
    }

    private func togglePause() {
        change { take in
            if take.status == .recording { take.status = .paused } else if take.status == .paused { take.status = .recording }
        }
    }

    private func mark() {
        change { $0.marks.append($0.bars.count) }
    }

    private func setGain(_ gain: Int) {
        change { $0.gain = gain }
    }

    /// Sample only: a real app would reopen the input here.
    private func retry() {
        guard var take else {
            phase = .loaded(.ready)
            return
        }
        take.status = .paused
        take.input = "USB mic"
        phase = .loaded(take)
    }
}

// MARK: - The work

/// What has been recorded, with the playhead at its end. Marks are small
/// flags over the bars they were made at.
private struct Waveform: View {
    let bars: [Double]
    let marks: [Int]

    var body: some View {
        Canvas { context, size in
            let step = 5.6, barWidth = 3.0, inset = 16.0
            let middle = size.height / 2
            var centre = Path()
            centre.move(to: CGPoint(x: 0, y: middle))
            centre.addLine(to: CGPoint(x: size.width, y: middle))
            context.stroke(centre, with: .color(ProLook.rule), lineWidth: 1)

            // When the take outgrows the width, the newest part stays in view.
            let capacity = max(1, Int((size.width - inset * 2) / step))
            let first = max(0, bars.count - capacity)
            for (offset, level) in bars[first...].enumerated() {
                let height = max(3, level * (size.height - 32))
                let rect = CGRect(x: inset + Double(offset) * step, y: middle - height / 2, width: barWidth, height: height)
                context.fill(Path(roundedRect: rect, cornerRadius: 1.5), with: .color(ProLook.ink))
            }
            for mark in marks where mark >= first {
                let x = inset + Double(mark - first) * step
                var flag = Path()
                flag.move(to: CGPoint(x: x - 5, y: 6))
                flag.addLine(to: CGPoint(x: x + 5, y: 6))
                flag.addLine(to: CGPoint(x: x, y: 14))
                flag.closeSubpath()
                context.fill(flag, with: .color(ProLook.accent))
            }
            let headX = inset + Double(bars.count - first) * step + 2
            var head = Path()
            head.move(to: CGPoint(x: headX, y: 8))
            head.addLine(to: CGPoint(x: headX, y: size.height - 8))
            context.stroke(head, with: .color(ProLook.accent), lineWidth: 2)
        }
        .accessibilityHidden(true)
    }
}

/// Recording is red and says so: a dot and the word, never the colour alone.
private struct StatusLabel: View {
    let status: Take.Status

    var body: some View {
        Group {
            switch status {
            case .opening: Text("Opening input")
            case .ready: Text("Ready")
            case .paused: Label("Paused", systemImage: "pause.fill")
            case .recording: Label("Rec", systemImage: "circle.fill")
            case .inputLost: Label("Input lost", systemImage: "exclamationmark.triangle.fill")
            }
        }
        .proLabel()
        .foregroundStyle(status == .recording || status == .inputLost ? ProLook.live : ProLook.ink2)
        .frame(minHeight: 16)
        .accessibilityLabel(status == .recording ? "Recording" : "")
    }
}

// MARK: - Readings

private struct Meters: View {
    let left: Double
    let right: Double
    @ScaledMetric(relativeTo: .caption2) private var labelWidth = 14.0

    var body: some View {
        VStack(spacing: 4) {
            MeterRow(name: "L", spoken: "Left level", level: left)
            MeterRow(name: "R", spoken: "Right level", level: right)
            // The scale is written out. When it does not fit, its two ends do.
            ViewThatFits(in: .horizontal) {
                scale(["−48", "−24", "−12", "−6", "0 dB"])
                scale(["−48", "0 dB"])
            }
            .padding(.leading, labelWidth + 8)
        }
    }

    private func scale(_ labels: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                if index > 0 { Spacer(minLength: 4) }
                Text(label)
            }
        }
        .font(.caption2)
        .fontWeight(.semibold)
        .monospacedDigit()
        .foregroundStyle(ProLook.ink2)
        .accessibilityHidden(true)
    }
}

private struct MeterRow: View {
    let name: String
    let spoken: String
    let level: Double
    /// Wide enough for one capital letter at any text size.
    @ScaledMetric(relativeTo: .caption2) private var labelWidth = 14.0

    private static let segments = 28

    var body: some View {
        let lit = Int((level * Double(Self.segments)).rounded())
        HStack(spacing: 8) {
            Text(name)
                .proLabel()
                .foregroundStyle(ProLook.ink2)
                .frame(width: labelWidth, alignment: .leading)
            HStack(spacing: 2) {
                ForEach(0..<Self.segments, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(color(index, lit: lit))
                        .frame(height: 10)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
        .accessibilityValue(level >= 1 ? "Clipping" : "\(Int(level * 100)) percent")
    }

    /// The top two segments turn red only when the level reaches them.
    private func color(_ index: Int, lit: Int) -> Color {
        guard index < lit else { return ProLook.track }
        return index >= Self.segments - 2 ? ProLook.live : ProLook.ink
    }
}

private struct LastTake: View {
    let name: String

    var body: some View {
        HStack(spacing: 12) {
            ProReadout(label: "Saved", value: name)
            Button("Play \(name)", systemImage: "play.fill", action: {})
                .labelStyle(.iconOnly)
                .font(.body)
                .foregroundStyle(ProLook.ink)
                .frame(minWidth: 44, minHeight: 44)
                .overlay { Circle().strokeBorder(ProLook.ink2, lineWidth: 1.5) }
        }
    }
}

// MARK: - The panel

private struct Panel: View {
    let take: Take
    let setGain: (Int) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Two columns of readouts, one column at the accessibility sizes.
            let columns = typeSize.isAccessibilitySize ? 1 : 2
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                ForEach(Array(stride(from: 0, to: readouts.count, by: columns)), id: \.self) { start in
                    GridRow {
                        ForEach(readouts[start..<min(start + columns, readouts.count)], id: \.label) { item in
                            ProReadout(label: item.label, value: item.value)
                        }
                    }
                }
            }
            Rectangle().fill(ProLook.rule).frame(height: 1)
            GainRuler(gain: take.gain, set: setGain)
                .disabled(take.status == .opening || take.status == .inputLost)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ProLook.panel)
        .overlay(alignment: .top) {
            Rectangle().fill(ProLook.rule).frame(height: 1)
        }
        .redacted(reason: take.status == .opening ? .placeholder : [])
    }

    private var readouts: [(label: String, value: String)] {
        [("Input", take.input ?? "None"), ("Space left", take.spaceLeft), ("Rate", take.rate), ("Format", take.format)]
    }
}

/// A ruler of ticks in place of a slider. The value is written beside the
/// label in the accent, and one taller accent tick shows where it sits.
private struct GainRuler: View {
    let gain: Int
    let set: (Int) -> Void
    @State private var width = 1.0
    @Environment(\.isEnabled) private var isEnabled

    private static let range = 0...40

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("Gain")
                    .proLabel()
                    .foregroundStyle(ProLook.ink2)
                Spacer(minLength: 8)
                Text("+\(gain) dB")
                    .proValue()
                    .foregroundStyle(isEnabled ? ProLook.accent : ProLook.ink2)
            }
            Canvas { context, size in
                let count = Self.range.upperBound
                for tick in 0...count {
                    let x = 1 + Double(tick) / Double(count) * (size.width - 2)
                    let isAt = tick == gain
                    let height = isAt ? 28.0 : tick % 5 == 0 ? 16 : 10
                    let rect = CGRect(x: x - (isAt ? 1.5 : 1), y: size.height - height, width: isAt ? 3 : 2, height: height)
                    let color = isAt && isEnabled ? ProLook.accent : tick % 5 == 0 ? ProLook.ink2 : ProLook.track
                    context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(color))
                }
            }
            // The ticks are 28 pt tall inside a 44 pt strip to drag in.
            .frame(height: 44)
            .contentShape(.rect)
            .onGeometryChange(for: Double.self) { $0.size.width } action: { width = $0 }
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                let fraction = min(max(value.location.x / max(width, 1), 0), 1)
                set(Int((fraction * Double(Self.range.upperBound)).rounded()))
            })
        }
        .sensoryFeedback(.selection, trigger: gain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Gain")
        .accessibilityValue("\(gain) decibels")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: set(min(gain + 1, Self.range.upperBound))
            case .decrement: set(max(gain - 1, Self.range.lowerBound))
            @unknown default: break
            }
        }
    }
}

// MARK: - Transport

private struct Transport: View {
    let take: Take
    let record: () -> Void
    let mark: () -> Void
    let pause: () -> Void
    let reconnect: () -> Void

    var body: some View {
        if take.status == .inputLost {
            Button("Reconnect the input", action: reconnect)
                .buttonStyle(ProAccentButtonStyle())
        } else {
            // One row when it fits. Otherwise the record control sits over
            // the other two, which share a row.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    markButton.fixedSize()
                    Spacer(minLength: 0)
                    recordButton
                    Spacer(minLength: 0)
                    pauseButton.fixedSize()
                }
                VStack(spacing: 12) {
                    recordButton
                    HStack(spacing: 12) {
                        markButton
                        pauseButton
                    }
                }
            }
            // The transport is a bar and has to stay under the thumb without
            // covering the readings. It stops growing at the first
            // accessibility size; held down, a control shows the system's
            // large-content preview.
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
    }

    private var isRolling: Bool { take.status == .recording || take.status == .paused }

    // Controls with a consequence carry a word as well as an icon.
    private var markButton: some View {
        Button("Mark", systemImage: "flag", action: mark)
            .buttonStyle(ProSideButtonStyle())
            .disabled(take.status != .recording)
            .accessibilityShowsLargeContentViewer()
    }

    private var pauseButton: some View {
        Button(take.status == .paused ? "Resume" : "Pause",
               systemImage: take.status == .paused ? "play.fill" : "pause.fill",
               action: pause)
            .buttonStyle(ProSideButtonStyle())
            .disabled(!isRolling)
            .accessibilityShowsLargeContentViewer()
    }

    /// A red disc in a ring when ready, a red square in the ring while
    /// recording. The shape changes as well as the meaning.
    private var recordButton: some View {
        Button(action: record) {
            ZStack {
                Circle().strokeBorder(take.status == .opening ? ProLook.track : ProLook.ink, lineWidth: 3)
                RoundedRectangle(cornerRadius: isRolling ? 6 : 27)
                    .fill(take.status == .opening ? ProLook.track : ProLook.live)
                    .frame(width: isRolling ? 28 : 54, height: isRolling ? 28 : 54)
            }
            .frame(width: 72, height: 72)
            .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(take.status == .opening)
        .accessibilityLabel(isRolling ? "Stop and save" : "Record")
    }
}

// MARK: - Empty and failed

/// A full-screen message in this direction's own colours. The system's
/// unavailable view would bring a grey of its own.
private struct ProUnavailable<Action: View>: View {
    let symbol: String
    let title: String
    var message: String?
    @ViewBuilder var action: Action

    var body: some View {
        ScrollsIfNeeded {
            VStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.largeTitle)
                    .foregroundStyle(ProLook.ink2)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(ProLook.ink)
                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(ProLook.ink2)
                }
                action
                    .padding(.top, 12)
            }
            .multilineTextAlignment(.center)
            .padding(32)
        }
    }
}

// MARK: - Sample data

extension Take {
    static let sampleBars: [Double] = [
        0.10, 0.15, 0.23, 0.36, 0.48, 0.42, 0.29, 0.19, 0.32, 0.55, 0.74, 0.65, 0.45, 0.31, 0.23, 0.39,
        0.61, 0.84, 0.71, 0.48, 0.36, 0.26, 0.19, 0.29, 0.45, 0.65, 0.94, 1.00, 0.77, 0.55, 0.39, 0.29,
        0.42, 0.58, 0.48, 0.32, 0.23, 0.16, 0.26, 0.42, 0.68, 0.87, 0.74, 0.52, 0.36, 0.26, 0.19, 0.15,
    ]

    static let opening = Take(number: 3, status: .opening, input: "USB mic")

    static let ready = Take(number: 3, status: .ready, left: 0.32, right: 0.26, input: "USB mic")

    static let recording = Take(
        number: 3, status: .recording, elapsed: 252, left: 0.74, right: 0.68, input: "USB mic",
        bars: Array(sampleBars.prefix(46)), marks: [17])

    /// The input dropped part-way through. What was recorded is kept.
    static let inputLost: Take = {
        var take = recording
        take.status = .inputLost
        take.left = 0
        take.right = 0
        take.input = nil
        return take
    }()

    /// Just stopped: the take is saved and the recorder is ready for the next.
    static let saved = Take(number: 4, status: .ready, left: 0.32, right: 0.26, input: "USB mic", lastTake: "Take 3 · 00:04:12")
}
