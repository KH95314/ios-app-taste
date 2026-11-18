import SwiftUI

// Direction 11 Layered Surfaces: the rest of the look's parts. `LayerLook.swift`
// has the colours, the sheet's two buttons and the status badge. This file
// adds what a second and a third screen need.
//
// One rule runs through all of it: the layer underneath keeps the colour, and
// the surface on top is ink on one solid ground. The subject's hue comes up
// onto a surface in one form only, a pin: large on the plan, small at the
// start of a row. A state is the look's badge. Nothing else on a surface has
// a hue.

extension LayerLook {
    // Type roles.
    /// The name that leads a surface.
    static let title = Font.title2.bold()
    static let fact = Font.subheadline
    static let factStrong = Font.subheadline.weight(.semibold)
    static let head = Font.headline
    static let row = Font.body
    static let rowStrong = Font.body.weight(.semibold)
    static let detail = Font.subheadline
    static let button = Font.headline
    static let smallButton = Font.subheadline.weight(.semibold)
    static let note = Font.footnote

    // Sizes.
    static let margin = 20.0
    static let rowMin = 52.0
    static let buttonMin = 50.0
    static let groupGap = 24.0
    /// What starts a row, whatever it is: a pin, a glyph, a person, a logo,
    /// the app's mark. One width, so every name starts at the same edge.
    static let rowLead = 32.0
    static let leadRadius = 8.0
    /// The top corners of a surface that lies over a layer.
    static let surfaceRadius = 28.0
    static let fieldRadius = 14.0
    /// The pin of the point that leads, and of every other point on the plan.
    static let pinLead = 46.0
    static let pinPlan = 30.0

    /// The solid ground of a surface. Text is measured on this, not on a
    /// material, whose ground changes with what is under it.
    static let surface = Color(light: 0xFFFFFF, dark: 0x1C1D20)
    /// The glyph and the ring of a pin.
    static let onPin = Color(fixed: 0xFFFFFF)
    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF4F5F6)
    /// The shadow a surface throws on the layer under it.
    static let shade = Color(fixed: 0x000000)

    // The drawn plan, the layer underneath. Its colours are the layer's own
    // and no text is set on them.
    static let planLand = Color(light: 0xF1EEE6, dark: 0x24262B)
    static let planRoad = Color(light: 0xFFFFFF, dark: 0x3A3D44)
    static let planPark = Color(light: 0xCFE6BF, dark: 0x1F3A2A)
    static let planPath = Color(light: 0xF4F7EE, dark: 0x335441)
    static let planWater = Color(light: 0xA9D3F0, dark: 0x1D4A6B)

    // contrast: ink on surface
    // contrast: ink2 on surface
    // contrast: ink on control
    // contrast: ink2 on control
    // contrast: onAction on action
    // contrast: warn on surface
    // contrast: ok on okTint
    // contrast: warn on warnTint
    // contrast: onPin on pin 3
    // contrast: onPin on pinOff 3
    // contrast: ink2 on rule 3
}

// MARK: The layer underneath

/// A pin: the subject's hue and a glyph on a disc. A point that cannot be
/// used changes its glyph as well as its colour. The same mark is large on
/// the plan and small at the start of a row.
struct LayerPin: View {
    var isWorking = true
    var size = 26.0
    /// On the plan a pin gets a white ring, so it reads on any ground.
    var hasRing = false

    var body: some View {
        Image(systemName: isWorking ? "drop.fill" : "exclamationmark")
            .font(.system(size: size * 0.46, weight: .bold))
            .foregroundStyle(LayerLook.onPin)
            .frame(width: size, height: size)
            .background(isWorking ? LayerLook.pin : LayerLook.pinOff, in: .circle)
            .overlay {
                if hasRing {
                    Circle().strokeBorder(LayerLook.onPin, lineWidth: size > 36 ? 3 : 2)
                }
            }
            .shadow(color: LayerLook.shade.opacity(hasRing ? 0.22 : 0), radius: 3, y: 1)
    }
}

