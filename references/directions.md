# Choosing a direction

A direction is a look with a reason behind it: what leads the screen, what colour is allowed to mean,
how type carries the order, and how dense the screen is. There are fourteen. Choose one for the whole
app before designing any screen.

**Basis.** What each look is comes from its look file and from the graded rows in its entry's "Do"
table. When to pick it is our choice, drawn from each entry's "Use it when" and "Use something else
when". The method has been tried once, by one agent, on four briefs from outside this library. That
run is where "Jobs the tables do not name" and three of the neighbour questions come from.

## The method

1. **Write the main job in one sentence:** "People open this to ___." Use a verb and an object:
   "see whether the tide is high enough to launch", not "tides". An app has many screens; take the
   job of the screen people open most. The category is not the job. Two habit trackers can differ
   more than a habit tracker and a timer.
2. **Find the family** in the first table.
3. **Pick inside the family** from that family's table. Read "Think again when" as closely as "Pick
   it when". Most wrong choices are a look laid over a job it does not suit. If the job sits in two
   families, read both tables.
4. **Check the choice against the people and the stakes.** A toy-like look on medicine or money, a
   dark dense panel for a casual task, a scene behind figures it says nothing about, a dry table
   for something people do for pleasure: the tables name each of these. If the check fails, take
   the runner-up.
5. **Write the choice down:** the direction, one sentence tying it to the main job, the runner-up, and
   why the runner-up lost. The runner-up is what you would build if the first choice failed step 4.
   It need not be in the same family. Naming one makes you compare two looks instead of taking the
   first that comes to mind.
6. **Open the entry and its look file.** Then return to step 3 of `SKILL.md`.

## The four families

| The main job is to | Family | Directions |
| --- | --- | --- |
| read, write, or work through items | A. Words and items | 01, 02, 12 |
| check, record or plan: values, states, things sorted in time | B. Values and states | 03, 04, 09, 10 |
| look, play or be kept company, where the feel is part of the product | C. Feel and pictures | 05, 07, 08, 14 |
| operate a tool, or work in a space | D. Tools and spaces | 06, 11, 13 |

The families are not walls. Each entry lists its neighbours under `also_fits`. A job can sit in
two: a list of your own things with a date on each is "work through items" and "things sorted in
time" at once.

## A. Words and items

| Direction | The look | Pick it when | Think again when |
| --- | --- | --- | --- |
| **01 Quiet Native Minimalism** | The system's ground, nothing in a box. One hue, only on what can be acted on. Order comes from weight; groups are parted by a hairline and a gap | People work through their own items many times a day: tasks, reminders, notes filed by date or project | Rows need pictures, charts or several values each. Or the product needs a mood of its own: this is the look nearest the system's, so its character has to come from type, spacing and wording |
| **02 Editorial Reading** | Warm paper and serif text. Type does the work, one hue marks links, and the tools leave while someone reads | The product is something to read for minutes: articles, essays, chapters, journals | The content is a feed of short items. People mostly edit (12). Pictures carry the piece (14) |
| **12 Focused Utility** | A plain page of monospaced text. Formatting marks stay on the page, quieter than the words. The caret is the only hue. Tools ride on the keyboard and leave with it | The job is to get words or entries in fast, usually with the keyboard up: notes, drafts, messages | The result must look finished while it is being made. Reading matters more than writing (02). The content is fields, not prose |

Entries: [01 list](../library/patterns/01-quiet-native/list--sectioned-list/pattern.md) ·
[02 reader](../library/patterns/02-editorial-reading/reader--long-read/pattern.md) ·
[12 editor](../library/patterns/12-focused-utility/editor--plain-draft/pattern.md).
Look files: [QuietLook](../library/patterns/01-quiet-native/QuietLook.swift) ·
[ReadingLook](../library/patterns/02-editorial-reading/ReadingLook.swift) ·
[FocusLook](../library/patterns/12-focused-utility/FocusLook.swift).

## B. Values and states

| Direction | The look | Pick it when | Think again when |
| --- | --- | --- | --- |
| **03 Data Precision** | Figures in aligned rows straight on the ground, between hairlines. Colour only for a state, and always with an icon and a word | People check several figures about one thing and must see which one is a problem: a service, an account, a device, a shipment | One figure matters far more than the rest (09). The figures are read for pleasure or motivation: this look is dry on purpose |
| **09 Metric Hero** | One coloured plate holds the number, and the plate's fill is the state. Everything else is neutral | People open the app to learn one value, and the value needs interpreting into a few named bands | Several values matter equally (03). The meaning will not fit in a word or two. The main job is entering data |
| **04 Soft Wellness** | A ground that fades slowly, with no hard edge. One hue that means "yours" and never good or bad | People report on themselves and there is no right answer: mood, energy, pain, sleep | A device measures the value (09 or 03). The product is built on goals and streaks; a target is honest there. A low answer should bring help, as in a clinical tool: then the screen must say so plainly |
| **10 Color-Blocked Structure** | A plain screen where the blocks are the only colour. A block's fill is its category. Every control is ink, so a control is never taken for a category | Things are sorted into a few categories people already think in, and placed in time or order: a day plan, a schedule | There are more than about five categories. Items have no time or order (01). One number matters more than the plan (09) |

