#!/bin/bash
# Builds the three picture tools: sheet, measure and frames.
#
#   build-tools.sh [out-dir]
#
# out-dir defaults to a folder under the temporary directory, so that nothing
# is written into the skill. It prints where the tools are. Needs only Xcode.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
out="${1:-${TMPDIR:-/tmp}/ios-app-taste-tools}"
mkdir -p "$out"
for tool in sheet measure frames; do
  xcrun swiftc -O "$here/$tool.swift" -o "$out/$tool"
done
echo "$out"
