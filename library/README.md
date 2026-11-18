# Pattern library

Original SwiftUI implementations of screen patterns seen across the reference apps. Each entry uses an
invented product and its own content; none reproduces a reference app's layout, branding or assets.

Status: fifteen entries: one screen in each of the fourteen directions, and one flow, in direction 03. Each is built and screenshotted in light and dark. All fifteen have had their main controls pressed by a UI test. That found one entry that froze when scrolled (02) and two with a layout that jumped (11, 13); all three are fixed, and each entry's `pattern.md` says what was wrong. The categories below are provisional until the full screenshot analysis is done.

## How entries are filed

`patterns/<direction>/<kind>--<id>/`, holding `pattern.md` and one Swift file.

Each direction folder also holds one look file, such as `01-quiet-native/QuietLook.swift`: the colours,
type roles, sizes, button styles and small parts that every entry in that direction shares. Three
directions also hold a kit file, a parts screen and `parts.md`: see "Parts of a look". A direction is told from the
others by its look file. The first three entries, built from system defaults alone, could not be told
apart.

**Direction** is the visual direction the entry belongs to first (the fourteen in the research
document). An entry that also suits another direction says so in `also_fits`.

**Kind** is the job of the screen:

| Kind | The screen is for |
| --- | --- |
| `list` | scanning a collection and acting on items |
| `detail` | one item and everything about it |
| `status` | learning a value or a state at a glance |
| `timeline` | things placed in time |
| `map` | choosing by position, with detail layered over it |
| `capture` | getting something in quickly |
| `editor` | writing or changing content |
| `reader` | reading long content |
| `session` | an activity in progress (a run, a timer, playback) |
| `canvas` | making something visual, with tools around a work area |
| `browse` | discovering media or collections |
| `flow` | one action carried from a list to a sheet and back, with every answer it can get |

## Entries

| Entry | Direction | Kind |
| --- | --- | --- |
| [Sectioned list without cards](patterns/01-quiet-native/list--sectioned-list/pattern.md) | 01 Quiet Native Minimalism | list |
| [A long read with quiet tools](patterns/02-editorial-reading/reader--long-read/pattern.md) | 02 Editorial Reading | reader |
| [One thing, in figures](patterns/03-data-precision/detail--service-status/pattern.md) | 03 Data Precision | detail |
| [One action, asked and answered](patterns/03-data-precision/flow--refill-request/pattern.md) | 03 Data Precision | flow |
| [A check-in without a score](patterns/04-soft-wellness/capture--gentle-checkin/pattern.md) | 04 Soft Wellness | capture |
| [A one-tap log that stacks up](patterns/05-playful-tactile/capture--one-tap-log/pattern.md) | 05 Playful & Tactile | capture |
| [A take in progress](patterns/06-dark-professional/session--audio-take/pattern.md) | 06 Dark Professional | session |
| [A scene that is the reading](patterns/07-immersive-environment/status--tide-scene/pattern.md) | 07 Immersive Environment | status |
| [A wait with a picture that shows it](patterns/08-warm-organic/session--proof-timer/pattern.md) | 08 Warm Organic | session |
| [One hero metric, explained](patterns/09-metric-hero/status--explained-metric/pattern.md) | 09 Metric Hero | status |
| [A day in colour blocks](patterns/10-color-blocked/timeline--day-blocks/pattern.md) | 10 Color-Blocked Structure | timeline |
| [Context with a resizable detail sheet](patterns/11-layered-surfaces/map--context-sheet/pattern.md) | 11 Layered Surfaces | map |
| [A plain draft with tools on the keyboard](patterns/12-focused-utility/editor--plain-draft/pattern.md) | 12 Focused Utility | editor |
| [A canvas with the tools beneath it](patterns/13-canvas-first/canvas--flyer-canvas/pattern.md) | 13 Canvas-First Creation | canvas |
| [A wall of pictures with one leading](patterns/14-media-led/browse--picture-wall/pattern.md) | 14 Media-Led Experience | browse |

## What every entry contains

- When to use it and when not to.
- A pointer to its direction's look file.
- A picture of the loaded sample in light and in dark: `sample-light.png` and `sample-dark.png`,
  simulator screenshots at half size. The map entry has none, because its screenshot shows Apple's
  map tiles; build the host to see it.
- Each design decision with its basis, in one of the five grades below.
- Common failures and how to verify against them.
- Loading, empty, failed and success states, not only the loaded screen.
- The evidence, by source link. Reference screenshots are not included.
- No one else's pictures. Where an entry needs artwork, such as the flyer and the prints, it is drawn
  in code for the sample.
