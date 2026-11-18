import SwiftUI

// Pattern: a scene that is the reading
// Direction 07 Immersive Environment · kind: status · look: SceneLook.swift
// Sample product (invented): the tide at one cove.
//
// The cove is the sample's own scene, drawn in code. Its sky, land and water
// colours belong to the scene and are not part of the look.

struct TideTable: Equatable {
    var place: String
    /// Minutes after midnight.
    var now: Int
    /// One high tide, in minutes after midnight, and the two heights in metres.
    var highAt: Int
    var high: Double
    var low: Double
    /// Minutes from one high tide to the next.
    var period = 744
    /// A live reading from the buoy, when there is one.
    var water: String?
    /// When that reading was taken, if it is no longer current.
    var waterTakenAt: String?

    func height(at minutes: Int) -> Double {
        let mean = (high + low) / 2, range = (high - low) / 2
        return mean + range * cos(2 * .pi * Double(minutes - highAt) / Double(period))
    }

    /// 0 at the lowest tide, 1 at the highest.
    func level(at minutes: Int) -> Double {
        (height(at: minutes) - low) / (high - low)
    }

    /// The next high and the next low after a moment, soonest first.
    func turns(after minutes: Int) -> [TideTurn] {
        func next(from first: Int) -> Int {
            var time = first
            while time <= minutes { time += period }
            while time - period > minutes { time -= period }
            return time
        }
        let turns = [
            TideTurn(isHigh: true, at: next(from: highAt), height: high),
            TideTurn(isHigh: false, at: next(from: highAt + period / 2), height: low),
        ]
        return turns.sorted { $0.at < $1.at }
    }
}

struct TideTurn: Identifiable, Equatable {
    var isHigh: Bool
    /// Minutes after midnight today. It may run past 1440, into tomorrow.
    var at: Int
    var height: Double
    var id: Int { at }
}

struct TideSceneScreen: View {
    @State private var phase: Phase<TideTable>
    /// How far ahead of now the scene is showing, in minutes.
    @State private var ahead: Double
    @Environment(\.dismiss) private var dismiss

    init(phase: Phase<TideTable>, ahead: Double = 0) {
        _phase = State(initialValue: phase)
        _ahead = State(initialValue: ahead)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                }
                // The status bar follows the sky: dark figures by day, light by night.
                .toolbarColorScheme(isBright ? .light : .dark, for: .navigationBar)
        }
        .sensoryFeedback(.selection, trigger: Int(ahead / 30))
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            scene(.placeholder, shows: 0, notice: nil)
                .redacted(reason: .placeholder)
                .disabled(true)
        case .empty:
            // No place chosen: a calm sea and one thing to do.
            message("No place yet", on: .placeholder) {
                Button("Choose a place") { phase = .loaded(.sample) }
                    .buttonStyle(SceneFilledButtonStyle())
            }
        case .loaded(let table):
            scene(table, shows: Int(ahead), notice: nil)
        case .failed(let message, let stale?):
            scene(stale, shows: Int(ahead), notice: message)
        case .failed(let text, nil):
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                    .foregroundStyle(SceneLook.on2)
                Text("Couldn't load the tide table")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(SceneLook.on2)
                Button("Try again", action: retry)
                    .buttonStyle(SceneFilledButtonStyle())
                    .padding(.top, 12)
            }
            .foregroundStyle(SceneLook.on)
            .multilineTextAlignment(.center)
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SceneLook.floor)
        }
    }

    /// The scene, edge to edge, with the words in its lower half. The water
    /// covers that half at every tide, so the words always have a dark ground.
    private func scene(_ table: TideTable, shows offset: Int, notice: String?) -> some View {
        let minutes = table.now + offset
        let turns = table.turns(after: minutes)
        return VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            if let notice {
                Notice(text: notice, retry: retry)
                    .padding(.bottom, 16)
            }
            Text("\(table.place) · \(offset == 0 ? "now" : TideClock.time(minutes))")
                .sceneLabel()
            Reading(height: table.height(at: minutes), isRising: turns.first?.isHigh ?? true)
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 6) {
                ForEach(turns) { turn in
                    row(turn.isHigh ? "High" : "Low", "\(TideClock.time(turn.at)) · \(TideClock.metres(turn.height))")
                }
                // A live reading says nothing about nine o'clock tonight, so
                // it is shown only for now.
                if offset == 0, let water = table.water {
                    row("Water", table.waterTakenAt.map { "\(water) at \($0)" } ?? water)
                }
            }
            .padding(.top, 16)
            Scrubber(ahead: $ahead, now: table.now)
                .padding(.top, 28)
        }
        .foregroundStyle(SceneLook.on)
        .padding(.horizontal, SceneLook.margin)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background {
            CoveScene(minutes: minutes, level: table.level(at: minutes))
        }
    }

    private func row(_ label: String, _ figure: String) -> some View {
        GridRow {
            Text(label)
                .sceneLabel()
            Text(figure)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }

    private func message(_ title: String, on table: TideTable, @ViewBuilder action: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(SceneLook.on)
            action()
        }
        .padding(.horizontal, SceneLook.margin)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background {
            CoveScene(minutes: table.now, level: table.level(at: table.now))
        }
    }

    private var table: TideTable? {
        switch phase {
        case .loaded(let table), .failed(_, let table?): table
        default: nil
        }
    }

    /// Whether the top of the scene is bright at the moment being shown.
    private var isBright: Bool {
        guard let table else { return true }
        return CoveLight.daylight(at: table.now + Int(ahead)) > 0.5
    }

    /// Sample only: a real app would refetch here.
    private func retry() {
        phase = .loaded(.sample)
    }
}

