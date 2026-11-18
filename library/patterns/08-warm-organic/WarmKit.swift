import SwiftUI

// Direction 08 Warm Organic: the rest of the look's parts. `WarmLook.swift`
// has the colours, the picture's palette, the pill, the text button and the
// disc. This file adds what a second and a third screen need.
//
// One rule runs through all of it: a drawn picture shows how far a thing has
// come, large where it leads a screen and small where it starts a row. The
// picture keeps its own palette in light and dark. Off the picture, titles
// are serif and the one clay hue is for what can be pressed and the step
// that is current.

extension WarmLook {
    // Type roles.
    /// The name under the picture that leads a screen.
    static let title = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let groupHead = Font.system(.title3, design: .serif, weight: .semibold)
    static let row = Font.body
    static let rowStrong = Font.body.weight(.semibold)
    static let detail = Font.subheadline
    static let button = Font.headline

    // Sizes.
    static let rowMin = 60.0
    static let buttonMin = 56.0
    static let groupGap = 28.0
    /// What starts a row, whatever it is: a small jar, a picture, a pebble, a
    /// person, a logo. One width, so every name starts at the same edge.
    static let rowLead = 44.0
    static let leadRadius = 14.0
    /// The picture that leads a screen.
    static let leadHeight = 236.0
    static let frameRadius = 28.0
    static let fieldRadius = 18.0

    /// A shape that is waiting, a field's edge, and a button that is off.
    static let rule = Color(light: 0xEADFCB, dark: 0x3A2E25)
    /// The tile another company's logo sits on, light in both appearances.
    static let logoPlate = Color(light: 0xFFFFFF, dark: 0xF6EBDD)

    // contrast: ink on ground
    // contrast: ink2 on ground
    // contrast: accent on ground
    // contrast: onAccent on accent
    // contrast: ink on surface
    // contrast: ink2 on surface
    // contrast: ink2 on rule
    // contrast: ground on ink
    // contrast: berry on cream
}

// MARK: Content parts

/// The picture that leads the counter: the entry's kitchen, with the dough at
/// this jar's height, standing still. With no `rise` the jar stands empty,
/// which is also the picture for a screen with nothing on it.
struct WarmCounterPicture: View {
    let rise: Double?

    var body: some View {
        KitchenPicture(rise: rise)
            .frame(maxWidth: .infinity)
            .frame(height: WarmLook.leadHeight)
            // The drawing has its own soft lower edge; only the top is cut.
            .clipShape(.rect(topLeadingRadius: WarmLook.frameRadius, topTrailingRadius: WarmLook.frameRadius))
    }
}

/// What leads a screen: a picture, a serif name under it, and one quiet line
/// at most.
struct WarmLead<Picture: View>: View {
    let name: String
    var line: String?
    @ViewBuilder var picture: Picture

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            picture
            Text(name)
                .font(WarmLook.title)
                .foregroundStyle(WarmLook.ink)
                .padding(.top, 12)
            if let line {
                Text(line)
                    .font(WarmLook.detail)
                    .foregroundStyle(WarmLook.ink2)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}

/// The kitchen's jar, small, at the start of a row: the dough stands at this
/// thing's own height under the band. The same palette as the large picture.
struct WarmJar: View {
    /// 0 when the dough has just gone in, 1 when it has reached the band.
    let rise: Double

    var body: some View {
        Canvas { context, size in
            let unit = size.width / 44
            func box(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> CGRect {
                CGRect(x: x * unit, y: y * unit, width: width * unit, height: height * unit)
            }
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(WarmLook.clay))
            context.fill(Path(ellipseIn: box(22, -8, 34, 34)), with: .color(WarmLook.sun))
            let jar = Path(roundedRect: box(11, 7, 22, 31), cornerRadius: 5 * unit)
            context.fill(jar, with: .color(WarmLook.clay))
            context.fill(jar, with: .color(WarmLook.cream.opacity(0.3)))
            let top = 30 - min(max(rise, 0), 1) * 13
            var dough = context
            dough.clip(to: jar)
            dough.fill(Path(roundedRect: box(11, top, 22, 40), cornerRadius: 4 * unit), with: .color(WarmLook.cream))
            context.stroke(jar, with: .color(WarmLook.cream), lineWidth: 2 * unit)
            context.fill(Path(roundedRect: box(9, 15, 26, 3), cornerRadius: 1.5 * unit), with: .color(WarmLook.berry))
        }
        .frame(width: WarmLook.rowLead, height: WarmLook.rowLead)
        .clipShape(.rect(cornerRadius: WarmLook.leadRadius))
    }
}

/// One step of a job, as the entry's pebbles draw it: filled when done, wide
/// and clay when current, a ring when still to come.
struct WarmPebble: View {
    enum Step { case done, current, toCome }
    let step: Step

