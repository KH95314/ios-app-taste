import SwiftUI

// Direction 03 Data Precision: the rest of the look's parts. `DataLook.swift`
// has the colours, the type roles, the sizes and the parts the first two
// entries were built from. This file adds what a second and a third screen
// need: the look's own content parts first, then its controls.

// MARK: Content parts

/// The state, first on a screen: an icon and words in the state's colour.
/// The small line under it is for what the words cannot hold: since when, or
/// how far from usual. A good state needs none.
struct DataStateLine: View {
    let state: DataState
    let title: String
    var detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: state.symbol)
                .font(DataLook.stateFont)
                .foregroundStyle(state.color)
            if let detail {
                Text(detail)
                    .font(DataLook.meta)
                    .foregroundStyle(DataLook.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// What a state does to the ground. A state someone must act on lights the
/// top of the screen with its own colour; a good state leaves the ground
/// plain, because calm is plain.
struct DataWash: View {
    let state: DataState

    var body: some View {
        if state == .ok {
            DataLook.ground
        } else {
            LinearGradient(
                colors: [state.color.opacity(DataLook.wash), state.color.opacity(0)],
                startPoint: .top, endPoint: .bottom)
                .background(DataLook.ground)
        }
    }
}

/// One figure: a label in capitals, a monospaced number with a small unit
/// beside it, and a comparison in words beneath. One figure leads a screen at
/// the large size; the figures under it are a step smaller (`isLead: false`),
/// so that the screen has one largest thing.
struct DataFigure: View {
    let label: String
    let value: String
    var unit: String?
    var note: String?
    var state: DataState?
    var isLead = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).dataHead()
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if let state {
                    Image(systemName: state.symbol)
                        .font(isLead ? .title3 : .body)
                        .foregroundStyle(state.color)
                }
                Text(value)
                    .font(isLead ? DataLook.largeFigure : DataLook.gridFigure)
                    .foregroundStyle(state?.color ?? DataLook.ink)
                if let unit {
                    Text(unit)
                        .font(DataLook.unit)
                        .foregroundStyle(DataLook.ink2)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            if let note {
                Text(note)
                    .font(DataLook.comparison)
                    .foregroundStyle(state?.color ?? DataLook.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The days a figure sums up. A day with nothing to report is second ink; a
/// day that went wrong takes its state's colour.
struct DataDayStrip: View {
    /// One entry a day, oldest first. `nil` is a day with nothing to report.
    let days: [DataState?]
    let from: String
    let to: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(day?.color ?? DataLook.ink2)
                        .frame(height: 28)
                }
            }
            HStack {
                Text(from)
                Spacer()
                Text(to)
            }
            .font(DataLook.meta)
            .foregroundStyle(DataLook.ink2)
        }
    }
}

/// A small line of the last readings, ending in a dot at the latest.
struct DataSparkline: View {
    let readings: [Double]
    var state: DataState?

    var body: some View {
        Canvas { context, size in
            guard readings.count > 1, let low = readings.min(), let high = readings.max() else { return }
            let span = max(high - low, 1)
            let step = (size.width - 6) / Double(readings.count - 1)
            let points = readings.enumerated().map { index, value in
                CGPoint(x: 2 + Double(index) * step, y: size.height - 3 - (value - low) / span * (size.height - 6))
            }
            var line = Path()
            line.addLines(points)
            let ink = GraphicsContext.Shading.color(state?.color ?? DataLook.ink2)
            context.stroke(line, with: ink, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
            if let last = points.last {
                context.fill(Path(ellipseIn: CGRect(x: last.x - 2.6, y: last.y - 2.6, width: 5.2, height: 5.2)), with: ink)
            }
        }
        .frame(width: 52, height: 20)
    }
}

/// A short code in a monospaced tag. It starts a row that has no logo.
struct DataCodeTag: View {
    let code: String

    var body: some View {
        Text(code)
            .font(DataLook.code)
            .foregroundStyle(DataLook.ink2)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .overlay {
                RoundedRectangle(cornerRadius: 4).strokeBorder(DataLook.ink2, lineWidth: 1)
            }
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours;
/// the tile keeps them readable in dark.
struct DataLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(4)
            .frame(width: DataLook.tile, height: DataLook.tile)
            .background(DataLook.plate, in: .rect(cornerRadius: DataLook.tileCorner))
            .overlay {
                RoundedRectangle(cornerRadius: DataLook.tileCorner).strokeBorder(DataLook.rule, lineWidth: 1)
            }
    }
}

/// A row for a thing that is measured: a logo or a code, its name, then a
/// small line of its last readings before the figure. A row in a state takes
/// the colour in its line, its figure and one word.
struct DataReadingRow<Lead: View>: View {
    let name: String
    let value: String
    let unit: String
    var readings: [Double] = []
    var state: DataState?
    var word: String?
    @ViewBuilder var lead: Lead

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                lead
                Text(name).foregroundStyle(DataLook.ink)
            }
            Spacer(minLength: 8)
            if !readings.isEmpty {
                DataSparkline(readings: readings, state: state)
            }
            VStack(alignment: .trailing, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    if let state {
                        Image(systemName: state.symbol).font(.footnote)
                    }
                    Text(value).font(DataLook.figure)
                    Text(unit)
                        .font(DataLook.rowUnit)
                        .foregroundStyle(DataLook.ink2)
                }
                .foregroundStyle(state?.color ?? DataLook.ink)
                if let word {
                    Text(word)
                        .font(DataLook.comparison)
                        .foregroundStyle(state?.color ?? DataLook.ink2)
                }
            }
            .frame(minWidth: 76, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: DataLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(DataLook.rule).frame(height: 1)
        }
    }
}

