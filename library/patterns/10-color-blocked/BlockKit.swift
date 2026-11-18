import SwiftUI

// Direction 10 Color-Blocked Structure: the rest of the look's parts.
// `BlockLook.swift` has the colours, the two buttons and the notice. This
// file adds what a second and a third screen need.
//
// One rule runs through all of it: a category's colour is always a filled
// block with white on it, large or small. Every control is ink.

extension BlockLook {
    // Type roles.
    static let title = Font.largeTitle.bold()
    static let blockTitle = Font.title3.bold()
    static let blockFigure = Font.system(.title, weight: .bold)
    static let blockDetail = Font.subheadline.weight(.medium)
    static let row = Font.body
    static let rowStrong = Font.body.weight(.semibold)
    static let detail = Font.footnote
    static let chip = Font.footnote.weight(.semibold)
    static let head = Font.title3.weight(.bold)
    static let emptyTitle = Font.title2.bold()

    // Sizes.
    static let margin = 16.0
    static let rowMin = 56.0
    static let buttonMin = 50.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is. One width, so names line up.
    static let rowLead = 40.0
    static let leadRadius = 10.0
    static let chipRadius = 10.0

    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF4F5F6)

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ink2 on rest
    // contrast: onBlock on feed
    // contrast: onBlock on walk
    // contrast: onBlock on clean
    // contrast: onBlock on care
}

// MARK: Content parts

/// A category as a block: its icon and name, and one figure. Its height is
/// given by the screen, so that a block's size can carry its share.
struct BlockTile: View {
    let kind: ShiftKind
    let figure: String
    var height = 88.0

    var body: some View {
        HStack(alignment: .top) {
            Label(kind.title, systemImage: kind.symbol)
                .font(BlockLook.blockTitle)
            Spacer(minLength: 8)
            Text(figure)
                .font(BlockLook.blockFigure)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .foregroundStyle(BlockLook.onBlock)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: height, alignment: .top)
        .background(kind.fill, in: .rect(cornerRadius: BlockLook.radius))
    }
}

/// A small block at the end of a row: the category's fill, its icon and a
/// few words. The same colours as the large block, so it reads as one.
struct BlockChip: View {
    let kind: ShiftKind
    let text: String

    var body: some View {
        Label(text, systemImage: kind.symbol)
            .font(BlockLook.chip)
            .monospacedDigit()
            .foregroundStyle(kind == .rest ? BlockLook.ink : BlockLook.onBlock)
            .padding(.horizontal, 10)
            .frame(minHeight: 30)
            .background(kind.fill, in: .rect(cornerRadius: BlockLook.chipRadius))
    }
}

/// A row: something at its start, a name, something at its end. No box and
/// no colour of its own: colour belongs to the blocks.
struct BlockListRow<Lead: View, End: View>: View {
    let name: String
    var isQuiet = false
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: BlockLook.rowLead, alignment: .leading)
            Text(name)
                .font(BlockLook.row)
                .foregroundStyle(isQuiet ? BlockLook.ink2 : BlockLook.ink)
            Spacer(minLength: 8)
            end
        }
        .frame(maxWidth: .infinity, minHeight: BlockLook.rowMin)
        .contentShape(.rect)
    }
}

/// A group's head, heavier than a row.
struct BlockGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .font(BlockLook.head)
            .foregroundStyle(BlockLook.ink)
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
    }
}

/// A picture at the start of a row: a rounded square. Waiting, it is the
/// neutral block colour; if it cannot load, the same square with a mark.
struct BlockPicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                BlockLook.rest
            case .failed:
                BlockLook.rest.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.footnote)
                        .foregroundStyle(BlockLook.ink2)
                }
            }
        }
        .frame(width: BlockLook.rowLead, height: BlockLook.rowLead)
        .clipShape(.rect(cornerRadius: BlockLook.leadRadius))
    }
}

/// A glyph on a neutral tile, for a row whose thing has no picture.
struct BlockGlyphTile: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(BlockLook.ink2)
            .frame(width: BlockLook.rowLead, height: BlockLook.rowLead)
            .background(BlockLook.rest, in: .rect(cornerRadius: BlockLook.leadRadius))
    }
}

/// A person: their photograph, else their initial on the neutral colour,
/// else a dashed ring for nobody yet.
struct BlockPersonMark<Photo: View>: View {
    private let initial: String?
    private let photo: Photo?

    init(photo: Photo) {
        self.photo = photo
        self.initial = nil
    }

