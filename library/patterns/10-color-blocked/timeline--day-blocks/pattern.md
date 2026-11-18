---
id: day-blocks
name: A day in colour blocks
direction: 10 Color-Blocked Structure
also_fits: 05 Playful & Tactile, 04 Soft Wellness
kind: timeline
code: DayBlocks.swift
look: ../BlockLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator in light, dark and the largest text size. Not used by hand.
---

# A day in colour blocks

A day drawn as a stack of blocks. A block's fill is its category, its height follows its length, and a
line shows where the day has got to. Everything that is not a block is black or white.

## Use it when

- Items are placed in time, one after another, and each has a length.
- Each item belongs to one of a few categories that people already think in.
- People look at the screen to answer "what now, and what next?"

## Use something else when

- Items have no time or order. A list is enough.
- There are more than about five categories. The colours stop being told apart; use labels.
- Many items overlap. That needs columns, which a phone held upright has no room for.
- One number matters more than the schedule. Lead with the number.

## Do

| Decision | Basis |
| --- | --- |
| Each item is a block filled with its category's colour. | Rule. Seen in 3 apps: E1, E2 and E3 (in E3 the colour follows position in the list) |
| Text and icons on a block are solid white. | Rule. White on the fill in 3 apps: E1, E2, E3 |
| Every fill is deep enough for white text at 4.5:1. | HIG, Accessibility: 4.5:1 for text up to 17 pt. Measured here: 5.0, 5.4, 6.3, 6.3. Some reference fills look too light for this; it cannot be measured from a promotional image |
| The fills are the same in light and dark. | Our choice. The fill is the category, so it does not shift with the appearance |
| Each category also has its own icon, beside the detail line. | HIG, Color: avoid relying on colour alone. An icon per item in 2 apps: E1 (inside the block), E4 (a disc beside the title) |
| Blocks are 4 pt apart with rounded corners, so the day reads as one stack. | Our choice. E3 has no gaps at all; E2 sets cards well apart |
| A longer block is taller, within limits, and never shorter than its text. | Recorded only: in E1 the length of a block follows its duration. The limits are our choice |
| The length is always written out, before where or who. | Recorded only: E4 writes each time range in words |
| Start times sit in a column left of the blocks. | Our choice |
| Now is a white line across the current block, under its text, with the time beside it in ink. | Our choice. No reference image shows where the day has got to |
| Every block has a ring to tick at its top right. | Recorded only: E4 has a circle at the right of each task |
| A finished item gives up its colour and its height: a tick and one struck-through line. | Common practice. Seen in 2 apps: E3 (struck through on black), E4 (struck through with a filled tick) |
| A break is a neutral block one line tall. | Our choice. A break is not a kind of work, so it gets no category colour |
| Every control is ink: the selected day, the add button, text buttons. | Common practice. Black controls beside coloured content in 2 apps: E2, E4 |
| The week sits above the day as seven dates. | Common practice. Seen in 2 apps: E1, E4 |
| At the accessibility text sizes the week becomes one day with a step either side, and the time moves inside the block. | Our choice, forced by the test: seven columns cannot hold a date each at those sizes |
| The day's name and the week are one solid header that stays put. | Our choice, forced by the test: with the system's large title, the title was drawn faded while blocks were behind it |
| Placeholders, a notice and an empty day are neutral. | Our choice. Until something has a category it gets no category colour |

## Common failures

- A category shown by colour only, with no icon or word.
- White text on a yellow or pale fill.
- A block dimmed with opacity to show that it is later or done, so its text fails contrast.
- A control drawn in a category colour, so a button reads as a kind of task.
- Height strictly proportional to length: a ten-minute block too short for its name, a three-hour block
  filling the screen.
- A tinted background behind the blocks, so the fills lose their edge.
- More than five category colours.
- A now line drawn through the block's text.
- A legend explaining the colours, when each block could carry its own icon.

## Verify