    var body: some View {
        switch step {
        case .done: Ellipse().fill(WarmLook.ink).frame(width: 14, height: 12)
        case .current: Ellipse().fill(WarmLook.accent).frame(width: 26, height: 12)
        case .toCome: Ellipse().strokeBorder(WarmLook.ink2, lineWidth: 2).frame(width: 14, height: 12)
        }
    }
}

/// A row: something at its start, a name with one quiet line at most, and
/// something at its end. No line and no box: the gap between rows is enough.
struct WarmRow<Lead: View, End: View>: View {
    let name: String
    var detail: String?
    var isStrong = false
    @ViewBuilder var lead: Lead
    @ViewBuilder var end: End

    var body: some View {
        HStack(spacing: 14) {
            lead
                .frame(width: WarmLook.rowLead, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(isStrong ? WarmLook.rowStrong : WarmLook.row)
                    .foregroundStyle(WarmLook.ink)
                if let detail {
                    Text(detail)
                        .font(WarmLook.detail)
                        .foregroundStyle(WarmLook.ink2)
                }
            }
            Spacer(minLength: 8)
            end
                .font(WarmLook.detail)
                .foregroundStyle(WarmLook.ink2)
        }
        .frame(maxWidth: .infinity, minHeight: WarmLook.rowMin)
        .contentShape(.rect)
    }
}

/// A group's head: a few serif words, for a group that needs a name.
struct WarmGroupHead: View {
    let title: String

    var body: some View {
        Text(title)
            .font(WarmLook.groupHead)
            .foregroundStyle(WarmLook.ink)
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
    }
}

/// The frame of a picture that leads: round at the top, with the soft uneven
/// lower edge of the kitchen's counter.
struct WarmFrame: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(WarmLook.frameRadius, rect.width / 2, rect.height / 2)
        let width = rect.width
        let height = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(to: CGPoint(x: radius, y: 0), control: .zero)
        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: radius), control: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height - 20))
        path.addCurve(
            to: CGPoint(x: width * 0.58, y: height - 8),
            control1: CGPoint(x: width * 0.86, y: height + 2), control2: CGPoint(x: width * 0.74, y: height - 14))
        path.addCurve(
            to: CGPoint(x: 0, y: height - 4),
            control1: CGPoint(x: width * 0.4, y: height + 2), control2: CGPoint(x: width * 0.2, y: height - 14))
        path.closeSubpath()
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

/// A photograph, where it leads a screen or starts a row. Waiting, its frame
/// is filled with the quiet colour; if it cannot load, the frame keeps a
/// mark. A thing with no picture gets the kitchen's field and sun.
struct WarmPicture: View {
    enum Place { case lead, row }
    /// `nil` for a thing that has no picture.
    let form: PictureForm?
    var place = Place.row

    var body: some View {
        switch place {
        case .lead:
            face
                .frame(maxWidth: .infinity)
                .frame(height: WarmLook.leadHeight)
                .clipShape(WarmFrame())
        case .row:
            face
                .frame(width: WarmLook.rowLead, height: WarmLook.rowLead)
                .clipShape(.rect(cornerRadius: WarmLook.leadRadius))
        }
    }

    @ViewBuilder private var face: some View {
        switch form {
        case .loaded(let picture):
            // An overlay, so a wide photograph cannot widen the page.
            Color.clear.overlay { picture.resizable().scaledToFill() }
        case .waiting:
            WarmLook.rule
        case .failed:
            WarmLook.rule.overlay {
                Image(systemName: "photo.badge.exclamationmark")
                    .font(place == .lead ? .title2 : .footnote)
                    .foregroundStyle(WarmLook.ink2)
            }
        case nil:
            Canvas { context, size in
                let side = min(size.width, size.height)
                let sun = CGRect(x: size.width - side * 0.78, y: side * 0.2, width: side * 0.9, height: side * 0.9)
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(WarmLook.clay))
                context.fill(Path(ellipseIn: sun), with: .color(WarmLook.sun))
                let counter = CGRect(x: 0, y: size.height - side * 0.2, width: size.width, height: side * 0.2)
                context.fill(Path(counter), with: .color(WarmLook.clay2))
            }
        }
    }
}

