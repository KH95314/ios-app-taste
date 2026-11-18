import SwiftUI

// Direction 06 Dark Professional: the rest of the look's parts.
// `ProLook.swift` has the colours, the label and value styles, the readout,
// the side button and the accent button. This file adds what a second and a
// third screen need.
//
// One rule runs through all of it: a value is monospaced under a small label
// in capitals, and the one hue marks the single thing that is selected or
// being adjusted. Nothing else is lit. Red means recording and is not used
// on these screens at all.

extension ProLook {
    // Type roles.
    static let title = Font.system(.title2, design: .monospaced, weight: .semibold)
    static let row = Font.system(.body, design: .monospaced)
    static let rowStrong = Font.system(.body, design: .monospaced, weight: .semibold)
    static let figure = Font.system(.subheadline, design: .monospaced, weight: .semibold)
    static let detail = Font.footnote
    static let button = Font.subheadline.weight(.semibold)
    static let emptyTitle = Font.title3.weight(.semibold)

    // Sizes.
    static let margin = 16.0
    static let rowMin = 52.0
    static let buttonMin = 52.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is. One width, so names line up.
    static let rowLead = 36.0
    static let leadRadius = 6.0

    /// The tile another company's logo sits on: light, on a black screen.
    static let logoPlate = Color(fixed: 0xF2F3F4)

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ink on panel
    // contrast: ink2 on panel
    // contrast: onAccent on accent
    // contrast: accent on ground
    // contrast: ink2 on track 3
}

// MARK: Content parts

/// The shape of a take's sound: bars from the middle line. Up to `played`
/// they are ink, and the rest are quiet, with the playhead in the one hue.
struct ProWave: View {
    /// Values from 0 to 1, oldest first.
    let levels: [Double]
    var played = 1.0
    var isQuiet = false

    var body: some View {
        Canvas { context, size in
            guard !levels.isEmpty else { return }
            let step = size.width / Double(levels.count)
            for (index, level) in levels.enumerated() {
                let height = max(2, level * size.height)
                let bar = CGRect(x: Double(index) * step + 0.75, y: (size.height - height) / 2, width: max(1, step - 1.5), height: height)
                let isPlayed = Double(index) / Double(levels.count) < played
                context.fill(Path(roundedRect: bar, cornerRadius: 1), with: .color(isQuiet ? ProLook.track : isPlayed ? ProLook.ink : ProLook.ink2))
            }
            if !isQuiet, played < 1 {
                let x = size.width * played
                context.fill(Path(CGRect(x: x - 1, y: 0, width: 2, height: size.height)), with: .color(ProLook.accent))
            }
        }
    }
}

/// A row: something at its start, a monospaced name, a figure at its end.
/// The selected row's name and figure take the hue, and it has a bar of the
/// hue at its leading edge. A hairline above, no box.
struct ProRow<Lead: View, End: View>: View {
    let name: String
    var isSelected = false
    var isQuiet = false
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: ProLook.rowLead, alignment: .leading)
            Text(name)
                .font(isSelected ? ProLook.rowStrong : ProLook.row)
                .foregroundStyle(isSelected ? ProLook.accent : isQuiet ? ProLook.ink2 : ProLook.ink)
                .lineLimit(1)
            Spacer(minLength: 8)
            end
                .font(ProLook.figure)
                .foregroundStyle(isSelected ? ProLook.accent : ProLook.ink2)
        }
        .frame(maxWidth: .infinity, minHeight: ProLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(ProLook.rule).frame(height: 1)
        }
        .contentShape(.rect)
    }
}

/// A group's head: one or two words in small capitals.
struct ProGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .proLabel()
            .foregroundStyle(ProLook.ink2)
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
    }
}

/// A picture: a square with small corners. Waiting, it is the track colour;
/// if it cannot load, the same square with a mark.
struct ProPicture: View {
    let form: PictureForm
    var size = 72.0

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                ProLook.track
            case .failed:
                ProLook.track.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.footnote)
                        .foregroundStyle(ProLook.ink2)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: ProLook.leadRadius))
    }
}

/// A glyph in an outlined square, for a row whose thing has no picture.
struct ProGlyphTile: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(ProLook.ink2)
            .frame(width: ProLook.rowLead, height: ProLook.rowLead)
            .overlay {
                RoundedRectangle(cornerRadius: ProLook.leadRadius).strokeBorder(ProLook.track, lineWidth: 1.5)
            }
    }
}