- What the evidence does not show.

## How strong a decision is

Every row in an entry's "Do" table starts with one of these.

| Grade | Means | How to treat it |
| --- | --- | --- |
| Rule | Visible in three or more reference apps | Follow it unless the entry's "Use something else when" applies |
| Common practice | Visible in two reference apps | A sound default. Depart from it when the product gives a reason |
| Recorded only | Visible in one reference app | Noted so it is not lost. Usually a brand decision; do not copy it |
| HIG | Stated in Apple's Human Interface Guidelines, with the page named | Follow it |
| Our choice | Not shown by the references. Made for this library, often forced by a test | Judge it on the reason given beside it |

Two screens of one app count as one app. The references are promotional images, so a grade says what is
visible in them, never how the app behaves in use.

## Running an entry

Needs Xcode 26 and [XcodeGen](https://github.com/yonaskolb/XcodeGen). These commands write a project
and a build folder into `host/`. If the skill is installed where it is shared or cannot be written
to, copy `library/` somewhere else first.

```bash
cd host && xcodegen generate
```

```bash
xcodebuild -project PatternHost.xcodeproj -scheme PatternHost -destination 'generic/platform=iOS Simulator' -derivedDataPath build build
```

```bash
./shoot.sh "iPhone 17" build/Build/Products/Debug-iphonesimulator/PatternHost.app shots light large
```

`shoot.sh` screenshots every entry in every state. Run it again with `dark`, and on a small phone.
The library is judged at the default text size, `large`. The first twelve entries were also shot at
`accessibility-extra-extra-extra-large`; newer ones are not.

Some entries have a second loaded view. Name it after the state, and limit the run to that entry:

```bash
PATTERNS="explained-metric" ./shoot.sh "iPhone 17" build/Build/Products/Debug-iphonesimulator/PatternHost.app shots light large loaded:fresh loaded:poor
```

`explained-metric` has `fresh` and `poor`; `context-sheet` has `nearby`; `long-read` has `reading`,
which opens the essay part-way through with the tools hidden; `service-status` has `down`;
`audio-take` has `recording`; `gentle-checkin` has `picked`; `flyer-canvas` has `selected`;
`proof-timer` has `paused`. `refill-request` has six loaded views to look at (`sheet`, `asking`, `refused`,
`unsent`, `refused-list`, `calm`), `sheet` again under `success`, and four that only decide how its
service answers when you press through it (`says-no`, `offline`, `slow`, `slow-offline`).

Some screens run past the first screenful. `SCROLL=end` opens each screen scrolled to the end of its
content and adds `-end` to the file names:

```bash
SCROLL=end PATTERNS="service-status" ./shoot.sh "iPhone SE (3rd generation)" build/Build/Products/Debug-iphonesimulator/PatternHost.app shots light large loaded
```

When you pass several states from a variable in zsh, write them out or use an array. zsh does not
split an unquoted variable into words, so the script would receive one long state name.

## Seeing motion

A screenshot cannot show motion. `host/UITests/EffectTour.swift` presses the buttons of an entry while
the simulator is recorded:

```bash
xcodebuild build-for-testing -project PatternHost.xcodeproj -scheme PatternHost -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build
```

```bash
xcrun simctl io booted recordVideo --codec=h264 --force motion.mp4
```

```bash
xcodebuild test-without-building -project PatternHost.xcodeproj -scheme PatternHost -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build -only-testing:PatternHostUITests/EffectTour/testOneTapLog
```

Start the recording in one terminal, run the test in another, then stop the recording with Control-C.
From a script, start the recorder in the background, run the test, then send the recorder
`kill -INT`, which is what Control-C sends. A recorder stopped any other way can leave the simulator
refusing to record until it is shut down and booted again.

`host/UITests/PressThrough.swift` does the same for the main controls of the other entries, one test an
entry, and prints a line for every step. A recording from `simctl` has a variable frame rate: pass it
through ffmpeg's `fps=30` filter before cutting frames by time, or a still period returns a later frame.
For your own app, `scripts/record.sh` and the `frames` tool do the recording and the cutting, with
no ffmpeg. How to read the result is in `SKILL.md`, step 7, "Reading a recording".

## Swift language mode

The host builds in Swift 5 language mode, with the main actor as the default isolation. In Swift 6
language mode the one-tap log stopped on its first key press: while the stack animated, SwiftUI called
a `ForEach` content closure away from the main thread, and the runtime check on that closure ended the
app. If your project uses Swift 6 mode, give such a closure `@Sendable` and let it only hand values to
a row view whose `init` is `nonisolated`, as `StackTray` and `StackRow` do in `OneTapLog.swift`. Only
that one `ForEach` in the library has been changed this way. This is what this host needed. It is
not advice for a new app, which may use either mode.

## Shared code

`patterns/Shared.swift` holds what every entry uses: the `Phase` states, `ScrollsIfNeeded` for
unavailable views that must survive large text, and `Color(light:dark:)`, which every look file uses
so that both appearances of a colour are chosen together. `UIColor(light:dark:)` is the same thing
for the one entry whose text view is UIKit.

A failure notice is not shared. Each direction draws its own in its look file, because a filled box is
right in one direction and wrong in another.

## Pairs

`pairs/` is a second small app: one bad and one good screen for each guard rule from G3 to G11, the
same invented product built twice. It builds like the host, from its own `project.yml`. Open one side
with `-pair g03 -side bad`. Pictures of every pair are in `../references/pairs/`. Both sides of a pair
are drawn in one look and differ only in the failure, so no colour or style in them is the thing
to avoid. Its UI test presses every control on the good sides and the working ones on the bad
sides. Each bad side breaks one rule on purpose; do not take that from it.

## Parts of a look

An entry shows one screen, and a look made for one screen has only that screen's parts. All fourteen looks
now have the rest: what a second and a third screen in that look are built from.

| Look | Notes | Code | Host id |
| --- | --- | --- | --- |
| 01 Quiet Native Minimalism | [parts.md](patterns/01-quiet-native/parts.md) | `QuietLook.swift`, `QuietKit.swift`, `QuietParts.swift` | `quiet-parts` |
| 03 Data Precision | [parts.md](patterns/03-data-precision/parts.md) | `DataLook.swift`, `DataKit.swift`, `DataParts.swift` | `data-parts` |
| 05 Playful & Tactile | [parts.md](patterns/05-playful-tactile/parts.md) | `TactileLook.swift`, `TactileKit.swift`, `TactileParts.swift` | `tactile-parts` |
| 09 Metric Hero | [parts.md](patterns/09-metric-hero/parts.md) | `MetricLook.swift`, `MetricKit.swift`, `MetricParts.swift` | `metric-parts` |
| 10 Color-Blocked Structure | [parts.md](patterns/10-color-blocked/parts.md) | `BlockLook.swift`, `BlockKit.swift`, `BlockParts.swift` | `block-parts` |
| 14 Media-Led Experience | [parts.md](patterns/14-media-led/parts.md) | `MediaLook.swift`, `MediaKit.swift`, `MediaParts.swift` | `media-parts` |
| 02 Editorial Reading | [parts.md](patterns/02-editorial-reading/parts.md) | `ReadingLook.swift`, `ReadingKit.swift`, `ReadingParts.swift` | `reading-parts` |
| 04 Soft Wellness | [parts.md](patterns/04-soft-wellness/parts.md) | `SoftLook.swift`, `SoftKit.swift`, `SoftParts.swift` | `soft-parts` |
| 06 Dark Professional | [parts.md](patterns/06-dark-professional/parts.md) | `ProLook.swift`, `ProKit.swift`, `ProParts.swift` | `pro-parts` |
| 07 Immersive Environment | [parts.md](patterns/07-immersive-environment/parts.md) | `SceneLook.swift`, `SceneKit.swift`, `SceneParts.swift` | `scene-parts` |
| 08 Warm Organic | [parts.md](patterns/08-warm-organic/parts.md) | `WarmLook.swift`, `WarmKit.swift`, `WarmParts.swift` | `warm-parts` |
| 11 Layered Surfaces | [parts.md](patterns/11-layered-surfaces/parts.md) | `LayerLook.swift`, `LayerKit.swift`, `LayerParts.swift` | `layer-parts` |
| 12 Focused Utility | [parts.md](patterns/12-focused-utility/parts.md) | `FocusLook.swift`, `FocusKit.swift`, `FocusParts.swift` | `focus-parts` |
| 13 Canvas-First Creation | [parts.md](patterns/13-canvas-first/parts.md) | `CanvasLook.swift`, `CanvasKit.swift`, `CanvasParts.swift` | `canvas-parts` |

Each kit has the look's own content parts (what only this look has, how it sets a figure, what a
row starts and ends with, how it frames a picture, what it draws when there is nothing to show)
and its controls: two kinds of button, a choice, a text field, a notice, loading.