/// The layer underneath, drawn: a plan of streets, a park, a pond and paths,
/// with pins over it. It is drawn from its own size, and everything that
/// matters is placed in the part the surface leaves clear, so a pin is never
/// under the surface or the bar.
struct LayerPlan: View {
    struct Pin: Identifiable {
        let id: Int
        /// Where it stands in the clear part of the plan, as shares of its
        /// width and height.
        var x: Double
        var y: Double
        var isWorking = true
        var leads = false
    }

    var pins: [Pin] = []
    /// How much of the bottom the surface covers.
    var covered = 0.0

    var body: some View {
        GeometryReader { proxy in
            let clear = CGSize(width: proxy.size.width, height: max(proxy.size.height - covered, 140))
            let inset = proxy.safeAreaInsets
            Canvas { context, size in
                Self.draw(&context, size: size, clear: CGRect(origin: CGPoint(x: inset.leading, y: inset.top), size: clear))
            }
            .ignoresSafeArea()
            ForEach(pins) { pin in
                LayerPin(
                    isWorking: pin.isWorking,
                    size: pin.leads ? LayerLook.pinLead : LayerLook.pinPlan,
                    hasRing: true)
                    .position(x: clear.width * pin.x, y: clear.height * pin.y)
                    .zIndex(pin.leads ? 1 : 0)
            }
        }
    }

    private static func draw(_ context: inout GraphicsContext, size: CGSize, clear: CGRect) {
        func at(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: clear.minX + clear.width * x, y: clear.minY + clear.height * y)
        }
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(LayerLook.planLand))

        // Streets run over the whole layer, past the clear part.
        var streets = Path()
        for share in [0.07, 0.31, 0.58, 0.83, 1.12, 1.38, 1.66] {
            let y = clear.minY + clear.height * share - clear.height * 0.1
            streets.move(to: CGPoint(x: 0, y: y))
            streets.addLine(to: CGPoint(x: size.width, y: y + size.width * 0.04))
        }
        for share in [0.06, 0.2, 0.52, 0.93] {
            let x = size.width * share
            streets.move(to: CGPoint(x: x, y: 0))
            streets.addLine(to: CGPoint(x: x - size.height * 0.03, y: size.height))
        }
        context.stroke(streets, with: .color(LayerLook.planRoad), style: StrokeStyle(lineWidth: 7, lineCap: .round))

        var park = Path()
        park.move(to: at(0.24, 0.02))
        park.addLine(to: at(0.86, 0.0))
        park.addLine(to: at(0.9, 1.0))
        park.addLine(to: at(0.34, 1.0))
        park.closeSubpath()
        context.fill(park, with: .color(LayerLook.planPark))

        var paths = Path()
        paths.move(to: at(0.5, 0.02))
        paths.addCurve(to: at(0.46, 1.0), control1: at(0.34, 0.35), control2: at(0.66, 0.7))
        paths.move(to: at(0.3, 0.46))
        paths.addCurve(to: at(0.88, 0.5), control1: at(0.5, 0.52), control2: at(0.7, 0.36))
        context.stroke(paths, with: .color(LayerLook.planPath), style: StrokeStyle(lineWidth: 4, lineCap: .round))

        let pond = CGRect(
            x: clear.minX + clear.width * 0.5, y: clear.minY + clear.height * 0.56,
            width: clear.width * 0.16, height: clear.height * 0.16)
        context.fill(Path(ellipseIn: pond), with: .color(LayerLook.planWater))
    }
}

/// A picture as the layer underneath: it fills its place and the surface
/// lies over its lower edge. Waiting, the place is the quiet control fill;
/// if it cannot load, the fill keeps a mark. With no picture at all a screen
/// puts the plan there instead, with the point's own pin.
struct LayerPicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                Color.clear.overlay { picture.resizable().scaledToFill() }
            case .waiting:
                LayerLook.control
            case .failed:
                LayerLook.control.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(LayerLook.ink2)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

