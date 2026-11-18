import SwiftUI

// Direction 09 Metric Hero: the look every pattern in this direction shares.
//
// One coloured plate holds the number, and the plate's fill is the state.
// Everything outside the plate is neutral, so the plate is the only colour on
// the screen.

enum MetricLook {
    static let ground = Color(light: 0xF2F3F5, dark: 0x0B0C0E)
    static let ink = Color(light: 0x0E0F11, dark: 0xF4F5F6)
    static let ink2 = Color(light: 0x565A61, dark: 0xA1A6AD)
    static let rule = Color(light: 0xDADDE1, dark: 0x26282C)

    /// A plate's fill and the single colour drawn on it. Text on a plate is
    /// never dimmed with opacity: the fill changes, so a dimmed colour would
    /// pass contrast on one plate and fail on the next.
    struct Plate {
        let fill: Color
        let on: Color
    }

    // The state plates are the same in both appearances. The fill is the
    // message, so it does not dim with the rest of the screen.
    static let fresh = Plate(fill: Color(fixed: 0x7CCFF5), on: Color(fixed: 0x12100A))
    static let stuffy = Plate(fill: Color(fixed: 0xF5A623), on: Color(fixed: 0x12100A))
    static let poor = Plate(fill: Color(fixed: 0xB3261E), on: Color(fixed: 0xFFFFFF))
    /// No current reading: a grey plate that makes no claim about the state.
    static let idle = Plate(
        fill: Color(light: 0xDFE2E6, dark: 0x1E2023),
        on: Color(light: 0x565A61, dark: 0xA1A6AD))
}

extension View {
    /// The short label in capitals above the number and above a group. Keep
    /// it to a few words: capitals are slow to read in a sentence.
    func metricLabel() -> some View {
        font(.caption)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .tracking(1)
    }
}

/// A full-width button filled with one colour and labelled in another. On a
/// plate the pair is the plate's own two colours swapped, so the button needs
/// no third colour.
struct InkButtonStyle: ButtonStyle {
    let fill: Color
    let label: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(label)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(fill, in: .rect(cornerRadius: 26))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(.rect(cornerRadius: 26))
    }
}

/// What failed, what to check, and a retry, set straight on the ground. It
/// has no box, because the plate is the only filled shape on the screen.
struct MetricNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: "wifi.slash")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(MetricLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.semibold)
                .underline()
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
