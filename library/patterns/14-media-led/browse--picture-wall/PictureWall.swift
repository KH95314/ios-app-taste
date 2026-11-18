import SwiftUI

// Pattern: a wall of pictures with one leading
// Direction 14 Media-Led Experience · kind: browse · look: MediaLook.swift
// Sample product (invented): a library that lends art prints.
//
// The prints are the sample's own pictures, drawn in code so that the entry
// ships no one else's artwork. In an app they would be the product's media.

struct ArtPrint: Identifiable, Equatable {
    let id: Int
    var art: PrintArt
    var title: String
    var artist: String
    /// Width and height in centimetres.
    var width: Int
    var height: Int
    var isNew = false
    var isColour = true
    /// Set only when few copies are left to borrow.
    var copiesLeft: Int?

    /// Who, then what size: the two facts that decide a print.
    var facts: String { "\(artist) · \(width) × \(height) cm" }
}

enum PrintFilter: String, CaseIterable, Identifiable {
    case all = "All", small = "Under 40 cm", colour = "Colour", mono = "Black and white"

    var id: String { rawValue }

    func matches(_ print: ArtPrint) -> Bool {
        switch self {
        case .all: true
        case .small: max(print.width, print.height) < 40
        case .colour: print.isColour
        case .mono: !print.isColour
        }
    }
}

struct PrintCatalogue: Equatable {
    var prints: [ArtPrint]
    var featuredID: Int
    var reservedID: Int?
    /// The last day a reserved print is held.
    var collectBy = "Friday"
}

struct PictureWallScreen: View {
    @State private var phase: Phase<PrintCatalogue>
    @State private var filter: PrintFilter
    @State private var position = ScrollPosition(edge: .top)
    @Environment(\.dynamicTypeSize) private var typeSize