// MARK: - Words on the scene

/// The value, large and thin, with what it is doing under it.
private struct Reading: View {
    let height: Double
    let isRising: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(height, format: .number.precision(.fractionLength(1)))
                    .font(.largeTitle.scaled(by: 2.8))
                    .fontWeight(.thin)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("m")
                    .font(.title)
                    .fontWeight(.light)
            }
            // Rising and falling differ by their arrow as well as their word.
            Label(isRising ? "Rising" : "Falling", systemImage: isRising ? "arrow.up" : "arrow.down")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

/// What is wrong, in one line over the water, with the retry at its end.
private struct Notice: View {
    let text: String
    let retry: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Label(text, systemImage: "wifi.slash")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer(minLength: 8)
            Button("Try again", action: retry)
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.semibold)
                .underline()
        }
    }
}

/// One control: a line of hours to look ahead through. Moving it changes the
/// scene, the value and the label together.
private struct Scrubber: View {
    @Binding var ahead: Double
    let now: Int
    @State private var width = 1.0

    /// A day, in minutes.
    private static let span = 1440.0

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // The way back shows only once the thumb has moved.
            Button("Back to now") {
                withAnimation(.snappy) { ahead = 0 }
            }
            .buttonStyle(.glass)
            .font(.footnote.weight(.semibold))
            .opacity(ahead > 0 ? 1 : 0)
            .disabled(ahead == 0)
            .padding(.bottom, 4)

            Canvas { context, size in
                // A tick for each hour on the clock, taller at six, noon and midnight.
                let firstHour = (now / 60 + 1) * 60
                for hour in stride(from: firstHour, through: now + Int(Self.span), by: 60) {
                    let x = Double(hour - now) / Self.span * size.width
                    let isMajor = (hour / 60) % 6 == 0
                    let tick = CGRect(x: x - 0.75, y: isMajor ? 8 : 14, width: 1.5, height: isMajor ? 12 : 6)
                    context.fill(Path(roundedRect: tick, cornerRadius: 0.75), with: .color(isMajor ? SceneLook.on : SceneLook.on2))
                    if isMajor {
                        let label = Text(TideClock.hour(hour)).font(.caption).fontWeight(.medium).foregroundStyle(SceneLook.on2)
                        let anchor: UnitPoint = x > size.width - 24 ? .topTrailing : .top
                        context.draw(label, at: CGPoint(x: min(x, size.width), y: 30), anchor: anchor)
                    }
                }
                context.draw(Text("Now").font(.caption).fontWeight(.medium).foregroundStyle(SceneLook.on2), at: CGPoint(x: 0, y: 30), anchor: .topLeading)
            }
            .frame(height: 48)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(SceneLook.on)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .offset(x: ahead / Self.span * width - 14, y: 0)
            }
            .contentShape(.rect)
            .onGeometryChange(for: Double.self) { $0.size.width } action: { width = $0 }
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                let fraction = min(max(value.location.x / max(width, 1), 0), 1)
                // Ten-minute steps: fine enough to watch the water move.
                ahead = (fraction * Self.span / 10).rounded() * 10
            })
        }
    }
}

