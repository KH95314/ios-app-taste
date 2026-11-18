import SwiftUI

// Direction 04 Soft Wellness: the look every pattern in this direction shares.
//
// The ground is a slow fade with no hard edge anywhere. There is one hue and
// it means "yours": the chosen row, the level marks, the main button. It never
// means good or bad, so a low answer looks as acceptable as a high one.

enum SoftLook {
    /// The top of the screen. It fades into `ground2`.
    static let ground = Color(light: 0xF3F1F8, dark: 0x16151C)
    /// The bottom of the screen: the warm end of the fade.
    static let ground2 = Color(light: 0xF8F1EC, dark: 0x1C1719)
    /// A choice, or a quiet button. Only a little lighter than the ground;
    /// the words carry it.
    static let surface = Color(light: 0xFFFFFF, dark: 0x24222C)
    static let ink = Color(light: 0x262331, dark: 0xF1EEF7)
    /// Times, comparisons and labels.
    static let ink2 = Color(light: 0x5F5A6E, dark: 0xB4AEC2)
    /// The one hue. There is no green for good and no red for bad.
    static let accent = Color(light: 0x4B55B5, dark: 0xAEB7FF)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x171A3D)
    /// Fill of the chosen row.
    static let tint = Color(light: 0xE4E7FA, dark: 0x2C3060)
    /// The light that gathers behind a saved answer: the hue, pale.
    static let glow = Color(light: 0xD4D9F8, dark: 0x343A78)

    /// Large and even. Nothing in this direction has a square corner.
    static let radius = 24.0

    static var backdrop: LinearGradient {
        LinearGradient(colors: [ground, ground2], startPoint: .top, endPoint: .bottom)
    }
}

/// The ground, alive. With `glow` at 0 it is the plain fade. As `glow` goes
/// to 1 a soft light in the hue gathers at `focus` and then drifts, slowly,
/// for as long as it is there. The light is the same for every answer.
struct SoftGround: View, Animatable {
    var glow = 0.0
    /// Where the light gathers, in the unit square.
    var focus = UnitPoint(x: 0.5, y: 0.28)

    var animatableData: Double {
        get { glow }
        set { glow = newValue }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: glow == 0)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            mesh(driftX: sin(time / 2.6) * 0.09, driftY: cos(time / 3.7) * 0.05)
        }
    }

    private func mesh(driftX: Double, driftY: Double) -> MeshGradient {
        let top = SoftLook.ground
        let bottom = SoftLook.ground2
        let middle = top.mix(with: bottom, by: 0.5)
        // With no glow the middle point sits at the centre in the middle
        // colour, which is the plain fade again.
        let x = 0.5 + (focus.x + driftX - 0.5) * glow
        let y = 0.5 + (focus.y + driftY - 0.5) * glow
        return MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [Float(x), Float(y)], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1],
            ],
            colors: [
                top, top, top,
                middle, middle.mix(with: SoftLook.glow, by: glow), middle,
                bottom, bottom, bottom,
            ])
    }
}

/// A level, drawn as a ring filled from the bottom. The height of the fill
/// shows the level; colour never does, so the levels are not ranked by hue.
struct SoftLevelMark: View {
    let level: Int
    var steps = 4
    var lineWidth = 2.0
    /// How much of the fill has arrived, 0 to 1. Animate it to pour the
    /// level in.
    var poured = 1.0

    var body: some View {
        Circle()
            .fill(SoftLook.accent)
            .mask(alignment: .bottom) {
                Rectangle().scaleEffect(y: Double(level) / Double(steps) * poured, anchor: .bottom)
            }
            .overlay {
                Circle().strokeBorder(SoftLook.accent, lineWidth: lineWidth)
            }
            .accessibilityHidden(true)
    }
}

/// The main button is the hue; the quiet one is a surface. Until there is
/// something to save, the main button looks like the quiet one.
struct SoftButtonStyle: ButtonStyle {
    enum Kind { case main, quiet }
    var kind = Kind.main

    func makeBody(configuration: Configuration) -> some View {
        Face(kind: kind, isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let kind: Kind
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            let isFilled = kind == .main && isEnabled
            label
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(isFilled ? SoftLook.onAccent : isEnabled ? SoftLook.ink : SoftLook.ink2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(isFilled ? SoftLook.accent : SoftLook.surface, in: .rect(cornerRadius: 28))
                .contentShape(.rect(cornerRadius: 28))
                .opacity(isPressed ? 0.75 : 1)
        }
    }
}

/// A button that is only words, in the hue.
struct SoftTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(SoftLook.accent)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// What went wrong and where the answer is, on a surface. No red: a failure
/// to sync is not the person's failure.
struct SoftNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: "wifi.slash")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(SoftLook.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(SoftLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(SoftTextButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 12)
        .background(SoftLook.surface, in: .rect(cornerRadius: SoftLook.radius))
    }
}
