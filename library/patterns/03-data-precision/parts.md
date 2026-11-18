---
id: data-parts
name: Parts of look 03
direction: 03 Data Precision
kind: parts
code: DataLook.swift, DataKit.swift, DataParts.swift
status: Rebuilt on 2026-11-17 as screens in use, after the first version (a labelled catalogue) was judged distracting. Built on the iOS 26.5 simulator; every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. Not used by hand, and never on a real device.
---

# Parts of look 03

Everything look 03 is made of, on one screen, for an invented product: a monitor for web services. Its second voice is in the figures: monospaced numbers, large, with a small unit, set against plain words.

The parts are shown in use, on a few screens of one invented product (a monitor for web services). Each screen is built
only from this look's parts, one thing leads it, and nothing on it names a part or a state: guard rules
G1 and G12. This page says which part is which. A real screen takes a few of these parts and lets one
of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern data-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Services | `services` | the one in a state first, the rest one line each. `empty`, `loading`, `offline` |
| One service | `service` | the state leads and washes the top; chart; regions. `service-slow`, `service-down` |
| Thirty days | `record` | one figure leads over its days; four smaller figures under it |
| A failed check | `check` | a picture, people in three forms, one action. `check-waiting`, `check-failed`, `check-busy`, `check-done` |
| New service | `new` | a sheet of field rows, two on/off chips, one wide button. `new-error`, `new-busy` |

## The look's own content parts

A product looks like itself in its content, not in its buttons. These come first.

| Part | In code | Decision | Basis |
| --- | --- | --- | --- |
| The state | `DataStateLine` | The state comes first, in words with an icon and the state's colour. Under it, when the data is from. | Our choice, from the first entry in this look. A state as a mark with a word is common practice: W1, W2 |
| The ground under a state | `DataWash` | A state someone must act on lights the top of the screen with its own colour at 14%, fading into the ground. A good state leaves the ground plain. | A ground that changes with its subject is a rule, seen in 4 apps: W1, W2, W4, W6. That it follows the state, and that calm is plain, is our choice |
| A figure | `DataFigure` | A label in capitals over a large monospaced number with a small unit in second ink, and a comparison in words beneath. In a state it takes the colour and the icon. | A large number with a small unit under a small label is a rule, seen in 3 apps: W1, W2, W4. Monospaced figures are common practice: W2, W5 |
| A figure over its record | `DataDayStrip` | Under a figure, the days it sums up. A day with nothing to report is second ink; a day that went wrong takes its state's colour. | Our choice |
| A chart | `DataBars` | Bars with nothing to report are second ink; a ringed dot marks now. | A dot for now or the latest value is a rule, seen in 3 apps: W1, W2, W4 |
| Row | `DataReadingRow` | A logo or a code, a name, then a small line of the last readings before the figure. A row in a state takes the colour in its line, its figure and one word. No chevron. | A row that starts with a glyph of its own is a rule, seen in 5 apps: W3, W4, W7, W10, W11. The small line is our choice |
| A code | `DataCodeTag` | A short code in a monospaced tag starts a row that has no logo. | Our choice |
| A logo | `DataLogoTile` | A service's logo keeps its own colours on a small tile. Its colour is not a state, so it stays small and at the start of the row, away from the state at the end. | Our choice |
| A person | `DataPersonMark` | A photograph in a disc, else initials in a ring, else a dashed ring. | A photograph in a disc is common practice: W1, W2 |
| A picture | `DataPicture` | A small frame with a hairline. Waiting and failed keep the frame. | Our choice |
| Empty | `DataEmptyChart` | A drawing of the chart that is not there yet. Then a title, one line for what the screen cannot show, the main button. | A drawing where a screen has little to say is a rule, seen in 4 apps: W1, W6, W11, W12. What it draws is our choice |

## Controls

Kept close to the system's. There are two kinds of button and no third.

| Part | In code | Decision | Basis |
| --- | --- | --- | --- |
| Main button | `DataInkButtonStyle`, `DataWideButtonStyle` | Ink. A capsule that hugs its words on a page; as wide as the sheet only at the foot of a sheet. Pressed, it dims. Busy, the fill lightens and the words stay whole. Off, it is the rule colour with second-ink words. | Our choice, from the flow entry. Measured busy: 7.25:1 in light and 9.25:1 in dark |
| Second button | `DataLinkButtonStyle` | Underlined words in ink. | Our choice |
| On or off | `DataOnOffToggleStyle` | A chip that says "On" or "Off": filled ink when on, outlined when off. It is a `Toggle` with a style, not a redrawn switch. | Our choice. The system's switch is green when on, and green means a good state here |
| One of a few | `DataChipStyle` | Capsule chips, the chosen one in ink. | Chips as capsules with the chosen one filled is a rule, seen in 4 apps: W2, W3, W4, W7 |
| Text field | `DataFieldRow` | A row: its name at the left, what is typed at the right as a figure with its unit. In use the row stands on two points of ink. An error is a mark and a reason under the figure, in ink. | Our choice. A state colour would say something about the data, not about what was typed |
| Notice | `DataNotice` | One row above the figures: what cannot be reached, and a retry at its end. | Our choice, from the first entry |
| Loading | `DataGhostRow` | The rows as shapes in the rule colour, with no state. | Our choice |

