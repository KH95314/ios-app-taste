import SwiftUI
import UIKit

// Pattern: a plain draft with tools on the keyboard
// Direction 12 Focused Utility · kind: editor · look: FocusLook.swift
// Sample product (invented): a notes app for drafting a short speech.
//
// The text view is UIKit. SwiftUI's editor cannot yet restyle marks as you
// type without disturbing the caret, and a text storage delegate can.

struct SpeechDraft: Equatable {
    var text: String

    /// How long the draft takes to say, at an unhurried 130 words a minute,
    /// rounded to ten seconds. The one count the writer of a speech needs.
    var speakingTime: String? {
        let words = text.split { $0.isWhitespace || $0.isNewline }.filter { $0.contains(where: \.isLetter) }.count
        guard words > 0 else { return nil }
        let seconds = max(10, Int((Double(words) * 60 / 130 / 10).rounded()) * 10)
        let minutes = seconds / 60, rest = seconds % 60
        if minutes == 0 { return "\(rest) s" }
        return rest == 0 ? "\(minutes) min" : "\(minutes) min \(rest) s"
    }
}

enum DraftFormat: Hashable {
    case heading, bold, italic, list, tasks
}

struct PlainDraftScreen: View {
    @State private var phase: Phase<SpeechDraft>
    @State private var isEditing: Bool
    @State private var editor = DraftEditor()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    /// `startsEditing` opens the draft with the keyboard up, as when writing.
    init(phase: Phase<SpeechDraft>, startsEditing: Bool = true) {
        _phase = State(initialValue: phase)
        _isEditing = State(initialValue: startsEditing)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FocusLook.ground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                    if let time = draft?.speakingTime {
                        // One count, and only this one: a speech is measured
                        // in time, not in characters.
                        ToolbarItem(placement: .principal) {
                            Text(time)
                                .font(.system(.footnote, design: .monospaced, weight: .medium))
                                .foregroundStyle(FocusLook.ink2)
                                .accessibilityLabel("About \(time) to say")
                        }
                    }
                    if draft != nil {
                        ToolbarItem(placement: .topBarTrailing) {
                            if isEditing {
                                Button("Done") { isEditing = false }
                                    .fontWeight(.semibold)
                            } else {
                                ShareLink(item: draft?.text ?? "")
                            }
                        }
                    }
                }
        }
        .tint(FocusLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            ScrollView {
                Text(SpeechDraft.placeholder.text)
                    .font(.system(.body, design: .monospaced))
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
            }
            .redacted(reason: .placeholder)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Opening the draft")
        case .empty:
            page(SpeechDraft(text: ""), notice: nil)
        case .loaded(let draft):
            page(draft, notice: nil)
        case .failed(let message, let stale?):
            page(stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't open the draft", systemImage: "wifi.slash")
                } description: {
                    Text(message)
                        .foregroundStyle(FocusLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .underline()
                        .foregroundStyle(FocusLook.ink)
                        .frame(minHeight: 44)
                }
            }
        }
    }

    private func page(_ draft: SpeechDraft, notice: String?) -> some View {
        VStack(spacing: 0) {
            if let notice {
                // Writing carries on under the notice. Nothing is blocked.
                FocusNotice(
                    title: "Not synced", message: notice,
                    isCompact: isEditing && typeSize.isAccessibilitySize, retry: retry)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
            DraftTextView(text: binding(for: draft), isEditing: $isEditing, editor: editor)
                .overlay(alignment: .topLeading) {
                    if draft.text.isEmpty {
                        // A blank page needs one cue and no instructions.
                        Text("Start writing")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(FocusLook.ink2)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
        }
        // The tools ride on the keyboard and leave with it.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isEditing {
                ToolRow(editor: editor) { isEditing = false }
            }
        }
    }

    private var draft: SpeechDraft? {
        switch phase {
        case .loaded(let draft), .failed(_, let draft?): draft
        case .empty: SpeechDraft(text: "")
        default: nil
        }
    }

    /// Every change is kept as it is made. There is no save button, and
    /// nothing tells the writer that saving happened.
    private func binding(for draft: SpeechDraft) -> Binding<String> {
        Binding {
            draft.text
        } set: { text in
            if case .failed(let message, _) = phase {
                phase = .failed(message: message, stale: SpeechDraft(text: text))
            } else {
                phase = .loaded(SpeechDraft(text: text))
            }
        }
    }

    /// Sample only: a real app would sync or reopen here.
    private func retry() {
        phase = .loaded(draft ?? .sample)
    }
}

