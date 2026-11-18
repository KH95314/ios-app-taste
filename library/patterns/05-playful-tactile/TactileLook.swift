import SwiftUI

// Direction 05 Playful & Tactile: the look every pattern in this direction shares.
//
// One loud ground. Anything that can be pressed has a lower edge and moves
// down when pressed, and nothing else has an edge except what a press
// produced. Type is the rounded design in heavy weights.

enum TactileLook {
    /// The screen: one loud colour in light, a deep one in dark.
    static let ground = Color(light: 0x5B34D6, dark: 0x1B1136)
    static let ink = Color(light: 0xFFFFFF, dark: 0xF3EDFF)
    /// Small labels and the outlines of empty slots.
    static let ink2 = Color(light: 0xDCD0FF, dark: 0xB9A9E6)
    /// The quieter panel that holds the stack or a notice.
    static let tray = Color(light: 0x4A27BD, dark: 0x2A1B57)
    /// A key, and a block earned by pressing one. Nothing decorative uses it.
    static let key = Color(fixed: 0xFFC531)
    static let keyEdge = Color(fixed: 0xB87A00)
    /// Labels and glyphs on either key fill.
    static let onKey = Color(fixed: 0x24114F)
    /// A second key, such as Undo.
    static let key2 = Color(light: 0xFFFFFF, dark: 0xF3EDFF)
    static let key2Edge = Color(light: 0xC3B2F5, dark: 0x9A86DE)

    /// Height of the lower edge. A pressed key travels this far.
    static let edge = 5.0
    /// How short and how tall a block in a stack may be.
    static let blockHeights = 18.0...47.0
    static let radius = 22.0
    /// The light stripe along the top of a bar's fill.
    static let shine = Color.white.opacity(0.6)
    /// The small tile behind another company's logo, so that the logo keeps
    /// its own colours. It has no lower edge: it cannot be pressed.
    static let plate = Color(light: 0xFFFFFF, dark: 0xF3EDFF)

    // Type roles. One face, the rounded design, in heavy weights. The count
    // is the second voice: the same face at twice the size of anything else.
    static let title = Font.system(.largeTitle, design: .rounded, weight: .heavy)
    static let keyLabel = Font.system(.title3, design: .rounded, weight: .bold)
    static let row = Font.system(.headline, design: .rounded)
    static let note = Font.system(.subheadline, design: .rounded, weight: .semibold)
    static let small = Font.system(.footnote, design: .rounded, weight: .bold)

    // Sizes that repeat.
    static let margin = 16.0
    static let keyMin = 59.0
    static let rowMin = 56.0
    static let tile = 34.0
    static let tileCorner = 10.0
    static let picture = 84.0
    static let person = 40.0

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ink on tray
    // contrast: ink2 on tray
    // contrast: onKey on key
    // contrast: onKey on key2
    // contrast: key on tray 3
    // contrast: key on ground 3
    // contrast: tray on ground 0
}

/// A key: a filled face over a darker lower edge. Pressed, the face moves
/// down onto the edge. With Reduce Motion on, the edge disappears and the
/// face stays where it is. Unavailable, the key is flat and quiet.
struct TactileKeyStyle: ButtonStyle {
    enum Kind { case main, second }
    var kind = Kind.main
    /// Keeps the key down: while its action runs, or when it is the chosen
    /// one of a few.
    var isHeld = false

    func makeBody(configuration: Configuration) -> some View {
        Face(kind: kind, isPressed: configuration.isPressed || isHeld, label: configuration.label)
    }

    private struct Face: View {
        let kind: Kind
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: TactileLook.radius)
            let isDown = isPressed && isEnabled
            label
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(isEnabled ? TactileLook.onKey : TactileLook.ink2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: 59)
                .background(fill, in: shape)
                .offset(y: isDown && !reduceMotion ? TactileLook.edge : 0)
                .background {
                    if isEnabled && !isDown {
                        shape.fill(edge).offset(y: TactileLook.edge)
                    }
                }
                .padding(.bottom, TactileLook.edge)
                .contentShape(.rect)
                .animation(reduceMotion ? nil : .snappy(duration: 0.1), value: isDown)
        }

        private var fill: Color {
            guard isEnabled else { return TactileLook.tray }
            return kind == .main ? TactileLook.key : TactileLook.key2
        }

        private var edge: Color {
            kind == .main ? TactileLook.keyEdge : TactileLook.key2Edge
        }
    }
}

/// A round control for the bar, drawn on a tray. The system's glass button
/// turned pale on this ground at some sizes and its white glyph was lost on
/// it, so the two bar buttons bring their own disc.
struct TactileDiscFace: View {
    let symbol: String
    @ScaledMetric(relativeTo: .headline) private var size = 44.0

    var body: some View {
        Image(systemName: symbol)
            .font(.system(.headline, weight: .bold))
            .foregroundStyle(TactileLook.ink)
            .frame(width: size, height: size)
            .background(TactileLook.tray, in: .circle)
            .contentShape(.circle)
    }
}

/// One earned block: the same fill and edge as the key that produced it.
struct TactileBlock: View {
    /// A fixed height, or nil to take what the stack can give, within
    /// `TactileLook.blockHeights`.
    var height: Double? = 47
    var symbol: String?
    /// Set a moment after the block is in place, so its mark hops once.
    @State private var hasSettled = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 16)
        shape
            .fill(TactileLook.key)
            .frame(
                minHeight: height ?? TactileLook.blockHeights.lowerBound,
                idealHeight: height ?? TactileLook.blockHeights.lowerBound,
                maxHeight: height ?? TactileLook.blockHeights.upperBound)
            .overlay {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(.body, weight: .bold))
                        .foregroundStyle(TactileLook.onKey)
                        .symbolEffect(.bounce.up, value: hasSettled)
                        .task {
                            try? await Task.sleep(for: .milliseconds(520))
                            hasSettled = true
                        }
                }
            }
            .background { shape.fill(TactileLook.keyEdge).offset(y: TactileLook.edge) }
            .padding(.bottom, TactileLook.edge)
    }
}

/// How a new block arrives: it falls from `distance` above its place. Give
/// it a bouncy animation and it lands with a little give.
struct TactileFall: Transition {
    var distance: Double

    func body(content: Content, phase: TransitionPhase) -> some View {
        content.offset(y: phase == .willAppear ? -distance : 0)
    }
}

/// The place a block will go: a dashed outline the size of a block.
struct TactileSlot: View {
    /// As for a block: fixed, or nil to stretch.
    var height: Double? = 47

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(TactileLook.ink2, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            .frame(
                minHeight: (height ?? TactileLook.blockHeights.lowerBound) + TactileLook.edge,
                idealHeight: (height ?? TactileLook.blockHeights.lowerBound) + TactileLook.edge,
                maxHeight: (height ?? TactileLook.blockHeights.upperBound) + TactileLook.edge)
    }
}

/// What is wrong, on a tray. No red: on this ground a warning colour would
/// fight the keys, so the icon and the words carry it.
struct TactileNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: "wifi.slash")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(TactileLook.ink)
            Text(message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(TactileLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.bold)
                .underline()
                .foregroundStyle(TactileLook.ink)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 12)
        .background(TactileLook.tray, in: .rect(cornerRadius: TactileLook.radius))
    }
}
