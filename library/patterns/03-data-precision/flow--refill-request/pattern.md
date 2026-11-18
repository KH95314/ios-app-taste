---
id: refill-request
name: One action, asked and answered
direction: 03 Data Precision
also_fits: 01 Quiet Native Minimalism, 12 Focused Utility
kind: flow
code: RefillRequest.swift
look: ../DataLook.swift
pictures: sample-light.png, sample-dark.png, sample-sheet-light.png
status: Built on the iOS 26.5 simulator. Twelve states screenshotted on iPhone 17 in light and dark and on iPhone SE. Six paths pressed by a UI test and recorded once each. Not used by hand, and never on a real device.
---

# One action, asked and answered

A list, a sheet and one action. The list leads with the one thing that needs something and keeps
everything else to a line. A sheet holds that thing's facts and one button. The button sends a
request, and the service may say yes, say no, or never hear it. This entry is about what the two
screens do in each of those cases.

## Use it when

- People keep a few things in view and now and then one of them needs an action: a refill, a
  renewal, a top-up, a payment that is due.
- The action is sent somewhere and comes back with an answer that can be no.
- The person should see a few facts before committing: where, when, how many are left.

## Use something else when

- The action cannot be refused and needs no facts first. Do it where the thing is, with no sheet.
- Sending takes several steps or typed input. That is a form on a page of its own, not a sheet.
- Every item needs attention at once. Then nothing leads, and the screen is a plain list.
- People come to study the figures, not to act. Use "One thing, in figures" in this direction.

## Do

The list.

| Decision | Basis |
| --- | --- |
| One thing leads the list: its name, its state in words, and one button. | Our choice, from a review of this entry's first build. That build gave every medicine a figure and a date under a state headline, and was rejected: too much on the screen, no focus |
| Everything else gets one line: a name, and one quiet figure at the right. | Our choice, from the same review. A name at the left with a figure at the right is common practice, seen in 2 apps: E2, E1 |
| A fact is said once. No headline that repeats the lead, no date beside a count of days, no count of the rows. | Guard rule G1, and the same review: the first build said "runs out in 3 days" in a headline, a head and a row |
| The state is words with an icon, and colour is only for a state. | Rule for pairing the colour with a mark, seen in 3 apps: E2, E3, E1. HIG, Color: do not rely on colour alone |
| A head over the quiet rows, a few words in small capitals. It also says what their figure counts. | Rule for the form, seen in 3 apps: E2, E3, E1 |
| The button on the list opens the sheet. It does not send. | Our choice. Where to collect, when it will be ready and how many are left come before the commitment |
| Two acts, two names: "Request a refill" opens the sheet, "Send request" sends. | Guard rule G6 |
| Every row opens its sheet, and no row shows a chevron or a hue for it. | Our choice. Where every row opens, a mark on each says nothing |
| The list is pulled down to fetch it again. There is no refresh button. | Our choice. One control fewer on a screen that should have one |
| The age of the list is shown only when the list is old: "List saved at 8:12 AM". | Our choice. Two apps show when their data is from at all times: E3, E2 |
| With nothing low there is no lead, no colour and no button. | Our choice. A calm screen is the message |

The sheet.

| Decision | Basis |
| --- | --- |
| The action is one wide filled button at the foot of a sheet. | Common practice. Seen in 2 apps: S1 ("Share Link"), S2 ("Read book"). S3 sets two buttons side by side |
| A close mark at the sheet's top right. | Common practice. Seen in 2 apps: S1, S2 |
| The facts are rows of name and value. | Recorded only: S1. It is also this direction's own row |
| The sheet takes the look's one ground. It is not a second surface colour. | Our choice |
| The sheet is as tall as its content, and it never changes height. | Our choice, from testing. In this skill's first trial a sheet grew when a refusal arrived, and this entry's first build shrank when the answer was yes |
| A line of fixed height sits above the button. Before the answer it carries the one fact the rows lack: how long a refill takes. Then it carries the answer. | Our choice. A sentence above the button is recorded only: S1 |
| One button whose words change: "Send request", "Sending…", "Done". It is never swapped for another. | Our choice |
| While it is sending, the button cannot be pressed again. Its fill lightens and its words stay whole. | Our choice. Measured: 7.25:1 in light and 9.25:1 in dark |
| A yes has no message. The supply row turns to its good state with the day the refill is ready, and the count of refills drops. | Our choice, and guard rule G1: the rows already say it |
| A no is not a state of the thing. Its reason is in ink with a mark, the supply keeps its warning, and the button reads "Done". | Our choice, from rule 5 of `SKILL.md` |
| "Could not be sent" never shares words with a no. It names the cause, and the same button sends again. | Our choice. HIG, Writing (read 2026-11-17): an error should be clear about what someone can do |
| The sheet can be closed while it is sending. The request goes on, and the list says so. | Our choice. A slow service must not hold the person in a sheet |

