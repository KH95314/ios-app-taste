import SwiftUI

/// Runs one library entry in one state.
///
///     xcrun simctl launch <device> dev.iostaste.patternhost -pattern sectioned-list -state empty
///
/// Some entries have more than one loaded view. Add `-variant` to pick one:
/// `explained-metric` has `fresh` and `poor`, `context-sheet` has `nearby`,
/// `long-read` has `reading`, `service-status` has `down`, `audio-take` has
/// `recording`, `gentle-checkin` has `picked`, `flyer-canvas` has `selected`,
/// `proof-timer` has `paused`. `refill-request` has `sheet`, `asking`,
/// `refused`, `unsent`, `refused-list` and `calm`, which are views to look at,
/// and `says-no`, `offline`, `slow` and `slow-offline`, which only decide how
/// its service answers.
/// Its `success` state has `sheet` too.
///
/// The fourteen ids that end in `-parts` show the parts of one look
/// in use, on a few screens of one product. Their variant names the screen
/// and, after a hyphen, its state: `home`, `empty`, `new-error`,
/// `service-down`, `studio-waiting`. `library/README.md` lists them.
///
/// Add `-scroll end` to open a screen scrolled to the end of its content, to
/// look at what is below the first screenful.
///
/// With no arguments it shows a menu of every entry and state.
@main
struct PatternHostApp: App {
    var body: some Scene {
        WindowGroup {
            HostRoot()
        }
    }
}

enum PreviewState: String, CaseIterable, Identifiable {
    case loaded, loading, empty, error, success
    var id: String { rawValue }
}

