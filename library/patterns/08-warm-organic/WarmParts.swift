import SwiftUI

// The parts of look 08 in use, for the entry's invented product: a timer for
// proofing bread dough. Each screen is built only from the look's parts, a
// picture leads it, and nothing on it names a part or a state. `parts.md`
// says which part is which and where it is in code.

struct WarmPartsScreen: View {
    /// The screen to open: `counter` (the default), `counter-waiting`,
    /// `counter-failed`, `empty`, `loading`, `offline`, `rise`, `rise-error`,
    /// `rise-busy`, `recipe`, `recipe-waiting`, `recipe-failed`,
    /// `recipe-plain`, `kitchen`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "recipe", "recipe-waiting", "recipe-failed":
                WarmRecipeScreen(recipe: .rye, opens: screen)
            case "recipe-plain": WarmRecipeScreen(recipe: .focaccia, opens: screen)
            case "kitchen": WarmKitchen()
            default: WarmCounter(opens: screen)
            }
        }
        // The clay hue is for what can be pressed.
        .tint(WarmLook.accent)
    }
}

// MARK: Sample content

private struct WarmRecipe: Identifiable {
    struct Step {
        let name: String
        let minutes: Int
    }

    var id: String { name }
    let name: String
    /// A free picture's name, or `nil` for a recipe with no photograph.
    var picture: String?
    let steps: [Step]

    var line: String {
        "\(steps.count) steps · \(warmLength(steps.reduce(0) { $0 + $1.minutes }))"
    }

    static let countryLoaf = WarmRecipe(name: "Country loaf", steps: [
        Step(name: "Mix", minutes: 20), Step(name: "First rise", minutes: 112), Step(name: "Shape", minutes: 10),
        Step(name: "Second rise", minutes: 45), Step(name: "Bake", minutes: 40),
    ])
    static let rye = WarmRecipe(name: "Seeded rye", picture: "dough-in-hands", steps: [
        Step(name: "Mix", minutes: 15), Step(name: "Rise", minutes: 180), Step(name: "Bake", minutes: 55),
    ])
    static let focaccia = WarmRecipe(name: "Focaccia", steps: [
        Step(name: "Mix", minutes: 10), Step(name: "Rise", minutes: 120), Step(name: "Dimple and top", minutes: 10),
        Step(name: "Bake", minutes: 25),
    ])
}

/// Something rising on the counter.
private struct WarmRising: Identifiable {
    var id: String { name }
    let name: String
    /// 0 when it has just gone in, 1 when it has doubled.
    let rise: Double
    let minutesLeft: Int
    /// The step of a bake this is, and the bake, when it belongs to one.
    var step: String?
    var recipe: WarmRecipe?

    var left: String { "\(warmLength(minutesLeft)) left" }

    static let sample = [
        WarmRising(name: "Country loaf", rise: 0.66, minutesLeft: 38, step: "First rise", recipe: .countryLoaf),
        WarmRising(name: "Rye starter", rise: 0.85, minutesLeft: 25),
        WarmRising(name: "Pizza dough", rise: 0.2, minutesLeft: 190),
    ]
}

/// A length of time in the entry's words, with whole hours left whole.
private func warmLength(_ minutes: Int) -> String {
    minutes >= 60 && minutes % 60 == 0 ? "\(minutes / 60) h" : ProofClock.length(minutes)
}

/// A picture, a row or a button that opens something dims while it is
/// pressed, and shows no chevron.
private struct WarmPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: Counter: everything that is rising

/// The jar that is ready soonest leads, as the kitchen picture. Every other
/// jar is one row that starts with the same jar, small.
private struct WarmCounter: View {
    private enum Phase { case loaded, loading, offline }

    @State private var jars: [WarmRising]
    @State private var phase: Phase
    @State private var isStarting: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _jars = State(initialValue: screen == "empty" ? [] : WarmRising.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isStarting = State(initialValue: screen?.hasPrefix("rise") == true)
    }

