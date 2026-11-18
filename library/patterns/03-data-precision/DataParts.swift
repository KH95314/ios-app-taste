import SwiftUI

// The parts of look 03 in use, for an invented product: a monitor for web
// services. Each screen is built only from the look's parts, one thing leads
// it, and nothing on it names a part or a state: a picture that is waiting
// looks like one, and a button that is busy says what it is doing.
// `parts.md` says which part is which and where it is in code.

struct DataPartsScreen: View {
    /// The screen to open: `services` (the default), `offline`, `loading`,
    /// `empty`, `new`, `new-error`, `new-busy`, `service`, `service-slow`,
    /// `service-down`, `record`, `check`, `check-waiting`, `check-failed`,
    /// `check-busy`, `check-done`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "service": DataService(name: "Checkout API", state: .ok)
            case "service-slow": DataService(name: "Billing export", state: .warn)
            case "service-down": DataService(name: "Checkout API", state: .bad)
            case "record": DataRecord()
            case "check", "check-waiting", "check-failed", "check-busy", "check-done": DataCheck(opens: screen)
            default: DataServices(opens: screen)
            }
        }
        // This look has no hue of its own: what can be pressed is ink.
        .tint(DataLook.ink)
    }
}

// MARK: Sample content

private struct MonitoredService: Identifiable {
    var id: String { name }
    let name: String
    var logo: SampleLogo.Company?
    let code: String
    let value: String
    var readings: [Double] = []
    var state: DataState?
    var word: String?

    static let sample: [MonitoredService] = [
        MonitoredService(
            name: "Billing export", code: "BX", value: "412", readings: [190, 196, 205, 240, 300, 350, 390, 412],
            state: .warn, word: "slow"),
        MonitoredService(name: "Checkout API", logo: .checkout, code: "CO", value: "182", readings: [176, 174, 180, 178, 183, 181, 186, 182]),
        MonitoredService(name: "Search", logo: .search, code: "SE", value: "96", readings: [101, 98, 97, 99, 95, 96, 97, 96]),
    ]
}

/// A rule under the last row of a group, since each row draws only its top.
private struct DataEndRule: View {
    var body: some View {
        Rectangle().fill(DataLook.rule).frame(height: 1)
    }
}

// MARK: Services: the list

/// A service that needs attention is first and carries its state. The rest
/// are one line each. A row opens its service.
private struct DataServices: View {
    private enum Phase { case loaded, loading, offline }

    @State private var services: [MonitoredService]
    @State private var phase: Phase
    @State private var isAdding: Bool
    @State private var isChecking = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _services = State(initialValue: screen == "empty" ? [] : MonitoredService.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isAdding = State(initialValue: screen?.hasPrefix("new") == true)
    }

