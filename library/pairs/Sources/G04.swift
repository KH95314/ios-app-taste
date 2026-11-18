import SwiftUI

// G4. Real words and figures that agree.
// A plant-watering log. Both sides are drawn in the same look and with the
// same chart. What differs is whether the words and the figures are real.

private struct Plant: Identifiable {
    let id = UUID()
    let name: String
    let place: String
    /// Days between waterings.
    let every: Int
    let lastDaysAgo: Int
    /// How the list words `lastDaysAgo`.
    let last: String
    let millilitres: Int
}

/// The sample's clock: Tuesday, November 17, 2026.
private let today = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2026, month: 11, day: 17).date!

private let plants = [
    Plant(name: "Monstera deliciosa", place: "Living room", every: 7, lastDaysAgo: 2, last: "Sunday", millilitres: 600),
    Plant(name: "Calathea orbifolia", place: "Bedroom", every: 4, lastDaysAgo: 1, last: "Yesterday", millilitres: 250),
    Plant(name: "Fiddle-leaf fig", place: "Hallway, by the door", every: 10, lastDaysAgo: 12, last: "12 days ago",
          millilitres: 900),
]

private struct Week {
    /// The week's first day, as the chart words it.
    let start: String
    let litres: Double
}

/// Water given in each of the last six weeks, oldest first. Nothing here is
/// typed in: each total is worked out from a plant's amount, its interval and
/// the day it was last watered, so the chart cannot disagree with the list.
private let weeks: [Week] = (0..<6).reversed().map { week in
    let daysAgo = (week * 7)...(week * 7 + 6)
    let millilitres = plants.reduce(0) { sum, plant in
        let waterings = daysAgo.filter { $0 >= plant.lastDaysAgo && ($0 - plant.lastDaysAgo) % plant.every == 0 }
        return sum + plant.millilitres * waterings.count
    }
    let start = Calendar(identifier: .gregorian).date(byAdding: .day, value: -(week * 7 + 6), to: today)!
    let name = start.formatted(.dateTime.month(.abbreviated).day().locale(Locale(identifier: "en_US")))
    return Week(start: name, litres: Double(millilitres) / 1000)
}

/// Columns on one baseline. Both sides draw their chart with this.
private struct Columns: View {
    let values: [Double]
    var tops: [String] = []
    var feet: [String] = []

    var body: some View {
        let largest = values.max() ?? 1
        HStack(alignment: .bottom, spacing: PairLook.rowGap) {
            ForEach(values.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    if index < tops.count {
                        Text(tops[index]).font(PairLook.note).monospacedDigit().foregroundStyle(PairLook.ink)
                    }
                    UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4)
                        .fill(PairLook.ink)
                        .frame(height: max(2, 120 * values[index] / largest))
                    if index < feet.count {
                        Text(feet[index]).font(PairLook.note).foregroundStyle(PairLook.quiet)
                    }
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

/// Bad on purpose: placeholder words, a count that disagrees with the list,
/// a chart with no unit and no dates, a change against a period nobody named,
/// and a made-up person.
struct G04Bad: View {
    var body: some View {
        PairPage {
            PairHead("12 plants")
            PairRow(name: "Plant Name", detail: "Lorem ipsum dolor sit amet") { EmptyView() }
            PairRow(name: "Item 2", detail: "Description goes here") { EmptyView() }
            PairRow(name: "Item 3", detail: "Description goes here") { EmptyView() }

            PairHead("Activity").padding(.top, PairLook.groupGap)
            Columns(values: [40, 75, 30, 90, 55, 65, 20])
            Text("+23.5% vs last period")
                .font(PairLook.small)
                .foregroundStyle(PairLook.quiet)
                .padding(.top, PairLook.rowGap)

            PairHead("Owner").padding(.top, PairLook.groupGap)
            Label("John Doe", systemImage: "person.crop.circle.fill").font(PairLook.body).foregroundStyle(PairLook.ink)
        }
    }
}

/// Good: real names at real lengths, a count taken from the list, and a
/// chart that says what it measures, in what unit and for which weeks.
struct G04Good: View {
    var body: some View {
        PairPage {
            PairHead("\(plants.count) plants")
            ForEach(plants) { plant in
                PairRow(name: plant.name, detail: "\(plant.place) · every \(plant.every) days") {
                    Text(plant.last).font(PairLook.small).foregroundStyle(PairLook.quiet)
                }
            }

            PairHead("Water given each week, litres").padding(.top, PairLook.groupGap)
            Columns(values: weeks.map { $0.litres },
                    tops: weeks.map { $0.litres.formatted(.number.precision(.fractionLength(0...2))) },
                    feet: weeks.map { $0.start })
        }
    }
}
