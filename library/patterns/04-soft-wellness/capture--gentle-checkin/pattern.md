---
id: gentle-checkin
name: A check-in without a score
direction: 04 Soft Wellness
also_fits: 08 Warm Organic, 01 Quiet Native Minimalism
kind: capture
code: GentleCheckin.swift
look: ../SoftLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator on iPhone 17 in light and dark and on iPhone SE. A UI test has chosen an answer and saved it on iPhone 17 in light, and the motion was recorded and read frame by frame. Not used by hand. The largest-text screenshots are older than the motion.
---

# A check-in without a score

One question, a few answers of equal standing, and the answer kept as a word. Nothing on the screen
says an answer is good or bad.

## Use it when

- People report on themselves: energy, mood, pain, sleep, appetite.
- There is no right answer, and the product must not suggest one.
- The same question is asked often, so answering has to be quick and calm.

## Use something else when

- The value is measured by a device, not reported. Show the reading and what it means.
- The product is built on goals and progress. A streak or a target is honest there.
- The answer needs detail every time. That is a form, or a journal entry.
- A low answer should trigger help, as in a clinical tool. Then the screen has to say so plainly.

## Do

| Decision | Basis |
| --- | --- |
| Every level is named in a word. | Rule. The state named in words in 3 apps: E1 ("Good", "Normal"), E2 (a word on every circle), E3 (a word under every face) |
| Choices and buttons are round or softly cornered. Nothing has a square corner. | Rule. Round or soft shapes in 3 apps: E1, E2, E3 |
| Each level has its own mark, a ring filled to a height, as well as its word. | Common practice. A shape or a face per state, not only a colour, in 2 apps: E2, E3. The ring is our choice |
| All levels use one hue. No green for good, no red for bad. | Our choice. It departs from E3, which runs from green to red. E2 uses four colours for four kinds of feeling and does not rank them |
| The hue means "yours": the chosen row, the marks, the main button. | Our choice |
| The choices have equal standing. The chosen one is marked the same way whichever it is. | Our choice |
| The chosen row is marked by a tick as well as a tint and a ring. | HIG, Color: do not rely on colour alone |
| The saved answer is compared with the person's own usual, in plain words. | Recorded only: E1 ("As Usual", "Later Than Usual", "Above Typical Sunday") |
| No praise, no streak, no target, no score. | Guard rule G1, and our choice. It departs from E1, which adds a sentence or a paragraph of encouragement on three screens |
| The time of the check-in is shown and can be changed. | Recorded only: E3 shows the date and time as a link under the question |
| Earlier answers from today sit under the choices. | Common practice for showing history as marks: 2 apps, E2 and E3 (calendars and grids). A short list for today is our choice |
| The ground is a slow fade between two near-neutral tones. | Recorded only: E1 uses a soft gradient or glow. E2 is black and E3 is white |
| Once an answer is saved, a soft light in the hue gathers behind it and drifts slowly. | Our choice. E1's glow is the nearest thing in the references; whether it moves cannot be seen |
| The light is the same for every answer: one place, one size, one colour. | Our choice. A light that changed with the level would be a score |
| The level pours into the ring once, as the answer arrives. | Our choice |
| Text on the light is measured where the light is strongest. | Our choice, from a measurement: second ink is 4.8:1 there in light and in dark, and the mark 4.6 and 5.4 |
| The buttons are pinned to the bottom, and their ground fades in. | Our choice. A hard line would be the only edge on the screen |
| Until something is chosen the main button looks like the quiet one. | Our choice |
| A note is optional and one tap away. The button's title says whether there is one. | Guard rule G1 |
| A failure to sync says where the answer is, in neutral colours. | Our choice. A failure to sync is not the person's failure |
| The pinned buttons stop growing at the second accessibility size. | Our choice, forced by the test: at the largest size "Save check-in" took two lines and a third of a small phone |
| An earlier answer and its time stack when they do not fit on a line. | Our choice, forced by the test: "Steady" was broken as "Stea-dy" and "7:40 AM" across two lines |

## Common failures

- A green-to-red scale on a question with no right answer.
- "Great job!" for a high answer, and "It's okay" for a low one. Both are a judgement.
- A streak counter that turns a missed day into a failure.
- A default answer already chosen.
- Tiny or crowded targets on a screen used by people who are tired.
- Faces that mock the low answers.
- A summary that compares the person with other people or with an ideal.
- A second and third question before the first answer is saved.
- A red banner when the answer cannot sync.
- Levels told apart by shade alone.
- A glow that is brighter or warmer for a high answer.
- A ground that moves fast enough to be noticed while reading.

