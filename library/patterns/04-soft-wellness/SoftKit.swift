import SwiftUI

// Direction 04 Soft Wellness: the rest of the look's parts. `SoftLook.swift`
// has the colours, the ground, the level mark, the buttons and the notice.
// This file adds what a second and a third screen need.
//
// One rule runs through all of it: the one hue means "yours" and never good
// or bad. It is the level mark, a ring filled from the bottom, large where it
// leads a screen and small where it starts a row; the chosen one of a few;
// and the main button. A failure and an error are said in ink, with no red.
// Nothing has a square corner or a hairline: things are set apart by a
// surface and by room.

extension SoftLook {
    // Type roles. Every one is in the rounded design.
    static let leadWord = Font.system(.largeTitle, design: .rounded, weight: .semibold)
    static let row = Font.system(.body, design: .rounded)
    static let rowStrong = Font.system(.body, design: .rounded, weight: .semibold)
    /// The words of one of a few: a little larger than a row's.
    static let choice = Font.system(.title3, design: .rounded, weight: .medium)
    /// Times, a group's head, and a row's one quiet line.
    static let detail = Font.system(.subheadline, design: .rounded, weight: .medium)
    static let button = Font.system(.headline, design: .rounded)
    static let emptyTitle = Font.system(.title2, design: .rounded, weight: .semibold)

    // Sizes.
    static let margin = 20.0
    /// Room inside a surface. With the margin it makes the one edge every
    /// name, head and field starts from.
    static let inset = 16.0
    static let rowMin = 52.0
    static let choiceMin = 60.0
    static let buttonMin = 56.0
    static let groupGap = 24.0
    /// What starts a row, whatever it is: a level mark, a person, a logo,
    /// the app's mark. One width, so every name starts at the same edge.
    static let rowLead = 36.0
    static let leadRadius = 12.0
    /// The level mark that leads a screen.
    static let leadMark = 96.0

    /// What has not arrived, and what holds no hue: a ghost's shapes, a
    /// waiting picture, the disc behind an initial.
    static let hush = Color(light: 0xE9E6F1, dark: 0x302D3A)
    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF4F5F6)

    // contrast: ink on ground
    // contrast: ink on ground2
    // contrast: ink on surface
    // contrast: ink2 on ground
    // contrast: ink2 on ground2
    // contrast: ink2 on surface
    // contrast: ink2 on hush
    // contrast: accent on surface
    // contrast: accent on tint
    // contrast: onAccent on accent
}

// MARK: Content parts

/// What leads a screen: one answer, as the level mark at its largest, its
/// word, and one quiet line. Centred, with nothing round it but the ground.
struct SoftLead: View {
    let level: Int
    let word: String
    var detail: String?

    var body: some View {
        VStack(spacing: 0) {
            SoftLevelMark(level: level, lineWidth: 6)
                .frame(width: SoftLook.leadMark, height: SoftLook.leadMark)
            Text(word)
                .font(SoftLook.leadWord)
                .foregroundStyle(SoftLook.ink)
                .padding(.top, 16)
            if let detail {
                Text(detail)
                    .font(SoftLook.row)
                    .foregroundStyle(SoftLook.ink2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// The small level mark that starts a row: the lead's mark, carried down.
struct SoftRowMark: View {
    let level: Int

    var body: some View {
        SoftLevelMark(level: level, lineWidth: 2.5)
            .frame(width: SoftLook.rowLead, height: SoftLook.rowLead)
    }
}

/// A group: its rows on one surface. Rows are set apart by room, not lines.
struct SoftGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(.horizontal, SoftLook.inset)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SoftLook.surface, in: .rect(cornerRadius: SoftLook.radius))
    }
}

/// A group's head: a few quiet words. Only for a group that needs a name.
struct SoftGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .font(SoftLook.detail)
            .foregroundStyle(SoftLook.ink2)
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. No line above or below.
struct SoftRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: SoftLook.rowLead)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(SoftLook.row)
                    .foregroundStyle(SoftLook.ink)
                if let detail {
                    Text(detail)
                        .font(SoftLook.detail)
                        .monospacedDigit()
                        .foregroundStyle(SoftLook.ink2)
                }
            }
            Spacer(minLength: 8)
            end
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: SoftLook.rowMin)
        .contentShape(.rect)
    }
}

