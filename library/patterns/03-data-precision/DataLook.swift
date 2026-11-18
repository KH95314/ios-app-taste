import SwiftUI

// Direction 03 Data Precision: the look every pattern in this direction shares.
//
// Figures sit in aligned rows straight on the ground, between hairlines.
// Colour is kept for a state someone can rely on or must act on, and it always
// comes with an icon and a word. A figure that only moved stays ink.

enum DataLook {
    static let ground = Color(light: 0xF5F6F8, dark: 0x0B0D10)
    /// Figures, row names, and every control.
    static let ink = Color(light: 0x101216, dark: 0xF1F3F5)
    /// Units, heads, comparisons, the time of the data, quiet chart bars.
    static let ink2 = Color(light: 0x575C66, dark: 0x9BA1AC)
    static let rule = Color(light: 0xDEE1E6, dark: 0x24272D)
    // Each state colour holds 4.5:1 on the ground in both appearances
    // (measured: 5.0, 5.9, 6.0 in light; 11.2, 11.7, 7.7 in dark).
    static let ok = Color(light: 0x0A7A3D, dark: 0x4ADE80)
    static let warn = Color(light: 0x8A5300, dark: 0xFBBF24)
    static let bad = Color(light: 0xB3261E, dark: 0xFF7B6E)

    /// The small tile behind another company's logo, so that the logo keeps
    /// its own colours in light and in dark. Never a state colour.
    static let plate = Color(light: 0xFFFFFF, dark: 0xF1F3F5)

    // Type roles. Figures are monospaced and words are not: that is the
    // look's second voice.
    static let stateFont = Font.title.bold()
    static let largeFigure = Font.system(.largeTitle, design: .monospaced, weight: .semibold)
    /// A figure under the one that leads: a step smaller, so one thing is largest.
    static let gridFigure = Font.system(.title2, design: .monospaced, weight: .semibold)
    static let figure = Font.system(.body, design: .monospaced, weight: .semibold)
    /// Words in a row that carry a state.
    static let strong = Font.body.weight(.semibold)
    /// The unit beside a large figure.
    static let unit = Font.subheadline.weight(.semibold)
    /// The unit beside a figure in a row.
    static let rowUnit = Font.footnote.weight(.semibold)
    static let code = Font.system(.caption, design: .monospaced, weight: .semibold)
    static let comparison = Font.footnote
    /// When the data is from, and a field's error.
    static let meta = Font.footnote.weight(.medium)
    static let chip = Font.footnote.weight(.semibold)
    static let emptyTitle = Font.title2.bold()

    // Sizes that repeat.
    static let margin = 16.0
    static let rowMin = 48.0
    static let buttonMin = 50.0
    static let tile = 28.0
    /// The room a row's logo or code takes, so that names line up under each other.
    static let leadWidth = 32.0
    static let tileCorner = 7.0
    static let pictureSize = CGSize(width: 96, height: 64)
    static let pictureCorner = 6.0
    static let person = 32.0
    /// How much of a state's colour the top of the screen takes when someone
    /// must act. At 0.14 the small line under the state still holds 4.9:1.
    static let wash = 0.14

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ok on ground
    // contrast: warn on ground
    // contrast: bad on ground
    // contrast: ground on ink
    // contrast: rule on ground 0
}

/// A state. Its colour never appears without its icon, and each icon has its
/// own outline so the three can be told apart in greyscale.
enum DataState: Equatable {
    case ok, warn, bad

    var color: Color {
        switch self {
        case .ok: DataLook.ok
        case .warn: DataLook.warn
        case .bad: DataLook.bad
        }
    }

    var symbol: String {
        switch self {
        case .ok: "checkmark.circle.fill"
        case .warn: "exclamationmark.triangle.fill"
        case .bad: "xmark.octagon.fill"
        }
    }
}

extension View {
    /// Section and column heads: a few words in capitals.
    func dataHead() -> some View {
        font(.caption)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(DataLook.ink2)
    }
}

