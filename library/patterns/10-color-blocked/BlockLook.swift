import SwiftUI

// Direction 10 Color-Blocked Structure: the look every pattern in this direction shares.
//
// The screen is plain and the blocks are the only colour on it. A block's
// fill is its category. Every control is ink, so a control is never mistaken
// for a category and a category never looks like a button.

enum BlockLook {
    static let ground = Color(light: 0xFFFFFF, dark: 0x000000)
    /// Titles, done rows, and every control.
    static let ink = Color(light: 0x111214, dark: 0xF4F5F6)
    /// Start times and other small text.
    static let ink2 = Color(light: 0x5A5D63, dark: 0xA3A7AD)
    static let rule = Color(light: 0xE2E3E6, dark: 0x2A2C30)
    /// A break, a notice, a placeholder: neutral, because none is a category.
    static let rest = Color(light: 0xF1F2F4, dark: 0x1B1C1F)

    // The sample's four categories. The fills are the same in both
    // appearances and deep enough for white text at 4.5:1 or better
    // (measured: 5.0, 5.4, 6.3, 6.3). Choose your own, five at most, and
    // check the text on each one.
    static let feed = Color(fixed: 0xC2460E)
    static let walk = Color(fixed: 0x167A3E)
    static let clean = Color(fixed: 0x1F55D6)
    static let care = Color(fixed: 0xB42060)
    /// Text, icons and the now line on any category fill. Always solid: a
    /// dimmed white passes on one fill and fails on the next.
    static let onBlock = Color(fixed: 0xFFFFFF)

    static let radius = 20.0
    /// Small, so the day reads as one stack.
    static let gap = 4.0
}

/// The filled call to action, in ink.
struct BlockInkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(BlockLook.ground)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .background(BlockLook.ink, in: .capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(.capsule)
    }
}

/// A second action as underlined ink text.
struct BlockTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(BlockLook.ink)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// What failed and what is on screen instead, as one neutral block above the
/// day. It takes the shape of a block and none of the category colours.
struct BlockNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: "wifi.slash")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(BlockLook.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(BlockLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(BlockTextButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 12)
        .background(BlockLook.rest, in: .rect(cornerRadius: BlockLook.radius))
    }
}
