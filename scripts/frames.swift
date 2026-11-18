import AVFoundation
import AppKit
import ImageIO

// Turns a simulator recording into pictures that can be read: one strip of
// frames for each burst of change on the screen.
//
//     frames <recording.mp4> <out-dir> [frames-per-strip]
//
// `simctl io … recordVideo` stores a frame only when the screen changes, so
// every stored frame after the first is a change. A burst is a run of stored
// frames no more than a third of a second apart. For each burst this prints
// when it starts, how long it lasts and how much of the screen changed, and
// writes <out-dir>/<recording>--b<n>.png: the frame before the burst, then
// frames across it, each with its time.
//
// A burst is flagged when most of a large change lands in a single frame.
// That is what a jump looks like. It is also what the app starting, a press
// highlight and a recorder that lost some frames look like, so read every
// flagged strip, and record a second time before calling one a fault.
//
// Build it once with build-tools.sh. Needs only Xcode.

let arguments = CommandLine.arguments
guard arguments.count >= 3 else {
    print("usage: frames <recording.mp4> <out-dir> [frames-per-strip]")
    exit(1)
}
let videoURL = URL(fileURLWithPath: arguments[1])
let outDirectory = URL(fileURLWithPath: arguments[2], isDirectory: true)
let perStrip = max(3, arguments.count > 3 ? Int(arguments[3]) ?? 8 : 8)
let name = videoURL.deletingPathExtension().lastPathComponent
try FileManager.default.createDirectory(at: outDirectory, withIntermediateDirectories: true)

let asset = AVURLAsset(url: videoURL)
guard let track = try await asset.loadTracks(withMediaType: .video).first else {
    print("no video in \(arguments[1])")
    exit(1)
}

/// Calls `body` with every stored frame in turn: its number, its time and its pixels (BGRA).
func eachFrame(_ body: (Int, Double, CVPixelBuffer) -> Void) throws {
    let reader = try AVAssetReader(asset: asset)
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    ])
    output.alwaysCopiesSampleData = false
    reader.add(output)
    guard reader.startReading() else { throw reader.error ?? CocoaError(.fileReadUnknown) }
    var number = 0
    while let sample = output.copyNextSampleBuffer() {
        guard let buffer = CMSampleBufferGetImageBuffer(sample) else { continue }
        body(number, CMSampleBufferGetPresentationTimeStamp(sample).seconds, buffer)
        number += 1
    }
}

