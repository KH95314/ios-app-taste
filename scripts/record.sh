#!/bin/bash
# Records a simulator's screen while one command runs, usually one UI test.
#
#   record.sh <device> <out.mp4> <command> [arguments…]
#
#   record.sh "$UDID" tour/testRenew.mp4 \
#     xcodebuild test-without-building -project App.xcodeproj -scheme App \
#       -destination "platform=iOS Simulator,id=$UDID" -derivedDataPath build \
#       -only-testing:AppUITests/Tour/testRenew -test-timeouts-enabled YES
#
# The simulator must be booted. Record one test at a time, so that one
# recording holds one path through the app. Beside <out.mp4> this writes
# <out>.log, the command's output. It prints when the recorder started, as a
# clock time in seconds, and the command's exit status, which is also its own.
#
# The output must end in .mp4 or .mov. The recording and the log are made in a
# private temporary folder and moved into place at the end, replacing an older
# recording of the same name; nothing beside <out.mp4> is touched before then.
#
# The recorder is stopped with an interrupt, which is what Control-C sends, also
# when this script is interrupted or ends early. A recorder stopped any other
# way can leave the simulator refusing to record until it is shut down and
# booted again.
#
# Then cut the recording into strips with the frames tool.
set -uo pipefail

if [ $# -lt 3 ]; then sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit 1; fi
device="$1"; out="$2"; shift 2
case "$out" in
  *.mp4|*.mov) ;;
  *) echo "the output must end in .mp4 or .mov: $out" >&2; exit 1 ;;
esac
base="${out%.*}"
for path in "$out" "$base.log"; do
  if [ -L "$path" ] || { [ -e "$path" ] && [ ! -f "$path" ]; }; then
    echo "$path exists and is not a plain file; not replacing it" >&2; exit 1
  fi
done

work=$(mktemp -d "${TMPDIR:-/tmp}/record.XXXXXX") || exit 1
recorder=""
child=""
finish() {
  if [ -n "$child" ] && kill -0 "$child" 2>/dev/null; then
    kill -TERM "$child" 2>/dev/null
    wait "$child" 2>/dev/null
  fi
  if [ -n "$recorder" ] && kill -0 "$recorder" 2>/dev/null; then
    kill -INT "$recorder" 2>/dev/null
    wait "$recorder" 2>/dev/null
  fi
  recorder=""
  rm -rf "$work"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

xcrun simctl io "$device" recordVideo --codec=h264 --force "$work/video.${out##*.}" 2> "$work/recorder" &
recorder=$!
started=no
for _ in $(seq 1 100); do
  if grep -q "Recording started" "$work/recorder" 2>/dev/null; then started=yes; break; fi
  if ! kill -0 "$recorder" 2>/dev/null; then
    echo "the recorder did not start:" >&2; cat "$work/recorder" >&2; exit 2
  fi
  sleep 0.1
done
if [ "$started" != yes ]; then
  echo "the recorder did not say it had started within 10 seconds:" >&2; cat "$work/recorder" >&2; exit 2
fi
echo "recorder started at $(python3 -c 'import time; print("%.2f" % time.time())')"

# In the background and waited for, so that an interrupt reaches the trap at once.
"$@" > "$work/log" 2>&1 &
child=$!
wait "$child"
status=$?
child=""

sleep 1
kill -INT "$recorder" 2>/dev/null
wait "$recorder" 2>/dev/null
recorder=""

mkdir -p "$(dirname "$out")"
mv -f "$work/video.${out##*.}" "$out" && mv -f "$work/log" "$base.log" || { echo "could not move the recording into place" >&2; exit 2; }
echo "command exit $status; recording in $out; output in $base.log"
exit $status
