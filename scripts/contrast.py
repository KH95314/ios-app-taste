#!/usr/bin/env python3
"""Contrast of the text and ground pairs in a look file, in light and in dark.

    python3 contrast.py Look.swift                        the pairs named in the look file
    python3 contrast.py Look.swift ink:ground warn:sheet@3
    python3 contrast.py 17212F F3EEE1                     two colours

Colours are read from lines of this form, which the library's look files use:

    static let ink = Color(light: 0x17212F, dark: 0xEFEADC)

Pairs are read from comments in the look file, so they are kept beside the colours:

    // contrast: ink on ground
    // contrast: warn on ground 3

A pair needs 4.5 unless it says otherwise: 4.5:1 for text up to 17 points, 3:1 for larger
or bold text (HIG, Accessibility). Give 0 to a pair that carries no meaning, such as a
hairline. The ratio is the WCAG 2 one. Exits 1 if any pair falls short.

Needs only the Python that comes with Xcode.
"""
import re
import sys

COLOUR = re.compile(
    r"let\s+(\w+)\s*(?::\s*Color\s*)?=\s*Color\(\s*light:\s*0x([0-9A-Fa-f]{6})\s*,\s*dark:\s*0x([0-9A-Fa-f]{6})\s*\)")
# A colour that is the same in both appearances.
FIXED = re.compile(r"let\s+(\w+)\s*(?::\s*Color\s*)?=\s*Color\(\s*fixed:\s*0x([0-9A-Fa-f]{6})\s*\)")
PAIR = re.compile(r"//[ \t]*contrast:[ \t]*(\w+)[ \t]+on[ \t]+(\w+)(?:[ \t]+(\d+(?:\.\d+)?))?")
HEX = re.compile(r"^(?:0x|#)?([0-9A-Fa-f]{6})$")


def luminance(value):
    def linear(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = [(value >> shift & 0xFF) / 255 for shift in (16, 8, 0)]
    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)


def ratio(a, b):
    la, lb = luminance(a), luminance(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def main(args):
    if len(args) == 2 and all(HEX.match(a) for a in args):
        a, b = [int(HEX.match(x).group(1), 16) for x in args]
        print(f"{ratio(a, b):.2f}:1")
        return 0
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return 0

    source = open(args[0], encoding="utf-8").read()
    look = {name: (int(light, 16), int(dark, 16)) for name, light, dark in COLOUR.findall(source)}
    look.update({name: (int(value, 16), int(value, 16)) for name, value in FIXED.findall(source)})
    if not look:
        print(f"No colours of the form Color(light: 0x……, dark: 0x……) in {args[0]}.")
        return 2

    pairs = []
    for arg in args[1:]:
        text, _, rest = arg.partition(":")
        ground, _, needs = rest.partition("@")
        pairs.append((text, ground, float(needs) if needs else 4.5))
    if not pairs:
        pairs = [(t, g, float(n) if n else 4.5) for t, g, n in PAIR.findall(source)]
    if not pairs:
        print("No pairs. Name them as text:ground, or in the look file as  // contrast: ink on ground")
        print("Colours found:", ", ".join(look))
        return 2

    failures = 0
    for index, mode in enumerate(("light", "dark")):
        print(mode)
        for text, ground, needs in pairs:
            missing = [name for name in (text, ground) if name not in look]
            if missing:
                print(f"  {text} on {ground}: no colour named {', '.join(missing)}")
                failures += 1
                continue
            value = ratio(look[text][index], look[ground][index])
            short = value < needs
            failures += short
            print(f"  {text:>10} on {ground:<10} {value:5.2f}:1  needs {needs:g}{'   <-- falls short' if short else ''}")
    print(f"{failures} short" if failures else "all pairs pass")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