    var body: some View {
        Group {
            if jars.isEmpty { empty } else { list }
        }
        .background(WarmLook.ground)
        .navigationTitle("On the counter")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            if !jars.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("New rise", systemImage: "plus") { isStarting = true }
                }
            }
        }
        .sheet(isPresented: $isStarting) {
            WarmRiseSheet(taken: jars.map(\.name), opens: opens) { jar in
                withAnimation { jars.append(jar) }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .offline {
                    WarmNotice(
                        words: isTrying ? "Trying…" : "Couldn’t sync the jars", symbol: "wifi.slash",
                        action: "Try again") {
                        Task { await retry() }
                    }
                    .allowsHitTesting(!isTrying)
                    .padding(.bottom, 8)
                }
                if phase == .loading {
                    WarmGhostLead()
                    VStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { _ in WarmGhostRow() }
                    }
                    .padding(.top, 16)
                } else if let first = jars.first {
                    lead(first)
                    VStack(spacing: 0) {
                        ForEach(jars.dropFirst()) { jar in
                            WarmRow(name: jar.name) {
                                WarmJar(rise: jar.rise)
                            } end: {
                                Text(jar.left)
                            }
                        }
                    }
                    .padding(.top, 16)

                    WarmGroupHead(title: "Recipes")
                        .padding(.top, WarmLook.groupGap)
                    ForEach([WarmRecipe.rye, .focaccia]) { recipe in
                        NavigationLink {
                            WarmRecipeScreen(recipe: recipe, opens: nil)
                        } label: {
                            WarmRow(name: recipe.name) {
                                WarmPicture(form: form(recipe.picture))
                            } end: {
                                Text(recipe.line)
                            }
                        }
                        .buttonStyle(WarmPressStyle())
                    }
                }
            }
            .padding(.horizontal, WarmLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    /// A jar that belongs to a bake opens the bake. A jar on its own opens
    /// nothing, so it is not a button.
    @ViewBuilder private func lead(_ jar: WarmRising) -> some View {
        let face = WarmLead(name: jar.name, line: [jar.step, jar.left].compactMap { $0 }.joined(separator: " · ")) {
            WarmCounterPicture(rise: jar.rise)
        }
        if let recipe = jar.recipe, let step = jar.step {
            NavigationLink {
                WarmRecipeScreen(recipe: recipe, opens: nil, rise: jar.rise, at: recipe.steps.firstIndex { $0.name == step })
            } label: {
                face
            }
            .buttonStyle(WarmPressStyle())
        } else {
            face
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 0) {
            WarmLead(name: "Nothing rising") {
                WarmCounterPicture(rise: nil)
            }
            Spacer(minLength: 8)
            Button("Start a first rise") { isStarting = true }
                .buttonStyle(WarmMainButtonStyle())
                .padding(.bottom, 16)
        }
        .padding(.horizontal, WarmLook.margin)
        .padding(.top, 8)
    }

    private func form(_ picture: String?) -> PictureForm? {
        guard let picture else { return nil }
        switch opens {
        case "counter-waiting": return .waiting
        case "counter-failed": return .failed
        default: return .loaded(.sample(picture))
        }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

// MARK: New rise: the sheet

/// One name and one length. The button's words say where the action stands.
private struct WarmRiseSheet: View {
    let taken: [String]
    let start: (WarmRising) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var length = "2 h"
    @State private var tellsMe = true
    @State private var error: String?
    @State private var isSending: Bool
    private let staysBusy: Bool

    private static let lengths = ["1 h": 60, "2 h": 120, "4 h": 240]

    init(taken: [String], opens screen: String?, start: @escaping (WarmRising) -> Void) {
        self.taken = taken
        self.start = start
        staysBusy = screen == "rise-busy"
        _name = State(initialValue: screen == "rise-error" ? "Rye starter" : screen == "rise-busy" ? "Brioche" : "")
        _error = State(initialValue: screen == "rise-error" ? Self.reason("Rye starter") : nil)
        _isSending = State(initialValue: screen == "rise-busy")
    }

    private static func reason(_ name: String) -> String {
        "A jar is already called \(name). Give this one another name"
    }

    private var trimmed: String { name.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    WarmField(name: "What’s rising", text: $name, error: error)
                    WarmChoices(options: ["1 h", "2 h", "4 h"], selection: $length)
                        .padding(.top, WarmLook.groupGap)
                    Toggle("Tell me when it has doubled", isOn: $tellsMe)
                        .font(WarmLook.row)
                        .foregroundStyle(WarmLook.ink)
                        .tint(WarmLook.accent)
                        .frame(minHeight: WarmLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, WarmLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isSending ? "Starting…" : "Start rise", action: submit)
                    .buttonStyle(WarmMainButtonStyle(isBusy: isSending))
                    .allowsHitTesting(!isSending)
                    .disabled(trimmed.isEmpty)
                    .padding(.horizontal, WarmLook.margin)
                    .padding(.bottom, 8)
            }
            .background(WarmLook.ground)
            .navigationTitle("New rise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: name) { error = nil }
        }
        .tint(WarmLook.accent)
        .presentationBackground(WarmLook.ground)
    }

    private func submit() {
        guard !isSending else { return }
        if let twin = taken.first(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            error = Self.reason(twin)
            return
        }
        isSending = true
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !staysBusy else { return }
            start(WarmRising(name: trimmed, rise: 0, minutesLeft: Self.lengths[length] ?? 120))
            dismiss()
        }
    }
}

