import SwiftUI

// Direction 02 Editorial Reading: the rest of the look's parts.
// `ReadingLook.swift` has the colours, the kicker, the running text, the link
// button, the notice and the progress line. This file adds what a second and
// a third screen need.
//
// One rule runs through all of it: type does the work. A thing is told from
// its neighbour by its face and size, not by a box. A title is serif and a
// control is sans, so nothing needs a fill to look pressable: the one hue and
// an underline say so.

extension ReadingLook {
    // Type roles. Titles and anything to be read are serif; the interface is sans.
    static let pageTitle = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let leadTitle = Font.system(.title, design: .serif, weight: .bold)
    static let rowTitle = Font.system(.title3, design: .serif, weight: .semibold)
    static let byline = Font.footnote
    static let name = Font.system(.body, design: .serif)
    static let action = Font.body.weight(.semibold)
    static let emptyTitle = Font.system(.title2, design: .serif, weight: .bold)
    static let field = Font.system(.title3, design: .serif)

    // Sizes.
    static let margin = 20.0
    static let rowMin = 64.0
    static let buttonMin = 48.0
    static let groupGap = 32.0
    /// What starts a row, whatever it is. One width, so names line up.
    static let rowLead = 40.0
    static let pictureRadius = 4.0

    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF1ECE2)

    // contrast: ink on paper
    // contrast: ink2 on paper
    // contrast: accent on paper
    // contrast: ink2 on rule 3
}

// MARK: Content parts

/// A picture at its own shape, with square-ish corners, as on a printed page.
/// Waiting, the frame is there in the rule colour, so the text under it does
/// not move when the picture comes.
struct ReadingPicture: View {
    let form: PictureForm
    /// Width over height.
    var shape = 1.5

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                Color.clear.overlay { picture.resizable().scaledToFill() }
            case .waiting:
                ReadingLook.rule
            case .failed:
                ReadingLook.rule.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(ReadingLook.ink2)
                }
            }
        }
        .aspectRatio(shape, contentMode: .fit)
        .clipShape(.rect(cornerRadius: ReadingLook.pictureRadius))
    }
}

/// The story that leads a page: its picture if it has one, the section in
/// capitals, a serif title, and one line for who wrote it and how long it is.
struct ReadingLead: View {
    let kicker: String
    let title: String
    let byline: String
    var picture: PictureForm?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let picture {
                ReadingPicture(form: picture)
                    .padding(.bottom, 16)
            }
            Text(kicker).readingKicker()
            Text(title)
                .font(ReadingLook.leadTitle)
                .foregroundStyle(ReadingLook.ink)
                .padding(.top, 4)
            Text(byline)
                .font(ReadingLook.byline)
                .foregroundStyle(ReadingLook.ink2)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A story in a list: a serif title, one quiet line, and something at its
/// end. A hairline above and no box.
struct ReadingStoryRow<End: View>: View {
    let title: String
    let byline: String
    @ViewBuilder var end: End

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(ReadingLook.rowTitle)
                    .foregroundStyle(ReadingLook.ink)
                Text(byline)
                    .font(ReadingLook.byline)
                    .foregroundStyle(ReadingLook.ink2)
            }
            Spacer(minLength: 8)
            end
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: ReadingLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(ReadingLook.rule).frame(height: 1)
        }
        .contentShape(.rect)
    }
}

/// A row for a person or a company: something at its start, a serif name,
/// and something at its end.
struct ReadingNameRow<Lead: View, End: View>: View {
    let name: String
    var isQuiet = false
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: ReadingLook.rowLead, alignment: .leading)
            Text(name)
                .font(ReadingLook.name)
                .foregroundStyle(isQuiet ? ReadingLook.ink2 : ReadingLook.ink)
            Spacer(minLength: 8)
            end
        }
        .frame(maxWidth: .infinity, minHeight: 56)
        .contentShape(.rect)
    }
}

/// A group's head: a few words in capitals over a hairline.
struct ReadingGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .readingKicker()
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle().fill(ReadingLook.ink).frame(height: 1)
            }
    }
}