    init(phase: Phase<PrintCatalogue>, filter: PrintFilter = .all) {
        _phase = State(initialValue: phase)
        _filter = State(initialValue: filter)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(MediaLook.ground)
                .navigationTitle("Paper Room")
                // The large title sits in the bar's own row, at the leading
                // edge. The usual large title would leave an empty row above
                // it, and the pictures would start lower.
                .toolbarTitleDisplayMode(.inlineLarge)
                .sensoryFeedback(.success, trigger: catalogue?.reservedID)
        }
        // Controls are black or white. None borrows a colour from a picture.
        .tint(MediaLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            LoadingWall()
        case .empty:
            message("No prints to borrow yet", symbol: "photo.on.rectangle") {
                Button("Check again", action: retry)
                    .buttonStyle(MediaInkButtonStyle())
            }
        case .loaded(let catalogue):
            wall(catalogue, notice: nil)
        case .failed(let message, let stale?):
            wall(stale, notice: message)
        case .failed(let text, nil):
            message("Couldn't load the prints", symbol: "wifi.slash", detail: text) {
                Button("Try again", action: retry)
                    .buttonStyle(MediaInkButtonStyle())
            }
        }
    }

    private func wall(_ catalogue: PrintCatalogue, notice: String?) -> some View {
        let visible = catalogue.prints.filter(filter.matches)
        let lead = visible.first { $0.id == catalogue.featuredID } ?? visible.first
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let notice {
                    MediaNotice(title: "You're offline", message: notice, retry: retry)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                FilterChips(selection: $filter)
                if let lead {
                    LeadPicture(
                        print: lead,
                        isReserved: catalogue.reservedID == lead.id,
                        collectBy: catalogue.collectBy,
                        // Offline, the action is taken away and the notice
                        // says why. A dimmed button on a picture would break
                        // the rule that text on a picture is solid.
                        toggle: notice == nil ? { toggleReservation(of: lead) } : nil)
                        .padding(.horizontal)
                    let rest = visible.filter { $0.id != lead.id }
                    if !rest.isEmpty {
                        Text("Just returned")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(MediaLook.ink)
                            .padding(.horizontal)
                            .padding(.top, 24)
                            .padding(.bottom, 12)
                            .accessibilityAddTraits(.isHeader)
                        shelf(rest, reservedID: catalogue.reservedID)
                    }
                } else {
                    // The chips above say what was asked for, so the message
                    // only has to say there is none, and offer the way out.
                    VStack(spacing: 4) {
                        Text("No \(filter.rawValue.lowercased()) prints right now")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(MediaLook.ink)
                            .multilineTextAlignment(.center)
                        Button("Show all prints") { filter = .all }
                            .buttonStyle(MediaInkButtonStyle())
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .padding(.top, 64)
                }
            }
            .padding(.bottom, 24)
        }
        .scrollPosition($position)
        // Pictures and large titles pass under the bar. A hard edge keeps
        // them from showing through its title.
        .scrollEdgeEffectStyle(.hard, for: .top)
    }

    /// A row to swipe through. At the largest text sizes a title needs the
    /// width, so the row becomes a list with the picture beside the words.
    @ViewBuilder private func shelf(_ prints: [ArtPrint], reservedID: Int?) -> some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: MediaLook.gap) {
                ForEach(prints) { print in
                    PrintCard(print: print, isReserved: print.id == reservedID, isRow: true) { feature(print) }
                }
            }
            .padding(.horizontal)
        } else {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: MediaLook.gap) {
                    ForEach(prints) { print in
                        PrintCard(print: print, isReserved: print.id == reservedID, isRow: false) { feature(print) }
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func message(_ title: String, symbol: String, detail: String? = nil, @ViewBuilder action: () -> some View) -> some View {
        ScrollsIfNeeded {
            VStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.largeTitle)
                    .foregroundStyle(MediaLook.ink2)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(MediaLook.ink)
                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(MediaLook.ink2)
                }
                action()
                    .padding(.top, 12)
            }
            .multilineTextAlignment(.center)
            .padding(32)
        }
    }

    private var catalogue: PrintCatalogue? {
        switch phase {
        case .loaded(let catalogue), .failed(_, let catalogue?): catalogue
        default: nil
        }
    }

    private func change(_ edit: (inout PrintCatalogue) -> Void) {
        guard var catalogue else { return }
        edit(&catalogue)
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: catalogue)
        } else {
            phase = .loaded(catalogue)
        }
    }

    /// The badge on the picture changes to say it is yours and until when.
    /// No message follows.
    private func toggleReservation(of print: ArtPrint) {
        withAnimation {
            change { $0.reservedID = $0.reservedID == print.id ? nil : print.id }
        }
    }

    /// Choosing a small picture makes it the large one.
    private func feature(_ print: ArtPrint) {
        withAnimation {
            change { $0.featuredID = print.id }
            position.scrollTo(edge: .top)
        }
    }

    /// Sample only: a real app would refetch here.
    private func retry() {
        phase = .loaded(catalogue ?? .sample)
    }
}

// MARK: - Parts

private struct FilterChips: View {
    @Binding var selection: PrintFilter

    var body: some View {
        // Filters are the one row that scrolls sideways at every size: the
        // cut-off chip at the edge is what says there are more.
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(PrintFilter.allCases) { filter in
                        Button(filter.rawValue) { selection = filter }
                            .buttonStyle(MediaChipStyle(isOn: filter == selection))
                            .accessibilityAddTraits(filter == selection ? .isSelected : [])
                            .id(filter)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            // The chosen chip is never the one that is cut off.
            .onChange(of: selection, initial: true) { _, chosen in
                proxy.scrollTo(chosen, anchor: chosen == .all ? .leading : .trailing)
            }
        }
        .padding(.bottom, 8)
    }
}

/// The picture that leads: large, with its title and the one action on it.
private struct LeadPicture: View {
    let print: ArtPrint
    let isReserved: Bool
    let collectBy: String
    let toggle: (() -> Void)?

