---
id: reading-parts
name: Parts of look 02
direction: 02 Editorial Reading
kind: parts
code: ReadingLook.swift, ReadingKit.swift, ReadingParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device.
---

# Parts of look 02

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: a weekly magazine of long reads. One rule runs through all of it: type does the work. A title is serif and a control is sans, a thing is told from its neighbour by its face and size and not by a box, and this look has no filled button at all.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern reading-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| This week | `issue` | one story leads with its picture; the rest are serif titles with a bookmark that fills. `issue-waiting`, `issue-failed`, `empty`, `loading`, `offline` |
| Masthead | `masthead` | people in three forms, letters, the printer's logo, the app's own mark |
| To the editor | `letter` | a sheet: words on a line, one of a few as rows, a switch; the action is a link in the bar. `letter-error`, `letter-busy` |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The lead story | `ReadingLead` | Its picture, the section in capitals, a serif title, one line for who wrote it and how long it is. |
| A picture | `ReadingPicture` | At its own shape with nearly square corners, as on a printed page. Waiting and failed keep the frame. |
| A story row | `ReadingStoryRow` | A serif title, one quiet line, something at its end. A hairline above. |
| A name row | `ReadingNameRow` | For a person or a company: a lead, a serif name, an end. |
| Group head | `ReadingGroupHead` | A few words in capitals over an ink hairline. |
| A person | `ReadingPersonMark` | A photograph, else a serif initial on the rule colour, else a dashed ring. |
| A logo | `ReadingLogoTile` | Its own colours on a light tile. |
| Empty | `ReadingEmptyPage` | A page with no words yet, drawn as fading lines of text. |

## Controls

Two kinds of button and no third. The switch is the system's.

| Part | In code | Decision |
| --- | --- | --- |
| Main action | `ReadingActionStyle` | A link a size larger: the hue and an underline. Busy, its words change and the underline goes. Off, second ink with no underline. |
| Second action | `ReadingLinkButtonStyle` | From the look: the smaller link. |
| One of a few | `ReadingChoiceRow` | Serif rows, a tick in the hue at the end of the chosen one. |
| Text field | `ReadingField` | Serif words on a line; in use the line is two points of ink. An error is a mark and a reason in ink: the hue means a link. |
| Notice | `ReadingNotice` | From the look. |
| Loading | `ReadingGhostRow` | A story's lines in the rule colour. |

## Basis

Every row above is **our choice**, carried over from the one accepted entry in this look and from the parts of looks 01, 03 and 05. No reference image was looked at for these parts. A person in three forms, a logo on a light tile, and a picture's waiting and failed forms follow `../../../references/pictures.md`.

## Type roles and sizes

Named in an extension of the look in the kit file: type roles, `margin`, `rowMin`, `buttonMin`, `groupGap`, and `rowLead`, the one width for whatever starts a row, so that every name starts at the same edge. The accepted entry in this look was written before these names and still sets its own.

## Verify

1. Look away and back: the first thing seen is the thing the screen is for.
2. Count the hues that are not a picture's: they belong to one kind of thing only.
3. Turn the network off: every picture's place holds its waiting form and nothing has moved.
4. Switch to dark: every logo still shows its own colours on its tile.
5. Press every control and say what changed on the screen.

## Found by building and pressing the screens

- The main action of the sheet sits in the bar as a link, with the bar's glass switched off behind it, because this look has no filled button to put at the sheet's foot.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what colour is allowed to mean, what a row starts and ends with, and the two kinds of button.
