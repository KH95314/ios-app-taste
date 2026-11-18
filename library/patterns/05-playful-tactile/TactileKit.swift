import SwiftUI

// Direction 05 Playful & Tactile: the rest of the look's parts.
// `TactileLook.swift` has the colours, the type roles, the sizes, the key,
// the block, the slot and the notice. This file adds what a second and a
// third screen need: the look's own content parts first, then its controls.
//
// One rule runs through all of it: only a thing that can be pressed, or that
// a press produced, has a lower edge.

// MARK: Content parts

/// Progress as a count of objects: blocks in a tray, with a dashed slot for
/// each one still to come.
struct TactileStack: View {
    let filled: Int
    let total: Int
    var blockHeight = 47.0

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<max(total - filled, 0), id: \.self) { _ in
                TactileSlot(height: blockHeight)
            }
            ForEach(0..<min(filled, total), id: \.self) { _ in
                TactileBlock(height: blockHeight)
            }
        }
        .padding(12)
        .frame(width: 150)
        .background(TactileLook.tray, in: .rect(cornerRadius: TactileLook.radius + 6))
    }
}

/// The number beside the stack: very large, with its total small under it.
struct TactileCount: View {
    let value: Int
    let total: String
    @ScaledMetric(relativeTo: .largeTitle) private var size = 76.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value, format: .number)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(TactileLook.ink)
                .contentTransition(.numericText())
            Text(total)
                .font(TactileLook.note)
                .foregroundStyle(TactileLook.ink2)
        }
    }
}

/// A week of discs inside one outline. A done day is a key-coloured disc with
/// a tick; today has a ring; the rest wait on the tray colour.
struct TactileWeek: View {
    let done: Set<Int>
    let today: Int
    private static let letters = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { day in
                VStack(spacing: 4) {
                    Circle()
                        .fill(done.contains(day) ? TactileLook.key : TactileLook.tray)
                        .frame(width: 36, height: 36)
                        .overlay {
                            if done.contains(day) {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(TactileLook.onKey)
                            }
                        }
                        .overlay {
                            if day == today {
                                Circle().strokeBorder(TactileLook.ink, lineWidth: 2.5).padding(-5.5)
                            }
                        }
                    Text(Self.letters[day])
                        .font(TactileLook.small)
                        .foregroundStyle(day == today ? TactileLook.ink : TactileLook.ink2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .overlay {
            RoundedRectangle(cornerRadius: TactileLook.radius + 6).strokeBorder(TactileLook.tray, lineWidth: 2)
        }
    }
}

/// Progress where a stack will not fit: a thick bar with a lower edge and a
/// light stripe, in a tray-coloured track.
struct TactileBar: View {
    let fraction: Double

    var body: some View {
        Capsule()
            .fill(TactileLook.tray)
            .frame(height: 25)
            .overlay(alignment: .topLeading) {
                GeometryReader { track in
                    Capsule()
                        .fill(TactileLook.key)
                        .overlay(alignment: .top) {
                            Capsule().fill(TactileLook.shine).frame(height: 3).padding(.horizontal, 9).padding(.top, 3)
                        }
                        .background { Capsule().fill(TactileLook.keyEdge).offset(y: 4) }
                        .frame(width: max(15, (track.size.width - 6) * min(max(fraction, 0), 1)), height: 15)
                        .padding(3)
                }
            }
    }
}

/// Rows that share one tray, cut apart by a line of the ground.
struct TactileRows<Rows: View>: View {
    @ViewBuilder var rows: Rows

    var body: some View {
        VStack(spacing: 2) { rows }
            .background(TactileLook.ground)
            .clipShape(.rect(cornerRadius: TactileLook.radius))
    }
}

/// One row on a tray: something at its start, a name, and something at its end.
struct TactileRow<Lead: View, End: View>: View {
    let name: String
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
            Text(name)
                .font(TactileLook.row)
                .foregroundStyle(TactileLook.ink)
            Spacer(minLength: 8)
            end
                .font(TactileLook.note)
                .foregroundStyle(TactileLook.ink2)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: TactileLook.rowMin)
        .background(TactileLook.tray)
    }
}

extension TactileRow where Lead == EmptyView {
    init(name: String, @ViewBuilder end: () -> End) {
        self.init(name: name, lead: { EmptyView() }, end: end)
    }
}

/// A glyph on a tile of the ground, at the start of a row.
struct TactileGlyphTile: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(TactileLook.ink)
            .frame(width: TactileLook.tile, height: TactileLook.tile)
            .background(TactileLook.ground, in: .rect(cornerRadius: TactileLook.tileCorner))
    }
}

/// One pip for each block: filled ones have the key's colour and edge, the
/// rest are dashed outlines.
struct TactilePips: View {
    let filled: Int
    let total: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<total, id: \.self) { index in
                if index < filled {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(TactileLook.key)
                        .frame(width: 9, height: 12)
                        .background { RoundedRectangle(cornerRadius: 3).fill(TactileLook.keyEdge).offset(y: 3) }
                        .padding(.bottom, 3)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(TactileLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [2.5, 2]))
                        .frame(width: 9, height: 15)
                }
            }
        }
    }
}

