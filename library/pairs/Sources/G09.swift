import SwiftUI

// G9. System parts for the jobs they are made for.
// A notes app, with one note open.

private let noteText = """
Seed order for the allotment

Broad beans, two packets. Chard. The purple carrots that Ines liked. \
Ask at the hut whether the water is back on before April.
"""

/// Bad on purpose: a tab bar whose tabs are actions. It looks like a way to
/// move between places; pressing "Delete" would act on the note.
struct G09Bad: View {
    @State private var text = noteText

    var body: some View {
        TabView {
            Tab("Save", systemImage: "square.and.arrow.down") { note }
            Tab("Share", systemImage: "square.and.arrow.up") { note }
            Tab("Delete", systemImage: "trash") { note }
        }
        .tint(PairLook.accent)
    }

    private var note: some View {
        TextEditor(text: $text)
            .font(PairLook.body)
            .foregroundStyle(PairLook.ink)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, PairLook.margin)
            .background(PairLook.ground)
    }
}

/// Good: the tab bar holds the app's two places. What acts on this note is
/// in the bar above it. There is no save control: the note is kept as it is typed.
struct G09Good: View {
    @State private var text = noteText

    var body: some View {
        TabView {
            Tab("Notes", systemImage: "note.text") {
                NavigationStack {
                    TextEditor(text: $text)
                        .font(PairLook.body)
                        .foregroundStyle(PairLook.ink)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, PairLook.margin)
                        .background(PairLook.ground)
                        .toolbar {
                            ToolbarItemGroup(placement: .topBarTrailing) {
                                ShareLink(item: text)
                                Button("Delete", systemImage: "trash", role: .destructive) { text = "" }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchPlace(text: text)
                }
            }
        }
        .tint(PairLook.accent)
    }
}

/// The second place: finds a word in the one note this sample has.
private struct SearchPlace: View {
    let text: String
    @State private var query = ""

    private var lines: [String] {
        guard !query.isEmpty else { return [] }
        return text.split(separator: "\n").map(String.init).filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List(lines, id: \.self) { line in
            Text(line).font(PairLook.body).foregroundStyle(PairLook.ink)
        }
        .scrollContentBackground(.hidden)
        .background(PairLook.ground)
        .searchable(text: $query, prompt: "Search notes")
        .navigationTitle("Search")
    }
}
