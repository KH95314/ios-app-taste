import SwiftUI

// Direction 01 Quiet Native Minimalism: the rest of the look's parts.
// `QuietLook.swift` has the colours, the type roles, the sizes, the filled
// button and the notice. This file adds what a second and a third screen
// need: the look's own content parts first, then its controls.

// MARK: Content parts

/// The sentence under the title that stands in for a dashboard: what is left,
/// and what is late. Only the late part takes the alert colour.
struct QuietSummary: View {
    let left: String
    var late: String?

    var body: some View {
        Group {
            if let late {
                Text("\(left) · \(Text(late).fontWeight(.semibold).foregroundStyle(QuietLook.late))")
            } else {
                Text(left)
            }
        }
        .font(QuietLook.row)
        .foregroundStyle(QuietLook.ink2)
    }
}

/// One day in the week strip.
struct QuietDay: Identifiable {
    let id: Int
    let letter: String
    let due: Int
}

/// Seven dates on one line. The chosen date is an accent disc, since it can
/// be pressed. Dots under a date count what is due, three at most.
struct QuietWeek: View {
    let days: [QuietDay]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                Button {
                    selection = day.id
                } label: {
                    VStack(spacing: 4) {
                        Text(day.letter)
                            .font(QuietLook.detail)
                            .foregroundStyle(QuietLook.ink2)
                        Text(day.id, format: .number)
                            .font(.body)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(day.id == selection ? QuietLook.onAccent : QuietLook.ink)
                            .frame(width: QuietLook.dateDisc, height: QuietLook.dateDisc)
                            .background(day.id == selection ? QuietLook.accent : .clear, in: .circle)
                        HStack(spacing: 3) {
                            ForEach(0..<min(day.due, 3), id: \.self) { _ in
                                Circle().fill(QuietLook.mark).frame(width: 5, height: 5)
                            }
                        }
                        .frame(height: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// A small pie for how much of a group is done.
struct QuietPie: Shape {
    let fraction: Double

    func path(in rect: CGRect) -> Path {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path(ellipseIn: rect.insetBy(dx: 0.75, dy: 0.75)).strokedPath(StrokeStyle(lineWidth: 1.5))
        guard fraction > 0 else { return path }
        var wedge = Path()
        wedge.move(to: centre)
        wedge.addArc(
            center: centre, radius: radius - 3, startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * min(fraction, 1)), clockwise: false)
        wedge.closeSubpath()
        path.addPath(wedge)
        return path
    }
}

/// A group's head. When the group can be finished it carries a small pie and
/// a count at its end.
struct QuietGroupHead: View {
    let title: String
    var done: Int?
    var total: Int?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(QuietLook.heading)
            Spacer()
            if let done, let total, total > 0 {
                HStack(spacing: 6) {
                    QuietPie(fraction: Double(done) / Double(total))
                        .frame(width: 16, height: 16)
                    Text("\(done) of \(total)")
                        .monospacedDigit()
                }
                .font(QuietLook.detail)
                .foregroundStyle(QuietLook.ink2)
            }
        }
    }
}

/// A group's head when the group is a date: a large numeral with the weekday
/// in second ink, under a hairline and a gap.
struct QuietDateHead: View {
    let day: Int
    let weekday: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(day, format: .number)
                .font(QuietLook.dateNumeral)
                .monospacedDigit()
            Text(weekday)
                .foregroundStyle(QuietLook.ink2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle().fill(QuietLook.rule).frame(height: 1)
        }
        .padding(.top, QuietLook.groupGap)
    }
}

/// A person at the end of a row: their photograph, else their initial on the
/// look's fill, else a dashed disc for nobody yet.
struct QuietPersonMark<Photo: View>: View {
    private let initial: String?
    private let photo: Photo?
    var size = QuietLook.person

    init(photo: Photo, size: Double = QuietLook.person) {
        self.photo = photo
        self.initial = nil
        self.size = size
    }

    var body: some View {
        Group {
            if let photo {
                photo.clipShape(.circle)
            } else if let initial {
                Text(initial)
                    .font(QuietLook.initial)
                    .foregroundStyle(QuietLook.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(QuietLook.fill, in: .circle)
            } else {
                Circle().strokeBorder(QuietLook.mark, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
        }
        .frame(width: size, height: size)
    }
}

extension QuietPersonMark where Photo == EmptyView {
    /// With no photograph: an initial, or `nil` for nobody yet.
    init(initial: String?, size: Double = QuietLook.person) {
        self.photo = nil
        self.initial = initial
        self.size = size
    }
}

/// A thing to do: a circle to tick, a name, one detail line, and at its end
/// the person it belongs to. Nothing else marks a row: no box, no colour, no
/// line of its own.
struct QuietTaskRow<Person: View>: View {
    let name: String
    let detail: String
    var isLate = false
    let isDone: Bool
    let toggle: () -> Void
    @ViewBuilder var person: Person

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button(action: toggle) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isDone ? QuietLook.accent : QuietLook.mark)
                    .frame(width: QuietLook.rowMin, height: QuietLook.rowMin)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("tick")
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(QuietLook.row)
                    .strikethrough(isDone)
                    .foregroundStyle(isDone ? QuietLook.ink2 : QuietLook.ink)
                Group {
                    if isLate && !isDone {
                        Text("\(Text("\(Image(systemName: "exclamationmark.circle.fill")) Overdue").fontWeight(.semibold).foregroundStyle(QuietLook.late)) · \(detail)")
                    } else {
                        Text(detail)
                    }
                }
                .font(QuietLook.detail)
                .foregroundStyle(QuietLook.ink2)
            }
            .padding(.vertical, 7)
            Spacer(minLength: 12)
            person
                .padding(.top, 9)
        }
        .padding(.leading, -10)
    }
}

