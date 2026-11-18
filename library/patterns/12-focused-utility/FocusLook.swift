import SwiftUI
import UIKit

// Direction 12 Focused Utility: the look every pattern in this direction shares.
//
// A plain page of monospaced text. Formatting marks stay on the page, quieter
// than the words. The caret is the only hue. Tools are one row of keys that
// rides on the keyboard and leaves with it.

enum FocusLook {
    static let ground = Color(light: 0xFCFCFB, dark: 0x101113)
    /// The words, and an active tool key.
    static let ink = Color(light: 0x17181A, dark: 0xECEDEE)
    /// Formatting marks, the count in the bar, placeholder text.
    static let ink2 = Color(light: 0x5F6368, dark: 0x9A9EA5)
    static let rule = Color(light: 0xE6E7E9, dark: 0x26282C)
    /// A tool key.
    static let key = Color(light: 0xEEEFF1, dark: 0x1E2023)
    /// The caret and the selection handles. The only hue on the page.
    static let caret = Color(light: 0x2456E6, dark: 0x7AA2FF)

    // The same colours for the text view, which is UIKit.
    nonisolated static let inkUI = UIColor(light: 0x17181A, dark: 0xECEDEE)
    nonisolated static let ink2UI = UIColor(light: 0x5F6368, dark: 0x9A9EA5)
    nonisolated static let caretUI = UIColor(light: 0x2456E6, dark: 0x7AA2FF)
}

/// One tool key. The key for the format at the caret is filled with ink. An
/// unavailable key keeps its place with a quieter glyph.
struct FocusKeyStyle: ButtonStyle {
    var isOn = false
    var isBare = false

    func makeBody(configuration: Configuration) -> some View {
        Face(isOn: isOn, isBare: isBare, isPressed: configuration.isPressed, label: configuration.label)
    }

    private struct Face: View {
        let isOn: Bool
        let isBare: Bool
        let isPressed: Bool
        let label: ButtonStyleConfiguration.Label
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            label
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(isOn ? FocusLook.ground : isEnabled ? FocusLook.ink : FocusLook.ink2)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isBare ? .clear : isOn ? FocusLook.ink : FocusLook.key, in: .rect(cornerRadius: 10))
                // The gap between two keys belongs to their tap areas, so a
                // key drawn 38 pt wide is still 44 pt wide to a finger.
                .padding(.horizontal, 3)
                .contentShape(.rect)
                .opacity(isPressed ? 0.6 : 1)
        }
    }
}

/// What is wrong, above the text and closed by a hairline. It is set in the
/// interface face, so it does not read as part of the draft.
struct FocusNotice: View {
    let title: String
    let message: String
    /// The short form: what is wrong and the retry, without the sentence.
    /// For when the page has almost no room, such as typing at the largest
    /// text sizes with the keyboard up.
    var isCompact = false
    let retry: () -> Void

    var body: some View {
        Group {
            if isCompact {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) {
                        label
                        Spacer(minLength: 12)
                        button
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        label
                        button
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    label
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(FocusLook.ink2)
                    button
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // The notice keeps its full height. The text under it gives way.
        .fixedSize(horizontal: false, vertical: true)
        .overlay(alignment: .bottom) {
            Rectangle().fill(FocusLook.rule).frame(height: 1)
        }
    }

    private var label: some View {
        Label(title, systemImage: "wifi.slash")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(FocusLook.ink)
    }

    private var button: some View {
        Button("Try again", action: retry)
            .buttonStyle(.plain)
            .font(.subheadline)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(FocusLook.ink)
            .frame(minHeight: 44)
    }
}
