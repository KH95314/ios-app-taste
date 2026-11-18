---
id: media-parts
name: Parts of look 14
direction: 14 Media-Led Experience
kind: parts
code: MediaLook.swift, MediaKit.swift, MediaParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-17, in use from the start (no catalogue version). Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. Not shown in the design system first. Not used by hand, and never on a real device.
---

# Parts of look 14

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: a library that lends art prints. One rule runs through all of it: the pictures are the only colour. Words on a picture are solid white over a scrim, and everything off a picture is black or white. The four prints are woodblock prints by Utagawa Hiroshige from The Met's open collection, CC0 (`../../pictures/CREDITS.md`).

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern media-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Your shelf | `shelf` | rows that start with a small picture. `shelf-waiting`, `shelf-failed`, `empty`, `loading`, `offline` |
| One print | `print` | the picture leads at its own shape, with its title and one action on it. `print-waiting`, `print-failed`, `print-busy`, `print-done` |
| Suggest a print | `request` | a sheet: a field like a title, chips, a switch, one button. `request-error`, `request-busy` |
| Card | `members` | people in three forms, another company's logo, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The lead picture | `MediaHero` | At the picture's own shape, held before the picture comes. Title and facts on it over a scrim, one action beside them, one badge at the top corner. Waiting and failed keep the frame and the words. |
| A small picture | `MediaThumb` | A square at the start of a row, with the same three forms. |
| Row | `MediaRow` | A lead, a name with one quiet line at most, an end. No box and no line: the pictures divide the rows. |
| Group head | `MediaGroupHead` | Heavier than a row. |
| A person | `MediaPersonMark` | Round, and smaller than a picture, so a person is never taken for one. A photograph, an initial, a dashed ring. |
| A logo | `MediaLogoTile` | Its own colours on a light tile. |
| Empty | `MediaEmptyFrames` | Frames with no pictures in them. |

## Controls

Two kinds of button and no third. The switch is the system's.

| Part | In code | Decision |
| --- | --- | --- |
| On a picture | `MediaOnPictureButtonStyle` | From the entry: a white pill, and a white outline for the way back. Its words say where the action stands. |
| Main button | `MediaMainButtonStyle` | Ink, off the pictures. Busy, its words change and the fill lightens. Off, the placeholder colour. |
| Second button | `MediaTextButtonStyle` | Underlined ink words. |
| One of a few | `MediaChipStyle` | From the entry: chips, the chosen one in ink. |
| Text field | `MediaField` | Large words on a line, like a title waiting to be written. An error is a mark and a reason in ink. |
| Notice | `MediaNotice` | From the entry. |

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

- On the small phone the facts under the title wrap onto a second line while the action reads "Reserving…". Nothing is cut.
- A suggested print has no picture yet, so its row shows the waiting form and does not open.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what colour is allowed to mean, what a row starts and ends with, and the two kinds of button.
