import SwiftUI
import UIKit

// Pattern: a long read with quiet tools
// Direction 02 Editorial Reading · kind: reader · look: ReadingLook.swift
// Sample product (invented): a read-later app showing one saved essay.

struct Passage: Identifiable, Equatable {
    enum Kind { case paragraph, heading, quotation }

    let id: Int
    var kind = Kind.paragraph
    var text: String
    /// A phrase inside `text` that links somewhere.
    var linkPhrase: String?
    var linkURL: URL?
    /// The part of `text` the reader has highlighted, if any.
    var highlight: String?
}

struct Essay: Equatable {
    var publication: String
    var title: String
    var author: String
    var minutes: Int
    var passages: [Passage]
    var isBookmarked = false
}

struct LongReadScreen: View {
    @State private var phase: Phase<Essay>
    @State private var showsTools: Bool
    @State private var progress = 0.0
    @State private var textScale = 1.0
    @State private var position = ScrollPosition(edge: .top)
    /// Where the reader last turned round. The tools change only once the
    /// page has moved `turn` points the other way from here.
    @State private var turnedAt = 0.0
    private let startsMidway: Bool

    /// A deliberate turn, and more than the bar's own height. When the bar
    /// still moved the text as it came and went, a smaller step let the two
    /// chase each other for ever, and the screen froze on the first scroll.
    private static let turn = 72.0

    /// The navigation bar's height. 54 points on iOS 26; measured again
    /// whenever the bar is showing, in case it is something else.
    @State private var barRoom = 54.0

