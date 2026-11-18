---
id: focus-parts
name: Parts of look 12
direction: 12 Focused Utility
kind: parts
code: FocusLook.swift, FocusKit.swift, FocusParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device.
---

# Parts of look 12

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: drafts of short speeches. One rule runs through all of it: everything is a line of monospaced text. A mark in second ink at the start of a line says what the line is, as "#" says a heading in the draft. Controls are keys, and the caret's blue is used for the caret and for nothing else.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern focus-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Drafts | `drafts` | the draft last worked on leads, a step larger; each line ends in how long it takes to say. `empty`, `loading`, `offline` |
| New draft | `new` | a sheet: a title line, one of a few as keys, a switch, one wide key. `new-error`, `new-busy` |
| Shared | `shared` | a picture, people in three forms, another company's logo and the app's own mark, each as a line. `shared-waiting`, `shared-failed` |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| A line | `FocusLine` | A mark in second ink, the words, a figure at its end. The lead line is a step larger. No box and no rule. |
| Group head | `FocusGroupHead` | Written as a comment in the draft would be: `// can read it`. |
| A picture | `FocusPicture` | A plain rectangle with small corners, set in from the marks. Waiting and failed are the key colour. |
| A person | `FocusPersonMark` | Small enough for a line's mark column: a photograph, an initial on a key, a dashed ring. |
| A logo | `FocusLogoTile` | Its own colours on a light tile the size of a mark. |
| Empty | `FocusEmptyPage` | A "#" and a caret waiting: the one place the hue appears. |

## Controls

Two kinds of button and no third. The switch is the system's.

| Part | In code | Decision |
| --- | --- | --- |
| Main key | `FocusMainKeyStyle` | A wide key filled with ink. Busy, the key colour and new words. Off, the key colour with quiet words. |
| Second button | `FocusBracketButtonStyle` | Words in square brackets, as a link is written in the draft. |
| One of a few | `FocusKeys` | A row of the look's own keys, the chosen one filled. |
| Text field | `FocusField` | A line of the page with its mark; in use the line under it is ink. An error is a line that starts with "!". |
| Notice | `FocusNotice` | From the look. |
| Loading | `FocusGhostLine` | A line's shapes in the key colour. |

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

- The keys of "one of a few" keep the look's own key style, which sets its label in the interface face and not in monospace. It was left as the entry has it.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what colour is allowed to mean, what a row starts and ends with, and the two kinds of button.
