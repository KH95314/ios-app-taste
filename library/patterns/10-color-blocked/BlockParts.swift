import SwiftUI

// The parts of look 10 in use, for an invented product: the shifts of a dog
// shelter. Each screen is built only from the look's parts, the blocks are
// the only colour on it, and nothing on it names a part or a state.
// `parts.md` says which part is which and where it is in code.

struct BlockPartsScreen: View {
    /// The screen to open: `week` (the default), `empty`, `loading`,
    /// `offline`, `new`, `new-error`, `new-busy`, `dogs`, `dogs-waiting`,
    /// `dogs-failed`, `team`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "dogs", "dogs-waiting", "dogs-failed": BlockDogs(opens: screen)
            case "team": BlockTeam()
            default: BlockWeek(opens: screen)
            }
        }
        // Every control is ink, so a control is never taken for a category.
        .tint(BlockLook.ink)
    }
}

private func hours(_ minutes: Int) -> String {
    minutes % 60 == 0 ? "\(minutes / 60) h" : "\(minutes / 60) h \(minutes % 60)"
}

// MARK: This week: the categories as blocks

/// Each category is one block, and a block's height is its share of the
/// week. The largest is first, so the stack is its own chart.
private struct BlockWeek: View {
    private enum Phase { case loaded, loading, offline }

