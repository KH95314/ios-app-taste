---
id: proof-timer
name: A wait with a picture that shows it
direction: 08 Warm Organic
also_fits: 04 Soft Wellness, 07 Immersive Environment
kind: session
code: ProofTimer.swift
look: ../WarmLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator at the default text size, on iPhone 17 in light and dark and on iPhone SE. A UI test has pressed "+10 min" and "It's ready now" on iPhone 17 in light, and the motion was recorded and read frame by frame. Pause, Resume and the timer's own counting are not verified.
---

# A wait with a picture that shows it

Someone waits through something slow and comes back to look. A drawn picture fills the top of the
screen and shows how far along it is: here, dough climbing a jar toward a band. The time left is
under it, with what comes next.

## Use it when

- The wait is long enough to walk away from: proofing, steeping, drying, a slow cook.
- Progress can be drawn as one thing moving toward one mark.
- There is one thing to do while waiting and one thing to do when it ends.

## Use something else when

- The wait is seconds. A picture has no time to mean anything; use a plain progress indicator.
- Several waits run at once. Use rows, each with its own time.
- The figure must be read exactly and often. Use the hero metric.
- The person acts all the way through, as in a recording. Use the take in progress.
- Nothing in the picture would change. Then it is decoration; keep it small or leave it out.

## Do

| Decision | Basis |
| --- | --- |
| A drawn picture leads: it fills the top of the screen. | Rule. An illustration is the largest thing on the screen in 3 apps: E1, E2, E3 |
| The picture runs edge to edge under the status bar and ends in a soft uneven edge. | Our choice. E1 sets its picture in a round-cornered panel; E3's fills the screen |
| The picture does work: the dough climbs the jar as the time passes. | Our choice. No reference image shows a picture that changes with progress |
| The dough glides to each new height. It never jumps. | Our choice. No reference shows motion |
| On arrival the dough swells a little past the band and settles, and the tag turns over: berry, with its word in cream. | Our choice. This is the one moment on the screen |
| Bubbles drift up while the timer runs, and hold still when it is paused or done. | Our choice. In a glance, a stopped timer otherwise looks the same as a running one |
| The words and the buttons change at once, with a blur. The picture takes its time. | Our choice, forced by the test: under one slow animation, the minutes and "Ready" showed on top of each other |
| One mark in the picture shows where done is, and it carries the picture's one word. | Our choice |
| Shapes are flat, with slightly uneven edges. No gradients and no faces. | Common practice for flat shapes with soft or uneven edges: 2 apps, E1 and E3. Leaving out faces is our choice; E1's are its brand |
| The picture has its own palette and is the same in light and dark. The page under it changes. | Our choice. E1 shows a light screen and a dark one, each with a different picture |
| The thing that changes and the mark for done are the two pairs that must read. The rest is setting. | Our choice, from a measurement: the dough is 3.3:1 on the field, and the band is 7.4:1 against the dough |
| The control on the picture is a cream disc. | Common practice. Round white buttons on the illustration in 2 apps: E1, E3 |
| Buttons are fully rounded. | Rule. Round or softly cornered buttons and panels in 3 apps: E1, E2, E3 |
| One full-width main button at the bottom, with one text button under it. | Recorded only: a full-width main action in E1. The text button is our choice |
| One hue for actions, the deep tone of the clay in the picture. | Our choice. E1's main button is blue |
| The step is a large serif title. What is being made sits over it, small. | Our choice. E1 has a large title under its picture |
| The time left is the largest text. Under it, when that is on the clock. | Our choice. The clock time saves a sum |
| The control that changes the time sits beside the time, as a quiet pill. | Our choice |
| A row of pebbles shows where this step sits in the whole job, with the next step in words. | Our choice |
| When the wait is over, the picture, one word and the main button say so. No message, no praise. | Guard rule G1 |
| The person can end the wait early or add to it. The clock does not decide alone. | Our choice. Dough is ready when it has doubled, not when a time has passed |
| A notice is one line over the title, with its fix at its end. The picture gives up the height. | Our choice |
| With nothing on the go, the jar stands empty, with a title and one button. | Our choice |
| In a short frame the drawing shrinks, so its subject stays clear of the bar above it. | Our choice, forced by the test |
| On a narrow phone the next step goes under the pebbles. | Our choice, forced by the test |

## Common failures

- A picture that never changes: a mascot beside a countdown.
- A ring and a percentage beside the picture, saying the same thing three times.
- Praise and confetti when the time is up.
- A page in browns and beiges alone, which reads as dull, not warm.
- A picture recoloured for dark until it is muddy.
- A known product's characters, or faces borrowed to make the screen friendly.
- Words laid over the busy part of the picture.
- Minutes left with no clock time, so the person does the sum.
- A mark for done that vanishes against the thing that reaches it.
- A timer that cannot be told it is wrong.
- A picture that jumps from one state to the next.
- Words cross-fading on top of each other while the picture moves.
- Motion that goes on when nothing is happening.

## Verify