/// A person: their photograph, else their initial on a quiet disc, else a
/// dashed ring for nobody yet.
struct WarmPersonMark<Photo: View>: View {
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
                    .font(WarmLook.groupHead)
                    .foregroundStyle(WarmLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(WarmLook.rule, in: .circle)
            } else {
                Circle().strokeBorder(WarmLook.ink2, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
        }
        .frame(width: WarmLook.rowLead, height: WarmLook.rowLead)
    }
}

extension WarmPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?) {
        self.photo = nil
        self.initial = initial
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct WarmLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(8)
            .frame(width: WarmLook.rowLead, height: WarmLook.rowLead)
            .background(WarmLook.logoPlate, in: .rect(cornerRadius: WarmLook.leadRadius))
            .overlay {
                RoundedRectangle(cornerRadius: WarmLook.leadRadius).strokeBorder(WarmLook.rule, lineWidth: 1)
            }
    }
}

/// One line for something that is off or did not work: what it is, and the
/// way to put it right, as the entry's own notice is drawn.
struct WarmNotice: View {
    let words: String
    let symbol: String
    let action: String
    let perform: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Label(words, systemImage: symbol)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(WarmLook.ink)
            Spacer(minLength: 8)
            Button(action, action: perform)
                .buttonStyle(WarmTextButtonStyle())
        }
    }
}

// MARK: Controls

/// The main button, drawn as `WarmFilledButtonStyle` draws it, with two more
/// forms. Busy, its words change and the fill stays: dimming the clay would
/// take the words under 4.5:1. Off, it is the quiet colour.
struct WarmMainButtonStyle: ButtonStyle {
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
            HStack(spacing: 8) {
                if isBusy { ProgressView().tint(WarmLook.onAccent) }
                label
            }
            .font(WarmLook.button)
            .foregroundStyle(isEnabled ? WarmLook.onAccent : WarmLook.ink2)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: WarmLook.buttonMin)
            .background(isEnabled ? WarmLook.accent : WarmLook.rule, in: .capsule)
            .contentShape(.capsule)
            .opacity(isPressed ? 0.75 : 1)
        }
    }
}

// The second kind of button is `WarmTextButtonStyle` in the look file: clay
// words. `WarmPillButtonStyle` stays what it was, a nudge beside a figure.

/// One of a few: quiet pills in a row, the chosen one filled with ink. Not
/// clay: clay says "press me", and the chosen one is already pressed.
struct WarmChoices: View {
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
                .font(WarmLook.button)
                .monospacedDigit()
                .foregroundStyle(isOn ? WarmLook.ground : WarmLook.ink)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isOn ? WarmLook.ink : WarmLook.surface, in: .capsule)
                .contentShape(.capsule)
                .opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

/// A field for a few words: a soft box in the pill's colour. In use its edge
/// is two points of clay. An error is a mark and the reason under the box, in
/// ink: the picture's berry means done, and clay means something to press.
struct WarmField: View {
    let name: String
    @Binding var text: String
    var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(name, text: $text, prompt: Text(name).foregroundStyle(WarmLook.ink2))
                .font(WarmLook.row)
                .foregroundStyle(WarmLook.ink)
                .tint(WarmLook.accent)
                .focused($isFocused)
                .padding(.horizontal, 18)
                .frame(minHeight: WarmLook.buttonMin)
                .background(WarmLook.surface, in: .rect(cornerRadius: WarmLook.fieldRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: WarmLook.fieldRadius)
                        .strokeBorder(isFocused ? WarmLook.accent : WarmLook.rule, lineWidth: isFocused ? 2 : 1)
                }
                .contentShape(.rect)
                .onTapGesture { isFocused = true }
            if let error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(WarmLook.detail)
                    .foregroundStyle(WarmLook.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// The lead that has not arrived: its frame in the quiet colour.
struct WarmGhostLead: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WarmFrame().fill(WarmLook.rule)
                .frame(height: WarmLook.leadHeight)
            RoundedRectangle(cornerRadius: 8).fill(WarmLook.rule)
                .frame(width: 200, height: 28)
                .padding(.top, 18)
        }
    }
}

/// A row that has not arrived: its shapes in the quiet colour.
struct WarmGhostRow: View {
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: WarmLook.leadRadius).fill(WarmLook.rule)
                .frame(width: WarmLook.rowLead, height: WarmLook.rowLead)
            RoundedRectangle(cornerRadius: 6).fill(WarmLook.rule).frame(width: 130, height: 14)
            Spacer()
            RoundedRectangle(cornerRadius: 6).fill(WarmLook.rule).frame(width: 64, height: 12)
        }
        .frame(minHeight: WarmLook.rowMin)
    }
}