    var body: some View {
        Group {
            if services.isEmpty { empty } else { list }
        }
        .background(DataLook.ground)
        .navigationTitle("Services")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            // One way to add in each state: this button while a list shows,
            // the button inside the empty state when none does.
            if !services.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add a service", systemImage: "plus") { isAdding = true }
                }
            }
        }
        .sheet(isPresented: $isAdding) {
            DataNewService(opens: opens) { service in
                withAnimation { services.append(service) }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    DataNotice(title: isChecking ? "Checking…" : "Can’t reach the monitor") {
                        Task { await check() }
                    }
                    .padding(.bottom, 12)
                }
                if phase == .loading {
                    ForEach(0..<3, id: \.self) { _ in DataGhostRow() }
                } else {
                    ForEach(services) { service in
                        NavigationLink {
                            DataService(name: service.name, state: service.state ?? .ok)
                        } label: {
                            DataReadingRow(
                                name: service.name, value: service.value, unit: "ms", readings: service.readings,
                                state: service.state, word: service.word) {
                                // One width for a logo and for a code, so that
                                // every name starts at the same edge.
                                Group {
                                    if let logo = service.logo {
                                        DataLogoTile { SampleLogo(company: logo) }
                                    } else {
                                        DataCodeTag(code: service.code)
                                    }
                                }
                                .frame(width: DataLook.leadWidth, alignment: .leading)
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(DataRowPressStyle())
                    }
                }
                DataEndRule()
            }
            .padding(.horizontal, DataLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            DataEmptyChart()
            Text("No services yet")
                .font(DataLook.emptyTitle)
                .foregroundStyle(DataLook.ink)
                .padding(.top, 16)
            Button("Add a service") { isAdding = true }
                .buttonStyle(DataInkButtonStyle())
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private func check() async {
        isChecking = true
        try? await Task.sleep(for: .seconds(2.5))
        isChecking = false
    }
}

// MARK: New service: a sheet

/// Fields are rows with what is typed at the right. The wide button is the
/// sheet's one action, and its words say where the action stands.
private struct DataNewService: View {
    let add: (MonitoredService) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var address: String
    @State private var limit: String
    @State private var addressError: String?
    @State private var limitError: String?
    @State private var isChecking: Bool
    @State private var alertsOn = true
    @State private var summaryOn = false
    private let staysBusy: Bool

    init(opens screen: String?, add: @escaping (MonitoredService) -> Void) {
        self.add = add
        staysBusy = screen == "new-busy"
        _address = State(initialValue: screen == "new-error" || screen == "new-busy" ? "pay.northline.example" : "")
        _limit = State(initialValue: screen == "new-error" ? "50" : "500")
        _limitError = State(initialValue: screen == "new-error" ? Self.limitReason : nil)
        _isChecking = State(initialValue: screen == "new-busy")
    }

    private static let limitReason = "Enter 100 ms or more"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    DataFieldRow(
                        name: "Address", text: $address, prompt: "status.example.com", error: addressError,
                        keyboard: .URL, width: 230, onSubmit: submit)
                    DataFieldRow(name: "Alert when slower than", text: $limit, unit: "ms", prompt: "500", error: limitError, onSubmit: submit)
                    Group {
                        Toggle("Alert me", isOn: $alertsOn)
                        Toggle("Weekly summary", isOn: $summaryOn)
                    }
                    .toggleStyle(DataOnOffToggleStyle())
                    DataEndRule()
                }
                .padding(.horizontal, DataLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isChecking ? "Checking…" : "Add service", action: submit)
                    .buttonStyle(DataWideButtonStyle(isBusy: isChecking))
                    .allowsHitTesting(!isChecking)
                    .padding(.horizontal, DataLook.margin)
                    .padding(.bottom, 8)
            }
            .background(DataLook.ground)
            .navigationTitle("New service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: address) { addressError = nil }
            .onChange(of: limit) { limitError = nil }
        }
        .tint(DataLook.ink)
        .presentationBackground(DataLook.ground)
    }

    private func submit() {
        guard !isChecking else { return }
        let host = address.trimmingCharacters(in: .whitespaces)
        addressError = host.isEmpty ? "Needs an address" : host.contains(".") ? nil : "Not an address"
        limitError = (Int(limit) ?? 0) >= 100 ? nil : Self.limitReason
        guard addressError == nil, limitError == nil else { return }
        isChecking = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            add(MonitoredService(name: host, code: String(host.prefix(2)).uppercased(), value: "142"))
            dismiss()
        }
    }
}

// MARK: One service

/// The state leads, and a state someone must act on lights the top of the
/// screen. Then the chart, then the regions.
private struct DataService: View {
    let name: String
    let state: DataState

    @State private var range = "24 h"

    private static let ranges = ["24 h", "7 d", "30 d"]
    private static let calm: [Double] = [
        150, 168, 172, 160, 181, 175, 166, 190, 178, 171, 163, 185, 176, 169, 182, 174, 181, 177, 172, 188, 177, 170, 184, 179,
        172, 167, 181, 193, 176, 168, 174, 186, 171, 165, 178, 182, 175, 169, 188, 173, 166, 180, 177, 171, 184, 176, 170, 182,
    ]

    private var title: String {
        switch state {
        case .ok: "Operational"
        case .warn: "Slow from Singapore"
        case .bad: "Down for 6 min"
        }
    }

