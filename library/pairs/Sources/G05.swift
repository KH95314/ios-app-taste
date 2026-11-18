import SwiftUI

// G5. No control that does nothing.
// A reading list.

private struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    var finished = false
}

private let shelf = [
    Book(title: "The Living Mountain", author: "Nan Shepherd"),
    Book(title: "A Month in the Country", author: "J. L. Carr", finished: true),
    Book(title: "The Summer Book", author: "Tove Jansson"),
]

/// Bad on purpose: a search field, a filter, a sort menu, an export button, a
/// menu on every row and "Sync with cloud". Each is drawn as carefully as a
/// working control, and each has an empty action. Only the list is real.
struct G05Bad: View {
    @State private var query = ""

    var body: some View {
        PairPage {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                PairHead("Reading list")
                icon("line.3.horizontal.decrease")
                icon("arrow.up.arrow.down")
                icon("square.and.arrow.up")
            }
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(PairLook.quiet)
                TextField("", text: $query, prompt: Text("Search books").foregroundStyle(PairLook.quiet))
                    .foregroundStyle(PairLook.ink)
            }
            .font(PairLook.body)
            .padding(.horizontal, PairLook.rowGap)
            .frame(minHeight: PairLook.hit)
            .background(PairLook.rule, in: .rect(cornerRadius: PairLook.corner))
            .padding(.bottom, PairLook.rowGap)

            ForEach(shelf) { book in
                PairRow(name: book.title, detail: book.author) {
                    if book.finished {
                        Label("Finished", systemImage: "checkmark").font(PairLook.small).foregroundStyle(PairLook.quiet)
                    }
                    icon("ellipsis")
                }
            }
            Button("Sync with cloud") {}
                .buttonStyle(PairMainButton())
                .padding(.top, PairLook.groupGap)
        }
    }

    private func icon(_ name: String) -> some View {
        Button {} label: {
            Image(systemName: name)
                .font(PairLook.body)
                .foregroundStyle(PairLook.accent)
                .frame(width: PairLook.hit, height: PairLook.hit)
        }
    }
}

/// Good: two controls, and both work. Pressing a row marks the book finished;
/// the button adds a book. Search, sorting and export are not built, so they
/// are not drawn.
struct G05Good: View {
    @State private var books = shelf

    var body: some View {
        PairPage {
            PairHead("Reading list")
            ForEach($books) { $book in
                Button {
                    book.finished.toggle()
                } label: {
                    PairRow(name: book.title, detail: book.author) {
                        if book.finished {
                            Label("Finished", systemImage: "checkmark").font(PairLook.small).foregroundStyle(PairLook.quiet)
                        }
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
            Button {
                books.append(Book(title: "Pilgrim at Tinker Creek", author: "Annie Dillard"))
            } label: {
                Label("Add a book", systemImage: "plus")
            }
            .buttonStyle(PairMainButton())
            .padding(.top, PairLook.groupGap)
        }
    }
}
