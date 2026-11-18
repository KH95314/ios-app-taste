---
id: plain-draft
name: A plain draft with tools on the keyboard
direction: 12 Focused Utility
also_fits: 01 Quiet Native Minimalism, 02 Editorial Reading
kind: editor
code: PlainDraft.swift
look: ../FocusLook.swift
pictures: sample-light.png, sample-dark.png
status: Built and screenshotted on the iOS 26.5 simulator in light, dark and the largest text size. Nothing was typed, so the tool keys, undo and selection are not verified.
---

# A plain draft with tools on the keyboard

A page for writing. The text has the screen. One row of tools rides on the keyboard and leaves with
it. The bar holds a back button, one count and Done.

## Use it when

- The job is to get words in: a note, a draft, a message, a speech.
- Formatting is light: headings, emphasis, lists.
- People would rather see their marks than a toolbar of styles.

## Use something else when

- The result must look like the finished page while it is written. Use a styled editor.
- The content is structured fields. That is a form.
- Reading matters more than writing. Use the long-read entry.
- Formatting is the work: tables, layout, images in place.

## Do

| Decision | Basis |
| --- | --- |
| The text has the screen. The bar holds only a back button, one count and Done. | Rule. Few small controls at the top, or none, in 3 apps: E1, E2, E3 |
| Formatting marks stay on the page, quieter than the words. | Rule. Seen in 3 apps: E1 (dimmed asterisks), E2 (grey marks), E3 (marks left in the text) |
| Tools are one row of keys above the keyboard, and leave with it. | Common practice. Tools over or in place of the keyboard in 2 apps: E1 (a grid in its place), E2 (a row above it) |
| The writing face is monospaced. | Recorded only: E3. Taken up here so marks line up and the direction is told from 01 and 02 at a glance |
| A heading is the same size as the text, in bold. | Recorded only: E2 sets headings bold at text size. E2 also colours them; this entry does not |
| The caret is the only hue on the page. | Common practice for a coloured caret: 2 apps, E3 (blue) and E1 (red). Having no other hue is our choice |
| The bar shows one count, chosen for the job: here, how long the speech takes to say. | Recorded only: E2 shows characters and words in its bar. Choosing one count by the job is our choice |
| Nothing asks the writer to save, and nothing announces that saving happened. | Guard rule G1. No reference image shows saving at all |
| An empty page shows the caret and two words: "Start writing". | Our choice. E3 shows nothing but the caret |
| The key for the format at the caret is filled with ink. | Our choice |
| An unavailable key keeps its place with a quieter glyph. | Our choice |
| The keys share the row equally. The gaps belong to the keys' tap areas. | Our choice, forced by the test: with separate gaps, eight keys of 44 pt did not fit an iPhone 17 |
| The row never scrolls sideways. On a narrower screen the less used tools move into a menu. | Our choice |
| The row stops growing at the largest standard text size. Held down, a key shows the large-content preview. | Our choice. A row of eight keys cannot grow with the text and still fit |
| The draft itself follows the text size all the way. | Our choice, checked at the largest size |
| A failure to sync is a short notice above the text. Writing carries on. | Our choice |
| While typing at the accessibility sizes the notice shortens to its title and the retry. | Our choice, forced by the test: the full notice was squeezed and its sentence truncated |
| When the keyboard is down, Done becomes Share. | Our choice |

## Common failures

- A formatting toolbar across the top that is there while nothing is selected.
- A save button, or "All changes saved" after every pause.
- Word count, character count, reading time and a date, all in the bar.
- Marks hidden while typing, so the caret jumps as they appear and vanish.
- Headings in three sizes and two colours in a tool meant for plain drafts.
- A tool row that scrolls sideways, hiding undo.
- Keys drawn 30 pt wide with nothing around them to tap.
- An empty page with a paragraph of tips.
- A sync error that blocks typing.
- A fixed font size in the editor, so the draft ignores the reader's text size.

## Verify