// MARK: - The scene

/// How much daylight there is, from 0 at night to 1 by day, with the change
/// spread over the forty minutes around sunrise and sunset.
enum CoveLight {
    static let sunrise = 370, sunset = 1180

    static func daylight(at minutes: Int) -> Double {
        let t = Double(((minutes % 1440) + 1440) % 1440)
        let up = (t - Double(sunrise) + 20) / 40, down = (Double(sunset) + 20 - t) / 40
        return min(max(min(up, down), 0), 1)
    }
}

/// The cove: sky, sun or moon, a headland, a tide pole, and the sea standing
/// where the tide is.
struct CoveScene: View {
    /// Minutes after midnight. It may run past 1440.
    let minutes: Int
    /// 0 at the lowest tide, 1 at the highest.
    let level: Double

    var body: some View {
        Canvas { context, size in
            let w = size.width, h = size.height
            let day = CoveLight.daylight(at: minutes)
            let clock = ((minutes % 1440) + 1440) % 1440
            // The water line moves between 44% and 32% of the way down, so the
            // sea always fills more than the lower half.
            let surface = h * (0.44 - 0.12 * min(max(level, 0), 1))

            // Sky
            context.fill(
                Path(CGRect(x: 0, y: 0, width: w, height: h * 0.56)),
                with: .linearGradient(
                    Gradient(colors: [SceneLook.mix(0x0B1B3A, 0x6DBDE6, day), SceneLook.mix(0x2A3D68, 0xD8EEF5, day)]),
                    startPoint: .zero, endPoint: CGPoint(x: 0, y: h * 0.5)))

            // Stars, then the moon or the sun, each on its arc across the sky.
            if day < 1 {
                let stars: [(Double, Double)] = [(0.14, 0.11), (0.37, 0.08), (0.59, 0.15), (0.80, 0.10), (0.89, 0.22), (0.09, 0.24), (0.51, 0.24), (0.69, 0.27)]
                for star in stars {
                    let dot = CGRect(x: w * star.0 - 1.6, y: h * star.1 - 1.6, width: 3.2, height: 3.2)
                    context.fill(Path(ellipseIn: dot), with: .color(Color(fixed: 0xF1F0E4).opacity(1 - day)))
                }
                let night = Double(1440 - CoveLight.sunset + CoveLight.sunrise)
                let since = Double(clock >= CoveLight.sunset ? clock - CoveLight.sunset : clock + 1440 - CoveLight.sunset)
                let centre = Self.arc(since / night, w: w, h: h)
                let moon = CGRect(x: centre.x - 26, y: centre.y - 26, width: 52, height: 52)
                context.fill(Path(ellipseIn: moon), with: .color(Color(fixed: 0xF1F0E4).opacity(1 - day)))
                for crater in [(-8.0, -7.0, 5.0), (9.0, 9.0, 3.5)] {
                    let mark = CGRect(x: centre.x + crater.0 - crater.2, y: centre.y + crater.1 - crater.2, width: crater.2 * 2, height: crater.2 * 2)
                    context.fill(Path(ellipseIn: mark), with: .color(Color(fixed: 0xD9D8CB).opacity(1 - day)))
                }
            }
            if day > 0 {
                let progress = Double(clock - CoveLight.sunrise) / Double(CoveLight.sunset - CoveLight.sunrise)
                let centre = Self.arc(progress, w: w, h: h)
                let sun = CGRect(x: centre.x - 36, y: centre.y - 36, width: 72, height: 72)
                context.fill(Path(ellipseIn: sun), with: .color(Color(fixed: 0xFFF0B8).opacity(day)))
            }

            // Headland
            var land = Path()
            land.move(to: CGPoint(x: 0, y: h * 0.50))
            land.addLine(to: CGPoint(x: 0, y: h * 0.339))
            land.addCurve(to: CGPoint(x: w * 0.294, y: h * 0.343), control1: CGPoint(x: w * 0.09, y: h * 0.316), control2: CGPoint(x: w * 0.204, y: h * 0.32))
            land.addCurve(to: CGPoint(x: w * 0.50, y: h * 0.50), control1: CGPoint(x: w * 0.373, y: h * 0.364), control2: CGPoint(x: w * 0.418, y: h * 0.387))
            land.closeSubpath()
            context.fill(land, with: .color(SceneLook.mix(0x16263F, 0x2F6F6A, day)))

            // Tide pole: bands a hand apart, so the water can be read against them.
            let poleX = w * 0.815, poleTop = h * 0.245, poleBottom = h * 0.53
            let pole = CGRect(x: poleX, y: poleTop, width: 12, height: poleBottom - poleTop)
            context.fill(Path(pole), with: .color(SceneLook.mix(0xB9B7AF, 0xF4F1E8, day)))
            for band in stride(from: poleTop, to: poleBottom, by: 28) {
                context.fill(Path(CGRect(x: poleX, y: band, width: 12, height: 7)), with: .color(SceneLook.mix(0x8E2D1C, 0xC23B22, day)))
            }

            // Sea
            context.fill(
                Path(CGRect(x: 0, y: surface, width: w, height: h - surface)),
                with: .linearGradient(
                    Gradient(colors: [SceneLook.mix(0x102C4A, 0x1B6680, day), SceneLook.mix(0x081A30, 0x0F3F56, day)]),
                    startPoint: CGPoint(x: 0, y: surface), endPoint: CGPoint(x: 0, y: h)))
            // The pole shows faintly under the water.
            context.fill(
                Path(CGRect(x: poleX, y: surface, width: 12, height: max(0, poleBottom - surface))),
                with: .color(Color(fixed: 0xF4F1E8).opacity(0.14)))

            // The water line. Nothing else is drawn on the water: on a small
            // phone the words start just under it.
            var line = Path()
            line.move(to: CGPoint(x: -4, y: surface))
            for x in stride(from: 0.0, through: w + 4, by: 4) {
                line.addLine(to: CGPoint(x: x, y: surface + 3.5 * sin(x / 120 * 2 * .pi)))
            }
            context.stroke(line, with: .color(.white.opacity(0.75)), lineWidth: 2)
        }
        .ignoresSafeArea()
    }

