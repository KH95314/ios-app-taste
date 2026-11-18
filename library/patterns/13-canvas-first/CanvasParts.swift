import SwiftUI

// The parts of look 13 in use, for the entry's invented product: a flyer
// maker for neighbourhood notices. Each screen is built only from the look's
// parts, a page leads it, and nothing on it names a part or a state.
// `parts.md` says which part is which and where it is in code.

struct CanvasPartsScreen: View {
    /// The screen to open: `flyers` (the default), `flyers-waiting`,
    /// `flyers-failed`, `empty`, `loading`, `offline`, `new`, `new-error`,
    /// `new-busy`, `flyer`, `flyer-ordered`, `people`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "flyer", "flyer-ordered": StudioOneFlyer(work: .plantSwap, opens: screen)
            case "people": StudioPeople()
            default: StudioHome(opens: screen)
            }
        }
        // The hue is for what is chosen: what can be pressed in a bar is ink.
        .tint(CanvasLook.ink)
    }
}

// MARK: Sample content

/// One flyer as the screens outside the editor know it: a name, a shape and
/// a picture of the work. `picture` is `nil` when nothing is on it yet.
private struct StudioWork: Identifiable {
    let id = UUID()
    let name: String
    var shape = CanvasLook.pageShape
    let picture: Image?

    init(flyer: Flyer) {
        name = flyer.name
        picture = Self.render(FlyerArtwork(flyer: flyer))
    }

    /// A flyer just made: a page with a title to change, or nothing at all.
    init(name: String, shape: Double, hasTitle: Bool) {
        self.name = name
        self.shape = shape
        picture = hasTitle ? Self.render(StudioTitlePage(shape: shape)) : nil
    }

    private static func render(_ work: some View) -> Image {
        let renderer = ImageRenderer(content: work)
        renderer.scale = 3
        return renderer.uiImage.map(Image.init(uiImage:)) ?? Image(systemName: "photo")
    }

    static let plantSwap = StudioWork(flyer: .sample)
    static let sample = [
        plantSwap,
        StudioWork(flyer: .streetParty),
        StudioWork(flyer: .bikeFixUp),
        StudioWork(flyer: .yardSale),
    ]
}

/// The page a new flyer starts as, drawn the way the editor's first step
/// leaves it. Its colours belong to the work.
private struct StudioTitlePage: View {
    let shape: Double

    var body: some View {
        FlyerPaper.white.color
            .overlay(alignment: .top) {
                Text("TITLE")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(FlyerColor.ink.color)
                    .padding(.top, 42)
            }
            .frame(width: Flyer.size.width, height: Flyer.size.width / shape)
    }
}

/// More of the sample's own artwork, so that the list is not one flyer four times.
private extension Flyer {
    static let streetParty = Flyer(name: "Street party", paper: .night, items: [
        FlyerItem(id: 1, kind: .disc, x: 226, y: 96, size: 124, color: .sun),
        FlyerItem(id: 2, kind: .text, text: "STREET\nPARTY", x: 128, y: 236, size: 52, color: .white),
        FlyerItem(id: 3, kind: .text, text: "Hale Rd, Sat 5 July, 4 till late", x: 120, y: 326, size: 13, color: .white, isHeavy: false),
    ])

    static let bikeFixUp = Flyer(name: "Bike fix-up", paper: .mint, items: [
        FlyerItem(id: 1, kind: .disc, x: 92, y: 262, size: 96, color: .ink),
        FlyerItem(id: 2, kind: .disc, x: 212, y: 262, size: 96, color: .ink),
        FlyerItem(id: 3, kind: .disc, x: 92, y: 262, size: 60, color: .white),
        FlyerItem(id: 4, kind: .disc, x: 212, y: 262, size: 60, color: .white),
        FlyerItem(id: 5, kind: .text, text: "BIKE\nFIX-UP", x: 124, y: 92, size: 54, color: .blue),
        FlyerItem(id: 6, kind: .text, text: "Free, Sundays 2–4", x: 88, y: 340, size: 14, color: .ink),
    ])

    static let yardSale = Flyer(name: "Yard sale", paper: .white, items: [
        FlyerItem(id: 1, kind: .disc, x: 222, y: 246, size: 116, color: .sun),
        FlyerItem(id: 2, kind: .text, text: "YARD\nSALE", x: 112, y: 100, size: 64, color: .coral),
        FlyerItem(id: 3, kind: .text, text: "12 Fern St, Sat 9–2", x: 92, y: 336, size: 14, color: .ink),
    ])
}

// MARK: Flyers: every flyer

/// The newest flyer leads, as a page on the board. Every other flyer is one
/// row that starts with a small page.
private struct StudioHome: View {
    private enum Phase { case loaded, loading, offline }

    @State private var works: [StudioWork]
    @State private var phase: Phase
    @State private var isNaming: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _works = State(initialValue: screen == "empty" ? [] : StudioWork.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isNaming = State(initialValue: screen?.hasPrefix("new") == true)
    }

