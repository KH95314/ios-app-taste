---
name: ios-app-taste
description: >-
  Design, build and review iPhone app screens in SwiftUI that look made for their product and hold
  up in every state, instead of looking like a template. Provides a method for choosing one of
  fourteen visual directions from what people come to the app to do, a library of original SwiftUI
  screens with the evidence behind each decision, guard rules, and a check of the built app in the
  simulator. Use this whenever the user wants an iPhone or iOS app screen or flow designed, built,
  redesigned or reviewed, asks what an app should look like or which design direction suits it, is
  doing SwiftUI interface work, or complains that an app looks like every other app or like it was
  generated, even if they do not name the skill. Not for websites, Android, iPad, Mac or watchOS
  layouts.
---

# iOS App Taste

Build the iPhone screen a careful product team would ship. It shows what the product is for. It has
one look, chosen for this product. Every state of it was designed. And it was checked running in an
app, not judged from code or from one screenshot.

| Need | Open |
| --- | --- |
| Choose a visual direction | `references/directions.md` |
| See a direction built, with the reason for each decision | the entry's `pattern.md` and its look file, listed in `library/README.md` |
| Build a second screen in any look | that look's `parts.md`, its kit file, and the screens that show the parts in use: `library/README.md`, "Parts of a look" |
| Know what to stop doing | `references/guard-rules.md`: eleven rules, each with when to run it; G3 to G11 with a bad and a good screen |
| Show a photograph, a person, a logo or an icon | `references/pictures.md`, and nine free pictures in `library/pictures/` with where each came from |
| Model a screen's states; keep both appearances of a colour together | `library/patterns/Shared.swift` |
| Open one screen in one state from the command line | `library/host/App/HostApp.swift` |
| Press controls from a UI test | `library/host/UITests/PressThrough.swift` |
| Check the built app: contrast, screenshots, sheets of them, recordings | `scripts/`, set out in step 7 |

Building the library's host writes a project and a build folder beside it. If the skill folder is
shared or cannot be written to, copy `library/` somewhere else first.

## Rules that hold

When anything else in this skill pulls against one of these, these hold. Each is our choice, with its
reason beside it.

1. **The main job decides the look.** Not the app's category, and not a look you happen to like. A
   look laid over a job it does not suit is the commonest way a screen ends up generic.
2. **One look for the whole app, written down once.** Every screen takes its colours, type and
   shapes from one look file. One thing has one name, one icon and one place on every screen.
   Screens that disagree make people guess again on each one.
3. **Real content.** Real names, real lengths, figures with units that agree with each other. A
   layout that only works with "Lorem ipsum" or three tidy sample rows has not been designed.
4. **Every control on the screen works.** A control that does nothing teaches people not to trust
   the others. If a feature is not built, leave its control out and say so in the report.
5. **A screen has states, and so does an action.** A screen: loaded, loading, empty, failed. An
   action the person sends, such as renew, save, send or pay: ready, in progress, done, refused,
   could not be sent. Design every one that can happen. People meet the empty one first and the
   failed one at the worst moment. "Refused" is not "could not be sent": the service answered and
   the answer was no, so the screen has to say why. When a state cannot happen, write "does not
   apply" and the reason; do not invent one to fill the list. The library's entries call the screen
   after a finished action "success".
6. **No caption for what the screen already says.** Guard rule G1, in `references/guard-rules.md`.
   A state's own word beside its icon, and the head over a column, are labels, not captions. The
   same file holds ten more guard rules, G3 to G12. Its first table says when to run each.
7. **A screenshot proves what is visible and nothing more.** Never report a flow or an interaction
   as good unless you ran it. In this library, screenshots alone missed a crash, a freeze and
   layouts that jumped; pressing the controls found them.
8. **Borrow decisions, not screens.** Never copy the layout, palette, pictures or wording of a
   reference app or of a sample in this library. The samples show a decision and its reason.
9. **An unusual style is not a fault.** Judge a choice by whether it gets in the person's way. When
   you set aside a decision graded "Rule", say why.

## The steps