1. Squint at the loaded day: the categories can be counted and the current block found.
2. Greyscale screenshot: every block's category is still readable from its icon.
3. Measure the white text on every fill. Each is 4.5:1 or better.
4. Dark appearance: the fills are unchanged, and each still stands off the ground. Measured here: 3.3:1 to 4.2:1 against black.
5. The now line sits in clear space under the text, and the time beside it is level with the line.
6. Tick a block: it becomes one struck-through line, and can be unticked.
7. Largest accessibility text size on a small iPhone: the header is one line of day with two arrows, the time is inside each block, nothing is truncated, and the ring is still 44 pt.
8. An unplanned day: the screen has no colour at all, and offers one way to add and one to copy.
9. Read every sentence on the screen and name what it says that the blocks do not (guard rule G1).

## States

| State | What the sample shows |
| --- | --- |
| Loading | Neutral blocks of different heights under the real header. The add button is unavailable |
| Empty | "Nothing planned for Sunday", an ink button to add a block, a text button to copy the same day last week |
| Failed, with a saved plan | A neutral notice above the day: offline, and when this plan was saved. The plan stays and can be ticked |
| Failed, nothing saved | A full-screen message with the cause and a retry |
| Success | The ticked block is now a struck-through line, and the next block carries the now line |

## Evidence

Promotional images from the App Store and a design gallery, not captures of a running app. App
versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Structured, week (`structured/09`) | Seven day columns; each day a track of capsule blocks whose length follows duration; fills in coral, blues, maroon and green; a white icon in each | [App Store](https://apps.apple.com/us/app/structured-daily-planner-todo/id1499198946) |
| E2 | Actions, schedule and lists (`actions/01`, `actions/02`, `actions/05`) | A black ground; task cards filled with their list's colour, white text; each list a full-height card in its colour; black chips and black round controls on light sheets | [Godly gallery](https://godly.design/app/actions/) |
| E3 | Clear, lists (`clear/05`, `clear/06`, `clear/08`) | Full-width colour rows with no gaps, the colour stepping down the list; large white text; done items struck through on black | [App Store](https://apps.apple.com/us/app/clear-to-dos-reminders/id493136154) |
| E4 | Tiimo, day (`tiimo/03`, `tiimo/06`) | A week strip with the selected day boxed; white cards, each with a coloured icon disc, a title and "8.30 → 9.00"; a circle to tick at the right; a done item struck through with a filled tick; a black pause pill on the timer | [App Store](https://apps.apple.com/us/app/tiimo-to-do-list-planner/id1480220328) |

Recorded only, each seen in one app: Structured joins its blocks with a line down each day (E1); Clear
shades one colour from the top of the list to the bottom (E3); Tiimo groups a day into Anytime,
Morning, Day and Evening (E4); Actions lets people pick each list's colour from a field of discs (E2).
These are brand and product decisions and are not copied.

## Not shown by the evidence

- A marker for the present moment in any of the four apps.
- What happens when two items overlap.
- An empty day, loading, or a failure.
- How any of them behave at large text sizes.

## Found by testing the sample

These came from screenshots of our own build, not from the references.

- Under a pinned bar, the system's large navigation title was drawn washed out whenever blocks were
  behind it. The header draws its own title on a solid ground instead.
- A line placed by time alone crossed the block's name early in the block. The line now travels only
  through the space under the text, and a current block keeps room for it.
- Aligning the time label to the line with an alignment guide left it at the top of the row, on top of
  the start time. A zero-height frame offset to the line's position holds it level.
- Seven date columns do not survive the accessibility sizes. One day with two arrows does.
- At those sizes a finished row reads "name, time". Only the name is struck through, because the time
  is still a fact.

## Make it yours

The four fills belong to the sample. Choose your own, five at most, by how your product's categories
differ, and check white text on each one. Keep the split that makes this direction work: colour means
category, and ink means control. The sample passes a fixed time for "now" so that its screenshots are
stable; a real screen reads the clock.
