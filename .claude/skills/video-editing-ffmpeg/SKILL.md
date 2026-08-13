---
name: video-editing-ffmpeg
description: ffmpeg(8.0.1 / Homebrew)を使った動画編集スキル。「動画を編集して」「トーク動画を整えて」「無音をカットして」「言い直しをカットして」「ハイライトReelを作って」「動画が真っ暗になる」といった依頼で使う。トーク動画の無音トリム・言い直しカット・ハイライトReel作成の3ワークフローをルーティングする。
---

# video-editing-ffmpeg

このマシンの ffmpeg には `drawtext` / `subtitles` フィルタが無い（`libfreetype` /
`libass` 未導入）。テロップは必ず Pillow で PNG を生成して overlay 合成する。
作業を始める前に必ず `references/ffmpeg-pitfalls.md`（落とし穴3件: drawtext不在 /
`-t` 配置ミス / HDR真っ暗問題）に目を通すこと。

## ワークフロー1: トーク動画の整音トリム（簡易 / ffmpeg のみ）

無音区間トリム → 縦型クロップ/パディング → 音量正規化。AI・文字起こし不要。

- 詳細手順: `references/talk-video-trim.md` の「段階1」を参照
- 落とし穴: `references/ffmpeg-pitfalls.md`
- 使用スクリプト: `scripts/silence_scan.sh` → `scripts/clip_export.sh` → `scripts/concat_clips.sh`

## ワークフロー2: トーク動画の言い直しカット（文字起こし判定 / mlx_whisper）

`mlx_whisper` で文字起こしし、言い直し・フィラー・仕切り直しを検出して該当区間を
秒数指定でカットする。テロップは画面に焼かない（判定にのみ使う）。

- 詳細手順: `references/talk-video-trim.md` の「段階2」を参照
- 落とし穴: `references/ffmpeg-pitfalls.md`
- 使用スクリプト: `scripts/transcribe.sh` →（Claude が保持区間を決定）→
  `scripts/clip_export.sh` → `scripts/concat_clips.sh`

## ワークフロー3: ハイライト Reel（テロップ/ラベル付き）

長尺素材からシーン検出で候補抽出 → サムネイル目視で区間選定 → Pillow でラベル PNG
生成 → overlay 合成 → concat 結合。HDR(HLG) 素材なら必ず tonemap + bt709 強制を
適用する（`clip_export.sh` が自動判定する）。

- 詳細手順: `references/highlight-reel.md` を参照
- 落とし穴: `references/ffmpeg-pitfalls.md`
- 使用スクリプト: `scripts/scene_scan.sh` → `scripts/make_label_png.py` →
  `scripts/clip_export.sh` → `scripts/concat_clips.sh`

## スクリプト一覧

- `scripts/probe_color.sh <input>`: 入力の色特性判定（HLG / SDR を標準出力）
- `scripts/clip_export.sh`: 単一区間の書き出し（`-t` 正配置 / HLG自動tonemap /
  bt709強制 / 縦型整形 / ラベルoverlay）
- `scripts/concat_clips.sh`: concat demuxer で複数クリップ結合
- `scripts/make_label_png.py`: Pillow で透過ラベル PNG 生成
- `scripts/scene_scan.sh`: シーン検出 pts_time 一覧 + サムネイル抽出
- `scripts/silence_scan.sh`: 無音検出 → 保持区間 TSV 出力
- `scripts/transcribe.sh`: mlx_whisper ラッパー（SRT/JSON 出力）