    var body: some View {
        Group {
            if works.isEmpty { empty } else { list }
        }
        .background(CanvasLook.board)
        .navigationTitle("Flyers")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    StudioPeople()
                } label: {
                    Label("People", systemImage: "person.2")
                }
                Button("New flyer", systemImage: "plus") { isNaming = true }
            }
        }
        .sheet(isPresented: $isNaming) {
            StudioNewSheet(taken: works.map(\.name), opens: opens) { work in
                withAnimation { works.insert(work, at: 0) }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if phase == .loading {
                    StudioLeadWork(name: nil, form: .waiting)
                    VStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in StudioGhostRow() }
                    }
                    .padding(.top, CanvasLook.groupGap)
                } else if let lead = works.first {
                    NavigationLink {
                        StudioOneFlyer(work: lead, opens: nil)
                    } label: {
                        StudioLeadWork(name: lead.name, form: form(lead), shape: lead.shape)
                    }
                    .buttonStyle(StudioPressStyle())
                    VStack(spacing: 0) {
                        ForEach(works.dropFirst()) { work in
                            NavigationLink {
                                StudioOneFlyer(work: work, opens: nil)
                            } label: {
                                StudioPartRow(name: work.name) {
                                    StudioPage(form: form(work), shape: work.shape)
                                } end: {}
                            }
                            .buttonStyle(StudioPressStyle())
                        }
                    }
                    .padding(.top, CanvasLook.groupGap)
                }
            }
            .padding(.horizontal, CanvasLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .safeAreaInset(edge: .top, spacing: 0) {
            if phase == .offline {
                CanvasNotice(
                    title: isTrying ? "Trying…" : "Can’t reach iCloud",
                    message: "These are the copies on this iPhone.") {
                    Task { await retry() }
                }
            }
        }
    }

    private var empty: some View {
        VStack(spacing: 0) {
            StudioEmptyPage()
            Text("No flyers yet")
                .font(CanvasLook.emptyTitle)
                .foregroundStyle(CanvasLook.ink)
                .padding(.top, 28)
            Button("New flyer") { isNaming = true }
                .buttonStyle(StudioMainButtonStyle())
                .frame(maxWidth: 240)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }

    private func form(_ work: StudioWork) -> PictureForm? {
        guard let picture = work.picture else { return nil }
        switch opens {
        case "flyers-waiting": return .waiting
        case "flyers-failed": return .failed
        default: return .loaded(picture)
        }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

/// A page or a row that opens something dims while it is pressed, and shows
/// no chevron: every one of them opens.
private struct StudioPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: A new flyer

/// The sheet is chrome, like the tools: nothing on it is the work. The
/// button's words say where the action stands.
private struct StudioNewSheet: View {
    let taken: [String]
    let create: (StudioWork) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var shape = "Portrait"
    @State private var hasTitle = true
    @State private var error: String?
    @State private var isCreating: Bool
    private let staysBusy: Bool

    init(taken: [String], opens screen: String?, create: @escaping (StudioWork) -> Void) {
        self.taken = taken
        self.create = create
        staysBusy = screen == "new-busy"
        _text = State(initialValue: screen == "new-error" ? "Plant swap flyer" : screen == "new-busy" ? "Book swap" : "")
        _error = State(initialValue: screen == "new-error" ? Self.takenReason : nil)
        _isCreating = State(initialValue: screen == "new-busy")
    }

    private static let takenReason = "You already have a flyer with this name"
    private static let shapes = ["Portrait": 0.8, "Square": 1.0, "Wide": 1.25]

    private var name: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    StudioField(name: "Name", text: $text, error: error, onSubmit: submit)
                    StudioChoice(options: ["Portrait", "Square", "Wide"], selection: $shape)
                        .padding(.top, CanvasLook.groupGap)
                    Toggle("Start with a title", isOn: $hasTitle)
                        .font(CanvasLook.name)
                        .foregroundStyle(CanvasLook.ink)
                        .tint(CanvasLook.active)
                        .frame(minHeight: CanvasLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, CanvasLook.margin)
                .padding(.top, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollEdgeEffectStyle(.hard, for: .top)
            .safeAreaInset(edge: .bottom) {
                Button(isCreating ? "Creating…" : "Create flyer", action: submit)
                    .buttonStyle(StudioMainButtonStyle(isBusy: isCreating))
                    .allowsHitTesting(!isCreating)
                    .disabled(name.isEmpty)
                    .padding(.horizontal, CanvasLook.margin)
                    .padding(.bottom, 8)
            }
            .background(CanvasLook.chrome)
            .navigationTitle("New flyer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: text) { error = nil }
        }
        .tint(CanvasLook.ink)
        .presentationBackground(CanvasLook.chrome)
    }

    private func submit() {
        guard !isCreating, !name.isEmpty else { return }
        guard !taken.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) else {
            error = Self.takenReason
            return
        }
        isCreating = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            create(StudioWork(name: name, shape: Self.shapes[shape] ?? CanvasLook.pageShape, hasTitle: hasTitle))
            dismiss()
        }
    }
}

