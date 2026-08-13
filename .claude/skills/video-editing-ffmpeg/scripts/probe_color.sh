#!/bin/bash
# probe_color.sh <input>
# 標準出力: "HLG" または "SDR" の1行のみ。
# 判定: color_transfer が arib-std-b67 / smpte2084 のいずれか、
#       または color_primaries が bt2020 の場合 HLG、それ以外 SDR。
set -eu

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  echo "usage: probe_color.sh <input>" >&2
  exit 1
fi

CT=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=nw=1:nk=1 "$INPUT" 2>/dev/null || true)
CP=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_primaries -of default=nw=1:nk=1 "$INPUT" 2>/dev/null || true)

if [ "$CT" = "arib-std-b67" ] || [ "$CT" = "smpte2084" ] || [ "$CP" = "bt2020" ]; then
  echo "HLG"
else
  echo "SDR"
fi
