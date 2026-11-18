---
id: sectioned-list
name: Sectioned list without cards
direction: 01 Quiet Native Minimalism
also_fits: 12 Focused Utility
kind: list
code: SectionedList.swift
look: ../QuietLook.swift
pictures: sample-light.png, sample-dark.png
status: test entry, second round. Built and screenshotted on the iOS 26.5 simulator; not used by hand.
---

# Sectioned list without cards

A list whose structure comes from type and spacing: a title, heavier group headings, plain rows with
one line of detail. Nothing sits in its own box, and the one hue on the screen marks what people can
act on.

## Use it when

- The screen is a list of things to act on, and people scan it many times a day.
- Items fall into a few groups that people already think in (today, this week; morning, evening).
- Each row needs a name and at most one line of detail.

## Use something else when

- Rows need a picture, a chart or several values each. That is a card or a table.
- Groups have to be compared side by side. That is a board or a grid.
- There is one item and its details. That is a detail screen.

## Do

| Decision | Basis |
| --- | --- |
| Rows sit on the page background. No fill, border or shadow per row. | Rule. Seen in 3 apps: E1, E2 and E3, E4 |
| Group headings are text, heavier than a row and lighter than the title. | Common practice. Seen in 2 apps: E1, E2 and E3. GoodTask (E4) shows a single day with no headings |
| A hairline and a gap separate one group from the next. No band, no box. | Our choice. Recorded in 1 app: E2 puts a rule with its second heading |
| Levels differ by weight as well as size: bold title, semibold headings, regular rows. | Our choice. It keeps the levels apart at the largest text sizes, where the size steps flatten |
| There is one hue, and it is only on things people can act on: the tick, the add button, links. | Our choice. Colour then has one meaning on the screen. Set once with `.tint(QuietLook.accent)` |
| A row is a control, a name, and one muted line of detail. | Rule. Seen in 3 apps: E1–E4 |
| The detail line uses the direction's own grey, darker than the system's secondary label. | Our choice, from a contrast check: the system grey is about 3.4:1 on white and this line is 13 pt. HIG, Accessibility asks for 4.5:1 up to 17 pt. Ours is 6.4:1 light, 8.7:1 dark |
| The detail line holds who or where, then when. | Rule. Seen in 3 apps: E1–E4 |
| A late item is marked on its detail line, not by tinting the row. | Common practice. Seen in 2 apps: E1 (red time), E2 (red flag) |
| Red is only on the overdue marker and on the overdue count in the summary. | Our choice |
| "Late" is an icon and a word, never colour alone. | HIG, Color: avoid relying solely on colour. The two apps above use colour plus a symbol or word |
| The screen summary is a sentence under the title ("3 left today · 1 overdue"). | Our choice. It replaces the row of stat cards a generated dashboard would put here |
| Adding is one button in the bottom trailing corner. | Common practice. Seen in 2 apps: E1, E2 and E3 show a round plus there. We place it in the system bottom bar so it gets the standard safe-area and scroll-edge behaviour |
| The add button draws its own disc and glyph in the accent pair. | Our choice, forced by the test: on the system's tinted glass button the glyph colour could not be set, and in the dark appearance it was a pale tint on our lighter accent. Our pair measures 5.3:1 light, 9.0:1 dark |
| The tick is at least 44 pt square; the row adds almost no padding around it. | HIG, Buttons: 44 pt regular hit region. Density matches E2 and E3 more closely than the default list row does |
| The tick's target hangs into the margin, so the circle lines up with the heading above it. | Our choice |
| The empty state is a title and two buttons, with no sentence between them. | Guard rule G1: the buttons already say what can be done |

## Common failures

- Every row wrapped in a rounded card. The list reads as a stack of banners and shows half as much.
- Stat cards ("3 left", "1 overdue", "7 total") above the list, pushing the first row below the fold.
- Late items shown only by red text, or the whole late row tinted.
- The accent spent on headings, icons or decoration, so it no longer means "you can act on this".
- A sentence in the empty state that repeats the buttons under it.
- A tick drawn at 22 pt with a 22 pt tap area.
- A fixed row height, so a two-line name is cut off at larger text sizes.
- The add button shown twice in the empty state, or missing from it.

## Verify

1. Default text size, standard iPhone: at least seven rows and two headings are visible without scrolling.
2. Largest accessibility text size, small iPhone: every name wraps instead of truncating; the detail line wraps as one sentence.
3. Dark appearance: headings, rows and the late marker are all still distinct, and the plus on the add button is clearly visible.
4. Tap the tick, not the row: only the tick toggles. Its tap area is 44 pt.
5. All four states render: see below.
6. Look only for colour: it is on ticked items, the add button, links and the overdue marker, and nowhere else.

## States

| State | What the sample shows |
| --- | --- |
| Loading | The same list layout with placeholder rows, so nothing moves when data arrives. The add button is disabled |
| Empty | What is missing as a title, and two ways forward as buttons. No sentence. The bottom add button is hidden because the empty state has its own |
| Failed, with a saved copy | The saved list stays. A notice above it says what happened and offers a retry |
| Failed, nothing saved | A full-screen message with a retry |
| Success | The ticked row is struck through and the summary sentence recounts |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Apple Reminders, Today (`apple-reminders/01`) | Coloured title; grey headings Morning, Afternoon, Tonight; rows of circle, name, one detail line; one time in red with a repeat symbol; round plus bottom trailing | [App Store](https://apps.apple.com/us/app/reminders/id1108187841) |
| E2 | Things 3, Today (`things-3/06`) | Title with an icon; a second heading "This Evening" with a rule; rows of box, name, grey project line; a red "today" flag on one row; round plus bottom trailing | [App Store](https://apps.apple.com/us/app/things-3/id904237743) |
| E3 | Things 3, Upcoming (`things-3/07`) | Headings made of a large day number and a grey weekday; calendar entries as plain coloured-time lines above the tasks | same |
| E4 | GoodTask, day list (`goodtask/05`) | Rows of coloured ring, name, small time and list name; no cards; no group headings on this screen | [App Store](https://apps.apple.com/us/app/goodtask-to-do-list-planner/id1068039220) |

Recorded only. Seen in one app, so not turned into a rule or a practice: Things puts the day's calendar
entries in one quiet block above the tasks (E2); Reminders leaves a dotted empty circle at the end of
each group as a place to add (E1).

## Not shown by the evidence

- What happens when a row is ticked: animation, where the row goes, whether there is an undo.
- Any empty, loading or error state in the reference apps.
- Swipe actions, drag to reorder, or how adding works.

The sample's behaviour in these areas is our own and is untested with people.

## Found by testing the sample

These came from screenshots of our own build, not from the references.

- With the system colours and the default blue, the screen could not be told from a stock app. The look
  in `QuietLook.swift` is the answer to that.
- A `Label` inside a list takes the tint for its icon. In this direction that puts the action hue on
  something that is not an action, so the notice sets its icon inline in the text colour.
- On a tinted glass button the system picks the glyph colour, and a foreground style on the label did
  not change it. On a light tint in the dark appearance the glyph was too faint to see, so the sample
  draws its own disc and switches the bar's glass off behind it.
- At the largest text sizes the tick grows to fill its 44 pt target. The hang into the margin has to
  shrink with it, or the circle leaves the margin.

## Make it yours

Change the product, the groups and the detail line. Change the accent in `QuietLook.swift`, and check
the new colour against the ground, against the notice fill, and under the text drawn on it, in both
appearances. Keep the structure only if the "Use it when" list holds for your screen. Do not reproduce
a reference app's title colour, icons, flag or heading style.