    private var detail: String? {
        switch state {
        case .ok: nil
        case .warn: "412 ms, usually 190"
        case .bad: "Since 14:02"
        }
    }

    private var latency: [Double] {
        switch state {
        case .ok: Self.calm
        case .warn: Array(Self.calm.dropLast(6)) + [214, 262, 318, 356, 390, 412]
        case .bad: Array(Self.calm.dropLast(3)) + [1000, 1000, 1000]
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                DataStateLine(state: state, title: title, detail: detail)
                chart
                    .padding(.top, 32)
                DataGroupHead(title: "By region")
                    .padding(.top, 12)
                region("Frankfurt", "FRA", "171", [168, 172, 166, 175, 169, 171, 170, 171])
                region("Virginia", "IAD", "188", [176, 174, 180, 178, 183, 181, 186, 188])
                region("Singapore", "SIN", state == .warn ? "412" : "196", state == .warn
                    ? [190, 196, 205, 240, 300, 350, 390, 412] : [192, 198, 194, 197, 193, 199, 195, 196], slow: state == .warn)
                DataEndRule()
            }
            .padding(.horizontal, DataLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(alignment: .top) {
            DataWash(state: state)
                .frame(height: 260)
                .ignoresSafeArea(edges: .top)
        }
        .background(DataLook.ground)
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The state line has already said which region and what; the row adds
    /// the figure and the colour, and no second word.
    @ViewBuilder private func region(_ name: String, _ code: String, _ value: String, _ readings: [Double], slow: Bool = false) -> some View {
        if state == .bad {
            DataReadingRow(name: name, value: "503", unit: "", state: .bad) { DataCodeTag(code: code) }
        } else {
            DataReadingRow(name: name, value: value, unit: "ms", readings: readings, state: slow ? .warn : nil) {
                DataCodeTag(code: code)
            }
        }
    }

    private var chart: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Response time").dataHead()
                Spacer()
                ForEach(Self.ranges, id: \.self) { item in
                    Button(item) { range = item }
                        .buttonStyle(DataChipStyle(isOn: range == item))
                }
            }
            DataBars(values: latency, ceiling: 1000, limit: 500)
                .padding(.trailing, 44)
                .overlay(alignment: .topTrailing) {
                    VStack(alignment: .trailing, spacing: 22) {
                        Text("1 s")
                        Text("0.5 s")
                    }
                    .offset(y: -8)
                }
            HStack {
                Text("\(range) ago")
                Spacer()
                Text("now")
            }
            .padding(.trailing, 44)
        }
        .font(DataLook.meta)
        .monospacedDigit()
        .foregroundStyle(DataLook.ink2)
    }
}

// MARK: Thirty days: figures

