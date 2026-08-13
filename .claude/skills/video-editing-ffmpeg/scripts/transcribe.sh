#!/bin/bash
# transcribe.sh -i <input> [--out-dir <dir>] [--format srt|json] [--lang ja] | --help
# mlx_whisper のラッパー。文字起こし結果を SRT/JSON 等で出力する。
set -eu

usage() {
  cat <<'EOF'
使い方 (usage): transcribe.sh -i <input> [--out-dir <dir>] [--format srt|json] [--lang ja]

  mlx_whisper で音声を文字起こしする。言い直し・フィラー検出はこの出力を
  Claude が読んで判定する（ワークフロー2 / references/talk-video-trim.md 段階2）。

  -i <input>        文字起こし対象の音声/動画ファイル
  --out-dir <dir>   出力先ディレクトリ（既定: tmp）
  --format <fmt>    出力形式 srt|json（既定: srt）
  --lang <lang>     言語コード（既定: ja）
  --help            このメッセージを表示して終了する
EOF
}

if [ $# -eq 0 ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

INPUT=""
OUT_DIR="tmp"
FORMAT="srt"
LANG="ja"

while [ $# -gt 0 ]; do
  case "$1" in
    -i) INPUT="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --lang) LANG="$2"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

if ! command -v mlx_whisper >/dev/null 2>&1; then
  echo "エラー: mlx_whisper が見つかりません（想定パス: /opt/homebrew/bin/mlx_whisper）。インストールしてから再実行してください。" >&2
  exit 3
fi

if [ -z "$INPUT" ]; then
  echo "エラー: -i <input> が必須です" >&2
  usage >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
mlx_whisper "$INPUT" --output-dir "$OUT_DIR" --output-format "$FORMAT" --language "$LANG"
