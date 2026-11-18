# Pictures, people, logos and icons

Status: first version, written 2026-11-17. It has not been tried by an agent on a brief. Most of it
is our choice; "Basis" at the end says what little rests on evidence.

Run this page when a screen shows a photograph, an artwork, a person, a logo or an icon.

## Where a picture may come from

Take the first of these that applies, and say in your report which one you took.

1. **The product's own pictures.** They are part of the real material in step 1 of `SKILL.md`. Ask
   for them. A real product is shown in its own pictures and in nothing else.
2. **A free picture, for an invented product or a sample.** `../library/pictures/` holds nine, and
   its `CREDITS.md` says where each came from. More can be added under the terms below.
3. **A drawing made in code.** It keeps its own colours, apart from the look's colour roles. The
   tide in entry 07 and the kitchen in entry 08 are drawn this way.
4. **No picture.** The look's type and shapes carry the screen.

Never use a picture taken from a reference app, a gallery or a search result with no licence you
have read. And in a real product never pass a stand-in off as the product's own: list every
stand-in in the report, with the picture the product has to supply in its place.

## Licences this skill ships

Only pictures under **CC0** or the **Public Domain Mark** go into `library/pictures/`. Whoever uses
the skill can then copy, change and ship them with no condition.

- Read the licence on the picture's own page, and on the site's licence page. A search result
  that says "free" is not a licence.
- Record each picture in `CREDITS.md` when you add it: file name, what it shows, its title at the
  source, the author, the source page, the licence, its size and the date.
- A licence that asks for credit (CC BY) is fine in an app that shows the credit. It does not go
  into this folder, because every sample that used it would owe a credit line.
- A licence on a page is the publisher's statement. Say so in the report; you have not checked that
  the uploader owned the picture.

Three places that answer a search with the licence attached, and need no key: Openverse (ask for
`cc0` and `pdm`), The Met's open collection, and the Art Institute of Chicago's catalogue.

## People

- Do not put an invented person's name on a real person's face. A licence covers the photograph,
  not the person in it. In a sample, a person is drawn, or is an initial.
- In a product, a person has three forms and the screen needs all three: their photograph, their
  initial when there is none, and an empty mark when there is nobody yet.

## Logos

- **Another company's logo** keeps its own colours and its own shape. Do not tint it, redraw it,
  or set it to one of the look's colours. Put it on a small neutral tile, so that it reads the
  same in light and in dark.
- Use another company's logo only to name something the product really works with. In a sample,
  invent the company and draw its mark.
- **The app's own mark** belongs to the first run and to About. People know which app they opened;
  a logo in the bar takes room from the content.

## Every picture has four forms

A picture is content that arrives late and sometimes never. Design all four, as rule 5 of
`SKILL.md` asks for any state:

| Form | What to decide |
| --- | --- |
| Loaded | Its frame: size, corner, and whether anything may sit on it |
| Waiting | The frame is already there at its final size, in one of the look's own shapes. Nothing moves when the picture comes |
| Could not load | The same frame with a quiet mark. No red, and no message, unless the picture is the point of the screen; then say what failed and offer a retry (guard rule G7) |
| None | What the row or the screen looks like for an item that has no picture at all |

Text on a picture has to be measured on the picture, in the worst place it can fall (guard rule
G8).

## Icons

Use SF Symbols. One symbol for one meaning across the app (guard rule G6), in the weight of the
text beside it. Draw an icon of your own only where no symbol says it, and keep it as plain as the
symbols around it.

## The same parts in three looks

A look decides how these parts are drawn, and three looks do it differently. The reasons are each
look's own rules, in its look file and its entry.

| | 01 Quiet Native | 03 Data Precision | 05 Playful & Tactile |
| --- | --- | --- | --- |
| A picture | A small square at the end of a row, never a banner | A small frame with a hairline | In a tray, like a block |
| Waiting | A square in the look's one fill | The frame, in the rule colour | A dashed slot, as for a block not yet earned |
| A person with no photograph | An initial on the fill | Initials in a ring | An initial on a tray disc |
| Another company's logo | On a tile, in a row | On a tile, starting the row; with none, a code in a tag | On a tile with no lower edge, since it cannot be pressed |

These three are drawn in the design system and are not yet built in SwiftUI.

## Verify

1. Every picture in the build is on your list of sources, with its licence, or is the product's own.
2. Turn the network off and open each screen. Every picture's place holds its waiting form and
   nothing has moved or collapsed.
3. Point one picture at an address that does not answer. The frame stays, with its mark.
4. Find an item with no picture and one person with no photograph. Both look intended.
5. Switch to dark. Every logo still shows its own colours.
6. Read the report: every stand-in is listed.

## Basis

- Twelve apps' App Store listings were looked at on 2026-11-17 (seven from the 2026 Apple Design
  Awards, three named in WWDC26 session 251). A person's photograph in a disc appears in two, by
  one developer. A row that starts with a square picture appears in one. Nine show no name or
  logo of their own on any screen pictured, and three do.
- WWDC26 session 251, "Communicate your brand identity on iOS", says people do not need reminding
  which app they are using, and that a logo takes room better given to content.
- No listing shows another company's logo, or a picture that is waiting or has failed. The tile,
  and the waiting and failed forms, are our choice: a store listing would not show a failure.
- The four forms follow rule 5 of `SKILL.md`. The rule about faces and the choice of CC0 are ours.

## Not covered

Video, maps, the app's icon on the Home Screen, and pictures made by a generator.
