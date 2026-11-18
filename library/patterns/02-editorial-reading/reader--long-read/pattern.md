---
id: long-read
name: A long read with quiet tools
direction: 02 Editorial Reading
also_fits: 12 Focused Utility, 01 Quiet Native Minimalism
kind: reader
code: LongRead.swift
look: ../ReadingLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator on iPhone 17 in light and dark and on iPhone SE. A UI test has scrolled the essay, tapped the page, changed the text size, set a bookmark and highlighted a paragraph on iPhone 17 in light, and the recording was read frame by frame. Not used by hand. The largest-text screenshots are older than these changes.
---

# A long read with quiet tools

One long text on a warm page, set in serif. The tools show at the top of the article and leave once
reading starts. A thin line at the bottom says how far through you are.

## Use it when

- The screen holds one text that takes minutes to read: an article, an essay, a chapter, a long note.
- The job is to read it. Saving, sharing and adjusting come second.

## Use something else when

- The content is a feed of short items. That is a list.
- People mostly edit the text. Lead with an editor and its keyboard tools.
- The text is a reference people jump around in. It needs a contents list and search before it needs calm.
- Pictures carry the piece. Then the pictures set the layout, not the column.

## Do

| Decision | Basis |
| --- | --- |
| Running text is serif, one step larger than interface text, with open leading. | Rule. Serif running text in 4 apps: E1, E2, E3, E4. The size and the leading are our choice |
| Labels around the text are sans: publication, writer, time left. | Common practice. Sans labels beside serif text in 2 apps: E1 (the bar under the page), E4 (the book title above it) |
| The page is tinted in both appearances, never pure white or black. | Rule. A tinted reading ground in 3 apps: E1 and E2 (navy), E4 (beige). E3 is plain white. The warm paper tone is our choice |
| The navigation bar hides while reading. | Rule. No bar is visible on the reading page in 3 apps: E1, E3, E4. E2 keeps three small floating controls |
| The bar returns on scrolling back or on a tap. | Our choice. No reference image shows how the bar comes back |
| A 2 pt progress line stays at the bottom. The time left appears with the tools. | Our choice. Three apps show time left, none of them on a text page: E1 (listen bar), E4 (audiobook player), E3 (a recap) |
| A highlight is a fill behind the words. The words keep their colour. | Rule. Seen in 3 apps: E1 (blue), E2 (yellow), E3 (cyan) |
| A highlight is also underlined. | Our choice, from a measurement: the fill alone is 1.2:1 on the page in light and 1.8:1 in dark, too faint to find again. The line is 4.0:1 and 9.2:1 |
| A link is the hue and an underline. | HIG, Color: avoid relying on colour alone |
| One hue, for links and text buttons. There are no filled buttons. | Our choice |
| Above the text: publication, title, writer and reading time, then a hairline. Nothing else. | Common practice for "who · how long": 2 apps, E1 and E2, in their lists. On the article itself it is our choice |
| The column has 24 pt margins, 16 pt at the accessibility sizes, and stops growing at 640 pt. | Our choice |
| Paragraphs are separated by space, not an indent. A heading has more space above than below. | Our choice |
| The reader can step the text size up or down, on top of the system text size. | Recorded only. E4 has a sheet with size, brightness and six themes. Two steps in a menu is our choice |
| A failure is a short notice above the title, closed by a hairline. The saved text stays readable under it. | Our choice |
| Bookmarking fills the glyph and says nothing. | Guard rule G1 |
| With the bar hidden, a strip of the page colour covers the status bar area. | Our choice, forced by the test: the text scrolled up behind the clock |
| The text keeps its place when the bar comes and goes. The bar lies over the page; it does not push it. | Our choice, forced by the test: when the bar moved the text, the screen froze on the first scroll |
| The tools change only after the reader has scrolled about 70 points the other way. | Our choice. A reader's thumb wobbles; a bar that answered every point of it would flicker |

## Common failures

- The text in a card, or centred, or justified into rivers.
- Interface body size for running text, with default leading.
- Pure black on pure white, or the reverse, for ten minutes of reading.
- Tools that stay on screen the whole time and take a fifth of it.
- A highlight that changes the text colour, or is so pale it cannot be found again.
- Links marked by colour alone.
- A percentage, a page count, a time left and a progress bar all at once.
- A toast after bookmarking, when the glyph has already changed.
- A failure that replaces a text the device already has.
- A font size typed as a number, so the page ignores the reader's text size.