/// A person: their photograph, else their initial in serif on the rule
/// colour, else a dashed ring for nobody yet.
struct ReadingPersonMark<Photo: View>: View {
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
                    .font(ReadingLook.name)
                    .foregroundStyle(ReadingLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ReadingLook.rule, in: .circle)
            } else {
                Circle().strokeBorder(ReadingLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: ReadingLook.rowLead, height: ReadingLook.rowLead)
    }
}

extension ReadingPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct ReadingLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(7)
            .frame(width: ReadingLook.rowLead, height: ReadingLook.rowLead)
            .background(ReadingLook.logoPlate, in: .rect(cornerRadius: ReadingLook.pictureRadius))
            .overlay {
                RoundedRectangle(cornerRadius: ReadingLook.pictureRadius).strokeBorder(ReadingLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a list with nothing in it: a page with no words on it
/// yet, drawn as fading lines of text.
struct ReadingEmptyPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            RoundedRectangle(cornerRadius: 2).fill(ReadingLook.ink2).frame(width: 96, height: 7)
            ForEach(Array([150.0, 138, 146, 90].enumerated()), id: \.offset) { index, width in
                RoundedRectangle(cornerRadius: 2).fill(ReadingLook.rule).frame(width: width, height: 5)
                    .opacity(1 - Double(index) * 0.2)
            }
        }
        .frame(width: 150, alignment: .leading)
    }
}

// MARK: Controls

/// The main action. This look has no filled button, so the main action is a
/// link a size larger: the hue and an underline. Busy, its words change and
/// the underline goes. Off, it is second ink with no underline.
struct ReadingActionStyle: ButtonStyle {
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
                .font(ReadingLook.action)
                .underline(isEnabled && !isBusy)
                .foregroundStyle(isEnabled && !isBusy ? ReadingLook.accent : ReadingLook.ink2)
                .frame(minHeight: ReadingLook.buttonMin)
                .contentShape(.rect)
                .opacity(isPressed ? 0.6 : 1)
        }
    }
}

/// One of a few: rows in serif, with a tick in the hue at the end of the
/// chosen one.
struct ReadingChoiceRow: View {
    let name: String
    let isChosen: Bool
    let choose: () -> Void

    var body: some View {
        Button(action: choose) {
            HStack {
                Text(name)
                    .font(ReadingLook.name)
                    .foregroundStyle(ReadingLook.ink)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                if isChosen {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(ReadingLook.accent)
                }
            }
            .frame(minHeight: 48)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

/// A text field: serif words on a line, like a line waiting to be written.
/// In use the line is two points of ink. An error is a mark and a reason
/// under the line in ink: the hue here means a link.
struct ReadingField: View {
    let name: String
    @Binding var text: String
    var prompt = ""
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(ReadingLook.ink2), axis: .vertical)
                .font(ReadingLook.field)
                .foregroundStyle(ReadingLook.ink)
                .tint(ReadingLook.accent)
                .lineLimit(1...4)
                .focused($isFocused)
                .padding(.vertical, 10)
                .frame(minHeight: 48)
            Rectangle()
                .fill(isFocused ? ReadingLook.ink : ReadingLook.ink2)
                .frame(height: isFocused ? 2 : 1)
            if let error {
                Label(error, systemImage: "nosign")
                    .font(ReadingLook.byline)
                    .foregroundStyle(ReadingLook.ink)
                    .padding(.top, 6)
            }
        }
    }
}

/// A story that has not arrived: its lines in the rule colour.
struct ReadingGhostRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            RoundedRectangle(cornerRadius: 3).fill(ReadingLook.rule).frame(width: 230, height: 14)
            RoundedRectangle(cornerRadius: 3).fill(ReadingLook.rule).frame(width: 120, height: 8)
        }
        .frame(maxWidth: .infinity, minHeight: ReadingLook.rowMin, alignment: .leading)
        .overlay(alignment: .top) {
            Rectangle().fill(ReadingLook.rule).frame(height: 1)
        }
    }
}
