---
id: warm-parts
name: Parts of look 08
direction: 08 Warm Organic
kind: parts
code: WarmLook.swift, WarmKit.swift, WarmParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device. Written by a second agent from one brief; built, screenshotted and tested by the agent that wrote the skill, which read its screens as contact sheets and did not read every line of its code.
---

# Parts of look 08

The parts a second and a third screen in this look are built from, shown in use on a few screens of the entry's invented product: a timer for proofing bread dough. One rule runs through all of it: a drawn picture shows how far a thing has come, large where it leads a screen and small where it starts a row, and it keeps its own palette in light and dark. Off the picture, titles are serif and the one clay hue is for what can be pressed and for the step that is current.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern warm-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| On the counter | `counter` | the jar that is ready soonest leads as the kitchen picture; every other jar is a row that starts with the same jar, small; recipes are rows that start with a photograph. `counter-waiting`, `counter-failed`, `empty`, `loading`, `offline` |
| New rise | `rise` | a sheet: one field, one of a few, a switch, one button. `rise-error`, `rise-busy` |
| One recipe | `recipe` | a photograph leads in the look's frame; each step is a row that starts with its pebble; one button steps through the bake. `recipe-waiting`, `recipe-failed`, and `recipe-plain` for a recipe with no photograph |
| Kitchen | `kitchen` | people in three forms, another company's logo, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The picture that leads | `WarmCounterPicture`, `WarmLead` | The entry's kitchen, standing still, with the dough at this jar's height; a serif name under it and one quiet line. In a scrolling screen it sits in the page with a round top, not under the status bar as in the entry. |
| A small jar | `WarmJar` | The same jar, band and palette at the start of a row, with the dough at that thing's own height. |
| A pebble | `WarmPebble` | The entry's step marks, one to a row: filled when done, wide and clay when current, a ring when to come. |
| Row | `WarmRow` | Something at its start, a name, something quiet at its end. No line and no box. |
| Group head | `WarmGroupHead` | A few serif words, only over a group that needs a name. |
| A photograph | `WarmPicture`, `WarmFrame` | Leading a screen it has a round top and the counter's soft uneven lower edge; starting a row it is a small rounded square. Waiting and failed keep the frame in the quiet colour. A thing with no photograph gets the kitchen's field and sun. |
| A person | `WarmPersonMark` | A photograph, else a serif initial on a quiet disc, else a dashed ring. |
| A logo | `WarmLogoTile` | Its own colours on a light tile. |
| Empty | `WarmCounterPicture(rise: nil)` | The kitchen with the jar standing empty, as in the entry. |

## Controls

Two kinds of button, and the pill for a nudge beside a figure. The switch is the system's, tinted clay.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `WarmMainButtonStyle` | Drawn as the look file's `WarmFilledButtonStyle`, with two more forms. Busy, its words change and the fill stays, because dimming the clay would take the words under 4.5:1. Off, the quiet colour. |
| Second button | `WarmTextButtonStyle` | From the look file: clay words. |
| One of a few | `WarmChoices` | Quiet pills in a row, the chosen one filled with ink. Not clay: clay says "press me". |
| Text field | `WarmField` | A soft box in the pill's colour; in use its edge is two points of clay. An error is a mark and the reason in ink: the picture's berry means done, and clay means something to press. |
| Notice | `WarmNotice` | One line with a text button, as the entry draws its own. |
| Loading | `WarmGhostLead`, `WarmGhostRow` | The picture's frame and the rows' shapes in the quiet colour. |

## Basis

Every row above is **our choice**, carried over from the one accepted entry in this look and from the parts of looks 01, 03, 05 and 09. No reference image was looked at for these parts. A person in three forms, a logo on a light tile, and a picture's waiting and failed forms follow `../../../references/pictures.md`. The photograph is `dough-in-hands` from `../../pictures/` (CC0; see `CREDITS.md` there).

## Type roles and sizes

Named in an extension of the look in the kit file: type roles, `rowMin`, `buttonMin`, `groupGap`, `leadHeight`, and `rowLead`, the one width for whatever starts a row, so that every name starts at the same edge. `margin` was already in the look file. Two colours were added: `rule`, for a shape that is waiting, a field's edge and a button that is off, and `logoPlate`. The accepted entry in this look was written before these names and still sets its own.

## Verify

1. Look away and back: the first thing seen is the picture, and it says how far the thing has come.
2. Count the hues that are not a picture's: clay only, and only on what can be pressed and the current step.
3. Turn the network off: every picture's place holds its waiting form and nothing has moved.
4. Switch to dark: the pictures and the small jars have not changed, and every logo still shows its own colours on its tile.
5. Press every control and say what changed on the screen.

## Found by writing the screens

- `WarmFilledButtonStyle` has no busy or off form, and the look file was not to be changed, so the kit has `WarmMainButtonStyle`, which draws the same when it is on.
- The entry's `ProofClock.length` writes four hours as "4 h 0 min". The parts screens keep whole hours whole.
- A clock time ("ready about 2:10 PM") is left out of the rows: the sample's clock is fixed and would disagree with the status bar. Rows say how long is left.
- Not checked: everything. The two files pass a type-check and have not been built, run or looked at.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: a picture that leads and shows progress, the same picture small at the start of a row, serif titles, one hue for what can be pressed, and the two kinds of button.
