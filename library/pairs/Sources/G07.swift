import SwiftUI

// G7. A failure says what failed and what to do.
// A parcel tracker whose courier cannot be reached. Both sides show that moment.

private struct Parcel: Identifiable {
    let id = UUID()
    let from: String
    let status: String
    let due: String
}

private let lastKnown = [
    Parcel(from: "Fennel & Rye Bakery Supplies", status: "Out for delivery", due: "Today"),
    Parcel(from: "Kestrel Books", status: "At the depot", due: "Thursday"),
    Parcel(from: "Marlow Cycle Parts", status: "Label created", due: "Next week"),
]

/// Bad on purpose: the list is thrown away, and what replaces it names no
/// cause and offers nothing to press.
struct G07Bad: View {
    var body: some View {
        PairPage {
            PairHead("Parcels")
            VStack(spacing: PairLook.rowGap) {
                Image(systemName: "exclamationmark.triangle.fill").font(PairLook.figure).foregroundStyle(PairLook.failed)
                Text("Oops!").font(PairLook.title).foregroundStyle(PairLook.ink)
                Text("Something went wrong. Please try again later.")
                    .font(PairLook.body)
                    .foregroundStyle(PairLook.quiet)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 150)
        }
    }
}

/// Good: the cause, one way to try again, and the last list kept on screen
/// with the time it was true.
struct G07Good: View {
    @State private var reaching = false

    var body: some View {
        PairPage {
            HStack(spacing: PairLook.rowGap) {
                Label("Can't reach the courier", systemImage: "wifi.slash")
                    .font(PairLook.strong)
                    .foregroundStyle(PairLook.failed)
                Spacer(minLength: PairLook.rowGap)
                Button(reaching ? "Trying…" : "Try again") {
                    reaching = true
                    Task {
                        // Long enough to see, and for a UI test to catch.
                        try? await Task.sleep(for: .seconds(2.5))
                        reaching = false
                    }
                }
                .font(PairLook.strong)
                .foregroundStyle(PairLook.accent)
                .frame(minHeight: PairLook.hit)
                .disabled(reaching)
            }
            .padding(.bottom, PairLook.groupGap)

            PairHead("Parcels, as of 8:12 AM")
            ForEach(lastKnown) { parcel in
                PairRow(name: parcel.from, detail: parcel.status) {
                    Text(parcel.due).font(PairLook.small).foregroundStyle(PairLook.quiet)
                }
            }
        }
    }
}