For a new screen or flow, do all eight steps. To restyle an existing app, first write down the look
it has now (its colour roles, type and shapes), then start at step 1. To review without building, do
steps 1 and 2, then go to "Reviewing".

### 1. Read the brief and write five lines

Write these before any design:

- **Main job:** "People open this to ___." A verb and an object. When the brief names two jobs,
  take the job of the screen people open most.
- **Then:** the action that follows, if there is one. "Then they ___." A screen that is only looked
  at has none; say so.
- **Who and when:** who uses it, and in what moment. In a hurry, with one hand, in the dark, at a desk.
- **Real material:** the names, figures, pictures and text that exist, and what is missing.
- **What can happen:** to the screen: nothing there yet; waiting; it could not be loaded, with and
  without an older copy to show. To the action: it worked; the answer was no, and why; it could not
  be sent.

If the brief does not give the main job, ask once. If no one can answer, state your reading as an
assumption and carry on. For a real product, do not invent facts about it. For an invented one,
invent content that is whole and agrees with itself.

### 2. Choose the direction

Read `references/directions.md` and follow its method. You leave this step with two more lines:

```
Main job:    People open this to see how much of this month's data allowance is left.
Then:        sometimes they buy a top-up.
Who and when: one person, a glance, often while deciding whether to start a download.
Real material: allowance 20 GB, used 14.2 GB, 9 days left, daily use for the month. No pictures.
What can happen: no plan linked yet; loading; the carrier cannot be reached, with yesterday's
             figure still to show. The top-up goes through; the card is declined; it cannot be sent.
Direction:   09 Metric Hero. One value, and it needs a verdict: plenty, enough, low.
Runner-up:   03 Data Precision. Lost because the other figures only support the one.
```

### 3. Read the entry

Open the direction's look file and read the whole of its entry's `pattern.md`. The sections do
different work:

- **"Use it when" and "Use something else when"** are about the entry's screen, not about the
  direction. When they rule the screen out, the look can still be right on another layout:
  `references/directions.md`, "When the screen you need is not the entry's kind".
- **"Do"** holds the decisions. Each row starts with a grade; `library/README.md` says how to treat
  each one. In short: follow a **Rule** unless "Use something else when" applies; treat **Common
  practice** as a default; do not copy what is **Recorded only**; judge **Our choice** by its reason.
- **"States"** shows how the sample handles each state, such as a failure with and without an older
  value to show.
- **"Common failures" and "Verify"** are checks. You run them in step 7.
- **"Make it yours"** says what belongs to the sample.

The entry folder also holds a picture of the sample in light and in dark.

A grade counts the reference apps that showed a thing. It does not say those apps are like yours;
the entry's "Evidence" table names them. The reference images are not in the skill, so the count is
taken on trust.

**What is the direction, and what is the sample.** The graded rows and the roles in the look file
are the direction: what leads the screen, what colour is allowed to mean, where a state is marked.
Follow them, and expect your screen to share that skeleton with the sample. The hues, the type
design where the direction does not name one, the corner radius, the form of a row, the product,
the content and the wording are the sample's. Those have to be yours. A system symbol used for the
same meaning is shared vocabulary, not a copy.

### 4. Write the look down first

Write one look file for the app before any screen, modelled on the direction's (for example
`library/patterns/09-metric-hero/MetricLook.swift`). It holds:

- **Colour roles:** the ground, ink, quiet ink, the accent and what it means, and any state colours.
  Each has a light and a dark value chosen together (`Color(light:dark:)` in
  `library/patterns/Shared.swift`). The hues come from this product, never from the sample.
- **Type:** system text styles, the design (default, serif, rounded or monospaced), and the weights
  that carry the order. If you use more than one design, write what each one stands for.
- **Shapes and density:** corner radius, spacing, row height, where lines and gaps separate things.
- **Shared parts:** the main button, a notice, a row. Anything two screens use.

The moment from step 1 comes before the direction's habits. A screen read in the dark beside a
telescope stays dim in both appearances, whatever the sample does.

