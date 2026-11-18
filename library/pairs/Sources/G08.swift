import SwiftUI

// G8. Readable and pressable before pretty.
// A sleep-sound player with one sound playing.

/// Bad on purpose: the same words and the same two controls, drawn too pale,
/// too thin and too small. The text is dimmed with opacity until it fails its
/// contrast figure, and the two glyphs have no place to press round them.
struct G08Bad: View {
    @State private var playing = true
    @State private var closed = false

    var body: some View {
        PairPage {
            HStack(alignment: .firstTextBaseline) {
                Text(closed ? "STOPPED" : "NOW PLAYING")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(PairLook.quiet.opacity(0.5))
                Spacer()
                Button {
                    closed = true
                    playing = false
                } label: {
                    Label("Stop", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(PairLook.ink.opacity(0.35))
                }
            }
            .padding(.bottom, PairLook.rowGap)
            Text("Rain on a tin roof")
                .font(.system(size: 22, weight: .ultraLight))
                .foregroundStyle(PairLook.ink.opacity(0.4))
            Text("45 min left · fades out at the end")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(PairLook.quiet.opacity(0.45))
                .padding(.bottom, PairLook.groupGap)

            Button {
                playing.toggle()
                if playing { closed = false }
            } label: {
                Label(playing ? "Pause" : "Play", systemImage: playing ? "pause" : "play")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 12))
                    .foregroundStyle(PairLook.ink.opacity(0.4))
            }
        }
    }
}

/// Good: ink on a solid ground, a quiet line that still passes 4.5:1, and
/// controls with a 44-point place to press and their names beside them.
struct G08Good: View {
    @State private var playing = true
    @State private var closed = false

    var body: some View {
        PairPage {
            HStack(alignment: .firstTextBaseline) {
                PairHead(closed ? "Stopped" : "Now playing")
                Button {
                    closed = true
                    playing = false
                } label: {
                    Label("Stop", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                        .font(PairLook.strong)
                        .foregroundStyle(PairLook.ink)
                        .frame(width: PairLook.hit, height: PairLook.hit)
                }
            }
            Text("Rain on a tin roof").font(PairLook.title).foregroundStyle(PairLook.ink)
            Text("45 min left · fades out at the end")
                .font(PairLook.small)
                .foregroundStyle(PairLook.quiet)
                .padding(.bottom, PairLook.groupGap)

            Button {
                playing.toggle()
                if playing { closed = false }
            } label: {
                Label(playing ? "Pause" : "Play", systemImage: playing ? "pause.fill" : "play.fill")
            }
            .buttonStyle(PairMainButton())
        }
    }
}