## Verify

1. Cover the words: the five marks can still be put in order by how full they are.
2. Greyscale screenshot: the chosen row is still found, by its tick.
3. Choose the lowest answer and save. The saved screen has the same layout, the same colours and the same light as for the highest.
4. Read every sentence. None praises, warns or scores.
5. Measure the text and the marks. Measured here, light and dark: second ink 5.9 and 8.4; the hue on the ground 5.7 and 9.5; label on the main button 6.4 and 8.8; a mark on its row 6.4 and 8.2.
6. Offline: the notice says where the answer is kept, in neutral colours.
7. Largest accessibility text size on a small iPhone: the question wraps, two choices are in view above the button, no word or time is broken, and the note button is in the flow.
8. Scroll to the end at that size: earlier answers are whole.
9. Name what each line of text says that the marks and words do not (guard rule G1).
10. Save an answer: the light gathers behind the mark, the level pours in once, and after that only the light moves, slowly.

Step 10 was run by a UI test with "Steady" on iPhone 17 in light and read from a recording. The lowest
and highest answers were not run. Steps 7 and 8 were checked before the motion was added.

## States

| State | What the sample shows |
| --- | --- |
| Loading | The layout with placeholder words and a disabled button |
| Empty | A first check-in: the same question with nothing under it, and no comparison after saving |
| Failed to sync | The saved answer, with a notice above it: not saved to the account, kept on the phone |
| Failed, nothing to show | A full-screen message with the cause and a retry |
| Success | The mark, the word, the time and the comparison with usual; today's answers; Change and Done |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Gentler Streak (`gentler-streak/03`, `/04`, `/05`) | A soft blue gradient with a large simple face; "Today Feels Great" and a paragraph of encouragement; values each with a ticked word under it ("Normal", "As Usual", "Later Than Usual"); "Above Typical Sunday" under a step count | [App Store](https://apps.apple.com/us/app/gentler-streak-workout-tracker/id1576857102) |
| E2 | How We Feel (`how-we-feel/01`, `/02`, `/03`) | A field of coloured circles, each with a feeling word; entries reading "I'm feeling grateful" with a coloured shape, a different shape for each colour; a calendar of those shapes | [App Store](https://apps.apple.com/us/app/how-we-feel/id1562706384) |
| E3 | Daylio (`daylio/02`, `/03`, `/04`, `/06`) | "How are you?" with the date and time as a link; five round faces from green to red, a word under each; round icon toggles for activities; a year as a grid of coloured dots | [App Store](https://apps.apple.com/us/app/daylio-journal-mood-tracker/id1194023242) |

Recorded only, each seen in one app: Gentler Streak's drawn character and its activity path (E1); How
We Feel's serif display face and its photo cards (E2); Daylio's faces and its "Year in Pixels" (E3).
These are brand and product decisions and are not copied.

## Not shown by the evidence

- What any of these apps show right after an answer is saved.
- Reminders, streaks or goals, and how they are worded.
- Loading, a failure, or the largest text sizes.
- Whether people answer more honestly when no answer is marked as better.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- A choice row is barely lighter than the ground (1.1:1). The mark and the word are what make it a
  row; the mark is 6.4:1 on it.
- A single pinned button grows with the text until it owns the screen. It needs a cap, and the content
  above it does not.
- A word and a time side by side break in the middle at large sizes. Each is kept to one line, and the
  pair stacks.
- The system's secondary grey would be about 3.1:1 on this ground. All quiet text uses the look's
  second ink.
- For about a fifth of a second after saving, the question and the answer show on top of each other
  as one fades out and the other in. It was left.
- The light is far easier to see in dark than in light: 1.7:1 against the ground in dark, 1.2:1 in
  light.
- The light is redrawn about twenty times a second for as long as the saved answer is on screen.
  What that costs was not measured.
- Behind the bar, scrolled text fades under the back button. That is the system's own edge and was
  left alone, because the bar has no title to tangle with.

## Make it yours

Change the question, the words and the number of levels; three to five works. Pick the hue for the
product, and keep it to one. If your product does have goals, this is the wrong direction for the
goal screens, and that is fine. The sample keeps times as words and offers two fixed times to change
to; a real app keeps a date and shows a picker.
