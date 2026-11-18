# iOS App Taste

An agent skill for designing, building and reviewing iPhone screens in SwiftUI that look made for
their product, not like a template, and that hold up in every state.

It gives an agent:

- **A way to choose a look.** Fourteen visual directions, and a method for picking one from what
  people come to the app to do (`references/directions.md`).
- **A library of original SwiftUI screens.** One built entry for each direction, with the reason
  and the evidence for each decision (`library/`). Every look also has its parts (rows, buttons,
  fields, empty and failed states, pictures, people, logos) shown in use on a few screens of one
  invented product.
- **Guard rules.** Eleven rules for what to stop doing, nine of them with a bad and a good screen
  drawn in the same look (`references/guard-rules.md`).
- **Checks of the built app.** Scripts for contrast, screenshots of every state, contact sheets,
  measuring a screenshot's colours, and recording a UI test and cutting it into frames
  (`scripts/`).

## Install

Clone this repository into your agent's skills folder. For Claude Code:

```bash
git clone https://github.com/KH95314/ios-app-taste.git ~/.claude/skills/ios-app-taste
```

The agent starts from `SKILL.md`.

To build the sample screens and run the checks you need Xcode 26 with the iOS 26 SDK, and
XcodeGen (`brew install xcodegen`). `library/README.md` says how to build the host app and open
any screen in any state.

## Status

A first version. Agents have tried it twice: once alone on four briefs, and once beside agents
without it on one brief, on two models. It does not cover accessibility support (large text sizes, VoiceOver) in this version.
Its own limits are listed at the end of `SKILL.md`.

## Licence

The code and the text are under the MIT licence (`LICENSE`).

The nine photographs and prints in `library/pictures/` are not covered by it. Each is CC0 or in the
public domain; `library/pictures/CREDITS.md` gives the author and source of each.

Every product, company, person and logo in the sample screens is invented. Real apps are named in
the `pattern.md` files only as the evidence for a decision, with a link to where each screen was
seen; no screenshot of another app is included.

The structure of the skill (an entry point, references and scripts) follows
[taste-skill](https://github.com/Leonxlnx/taste-skill). Its rules, wording and code are not used here.
