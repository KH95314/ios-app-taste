import SwiftUI
import UIKit

// The one look both sides of every pair use. A pair is about one rule, not
// about a direction, so this look is as quiet as it can be. The two sides
// share its colours, type and parts, and differ only in the failure the rule
// names. No colour, effect or style is ever what makes a side bad: a gradient,
// a glow, glass and cards are all open to a look of your own.

extension Color {
    /// Both appearances of one colour, chosen together.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat(value >> 16 & 0xFF) / 255, green: CGFloat(value >> 8 & 0xFF) / 255,
                           blue: CGFloat(value & 0xFF) / 255, alpha: 1)
        })
    }
}

enum PairLook {
    static let ground = Color(light: 0xF6F5F1, dark: 0x121311)
    static let ink = Color(light: 0x15181A, dark: 0xF1F2EE)
    static let quiet = Color(light: 0x596066, dark: 0xA4ABA9)
    static let rule = Color(light: 0xDEDCD4, dark: 0x2A2D2B)
    /// Only on what can be pressed.
    static let accent = Color(light: 0x0B5FA5, dark: 0x7DB9F0)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x06243F)
    /// A failure or a refusal, always with an icon and words.
    static let failed = Color(light: 0xA6311F, dark: 0xFF9A85)

    // contrast: ink on ground
    // contrast: quiet on ground
    // contrast: accent on ground
    // contrast: onAccent on accent
    // contrast: failed on ground
    // contrast: rule on ground 0

    static let margin: CGFloat = 20
    static let rowGap: CGFloat = 12
    static let groupGap: CGFloat = 28
    static let corner: CGFloat = 12
    static let hit: CGFloat = 44

    static let figure = Font.system(size: 52, weight: .semibold, design: .rounded)
    static let title = Font.title2.weight(.semibold)
    static let body = Font.body
    static let strong = Font.body.weight(.semibold)
    static let small = Font.subheadline
    static let head = Font.footnote.weight(.semibold)
    /// The smallest text: what stands under a column, and small print.
    static let note = Font.caption
}

/// The one filled button a screen has.
struct PairMainButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PairLook.strong)
            .foregroundStyle(PairLook.onAccent)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(PairLook.accent.opacity(configuration.isPressed ? 0.8 : 1), in: .rect(cornerRadius: PairLook.corner))
    }
}

/// A head over a group of rows.
struct PairHead: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(PairLook.head)
            .kerning(0.6)
            .foregroundStyle(PairLook.quiet)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, PairLook.rowGap)
    }
}

/// A row between hairlines: a name, a quiet line under it, and something at its end.
struct PairRow<Trailing: View>: View {
    let name: String
    let detail: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: PairLook.rowGap) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name).font(PairLook.body).foregroundStyle(PairLook.ink)
                    if !detail.isEmpty { Text(detail).font(PairLook.small).foregroundStyle(PairLook.quiet) }
                }
                Spacer(minLength: PairLook.rowGap)
                trailing
            }
            .padding(.vertical, PairLook.rowGap)
            Rectangle().fill(PairLook.rule).frame(height: 1)
        }
    }
}

/// The page every good side sits on.
struct PairPage<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { content }
                .padding(.horizontal, PairLook.margin)
                .padding(.top, PairLook.margin)
        }
        .background(PairLook.ground)
    }
}
