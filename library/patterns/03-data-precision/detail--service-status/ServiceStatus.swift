import Charts
import SwiftUI

// Pattern: one thing, in figures
// Direction 03 Data Precision · kind: detail · look: DataLook.swift
// Sample product (invented): an uptime monitor's page for one web service.

struct ServiceFigure: Identifiable, Equatable {
    var id: String { name }
    var name: String
    var figure: String
    /// What the figure is compared against, in words with a unit.
    var comparison: String?
    /// Set only when the figure is a state someone should act on.
    var state: DataState?
}

struct ServiceReport: Equatable {
    var name: String
    /// `nil` when the figures are old: an old report makes no claim about now.
    var state: DataState?
    var headline: String
    /// When the data is from, and how often it is refreshed.
    var checked: String
    /// Median response per half hour over the last day, in milliseconds, oldest first.
    var responses: [Int]
    var figures: [ServiceFigure]
    var regions: [ServiceFigure]
    var incidents: [ServiceFigure]
}

enum ChartRange: String, CaseIterable, Identifiable {
    case day = "24 h", week = "7 d", month = "30 d"

    var id: String { rawValue }

    var spoken: String {
        switch self {
        case .day: "24 hours"
        case .week: "7 days"
        case .month: "30 days"
        }
    }
}

struct ServiceStatusScreen: View {
    @State private var phase: Phase<ServiceReport>
    @State private var range = ChartRange.day
    @State private var checkCount = 0
    @Environment(\.dismiss) private var dismiss

    init(phase: Phase<ServiceReport>) {
        _phase = State(initialValue: phase)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DataLook.ground)
                .navigationTitle(report?.name ?? ServiceReport.sample.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                    if report != nil {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Check now", systemImage: "arrow.clockwise", action: checkNow)
                        }
                    }
                }
                .sensoryFeedback(.success, trigger: checkCount)
        }
        // Controls are ink. Colour on this screen always means a state.
        .tint(DataLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            page(.placeholder, notice: nil)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading the report")
        case .empty:
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("No checks yet", systemImage: "waveform.path.ecg")
                } description: {
                    // When the figures will appear is not something the
                    // screen can show any other way.
                    Text("The first check runs within a minute.")
                        .foregroundStyle(DataLook.ink2)
                } actions: {
                    Button("Check now") { phase = .loaded(.sample) }
                        .buttonStyle(DataInkButtonStyle())
                }
            }
        case .loaded(let report):
            page(report, notice: nil)
        case .failed(let message, let stale?):
            page(stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't load the report", systemImage: "wifi.slash")
                } description: {
                    Text(message)
                        .foregroundStyle(DataLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(DataInkButtonStyle())
                }
            }
        }
    }

    private func page(_ report: ServiceReport, notice: String?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let notice {
                    DataNotice(title: notice, retry: retry)
                        .padding(.bottom, 12)
                }
                StatusLine(report: report)
                SectionHead(title: "Response time") {
                    RangeChips(selection: $range)
                }
                ResponseChart(values: report.responses, range: range)
                    .padding(.bottom, 12)
                rows(report.figures)
                SectionHead(title: "By region")
                rows(report.regions)
                if !report.incidents.isEmpty {
                    SectionHead(title: "Incidents")
                    rows(report.incidents)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        // Rows of figures pass under the bar. A hard edge keeps them from
        // showing through the title.
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private func rows(_ figures: [ServiceFigure]) -> some View {
        ForEach(figures) { item in
            DataRow(name: item.name, figure: item.figure, comparison: item.comparison, state: item.state)
        }
    }

    private var report: ServiceReport? {
        switch phase {
        case .loaded(let report), .failed(_, let report?): report
        default: nil
        }
    }

    /// Sample only. The line under the state is the confirmation: it now
    /// says the check was just made. No message follows.
    private func checkNow() {
        guard var report else { return }
        if report.state == nil { report = .sample }
        report.checked = "Checked just now · every minute"
        phase = .loaded(report)
        checkCount += 1
    }

    /// Sample only: a real app would refetch here.
    private func retry() {
        phase = .loaded(.sample)
    }
}

/// The state, in words, before any figure. Under it, when the data is from.
private struct StatusLine: View {
    let report: ServiceReport
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            headline
                .font(.title)
                .fontWeight(.bold)
                // Old figures lose the state colour along with the claim.
                .foregroundStyle(report.state?.color ?? DataLook.ink2)
                // A one-word state has to stay whole. Past this size
                // "Operational" no longer fits a small phone on one line and
                // the system breaks it with a hyphen.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            Text(report.checked)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(DataLook.ink2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    /// At the accessibility sizes the icon sits above the words, so the
    /// words get the full width.
    @ViewBuilder private var headline: some View {
        let symbol = report.state?.symbol ?? "clock"
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: symbol)
                Text(report.headline)
            }
        } else {
            Label(report.headline, systemImage: symbol)
        }
    }
}

private struct SectionHead<Accessory: View>: View {
    let title: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                head
                Spacer(minLength: 12)
                accessory
            }
            VStack(alignment: .leading, spacing: 0) {
                head
                accessory
            }
        }
        .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
        .padding(.top, 12)
    }

    private var head: some View {
        Text(title)
            .dataHead()
            .accessibilityAddTraits(.isHeader)
    }
}

extension SectionHead where Accessory == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

private struct RangeChips: View {
    @Binding var selection: ChartRange

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ChartRange.allCases) { range in
                Button(range.rawValue) { selection = range }
                    .buttonStyle(DataChipStyle(isOn: range == selection))
                    .accessibilityLabel(range.spoken)
                    .accessibilityAddTraits(range == selection ? .isSelected : [])
            }
        }
    }
}