Measure the contrast of every text and ground pair now, in both appearances: 4.5:1 for text up to
17 points, 3:1 for larger or bold text (HIG, Accessibility). When you are unsure whether a line
counts as large or bold, hold it to 4.5:1. Write each pair that occurs beside the colours, as a
comment in the look file, and run the script. It reads colours written as
`Color(light: 0x……, dark: 0x……)` and fails when a pair falls short in either appearance.

```swift
// contrast: ink on ground
// contrast: verdict on plate 3
```

```bash
python3 scripts/contrast.py Sources/MyLook.swift
```

If the person is there to ask, show them the look on one screen before you build the rest. A look
changed now costs one file. If they are not, carry on and put the look first in your report.

### 5. Plan the screens as one flow

One line for each screen: its job, its kind (the table in `library/README.md`), what leads it, how
people arrive and how they get back. Then its states, and the states of each action on it (rule 5).

One thing leads a screen. If a fact is on the screen twice, or every row carries a second figure
that nobody acts on, take one away. A screen where everything is as loud as the thing that needs
attention has no focus; the flow entry's first list was rebuilt for exactly this.

Layout says the rest without words: few left edges, few sizes of type, one gap inside a group and
a larger one between groups, one state at a time. Guard rule G12 has the list and the counts to
take from a screenshot. A screen that needs labels and notes to explain its own layout is laid
out wrong; the parts of three looks were rebuilt for exactly this.

Write a short list of the things in the app and the one word and icon each gets. Put the actions
and the age of the data on the list as well as the things: "Updated", "Checked" and "Refresh" for
one thing is the fault this list exists to stop. Use it on every screen.

For a screen that an action happens on, decide these before building and write each one down. The
flow entry, `library/patterns/03-data-precision/flow--refill-request/`, gives one answer to each
with its basis. It is one entry in one direction, so where yours differs, say so in the report:

- A pushed page or a sheet; for a sheet, what decides its height.
- Its ground: a colour from the look, not the system's default by accident.
- How a thing shows that it can be pressed, when the look has no hue for controls.
- Where it closes, and what the main button reads before, during and after the action. One button
  whose words change holds still; three buttons swapped for each other flicker.
- Where the answer appears. Keep room for a refusal's reason beside the thing it is about, so that
  nothing moves when it arrives.

Read the flow entry's `pattern.md` for the five states of an action, on the sheet and on the list
behind it, and for what pressing it found that screenshots had not. The 11 entry has a sheet that
changes height, and says what was found about that.

Use the system's navigation parts for the jobs they are made for. Before using one in an unusual
way, read its current page in Apple's Human Interface Guidelines and name that page in your report.
This skill does not yet carry its own rules for them. A kind the library does not have, such as a
conversation or a form of several steps, has no entry to take a layout from; say so in the report.

### 6. Build

- Every colour comes from the look file. A colour written inside a screen is a bug; the one
  exception is a drawn picture's own palette, kept with the picture. Type roles belong there too,
  and so do the sizes and gaps that repeat: margins, row padding, corner radii. A gap used once can
  stay where it is used. Fonts and gaps are the ones that slip in, so before step 7 run
  `python3 scripts/literals.py` on the screen files and read what it lists.
- Model a screen's states with one type, such as `Phase` in `library/patterns/Shared.swift`, and
  each action's states with a second small type. `Phase` describes loading a screen; it does not
  describe sending something. When a load fails and an older value exists, keep showing it and say
  what failed beside it.
- Put the real content in sample data, at real lengths, including one long name and one large figure.
- Wire every control. Give the app launch arguments that open one screen in one state, as
  `library/host/App/HostApp.swift` does, so each state can be opened without tapping. Add an
  argument for whatever a state needs in order to hold still: an open sheet, a step part-way
  through an action, a delay long enough to catch a passing state, the network off, and a fixed
  clock. The screenshots set the status bar to 9:41, and an app that reads the real clock will
  disagree with it.
- A colour the code cannot set, such as the launch screen's, repeats the look's ground in the asset
  catalogue. Otherwise the app opens on a white flash.
- Use the project's own Swift language mode. The library's host is built in Swift 5 mode for a
  reason given in `library/README.md`; that is the host's history, not a rule for your app.