The parts are shown **in use**: a few short screens of one invented product, each built only from
the kit, with one thing leading it. Nothing on a screen names a part or a state. A picture that is
waiting looks like one; a button that is off looks off; `parts.md` says which part is which and
where it is in code. The first version set the parts out as a catalogue with a label on each, and
was rebuilt: see guard rules G1 and G12. Every control on these screens answers, and the answer is
on the screen: a row that appears, a sentence that changes.

The variant names the screen to open:

```bash
PATTERNS="quiet-parts" ./shoot.sh "iPhone 17" build/Build/Products/Debug-iphonesimulator/PatternHost.app shots light large loaded:home loaded:week loaded:flat loaded:plants loaded:new
```

| Host id | Screens | The same screens in another state |
| --- | --- | --- |
| `quiet-parts` | `home` (one day), `week`, `flat`, `plants`, `new` (a sheet) | `empty`, `loading`, `offline`, `plants-waiting`, `plants-failed`, `new-error`, `new-busy` |
| `data-parts` | `services`, `service`, `record`, `check`, `new` (a sheet) | `empty`, `loading`, `offline`, `service-slow`, `service-down`, `check-waiting`, `check-failed`, `check-busy`, `check-done`, `new-error`, `new-busy` |
| `tactile-parts` | `today`, `week`, `goal`, `goal-daily`, `studio`, `instrument` (a sheet) | `empty`, `loading`, `offline`, `today-busy`, `studio-waiting`, `studio-failed`, `instrument-error` |
| `metric-parts` | `home`, `room`, `household`, `alert` (a sheet) | `empty`, `loading`, `offline`, `home-waiting`, `home-failed`, `alert-error`, `alert-busy` |
| `block-parts` | `week`, `dogs`, `team`, `new` (a sheet) | `empty`, `loading`, `offline`, `dogs-waiting`, `dogs-failed`, `new-error`, `new-busy` |
| `media-parts` | `shelf`, `print`, `members`, `request` (a sheet) | `empty`, `loading`, `offline`, `shelf-waiting`, `shelf-failed`, `print-waiting`, `print-failed`, `print-busy`, `print-done`, `request-error`, `request-busy` |

