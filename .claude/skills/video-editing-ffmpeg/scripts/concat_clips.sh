#!/bin/bash
# concat_clips.sh -o <出力mp4> <clip1> <clip2> ...
# concat demuxer で複数クリップを結合する。中間リストファイルは tmp/ 配下に作る
# （リポジトリを汚さない）。
set -eu

if [ "${1:-}" != "-o" ]; then
  echo "usage: concat_clips.sh -o <output> <clip1> <clip2> ..." >&2
  exit 1
fi
OUT="$2"
shift 2

if [ $# -lt 1 ]; then
  echo "usage: concat_clips.sh -o <output> <clip1> <clip2> ..." >&2
  exit 1
fi

mkdir -p tmp
LIST="tmp/concat_list_$$.txt"
: > "$LIST"
for clip in "$@"; do
  abspath="$(cd "$(dirname "$clip")" && pwd)/$(basename "$clip")"
  printf "file '%s'\n" "$abspath" >> "$LIST"
done

ffmpeg -y -f concat -safe 0 -i "$LIST" -c copy "$OUT"

rm -f "$LIST"
