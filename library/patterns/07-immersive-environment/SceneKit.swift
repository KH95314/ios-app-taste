import SwiftUI

// Direction 07 Immersive Environment: the rest of the look's parts.
// `SceneLook.swift` has the colours of words on a scene, the label in
// capitals and the white filled button. This file adds what a second and a
// third screen need.
//
// Two rules run through all of it.
//
// The scene is the data, large or small. It fills the main screen. On every
// other screen it comes back as a porthole at the start of a row, drawn at
// that row's own tide and hour, and the reading comes back as thin white
// figures at the row's end.
//
// How much scene stays behind a second screen: none. A list, a form and a
// sheet scroll, and scrolled words would cross the sky, which is too light
// for them. So those screens sit under the water: their ground is the sea's
// own two colours, from `floor` at the top to `deep` at the bottom, the same
// in light and dark. White is 6.4:1 on the lighter of the two. Nothing is in
// a card, and no shape lighter than `floor` ever has words on it: a control
// is solid white with dark words, or an outline.

extension SceneLook {
    // Type roles.
    /// The reading that leads a screen.
    static let hero = Font.largeTitle.scaled(by: 2.8).weight(.thin)
    static let heroUnit = Font.title.weight(.light)
    static let trend = Font.title2.weight(.semibold)
    static let row = Font.body.weight(.medium)
    static let detail = Font.footnote
    /// The reading at the end of a row: the hero's figures, small.
    static let figure = Font.body.weight(.light)
    static let button = Font.headline
    static let textButton = Font.subheadline.weight(.semibold)
    static let emptyTitle = Font.title.bold()
    static let fieldNumber = Font.system(.largeTitle, weight: .light)

    // Sizes. `margin` is in the look file.
    static let rowMin = 56.0
    static let buttonMin = 50.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is: a porthole, a person, a logo, the
    /// app's mark. One width, so every name starts at the same edge.
    static let rowLead = 44.0
    static let rowGap = 14.0
    static let logoRadius = 11.0
    /// How tall a picture stands at the top of a screen.
    static let windowHeight = 200.0

    /// The bottom of the water: the ground at the foot of a screen that scrolls.
    static let deep = Color(fixed: 0x0F3F56)
    /// A shape that is waiting for its content. Lighter than `floor`, so it
    /// never has words on it, only a mark.
    static let haze = Color(fixed: 0x3E8299)
    /// The tile another company's logo sits on. The look has one appearance,
    /// so the tile is the same in light and dark.
    static let logoPlate = Color(fixed: 0xFFFFFF)

    // contrast: on on floor
    // contrast: on2 on floor
    // contrast: on on deep
    // contrast: on2 on deep
    // contrast: ink on on
    // contrast: ink on on2
    // contrast: on on haze 3
    // contrast: on2 on floor 3
}

// MARK: Content parts

/// The ground of every screen that scrolls: the sea with no sky, lightest at
/// the top. It runs under the bars.
struct SceneWater: View {
    var body: some View {
        LinearGradient(colors: [SceneLook.floor, SceneLook.deep], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

/// The line where the water meets the air: a slow wave. The scene has one,
/// and so has the lower edge of a picture and the empty drawing.
struct SceneWaterLine: Shape {
    var swell = 3.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for x in stride(from: rect.minX, through: rect.maxX, by: 2) {
            path.addLine(to: CGPoint(x: x, y: rect.midY + swell * sin(Double(x - rect.minX) / 120 * 2 * .pi)))
        }
        return path
    }
}

/// The reading that leads a screen: a few words in capitals, one very large
/// thin figure with its unit, and what the figure is doing as an arrow and a
/// word. It sits straight on the water.
struct SceneReading: View {
    var label: String?
    let value: String
    let unit: String
    let trend: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                Text(label).sceneLabel()
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value)
                    .font(SceneLook.hero)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(unit)
                    .font(SceneLook.heroUnit)
                    .fixedSize()
            }
            Label(trend, systemImage: symbol)
                .font(SceneLook.trend)
        }
        .foregroundStyle(SceneLook.on)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The reading at the end of a row: the same thin figures with their arrow.
struct SceneFigure: View {
    let value: String
    var symbol: String?

    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(SceneLook.figure)
                .monospacedDigit()
            if let symbol {
                Image(systemName: symbol)
                    .font(.footnote.weight(.semibold))
            }
        }
        .foregroundStyle(SceneLook.on)
        .fixedSize()
    }
}

