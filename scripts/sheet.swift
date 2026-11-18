import AppKit
import ImageIO

// Lays screenshots out on one sheet, each with its file name under it, so that
// many can be read at once.
//
//     sheet <out.png> <cell-height> <columns> <image>...
//
// A cell height of about 1000 with four columns shows an iPhone screenshot at
// roughly two fifths of its size: enough to find cut text and things on top
// of each other, not enough to find a misalignment of a point or two.
//
// Build it once with build-tools.sh. Needs only Xcode.

let args = CommandLine.arguments
guard args.count >= 5, let cellHeight = Double(args[2]), let columns = Int(args[3]), columns > 0 else {
    print("usage: sheet <out.png> <cell-height> <columns> <image>...")
    exit(1)
}

var images: [(String, CGImage)] = []
for path in args[4...] {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        print("skipped \(path)")
        continue
    }
    images.append((url.deletingPathExtension().lastPathComponent, image))
}
guard !images.isEmpty else { print("no images"); exit(1) }

let gap = 12.0
let labelHeight = max(22.0, cellHeight / 28)
let widths = images.map { Double($0.1.width) * cellHeight / Double($0.1.height) }
let rows = stride(from: 0, to: images.count, by: columns).map { Array($0..<min($0 + columns, images.count)) }
let totalWidth = Int((rows.map { $0.reduce(gap) { $0 + widths[$1] + gap } }.max() ?? 0).rounded(.up))
let totalHeight = Int((Double(rows.count) * (cellHeight + labelHeight + gap) + gap).rounded(.up))

guard let context = CGContext(data: nil, width: totalWidth, height: totalHeight, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }
context.setFillColor(CGColor(gray: 0.47, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
context.interpolationQuality = .high
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)

let labelAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: labelHeight * 0.62, weight: .medium),
    .foregroundColor: NSColor.white,
]
for (rowIndex, row) in rows.enumerated() {
    var x = gap
    let top = Double(totalHeight) - gap - Double(rowIndex) * (cellHeight + labelHeight + gap)
    for index in row {
        let (label, image) = images[index]
        context.draw(image, in: CGRect(x: x, y: top - cellHeight, width: widths[index], height: cellHeight))
        (label as NSString).draw(at: CGPoint(x: x, y: top - cellHeight - labelHeight + labelHeight * 0.12),
                                 withAttributes: labelAttributes)
        x += widths[index] + gap
    }
}

guard let output = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: args[1]) as CFURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, output, nil)
guard CGImageDestinationFinalize(destination) else { print("could not write \(args[1])"); exit(1) }
print("wrote \(args[1])  \(totalWidth) x \(totalHeight)  \(images.count) images")
