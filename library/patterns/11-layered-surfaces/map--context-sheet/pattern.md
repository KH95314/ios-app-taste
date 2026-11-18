---
id: context-sheet
name: Context with a resizable detail sheet
direction: 11 Layered Surfaces
also_fits: 14 Media-Led Experience
kind: map
code: ContextSheet.swift
look: ../LayerLook.swift
status: Built and screenshotted on the iOS 26.5 simulator on iPhone 17 in light and dark and on iPhone SE. A UI test has reported a problem, gone between the list and a point, and dragged the sheet up and down on iPhone 17 in light, and the recording was read frame by frame. Directions and the map's own pins were not pressed. Not used by hand.
---

# Context with a resizable detail sheet

A map or picture fills the screen, stays in view, and keeps the colour. A sheet rests over its lower
part with the selected thing's name, the facts needed to decide, a status badge and one pinned action
in ink. Pulling the sheet up shows the rest.

## Use it when

- People choose among things by where they are, or by looking at them.
- They move back and forth between the overview and one item.
- One action follows from choosing (go there, book it, start).

## Use something else when

- Position does not help the choice. Use a list and a pushed detail screen.
- The detail is long and read top to bottom. Give it a full screen.
- The sheet would hold a multi-step form. Present that as its own full-height sheet.

## Do

| Decision | Basis |
| --- | --- |
| The context stays visible above the resting sheet. | Rule. Seen in 3 apps: E1, E2, E3 |
| The resting sheet shows the name, one line of key facts, and status. | Rule. Seen in 3 apps: E1, E2, E3 |
| In the line of facts, the one people decide by (the distance) is heavier than the rest. | Our choice. Recorded in 1 app: E2 sets its figures large with small units |
| Status is a badge: an icon, the state in words, and a tint. | Our choice. Recorded in 1 app: E3 (a red badge with an icon and "Running late"). HIG, Color: avoid relying solely on colour |
| Nothing is written under the badge, and the no-results state has no sentence. | Guard rule G1. It departs from E3, which states the reason for a status in a sentence |
| The main action is pinned to the bottom of the sheet, with a smaller second action beside it. | Common practice. Seen in 2 apps: E1 (wide button plus a small one), E2 (two pills). E3 shows no action in the visible part |
| The main action is filled with ink, not a hue. The second takes a quiet neutral fill. | Our choice. On this screen colour belongs to the map and its pins, so the sheet does not compete with them |
| A pin's hue belongs to the subject (water here). A point that cannot be used changes its glyph as well as its colour. | Our choice. HIG, Color: avoid relying solely on colour |
| The sheet has a grabber and two heights. | HIG, Sheets: include a grabber in a resizable sheet; a smaller detent allows progressive disclosure |
| The resting height is measured from the content, not typed as a number. | Our choice, forced by the test: a fixed height cut the action off at large text |
| The resting height is capped at about three fifths of the screen. | Our choice, forced by the test: uncapped, the sheet hid the map on a small phone at the largest text size |
| Everything below the header is hidden until the sheet is pulled up. | Our choice, forced by the test: the resting sheet ended on a half-cut line |
| When the content changes, the sheet glides to its new resting height and the map glides with it. | Our choice, forced by the test: both jumped in a single frame |
| Controls over the context are round and float in the top corners. | Common practice. Seen in 2 apps: E1, E2. The sample has none because it has no screen to go back to |
| The selected marker is kept clear of the sheet. | Our choice. Without it the selection sits underneath the sheet |
| The sheet's own material is the system's. No custom blur. | HIG, Materials: standard components pick up Liquid Glass; use it sparingly on custom ones |

## Common failures

- A resting height typed as a number. It is right at one text size on one phone.
- The main action inside the scrolling content, so it is below the fold when the sheet rests.
- Two equal-width buttons, so the longer label wraps to two lines.
- A main button in a bright hue that fights the map for attention.
- Status shown by a coloured dot alone.
- A sentence under the badge, or after an action, that repeats what the badge now says.
- A sheet that covers the whole context at rest.
- A sheet with no grabber, so nothing says it can be pulled up.
- A custom frosted panel in place of a system sheet. It loses the grabber's accessibility and the standard heights.
- An empty or failed state that replaces the map with a blank screen.

