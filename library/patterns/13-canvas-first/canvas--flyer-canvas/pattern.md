---
id: flyer-canvas
name: A canvas with the tools beneath it
direction: 13 Canvas-First Creation
also_fits: 06 Dark Professional, 12 Focused Utility
kind: canvas
code: FlyerCanvas.swift
look: ../CanvasLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator on iPhone 17 in light and dark and on iPhone SE. A UI test has selected, resized, moved, recoloured and added things, used undo and redo, the layers, the paper and Export on iPhone 17 in light, and the recording was read frame by frame. The photo picker was not opened. Not used by hand. The largest-text screenshots are older than these changes.
---

# A canvas with the tools beneath it

The work sits in the middle of a neutral board and keeps all the colour. A row of tools runs under
it. When something is selected, its controls appear in a strip above the tools.

## Use it when

- People make something by arranging objects: a flyer, a slide, a card, a collage, a room plan.
- The work has to stay in view while it is changed.
- Different objects need different controls.

## Use something else when

- The work is text. Use an editor.
- The job is adjusting one picture with sliders, on live material. The dark professional direction fits.
- There is nothing to arrange, only fields to fill. That is a form with a preview.
- The work needs many precise numeric settings at once. A phone canvas is the wrong place.

## Do

| Decision | Basis |
| --- | --- |
| The work takes most of the screen and the tools sit under it. | Rule. Seen in 5 apps: E1, E2, E3, E4, E5 |
| The board and the bars are neutral. The work has all the colour. | Rule. Neutral chrome in 5 apps: E1 to E5 |
| The tools are a row along the bottom, each a glyph over a word. | Rule. A bottom row of icon and word in 3 apps: E1, E2, E4. E5's row is icons only |
| The tool in use is marked with one hue. | Rule. The selected tool marked with an accent or a filled shape in 3 apps: E5 (purple), E4 (green), E1 (a dark pill) |
| A selected object has a thin outline and round handles at its corners. | Common practice. Seen in 2 apps: E1, E2 |
| The outline is two tones: the hue, with a white hairline either side. Handles are white, ringed in the hue. | Our choice, from a measurement: on the sample's own green the hue alone is 1.1:1 and on its coral 1.6:1. White is 6.5:1 and 3.7:1 on them |
| The selection colours are the same in light and dark. | Our choice. The work under them does not change with the appearance |
| The controls for the selected thing appear in a strip above the tools. | Common practice. Tools that change to suit the selection in 2 apps: E1, E2 |
| The strip's room is kept when nothing is selected. Only its drawing comes and goes, with a short fade. | Our choice, forced by the test: when the strip took its room on selection, the whole page moved up 24 points under the finger that had just touched it, and on a small phone it would also have changed size |
| Values are written as figures: the face by name, the size in points. | Common practice. A slider's value as a figure in 2 apps: E3, E4 |
| Undo and redo are in the top bar. | Common practice. Seen in 2 apps: E2, E5 |
| The top bar holds one worded action, Export. | Our choice. E2 uses icons for download and share |
| The work's name sits over the page's top corner, not in the bar. | Our choice, forced by the test: beside undo, redo and Export the name was cut to "Plant swap f…" on an iPhone 17 and dropped entirely on a narrower phone. None of the five apps shows the work's name in the editor |
| Tool names are short: "Paper", not "Background". | Our choice, forced by the test: five cells across a small phone hold about six letters |
| The dock, the name and the notice stop growing at the first accessibility size. | Our choice, forced by the test: at the largest size a notice left the page a thumbnail. Tools show the large-content preview when held |
| Text inside the work is sized by the work, in points on the page. | Our choice. A flyer's headline is part of the picture, not interface text |
| A new thing appears on the page already selected. Nothing announces it. | Guard rule G1 |
| An empty page offers one dashed placeholder where the first thing would go. | Our choice |
| A page that is still opening shows a spinner. | Our choice, forced by the test: without it, opening looked the same as empty |
| A move or a resize is one step of undo. | Our choice |
| A failure to save is a strip under the bar. Editing carries on. | Our choice |

## Common failures

- A tinted or patterned board that fights the work.
- Panels that slide over the work to change it, so the result cannot be seen.
- A selection outline in one colour that vanishes on artwork of that colour.
- Handles 14 pt wide with a 14 pt target.
- Tool icons with no words, in a tool people open once a month.
- Controls for every kind of object shown at once.
- A value changed by a slider with no figure beside it.
- No undo, or undo that takes one step per pixel of a drag.
- "Shape added" after a shape has appeared on the page.
- The work's name in a bar too crowded to show it.
- Interface text and artwork text scaled by the same setting, so the flyer changes when the reader's text size does.

## Verify