The other eight, with every variant:

| Host id | Variants |
| --- | --- |
| `reading-parts` | `issue`, `issue-waiting`, `issue-failed`, `empty`, `loading`, `offline`, `masthead`, `letter`, `letter-error`, `letter-busy` |
| `soft-parts` | `today`, `today-waiting`, `today-failed`, `empty`, `loading`, `offline`, `checkin`, `moment`, `moment-waiting`, `moment-failed`, `circle`, `invite`, `invite-error`, `invite-busy` |
| `pro-parts` | `takes`, `empty`, `loading`, `offline`, `export`, `export-error`, `export-busy`, `session`, `session-waiting`, `session-failed` |
| `scene-parts` | `coves`, `empty`, `loading`, `offline`, `cove`, `cove-waiting`, `cove-failed`, `alert`, `alert-error`, `alert-busy`, `crew` |
| `warm-parts` | `counter`, `counter-waiting`, `counter-failed`, `empty`, `loading`, `offline`, `rise`, `rise-error`, `rise-busy`, `recipe`, `recipe-waiting`, `recipe-failed`, `recipe-plain`, `kitchen` |
| `layer-parts` | `map`, `empty`, `loading`, `offline`, `add`, `add-error`, `add-busy`, `point`, `point-waiting`, `point-failed`, `point-plain`, `keepers` |
| `focus-parts` | `drafts`, `empty`, `loading`, `offline`, `new`, `new-error`, `new-busy`, `shared`, `shared-waiting`, `shared-failed` |
| `canvas-parts` | `flyers`, `flyers-waiting`, `flyers-failed`, `empty`, `loading`, `offline`, `new`, `new-error`, `new-busy`, `flyer`, `flyer-ordered`, `people` |

`patterns/SampleMarks.swift` holds the drawn logos and faces they all share; every company in it
is invented.

## Pictures

`pictures/` holds nine free pictures for samples: a plant, a succulent, a bicycle, dough, a cello and
four woodblock prints. All are CC0, and `pictures/CREDITS.md` says where each came from and how its
licence was checked. The host app carries them as resources, and `Image.sample(_:)` in `patterns/Shared.swift` loads one by name. `../references/pictures.md` has the rule for
using them and for adding more.

## Rules that apply to every entry

[Guard rules](../references/guard-rules.md) lists what to stop doing. G1 applies to every screen here:
no caption or sentence of explanation for something the screen already says. G3 to G11 were written
after the entries. The entries have not been checked against them one by one; G5's own search finds
four controls with empty actions in the 06 and 02 entries.