    /// The picture's width, so that it can be at least as tall as it is wide.
    @State private var side = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            badge
                .padding(12)
            Spacer(minLength: 0)
            // The scrim fades in above the words and is at full strength
            // behind every one of them.
            LinearGradient(colors: [MediaLook.scrim.opacity(0), MediaLook.scrim], startPoint: .top, endPoint: .bottom)
                .frame(height: 64)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .bottom, spacing: 12) {
                    words
                    Spacer(minLength: 12)
                    action
                }
                VStack(alignment: .leading, spacing: 12) {
                    words
                    action
                }
            }
            .padding([.horizontal, .bottom], 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MediaLook.scrim)
        }
        // The picture is square, and grows taller only when large text makes
        // the badge and the words need more room than that. The badge is in
        // the flow, so it can never sit on the title.
        .frame(maxWidth: .infinity, minHeight: side, alignment: .topLeading)
        .onGeometryChange(for: Double.self) { $0.size.width } action: { side = $0 }
        .background {
            PrintArtView(art: print.art)
        }
        .clipShape(.rect(cornerRadius: MediaLook.pictureRadius))
    }

    private var words: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(print.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            // Solid white, like the title. Never dimmed on a picture.
            Text(print.facts)
                .font(.footnote)
        }
        // The words wrap; they are never cut short to save height.
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(MediaLook.onPicture)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder private var action: some View {
        if let toggle {
            Button(isReserved ? "Cancel" : "Reserve", action: toggle)
                .buttonStyle(MediaOnPictureButtonStyle(isOutline: isReserved))
                .accessibilityLabel(isReserved ? "Cancel reservation of \(print.title)" : "Reserve \(print.title)")
        }
    }

    /// One fact, and the most useful one: that it is yours and until when,
    /// else how few are left, else that it is new.
    @ViewBuilder private var badge: some View {
        if isReserved {
            MediaBadge(text: "Reserved · collect by \(collectBy)", systemImage: "checkmark")
        } else if let left = print.copiesLeft {
            MediaBadge(text: "\(left) left")
        } else if print.isNew {
            MediaBadge(text: "New this week")
        }
    }
}

private struct PrintCard: View {
    let print: ArtPrint
    let isReserved: Bool
    let isRow: Bool
    let choose: () -> Void
    @ScaledMetric(relativeTo: .subheadline) private var cardWidth = 168.0

    var body: some View {
        Button(action: choose) {
            if isRow {
                HStack(alignment: .top, spacing: 12) {
                    picture
                        .frame(width: 104)
                    words
                    Spacer(minLength: 0)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    picture
                    words
                }
                .frame(width: min(cardWidth, 220), alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    private var picture: some View {
        PrintArtView(art: print.art)
            .aspectRatio(4.0 / 5.0, contentMode: .fit)
            .clipShape(.rect(cornerRadius: MediaLook.pictureRadius))
            .overlay(alignment: .topLeading) {
                if isReserved {
                    MediaBadge(text: "Reserved", systemImage: "checkmark")
                        .padding(8)
                } else if let left = print.copiesLeft {
                    MediaBadge(text: "\(left) left")
                        .padding(8)
                }
            }
    }

    private var words: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(print.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(MediaLook.ink)
            Text(print.facts)
                .font(.footnote)
                .foregroundStyle(MediaLook.ink2)
        }
        .multilineTextAlignment(.leading)
    }
}

/// Placeholders hold the pictures' places at their real sizes, so nothing
/// moves when they arrive.
private struct LoadingWall: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    ForEach([44.0, 104, 72], id: \.self) { width in
                        Capsule()
                            .fill(MediaLook.placeholder)
                            .frame(width: width, height: 36)
                    }
                }
                .frame(minHeight: 44)
                .padding(.bottom, 8)
                RoundedRectangle(cornerRadius: MediaLook.pictureRadius)
                    .fill(MediaLook.placeholder)
                    .aspectRatio(1, contentMode: .fit)
                RoundedRectangle(cornerRadius: 4)
                    .fill(MediaLook.placeholder)
                    .frame(width: 150, height: 22)
                    .padding(.top, 28)
                    .padding(.bottom, 14)
                // The row runs off the trailing edge, as the real one does.
                // It sits in an overlay so that its width does not widen
                // the page.
                Color.clear
                    .frame(height: 258)
                    .overlay(alignment: .topLeading) {
                        HStack(alignment: .top, spacing: MediaLook.gap) {
                            ForEach(0..<3, id: \.self) { _ in
                                VStack(alignment: .leading, spacing: 8) {
                                    RoundedRectangle(cornerRadius: MediaLook.pictureRadius)
                                        .fill(MediaLook.placeholder)
                                        .frame(width: 168, height: 210)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(MediaLook.placeholder)
                                        .frame(width: 120, height: 12)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(MediaLook.placeholder)
                                        .frame(width: 80, height: 12)
                                }
                            }
                        }
                        .fixedSize()
                    }
            }
            .padding(.horizontal)
        }
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading prints")
    }
}

