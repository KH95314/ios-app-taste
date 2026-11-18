---
id: tactile-parts
name: Parts of look 05
direction: 05 Playful & Tactile
kind: parts
code: TactileLook.swift, TactileKit.swift, TactileParts.swift
status: Rebuilt on 2026-11-17 as screens in use, after the first version (a labelled catalogue) was judged distracting. Built on the iOS 26.5 simulator; every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. Not used by hand, and never on a real device.
---

# Parts of look 05

Everything look 05 is made of, on one screen, for an invented product: a log of minutes practised on an instrument. One rule runs through all of it: only a thing that can be pressed, or that a press produced, has a lower edge.

The parts are shown in use, on a few screens of one invented product (a log of minutes practised on an instrument). Each screen is built
only from this look's parts, one thing leads it, and nothing on it names a part or a state: guard rules
G1 and G12. This page says which part is which. A real screen takes a few of these parts and lets one
of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern tactile-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Today | `today` | the count leads beside its stack; one key logs, a second undoes. `today-busy`, `empty`, `loading`, `offline` |
| This week | `week` | a bar, rows with pips, a row that adds |
| Goal | `goal`, `goal-daily` | rows that open, switches; one of a few as keys |
| Studio | `studio` | a picture in a tray, people in three forms, a logo, the app's mark. `studio-waiting`, `studio-failed` |
| New instrument | `instrument` | a sheet: one field and one key. `instrument-error` |

## The look's own content parts

A product looks like itself in its content, not in its buttons. These come first.

| Part | In code | Decision | Basis |
| --- | --- | --- | --- |
| The stack | `TactileStack` | Progress is a count of objects: blocks in a tray, with a dashed slot for each one to come. | Our choice, from the first entry in this look |
| The count | `TactileCount` | The number stands beside the stack at about twice the size of anything else, with its total small under it. | A very large number with its words under it is common practice: W1, W11 |
| The week | `TactileWeek` | Discs inside one outline: a ticked key-coloured disc for a done day, a ring for today. | Recorded only: W11 |
| A bar | `TactileBar` | Where a stack will not fit: a thick bar with a lower edge and a light stripe, in a tray-coloured track. | Recorded only: W11 |
| Rows | `TactileRows`, `TactileRow` | Rows share one tray, cut apart by a line of the ground. | Our choice |
| A row's start | `TactileGlyphTile` | A glyph on a tile of the ground. | A row that starts with a glyph of its own is a rule, seen in 5 apps: W3, W4, W7, W10, W11 |
| A row's end | `TactilePips` | One pip for each block, before the figure. Filled pips have the key's colour and edge. | A drawing of its state at a row's end is a rule, seen in 3 apps: W3, W7, W10. Pips are our choice |
| A row that opens | `TactileSmallKeyStyle` | It ends in a small second key. | Our choice, from the look's own rule |
| A picture | `TactilePicture` | It sits in a tray, like a block. Until it comes its place is a dashed slot; if it cannot load, the slot keeps a mark. | Our choice |
| A person | `TactilePersonMark` | A photograph in a disc, else an initial on a tray disc, else a dashed ring. | A photograph in a disc is common practice: W1, W2 |
| A logo | `TactileLogoTile` | Another company's logo keeps its own colours on a tile with no lower edge: it cannot be pressed. | Our choice |
| Empty | `TactileEmptyDrawing` | An empty tray and a block about to fall. Then a title and one key. | A drawing where a screen has little to say is a rule, seen in 4 apps: W1, W6, W11, W12. What it draws is our choice |

## Controls

Kept close to the system's. There are two kinds of button and no third.

| Part | In code | Decision | Basis |
| --- | --- | --- | --- |
| Main button | `TactileKeyStyle` | A key over a lower edge. Pressed, it moves down onto its edge. While its action runs it stays down and its words change. Off, it is flat, in the tray colour. | Things that can be pressed look solid is common practice: W11, W5. Staying down while busy is our choice |
| Second button | `TactileKeyStyle(kind: .second)` | A key in the second key colour. | Our choice, from the first entry |
| In a bar, in a notice | `TactileDiscFace`, `TactileTextButtonStyle` | A round disc on the tray colour; underlined words. The words are the one thing that can be pressed and has no edge. | Our choice, kept from the first entry as built |
| One of a few | `TactileChoiceKeys` | A row of keys, and the chosen one stays down. | A chosen card that takes a tint and loses its lift is recorded only: W11 |
| On or off | `Toggle` with `.tint` | The system's switch with the key's yellow as its tint. | Apple's talk: keep everyday controls standard |
| Text field | `TactileField` | Its name above, the text on a tray the size of a key. In use a ring in ink stands off it. An error is an icon and a reason under it, in ink. | Our choice. On this ground a warning colour fights the keys |
| Notice | `TactileNotice` | A tray: an icon with what is wrong, what it means, a retry. | Our choice, from the first entry |
| Loading | `TactileStack` with nothing filled | The trays and slots of what will come. | Our choice |

## Type roles and sizes

Named in `TactileLook`: `title`, `keyLabel`, `row`, `note`, `small`, each a system text style in the rounded design; the count scales from 76 points with the large title; and `margin`, `keyMin`, `rowMin`, `tile`, `picture`, `person`, with `edge` and `radius` from before. The first entry in this look still sets some of these in place.

## Verify

1. Squint at a screen built from these parts. The stack and the count are found first.
2. Find everything with a lower edge. Each can be pressed, or is a block, a pip or the bar's fill.
3. Find a red. There should be none.
4. Press a key and hold: it sits on its edge. Press one that saves: it stays down until the answer, and its words change.
5. Turn the network off: every picture's place is a slot and nothing has moved.
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

The instruments and the invented company belong to the sample. Keep what belongs to the look: which part leads, what colour is allowed to mean, what a
row starts and ends with, and the two kinds of button. The hues, the product and the words are the
sample's.
