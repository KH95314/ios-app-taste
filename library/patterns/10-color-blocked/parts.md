---
id: block-parts
name: Parts of look 10
direction: 10 Color-Blocked Structure
kind: parts
code: BlockLook.swift, BlockKit.swift, BlockParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-17, in use from the start (no catalogue version). Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. Not shown in the design system first. Not used by hand, and never on a real device.
---

# Parts of look 10

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: the shifts of a dog shelter. One rule runs through all of it: a category's colour is always a filled block with white on it, large or small, and every control is ink.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern block-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| This week | `week` | each category is one block and a block's height is its share of the week. `empty`, `loading`, `offline` |
| New shift | `new` | a sheet: a field, the category chosen from the blocks themselves, segments, a switch, one button. `new-error`, `new-busy` |
| Dogs | `dogs` | a picture at the start of a row and a small block at its end. `dogs-waiting`, `dogs-failed`; a row with no picture |
| Team | `team` | people in three forms, another company's logo, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| A category block | `BlockTile` | Icon and name, and one figure. Its height is given by the screen, so size can carry a share. |
| A small block | `BlockChip` | The category's fill, its icon and a time, at the end of a row. |
| Row | `BlockListRow` | Something at its start, a name, something at its end. No box, no line, no colour of its own. |
| Group head | `BlockGroupHead` | Heavier than a row. |
| A picture | `BlockPicture`, `BlockGlyphTile` | A rounded square at the start of a row; waiting and failed are the neutral block colour. |
| A person | `BlockPersonMark` | A photograph, else an initial on the neutral colour, else a dashed ring. |
| A logo | `BlockLogoTile` | Its own colours on a light tile. |
| Empty and loading | `BlockGhostStack` | The stack that is not there, in the neutral block colour. |

## Controls

Two kinds of button and no third. The switch is the system's.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `BlockMainButtonStyle` | Ink. Busy, its words change and the fill lightens. Off, the neutral block colour. |
| Second button | `BlockTextButtonStyle` | From the entry: underlined ink words. |
| One of a few categories | `BlockKindChoice` | The blocks themselves, two to a line; the chosen one has a filled ring with a tick, as a block in the day has. |
| One of a few lengths | `BlockSegments` | Segments in one neutral track, the chosen one in ink. |
| Text field | `BlockField` | The text on a neutral block; in use a two-point ink outline. An error is a mark and a reason in ink: a colour would read as a category. |
| Notice | `BlockNotice` | From the entry. |

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

- "Vet and care" broke onto two lines inside its choice block. The choice sets its names a step smaller and on one line.
- The dogs are drawings (`SampleDog`), since the library has no free photograph of one. Their colours are their own.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what colour is allowed to mean, what a row starts and ends with, and the two kinds of button.
