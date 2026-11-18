import SwiftUI

// The parts of look 07 in use, for the product of the look's accepted entry:
// the tide at a few coves. The main screen is the scene with words on its
// water. Every other screen sits under the water and is built only from the
// look's parts. Nothing on a screen names a part or a state; `parts.md` says
// which part is which and where it is in code.

struct ScenePartsScreen: View {
    /// The screen to open: `coves` (the default), `empty`, `loading`,
    /// `offline`, `cove`, `cove-waiting`, `cove-failed`, `alert`,
    /// `alert-error`, `alert-busy`, `crew`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "cove", "cove-waiting", "cove-failed", "alert", "alert-error", "alert-busy":
                SceneCovePage(cove: .gull, opens: screen)
            case "crew": SceneCrewPage()
            default: SceneCovesHome(opens: screen)
            }
        }
        // What can be pressed in a bar is white, as every control here is.
        .tint(SceneLook.on)
    }
}

// MARK: Sample content

private struct TideCove: Identifiable {
    var id: String { table.place }
    let table: TideTable
    /// Whether the harbour has a camera, and so a picture.
    var hasCamera = false

    var name: String { table.place }
    var now: Int { table.now }
    var level: Double { table.level(at: now) }
    var isRising: Bool { table.turns(after: now).first?.isHigh ?? true }
    var height: String { table.height(at: now).formatted(.number.precision(.fractionLength(1))) }
    var arrow: String { isRising ? "arrow.up" : "arrow.down" }

    static let skerry = TideCove(table: .sample)
    static let gull = TideCove(
        table: TideTable(place: "Gull Rock", now: 754, highAt: 1010, high: 3.6, low: 0.4), hasCamera: true)
    static let sample = [
        skerry,
        gull,
        TideCove(table: TideTable(place: "Marram Bay", now: 754, highAt: 690, high: 4.4, low: 0.9)),
        TideCove(table: TideTable(place: "Otter Slip", now: 754, highAt: 1130, high: 3.2, low: 0.5), hasCamera: true),
    ]
}

/// The product's scene drawn for a small place: sky, a light, the headland
/// and the sea standing where the tide is. Its colours are the scene's own,
/// as the large scene's are, and are not part of the look.
private struct CoveVignette: View {
    /// Minutes after midnight. It may run past 1440.
    let minutes: Int
    /// 0 at the lowest tide, 1 at the highest.
    let level: Double

    var body: some View {
        Canvas { context, size in
            let w = size.width, h = size.height
            let day = CoveLight.daylight(at: minutes)
            let surface = h * (0.70 - 0.38 * min(max(level, 0), 1))

            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .linearGradient(
                    Gradient(colors: [SceneLook.mix(0x0B1B3A, 0x6DBDE6, day), SceneLook.mix(0x2A3D68, 0xD8EEF5, day)]),
                    startPoint: .zero, endPoint: CGPoint(x: 0, y: h * 0.7)))

            let radius = h * 0.11
            let light = CGRect(x: w * 0.68 - radius, y: h * 0.24 - radius, width: radius * 2, height: radius * 2)
            context.fill(Path(ellipseIn: light), with: .color(SceneLook.mix(0xF1F0E4, 0xFFF0B8, day)))

            var land = Path()
            land.move(to: CGPoint(x: 0, y: h * 0.74))
            land.addLine(to: CGPoint(x: 0, y: h * 0.36))
            land.addCurve(
                to: CGPoint(x: w * 0.52, y: h * 0.74),
                control1: CGPoint(x: w * 0.22, y: h * 0.28), control2: CGPoint(x: w * 0.42, y: h * 0.5))
            land.closeSubpath()
            context.fill(land, with: .color(SceneLook.mix(0x16263F, 0x2F6F6A, day)))

            context.fill(
                Path(CGRect(x: 0, y: surface, width: w, height: h - surface)),
                with: .linearGradient(
                    Gradient(colors: [SceneLook.mix(0x102C4A, 0x1B6680, day), SceneLook.mix(0x081A30, 0x0F3F56, day)]),
                    startPoint: CGPoint(x: 0, y: surface), endPoint: CGPoint(x: 0, y: h)))
            let line = Path(CGRect(x: 0, y: surface - max(1, h / 44) / 2, width: w, height: max(1, h / 44)))
            context.fill(line, with: .color(.white.opacity(0.75)))
        }
    }
}

