---
id: picture-wall
name: A wall of pictures with one leading
direction: 14 Media-Led Experience
also_fits: 11 Layered Surfaces, 02 Editorial Reading
kind: browse
code: PictureWall.swift
look: ../MediaLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator in light, dark and the largest text size. Not used by hand. The pictures are drawings made for the sample, not photographs.
---

# A wall of pictures with one leading

People choose by looking. One picture is large and carries its title and the one action. Rows of
smaller pictures follow. The screen itself is black or white, so the pictures are the only colour.

## Use it when

- People pick by appearance: prints, films, classes, recipes, places to stay.
- Each item has a picture that does most of the telling.
- There is one obvious thing to do with an item: reserve, play, open.

## Use something else when

- Items have no pictures, or the pictures are all alike. Use a list.
- People choose by comparing figures. Use a table of facts.
- Place matters more than appearance. Put the items on a map.
- The pictures are small decorations beside text. Then the text leads, and this is the wrong direction.

## Do

| Decision | Basis |
| --- | --- |
| A picture leads: it takes the top of the screen. | Rule. Seen in 4 apps: E1, E2, E3, E4 |
| The title sits on the picture, in white, over a darkened lower part. | Rule. Seen in 3 apps: E1, E3, E4. E2 keeps its text under the picture |
| The darkening reaches 66% black behind every word. | Our choice, from a measurement: white text is then 7.2:1 even on a white picture. No reference image shows text on a pale picture |
| Text on a picture is solid white. It is never dimmed. | Our choice, as in the colour-block direction |
| One fact rides on the picture's corner as a badge. | Rule. A small corner badge in 3 apps: E2 (length), E1 ("Going"), E4 (a time) |
| Under a small picture: a title, then one line of facts. | Rule. A line of facts with the title in 3 apps: E2, E3, E1 |
| The ground is white in light and black in dark. | Rule. Neutral chrome with colour from the pictures in 3 apps: E2, E1, E4. E3 adds a brand blue |
| Controls are black or white. | Common practice. The main action as a black or white bar or pill in 2 apps: E2 (black), E1 (white) |
| The action on a picture is a white pill. Its opposite is a white outline. | Our choice |
| After the action, the badge says it is yours and until when. No message. | Guard rule G1 |
| Smaller pictures follow in a row to swipe. | Common practice. A row of picture cards under a heading in 2 apps: E2, E3 |
| Choosing a small picture makes it the large one. | Our choice. A real app might open a detail screen instead |
| Filters are chips above the pictures. The chosen one is filled, and scrolled into view. | Common practice for filter pills: E2. Scrolling the chosen one into view is our choice, forced by the test |
| Pictures share one corner radius and one gap. | Our choice. Rounded corners and small gaps in 2 apps: E1, E4 |
| While loading, placeholders hold the pictures' places at their real sizes. | Our choice. No reference image shows loading |
| Offline, the saved pictures stay and the action is removed. The notice says why. | Our choice. A dimmed button on a picture would break the rule above |
| The screen's title sits in the bar's own row, large and leading. | Our choice, forced by the test: the usual large title left an empty row above it |
| At the accessibility text sizes the row becomes a list, picture beside words. | Our choice, forced by the test |
| The lead picture grows taller when the badge and the words need the room. | Our choice, forced by the test: a wrapped badge covered the title |

## Common failures

- A tinted ground, or a brand colour on every button, competing with the pictures.
- White text straight on a picture, readable on a dark one and lost on a pale one.
- Text on a picture dimmed with opacity.
- Three badges on one picture.
- A caption under the picture repeating its title.
- Pictures in several corner radii and gaps.
- A spinner where the wall will be, so everything jumps when it loads.
- A toast after the action, when the picture could say it.
- A failed picture shown as a broken-image icon with no title.
- Filters in a row that hides the chosen one off screen.

## Verify

