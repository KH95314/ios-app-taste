---
id: quiet-parts
name: Parts of look 01
direction: 01 Quiet Native Minimalism
kind: parts
code: QuietLook.swift, QuietKit.swift, QuietParts.swift
status: Rebuilt on 2026-11-17 as screens in use, after the first version (a labelled catalogue) was judged distracting. Built on the iOS 26.5 simulator; every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. Not used by hand, and never on a real device.
---

# Parts of look 01

Everything look 01 is made of, on one screen, for an invented product: the chores of a shared flat. The look stays the quietest of the fourteen. What makes it this product's own is small: one sentence that is the whole dashboard, a week of dates, and a person's initial at the end of a row.

The parts are shown in use, on a few screens of one invented product (Flat chores, the chores of a shared flat). Each screen is built
only from this look's parts, one thing leads it, and nothing on it names a part or a state: guard rules
G1 and G12. This page says which part is which. A real screen takes a few of these parts and lets one
of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern quiet-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| One day | `home` | the summary sentence leads; the week chooses the day; rows with a person at the end. States: `empty`, `loading`, `offline` |
| This week | `week` | a group head with a pie, a date head with a numeral |
| Flat | `flat` | people in three forms, another company's logo, the app's own mark |
| Plants | `plants` | a picture at a row's end. `plants-waiting`, `plants-failed`; a row with none |
| New chore | `new` | a sheet: one field, one choice, switches, one button. `new-error`, `new-busy` |

## The look's own content parts

A product looks like itself in its content, not in its buttons. These come first.

| Part | In code | Decision | Basis |
| --- | --- | --- | --- |
| The summary sentence | `QuietSummary` | One sentence under the title says what is left and what is late. Only the late part takes the alert colour. | Our choice, from the first entry in this look |
| The week | `QuietWeek` | Seven dates on one line; dots under a date count what is due, three at most; the chosen date is a filled disc in the accent, because it can be pressed. | Recorded only: W7 |
| Group head | `QuietGroupHead` | A head heavier than a row. A group that can be finished carries a small pie and a count at its end. | The pie is recorded only: W10 |
| Date head | `QuietDateHead` | A large numeral with the weekday in second ink, under a hairline and a gap. | Recorded only: W10 |
| Row | `QuietTaskRow` | A circle to tick, a name, one detail line. No box, no colour and no line of its own. | Our choice. A mark to tick at one end of a row is a rule, seen in 3 apps: W3, W7, W10 |
| A person | `QuietPersonMark` | At the end of a row: a photograph in a disc, else an initial on the look's fill, else a dashed disc for nobody yet. | A photograph in a disc is common practice: W1, W2. The initial and the empty disc are our choice |
| A picture | `QuietPicture` | A small square with an 8 corner at a row's end, never a banner. Waiting is a square of the look's fill; failed is the same square with a mark, and no red. | Our choice. A square picture on a row is recorded only: W3 |
| A logo | `QuietLogoTile` | Another company's logo keeps its own colours on a small tile edged with the hairline colour. | Our choice |
| Empty | `QuietGhostList` | A drawing of the list that is not there, fading, in the look's own marks. Then a title, the main button, one second button at most. | A drawing where a screen has little to say is a rule, seen in 4 apps: W1, W6, W11, W12. What it draws is our choice |

## Controls

Kept close to the system's. There are two kinds of button and no third.

| Part | In code | Decision | Basis |
| --- | --- | --- | --- |
| Main button | `QuietFilledButtonStyle` | A filled accent capsule, 50 high, one on a screen. Pressed, it dims. While its action runs it keeps its fill and its words change. Off, it is the look's fill with second-ink words. | Our choice. Dimming the fill while busy took the label to 3.1:1 |
| Second button | `QuietTextButtonStyle` | Words in the accent, with no box. | Our choice |
| On or off | `Toggle` with `.tint` | The system's switch with the accent as its tint. | Apple's talk: keep everyday controls standard |
| One of a few | `QuietChoiceRow` | Rows, with a tick at the end of the chosen one. | Our choice, after the system's own lists |
| Text field | `QuietField` | Its name above, the text on a line. In use the line is two points of the accent. An error is an icon and a reason under the line in the alert colour; the line keeps its own. | Our choice |
| Notice | `QuietNotice` | The one filled box: what is wrong, what it means, a retry. | Our choice, from the first entry |
| Loading | `QuietGhostRow` | The shapes of what will come, in the look's fill. | Our choice |

## Type roles and sizes

Named in `QuietLook`: `title`, `dateNumeral`, `heading`, `row`, `detail`, `button`, `secondButton`, `initial`, `emptyTitle`, each a system text style; and `margin`, `rowMin`, `buttonMin`, `groupGap`, `dateDisc`, `person`, `picture`, `tile` with their corners. The first entry in this look was written before these names and still sets some of them in place.

## Verify

1. Squint at a screen built from these parts. One thing leads, and it is not a control.
2. Count the hues. One, and only on things that can be pressed; the alert colour only with an icon and a word.
3. Find a row with a box, a tint or a line of its own. There should be none.
4. Turn the network off: every picture's place holds its waiting form and nothing has moved.
5. Switch to dark: every logo still shows its own colours on its tile.
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

The chores, the flatmates and the two invented companies belong to the sample. Keep what belongs to the look: which part leads, what colour is allowed to mean, what a
row starts and ends with, and the two kinds of button. The hues, the product and the words are the
sample's.
