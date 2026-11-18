import SwiftUI

// Direction 11 Layered Surfaces: the look every pattern in this direction shares.
//
// The picture underneath (a map, a photo, a camera view) keeps the colour.
// The surface on top is the system sheet, and its main action is ink rather
// than a hue, so the sheet never competes with what it sits on.

enum LayerLook {
    static let ink = Color(light: 0x0F1012, dark: 0xF5F6F7)
    static let ink2 = Color(light: 0x585B62, dark: 0xA4A8AF)
    static let rule = Color(light: 0xE4E5E8, dark: 0x2E3035)

    /// The main action's fill and the label on it.
    static let action = Color(light: 0x0F1012, dark: 0xF5F6F7)
    static let onAction = Color(light: 0xFFFFFF, dark: 0x0F1012)
    /// The fill of a second action and of small round controls.
    static let control = Color(light: 0xECEDEF, dark: 0x2A2C30)

    /// A pin's hue belongs to the subject: water here. `pinOff` marks a point
    /// that is not usable, and it always comes with a different glyph.
    static let pin = Color(light: 0x0B74C4, dark: 0x2F95E8)
    static let pinOff = Color(light: 0x6B6F77, dark: 0x8B9099)

    static let ok = Color(light: 0x0F6B45, dark: 0x7BE3B0)
    static let okTint = Color(light: 0xDFF3E8, dark: 0x143524)
    static let warn = Color(light: 0x7A4A00, dark: 0xFFC56B)
    static let warnTint = Color(light: 0xFFE9C2, dark: 0x3A2A0C)
}

/// The sheet's two buttons. The main one is filled with ink; a second one,
/// when there is room for it, takes the quiet control fill.
struct LayerButtonStyle: ButtonStyle {
    enum Kind { case main, second }

    let kind: Kind
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(kind == .main ? LayerLook.onAction : LayerLook.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .background(kind == .main ? LayerLook.action : LayerLook.control, in: .rect(cornerRadius: 25))
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.45)
            .contentShape(.rect(cornerRadius: 25))
    }
}

/// A short status: an icon, the state in words, and a tint. Three signals, so
/// it never depends on colour alone.
struct StatusBadge: View {
    enum Tone { case ok, warning }

    let text: String
    let tone: Tone

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: tone == .ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            Text(text)
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundStyle(tone == .ok ? LayerLook.ok : LayerLook.warn)
        .padding(.vertical, 5)
        .padding(.leading, 8)
        .padding(.trailing, 12)
        .background(tone == .ok ? LayerLook.okTint : LayerLook.warnTint, in: .rect(cornerRadius: 14))
    }
}
