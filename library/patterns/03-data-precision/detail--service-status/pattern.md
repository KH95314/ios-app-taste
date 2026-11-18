---
id: service-status
name: One thing, in figures
direction: 03 Data Precision
also_fits: 09 Metric Hero, 01 Quiet Native Minimalism
kind: detail
code: ServiceStatus.swift
look: ../DataLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator in light, dark and the largest text size. Not used by hand.
---

# One thing, in figures

Everything about one thing, as figures. Its state comes first, in words. Then a chart, then rows of
name and figure with a comparison under each figure. Colour appears only where something is right or
wrong.

## Use it when

- People come to check several figures about one thing: a service, an account, a device, a shipment.
- They need to see quickly which figure, if any, is a problem.
- The figures have something to be compared with: a plan, an average, last week.

## Use something else when

- One figure matters far more than the rest. Lead with it, as in "One hero metric, explained".
- The figures are read for pleasure or motivation. This look is dry on purpose.
- There is nothing to compare a figure with. A plain list of values is enough.
- People mostly enter data here. Lead with the input.

## Do

| Decision | Basis |
| --- | --- |
| The state comes first, in words, with an icon. | Common practice. Words before the figure in 2 apps: E3 ("Ready to Train" over the score), E1 (a "RUNNING LATE" badge over the details) |
| The line under the state says when the data is from. | Common practice. Seen in 2 apps: E3 ("Recovery Calculated at: 9:54 AM"), E2 ("5 hours ago", "live balance estimate") |
| A row is a name at the left and a figure right-aligned in tabular digits. | Common practice. Seen in 2 apps: E2, E1. E4 puts the amount at the left |
| A comparison sits under the figure. | Rule. A figure shown with a comparison in 3 apps: E2 ("vs $6,842.25 in …"), E3 ("↑ 69% vs avg"), E1 ("52m Late") |
| The comparison is words with a unit: "12 ms slower than last week". | Our choice. E2 and E3 give a bare percentage with an arrow |
| The unit is written with the figure, at the same size. | Our choice. Five apps set the unit smaller (E2, E3, E4, E5, E6); that suits a large figure. In a row at body size a smaller unit would be hard to read and would break the right edge |
| Colour is for a state, and comes with an icon and a word. | Rule for pairing the colour with a mark: green or red with an arrow, icon or word in 3 apps: E2, E3, E1. HIG, Color: do not rely on colour alone |
| A figure that only moved stays ink. | Our choice. It departs from E2, which colours every rise and fall |
| Each state's icon has its own outline: disc, triangle, octagon. | Our choice, so the three can be told apart in greyscale |
| Section heads are a few words in small capitals. | Rule. Seen in 3 apps: E2, E3, E1 |
| A range control sits beside the chart's head. | Common practice. Seen in 2 apps: E2 (five chips), E3 (three segments). Making it ink is our choice |
| Rows sit straight on the ground between hairlines. Nothing is a card. | Our choice. E2, E3 and E5 use cards or tiles. One list does the same: E4 |
| Chart bars are neutral. Only the bars a state refers to take its colour. | Our choice. E2 colours every bar by its sign |
| Old figures are labelled as old, and the state turns grey: "Operational at 2:10 PM". | Our choice. No reference image shows old data |
| No sentence explains a figure. | Guard rule G1. It departs from E3, E1 and E2, which each put a sentence or a paragraph beside a figure |
| Small text is the look's second ink, not the system's secondary grey. | Our choice, from a measurement: 6.2:1 against about 3.2:1 on this ground. HIG, Accessibility: 4.5:1 for text up to 17 pt |
| At the accessibility text sizes a row stacks: name, then figure, then comparison. | Our choice, forced by the test |
| The state stops growing at the first accessibility size, and its icon moves above the words. | Our choice, forced by the test: "Operational" was broken with a hyphen on a small phone |
| The chart has a label at each end and none between. | Our choice, forced by the test: three labels ran into each other at large sizes |
| The scroll edge under the bar is hard. | Our choice, forced by the test: large figures showed through the title |

## Common failures

- Every figure in its own card, so the eye reads boxes before numbers.
- Green and red on every change, so nothing stands out when something is wrong.
- A state shown by colour alone: a red number with no icon or word.
- A bare "+7%" with no hint of what it is compared with.
- Figures in a proportional face, so digits do not line up down the column.
- A paragraph under each figure saying what the figure already says.
- A present-tense verdict over data that stopped updating an hour ago.
- A legend for a chart that has one series.
- A unit so small it cannot be read, or a figure with no unit at all.
- Rows with a fixed height, so a name and a figure collide at large text sizes.

## Verify