1. Squint: the work is the only colour on the screen, apart from the active tool and the selection.
2. Select something on each colour of your artwork, light and dark. The outline and all four handles show.
3. Switch appearance: the board and bars change, the work and the selection do not.
4. Every value in the strip is a figure or a name.
5. Add something: it appears selected, and undo becomes available. Undo: it is gone and nothing stays selected.
6. Drag a thing, then undo once. It returns to where it started.
7. Measure the chrome. Measured here, light and dark: quiet labels on the board 5.0 and 7.6; the active tool on the bar 5.8 and 6.6.
8. Largest accessibility text size on a small iPhone: the page still fills the board, every tool name is whole, and the name over the page is readable.
9. Hold a tool at that size: the large-content preview names it.
10. Name what each line of interface text says that the work does not (guard rule G1).

Steps 2, 5, 6 and 9 need hands. For this sample the selection was looked at on one object in each
appearance, from a launch argument; nothing was tapped or dragged.

## States

| State | What the sample shows |
| --- | --- |
| Loading | A blank page with a spinner; tools unavailable |
| Empty | A white page with one dashed "Add a title"; Layers unavailable; no Export |
| Failed to save | A strip under the bar: not saved to iCloud, kept on the phone. The work stays editable |
| Failed, nothing to show | A full-screen message with the cause and a retry |
| Success | A circle just added: on the page, selected, its size and colour in the strip, undo available |

## Evidence

Promotional images from a design gallery, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Adobe Photoshop (`adobe-photoshop/03`, `/04`, `/07`, `/08`) | The image over a white panel; a bottom row of icon over word; the selected tool as a dark pill; a text object in a thin box with round blue corner handles, with a floating pill of type tools and a row of Font Family, Style, Size, Color | [Godly gallery](https://godly.design/app/adobe-photoshop/) |
| E2 | Adobe Express (`adobe-express/06`, `/07`, `/10`) | A dark top bar with back, undo, redo, layers, download, share; a text object with a thin outline and small round handles; a bottom row of icon over word; a "Results" sheet with thumbnails | [Godly gallery](https://godly.design/app/adobe-express/) |
| E3 | Afterlight (`afterlight-video-editor/05`, `/06`) | A photo on a dark ground; "GRAIN 30%" and "FILTER 60%" beside sliders; an X and a tick at the bottom corners | [Godly gallery](https://godly.design/app/afterlight-video-editor/) |
| E4 | A Color Story (`a-color-story/03`, `/05`, `/06`) | The photo on top with a curve and white handles over it; a row of icon over tiny capital word, the selected one green; a list of edits each with a percentage | [Godly gallery](https://godly.design/app/a-color-story/) |
| E5 | Pigment (`pigment/07`, `/08`) | A dark frame; a top row of close, undo, redo, more; the artwork; a size slider and a row of colour dots; a bottom row of tool icons, the selected one purple | [Godly gallery](https://godly.design/app/adult-coloring-book/) |

Recorded only, each seen in one app: Photoshop's before-and-after split line (E1); Express's floating
timeline (E2); Afterlight's paired cancel and confirm (E3, also Halide in direction 06); A Color
Story's list of applied edits with a bin each (E4); Pigment's strip of earlier versions (E5). These are
features of those tools and are not part of this pattern.

## Not shown by the evidence

- Dragging or resizing an object, or zooming the board.
- A new, empty project.
- Saving, exporting, or a failure of either.
- How any of them behave at large text sizes.
- Whether the work's name is shown anywhere in these editors. It is not in any of these images.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- Selecting a thing moved the page. The strip appeared in the bottom bar, the board lost that
  height, and the page, centred on the board, jumped up in a single frame. No screenshot shows it,
  because each one is of one state. The strip's room is now always kept, so the page stands a
  little above the middle of the board when nothing is selected.
- The kept room is measured from a hidden strip for the first thing on the page. During the fade,
  that thing's figures showed through for two frames, until the values were set to change at once.
- A navigation bar with a back button, undo, redo and a worded action has almost no room for a title.
  Setting the title and removing it from the bar keeps it for the system; the board shows it.
- The photo picker's label is built off the main actor, so it cannot compare the sample's own types
  there. The comparison is made outside and passed in.
- Default leading on a 56 pt headline pushed the second line into the drawing under it. Display sizes
  take a tighter line height; small text keeps the face's own.
- At the largest text size a three-line notice shrank the page to a thumbnail. Everything around the
  work is capped; the work is not affected by the setting at all.
- The outline hue is invisible on some of the sample's own colours. That is what the white hairline
  is for, and why a one-tone selection should never ship.

## Make it yours

The flyer, its colours and its sprig belong to the sample. Replace the object kinds and the strip for
each with your own. Keep the split that makes this direction work: the work has the colour, the
chrome is neutral, and one hue says what is selected. The sample renders the page again after every
change so Export is always current; that suits one page and would be too slow for a long document.