// MARK: The surface and its content

/// A surface over a layer: one solid ground with rounded top corners, as
/// wide as the screen and running on under the home indicator. It has no
/// grabber, because it is not dragged.
struct LayerSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, LayerLook.margin)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                UnevenRoundedRectangle(topLeadingRadius: LayerLook.surfaceRadius, topTrailingRadius: LayerLook.surfaceRadius)
                    .fill(LayerLook.surface)
                    .shadow(color: LayerLook.shade.opacity(0.16), radius: 12, y: -2)
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}

/// What leads a surface: a name, the two facts needed to decide with the
/// distance in ink, and the state as the look's badge.
struct LayerLead: View {
    let name: String
    let distance: String
    let walk: String
    let state: String
    var tone = StatusBadge.Tone.ok

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name)
                .font(LayerLook.title)
                .foregroundStyle(LayerLook.ink)
            Text("\(Text(distance).font(LayerLook.factStrong).foregroundStyle(LayerLook.ink)) · \(walk)")
                .font(LayerLook.fact)
                .foregroundStyle(LayerLook.ink2)
                .padding(.top, 2)
            StatusBadge(text: state, tone: tone)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. A hairline above, no box.
struct LayerPartRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 12) {
            lead
                .frame(width: LayerLook.rowLead, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(LayerLook.row)
                    .foregroundStyle(LayerLook.ink)
                if let detail {
                    Text(detail)
                        .font(LayerLook.detail)
                        .foregroundStyle(LayerLook.ink2)
                }
            }
            Spacer(minLength: 8)
            end
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: LayerLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(LayerLook.rule).frame(height: 1)
        }
        .contentShape(.rect)
    }
}

/// A group's head: a few words at the reading size, in bold.
struct LayerGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .font(LayerLook.head)
            .foregroundStyle(LayerLook.ink)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
    }
}

/// A glyph at the start of a row whose thing has no pin and no picture.
/// Second ink and no tile: a surface stays quiet.
struct LayerGlyph: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(LayerLook.ink2)
            .frame(width: 26, height: 26)
    }
}

/// A person: their photograph, else their initial on the control fill, else
/// a dashed ring for nobody yet.
struct LayerPersonMark<Photo: View>: View {
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
                    .font(LayerLook.smallButton)
                    .foregroundStyle(LayerLook.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(LayerLook.control, in: .circle)
            } else {
                Circle().strokeBorder(LayerLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: LayerLook.rowLead, height: LayerLook.rowLead)
    }
}

extension LayerPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct LayerLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(5)
            .frame(width: LayerLook.rowLead, height: LayerLook.rowLead)
            .background(LayerLook.logoPlate, in: .rect(cornerRadius: LayerLook.leadRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LayerLook.leadRadius).strokeBorder(LayerLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a surface with nothing to list: the place a pin would
/// stand, as a dashed ring, inside two rings of the distance searched.
struct LayerEmptyPin: View {
    var body: some View {
        ZStack {
            Circle().strokeBorder(LayerLook.rule, lineWidth: 1.5)
            Circle().strokeBorder(LayerLook.rule, lineWidth: 1.5).padding(18)
            Circle()
                .strokeBorder(LayerLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                .frame(width: LayerLook.pinPlan, height: LayerLook.pinPlan)
        }
        .frame(width: 104, height: 104)
    }
}

/// A state the screen cannot show by itself, such as being offline: a
/// glyph, the state, one quiet line, and the second kind of button. It is a
/// quiet fill and not a hue, because it sits on a surface.
struct LayerNotice: View {
    let symbol: String
    let title: String
    var message: String?
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(LayerLook.ink)
                .frame(width: LayerLook.rowLead - 12, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(LayerLook.factStrong)
                    .foregroundStyle(LayerLook.ink)
                if let message {
                    Text(message)
                        .font(LayerLook.note)
                        .foregroundStyle(LayerLook.ink2)
                }
            }
            Spacer(minLength: 8)
            Button(actionTitle, action: action)
                .buttonStyle(LayerSmallButtonStyle(onFill: true))
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: LayerLook.rowMin)
        .background(LayerLook.control, in: .rect(cornerRadius: LayerLook.fieldRadius))
    }
}

// MARK: Controls

/// The main button of a surface: ink, as wide as its place, and the same
/// drawing as the look file's main button. Busy, its words change and the
/// fill lightens. Off, it is the control fill with second ink.
struct LayerMainButtonStyle: ButtonStyle {
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
                .font(LayerLook.button)
                .foregroundStyle(isEnabled ? LayerLook.onAction : LayerLook.ink2)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: LayerLook.buttonMin)
                .background(
                    isEnabled ? LayerLook.action.opacity(isBusy ? 0.72 : 1) : LayerLook.control,
                    in: .rect(cornerRadius: LayerLook.buttonMin / 2))
                .opacity(isPressed ? 0.7 : 1)
                .contentShape(.rect(cornerRadius: LayerLook.buttonMin / 2))
        }
    }
}

