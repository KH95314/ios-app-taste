---
id: scene-parts
name: Parts of look 07
direction: 07 Immersive Environment
kind: parts
code: SceneLook.swift, SceneKit.swift, SceneParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device. Written by a second agent from one brief; built, screenshotted and tested by the agent that wrote the skill, which read its screens as contact sheets and did not read every line of its code.
---

# Parts of look 07

The parts a second and a third screen in this look are built from, shown in use on a few screens of the entry's own invented product: the tide at a few coves. Two rules run through all of it. The scene is the data, large or small: it fills the main screen, and on every other screen it comes back as a porthole at the start of a row, drawn at that row's own tide and hour. And words sit only on water: no card, and no shape lighter than the look's `floor` ever has words on it.

How much scene stays behind a second screen: none. A list, a form and a sheet scroll, and scrolled words would cross the sky. Those screens sit under the water: their ground is the sea's two colours, the same in light and dark.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern scene-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Coves | `coves` | the nearest cove is the scene and the reading; every other cove is a row on the water with a porthole and a figure. It does not scroll. `empty`, `loading`, `offline` |
| One cove | `cove` | a picture where the scene stood, the reading, the day's turns as rows, the alert as one row with a text button. `cove-waiting`, `cove-failed`. A cove with no camera shows the drawn scene in the picture's place (open Skerry Cove from `coves`) |
| Alert below | `alert` | a sheet: one large number field, three choices, a switch, one button. `alert-error`, `alert-busy` |
| Sharing | `crew` | people in three forms, another company's logo, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The reading | `SceneReading` | A few words in capitals, one very large thin figure with its unit, and what it is doing as an arrow and a word. Straight on the water. |
| A small reading | `SceneFigure` | The same thin figures at the end of a row, with the arrow alone. |
| A porthole | `ScenePorthole` | The scene, small: a round window at the start of a row, holding the product's drawing of that row's own water and sky. |
| Water | `SceneWater`, `SceneWaterLine` | The ground of every screen that scrolls, from `floor` to `deep`. The wave line closes a picture and crosses the empty drawing. |
| Row | `ScenePartRow`, `SceneGlyph` | Something at its start, a name, one quiet line at most, something at its end. No box and no rule. A thing that is not a place starts with a plain glyph. |
| Group head | `SceneGroupHead` | The look's label in capitals, only where a group needs a name. |
| A picture | `SceneWindow` | It stands where the scene stands: at the top, edge to edge, no corners, ending in the water line. Waiting, the same band in haze; failed, the band keeps a mark. With no picture, the drawn scene takes the band. |
| A person | `ScenePersonMark` | A photograph in a ring, else an initial in a ring, else a dashed ring. Rings only: a filled white disc is a button here. |
| A logo | `SceneLogoTile` | Its own colours on a white tile with corners, so it is not taken for a porthole. |
| Empty | `SceneEmptyPorthole` | A large dashed porthole with still water across it, on the water alone. |

## Controls

Two kinds of button and no third. Every control is solid white with dark words, or an outline. The switch is the system's, untinted: the look has no hue of its own.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `SceneMainButtonStyle` | The look file's white button, as wide as its place. Busy, its words change and the white greys a little. Off, an outline: a dimmed white would pass on one part of the water and fail on another. |
| Second button | `SceneTextButtonStyle` | Underlined white words, as the entry's "Try again" is. |
| One of a few | `SceneChoices` | Capsules in a row, the chosen one solid white, the others outlines. No track. |
| Number field | `SceneNumberField` | The reading's thin figures with their unit on a line; in use the line is two points of white. An error is a mark and the cause in white. |
| Notice | `SceneNotice` | One line on the water with the way out at its end. The entry's own notice is private to its file; this one draws the same. |
| Loading | `SceneGhostReading`, `SceneGhostRow` | The reading's and the rows' shapes in haze. Haze is lighter than `floor`, so it never has words on it. |
| A press | `ScenePressStyle` | A reading or a row that opens dims while pressed, with no chevron. |

## Basis

Every row above is **our choice**, carried over from the one accepted entry in this look and from the parts of the looks built before it. No reference image was looked at for these parts. A person in three forms, a logo on a light tile, and a picture's waiting and failed forms follow `../../../references/pictures.md`.

Three things differ from the accepted entry, on purpose. Its empty state shows a calm sea; here a screen with no place shows the water alone and the empty porthole, because a scene of nowhere would be made up. Its failed screen is flat `floor`; the screens here use the two-colour water. And the main screen here carries rows of other coves where the entry has its scrubber.

## Type roles and sizes

Named in an extension of the look in the kit file: type roles, `rowMin`, `buttonMin`, `groupGap`, `windowHeight`, and `rowLead`, the one width for whatever starts a row, so that every name starts at the same edge. `margin` was already in the look file. Three colours are added: `deep`, `haze` and `logoPlate`. The accepted entry in this look was written before these names and still sets its own type.

## Verify

1. Look away and back: the first thing seen is the thing the screen is for.
2. Find every word and say what is behind it: water, solid white, or nothing lighter than `floor`.
3. On the main screen at the lowest tide on the smallest phone, check that the top word is still under the water line.
4. Turn the network off: every picture's place holds its waiting form and nothing has moved.
5. Switch to dark: nothing changes but the system's own controls.
6. Press every control and say what changed on the screen.

## Not checked

Nothing here has been built or seen. In particular: whether the reading and three rows stay under the water line on the small phone; the status bar's figures over the sky on the main screen, which has no bar button; the system's switch and the keyboard on the water in light appearance; and the hard scroll edge over the two-colour ground.

## Make it yours

The product, the cove drawing, the names and the invented companies belong to the sample. Keep what belongs to the look: the scene as the ground of one screen and as a porthole on the others, words only on water, thin white figures large and small, and the two kinds of button.
