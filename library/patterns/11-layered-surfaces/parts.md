---
id: layer-parts
name: Parts of look 11
direction: 11 Layered Surfaces
kind: parts
code: LayerLook.swift, LayerKit.swift, LayerParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device. Written by a second agent from one brief; built, screenshotted and tested by the agent that wrote the skill, which read its screens as contact sheets and did not read every line of its code.
---

# Parts of look 11

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: a finder for public drinking-water refill points, the product of the look's accepted entry. One rule runs through all of it: the layer underneath keeps the colour, and the surface on top is ink on one solid ground. The subject's hue comes up onto a surface in one form only, a pin, large on the plan and small at the start of a row; a state is the look's badge; nothing else on a surface has a hue.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

The layer underneath is a drawn plan here, not Apple's map as in the accepted entry: map tiles cannot be in the library's pictures, and a live map does not hold still for a screenshot. The surface is a solid panel and not the system's sheet, so its words are measured on one colour. A real product keeps the system's map and sheet, as the entry does.

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern layer-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Nearby | `map` | the plan with its pins, and a surface over it: the nearest point leads, every other point is a row that starts with its own pin. `empty`, `loading`, `offline` |
| New refill point | `add` | a sheet: a name field, one of three kinds, a switch, one button. `add-error`, `add-busy` |
| One point | `point` | a picture underneath and a surface over its lower edge: the lead, what is at the point, two buttons. `point-waiting`, `point-failed`, and `point-plain` for a point with no picture, which gets the plan and its pin |
| Keepers | `keepers` | people in three forms, another company's logo, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The plan | `LayerPlan` | The layer underneath, drawn from its own size. Everything that matters is placed in the part the surface leaves clear. No text is set on it. |
| A pin | `LayerPin` | The subject's hue and a glyph on a disc; a point that cannot be used changes its glyph as well as its colour. Large for the point that leads, smaller for the others, small at the start of a row. |
| The surface | `LayerSurface` | One solid ground with rounded top corners, running on under the home indicator. No grabber: it is not dragged. |
| The lead | `LayerLead` | A name, the distance in ink with the walk beside it, and the state as the look's badge. |
| Row | `LayerPartRow` | Something at its start, a name with one quiet line at most, something at its end. A hairline above, no box. |
| Group head | `LayerGroupHead` | A few words at the reading size, in bold. |
| A picture | `LayerPicture`, `LayerGlyph` | The layer underneath: it fills its place. Waiting, the place is the control fill; failed, the fill keeps a mark. With no picture, the plan with the point's pin. A row whose thing has neither gets a bare glyph in second ink. |
| A person | `LayerPersonMark` | A photograph, else an initial on the control fill, else a dashed ring. |
| A logo | `LayerLogoTile` | Its own colours on a light tile. |
| Empty | `LayerEmptyPin` | A dashed ring where a pin would stand, inside two rings of the distance searched. |
| State | `StatusBadge` | From the look file: an icon, the state in words and a tint. |

## Controls

Two kinds of button and no third. The switch is the system's, with the pin's hue when it is on.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `LayerMainButtonStyle` | Ink, as wide as its place, drawn as the look file's main button. Busy, its words change and the fill lightens. Off, the control fill with second ink. |
| Second button | `LayerButtonStyle(kind: .second)`, `LayerSmallButtonStyle` | The control fill and ink words: the look file's beside a main button, and a smaller capsule at a row's end or in a notice. |
| One of a few | `LayerChoice` | Segments in one track of the control fill, the chosen one in ink. |
| Text field | `LayerField` | The control fill with a ring of ink while in use. An error is the warning colour as a ring, a mark and the cause, and it goes when the text changes. |
| Switch | the system's `Toggle` | Tinted with the pin's hue. Ink would lose the knob in dark. |
| Notice | `LayerNotice` | A glyph, the state, one quiet line and a small button on the control fill. Not a hue, because it sits on a surface. |
| Loading | `LayerGhostLead`, `LayerGhostRow` | The lead's three lines and the rows' shapes in the control fill; the plan has no pins yet. |

## Basis

Every row above is **our choice**, carried over from the one accepted entry in this look and from the parts of looks 01, 03, 05, 09, 10 and 14. No reference image was looked at for these parts. A person in three forms, a logo on a light tile, and a picture's waiting and failed forms follow `../../../references/pictures.md`.

## Type roles and sizes

Named in an extension of the look in the kit file: type roles, `margin`, `rowMin`, `buttonMin`, `groupGap`, and `rowLead`, the one width for whatever starts a row, so that every name starts at the same edge. The kit also names the surface's solid ground, the pin's glyph colour and the plan's five colours. The accepted entry in this look was written before these names and still sets its own.

## Verify

1. Look away and back: the first thing seen on the surface is the thing the screen is for.
2. Count the hues on a surface: a pin, a badge, a switch that is on, and nothing else.
3. Check that no pin is under the surface or the bar, on the small phone as well.
4. Turn the network off: the picture's place holds its waiting form and the surface has not moved.
5. Switch to dark: every logo still shows its own colours on its tile.
6. Press every control and say what changed on the screen.

## Make it yours

The product, the names, the drawn plan and the invented companies belong to the sample. Keep what belongs to the look: the layer underneath keeps the colour, the surface is ink on one ground, a pin is the one hue that comes up onto it, and there are two kinds of button.