    /// The top safe area with the bar away: the status bar alone. Read from
    /// the window, which does not count the navigation bar, so that it is
    /// known before the first layout and never changes.
    private var statusRoom: Double {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return Double(scenes.first?.keyWindow?.safeAreaInsets.top ?? 0)
    }
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    /// `startsMidway` opens the essay part-way through with the tools hidden,
    /// the way it looks while someone is reading.
    init(phase: Phase<Essay>, startsMidway: Bool = false) {
        _phase = State(initialValue: phase)
        _showsTools = State(initialValue: !startsMidway)
        self.startsMidway = startsMidway
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ReadingLook.paper)
                .onGeometryChange(for: Double.self) { $0.safeAreaInsets.top } action: { inset in
                    if showsTools, inset > statusRoom { barRoom = inset - statusRoom }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                    if let essay {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            // The reader's own size, on top of the system text size.
                            Menu("Text size", systemImage: "textformat.size") {
                                Button("Larger text", systemImage: "textformat.size.larger") {
                                    textScale = min(textScale + 0.1, 1.4)
                                }
                                .disabled(textScale >= 1.4)
                                Button("Smaller text", systemImage: "textformat.size.smaller") {
                                    textScale = max(textScale - 0.1, 0.8)
                                }
                                .disabled(textScale <= 0.8)
                            }
                            // The filled glyph is the confirmation. No message follows.
                            Button(essay.isBookmarked ? "Remove bookmark" : "Bookmark",
                                   systemImage: essay.isBookmarked ? "bookmark.fill" : "bookmark",
                                   action: toggleBookmark)
                        }
                    }
                }
                .toolbarVisibility(showsTools ? .visible : .hidden, for: .navigationBar)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: showsTools)
        }
        // Bar buttons are ink. The hue is kept for links inside the text.
        .tint(ReadingLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            article(.placeholder, notice: nil)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading the article")
        case .empty:
            // The page was saved but nothing in it could be turned into text.
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("This page has no readable text", systemImage: "doc.plaintext")
                } actions: {
                    Button("Open the original", action: {})
                        .buttonStyle(ReadingLinkButtonStyle())
                }
                .fontDesign(.serif)
            }
        case .loaded(let essay):
            article(essay, notice: nil)
        case .failed(let message, let stale?):
            article(stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't load the article", systemImage: "wifi.slash")
                } description: {
                    // The system's grey for this line is about 3.5:1. The look's
                    // second ink holds 4.5:1.
                    Text(message)
                        .foregroundStyle(ReadingLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(ReadingLinkButtonStyle())
                }
                .fontDesign(.serif)
            }
        }
    }

    private func article(_ essay: Essay, notice: String?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let notice {
                    ReadingNotice(title: "You're offline", message: notice, retry: retry)
                        .padding(.bottom, 20)
                }
                EssayHead(essay: essay)
                ForEach(essay.passages) { passage in
                    PassageView(
                        passage: passage,
                        scale: textScale,
                        followsHeading: essay.followsHeading(passage)
                    ) { toggleHighlight(passage) }
                }
            }
            .scrollTargetLayout()
            // A wider margin than the usual 16 pt shortens the line. At the
            // accessibility sizes the words need the width more than the page
            // needs the margin.
            .padding(.horizontal, typeSize.isAccessibilitySize ? 16 : 24)
            // Room for the bar at the head of the page. It scrolls away with
            // the page; further down, the bar lies over the text.
            .padding(.top, 12 + barRoom)
            .padding(.bottom, 48)
            // On a wide screen the column stops growing; the margins take the rest.
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
            .onTapGesture { showsTools.toggle() }
            .tint(ReadingLook.accent)
        }
        // The text keeps its place when the bar comes and goes. The scroll
        // view takes no notice of the bar: it runs to the top of the screen
        // and keeps the status bar's room itself. Left to follow the safe
        // area, the text jumped by the bar's height each time.
        .contentMargins(.top, statusRoom, for: .scrollContent)
        .ignoresSafeArea(.container, edges: .top)
        .scrollPosition($position, anchor: .top)
        .task {
            guard startsMidway else { return }
            position.scrollTo(id: 3, anchor: .top)
            showsTools = false
        }
        .onScrollGeometryChange(for: ScrollState.self) { geometry in
            ScrollState(geometry)
        } action: { old, new in
            progress = new.progress
            // The tools leave when the reader moves on and return when they
            // scroll back. Rubber-banding at either end is ignored.
            guard !new.isBouncing else { return }
            if showsTools {
                turnedAt = min(turnedAt, new.offset)
                if new.offset > turnedAt + Self.turn, new.offset > 80 {
                    showsTools = false
                    turnedAt = new.offset
                }
            } else {
                turnedAt = max(turnedAt, new.offset)
                if new.offset < turnedAt - Self.turn {
                    showsTools = true
                    turnedAt = new.offset
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ReadingBar(progress: progress, timeLeft: showsTools ? timeLeft(in: essay) : nil)
        }
        // With the bar hidden, the text would scroll up behind the clock.
        // A strip of paper over the top safe area keeps the two apart.
        .overlay {
            GeometryReader { proxy in
                ReadingLook.paper
                    .frame(height: proxy.safeAreaInsets.top)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(edges: .top)
            }
            .allowsHitTesting(false)
        }
    }

    private var essay: Essay? {
        switch phase {
        case .loaded(let essay), .failed(_, let essay?): essay
        default: nil
        }
    }

    /// Time left is what the page cannot show by itself: the scroll position
    /// says where you are, not how long the rest takes.
    private func timeLeft(in essay: Essay) -> String? {
        let left = Int((Double(essay.minutes) * (1 - progress)).rounded(.up))
        return left > 0 ? "\(left) min left" : nil
    }

    private func store(_ essay: Essay) {
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: essay)
        } else {
            phase = .loaded(essay)
        }
    }

    private func toggleBookmark() {
        guard var essay else { return }
        essay.isBookmarked.toggle()
        store(essay)
    }

    /// The sample highlights a whole passage from its menu. Highlighting a
    /// selection of words needs a text view from UIKit.
    private func toggleHighlight(_ passage: Passage) {
        guard var essay, let index = essay.passages.firstIndex(of: passage) else { return }
        essay.passages[index].highlight = passage.highlight == nil ? passage.text : nil
        store(essay)
    }

    /// Sample only: a real app would refetch here.
    private func retry() {
        phase = .loaded(essay ?? .sample)
    }
}

/// What the screen needs from the scroll view: where it is, how far through,
/// and whether it is past either end.
private struct ScrollState: Equatable {
    var offset: Double
    var progress: Double
    var isBouncing: Bool

    init(_ geometry: ScrollGeometry) {
        let top = -geometry.contentInsets.top
        let distance = geometry.contentSize.height + geometry.contentInsets.bottom - geometry.containerSize.height - top
        offset = geometry.contentOffset.y - top
        progress = distance > 0 ? min(max(offset / distance, 0), 1) : 0
        isBouncing = offset < 0 || offset > max(distance, 0)
    }
}

private struct EssayHead: View {
    let essay: Essay

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(essay.publication)
                .readingKicker()
            Text(essay.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(ReadingLook.ink)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)
            // The reading time is the one fact that helps decide whether to
            // start now. Nothing else sits between the title and the text.
            Text("\(essay.author) · \(essay.minutes) min read")
                .font(.subheadline)
                .foregroundStyle(ReadingLook.ink2)
                .padding(.top, 12)
            Rectangle()
                .fill(ReadingLook.rule)
                .frame(height: 1)
                .padding(.top, 16)
        }
    }
}

private struct PassageView: View {
    let passage: Passage
    let scale: Double
    let followsHeading: Bool
    let toggleHighlight: () -> Void