/// A drawing of a slipway under a grey sky, standing in for the harbour
/// camera's photograph. Its colours are its own. A real product shows its
/// own pictures here.
private struct SampleSlipway: View {
    static let picture: Image = {
        let renderer = ImageRenderer(content: SampleSlipway().frame(width: 440, height: 220))
        renderer.scale = 2
        return renderer.uiImage.map(Image.init(uiImage:)) ?? Image(systemName: "photo")
    }()

    var body: some View {
        Canvas { context, size in
            let w = size.width, h = size.height
            func fill(_ path: Path, _ hex: UInt32) { context.fill(path, with: .color(Color(fixed: hex))) }
            fill(Path(CGRect(origin: .zero, size: size)), 0xC9CFD2)
            fill(Path(ellipseIn: CGRect(x: w * 0.08, y: h * 0.06, width: w * 0.5, height: h * 0.2)), 0xDDE1E2)
            fill(Path(ellipseIn: CGRect(x: w * 0.5, y: h * 0.16, width: w * 0.44, height: h * 0.16)), 0xD6DBDD)
            fill(Path(CGRect(x: 0, y: h * 0.46, width: w, height: h * 0.54)), 0x5E7C86)
            // The far shore.
            var shore = Path()
            shore.move(to: CGPoint(x: w * 0.55, y: h * 0.46))
            shore.addQuadCurve(to: CGPoint(x: w, y: h * 0.36), control: CGPoint(x: w * 0.8, y: h * 0.33))
            shore.addLine(to: CGPoint(x: w, y: h * 0.46))
            shore.closeSubpath()
            fill(shore, 0x55615A)
            // The slipway, running down into the water.
            var slip = Path()
            slip.move(to: CGPoint(x: 0, y: h))
            slip.addLine(to: CGPoint(x: 0, y: h * 0.62))
            slip.addLine(to: CGPoint(x: w * 0.62, y: h * 0.7))
            slip.addLine(to: CGPoint(x: w * 0.5, y: h))
            slip.closeSubpath()
            fill(slip, 0x9A9890)
            // A boat on the water.
            var hull = Path()
            hull.move(to: CGPoint(x: w * 0.66, y: h * 0.60))
            hull.addLine(to: CGPoint(x: w * 0.88, y: h * 0.60))
            hull.addLine(to: CGPoint(x: w * 0.84, y: h * 0.68))
            hull.addLine(to: CGPoint(x: w * 0.70, y: h * 0.68))
            hull.closeSubpath()
            fill(hull, 0xB5412C)
            fill(Path(CGRect(x: w * 0.74, y: h * 0.52, width: w * 0.07, height: h * 0.08)), 0xEDEAE0)
        }
    }
}

// MARK: Coves: the scene, and the other places

/// The nearest cove is the scene and the reading. Every other cove is one
/// row on the water: a porthole at its own tide, its name, its figure. The
/// screen does not scroll, so no word ever reaches the sky.
private struct SceneCovesHome: View {
    private enum Stage { case loaded, loading, offline }

    @State private var coves: [TideCove]
    @State private var stage: Stage
    @State private var isFinding = false
    @State private var isTrying = false

    init(opens screen: String?) {
        _coves = State(initialValue: screen == "empty" ? [] : TideCove.sample)
        _stage = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
    }