/// The small second key at the end of a row that opens something.
struct TactileSmallKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.heavy)
            .foregroundStyle(TactileLook.onKey)
            .frame(width: 30, height: 26)
            .background(TactileLook.key2, in: .capsule)
            .offset(y: configuration.isPressed ? 4 : 0)
            .background {
                if !configuration.isPressed {
                    Capsule().fill(TactileLook.key2Edge).offset(y: 4)
                }
            }
            .padding(.bottom, 4)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
    }
}

/// A picture sits in a tray, like a block. Until it comes its place is a
/// dashed slot, as for a block not yet earned; if it cannot load, the slot
/// keeps a mark.
struct TactilePicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
                    .frame(width: TactileLook.picture, height: TactileLook.picture)
                    .clipShape(.rect(cornerRadius: 16))
            case .waiting:
                slot
            case .failed:
                slot.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(TactileLook.ink2)
                }
            }
        }
        .padding(6)
        .background(TactileLook.tray, in: .rect(cornerRadius: TactileLook.radius))
    }

    private var slot: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(TactileLook.ink2, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            .frame(width: TactileLook.picture, height: TactileLook.picture)
    }
}

/// A person: their photograph, else their initial on a disc, else a dashed
/// ring for nobody yet. The disc is the tray's colour on the ground and the
/// ground's colour in a row, which is itself a tray.
struct TactilePersonMark<Photo: View>: View {
    private let initial: String?
    private let photo: Photo?
    private let isInRow: Bool

    init(photo: Photo) {
        self.photo = photo
        self.initial = nil
        self.isInRow = false
    }

    var body: some View {
        Group {
            if let photo {
                photo.clipShape(.circle)
            } else if let initial {
                Text(initial)
                    .font(TactileLook.row)
                    .fontWeight(.bold)
                    .foregroundStyle(TactileLook.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(isInRow ? TactileLook.ground : TactileLook.tray, in: .circle)
            } else {
                Circle().strokeBorder(TactileLook.ink2, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
        }
        .frame(width: TactileLook.person, height: TactileLook.person)
    }
}

extension TactilePersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?, isInRow: Bool = false) {
        self.photo = nil
        self.initial = initial
        self.isInRow = isInRow
    }
}

/// The tile another company's logo sits on. No lower edge: it cannot be
/// pressed.
struct TactileLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(5)
            .frame(width: TactileLook.tile, height: TactileLook.tile)
            .background(TactileLook.plate, in: .rect(cornerRadius: TactileLook.tileCorner))
    }
}

/// The picture for a screen with nothing logged: an empty tray, and a block
/// about to fall into it.
struct TactileEmptyDrawing: View {
    var body: some View {
        TactileStack(filled: 0, total: 2)
            .padding(.top, 62)
            .overlay(alignment: .top) {
                TactileBlock(height: 47)
                    .frame(width: 98)
                    .rotationEffect(.degrees(-8))
            }
    }
}

// MARK: Controls

/// Underlined words, for the retry in a notice. The one thing that can be
/// pressed and has no lower edge.
struct TactileTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TactileLook.note)
            .fontWeight(.bold)
            .underline()
            .foregroundStyle(TactileLook.ink)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// One of a few: a row of keys, and the chosen one stays down.
struct TactileChoiceKeys: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
                    .buttonStyle(TactileKeyStyle(kind: option == selection ? .main : .second, isHeld: option == selection))
            }
        }
    }
}

/// A text field: its name above, the text on a tray the size of a key. In
/// use, a ring in ink stands off it. An error is an icon and a reason under
/// it, in ink: on this ground a warning colour would fight the keys.
/// Where the screen's title already names the one field on it, leave the
/// name off (`showsName: false`): it would say the title twice.
struct TactileField: View {
    let name: String
    @Binding var text: String
    var prompt = ""
    var error: String?
    var showsName = true
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showsName {
                Text(name)
                    .font(TactileLook.note)
                    .foregroundStyle(TactileLook.ink2)
            }
            TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(TactileLook.ink2))
                .font(TactileLook.keyLabel)
                .foregroundStyle(TactileLook.ink)
                .tint(TactileLook.ink)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .padding(.horizontal, 16)
                .frame(minHeight: TactileLook.keyMin)
                .background(TactileLook.tray, in: .rect(cornerRadius: TactileLook.radius))
                .overlay {
                    if isFocused {
                        RoundedRectangle(cornerRadius: TactileLook.radius + 5.5)
                            .strokeBorder(TactileLook.ink, lineWidth: 2.5)
                            .padding(-5.5)
                    }
                }
            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(TactileLook.note)
                    .foregroundStyle(TactileLook.ink)
                    .padding(.top, 2)
            }
        }
    }
}