// MARK: One recipe, and a bake stepped through

/// A picture leads: the photograph of the bread, or, for a bake that is on
/// the go, the kitchen with its dough. Each step is a row that starts with
/// its pebble.
private struct WarmRecipeScreen: View {
    let recipe: WarmRecipe
    /// The dough's height, when this bake is already on the counter.
    private let rise: Double?
    private let opens: String?
    /// The step that is current; `nil` before the bake has started.
    @State private var current: Int?

    init(recipe: WarmRecipe, opens screen: String?, rise: Double? = nil, at step: Int? = nil) {
        self.recipe = recipe
        self.rise = rise
        opens = screen
        _current = State(initialValue: step)
    }

    private var isOver: Bool { (current ?? 0) >= recipe.steps.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                WarmLead(name: recipe.name, line: recipe.line) {
                    if let rise {
                        WarmCounterPicture(rise: rise)
                    } else {
                        WarmPicture(form: form, place: .lead)
                    }
                }
                VStack(spacing: 0) {
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        WarmRow(name: step.name, isStrong: index == current) {
                            WarmPebble(step: pebble(index))
                        } end: {
                            Text(warmLength(step.minutes))
                        }
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, WarmLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .safeAreaInset(edge: .bottom) {
            Button(isOver ? "Baked" : current == nil ? "Start this bake" : "Next step", action: advance)
                .buttonStyle(WarmMainButtonStyle())
                .disabled(isOver)
                .animation(nil, value: current)
                .padding(.horizontal, WarmLook.margin)
                .padding(.bottom, 8)
        }
        .background(WarmLook.ground)
        // The name is drawn under the picture, in the look's serif.
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
    }

    private var form: PictureForm? {
        guard let picture = recipe.picture else { return nil }
        switch opens {
        case "recipe-waiting": return .waiting
        case "recipe-failed": return .failed
        default: return .loaded(.sample(picture))
        }
    }

    private func pebble(_ index: Int) -> WarmPebble.Step {
        guard let current else { return .toCome }
        return index < current ? .done : index == current ? .current : .toCome
    }

    private func advance() {
        withAnimation(.smooth) { current = current.map { $0 + 1 } ?? 0 }
    }
}

// MARK: Kitchen: people, another company's logo, the app's own mark

private struct WarmKitchen: View {
    @State private var link = Link.none
    private enum Link { case none, linking, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                WarmGroupHead(title: "Bakers")
                WarmRow(name: "Mina") {
                    WarmPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                WarmRow(name: "Jonas") {
                    WarmPersonMark(initial: "J")
                } end: {}
                ShareLink(item: "Bake with me: https://example.com/proof/join/4410") {
                    WarmRow(name: "Invite someone") {
                        WarmPersonMark(initial: nil)
                    } end: {}
                }
                .buttonStyle(WarmPressStyle())

                WarmGroupHead(title: "Ovens")
                    .padding(.top, WarmLook.groupGap)
                WarmRow(name: "Northline") {
                    WarmLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("Linked")
                }
                WarmRow(name: "Tempo") {
                    WarmLogoTile { SampleLogo(company: .tempo) }
                } end: {
                    if link == .linked {
                        Text("Linked")
                    } else {
                        Button(link == .linking ? "Linking…" : "Link") { Task { await connect() } }
                            .buttonStyle(WarmTextButtonStyle())
                            .allowsHitTesting(link == .none)
                    }
                }

                // The app's own mark belongs here and on the first run, not in a bar.
                WarmRow(name: "Proof", detail: "Version 2.1", isStrong: true) {
                    WarmJar(rise: 1)
                } end: {}
                .padding(.top, WarmLook.groupGap)
            }
            .padding(.horizontal, WarmLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(WarmLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Kitchen")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func connect() async {
        link = .linking
        try? await Task.sleep(for: .seconds(2.5))
        link = .linked
    }
}

#Preview {
    WarmPartsScreen()
}
