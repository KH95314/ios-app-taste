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
# The recorder is stopped with an interrupt, which is what Control-C sends. A
# recorder stopped any other way can leave the simulator refusing to record
# until it is shut down and booted again.
#
# Then cut the recording into strips with the frames tool.
set -uo pipefail

if [ $# -lt 3 ]; then sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 1; fi
device="$1"; out="$2"; shift 2
base="${out%.*}"
mkdir -p "$(dirname "$out")"
rm -f "$out"

xcrun simctl io "$device" recordVideo --codec=h264 --force "$out" 2> "$base.recorder" &
recorder=$!
for _ in $(seq 1 100); do
  grep -q "Recording started" "$base.recorder" 2>/dev/null && break
  if ! kill -0 "$recorder" 2>/dev/null; then
    echo "the recorder did not start:"; cat "$base.recorder"; exit 2
  fi
  sleep 0.1
done
echo "recorder started at $(python3 -c 'import time; print("%.2f" % time.time())')"

"$@" > "$base.log" 2>&1
status=$?

sleep 1
kill -INT "$recorder" 2>/dev/null
wait "$recorder" 2>/dev/null
rm -f "$base.recorder"
echo "command exit $status; recording in $out; output in $base.log"
exit $status