enum PatternID: String, CaseIterable, Identifiable {
    case sectionedList = "sectioned-list"
    case explainedMetric = "explained-metric"
    case contextSheet = "context-sheet"
    case longRead = "long-read"
    case dayBlocks = "day-blocks"
    case oneTapLog = "one-tap-log"
    case serviceStatus = "service-status"
    case audioTake = "audio-take"
    case plainDraft = "plain-draft"
    case gentleCheckin = "gentle-checkin"
    case flyerCanvas = "flyer-canvas"
    case pictureWall = "picture-wall"
    case tideScene = "tide-scene"
    case proofTimer = "proof-timer"
    case refillRequest = "refill-request"
    case quietParts = "quiet-parts"
    case dataParts = "data-parts"
    case tactileParts = "tactile-parts"
    case metricParts = "metric-parts"
    case blockParts = "block-parts"
    case mediaParts = "media-parts"
    case readingParts = "reading-parts"
    case proParts = "pro-parts"
    case focusParts = "focus-parts"
    case softParts = "soft-parts"
    case sceneParts = "scene-parts"
    case warmParts = "warm-parts"
    case layerParts = "layer-parts"
    case canvasParts = "canvas-parts"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sectionedList: "Sectioned list without cards"
        case .explainedMetric: "One hero metric, explained"
        case .contextSheet: "Context with a resizable sheet"
        case .longRead: "A long read with quiet tools"
        case .dayBlocks: "A day in colour blocks"
        case .oneTapLog: "A one-tap log that stacks up"
        case .serviceStatus: "One thing, in figures"
        case .audioTake: "A take in progress"
        case .plainDraft: "A plain draft with tools on the keyboard"
        case .gentleCheckin: "A check-in without a score"
        case .flyerCanvas: "A canvas with the tools beneath it"
        case .pictureWall: "A wall of pictures with one leading"
        case .tideScene: "A scene that is the reading"
        case .proofTimer: "A wait with a picture that shows it"
        case .refillRequest: "One action, asked and answered"
        case .quietParts: "Parts of look 01 Quiet Native"
        case .dataParts: "Parts of look 03 Data Precision"
        case .tactileParts: "Parts of look 05 Playful & Tactile"
        case .metricParts: "Parts of look 09 Metric Hero"
        case .blockParts: "Parts of look 10 Color-Blocked"
        case .mediaParts: "Parts of look 14 Media-Led"
        case .readingParts: "Parts of look 02 Editorial Reading"
        case .proParts: "Parts of look 06 Dark Professional"
        case .focusParts: "Parts of look 12 Focused Utility"
        case .softParts: "Parts of look 04 Soft Wellness"
        case .sceneParts: "Parts of look 07 Immersive Environment"
        case .warmParts: "Parts of look 08 Warm Organic"
        case .layerParts: "Parts of look 11 Layered Surfaces"
        case .canvasParts: "Parts of look 13 Canvas-First"
        }
    }

    @ViewBuilder func screen(_ state: PreviewState, variant: String? = nil) -> some View {
        switch self {
        case .sectionedList:
            switch state {
            case .loaded: SectionedListScreen(phase: .loaded(.sample))
            case .loading: SectionedListScreen(phase: .loading)
            case .empty: SectionedListScreen(phase: .empty)
            case .error: SectionedListScreen(phase: .failed(
                message: "This is the last saved list. Changes sync when you reconnect.",
                stale: .sample))
            case .success: SectionedListScreen(phase: .loaded(.sampleWithOneDone))
            }
        case .explainedMetric:
            switch state {
            case .loaded: ExplainedMetricScreen(phase: .loaded(
                variant == "fresh" ? .fresh : variant == "poor" ? .poor : .sample))
            case .loading: ExplainedMetricScreen(phase: .loading)
            case .empty: ExplainedMetricScreen(phase: .empty)
            case .error: ExplainedMetricScreen(phase: .failed(
                message: "No signal since 2:10 PM. Check that it's plugged in and within Wi-Fi range.",
                stale: .lastKnown))
            case .success: ExplainedMetricScreen(phase: .loaded(.sample), reminderTime: "3:52 PM")
            }
        case .contextSheet:
            switch state {
            case .loaded: ContextSheetScreen(phase: .loaded(.sample), selectedID: variant == "nearby" ? nil : 1)
            case .loading: ContextSheetScreen(phase: .loading)
            case .empty: ContextSheetScreen(phase: .empty)
            case .error: ContextSheetScreen(phase: .failed(
                message: "You're offline.",
                stale: nil))
            case .success: ContextSheetScreen(phase: .loaded(.sample), selectedID: 1, reportedIDs: [1])
            }
        case .longRead:
            switch state {
            case .loaded: LongReadScreen(phase: .loaded(.sample), startsMidway: variant == "reading")
            case .loading: LongReadScreen(phase: .loading)
            case .empty: LongReadScreen(phase: .empty)
            case .error: LongReadScreen(phase: .failed(
                message: "This is the copy saved on 12 May.",
                stale: .sample))
            case .success: LongReadScreen(phase: .loaded(.sampleBookmarked))
            }
        case .dayBlocks:
            switch state {
            case .loaded: DayBlocksScreen(phase: .loaded(.sample))
            case .loading: DayBlocksScreen(phase: .loading)
            case .empty: DayBlocksScreen(phase: .empty, day: 6)
            case .error: DayBlocksScreen(phase: .failed(
                message: "This is the plan saved at 7:10 this morning. Changes sync when you reconnect.",
                stale: .sample))
            case .success: DayBlocksScreen(phase: .loaded(.afterWalk))
            }
        case .oneTapLog:
            switch state {
            case .loaded: OneTapLogScreen(phase: .loaded(.sample))
            case .loading: OneTapLogScreen(phase: .loading)
            case .empty: OneTapLogScreen(phase: .empty)
            case .error: OneTapLogScreen(phase: .failed(
                message: "Today's 40 min is kept on this iPhone.",
                stale: .sample))
            case .success: OneTapLogScreen(phase: .loaded(.goalReached))
            }
        case .serviceStatus:
            switch state {
            case .loaded: ServiceStatusScreen(phase: .loaded(variant == "down" ? .down : .sample))
            case .loading: ServiceStatusScreen(phase: .loading)
            case .empty: ServiceStatusScreen(phase: .empty)
            case .error: ServiceStatusScreen(phase: .failed(
                message: "Can't reach the monitor",
                stale: .lastKnown))
            case .success: ServiceStatusScreen(phase: .loaded(.justChecked))
            }
        case .audioTake:
            switch state {
            case .loaded: AudioTakeScreen(phase: .loaded(variant == "recording" ? .recording : .ready))
            case .loading: AudioTakeScreen(phase: .loading)
            case .empty: AudioTakeScreen(phase: .empty)
            case .error: AudioTakeScreen(phase: .failed(
                message: "The take is saved up to 00:04:12.",
                stale: .inputLost))
            case .success: AudioTakeScreen(phase: .loaded(.saved))
            }
        case .plainDraft:
            switch state {
            case .loaded: PlainDraftScreen(phase: .loaded(.sample))
            case .loading: PlainDraftScreen(phase: .loading)
            case .empty: PlainDraftScreen(phase: .empty)
            case .error: PlainDraftScreen(phase: .failed(
                message: "Your changes are saved on this iPhone.",
                stale: .sample))
            case .success: PlainDraftScreen(phase: .loaded(.sample), startsEditing: false)
            }
        case .gentleCheckin:
            switch state {
            case .loaded: GentleCheckinScreen(phase: .loaded(.sample), picked: variant == "picked" ? 2 : nil)
            case .loading: GentleCheckinScreen(phase: .loading)
            case .empty: GentleCheckinScreen(phase: .empty)
            case .error: GentleCheckinScreen(phase: .failed(
                message: "This check-in is kept on this iPhone.",
                stale: .checkedIn))
            case .success: GentleCheckinScreen(phase: .loaded(.checkedIn))
            }
        case .flyerCanvas:
            switch state {
            case .loaded: FlyerCanvasScreen(phase: .loaded(.sample), selection: variant == "selected" ? 1 : nil)
            case .loading: FlyerCanvasScreen(phase: .loading)
            case .empty: FlyerCanvasScreen(phase: .empty)
            case .error: FlyerCanvasScreen(phase: .failed(
                message: "Your changes are kept on this iPhone.",
                stale: .sample))
            case .success: FlyerCanvasScreen(phase: .loaded(.withNewShape), selection: 6, history: [.sample])
            }
        case .pictureWall:
            switch state {
            case .loaded: PictureWallScreen(phase: .loaded(.sample))
            case .loading: PictureWallScreen(phase: .loading)
            case .empty: PictureWallScreen(phase: .loaded(.sample), filter: .mono)
            case .error: PictureWallScreen(phase: .failed(
                message: "This is this morning's catalogue. Reserving needs a connection.",
                stale: .sample))
            case .success: PictureWallScreen(phase: .loaded(.reserved))
            }
        case .tideScene:
            switch state {
            case .loaded: TideSceneScreen(phase: .loaded(.sample))
            case .loading: TideSceneScreen(phase: .loading)
            case .empty: TideSceneScreen(phase: .empty)
            case .error: TideSceneScreen(phase: .failed(
                message: "Offline. Saved tide table.",
                stale: .saved))
            // The scrubber moved to 9:00 PM: night, a lower sea, and a way back.
            case .success: TideSceneScreen(phase: .loaded(.sample), ahead: 506)
            }
        case .proofTimer:
            switch state {
            case .loaded: ProofTimerScreen(phase: .loaded(variant == "paused" ? .paused : .sample))
            case .loading: ProofTimerScreen(phase: .loading)
            case .empty: ProofTimerScreen(phase: .empty)
            case .error: ProofTimerScreen(phase: .failed(
                message: "Alerts are off",
                stale: .sample))
            case .success: ProofTimerScreen(phase: .loaded(.ready))
            }
        case .refillRequest:
            let inhaler = Medicine.salbutamol.id
            switch state {
            case .loaded:
                switch variant {
                case "sheet": RefillRequestScreen(phase: .loaded(.sample), open: inhaler)
                // No request is running here, so the sheet stays as it is while asking.
                case "asking": RefillRequestScreen(phase: .loaded(.sample(.asking)), open: inhaler)
                case "refused": RefillRequestScreen(phase: .loaded(.refused), open: inhaler)
                case "unsent": RefillRequestScreen(phase: .loaded(.unsent), open: inhaler)
                case "refused-list": RefillRequestScreen(phase: .loaded(.refused))
                case "calm": RefillRequestScreen(phase: .loaded(.calm))
                case "says-no": RefillRequestScreen(phase: .loaded(.sample), answers: [.no])
                case "offline": RefillRequestScreen(phase: .loaded(.sample), answers: [.unreachable])
                // A slow service, so the sheet can be closed before it answers.
                case "slow": RefillRequestScreen(phase: .loaded(.sample), delay: .seconds(5))
                case "slow-offline": RefillRequestScreen(
                    phase: .loaded(.sample), answers: [.unreachable], delay: .seconds(5))
                default: RefillRequestScreen(phase: .loaded(.sample))
                }
            case .loading: RefillRequestScreen(phase: .loading)
            case .empty: RefillRequestScreen(phase: .empty)
            case .error: RefillRequestScreen(phase: .failed(
                message: "Can't reach the pharmacy",
                stale: .saved))
            case .success: RefillRequestScreen(phase: .loaded(.requested), open: variant == "sheet" ? inhaler : nil)
            }
        // The parts of a look, in use. The variant names a screen and its state.
        case .quietParts: QuietPartsScreen(screen: variant)
        case .dataParts: DataPartsScreen(screen: variant)
        case .tactileParts: TactilePartsScreen(screen: variant)
        case .metricParts: MetricPartsScreen(screen: variant)
        case .blockParts: BlockPartsScreen(screen: variant)
        case .mediaParts: MediaPartsScreen(screen: variant)
        case .readingParts: ReadingPartsScreen(screen: variant)
        case .proParts: ProPartsScreen(screen: variant)
        case .focusParts: FocusPartsScreen(screen: variant)
        case .softParts: SoftPartsScreen(screen: variant)
        case .sceneParts: ScenePartsScreen(screen: variant)
        case .warmParts: WarmPartsScreen(screen: variant)
        case .layerParts: LayerPartsScreen(screen: variant)
        case .canvasParts: CanvasPartsScreen(screen: variant)
        }
    }
}