// MARK: - The tool row

/// One row, shared equally. On a narrow phone the less used tools move into
/// a menu instead of the row scrolling sideways.
private struct ToolRow: View {
    let editor: DraftEditor
    let hideKeyboard: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(compact: false)
            row(compact: true)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 8)
        .background(FocusLook.ground)
        .overlay(alignment: .top) {
            Rectangle().fill(FocusLook.rule).frame(height: 1)
        }
        // A row of keys cannot grow with the text size and still fit, so it
        // stops at the largest standard size. Each key shows the system's
        // large-content preview when held.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func row(compact: Bool) -> some View {
        HStack(spacing: 0) {
            format(.heading, "Heading") { Text("H") }
            format(.bold, "Bold") { Text("B") }
            if !compact {
                format(.italic, "Italic") { Text("I").italic().fontDesign(.serif) }
            }
            format(.list, "List") { Image(systemName: "list.bullet") }
            if !compact {
                format(.tasks, "Checklist") { Image(systemName: "checkmark.square") }
            }
            key("Undo", isEnabled: editor.canUndo, action: editor.undo) { Image(systemName: "arrow.uturn.backward") }
            if compact {
                Menu {
                    Button("Italic", systemImage: "italic") { editor.toggle(.italic) }
                    Button("Checklist", systemImage: "checkmark.square") { editor.toggle(.tasks) }
                    Button("Redo", systemImage: "arrow.uturn.forward", action: editor.redo)
                        .disabled(!editor.canRedo)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(FocusLook.ink)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(FocusLook.key, in: .rect(cornerRadius: 10))
                        .padding(.horizontal, 3)
                        .contentShape(.rect)
                }
                .frame(minWidth: 44)
                .accessibilityLabel("More tools")
            } else {
                key("Redo", isEnabled: editor.canRedo, action: editor.redo) { Image(systemName: "arrow.uturn.forward") }
            }
            Button(action: hideKeyboard) { Image(systemName: "keyboard.chevron.compact.down") }
                .buttonStyle(FocusKeyStyle(isBare: true))
                .frame(minWidth: 44)
                .accessibilityLabel("Hide keyboard")
                .accessibilityShowsLargeContentViewer {
                    Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
                }
        }
    }

    private func format(_ format: DraftFormat, _ name: String, @ViewBuilder label: () -> some View) -> some View {
        Button { editor.toggle(format) } label: { label() }
            // The key for the format at the caret is filled.
            .buttonStyle(FocusKeyStyle(isOn: editor.active.contains(format)))
            .frame(minWidth: 44)
            .accessibilityLabel(name)
            .accessibilityAddTraits(editor.active.contains(format) ? .isSelected : [])
            .accessibilityShowsLargeContentViewer { Text(name) }
    }

    private func key(_ name: String, isEnabled: Bool, action: @escaping () -> Void, @ViewBuilder label: () -> some View) -> some View {
        Button(action: action) { label() }
            .buttonStyle(FocusKeyStyle())
            .frame(minWidth: 44)
            .disabled(!isEnabled)
            .accessibilityLabel(name)
            .accessibilityShowsLargeContentViewer { Text(name) }
    }
}

// MARK: - Editing

/// What the tool row can do to the text, and what it needs to know back.
@Observable final class DraftEditor {
    fileprivate weak var textView: UITextView?
    private(set) var active: Set<DraftFormat> = []
    private(set) var canUndo = false
    private(set) var canRedo = false

    private static let linePrefixes: [DraftFormat: String] = [.heading: "# ", .list: "- ", .tasks: "- [ ] "]
    /// Longest first, so "- [ ] " is not mistaken for "- ".
    private static let knownPrefixes = ["- [ ] ", "- [x] ", "## ", "# ", "- "]

    func toggle(_ format: DraftFormat) {
        guard let textView else { return }
        switch format {
        case .heading, .list, .tasks: togglePrefix(Self.linePrefixes[format] ?? "", in: textView)
        case .bold: toggleWrap("**", in: textView)
        case .italic: toggleWrap("*", in: textView)
        }
        textView.delegate?.textViewDidChange?(textView)
    }

    func undo() {
        guard let textView else { return }
        textView.undoManager?.undo()
        textView.delegate?.textViewDidChange?(textView)
    }

    func redo() {
        guard let textView else { return }
        textView.undoManager?.redo()
        textView.delegate?.textViewDidChange?(textView)
    }