Entries: [03 detail](../library/patterns/03-data-precision/detail--service-status/pattern.md) ·
[09 status](../library/patterns/09-metric-hero/status--explained-metric/pattern.md) ·
[04 capture](../library/patterns/04-soft-wellness/capture--gentle-checkin/pattern.md) ·
[10 timeline](../library/patterns/10-color-blocked/timeline--day-blocks/pattern.md).
Look files: [DataLook](../library/patterns/03-data-precision/DataLook.swift) ·
[MetricLook](../library/patterns/09-metric-hero/MetricLook.swift) ·
[SoftLook](../library/patterns/04-soft-wellness/SoftLook.swift) ·
[BlockLook](../library/patterns/10-color-blocked/BlockLook.swift).

## C. Feel and pictures

| Direction | The look | Pick it when | Think again when |
| --- | --- | --- | --- |
| **05 Playful & Tactile** | One loud ground. Anything that can be pressed has a lower edge and moves down when pressed. Rounded type in heavy weights | A small action is repeated many times and should feel like play: habits, water, practice | The setting is serious: medicine, money, work records. The amount is different every time |
| **07 Immersive Environment** | A scene fills the screen and is the data. Words sit straight on it, only where it is dark enough. The scene keeps its own time of day in light and dark | What people come to check can be drawn, such as a level, the weather, the sky or a place, and there is little to do but look | There are many figures of equal weight (03). The value has no natural picture, so the scene would be decoration (09). People act more than they read |
| **08 Warm Organic** | A drawn picture leads and does work: something in it changes with progress. The picture keeps its palette in light and dark; the page under it changes. Serif titles, one hue for actions | The product keeps someone company through something slow or gentle, such as a wait, a routine or a practice, and a drawing can show how it is going | Nothing in the picture would change. The figure must be read exactly and often (09). The person acts all the way through (06) |
| **14 Media-Led Experience** | White in light, black in dark, so the pictures are the only colour. Words on a picture are solid white over a scrim. Controls are black or white | People choose by looking, and every item has a picture of its own: prints, films, classes, recipes, places to stay | Items have no pictures, or the pictures are alike (01). People choose by comparing figures (03). Place matters more than appearance (11) |

Entries: [05 capture](../library/patterns/05-playful-tactile/capture--one-tap-log/pattern.md) ·
[07 status](../library/patterns/07-immersive-environment/status--tide-scene/pattern.md) ·
[08 session](../library/patterns/08-warm-organic/session--proof-timer/pattern.md) ·
[14 browse](../library/patterns/14-media-led/browse--picture-wall/pattern.md).
Look files: [TactileLook](../library/patterns/05-playful-tactile/TactileLook.swift) ·
[SceneLook](../library/patterns/07-immersive-environment/SceneLook.swift) ·
[WarmLook](../library/patterns/08-warm-organic/WarmLook.swift) ·
[MediaLook](../library/patterns/14-media-led/MediaLook.swift).

The evidence behind 07 and 08 is thin. Their entries say how thin.

## D. Tools and spaces

| Direction | The look | Pick it when | Think again when |
| --- | --- | --- | --- |
| **06 Dark Professional** | Black in both appearances, so the work is the only large bright thing. Monospaced values under small capital labels. One hue marks what is being adjusted; red means recording and nothing else | The app is operated while something is live, such as recording, filming, measuring or mixing, and a wrong press costs the take | Nothing is live. The audience is casual. The product must follow the system's appearance |
| **11 Layered Surfaces** | The picture underneath (a map, a photo, a camera view) keeps the colour. The surface over it is the system's sheet, and its main action is ink | People choose among things by where they are, going back and forth between the overview and one item | Position does not help the choice (01 or 14). The detail is long and read top to bottom. The sheet would hold a form of several steps |
| **13 Canvas-First Creation** | The work sits on a neutral board and has all the colour. The bars round it are neutral. One hue marks what is selected and which tool is in use | People make something visual by arranging objects, and the work must stay in view while it changes | The work is text (12). The job is adjusting one picture on live material (06). There is nothing to arrange, only fields to fill |

