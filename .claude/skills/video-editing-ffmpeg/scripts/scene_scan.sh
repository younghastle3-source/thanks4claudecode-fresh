#!/bin/bash
# scene_scan.sh -i <input> [-t <しきい値>] [--thumbs <出力ディレクトリ>]
# 標準出力: "pts_time:<秒>" を含む行を検出数だけ出力する。
# --thumbs: 検出時刻のフレームを PNG として指定ディレクトリに書き出す。
set -eu

INPUT=""
THRESHOLD="0.3"
THUMBS_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    -i) INPUT="$2"; shift 2 ;;
    -t) THRESHOLD="$2"; shift 2 ;;
    --thumbs) THUMBS_DIR="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$INPUT" ]; then
  echo "usage: scene_scan.sh -i <input> [-t threshold] [--thumbs dir]" >&2
  exit 1
fi

TIMES=$(ffmpeg -hide_banner -i "$INPUT" -vf "select='gt(scene,${THRESHOLD})',showinfo" -f null - 2>&1 \
  | grep -o "pts_time:[0-9.]*" || true)

if [ -n "$TIMES" ]; then
  printf '%s\n' "$TIMES"
fi

if [ -n "$THUMBS_DIR" ]; then
  mkdir -p "$THUMBS_DIR"
  i=0
  if [ -n "$TIMES" ]; then
    while IFS= read -r line; do
      i=$((i + 1))
      t="${line#pts_time:}"
      ffmpeg -y -ss "$t" -i "$INPUT" -frames:v 1 "$THUMBS_DIR/thumb_$(printf '%02d' "$i")_${t}.png" >/dev/null 2>&1
    done <<EOF
$TIMES
EOF
  fi
fi