/// Bars over time with a ringed dot for now. A bar over the limit takes the
/// bad colour; the rest have nothing to report and stay second ink.
struct DataBars: View {
    let values: [Double]
    let ceiling: Double
    let limit: Double

    var body: some View {
        Canvas { context, size in
            guard !values.isEmpty else { return }
            let step = size.width / Double(values.count)
            var grid = Path()
            grid.move(to: CGPoint(x: 0, y: 0.5)); grid.addLine(to: CGPoint(x: size.width, y: 0.5))
            grid.move(to: CGPoint(x: 0, y: size.height / 2)); grid.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            context.stroke(grid, with: .color(DataLook.rule), lineWidth: 1)
            var top = CGPoint.zero
            for (index, value) in values.enumerated() {
                let height = max(3, min(value, ceiling) / ceiling * size.height)
                let bar = CGRect(x: Double(index) * step + 1, y: size.height - height, width: step - 2, height: height)
                context.fill(Path(roundedRect: bar, cornerRadius: 1.5), with: .color(value > limit ? DataLook.bad : DataLook.ink2))
                top = CGPoint(x: min(bar.midX, size.width - 5), y: bar.minY - 7)
            }
            let ring = CGRect(x: top.x - 4, y: top.y - 4, width: 8, height: 8)
            context.fill(Path(ellipseIn: ring), with: .color(DataLook.ground))
            context.stroke(Path(ellipseIn: ring), with: .color(DataLook.ink), lineWidth: 2)
        }
        .frame(height: 80)
    }
}

/// The picture for a screen with nothing to show yet: a chart with no
/// readings, drawn in the look's own marks.
struct DataEmptyChart: View {
    var body: some View {
        Canvas { context, size in
            var axis = Path()
            axis.move(to: CGPoint(x: 4, y: 8)); axis.addLine(to: CGPoint(x: 4, y: size.height - 8))
            axis.addLine(to: CGPoint(x: size.width - 4, y: size.height - 8))
            context.stroke(axis, with: .color(DataLook.ink2), lineWidth: 1.5)
            var flat = Path()
            flat.move(to: CGPoint(x: 12, y: size.height - 20)); flat.addLine(to: CGPoint(x: size.width - 38, y: size.height - 20))
            context.stroke(flat, with: .color(DataLook.ink2), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, dash: [3, 5]))
            let ring = CGRect(x: size.width - 29, y: size.height - 25, width: 10, height: 10)
            context.fill(Path(ellipseIn: ring), with: .color(DataLook.ground))
            context.stroke(Path(ellipseIn: ring), with: .color(DataLook.ink), lineWidth: 2)
        }
        .frame(width: 200, height: 64)
    }
}

/// A person: their photograph, else their initials in a ring, else an empty
/// ring for nobody yet.
struct DataPersonMark<Photo: View>: View {
    private let initials: String?
    private let photo: Photo?

    init(photo: Photo) {
        self.photo = photo
        self.initials = nil
    }

