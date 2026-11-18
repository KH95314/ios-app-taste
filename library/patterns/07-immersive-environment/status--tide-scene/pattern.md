---
id: tide-scene
name: A scene that is the reading
direction: 07 Immersive Environment
also_fits: 09 Metric Hero, 14 Media-Led Experience
kind: status
code: TideScene.swift
look: ../SceneLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator at the default text size, on iPhone 17 in light and dark and on iPhone SE. Not used by hand, so the scrubber is not verified.
---

# A scene that is the reading

A scene fills the screen and is the data. Here the sea stands where the tide is and the sky is the
time of day. A thin value, one word and a few rows sit straight on the water. One scrubber looks
ahead through the day.

## Use it when

- The thing people come to check can be drawn: a level, the weather, the sky, a place.
- The drawing can carry the reading, so a glance tells most of it before any number is read.
- There is little to do on the screen besides look, and perhaps look ahead.

## Use something else when

- There are many figures of equal weight. Use rows of figures.
- The value has no natural picture. A scene would only be decoration; use the hero metric.
- People act on the screen more than they read it. A scene leaves little room for controls.
- The pictures are content to choose from. That is the picture wall.

## Do

| Decision | Basis |
| --- | --- |
| A scene fills the screen, edge to edge, with no frame. | Rule. A scene or object filling half the screen or more, unframed, in 3 apps: E1, E2, E3. Running it under the status bar and to every edge is our choice |
| The scene is the reading: the water stands where the tide is, and the sky is the time. | Our choice. E1's scenes show the kind of weather; none of the images shows a scene carrying a measured value |
| Words sit straight on the scene, not in cards. | Rule. Seen in 3 apps: E1, E2, E3 |
| Words sit only where the scene is dark enough, and that part is kept dark at every state. | Our choice, from a measurement: white on the day sky is 1.9:1, and 6.4:1 on the lightest water. The sea fills more than the lower half at every tide, so the words stay on it |
| Text is solid white, with one solid tint for small labels. Nothing is dimmed. | Our choice, as in the colour-block and picture-wall entries |
| The scene follows its own time of day, not the light or dark setting. | Recorded only: in E1 the ground is pale, black or cream with the weather. E2 and E3 are dark in every image |
| The value is large and thin; one word under it says what it is doing, with an arrow. | Our choice. E1 builds its numerals from coloured blocks, which is its brand |
| A few rows of label and figure follow, with labels in small capitals. | Common practice. A table of label and value under the scene in 2 apps: E1, E2. Capital labels in the same 2 |
| No lines or boxes between the rows. | Our choice. E1 draws leader lines |
| One scrubber looks ahead through time, and the scene changes with it. | Recorded only: E1 has a scrubber under its scene. What it does to the scene cannot be seen in a still image |
| Away from now, one button returns, and it is the system's glass. | Common practice for translucent controls over a scene: 2 apps, E2 and E3 |
| A reading that is only true now is left out when looking ahead. | Our choice |
| The status bar follows the sky: dark figures by day, light by night. | Our choice |
| A failure is one line on the water with the retry at its end. The scene and the table stay. | Our choice |
| With no place chosen, the scene is still there, with a title and one white button. | Our choice |

## Common failures

- A photograph or a gradient behind the figures that says nothing about them.
- White text over a bright sky, readable at night and lost at noon.
- Text dimmed with opacity to make it quieter, so it fails wherever the scene is light.
- Cards laid over the scene until the scene is a border.
- A scene that changes with the system's light or dark setting and not with what it shows.
- Controls scattered over the scene.
- A value in a heavy face that fights the scene for attention.
- Looking ahead changes the number and not the scene.
- A live reading still shown beside a time six hours away.

## Verify

1. Cover the words. The scene still says roughly how high the tide is and whether it is day or night.
2. Move through a whole day. At every hour, every word sits on water.
3. Measure the text on the lightest part of the scene it can sit on. Measured here: 6.4:1 for the value and the rows, 4.9:1 for the small labels.
4. Switch between light and dark. The screen does not change.
5. Look ahead to the evening: the sky, the sea level, the value, the label and the rows all change, and a way back appears.
6. Small iPhone: the words still start below the water line, with the notice showing.
7. Offline: the scene and the tide table remain, the notice is one line, and the buoy reading carries its time.
8. Name what each line of text says that the scene does not (guard rule G1).

Steps 2 and 5 were checked at two moments, from launch arguments: now, and 9:00 PM. The scrubber was
not moved by hand.

## States

| State | What the sample shows |
| --- | --- |
| Loading | The scene at midday with placeholders for the words; the scrubber unavailable |
| Empty | No place chosen: the scene, "No place yet", and one white button |
| Failed, with a saved table | One line on the water: offline, saved tide table, try again. The buoy reading shows when it was taken |
| Failed, nothing saved | A plain ground in the water's colour, with the cause and a retry |
| Success | Looking ahead to 9:00 PM: night, the moon rising behind the headland, a lower sea, "0.8 m, Falling", the next low and high, and "Back to now" |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown. The
evidence for this direction is thin: one of the three apps has a single usable image.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | (Not Boring) Weather (`not-boring-weather/02`, `/04`, `/05`, `/06`) | A 3-D island with rain, a moon, or a storm cloud filling half the screen or all of it; grounds in pale grey, black and cream; tables of monospaced capital labels and values with leader lines, one row in a pill; a scrubber and a day or week switch; a temperature built from coloured blocks | [App Store](https://apps.apple.com/us/app/not-boring-weather/id1531063436) |
| E2 | Sky Guide (`sky-guide/03`, `/04`) | A picture of a space station over the earth filling the top; the title on it; a table of grey capital labels and values; three round translucent controls floating at the bottom | [App Store](https://apps.apple.com/us/app/sky-guide/id576588894) |
| E3 | Portal (`portal/02`, tilted in the source) | A nature scene inside a large circle; a serif title and an italic place name on it; a heart, a translucent "Play" pill and a download icon | [App Store](https://apps.apple.com/us/app/portal-escape-into-nature/id1436994560) |

Recorded only, each seen in one app: (Not Boring) Weather's 3-D rendering, its block numerals and its
yellow warning pill (E1); Sky Guide's sheet of picture cards over the star field (E2); Portal's
circular frame and serif title (E3). These are brand decisions and are not copied.

## Not shown by the evidence

- How any of these apps keep text readable over a bright part of a scene.
- What their scrubbers and switches do to the scene.
- Loading, a failure, or a first run with nothing chosen.
- Whether people read the scene first or the number first.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- A scene drawn at one fixed shape and scaled to cover puts the water line in a different place on
  every phone. Drawing it from the screen's own size, with the water line as a share of the height,
  keeps the words on the water on a small phone too.
- Ripples drawn on the water ran through the words on a small phone. The water is now plain below its
  line.
- On a small phone with the notice showing, the retry link sits over the faint underwater part of the
  tide pole. It is still readable; a busier scene would need that corner kept clear.
- The light and dark screenshots are the same picture, as intended.

## Make it yours

The cove, its colours and the tide pole belong to the sample. Draw your own scene, and decide first
which part of it stays dark enough for words at every state; that part is where the words go. Keep
the controls to one or two. The sample's tide is a single smooth wave and its scene does not move; a
real one would use a tide table, and might let the water drift.