    /// Reads the format at the caret, so the row can fill the matching keys.
    fileprivate func refresh() {
        guard let textView else { return }
        let text = textView.text as NSString
        let caret = min(textView.selectedRange.location, text.length)
        let lineRange = text.lineRange(for: NSRange(location: caret, length: 0))
        let line = text.substring(with: lineRange)
        var formats: Set<DraftFormat> = []
        if line.hasPrefix("# ") || line.hasPrefix("## ") {
            formats.insert(.heading)
        } else if line.hasPrefix("- [ ] ") || line.hasPrefix("- [x] ") {
            formats.insert(.tasks)
        } else if line.hasPrefix("- ") {
            formats.insert(.list)
        }
        let offset = caret - lineRange.location
        if DraftStyle.spans(of: DraftStyle.bold, in: line).contains(where: { NSLocationInRange(offset, $0) }) { formats.insert(.bold) }
        if DraftStyle.spans(of: DraftStyle.italic, in: line).contains(where: { NSLocationInRange(offset, $0) }) { formats.insert(.italic) }
        active = formats
        canUndo = textView.undoManager?.canUndo ?? false
        canRedo = textView.undoManager?.canRedo ?? false
    }

    /// Puts a mark at the start of the caret's line, or takes it away.
    private func togglePrefix(_ prefix: String, in textView: UITextView) {
        let text = textView.text as NSString
        let caret = textView.selectedRange.location
        var lineRange = text.lineRange(for: NSRange(location: caret, length: 0))
        var line = text.substring(with: lineRange)
        if line.hasSuffix("\n") {
            line.removeLast()
            lineRange.length -= 1
        }
        let current = Self.knownPrefixes.first { line.hasPrefix($0) }
        if let current { line.removeFirst(current.count) }
        let isSame = current == prefix || (prefix == "- [ ] " && current == "- [x] ")
        if !isSame { line = prefix + line }
        replace(lineRange, with: line, in: textView)
        textView.selectedRange = NSRange(location: lineRange.location + (line as NSString).length, length: 0)
    }

    /// Wraps the selection in a mark, or unwraps it. With nothing selected,
    /// it writes the pair and leaves the caret between them.
    private func toggleWrap(_ mark: String, in textView: UITextView) {
        let range = textView.selectedRange
        let selected = (textView.text as NSString).substring(with: range)
        let length = (mark as NSString).length
        if selected.hasPrefix(mark), selected.hasSuffix(mark), (selected as NSString).length >= length * 2 {
            let inner = String(selected.dropFirst(mark.count).dropLast(mark.count))
            replace(range, with: inner, in: textView)
            textView.selectedRange = NSRange(location: range.location, length: (inner as NSString).length)
        } else {
            replace(range, with: mark + selected + mark, in: textView)
            textView.selectedRange = NSRange(location: range.location + length, length: range.length)
        }
    }

    /// Goes through the text view, so the change can be undone.
    private func replace(_ range: NSRange, with string: String, in textView: UITextView) {
        guard let start = textView.position(from: textView.beginningOfDocument, offset: range.location),
              let end = textView.position(from: start, offset: range.length),
              let textRange = textView.textRange(from: start, to: end) else { return }
        textView.replace(textRange, withText: string)
    }
}

