import SwiftUI

// Direction 02 Editorial Reading: the look every pattern in this direction shares.
//
// The page is warm paper and the text is serif. Type does the work: nothing
// is boxed, one hue marks links, and the tools leave while someone is reading.

enum ReadingLook {
    /// The page. Warm in both appearances, never pure white or pure black.
    static let paper = Color(light: 0xFAF6EE, dark: 0x16130F)
    /// Title and running text.
    static let ink = Color(light: 0x211D18, dark: 0xE9E3D8)
    /// Kicker, byline, time left, notice text.
    static let ink2 = Color(light: 0x6A6157, dark: 0xA59C8E)
    /// Hairlines, the line beside a quotation, the track of the progress line.
    static let rule = Color(light: 0xE4DCCD, dark: 0x2D2822)
    /// Fill behind highlighted words. The words keep `ink`.
    static let mark = Color(light: 0xFFE38F, dark: 0x4D3F10)
    /// Underline of a highlight. The fill alone is under 3:1 on the page, so
    /// this line is what lets someone find a highlight again.
    static let markLine = Color(light: 0x9A7400, dark: 0xD9B23A)
    /// Links and text buttons. The only hue besides the highlight.
    static let accent = Color(light: 0x9B3A16, dark: 0xF0A27C)
}

extension View {
    /// The publication or section above a title: a few words in capitals.
    func readingKicker() -> some View {
        font(.caption)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(ReadingLook.ink2)
    }
}

/// Running text: serif, one step larger than interface text, with open
/// leading. `scale` is the reader's own adjustment on top of the system text
/// size, so both are respected.
struct ReadingText: ViewModifier {
    var scale = 1.0
    var isItalic = false
    @ScaledMetric(relativeTo: .title3) private var leading = 7.0

    func body(content: Content) -> some View {
        content
            .font(.system(.title3, design: .serif).scaled(by: scale))
            .italic(isItalic)
            .lineSpacing(leading * scale)
            .foregroundStyle(ReadingLook.ink)
    }
}

/// A button that reads as a link: the hue, an underline, and a full-height
/// tap area. This direction has no filled buttons.
struct ReadingLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(ReadingLook.accent)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// What is wrong and what the reader is looking at instead, above the text
/// and closed by a hairline. It is not boxed, and the text under it stays.
struct ReadingNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(Image(systemName: "wifi.slash")) \(title)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(ReadingLook.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(ReadingLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(ReadingLinkButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(ReadingLook.rule).frame(height: 1)
        }
    }
}

/// How far through the text the reader is: a 2 pt line that is always there,
/// and the time left, which shows only with the other tools.
struct ReadingBar: View {
    let progress: Double
    let timeLeft: String?
    @Environment(\.layoutDirection) private var direction

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ReadingLook.rule)
                .frame(height: 2)
                .overlay {
                    Rectangle()
                        .fill(ReadingLook.ink)
                        .scaleEffect(x: progress, anchor: direction == .rightToLeft ? .trailing : .leading)
                }
            if let timeLeft {
                Text(timeLeft)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(ReadingLook.ink2)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .background(ReadingLook.paper)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reading progress")
        .accessibilityValue(Text(progress, format: .percent.precision(.fractionLength(0))))
    }
}
