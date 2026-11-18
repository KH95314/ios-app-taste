import AppKit
import ImageIO

// Measures the colours a built screen really draws, from a screenshot.
//
//     measure <shot.png> [x0 y0 x1 y1] [--look Look.swift] [--dark]
//
// Inside the box (the whole screenshot if none is given, in pixels from the
// top left) the ground is the commonest colour. Every other colour that fills
// at least 150 pixels is listed with its contrast against that ground. 150
// pixels is the solid inside of a letter's stroke, not its soft edge, so very
// thin or very small text may not appear: measure it in a tighter box.
//
// With --look, each colour is matched to the nearest colour in the look file
// (lines of the form  static let ink = Color(light: 0x17212F, dark: 0xEFEADC)).
// A colour far from every look colour was drawn by the system or by a blend,
// such as glass or a list dimmed under a sheet, and deserves a second look.
// Add --dark for a screenshot taken in dark.
//
// Build it once with build-tools.sh. Needs only Xcode.

var positional: [String] = []
var lookPath: String?
var dark = false
var index = 1
let arguments = CommandLine.arguments
while index < arguments.count {
    switch arguments[index] {
    case "--look":
        index += 1
        if index < arguments.count { lookPath = arguments[index] }
    case "--dark":
        dark = true
    default:
        positional.append(arguments[index])
    }
    index += 1
}
guard positional.count == 1 || positional.count == 5 else {
    print("usage: measure <shot.png> [x0 y0 x1 y1] [--look Look.swift] [--dark]")
    exit(1)
}

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: positional[0]) as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    print("cannot read \(positional[0])")
    exit(1)
}
let width = image.width, height = image.height
var pixels = [UInt8](repeating: 0, count: width * height * 4)
guard let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { exit(1) }
context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

var box = (x0: 0, y0: 0, x1: width, y1: height)
if positional.count == 5 {
    let numbers = positional[1...].compactMap { Int($0) }
    guard numbers.count == 4 else { print("the box is four whole numbers: x0 y0 x1 y1"); exit(1) }
    box = (max(0, numbers[0]), max(0, numbers[1]), min(width, numbers[2]), min(height, numbers[3]))
    guard box.x1 > box.x0, box.y1 > box.y0 else { print("the box is empty"); exit(1) }
}

var counts: [UInt32: Int] = [:]
for y in box.y0..<box.y1 {
    var offset = (y * width + box.x0) * 4
    for _ in box.x0..<box.x1 {
        let key = UInt32(pixels[offset]) << 16 | UInt32(pixels[offset + 1]) << 8 | UInt32(pixels[offset + 2])
        counts[key, default: 0] += 1
        offset += 4
    }
}

func parts(_ value: UInt32) -> (Double, Double, Double) {
    (Double(value >> 16 & 0xFF), Double(value >> 8 & 0xFF), Double(value & 0xFF))
}
func distance(_ a: UInt32, _ b: UInt32) -> Double {
    let (ar, ag, ab) = parts(a), (br, bg, bb) = parts(b)
    return ((ar - br) * (ar - br) + (ag - bg) * (ag - bg) + (ab - bb) * (ab - bb)).squareRoot()
}
func luminance(_ value: UInt32) -> Double {
    func linear(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
    let (r, g, b) = parts(value)
    return 0.2126 * linear(r / 255) + 0.7152 * linear(g / 255) + 0.0722 * linear(b / 255)
}
func ratio(_ a: UInt32, _ b: UInt32) -> Double {
    let la = luminance(a), lb = luminance(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
}
func hex(_ value: UInt32) -> String { String(format: "#%06X", value) }

var look: [(name: String, value: UInt32)] = []
if let lookPath {
    guard let text = try? String(contentsOfFile: lookPath, encoding: .utf8) else { print("cannot read \(lookPath)"); exit(1) }
    let pattern = #"let\s+(\w+)\s*(?::\s*Color\s*)?=\s*Color\(\s*light:\s*0x([0-9A-Fa-f]{6})\s*,\s*dark:\s*0x([0-9A-Fa-f]{6})\s*\)"#
    let regex = try! NSRegularExpression(pattern: pattern)
    let whole = NSRange(text.startIndex..., in: text)
    for match in regex.matches(in: text, range: whole) {
        let name = String(text[Range(match.range(at: 1), in: text)!])
        let value = String(text[Range(match.range(at: dark ? 3 : 2), in: text)!])
        look.append((name, UInt32(value, radix: 16)!))
    }
    if look.isEmpty { print("no colours of the form Color(light: 0x……, dark: 0x……) in \(lookPath)") }
}
func named(_ value: UInt32) -> String {
    guard let nearest = look.min(by: { distance($0.value, value) < distance($1.value, value) }) else { return "" }
    let off = distance(nearest.value, value)
    return off < 6 ? "  look: \(nearest.name)" : "  not in the look (nearest \(nearest.name), off by \(Int(off.rounded())))"
}

let sorted = counts.sorted { $0.value > $1.value }
let ground = sorted[0].key
print("ground \(hex(ground))  \(sorted[0].value) px\(named(ground))")

var groups: [(colour: UInt32, count: Int)] = []
for (colour, count) in sorted.dropFirst() where count >= 150 && distance(colour, ground) > 40 {
    if let at = groups.firstIndex(where: { distance($0.colour, colour) < 14 }) {
        groups[at].count += count
    } else {
        groups.append((colour, count))
    }
}
if groups.isEmpty { print("  nothing solid on it in this box") }
for group in groups.prefix(12) {
    let value = String(format: "%5.2f", ratio(group.colour, ground))
    print("  \(hex(group.colour))  \(value):1  \(group.count) px\(named(group.colour))")
}
