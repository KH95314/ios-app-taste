import SwiftUI

// Direction 14 Media-Led Experience: the rest of the look's parts.
// `MediaLook.swift` has the colours, the badge, the chip, the buttons and the
// notice. This file adds what a second and a third screen need.
//
// One rule runs through all of it: the pictures are the only colour. Words on
// a picture are solid white over a scrim; everything off a picture is black
// or white.

extension MediaLook {
    // Type roles.
    static let title = Font.largeTitle.bold()
    /// The title set on the picture that leads a screen.
    static let pictureTitle = Font.title.bold()
    static let pictureFacts = Font.footnote
    static let row = Font.body
    static let rowStrong = Font.body.weight(.semibold)
    static let detail = Font.footnote
    static let head = Font.title3.weight(.bold)
    static let emptyTitle = Font.title2.bold()

    // Sizes.
    static let margin = 16.0
    static let rowMin = 72.0
    static let buttonMin = 50.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is: a small picture, a person, a logo,
    /// the app's mark. One width, so every name starts at the same edge.
    static let rowLead = 56.0
    static let leadRadius = 8.0

    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF4F5F6)

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ink2 on placeholder
    // contrast: onBadge on badge
}

// MARK: Content parts

/// The picture that leads a screen, at its own shape. Its title and facts
/// are set on it, solid white over a scrim, with one action beside them and
/// one badge at its top corner. Waiting, it is the placeholder at the same
/// shape, so nothing moves when the picture comes; the words stay readable
/// on the scrim in every form.
struct MediaHero<Action: View>: View {
    let form: PictureForm
    /// Width over height. The frame is this shape before the picture comes.
    let shape: Double
    let title: String
    let facts: String
    var badge: String?
    var badgeSymbol: String?
    @ViewBuilder var action: Action

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let badge {
                MediaBadge(text: badge, systemImage: badgeSymbol)
                    .padding(12)
            }
            Spacer(minLength: 0)
            LinearGradient(colors: [MediaLook.scrim.opacity(0), MediaLook.scrim], startPoint: .top, endPoint: .bottom)
                .frame(height: 56)
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(MediaLook.pictureTitle)
                    Text(facts).font(MediaLook.pictureFacts)
                }
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(MediaLook.onPicture)
                Spacer(minLength: 8)
                action
            }
            .padding([.horizontal, .bottom], 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MediaLook.scrim)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(shape, contentMode: .fit)
        .background {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                MediaLook.placeholder
            case .failed:
                MediaLook.placeholder.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.title)
                        .foregroundStyle(MediaLook.ink2)
                        .offset(y: -40)
                }
            }
        }
        .clipShape(.rect(cornerRadius: MediaLook.pictureRadius))
    }
}

/// A small picture at the start of a row. Waiting, it is the placeholder
/// colour; if it cannot load, the same square with a mark.
struct MediaThumb: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                MediaLook.placeholder
            case .failed:
                MediaLook.placeholder.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.footnote)
                        .foregroundStyle(MediaLook.ink2)
                }
            }
        }
        .frame(width: MediaLook.rowLead, height: MediaLook.rowLead)
        .clipShape(.rect(cornerRadius: MediaLook.leadRadius))
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. No box and no line: the pictures divide the rows.
struct MediaRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: MediaLook.rowLead, height: MediaLook.rowLead)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(MediaLook.rowStrong)
                    .foregroundStyle(MediaLook.ink)
                if let detail {
                    Text(detail)
                        .font(MediaLook.detail)
                        .foregroundStyle(MediaLook.ink2)
                }
            }
            Spacer(minLength: 8)
            end
        }
        .frame(maxWidth: .infinity, minHeight: MediaLook.rowMin)
        .contentShape(.rect)
    }
}

/// A group's head, heavier than a row.
struct MediaGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .font(MediaLook.head)
            .foregroundStyle(MediaLook.ink)
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
    }
}

/// A person: their photograph, else their initial on the placeholder colour,
/// else a dashed ring for nobody yet. Smaller than a picture, and round, so
/// a person is never taken for one.
struct MediaPersonMark<Photo: View>: View {
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
                    .font(MediaLook.rowStrong)
                    .foregroundStyle(MediaLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(MediaLook.placeholder, in: .circle)
            } else {
                Circle().strokeBorder(MediaLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: 44, height: 44)
    }
}

extension MediaPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct MediaLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(9)
            .frame(width: 44, height: 44)
            .background(MediaLook.logoPlate, in: .rect(cornerRadius: MediaLook.leadRadius))
            .overlay {
                RoundedRectangle(cornerRadius: MediaLook.leadRadius).strokeBorder(MediaLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a shelf with nothing on it: frames with no pictures in
/// them, in the placeholder colour.
struct MediaEmptyFrames: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            frame(width: 58, height: 78)
            frame(width: 84, height: 58)
            frame(width: 46, height: 46)
        }
    }

    private func frame(width: Double, height: Double) -> some View {
        RoundedRectangle(cornerRadius: MediaLook.leadRadius)
            .fill(MediaLook.placeholder)
            .frame(width: width, height: height)
            .overlay {
                RoundedRectangle(cornerRadius: MediaLook.leadRadius).strokeBorder(MediaLook.rule, lineWidth: 1)
            }
    }
}

// MARK: Controls

/// The main button off the pictures: ink. Busy, its words change and the
/// fill lightens. Off, it is the placeholder colour.
struct MediaMainButtonStyle: ButtonStyle {
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
                .foregroundStyle(isEnabled ? MediaLook.ground : MediaLook.ink2)
                .padding(.horizontal, 24)
                .frame(maxWidth: isWide ? .infinity : nil, minHeight: MediaLook.buttonMin)
                .background(isEnabled ? MediaLook.ink.opacity(isBusy ? 0.72 : 1) : MediaLook.placeholder, in: .rect(cornerRadius: 25))
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.rect(cornerRadius: 25))
        }
    }
}

/// The second kind of button off the pictures: underlined words in ink.
struct MediaTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(MediaLook.ink)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// A text field: large words on a line, like a title waiting to be written.
/// In use the line is two points of ink. An error is a mark and a reason
/// under the line, in ink.
struct MediaField: View {
    let name: String
    @Binding var text: String
    var prompt = ""
    var error: String?
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(MediaLook.ink2))
                .font(MediaLook.head)
                .foregroundStyle(MediaLook.ink)
                .tint(MediaLook.ink)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .frame(minHeight: 48)
            Rectangle()
                .fill(isFocused ? MediaLook.ink : MediaLook.ink2)
                .frame(height: isFocused ? 2 : 1)
            if let error {
                Label(error, systemImage: "nosign")
                    .font(MediaLook.detail)
                    .foregroundStyle(MediaLook.ink)
                    .padding(.top, 6)
            }
        }
    }
}

/// A row that has not arrived.
struct MediaGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: MediaLook.leadRadius).fill(MediaLook.placeholder)
                .frame(width: MediaLook.rowLead, height: MediaLook.rowLead)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).fill(MediaLook.placeholder).frame(width: 150, height: 12)
                RoundedRectangle(cornerRadius: 4).fill(MediaLook.placeholder).frame(width: 90, height: 8)
            }
            Spacer()
        }
        .frame(minHeight: MediaLook.rowMin)
    }
}