## Verify

1. Read a full paragraph on the device. The line holds roughly 35 to 45 characters and the eye finds the next line without effort.
2. Scroll down: the bar leaves and the text does not jump. Scroll back a little, or tap: the bar returns.
3. With the bar hidden, nothing shows behind the clock and the status icons.
4. Greyscale screenshot: a highlight and a link can both still be found.
5. Dark appearance: page, text, highlight and link are all still distinct. Measured here: text 14.5:1, small text 6.8:1, link 9.0:1, text on a highlight 8.1:1.
6. Largest accessibility text size on a small iPhone: the title wraps instead of shrinking, nothing is truncated, and the bar's buttons are still reachable.
7. Failed state: the saved text is readable and the notice says what copy this is.
8. Read every sentence of interface text and name what it says that the page does not (guard rule G1).

## States

| State | What the sample shows |
| --- | --- |
| Loading | The page layout with placeholder lines. Only the back button is in the bar |
| Empty | The page was saved but holds no readable text: a title and one link to the original |
| Failed, with a saved copy | A notice above the title: offline, and when this copy was saved. The text stays |
| Failed, nothing saved | A full-screen message with the cause and a retry |
| Success | The bookmark glyph is filled. A highlight appears in the text. No message |

## Evidence

Promotional images from the App Store and a design gallery, not captures of a running app. App
versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Matter, article (`matter/03`, `matter/06`) | Serif text on a navy ground; a passage with a blue fill behind it; no top bar; a bar at the bottom with the title, "1h 35m left", pause and close; a serif heading inside the text | [App Store](https://apps.apple.com/us/app/matter-reading-app/id1501592184) |
| E2 | Readwise Reader, article (`readwise-reader/03`) | Large serif text on navy; a passage filled in yellow; three small round controls over the text; a panel at the bottom holding a note for the highlight | [App Store](https://apps.apple.com/us/app/readwise-reader/id1567599761) |
| E3 | Kindle, book page (`amazon-kindle/04`, `amazon-kindle/05`) | Serif text on white; a passage filled in cyan; a menu with Highlight, Look up, Ask, Note, Copy; no bars; a recap sheet with "78% read" and "2 mins to read" | [App Store](https://apps.apple.com/us/app/amazon-kindle-reading-app/id302584613) |
| E4 | Apple Books, book page (`apple-books/03`, `apple-books/02`) | A beige page with the book title small and grey above a serif chapter opening; a sheet with text size, brightness and six themes; the audiobook player shows "1 hour, 13 minutes left" | [App Store](https://apps.apple.com/us/app/apple-books/id364709193) |

Recorded only, each seen in one app: Matter offers questions about the text in a sheet (E1); Apple Books
names its themes (E4); Kindle opens a dictionary under a selected word (E3). These are product
features and are not part of this pattern.

## Not shown by the evidence

- How any of these apps bring their tools back, or how the page moves when they do.
- What they show while an article loads, when it cannot be parsed, or offline.
- Whether readers use, or miss, the time left.

## Found by testing the sample

These came from screenshots and measurements of our own build, not from the references.

- The first scroll froze the screen. The bar was hidden as the reader moved on; hiding it moved the
  text by the bar's height; the scroll handler read that as scrolling back and showed the bar; and
  so on, inside one layout pass, with memory climbing until the app was stopped. Every screenshot
  had passed. Two changes ended it: the scroll view no longer follows the bar (it runs to the top of
  the screen and keeps the status bar's room itself), and the tools wait for a real turn.
- A scroll position given an item to show moves only as far as it must. To put a heading at the top,
  the scroll view needs a top anchor as well.
- With the navigation bar hidden, the system draws nothing over the status bar area, and text scrolls
  behind the clock. The page has to cover that strip itself.
- A highlight fill pale enough to keep the words readable is too pale to see as a shape. The underline
  fixes that without touching the words.
- The system's unavailable view takes the serif design well. Its button did not match the direction,
  so the empty and failed states use the link-style button from the look file.

## Make it yours

The page tone, the hue and the face are choices, not requirements: a cooler page, a different serif,
or a sans for running text are all legitimate if the line length and the leading hold. Keep the things
that protect reading: one column, tools that leave, a highlight that does not change the words, and no
interface text that repeats the page. The sample highlights a whole passage from a menu; highlighting
a selection of words needs a text view from UIKit.
