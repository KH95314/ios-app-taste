import SwiftUI

// Direction 01 Quiet Native Minimalism: the look every pattern in this direction shares.
//
// The ground is the system background and nothing sits in its own box. There
// is one hue, and it only ever appears on things people can act on. Hierarchy
// comes from weight, and groups are separated by a hairline and a gap.

enum QuietLook {
    /// The screen. It is the system's own background, in light and in dark.
    static let ground = Color(.systemBackground)
    /// Titles and row names: the system's own label colour.
    static let ink = Color.primary
    /// The one hue: ticks, buttons, links. Pick it for the product; this green
    /// belongs to the sample. Set it once with `.tint(QuietLook.accent)`.
    static let accent = Color(light: 0x0B7A62, dark: 0x3DD6AE)
    /// Text and icons drawn on top of `accent`.
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x00241B)
    /// Second-level text. The system's secondary label is about 3.4:1 on
    /// white, too faint for the 13 pt detail lines this direction relies on.
    static let ink2 = Color(light: 0x5C5F66, dark: 0xA3A7AE)
    /// Marks that are not text, such as an empty tick.
    static let mark = Color(light: 0x8E9199, dark: 0x6E727A)
    /// The hairline between groups.
    static let rule = Color(light: 0xE3E4E8, dark: 0x2A2B2F)
    /// The one filled box in this direction: a notice that something is wrong.
    static let fill = Color(light: 0xF1F2F4, dark: 0x1B1C1F)
    /// The one alert colour: the word "Overdue", and the reason under a field
    /// that was filled in wrongly. Always an icon with words. It never tints
    /// a row or a field.
    static let late = Color(light: 0xC5221F, dark: 0xFF7A70)
    /// The small tile behind another company's logo, so that the logo keeps
    /// its own colours in light and in dark.
    static let plate = Color(light: 0xFFFFFF, dark: 0xF2F3F5)

    // Type roles. One face, the system's; the order comes from weight.
    static let title = Font.largeTitle.bold()
    static let dateNumeral = Font.title.bold()
    static let heading = Font.title3.weight(.semibold)
    static let row = Font.body
    static let detail = Font.footnote
    static let button = Font.headline
    static let secondButton = Font.subheadline.weight(.semibold)
    static let initial = Font.caption.weight(.semibold)
    static let emptyTitle = Font.title2.bold()

    // Sizes that repeat.
    static let margin = 16.0
    static let rowMin = 44.0
    static let buttonMin = 50.0
    static let groupGap = 28.0
    static let dateDisc = 34.0
    static let person = 26.0
    /// What starts a row, whatever it is: a person, a logo, the app's mark.
    /// One width, so that every name on the screen starts at the same edge.
    static let rowLead = 32.0
    static let picture = 64.0
    static let pictureCorner = 8.0
    static let tile = 28.0
    static let tileCorner = 7.0
    static let noticeCorner = 12.0

    // contrast: onAccent on accent
    // contrast: ink2 on fill
    // contrast: late on fill
    // contrast: mark on fill 0
}

/// The filled call to action. The label colour is set here, next to the fill,
/// so the pair is chosen together for both appearances.
/// Off, it is the look's fill with second-ink words. While its action runs it
/// keeps its fill and its words change: dimming an accent fill took the label
/// to 3.1:1.
struct QuietFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Face(isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(QuietLook.button)
                .foregroundStyle(isEnabled ? QuietLook.onAccent : QuietLook.ink2)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(minHeight: QuietLook.buttonMin)
                .background(isEnabled ? QuietLook.accent : QuietLook.fill, in: .rect(cornerRadius: 25))
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.rect(cornerRadius: 25))
        }
    }
}

/// What failed, what it means for the person, and a retry. It sits above the
/// last good content and never replaces it.
struct QuietNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // The icon is part of the sentence, in the text colour. In this
            // direction the hue is kept for things people can act on.
            Text("\(Image(systemName: "wifi.slash")) \(title)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(QuietLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(.borderless)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 12)
        .background(QuietLook.fill, in: .rect(cornerRadius: 12))
    }
}