1. Squint at the loaded screen: the state is found first, then the one coloured figure.
2. With nothing wrong, the only colour on the screen is the state line.
3. Greyscale screenshot: each state is still told by its icon. A slow bar is still told by its height: it crosses the 0.5 s line.
4. Every figure has a unit, and every comparison says what it is compared with.
5. Measure the small text and each state colour on the ground. Measured here, light and dark: second ink 6.2 and 7.5; good 5.0 and 11.2; watch 5.9 and 11.7; bad 6.0 and 7.7.
6. Failed state: the state is grey and gives a time, the notice says what is unreachable, and the figures are still there.
7. Largest accessibility text size on a small iPhone: the state is one whole word, rows are stacked, chips and chart labels do not touch, nothing is truncated.
8. Scroll to the end at that size: the last rows are whole and nothing shows through the bar.
9. Read every sentence on the screen and name what it says that the figures do not (guard rule G1).

## States

| State | What the sample shows |
| --- | --- |
| Loading | The page layout with placeholder figures and flat bars |
| Empty | "No checks yet", when the first one will run, and a button to check now |
| Failed, with a last report | One row above the state: what cannot be reached, and a retry. The state is grey with its time. The figures stay |
| Failed, nothing known | A full-screen message with the cause and a retry |
| Success | After "Check now", the line under the state reads "Checked just now". No message |

## Evidence

Promotional images from the App Store and a design gallery, not captures of a running app. App
versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Flighty, flight (`flighty/04`, `flighty/06`) | A red "RUNNING LATE" badge with a warning icon over a sentence of explanation; rows with a status at the right in red ("52m Late"); "IN AIR" in small capitals; times in green with arrow icons | [App Store](https://apps.apple.com/us/app/flighty-live-flight-tracker/id1358823008) |
| E2 | Copilot Money (`copilot-money/01`, `/03`, `/05`, `/06`) | "$15,598.32" in green with a "↗ 128%" badge and "vs $6,842.25 in Jan 1 – Sep 12, 2024"; a table with small capital column heads and right-aligned figures; bars green above zero and red below; range chips 1W to 1Y; "5 hours ago" on account rows | [App Store](https://apps.apple.com/us/app/copilot-track-budget-money/id1447330651) |
| E3 | Athlytic, Recovery, Exertion, Stress (`athlytic/03`, `/04`, `/06`) | "Ready to Train" over "100%"; tiles with "44 ms", "↑ 69% vs avg"; "WHAT'S DRIVING IT" in small capitals; a paragraph under the figures; "Recovery Calculated at: 9:54 AM"; a scale with four named bands and a marker; a 7 / 30 / 60 Days control | [App Store](https://apps.apple.com/us/app/athlytic-fitness-recovery/id1543571755) |
| E4 | Stride, deductions (`stride/04`, `stride/06`) | "$230" and "189 mi" with labels under them; rows of amount, name and date between hairlines; cards with a bar and its figure | [Godly gallery](https://godly.design/app/stride/) |
| E5 | Airtable, dashboard and record (`airtable/02`, `/04`) | Two tiles with a label and a large red figure; a donut with percentages on it; a record as bold labels over boxed values | [App Store](https://apps.apple.com/us/app/airtable/id914172636) |
| E6 | Yazio (`yazio/04`, `/05`) | "13 : 41 : 07" under a ring; "88.00 fl oz" over a grid of glasses | [Godly gallery](https://godly.design/app/ai-calorie-tracker-by-yazio/) |

Recorded only, each seen in one app: Athlytic's four-band scale with a marker (E3); Flighty's vertical
timeline of a plane's earlier flights (E1); Copilot's coloured dot per budget category (E2); Stride's
heavy condensed numerals (E4). The first three are product features; the last is a brand decision.

## Not shown by the evidence

- Loading, an empty first run, a failure, or old data in any of the six apps.
- What a tap on a figure or a bar does.
- How any of them behave at large text sizes.
- Whether people prefer a comparison in words to a percentage.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- At the largest text sizes the system breaks a long single word with a hyphen. For the one word that
  is the whole message, that is worth preventing: the state is capped and its icon moved above it.
- The top figure of a chart's scale is drawn half above the plot. Without room over the chart it ran
  into the chips.
- With the default soft scroll edge, large figures were legible through the bar and tangled with the
  title. A hard edge fixed it.
- The slow bars and the neutral bars are the same lightness in the light appearance (1.0:1 between
  them). What separates them without colour is height, so the 0.5 s line has to stay.
- The system's unavailable view sets its description in a grey of about 3.2:1 here. The description
  takes the look's second ink instead. The same fix went into four older entries.

## Make it yours

The service, the figures and the three state words belong to the sample. Keep the discipline, which
is the direction: state first, one unit per figure, a comparison in words, colour only for a state.
The sample's chart shows the same series for every range and passes fixed times; a real screen loads
a series per range and reads the clock.
