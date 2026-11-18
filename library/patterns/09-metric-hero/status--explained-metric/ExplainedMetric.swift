import SwiftUI

// Pattern: one hero metric, explained
// Direction 09 Metric Hero · kind: status · look: MetricLook.swift
// Sample product (invented): a CO₂ monitor for one room.

struct AirReading: Equatable {
    var co2: Int
    var updated: String
    var others: [SupportingMetric]
}

struct SupportingMetric: Identifiable, Equatable {
    var id: String { label }
    var label: String
    var symbol: String
    var value: String
    var note: String
}

/// The meaning of the number. Each band has its own plate colour, its own
/// word and its own icon shape, so the state never depends on colour alone.
enum AirBand: Int {
    case fresh, stuffy, poor

    init(co2: Int) {
        self = co2 < 800 ? .fresh : co2 < 1200 ? .stuffy : .poor
    }

    var title: String {
        switch self {
        case .fresh: "Fresh"
        case .stuffy: "Getting stuffy"
        case .poor: "Poor air"
        }
    }

    var symbol: String {
        switch self {
        case .fresh: "checkmark.circle.fill"
        case .stuffy: "exclamationmark.triangle.fill"
        case .poor: "exclamationmark.octagon.fill"
        }
    }

    var plate: MetricLook.Plate {
        switch self {
        case .fresh: MetricLook.fresh
        case .stuffy: MetricLook.stuffy
        case .poor: MetricLook.poor
        }
    }

    /// The band's limits in words, for when four tick labels won't fit under
    /// the scale. The verdict is right above it, so it does not repeat it.
    var range: String {
        switch self {
        case .fresh: "Under 800 ppm"
        case .stuffy: "800 to 1,200 ppm"
        case .poor: "Over 1,200 ppm"
        }
    }
}

private enum HistoryRoute: Hashable { case today }

struct ExplainedMetricScreen: View {
    @State private var phase: Phase<AirReading>
    @State private var reminderTime: String?

