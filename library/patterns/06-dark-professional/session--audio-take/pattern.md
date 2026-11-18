---
id: audio-take
name: A take in progress
direction: 06 Dark Professional
also_fits: 13 Canvas-First Creation, 03 Data Precision
kind: session
code: AudioTake.swift
look: ../ProLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator at the default and the largest text size. Not used by hand, so nothing here says how the controls feel. The levels and waveform are fixed sample data.
---

# A take in progress

Someone is operating a tool on live material. The work fills the top of the screen, the running time
and the levels sit under it, and the controls stay in a panel at the bottom. The screen is black in
both appearances.

## Use it when

- The screen is used while something is happening: recording, filming, measuring, mixing.
- The operator reads values in a glance and must not be dazzled or distracted.
- A wrong press costs the take.

## Use something else when

- Nothing is live. A dark, dense screen for browsing is harder to read and has no reason to be.
- The audience is casual. A voice memo for a shopping list needs one button, not a panel.
- The work is a document to be read. Use a light page.
- The product must follow the system appearance. This look has one.

## Do

| Decision | Basis |
| --- | --- |
| The ground is black, in light and in dark. The work is the only large bright thing. | Rule. Seen in 3 apps: E1, E2, E3. No image shows a light version of any of them |
| The work is on top and the controls are a panel under it. | Common practice in portrait. Seen in 2 apps: E1, E3 |
| One hue marks what is being adjusted: the value, its tick on the ruler, the playhead. | Rule. One hue for the selected thing in 3 apps: E1 (yellow), E2 (blue), E3 (red). The yellow-green is our choice |
| Values are written as figures beside their controls. | Rule. Seen in 3 apps: E1 ("+0.8"), E2 (the whole top strip), E3 ("50° 85%") |
| Each value sits under a label in small capitals. | Common practice. Seen in 2 apps: E2 (over every value), E1 (mode names) |
| Values are monospaced. | Our choice, so a running time keeps its width as digits change. The faces in the references cannot be told from the images |
| A slider is a ruler of ticks, with one taller tick in the hue. | Common practice. Seen in 2 apps: E1, E2. E3 uses plain sliders and wheels |
| Red means recording, and a clipped level. Nothing else is red. | Recorded only: E2 keeps red for the record button and the timecode |
| Recording is a red dot and the word REC, never the colour alone. | HIG, Color: do not rely on colour alone |
| The record control changes shape: a disc when ready, a square while recording. | Our choice |
| A control with a consequence has a word as well as an icon: Mark, Pause. | Our choice. It departs from the references, where controls are icons without words in 3 apps: E1, E2, E3. Whether those icons are labelled for assistive technology cannot be seen |
| The transport stays at the bottom whatever scrolls above it. | Our choice |
| The transport stops growing at the first accessibility size. Held down, a control shows the large-content preview. | Our choice, forced by the test: at the largest size it covered half a small phone |
| When the input is lost: say what was saved, drop the levels, dim the gain, offer one way back. | Our choice. No reference image shows a failure |
| The one filled button is that way back, in the hue. | Our choice |
| Stopping a take leaves it on the screen as a row with a play control. No message. | Guard rule G1 |
| An unavailable control keeps its place and goes quiet. | Our choice |
| The running time stays on one line and shrinks to fit. | Our choice, as for the number in "One hero metric, explained" |
| At the accessibility sizes the readouts are one column and the meter labels widen. | Our choice, forced by the test: the "R" was cut to look like an "F" |
| The scale under the meters is written out; when it does not fit, only its two ends are. | Our choice, forced by the test |

## Common failures

- A dark theme that also follows the system and turns white in a bright room.
- Red used for a selected tab or a brand accent on a screen where red means recording.
- Several hues, each meaning "selected" somewhere.
- Icon-only controls on actions that cannot be undone.
- A value shown only by a slider's position, with no figure.
- A timecode in a proportional face that shifts as the digits change.
- Controls that move when the state changes, so the thumb lands on the wrong one.
- A toast that says "Recording saved" over the meters.
- Grey labels too faint to read on black.
- A failure that clears the screen and hides how much was recorded.