1. Squint: the pictures are the only colour. The chosen chip and the buttons are black or white.
2. Put a white picture in the lead. The title and the facts are still readable. Measured here: 7.2:1.
3. Greyscale screenshot: the reserved picture is still told apart, by the tick and the words in its badge.
4. Dark appearance: the pictures are unchanged and the ground is black.
5. Reserve, then look for a message. There is none; the badge and the button have changed.
6. Offline: pictures and titles remain, the action is gone, the notice says what is stale and what needs a connection.
7. Loading: placeholders match the loaded layout, and nothing moves when pictures arrive.
8. Largest accessibility text size on a small iPhone: the badge does not touch the title, nothing is truncated, the action is under the words, and the row has become a list.
9. Scroll at that size: nothing shows through the bar's title.
10. Name what each line of text says that the picture does not (guard rule G1).

Steps 2, 5 and 7 were checked by measurement and from screenshots of fixed states, not by using the screen.

## States

| State | What the sample shows |
| --- | --- |
| Loading | Placeholders for the chips, the lead picture, the heading and the row |
| Empty | A filter with no matches: the chosen chip, "No black and white prints right now", and "Show all prints" |
| Failed, with a saved catalogue | A notice above the chips: offline, this morning's catalogue, reserving needs a connection. Pictures stay; no Reserve |
| Failed, nothing to show | A full-screen message with the cause and a retry |
| Success | The badge reads "Reserved · collect by Friday" with a tick; the button is an outlined Cancel |

## Evidence

Promotional images from the App Store and a design gallery, not captures of a running app. App
versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Apple Invites (`apple-invites/02`, `/03`, `/05`) | One large picture card with a "Going" chip at its corner and the title in white over its lower part; a three-way reply control, the chosen one white; a three-column photo grid with small gaps and rounded corners; a dark ground tinted by the picture | [App Store](https://apps.apple.com/us/app/apple-invites/id6472498645) |
| E2 | Alo Wellness Club (`alo-wellness-club/03`, `/04`, `/06`, `/07`) | Outlined filter pills; rows of video stills with the length in a corner badge; under each a title, instructors and level; a black "PLAY" bar; white ground, black type | [Godly gallery](https://godly.design/app/alo-wellness-club/) |
| E3 | Aaptiv (`aaptiv/02`, `/03`, `/04`, `/05`) | A photo at the top with the title over it; photo tiles with a white capital title over the darkened picture; "Programs for you" with "See all"; "Beginner", "6 weeks" under a title | [Godly gallery](https://godly.design/app/aaptiv/) |
| E4 | 1 Second Everyday (`1-second-everyday/02`, `/04`) | A grid of day tiles, each a photo with the weekday and a large date in white; a photo card with a time in a pill | [Godly gallery](https://godly.design/app/1-second-everyday/) |

Recorded only, each seen in one app: Apple Invites tints its ground with the picture's own colours (E1);
Alo sets every heading in capitals and uses square corners (E2); Aaptiv washes its photos in a brand
blue (E3); 1 Second Everyday puts a large date on every tile (E4). These are brand decisions and are
not copied.

## Not shown by the evidence

- Pictures still loading, or one that failed to load.
- An empty result, or the screen offline.
- How text stays readable over a pale picture.
- How any of them behave at large text sizes.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- A badge laid over the picture's corner collides with the title as soon as large text wraps it. The
  badge has to be in the same flow as the words, with the picture sized by both.
- A stack that lays children on top of each other gave the words less height than they needed, and
  the facts were cut with an ellipsis. One column with a minimum height did not.
- A capsule around wrapped text becomes a blob. A fixed corner radius looks like a pill on one line
  and like a box on three.
- A row of placeholders wider than the screen widened the whole page and pushed it off the leading
  edge. The row is drawn in an overlay so that it cannot.
- An unselected chip's outline is faint (1.3:1 on the ground). Its label, at 18.7:1, is what marks it.
- The six prints are drawn in code. Real photographs vary far more, which is the reason for testing
  the scrim against white.

## Make it yours

Replace the prints with your media, and the one fact on the badge with the one that decides a choice
in your product. Keep the three rules that are the direction: the ground has no colour, text on a
picture sits on the scrim in solid white, and controls are black or white. If pictures come from a
network, give each a placeholder of the right shape and a title that shows even when the picture
cannot.