/// The scene, small: a round window at the start of a row, holding a drawing
/// of that row's own water and sky. The product supplies the drawing.
struct ScenePorthole<Content: View>: View {
    @ViewBuilder var scene: Content

    var body: some View {
        scene
            .frame(width: SceneLook.rowLead, height: SceneLook.rowLead)
            .clipShape(.circle)
            .overlay {
                Circle().strokeBorder(SceneLook.on, lineWidth: 1.5)
            }
    }
}

/// A glyph at the start of a row whose thing is not a place.
struct SceneGlyph: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.body.weight(.medium))
            .foregroundStyle(SceneLook.on2)
            .frame(width: SceneLook.rowLead, height: SceneLook.rowLead)
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. No box and no rule: rows are told apart by their
/// height and by what starts them.
struct ScenePartRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: SceneLook.rowGap) {
            lead
                .frame(width: SceneLook.rowLead, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(SceneLook.row)
                    .foregroundStyle(SceneLook.on)
                if let detail {
                    Text(detail)
                        .font(SceneLook.detail)
                        .foregroundStyle(SceneLook.on2)
                }
            }
            Spacer(minLength: 8)
            end
        }
        .frame(maxWidth: .infinity, minHeight: SceneLook.rowMin)
        .contentShape(.rect)
    }
}

/// A group's head: the look's label in capitals. Only for a group that needs
/// a name.
struct SceneGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .sceneLabel()
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
    }
}

/// A picture stands where the scene stands: at the top, from edge to edge,
/// with no corners, ending in the water line. Waiting, it is the same band in
/// haze. If it cannot load, the band keeps a mark. With no picture at all,
/// the product's drawn scene takes the band.
struct SceneWindow<Drawing: View>: View {
    /// `nil` when the thing has no picture.
    let form: PictureForm?
    @ViewBuilder var drawing: Drawing

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: SceneLook.windowHeight)
            .overlay {
                switch form {
                case .loaded(let picture):
                    picture.resizable().scaledToFill()
                case .waiting:
                    SceneLook.haze
                case .failed:
                    SceneLook.haze.overlay {
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.title2)
                            .foregroundStyle(SceneLook.on)
                    }
                case nil:
                    drawing
                }
            }
            .clipped()
            .overlay(alignment: .bottom) {
                SceneWaterLine()
                    .stroke(SceneLook.on, lineWidth: 2)
                    .frame(height: 8)
                    .offset(y: 4)
            }
    }
}

/// A person: their photograph in a ring, else their initial in a ring, else
/// a dashed ring for nobody yet. Rings only: a filled white disc is a button.
struct ScenePersonMark<Photo: View>: View {
    private let initial: String?
    private let photo: Photo?

    init(photo: Photo) {
        self.photo = photo
        self.initial = nil
    }

    var body: some View {
        Group {
            if let photo {
                photo
                    .clipShape(.circle)
                    .overlay { Circle().strokeBorder(SceneLook.on, lineWidth: 1.5) }
            } else if let initial {
                Text(initial)
                    .font(SceneLook.row)
                    .foregroundStyle(SceneLook.on)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay { Circle().strokeBorder(SceneLook.on2, lineWidth: 1.5) }
            } else {
                Circle().strokeBorder(SceneLook.on2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: SceneLook.rowLead, height: SceneLook.rowLead)
    }
}

extension ScenePersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on: white and square-cornered enough
/// not to be taken for a porthole. The logo keeps its own colours.
struct SceneLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(8)
            .frame(width: SceneLook.rowLead, height: SceneLook.rowLead)
            .background(SceneLook.logoPlate, in: .rect(cornerRadius: SceneLook.logoRadius))
    }
}

/// The picture for a screen with no place on it: a large porthole that is
/// only a dashed ring, with still water across it and nothing above.
struct SceneEmptyPorthole: View {
    var body: some View {
        Circle()
            .strokeBorder(SceneLook.on2, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            .frame(width: 112, height: 112)
            .overlay {
                SceneWaterLine(swell: 2.5)
                    .stroke(SceneLook.on, lineWidth: 2)
                    .frame(width: 84, height: 8)
                    .offset(y: 14)
            }
    }
}

/// What is wrong, in one line on the water, with the way out at its end.
struct SceneNotice: View {
    let text: String
    var symbol = "wifi.slash"
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Label(text, systemImage: symbol)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(SceneLook.on)
            Spacer(minLength: 8)
            Button(actionTitle, action: action)
                .buttonStyle(SceneTextButtonStyle())
        }
    }
}

