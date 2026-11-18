import SwiftUI

// Direction 13 Canvas-First Creation: the rest of the look's parts.
// `CanvasLook.swift` has the colours, the tool cell, the chip, the selection
// outline and the notice. This file adds what a second and a third screen
// need. Its types are named `Studio…`, because `Canvas` is SwiftUI's.
//
// One rule runs through all of it: the work has the colour, and it lies on
// the board as a page, large where it leads a screen and small where it
// starts a row. Everything around it is neutral. The one hue marks what is
// chosen or in use, and nothing else.

extension CanvasLook {
    // Type roles.
    /// The work's name over the corner of its page, the way an artboard is labelled.
    static let corner = Font.footnote.weight(.semibold)
    static let name = Font.body
    static let nameStrong = Font.body.weight(.semibold)
    static let detail = Font.footnote
    static let figure = Font.body.weight(.semibold)
    static let chip = Font.subheadline.weight(.medium)
    static let button = Font.headline
    static let emptyTitle = Font.title2.bold()

    // Sizes.
    /// The board's margin: the page's edge and every row's edge.
    static let margin = 24.0
    static let rowMin = 64.0
    static let buttonMin = 50.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is: a small page, a person, a logo, the
    /// app's mark. One width, so every name starts at the same edge.
    static let rowLead = 40.0
    static let chipRadius = 8.0
    static let buttonRadius = 10.0
    /// A page's width over its height, unless the work says otherwise.
    static let pageShape = 0.8
    /// The tallest a page that leads a list is drawn, so a row shows under it.
    static let leadMax = 320.0

    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF4F5F6)
    /// Under a page, to lift it off the board.
    static let pageShadow = Color(fixed: 0x000000).opacity(0.14)

    // contrast: ink on board
    // contrast: ink2 on board
    // contrast: ink on chrome
    // contrast: ink2 on chrome
    // contrast: ink on control
    // contrast: ink2 on control
    // contrast: active on control
    // contrast: chrome on ink
    // contrast: active on chrome 3
}

// MARK: Content parts

/// A page: the work as a picture, at any size. Waiting, it is the bare page;
/// if it cannot load, the page keeps a mark; with nothing made yet, it is a
/// dashed outline on the board. No hue in any of them: colour is the work's.
struct StudioPage: View {
    /// `nil` when there is nothing to draw yet.
    let form: PictureForm?
    var shape = CanvasLook.pageShape
    /// The page that leads a screen shows that it is on its way.
    var isLead = false

    var body: some View {
        ZStack {
            switch form {
            case .some(.loaded(let picture)):
                picture.resizable()
            case .some(.waiting):
                CanvasLook.chrome
                if isLead {
                    ProgressView()
                        .controlSize(.large)
                        .tint(CanvasLook.ink2)
                }
            case .some(.failed):
                CanvasLook.chrome
                Image(systemName: "photo.badge.exclamationmark")
                    .font(isLead ? .largeTitle : .footnote)
                    .foregroundStyle(CanvasLook.ink2)
            case .none:
                Rectangle()
                    .strokeBorder(CanvasLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            }
        }
        .aspectRatio(shape, contentMode: .fit)
        .shadow(color: form == nil ? .clear : CanvasLook.pageShadow, radius: isLead ? 12 : 3, y: isLead ? 6 : 1.5)
    }
}

/// What leads a list of work: the newest page, large on the board, with its
/// name over its corner. `name` is `nil` while the list is on its way.
struct StudioLeadWork: View {
    let name: String?
    let form: PictureForm?
    var shape = CanvasLook.pageShape

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let name {
                Text(name)
                    .font(CanvasLook.corner)
                    .foregroundStyle(CanvasLook.ink2)
                    .lineLimit(1)
            } else {
                RoundedRectangle(cornerRadius: 4).fill(CanvasLook.chrome)
                    .frame(width: 110, height: 10)
                    .frame(height: 16)
            }
            StudioPage(form: form, shape: shape, isLead: true)
                .frame(maxHeight: CanvasLook.leadMax)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. No box and no line: on the board the small pages
/// mark the rows themselves.
struct StudioPartRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 14) {
            lead
                .frame(width: CanvasLook.rowLead, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(CanvasLook.name)
                    .foregroundStyle(CanvasLook.ink)
                if let detail {
                    Text(detail)
                        .font(CanvasLook.detail)
                        .foregroundStyle(CanvasLook.ink2)
                }
            }
            Spacer(minLength: 8)
            end
        }
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, minHeight: CanvasLook.rowMin)
        .contentShape(.rect)
    }
}

/// A person: their photograph, else their initial on a neutral disc, else a
/// dashed ring for nobody yet.
struct StudioPersonMark<Photo: View>: View {
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
                    .font(CanvasLook.nameStrong)
                    .foregroundStyle(CanvasLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CanvasLook.chrome, in: .circle)
            } else {
                Circle().strokeBorder(CanvasLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: CanvasLook.rowLead, height: CanvasLook.rowLead)
    }
}