/// A picture someone kept with an answer. With no `shape` it is a small
/// rounded square at a row's end; with one it runs as wide as its place, at
/// that shape before the picture comes, so nothing moves. Waiting, it is the
/// quiet fill; if it cannot load, the fill keeps a mark. With no picture at
/// all the square holds a glyph for what is there instead.
struct SoftPicture: View {
    let form: PictureForm?
    /// Width over height, for the wide form.
    var shape: Double?
    var symbol = "note.text"

    var body: some View {
        if let shape {
            Color.clear
                .aspectRatio(shape, contentMode: .fit)
                .overlay { content }
                .clipShape(.rect(cornerRadius: SoftLook.radius))
        } else {
            content
                .frame(width: SoftLook.rowLead, height: SoftLook.rowLead)
                .clipShape(.rect(cornerRadius: SoftLook.leadRadius))
        }
    }

    @ViewBuilder private var content: some View {
        switch form {
        case .loaded(let picture):
            picture.resizable().scaledToFill()
        case .waiting:
            SoftLook.hush
        case .failed:
            SoftLook.hush.overlay { glyph("photo.badge.exclamationmark") }
        case nil:
            SoftLook.hush.overlay { glyph(symbol) }
        }
    }

    private func glyph(_ name: String) -> some View {
        Image(systemName: name)
            .font(shape == nil ? .footnote : .title2)
            .foregroundStyle(SoftLook.ink2)
    }
}

/// A person: their photograph, else their initial on a quiet disc, else a
/// dashed ring for nobody yet. No hue: the hue is the diary owner's.
struct SoftPersonMark<Photo: View>: View {
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
                    .font(SoftLook.rowStrong)
                    .foregroundStyle(SoftLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(SoftLook.hush, in: .circle)
            } else {
                Circle().strokeBorder(SoftLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: SoftLook.rowLead, height: SoftLook.rowLead)
    }
}

extension SoftPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct SoftLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(6)
            .frame(width: SoftLook.rowLead, height: SoftLook.rowLead)
            .background(SoftLook.logoPlate, in: .rect(cornerRadius: SoftLook.leadRadius))
            .overlay {
                RoundedRectangle(cornerRadius: SoftLook.leadRadius).strokeBorder(SoftLook.hush, lineWidth: 1)
            }
    }
}

/// The app's own mark: a half-full ring on the hue. It belongs to the first
/// run and to the screen that gives the version, not to a bar.
struct SoftAppMark: View {
    var body: some View {
        Circle()
            .fill(SoftLook.onAccent)
            .mask(alignment: .bottom) {
                Rectangle().scaleEffect(y: 0.5, anchor: .bottom)
            }
            .overlay {
                Circle().strokeBorder(SoftLook.onAccent, lineWidth: 2)
            }
            .padding(8)
            .frame(width: SoftLook.rowLead, height: SoftLook.rowLead)
            .background(SoftLook.accent, in: .rect(cornerRadius: SoftLook.leadRadius))
    }
}

/// The picture for a screen with no answer yet: the ring, empty, in a soft
/// light of the hue with no edge.
struct SoftEmptyDrawing: View {
    var body: some View {
        ZStack {
            Circle().fill(SoftLook.tint).frame(width: 176, height: 176).blur(radius: 14)
            Circle().fill(SoftLook.glow).frame(width: 124, height: 124).blur(radius: 12)
            SoftLevelMark(level: 0, lineWidth: 6)
                .frame(width: SoftLook.leadMark, height: SoftLook.leadMark)
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: Controls

/// The main button: `SoftButtonStyle()` as the look draws it, with a busy
/// form. Busy, its words change and it takes the chosen row's fill with the
/// words in the hue. Off, it is a surface, as in the look.
struct SoftMainButtonStyle: ButtonStyle {
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
            HStack(spacing: 8) {
                if isBusy {
                    ProgressView().tint(SoftLook.accent)
                }
                label
            }
            .font(SoftLook.button)
            .foregroundStyle(!isEnabled ? SoftLook.ink2 : isBusy ? SoftLook.accent : SoftLook.onAccent)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: SoftLook.buttonMin)
            .background(
                !isEnabled ? SoftLook.surface : isBusy ? SoftLook.tint : SoftLook.accent,
                in: .rect(cornerRadius: SoftLook.buttonMin / 2))
            .contentShape(.rect(cornerRadius: SoftLook.buttonMin / 2))
            .opacity(isPressed ? 0.75 : 1)
        }
    }
}