    var body: some View {
        Group {
            if let photo {
                photo.clipShape(.circle)
            } else if let initials {
                Text(initials)
                    .font(DataLook.code)
                    .foregroundStyle(DataLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay { Circle().strokeBorder(DataLook.ink2, lineWidth: 1) }
            } else {
                Circle().strokeBorder(DataLook.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: DataLook.person, height: DataLook.person)
    }
}

extension DataPersonMark where Photo == EmptyView {
    /// With no photograph: initials, or `nil` for nobody yet.
    init(initials: String?) {
        self.photo = nil
        self.initials = initials
    }
}

/// A picture in a small frame with a hairline. Waiting and failed keep the
/// frame, so nothing moves when the picture comes.
struct DataPicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                DataLook.rule
            case .failed:
                DataLook.rule.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(DataLook.ink2)
                }
            }
        }
        .frame(width: DataLook.pictureSize.width, height: DataLook.pictureSize.height)
        .clipShape(.rect(cornerRadius: DataLook.pictureCorner))
        .overlay {
            RoundedRectangle(cornerRadius: DataLook.pictureCorner).strokeBorder(DataLook.rule, lineWidth: 1)
        }
    }
}

// MARK: Controls

/// The second kind of button: underlined words in ink. There is no third.
struct DataLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Face(isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(.subheadline)
                .fontWeight(.semibold)
                .underline(isEnabled)
                .foregroundStyle(isEnabled ? DataLook.ink : DataLook.ink2)
                .frame(minHeight: 44)
                .contentShape(.rect)
                .opacity(isPressed ? 0.5 : 1)
        }
    }
}

/// On or off, as a chip that says which. Filled ink when on, outlined when
/// off. The system's switch is green when on, and green means a good state
/// in this look.
struct DataOnOffToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                configuration.label
                    .foregroundStyle(DataLook.ink)
                Spacer(minLength: 12)
                Text(configuration.isOn ? "On" : "Off")
                    .font(DataLook.chip)
                    .foregroundStyle(configuration.isOn ? DataLook.ground : DataLook.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(configuration.isOn ? DataLook.ink : .clear, in: .capsule)
                    .overlay {
                        if !configuration.isOn {
                            Capsule().strokeBorder(DataLook.ink2, lineWidth: 1.5)
                        }
                    }
            }
            .frame(maxWidth: .infinity, minHeight: DataLook.rowMin)
            .contentShape(.rect)
        }
        .buttonStyle(DataRowPressStyle())
        .overlay(alignment: .top) {
            Rectangle().fill(DataLook.rule).frame(height: 1)
        }
    }
}

/// A text field is a row: its name at the left, what is typed at the right as
/// a figure with its unit. In use, the row stands on two points of ink. An
/// error is a mark and a reason under the figure, in ink: a state colour
/// would say something about the data, not about what was typed.
/// For words in place of a figure, leave the unit out and pass a keyboard
/// and a width.
struct DataFieldRow: View {
    let name: String
    @Binding var text: String
    var unit: String?
    var prompt = "0"
    var error: String?
    var keyboard = UIKeyboardType.numberPad
    var width = 120.0
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(name).foregroundStyle(DataLook.ink)
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(DataLook.ink2))
                        .font(DataLook.figure)
                        .foregroundStyle(DataLook.ink)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .onSubmit(onSubmit)
                        .frame(maxWidth: width)
                    if let unit {
                        Text(unit)
                            .font(DataLook.rowUnit)
                            .foregroundStyle(DataLook.ink2)
                    }
                }
                if let error {
                    Label(error, systemImage: "nosign")
                        .font(DataLook.meta)
                        .foregroundStyle(DataLook.ink)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: DataLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(DataLook.rule).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(DataLook.ink).frame(height: isFocused ? 2 : 0)
        }
        .contentShape(.rect)
        .onTapGesture { isFocused = true }
    }
}

/// A row that has not arrived: its shapes in the rule colour, with no state.
struct DataGhostRow: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4).fill(DataLook.rule).frame(width: 170, height: 12)
            Spacer()
            RoundedRectangle(cornerRadius: 4).fill(DataLook.rule).frame(width: 46, height: 12)
        }
        .frame(minHeight: DataLook.rowMin)
        .overlay(alignment: .top) {
            Rectangle().fill(DataLook.rule).frame(height: 1)
        }
    }
}
