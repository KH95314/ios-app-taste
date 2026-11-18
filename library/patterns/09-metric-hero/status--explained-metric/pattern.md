---
id: explained-metric
name: One hero metric, explained
direction: 09 Metric Hero
also_fits: 03 Data Precision, 04 Soft Wellness
kind: status
code: ExplainedMetric.swift
look: ../MetricLook.swift
pictures: sample-light.png, sample-dark.png
status: test entry, second round. Built and screenshotted on the iOS 26.5 simulator; not used by hand.
---

# One hero metric, explained

One number on a coloured plate, several times larger than anything else. The plate's colour and one
word say what the number means, and at most one button says what to do. Other readings come after, as
plain rows.

## Use it when

- People open the screen to learn one value.
- The value needs interpreting. A raw number would leave people asking "is that good?"
- The meaning falls into a few named bands (fresh, stuffy, poor).

## Use something else when

- Several values matter equally. That is a table or a comparison.
- The value is self-explanatory and there is nothing to do about it. A row in a list is enough.
- The main job is entering data. Lead with the input.
- The meaning cannot be put in one or two words. Then the explanation is the content, and it needs a
  screen that is built for reading.

## Do

| Decision | Basis |
| --- | --- |
| One number is the largest thing on the screen by a wide margin; its unit sits beside it, small. | Rule. Seen in 3 apps: E1, E2, E3 |
| The number sits on a plate, and the plate's fill is the state. | Our choice. The references show the state with a ring, an arc, or not at all (E1, E2, E3). A filled plate copies none of them, and the state reads before the number does |
| The plate holds a label, the number, a verdict, a scale and at most one action. Nothing else. | Our choice |
| A short verdict in words comes directly under the number. | Our choice. Recorded in 1 app: E2 (a headline plus two lines). E1 explains the score in a sentence lower down, after the supporting rows. E3 gives no verdict |
| No sentence of advice or explanation on the plate. | Guard rule G1, set in review. It departs from E1 and E2, which both put sentences of explanation near the score |
| The action is one button on the plate, drawn in the plate's two colours swapped. | Common practice for offering a next step. Seen in 2 apps: E1 (link to a breakdown), E2 ("Learn more"). Making it a direct action, and its colouring, are our choice |
| The state has its own icon shape and its own word as well as its colour. | HIG, Color: avoid relying solely on colour |
| The scale is drawn in the plate's one ink colour: outlined segments, the current one filled, a pointer. | Our choice. A second set of state colours inside a coloured plate fails contrast on at least one of them |
| Text on a plate is one solid colour, never dimmed with opacity. | Our choice, from a contrast check: black at 72% passed on amber and failed on red. Measured now: 11.0:1 on blue, 9.4:1 on amber, 6.5:1 (white) on red |
| The plate fills are the same in light and dark. | Our choice. The fill is the message, so it does not dim with the rest of the screen |
| With no current reading the plate turns grey and drops the verdict, the scale and the action. | Our choice. Old data should not produce a present-tense verdict |
| The label above the number always says how current it is: "2 min ago", "last reading 2:10 PM", "connecting". | Our choice. It removes the need for a separate status line |
| Short labels are in capitals with a little tracking, and stay to a few words. | Our choice |
| Everything outside the plate is neutral. | Our choice. The plate is then the only colour on the screen |
| Three or four supporting readings follow, each a label, a value and a comparison with usual. | Rule. Seen in 3 apps: E1 (four rows with trend marks), E2 (score chips), E3 (three figures in a row) |
| The supporting readings are rows, not cards or more plates. | Our choice. E1 uses one grouped panel; E3 uses bare figures |
| The bar title is small, because the number is the real title. | Common practice. Seen in 2 apps: E1 (a small centred title), E2 (a small wordmark, no title) |
| The hero number stops growing at the first accessibility size; everything else scales fully. | Our choice. It is already about six times body size |
| The number and its unit stay on one line, and a longer number shrinks to fit. At accessibility sizes the unit moves under the number. | Our choice, forced by the test: "1,460 ppm" clipped its unit at phone width |

