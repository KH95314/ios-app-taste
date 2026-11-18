import SwiftUI

// Direction 13 Canvas-First Creation: the look every pattern in this direction shares.
//
// The work sits on a neutral board and has all the colour. The bars around it
// are neutral too. One hue marks what is selected and which tool is in use.

enum CanvasLook {
    /// The area around the work. It is not part of the work.
    static let board = Color(light: 0xE6E7EA, dark: 0x101113)
    /// The tool row and the strip for the selected thing.
    static let chrome = Color(light: 0xFFFFFF, dark: 0x1C1D20)
    static let ink = Color(light: 0x16171A, dark: 0xF2F3F5)
    /// Unavailable tools and quiet labels.
    static let ink2 = Color(light: 0x5E6269, dark: 0xA0A4AB)
    static let rule = Color(light: 0xD9DBDF, dark: 0x2C2E33)
    /// Chips in the strip.
    static let control = Color(light: 0xEEF0F2, dark: 0x2A2C30)
    /// The tool in use. The same hue as the selection, tuned for the chrome.
    static let active = Color(light: 0xC2186F, dark: 0xFF6FB5)
    /// The selection outline. It is drawn over the work, which does not
    /// change with the appearance, so neither does this.
    static let select = Color(fixed: 0xC2186F)
    /// A hairline outside the outline, and the fill of the handles. One tone
    /// alone disappears on some artwork: the hue is 5.3:1 on a cream page and
    /// about 1.5:1 on a mid grey.
    static let selectHalo = Color(fixed: 0xFFFFFF)
}

/// One cell of the tool row: a glyph over a word.
struct CanvasToolFace: View {
    let title: String
    let systemImage: String
    var isOn = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.title3)
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(isOn ? CanvasLook.active : isEnabled ? CanvasLook.ink : CanvasLook.ink2)
        .frame(maxWidth: .infinity, minHeight: 56)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isOn ? .isSelected : [])
        // The dock stops growing with the text size, so each tool offers the
        // system's large preview when held.
        .accessibilityShowsLargeContentViewer {
            Label(title, systemImage: systemImage)
        }
    }
}

extension View {
    /// A chip in the strip for the selected thing: 36 pt tall inside a 44 pt row.
    func canvasChip() -> some View {
        font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(CanvasLook.ink)
            .padding(.horizontal, 12)
            .frame(minWidth: 36, minHeight: 36)
            .background(CanvasLook.control, in: .rect(cornerRadius: 8))
            .frame(minHeight: 44)
            .contentShape(.rect)
    }
}

/// The outline and corner handles of the selected thing. `scale` is how much
/// the work is magnified on screen, so the line stays one and a half points
/// wide however large the page is drawn.
struct CanvasSelectionFrame: View {
    let scale: Double

    var body: some View {
        let line = 1.5 / scale, hair = 1 / scale
        Rectangle()
            .strokeBorder(CanvasLook.select, lineWidth: line)
            .background {
                Rectangle()
                    .strokeBorder(CanvasLook.selectHalo, lineWidth: line + hair * 2)
                    .padding(-hair)
            }
            .accessibilityHidden(true)
    }
}

/// One handle: a white disc ringed in the selection hue.
struct CanvasHandle: View {
    let scale: Double

    var body: some View {
        let size = 14 / scale
        Circle()
            .fill(CanvasLook.selectHalo)
            .overlay { Circle().strokeBorder(CanvasLook.select, lineWidth: 2 / scale) }
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.3), radius: 1.5 / scale, y: 1 / scale)
            // The disc is small; its tap area is not.
            .frame(width: 44 / scale, height: 44 / scale)
            .contentShape(.rect)
    }
}

/// What is wrong, in one strip between the bar and the board.
struct CanvasNotice: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: "icloud.slash")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(CanvasLook.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(CanvasLook.ink2)
            Button("Try again", action: retry)
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.semibold)
                .underline()
                .foregroundStyle(CanvasLook.ink)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 10)
        .background(CanvasLook.chrome)
        .overlay(alignment: .bottom) {
            Rectangle().fill(CanvasLook.rule).frame(height: 1)
        }
        // Like the dock, the notice stops growing so that the work keeps
        // the screen. At the largest size it left the page a thumbnail.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }
}