- Before writing any caption, helper line, empty-state sentence or confirmation, or a word that
  names what a thing visibly is, run G1. Before adding a control, a gradient, a tab or a fixed
  size, run the guard rule its table names.

### 7. Check the built app

Build it and run it in the simulator. Press before you screenshot widely: a fault found by pressing
is fixed by a change that alters every screenshot of that screen. Do these in order, fix what you
find, and repeat what a fix touched.

1. **Build** with no warnings from your own code.
2. **On one phone, in one appearance:** open every state by its launch arguments and look at it.
   Then **press every main control once** while the screen is recorded, by hand or from a UI test.
   Watch for a stop, a freeze, a layout that jumps, two things showing on top of each other while
   one replaces the other, and a control that does nothing. "Reading a recording", below, says how.
3. **Screenshot every state of every screen** on a current iPhone in light and in dark, and on the
   smallest iPhone the app supports in one appearance. For iOS 26 that is 375 points wide.
   `scripts/shoot.sh` takes a file of state names and their launch arguments.
4. **Read every screenshot.** Several to a sheet, with the `sheet` tool, is enough to find cut text
   and things on top of each other. Open at full size the main screen in each appearance, and any
   you doubt. Look for cut text, overlap, content under the clock or the home indicator, two states
   that look the same, and a state with no control at all. A retry counts as a control. A next step
   that belongs to a feature you did not build is left out (rule 4), not faked.
5. **Check the words.** Go through the list from step 5 against every state: one thing, one word.
6. **Measure contrast** on the built screens. The `measure` tool lists the colours a screenshot
   really draws, each with its contrast against the ground, and names the ones that are the look's.
   A colour it cannot name was drawn by the system or by a blend: glass, or a list dimmed under a
   sheet. If text of yours sits on one, that pair counts too.
7. **Run the entry's "Verify", G1's "Verify" and G12's "Verify"** on every screen and state, and
   the "Verify" of each other guard rule once for the app. G12's is done on a screenshot at real
   size: what you see first, and counts of left edges, sizes of type and small quiet lines.
8. **The look test**, below.

**Reading a recording.** A recording has to become pictures before an agent can read it.

- `scripts/record.sh` records the simulator while one command runs. Give it one UI test at a time,
  so one recording holds one path.
- The `frames` tool cuts the recording into a strip of frames for each burst of change, with the
  time on each frame. `simctl` stores a frame only when the screen changes, so the strips hold
  everything that happened.
- Match strips to steps by what they show. A test prints a step's time when the step begins; the
  press lands a second or more later.
- `frames` flags a burst where most of a large change lands in one frame. That is what a jump
  looks like. It is also what the app starting and a press highlight look like, so read every
  flagged strip.
- Read the others too. Two labels showing on top of each other while one replaces the other is
  never flagged.
- A recorder can lose a stretch of frames, and the gap looks exactly like a jump. Record a second
  time before you call it a fault. (Seen once, in the first trial run of this skill.)

**The look test.** Put your main screen beside two others: the same content in plain system
defaults, and the library's sample for your direction. The plain version is a throwaway `List` of
about forty lines; do not ship it. The sample is pictured in its entry folder, as
`sample-light.png` and `sample-dark.png`.

- Beside the plain version, yours fails if it could be taken for what SwiftUI gives with no design.
- Beside the sample, a shared skeleton is expected: that is the direction (step 3). Yours fails if
  it shares what belongs to the sample: its hues in either appearance, its type, its wording, its
  product. "The same kind of screen for another product" passes.

If it fails, go back to step 4. You wrote the screen, which makes you a poor judge of it. Show both
pictures to the person if they are there.

**When to stop.** Each pass finds something, so decide what must be fixed. Fix these before you
report: a crash or a freeze; a control that does nothing; cut or overlapping text; content under
the clock or the home indicator; a layout that jumps under the finger; a text pair below its
contrast figure; two words for one thing. Fix or list the rest under "Known faults". Stop when a
pass finds none of the first kind.

