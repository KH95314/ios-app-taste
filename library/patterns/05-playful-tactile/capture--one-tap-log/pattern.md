---
id: one-tap-log
name: A one-tap log that stacks up
direction: 05 Playful & Tactile
also_fits: 04 Soft Wellness, 09 Metric Hero
kind: capture
code: OneTapLog.swift
look: ../TactileLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator on iPhone 17 in light and dark and on iPhone SE. A UI test has pressed the +10, Undo and +20 keys on iPhone 17 in light, and the motion was recorded and read frame by frame. Not used by hand, so nothing here says how a press feels; haptics cannot be checked on a simulator. The largest-text screenshots are older than the motion.
---

# A one-tap log that stacks up

Three big keys at the bottom of the screen. Each press adds to a stack of blocks, and the stack is
the progress. The keys look pressable, and what a press makes looks like the key that made it.

## Use it when

- People log one kind of thing, many times, in a few fixed amounts.
- There is a daily goal, and progress toward it is worth seeing as a whole.
- The product wants the action to feel like play.

## Use something else when

- The amount is different every time. Lead with a number field or a dial.
- Each entry needs detail: a note, a place, a category. That is a form.
- The setting is serious. Medicine, money and work records should not look like a toy.
- People only read the total and never enter anything. That is a status screen.

## Do

| Decision | Basis |
| --- | --- |
| The screen is one loud colour, in light and in dark. | Rule. A saturated full-colour ground in 3 apps: E2, E3, E5. The violet and its dark form are our choice |
| A key has a lower edge in a darker tone of its fill. | Rule. Controls drawn with depth in 3 apps: E1 and E2 (a lower edge), E4 (an embossed disc) |
| Pressed, the key moves down onto its edge. | Our choice. A still image cannot show a press, so no reference supports it |
| With Reduce Motion on, the edge disappears and the key does not travel. | Our choice |
| An unavailable key is flat: no edge, a quiet fill. | Our choice |
| A new block falls into its place from the top of the tray. Two fall one after the other. | Our choice. No reference shows motion |
| As a block lands, the stack is pressed down a little and springs back. | Our choice. The stack is made of solid things, so it takes weight |
| Motion here is what solid things do: fall, land, settle. Nothing ripples, glows or fades in from nowhere. | Our choice. A liquid or a glow belongs to another direction |
| When the goal is met, the mark on the top block hops once. | Our choice |
| Progress is a stack of blocks, one per step, with empty steps as dashed slots. | Rule. Progress as a thing that fills or grows in 4 apps: E1 (a thick bar), E2 (a dashed journey), E3 (a figure), E4 (a mountain). A stack of blocks is our choice |
| The count is also written out, under the stack. | Common practice. A figure with its number in 2 apps: E3 ("52oz, 80% of your goal"), E4 ("60 / 60") |
| A key and a block share one fill. Nothing decorative uses it. | Our choice. A press visibly turns into a block |
| The keys sit at the bottom edge. | Recorded only: E2 puts its main button there in two screens |
| After a press, a second key offers to undo it and names what it undoes. | Our choice, and guard rule G1: the key says it, so no message follows a press |
| The week is a row of discs, ticked when the goal was met. Today has a ring. | Rule. Seen in 3 apps: E1, E4, and Apple Books' reading goal (`apple-books/05`) |
| Reaching the goal fills the stack, marks the top block and ticks today. No sentence announces it. | Guard rule G1. It departs from E1, E2 and E4, which each show a celebration screen with words |
| Type is the rounded design in heavy weights. | Rule. Rounded heavy type in 3 apps: E1, E2, E3 |
| There is no mascot. | The brief: no app's brand is copied. E1, E2 and E3 each have one, and it is theirs |
| Text on the ground is white or near white, and small text has its own colour. | Our choice, from a measurement: white is 7.2:1, the small-text colour 5.0:1. The system's secondary grey fails on this ground |
| The two bar buttons draw their own disc. | Our choice, forced by the test: the system's glass button turned pale and lost its white glyph |
| The stack gives up height before anything scrolls: its blocks stretch between 18 and 47 points. | Our choice, forced by the test: with a notice or the undo key showing, full-height blocks no longer fit |
| The stack is one view at every height. | Our choice, forced by the test: built as a choice among fixed heights, the whole stack was swapped when the undo key took its room, so no block could be seen arriving and the screen jumped |
| At the accessibility text sizes the keys stack one above another and come straight after the count; the week becomes a sentence. | Our choice, forced by the test |
| A failure is a notice on a quieter panel, with an icon and words and no red. | Our choice. On this ground a warning colour fights the keys |

## Common failures

- Depth on everything, so nothing says "press me" more than anything else.
- The key colour reused for decoration.
- A mascot or illustration style lifted from a known app.
- A progress ring where an object would do, in a direction that is about objects.
- "Great job!" after every press.
- No undo on a one-tap action.
- Keys in the middle of the screen, out of reach of a thumb.
- Grey secondary text on a saturated ground.
- An animation that cannot be turned off, on a screen used many times a day.
- A new block that fades in where it stands, so the press and the block are not connected.
- Motion borrowed from another material: a ripple or a glow on a screen made of blocks.
- A layout that rearranges under the thing that is moving.
- The stack or the week as the only place the number can be read.

## Verify

