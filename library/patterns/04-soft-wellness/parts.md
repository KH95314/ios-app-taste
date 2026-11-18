---
id: soft-parts
name: Parts of look 04
direction: 04 Soft Wellness
kind: parts
code: SoftLook.swift, SoftKit.swift, SoftParts.swift
status: Built on the iOS 26.5 simulator on 2026-11-18, in use from the start. Every screen and state screenshotted on iPhone 17 in light and dark and on iPhone SE. Live controls pressed by one UI test that checks what each changes on the screen; not recorded. `contrast.py` passes on the look with its kit. Not shown in the design system first. Not used by hand, and never on a real device. Written by a second agent from one brief; built, screenshotted and tested by the agent that wrote the skill, which read its screens as contact sheets and did not read every line of its code.
---

# Parts of look 04

The parts a second and a third screen in this look are built from, shown in use on a few screens of one invented product: the energy diary of the look's accepted entry, for someone pacing a recovery. One rule runs through all of it: the one hue means "yours" and never good or bad. It is the level mark, a ring filled from the bottom, large where it leads a screen and small where it starts a row; the chosen one of a few; and the main button. Nothing is scored, and a failure or an error is said in ink, with no red.

Nothing on a screen names a part or a state (guard rules G1 and G12); this page does. A real screen takes a few of these parts and lets one of them lead (`../../../SKILL.md`, step 5).

```bash
xcrun simctl launch <device> dev.iostaste.patternhost -pattern soft-parts -variant <variant>
```

| Screen | Variant | Shows |
| --- | --- | --- |
| Today | `today` | the latest answer leads as the large mark and its word; every earlier answer is a row that starts with the small mark, and ends in a picture when one was kept with its note. `today-waiting`, `today-failed`, `empty`, `loading`, `offline` |
| How's your energy? | `checkin` | a sheet: five choices of equal standing and one button, a surface until one is chosen |
| One answer | `moment` | the mark, the note, and the picture at its full width. `moment-waiting`, `moment-failed` |
| Circle | `circle` | people in three forms, another company's logo, the app's own mark |
| Invite someone | `invite` | a sheet: one field, two choices, a switch, one button. `invite-error`, `invite-busy` |

## The look's own content parts

| Part | In code | Decision |
| --- | --- | --- |
| The lead | `SoftLead` | One answer: the level mark at 96 points, its word, one quiet line. Centred on the ground, in no box. The fill's height is the level; no colour ranks it. |
| The small mark | `SoftRowMark` | The same mark at the start of a row. |
| Group | `SoftGroup` | Rows on one surface with large corners. Room sets rows apart; there is no hairline. |
| Group head | `SoftGroupHead` | A few quiet words, only where a group needs a name. Today's rows have none. |
| Row | `SoftRow` | Something at its start, a name with one quiet line at most, something at its end. |
| A picture | `SoftPicture` | A small rounded square at a row's end, or as wide as its place at a given shape. Waiting, the quiet fill at the same size; failed, the fill keeps a mark. No picture: a note's glyph on the same square. |
| A person | `SoftPersonMark` | A photograph, else an initial on a quiet disc, else a dashed ring. No hue: the hue is the diary owner's. |
| A logo | `SoftLogoTile` | Its own colours on a light tile with round corners. |
| The app's mark | `SoftAppMark` | A half-full ring on the hue, beside the version. |
| Empty | `SoftEmptyDrawing` | The ring, empty, in a soft light of the hue with no edge. |

## Controls

A main button, the look's quiet button and its text button. The switch is the system's, tinted with the hue.

| Part | In code | Decision |
| --- | --- | --- |
| Main button | `SoftMainButtonStyle` | Draws as the look's `SoftButtonStyle()` and adds a busy form: its words change, and it takes the chosen row's fill with the words in the hue. Off, it is a surface, as in the look. |
| Second button | `SoftTextButtonStyle`, `SoftButtonStyle(kind: .quiet)` | From the look file. Words in the hue at a row's end; a surface beside a main button. |
| One of a few | `SoftChoiceRow` | Each choice is a surface of its own. The chosen one takes the tint, a ring in the hue and a tick, whichever it is. It may start with a mark. |
| Field | `SoftField` | A surface as round as the buttons; in use it takes the chosen row's ring. An error is a ring, a mark and the reason, all in ink: a mistake in an address is not a bad answer. |
| Notice | `SoftNotice` | From the look file. Offline, nothing is dimmed: the answers are still the person's. |
| Loading | `SoftGhostLead`, `SoftGhostRow` | The ring and the rows' shapes in the quiet fill. The soft light waits for an answer. |
| A row that opens | `SoftPressStyle` | Dims while pressed. It shows no chevron; what it ends with says there is more. |

## Basis

Every row above is **our choice**, carried over from the one accepted entry in this look and from the parts of looks 01, 03, 05 and 09. No reference image was looked at for these parts. A person in three forms, a logo on a light tile, and a picture's waiting and failed forms follow `../../../references/pictures.md`.

## Type roles and sizes

Named in an extension of the look in the kit file: type roles (all in the rounded design), `margin`, `inset`, `rowMin`, `buttonMin`, `groupGap`, and `rowLead`, the one width for whatever starts a row, so that every name starts at the same edge. The kit adds two colours: `hush`, for what has not arrived and what holds no hue, and `logoPlate`. The accepted entry in this look was written before these names and still sets its own.

## Verify

1. Look away and back: the first thing seen is the thing the screen is for.
2. Find every place the hue is used: each is the person's own answer, their choice, or the one main action. None says good or bad.
3. Turn the network off: every picture's place holds its waiting form and nothing has moved.
4. Switch to dark: every logo still shows its own colours on its tile.
5. Press every control and say what changed on the screen.

## Found by building and pressing the screens

- Nothing yet: the screens are written and type-checked, and have not been built.

## Make it yours

The product, the names and the invented companies belong to the sample. Keep what belongs to the look: what leads, what the one hue is allowed to mean, what a row starts and ends with, and that nothing is scored or shown in red.