// MARK: One flyer, and its prints

/// The work on the board and, as in the editor, everything else in a quiet
/// dock under it. The dock keeps its height through the order, so the page
/// never moves.
private struct StudioOneFlyer: View {
    let work: StudioWork

    private enum Order { case none, sending, placed }
    @State private var copies = "25 copies"
    @State private var order: Order

    init(work: StudioWork, opens screen: String?) {
        self.work = work
        _order = State(initialValue: screen == "flyer-ordered" ? .placed : .none)
    }

    private static let prices = ["10 copies": "£4.50", "25 copies": "£8.75", "50 copies": "£15.00"]

    var body: some View {
        StudioPage(form: work.picture.map { .loaded($0) }, shape: work.shape, isLead: true)
            .padding(CanvasLook.margin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CanvasLook.board)
            .safeAreaInset(edge: .bottom, spacing: 0) { dock }
            .navigationTitle(work.name)
            .navigationBarTitleDisplayMode(.inline)
    }

    private var dock: some View {
        VStack(spacing: 10) {
            StudioPartRow(
                name: order == .placed ? "Ready Thursday" : "Northline Print",
                detail: order == .placed ? "Northline Print" : nil) {
                StudioLogoTile { SampleLogo(company: .northline) }
            } end: {
                Text(Self.prices[copies] ?? "")
                    .font(CanvasLook.figure)
                    .monospacedDigit()
                    .foregroundStyle(CanvasLook.ink)
            }
            // Words change at once: a fade would lay the old over the new.
            .animation(nil, value: order)
            StudioChoice(options: ["10 copies", "25 copies", "50 copies"], selection: $copies)
                .disabled(order != .none)
            // The action turns into its way back, in the same place.
            if order == .placed {
                Button("Cancel order") { order = .none }
                    .buttonStyle(StudioTextButtonStyle())
                    .frame(minHeight: CanvasLook.buttonMin)
            } else {
                Button(order == .sending ? "Sending…" : "Order prints") { Task { await send() } }
                    .buttonStyle(StudioMainButtonStyle(isBusy: order == .sending))
                    .allowsHitTesting(order == .none)
            }
        }
        .padding(.horizontal, CanvasLook.margin)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(CanvasLook.chrome)
        .overlay(alignment: .top) {
            Rectangle().fill(CanvasLook.rule).frame(height: 1)
        }
    }

    private func send() async {
        order = .sending
        try? await Task.sleep(for: .seconds(2.5))
        order = .placed
    }
}

// MARK: People: people, another company's logo, the app's own mark

private struct StudioPeople: View {
    @State private var link = Link.none
    private enum Link { case none, linking, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                StudioPartRow(name: "Mina") {
                    StudioPersonMark(photo: SampleFace(person: .mina))
                } end: {}
                StudioPartRow(name: "Jonas") {
                    StudioPersonMark(initial: "J")
                } end: {}
                ShareLink(item: "Make flyers with me: https://example.com/flyers/join/4410") {
                    StudioPartRow(name: "Invite someone") {
                        StudioPersonMark(initial: nil)
                    } end: {}
                }
                .buttonStyle(StudioPressStyle())

                StudioPartRow(name: "Northline Print") {
                    StudioLogoTile { SampleLogo(company: .northline) }
                } end: {
                    Text("Linked").foregroundStyle(CanvasLook.ink2)
                }
                .padding(.top, CanvasLook.groupGap)
                StudioPartRow(name: "Tempo Copy") {
                    StudioLogoTile { SampleLogo(company: .tempo) }
                } end: {
                    if link == .linked {
                        Text("Linked").foregroundStyle(CanvasLook.ink2)
                    } else {
                        Button(link == .linking ? "Linking…" : "Link") { Task { await connect() } }
                            .buttonStyle(StudioTextButtonStyle())
                            .allowsHitTesting(link == .none)
                    }
                }

                // The app's own mark belongs here and on the first run, not in a bar.
                StudioPartRow(name: "Noticeboard", detail: "Version 2.1") {
                    Image(systemName: "pin.fill")
                        .font(.headline)
                        .foregroundStyle(CanvasLook.chrome)
                        .frame(width: CanvasLook.rowLead, height: CanvasLook.rowLead)
                        .background(CanvasLook.ink, in: .rect(cornerRadius: CanvasLook.chipRadius))
                } end: {}
                .padding(.top, CanvasLook.groupGap)
            }
            .padding(.horizontal, CanvasLook.margin)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(CanvasLook.board)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("People")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func connect() async {
        link = .linking
        try? await Task.sleep(for: .seconds(1.2))
        link = .linked
    }
}

#Preview {
    CanvasPartsScreen()
}
