import SwiftUI
import UIKit

/// The states every library screen has to render. An entry is not finished
/// until all of them are designed, not only `loaded`.
enum Phase<Value> {
    case loading
    case empty
    case loaded(Value)
    /// `stale` is the last good value. When there is one, keep showing it and
    /// explain the failure beside it instead of replacing the screen.
    case failed(message: String, stale: Value?)
}

/// `ContentUnavailableView` does not scroll, so at the largest text sizes on a
/// small phone its actions fall off the screen. This keeps the content centred
/// when it fits and lets it scroll when it doesn't.
struct ScrollsIfNeeded<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ViewThatFits(in: .vertical) {
            content
            ScrollView { content }
        }
    }
}

extension UIColor {
    /// One colour with a light and a dark value, each written as 0xRRGGBB.
    nonisolated convenience init(light: UInt32, dark: UInt32) {
        self.init { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1)
        }
    }
}

extension Color {
    /// One colour with a light and a dark value, each written as 0xRRGGBB.
    /// Every direction defines its colours this way, so both appearances are
    /// chosen together and checked for contrast as a pair.
    nonisolated init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor(light: light, dark: dark))
    }

    /// A colour that is the same in both appearances.
    nonisolated init(fixed hex: UInt32) {
        self.init(light: hex, dark: hex)
    }
}

/// The forms a picture takes. It arrives late and sometimes never, so a screen
/// draws all three, and each look draws them in its own shapes
/// (`../../references/pictures.md`).
enum PictureForm {
    case loaded(Image)
    case waiting
    case failed
}

extension Image {
    /// One of the free pictures in `library/pictures`, by its file name
    /// without ".jpg". `CREDITS.md` in that folder says where each came from.
    static func sample(_ name: String) -> Image {
        if let picture = UIImage(named: "\(name).jpg") {
            return Image(uiImage: picture)
        }
        return Image(systemName: "photo")
    }
}