What the list does with an answer.

| Decision | Basis |
| --- | --- |
| The list and the sheet draw from one value, so they cannot disagree. | Our choice |
| After a yes the lead reads "Refill ready Thu, Nov 19" in the good state, and its button is gone. | Our choice |
| After a no the reason stays under the lead in ink, and the list stops offering to ask. | Our choice. Asking again would get the same answer |
| After a failure to send the lead says "Refill not sent" and keeps its button. | Our choice |
| While a request is on its way the list's button reads "Sending…". | Our choice |
| Words change at once. When a line or a button comes or goes, only the rows below it move, in a glide. | Our choice, from recordings. A fade drew the old words over the new |
| A haptic marks each answer: success, warning, error. | Our choice. The simulator cannot show it |

## Common failures

- A list where every row is as loud as the one that needs attention.
- One fact in a headline, a head and a row.
- A button on the list and a button on the sheet with the same words and different effects.
- A sheet that grows or shrinks when the answer arrives.
- "Request sent!" over a screen that already shows the request.
- One message for "refused" and "could not be sent".
- A refusal in red, as though the thing's own state had changed.
- The button swapped for another button, or two labels fading over each other.
- A spinner over the whole sheet, so the facts cannot be read while waiting.
- The list still showing the old state after the sheet closes.
- A sheet that cannot be closed until the service answers.

## Verify

1. Squint at the list: the lead is found first, then its button.
2. With nothing low, the list has no colour and no button.
3. Count how many times each fact appears on the list. Once.
4. Press each path under a recording: yes, no, could not be sent and then sent, and the sheet
   closed before the answer. In the frames round the answer, nothing in the sheet moves and no two
   labels overlap.
5. Compare the sheet across its five states. Its top edge is at the same height in each.
6. After each answer, close the sheet. The list says what the sheet said.
7. Measure the text on the ground and on the button. Measured here, light and dark: second ink
   6.21 and 7.49; the warning 5.85 and 11.66; the busy button's words 7.25 and 9.25.
8. On the smallest phone the lead's name takes two lines and the whole sheet fits.
9. Read every sentence on both screens and name what it says that the screen does not (guard rule G1).

## States

The list.

| State | What the sample shows |
| --- | --- |
| Loaded, one low | The lead with its warning and "Request a refill", then three quiet rows |
| Loaded, nothing low | "In supply" and four quiet rows |
| Loading | The rows as grey shapes, with no colour: loading claims no state |
| Empty | "No repeat medicines", where a medicine comes from, and "Check again" |
| Failed, with a saved list | What cannot be reached and a retry, "List saved at 8:12 AM", and the lead's state in grey with a clock |
| Failed, nothing saved | A full-screen message with the cause and a retry. It is in the code and was not screenshotted |
| Success | After a yes: the lead reads "Refill ready Thu, Nov 19" and has no button |

The action.

| State | The sheet | The list |
| --- | --- | --- |
| Ready | "Ready to collect in about 2 days" above "Send request" | "Request a refill" |
| In progress | "Sending…" with a spinner, and it cannot be pressed | Its button reads "Sending…" |
| Done | The supply row in its good state, one refill fewer, "Done" | "Refill ready Thu, Nov 19", no button |
| Refused | "A review with Dr Okafor is due first" in ink, "Done" | "A review is due before a refill" under the lead, no button |
| Could not be sent | "Not sent. Can't reach the pharmacy", "Send request" again | "Refill not sent" under the lead, with its button |

## Evidence