1. Cover the words. The picture still says roughly how far along it is, and where done is.
2. Compare a middle moment with the end. The thing that changes stands at a different height, and at the end it meets the mark.
3. Measure the two pairs that carry the meaning. Measured here: the dough on the field 3.3:1; the band against the dough 7.4:1.
4. Switch between light and dark. The picture does not change; the page does. Measured here, the lowest text pair is the text button in light, 4.9:1.
5. Small iPhone, with the notice showing: the picture's subject is clear of the bar, nothing is cut short, and both buttons are on the screen.
6. When the wait ends, look for a message. There is none; the picture, one word and the main button have changed.
7. Add time. The minutes, the clock time and the picture all change.
8. Name what each line of text says that the picture does not (guard rule G1).

Steps 6 and 7 were run by a UI test on iPhone 17 in light and read from a recording. Step 2 was
checked from screenshots of two fixed moments: 74 minutes into a rise of 112, and done.

## States

| State | What the sample shows |
| --- | --- |
| Loading | The picture with an empty jar; placeholders for the words; the buttons unavailable |
| Empty | Nothing on the go: the empty jar, "Nothing rising", and one button, "Start a first rise" |
| Paused | "Paused" in place of the clock time; the main button reads "Resume" |
| Failed, with the timer still running | One line over the title: "Alerts are off" and "Turn on". The timer and the picture stay |
| Failed, nothing to show | A plain page with the cause and a retry. Not screenshotted |
| Success | The dough at the band, and the tag in berry; "Ready", "Doubled in 1 h 52 min"; the pebbles one step on; the main button reads "Shape the loaf", with "Give it 10 more min" under it |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown. The
evidence for this direction is thin: two of the three apps have a single usable image.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Headspace (`headspace/03`, `/04`, `/05`, `/06`) | An illustration in a round-cornered panel at the top: a sun with a sleeping face on orange and pink shapes; three round white buttons on it; a large title, one line of facts, a paragraph; rows with a radio mark; an outlined pill; a full-width blue pill, "Play"; a navy screen with a blue wave illustration | [App Store](https://apps.apple.com/us/app/headspace-sleep-meditation/id493145008) |
| E2 | Lake (`lake/04`) | A dark screen; a search field; a two-column grid of drawings on round-cornered cards, the artist's name under each; a tab bar in a pill | [App Store](https://apps.apple.com/us/app/lake-coloring-book-for-adults/id1183717726) |
| E3 | Pok Pok (`pok-pok/01`) | An illustrated street fills the screen: flat shapes with slightly uneven edges in red, yellow, blue and teal; one round white button with four coloured dots; no words | [App Store](https://apps.apple.com/us/app/pok-pok-montessori-preschool/id1550204730) |

Recorded only, each seen in one app: Headspace's faces on its shapes and its blue "Play" pill (E1);
Lake's line drawings by many artists and its tab bar in a pill (E2); Pok Pok's screen with no words
and its four-dot button (E3). These are brand decisions and are not copied.

## Not shown by the evidence

- A picture that changes with progress, or with anything the person does.
- A timer, or any session in progress.
- Loading, a failure, or a first run with nothing started.
- Whether any of them keeps one picture across light and dark.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- The first look for this direction was a page in browns and beiges with a plain half-circle in a
  bowl, and a bare lower half. It was rejected at review as not good enough, with no reason given.
  Our reading of why: one hue, a picture too plain to enjoy, and an empty half. This look answers
  each of the three.
- Fixing the picture's height before letting it run under the status bar made it keep its height
  and slide up, which left a bare band between the picture and the words. It has to reach into the
  safe area first and take its height second.
- On a 375-point phone the line beside the pebbles was cut short once the wait was over. It now goes
  under the pebbles when it does not fit.
- With the notice showing on a small phone, the picture was cropped from the top until the jar met
  the status bar. The drawing now shrinks in a short frame. The field and the counter then have to
  run on past the drawing's sides, and the counter's edge has to carry on smoothly; a first attempt
  left a corner there.
- The band is 3.3:1 on the glass above the dough and 7.4:1 against the dough. Its two short ends,
  over the bare field, are 2.3:1. The tag beside it names it.
- The quiet pill is white on a cream page, 1.1:1 in light and 1.2:1 in dark. Its label, at 16.3:1
  and 13.0:1, is what marks it.
- The lower half of one leaf sits on the field, at 1.7:1, not on the sun. It is setting and was left.
- The light and dark screenshots show the same picture, as intended. The bubbles are placed by the
  clock, so they stand in different places from one screenshot to the next.
- The bubbles first looped by taking the time modulo the height they climb. While the dough's
  height animated, that height changed a little each frame and the bubbles jumped all over the jar.
  Each is now a share of the way up, scaled to the height.
- One animation for the whole change let the minutes and "Ready" cross-fade on top of each other for
  a third of a second. The words now swap in under a fifth of a second, and only the picture keeps
  the slow spring.

## Make it yours

The kitchen, the jar and the palette belong to the sample. Draw your own thing that changes, and
decide first what the mark for done is; then check that those two read against each other and
against the field. Keep the page under the picture plain. The sample's dough rises in step with the
clock and glides to each new height. A real rise depends on the room, which
is why the person can call it ready early or add ten minutes.
