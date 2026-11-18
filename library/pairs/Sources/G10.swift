import SwiftUI

// G10. Not laid out for one screenshot.
// Tickets someone holds. One event has a long name, and the phone is small.
// Look at this pair on the smallest iPhone the app supports.

private struct Ticket: Identifiable {
    let id = UUID()
    let event: String
    let when: String
    let seat: String
}

private let tickets = [
    Ticket(event: "The Lantern Quarter Night Market and Street Food Fair", when: "Sat, Nov 21 · 6:00 PM", seat: "Entry B"),
    Ticket(event: "Low Tide", when: "Thu, Dec 3 · 8:30 PM", seat: "Row F, seat 12"),
    Ticket(event: "An Evening with the Harbour Choir", when: "Sun, Dec 13 · 4:00 PM", seat: "Stalls, unreserved"),
    Ticket(event: "Winter Film Night: The Red Balloon", when: "Fri, Dec 18 · 7:15 PM", seat: "Row C, seats 4 and 5"),
]

/// Bad on purpose: every row is a fixed width and height, names and seats are
/// held to one line, and the button comes after a fixed gap. All of it was
/// sized on one taller phone, with short names in mind.
struct G10Bad: View {
    @State private var held = tickets

    var body: some View {
        VStack(spacing: 0) {
            PairHead("Tickets").frame(width: 362)
            ForEach(held) { ticket in
                HStack(spacing: PairLook.rowGap) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ticket.event).font(PairLook.body).foregroundStyle(PairLook.ink).lineLimit(1)
                        Text(ticket.when).font(PairLook.small).foregroundStyle(PairLook.quiet).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Text(ticket.seat)
                        .font(PairLook.small)
                        .foregroundStyle(PairLook.quiet)
                        .lineLimit(1)
                        .frame(width: 110, alignment: .trailing)
                }
                .frame(width: 362, height: 64)
                Rectangle().fill(PairLook.rule).frame(width: 362, height: 1)
            }
            Spacer().frame(height: 300)
            Button {
                held.append(Ticket(event: "New Year Ceilidh", when: "Thu, Dec 31 · 9:00 PM", seat: "Entry A"))
            } label: {
                Label("Add a ticket", systemImage: "plus")
            }
            .buttonStyle(PairMainButton())
            .frame(width: 362)
        }
        .padding(.top, PairLook.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(PairLook.ground)
    }
}

/// Good: rows take the height their words need, a long name runs to a second
/// line, and the button is held at the bottom whatever is above it.
struct G10Good: View {
    @State private var held = tickets

    var body: some View {
        PairPage {
            PairHead("Tickets")
            ForEach(held) { ticket in
                PairRow(name: ticket.event, detail: "\(ticket.when)\n\(ticket.seat)") { EmptyView() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                held.append(Ticket(event: "New Year Ceilidh", when: "Thu, Dec 31 · 9:00 PM", seat: "Entry A"))
            } label: {
                Label("Add a ticket", systemImage: "plus")
            }
            .buttonStyle(PairMainButton())
            .padding(.horizontal, PairLook.margin)
            .padding(.vertical, PairLook.rowGap)
            .frame(maxWidth: .infinity)
            .background(PairLook.ground)
        }
    }
}
