---
id: metric-parts
name: Parts of look 09
direction: 09 Metric Hero
kind: parts
code: MetricLook.swift, MetricKit.swift, MetricParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-17, in use from the start (no catalogue version). Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. Not shown in the design system first. Not used by hand, and never on a real device.
---

# Parts of look 09

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: the air in the rooms of a home. One rule runs through all of it: a state's colour is always a filled plate with a number or a word on it, large or small, and nothing else has a hue.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern metric-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Air | `home` | the room that most needs air leads as the plate; every other room is a row ending in a small plate. `home-waiting`, `home-failed`, `empty`, `loading`, `offline` |
| One room | `room` | the plate, and the alert as one row with a text button |
| Alert above | `alert` | a sheet: one large number field, segments, a switch, one button. `alert-error`, `alert-busy` |
| Home | `household` | people in three forms, another company's logo, the app's own mark |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The plate | `MetricHeroPlate` | A label in capitals, one very large number with its unit, the verdict as an icon and words. The fill is the state. |
| A small plate | `MetricChip` | The same fill and ink at the end of a row, with the number alone. No reading: the grey plate and a dash. |
| Row | `MetricPartRow` | Something at its start, a name, something at its end. A hairline above, no box. |
| Group head | `MetricGroupHead` | A few words in capitals. |
| A picture | `MetricPicture`, `MetricGlyphTile` | A small rounded square at the start of a row; waiting and failed keep the square, with no hue. A thing with no picture gets a glyph on a neutral tile. |
| A person | `MetricPersonMark` | A photograph, else an initial on a neutral disc, else a dashed ring. |
| A logo | `MetricLogoTile` | Its own colours on a light tile. |
| Empty | `MetricEmptyPlate` | The grey plate with dashes where the number will be. |

## Controls

Two kinds of button and no third. The switch is the system's.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `MetricMainButtonStyle` | Ink, as wide as its place. Busy, its words change and the fill lightens. Off, the rule colour. On a plate the entry's `InkButtonStyle` is used instead. |
| Second button | `MetricTextButtonStyle` | Underlined words in ink. |
| One of a few | `MetricSegments` | Segments in one track, the chosen one in ink. |
| Number field | `MetricNumberField` | One large number with its unit on a line; in use the line is two points of ink. An error is a mark and a reason in ink: a state's colour would say something about the air. |
| Notice | `MetricNotice` | From the entry. Offline, the plates turn grey and keep their last numbers. |
| Loading | `MetricGhostRow` | The plate's shape and the rows' shapes in neutral. |

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

- The kit's row first took the name of a private type in the accepted entry, and the build stopped. It is `MetricPartRow`.
- Two quiet lines were cut after the first screenshot ("gets every alert", "3 sensors"): nobody acts on either.
- Not checked: the keyboard over a sheet on the small phone, anything by hand, a recording of the presses, and a real device.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what colour is allowed to mean, what a row starts and ends with, and the two kinds of button.
