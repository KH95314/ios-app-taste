import SwiftUI

// Direction 12 Focused Utility: the rest of the look's parts.
// `FocusLook.swift` has the colours, the tool key and the notice. This file
// adds what a second and a third screen need.
//
// One rule runs through all of it: everything is a line of monospaced text.
// A mark in second ink at the start of a line says what the line is, as "#"
// says a heading in the draft. Controls are keys. The caret's blue is used
// for the caret and for nothing else.

extension FocusLook {
    // Type roles. All monospaced, because the page is.
    static let line = Font.system(.body, design: .monospaced)
    static let lineStrong = Font.system(.body, design: .monospaced, weight: .semibold)
    static let leadLine = Font.system(.title3, design: .monospaced, weight: .semibold)
    static let figure = Font.system(.footnote, design: .monospaced)
    static let keyLabel = Font.system(.body, design: .monospaced, weight: .semibold)
    static let emptyTitle = Font.system(.title3, design: .monospaced, weight: .semibold)

    // Sizes.
    static let margin = 20.0
    static let rowMin = 48.0
    static let buttonMin = 48.0
    static let groupGap = 28.0
    /// The room a line's mark takes, so that the words of every line start
    /// at the same edge, whatever the mark is.
    static let rowLead = 28.0
    static let keyRadius = 10.0

    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xECEDEE)

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ink on key
    // contrast: ink2 on key
}

// MARK: Content parts

/// One line: a mark in second ink, the words, and a figure at its end. The
/// line that leads a screen is a step larger and heavier. No box, no rule:
/// lines of text need none.
struct FocusLine<Mark: View, End: View>: View {
    let words: String
    var isLead = false
    var isQuiet = false
    @ViewBuilder var mark: Mark
    @ViewBuilder var end: End

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            mark
                .font(isLead ? FocusLook.leadLine : FocusLook.line)
                .foregroundStyle(FocusLook.ink2)
                .frame(width: FocusLook.rowLead, alignment: .leading)
            Text(words)
                .font(isLead ? FocusLook.leadLine : FocusLook.line)
                .foregroundStyle(isQuiet ? FocusLook.ink2 : FocusLook.ink)
            Spacer(minLength: 12)
            end
                .font(FocusLook.figure)
                .foregroundStyle(FocusLook.ink2)
        }
        .frame(maxWidth: .infinity, minHeight: FocusLook.rowMin)
        .contentShape(.rect)
    }
}

/// A group's head, written as a comment in the draft would be.
struct FocusGroupHead: View {
    let title: String

    var body: some View {
        Text("// \(title)")
            .font(FocusLook.figure)
            .foregroundStyle(FocusLook.ink2)
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
    }
}

/// A picture: a plain rectangle with small corners, as an attachment on a
/// page of text. Waiting, it is the key colour; if it cannot load, the same
/// rectangle with a mark.
struct FocusPicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                Color.clear.overlay { picture.resizable().scaledToFill() }
            case .waiting:
                FocusLook.key
            case .failed:
                FocusLook.key.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(FocusLook.ink2)
                }
            }
        }
        .aspectRatio(16.0 / 9, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 6))
    }
}

/// A person, small enough to sit in a line's mark column: their photograph,
/// else their initial on a key, else a dashed ring for nobody yet.
struct FocusPersonMark<Photo: View>: View {
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
                    .font(.system(.caption2, design: .monospaced, weight: .semibold))
                    .foregroundStyle(FocusLook.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(FocusLook.key, in: .circle)
            } else {
                Circle().strokeBorder(FocusLook.ink2, style: StrokeStyle(lineWidth: 1.2, dash: [2.5, 2.5]))
            }
        }
        .frame(width: 20, height: 20)
        .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 4 }
    }
}

extension FocusPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on, the size of a line's mark.
struct FocusLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(3)
            .frame(width: 20, height: 20)
            .background(FocusLook.logoPlate, in: .rect(cornerRadius: 5))
            .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 4 }
    }
}

/// The picture for a list with nothing in it: an empty page with a caret
/// waiting on its first line. The caret is the one place the hue appears.
struct FocusEmptyPage: View {
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Text("#")
                .font(FocusLook.leadLine)
                .foregroundStyle(FocusLook.ink2)
            RoundedRectangle(cornerRadius: 1).fill(FocusLook.caret).frame(width: 2.5, height: 26)
        }
    }
}

// MARK: Controls

/// The main action: a wide key filled with ink. Busy, its words change and
/// it turns to the key colour. Off, it is the key colour with quiet words.
struct FocusMainKeyStyle: ButtonStyle {
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
            let isFull = isEnabled && !isBusy
            label
                .font(FocusLook.keyLabel)
                .foregroundStyle(isFull ? FocusLook.ground : isEnabled ? FocusLook.ink : FocusLook.ink2)
                .frame(maxWidth: .infinity, minHeight: FocusLook.buttonMin)
                .background(isFull ? FocusLook.ink : FocusLook.key, in: .rect(cornerRadius: FocusLook.keyRadius))
                .opacity(isPressed ? 0.6 : 1)
                .contentShape(.rect)
        }
    }
}

/// The second kind of button: words in square brackets, as a link is
/// written in the draft.
struct FocusBracketButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            Text("[").foregroundStyle(FocusLook.ink2)
            configuration.label.foregroundStyle(FocusLook.ink)
            Text("]").foregroundStyle(FocusLook.ink2)
        }
        .font(FocusLook.lineStrong)
        .frame(minHeight: 44)
        .contentShape(.rect)
        .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// One of a few: a row of keys, the chosen one filled with ink.
struct FocusKeys: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
                    .buttonStyle(FocusKeyStyle(isOn: option == selection))
                    .font(FocusLook.keyLabel)
            }
        }
        .padding(.horizontal, -3)
    }
}

/// A text field: a line of the page, with its mark at the start and the
/// caret in it. An error is a line under it that starts with "!" in ink.
struct FocusField: View {
    let mark: String
    let name: String
    @Binding var text: String
    var prompt = ""
    var error: String?
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(mark)
                    .foregroundStyle(FocusLook.ink2)
                    .frame(width: FocusLook.rowLead, alignment: .leading)
                TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(FocusLook.ink2))
                    .foregroundStyle(FocusLook.ink)
                    .tint(FocusLook.caret)
                    .focused($isFocused)
                    .onSubmit(onSubmit)
            }
            .font(FocusLook.leadLine)
            .frame(minHeight: FocusLook.rowMin)
            Rectangle()
                .fill(isFocused ? FocusLook.ink : FocusLook.rule)
                .frame(height: isFocused ? 2 : 1)
            if let error {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("!").frame(width: FocusLook.rowLead, alignment: .leading)
                    Text(error)
                }
                .font(FocusLook.figure)
                .foregroundStyle(FocusLook.ink)
                .padding(.top, 8)
            }
        }
    }
}

/// A line that has not arrived.
struct FocusGhostLine: View {
    var width = 200.0

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2).fill(FocusLook.key).frame(width: 12, height: 12)
                .frame(width: FocusLook.rowLead, alignment: .leading)
            RoundedRectangle(cornerRadius: 2).fill(FocusLook.key).frame(width: width, height: 12)
            Spacer()
        }
        .frame(minHeight: FocusLook.rowMin)
    }
}
