#!/usr/bin/env python3
"""Finds styling written straight into screen files instead of taken from the look file.

    python3 literals.py Sources/Screens
    python3 literals.py Sources --look Sources/MyLook.swift
    python3 literals.py Sources/Home.swift Sources/MoveSheet.swift

Give it files or folders; folders are searched for .swift files. Leave the look file out,
or name it with --look (as often as needed) so that it is skipped. It lists every line
that writes one of these in place:

    a colour       Color(…), Color.red, .foregroundStyle(.secondary), UIColor
    a font         .font(.headline), .font(.system(size: 17))
    a size or gap  .padding(12), cornerRadius: 8, .frame(height: 44), spacing: 6

Step 6 of SKILL.md asks for every colour to come from the look file, and for type roles
and the gaps that repeat to live there too. Colour is the one people watch; fonts and gaps
are the ones that slip in. Zero is not counted: `spacing: 0` and `.padding(0)` say "none", not a size. A line can be right and
still be listed, for example a frame that comes from a measurement, or the palette of a
drawn picture. Read the list; do not only count it. Exits 1 if a colour is listed, because
that one is never right outside a picture; fonts and gaps are listed for you to judge.

Needs only the Python that comes with Xcode.
"""
import pathlib
import re
import sys

NAMED = r"(red|orange|yellow|green|mint|teal|cyan|blue|indigo|purple|pink|brown|gray|grey|black|white|primary|secondary|tertiary|quaternary)"
KINDS = [
    ("colour", re.compile(
        r"\bColor\(|\bUIColor\b|\bColor\." + NAMED + r"\b"
        r"|\.(foregroundStyle|foregroundColor|tint|background|fill|stroke|shadow)\(\s*(color:\s*)?\." + NAMED + r"\b")),
    ("font", re.compile(r"\.font\(\s*\.(system|largeTitle|title[23]?|headline|subheadline|body|callout|footnote|caption2?)\b")),
    ("size or gap", re.compile(
        r"\.padding\([^)]*?[1-9]|cornerRadius:\s*\.?[0-9]*[1-9]|\.frame\([^)]*?[1-9]"
        r"|spacing:\s*\.?[0-9]*[1-9]|lineWidth:\s*\.?[0-9]*[1-9]|size:\s*[0-9]*[1-9]")),
]


def swift_files(paths, skipped):
    for path in paths:
        root = pathlib.Path(path)
        found = sorted(root.rglob("*.swift")) if root.is_dir() else [root]
        for file in found:
            if file.resolve() not in skipped:
                yield file


def main(args):
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    paths, looks = [], set()
    index = 0
    while index < len(args):
        if args[index] == "--look" and index + 1 < len(args):
            looks.add(pathlib.Path(args[index + 1]).resolve())
            index += 2
        else:
            paths.append(args[index])
            index += 1

    counts = {name: 0 for name, _ in KINDS}
    lines_read = 0
    for file in swift_files(paths, looks):
        try:
            text = file.read_text(encoding="utf-8")
        except OSError as error:
            print(f"cannot read {file}: {error}")
            return 2
        for number, line in enumerate(text.splitlines(), 1):
            stripped = line.strip()
            if not stripped or stripped.startswith("//"):
                continue
            lines_read += 1
            code = stripped.split(" //")[0]
            for name, pattern in KINDS:
                if pattern.search(code):
                    counts[name] += 1
                    print(f"{file}:{number}: {name}: {stripped[:110]}")

    summary = ", ".join(f"{name} {count}" for name, count in counts.items())
    print(f"{summary}, in {lines_read} lines of code")
    return 1 if counts["colour"] else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
