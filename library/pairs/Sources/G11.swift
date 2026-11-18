import SwiftUI

// G11. No ceremony before the job.
// A rain alert app, opened for the first time.

private let minutes: [Double] = [0, 0, 0.1, 0.25, 0.5, 0.8, 1.0, 0.9, 0.7, 0.45, 0.3, 0.15]

/// Bad on purpose: three pages stand between the person and the weather. The
/// first is about the app, the second asks for an account and the third for
/// notifications. Every control works; the failure is that the pages are there.
struct G11Bad: View {
    @State private var page = 0
    @State private var started = false

    private let pages = [
        (title: "Welcome to Drizzle",
         line: "Get hyper-local rain alerts powered by AI, so you never get caught in the rain again."),
        (title: "Create your account", line: "Sign up to keep your places on all your devices."),
        (title: "Turn on notifications", line: "Allow alerts so we can warn you before it rains."),
    ]

    var body: some View {
        if started {
            G11Good()
        } else {
            VStack(spacing: PairLook.margin) {
                HStack {
                    Spacer()
                    Button("Skip") { started = true }
                        .font(PairLook.body)
                        .foregroundStyle(PairLook.accent)
                        .frame(minHeight: PairLook.hit)
                }
                Spacer()
                Image(systemName: "cloud.rain.fill").font(.system(size: 110)).foregroundStyle(PairLook.ink)
                Text(pages[page].title).font(PairLook.title).foregroundStyle(PairLook.ink)
                Text(pages[page].line)
                    .font(PairLook.body)
                    .foregroundStyle(PairLook.quiet)
                    .multilineTextAlignment(.center)
                Spacer()
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == page ? PairLook.ink : PairLook.rule)
                            .frame(width: index == page ? 22 : 8, height: 8)
                    }
                }
                Button(page == pages.count - 1 ? "Get started" : "Next") {
                    if page == pages.count - 1 { started = true } else { page += 1 }
                }
                .buttonStyle(PairMainButton())
                Text("By continuing you agree to our Terms and Privacy Policy")
                    .font(PairLook.note)
                    .foregroundStyle(PairLook.quiet)
            }
            .padding(PairLook.margin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PairLook.ground)
        }
    }
}

/// Good: the app opens on its answer. Alerts need a permission, and that is
/// asked for where the alert is offered, when the person chooses it.
struct G11Good: View {
    @State private var alerts = false

    var body: some View {
        PairPage {
            PairHead("Mill Street · now")
            Text("Rain in 25 min").font(PairLook.figure).foregroundStyle(PairLook.ink)
            Text("Light rain until about 4:10 PM")
                .font(PairLook.small)
                .foregroundStyle(PairLook.quiet)
                .padding(.bottom, PairLook.groupGap)

            PairHead("Next hour, every 5 minutes")
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(minutes.enumerated()), id: \.offset) { _, amount in
                    Rectangle().fill(PairLook.ink).frame(height: 4 + 76 * amount)
                }
            }
            .frame(height: 80, alignment: .bottom)
            HStack {
                Text("Now")
                Spacer()
                Text("30 min")
                Spacer()
                Text("60 min")
            }
            .font(PairLook.small)
            .foregroundStyle(PairLook.quiet)
            .padding(.bottom, PairLook.groupGap)

            PairRow(name: alerts ? "Alerts are on" : "Alerts are off", detail: "Ten minutes before rain here") {
                // The sample only flips a value. A real app asks the system for
                // permission here, when the person presses, and not at launch.
                Button(alerts ? "Turn off" : "Turn on") { alerts.toggle() }
                    .font(PairLook.strong)
                    .foregroundStyle(PairLook.accent)
                    .frame(minHeight: PairLook.hit)
            }
        }
    }
}
