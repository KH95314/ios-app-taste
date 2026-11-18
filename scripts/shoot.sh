#!/bin/bash
# Screenshots every state of your app on one simulator, in one appearance.
#
#   shoot.sh <device> <app> <out-dir> <appearance> <states-file> [label]
#
#   device       simulator name or UDID (it is booted if needed)
#   app          path to the built .app; its bundle identifier is read from it
#   appearance   light | dark
#   states-file  one state a line:  <name> | <launch arguments>
#                Blank lines and lines starting with # are skipped.
#   label        goes into the file names, e.g. iphone17. Defaults to "phone".
#
# Each file is <out-dir>/<name>--<label>-<appearance>.png. A states file:
#
#   loans--loaded        | -state loaded
#   loans--empty         | -state empty
#   renew--refused       | -state loaded -sheet piranesi -step refused
#
#   SETTLE=6 shoot.sh …      waits six seconds before each screenshot (default 3)
#   ONLY=renew shoot.sh …    shoots only the states whose name contains "renew"
#
# The status bar is set to 9:41 and the text size to the default. An app that
# reads the real clock will disagree with 9:41: give it a launch argument that
# fixes its clock.
set -euo pipefail

if [ $# -lt 5 ]; then sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 1; fi
device="$1"; app="$2"; out="$3"; appearance="$4"; states="$5"; label="${6:-phone}"
bundle=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$app/Info.plist")

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl install "$device" "$app"
xcrun simctl ui "$device" appearance "$appearance"
xcrun simctl ui "$device" content_size large
xcrun simctl status_bar "$device" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 2>/dev/null || true
mkdir -p "$out"

count=0
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|\#*) continue ;; esac
  name=$(printf '%s' "${line%%|*}" | xargs)
  args="${line#*|}"; [ "$args" = "$line" ] && args=""
  [ -z "$name" ] && continue
  if [ -n "${ONLY:-}" ] && [[ "$name" != *"$ONLY"* ]]; then continue; fi
  xcrun simctl terminate "$device" "$bundle" 2>/dev/null || true
  # shellcheck disable=SC2086
  xcrun simctl launch "$device" "$bundle" $args >/dev/null
  sleep "${SETTLE:-3}"
  xcrun simctl io "$device" screenshot "$out/$name--$label-$appearance.png" >/dev/null 2>&1
  echo "shot $name--$label-$appearance"
  count=$((count + 1))
done < "$states"
xcrun simctl terminate "$device" "$bundle" 2>/dev/null || true
echo "$count screenshots in $out"
