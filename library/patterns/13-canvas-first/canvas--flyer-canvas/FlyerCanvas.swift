import PhotosUI
import SwiftUI
import UIKit

// Pattern: a canvas with the tools beneath it
// Direction 13 Canvas-First Creation · kind: canvas · look: CanvasLook.swift
// Sample product (invented): a flyer maker for neighbourhood notices.
//
// The flyer is the sample's own artwork, drawn in code. Its colours belong to
// the work and are not part of the look.

enum FlyerColor: String, CaseIterable, Identifiable {
    case green = "Leaf green", coral = "Coral", ink = "Ink", blue = "Harbour blue", sun = "Sun yellow", white = "White"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .green: Color(fixed: 0x1F6B45)
        case .coral: Color(fixed: 0xE4572E)
        case .ink: Color(fixed: 0x1D1B16)
        case .blue: Color(fixed: 0x2E5E8C)
        case .sun: Color(fixed: 0xF2B441)
        case .white: Color(fixed: 0xFFFFFF)
        }
    }
}

enum FlyerFace: String, CaseIterable, Identifiable {
    case grotesk = "Grotesk", rounded = "Rounded", serif = "Serif", mono = "Mono"

    var id: String { rawValue }

    var design: Font.Design {
        switch self {
        case .grotesk: .default
        case .rounded: .rounded
        case .serif: .serif
        case .mono: .monospaced
        }
    }
}

enum FlyerPaper: String, CaseIterable, Identifiable {
    case cream = "Cream", white = "White", mint = "Mint", night = "Night"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .cream: Color(fixed: 0xFFF4DC)
        case .white: Color(fixed: 0xFFFFFF)
        case .mint: Color(fixed: 0xE3F1E4)
        case .night: Color(fixed: 0x14213D)
        }
    }
}

struct FlyerItem: Identifiable, Equatable {
    enum Kind: Equatable { case text, disc, sprig, photo }

    let id: Int
    var kind: Kind
    var text = ""
    /// The centre, in page points. The page is 300 by 375.
    var x: Double
    var y: Double
    /// Text: the point size. Anything else: its width.
    var size: Double
    var color = FlyerColor.green
    var face = FlyerFace.grotesk
    var alignment = TextAlignment.leading
    var isHeavy = true
    var photo: UIImage?

    var name: String {
        switch kind {
        case .text: text.replacing("\n", with: " ")
        case .disc: "Circle"
        case .sprig: "Sprig"
        case .photo: "Photo"
        }
    }

    var symbol: String {
        switch kind {
        case .text: "textformat"
        case .disc: "circle.fill"
        case .sprig: "leaf.fill"
        case .photo: "photo"
        }
    }
}

struct Flyer: Equatable {
    static let size = CGSize(width: 300, height: 375)

    var name: String
    var paper = FlyerPaper.cream
    /// Back to front.
    var items: [FlyerItem]
}

struct FlyerCanvasScreen: View {
    @State private var phase: Phase<Flyer>
    @State private var selection: Int?
    @State private var past: [Flyer]
    @State private var future: [Flyer] = []
    /// How large each thing is drawn, so the selection can wrap it.
    @State private var sizes: [Int: CGSize] = [:]
    /// The move and the resize in progress. They are applied to the work
    /// only when the finger lifts, so one drag is one step of undo.
    @State private var drag = CGSize.zero
    @State private var resize = 1.0
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var showsLayers = false
    @State private var isEditingText = false
    @State private var snapshot: Image?
    @State private var nameHeight = 0.0
    @Environment(\.dismiss) private var dismiss

