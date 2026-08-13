# talk-video-trim.md

トーク動画の整音トリム手順。段階1（AI不要・ffmpeg のみ）と段階2（mlx_whisper による
文字起こし判定カット）の2段階に分かれる。必要な方だけ使ってよい。

## 段階1: 無音トリム・縦型整形・音量正規化（簡易 / ffmpeg のみ）

AI・文字起こしは不要。無音区間を検出して詰め、縦型にクロップ/パディングし、
音量を正規化するだけの軽量ワークフロー。

手順:

1. `scripts/silence_scan.sh -i <input> -n -40dB -d 0.5` で保持区間（無音でない区間）を
   TAB 区切りで取得する。内部では `silencedetect` フィルタを使う。
2. 保持区間ごとに `scripts/clip_export.sh -i <input> -s <開始> -d <長さ> -o <clipN.mp4>` を
   呼び出す（`-r 1080x1920` を付ければ縦型クロップ/パディングも同時に行える）。
3. `scripts/concat_clips.sh -o <output.mp4> <clip1.mp4> <clip2.mp4> ...` で結合する。
4. 音量正規化が必要なら `loudnorm` フィルタ（例: `-af loudnorm=I=-16:TP=-1.5:LRA=11`）を
   段階1の書き出しコマンドに追加する。

検証済みコマンド例（無音検出）:

```
ffmpeg -hide_banner -i in.wav -af "silencedetect=n=-40dB:d=0.5" -f null - 2>&1 \
  | grep -E "silence_(start|end)"
```

## 段階2: 言い直し・フィラーカット（文字起こし判定 / mlx_whisper）

`mlx_whisper` で文字起こしし、Claude が言い直し・フィラー・仕切り直しを検出して
該当区間を秒数指定でカットする。**テロップは画面に焼かない**（判定にのみ使う。
画面にテロップを焼き込みたい場合はワークフロー3のラベル合成を使う）。

手順:

1. `scripts/transcribe.sh -i <input> --format srt --lang ja` で `mlx_whisper` を実行し、
   タイムスタンプ付きの文字起こし（SRT/JSON）を得る。
2. Claude が文字起こしテキストを読み、言い直し・フィラー（「えー」「あのー」等）・
   仕切り直しの区間を秒数で特定する。
3. 保持したい区間ごとに `scripts/clip_export.sh` を呼び出す。
4. `scripts/concat_clips.sh` で結合する。

`transcribe.sh` は `mlx_whisper` が PATH 上に無い環境では非ゼロ終了し、
インストール案内をエラー出力する。
