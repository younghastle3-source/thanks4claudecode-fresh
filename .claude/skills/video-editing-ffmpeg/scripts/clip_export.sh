#!/bin/bash
# clip_export.sh -i <input> -s <開始秒> -d <長さ秒> -o <出力mp4>
#                [-r <幅x高さ>] [--label <png>] [--label-pos <x:y>] [--dry-run]
#
# 単一区間の書き出し。HLG(HDR) 素材は probe_color.sh で自動判定して
# tonemap + bt709 強制を適用する（references/ffmpeg-pitfalls.md 落とし穴3）。
# -t は必ず対象の -i の直前に置く（落とし穴2）。
# --label は透過PNGを overlay 合成する（落とし穴1の回避策）。
set -eu

INPUT=""
START=""
DUR=""
OUT=""
RES=""
LABEL=""
LABEL_POS=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    -i) INPUT="$2"; shift 2 ;;
    -s) START="$2"; shift 2 ;;
    -d) DUR="$2"; shift 2 ;;
    -o) OUT="$2"; shift 2 ;;
    -r) RES="$2"; shift 2 ;;
    --label) LABEL="$2"; shift 2 ;;
    --label-pos) LABEL_POS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$INPUT" ] || [ -z "$START" ] || [ -z "$DUR" ] || [ -z "$OUT" ]; then
  echo "usage: clip_export.sh -i <input> -s <start> -d <duration> -o <output> [-r WxH] [--label png] [--label-pos x:y] [--dry-run]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COLOR=$(bash "$SCRIPT_DIR/probe_color.sh" "$INPUT")

# HLG のときだけ適用するトーンマップ・色補正フィルタ（SDR には一切付けない）
HLG_VF=""
if [ "$COLOR" = "HLG" ]; then
  HLG_VF="format=gbrpf32le,tonemap=mobius:param=0.5,eq=gamma=1.15:brightness=0.03,format=yuv420p"
fi

# -r 指定時の scale+pad フィルタ（アスペクト維持・レターボックス。歪ませない）
RES_VF=""
if [ -n "$RES" ]; then
  W="${RES%x*}"
  H="${RES#*x}"
  RES_VF="scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:color=black"
fi

VCHAIN=""
if [ -n "$HLG_VF" ] && [ -n "$RES_VF" ]; then
  VCHAIN="${HLG_VF},${RES_VF}"
elif [ -n "$HLG_VF" ]; then
  VCHAIN="$HLG_VF"
elif [ -n "$RES_VF" ]; then
  VCHAIN="$RES_VF"
fi

X264_PARAMS='colorprim=bt709:transfer=bt709:colormatrix=bt709'

if [ -n "$LABEL" ]; then
  # --label 経路: PNG を -loop 1 -framerate <入力fps> で静止画ループ入力として読み込み、
  # overlay に shortest=1 を付けて動画側の終端で終わらせる（shortest 欠落はハングする）。
  FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=nw=1:nk=1 "$INPUT")

  if [ -n "$VCHAIN" ]; then
    VPRE="[0:v]${VCHAIN}[v];"
    VREF="[v]"
  else
    VPRE=""
    VREF="[0:v]"
  fi

  X="0"
  Y="H-400"
  if [ -n "$LABEL_POS" ]; then
    X="${LABEL_POS%%:*}"
    Y="${LABEL_POS#*:}"
  fi

  FILTER="${VPRE}[1:v]fade=t=in:st=0:d=0.3:alpha=1[l];${VREF}[l]overlay=x=${X}:y=${Y}:shortest=1[o]"

  CMD="ffmpeg -y -ss ${START} -t ${DUR} -i \"${INPUT}\" -loop 1 -framerate \"${FPS}\" -i \"${LABEL}\" -filter_complex \"${FILTER}\" -map \"[o]\" -map \"0:a?\" -c:v libx264 -preset veryfast -crf 20 -x264-params \"${X264_PARAMS}\" -c:a aac -movflags +faststart \"${OUT}\""
else
  # -vf 経路（ラベル無し）
  if [ -n "$VCHAIN" ]; then
    VF_OPT=" -vf \"${VCHAIN}\""
  else
    VF_OPT=""
  fi

  CMD="ffmpeg -y -ss ${START} -t ${DUR} -i \"${INPUT}\"${VF_OPT} -map 0:v -map \"0:a?\" -c:v libx264 -preset veryfast -crf 20 -x264-params \"${X264_PARAMS}\" -c:a aac -movflags +faststart \"${OUT}\""
fi

if [ "$DRY_RUN" = 1 ]; then
  printf '%s\n' "$CMD"
  exit 0
fi

eval "$CMD" </dev/null