Entries: [06 session](../library/patterns/06-dark-professional/session--audio-take/pattern.md) ·
[11 map](../library/patterns/11-layered-surfaces/map--context-sheet/pattern.md) ·
[13 canvas](../library/patterns/13-canvas-first/canvas--flyer-canvas/pattern.md).
Look files: [ProLook](../library/patterns/06-dark-professional/ProLook.swift) ·
[LayerLook](../library/patterns/11-layered-surfaces/LayerLook.swift) ·
[CanvasLook](../library/patterns/13-canvas-first/CanvasLook.swift).

## Telling neighbours apart

| Between | Ask |
| --- | --- |
| 01 and 03 | Can an item be in a state people must spot, such as late or failing? Then colour has to mean the state: 03. If items are only done or not done, 01 |
| 03 and 10 | Does colour mean a state (03) or a category (10)? |
| 03 and 09 | Is one figure worth several times the others? Then 09 |
| 07 and 09 | Can the value be drawn so that a glance reads it? If the picture would say nothing about the value, 09 |
| 07 and 08 | Is the screen a place to look at (07), or a page with a drawing at its head and things to do under it (08)? |
| 07, 08 and 14 | Is the picture the reading (07, 08), or one of many things to choose from (14)? |
| 04 and 05 | Is there a goal to reach (05), or no right answer (04)? |
| 01 and 12 | Do people tick through items (01) or type (12)? |
| 02 and 12 | Do people read (02) or write (12)? |
| 06 and 13 | Is the material live (06), or a piece of work being arranged (13)? |
| 11 and 14 | Do people choose by place (11) or by appearance (14)? |

When 03, 07 and 09 each fit a sentence of the brief, ask about the figures first and the picture
second. Is one figure worth several times the others? If not, 03. If so, can it be drawn so that a
glance reads it? Then 07; otherwise 09. Asked the other way round, the questions can stop one short.

## Jobs the tables do not name

Three common jobs have no row above. These answers are our choice, from one trial run.

- **Many things, one figure each, and the job is to find the one that needs attention:** loans,
  bills, deliveries, deadlines. 03 is written for several figures about one thing; this is one
  figure about each of several things. Take 03's look on a list: the one that needs attention
  leads, with its state in words and the way to act; every other thing is one line that ends in a
  quiet figure; colour means a state. The flow entry in 03 shows it. Do not put a verdict over the
  list as well: it says the lead twice. Take 01 instead if no item can be in a bad state.
- **Entering one measured value:** a meter reading, a weight, a mileage. The family table sends
  "record" to B, and 04, 09 and the 03 entry each turn data entry away. Take 03 with the input
  leading; its comparison under a figure is what catches a wrong digit. Take 12 if what goes in is
  closer to prose. No entry shows either.
- **A conversation.** No kind and no entry. Take the look from the direction the rest of the app
  has, and say in the report that the layout is yours.

## When the screen you need is not the entry's kind

The library holds one screen for each direction. A metric app also needs a history list, and there
is no list entry in 09.

Take the look from your direction: its colour roles, its type, its shapes and what its colour means.
Take the layout from the job of the screen. An entry of that kind in another direction shows the
layout decisions and their grades (for a list, the 01 entry); read it for those and leave its look
behind.

The two can disagree, because an entry does not keep its layout rows apart from its look rows. Then
the look decides what colour means and where a state is marked, and the kind's entry decides the
order and grouping of things. A late item is marked on its detail line in the 01 list and on its
figure in the 03 look; in a list built in 03 it goes on the figure.

An entry's "Use something else when" is about that entry's screen, not about the direction. "People
mostly enter data here. Lead with the input" in the 03 entry means another screen in the same look.
It does not mean another look.

A kind's entry may rule your rows out as well: the 01 list is for a name and one line of detail.
The library has no table or card-list entry. Say so, and design the row yourself.

This is our choice. No entry yet shows one direction carried across several kinds of screen.

## Making the direction yours

A direction fixes roles, not hues. "One hue, only on what can be acted on" is the direction. The blue
in the sample is the sample's. So are its type design where the table above names none, its corner
radius, and the form of its rows. Following the graded rows will give your screen the sample's
skeleton; these are what make it another product.

- Take the hues from the product: its subject, its material, or its brand colours if it has them.
- Give each hue one role from the look file and keep it there. A brand colour usually takes the
  accent's role, or the plate's or the blocks' where the direction has them.
- Choose the light and dark value of every colour together, then measure the text on it.
- The sample's product, pictures, names and wording belong to the sample. Write your own. A system
  symbol used for the same meaning is shared vocabulary, not a copy.

Fitting a brand's colours to a direction's roles is our choice and has not been tried on a real brand.

## When nothing fits

Do not force a product into a direction. Start from the nearest one, write down what you changed and
why, and judge the result by whether the screen serves its main job. A look outside the fourteen is
not a fault.
