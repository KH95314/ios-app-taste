import SwiftUI

// Direction 09 Metric Hero: the rest of the look's parts. `MetricLook.swift`
// has the colours, the plates, the label in capitals, the plate's button and
// the notice. This file adds what a second and a third screen need.
//
// One rule runs through all of it: a state's colour is always a filled plate
// with a number or a word on it, large or small. Nothing else has a hue.

extension MetricLook {
    // Type roles.
    static let title = Font.largeTitle.bold()
    /// The number on the plate that leads a screen.
    static let heroNumber = Font.largeTitle.scaled(by: 2.4).weight(.black)
    static let verdict = Font.title2.bold()
    static let unit = Font.headline
    static let row = Font.body
    static let rowStrong = Font.body.weight(.semibold)
    static let detail = Font.footnote
    /// The number on a small plate at the end of a row.
    static let chipNumber = Font.subheadline.weight(.bold)
    static let button = Font.headline
    static let emptyTitle = Font.title2.bold()
    static let fieldNumber = Font.system(.title, weight: .bold)

    // Sizes.
    static let margin = 16.0
    static let rowMin = 56.0
    static let buttonMin = 52.0
    static let plateRadius = 32.0
    static let chipRadius = 10.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is: a picture, a person, a logo, the
    /// app's mark. One width, so every name starts at the same edge.
    static let rowLead = 40.0
    static let leadRadius = 10.0

    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF4F5F6)

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: ink2 on rule 3
}

/// How a room's air is, as this look says it: a plate and a word.
enum MetricState: Equatable {
    case fresh, stuffy, poor, idle

    var plate: MetricLook.Plate {
        switch self {
        case .fresh: MetricLook.fresh
        case .stuffy: MetricLook.stuffy
        case .poor: MetricLook.poor
        case .idle: MetricLook.idle
        }
    }

    var word: String {
        switch self {
        case .fresh: "Fresh"
        case .stuffy: "Getting stuffy"
        case .poor: "Poor air"
        case .idle: "No reading"
        }
    }

    var symbol: String {
        switch self {
        case .fresh: "checkmark.circle.fill"
        case .stuffy: "exclamationmark.triangle.fill"
        case .poor: "exclamationmark.octagon.fill"
        case .idle: "minus.circle"
        }
    }
}

// MARK: Content parts

/// The plate that leads a screen: a label in capitals, one very large number
/// with its unit, and the verdict as an icon and words. The fill is the state.
struct MetricHeroPlate: View {
    let label: String
    let value: String
    let unit: String
    let state: MetricState

    var body: some View {
        let look = state.plate
        VStack(alignment: .leading, spacing: 0) {
            Text(label).metricLabel()
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value)
                    .font(MetricLook.heroNumber)
                    .monospacedDigit()
                    .tracking(-2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(unit)
                    .font(MetricLook.unit)
                    .fixedSize()
            }
            Label(state.word, systemImage: state.symbol)
                .font(MetricLook.verdict)
        }
        .foregroundStyle(look.on)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(look.fill, in: .rect(cornerRadius: MetricLook.plateRadius))
    }
}

/// A small plate at the end of a row: the same fill and ink as the large one,
/// with the number alone. A row with no reading gets the grey plate and a dash.
struct MetricChip: View {
    let value: String?
    let state: MetricState

    var body: some View {
        Text(value ?? "–")
            .font(MetricLook.chipNumber)
            .monospacedDigit()
            .foregroundStyle(state.plate.on)
            .padding(.horizontal, 10)
            .frame(minWidth: 58, minHeight: 32)
            .background(state.plate.fill, in: .rect(cornerRadius: MetricLook.chipRadius))
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. A hairline above, no box.
struct MetricPartRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: MetricLook.rowLead, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(MetricLook.row)
                    .foregroundStyle(MetricLook.ink)
                if let detail {
                    Text(detail)
                        .font(MetricLook.detail)
                        .foregroundStyle(MetricLook.ink2)
                }
            }
            Spacer(minLength: 8)
            end
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: MetricLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(MetricLook.rule).frame(height: 1)
        }
        .contentShape(.rect)
    }
}

/// A group's head: a few words in capitals.
struct MetricGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .metricLabel()
            .foregroundStyle(MetricLook.ink2)
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
    }
}

/// A picture at the start of a row: a small rounded square. Waiting, it is
/// the same square in the rule colour; if it cannot load, the square keeps a
/// mark. No hue: colour here belongs to the plates.
struct MetricPicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                MetricLook.rule
            case .failed:
                MetricLook.rule.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.footnote)
                        .foregroundStyle(MetricLook.ink2)
                }
            }
        }
        .frame(width: MetricLook.rowLead, height: MetricLook.rowLead)
        .clipShape(.rect(cornerRadius: MetricLook.leadRadius))
    }
}