// MARK: Controls

/// The main button, as wide as its place: solid white with dark words, the
/// look file's filled button with two more forms. Busy, its words change and
/// the white greys a little. Off, it is an outline, since a dimmed white
/// would pass on one part of the water and fail on another.
struct SceneMainButtonStyle: ButtonStyle {
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
                .font(SceneLook.button)
                .foregroundStyle(isEnabled ? SceneLook.ink : SceneLook.on2)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, minHeight: SceneLook.buttonMin)
                .background {
                    if isEnabled {
                        Capsule().fill(isBusy ? SceneLook.on2 : SceneLook.on)
                    } else {
                        Capsule().strokeBorder(SceneLook.on2, lineWidth: 1.5)
                    }
                }
                .contentShape(.capsule)
                .opacity(isPressed ? 0.7 : 1)
        }
    }
}

/// The second kind of button: underlined white words, as the scene's own
/// "Try again" is. There is no third.
struct SceneTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SceneLook.textButton)
            .underline()
            .foregroundStyle(SceneLook.on)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// A row or a scene that opens something dims while it is pressed, and shows
/// no chevron.
struct ScenePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// One of a few: capsules in a row. The chosen one is solid white with dark
/// words; the others are outlines. No track behind them.
struct SceneChoices: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
                    .buttonStyle(Choice(isOn: option == selection))
            }
        }
    }

    private struct Choice: ButtonStyle {
        let isOn: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(SceneLook.textButton)
                .monospacedDigit()
                .foregroundStyle(isOn ? SceneLook.ink : SceneLook.on)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background {
                    if isOn {
                        Capsule().fill(SceneLook.on)
                    } else {
                        Capsule().strokeBorder(SceneLook.on2, lineWidth: 1.5)
                    }
                }
                .contentShape(.capsule)
                .opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

/// A field for one number: the reading's thin figures with their unit, on a
/// line. In use the line is two points of white. An error is a mark and the
/// cause under the line, in white: the look has no hue of its own to spend.
struct SceneNumberField: View {
    let name: String
    @Binding var text: String
    let unit: String
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                TextField(name, text: $text, prompt: Text("0").foregroundStyle(SceneLook.on2))
                    .font(SceneLook.fieldNumber)
                    .monospacedDigit()
                    .foregroundStyle(SceneLook.on)
                    .tint(SceneLook.on)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .fixedSize()
                Text(unit)
                    .font(SceneLook.heroUnit)
                    .foregroundStyle(SceneLook.on2)
                Spacer(minLength: 0)
            }
            .frame(minHeight: 56)
            .contentShape(.rect)
            .onTapGesture { isFocused = true }
            Rectangle()
                .fill(isFocused ? SceneLook.on : SceneLook.on2)
                .frame(height: isFocused ? 2 : 1)
            if let error {
                Label(error, systemImage: "nosign")
                    .font(SceneLook.detail.weight(.medium))
                    .foregroundStyle(SceneLook.on)
                    .padding(.top, 8)
            }
        }
    }
}

/// A row that has not arrived: its shapes in haze.
struct SceneGhostRow: View {
    var body: some View {
        HStack(spacing: SceneLook.rowGap) {
            Circle().fill(SceneLook.haze)
                .frame(width: SceneLook.rowLead, height: SceneLook.rowLead)
            Capsule().fill(SceneLook.haze).frame(width: 120, height: 12)
            Spacer()
            Capsule().fill(SceneLook.haze).frame(width: 52, height: 12)
        }
        .frame(minHeight: SceneLook.rowMin)
    }
}

/// The reading that has not arrived: its shapes in haze, at its size.
struct SceneGhostReading: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Capsule().fill(SceneLook.haze).frame(width: 130, height: 10)
            RoundedRectangle(cornerRadius: 12).fill(SceneLook.haze).frame(width: 170, height: 84)
            Capsule().fill(SceneLook.haze).frame(width: 96, height: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}