/// Bars are neutral. Only the bars a state refers to take its colour, so a
/// bad half hour stands out without a legend.
private struct ResponseChart: View {
    let values: [Int]
    let range: ChartRange
    @ScaledMetric private var height = 96.0
    /// Half a label of room above the plot, so the top figure of the scale
    /// does not run into the chips over it.
    @ScaledMetric(relativeTo: .footnote) private var labelRoom = 8.0
    @Environment(\.dynamicTypeSize) private var typeSize

    private static let ceiling = 1000
    private static let slow = 500

    var body: some View {
        Chart(Array(values.enumerated()), id: \.offset) { item in
            BarMark(
                x: .value("Half hour", item.offset),
                y: .value("Response", min(item.element, Self.ceiling)),
                width: .fixed(4.5))
                .foregroundStyle(item.element > Self.slow ? DataLook.bad : DataLook.ink2)
                .cornerRadius(1.5)
        }
        .chartXScale(domain: -0.5...Double(values.count) - 0.5)
        .chartYScale(domain: 0...Self.ceiling)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [Self.slow, Self.ceiling]) { value in
                AxisGridLine().foregroundStyle(DataLook.rule)
                AxisValueLabel {
                    Text(value.as(Int.self) == Self.ceiling ? "1 s" : "0.5 s")
                        .font(.footnote)
                        .foregroundStyle(DataLook.ink2)
                }
            }
        }
        .chartXAxis {
            // Two labels, one at each end. A third in the middle collides
            // with them at large text sizes, and says nothing they don't.
            AxisMarks(values: [0, values.count - 1]) { value in
                let isStart = value.as(Int.self) == 0
                AxisValueLabel(anchor: isStart ? .topLeading : .topTrailing) {
                    Text(isStart ? startLabel : "now")
                        .font(.footnote)
                        .foregroundStyle(DataLook.ink2)
                }
            }
        }
        // The chart grows with the text, up to the point where it would push
        // the figures off the first screen.
        .frame(height: min(height, 200))
        .padding(.top, labelRoom)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Response time, last \(range.spoken)")
        .accessibilityValue(summary)
    }

    private var startLabel: String {
        typeSize.isAccessibilitySize ? "−\(range.rawValue)" : "\(range.rawValue) ago"
    }

    private var summary: String {
        let sorted = values.sorted()
        guard let peak = sorted.last, !sorted.isEmpty else { return "No data" }
        let slowCount = values.filter { $0 > Self.slow }.count
        return "Typically \(sorted[sorted.count / 2]) milliseconds. Peak \(peak) milliseconds. \(slowCount) slow periods."
    }
}

extension ServiceReport {
    private static let day: [Int] = [
        150, 168, 172, 160, 181, 175, 166, 190, 178, 171, 163, 185, 176, 169, 182, 174, 620, 910, 240, 188, 177, 170, 184, 179,
        172, 167, 181, 193, 176, 168, 174, 186, 171, 165, 178, 182, 175, 169, 188, 173, 166, 180, 177, 171, 184, 176, 170, 182,
    ]

    private static let regions = [
        ServiceFigure(name: "Frankfurt", figure: "171 ms"),
        ServiceFigure(name: "Virginia", figure: "188 ms"),
        ServiceFigure(name: "Singapore", figure: "412 ms", comparison: "slow", state: .warn),
    ]

    static let sample = ServiceReport(
        name: "Checkout API",
        state: .ok,
        headline: "Operational",
        checked: "Checked 40 s ago · every minute",
        responses: day,
        figures: [
            ServiceFigure(name: "Uptime, 30 days", figure: "99.92%", comparison: "0.05 points lower than last month"),
            ServiceFigure(name: "Median response", figure: "182 ms", comparison: "12 ms slower than last week"),
            ServiceFigure(name: "Slowest 1%", figure: "940 ms", comparison: "about the same"),
            ServiceFigure(name: "Failed checks", figure: "3 of 1,440"),
        ],
        regions: regions,
        incidents: [
            ServiceFigure(name: "Mon 11 PM", figure: "9 min", comparison: "timeouts from Singapore"),
        ])

    /// The same service during an outage.
    static let down: ServiceReport = {
        var report = sample
        report.state = .bad
        report.headline = "Down for 6 min"
        report.checked = "Since 2:02 PM · checked 20 s ago"
        report.figures[0] = ServiceFigure(name: "Uptime, 30 days", figure: "99.91%", comparison: "0.06 points lower than last month")
        report.figures[3] = ServiceFigure(name: "Failed checks", figure: "9 of 1,440", comparison: "6 in the last 6 min", state: .bad)
        report.incidents.insert(ServiceFigure(name: "Today 2:02 PM", figure: "ongoing", comparison: "timeouts from all regions", state: .bad), at: 0)
        return report
    }()

    /// The last report received before the monitor became unreachable.
    static let lastKnown: ServiceReport = {
        var report = sample
        report.state = nil
        report.headline = "Operational at 2:10 PM"
        report.checked = "No newer check has arrived"
        return report
    }()

    /// The sample just after "Check now".
    static let justChecked: ServiceReport = {
        var report = sample
        report.checked = "Checked just now · every minute"
        return report
    }()

    static let placeholder = ServiceReport(
        name: "Service name",
        state: nil,
        headline: "Placeholder",
        checked: "Checked some time ago",
        responses: Array(repeating: 180, count: 48),
        figures: (1...4).map { ServiceFigure(name: "Figure name \($0)", figure: "000 ms", comparison: "compared with before") },
        regions: (1...3).map { ServiceFigure(name: "Region \($0)", figure: "000 ms") },
        incidents: [])
}