## Common failures

- Four equal stat cards, so nothing is the hero.
- A big number with no words: people cannot tell whether 842 is good.
- A paragraph of advice under the number, when the verdict word and the button already say it.
- State shown only by a coloured ring or coloured digits.
- A second set of traffic-light colours inside the plate.
- Text on the plate dimmed with opacity, so it passes contrast on one fill and fails on another.
- A font size typed as a number, so the screen ignores the text-size setting.
- Supporting values laid out in a fixed three-column row that collides at large text sizes.
- A scale with tick labels that break mid-number when text grows.
- A failure that blanks the screen, or keeps showing the old value as if it were live.

## Verify

1. Squint test at default size: the plate's colour, then the number, then the verdict, then the action are found in that order.
2. Cover the colour (greyscale screenshot): the state is still readable from its icon and word.
3. Every band: render the lowest, the middle and the highest state. Each plate's text is at least 4.5:1, and the longest value fits on one line with its unit.
4. Largest accessibility text size, small iPhone: the number fits on one line; the unit sits under it; supporting rows stack; the scale labels become one short line.
5. Dark appearance: the plate is unchanged and the rows around it are still readable.
6. Failed state: the plate is grey, the label gives the time of the last reading, and there is no verdict, scale or action.
7. Read every sentence on the screen and name what it says that the plate does not (guard rule G1).

## States

| State | What the sample shows |
| --- | --- |
| Loading | A grey plate whose label reads "CO₂ · connecting", with the number as a placeholder. Rows are placeholders |
| Empty | No sensor paired: a title and one button |
| Failed, with a last reading | A notice with what happened and what to check; a grey plate with the last value and its time; no verdict, scale or action |
| Failed, nothing known | A full-screen message with a retry |
| Success | The reminder button is replaced by the confirmation and a link to cancel it |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | WHOOP, Recovery (`whoop/03`) | A ring with "85%" and the word Recovery inside; four rows of icon, label, value and trend mark; a legend "Today vs. prior 30 days"; a boxed sentence explaining the score with a link | [App Store](https://apps.apple.com/us/app/whoop/id933944389) |
| E2 | Oura, Today (`oura/01`) | An arc with "88" and "Readiness"; a serif headline; two lines of interpretation; a "Learn more" button; a row of smaller scores above | [App Store](https://apps.apple.com/us/app/oura/id1043837948) |
| E3 | Nike Run Club, Activity (`nike-run-club/02`) | "20.6" in heavy italic with "Miles" beneath; three smaller figures in a row; a week bar chart with an average line | [App Store](https://apps.apple.com/us/app/nike-run-club-running-coach/id387771637) |

Recorded only, each seen in one app: Oura sets the verdict in a serif display face (E2); WHOOP marks each
supporting value with a small trend triangle against a 30-day baseline (E1); Nike sets the number in
heavy italic (E3). These are brand decisions and are not copied.

## Not shown by the evidence

- How any of these apps behave while loading, with no device, or when the sensor is unreachable.
- Whether the explanation text changes with the score, and how.
- Whether people act on the advice, or miss it when it is absent.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- With system colours and a pastel three-colour scale, the screen read as a stock app. The plate in
  `MetricLook.swift` is the answer to that.
- A four-digit value with its unit is wider than the plate on a 402 pt phone at full size. One line with
  a minimum scale factor fixes it; a fixed font size would not.
- A capital label wraps badly when it ends in an ellipsis: the ellipsis lands on a line of its own at
  large sizes. The label has none.
- When the unit stacks under the number at accessibility sizes, the verdict needs its own gap above it.

## Make it yours

The ring and the arc belong to the apps above; the sample deliberately uses neither. Replace the
metric, the bands, the verdict words and the action. Choose your own plate colours in
`MetricLook.swift`, one per band, and check the text colour on each of them: the three here were picked
together so that the lightest and the darkest also differ in lightness, not only in hue. The verdict
wording carries the product's voice, so write it for your audience.
