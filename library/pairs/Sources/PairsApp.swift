import SwiftUI

// One bad and one good screen for each guard rule from G3 to G11
// (../../../references/guard-rules.md). The bad side is what the rule stops;
// the good side is the same product, the same content and the same look with
// the rule applied. Each pair is an invented product. None is a library entry.
//
// Open one side from the command line:
//
//     xcrun simctl launch <device> dev.iostaste.pairs -pair g03 -side bad
//
// With no arguments the app lists every pair.

@main
struct PairsApp: App {
    var body: some Scene {
        WindowGroup { PairRoot() }
    }
}

struct Pair: Identifiable {
    let id: String
    let rule: String
    let bad: AnyView
    let good: AnyView
}

enum Pairs {
    static let all: [Pair] = [
        Pair(id: "g03", rule: "G3. Decoration never outranks content", bad: AnyView(G03Bad()), good: AnyView(G03Good())),
        Pair(id: "g04", rule: "G4. Real words and figures that agree", bad: AnyView(G04Bad()), good: AnyView(G04Good())),
        Pair(id: "g05", rule: "G5. No control that does nothing", bad: AnyView(G05Bad()), good: AnyView(G05Good())),
        Pair(id: "g06", rule: "G6. One name and one icon for one thing", bad: AnyView(G06Bad()), good: AnyView(G06Good())),
        Pair(id: "g07", rule: "G7. A failure says what failed and what to do", bad: AnyView(G07Bad()), good: AnyView(G07Good())),
        Pair(id: "g08", rule: "G8. Readable and pressable before pretty", bad: AnyView(G08Bad()), good: AnyView(G08Good())),
        Pair(id: "g09", rule: "G9. System parts for the jobs they are made for", bad: AnyView(G09Bad()), good: AnyView(G09Good())),
        Pair(id: "g10", rule: "G10. Not laid out for one screenshot", bad: AnyView(G10Bad()), good: AnyView(G10Good())),
        Pair(id: "g11", rule: "G11. No ceremony before the job", bad: AnyView(G11Bad()), good: AnyView(G11Good())),
    ]
}

struct PairRoot: View {
    private let pair = UserDefaults.standard.string(forKey: "pair")
    private let side = UserDefaults.standard.string(forKey: "side") ?? "good"

    var body: some View {
        if let entry = Pairs.all.first(where: { $0.id == pair }) {
            if side == "bad" { entry.bad } else { entry.good }
        } else {
            NavigationStack {
                List(Pairs.all) { entry in
                    Section(entry.rule) {
                        NavigationLink("Bad") { entry.bad }
                        NavigationLink("Good") { entry.good }
                    }
                }
                .navigationTitle("Guard rule pairs")
            }
        }
    }
}