// MARK: - The sample's pictures

enum PrintArt: Equatable {
    case lowSun, pears, harbour, nightSwim, stairs, field
}

/// One print, drawn to fill whatever frame it is given.
struct PrintArtView: View {
    let art: PrintArt

    var body: some View {
        Canvas { context, size in
            // Each drawing is made on a 100 by 125 sheet and scaled to cover.
            let scale = max(size.width / 100, size.height / 125)
            context.translateBy(x: (size.width - 100 * scale) / 2, y: (size.height - 125 * scale) / 2)
            context.scaleBy(x: scale, y: scale)
            PrintPainter.paint(art, in: &context)
        }
        .accessibilityHidden(true)
    }
}

private enum PrintPainter {
    static func paint(_ art: PrintArt, in context: inout GraphicsContext) {
        switch art {
        case .lowSun:
            sheet(0xF2E3C9, in: &context)
            fill(Path(ellipseIn: CGRect(x: 23, y: 23, width: 54, height: 54)), 0xE4572E, in: &context)
            fill(rect(0, 78, 100, 47), 0x2E5E8C, in: &context)
            for y in [90.0, 101, 112] { fill(rect(0, y - 1.2, 100, 2.4), 0x5B8FC0, in: &context) }
            fill(rect(38, 78, 24, 5), 0xF2B441, in: &context)
        case .pears:
            sheet(0xE9EFD9, in: &context)
            fill(rect(0, 95, 100, 2), 0x5A4A36, in: &context)
            pear(x: 27, y: 74, width: 28, height: 38, hex: 0x5E8C3A, in: &context)
            pear(x: 55, y: 72, width: 30, height: 42, hex: 0xC9B037, in: &context)
            pear(x: 79, y: 78, width: 22, height: 30, hex: 0x8C5E3A, in: &context)
        case .harbour:
            sheet(0xDCE8F2, in: &context)
            fill(rect(0, 84, 100, 41), 0x3F6F9F, in: &context)
            fill(polygon([(22, 84), (62, 84), (56, 96), (28, 96)]), 0x1F3A5F, in: &context)
            fill(polygon([(42, 42), (64, 76), (42, 76)]), 0xF7F4EC, in: &context)
            fill(polygon([(40, 50), (24, 78), (40, 78)]), 0xE4572E, in: &context)
            fill(rect(41.2, 40, 1.6, 44), 0x1F3A5F, in: &context)
            fill(polygon([(64, 84), (90, 84), (86, 93), (68, 93)]), 0x1F3A5F, in: &context)
            fill(polygon([(76, 60), (88, 80), (76, 80)]), 0xF2B441, in: &context)
            fill(rect(75.3, 58, 1.4, 26), 0x1F3A5F, in: &context)
        case .nightSwim:
            sheet(0x14213D, in: &context)
            fill(Path(ellipseIn: CGRect(x: 57, y: 17, width: 26, height: 26)), 0xFCA311, in: &context)
            for y in [70.0, 86, 102] {
                var wave = Path()
                wave.move(to: CGPoint(x: 0, y: y))
                for x in stride(from: 2.0, through: 100, by: 2) {
                    wave.addLine(to: CGPoint(x: x, y: y - 4 * sin(x / 60 * 2 * .pi)))
                }
                context.stroke(wave, with: .color(Color(fixed: 0xE5E5E5)), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
            }
            fill(Path(ellipseIn: CGRect(x: 30.8, y: 76.8, width: 6.4, height: 6.4)), 0xFCA311, in: &context)
        case .stairs:
            sheet(0xF7D6E0, in: &context)
            fill(polygon([(0, 125), (0, 96), (20, 96), (20, 76), (40, 76), (40, 56), (60, 56), (60, 36), (80, 36), (80, 16), (100, 16), (100, 125)]), 0xC2185B, in: &context)
            fill(polygon([(0, 125), (0, 113), (20, 113), (20, 93), (40, 93), (40, 73), (60, 73), (60, 53), (80, 53), (80, 33), (100, 33), (100, 125)]), 0x7B1E3A, in: &context)
        case .field:
            sheet(0xFAF3DD, in: &context)
            for row in 0..<6 {
                for column in 0..<5 {
                    let radius = 3.0 + Double((row * 5 + column * 3) % 5)
                    let centre = CGPoint(x: 14 + Double(column) * 18, y: 16 + Double(row) * 18.5)
                    let dot = Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2))
                    fill(dot, row == 3 && column == 2 ? 0xE4572E : 0x2D6A4F, in: &context)
                }
            }
        }
    }

    private static func sheet(_ hex: UInt32, in context: inout GraphicsContext) {
        fill(rect(-50, -50, 200, 225), hex, in: &context)
    }

    private static func fill(_ path: Path, _ hex: UInt32, in context: inout GraphicsContext) {
        context.fill(path, with: .color(Color(fixed: hex)))
    }

    private static func rect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> Path {
        Path(CGRect(x: x, y: y, width: width, height: height))
    }

    private static func polygon(_ points: [(Double, Double)]) -> Path {
        var path = Path()
        path.addLines(points.map { CGPoint(x: $0.0, y: $0.1) })
        path.closeSubpath()
        return path
    }

    private static func pear(x: Double, y: Double, width: Double, height: Double, hex: UInt32, in context: inout GraphicsContext) {
        fill(Path(ellipseIn: CGRect(x: x - width / 2, y: y - height / 2, width: width, height: height)), hex, in: &context)
        let head = width * 0.62
        fill(Path(ellipseIn: CGRect(x: x - head / 2, y: y - height / 2 - head * 0.55, width: head, height: head)), hex, in: &context)
        fill(rect(x - 0.9, y - height / 2 - head * 0.55 - 7, 1.8, 8), 0x3B2F22, in: &context)
    }
}

// MARK: - Sample data

extension PrintCatalogue {
    static let sample = PrintCatalogue(
        prints: [
            ArtPrint(id: 1, art: .lowSun, title: "Low Sun", artist: "Ana Ruiz", width: 50, height: 70, isNew: true),
            ArtPrint(id: 2, art: .pears, title: "Three Pears", artist: "Jun Okada", width: 30, height: 40),
            ArtPrint(id: 3, art: .nightSwim, title: "Night Swim", artist: "Mo Adeyemi", width: 40, height: 50, copiesLeft: 1),
            ArtPrint(id: 4, art: .stairs, title: "Stairs", artist: "Ana Ruiz", width: 30, height: 40),
            ArtPrint(id: 5, art: .harbour, title: "Harbour", artist: "Jun Okada", width: 30, height: 40),
            ArtPrint(id: 6, art: .field, title: "Field Notes", artist: "Siv Lind", width: 21, height: 30),
        ],
        featuredID: 1)

    /// The sample just after "Low Sun" was reserved.
    static let reserved: PrintCatalogue = {
        var catalogue = sample
        catalogue.reservedID = 1
        return catalogue
    }()
}