1. Press and hold a key: it sits down on its edge. Release: it comes back. With Reduce Motion on it changes without moving.
2. Press a key: a block falls in from the top of the tray and lands, the stack gives a little, the count rolls, and an undo key names the amount. Press undo: all three go back. Press +20: two blocks fall one after the other.
3. Reach the goal: the stack is full, the top block is marked, today is ticked, and no message appears.
4. Greyscale screenshot: a met day can still be told from an unmet one, by its tick.
5. Measure the text: on the ground, on the quieter panel, and on both key fills. Measured here: 7.2, 9.1, 10.5 and 16.6 to 1.
6. Dark appearance: the ground is the deep form and the keys are unchanged.
7. Small iPhone with a notice showing: the stack is shorter and nothing is cut off.
8. Largest accessibility text size: three keys one above another, each label on one line, reachable without scrolling past the stack.
9. VoiceOver reads the count as "40 of 60 minutes today" and each key as "Add 10 minutes". The stack itself is skipped.
10. Read every sentence on the screen and name what it says that the stack and the keys do not (guard rule G1).

Steps 2 and 3 were run by a UI test on iPhone 17 in light and read from a recording. Holding a key down
was not run. The other steps were checked from screenshots, and steps 8 and 9 before the motion was added.

## States

| State | What the sample shows |
| --- | --- |
| Loading | An empty stack of slots, placeholder count, flat keys |
| Empty | No goal yet: a title and one key, "Set a goal" |
| Failed, with today's minutes | A notice on a panel: not synced, and that today's minutes are kept on the phone. Logging still works |
| Failed, nothing known | A full-screen message with the cause and a key to retry |
| Success | A full stack with the top block marked, "60 of 60 min", today ticked, and the undo key |

## Evidence

Promotional images from the App Store and a design gallery, not captures of a running app. App
versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Duolingo, lesson and streak (`duolingo/02`, `duolingo/04`, `duolingo/06`) | Option cards and word chips with a heavier lower edge; a thick progress bar; bold rounded type; "3 day streak" with a week row of ticked discs | [App Store](https://apps.apple.com/us/app/duolingo-learn-languages/id570060128) |
| E2 | Finch, goals (`finch/03`, `finch/04`, `finch/05`) | A full-colour scene; goal rows as white cards with a lower edge and a square tick button; a dashed journey track; full-width buttons with a darker lower edge at the bottom; a celebration with confetti and a headline | [App Store](https://apps.apple.com/us/app/finch-self-care-pet/id1528595748) |
| E3 | Waterllama, today (`waterllama/07`, `waterllama/09`) | "52oz" and "80% of your goal" in bold rounded type over a figure filled from the bottom in colour bands; a grid of bright tiles | [App Store](https://apps.apple.com/us/app/water-tracker-waterllama/id1454778585) |
| E4 | (Not Boring) Habits (`not-boring-habits/02`, `not-boring-habits/04`) | One large embossed round button with "1 / 2X"; a week row of ticked discs; a 3-D mountain titled "The Summit" with "60 / 60" | [Godly gallery](https://godly.design/app/not-boring-habits/) |
| E5 | (Not Boring) Calculator (`not-boring-calculator/03`) | A full orange ground; a huge 3-D result; keypad digits with no key backgrounds | [Godly gallery](https://godly.design/app/not-boring-calculator/) |

Recorded only, each seen in one app: Duolingo's speech-bubble prompts and energy counter (E1); Finch's
pet and its journeys (E2); Waterllama's animal for every challenge (E3); the 3-D rendering of
(Not Boring) apps (E4, E5). These are brand property and are not copied.

## Not shown by the evidence

- What a press looks like, or feels like, in any of these apps. No motion and no haptics.
- Undo, a failure, loading, or an empty first run.
- How any of them behave at large text sizes.
- Whether people keep using a playful log after the first week.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- On a saturated ground the system's glass bar button was dark at one size and pale at another, and
  its glyph stayed white. The bar buttons now draw their own disc in the panel colour.
- The system's unavailable view sets its detail text in a grey that fails on this ground, so the empty
  and failed screens are built from the look's own colours.
- Measured before building: a bright block on a light tinted ground did not reach 3:1 as a shape.
  That is why the ground is deep and the blocks are bright, and not the other way round.
- One notice or one extra key is enough to push a full-height stack off an iPhone 17 screen. The
  stack's blocks now stretch, and take the tallest height that fits.
- The first press of a key stopped the app. Built in Swift 6 language mode, SwiftUI called the
  stack's `ForEach` closure away from the main thread while the stack animated, and the runtime's
  check on that closure ended the app. No screenshot could have shown it. See the library's README.
- The first version chose among four fixed block heights. When the undo key took its room, a
  different stack was shown in place of the old one with no transition: the screen jumped, and a
  block could not be seen arriving. Both were invisible in screenshots.
- On a 375-point phone with the notice or the undo key showing, blocks no shorter than 26 points
  left no room for the week. They may now go down to 18.
- Seven discs with letters do not fit the accessibility sizes. A sentence does.

## Make it yours

Change the ground, the key fill and what a block stands for. Keep the rule that gives this direction
its sense: an edge means "you can press this", and the key's colour means "a press made this". If the
product has a character of its own, it can live here; this sample has none because it has no product
behind it. A real app should also decide how long the undo key stays.