## Type roles and sizes

Named in `DataLook`: `stateFont`, `largeFigure`, `figure`, `unit`, `rowUnit`, `code`, `comparison`, `meta`, `chip`, each a system text style, the figures in the monospaced design; and `margin`, `rowMin`, `buttonMin`, `tile`, `pictureSize`, `person`, `wash`. The two entries in this look were written before these names. They set their figures in the plain design with tabular digits, and have not been changed.

## Verify

1. Squint at a screen built from these parts. The state is found first, then one figure.
2. Find every colour. Each is a state with an icon and a word, or a logo on its tile.
3. With a good state the ground is plain; with a bad one the top of the screen says so before the words are read.
4. Measure the small line under the state on the wash. Measured from the tokens: 4.95:1 on the red wash and 5.08:1 on the amber, in light.
5. Type a wrong value and save. The reason appears under the figure in ink and nothing else moves; type a right one and it goes.
6. Press every control and say what changed on the screen.

## Evidence

Promotional images from the App Store, not captures of a running app, viewed on 2026-11-17. They
prove what is drawn in them and nothing about how an app behaves. W1 and W2 are by one developer.
Apple's WWDC26 session 251, "Communicate your brand identity on iOS", read as a transcript the same
day, is cited as "Apple's talk": it says to put a product's identity in its content and to keep
navigation and everyday controls standard.

| Ref | App | What is visible | Source |
| --- | --- | --- | --- |
| W1 | Gentler Streak | A bold number with a small unit beside it under a small grey label, two to a row; a state as a small coloured disc with a word; a drawing that fills the top of each screen; a ground whose colour changes by section; a person's photograph in a disc at the top corner; the system's tab bar | [App Store](https://apps.apple.com/us/app/gentler-streak-workout-tracker/id1576857102) |
| W2 | The Outsiders | Monospaced figures with a small unit; a state as a disc and a word in capitals; capsule chips, the chosen one filled; a line chart with a ringed dot at the latest value; coloured light at the top of a black ground, a different hue on each screen | [App Store](https://apps.apple.com/us/app/the-outsiders-fitness-tracker/id6751584800) |
| W3 | Moonlitt | Rows that start with a square picture; a row that ends in a small drawn disc showing its state; a two-part switch whose chosen part is a lighter capsule | [App Store](https://apps.apple.com/us/app/moonlitt-moon-phase-tracker/id6444718902) |
| W4 | Tide Guide | A figure with a small unit under a small capital label; a curve with a red dot for now; capsule chips; small coloured glyphs before times in a row; a ground that shades with the time of day | [App Store](https://apps.apple.com/us/app/tide-guide-charts-tables/id1406371071) |
| W5 | (Not Boring) Camera | Controls drawn as solid objects; labels in monospaced capitals | [App Store](https://apps.apple.com/us/app/not-boring-camera/id6737783441) |
| W6 | grug | A hand-drawn picture that fills the top of the screen; a different flat ground each day | [App Store](https://apps.apple.com/us/app/grug/id6751649802) |
| W7 | Structured | A week of dates with coloured dots under each and the chosen date as a filled disc; a coloured glyph at the start of each row and a ring to tick at its end; a round floating add button | [App Store](https://apps.apple.com/us/app/structured-daily-planner-todo/id1499198946) |
| W10 | Things 3 | A small coloured glyph for each list; a small pie of progress beside a project; a square to tick; in the calendar a large numeral with the weekday in grey; heads with a hairline | [App Store](https://apps.apple.com/us/app/things-3/id904237743) |
| W11 | Duolingo | Everything that can be pressed has a darker lower edge; a chosen card takes a tint and an edge; one very large numeral with its words under it; a week of ticked discs inside a rounded outline; a thick rounded bar with a lighter stripe; drawn characters | [App Store](https://apps.apple.com/us/app/duolingo-learn-languages/id570060128) |
| W12 | CapWords | Photographs cut out as stickers; a drawing of a character where a screen has little to say | [App Store](https://apps.apple.com/us/app/capwords-ai-language-tutor/id6738896465) |

## Not shown by the evidence

- How any of these apps behaves, and whether its controls are the system's under the drawing.
- Another company's logo, or a picture that is waiting or has failed, in any of them. The tile,
  and the waiting and failed forms, are our choice (`../../../references/pictures.md`).
- Whether a screen built from these parts is easier to use than one that is not.

## Found by building and pressing the screens

- **The first version was a catalogue** (a numbered label over each group, a word under each specimen, a note beside each live control) and was judged distracting at real size, though the same content had been approved as design-system cards. It was rebuilt as the screens above. The words moved to this page.
- Rows that start with a person, a logo or the app's mark took different widths, so names did not line up across groups. They share one width now.
- A text field whose text is set at the right needs the test's tap at the right, or the cursor lands before the text.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device. Pictures, faces and logos are drawings or free photographs.

## Make it yours

The services, the regions and the two invented companies belong to the sample. Keep what belongs to the look: which part leads, what colour is allowed to mean, what a
row starts and ends with, and the two kinds of button. The hues, the product and the words are the
sample's.
