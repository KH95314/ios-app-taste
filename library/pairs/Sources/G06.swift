import SwiftUI

// G6. One name and one icon for one thing.
// A recipe box. Keeping a recipe is the same act wherever it is shown.
// Each side shows the three places that act appears: the list, the recipe
// and the tab that collects what was kept.

/// Bad on purpose: one act under three names and three icons. A heart called
/// "Favourite" in the list, a bookmark called "Save to collection" on the
/// recipe, and a star called "Starred" on the tab. Both controls work, and
/// both change the same thing.
struct G06Bad: View {
    @State private var saved = false

    var body: some View {
        PairPage {
            PairHead("In the list")
            PairRow(name: "Braised leeks with mustard", detail: "35 min") {
                Button {
                    saved.toggle()
                } label: {
                    Label("Favourite", systemImage: saved ? "heart.fill" : "heart")
                        .labelStyle(.iconOnly)
                        .font(PairLook.title)
                        .foregroundStyle(PairLook.accent)
                        .frame(minWidth: PairLook.hit, minHeight: PairLook.hit)
                }
            }

            PairHead("On the recipe").padding(.top, PairLook.groupGap)
            HStack(alignment: .firstTextBaseline) {
                Text("Braised leeks with mustard").font(PairLook.title).foregroundStyle(PairLook.ink)
                Spacer(minLength: PairLook.rowGap)
                Button {
                    saved.toggle()
                } label: {
                    Label(saved ? "Saved to collection" : "Save to collection",
                          systemImage: saved ? "bookmark.fill" : "bookmark")
                        .font(PairLook.small)
                        .foregroundStyle(PairLook.accent)
                        .frame(minHeight: PairLook.hit)
                }
            }

            PairHead("The tab that collects them").padding(.top, PairLook.groupGap)
            Label("Starred", systemImage: "star.fill").font(PairLook.body).foregroundStyle(PairLook.ink)
        }
    }
}

/// Good: one word, "Saved", and one icon, a bookmark, in all three places.
/// The icon fills when the recipe is saved; that is its only change.
struct G06Good: View {
    @State private var saved = false

    var body: some View {
        PairPage {
            PairHead("In the list")
            PairRow(name: "Braised leeks with mustard", detail: "35 min") { toggle }

            PairHead("On the recipe").padding(.top, PairLook.groupGap)
            HStack(alignment: .firstTextBaseline) {
                Text("Braised leeks with mustard").font(PairLook.title).foregroundStyle(PairLook.ink)
                Spacer(minLength: PairLook.rowGap)
                toggle
            }

            PairHead("The tab that collects them").padding(.top, PairLook.groupGap)
            Label("Saved", systemImage: "bookmark.fill").font(PairLook.body).foregroundStyle(PairLook.ink)
        }
    }

    private var toggle: some View {
        Button {
            saved.toggle()
        } label: {
            Label(saved ? "Saved" : "Save", systemImage: saved ? "bookmark.fill" : "bookmark")
                .labelStyle(.iconOnly)
                .font(PairLook.title)
                .foregroundStyle(PairLook.accent)
                .frame(minWidth: PairLook.hit, minHeight: PairLook.hit)
        }
    }
}