    init(phase: Phase<AirReading>, reminderTime: String? = nil) {
        _phase = State(initialValue: phase)
        _reminderTime = State(initialValue: reminderTime)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(MetricLook.ground)
                .foregroundStyle(MetricLook.ink)
                // The number is the title of this screen, so the bar title stays small.
                .navigationTitle("Bedroom")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: HistoryRoute.self) { _ in ReadingsHistory() }
        }
        // Controls outside the plate are neutral: the plate is the only colour.
        .tint(MetricLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            page(.placeholder, isLoading: true)
        case .empty:
            ScrollsIfNeeded {
                // The title says what is missing and the button says what to
                // do, so no sentence sits between them.
                ContentUnavailableView {
                    Label("No sensor in this room", systemImage: "sensor")
                } actions: {
                    Button("Pair a sensor") { phase = .loaded(.sample) }
                        .buttonStyle(InkButtonStyle(fill: MetricLook.ink, label: MetricLook.ground))
                        .padding(.top, 8)
                }
            }
        case .loaded(let reading):
            page(reading)
        case .failed(let message, let stale?):
            page(stale, staleMessage: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't reach the sensor", systemImage: "wifi.slash")
                } description: {
                    // The system's grey for this line is about 3.5:1. The look's
                    // second ink holds 4.5:1.
                    Text(message)
                        .foregroundStyle(MetricLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(InkButtonStyle(fill: MetricLook.ink, label: MetricLook.ground))
                }
            }
        }
    }

    private func page(_ reading: AirReading, staleMessage: String? = nil, isLoading: Bool = false) -> some View {
        // A verdict is only given on a live reading, never on an old one.
        let band = staleMessage == nil && !isLoading ? AirBand(co2: reading.co2) : nil
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let staleMessage {
                    MetricNotice(title: "Sensor offline", message: staleMessage, retry: retry)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }

                Plate(reading: reading, band: band, isLoading: isLoading) {
                    if let band, band != .fresh { reminder(on: band.plate) }
                }

                SupportingReadings(metrics: reading.others)
                    .padding(.top, 24)
                    .redacted(reason: isLoading ? .placeholder : [])
                    .disabled(isLoading)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    @ViewBuilder private func reminder(on plate: MetricLook.Plate) -> some View {
        if let reminderTime {
            // The result replaces the button it came from.
            VStack(alignment: .leading, spacing: 0) {
                Label("Reminder set for \(reminderTime)", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                Button("Cancel reminder") { withAnimation { self.reminderTime = nil } }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .underline()
                    .frame(minHeight: 44)
            }
        } else {
            Button {
                let time = Date.now.addingTimeInterval(600).formatted(date: .omitted, time: .shortened)
                withAnimation { reminderTime = time }
            } label: {
                Label("Remind me in 10 minutes", systemImage: "bell")
            }
            // The plate's two colours, swapped.
            .buttonStyle(InkButtonStyle(fill: plate.on, label: plate.fill))
        }
    }

    /// Sample only: a real app would reconnect here.
    private func retry() {
        phase = .loaded(.sample)
    }
}

/// The hero block. Its fill is the state, so the state reads before the
/// number does. It holds the label, the number, the verdict, the scale and at
/// most one action, and no sentence of explanation.
private struct Plate<Action: View>: View {
    let reading: AirReading
    /// `nil` while connecting or when the reading is old. The plate turns
    /// grey and drops the verdict, the scale and the action.
    let band: AirBand?
    let isLoading: Bool
    @ViewBuilder var action: Action
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let look = band?.plate ?? MetricLook.idle
        // The unit sits beside the number, and under it when text is very large.
        let numberLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 8))

        VStack(alignment: .leading, spacing: 0) {
            // This slot always says how current the number is.
            Text(isLoading ? "CO₂ · connecting" : "CO₂ · \(reading.updated)")
                .metricLabel()

            numberLayout {
                Text(reading.co2, format: .number)
                    .font(.largeTitle.scaled(by: 3.2))
                    .fontWeight(.black)
                    .monospacedDigit()
                    .tracking(-3)
                    // One line, always. A longer number shrinks to fit.
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    // Already about six times body size, so it stops growing early.
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .redacted(reason: isLoading ? .placeholder : [])
                Text("ppm")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isLoading ? "Connecting to the sensor" : "\(reading.co2) parts per million")

            if let band {
                Label(band.title, systemImage: band.symbol)
                    .font(.title)
                    .fontWeight(.bold)
                    // Beside the number its own line height is gap enough.
                    // Under a stacked unit it needs one.
                    .padding(.top, dynamicTypeSize.isAccessibilitySize ? 8 : 0)
                BandScale(co2: reading.co2, band: band)
                    .padding(.top, 24)
                action
                    .padding(.top, 20)
            }
        }
        .foregroundStyle(look.on)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(look.fill, in: .rect(cornerRadius: 32))
    }
}

/// Where the number sits between fresh and poor, drawn in the plate's one ink
/// colour. Bands are 400–800, 800–1,200 and 1,200–2,000, which is why the
/// track splits 1 : 1 : 2.
private struct BandScale: View {
    let co2: Int
    let band: AirBand
    @ScaledMetric private var bar = 10.0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let ink = band.plate.on
        let current = band.rawValue
        VStack(alignment: .leading, spacing: 6) {
            Canvas { context, size in
                let gap = 4.0
                let unit = (size.width - gap * 2) / 4
                let top = size.height - bar
                var x = 0.0
                for (index, width) in [unit, unit, unit * 2].enumerated() {
                    let rect = CGRect(x: x, y: top, width: width, height: bar)
                    if index == current {
                        // The band the reading is in is filled.
                        context.fill(Path(roundedRect: rect, cornerRadius: bar / 2), with: .color(ink))
                    } else {
                        let outline = Path(roundedRect: rect.insetBy(dx: 0.75, dy: 0.75), cornerRadius: bar / 2)
                        context.stroke(outline, with: .color(ink), lineWidth: 1.5)
                    }
                    x += width + gap
                }
                let fraction = min(max((Double(co2) - 400) / 1600, 0), 1)
                let tipX = min(max(fraction * size.width, 7), size.width - 7)
                var pointer = Path()
                pointer.move(to: CGPoint(x: tipX, y: top - 2))
                pointer.addLine(to: CGPoint(x: tipX - 7, y: top - 11))
                pointer.addLine(to: CGPoint(x: tipX + 7, y: top - 11))
                pointer.closeSubpath()
                context.fill(pointer, with: .color(ink))
            }
            .frame(height: bar + 11)

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    // Four numbers in a row collide at these sizes, so the
                    // limits of the current band are given as one short line.
                    Text(band.range)
                } else {
                    // Each label sits under its own boundary: 0, 1/4, 1/2 and
                    // the end of the track.
                    ZStack {
                        Text("400").frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 0) {
                            Text("800").frame(maxWidth: .infinity)
                            Color.clear.frame(height: 0)
                        }
                        Text("1,200")
                        Text("2,000").frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .font(.caption)
            .fontWeight(.semibold)
            .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Scale from 400 to 2,000 parts per million")
        .accessibilityValue("\(co2), \(band.title)")
    }
}

