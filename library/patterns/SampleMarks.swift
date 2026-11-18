import SwiftUI

// Drawings that stand in, on the screens that show a look's parts in use,
// for things a real product supplies: other companies' logos and people's photographs. Every company is
// invented, and no face is a real person's. Their colours are their own and
// are not part of any look.

/// An invented company's mark, drawn to fill the square it is given.
struct SampleLogo: View {
    enum Company { case northline, paywell, checkout, search, tempo }
    let company: Company

    var body: some View {
        Canvas { context, size in
            let unit = min(size.width, size.height) / 28
            func point(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * unit, y: y * unit) }
            let white = GraphicsContext.Shading.color(.white)
            let line = StrokeStyle(lineWidth: 2.3 * unit, lineCap: .round, lineJoin: .round)
            switch company {
            case .northline:
                context.fill(Path(ellipseIn: CGRect(x: 3 * unit, y: 3 * unit, width: 22 * unit, height: 22 * unit)), with: .color(Color(fixed: 0x1D5FD6)))
                var letter = Path()
                letter.move(to: point(9.5, 18.5)); letter.addLine(to: point(9.5, 9.5))
                letter.addLine(to: point(18.5, 18.5)); letter.addLine(to: point(18.5, 9.5))
                context.stroke(letter, with: white, style: line)
            case .paywell:
                let square = CGRect(x: 3 * unit, y: 3 * unit, width: 22 * unit, height: 22 * unit)
                context.fill(Path(roundedRect: square, cornerRadius: 6 * unit), with: .color(Color(fixed: 0x0F9D6B)))
                var bars = Path()
                bars.move(to: point(9, 10.5)); bars.addLine(to: point(19, 10.5))
                bars.move(to: point(9, 14)); bars.addLine(to: point(19, 14))
                bars.move(to: point(9, 17.5)); bars.addLine(to: point(15, 17.5))
                context.stroke(bars, with: white, style: line)
            case .checkout:
                var diamond = Path()
                diamond.move(to: point(14, 2.5)); diamond.addLine(to: point(25.5, 14))
                diamond.addLine(to: point(14, 25.5)); diamond.addLine(to: point(2.5, 14)); diamond.closeSubpath()
                context.fill(diamond, with: .color(Color(fixed: 0xF26B21)))
                context.fill(Path(ellipseIn: CGRect(x: 10 * unit, y: 10 * unit, width: 8 * unit, height: 8 * unit)), with: white)
            case .search:
                let teal = GraphicsContext.Shading.color(Color(fixed: 0x0E8F9C))
                let thick = StrokeStyle(lineWidth: 4 * unit, lineCap: .round)
                context.stroke(Path(ellipseIn: CGRect(x: 4.5 * unit, y: 4.5 * unit, width: 16 * unit, height: 16 * unit)), with: teal, style: thick)
                var handle = Path()
                handle.move(to: point(19, 19)); handle.addLine(to: point(24.5, 24.5))
                context.stroke(handle, with: teal, style: thick)
            case .tempo:
                var triangle = Path()
                triangle.move(to: point(14, 3)); triangle.addLine(to: point(23, 25))
                triangle.addLine(to: point(5, 25)); triangle.closeSubpath()
                context.fill(triangle, with: .color(Color(fixed: 0xD43F3A)))
                var arm = Path()
                arm.move(to: point(14, 22)); arm.addLine(to: point(19, 8))
                context.stroke(arm, with: white, style: line)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// A drawn head and shoulders, where a person's photograph would go.
struct SampleFace: View {
    enum Person { case mina, jonas }
    let person: Person

    var body: some View {
        Canvas { context, size in
            let unit = min(size.width, size.height) / 32
            let tones: (ground: UInt32, skin: UInt32, top: UInt32) = switch person {
            case .mina: (0xF1D9B5, 0x8A5A3C, 0x2E6F8E)
            case .jonas: (0xC9D8F0, 0xE6B894, 0x3C3A52)
            }
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(fixed: tones.ground)))
            var shoulders = Path()
            shoulders.move(to: CGPoint(x: 3 * unit, y: 34 * unit))
            shoulders.addCurve(
                to: CGPoint(x: 29 * unit, y: 34 * unit),
                control1: CGPoint(x: 3 * unit, y: 16 * unit),
                control2: CGPoint(x: 29 * unit, y: 16 * unit))
            context.fill(shoulders, with: .color(Color(fixed: tones.top)))
            let head = CGRect(x: 9.8 * unit, y: 6.3 * unit, width: 12.4 * unit, height: 12.4 * unit)
            context.fill(Path(ellipseIn: head), with: .color(Color(fixed: tones.skin)))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