    var body: some View {
        Group {
            if let photo {
                photo.clipShape(.circle)
            } else if let initial {
                Text(initial)
                    .font(BlockLook.rowStrong)
                    .foregroundStyle(BlockLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BlockLook.rest, in: .circle)
            } else {
                Circle().strokeBorder(BlockLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: BlockLook.rowLead, height: BlockLook.rowLead)
    }
}

extension BlockPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct BlockLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(7)
            .frame(width: BlockLook.rowLead, height: BlockLook.rowLead)
            .background(BlockLook.logoPlate, in: .rect(cornerRadius: BlockLook.leadRadius))
            .overlay {
                RoundedRectangle(cornerRadius: BlockLook.leadRadius).strokeBorder(BlockLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a week with nothing in it, and for a week still loading:
/// the stack that is not there, in the neutral block colour.
struct BlockGhostStack: View {
    var heights: [Double] = [88, 64, 48]

    var body: some View {
        VStack(spacing: BlockLook.gap) {
            ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
                RoundedRectangle(cornerRadius: BlockLook.radius).fill(BlockLook.rest).frame(height: height)
            }
        }
    }
}

// MARK: Controls

/// The main button: ink. Busy, its words change and the fill lightens. Off,
/// it is the neutral block colour.
struct BlockMainButtonStyle: ButtonStyle {
    var isBusy = false
    var isWide = false

    func makeBody(configuration: Configuration) -> some View {
        Face(isBusy: isBusy, isWide: isWide, isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isBusy: Bool
        let isWide: Bool
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(.headline)
                .foregroundStyle(isEnabled ? BlockLook.ground : BlockLook.ink2)
                .padding(.horizontal, 24)
                .frame(maxWidth: isWide ? .infinity : nil, minHeight: BlockLook.buttonMin)
                .background(isEnabled ? BlockLook.ink.opacity(isBusy ? 0.72 : 1) : BlockLook.rest, in: .capsule)
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.capsule)
        }
    }
}

/// One of a few categories: the blocks themselves, two to a line. The chosen
/// one carries a filled ring with a tick; the others an empty ring.
struct BlockKindChoice: View {
    let kinds: [ShiftKind]
    @Binding var selection: ShiftKind

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: BlockLook.gap), GridItem(.flexible())], spacing: BlockLook.gap) {
            ForEach(kinds) { kind in
                Button {
                    selection = kind
                } label: {
                    HStack {
                        Label(kind.title, systemImage: kind.symbol)
                            .font(BlockLook.chip)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Image(systemName: kind == selection ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                    }
                    .foregroundStyle(BlockLook.onBlock)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(kind.fill, in: .rect(cornerRadius: BlockLook.radius))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// One of a few lengths: segments in one neutral track, the chosen one in ink.
struct BlockSegments: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Text(option)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(option == selection ? BlockLook.ground : BlockLook.ink)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(option == selection ? BlockLook.ink : .clear, in: .rect(cornerRadius: 12))
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(BlockLook.rest, in: .rect(cornerRadius: 16))
    }
}

/// A text field: the text on a neutral block the height of a row. In use it
/// has a two-point ink outline. An error is a mark and a reason under it, in
/// ink: a colour here would read as a category.
struct BlockField: View {
    let name: String
    @Binding var text: String
    var prompt = ""
    var error: String?
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(BlockLook.ink2))
                .font(BlockLook.rowStrong)
                .foregroundStyle(BlockLook.ink)
                .tint(BlockLook.ink)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .padding(.horizontal, 16)
                .frame(minHeight: BlockLook.rowMin)
                .background(BlockLook.rest, in: .rect(cornerRadius: BlockLook.radius))
                .overlay {
                    if isFocused {
                        RoundedRectangle(cornerRadius: BlockLook.radius).strokeBorder(BlockLook.ink, lineWidth: 2)
                    }
                }
            if let error {
                Label(error, systemImage: "nosign")
                    .font(BlockLook.detail)
                    .foregroundStyle(BlockLook.ink)
            }
        }
    }
}

/// A row that has not arrived.
struct BlockGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: BlockLook.leadRadius).fill(BlockLook.rest)
                .frame(width: BlockLook.rowLead, height: BlockLook.rowLead)
            RoundedRectangle(cornerRadius: 4).fill(BlockLook.rest).frame(width: 120, height: 12)
            Spacer()
        }
        .frame(minHeight: BlockLook.rowMin)
    }
}