1. With the keyboard up, count what is not the text: three things in the bar and one row of keys.
2. Put the caret in a heading, a bold phrase and a list line. The matching key fills each time.
3. Type a mark. The caret does not jump and the mark turns quieter than the words.
4. Dismiss the keyboard: the tool row leaves with it and Done becomes Share.
5. Measure the quiet ink and the caret on the page. Measured here, light and dark: marks 5.9 and 7.0; caret 5.8 and 7.6.
6. Offline: the notice says what is saved and where, and the text can still be edited.
7. Largest accessibility text size on a small iPhone, keyboard up: the draft is large, the notice is two lines and whole, and at least two lines of the draft show.
8. Hold a tool key at that size: the large-content preview names it.
9. Read every sentence of interface text and name what it says that the page does not (guard rule G1).

Steps 2, 3, 4 and 8 need hands. They have not been done for this sample.

## States

| State | What the sample shows |
| --- | --- |
| Loading | Placeholder lines where the draft will be. Only the back button is in the bar |
| Empty | A blank page with the caret, "Start writing" in the quiet ink, and the keyboard up |
| Failed to sync | A notice above the text: not synced, and that changes are saved on the phone. The draft stays editable |
| Failed, nothing to show | A full-screen message with the cause and a retry |
| Success | The keyboard is down, the tool row is gone, and Done has become Share |

## Evidence

Promotional images from the App Store, not captures of a running app. App versions are unknown.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Bear, note (`bear/02`, `bear/03`, `bear/04`) | A round back button and one pill of two icons; a large title; body text with a tag as a pill inside the sentence; bold text with its asterisks dimmed; a red caret; in place of the keyboard, a grid of formatting keys | [App Store](https://apps.apple.com/us/app/bear-markdown-notes-journal/id1016366447) |
| E2 | Drafts, editor (`drafts/01`, `drafts/02`) | A row of small round buttons with "551c 81w" in grey; text with its marks in grey and its headings bold in dark red at text size; a row of round keys above the keyboard (undo, redo, arrows, search); tag chips in the dark version | [App Store](https://apps.apple.com/us/app/drafts/id1236254471) |
| E3 | iA Writer (`ia-writer/01`, `/03`, `/04`) | A white page of monospaced text with a blue caret and nothing else; one sentence bright with the rest dimmed; a selection in blue with handles | [App Store](https://apps.apple.com/us/app/ia-writer-get-focused/id775737172) |

Recorded only, each seen in one app: Bear's tags inside the sentence and its drawing tray (E1);
Drafts' list of actions that send text elsewhere (E2); iA Writer's dimming of everything but the
current sentence, and its colouring of pasted text (E3). These are those products' ideas and are
not copied.

## Not shown by the evidence

- Saving, syncing, or a failure of either, in any of the three.
- An empty new note in Bear or Drafts.
- How the tools behave with a hardware keyboard.
- How any of them behave at large text sizes.

## Found by testing the sample

These came from screenshots of our own build, not from the references.

- Eight keys at 44 pt with gaps between them are wider than an iPhone 17. Letting each key's tap area
  take half the gap either side fits them, and each key still draws as its own shape.
- The compact row with a menu was seen once, in an earlier build where the row was too wide. It has
  not been screenshotted on a narrower screen.
- A notice above a text view is squeezed before the text view is, and truncates. It has to keep its
  own height, and be shorter when there is almost no room.
- The simulator shows a one-time typing tip in place of the keyboard on first launch. It is the
  system's, not this screen's.
- The selection fill is the system's, drawn from the caret colour. It was not screenshotted, because
  selecting needs a touch.
- The key fill is close to the page (1.1:1). The glyph is what marks a key, at 15:1.

## Make it yours

Change the count in the bar to the one your writers need, or remove it. Choose the tools by what is
used most; eight is the limit of the row. The text view is UIKit: SwiftUI's editor cannot yet restyle
marks while typing without disturbing the caret. The sample restyles the whole draft on every change,
which is fine for a page and too slow for a book.