/// The second kind of button at the size of a row's end: the control fill
/// and ink words. On a part that is already the control fill it takes the
/// surface's ground. There is no third kind.
struct LayerSmallButtonStyle: ButtonStyle {
    var onFill = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LayerLook.smallButton)
            .foregroundStyle(LayerLook.ink)
            .lineLimit(1)
            .padding(.horizontal, 14)
            .frame(minHeight: 34)
            .background(onFill ? LayerLook.surface : LayerLook.control, in: .capsule)
            .frame(minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// One of a few: segments in one track of the control fill, the chosen one
/// in ink, like the main action.
struct LayerChoice: View {
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
        .background(LayerLook.control, in: .rect(cornerRadius: LayerLook.fieldRadius + 4))
    }

    private struct Segment: ButtonStyle {
        let isOn: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(LayerLook.smallButton)
                .foregroundStyle(isOn ? LayerLook.onAction : LayerLook.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(isOn ? LayerLook.action : .clear, in: .rect(cornerRadius: LayerLook.fieldRadius))
                .contentShape(.rect)
                .opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

/// A text field: the control fill, with a ring of ink while it is in use.
/// An error is the look's warning colour as a ring, a mark and the cause.
struct LayerField: View {
    let name: String
    @Binding var text: String
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(name, text: $text, prompt: Text(name).foregroundStyle(LayerLook.ink2))
                .font(LayerLook.row)
                .foregroundStyle(LayerLook.ink)
                .tint(LayerLook.ink)
                .focused($isFocused)
                .padding(.horizontal, 14)
                .frame(minHeight: LayerLook.buttonMin)
                .background(LayerLook.control, in: .rect(cornerRadius: LayerLook.fieldRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LayerLook.fieldRadius)
                        .strokeBorder(error != nil ? LayerLook.warn : isFocused ? LayerLook.ink : .clear, lineWidth: 2)
                }
            if let error {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(LayerLook.note)
                    .foregroundStyle(LayerLook.warn)
            }
        }
    }
}

/// The lead of a surface that has not arrived: its three lines as shapes.
struct LayerGhostLead: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 6).fill(LayerLook.control).frame(width: 210, height: 22)
            RoundedRectangle(cornerRadius: 4).fill(LayerLook.control).frame(width: 130, height: 12)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 14).fill(LayerLook.control).frame(width: 190, height: 28)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A row that has not arrived: its shapes in the control fill.
struct LayerGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(LayerLook.control).frame(width: 26, height: 26)
                .frame(width: LayerLook.rowLead, alignment: .leading)
            RoundedRectangle(cornerRadius: 4).fill(LayerLook.control).frame(width: 150, height: 12)
            Spacer()
            RoundedRectangle(cornerRadius: 4).fill(LayerLook.control).frame(width: 44, height: 12)
        }
        .frame(minHeight: LayerLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(LayerLook.rule).frame(height: 1)
        }
    }
}