/// One figure leads, over the days it sums up. The four under it are a step
/// smaller, two to a line.
private struct DataRecord: View {
    private static let days: [DataState?] = (0..<30).map { $0 == 16 ? .bad : $0 == 23 ? .warn : nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                DataFigure(label: "Uptime", value: "99.92", unit: "%")
                DataDayStrip(days: Self.days, from: "30 days ago", to: "today")
                    .padding(.top, 10)
                Grid(alignment: .topLeading, horizontalSpacing: 16, verticalSpacing: 24) {
                    GridRow {
                        DataFigure(label: "Median response", value: "182", unit: "ms", note: "12 ms slower than last week", isLead: false)
                        DataFigure(label: "Slowest 1%", value: "940", unit: "ms", note: "about the same", isLead: false)
                    }
                    GridRow {
                        DataFigure(label: "Failed checks", value: "9", unit: "of 43,200", isLead: false)
                        DataFigure(label: "Longest outage", value: "6", unit: "min", isLead: false)
                    }
                }
                .padding(.top, 36)
            }
            .padding(.horizontal, DataLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(DataLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Last 30 days")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: A failed check: a picture, people, one action

/// What the check saw, who is on it, and the one thing to do. The button's
/// words say where the action stands: to do, on its way, done.
private struct DataCheck: View {
    private enum Step { case toDo, sending, done }

    @State private var step: Step
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _step = State(initialValue: screen == "check-busy" ? .sending : screen == "check-done" ? .done : .toDo)
    }

    private var picture: PictureForm {
        switch opens {
        case "check-waiting": .waiting
        case "check-failed": .failed
        default: .loaded(SamplePage.picture)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 14) {
                    DataPicture(form: picture)
                    VStack(alignment: .leading, spacing: 2) {
                        Label("503 Service Unavailable", systemImage: DataState.bad.symbol)
                            .font(DataLook.strong)
                            .foregroundStyle(DataLook.bad)
                        Text("Singapore · 14:02")
                            .font(DataLook.meta)
                            .foregroundStyle(DataLook.ink2)
                    }
                }
                DataGroupHead(title: "On call")
                    .padding(.top, 12)
                person("Mina Okafor", "Paged 14:03") { DataPersonMark(photo: SampleFace(person: .mina)) }
                person("Jonas Keller", "Backup") { DataPersonMark(initials: "JK") }
                person(nil, "Second backup") { DataPersonMark(initials: nil) }
                DataEndRule()
                Button {
                    Task { await acknowledge() }
                } label: {
                    switch step {
                    case .toDo: Text("Acknowledge")
                    case .sending:
                        HStack(spacing: 8) {
                            ProgressView().tint(DataLook.ground)
                            Text("Acknowledging…")
                        }
                    case .done: Text("Acknowledged")
                    }
                }
                .buttonStyle(DataInkButtonStyle(isBusy: step == .sending))
                .allowsHitTesting(step == .toDo)
                .disabled(step == .done)
                .padding(.top, 24)
            }
            .padding(.horizontal, DataLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(DataLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Failed check")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func person(_ name: String?, _ role: String, @ViewBuilder mark: () -> some View) -> some View {
        HStack(spacing: 10) {
            mark()
            Text(name ?? "Nobody yet")
                .foregroundStyle(name == nil ? DataLook.ink2 : DataLook.ink)
            Spacer(minLength: 8)
            Text(role)
                .font(DataLook.meta)
                .foregroundStyle(DataLook.ink2)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: DataLook.rowMin)
        .overlay(alignment: .top) { DataEndRule() }
    }

    private func acknowledge() async {
        step = .sending
        try? await Task.sleep(for: .seconds(1.2))
        guard opens != "check-busy" else { return }
        step = .done
    }
}

/// A drawing of a web page with a red banner, standing in for what a check
/// saw. A real product shows its own capture here.
private struct SamplePage: View {
    static let picture: Image = {
        let renderer = ImageRenderer(content: SamplePage().frame(width: 192, height: 128))
        renderer.scale = 3
        return renderer.uiImage.map(Image.init(uiImage:)) ?? Image(systemName: "photo")
    }()

    var body: some View {
        Canvas { context, size in
            let unit = size.width / 72
            func box(_ x: Double, _ y: Double, _ width: Double, _ height: Double, _ radius: Double, _ hex: UInt32) {
                let rect = CGRect(x: x * unit, y: y * unit, width: width * unit, height: height * unit)
                context.fill(Path(roundedRect: rect, cornerRadius: radius * unit), with: .color(Color(fixed: hex)))
            }
            box(0, 0, 72, 48, 0, 0xFFFFFF)
            box(0, 0, 72, 9, 0, 0xE4E7EC)
            box(4.4, 2.9, 3.2, 3.2, 1.6, 0xB6BCC6)
            box(9.4, 2.9, 3.2, 3.2, 1.6, 0xB6BCC6)
            box(7, 15, 34, 4.5, 2, 0xAEB4BE)
            box(7, 24, 58, 3, 1.5, 0xD5D9DF)
            box(7, 30, 48, 3, 1.5, 0xD5D9DF)
            box(7, 38, 24, 6, 2, 0xD2544A)
        }
    }
}

#Preview {
    DataPartsScreen()
}
