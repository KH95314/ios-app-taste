import SwiftUI

// G3. Decoration never outranks content.
// A transit fare card. People open it to see the balance and top it up.
// Both sides are drawn in the same look. What differs is what comes first.

private struct Trip: Identifiable {
    let id = UUID()
    let route: String
    let when: String
    let fare: String
}

private let trips = [
    Trip(route: "Harbour Road to Mill Street", when: "Today, 8:14 AM", fare: "£1.75"),
    Trip(route: "Mill Street to Harbour Road", when: "Yesterday, 5:52 PM", fare: "£1.75"),
    Trip(route: "Harbour Road to Northgate", when: "Yesterday, 8:09 AM", fare: "£2.40"),
]

/// Bad on purpose: a picture and a slogan that say nothing about this card
/// take the first screenful. The balance and the way to top it up are small
/// and at the bottom, and the trips are pushed off the screen.
struct G03Bad: View {
    @State private var balance: Decimal = 12.40

    var body: some View {
        VStack(spacing: PairLook.rowGap) {
            Spacer()
            Image(systemName: "tram.fill").font(.system(size: 120)).foregroundStyle(PairLook.ink)
                .padding(.bottom, PairLook.rowGap)
            Text("Your journey, simplified.").font(PairLook.title).foregroundStyle(PairLook.ink)
            Text("Tap. Ride. Repeat.").font(PairLook.body).foregroundStyle(PairLook.quiet)
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle().fill(index == 0 ? PairLook.ink : PairLook.rule).frame(width: 7)
                }
            }
            .padding(.top, PairLook.rowGap)
            Spacer()
            Spacer()
            HStack {
                Text("Balance: \(balance.formatted(.currency(code: "GBP")))")
                    .font(PairLook.note)
                    .foregroundStyle(PairLook.quiet)
                Spacer()
                Button("Top up") { balance += 10 }
                    .font(PairLook.note)
                    .foregroundStyle(PairLook.accent)
                    .frame(minHeight: PairLook.hit)
            }
        }
        .padding(.horizontal, PairLook.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PairLook.ground)
    }
}

/// Good: the balance is the largest thing, the action is under it, and the
/// trips that explain the balance follow. Nothing is there to be looked at only.
struct G03Good: View {
    @State private var balance: Decimal = 12.40

    var body: some View {
        PairPage {
            PairHead("Balance")
            Text(balance.formatted(.currency(code: "GBP"))).font(PairLook.figure).foregroundStyle(PairLook.ink)
            Text("About 7 trips at £1.75")
                .font(PairLook.small)
                .foregroundStyle(PairLook.quiet)
                .padding(.bottom, PairLook.margin)
            Button("Top up £10") { balance += 10 }
                .buttonStyle(PairMainButton())
                .padding(.bottom, PairLook.groupGap)

            PairHead("Recent trips")
            ForEach(trips) { trip in
                PairRow(name: trip.route, detail: trip.when) {
                    Text(trip.fare).font(PairLook.body).monospacedDigit().foregroundStyle(PairLook.ink)
                }
            }
        }
    }
}
