import SwiftUI

// Direction 06 Dark Professional: the look every pattern in this direction shares.
//
// The screen is black in both appearances, so the work is the only large
// bright thing on it. Values are monospaced under small capital labels. One
// hue marks what is being adjusted, and red means recording and nothing else.

enum ProLook {
    static let ground = Color(fixed: 0x000000)
    /// The control panel under the work area.
    static let panel = Color(fixed: 0x131416)
    static let rule = Color(fixed: 0x2B2D31)
    static let ink = Color(fixed: 0xF2F3F4)
    /// Labels over values, scale figures, unavailable controls.
    static let ink2 = Color(fixed: 0x9C9FA6)
    /// The value being adjusted, its mark on the ruler, the playhead.
    static let accent = Color(fixed: 0xD2F03A)
    static let onAccent = Color(fixed: 0x101200)
    /// Recording, and a clipped level. Always with a word or a shape.
    static let live = Color(fixed: 0xFF453A)
    /// Unlit meter segments and the edge of an unavailable control.
    static let track = Color(fixed: 0x3A3D42)
}

extension View {
    /// The label over a value: one or two words in small capitals.
    func proLabel() -> some View {
        font(.caption2)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .tracking(1.2)
    }

    /// A setting or reading, in monospaced figures.
    func proValue() -> some View {
        font(.system(.body, design: .monospaced, weight: .semibold))
    }
}

/// A label over its value.
struct ProReadout: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .proLabel()
                .foregroundStyle(ProLook.ink2)
            Text(value)
                .proValue()
                .foregroundStyle(ProLook.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// A control beside the main one: an outlined capsule with an icon and a
/// word. Unavailable, it keeps its place and goes quiet.
struct ProSideButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Face(isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isEnabled ? ProLook.ink : ProLook.ink2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .frame(minWidth: 92, maxWidth: .infinity, minHeight: 48)
                .overlay {
                    Capsule().strokeBorder(isEnabled ? ProLook.ink2 : ProLook.track, lineWidth: 1.5)
                }
                .contentShape(.capsule)
                .opacity(isPressed ? 0.6 : 1)
        }
    }
}

/// The one filled button: the way out of a problem. It takes the accent
/// because, at that moment, it is the thing to adjust.
struct ProAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(ProLook.onAccent)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(ProLook.accent, in: .capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(.capsule)
    }
}