    var body: some View {
        Group {
            if let lead = coves.first {
                scene(lead)
            } else {
                empty
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // The status bar follows the sky: dark figures by day, light by night.
        .toolbarColorScheme(isBright ? .light : .dark, for: .navigationBar)
    }

    private func scene(_ lead: TideCove) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            if stage == .loading {
                SceneGhostReading()
                ForEach(0..<3, id: \.self) { _ in SceneGhostRow() }
            } else {
                if stage == .offline {
                    SceneNotice(
                        text: isTrying ? "Trying…" : "Offline. Times are from the saved table",
                        actionTitle: "Try again") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 12)
                }
                NavigationLink {
                    SceneCovePage(cove: lead, opens: nil)
                } label: {
                    SceneReading(
                        label: "\(lead.name) · now", value: lead.height, unit: "m",
                        trend: lead.isRising ? "Rising" : "Falling", symbol: lead.arrow)
                }
                .buttonStyle(ScenePressStyle())
                VStack(spacing: 0) {
                    ForEach(coves.dropFirst()) { cove in
                        NavigationLink {
                            SceneCovePage(cove: cove, opens: nil)
                        } label: {
                            ScenePartRow(name: cove.name) {
                                ScenePorthole { CoveVignette(minutes: cove.now, level: cove.level) }
                            } end: {
                                SceneFigure(value: "\(cove.height) m", symbol: cove.arrow)
                            }
                        }
                        .buttonStyle(ScenePressStyle())
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, SceneLook.margin)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background {
            if stage == .loading {
                CoveScene(minutes: TideTable.placeholder.now, level: 0.5)
            } else {
                CoveScene(minutes: lead.now, level: lead.level)
            }
        }
    }

    /// No place, so no scene: a scene here would be of nowhere. The water
    /// alone, the empty porthole, and one thing to do.
    private var empty: some View {
        VStack(alignment: .leading, spacing: 0) {
            SceneEmptyPorthole()
            Text("No cove yet")
                .font(SceneLook.emptyTitle)
                .foregroundStyle(SceneLook.on)
                .padding(.top, 24)
            Button {
                Task { await find() }
            } label: {
                if isFinding {
                    HStack(spacing: 8) {
                        ProgressView().tint(SceneLook.ink)
                        Text("Looking nearby…")
                    }
                } else {
                    Text("Find the nearest cove")
                }
            }
            .buttonStyle(SceneMainButtonStyle(isBusy: isFinding))
            .allowsHitTesting(!isFinding)
            .padding(.top, 20)
        }
        .padding(.horizontal, SceneLook.margin)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background { SceneWater() }
    }

    private var isBright: Bool {
        guard let lead = coves.first else { return false }
        return CoveLight.daylight(at: lead.now) > 0.5
    }

    private func find() async {
        isFinding = true
        try? await Task.sleep(for: .seconds(2.5))
        isFinding = false
        coves = TideCove.sample
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

// MARK: One cove, and its alert

/// The same order as the main screen, under water: a picture where the scene
/// stood, the reading, then rows. A turn of the tide starts with a porthole
/// drawn at that turn's own water and hour.
private struct SceneCovePage: View {
    let cove: TideCove

    @State private var limit = 1.0
    @State private var ahead = "1 h"
    @State private var isSetting: Bool
    private let opens: String?

    init(cove: TideCove, opens screen: String?) {
        self.cove = cove
        opens = screen
        _isSetting = State(initialValue: screen?.hasPrefix("alert") == true)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SceneWindow(form: form) {
                    CoveVignette(minutes: cove.now, level: cove.level)
                }
                VStack(alignment: .leading, spacing: 0) {
                    SceneReading(
                        value: cove.height, unit: "m",
                        trend: cove.isRising ? "Rising" : "Falling", symbol: cove.arrow)
                        .padding(.top, 20)
                    VStack(spacing: 0) {
                        ForEach(cove.table.turns(after: cove.now)) { turn in
                            ScenePartRow(name: turn.isHigh ? "High" : "Low", detail: TideClock.time(turn.at)) {
                                ScenePorthole { CoveVignette(minutes: turn.at, level: turn.isHigh ? 1 : 0) }
                            } end: {
                                SceneFigure(value: TideClock.metres(turn.height))
                            }
                        }
                    }
                    .padding(.top, 16)
                    ScenePartRow(name: "Alert below \(TideClock.metres(limit))", detail: "\(ahead) ahead") {
                        SceneGlyph(symbol: "bell.fill")
                    } end: {
                        Button("Change") { isSetting = true }
                            .buttonStyle(SceneTextButtonStyle())
                    }
                    .padding(.top, SceneLook.groupGap)
                }
                .padding(.horizontal, SceneLook.margin)
            }
            .padding(.bottom, 24)
        }
        .background { SceneWater() }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle(cove.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $isSetting) {
            SceneAlertSheet(limit: limit, ahead: ahead, lowest: cove.table.low, opens: opens) { newLimit, newAhead in
                limit = newLimit
                ahead = newAhead
            }
        }
    }

    private var form: PictureForm? {
        guard cove.hasCamera else { return nil }
        return switch opens {
        case "cove-waiting": .waiting
        case "cove-failed": .failed
        default: .loaded(SampleSlipway.picture)
        }
    }
}

/// One number leads the sheet. The button's words say where the action stands.
private struct SceneAlertSheet: View {
    let lowest: Double
    let save: (Double, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var ahead: String
    @State private var atNight = false
    @State private var error: String?
    @State private var isSaving: Bool
    private let staysBusy: Bool

    init(limit: Double, ahead: String, lowest: Double, opens screen: String?, save: @escaping (Double, String) -> Void) {
        self.lowest = lowest
        self.save = save
        staysBusy = screen == "alert-busy"
        _text = State(initialValue: screen == "alert-error" ? "0.3" : Self.plain(limit))
        _ahead = State(initialValue: ahead)
        _error = State(initialValue: screen == "alert-error" ? Self.reason(lowest) : nil)
        _isSaving = State(initialValue: screen == "alert-busy")
    }

    private static func plain(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }

    private static func reason(_ lowest: Double) -> String {
        "The water here never drops below \(TideClock.metres(lowest))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SceneNumberField(name: "Alert below", text: $text, unit: "m", error: error)
                    SceneGroupHead(title: "Tell me ahead")
                        .padding(.top, SceneLook.groupGap)
                    SceneChoices(options: ["30 min", "1 h", "2 h"], selection: $ahead)
                    Toggle("At night too", isOn: $atNight)
                        .font(SceneLook.row)
                        .foregroundStyle(SceneLook.on)
                        .frame(minHeight: SceneLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, SceneLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isSaving ? "Saving…" : "Save alert", action: submit)
                    .buttonStyle(SceneMainButtonStyle(isBusy: isSaving))
                    .allowsHitTesting(!isSaving)
                    .padding(.horizontal, SceneLook.margin)
                    .padding(.bottom, 8)
            }
            .background { SceneWater() }
            .scrollEdgeEffectStyle(.hard, for: .top)
            .navigationTitle("Alert below")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: text) { error = nil }
        }
        .tint(SceneLook.on)
        .presentationBackground(SceneLook.deep)
        // The water is dark in both appearances, so the sheet's bar button
        // and switch are drawn for dark. In light the glass button was pale
        // with white words on it.
        .environment(\.colorScheme, .dark)
    }

