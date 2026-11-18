import SwiftUI

// Direction 07 Immersive Environment: the look every pattern in this direction shares.
//
// A scene fills the screen and is the data. Words sit straight on it, with no
// cards, and only where it is dark enough. The scene follows its own time of
// day, so these colours are the same in the light and dark appearances.

enum SceneLook {
    /// Values, words and marks on the scene. Solid.
    static let on = Color(fixed: 0xFFFFFF)
    /// Small capital labels on the scene. Solid, never a dimmed white.
    static let on2 = Color(fixed: 0xD3E3EA)
    /// The lightest the scene may be behind text. White is 6.4:1 on it and
    /// the label colour 4.9:1. Keep words off anything lighter than this.
    static let floor = Color(fixed: 0x1B6680)
    /// Words on a white control.
    static let ink = Color(fixed: 0x0E2A36)

    /// Side margin of the words on the scene.
    static let margin = 24.0

    /// A colour between two others, each written as 0xRRGGBB. The scene uses
    /// it to move from night to day without a second set of artwork.
    static func mix(_ from: UInt32, _ to: UInt32, _ amount: Double) -> Color {
        let t = min(max(amount, 0), 1)
        func channel(_ shift: UInt32) -> Double {
            let a = Double((from >> shift) & 0xFF), b = Double((to >> shift) & 0xFF)
            return (a + (b - a) * t) / 255
        }
        return Color(red: channel(16), green: channel(8), blue: channel(0))
    }
}

extension View {
    /// Place, time and row labels: a few words in capitals.
    func sceneLabel() -> some View {
        font(.caption)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(SceneLook.on2)
    }
}

/// The one filled button: white, with dark words. It is for the few moments
/// when the scene has nothing to show yet.
struct SceneFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(SceneLook.ink)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .background(SceneLook.on, in: .capsule)
            .contentShape(.capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
