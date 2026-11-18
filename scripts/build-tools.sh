#!/bin/bash
# Builds the three picture tools: sheet, measure and frames.
#
#   build-tools.sh [out-dir]
#
# Without out-dir the tools go into a new private folder under the temporary
# directory, so that nothing is written into the skill. A given out-dir must be
# yours, not a symbolic link, and writable by nobody else. It prints where the
# tools are. Needs only Xcode.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
if [ $# -ge 1 ]; then
  out="$1"
  if [ -L "$out" ]; then echo "$out is a symbolic link; give a real folder" >&2; exit 1; fi
  mkdir -p "$out"
  if [ ! -O "$out" ]; then echo "$out belongs to someone else" >&2; exit 1; fi
  mode=$(stat -f '%Lp' "$out")
  if (( (8#$mode & 8#022) != 0 )); then echo "$out can be written by others (mode $mode)" >&2; exit 1; fi
else
  out=$(mktemp -d "${TMPDIR:-/tmp}/ios-app-taste-tools.XXXXXX")
fi
for tool in sheet measure frames; do
  xcrun swiftc -O "$here/$tool.swift" -o "$out/$tool"
done
echo "$out"