## Verify

1. Switch the system between light and dark: the screen does not change.
2. Ready and recording differ in three ways: the word, the colour, and the shape of the record control.
3. Greyscale screenshot: recording can still be told, by the word REC and the square.
4. The hue appears only on the gain value, its tick, the playhead and the marks. Red appears only on recording and clipping.
5. Measure the text. Measured here: labels 7.9:1 on the ground and 7.0:1 on the panel; red 6.2:1; the hue 14.3:1 on the panel; lit against unlit meter segments 9.8:1.
6. Lost input: the red label names it, a sentence says what was saved, the levels are empty, and one button offers the way back.
7. Largest accessibility text size on a small iPhone: the time is on one line, the transport is the record control over two buttons, and the readings scroll above it.
8. Scroll to the end at that size: readouts in one column, gain whole, nothing under the transport.
9. Read every sentence on the screen and name what it says that the readings do not (guard rule G1).

## States

| State | What the sample shows |
| --- | --- |
| Loading | "Opening input", dashes for the time, unlit levels, placeholder readouts, a grey record control |
| Empty | Microphone access is off: a title and one button to Settings |
| Failed, with a take | "Input lost" in red with an icon, what was saved, empty levels, input "None", and "Reconnect the input" |
| Failed, nothing known | A full-screen message with the cause and a retry |
| Success | Ready for take 4, with take 3 as a row: its name, its length and a play control |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Halide, camera and edit (`halide/04`, `/05`, `/06`) | A photo over a black panel; mode names in spaced capitals; a ruler with a yellow centre tick and "0.0"; six vertical rulers with a value and a yellow marker each; round icon buttons; a grey X and a yellow tick at the bottom corners | [App Store](https://apps.apple.com/us/app/halide-mark-iii-pro-camera/id885697368) |
| E2 | Blackmagic Camera (`blackmagic-camera/01` to `/04`) | A strip of tiny capital labels over values ("ISO 800", "WB 5600K"); a large timecode, red while recording; the selected value in blue with a vertical ruler beside the picture; a rail of icons; a red record button; a histogram and level meters; a slate of large numerals with step arrows | [App Store](https://apps.apple.com/us/app/blackmagic-camera/id6449580241) |
| E3 | Darkroom, edit (`darkroom/05`, `/08`, `/09`) | A photo over a black panel; a row of tool icons with a red underline under the selected one; colour wheels; "Hue • 50° 85%"; a slider with its label at the left and its value at the right | [App Store](https://apps.apple.com/us/app/darkroom-photo-video-editor/id953286746) |

Recorded only, each seen in one app: Halide's preset thumbnails and its paired cancel and confirm
buttons (E1); Blackmagic's histogram and its slate (E2); Darkroom's three colour wheels (E3). These
are features of those tools and are not part of this pattern.

## Not shown by the evidence

- Anything in motion: a running meter, a ruler being dragged, a control being pressed.
- A failure, a missing permission, a full disk, or loading.
- How any of these apps behave at large text sizes.
- Whether their icon-only controls carry labels for assistive technology.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- A stacked transport at the largest text size took half a small phone and sat on top of the
  readings. A bar has to give up growing before the content does.
- A panel pinned with a safe-area inset is only as wide as its content unless it is told to fill the
  width. The readings showed either side of it.
- A fixed-width column for the "L" and "R" labels clipped the letters at large sizes.
- The running clock was seen to advance: the recording screenshot reads 00:04:14 from a start of
  00:04:12. That is the only motion this entry can vouch for.
- The system's unavailable view brings its own greys, so the empty and failed screens are built from
  the look's colours.

## Make it yours

Replace the waveform with your work area: a viewfinder, a canvas, a scope. Keep the three colour
rules, which are the direction: black in both appearances, one hue for what is being adjusted, red
for recording only. Pick the hue against your material; a yellow-green shows on a waveform and might
not on foliage. The sample plays fixed data and its Settings and Play buttons do nothing.