/// A person: their photograph, else their initials in monospace in a ring,
/// else a dashed ring for nobody yet.
struct ProPersonMark<Photo: View>: View {
    private let initials: String?
    private let photo: Photo?

    init(photo: Photo) {
        self.photo = photo
        self.initials = nil
    }

    var body: some View {
        Group {
            if let photo {
                photo.clipShape(.circle)
            } else if let initials {
                Text(initials)
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(ProLook.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay { Circle().strokeBorder(ProLook.ink2, lineWidth: 1.5) }
            } else {
                Circle().strokeBorder(ProLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: ProLook.rowLead, height: ProLook.rowLead)
    }
}

extension ProPersonMark where Photo == EmptyView {
    /// With no photograph: initials, or `nil` for nobody yet.
    init(initials: String?) {
        self.photo = nil
        self.initials = initials
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct ProLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(6)
            .frame(width: ProLook.rowLead, height: ProLook.rowLead)
            .background(ProLook.logoPlate, in: .rect(cornerRadius: ProLook.leadRadius))
    }
}

// MARK: Controls

/// The main action of a sheet: filled with the hue, because at that moment
/// it is the thing to adjust. Busy, its words change and the fill dims to
/// the track with ink words. Off, it is an outline in the track colour.
struct ProMainButtonStyle: ButtonStyle {
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
                .font(ProLook.button)
                .foregroundStyle(!isEnabled ? ProLook.ink2 : isBusy ? ProLook.ink : ProLook.onAccent)
                .frame(maxWidth: .infinity, minHeight: ProLook.buttonMin)
                .background {
                    if !isEnabled {
                        Capsule().strokeBorder(ProLook.track, lineWidth: 1.5)
                    } else {
                        Capsule().fill(isBusy ? ProLook.track : ProLook.accent)
                    }
                }
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.capsule)
        }
    }
}

/// The second kind of button: underlined words in ink.
struct ProTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ProLook.button)
            .underline()
            .foregroundStyle(ProLook.ink)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// One of a few: outlined keys in a row. The chosen one is filled with the
/// hue, as the one thing being set.
struct ProKeys: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Text(option)
                        .font(ProLook.figure)
                        .foregroundStyle(option == selection ? ProLook.onAccent : ProLook.ink)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background {
                            if option == selection {
                                RoundedRectangle(cornerRadius: 8).fill(ProLook.accent)
                            } else {
                                RoundedRectangle(cornerRadius: 8).strokeBorder(ProLook.track, lineWidth: 1.5)
                            }
                        }
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// A text field: its label in small capitals, the text in monospace on a
/// line. In use the line is two points of the hue. An error is a mark and a
/// reason under the line in ink: red here means recording.
struct ProField: View {
    let label: String
    @Binding var text: String
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .proLabel()
                .foregroundStyle(ProLook.ink2)
            TextField(label, text: $text)
                .font(ProLook.title)
                .foregroundStyle(ProLook.ink)
                .tint(ProLook.accent)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isFocused)
                .frame(minHeight: 48)
            Rectangle()
                .fill(isFocused ? ProLook.accent : ProLook.ink2)
                .frame(height: isFocused ? 2 : 1)
            if let error {
                Label(error, systemImage: "nosign")
                    .font(ProLook.detail)
                    .foregroundStyle(ProLook.ink)
                    .padding(.top, 6)
            }
        }
    }
}

/// What is wrong, as one row on the panel with a retry at its end.
struct ProNotice: View {
    let title: String
    let retry: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: "wifi.slash")
                .font(ProLook.button)
                .foregroundStyle(ProLook.ink)
            Spacer(minLength: 8)
            Button("Try again", action: retry)
                .buttonStyle(ProTextButtonStyle())
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 48)
        .background(ProLook.panel, in: .rect(cornerRadius: 8))
    }
}

/// A row that has not arrived.
struct ProGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: ProLook.leadRadius).fill(ProLook.panel)
                .frame(width: ProLook.rowLead, height: ProLook.rowLead)
            RoundedRectangle(cornerRadius: 3).fill(ProLook.panel).frame(width: 130, height: 12)
            Spacer()
            RoundedRectangle(cornerRadius: 3).fill(ProLook.panel).frame(width: 48, height: 12)
        }
        .frame(minHeight: ProLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(ProLook.rule).frame(height: 1)
        }
    }
}
