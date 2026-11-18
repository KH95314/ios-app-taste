---
id: canvas-parts
name: Parts of look 13
direction: 13 Canvas-First Creation
kind: parts
code: CanvasLook.swift, CanvasKit.swift, CanvasParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device. Written by a second agent from one brief; built, screenshotted and tested by the agent that wrote the skill, which read its screens as contact sheets and did not read every line of its code.
---

# Parts of look 13

The parts a second and a third screen in this look are built from, shown in use on a few screens of the entry's invented product: a flyer maker for neighbourhood notices. One rule runs through all of it: the work has the colour, and it lies on the board as a page, large where it leads a screen and small where it starts a row. Everything around it is neutral, and the one hue marks what is chosen or in use.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5). The kit's types are named `Studio…`, because `Canvas` is SwiftUI's own.

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern canvas-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Flyers | `flyers` | the newest flyer leads as a page on the board with its name over its corner; every other flyer is a row that starts with a small page. `flyers-waiting`, `flyers-failed`, `empty`, `loading`, `offline` |
| New flyer | `new` | a sheet in chrome: a name field, three chips for the shape, a switch, one button. `new-error`, `new-busy` |
| One flyer | `flyer` | the page on the board and a dock under it: a print shop's row with the price, chips for the copies, one button. `flyer-ordered` |
| People | `people` | people in three forms, two print shops' logos, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| A page | `StudioPage` | The work as a picture, square-cornered, with a soft shadow on the board. Waiting, the bare page (and a spinner when it leads); failed, the page keeps a mark; nothing made yet, a dashed outline. No hue in any form. |
| The page that leads | `StudioLeadWork` | The page large, at most 320 points tall so a row shows under it, with the work's name over its corner in the quiet ink, as the editor labels it. |
| Row | `StudioPartRow` | Something at its start, a name, something at its end. No box and no line: on the board the small pages mark the rows. |
| A person | `StudioPersonMark` | A photograph, else an initial on a chrome disc, else a dashed ring. |
| A logo | `StudioLogoTile` | Its own colours on a light tile with a hairline. |
| Empty | `StudioEmptyPage` | A bare page, already selected, with the look's outline and handles. |

There is no group head: a larger gap separates the groups, and none of them needs a name.

## Controls

Two kinds of button and no third. The switch is the system's, tinted with the hue: on is "in use".

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `StudioMainButtonStyle` | Ink, as wide as its place, never the hue: a coloured button would outshine the work. Busy, its words change and the fill lightens. Off, a chip with quiet words. |
| Second button | `StudioTextButtonStyle` | Underlined words in ink, as in the look's notice. |
| One of a few | `StudioChoice` | The look's chips in a row; the chosen one is worded and ringed in the hue, as the tool in use is. Off, the others go quiet and the chosen one stays. |
| Text field | `StudioField` | A chip as wide as its place; in use it is ringed in the hue. An error is a mark and a reason in ink: the hue means "chosen" and cannot also mean "wrong". |
| Notice | `CanvasNotice` | From the look file. Offline, the list keeps the copies on the phone. |
| Loading | `StudioGhostRow` | A bare page and a bar for the name; the lead is a bare page with a spinner. |

## Basis

Every row above is **our choice**, carried over from the one accepted entry in this look and from the parts of the other looks. No reference image was looked at for these parts. A person in three forms, a logo on a light tile, and a picture's waiting and failed forms follow `../../../references/pictures.md`.

## Type roles and sizes

Named in an extension of the look in the kit file: type roles, `margin`, `rowMin`, `buttonMin`, `groupGap`, and `rowLead`, the one width for whatever starts a row, so that every name starts at the same edge. The margin is the entry's 24 points, so a page's edge and a row's edge are one edge. The accepted entry in this look was written before these names and still sets its own.

## Verify

1. Look away and back: the first thing seen is the work.
2. Count the hues that are not the work's, a photograph's or a logo's: there is one, and it is on something chosen or in use.
3. Turn the network off: every page's place holds its waiting form and nothing has moved.
4. Switch to dark: the pages and the logos keep their own colours; only the board and the chrome change.
5. Press every control and say what changed on the screen.
6. Order prints and cancel: the page does not move.

## Found by writing the screens

- A flyer made with no title has nothing to draw, so it shows as the dashed outline; one made with a title shows a white page with the word on it.
- The pictures of the flyers are the entry's own `FlyerArtwork`, rendered once. Three more flyers were drawn from the entry's items for the list.
- Not checked: everything. The two files pass a type-check outside the host; nothing has been built, screenshotted or pressed.

## Make it yours

The product, the names, the flyers and the invented companies belong to the sample. Keep what belongs to the look: the work as the only colour, lying on the board; neutral rows and tools; ink for buttons; the hue for what is chosen and nothing else.