    init(phase: Phase<Flyer>, selection: Int? = nil, history: [Flyer] = []) {
        _phase = State(initialValue: phase)
        _selection = State(initialValue: selection)
        _past = State(initialValue: history)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CanvasLook.board)
                // The name is set, for the system and for assistive
                // technology, and not drawn in the bar: beside undo, redo and
                // Export a small phone has no room for it. It is drawn over
                // the page instead.
                .navigationTitle(flyer?.name ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .title)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                    if let flyer {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button("Undo", systemImage: "arrow.uturn.backward", action: undo)
                                .disabled(past.isEmpty)
                            Button("Redo", systemImage: "arrow.uturn.forward", action: redo)
                                .disabled(future.isEmpty)
                        }
                        if let snapshot, !flyer.items.isEmpty {
                            ToolbarSpacer(.fixed, placement: .topBarTrailing)
                            ToolbarItem(placement: .topBarTrailing) {
                                // The one worded action in the bar.
                                ShareLink(item: snapshot, preview: SharePreview(flyer.name, image: snapshot)) {
                                    Text("Export")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showsLayers) {
                    LayersSheet(items: flyer?.items ?? [], selection: selection) { selection = $0 }
                }
                .sheet(isPresented: $isEditingText) {
                    if let item = selected {
                        EditTextSheet(text: item.text) { text in
                            edit(item.id) { $0.text = text }
                        }
                    }
                }
                // Sample only: the page is drawn again after every change so
                // that Export always has the current picture. Fine for one
                // page; a larger work would render when asked.
                .onChange(of: flyer, initial: true) { _, flyer in
                    snapshot = flyer.flatMap(Self.render)
                }
                .onChange(of: pickedPhoto) { _, item in
                    Task { await addPhoto(item) }
                }
                .sensoryFeedback(.selection, trigger: selection)
        }
        .tint(CanvasLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            ZStack {
                Rectangle()
                    .fill(CanvasLook.chrome)
                    .aspectRatio(Flyer.size.width / Flyer.size.height, contentMode: .fit)
                    .padding(24)
                // Without this a page that is still opening looks the same
                // as a new, empty one.
                ProgressView()
                    .controlSize(.large)
                    .tint(CanvasLook.ink2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                dock(.blank)
                    .disabled(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Opening the flyer")
        case .empty:
            editor(.blank, notice: nil)
        case .loaded(let flyer):
            editor(flyer, notice: nil)
        case .failed(let message, let stale?):
            editor(stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                VStack(spacing: 12) {
                    Image(systemName: "icloud.slash")
                        .font(.largeTitle)
                        .foregroundStyle(CanvasLook.ink2)
                        .accessibilityHidden(true)
                    Text("Couldn't open the flyer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(CanvasLook.ink)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(CanvasLook.ink2)
                    Button("Try again", action: retry)
                        .buttonStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .underline()
                        .foregroundStyle(CanvasLook.ink)
                        .frame(minHeight: 44)
                }
                .multilineTextAlignment(.center)
                .padding(32)
            }
        }
    }

    // MARK: The board

    private func editor(_ flyer: Flyer, notice: String?) -> some View {
        GeometryReader { proxy in
            // The work is as large as the board allows, with room around it
            // so the handles of a thing at the edge can still be reached.
            let scale = max(0.2, min(
                (proxy.size.width - 48) / Flyer.size.width,
                (proxy.size.height - 48 - nameHeight - 6) / Flyer.size.height))
            ZStack {
                // A tap on the board lets go of the selection.
                CanvasLook.board
                    .contentShape(.rect)
                    .onTapGesture { selection = nil }
                VStack(alignment: .leading, spacing: 6) {
                    // The name of the work, over the page's top corner the
                    // way an artboard is labelled. It can run to two lines
                    // and is never cut by the bar's buttons.
                    Text(flyer.name)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(CanvasLook.ink2)
                        .lineLimit(2)
                        .frame(width: Flyer.size.width * scale, alignment: .leading)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .onGeometryChange(for: Double.self) { $0.size.height } action: { nameHeight = $0 }
                        .accessibilityAddTraits(.isHeader)
                page(flyer, scale: scale)
                    .scaleEffect(scale)
                    .frame(width: Flyer.size.width * scale, height: Flyer.size.height * scale)
                    .overlay(alignment: .top) {
                        if flyer.items.isEmpty {
                            // An empty page offers the first step, where the
                            // first thing would go. The page is white in both
                            // appearances, so this colour is fixed too.
                            Button { addText(asTitle: true) } label: {
                                Label("Add a title", systemImage: "textformat")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 20)
                                    .frame(minHeight: 44)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                                    }
                                    .foregroundStyle(Color(fixed: 0x5E6269))
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 40)
                        }
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let notice {
                // Editing carries on under the notice.
                CanvasNotice(title: "Not saved to iCloud", message: notice, retry: retry)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            dock(flyer)
        }
    }

    private func page(_ flyer: Flyer, scale: Double) -> some View {
        let shown = displayed(flyer)
        return FlyerArtwork(flyer: shown, select: { selection = $0 }, measure: { sizes[$0] = $1 })
            .shadow(color: .black.opacity(0.14), radius: 12 / scale, y: 6 / scale)
            .overlay {
                if let item = shown.items.first(where: { $0.id == selection }), let size = sizes[item.id] {
                    selectionOverlay(for: item, size: size, scale: scale)
                }
            }
            .coordinateSpace(.named("page"))
    }

    /// The outline, which moves the thing when dragged, and a handle at each
    /// corner, which resizes it.
    private func selectionOverlay(for item: FlyerItem, size: CGSize, scale: Double) -> some View {
        let width = size.width + 14, height = size.height + 14
        return ZStack {
            CanvasSelectionFrame(scale: scale)
                .contentShape(.rect)
                .gesture(DragGesture(minimumDistance: 2)
                    .onChanged { drag = $0.translation }
                    .onEnded { value in
                        drag = .zero
                        edit(item.id) {
                            $0.x += value.translation.width
                            $0.y += value.translation.height
                        }
                    })
            ForEach(0..<4, id: \.self) { corner in
                CanvasHandle(scale: scale)
                    .position(x: corner % 2 == 0 ? 0 : width, y: corner < 2 ? 0 : height)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("page"))
                        .onChanged { resize = factor(for: $0) }
                        .onEnded { value in
                            let factor = factor(for: value)
                            resize = 1
                            edit(item.id) { $0.size = ($0.size * factor).rounded() }
                        })
                    .accessibilityHidden(true)
            }
        }
        .frame(width: width, height: height)
        .position(x: item.x, y: item.y)
    }

    /// How far the finger is from the thing's centre now, against where it
    /// started. The centre is the committed one, so it holds still.
    private func factor(for value: DragGesture.Value) -> Double {
        guard let item = selected else { return 1 }
        let start = hypot(value.startLocation.x - item.x, value.startLocation.y - item.y)
        let now = hypot(value.location.x - item.x, value.location.y - item.y)
        return start > 1 ? min(max(now / start, 0.3), 4) : 1
    }

    /// The work with the move or resize in progress applied to it.
    private func displayed(_ flyer: Flyer) -> Flyer {
        guard let index = flyer.items.firstIndex(where: { $0.id == selection }) else { return flyer }
        var flyer = flyer
        flyer.items[index].x += drag.width
        flyer.items[index].y += drag.height
        flyer.items[index].size *= resize
        return flyer
    }

    // MARK: The dock

    private func dock(_ flyer: Flyer) -> some View {
        let item = flyer.items.first { $0.id == selection }
        // Which tool made the selected thing. Worked out here, because the
        // photo picker's label is built off the main actor.
        let usesText = item?.kind == .text
        let usesShape = item?.kind == .disc || item?.kind == .sprig
        let usesPhoto = item?.kind == .photo
        return VStack(spacing: 0) {
            // The controls for the selected thing, above the tools. Their
            // room is kept while nothing is selected, and only their
            // drawing comes and goes. When the strip took its room on
            // selection, the whole page moved up under the finger that had
            // just touched it.
            if let shown = item ?? flyer.items.first {
                // They scroll sideways only when the text is too large for
                // them to fit.
                ViewThatFits(in: .horizontal) {
                    strip(for: shown)
                    ScrollView(.horizontal) { strip(for: shown) }
                        .scrollIndicators(.hidden)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
                // Only the fade is animated. The values change at once, so
                // the stand-in's figures never show through.
                .transaction { $0.animation = nil }
                .frame(maxWidth: .infinity)
                .background(CanvasLook.chrome)
                .overlay(alignment: .top) {
                    Rectangle().fill(CanvasLook.rule).frame(height: 1)
                }
                .opacity(item == nil ? 0 : 1)
                .allowsHitTesting(item != nil)
                .accessibilityHidden(item == nil)
                .animation(.easeOut(duration: 0.15), value: item == nil)
            } else {
                // An empty flyer has nothing to measure the strip from.
                Color.clear.frame(height: 48)
            }
            Rectangle()
                .fill(CanvasLook.rule)
                .frame(height: 1)
            HStack(spacing: 0) {
                Button { addText(asTitle: false) } label: {
                    CanvasToolFace(title: "Text", systemImage: "textformat", isOn: usesText)
                }
                Button(action: addShape) {
                    CanvasToolFace(title: "Shape", systemImage: "circle.square", isOn: usesShape)
                }
                PhotosPicker(selection: $pickedPhoto, matching: .images) {
                    CanvasToolFace(title: "Photo", systemImage: "photo", isOn: usesPhoto)
                }
                Menu {
                    Picker("Paper", selection: paperBinding) {
                        ForEach(FlyerPaper.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    // "Paper", not "Background": five cells across a small
                    // phone leave room for about six letters.
                    CanvasToolFace(title: "Paper", systemImage: "drop")
                }
                Button { showsLayers = true } label: {
                    CanvasToolFace(title: "Layers", systemImage: "square.3.layers.3d")
                }
                .disabled(flyer.items.isEmpty)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(CanvasLook.chrome)
        }
        // The dock is a bar. It stops growing at the first accessibility
        // size so that the work keeps the screen; held down, a tool shows
        // the system's large-content preview.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    /// Values are written as figures: the face by name, the size in points.
    private func strip(for item: FlyerItem) -> some View {
        // Text steps by two points; a shape or a photo by ten.
        let isText = item.kind == .text
        let step = isText ? 2.0 : 10.0
        return HStack(spacing: 8) {
            if isText {
                Menu {
                    Picker("Typeface", selection: faceBinding(for: item)) {
                        ForEach(FlyerFace.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Text(item.face.rawValue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .canvasChip()
                }
                .accessibilityLabel("Typeface")
                .accessibilityValue(item.face.rawValue)
            }
            SizeStepper(
                value: "\(Int(item.size))\(isText ? " pt" : "")",
                smaller: { edit(item.id) { $0.size = max(8, $0.size - step) } },
                larger: { edit(item.id) { $0.size = min(240, $0.size + step) } })
            if item.kind != .photo {
                Menu {
                    Picker("Colour", selection: colorBinding(for: item)) {
                        ForEach(FlyerColor.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Circle()
                        .fill(item.color.color)
                        .frame(width: 18, height: 18)
                        // A ring, so a pale colour still shows on the chip.
                        .overlay { Circle().strokeBorder(CanvasLook.ink2, lineWidth: 1).padding(-3) }
                        .canvasChip()
                }
                .accessibilityLabel("Colour")
                .accessibilityValue(item.color.rawValue)
            }
            Menu {
                if isText {
                    Button("Edit text", systemImage: "pencil") { isEditingText = true }
                    Picker("Alignment", selection: alignmentBinding(for: item)) {
                        Label("Left", systemImage: "text.alignleft").tag(TextAlignment.leading)
                        Label("Centre", systemImage: "text.aligncenter").tag(TextAlignment.center)
                        Label("Right", systemImage: "text.alignright").tag(TextAlignment.trailing)
                    }
                    Toggle("Heavy", systemImage: "bold", isOn: heavyBinding(for: item))
                }
                Button("Duplicate", systemImage: "plus.square.on.square") { duplicate(item) }
                Button("Bring to front", systemImage: "square.3.layers.3d.top.filled") { bringToFront(item) }
                Button("Delete", systemImage: "trash", role: .destructive) { delete(item) }
            } label: {
                Image(systemName: "ellipsis")
                    .canvasChip()
            }
            .accessibilityLabel("More for \(item.name)")
        }
    }

    // MARK: State

    private var flyer: Flyer? {
        switch phase {
        case .loaded(let flyer), .failed(_, let flyer?): flyer
        case .empty: .blank
        default: nil
        }
    }

    private var selected: FlyerItem? {
        flyer?.items.first { $0.id == selection }
    }

    private func store(_ flyer: Flyer) {
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: flyer)
        } else {
            phase = .loaded(flyer)
        }
    }

    /// Every change goes through here, so every change can be undone.
    private func commit(_ change: (inout Flyer) -> Void) {
        guard var flyer else { return }
        let before = flyer
        change(&flyer)
        guard flyer != before else { return }
        past.append(before)
        future = []
        store(flyer)
    }

    private func edit(_ id: Int, _ change: (inout FlyerItem) -> Void) {
        commit { flyer in
            guard let index = flyer.items.firstIndex(where: { $0.id == id }) else { return }
            change(&flyer.items[index])
        }
    }

    private func undo() {
        guard let flyer, let previous = past.popLast() else { return }
        future.append(flyer)
        store(previous)
        if !previous.items.contains(where: { $0.id == selection }) { selection = nil }
    }

    private func redo() {
        guard let flyer, let next = future.popLast() else { return }
        past.append(flyer)
        store(next)
    }

    private func nextID(in flyer: Flyer) -> Int {
        (flyer.items.map(\.id).max() ?? 0) + 1
    }

    /// The new thing is on the page and selected. That is the confirmation.
    private func add(_ make: (Int, Flyer) -> FlyerItem) {
        commit { flyer in
            let item = make(nextID(in: flyer), flyer)
            flyer.items.append(item)
            selection = item.id
        }
    }

    private func addText(asTitle: Bool) {
        // Ink on a light page, white on the dark one.
        let isDark = flyer?.paper == .night
        add { id, _ in
            FlyerItem(
                id: id, kind: .text, text: asTitle ? "TITLE" : "New text",
                x: Flyer.size.width / 2, y: asTitle ? 70 : Flyer.size.height / 2,
                size: asTitle ? 48 : 20,
                color: isDark ? .white : .ink,
                alignment: .center, isHeavy: asTitle)
        }
    }

    private func addShape() {
        add { id, _ in
            FlyerItem(id: id, kind: .disc, x: Flyer.size.width / 2, y: Flyer.size.height / 2, size: 60, color: .sun)
        }
    }

    private func addPhoto(_ picked: PhotosPickerItem?) async {
        guard let picked, let data = try? await picked.loadTransferable(type: Data.self), let image = UIImage(data: data) else { return }
        add { id, _ in
            FlyerItem(id: id, kind: .photo, x: Flyer.size.width / 2, y: Flyer.size.height / 2, size: 160, photo: image)
        }
        pickedPhoto = nil
    }

    private func duplicate(_ item: FlyerItem) {
        add { id, _ in
            var copy = FlyerItem(id: id, kind: item.kind, text: item.text, x: item.x + 12, y: item.y + 12, size: item.size)
            copy.color = item.color
            copy.face = item.face
            copy.alignment = item.alignment
            copy.isHeavy = item.isHeavy
            copy.photo = item.photo
            return copy
        }
    }

    private func bringToFront(_ item: FlyerItem) {
        commit { flyer in
            flyer.items.removeAll { $0.id == item.id }
            flyer.items.append(item)
        }
    }

    private func delete(_ item: FlyerItem) {
        commit { $0.items.removeAll { $0.id == item.id } }
        selection = nil
    }

    private var paperBinding: Binding<FlyerPaper> {
        Binding { flyer?.paper ?? .cream } set: { paper in commit { $0.paper = paper } }
    }

    private func faceBinding(for item: FlyerItem) -> Binding<FlyerFace> {
        Binding { item.face } set: { face in edit(item.id) { $0.face = face } }
    }

    private func colorBinding(for item: FlyerItem) -> Binding<FlyerColor> {
        Binding { item.color } set: { color in edit(item.id) { $0.color = color } }
    }

    private func alignmentBinding(for item: FlyerItem) -> Binding<TextAlignment> {
        Binding { item.alignment } set: { alignment in edit(item.id) { $0.alignment = alignment } }
    }

    private func heavyBinding(for item: FlyerItem) -> Binding<Bool> {
        Binding { item.isHeavy } set: { isHeavy in edit(item.id) { $0.isHeavy = isHeavy } }
    }

    private static func render(_ flyer: Flyer) -> Image? {
        let renderer = ImageRenderer(content: FlyerArtwork(flyer: flyer))
        renderer.scale = 4
        return renderer.uiImage.map { Image(uiImage: $0) }
    }

    /// Sample only: a real app would save or reopen here.
    private func retry() {
        phase = .loaded(flyer ?? .sample)
    }
}

// MARK: - The work

/// The flyer itself, with nothing of the editor in it. The same view is
/// drawn on the board and rendered for export.
struct FlyerArtwork: View {
    let flyer: Flyer
    var select: ((Int) -> Void)?
    var measure: ((Int, CGSize) -> Void)?

    var body: some View {
        ZStack {
            flyer.paper.color
            ForEach(flyer.items) { item in
                FlyerItemView(item: item)
                    .onGeometryChange(for: CGSize.self) { $0.size } action: { measure?(item.id, $0) }
                    .contentShape(.rect)
                    .onTapGesture { select?(item.id) }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(item.name)
                    .accessibilityAddTraits(.isButton)
                    .position(x: item.x, y: item.y)
            }
        }
        .frame(width: Flyer.size.width, height: Flyer.size.height)
        .clipped()
    }
}

private struct FlyerItemView: View {
    let item: FlyerItem

    var body: some View {
        switch item.kind {
        case .text:
            // These words are part of the work, so their size belongs to the
            // work and is set in points on the page. They do not follow the
            // text size setting. The bars around the work do.
            Text(item.text)
                .font(.system(size: item.size, weight: item.isHeavy ? .black : .medium, design: item.face.design))
                .foregroundStyle(item.color.color)
                .multilineTextAlignment(item.alignment)
                // Display sizes are set tight, as on a poster. Small text
                // keeps the face's own leading.
                .lineHeight(item.size >= 32 ? .exact(points: item.size * 0.95) : nil)
                .fixedSize()
        case .disc:
            Circle()
                .fill(item.color.color)
                .frame(width: item.size, height: item.size)
        case .sprig:
            SprigShape()
                .fill(item.color.color)
                .frame(width: item.size, height: item.size * 224 / 136)
        case .photo:
            if let photo = item.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: item.size, height: item.size * 0.75)
                    .clipped()
            }
        }
    }
}

/// A stem with three leaves, drawn for the sample.
private struct SprigShape: Shape {
    func path(in rect: CGRect) -> Path {
        var stem = Path()
        stem.move(to: CGPoint(x: 40, y: 372))
        stem.addCurve(to: CGPoint(x: 96, y: 214), control1: CGPoint(x: 40, y: 300), control2: CGPoint(x: 58, y: 250))
        var path = stem.strokedPath(StrokeStyle(lineWidth: 5, lineCap: .round))
        path.addPath(Self.leaf(
            from: CGPoint(x: 96, y: 214), out: (CGPoint(x: 62, y: 208), CGPoint(x: 38, y: 184)),
            tip: CGPoint(x: 34, y: 148), back: (CGPoint(x: 70, y: 150), CGPoint(x: 94, y: 174))))
        path.addPath(Self.leaf(
            from: CGPoint(x: 88, y: 236), out: (CGPoint(x: 108, y: 224), CGPoint(x: 130, y: 227)),
            tip: CGPoint(x: 146, y: 245), back: (CGPoint(x: 124, y: 257), CGPoint(x: 102, y: 254))))
        path.addPath(Self.leaf(
            from: CGPoint(x: 66, y: 288), out: (CGPoint(x: 36, y: 286), CGPoint(x: 16, y: 268)),
            tip: CGPoint(x: 10, y: 238), back: (CGPoint(x: 40, y: 240), CGPoint(x: 60, y: 258))))
        // The drawing spans x 10 to 146 and y 148 to 372. Fit it to the frame.
        let fit = CGAffineTransform(translationX: -10, y: -148)
            .concatenating(CGAffineTransform(scaleX: rect.width / 136, y: rect.height / 224))
        return path.applying(fit)
    }

    private static func leaf(from start: CGPoint, out: (CGPoint, CGPoint), tip: CGPoint, back: (CGPoint, CGPoint)) -> Path {
        var path = Path()
        path.move(to: start)
        path.addCurve(to: tip, control1: out.0, control2: out.1)
        path.addCurve(to: start, control1: back.0, control2: back.1)
        path.closeSubpath()
        return path
    }
}

// MARK: - Parts

/// Smaller, the value, larger: one chip. Each end is a full-height tap area.
private struct SizeStepper: View {
    let value: String
    let smaller: () -> Void
    let larger: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: smaller) {
                Image(systemName: "minus")
                    .frame(width: 40, height: 44)
                    .contentShape(.rect)
            }
            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
                .frame(minWidth: 48)
            Button(action: larger) {
                Image(systemName: "plus")
                    .frame(width: 40, height: 44)
                    .contentShape(.rect)
            }
        }
        .font(.subheadline)
        .foregroundStyle(CanvasLook.ink)
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(CanvasLook.control)
                .padding(.vertical, 4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Size")
        .accessibilityValue(value)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: larger()
            case .decrement: smaller()
            @unknown default: break
            }
        }
    }
}

private struct LayersSheet: View {
    let items: [FlyerItem]
    let selection: Int?
    let select: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            // Front first, the way the page is stacked.
            List(items.reversed()) { item in
                Button {
                    select(item.id)
                    dismiss()
                } label: {
                    HStack {
                        Label(item.name, systemImage: item.symbol)
                        Spacer()
                        if item.id == selection {
                            Image(systemName: "checkmark")
                                .accessibilityHidden(true)
                        }
                    }
                }
                .accessibilityAddTraits(item.id == selection ? .isSelected : [])
            }
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct EditTextSheet: View {
    @State var text: String
    let save: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField("Text", text: $text, axis: .vertical)
                    .focused($isFocused)
            }
            .navigationTitle("Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save(text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Sample data

extension Flyer {
    static let sample = Flyer(name: "Plant swap flyer", items: [
        FlyerItem(id: 3, kind: .sprig, x: 78, y: 260, size: 136, color: .green),
        FlyerItem(id: 2, kind: .disc, x: 236, y: 176, size: 80, color: .coral),
        FlyerItem(id: 1, kind: .text, text: "PLANT\nSWAP", x: 118, y: 88, size: 56, color: .green),
        FlyerItem(id: 4, kind: .text, text: "Sat 14 June, 10–1", x: 222, y: 250, size: 14, color: .ink),
        FlyerItem(id: 5, kind: .text, text: "Bring a cutting,\ntake a cutting.\nFern St at Hale Rd", x: 211, y: 292, size: 12, color: .ink, isHeavy: false),
    ])

    /// The sample just after a circle was added with the Shape tool.
    static let withNewShape: Flyer = {
        var flyer = sample
        flyer.items.append(FlyerItem(id: 6, kind: .disc, x: 150, y: 187, size: 60, color: .sun))
        return flyer
    }()

    static let blank = Flyer(name: "Untitled flyer", paper: .white, items: [])
}