private struct Selection: Identifiable {
    let pattern: PatternID
    let state: PreviewState
    var id: String { "\(pattern.rawValue)/\(state.rawValue)" }
}

struct HostRoot: View {
    @State private var selection: Selection?

    private let launchPattern = UserDefaults.standard.string(forKey: "pattern").flatMap(PatternID.init)
    private let launchState = UserDefaults.standard.string(forKey: "state").flatMap(PreviewState.init) ?? .loaded
    private let launchVariant = UserDefaults.standard.string(forKey: "variant")
    private let launchScrollsToEnd = UserDefaults.standard.string(forKey: "scroll") == "end"

    var body: some View {
        if let launchPattern {
            launchPattern.screen(launchState, variant: launchVariant)
                .defaultScrollAnchor(launchScrollsToEnd ? .bottom : nil)
        } else {
            NavigationStack {
                List(PatternID.allCases) { pattern in
                    Section(pattern.title) {
                        ForEach(PreviewState.allCases) { state in
                            Button(state.rawValue.capitalized) {
                                selection = Selection(pattern: pattern, state: state)
                            }
                        }
                    }
                }
                .navigationTitle("Pattern library")
            }
            .fullScreenCover(item: $selection) { selection in
                selection.pattern.screen(selection.state)
                    .safeAreaInset(edge: .top) {
                        Button("Close preview") { self.selection = nil }
                            .buttonStyle(.bordered)
                    }
            }
        }
    }
}