## Verify

1. Default text size: the resting sheet shows name, facts, the status badge and both actions, each on one line, and no partial line at its lower edge.
2. Largest accessibility text size, small iPhone: the map is still visible and the main action is fully on screen.
3. Dark appearance: text on the sheet is readable over the map, and the main button has turned light with dark text.
4. Select a different marker: the sheet changes and the marker is not under the sheet.
5. Loading, empty and failed states keep the map in view.
6. Greyscale screenshot: a working point and a broken one still differ on the map and in the badge.

## States

| State | What the sample shows |
| --- | --- |
| Loading | A one-line sheet saying what is being looked for. The map is usable |
| Empty | What was not found, as a title, with one pinned action |
| Failed | What went wrong and its cause, with a pinned retry |
| Success | The badge changes to "Problem reported"; the marker turns grey with a different glyph; the report button is disabled |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Uber, confirm a ride (`uber/02`) | A map with the route in the upper two fifths; a sheet titled "Confirm details"; one option with price and time; a full-width button pinned at the bottom with a small square button beside it; a round back button over the map | [App Store](https://apps.apple.com/us/app/uber-rides-eats-hotels/id368677368) |
| E2 | AllTrails, a trail (`alltrails/03`) | A photograph in the upper half with round buttons over it; a sheet with the trail name, a one-line summary, four figures in a two-by-two grid; two pill buttons pinned at the bottom, the first filled | [App Store](https://apps.apple.com/us/app/alltrails-hike-bike-run/id405075943) |
| E3 | Flighty, a flight (`flighty/04`) | A weather map in the upper half; a sheet with a title, two lines of facts, a picture, a red status badge with an icon and the words "Running late", and a sentence giving the reason | [App Store](https://apps.apple.com/us/app/flighty-live-flight-tracker/id1358823008) |

Recorded only, each seen in one app: Flighty states the reason for a status in a full sentence under the badge
(E3). AllTrails sets figures large with small units in a grid (E2).

## Not shown by the evidence

- How many heights each sheet has, or how it moves between them.
- Whether the context can be panned while the sheet is up.
- Any loading, empty or failed state.

## Found by testing the sample

These came from screenshots of our own build, not from the references.

- Going between the list and one point changed the sheet's height in a single frame, and the map
  jumped to its new centre with it. SwiftUI applies a new set of detents at once, whatever animation
  surrounds the change. Handing the sheet a new height every frame, from an animatable modifier,
  makes it glide, and the same is done for the room the map keeps clear.
- Keeping the map's room fixed, so that it never moved, was tried first. With the list up, the
  sheet then covered the map's own attribution, so the room follows the sheet.
- On a 375-point phone the selected pin's balloon reaches the status bar and touches the clock.
  Seen in the first small-phone screenshot at the default text size; not fixed.
- `ContentUnavailableView` and other fixed blocks do not scroll. On a small phone at the largest text size, content below the fold cannot be reached unless it is in a scroll view.
- Two buttons given equal width wrap the longer label. Let the main action take the spare width and the second keep its own.
- At accessibility sizes the second action no longer fits beside the first. The sample moves it into the pulled-up sheet.
- With the system's blue buttons and plain status line, the sheet read as a stock app. The look in `LayerLook.swift` is the answer to that.
- Custom capsule buttons are wider than the system's. With 20 pt of padding inside each, "Directions" and "Report a problem" stopped fitting side by side on a 402 pt phone and stacked. At 16 pt they fit again.
- The resting sheet is glass in iOS 26, so the map shows through it. The sheet's text colours were checked on it in both appearances by eye, not by measurement.

## Make it yours

The context can be a map, a photograph, a floor plan or a camera view. Replace the facts, the status
wording and the action. Pick the pin colour in `LayerLook.swift` for your subject and keep the buttons
in ink. Do not copy a reference app's sheet title style, badge or button shapes.