/// One figure: its name at the left, the figure right-aligned in tabular
/// digits, and the comparison under the figure. When the two do not fit side
/// by side, the figure moves under the name.
struct DataRow: View {
    let name: String
    let figure: String
    var comparison: String?
    var state: DataState?
    /// For a list of things with long names: the name breaks onto a second
    /// line beside its figure, and the figure keeps its place at the right.
    var nameWraps = false
    /// For a figure nobody has to act on: second ink at regular weight, so
    /// that the one figure that matters is the only strong one on the screen.
    var isQuiet = false

    var body: some View {
        Group {
            if nameWraps {
                HStack(alignment: .center, spacing: 12) {
                    nameText
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 12)
                    value(alignment: .trailing)
                        .fixedSize()
                }
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 12) {
                        nameText
                        Spacer(minLength: 12)
                        value(alignment: .trailing)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        nameText
                        value(alignment: .leading)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .overlay(alignment: .top) {
            Rectangle().fill(DataLook.rule).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var nameText: some View {
        Text(name)
            .foregroundStyle(DataLook.ink)
    }

    private func value(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            Group {
                if let state {
                    Label(figure, systemImage: state.symbol)
                } else {
                    Text(figure)
                }
            }
            .fontWeight(isQuiet ? .regular : .semibold)
            .monospacedDigit()
            .foregroundStyle(state?.color ?? (isQuiet ? DataLook.ink2 : DataLook.ink))
            if let comparison {
                // Words with a unit, not a bare percentage.
                Text(comparison)
                    .font(.footnote)
                    .foregroundStyle(state?.color ?? DataLook.ink2)
            }
        }
        .multilineTextAlignment(alignment == .trailing ? .trailing : .leading)
    }
}

/// A range chip. The selected one is ink. The filled part is shorter than the
/// tap area.
struct DataChipStyle: ButtonStyle {
    let isOn: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .fontWeight(.semibold)
            .monospacedDigit()
            .foregroundStyle(isOn ? DataLook.ground : DataLook.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(isOn ? DataLook.ink : .clear, in: .capsule)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// The filled call to action, in ink. While the action is in progress the
/// fill lightens and the words stay whole.
struct DataInkButtonStyle: ButtonStyle {
    var isBusy = false

    func makeBody(configuration: Configuration) -> some View {
        Face(isBusy: isBusy, isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isBusy: Bool
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(.headline)
                .foregroundStyle(isEnabled ? DataLook.ground : DataLook.ink2)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(minHeight: DataLook.buttonMin)
                .background(isEnabled ? DataLook.ink.opacity(isBusy ? 0.72 : 1) : DataLook.rule, in: .capsule)
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.capsule)
        }
    }
}

/// The one action of a sheet: ink, as wide as the sheet. Its words change
/// with the state of the action, and it is never swapped for another button.
/// While the action is in progress the fill lightens and the words stay whole.
struct DataWideButtonStyle: ButtonStyle {
    var isBusy = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(DataLook.ground)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(DataLook.ink.opacity(isBusy ? 0.72 : 1), in: .rect(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(.rect(cornerRadius: 12))
    }
}

/// A row that opens something. It shows no hue and no chevron: where every
/// row opens, a mark on each says nothing. It dims while it is pressed.
struct DataRowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// A head over a group of rows.
struct DataGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .dataHead()
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
            .padding(.top, 12)
    }
}

/// What is wrong, in one row above the figures, with a retry at its end.
struct DataNotice: View {
    let title: String
    let retry: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                label
                Spacer(minLength: 12)
                button
            }
            VStack(alignment: .leading, spacing: 0) {
                label
                button
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DataLook.rule).frame(height: 1)
        }
    }

    private var label: some View {
        Label(title, systemImage: "wifi.slash")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(DataLook.ink)
    }

    private var button: some View {
        Button("Try again", action: retry)
            .buttonStyle(.plain)
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(DataLook.ink)
            .frame(minHeight: 44)
    }
}