extension StudioPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct StudioLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(7)
            .frame(width: CanvasLook.rowLead, height: CanvasLook.rowLead)
            .background(CanvasLook.logoPlate, in: .rect(cornerRadius: CanvasLook.chipRadius))
            .overlay {
                RoundedRectangle(cornerRadius: CanvasLook.chipRadius).strokeBorder(CanvasLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a screen with no work on it: a bare page, already
/// selected, with the look's own outline and handles. The hue is here
/// because the page is what the first tool will act on.
struct StudioEmptyPage: View {
    private let width = 132.0, height = 165.0

    var body: some View {
        ZStack {
            CanvasLook.chrome
            CanvasSelectionFrame(scale: 1)
            ForEach(0..<4, id: \.self) { corner in
                CanvasHandle(scale: 1)
                    .position(x: corner % 2 == 0 ? 0 : width, y: corner < 2 ? 0 : height)
            }
        }
        .frame(width: width, height: height)
        .shadow(color: CanvasLook.pageShadow, radius: 12, y: 6)
        .allowsHitTesting(false)
    }
}

// MARK: Controls

/// The main button: ink, as wide as its place, and never the hue, which
/// would outshine the work. Busy, its words change and the fill lightens.
/// Off, it is a chip with quiet words.
struct StudioMainButtonStyle: ButtonStyle {
    var isBusy = false

    func makeBody(configuration: Configuration) -> some View {
        Face(isBusy: isBusy, isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isBusy: Bool
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(CanvasLook.button)
                .foregroundStyle(isEnabled ? CanvasLook.chrome : CanvasLook.ink2)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: CanvasLook.buttonMin)
                .background(
                    isEnabled ? CanvasLook.ink.opacity(isBusy ? 0.72 : 1) : CanvasLook.control,
                    in: .rect(cornerRadius: CanvasLook.buttonRadius))
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.rect(cornerRadius: CanvasLook.buttonRadius))
        }
    }
}

/// The second kind of button: underlined words in ink, as in the look's
/// notice. There is no third.
struct StudioTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(CanvasLook.ink)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// One of a few: the look's chips in a row. The chosen one is worded and
/// ringed in the hue, as the tool in use is. Off, the others go quiet and
/// the chosen one stays.
struct StudioChoice: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
                    .buttonStyle(Chip(isOn: option == selection))
            }
        }
    }

    private struct Chip: ButtonStyle {
        let isOn: Bool

        func makeBody(configuration: Configuration) -> some View {
            Face(isOn: isOn, isPressed: configuration.isPressed, label: configuration.label)
        }

        private struct Face: View {
            let isOn: Bool
            let isPressed: Bool
            let label: ButtonStyleConfiguration.Label
            @Environment(\.isEnabled) private var isEnabled

            var body: some View {
                label
                    .font(CanvasLook.chip)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(isOn ? CanvasLook.active : isEnabled ? CanvasLook.ink : CanvasLook.ink2)
                    .padding(.horizontal, 6)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(CanvasLook.control, in: .rect(cornerRadius: CanvasLook.chipRadius))
                    .overlay {
                        if isOn {
                            RoundedRectangle(cornerRadius: CanvasLook.chipRadius)
                                .strokeBorder(CanvasLook.active, lineWidth: 1.5)
                        }
                    }
                    .contentShape(.rect)
                    .opacity(isPressed ? 0.6 : 1)
            }
        }
    }
}

/// A text field: a chip as wide as its place. In use it is ringed in the
/// hue. An error is a mark and a reason under it, in ink: the hue means
/// "chosen" here and cannot also mean "wrong".
struct StudioField: View {
    let name: String
    @Binding var text: String
    var error: String?
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(name, text: $text, prompt: Text(name).foregroundStyle(CanvasLook.ink2))
                .font(CanvasLook.name)
                .foregroundStyle(CanvasLook.ink)
                .tint(CanvasLook.active)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .padding(.horizontal, 12)
                .frame(minHeight: 48)
                .background(CanvasLook.control, in: .rect(cornerRadius: CanvasLook.chipRadius))
                .overlay {
                    if isFocused {
                        RoundedRectangle(cornerRadius: CanvasLook.chipRadius)
                            .strokeBorder(CanvasLook.active, lineWidth: 1.5)
                    }
                }
            if let error {
                Label(error, systemImage: "nosign")
                    .font(CanvasLook.detail)
                    .foregroundStyle(CanvasLook.ink)
                    .padding(.top, 8)
            }
        }
    }
}

/// A row that has not arrived: a bare page and a bar for its name.
struct StudioGhostRow: View {
    var body: some View {
        HStack(spacing: 14) {
            Rectangle().fill(CanvasLook.chrome)
                .frame(width: CanvasLook.rowLead, height: CanvasLook.rowLead / CanvasLook.pageShape)
            RoundedRectangle(cornerRadius: 4).fill(CanvasLook.chrome).frame(width: 130, height: 12)
            Spacer()
        }
        .frame(minHeight: CanvasLook.rowMin)
    }
}
