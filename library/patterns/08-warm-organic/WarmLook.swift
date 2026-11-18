import SwiftUI

// Direction 08 Warm Organic: the look every pattern in this direction shares.
//
// A drawn picture leads and does work: something in it changes with progress.
// The picture has its own palette and is the same in light and dark; the page
// under it changes. Titles are serif. One clay hue is for actions.

enum WarmLook {
    /// The page under the picture.
    static let ground = Color(light: 0xFBF3E4, dark: 0x1F1712)
    /// The quiet pill.
    static let surface = Color(light: 0xFFFFFF, dark: 0x2D231C)
    static let ink = Color(light: 0x2B1D14, dark: 0xF6EBDD)
    static let ink2 = Color(light: 0x6F5B4B, dark: 0xC2B09E)
    /// The main button, text buttons and the current step: the deep tone of
    /// the clay in the picture.
    static let accent = Color(light: 0xB5471B, dark: 0xF09464)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x2A1408)

    // The picture's palette. Fixed, because the picture does not change with
    // the appearance.
    /// The field behind the picture.
    static let clay = Color(fixed: 0xD9652E)
    /// The counter that things stand on.
    static let clay2 = Color(fixed: 0xB8501F)
    static let sun = Color(fixed: 0xF6C453)
    /// Plants. Put it over `sun` or `cream`; on `clay` it sinks.
    static let leaf = Color(fixed: 0x3F6B4A)
    /// The thing that changes, and anything that sits on the picture.
    static let cream = Color(fixed: 0xFFF3DC)
    /// The mark for done, and words on `cream`.
    static let berry = Color(fixed: 0x8E2F2F)

    static let margin = 24.0
}

/// The main button: clay, fully rounded.
struct WarmFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(WarmLook.onAccent)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(WarmLook.accent, in: .capsule)
            .contentShape(.capsule)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

/// A small quiet pill, for a nudge that sits beside the thing it changes.
struct WarmPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .monospacedDigit()
            .foregroundStyle(WarmLook.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 40)
            .background(WarmLook.surface, in: .capsule)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// A button that is only words, in the clay hue.
struct WarmTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(WarmLook.accent)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// A round control that sits on the picture: cream, with a berry glyph. Both
/// are from the picture's palette, so it reads in light and dark alike.
struct WarmDiscFace: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.headline)
            .foregroundStyle(WarmLook.berry)
            .frame(width: 44, height: 44)
            .background(WarmLook.cream, in: .circle)
            .contentShape(.circle)
    }
}