/// A small grey copy of a frame, for comparing with the next one.
func thumbnail(_ buffer: CVPixelBuffer) -> [UInt8] {
    CVPixelBufferLockBaseAddress(buffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
    let width = CVPixelBufferGetWidth(buffer), height = CVPixelBufferGetHeight(buffer)
    let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
    let base = CVPixelBufferGetBaseAddress(buffer)!.assumingMemoryBound(to: UInt8.self)
    let step = max(1, width / 200)
    var grey: [UInt8] = []
    grey.reserveCapacity((width / step + 1) * (height / step + 1))
    var y = 0
    while y < height {
        var x = 0
        while x < width {
            let pixel = base + y * rowBytes + x * 4
            let blue = Int(pixel[0]), green = Int(pixel[1]), red = Int(pixel[2])
            let sum: Int = blue * 29 + green * 150 + red * 77
            grey.append(UInt8(sum >> 8))
            x += step
        }
        y += step
    }
    return grey
}

// First pass: when each frame is, and how much of the screen it changed.
var times: [Double] = []
var changes: [Double] = []
var previous: [UInt8] = []
var outOfOrder = false
try eachFrame { _, time, buffer in
    let current = thumbnail(buffer)
    var differing = 0
    if previous.count == current.count {
        for at in 0..<current.count where abs(Int(current[at]) - Int(previous[at])) > 24 { differing += 1 }
    }
    if let last = times.last, time < last { outOfOrder = true }
    times.append(time)
    changes.append(previous.isEmpty ? 0 : Double(differing) / Double(current.count))
    previous = current
}
guard !times.isEmpty else { print("no frames in \(arguments[1])"); exit(1) }
if outOfOrder { print("warning: frames are not in time order; the figures below may be wrong") }

let moving = changes.indices.filter { $0 > 0 && changes[$0] > 0.0015 }
var bursts: [[Int]] = []
for frame in moving {
    if let last = bursts.last?.last, times[frame] - times[last] <= 0.34 {
        bursts[bursts.count - 1].append(frame)
    } else {
        bursts.append([frame])
    }
}

// Which frames each strip shows: the one before the burst, then frames across it.
var picks: [[Int]] = []
for burst in bursts {
    let before = max(0, burst[0] - 1)
    let room = perStrip - 1
    var chosen = [before]
    if burst.count <= room {
        chosen += burst
    } else {
        for slot in 0..<room { chosen.append(burst[slot * (burst.count - 1) / (room - 1)]) }
    }
    picks.append(Array(NSOrderedSet(array: chosen)) as! [Int])
}

// Second pass: keep a small copy of each frame a strip needs.
let wanted = Set(picks.joined())
let cellWidth = 300.0
var cells: [Int: CGImage] = [:]
let colourSpace = CGColorSpace(name: CGColorSpace.sRGB)!
try eachFrame { number, _, buffer in
    guard wanted.contains(number) else { return }
    CVPixelBufferLockBaseAddress(buffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
    let width = CVPixelBufferGetWidth(buffer), height = CVPixelBufferGetHeight(buffer)
    let info = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    guard let full = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: width, height: height, bitsPerComponent: 8,
                               bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: colourSpace, bitmapInfo: info)?.makeImage() else { return }
    let cellHeight = (cellWidth * Double(height) / Double(width)).rounded()
    guard let small = CGContext(data: nil, width: Int(cellWidth), height: Int(cellHeight), bitsPerComponent: 8, bytesPerRow: 0,
                                space: colourSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return }
    small.interpolationQuality = .high
    small.draw(full, in: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
    cells[number] = small.makeImage()
}

func seconds(_ value: Double) -> String { String(format: "%.2f", value) }

print("\(name): \(times.count) stored frames, last at \(seconds(times.last!)) s, \(bursts.count) bursts of change")
for (number, burst) in bursts.enumerated() {
    let total = burst.reduce(0) { $0 + changes[$1] }
    let peak = burst.map { changes[$0] }.max() ?? 0
    let span = times[burst.last!] - times[burst[0]]
    let flagged = peak > 0.03 && (burst.count == 1 || peak > 0.7 * total)
    let label = String(format: "b%02d", number + 1)
    print("  \(label) at \(seconds(times[burst[0]])) s: \(burst.count) frames over \(seconds(span)) s, "
        + "largest change \(Int((peak * 100).rounded()))% of the screen\(flagged ? "   <-- most of it in one frame" : "")")

    let shown = picks[number].filter { cells[$0] != nil }
    guard let first = shown.first, let sample = cells[first] else { continue }
    let gap = 6.0, labelHeight = 30.0
    let cellHeight = Double(sample.height)
    let stripWidth = Int(Double(shown.count) * (cellWidth + gap) + gap)
    let stripHeight = Int(cellHeight + labelHeight + gap)
    guard let strip = CGContext(data: nil, width: stripWidth, height: stripHeight, bitsPerComponent: 8, bytesPerRow: 0,
                                space: colourSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { continue }
    strip.setFillColor(CGColor(gray: 0.16, alpha: 1))
    strip.fill(CGRect(x: 0, y: 0, width: stripWidth, height: stripHeight))
    NSGraphicsContext.current = NSGraphicsContext(cgContext: strip, flipped: false)
    for (slot, frame) in shown.enumerated() {
        let x = gap + Double(slot) * (cellWidth + gap)
        strip.draw(cells[frame]!, in: CGRect(x: x, y: gap, width: cellWidth, height: cellHeight))
        ("\(seconds(times[frame])) s" as NSString).draw(at: CGPoint(x: x + 4, y: cellHeight + gap + 6), withAttributes: [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium), .foregroundColor: NSColor.white,
        ])
    }
    let file = outDirectory.appendingPathComponent("\(name)--\(label).png")
    if let image = strip.makeImage(),
       let destination = CGImageDestinationCreateWithURL(file as CFURL, "public.png" as CFString, 1, nil) {
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}