    private func submit() {
        guard !isSaving else { return }
        guard let value = Double(text.replacingOccurrences(of: ",", with: ".")), value > lowest else {
            error = Self.reason(lowest)
            return
        }
        isSaving = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            save(value, ahead)
            dismiss()
        }
    }
}

// MARK: Sharing: people, another company's logo, the app's own mark

private struct SceneCrewPage: View {
    @State private var link = Link.none
    private enum Link { case none, linking, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScenePartRow(name: "Mina") {
                    ScenePersonMark(photo: SampleFace(person: .mina))
                } end: {}
                ScenePartRow(name: "Jonas") {
                    ScenePersonMark(initial: "J")
                } end: {}
                ShareLink(item: "See the tide at our coves: https://example.com/tide/join/4410") {
                    ScenePartRow(name: "Invite someone") {
                        ScenePersonMark(initial: nil)
                    } end: {}
                }
                .buttonStyle(ScenePressStyle())

                SceneGroupHead(title: "Buoy data")
                    .padding(.top, SceneLook.groupGap)
                ScenePartRow(name: "Northline") {
                    SceneLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("Linked")
                        .font(SceneLook.detail)
                        .foregroundStyle(SceneLook.on2)
                }
                ScenePartRow(name: "Tempo") {
                    SceneLogoTile { SampleLogo(company: .tempo) }
                } end: {
                    if link == .linked {
                        Text("Linked")
                            .font(SceneLook.detail)
                            .foregroundStyle(SceneLook.on2)
                    } else {
                        Button(link == .linking ? "Linking…" : "Link") { Task { await connect() } }
                            .buttonStyle(SceneTextButtonStyle())
                            .allowsHitTesting(link == .none)
                    }
                }

                // The app's own mark is its scene, small. It belongs here and
                // on the first run, not in a bar.
                ScenePartRow(name: "Tide", detail: "Version 2.1") {
                    ScenePorthole { CoveVignette(minutes: 754, level: 0.5) }
                } end: {}
                .padding(.top, SceneLook.groupGap)
            }
            .padding(.horizontal, SceneLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background { SceneWater() }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Sharing")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func connect() async {
        link = .linking
        try? await Task.sleep(for: .seconds(1.2))
        link = .linked
    }
}

#Preview {
    ScenePartsScreen()
}