/// A row that names a setting: a name, and at its end a value in second ink.
/// A row that opens something adds the system's chevron.
struct QuietValueRow<Lead: View>: View {
    let name: String
    var value: String?
    var opens = false
    @ViewBuilder var lead: Lead

    var body: some View {
        HStack(spacing: 10) {
            lead
            Text(name)
                .font(QuietLook.row)
            Spacer(minLength: 12)
            if let value {
                Text(value)
                    .foregroundStyle(QuietLook.ink2)
            }
            if opens {
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(QuietLook.mark)
            }
        }
        .frame(minHeight: QuietLook.rowMin)
        .contentShape(.rect)
    }
}

extension QuietValueRow where Lead == EmptyView {
    init(name: String, value: String? = nil, opens: Bool = false) {
        self.init(name: name, value: value, opens: opens) { EmptyView() }
    }
}

/// A picture on a row: a small square with an 8 corner, never a banner.
/// Waiting, it is a square of the look's fill; if it cannot load, the same
/// square with a mark, and no red.
struct QuietPicture: View {
    let form: PictureForm

    var body: some View {
        Group {
            switch form {
            case .loaded(let picture):
                picture.resizable().scaledToFill()
            case .waiting:
                QuietLook.fill
            case .failed:
                QuietLook.fill.overlay {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(QuietLook.ink2)
                }
            }
        }
        .frame(width: QuietLook.picture, height: QuietLook.picture)
        .clipShape(.rect(cornerRadius: QuietLook.pictureCorner))
    }
}

/// The tile another company's logo sits on. The logo keeps its own colours.
struct QuietLogoTile<Logo: View>: View {
    @ViewBuilder var logo: Logo

    var body: some View {
        logo
            .padding(4)
            .frame(width: QuietLook.tile, height: QuietLook.tile)
            .background(QuietLook.plate, in: .rect(cornerRadius: QuietLook.tileCorner))
            .overlay {
                RoundedRectangle(cornerRadius: QuietLook.tileCorner).strokeBorder(QuietLook.rule, lineWidth: 1)
            }
    }
}

/// The picture for a list with nothing in it: the list that is not there,
/// fading, drawn in the look's own marks.
struct QuietGhostList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            line(width: 130, circle: QuietLook.mark)
            line(width: 92, circle: QuietLook.mark.opacity(0.55))
            line(width: 58, circle: QuietLook.rule)
        }
        .frame(width: 160, alignment: .leading)
    }

    private func line(width: Double, circle: Color) -> some View {
        HStack(spacing: 10) {
            Circle().strokeBorder(circle, lineWidth: 1.5).frame(width: 20, height: 20)
            RoundedRectangle(cornerRadius: 4).fill(QuietLook.fill).frame(width: width, height: 8)
        }
    }
}

// MARK: Controls

/// The second kind of button: words in the accent, with no box. There is no
/// third kind.
struct QuietTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Face(isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(QuietLook.secondButton)
                .foregroundStyle(isEnabled ? QuietLook.accent : QuietLook.ink2)
                .frame(minHeight: 44)
                .contentShape(.rect)
                .opacity(isPressed ? 0.5 : 1)
        }
    }
}

/// One of a few: a row, with a tick at the end of the chosen one.
struct QuietChoiceRow: View {
    let name: String
    let isChosen: Bool
    let choose: () -> Void

    var body: some View {
        Button(action: choose) {
            HStack {
                Text(name)
                    .font(QuietLook.row)
                    .foregroundStyle(QuietLook.ink)
                Spacer()
                if isChosen {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(QuietLook.accent)
                }
            }
            .frame(minHeight: QuietLook.rowMin)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

/// A text field: its name above, the text on a line. In use, the line is two
/// points of the accent. An error is an icon and a reason under the line in
/// the alert colour; the line keeps its own.
/// Where the screen's title already names the one field on it, leave the
/// name off (`showsName: false`): it would say the title twice.
struct QuietField: View {
    let name: String
    @Binding var text: String
    var prompt = ""
    var error: String?
    var showsName = true
    var onSubmit: () -> Void = {}
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsName {
                Text(name)
                    .font(QuietLook.detail)
                    .foregroundStyle(QuietLook.ink2)
            }
            TextField(name, text: $text, prompt: Text(prompt).foregroundStyle(QuietLook.ink2))
                .font(QuietLook.row)
                .tint(QuietLook.accent)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .frame(minHeight: 40)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isFocused ? QuietLook.accent : QuietLook.mark)
                        .frame(height: isFocused ? 2 : 1)
                }
            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(QuietLook.detail)
                    .foregroundStyle(QuietLook.late)
                    .padding(.top, 6)
            }
        }
    }
}

/// A row that has not arrived: its shapes in the look's fill.
struct QuietGhostRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6).fill(QuietLook.fill).frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: 7) {
                RoundedRectangle(cornerRadius: 4).fill(QuietLook.fill).frame(width: 190, height: 12)
                RoundedRectangle(cornerRadius: 4).fill(QuietLook.fill).frame(width: 112, height: 8)
            }
        }
        .frame(maxWidth: .infinity, minHeight: QuietLook.rowMin, alignment: .leading)
    }
}
