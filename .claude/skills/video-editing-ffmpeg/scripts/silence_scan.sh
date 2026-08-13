#!/bin/bash
# silence_scan.sh -i <input> [-n <ノイズ閾値>] [-d <最小無音秒>]
# 標準出力: 「保持区間」を1行1区間、TAB区切り・小数3桁固定で出力する。
# 例: "0.000\t2.000"
set -eu

INPUT=""
NOISE="-40dB"
MINDUR="0.5"

while [ $# -gt 0 ]; do
  case "$1" in
    -i) INPUT="$2"; shift 2 ;;
    -n) NOISE="$2"; shift 2 ;;
    -d) MINDUR="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$INPUT" ]; then
  echo "usage: silence_scan.sh -i <input> [-n threshold] [-d min_silence_duration]" >&2
  exit 1
fi

TOTAL=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$INPUT")

LOG=$(ffmpeg -hide_banner -i "$INPUT" -af "silencedetect=n=${NOISE}:d=${MINDUR}" -f null - 2>&1)

STARTS=$(printf '%s\n' "$LOG" | grep -oE 'silence_start: [0-9.]+' | awk '{print $2}' | tr '\n' ' ')
ENDS=$(printf '%s\n' "$LOG" | grep -oE 'silence_end: [0-9.]+' | awk '{print $2}' | tr '\n' ' ')

python3 -c '
import sys

total = float(sys.argv[1])
starts_raw = sys.argv[2].split()
ends_raw = sys.argv[3].split()
starts = [float(x) for x in starts_raw]
ends = [float(x) for x in ends_raw]

kept = []
cur = 0.0
for s, e in zip(starts, ends):
    if s > cur:
        kept.append((cur, s))
    cur = max(cur, e)
if cur < total:
    kept.append((cur, total))

for a, b in kept:
    if b - a > 0.001:
        sys.stdout.write("%.3f\t%.3f\n" % (a, b))
' "$TOTAL" "$STARTS" "$ENDS"