/// How the draft is drawn: one size throughout, marks quieter than words.
enum DraftStyle {
    nonisolated static let bold = try? NSRegularExpression(pattern: #"\*\*(?=\S)(.+?)(?<=\S)\*\*"#)
    nonisolated static let italic = try? NSRegularExpression(pattern: #"(?<![\*\w])\*(?=[^\s\*])(.+?)(?<=[^\s\*])\*(?![\*\w])"#)

    nonisolated static func font(_ weight: UIFont.Weight = .regular, italic: Bool = false) -> UIFont {
        var base = UIFont.monospacedSystemFont(ofSize: 17, weight: weight)
        if italic, let descriptor = base.fontDescriptor.withSymbolicTraits(.traitItalic) {
            base = UIFont(descriptor: descriptor, size: 17)
        }
        // Scaled from the body style, so the draft follows the reader's text size.
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: base)
    }

    nonisolated static func spans(of expression: NSRegularExpression?, in line: String) -> [NSRange] {
        expression?.matches(in: line, range: NSRange(location: 0, length: (line as NSString).length)).map(\.range) ?? []
    }

    nonisolated static var base: [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = UIFontMetrics(forTextStyle: .body).scaledValue(for: 6)
        return [.font: font(), .foregroundColor: FocusLook.inkUI, .paragraphStyle: paragraph]
    }

    /// Restyles the whole draft. Only attributes change, never characters, so
    /// the caret and the undo stack are left alone.
    nonisolated static func apply(to storage: NSTextStorage) {
        let all = NSRange(location: 0, length: storage.length)
        let string = storage.string as NSString
        storage.setAttributes(base, range: all)
        string.enumerateSubstrings(in: all, options: [.byLines, .substringNotRequired]) { _, lineRange, _, _ in
            let line = string.substring(with: lineRange)
            guard let prefix = ["- [ ] ", "- [x] ", "## ", "# ", "- "].first(where: { line.hasPrefix($0) }) else { return }
            let markRange = NSRange(location: lineRange.location, length: (prefix as NSString).length)
            if prefix.hasPrefix("#") {
                // A heading is the same size as the text, in bold.
                storage.addAttribute(.font, value: font(.bold), range: lineRange)
            }
            if prefix == "- [x] " {
                let rest = NSRange(location: NSMaxRange(markRange), length: lineRange.length - markRange.length)
                storage.addAttributes([.strikethroughStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: FocusLook.ink2UI], range: rest)
            }
            // The mark stays on the page, quieter than the words.
            storage.addAttributes([.foregroundColor: FocusLook.ink2UI, .font: font()], range: markRange)
        }
        for match in bold?.matches(in: storage.string, range: all) ?? [] {
            storage.addAttribute(.font, value: font(.bold), range: match.range(at: 1))
            dim(match.range, inner: match.range(at: 1), in: storage)
        }
        for match in italic?.matches(in: storage.string, range: all) ?? [] {
            storage.addAttribute(.font, value: font(italic: true), range: match.range(at: 1))
            dim(match.range, inner: match.range(at: 1), in: storage)
        }
    }

    nonisolated private static func dim(_ whole: NSRange, inner: NSRange, in storage: NSTextStorage) {
        let lead = NSRange(location: whole.location, length: inner.location - whole.location)
        let trail = NSRange(location: NSMaxRange(inner), length: NSMaxRange(whole) - NSMaxRange(inner))
        storage.addAttribute(.foregroundColor, value: FocusLook.ink2UI, range: lead)
        storage.addAttribute(.foregroundColor, value: FocusLook.ink2UI, range: trail)
    }
}

private struct DraftTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    let editor: DraftEditor
    @Environment(\.dynamicTypeSize) private var typeSize

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.textStorage.delegate = context.coordinator
        view.backgroundColor = .clear
        view.tintColor = FocusLook.caretUI
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets(top: 12, left: 20, bottom: 24, right: 20)
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .interactive
        view.adjustsFontForContentSizeCategory = true
        view.typingAttributes = DraftStyle.base
        view.text = text
        view.accessibilityLabel = "Draft"
        editor.textView = view
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        if view.text != text {
            view.text = text
        }
        if coordinator.typeSize != typeSize {
            coordinator.typeSize = typeSize
            DraftStyle.apply(to: view.textStorage)
            view.typingAttributes = DraftStyle.base
        }
        // Focus follows the screen's state, one step after this update.
        if isEditing != view.isFirstResponder {
            let shouldEdit = isEditing
            Task { @MainActor in
                if shouldEdit { view.becomeFirstResponder() } else { view.resignFirstResponder() }
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate, NSTextStorageDelegate {
        var parent: DraftTextView
        var typeSize: DynamicTypeSize?

        init(_ parent: DraftTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            if parent.text != textView.text { parent.text = textView.text }
            textView.typingAttributes = DraftStyle.base
            parent.editor.refresh()
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.editor.refresh()
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if !parent.isEditing { parent.isEditing = true }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if parent.isEditing { parent.isEditing = false }
        }

        nonisolated func textStorage(
            _ textStorage: NSTextStorage,
            didProcessEditing editedMask: NSTextStorage.EditActions,
            range editedRange: NSRange,
            changeInLength delta: Int
        ) {
            guard editedMask.contains(.editedCharacters) else { return }
            DraftStyle.apply(to: textStorage)
        }
    }
}

// MARK: - Sample data

extension SpeechDraft {
    static let sample = SpeechDraft(text: """
        # Toast for Hana and Ilya

        The first time I met Ilya he was carrying a ladder through a doorway that was plainly too small for it.

        - the ladder
        - the *borrowed* suit
        - what Hana said at the lake

        Keep it under two minutes.
        """)

    static let placeholder = SpeechDraft(text: String(repeating: "Placeholder words for a line of the draft.\n\n", count: 5))
}
