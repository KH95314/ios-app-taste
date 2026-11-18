#!/bin/bash
# Screenshots every library entry in the states you name, on one simulator.
#
#   shoot.sh <device> <app> <out-dir> <appearance> <content-size> [states...]
#
#   device        simulator name or UDID (it is booted if needed)
#   app           path to the built PatternHost.app
#   appearance    light | dark
#   content-size  a simctl content size, e.g. large (the default text size)
#                 or accessibility-extra-extra-extra-large (the largest)
#   states        defaults to: loaded loading empty error success
#                 Write state:variant for a second loaded view, e.g. loaded:poor
#
#   PATTERNS="explained-metric" shoot.sh ...   limits the run to those entries
#   SCROLL=end shoot.sh ...                    opens each screen scrolled to its end;
#                                              files get "-end" added to their names
set -euo pipefail

device="$1"; app="$2"; out="$3"; appearance="$4"; size="$5"; shift 5
states=("$@"); [ ${#states[@]} -eq 0 ] && states=(loaded loading empty error success)
read -r -a patterns <<< "${PATTERNS:-sectioned-list explained-metric context-sheet long-read day-blocks one-tap-log service-status audio-take plain-draft gentle-checkin flyer-canvas picture-wall tide-scene proof-timer refill-request}"
bundle="dev.iostaste.patternhost"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl install "$device" "$app"
xcrun simctl ui "$device" appearance "$appearance"
xcrun simctl ui "$device" content_size "$size"
xcrun simctl status_bar "$device" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 2>/dev/null || true

mkdir -p "$out"
for pattern in "${patterns[@]}"; do
  for entry in "${states[@]}"; do
    state="${entry%%:*}"; variant=""; name="$state"
    if [ "$entry" != "$state" ]; then variant="${entry#*:}"; name="$state-$variant"; fi
    xcrun simctl terminate "$device" "$bundle" 2>/dev/null || true
    if [ "${SCROLL:-}" = "end" ]; then name="$name-end"; fi
    xcrun simctl launch "$device" "$bundle" -pattern "$pattern" -state "$state" ${variant:+-variant "$variant"} ${SCROLL:+-scroll "$SCROLL"} >/dev/null
    # Map tiles and the sheet need a moment to settle.
    if [ "$pattern" = "context-sheet" ]; then sleep 6; else sleep 3; fi
    xcrun simctl io "$device" screenshot "$out/$pattern--$name.png" >/dev/null 2>&1
    echo "shot $pattern--$name"
  done
done
xcrun simctl terminate "$device" "$bundle" 2>/dev/null || true