    var body: some View {
        switch passage.kind {
        case .heading:
            Text(passage.text)
                .font(.system(.title2, design: .serif, weight: .bold).scaled(by: scale))
                .foregroundStyle(ReadingLook.ink)
                // More space above a heading than below it ties it to the
                // text it introduces.
                .padding(.top, 32)
                .accessibilityAddTraits(.isHeader)
        case .quotation:
            Text(attributed)
                .modifier(ReadingText(scale: scale, isItalic: true))
                .padding(.leading, 19)
                .overlay(alignment: .leading) {
                    Rectangle().fill(ReadingLook.rule).frame(width: 3)
                }
                .padding(.top, 20)
                .contextMenu { menu }
        case .paragraph:
            Text(attributed)
                .modifier(ReadingText(scale: scale))
                // Paragraphs are separated by space, not by an indent.
                .padding(.top, followsHeading ? 8 : 20)
                .accessibilityValue(passage.highlight == nil ? "" : "Highlighted")
                .contextMenu { menu }
        }
    }

    @ViewBuilder private var menu: some View {
        Button(passage.highlight == nil ? "Highlight" : "Remove highlight",
               systemImage: "highlighter", action: toggleHighlight)
        Button("Copy", systemImage: "doc.on.doc") {
            UIPasteboard.general.string = passage.text
        }
    }

    private var attributed: AttributedString {
        var text = AttributedString(passage.text)
        if let phrase = passage.highlight, let range = text.range(of: phrase) {
            // A fill behind the words and a line under them. The words keep
            // their colour, so a highlight never costs legibility.
            text[range].swiftUI.backgroundColor = ReadingLook.mark
            text[range].swiftUI.underlineStyle = Text.LineStyle(pattern: .solid, color: ReadingLook.markLine)
        }
        if let phrase = passage.linkPhrase, let url = passage.linkURL, let range = text.range(of: phrase) {
            // A link is the hue and an underline, never the hue alone.
            text[range].link = url
            text[range].swiftUI.underlineStyle = .single
        }
        return text
    }
}

extension Essay {
    func followsHeading(_ passage: Passage) -> Bool {
        guard let index = passages.firstIndex(of: passage), index > 0 else { return false }
        return passages[index - 1].kind == .heading
    }

    static let sample = Essay(
        publication: "The Long Way Round",
        title: "The Bridge That Counts Bicycles",
        author: "Ines Okafor",
        minutes: 9,
        passages: [
            Passage(id: 1, text: "The counter on the Mill Street bridge has no opinion about cycling. It is a steel post with a loop of wire under the asphalt, and every time a wheel crosses the loop it adds one."),
            Passage(id: 2, text: "By nine each morning the display reads somewhere past two thousand. Nobody set that as a target. The number is simply there, tall and amber, and people who ride past it begin to feel counted."),
            Passage(id: 3, kind: .heading, text: "What a number does"),
            Passage(id: 4, text: "Planners call a post like this a totem. It measures nothing a hidden sensor couldn’t, but a hidden sensor doesn’t change how anyone rides. The post does, because it answers a question riders didn’t know they were asking: is it only me?",
                    highlight: "It measures nothing a hidden sensor couldn’t, but a hidden sensor doesn’t change how anyone rides."),
            Passage(id: 5, kind: .quotation, text: "“You see 2,311 and you think, well, I’m not the only one out in the rain.”"),
            Passage(id: 6, text: "The city put up its first counter in 2014 as a six-month trial. It is still there, and there are now eleven more.",
                    linkPhrase: "six-month trial", linkURL: URL(string: "https://example.com/mill-street-trial")),
            Passage(id: 7, text: "Each cost about as much as a bus shelter. What the city bought was not the data, which the wire in the road would have gathered anyway. It bought the display."),
            Passage(id: 8, kind: .heading, text: "The day it broke"),
            Passage(id: 9, text: "In February the Mill Street counter froze at 1,204 and stayed there for nine days. The transport office received more messages about it than about the bridge’s resurfacing the year before."),
            Passage(id: 10, text: "Most asked when it would be fixed. A few sent their own tallies, kept on paper from a café window, so that the days would not be lost."),
            Passage(id: 11, text: "When the display came back it started again from zero, as it does every midnight. The paper tallies are in a drawer at the transport office. Nobody has thrown them away."),
        ])

    /// The sample after the reader has bookmarked it.
    static let sampleBookmarked: Essay = {
        var essay = sample
        essay.isBookmarked = true
        return essay
    }()

    static let placeholder = Essay(
        publication: "Publication name",
        title: "A placeholder title that runs to two lines",
        author: "Author Name",
        minutes: 9,
        passages: (1...4).map {
            Passage(id: $0, text: String(repeating: "Placeholder words for a paragraph of running text. ", count: 4))
        })
}
