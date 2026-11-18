---
id: pro-parts
name: Parts of look 06
direction: 06 Dark Professional
kind: parts
code: ProLook.swift, ProKit.swift, ProParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device.
---

# Parts of look 06

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: the takes of a field recorder. One rule runs through all of it: a value is monospaced under a small label in capitals, and the one hue marks the single thing that is selected or being set. Nothing else is lit. Red means recording and is not used on these screens.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern pro-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Takes | `takes` | the selected take leads as its sound, with its figures; every take is a row and selecting one moves the light. `empty`, `loading`, `offline` |
| Export | `export` | a sheet: a name, a format as keys, a switch, one button. `export-error`, `export-busy` |
| Session | `session` | a picture, people in three forms, another company's logo, the app's own mark. `session-waiting`, `session-failed` |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| A take's sound | `ProWave` | Bars from the middle line: ink up to the playhead, quiet after it, the playhead in the hue. |
| Row | `ProRow` | A lead, a monospaced name, a figure at its end. The selected row takes the hue and a bar of it at the leading edge. |
| Group head | `ProGroupHead` | One or two words in small capitals. |
| A picture | `ProPicture`, `ProGlyphTile` | A square with small corners; waiting and failed are the track colour. A thing with no picture gets a glyph in an outlined square. |
| A person | `ProPersonMark` | A photograph, else monospaced initials in a ring, else a dashed ring. |
| A logo | `ProLogoTile` | Its own colours on a light tile, on a black screen. |
| Empty | `ProWave(isQuiet:)` | A flat line where the sound will be. |

## Controls

Two kinds of button and no third. The switch is the system's.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `ProMainButtonStyle` | Filled with the hue: at that moment it is the thing to set. Busy, the track colour with ink words. Off, an outline. |
| Beside it | `ProSideButtonStyle` | From the look: an outlined capsule. |
| Second button | `ProTextButtonStyle` | Underlined ink words. |
| One of a few | `ProKeys` | Outlined keys; the chosen one filled with the hue. |
| Text field | `ProField` | A label in capitals, monospaced text on a line; in use the line is the hue. An error is a mark and a reason in ink: red means recording. |
| Notice | `ProNotice` | One row on the panel with a retry at its end. |

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

- The screens are dark in both appearances, as the entry is, so the light and dark screenshots are the same.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what colour is allowed to mean, what a row starts and ends with, and the two kinds of button.
