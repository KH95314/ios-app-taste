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
# A name and a label take letters, digits, ".", "-" and "_", and do not start
# with ".". Launch arguments are split at spaces, with no quoting and no
# wildcards: an argument cannot hold a space.
#
#   SETTLE=6 shoot.sh …      waits six seconds before each screenshot (default 3)
#   ONLY=renew shoot.sh …    shoots only the states whose name contains "renew"
#
# The status bar is set to 9:41 and the text size to the default. An app that
# reads the real clock will disagree with 9:41: give it a launch argument that
# fixes its clock.
set -euo pipefail
set -f   # no wildcard expansion anywhere, launch arguments included

if [ $# -lt 5 ]; then sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'; exit 1; fi
device="$1"; app="$2"; out="$3"; appearance="$4"; states="$5"; label="${6:-phone}"

# A part of a file name: no separator, no "..", nothing hidden.
safe() { [[ "$1" =~ ^[A-Za-z0-9_-][A-Za-z0-9._-]*$ ]]; }
trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

case "$appearance" in light|dark) ;; *) echo "appearance must be light or dark" >&2; exit 1 ;; esac
safe "$label" || { echo "label \"$label\": use letters, digits, '.', '-' and '_'" >&2; exit 1; }
[ -f "$states" ] || { echo "no states file at $states" >&2; exit 1; }

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
  name=$(trim "${line%%|*}")
  args="${line#*|}"; [ "$args" = "$line" ] && args=""
  [ -z "$name" ] && continue
  if ! safe "$name"; then echo "skipped \"$name\": use letters, digits, '.', '-' and '_'" >&2; continue; fi
  if [ -n "${ONLY:-}" ] && [[ "$name" != *"$ONLY"* ]]; then continue; fi
  read -r -a argv <<< "$args" || true
  file="$out/$name--$label-$appearance.png"
  [ -L "$file" ] && { echo "skipped $name: $file is a symbolic link" >&2; continue; }
  xcrun simctl terminate "$device" "$bundle" 2>/dev/null || true
  xcrun simctl launch "$device" "$bundle" ${argv[@]+"${argv[@]}"} >/dev/null
  sleep "${SETTLE:-3}"
  xcrun simctl io "$device" screenshot "$file" >/dev/null 2>&1
  echo "shot $name--$label-$appearance"
  count=$((count + 1))
done < "$states"
xcrun simctl terminate "$device" "$bundle" 2>/dev/null || true
echo "$count screenshots in $out"