Promotional images from the App Store and a design gallery, not captures of a running app. App
versions are unknown. E1 to E3 were viewed on 2026-11-16 and S1 to S4 on 2026-11-17.

| Ref | App and screen | What is visible | Source |
| --- | --- | --- | --- |
| E1 | Flighty, flight (`flighty/04`, `flighty/06`) | A red "RUNNING LATE" badge with a warning icon; rows with a status at the right in red ("52m Late"); "IN AIR" in small capitals | [App Store](https://apps.apple.com/us/app/flighty-live-flight-tracker/id1358823008) |
| E2 | Copilot Money (`copilot-money/01`, `/03`, `/06`) | A table with small capital column heads and right-aligned figures; rows of a name and an amount at the right; "5 hours ago" on account rows | [App Store](https://apps.apple.com/us/app/copilot-track-budget-money/id1447330651) |
| E3 | Athlytic, Recovery (`athlytic/03`) | "Ready to Train" over a figure; "WHAT'S DRIVING IT" in small capitals; "Recovery Calculated at: 9:54 AM" | [App Store](https://apps.apple.com/us/app/athlytic-fitness-recovery/id1543571755) |
| S1 | 1Password, sharing (`1password/04`) | A sheet titled "Share a link to this item" with a round close mark at its top right; the item's icon and name; rows of a label at the left and a value at the right; a switch; a sentence under the rows; a text link; one wide filled button, "Share Link" | [Godly gallery](https://godly.design/app/1password/) |
| S2 | Amazon Kindle, recap (`amazon-kindle/05`) | A sheet with a title and a close mark at its top right; a cover, a title and "78% read"; one wide filled button, "Read book"; a two-part control; text | [App Store](https://apps.apple.com/us/app/amazon-kindle-reading-app/id302584613) |
| S3 | Adobe Express, results (`adobe-express/06`) | A sheet titled "Results" with a back chevron; thumbnails; two buttons side by side, a grey "Discard" and a filled "Keep" | [Godly gallery](https://godly.design/app/adobe-express/) |
| S4 | Headspace, length (`headspace/04`) | A sheet titled "Choose a length" over a page; two rows with a radio mark each; no button | [App Store](https://apps.apple.com/us/app/headspace-sleep-meditation/id493145008) |

## Not shown by the evidence

- Any of these apps sending an action, waiting for it, being refused, or failing to send. A
  screenshot cannot show a flow.
- What the list behind any of these sheets does when the sheet's action succeeds.
- A list with one item leading in any of the direction's six reference apps.
- Whether people find the list's button or the sheet's button the clearer place to commit.

## Found by testing the sample

These came from screenshots, recordings and measurements of our own build, not from the references.

- **The first list was too busy.** A state headline, a line with a time and a count, two heads, and
  four rows with a figure and a date each. It was approved as a small drawing and rejected at real
  size on the simulator. Judge density on the simulator.
- **Pressing a row opened an empty sheet that filled the screen.** The sheet was presented with a
  flag while the medicine it was for sat in a second piece of state, and its content was built
  before that state had changed. Screenshots had not shown it, because they start with the sheet
  open. The sheet is now handed its medicine with `.sheet(item:)`.
- **The sheet shrank when the answer was yes.** The answer line was an empty view with a frame,
  which takes no room. It is now a clear colour.
- **On the list the old words faded over the new.** Inside the glide that closes the gap, the state
  line changed by a fade, and the button faded out while the head below slid over it. The words now
  change at once, the button leaves at once, and a line that arrives shows after the rows have moved.
- **The loading state was green.** Its placeholder list had nothing low, so its shapes took the
  good colour. A placeholder now counts as a saved copy and has no colour.
- In dark the sheet's edge is faint, because the sheet and the page share one ground. What
  separates them is the dimmed page behind.
- A UI test's press lands more than a second after it is asked for. To close the sheet before the
  answer, the sample's service had to be slowed to five seconds.

## Make it yours

The medicines, the pharmacy and the words of the refusal belong to the sample. Keep what the entry
is about: one thing leads, the action has five states, the sheet does not move, a no is not a
failure to send, and the list always knows what the sheet did. The sample's service is a list of
answers handed to the screen, with a wait. A real one sends the request, and must also decide what
to show when the app is closed before the answer comes.