/// A row or a picture that opens something dims while it is pressed.
struct SoftPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// One of a few: each choice is a surface of its own, of equal standing.
/// The chosen one takes the tint, a ring in the hue and a tick, whichever
/// it is. It may start with a mark.
struct SoftChoiceRow<Lead: View>: View {
    private let name: String
    private let isOn: Bool
    private let choose: () -> Void
    private let lead: Lead?

    init(name: String, isOn: Bool, choose: @escaping () -> Void, @ViewBuilder lead: () -> Lead) {
        self.name = name
        self.isOn = isOn
        self.choose = choose
        self.lead = lead()
    }

    var body: some View {
        Button(action: choose) {
            HStack(spacing: 12) {
                if let lead {
                    lead.frame(width: SoftLook.rowLead)
                }
                Text(name)
                    .font(SoftLook.choice)
                    .foregroundStyle(SoftLook.ink)
                Spacer(minLength: 8)
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.system(.footnote, weight: .bold))
                        .foregroundStyle(SoftLook.onAccent)
                        .frame(width: 28, height: 28)
                        .background(SoftLook.accent, in: .circle)
                }
            }
            .padding(.horizontal, SoftLook.inset)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: SoftLook.choiceMin, alignment: .leading)
            .background(isOn ? SoftLook.tint : SoftLook.surface, in: .rect(cornerRadius: SoftLook.radius))
            .overlay {
                if isOn {
                    RoundedRectangle(cornerRadius: SoftLook.radius).strokeBorder(SoftLook.accent, lineWidth: 2)
                }
            }
            .contentShape(.rect(cornerRadius: SoftLook.radius))
        }
        .buttonStyle(.plain)
    }
}

extension SoftChoiceRow where Lead == EmptyView {
    /// A choice that is only words.
    init(name: String, isOn: Bool, choose: @escaping () -> Void) {
        self.name = name
        self.isOn = isOn
        self.choose = choose
        self.lead = nil
    }
}

/// A field: a surface as round as the buttons. In use it takes the chosen
/// row's ring, in the hue. An error is a ring, a mark and the reason, all in
/// ink: a mistake in an address is not a bad answer, so it gets no red.
struct SoftField: View {
    let name: String
    @Binding var text: String
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(name, text: $text, prompt: Text(name).foregroundStyle(SoftLook.ink2))
                .font(SoftLook.row)
                .foregroundStyle(SoftLook.ink)
                .tint(SoftLook.accent)
                .focused($isFocused)
                .padding(.horizontal, SoftLook.inset)
                .frame(minHeight: SoftLook.buttonMin)
                .background(SoftLook.surface, in: .rect(cornerRadius: SoftLook.buttonMin / 2))
                .overlay {
                    if error != nil || isFocused {
                        RoundedRectangle(cornerRadius: SoftLook.buttonMin / 2)
                            .strokeBorder(error != nil ? SoftLook.ink : SoftLook.accent, lineWidth: 2)
                    }
                }
                .contentShape(.rect)
                .onTapGesture { isFocused = true }
            if let error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(SoftLook.detail)
                    .foregroundStyle(SoftLook.ink)
                    .padding(.horizontal, SoftLook.inset)
            }
        }
    }
}

/// The lead before it has arrived: its ring and its two lines, quiet.
struct SoftGhostLead: View {
    var body: some View {
        VStack(spacing: 0) {
            Circle().strokeBorder(SoftLook.hush, lineWidth: 6)
                .frame(width: SoftLook.leadMark, height: SoftLook.leadMark)
            Capsule().fill(SoftLook.hush).frame(width: 132, height: 26)
                .padding(.top, 24)
            Capsule().fill(SoftLook.hush).frame(width: 208, height: 12)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
    }
}

/// A row that has not arrived: its shapes, quiet.
struct SoftGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(SoftLook.hush)
                .frame(width: SoftLook.rowLead, height: SoftLook.rowLead)
            VStack(alignment: .leading, spacing: 8) {
                Capsule().fill(SoftLook.hush).frame(width: 84, height: 12)
                Capsule().fill(SoftLook.hush).frame(width: 56, height: 9)
            }
            Spacer()
        }
        .frame(minHeight: SoftLook.rowMin)
    }
}