    /// A point on the arc the sun and the moon travel, from rising at the
    /// left to setting at the right.
    private static func arc(_ progress: Double, w: Double, h: Double) -> CGPoint {
        let p = min(max(progress, 0), 1)
        return CGPoint(x: w * (0.12 + 0.76 * p), y: h * 0.40 - sin(.pi * p) * h * 0.23)
    }
}

// MARK: - Words and sample data

enum TideClock {
    /// A clock time in the reader's own format, 12- or 24-hour.
    static func time(_ minutes: Int) -> String {
        date(minutes).formatted(date: .omitted, time: .shortened)
    }

    /// An hour alone, for the scrubber: "6 PM", or "18" on a 24-hour clock.
    static func hour(_ minutes: Int) -> String {
        date(minutes).formatted(.dateTime.hour())
    }

    static func metres(_ height: Double) -> String {
        "\(height.formatted(.number.precision(.fractionLength(1)))) m"
    }

    private static func date(_ minutes: Int) -> Date {
        let clock = ((minutes % 1440) + 1440) % 1440
        return Calendar.current.date(bySettingHour: clock / 60, minute: clock % 60, second: 0, of: .now) ?? .now
    }
}

extension TideTable {
    /// 12:34 PM at the cove: the tide is half-way up and still rising.
    static let sample = TideTable(place: "Skerry Cove", now: 754, highAt: 940, high: 4.1, low: 0.6, water: "14 °C")

    /// The same table with a buoy reading from earlier in the day.
    static let saved: TideTable = {
        var table = sample
        table.waterTakenAt = "9:10 AM"
        return table
    }()

    static let placeholder = TideTable(place: "Place", now: 720, highAt: 906, high: 4, low: 1)
}
