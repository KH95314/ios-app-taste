import SwiftUI

// Direction 14 Media-Led Experience: the look every pattern in this direction shares.
//
// The ground is white in light and black in dark, and the pictures are the
// only colour. Text set on a picture is solid white over a scrim. Controls
// are black or white and never borrow a colour from a picture.

enum MediaLook {
    static let ground = Color(light: 0xFFFFFF, dark: 0x000000)
    /// Titles off the pictures, and every control.
    static let ink = Color(light: 0x111214, dark: 0xF4F5F6)
    /// The line of facts under a title.
    static let ink2 = Color(light: 0x5B5E64, dark: 0xA2A6AD)
    /// Outline of an unselected chip.
    static let rule = Color(light: 0xE3E4E7, dark: 0x26282C)
    /// Where a picture will be, until it loads or if it cannot.
    static let placeholder = Color(light: 0xE9EAEC, dark: 0x1C1D20)
    /// Text on a picture. Solid, never dimmed.
    static let onPicture = Color(fixed: 0xFFFFFF)
    /// The badge on a picture, and the action on a picture.
    static let badge = Color(fixed: 0xFFFFFF)
    static let onBadge = Color(fixed: 0x111214)

    /// How dark the scrim is behind text. At 66% black, white text holds
    /// 7:1 even on a white picture.
    static let scrim = Color.black.opacity(0.66)

    static let pictureRadius = 14.0
    static let gap = 12.0
}

/// One fact on the corner of a picture: new, how many are left, or that it
/// is yours. The shadow lets it show on a white picture.
struct MediaBadge: View {
    let text: String
    var systemImage: String?

    var body: some View {
        Group {
            if let systemImage {
                Label(text, systemImage: systemImage)
            } else {
                Text(text)
            }
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(MediaLook.onBadge)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        // On one line this is a pill. When large text wraps it, the same
        // radius gives a rounded box instead of a blob.
        .background(MediaLook.badge, in: .rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.28), radius: 2, y: 1)
    }
}

/// A filter chip. The chosen one is ink.
struct MediaChipStyle: ButtonStyle {
    let isOn: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(isOn ? MediaLook.ground : MediaLook.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 36)
            .background {
                if isOn {
                    Capsule().fill(MediaLook.ink)
                } else {
                    Capsule().strokeBorder(MediaLook.rule, lineWidth: 1)
                }
            }
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// The action on a picture: a white pill, or a white outline for the way
/// back. The same in light and dark, because the picture is.
struct MediaOnPictureButtonStyle: ButtonStyle {
    var isOutline = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(isOutline ? MediaLook.onPicture : MediaLook.onBadge)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .frame(minHeight: 48)
            .background {
                if isOutline {
                    RoundedRectangle(cornerRadius: 24).strokeBorder(MediaLook.onPicture, lineWidth: 1.5)
                } else {
                    RoundedRectangle(cornerRadius: 24).fill(MediaLook.badge)
                }
            }
            .contentShape(.rect(cornerRadius: 24))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// The filled call to action off the pictures, in ink.
struct MediaInkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(MediaLook.ground)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .background(MediaLook.ink, in: .rect(cornerRadius: 25))
            .contentShape(.rect(cornerRadius: 25))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// What is wrong, set straight on the ground above the pictures.
struct MediaNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: "wifi.slash")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(MediaLook.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(MediaLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.semibold)
                .underline()
                .foregroundStyle(MediaLook.ink)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