/// A glyph on a neutral tile, for a row whose thing has no picture.
struct MetricGlyphTile: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(MetricLook.ink2)
            .frame(width: MetricLook.rowLead, height: MetricLook.rowLead)
            .background(MetricLook.rule, in: .rect(cornerRadius: MetricLook.leadRadius))
    }
}

/// A person: their photograph, else their initial on a neutral disc, else a
/// dashed ring for nobody yet.
struct MetricPersonMark<Photo: View>: View {
    private let initial: String?
    private let photo: Photo?

    init(photo: Photo) {
        self.photo = photo
        self.initial = nil
    }

    var body: some View {
        Group {
            if let photo {
                photo.clipShape(.circle)
            } else if let initial {
                Text(initial)
                    .font(MetricLook.rowStrong)
                    .foregroundStyle(MetricLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(MetricLook.rule, in: .circle)
            } else {
                Circle().strokeBorder(MetricLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: MetricLook.rowLead, height: MetricLook.rowLead)
    }
}

extension MetricPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct MetricLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(7)
            .frame(width: MetricLook.rowLead, height: MetricLook.rowLead)
            .background(MetricLook.logoPlate, in: .rect(cornerRadius: MetricLook.leadRadius))
            .overlay {
                RoundedRectangle(cornerRadius: MetricLook.leadRadius).strokeBorder(MetricLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a screen with nothing to read: the grey plate, with
/// dashes where the number will be.
struct MetricEmptyPlate: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 3).fill(MetricLook.idle.on.opacity(0.35)).frame(width: 54, height: 6)
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 5).fill(MetricLook.idle.on).frame(width: 30, height: 10)
                }
            }
            .padding(.vertical, 14)
        }
        .padding(20)
        .frame(width: 190, alignment: .leading)
        .background(MetricLook.idle.fill, in: .rect(cornerRadius: 24))
    }
}

// MARK: Controls

/// The main button off a plate: ink, as wide as its place. Busy, its words
/// change and the fill lightens. Off, it is the rule colour.
struct MetricMainButtonStyle: ButtonStyle {
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
                .font(MetricLook.button)
                .foregroundStyle(isEnabled ? MetricLook.ground : MetricLook.ink2)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: MetricLook.buttonMin)
                .background(isEnabled ? MetricLook.ink.opacity(isBusy ? 0.72 : 1) : MetricLook.rule, in: .rect(cornerRadius: 26))
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.rect(cornerRadius: 26))
        }
    }
}

/// The second kind of button: underlined words in ink. There is no third.
struct MetricTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(MetricLook.ink)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// One of a few: segments in one track, the chosen one in ink.
struct MetricSegments: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
                    .buttonStyle(Segment(isOn: option == selection))
            }
        }
        .padding(4)
        .background(MetricLook.rule, in: .rect(cornerRadius: 14))
    }

    private struct Segment: ButtonStyle {
        let isOn: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(isOn ? MetricLook.ground : MetricLook.ink)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(isOn ? MetricLook.ink : .clear, in: .rect(cornerRadius: 10))
                .contentShape(.rect)
                .opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

/// A field for one number: large, with its unit, on a line. In use the line
/// is two points of ink. An error is a mark and a reason under the line, in
/// ink: a state's colour would say something about the air.
struct MetricNumberField: View {
    let name: String
    @Binding var text: String
    let unit: String
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                TextField(name, text: $text, prompt: Text("0").foregroundStyle(MetricLook.ink2))
                    .font(MetricLook.fieldNumber)
                    .monospacedDigit()
                    .foregroundStyle(MetricLook.ink)
                    .tint(MetricLook.ink)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .fixedSize()
                Text(unit)
                    .font(MetricLook.unit)
                    .foregroundStyle(MetricLook.ink2)
                Spacer(minLength: 0)
            }
            .frame(minHeight: 52)
            .contentShape(.rect)
            .onTapGesture { isFocused = true }
            Rectangle()
                .fill(isFocused ? MetricLook.ink : MetricLook.ink2)
                .frame(height: isFocused ? 2 : 1)
            if let error {
                Label(error, systemImage: "nosign")
                    .font(MetricLook.detail)
                    .foregroundStyle(MetricLook.ink)
                    .padding(.top, 6)
            }
        }
    }
}

/// A row that has not arrived: its shapes in the rule colour.
struct MetricGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: MetricLook.leadRadius).fill(MetricLook.rule)
                .frame(width: MetricLook.rowLead, height: MetricLook.rowLead)
            RoundedRectangle(cornerRadius: 4).fill(MetricLook.rule).frame(width: 120, height: 12)
            Spacer()
            RoundedRectangle(cornerRadius: MetricLook.chipRadius).fill(MetricLook.rule).frame(width: 58, height: 32)
        }
        .frame(minHeight: MetricLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(MetricLook.rule).frame(height: 1)
        }
    }
}