    @State private var minutes: [ShiftKind: Int]
    @State private var phase: Phase
    @State private var isAdding: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _minutes = State(initialValue: screen == "empty" ? [:] : [.walk: 330, .feed: 180, .clean: 150, .care: 90])
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isAdding = State(initialValue: screen?.hasPrefix("new") == true)
    }

    private var ordered: [(kind: ShiftKind, minutes: Int)] {
        minutes.map { (kind: $0.key, minutes: $0.value) }.sorted { $0.minutes > $1.minutes }
    }

    var body: some View {
        Group {
            if minutes.isEmpty { empty } else { stack }
        }
        .background(BlockLook.ground)
        .navigationTitle("This week")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            // One way to add in each state: this button while blocks show,
            // the button inside the empty state when none does.
            if !minutes.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add a shift", systemImage: "plus") { isAdding = true }
                }
            }
        }
        .sheet(isPresented: $isAdding) {
            BlockNewShift(opens: opens) { kind, length in
                withAnimation { minutes[kind, default: 0] += length }
            }
        }
    }

    private var stack: some View {
        ScrollView {
            VStack(spacing: BlockLook.gap) {
                if phase == .offline {
                    BlockNotice(
                        title: isTrying ? "Trying…" : "You’re offline",
                        message: "This is the week as last saved. Changes are kept on this iPhone.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, 12)
                }
                if phase == .loading {
                    BlockGhostStack(heights: [150, 82, 68, 64])
                } else {
                    let most = Double(ordered.first?.minutes ?? 1)
                    ForEach(ordered, id: \.kind) { entry in
                        BlockTile(kind: entry.kind, figure: hours(entry.minutes), height: max(64, Double(entry.minutes) / most * 150))
                    }
                }
            }
            .padding(.horizontal, BlockLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    private var empty: some View {
        VStack(spacing: 0) {
            BlockGhostStack()
                .frame(width: 200)
            Text("No shifts this week")
                .font(BlockLook.emptyTitle)
                .foregroundStyle(BlockLook.ink)
                .padding(.top, 20)
            Button("Add a shift") { isAdding = true }
                .buttonStyle(BlockMainButtonStyle())
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

// MARK: New shift: a sheet

/// The name leads. The category is chosen from the blocks themselves, and
/// the button is off until there is a name.
private struct BlockNewShift: View {
    let add: (ShiftKind, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var kind = ShiftKind.walk
    @State private var length = "30 min"
    @State private var everyDay = false
    @State private var error: String?
    @State private var isAdding: Bool
    private let staysBusy: Bool

    init(opens screen: String?, add: @escaping (ShiftKind, Int) -> Void) {
        self.add = add
        staysBusy = screen == "new-busy"
        _name = State(initialValue: screen == "new-error" ? "Walk Otis" : screen == "new-busy" ? "Bath for Pru" : "")
        _error = State(initialValue: screen == "new-error" ? Self.takenReason : nil)
        _isAdding = State(initialValue: screen == "new-busy")
    }

    private static let takenReason = "Walk Otis is already on Saturday at 12:00"
    private var trimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BlockField(name: "Shift", text: $name, prompt: "What is it?", error: error, onSubmit: submit)
                    BlockKindChoice(kinds: [.walk, .feed, .clean, .care], selection: $kind)
                        .padding(.top, 20)
                    BlockSegments(options: ["15 min", "30 min", "45 min", "1 h"], selection: $length)
                        .padding(.top, 20)
                    Toggle("Every day", isOn: $everyDay)
                        .font(BlockLook.row)
                        .foregroundStyle(BlockLook.ink)
                        .frame(minHeight: BlockLook.rowMin)
                        .padding(.top, 8)
                }
                .padding(.horizontal, BlockLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isAdding ? "Adding…" : "Add shift", action: submit)
                    .buttonStyle(BlockMainButtonStyle(isBusy: isAdding, isWide: true))
                    .disabled(trimmed.isEmpty)
                    .allowsHitTesting(!isAdding)
                    .padding(.horizontal, BlockLook.margin)
                    .padding(.bottom, 8)
            }
            .background(BlockLook.ground)
            .navigationTitle("New shift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: name) { error = nil }
        }
        .tint(BlockLook.ink)
        .presentationBackground(BlockLook.ground)
    }

    private func submit() {
        guard !trimmed.isEmpty, !isAdding else { return }
        guard trimmed.lowercased() != "walk otis" else {
            error = Self.takenReason
            return
        }
        isAdding = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            add(kind, length == "1 h" ? 60 : Int(length.prefix(2)) ?? 30)
            dismiss()
        }
    }
}

// MARK: Dogs: a picture at the start of a row, a small block at its end

/// A picture has four forms, and a row shows whichever it is in with no word
/// about it. The small block at the end is the dog's next shift.
private struct BlockDogs: View {
    let opens: String?

    private static let dogs: [(name: String, coat: UInt32?, kind: ShiftKind, next: String)] = [
        ("Biscuit", 0xC98A4B, .walk, "8:00"),
        ("Pru", 0x4A3B32, .walk, "8:00"),
        ("Otis", 0xE4D3B8, .feed, "11:30"),
        ("Juniper", nil, .care, "10:15"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Self.dogs, id: \.name) { dog in
                    BlockListRow(name: dog.name) {
                        if let coat = dog.coat {
                            BlockPicture(form: form(coat))
                        } else {
                            BlockGlyphTile(symbol: "pawprint.fill")
                        }
                    } end: {
                        BlockChip(kind: dog.kind, text: dog.next)
                    }
                }
            }
            .padding(.horizontal, BlockLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(BlockLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Dogs")
        .toolbarTitleDisplayMode(.inlineLarge)
    }

    private func form(_ coat: UInt32) -> PictureForm {
        switch opens {
        case "dogs-waiting": .waiting
        case "dogs-failed": .failed
        default: .loaded(SampleDog.picture(coat: coat))
        }
    }
}

/// A drawing of a dog, standing in for a photograph. Its colours are its own.
/// A real product shows its own pictures here.
private struct SampleDog: View {
    let coat: UInt32

    static func picture(coat: UInt32) -> Image {
        let renderer = ImageRenderer(content: SampleDog(coat: coat).frame(width: 80, height: 80))
        renderer.scale = 3
        return renderer.uiImage.map(Image.init(uiImage:)) ?? Image(systemName: "photo")
    }

    var body: some View {
        Canvas { context, size in
            let unit = size.width / 40
            func oval(_ x: Double, _ y: Double, _ width: Double, _ height: Double, _ hex: UInt32) {
                context.fill(
                    Path(ellipseIn: CGRect(x: x * unit, y: y * unit, width: width * unit, height: height * unit)),
                    with: .color(Color(fixed: hex)))
            }
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(fixed: 0xDCE6DF)))
            oval(5, 10, 10, 20, coat)
            oval(25, 10, 10, 20, coat)
            oval(9, 9, 22, 24, coat)
            oval(13, 22, 14, 11, 0xF3EBDD)
            oval(17.5, 23, 5, 3.6, 0x2A2320)
            oval(13.5, 16, 2.6, 2.6, 0x2A2320)
            oval(23.9, 16, 2.6, 2.6, 0x2A2320)
            oval(6, 33, 28, 14, coat)
        }
    }
}

// MARK: Team: people, another company's logo, the app's own mark

private struct BlockTeam: View {
    @State private var tookIt = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BlockGroupHead(title: "Saturday")
                BlockListRow(name: "Mina") {
                    BlockPersonMark(photo: SampleFace(person: .mina))
                } end: {
                    BlockChip(kind: .walk, text: "8:00")
                }
                BlockListRow(name: "Tomas") {
                    BlockPersonMark(initial: "T")
                } end: {
                    BlockChip(kind: .clean, text: "9:00")
                }
                BlockListRow(name: tookIt ? "You" : "Nobody yet", isQuiet: !tookIt) {
                    BlockPersonMark(initial: tookIt ? "Y" : nil)
                } end: {
                    if !tookIt {
                        Button("Take it") { withAnimation { tookIt = true } }
                            .buttonStyle(BlockTextButtonStyle())
                    }
                    BlockChip(kind: .feed, text: "11:30")
                }

                BlockGroupHead(title: "Vet")
                    .padding(.top, BlockLook.groupGap)
                BlockListRow(name: "Northline Animal Clinic") {
                    BlockLogoTile { SampleLogo(company: .northline) }
                } end: {
                    BlockChip(kind: .care, text: "10:15")
                }

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    Image(systemName: "pawprint.fill")
                        .font(.headline)
                        .foregroundStyle(BlockLook.ground)
                        .frame(width: BlockLook.rowLead, height: BlockLook.rowLead)
                        .background(BlockLook.ink, in: .rect(cornerRadius: BlockLook.leadRadius))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Kennel")
                            .font(BlockLook.rowStrong)
                            .foregroundStyle(BlockLook.ink)
                        Text("Version 1.8")
                            .font(BlockLook.detail)
                            .foregroundStyle(BlockLook.ink2)
                    }
                }
                .padding(.top, BlockLook.groupGap)
            }
            .padding(.horizontal, BlockLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(BlockLook.ground)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Team")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

#Preview {
    BlockPartsScreen()
}