/// The other readings are plain rows on the ground with a hairline between
/// them. They are never turned into more plates.
private struct SupportingReadings: View {
    let metrics: [SupportingMetric]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Also in this room")
                .metricLabel()
                .foregroundStyle(MetricLook.ink2)
                .padding(.bottom, 4)
            ForEach(metrics) { metric in
                MetricRow(metric: metric)
                rule
            }
            NavigationLink(value: HistoryRoute.today) {
                HStack {
                    Text("Today's readings")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(MetricLook.ink2)
                }
                .frame(minHeight: 56)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
    }

    private var rule: some View {
        Rectangle()
            .fill(MetricLook.rule)
            .frame(height: 1)
    }
}

private struct MetricRow: View {
    let metric: SupportingMetric
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Side by side at ordinary sizes, stacked when text is very large.
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let layout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout(alignment: .center))
        layout {
            Label {
                Text(metric.label)
            } icon: {
                Image(systemName: metric.symbol)
                    .foregroundStyle(MetricLook.ink2)
            }
            if !isLarge { Spacer() }
            VStack(alignment: isLarge ? .leading : .trailing) {
                Text(metric.value)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                // Kept because the value alone does not say whether it is
                // usual. A note that only repeated the value would be cut.
                Text(metric.note)
                    .font(.footnote)
                    .foregroundStyle(MetricLook.ink2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .padding(.vertical, isLarge ? 10 : 0)
        .accessibilityElement(children: .combine)
    }
}

private struct ReadingsHistory: View {
    private let rows: [(time: String, co2: Int)] = [
        ("3:40 PM", 842), ("3:00 PM", 790), ("2:00 PM", 655), ("1:00 PM", 540),
        ("Noon", 512), ("11:00 AM", 498), ("10:00 AM", 620), ("9:00 AM", 910),
    ]

    var body: some View {
        List(rows, id: \.time) { row in
            let band = AirBand(co2: row.co2)
            LabeledContent {
                Text("\(row.co2) ppm")
                    .monospacedDigit()
                    .foregroundStyle(MetricLook.ink)
            } label: {
                // Away from the plate the band is an icon shape and a word.
                Label {
                    Text(row.time)
                    Text(band.title)
                        .foregroundStyle(MetricLook.ink2)
                } icon: {
                    Image(systemName: band.symbol)
                        .foregroundStyle(MetricLook.ink)
                }
            }
            .listRowBackground(MetricLook.ground)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(MetricLook.ground)
        .navigationTitle("Today's readings")
    }
}

extension AirReading {
    static let sample = AirReading(co2: 842, updated: "2 min ago", others: .sample)

    /// The last value received before the sensor dropped off.
    static let lastKnown = AirReading(co2: 842, updated: "last reading 2:10 PM", others: .sample)

    static let placeholder = AirReading(co2: 888, updated: "just now", others: .sample)

    /// The other two bands, for checking every plate.
    static let fresh = AirReading(co2: 540, updated: "2 min ago", others: .sample)
    static let poor = AirReading(co2: 1460, updated: "2 min ago", others: .sample)
}

extension [SupportingMetric] {
    static let sample: [SupportingMetric] = [
        SupportingMetric(label: "Temperature", symbol: "thermometer.medium", value: "23.4 °C", note: "0.6° warmer than usual"),
        SupportingMetric(label: "Humidity", symbol: "humidity", value: "58%", note: "typical for this hour"),
        SupportingMetric(label: "Fine particles", symbol: "aqi.low", value: "8 µg/m³", note: "low"),
    ]
}