```bash
tools=$(scripts/build-tools.sh)   # builds sheet, measure and frames outside the skill; prints where
python3 scripts/literals.py Sources/Screens     # styling written in place, to read before the check
scripts/shoot.sh "iPhone 17" build/Build/Products/Debug-iphonesimulator/App.app shots light states.txt iphone17
"$tools/sheet" sheets/list-light.png 1000 4 shots/list--*-light.png
"$tools/measure" shots/list--loaded--iphone17-dark.png --look Sources/MyLook.swift --dark
scripts/record.sh "$UDID" tour/renew.mp4 xcodebuild test-without-building … -only-testing:AppUITests/Tour/testRenew
"$tools/frames" tour/renew.mp4 tour/strips
```

Each script says at its top how to use it. They need Xcode and nothing else.

With no simulator to hand, do what can be done from the code and list the rest under "Not checked".
Do not describe how a screen looks or behaves from its source.

### 8. Report

Put the look first, then the lines from steps 1 and 2, then:

```
Plan:         <each screen: its job, kind, how people arrive and leave; the choices from step 5>
Built:        <each screen and its states; each action and its states; what does not apply>
Checked:      <devices, appearances and states screenshotted; controls pressed; pairs measured>
Not checked:  <everything else, plainly>
Departures:   <each graded row you set aside, with its grade, and why>
Known faults: <what you found and left>
Assumed:      <content or facts you had to invent or guess>
```

## Reviewing

Use this for an app or a design someone else made.

1. Write the main job (step 1), and name the direction the app is nearest to, or say that it has
   none and sits on system defaults.
2. Say what you are looking at. From screenshots you can judge what is visible on those screens in
   those states, and nothing about how the app behaves. Say which states you were not shown.
3. Go through "Rules that hold", the nearest entry's "Common failures", and G1's "Verify".
4. Write each finding in this form:

```
What:    <what is on the screen>
Where:   <screen and state>
Harm:    <how it gets in the person's way>
Instead: <what to do, and when the current design would be right after all>
Basis:   <the rule or the entry's row, with its grade>
Checked: <seen in a screenshot | run in the app | read in the code only>
```

A finding with no harm is a preference. Leave it out, or mark it as one.

## Limits of this version

- The library has one screen for each direction and one flow: a list, a sheet and one action, in
  direction 03. No entry shows a flow in another direction, a flow of several steps, or one
  direction carried across a whole app. Most rows of the flow entry are our choice, because a
  reference image cannot show an action being answered.
- The guard rules G3 to G12 rest on Apple's guidelines, on two papers about generated interfaces
  and on this project's own tests and reviews. None is graded from the reference apps.
- Every look has the parts for a second screen, shown in use on a few screens of one product.
  Only the parts of 01, 03 and 05 rest on anything seen in other apps; the other eleven are our
  choice throughout. Five of them (04, 07, 08, 11, 13) were written by other agents from one
  brief and checked by the agent that wrote the skill. Those screens are
  samples of parts, not graded entries: they have no evidence table of their own beyond `parts.md`.
- G12, on layout, has no built pair: its picture is the library's own screens before and after.
- Pictures: one page of rules, written and not yet tried, and nine free stand-ins. Nothing for
  video, maps or the app's icon. Three looks' parts use photographs or prints; no entry does.
- There is no lint or gate script. `scripts/` holds tools for step 7; what they show is still yours
  to judge. They have been used by two agents on one brief. `contrast.py` reads only colours
  written as `Color(light:dark:)`, not an asset catalogue.
- The library's own screens were written before `literals.py`. Their colours come from their look
  files; some of their fonts and gaps are written in place.
- iPhone, upright, at the default text size. Accessibility support is not covered in this version.
  Entries written earlier still carry rows and checks for the largest text size and for VoiceOver.
  Skip them; they are not departures.
- These steps have been run on two briefs from outside the library: a list of library loans with a
  renew flow, before they were revised, and a dental appointment with a move flow, after, once by
  a top model and once by a mid-tier one. That is three runs. The first is the reason for much of
  steps 1, 3, 5, 6 and 7.
