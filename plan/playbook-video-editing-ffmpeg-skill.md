# playbook-video-editing-ffmpeg-skill.md

> **今日のセッションで実地検証した ffmpeg 動画編集ワークフローを、再利用可能な Claude Code Skill として `.claude/skills/` に永続化する。**

---

## meta

```yaml
project: thanks4claudecode
branch: feat/video-editing-ffmpeg-skill
base_commit: 609cc09  # main の HEAD。既存スキルの回帰検証の比較元として固定
created: 2026-08-12
issue: null
derives_from: null  # ユーザー資産（スキル）の新規構築であり project.done_when に対応なし
reviewed: false
roles:
  worker: claudecode  # toolstack A（state.md config.roles と一致）
```

---

## goal

```yaml
summary: >
  今日のセッションで実地検証した ffmpeg 動画編集ワークフロー（HLG→SDR トーンマップ、
  Pillow ラベル PNG + overlay 合成、シーン検出、無音トリム、mlx_whisper 判定カット）を、
  .claude/skills/video-editing-ffmpeg/ に SKILL.md + references/ + scripts/ 構成の
  Claude Code Skill として新規構築する
done_when:
  - "DW1: .claude/skills/video-editing-ffmpeg/SKILL.md が存在し、先頭 frontmatter の name が video-editing-ffmpeg で、description に inputs 起動フレーズ6個が全て逐語で含まれ、本文に `## ワークフロー1` `## ワークフロー2` `## ワークフロー3` の H2 見出しが各1本ずつ存在し、各ワークフロー区間内に `references/` へのパス参照行と `scripts/` へのパス参照行がそれぞれ1行以上存在する"
  - "DW2: references/ffmpeg-pitfalls.md に落とし穴3件の H2 見出し（`## 落とし穴1` `## 落とし穴2` `## 落とし穴3`）が存在し、ファイル全体に inputs 検証済み事実の逐語文字列7個（`drawtext`, `libfreetype`, `tonemap=mobius:param=0.5`, `colorprim=bt709:transfer=bt709:colormatrix=bt709`, `arib-std-b67`, `eq=gamma=1.15:brightness=0.03`, `overlay`）が全て含まれ、落とし穴2 の区間内に NG 例と OK 例の両方が `-i` を含むコードブロック行として存在する"
  - "DW3: scripts/clip_export.sh が実行権限付きで存在し、(a) 合成 HLG フィクスチャ（color_transfer=arib-std-b67）に対し開始1秒・長さ3秒で実行すると出力 mp4 の format.duration が 2.85〜3.15 に収まり ffprobe の color_transfer / color_space / color_primaries が3つとも bt709 を返し pix_fmt が yuv420p である、(b) 同入力の `--dry-run` 出力に `tonemap=mobius:param=0.5` と `eq=gamma=1.15:brightness=0.03` と `-map \"0:a?\"` の3文字列が逐語で含まれ、かつ**その dry-run 文字列をそのまま eval して得た出力の映像 md5 が、--dry-run 無しで実行した出力の映像 md5 と一致する**（＝dry-run 文字列が実処理を正直に反映しており、逐語 grep が有効な証拠になっている）、(c) 音声トラックの無い入力（tmp/fixture_videoonly.mp4）に対しても exit 0 で duration > 0 の mp4 を生成する、(d) **同一ピクセルで色タグだけ SDR に書き換えた双子フィクスチャ（tmp/fixture_hlg_sdrtag.mp4）を入力にした出力と、HLG フィクスチャを入力にした出力の映像 md5 が異なる**（＝tonemap 分岐が実際にピクセルを変えている・文字列非依存）"
  - "DW4: scripts/make_label_png.py が日本語文字列を引数に実行でき、出力 PNG が Pillow で mode=RGBA として読め、透明ピクセル（alpha=0）と不透明ピクセル（alpha>0）の両方を含み、その PNG を clip_export.sh のラベル指定で合成した mp4 が生成され duration が 0 より大きく、かつ**同一入力・同一区間をラベル無しで書き出した mp4 と映像 md5 が異なる**（＝ラベルが実際にピクセルとして焼き込まれている）"
  - "DW5: scripts/scene_scan.sh / scripts/silence_scan.sh / scripts/concat_clips.sh / scripts/transcribe.sh の4本が実行権限付きで存在して bash -n を全て通り、scene_scan.sh がシーン変化2箇所の合成フィクスチャで pts_time 行を2行以上出力し、silence_scan.sh が中央2秒無音の合成フィクスチャで保持区間行を2行以上出力する"
  - "DW6: references/talk-video-trim.md と references/highlight-reel.md が存在し、talk-video-trim.md に `## 段階1` と `## 段階2` の H2 見出しが各1本存在して段階2区間に `mlx_whisper` が含まれ、highlight-reel.md に `## 手順` H2 見出しが存在して区間内に番号付きステップ行が5行以上ある"
  - "DW7: 回帰: 追跡済み差分（base_commit 609cc09 比）と未追跡ファイル（git status --porcelain）を合わせた全変更ファイル集合において、`.claude/skills/video-editing-ffmpeg/` 以外の `.claude/skills/` 配下ファイルが0件であり、かつ I-12 の除外集合（`.claude/skills/video-editing-ffmpeg/` 配下・`plan/playbook-video-editing-ffmpeg-skill.md`・`state.md`・`docs/repository-map.yaml`・`.gitignore`・`.claude/agents/critic.md`・`plan/playbook-setup-instagram-skills.md`・`.claude/worktrees/`・`tmp/` 配下）に該当しないファイルが0件である"
```

---

## inputs（合意済み素材 / worker の唯一の正典）

> **本セクションが worker の参照すべき唯一の正典（source of truth）である。**
> CLAUDE.md §7「Trust state files over chat history」に従い、チャット文脈ではなく本ファイルに固定する。
> **test_command が以下から抜き出した文字列を `grep -qF` で逐語照合する。表現を変えると FAIL する。**

### I-1. 検証済み環境事実（2026-08-12 実測、このマシン固有）

```yaml
ffmpeg:
  version: "8.0.1 (Homebrew)"
  存在しないフィルタ: [drawtext, subtitles, ass, zscale]
  存在しないビルドフラグ: [--enable-libfreetype, --enable-libass]
  存在するフィルタ: [tonemap, overlay, eq, select, showinfo, silencedetect, loudnorm, afade, fade, scale, pad, concat, xfade, acrossfade]
  検証コマンド: "ffmpeg -hide_banner -filters | grep -cw drawtext  # => 0"

python:
  pillow: "12.3.0 (import PIL OK)"

mlx_whisper:
  path: /opt/homebrew/bin/mlx_whisper
  出力形式: "--output-format {txt,vtt,srt,tsv,json,all}"
  言語指定: "--language ja"

日本語フォント（Pillow 用・実在確認済み）:
  - "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
  - "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
  - "/Library/Fonts/Arial Unicode.ttf"
```

### I-2. 落とし穴1 — drawtext / subtitles が使えない

```
事象: このマシンの ffmpeg には libfreetype/libass が入っておらず、
      drawtext フィルタも subtitles フィルタも存在しない（grep -cw drawtext => 0）。
回避: Python(Pillow) でテロップ/ラベルを「透過PNG」として事前生成し、
      ffmpeg の overlay フィルタで合成する。
```

### I-3. 落とし穴2 — `-t` の配置ミスで全編エンコードされる

```
事象: `-ss S -i input.mp4 -t D -i label.png` と書くと、-t D が input.mp4 ではなく
      2番目の入力 label.png の入力オプションとして解釈され、動画側の長さ制限が効かず
      全編が再エンコードされる。
実測: 6秒素材を -ss 1 で切り出した場合
      NG（-t を2番目の -i の前）: duration = 5.013991
      OK（-t を対象の -i の直前）: duration = 3.000000
回避: -t は必ず対象の -i の直前に置く。
NG例: ffmpeg -ss 1 -i input.mp4 -t 3 -i label.png ...
OK例: ffmpeg -ss 1 -t 3 -i input.mp4 -loop 1 -framerate 30 -i label.png ...
※ -loop 1 / -framerate は label.png 側の入力オプション（I-5 参照）。
   これらを足しても -t が対象 -i の直前にある構造は変わらない。
```

### I-4. 落とし穴3 — HDR(HLG) 素材が SDR 変換後に真っ暗になる

```
事象: iPhone 等で撮影した HLG(arib-std-b67)/BT.2020 タグ付き 10bit 素材を
      -pix_fmt yuv420p で 8bit 化しただけだと、コンテナの色タグ（bt2020nc / arib-std-b67）
      が残り、プレイヤーが HDR として解釈して画面が真っ暗になる。
回避:
  1. tonemap=mobius:param=0.5 でトーンマップ（このビルドに zscale が無いため tonemap を使う）
     ※ tonemap の入力は浮動小数へ変換する必要があるため format=gbrpf32le を前段に置く
  2. eq=gamma=1.15:brightness=0.03 で明るさを補正
  3. 出力時に -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709" で
     libx264 の VUI タグを bt709 に上書きする
     ※ コンテナレベルの -color_primaries / -color_trc / -colorspace だけでは
       libx264 の VUI に反映されず不十分（実測確認済み）
検証済み実コマンド（このまま動作する）:
  ffmpeg -y -ss 1 -t 3 -i in.mp4 \
    -vf "format=gbrpf32le,tonemap=mobius:param=0.5,eq=gamma=1.15:brightness=0.03,format=yuv420p" \
    -c:v libx264 -preset veryfast -crf 20 \
    -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709" \
    -c:a aac -movflags +faststart out.mp4
検証結果: pix_fmt=yuv420p / color_space=bt709 / color_transfer=bt709 / color_primaries=bt709 / duration=3.000000
```

### I-5. ラベル合成の検証済み実コマンド（★2026-08-13 修正・ピクセル実測で再検証済み）

> **★ 旧版のレシピには実バグがあった（3回目レビュー Critical C-1）。**
> 旧版は `-i label.png`（＝1フレームしか無い静止画入力）に対して
> `fade=t=in:st=0:d=0.3:alpha=1` を掛けていた。PNG 入力のフレームは t=0 の1枚だけであり、
> そのフレームの alpha 係数は fade-in の開始点＝0（完全透明）である。
> その完全透明な唯一のフレームが overlay の `eof_action=repeat`（既定）で最後まで繰り返されるため、
> **ラベルは全編で一度も表示されない**。旧版の「検証結果: duration=3.000000」は
> 動画長しか見ておらず、表示の有無を一度も確認していなかった。
> 修正: PNG を `-loop 1 -framerate <入力fps>` で静止画ループ入力として読み込み、
> overlay を `shortest=1` にして入力側（動画）の終端で終わらせる。

```
FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=nw=1:nk=1 in.mp4)
ffmpeg -y -ss 1 -t 3 -i in.mp4 -loop 1 -framerate "$FPS" -i label.png \
  -filter_complex "[0:v]format=gbrpf32le,tonemap=mobius:param=0.5,eq=gamma=1.15:brightness=0.03,format=yuv420p[v];[1:v]fade=t=in:st=0:d=0.3:alpha=1[l];[v][l]overlay=x=0:y=H-400:shortest=1[o]" \
  -map "[o]" -map "0:a?" -c:v libx264 -preset veryfast -crf 20 \
  -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709" -c:a aac good.mp4
検証結果（2026-08-13 実測）:
  duration=3.000000（ラベル PNG を入力に足しても動画長が伸びない）
  フレーム数もラベル無し出力と一致（60/60・2秒素材で実測）
  ★ラベル無し出力との映像 md5 が異なる（＝ラベルが実際にピクセルとして焼き込まれている）
    旧レシピ: 映像 md5 がラベル無し出力と完全一致 = 一度も表示されていなかった
  ★fade も正しく効く（白ラベルの画素を実測: t=0.0 → ff1700(素材色) /
    t=0.15 → ff978a(中間) / t=1.5 → fdfdfd(白・完全表示)）
  ※ -loop 1 は label.png 側の入力オプションであり、-t は依然として対象 -i の直前にある（I-3 は不変）
  ※ r_frame_rate は "30/1" 形式で返るが -framerate にそのまま渡して動作する（実測）
```

> **★ スクリプト化時の唯一の変更点**: 上記レシピの `-map "0:a?"` は
> **optional map であることが必須**（I-11 必須挙動4）。
> `-map 0:a`（`?` 無し）を音声トラックの無い入力に渡すと
> `Stream map '' matches no streams.` / Invalid argument で即失敗する
> （実測 2026-08-13: rc=234・出力なし。`-vf` 経路・`filter_complex` 経路とも同じメッセージ）。
> それ以外（filter_complex の中身、-x264-params、fade/overlay/loop/framerate の指定）は**一字も変えない**。

### I-6. シーン検出 / 無音検出の検証済み実コマンド

```
シーン検出:
  ffmpeg -hide_banner -i in.mp4 -vf "select='gt(scene,0.3)',showinfo" -f null - 2>&1 \
    | grep -o "pts_time:[0-9.]*"
  検証結果: 2秒/4秒でカットが入る合成素材に対し pts_time:2 / pts_time:4 の2行を出力

無音検出:
  ffmpeg -hide_banner -i in.wav -af "silencedetect=n=-40dB:d=0.5" -f null - 2>&1 \
    | grep -E "silence_(start|end)"
  検証結果: 中央2秒無音の合成音声に対し
    silence_start: 1.999977 / silence_end: 4.000045 | silence_duration: 2.000068
```

### I-7. スキル構成（合意済み・この構成で作る）

> **判断: 1スキル・3ワークフロー構成を採用する。**
> 理由: 3つの落とし穴（特に `-t` 配置と HLG）は両ワークフロー共通の知識であり、
> スキルを2個に分けると同じ知識が2箇所に重複して drift する。
> 既存 `threads-pdca` スキルも「1 SKILL.md に4ワークフロー + references/」構成であり、
> 本リポジトリの確立された慣例と一致する。

```
.claude/skills/video-editing-ffmpeg/
├── SKILL.md                      # frontmatter + 3ワークフローのルーティング（短く保つ）
├── references/
│   ├── ffmpeg-pitfalls.md        # 落とし穴3件（全ワークフロー共通の中核知識）
│   ├── talk-video-trim.md        # ワークフロー1・2 の詳細手順
│   └── highlight-reel.md         # ワークフロー3 の詳細手順
└── scripts/
    ├── probe_color.sh            # 入力の色特性判定（HLG / SDR を標準出力）
    ├── clip_export.sh            # 単一区間の書き出し（-t 正配置 / HLG自動tonemap / bt709強制 / 縦型整形 / ラベルoverlay）
    ├── concat_clips.sh           # concat demuxer で複数クリップ結合
    ├── make_label_png.py         # Pillow で透過ラベル PNG 生成
    ├── scene_scan.sh             # シーン検出 pts_time 一覧 + サムネイル抽出
    ├── silence_scan.sh           # 無音検出 → 保持区間 TSV 出力
    └── transcribe.sh             # mlx_whisper ラッパー（SRT/JSON 出力）
```

**補足1（前例の明示）**: `scripts/` サブディレクトリを持つスキルは本リポジトリで**初**である。
既存25スキルは `SKILL.md` 単体、または `SKILL.md` + `references/` 構成のみ。
これは規約違反ではなく、**実行可能スクリプトを同梱する新しい前例**として意図的に導入する。
理由: ffmpeg のコマンド列は長大かつ引用符地雷が多く、SKILL.md に貼るとコピペ事故が起きる。
スクリプト化して引数契約（I-11）で固定するほうが再現性が高い。

**補足2（実行権限の統一ルール）**: `scripts/` 配下の**全ファイル**（`.sh` / `.py` とも）に
shebang を付け `chmod +x` する。`.py` はテストでは `python3` 経由で呼ぶが、権限は統一する。

**補足3（clip_export.sh の所有権と実行順序）**:
`clip_export.sh` は **p2 が唯一の所有者**であり、p2 完了時点で CLI 契約（I-11）と実装を確定させる。
p3・p4 は clip_export.sh を**呼び出すだけで、変更しない**。
これにより p3 と p4 は**並行実行可能**である（両者とも depends_on: [p2] のみ）。

> **★ `--label` / `--label-pos` 経路も p2 で実装する（所有権の例外を作らない）。**
> p2 は make_label_png.py に依存しない検証用 PNG（ffmpeg の `color=...,format=rgba` で生成）を使って
> `--label` / `--label-pos` のスモークテストまで完了させる（p2.10）。
> p3.3 は **make_label_png.py が生成した実 PNG での受入検証に限定**し、
> clip_export.sh の実装追加は行わない。
> （旧版は `--label` を要求する subtask が p3.3 にしか無く、p2 完了時点で `--label` が未実装のまま
> p3 に入る設計になっていた。p3 の worker が p2 所有ファイルを編集せざるを得なくなるため修正した。）

p3 または p4 で clip_export.sh の不具合が見つかった場合は、p2 に差し戻して修正する
（p3/p4 側で個別にパッチを当てると、もう一方の Phase の検証結果が無効になる）。
**差し戻し時の再実行範囲は notes.実行順序 に規定する（p2.3〜p2.10 および p3/p4 の
clip_export.sh 依存 subtask のうち完了済みのものを全て再実行する）。**

### I-8. ワークフロー定義（SKILL.md にこの3本を H2 見出しで置く）

```yaml
ワークフロー1: "トーク動画の整音トリム（簡易 / ffmpeg のみ）"
  内容: 無音区間トリム → 縦型クロップ/パディング → 音量正規化。AI・文字起こし不要。
  使用: silence_scan.sh → clip_export.sh → concat_clips.sh

ワークフロー2: "トーク動画の言い直しカット（文字起こし判定 / mlx_whisper）"
  内容: mlx_whisper で文字起こしし、言い直し・フィラー・仕切り直しを検出して
        該当区間を秒数指定でカットする。テロップは画面に焼かない（判定にのみ使う）。
  使用: transcribe.sh → （Claude が保持区間を決定）→ clip_export.sh → concat_clips.sh

ワークフロー3: "ハイライト Reel（テロップ/ラベル付き）"
  内容: 長尺素材からシーン検出で候補抽出 → サムネイル目視で区間選定 →
        Pillow でラベル PNG 生成 → overlay 合成 → concat 結合。
        HDR(HLG) 素材なら必ず tonemap + bt709 強制を適用する。
  使用: scene_scan.sh → make_label_png.py → clip_export.sh → concat_clips.sh
```

### I-9. 起動フレーズ（frontmatter の description にこの6語句を逐語で含める）

```
「動画を編集して」
「トーク動画を整えて」
「無音をカットして」
「言い直しをカットして」
「ハイライトReelを作って」
「動画が真っ暗になる」
```

**注記（description は物理1行で書くこと）**:
p5.2 / p_final.1 の検証は `grep '^description:'` で**1行を抜き出して**6フレーズを照合する。
そのため SKILL.md の frontmatter の `description:` は
**folded scalar（`description: >`）や複数行にせず、必ず物理1行**で書くこと。
（本 playbook 自身の `goal.summary` は `>` を使っているが、それは playbook 側の都合であり
SKILL.md の frontmatter には適用しない。両者の書式が違うのは意図的である。）
Claude Code の SKILL frontmatter は1行 description が標準形であり、実害はない。

### I-10. 合成テストフィクスチャ（tmp/ に生成する。実素材に依存しない）

```
HLG フィクスチャ（tmp/fixture_hlg.mp4）:
  ffmpeg -y -f lavfi -i testsrc2=size=1080x1920:rate=30:duration=6 \
    -f lavfi -i sine=frequency=440:duration=6 \
    -c:v libx265 -tag:v hvc1 -pix_fmt yuv420p10le \
    -x265-params "colorprim=bt2020:transfer=arib-std-b67:colormatrix=bt2020nc" \
    -c:a aac -t 6 tmp/fixture_hlg.mp4
  ※ -x265-params を使わず -color_trc arib-std-b67 だけ渡すと color_transfer=unknown になる（実測）

HLG 双子フィクスチャ（tmp/fixture_hlg_sdrtag.mp4）★tonemap を文字列非依存で検証する唯一の手段:
  ffmpeg -y -i tmp/fixture_hlg.mp4 -c copy \
    -bsf:v hevc_metadata=colour_primaries=1:transfer_characteristics=1:matrix_coefficients=1 \
    tmp/fixture_hlg_sdrtag.mp4
  用途: fixture_hlg.mp4 と**ピクセルが完全に同一**（-c copy なので再エンコードなし）で、
        色タグだけ bt709（SDR）に書き換えた双子。
        clip_export.sh に両方を通し、出力の映像 md5 が**異なる**ことをアサートすると、
        「HLG 分岐が実際にピクセルを変えている」＝ tonemap が実装されていることを
        文字列 grep に一切依存せず証明できる（notes の絶対ルールに対応）。
  ※ 実測確認済み（2026-08-13）:
     pix_fmt=yuv420p10le（fixture_hlg と同一）/ color_transfer,color_space,color_primaries = 全て bt709
     → probe_color.sh は SDR を返す（fixture_hlg.mp4 は HLG）
     tonemap 実装あり → 2出力の映像 md5 が異なる（PASS）
     tonemap 未実装（-vf が format=yuv420p だけ）→ 2出力の映像 md5 が完全一致（FAIL-tonemap-noop）
     ★重要: pix_fmt=yuv420p のアサートだけでは
       「format=yuv420p は持つが tonemap は無い」実装を検出できない（実測確認済み）。
       この双子フィクスチャ検証がそこを埋める。

シーン変化フィクスチャ（tmp/fixture_scenes.mp4）★音声トラック必須:
  ffmpeg -y -f lavfi -i "color=c=red:s=640x480:r=30:d=2" \
    -f lavfi -i "color=c=blue:s=640x480:r=30:d=2" \
    -f lavfi -i "color=c=green:s=640x480:r=30:d=2" \
    -f lavfi -i "sine=f=440:d=6" \
    -filter_complex "[0:v][1:v][2:v]concat=n=3:v=1:a=0[v]" \
    -map "[v]" -map 3:a -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest tmp/fixture_scenes.mp4
  ※ 音声トラックは必須。映像のみだと clip_export.sh の音声マップで失敗する（I-11 参照）。
  ※ 実測確認済み: 音声を足してもシーン検出は 2 件のまま（pts_time:2 / pts_time:4）。
     duration=6.000000 / 640x480 / video+audio 2ストリーム。

無音入りフィクスチャ（音声のみ / tmp/fixture_silence.wav）:
  ffmpeg -y -f lavfi -i "sine=f=440:d=2" -f lavfi -i "anullsrc=r=44100:cl=mono:d=2" \
    -f lavfi -i "sine=f=440:d=2" \
    -filter_complex "[0:a][1:a][2:a]concat=n=3:v=0:a=1[a]" -map "[a]" -ar 44100 tmp/fixture_silence.wav
  用途: silence_scan.sh 単体の検出精度確認（p4.1 / p_final.5）

無音入り映像+音声フィクスチャ（tmp/fixture_silence_av.mp4）★ワークフロー1 の end-to-end 用:
  ffmpeg -y -f lavfi -i "testsrc2=size=640x480:rate=30:duration=6" \
    -f lavfi -i "sine=f=440:d=2" -f lavfi -i "anullsrc=r=44100:cl=mono:d=2" \
    -f lavfi -i "sine=f=440:d=2" \
    -filter_complex "[1:a][2:a][3:a]concat=n=3:v=0:a=1[a]" \
    -map 0:v -map "[a]" -c:v libx264 -pix_fmt yuv420p -c:a aac -t 6 tmp/fixture_silence_av.mp4
  用途: silence_scan.sh → clip_export.sh → concat_clips.sh の end-to-end 検証（p4.2）
  ※ 実測確認済み: duration=6.000000 / video+audio 2ストリーム /
     silencedetect(n=-40dB:d=0.5) → silence_start: 1.999977 / silence_end: 4.000045
     → 保持区間 2 本（0.000-2.000 / 4.000-6.000、合計 4.0 秒）
     → 2 クリップを切り出して concat した実測出力 duration = 4.023220（< 6.0）

映像のみフィクスチャ（tmp/fixture_videoonly.mp4）★音声トラックを絶対に付けない:
  ffmpeg -y -f lavfi -i "testsrc2=size=640x480:rate=30:duration=4" \
    -c:v libx264 -pix_fmt yuv420p tmp/fixture_videoonly.mp4
  用途: clip_export.sh の `-map "0:a?"`（optional map / I-11 必須挙動4）を**実行時に**検証する唯一のフィクスチャ。
        ★経路ごとに使う: `-vf` 経路 = p2.8 / p_final.3(c)、`--label`（filter_complex）経路 = p2.10(3)
  ※ ★このフィクスチャに音声を足してはならない。足した瞬間に -map "0:a?" の検証が消滅する。
     p2.1 / p_final.0 で「音声ストリーム数 = 0」を明示アサートしているのはこのため。
  ※ 実測確認済み（2026-08-12）:
     duration=4.000000 / 音声ストリーム 0 本 / color_transfer,color_space,color_primaries = 全て unknown
     （→ probe_color.sh は SDR を返す。tonemap 分岐には入らない）
     -map 0:a  + この入力 → "Stream map '' matches no streams" で即失敗（exit 非0・出力なし）
     -map "0:a?" + この入力 → 成功し duration=2.000000 の切り出しが得られる
```

### I-11. スクリプト CLI 契約（test_command が前提とするインターフェース。この通りに実装すること）

> **test_command はここに書かれた引数名でスクリプトを呼ぶ。引数名を変えると全 subtask が FAIL する。**

```
probe_color.sh <input>
  出力: 標準出力に "HLG" または "SDR" の1行のみ
  判定: ffprobe の color_transfer が arib-std-b67 / smpte2084 のいずれか、
        または color_primaries が bt2020 の場合 HLG、それ以外 SDR

clip_export.sh -i <input> -s <開始秒> -d <長さ秒> -o <出力mp4>
               [-r <幅x高さ>] [--label <png>] [--label-pos <x:y>] [--dry-run]
  必須: -i / -s / -d / -o
  -r        : scale + pad で指定解像度に収める（アスペクト維持・歪ませない）
              ★検証（生成物・文字列非依存 / 4回目レビュー Major-2）:
                width,height の一致だけでは `scale=${W}:${H}`（pad 無し・アスペクト破壊）実装を
                検出できない（実測確認済み: 歪ませる実装で旧 p2.6 が PASS した）。
                p2.6 が cropdetect で**実映像領域**を取り出し、
                (i) 実映像領域のアスペクト比が入力のアスペクト比と一致する（許容 2%）
                (ii) 実映像領域が出力の幅または高さに接している（＝収まりきっている / 拡大漏れ検出）
                (iii) 実映像領域が出力全面ではない（＝レターボックス帯が存在する）
                の3点をアサートする。
                実測（2026-08-13 / 入力 640x480 → -r 1080x1920）:
                  scale+pad 実装      → crop=1080:810:0:554（比 1.3333 = 入力比）→ PASS
                  scale のみ（歪み）  → crop=1080:1920:0:0（比 0.5625）→ FAIL-stretched
                  pad のみ（拡大なし）→ crop=640:480:220:720 → FAIL-notfitted
  --label   : 透過PNG を overlay 合成。fade=t=in:alpha=1 でフェードインさせる
              ★検証（生成物 / 4回目レビュー Minor-2）: fade の有無は「ラベル有無の md5 差分」では
                検出できない（fade を外しても差分は出る）。p2.10 がラベル矩形内の画素を
                t=0.05 と t=1.5 で実測し、G チャンネルの差が 30 以上あることをアサートする。
                実測（2026-08-13 / 白ラベル on 赤素材）:
                  fade あり → t=0.05: (255,75,52) / t=1.5: (255,255,255) → 差 180 → PASS
                  fade なし → t=0.05: (255,255,255) / t=1.5: (255,255,255) → 差 0 → FAIL-nofade
              ★★ PNG 入力は必ず `-loop 1 -framerate <入力動画の r_frame_rate> -i <png>` の形で読み込み、
                 overlay には `shortest=1` を付けること（I-5）。
                 `-i <png>` だけで読み込むと PNG は1フレームしか無く、
                 そのフレームの fade-in alpha=0（完全透明）が eof_action=repeat で全編に繰り返され、
                 **ラベルが一度も表示されない**（＝出力が「ラベル無し」と完全に同一ピクセルになる）。
                 shortest=1 を付けないと、-loop 1 の無限入力で終端しなくなる。
                 ★実測（2026-08-13）: shortest=1 を外した実装は**終了しない**（20秒で
                   SIGALRM 強制終了・出力ファイルなし）。すなわち FAIL ではなく**ハング**する。
                   → p2.10 の最初の --label 実行は `perl -e 'alarm shift; exec @ARGV' 60 bash ...`
                     でラップし、ハングを FAIL-exit-or-hang に変換する（実測確認済み）
                 → p2.10 の「ラベルあり出力とラベルなし出力の映像 md5 が異なる」で担保する
  --label-pos : overlay の座標。★引数 "<x>:<y>" を受け取り、フィルタに
              overlay=x=<x>:y=<y> の形で**そのまま逐語展開**する（例: --label-pos 10:20
              → overlay=x=10:y=20）。未指定時の既定は overlay=x=0:y=H-400（I-5）。
              ★検証（生成物・文字列非依存 / 4回目レビュー Major-1）:
                --dry-run 出力への 'overlay=x=10:y=20' の grep **だけでは不十分**。
                実測（2026-08-13）: dry-run では要求どおりの座標を出力し、実行時だけ既定位置に
                差し替える実装を作ると、旧 p2.10 / p3.3 / p_final.4 / p2.9 / p_final.3 が
                **全て PASS した**。
                → p2.10 が同一素材・同一ラベルを2座標（10:20 と 300:300）で書き出し、
                  映像 md5 が**異なる**ことをアサートする（実測: 正しい実装 → 異なる /
                  座標無視の実装 → 完全一致で FAIL-labelpos-ignored）。
                  併せて p2.10 は `--label` 経路にも eval 同一性検証を課す（下記）。
  --dry-run : ★実行せず（＝出力ファイルを1バイトも書かず）、組み立てた ffmpeg コマンド文字列を
              標準出力に1行以上出して exit 0。
              ★出力文字列の要件（p2.9 / p_final.3 が grep -qF で逐語照合する）:
                - 先頭コマンド名として 'ffmpeg' を含む
                - HLG 入力時は 'tonemap=mobius:param=0.5' と 'eq=gamma=1.15:brightness=0.03' を含む
                - 音声マップを **ダブルクォート込みの逐語 `-map "0:a?"`** の形で含む
                  （`-map 0:a?` のようにクォートを外して出力すると FAIL する）
                - `--label-pos <x>:<y>` 指定時は `overlay=x=<x>:y=<y>` を逐語で含む
              ★★ --dry-run 文字列と実処理の**同一性**が契約である（3回目レビュー M-2）:
                - --dry-run が出す文字列は **そのまま `eval` して実行できる**（＝シェル的に妥当な
                  クォーティングがされている）こと
                - **その文字列を eval して得た出力と、--dry-run 無しで実行した出力の映像 md5 が
                  一致する**こと。すなわち「dry-run 用の理想文字列」と「実際に実行するコマンド」を
                  別々に組み立ててはならない
                - 推奨実装（この形にすれば同一性は構造的に保証される）:
                    CMD="ffmpeg ... "                       # 1本の文字列として組み立てる
                    if [ "$DRY" = 1 ]; then printf '%s\n' "$CMD"; exit 0; fi
                    eval "$CMD" </dev/null                  # dry-run と同じ文字列を実行する
                - 理由: この同一性が無いと、p2.9 / p_final.3 の tonemap・optional map の
                  逐語 grep は「検証されていない前提」の上に乗るだけの飾りになる
                  （実測: dry-run だけ tonemap 入りの文字列を printf し、実行パスには
                   tonemap を入れない実装で p2.3〜p2.10 / p_final.3 が全て PASS した）
                - ★★ **同一性検証は経路（-vf 経路 / filter_complex 経路）ごとに個別に必要**
                  （4回目レビュー Major-1）。片方の経路にしか eval 同一性が無いと、
                  もう一方の経路の逐語 grep は再び「土台の無い飾り」に戻る。
                  実測（2026-08-13）: eval 同一性を持つのが `-vf` 経路（p2.9）だけだった時点では、
                  `--label` 経路で dry-run と実処理を別々に組み立てる実装が全 subtask を通過した。
                  → `-vf` 経路 = p2.9 / p_final.3、`--label`（filter_complex）経路 = p2.10 が
                    それぞれ eval 同一性をアサートする（実測: 座標差し替え実装は
                    FAIL-dryrun-mismatch でも検出される）
                → p2.9 / p2.10 / p_final.3 の「dry-run を eval した出力と実 run 出力の映像 md5 一致」で担保する
              ※ 標準出力に出すのはコマンド文字列のみ（診断ログは標準エラーへ）
  必須挙動1 : -t は必ず対象の -i の直前に置く（I-3）
  必須挙動2 : probe_color.sh が HLG を返したときのみ
              format=gbrpf32le,tonemap=mobius:param=0.5,eq=gamma=1.15:brightness=0.03,format=yuv420p を適用
              （SDR 入力ではこの区間を一切付けない → p2.5 の否定形検証で担保）
              ★検証（文字列非依存）: p2.4 / p_final.3 が
                (i) 出力 pix_fmt が yuv420p であること（HLG 素材は 10bit の yuv420p10le なので、
                    映像フィルタを一切通さない実装は yuv420p10le のまま出力され検出される）
                (ii) fixture_hlg.mp4 と双子の fixture_hlg_sdrtag.mp4（同一ピクセル・SDR タグ / I-10）
                     をそれぞれ入力にした出力の映像 md5 が**異なる**こと
                     （＝HLG 分岐が実際にピクセルを変えている）
                をアサートする。(ii) が無いと「format=yuv420p は持つが tonemap は無い」実装を
                取り逃す（実測確認済み）
  必須挙動3 : 出力は常に -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709" を付ける（I-4）
              ★検証（生成物）: HLG 経路は p2.4 / p_final.3、**SDR 経路は p2.5** が
                出力の color_transfer / color_space / color_primaries = bt709 を実測する。
                「常に」が契約なので SDR 経路にも検証が要る（4回目レビュー時の棚卸しで追加）。
                実測（2026-08-13 / 入力 fixture_scenes.mp4 は3タグとも unknown）:
                  -x264-params あり → 出力3タグ = bt709 / 外した実装 → 出力3タグ = unknown（検出可）
  必須挙動4 : ★音声マップは必ず optional map の -map "0:a?" を使う（-map 0:a は禁止）
              理由: 音声トラックの無い入力に -map 0:a を渡すと
              "Stream map '' matches no streams." / Invalid argument で即失敗する
              （実測 2026-08-13: rc=234・出力ファイルなし）。
              `?` 付きの optional map なら音声なし入力でも黙ってスキップして成功する。
              ★★ これは `-vf` 経路と `--label`（filter_complex）経路の**両方**に適用される。
                 実測（3回目レビュー M-1）: `-vf 経路だけ -map "0:a?" / --label 経路は -map 0:a`
                 という実装を作ると、p2.3〜p2.10 が**全て PASS してしまう**
                 （p2.8 は --label を付けずに呼び、p2.10 は overlay 座標しか grep していなかったため）。
                 → p2.10 で「音声なし入力 + --label」の実行成功と
                   dry-run 文字列への `-map "0:a?"` 逐語照合の**両方**を要求する
              ★補足: -map を1つでも書いた時点で ffmpeg の既定ストリーム選択は無効になるため、
              映像側も必ず明示 map すること（-vf 経路は -map 0:v、filter_complex 経路は -map "[o]"）。
              映像 map を書き忘れると音声のみの mp4 が出力され、p2.6/p2.7 の解像度検査で FAIL する。
              ★検証: 音声なし入力での実動作は
              -vf 経路 = p2.8 / p_final.3(c)、filter_complex 経路 = p2.10 が
              tmp/fixture_videoonly.mp4（I-10・音声0本）で担保し、
              コマンド文字列は p2.9 / p2.10 / p_final.3(b) が --dry-run で逐語照合する
              （＝経路2本 × 実行/文字列2層 の防御）。

concat_clips.sh -o <出力mp4> <clip1> <clip2> ...
  concat demuxer 用リストは tmp/ 配下に作る（リポジトリを汚さない）
  ※ 「リポジトリを汚さない」の検証は p_final.7（追跡差分 + 未追跡ファイルの和集合で
     除外集合外が0件）が担う。リストファイルの**削除**そのものは意図的に未検証（I-13）。

make_label_png.py --text <文字列> --out <出力png> [--font <ttf/ttc>] [--size <px>] [--width <px>]
  出力: mode=RGBA の透過PNG（背景 alpha=0、文字は縁取りつきで alpha>0）
  --font 未指定・または指定パスが存在しない場合は I-1 のフォント候補を順に試す（例外死しない）
  ★検証（生成物）: p3.1 / p3.2 とも alpha の min=0 / max>0 を実測する。
    p3.2（フォールバック）で「exit 0 かつ PNG が存在する」だけを見ると、
    フォールバック時に**空（全透明）の PNG を書く実装**が通ってしまうため、
    p3.2 にも alpha 実測を課す（4回目レビュー時の棚卸しで追加）。
  ※ --size / --width と「縁取り」は意図的に未検証（I-13）。

scene_scan.sh -i <input> [-t <しきい値>] [--thumbs <出力ディレクトリ>]
  標準出力: "pts_time:<秒>" を含む行を検出数だけ出力
  --thumbs : 検出時刻のフレームを PNG または JPG として指定ディレクトリに書き出す
  ★検証（生成物）:
    - -t の配線: p3.4 が `-t 0.3` → 2件、`-t 0.99` → **0件** を実測する
      （実測 2026-08-13。しきい値をハードコードした実装を検出できる）
    - --thumbs の**検出時刻対応**: p3.5 が生成画像の代表色を実測し、
      青優勢（t=2 のフレーム）と緑優勢（t=4 のフレーム）が**両方**存在することを要求する。
      枚数だけの検査では「先頭フレームを2枚出すだけ」の実装が通る
      （実測 2026-08-13: 正しい実装 → 青(0,0,253)・緑(0,127,0) / 先頭2枚実装 → 赤のみで FAIL）

silence_scan.sh -i <input> [-n <ノイズ閾値>] [-d <最小無音秒>]
  標準出力: 「保持区間」を1行1区間で出力。
  形式: ★TAB 区切り固定 "<開始秒>\t<終了秒>"（カンマ区切りは不可）
        - 数値は小数3桁固定（例: "0.000\t2.000"）
        - 保持区間以外のログ・ヘッダ行を標準出力に混ぜない（診断は標準エラーへ）
        - clip_export.sh には -s <開始秒> -d <終了秒 - 開始秒> に変換して渡す
  ★検証（生成物 = スクリプトの標準出力そのもの）:
    - **p4.1 は TAB と小数3桁を厳格に照合する**（`^[0-9]+\.[0-9]{3}<TAB>[0-9]+\.[0-9]{3}$`）。
      旧版の `[[:space:],]` 許容パターンはカンマ区切り実装も通してしまい、
      「TAB 固定」という契約が一切検証されていなかった
      （実測 2026-08-13: 厳格パターンなら TAB 実装 → 2行 / カンマ実装 → 0行で検出）
    - -d の配線: p4.1 が `-d 0.5` → 2行（0.000/2.000, 4.000/6.000）、
      `-d 3.0` → **1行**（0.000/6.000・2秒の無音が最小無音長未満で無視される）を実測する
  ※ 検証側（p4.2）は**下流の耐性確認**として awk -F'[,\t ]+' を使い、
     TAB/カンマ/空白のいずれでも列分割できるようにしてある（実測: TAB・カンマとも sum=4）。
     契約の照合は p4.1 が厳格に行い、p4.2 は end-to-end の疎通確認に徹する。

transcribe.sh -i <input> [--out-dir <dir>] [--format srt|json] [--lang ja] | --help
  --help : 使用法を出力して exit 0
  冒頭で command -v mlx_whisper による存在チェックを行い、無ければ案内を出して非ゼロ終了
  ★検証（挙動 / 4回目レビュー Minor-1）: ソースの grep（`command -v mlx_whisper`）だけでは
    コメント行1本でも通る（実測 2026-08-13: `# TODO: command -v mlx_whisper で存在チェックする`
    だけのスクリプトが旧 p4.4 を PASS し、実際に呼ぶと rc=0 で契約違反）。
    → p4.4 は `env PATH=/usr/bin:/bin`（mlx_whisper が /opt/homebrew/bin にあるため不可視になる）
      で実行し、**非ゼロ終了**かつ標準エラーに `mlx_whisper` を含む案内が出ることを実測する
      （実測: 正しい実装 → rc=3 + 案内 / コメントのみ → rc=0 で FAIL-zero-exit）
  ※ --output-format / --language の実配線はモデル DL を伴うため意図的に未検証（I-13）。
```

---

### I-12. ブランチ作成時点で既に存在したダーティ差分（本タスクの成果物ではない）

> **これらは main から引き継いだ未コミット差分であり、本 playbook が作ったものではない。**
> DW7 の回帰判定ではこれらを除外する。
> **ft3 では絶対に `git add -A` を使わない（add / commit の両方に明示パス指定）。理由は下記。**

`git status --porcelain` 実測（**2026-08-12 再実測・これが現状**）:

```
 M .claude/agents/critic.md                    # 既存の未コミット変更（別件）
 M state.md                                    # 本 playbook による playbook.active 更新
 D "tmp/AI\303\227\345\226\266\346\245\255.html"  # 既存の削除（tmp/AI×営業.html・追跡ファイル）
?? plan/playbook-setup-instagram-skills.md     # 未追跡（別タスク・本 playbook では触らない）
?? plan/playbook-video-editing-ffmpeg-skill.md # 本 playbook 自身（成果物）
```

> **★ 訂正（旧版の記述は現時点では偽）**: 旧版はここに `?? .claude/worktrees/` を挙げ
> 「467ファイル / 4.5MB / git add -A の対象に入る ★危険」と書いていたが、**現在は該当しない**。

DW7 の除外集合（＝「変更されていてよい」ファイル）:

```
.claude/skills/video-editing-ffmpeg/     # 本タスクの成果物
plan/playbook-video-editing-ffmpeg-skill.md  # 本 playbook 自身
state.md                                 # 進捗同期
docs/repository-map.yaml                 # ft1 が自動再生成する追跡ファイル
.gitignore                               # ft0 が1行追記する（下記）
.claude/agents/critic.md                 # 既存ダーティ（別件）
plan/playbook-setup-instagram-skills.md  # 既存ダーティ（別タスク）
.claude/worktrees/                       # git worktree 実体（現在は exclude 済みで status に出ない。保険として除外集合に残す）
tmp/                                     # 中間成果物・gitignore 済み
```

**★ `.claude/worktrees/` の現状（実測 2026-08-12）と ft0 の位置づけ**:

```
実体: git worktree（.claude/worktrees/ 配下）
現状: ★既に .git/info/exclude で除外済み
      実測: .git/info/exclude:11 に `**/.claude/worktrees/` の行が存在する
      → git status --porcelain に現れない（上記の実測リストにも無い）
      → git add -An の対象にも入らない
      → 「git add -A で worktrees を巻き込む」という旧版の危険記述は現時点では成立しない

.git/info/exclude の扱い（★本 playbook の決定）:
  - .git/info/exclude は **ローカル専用**（コミットされない / clone・他マシンに伝播しない）。
    そのため「このマシンでは今たまたま除外されている」だけの脆い状態である。
  - 決定: ft0 で `.claude/worktrees/` を **.gitignore（追跡ファイル）にも追記して恒久化**する。
    .git/info/exclude の既存行は**削除も編集もしない**（他ツールが書いた可能性があり、
    本 playbook の管轄外。二重指定は無害）。
  - ft0 は冪等（既に .gitignore にあれば何もしない）。

git add -A 禁止は依然として正当（理由は worktrees ではなく別の2件）:
  - 別タスクの plan/playbook-setup-instagram-skills.md を巻き込む
    （exclusions で「触らない」と宣言済みなのに、コミットしてしまえば宣言違反）
  - .claude/agents/critic.md（別件の未コミット変更）が混入する
  → この2件は現在も未追跡/未コミットで作業ツリーに存在するため、git add -A は今も危険。

対策（三重の防御）:
  1. ft0 で .claude/worktrees/ を .gitignore に追記（恒久・共有される対策）
  2. ft3 は git add -A ではなく明示パス指定、かつ git commit にも同じ pathspec を渡す
     （commit に pathspec が無いと index 全体をコミットしてしまうため。実測確認済み）
  3. ft4 は denylist ではなく **allowlist** で「許可された5パターン以外が
     コミットに含まれていないこと」を検査する
```

---

### I-13. 契約検証マトリクス（★4回目レビュー後に I-11 を1行ずつ機械的に棚卸しした結果）

> **棚卸しの問い（1項目ずつ機械的に適用する）: 「この契約項目は生成物（ピクセル / ストリーム構成 /
> pix_fmt / md5 / スクリプトの標準出力そのもの）で検証されているか？ 文字列 grep だけに依存していないか？」**
> 検証手段: **G**=生成物ベース / **S**=文字列 grep（G の土台があるものだけ有効）/ **N**=意図的に未検証。

| # | I-11 契約項目 | 検証手段 | 担当 subtask | 備考 |
|---|---------------|----------|--------------|------|
| 1 | probe_color.sh が HLG/SDR の1行を返す | G | p2.2 | HLG / SDR / 双子の3入力で分岐を実測 |
| 2 | probe_color.sh の判定基準（smpte2084・bt2020 primaries 分岐） | **N** | — | PQ 素材のフィクスチャを作らない。arib-std-b67 分岐と同一コードパスの列挙値追加のみのため（対象ワークフローは HLG） |
| 3 | clip_export.sh -i/-s/-d/-o | G | p2.3 | duration 2.85〜3.15 |
| 4 | 必須挙動1: `-t` は対象 `-i` の直前 | G | p2.3 | 誤配置なら duration=5.01 になり範囲外で FAIL（I-3 実測） |
| 5 | `-r` が指定解像度になる | G | p2.6 / p_final.9 | width,height 一致 |
| 6 | `-r` のアスペクト維持（歪ませない） | **G**（4回目 Major-2 で追加） | p2.6 / p_final.9 | cropdetect の比較・接触・レターボックス存在の3点 |
| 7 | `--label` が実際にピクセルに焼き込まれる | G | p2.10 / p3.3 / p_final.4 | ラベル有無の映像 md5 差分 |
| 8 | `--label` の fade-in（`fade=t=in:alpha=1`） | **G**（4回目 Minor-2 で追加） | p2.10 / p_final.9 | t=0.05 と t=1.5 の画素 G 値の差 ≥30 |
| 9 | `--label` の `-loop 1` / `shortest=1` | G | p2.10 | loop 欠落→md5 一致で FAIL / shortest 欠落→ハングを perl alarm で FAIL 化 |
| 10 | `--label-pos` の座標反映 | **G**（4回目 Major-1 で追加） | p2.10 / p_final.9 | 10:20 と 300:300 の映像 md5 差分 |
| 11 | `--label-pos` の逐語展開 `overlay=x=<x>:y=<y>` | S（#10・#13 が土台） | p2.10 | dry-run 文字列の逐語 grep |
| 12 | `--dry-run` が出力を書かず exit 0 | G | p2.5 / p2.9 / p2.10 / p_final.3 | FAIL-dryrun-wrote-file |
| 13 | `--dry-run` と実処理の同一性（eval して md5 一致） | G（`-vf`）+ **G**（`--label`・4回目 Major-1 で追加） | p2.9 / p2.10 / p_final.3 | **経路ごとに1本ずつ必要** |
| 14 | dry-run 文字列の tonemap / eq / `-map "0:a?"` 逐語 | S（#13 が土台） | p2.9 / p2.10 / p_final.3 | |
| 15 | 必須挙動2: HLG のときだけ tonemap | G | p2.4 / p_final.3 | 双子フィクスチャの md5 差分 + pix_fmt=yuv420p |
| 16 | 必須挙動2 の否定形（SDR で tonemap を付けない） | S（#13 が土台） | p2.5 | dry-run に tonemap が無いこと |
| 17 | 必須挙動3: **常に** `-x264-params` を付ける | G（HLG）+ **G**（SDR・4回目棚卸しで追加） | p2.4 / p2.5 / p_final.3 | SDR 経路の3タグ bt709 実測を追加 |
| 18 | 必須挙動4: `-map "0:a?"`（`-vf` 経路） | G | p2.8 / p_final.3 | 音声0本入力で実行成功 |
| 19 | 必須挙動4: `-map "0:a?"`（filter_complex 経路） | G | p2.10 | 音声0本入力 + `--label` で実行成功 |
| 20 | 映像 map の明示（`-map 0:v` / `-map "[o]"`） | G | p2.4 / p2.6 / p2.7 | 欠落すると色タグ・解像度が空になる |
| 21 | concat_clips.sh の結合動作 | G | p2.7 / p4.2 | duration 加算 + width/height 一致 |
| 22 | concat リストが tmp/ 配下（リポジトリを汚さない） | G（間接） | p_final.7 | 未追跡ファイル混入0件で担保 |
| 23 | concat リストファイルの後片付け（残骸を残さない） | **N** | — | tmp/ は ft2 で一括削除されるため実害なし。p2.7 の validations から主張を撤回済み |
| 24 | make_label_png.py が RGBA 透過 PNG を出す | G | p3.1 / p_final.4 | alpha min=0 / max>0 |
| 25 | フォントのフォールバック（例外死しない・空 PNG にしない） | G（**alpha 実測を4回目棚卸しで追加**） | p3.2 | |
| 26 | make_label_png.py の `--size` / `--width` / 縁取り | **N** | — | 見た目の調整項目。壊れても他の検証で二次被害が出ない |
| 27 | scene_scan.sh の pts_time 出力 | G（標準出力そのものが生成物） | p3.4 / p_final.5 | 値を逐語照合（pts_time:2 / pts_time:4） |
| 28 | scene_scan.sh の `-t` 配線 | **G**（4回目棚卸しで追加） | p3.4 | `-t 0.99` → 0件 |
| 29 | `--thumbs` が**検出時刻の**フレームを書く | **G**（4回目 Minor-3 で追加） | p3.5 | 青（t=2）と緑（t=4）の代表色を実測 |
| 30 | silence_scan.sh の保持区間の値 | G | p4.1 / p4.2 / p_final.5 | end-to-end 出力 duration 3.8〜4.3 |
| 31 | 出力形式が TAB 区切り・小数3桁固定 | **G**（4回目棚卸しで厳格化） | p4.1 | 旧版はカンマ区切りも通していた |
| 32 | silence_scan.sh の `-d` 配線 | **G**（4回目棚卸しで追加） | p4.1 | `-d 3.0` → 1行 |
| 33 | silence_scan.sh の `-n` 配線 | **N** | — | `-d` で引数配線の仕組み自体は検証済み。無音判定閾値の網羅は費用対効果が低い |
| 34 | transcribe.sh の `--help` が exit 0 | G | p4.3 | |
| 35 | mlx_whisper 不在時に非ゼロ終了 + 案内 | **G**（4回目 Minor-1 で挙動検証に変更） | p4.4 | `env PATH=/usr/bin:/bin` で再現 |
| 36 | transcribe.sh の `--output-format` / `--language` 配線 | **N** | — | 実行にモデル DL（数百 MB・ネットワーク）が要る。exclusions の方針に従い未検証 |

**未検証（N）の合計6件はいずれも「壊れても他の検証結果を無効化しない」項目に限定されている。**
文字列 grep のみ（S）の3項目（#11 / #14 / #16）は、すべて**同一経路の** eval 同一性検証（#13）を土台に持つ。

---

## exclusions（このタスクでやらないこと）

```yaml
やらない:
  - 実際の HYROX 大会動画・ユーザー個人素材をリポジトリに追加すること（合成フィクスチャのみ使用）
  - 既存スキル（threads-pdca 等）の内容変更
  - plan/playbook-setup-instagram-skills.md（未追跡の別タスク）への着手
  - GPU/VideoToolbox エンコード最適化、字幕焼き込み（drawtext 代替以外）
  - ffmpeg の再ビルド（libfreetype/libass の導入）→ 回避策で解決済みのため不要
  - 動画の自動アップロード・SNS 投稿連携
```

---

## rollback

```yaml
手順:
  # 1. 未追跡の成果物を明示削除する（★必須。git checkout は未追跡ファイルを消さない）
  rm -rf .claude/skills/video-editing-ffmpeg/
  # 2. 中間成果物を削除
  find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true
  # 3. state.md を戻す（playbook.active を null または前の playbook に）
  git checkout -- state.md
  # 4. ft0 で .gitignore を触っていたら戻す
  git checkout -- .gitignore 2>/dev/null || true
  # 5. ブランチを破棄
  git checkout main
  git branch -D feat/video-editing-ffmpeg-skill

注意:
  - 本 playbook の成果物は全て「未追跡ファイル」として始まるため、
    git checkout main / git branch -D だけでは消えずに main の作業ツリーに残る。
    手順1 の rm -rf を飛ばすと、ロールバックしたつもりで成果物が main に残存する。
  - .claude/worktrees/ / .claude/agents/critic.md /
    plan/playbook-setup-instagram-skills.md は本 playbook の管轄外なので触らない。

影響範囲: .claude/skills/video-editing-ffmpeg/ の新規追加 + .gitignore 1行 + state.md のみ。
          既存スキル・既存コードは変更しない（DW7 で保証）
```

---

## phases

### p1: スキル骨格と落とし穴リファレンスの固定

**goal**: スキルディレクトリを作成し、全ワークフロー共通の中核知識である3つの落とし穴を検証済み事実つきで固定する

#### subtasks

- [ ] **p1.1**: `.claude/skills/video-editing-ffmpeg/references/` と `.claude/skills/video-editing-ffmpeg/scripts/` の2ディレクトリが存在する
  - executor: claudecode
  - test_command: `test -d .claude/skills/video-editing-ffmpeg/references && test -d .claude/skills/video-editing-ffmpeg/scripts && echo PASS || echo FAIL`
  - validations:
    - technical: "test -d が両方 true を返す"
    - consistency: "I-7 のディレクトリ構成と一致する"
    - completeness: "references/ と scripts/ の両方が作られている"

- [ ] **p1.2**: `references/ffmpeg-pitfalls.md` に `## 落とし穴1` `## 落とし穴2` `## 落とし穴3` の H2 見出しが各1本ずつ存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/ffmpeg-pitfalls.md; for n in 1 2 3; do [ "$(grep -c "^## 落とし穴$n" $F)" = "1" ] || { echo FAIL; exit 0; }; done; echo PASS`
  - validations:
    - technical: "grep -c が各見出しについて 1 を返す"
    - consistency: "I-2/I-3/I-4 の3件と1対1で対応している"
    - completeness: "3件すべてが独立した節として存在する"

- [ ] **p1.3**: `references/ffmpeg-pitfalls.md` に I-1〜I-4 の逐語キーワード7個（`drawtext`, `libfreetype`, `tonemap=mobius:param=0.5`, `colorprim=bt709:transfer=bt709:colormatrix=bt709`, `arib-std-b67`, `eq=gamma=1.15:brightness=0.03`, `overlay`）が全て含まれる
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/ffmpeg-pitfalls.md; for s in 'drawtext' 'libfreetype' 'tonemap=mobius:param=0.5' 'colorprim=bt709:transfer=bt709:colormatrix=bt709' 'arib-std-b67' 'eq=gamma=1.15:brightness=0.03' 'overlay'; do grep -qF "$s" $F || { echo "FAIL:$s"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "grep -qF が7個すべてで 0 を返す"
    - consistency: "inputs I-1〜I-4 に記載した文字列と一字一句一致する"
    - completeness: "回避策のコマンドが省略・要約されず具体値のまま残っている"

- [ ] **p1.4**: `## 落とし穴2` 区間内に NG 例と OK 例の両方が存在し、それぞれ `-i` を含み、NG 例に `-i input.mp4 -t` の並び、OK 例に `-t 3 -i input.mp4` の並びが逐語で含まれる
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/ffmpeg-pitfalls.md; rm -f tmp/p14.txt; awk '/^## 落とし穴2/{f=1;next} f&&/^## /{f=0} f' $F > tmp/p14.txt; test -s tmp/p14.txt || { echo FAIL-nosection; exit 0; }; grep -qF -- '-i input.mp4 -t' tmp/p14.txt && grep -qF -- '-t 3 -i input.mp4' tmp/p14.txt && echo PASS || echo FAIL`
  - validations:
    - technical: "awk で切り出した落とし穴2 区間内に両パターンが存在する"
    - consistency: "I-3 の NG例/OK例 と一致する"
    - completeness: "誤りだけでなく正しい書き方も併記されている"

- [ ] **p1.5**: `## 落とし穴3` 区間内に実測値 `duration=3.000000` と `color_transfer=bt709` が逐語で含まれ、`zscale` が使えない旨の記述がある
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/ffmpeg-pitfalls.md; rm -f tmp/p15.txt; awk '/^## 落とし穴3/{f=1;next} f&&/^## /{f=0} f' $F > tmp/p15.txt; test -s tmp/p15.txt || { echo FAIL-nosection; exit 0; }; grep -qF 'duration=3.000000' tmp/p15.txt && grep -qF 'color_transfer=bt709' tmp/p15.txt && grep -qF 'zscale' tmp/p15.txt && echo PASS || echo FAIL`
  - validations:
    - technical: "3文字列すべてが落とし穴3 区間に存在する"
    - consistency: "I-4 の検証結果と数値が一致する"
    - completeness: "なぜ tonemap を使うか（zscale 不在）の理由が残っている"

**status**: pending
**max_iterations**: 5
**time_limit**: 40min
**priority**: high

---

### p2: 共通スクリプト（色判定・クリップ書き出し・結合）

**goal**: 3ワークフロー全てが使う中核スクリプトを実装し、合成フィクスチャで実動作を検証する

**depends_on**: [p1]

> **★ p2 は `clip_export.sh` の唯一の所有者である（I-7 補足3）。**
> p3・p4 は clip_export.sh を呼ぶだけで変更しない。p2 完了時点で CLI 契約（I-11）を確定させること。
> 特に `-map "0:a?"`（optional map）は必須挙動4 であり、これを `-map 0:a` にすると
> 音声トラックの無い入力で即失敗する。
> **`-r` / `--label` / `--label-pos` / `--dry-run` を含む I-11 の全オプションを p2 で実装しきること**
> （p2.5〜p2.10 が全オプションを検証する。p3.3 は make_label_png.py 由来の実 PNG での受入検証のみ）。
>
> **★ p2 の検証は「生成物」を第一級とし、コマンド文字列（--dry-run）はその補助として使う。**
> notes 冒頭の「★検証方針の絶対ルール」に従うこと。具体的には:
> - HDR/tonemap: 生成物での担保 = **p2.4**（pix_fmt=yuv420p + 双子フィクスチャとの映像 md5 差分）。
>   文字列での担保 = p2.9 の逐語 grep。ただし **grep が有効なのは p2.9 の
>   「dry-run を eval した出力と実 run 出力の映像 md5 一致」があるからである**（M-2）。
>   ※ 旧版はここに「HDR 対策は p2.9 の逐語検証でしか担保できない」と書いていたが誤り。
>     双子フィクスチャ（I-10）を使えば文字列に一切依存せず担保できる。
> - ラベル表示: 生成物での担保 = **p2.10**（ラベル有無での映像 md5 差分）。
>   duration だけでは「ラベルが一度も表示されない実装」を検出できない（C-1）。
> - optional map `-map "0:a?"`: **経路が2本ある**ので2本とも検証する。
>   `-vf` 経路 = p2.8（実行）+ p2.9（文字列）、`--label` 経路 = p2.10（実行 + 文字列）（M-1）。
> - `--dry-run` の同一性（eval → md5 一致）も**経路ごとに必要**。
>   `-vf` 経路 = p2.9、`--label` 経路 = p2.10（4回目 Major-1）。
> - `--label-pos`: 生成物での担保 = **p2.10**（2座標の映像 md5 差分）。
>   dry-run 文字列の grep だけでは「実行時だけ既定位置に差し替える実装」を通す（4回目 Major-1）。
> - `-r` のアスペクト維持: 生成物での担保 = **p2.6**（cropdetect の比一致・接触・レターボックス）。
>   width,height の一致だけでは歪ませる実装を通す（4回目 Major-2）。
> - `--label` の fade-in: 生成物での担保 = **p2.10**（t=0.05 と t=1.5 の画素差）。
>   ラベル有無の md5 差分では fade の有無を検出できない（4回目 Minor-2）。
> - 必須挙動3（常に -x264-params）: HLG 経路 = p2.4、**SDR 経路 = p2.5**（棚卸しで追加）。
>
> **★ 契約項目の網羅性は I-13（契約検証マトリクス）で機械的に管理する。**
> clip_export.sh の実装・契約を変更したら I-13 の該当行を必ず更新すること。

#### subtasks

- [ ] **p2.1**: I-10 の**6フィクスチャ**が全て生成され、`tmp/fixture_hlg.mp4` の color_transfer が `arib-std-b67` であり、`tmp/fixture_scenes.mp4` と `tmp/fixture_silence_av.mp4` がいずれも音声ストリームを1本持ち、**`tmp/fixture_videoonly.mp4` の音声ストリームが0本**であり、**`tmp/fixture_hlg_sdrtag.mp4` の color_transfer が `bt709` かつ pix_fmt が `fixture_hlg.mp4` と同一（＝再エンコードされていない双子）である**
  - executor: claudecode
  - test_command: `for f in tmp/fixture_hlg.mp4 tmp/fixture_hlg_sdrtag.mp4 tmp/fixture_scenes.mp4 tmp/fixture_silence.wav tmp/fixture_silence_av.mp4 tmp/fixture_videoonly.mp4; do test -f $f || { echo "FAIL-missing:$f"; exit 0; }; done; ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=nw=1:nk=1 tmp/fixture_hlg.mp4 | grep -qx 'arib-std-b67' || { echo FAIL-hlg; exit 0; }; ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=nw=1:nk=1 tmp/fixture_hlg_sdrtag.mp4 | grep -qx 'bt709' || { echo FAIL-sdrtag-tag; exit 0; }; PA=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 tmp/fixture_hlg.mp4); PB=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 tmp/fixture_hlg_sdrtag.mp4); [ -n "$PA" ] && [ "$PA" = "$PB" ] || { echo "FAIL-sdrtag-pixfmt:$PA!=$PB"; exit 0; }; for f in tmp/fixture_scenes.mp4 tmp/fixture_silence_av.mp4; do [ "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 $f | grep -c .)" = "1" ] || { echo "FAIL-noaudio:$f"; exit 0; }; done; [ "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 tmp/fixture_videoonly.mp4 | grep -c .)" = "0" ] || { echo FAIL-videoonly-has-audio; exit 0; }; [ "$(ffprobe -v error -select_streams v -show_entries stream=index -of csv=p=0 tmp/fixture_videoonly.mp4 | grep -c .)" = "1" ] || { echo FAIL-videoonly-novideo; exit 0; }; echo PASS`
  - validations:
    - technical: "6フィクスチャの存在・HLG タグ・音声ストリーム本数・★双子フィクスチャの SDR タグと pix_fmt 同一性を全て実測している"
    - consistency: "I-10 の生成コマンド（-x265-params / -map 3:a / -shortest / videoonly は音声入力なし / sdrtag は -c copy + hevc_metadata bsf）と一致する"
    - completeness: "★音声ありフィクスチャ（音声マップ経路が通ること）と音声0本フィクスチャ（-map \"0:a?\" でないと失敗すること）の**両方**を担保する。videoonly の音声0本アサートを外すと p2.8 の検証価値が消滅する。★双子の pix_fmt 同一性アサートを外すと、双子が再エンコードされていた場合に p2.4(ii) が『tonemap が無くても md5 が異なる』空振り検証に化ける"

- [ ] **p2.2**: `scripts/probe_color.sh` が実行権限付きで存在し、`tmp/fixture_hlg.mp4` に対し `HLG` を、`tmp/fixture_scenes.mp4` と **`tmp/fixture_hlg_sdrtag.mp4`** に対し `SDR` を標準出力に返す
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/probe_color.sh; test -x $S || { echo FAIL-notexec; exit 0; }; bash $S tmp/fixture_hlg.mp4 | grep -qx HLG || { echo FAIL-hlg; exit 0; }; bash $S tmp/fixture_scenes.mp4 | grep -qx SDR || { echo FAIL-scenes; exit 0; }; bash $S tmp/fixture_hlg_sdrtag.mp4 | grep -qx SDR || { echo FAIL-sdrtag; exit 0; }; echo PASS`
  - validations:
    - technical: "HLG 素材と SDR 素材で出力が分岐する。★双子フィクスチャ（ピクセルは HLG 素材と同一だが色タグは bt709）が SDR と判定されることも確認する"
    - consistency: "clip_export.sh の自動判定ロジックがこのスクリプトを使う"
    - completeness: "実行権限が付いており単体で呼び出せる。★双子が SDR と判定されなければ p2.4(ii) の tonemap 検証が成立しない（両方 HLG 分岐に入り md5 が一致して FAIL する）ので、ここで先に切り分けられるようにしている"

- [ ] **p2.3**: `scripts/clip_export.sh` が HLG フィクスチャに対し開始1秒・長さ3秒で実行され、出力 mp4 の duration が 2.85〜3.15 に収まる
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; test -x $S || { echo FAIL-notexec; exit 0; }; rm -f tmp/p23.mp4; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/p23.mp4 >/dev/null 2>&1; test -f tmp/p23.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p23.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{if(d>=2.85 && d<=3.15) print "PASS"; else print "FAIL:" d}'`
  - validations:
    - technical: "実行権限を検査し、出力を事前削除してから生成・実測している（前回残骸での偽 PASS を防ぐ）"
    - consistency: "I-3 の実測（NG=5.01 / OK=3.00）と同じ挙動になる"
    - completeness: "音声も切り出され映像と同じ長さである"

- [ ] **p2.4**: `scripts/clip_export.sh` の出力 mp4 の color_transfer / color_space / color_primaries が3つとも `bt709` を返し、**pix_fmt が `yuv420p` である**（＝10bit HLG が実際に 8bit へ変換されている）、かつ**双子フィクスチャ `tmp/fixture_hlg_sdrtag.mp4`（同一ピクセル・SDR タグ）を入力にした出力の映像 md5 が、HLG 入力の出力の映像 md5 と異なる**（＝tonemap 分岐が実際にピクセルを変えている）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; test -f tmp/p23.mp4 || { echo FAIL-noout; exit 0; }; C=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer,color_space,color_primaries -of default=nw=1:nk=1 tmp/p23.mp4 | sort -u | tr -d '\n'); [ "$C" = "bt709" ] || { echo "FAIL-color:$C"; exit 0; }; PF=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 tmp/p23.mp4); [ "$PF" = "yuv420p" ] || { echo "FAIL-pixfmt:$PF"; exit 0; }; rm -f tmp/p24s.mp4; bash $S -i tmp/fixture_hlg_sdrtag.mp4 -s 1 -d 3 -o tmp/p24s.mp4 >/dev/null 2>&1 || { echo FAIL-sdrtag-exit; exit 0; }; test -f tmp/p24s.mp4 || { echo FAIL-sdrtag-noout; exit 0; }; MH=$(ffmpeg -v error -i tmp/p23.mp4 -map 0:v -f md5 - 2>/dev/null); MS=$(ffmpeg -v error -i tmp/p24s.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$MH" ] && [ -n "$MS" ] || { echo FAIL-nomd5; exit 0; }; [ "$MH" = "$MS" ] && { echo FAIL-tonemap-noop; exit 0; }; echo PASS`
  - validations:
    - technical: "★3タグ bt709 に加えて、**文字列 grep に一切依存しない2つの生成物アサート**を持つ。(i) pix_fmt=yuv420p は映像フィルタを一切通さない実装（HLG 素材は yuv420p10le のまま出力される）を検出する。(ii) 双子フィクスチャとの md5 差分は、format=yuv420p は持つが tonemap を欠く実装を検出する。実測（2026-08-13）: tonemap 未実装の実装 → 2出力の映像 md5 が完全一致し FAIL-tonemap-noop、正しい実装 → md5 が異なり PASS"
    - consistency: "I-4 の -x264-params 指定・I-10 の双子フィクスチャ・I-11 必須挙動2 と一致する"
    - completeness: "★notes の絶対ルール（必須挙動は生成物の変化で検証する）を tonemap に適用したもの。旧版は3色タグしか見ておらず、`-x264-params` だけで3タグは bt709 になるため tonemap 未実装を一切検出できなかった（実測確認済み）。★注記: (i) の pix_fmt アサート単体では『format=yuv420p は持つが tonemap は無い』実装は検出できない（実測確認済み・そちらは (ii) が担当する）ので、(i) と (ii) の**両方**が必要"

- [ ] **p2.5**: `scripts/clip_export.sh` が SDR 入力（`tmp/fixture_scenes.mp4`）で exit 0 かつ duration > 0 の出力を持ち、**その出力の color_transfer / color_space / color_primaries が3つとも `bt709` であり**（＝必須挙動3「常に -x264-params を付ける」が SDR 経路でも守られている）、`--dry-run` 実行時に出力される ffmpeg コマンド文字列に `tonemap` が含まれない
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; rm -f tmp/p25.mp4 tmp/p25b.mp4; bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 -o tmp/p25.mp4 >/dev/null 2>&1 || { echo FAIL-exit; exit 0; }; test -f tmp/p25.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p25.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{exit !(d>0)}' || { echo "FAIL-dur:$D"; exit 0; }; C=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer,color_space,color_primaries -of default=nw=1:nk=1 tmp/p25.mp4 | sort -u | tr -d '\n'); [ "$C" = "bt709" ] || { echo "FAIL-sdr-color:$C"; exit 0; }; CMD=$(bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 -o tmp/p25b.mp4 --dry-run 2>/dev/null); [ $? = 0 ] || { echo FAIL-dryrc; exit 0; }; test -f tmp/p25b.mp4 && { echo FAIL-dryrun-wrote-file; exit 0; }; printf '%s' "$CMD" | grep -qF 'ffmpeg' || { echo FAIL-nocmd; exit 0; }; printf '%s' "$CMD" | grep -qF 'tonemap' && { echo FAIL-tonemap; exit 0; }; echo PASS`
  - validations:
    - technical: "SDR 入力で exit 0・duration > 0・**3色タグ bt709**。--dry-run は exit 0 かつ 'ffmpeg' を含む文字列を出し、**出力ファイルを書かず**、tonemap を含まない。失敗は必ず FAIL-* を標準出力に出す（旧版の `awk|grep -q FAIL && exit 0` は失敗時に無出力で exit 0 する握り潰しバグがあった）"
    - consistency: "probe_color.sh の SDR 判定でトーンマップ分岐がオフになることを実際に確認している（否定形）。肯定形（HLG で tonemap が付くこと）は p2.9 が担当する。必須挙動3（常に -x264-params）の SDR 経路担当がここ"
    - completeness: "HLG 前提の処理が SDR 素材を壊さない。★色タグアサートは4回目レビューの契約棚卸しで追加した: 旧版は必須挙動3 を HLG 経路（p2.4 / p_final.3）でしか検証しておらず、『HLG のときだけ -x264-params を付ける』実装を検出できなかった。実測（2026-08-13）: 入力 fixture_scenes.mp4 は3タグとも unknown / -x264-params あり → 出力 bt709×3 / 外すと unknown×3 で検出できる。★否定形チェックのみでは『--dry-run を無視する実装』を検出できないため、`grep -qF 'ffmpeg'` の肯定アサートと FAIL-dryrun-wrote-file、および p2.9 の逐語検証と合わせて穴を塞いでいる"

- [ ] **p2.6**: `scripts/clip_export.sh` に縦型整形オプションが実装され、`-r 1080x1920` 指定時に出力の解像度が 1080x1920 になり、**cropdetect で検出した実映像領域のアスペクト比が入力（640x480）のアスペクト比と一致し（許容2%）、その領域が出力の幅または高さに接し、かつ出力全面ではない**（＝scale + pad で歪みなくレターボックス付きに収まっている）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; rm -f tmp/p26.mp4; bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 -r 1080x1920 -o tmp/p26.mp4 >/dev/null 2>&1; test -f tmp/p26.mp4 || { echo FAIL-noout; exit 0; }; WH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/p26.mp4); [ "$WH" = "1080,1920" ] || { echo "FAIL-wh:$WH"; exit 0; }; SWH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/fixture_scenes.mp4); SW=${SWH%,*}; SH=${SWH#*,}; { [ -n "$SW" ] && [ -n "$SH" ]; } || { echo FAIL-nosrcwh; exit 0; }; CD=$(ffmpeg -hide_banner -i tmp/p26.mp4 -vf cropdetect=limit=24:round=2 -frames:v 30 -f null - 2>&1 | grep -o 'crop=[0-9:]*' | tail -1); CW=$(printf '%s' "$CD" | cut -d= -f2 | cut -d: -f1); CH=$(printf '%s' "$CD" | cut -d= -f2 | cut -d: -f2); { [ -n "$CW" ] && [ -n "$CH" ] && [ "$CH" != "0" ]; } || { echo "FAIL-nocrop:$CD"; exit 0; }; awk -v cw="$CW" -v ch="$CH" -v sw="$SW" -v sh="$SH" 'BEGIN{r=cw/ch; s=sw/sh; d=(r-s)/s; if(d<0)d=-d; exit !(d<=0.02)}' || { echo "FAIL-stretched:$CD(src=$SWH)"; exit 0; }; { [ "$CW" = "1080" ] || [ "$CH" = "1920" ]; } || { echo "FAIL-notfitted:$CD"; exit 0; }; { [ "$CW" = "1080" ] && [ "$CH" = "1920" ]; } && { echo "FAIL-noletterbox:$CD"; exit 0; }; echo "PASS($CD)"`
  - validations:
    - technical: "★width,height の一致だけでは**アスペクト維持を一切検証していない**（4回目レビュー Major-2）。cropdetect で実映像領域を取り出し、(i) アスペクト比が入力と一致（歪み検出）、(ii) 出力の幅か高さに接する（拡大漏れ検出）、(iii) 出力全面ではない（レターボックス存在）の3点を実測する。実測（2026-08-13 / 入力 640x480）: scale+pad → crop=1080:810:0:554 で PASS / `scale=${W}:${H}` のみ（歪み）→ crop=1080:1920:0:0 で FAIL-stretched / pad のみ（拡大なし）→ crop=640:480:220:720 で FAIL-notfitted"
    - consistency: "I-11 の `-r` 契約（scale + pad・アスペクト維持・歪ませない）と1対1で対応する。ワークフロー1 の縦型クロップ/パディング要件を満たす"
    - completeness: "横型素材（640x480）から縦型出力でき、かつ**歪んでいない**ことを生成物のピクセル配置で保証する。旧版の validations は『scale+pad で歪みなく収まる』とテストが確立していない事実を主張していた"

- [ ] **p2.7**: `scripts/concat_clips.sh` が**同一ソース（`tmp/fixture_scenes.mp4`）から切り出した同一解像度の2クリップ**を結合し、出力 duration が 3.5 以上、かつ出力の width,height が入力クリップの width,height と一致する
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts; rm -f tmp/p27a.mp4 tmp/p27b.mp4 tmp/p27.mp4; bash $S/clip_export.sh -i tmp/fixture_scenes.mp4 -s 0 -d 2 -o tmp/p27a.mp4 >/dev/null 2>&1; bash $S/clip_export.sh -i tmp/fixture_scenes.mp4 -s 2 -d 2 -o tmp/p27b.mp4 >/dev/null 2>&1; test -f tmp/p27a.mp4 && test -f tmp/p27b.mp4 || { echo FAIL-noclips; exit 0; }; WA=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/p27a.mp4); WB=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/p27b.mp4); [ -n "$WA" ] || { echo FAIL-srcwh-empty; exit 0; }; [ "$WA" = "$WB" ] || { echo "FAIL-srcwh:$WA!=$WB"; exit 0; }; bash $S/concat_clips.sh -o tmp/p27.mp4 tmp/p27a.mp4 tmp/p27b.mp4 >/dev/null 2>&1; test -f tmp/p27.mp4 || { echo FAIL-noout; exit 0; }; WO=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/p27.mp4); [ "$WO" = "$WA" ] || { echo "FAIL-outwh:$WO!=$WA"; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p27.mp4); awk -v d="$D" -v w="$WO" 'BEGIN{if(d>=3.5) print "PASS(wh=" w " dur=" d ")"; else print "FAIL-dur:" d}'`
  - validations:
    - technical: "★同一ソース・同一解像度の2クリップを結合し、duration 加算に加えて width/height 一致もアサートしている（旧版は 1080x1920 と 640x480 の混在クリップを結合しており、concat demuxer + -c copy では duration だけ加算されて『再生不能な成果物でも PASS する』穴があった）。★`[ -n \"$WA\" ]` を追加済み: 映像ストリームが無いと ffprobe が空文字を返し `\"\"=\"\"` で真になって空振りしていた（実測確認済み: 映像ストリームなしの実装で `PASS(wh= dur=4.023220)` を返していた）"
    - consistency: "clip_export.sh の出力仕様（同一コーデック/解像度前提）と検証条件が一致する"
    - completeness: "★『中間の concat リストファイルがリポジトリを汚さない』ことは p_final.7（追跡差分 + 未追跡ファイルの和集合で除外集合外0件）が担保する。リストファイルの**削除**そのものは意図的に未検証（I-13 / tmp/ 配下は ft2 で一括削除されるため実害がない）。旧版はここで『残骸を残さない』とテストが確立していない事実を主張していた"
  - note: "実測値: 640x480 の2秒クリップ×2 → duration=4.023220 / 640,480"

- [ ] **p2.8**: `scripts/clip_export.sh` が**音声トラックの無い入力**（`tmp/fixture_videoonly.mp4`）に対して exit 0 で成功し、出力 mp4 が映像ストリームを1本持ち duration が 1.85〜2.15 に収まる
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; test -f tmp/fixture_videoonly.mp4 || { echo FAIL-nofixture; exit 0; }; [ "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 tmp/fixture_videoonly.mp4 | grep -c .)" = "0" ] || { echo FAIL-fixture-has-audio; exit 0; }; rm -f tmp/p28.mp4; bash $S -i tmp/fixture_videoonly.mp4 -s 1 -d 2 -o tmp/p28.mp4 >/dev/null 2>&1 || { echo FAIL-exit; exit 0; }; test -f tmp/p28.mp4 || { echo FAIL-noout; exit 0; }; [ "$(ffprobe -v error -select_streams v -show_entries stream=index -of csv=p=0 tmp/p28.mp4 | grep -c .)" = "1" ] || { echo FAIL-novideo; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p28.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{if(d>=1.85 && d<=2.15) print "PASS"; else print "FAIL-dur:" d}'`
  - validations:
    - technical: "★これが `-map \"0:a?\"`（I-11 必須挙動4）を **`-vf` 経路について**実行時に検証する subtask である（`--label` / filter_complex 経路は p2.10(3) が担当する。経路が2本あるので実行時検証も2本必要 / 3回目レビュー M-1）。実測（2026-08-13）: `-map 0:a` 実装 + 音声なし入力 → \"Stream map '' matches no streams.\" で rc=234・出力なし → FAIL-exit / `-map \"0:a?\"` 実装 → duration=2.000000 で PASS"
    - consistency: "I-10 の fixture_videoonly.mp4（音声0本）と I-11 必須挙動4 に対応する。フィクスチャに音声が混入していないことを test 冒頭で再確認している"
    - completeness: "映像ストリーム1本もアサートし、音声なし入力から音声のみ/空の mp4 が出ることを防ぐ。※実測補足（2026-08-13 再実測・旧記述を訂正）: `-map 0:v` を書き忘れた実装は音声のみの mp4 を出力する。これを検出するのは **p2.4（色タグと pix_fmt が空文字になる）と p2.6（width,height が空文字になる）の2つだけ**である。**p2.3 は PASS してしまう**（音声のみの mp4 でも format.duration=3.000000 で範囲内）。p2.7 も m-2 修正前は空文字同士の比較で PASS していたが、`[ -n \"$WA\" ]` 追加後は FAIL-srcwh-empty で検出する。★旧版はここに『p2.6 / p2.7 / p2.3 が検出する（実測確認済み）』と書いていたが実測と食い違っていたため訂正した"
  - note: "★本 subtask は `-vf` 経路の音声なし検証である。`--label`（filter_complex）経路の音声なし検証は p2.10 が担当する（3回目レビュー M-1: 経路が2本あるので必須挙動の検証も2本必要）"

- [ ] **p2.9**: `scripts/clip_export.sh` の HLG 入力 `--dry-run` 出力に、`ffmpeg` / `tonemap=mobius:param=0.5` / `eq=gamma=1.15:brightness=0.03` / `-map "0:a?"` の4文字列が**逐語で含まれ**、出力ファイルが生成されず、**かつその dry-run 文字列をそのまま `eval` して得た出力の映像 md5 が、`--dry-run` 無しで実行した出力の映像 md5 と一致する**（＝dry-run 文字列が実処理を正直に反映している）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; rm -f tmp/p29.mp4 tmp/p29_dry.mp4 tmp/p29_real.mp4; CMD=$(bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/p29.mp4 --dry-run 2>/dev/null); rc=$?; [ $rc = 0 ] || { echo FAIL-dryrc; exit 0; }; test -f tmp/p29.mp4 && { echo FAIL-dryrun-wrote-file; exit 0; }; printf '%s' "$CMD" | grep -qF 'ffmpeg' || { echo FAIL-nocmd; exit 0; }; printf '%s' "$CMD" | grep -qF 'tonemap=mobius:param=0.5' || { echo FAIL-notonemap; exit 0; }; printf '%s' "$CMD" | grep -qF 'eq=gamma=1.15:brightness=0.03' || { echo FAIL-noeq; exit 0; }; printf '%s' "$CMD" | grep -qF -- '-map "0:a?"' || { echo FAIL-nooptmap; exit 0; }; DCMD=$(bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/p29_dry.mp4 --dry-run 2>/dev/null); eval "$DCMD" </dev/null >/dev/null 2>&1 || { echo FAIL-dryrun-not-executable; exit 0; }; test -f tmp/p29_dry.mp4 || { echo FAIL-dryrun-noout; exit 0; }; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/p29_real.mp4 >/dev/null 2>&1 || { echo FAIL-real-exit; exit 0; }; test -f tmp/p29_real.mp4 || { echo FAIL-real-noout; exit 0; }; M1=$(ffmpeg -v error -i tmp/p29_dry.mp4 -map 0:v -f md5 - 2>/dev/null); M2=$(ffmpeg -v error -i tmp/p29_real.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$M1" ] && [ -n "$M2" ] || { echo FAIL-nomd5; exit 0; }; [ "$M1" = "$M2" ] && echo PASS || echo "FAIL-dryrun-mismatch:$M1!=$M2"`
  - validations:
    - technical: "★この subtask は2つの役割を持つ。(1) HDR/HLG 対策の肯定的な逐語検証。(2) ★**その逐語検証を有効にするための土台**＝dry-run 文字列と実処理の同一性検証。(2) が無いと (1) は『検証されていない前提』の上に乗るだけになる。実測（3回目レビュー M-2）: dry-run では tonemap 入りの理想文字列を printf し、実行パスには tonemap を入れない実装を作ったところ、p2.3〜p2.10 / p_final.3 が**全て PASS**した。md5 一致アサート追加後は FAIL-dryrun-mismatch で検出する（実測確認済み）"
    - consistency: "I-4 の検証済みコマンドおよび I-11 --dry-run 出力要件（ダブルクォート込みの `-map \"0:a?\"` / eval 可能性 / 実処理との同一性）と逐語一致する"
    - completeness: "`--dry-run` を無視して普通にエンコードする実装は FAIL-dryrun-wrote-file で落ち、dry-run 文字列がシェル的に壊れている実装は FAIL-dryrun-not-executable で落ち、dry-run が実処理と乖離している実装は FAIL-dryrun-mismatch で落ちる。`-map \"0:a?\"` の文字列検証も兼ね、p2.8（-vf 経路）/ p2.10（filter_complex 経路）の実行時検証と合わせて必須挙動4 を守る"
  - note: "実測確認済み（2026-08-13）: libx264 の同一パラメータ・同一入力のエンコードは決定的で、2回実行してもバイト単位まで一致する（映像 md5 も当然一致）。よって md5 一致アサートは偽 FAIL を起こさない。★eval するため dry-run 文字列は `-y` を含むか、または test 側で事前に rm -f しておく必要がある（本 test_command は冒頭で rm -f 済み）。`</dev/null` は ffmpeg が標準入力を掴んで停止するのを防ぐため"

- [ ] **p2.10**: `scripts/clip_export.sh` の `--label` / `--label-pos` が p2 内で実装され、(1) ffmpeg 生成の**白** RGBA PNG で overlay 合成が成功し（duration 1.85〜2.15・ハングしない）、(2) **同一入力・同一区間をラベル無しで書き出した出力と映像 md5 が異なり**（＝ラベルが実際にピクセルとして焼き込まれている）、(3) **`--label-pos 10:20` の出力と `--label-pos 300:300` の出力の映像 md5 が異なり**（＝座標指定が実際にピクセル配置を変えている）、(4) **ラベル矩形内の画素が t=0.05 と t=1.5 で異なる**（＝fade-in が実際に効いている）、(5) **音声トラックの無い入力（`tmp/fixture_videoonly.mp4`）に `--label` を付けても exit 0 で duration > 0 の mp4 を生成し**、(6) `--label-pos 10:20` 指定時の `--dry-run` 出力に `overlay=x=10:y=20` と **`-map "0:a?"`** が逐語で含まれ、(7) **その dry-run 文字列をそのまま `eval` して得た出力の映像 md5 が、`--dry-run` 無しで実行した (1) の出力の映像 md5 と一致する**（＝filter_complex 経路でも dry-run 文字列が実処理を正直に反映している）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; L=tmp/lbl.png; rm -f $L tmp/p210.mp4 tmp/p210n.mp4 tmp/p210p2.mp4 tmp/p210vo.mp4 tmp/p210b.mp4 tmp/p210dry.mp4; ffmpeg -y -f lavfi -i "color=c=white:s=300x120,format=rgba" -frames:v 1 $L >/dev/null 2>&1; test -s $L || { echo FAIL-nolabelpng; exit 0; }; perl -e 'alarm shift; exec @ARGV' 60 bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 --label $L --label-pos 10:20 -o tmp/p210.mp4 >/dev/null 2>&1 || { echo FAIL-exit-or-hang; exit 0; }; test -f tmp/p210.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p210.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{exit !(d>=1.85 && d<=2.15)}' || { echo "FAIL-dur:$D"; exit 0; }; bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 -o tmp/p210n.mp4 >/dev/null 2>&1 || { echo FAIL-nolabel-exit; exit 0; }; ML=$(ffmpeg -v error -i tmp/p210.mp4 -map 0:v -f md5 - 2>/dev/null); MN=$(ffmpeg -v error -i tmp/p210n.mp4 -map 0:v -f md5 - 2>/dev/null); { [ -n "$ML" ] && [ -n "$MN" ]; } || { echo FAIL-nomd5; exit 0; }; [ "$ML" = "$MN" ] && { echo FAIL-label-invisible; exit 0; }; bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 --label $L --label-pos 300:300 -o tmp/p210p2.mp4 >/dev/null 2>&1 || { echo FAIL-pos2-exit; exit 0; }; MP=$(ffmpeg -v error -i tmp/p210p2.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$MP" ] || { echo FAIL-nomd5-pos; exit 0; }; [ "$ML" = "$MP" ] && { echo FAIL-labelpos-ignored; exit 0; }; GA=$(ffmpeg -v error -ss 0.05 -i tmp/p210.mp4 -vf "crop=200:80:20:30,scale=1:1" -frames:v 1 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | od -An -tu1 | awk '{print $2}'); GB=$(ffmpeg -v error -ss 1.5 -i tmp/p210.mp4 -vf "crop=200:80:20:30,scale=1:1" -frames:v 1 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | od -An -tu1 | awk '{print $2}'); { [ -n "$GA" ] && [ -n "$GB" ]; } || { echo FAIL-nopixel; exit 0; }; awk -v a="$GA" -v b="$GB" 'BEGIN{d=a-b; if(d<0)d=-d; exit !(d>=30)}' || { echo "FAIL-nofade:$GA/$GB"; exit 0; }; bash $S -i tmp/fixture_videoonly.mp4 -s 1 -d 2 --label $L --label-pos 10:20 -o tmp/p210vo.mp4 >/dev/null 2>&1 || { echo FAIL-videoonly-exit; exit 0; }; test -f tmp/p210vo.mp4 || { echo FAIL-videoonly-noout; exit 0; }; DV=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p210vo.mp4); awk -v d="$DV" 'BEGIN{exit !(d>0)}' || { echo "FAIL-videoonly-dur:$DV"; exit 0; }; CMD=$(bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 --label $L --label-pos 10:20 -o tmp/p210b.mp4 --dry-run 2>/dev/null); [ $? = 0 ] || { echo FAIL-dryrc; exit 0; }; test -f tmp/p210b.mp4 && { echo FAIL-dryrun-wrote-file; exit 0; }; printf '%s' "$CMD" | grep -qF 'overlay=x=10:y=20' || { echo FAIL-labelpos-str; exit 0; }; printf '%s' "$CMD" | grep -qF -- '-map "0:a?"' || { echo FAIL-nooptmap; exit 0; }; DCMD=$(bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 --label $L --label-pos 10:20 -o tmp/p210dry.mp4 --dry-run 2>/dev/null); eval "$DCMD" </dev/null >/dev/null 2>&1 || { echo FAIL-dryrun-not-executable; exit 0; }; test -f tmp/p210dry.mp4 || { echo FAIL-dryrun-noout; exit 0; }; MD=$(ffmpeg -v error -i tmp/p210dry.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$MD" ] || { echo FAIL-dryrun-nomd5; exit 0; }; [ "$MD" = "$ML" ] || { echo "FAIL-dryrun-mismatch:$MD!=$ML"; exit 0; }; echo PASS`
  - validations:
    - technical: "★`--label` の実装所有権を p2 に置くための subtask（I-7 補足3）。make_label_png.py に依存しないため p3 と独立に実行できる。★**生成物アサートが4本ある**: (2) ラベル可視性（3回目 C-1）、(3) 座標反映（4回目 Major-1）、(4) fade（4回目 Minor-2）、(7) filter_complex 経路の dry-run↔実 run 同一性（4回目 Major-1）。実測（2026-08-13・全て検証済み）: 正しい実装 → 全 PASS / 実行時だけ既定座標に差し替える実装 → FAIL-labelpos-ignored（かつ (7) でも FAIL-dryrun-mismatch）/ fade を外した実装 → FAIL-nofade（G 値 255 vs 255）"
    - consistency: "I-5 の修正済み filter_complex 構成（`-loop 1 -framerate <入力fps>` + `shortest=1`）、I-11 の --label-pos 契約（overlay=x=<x>:y=<y> に逐語展開 + 生成物検証）、--dry-run 同一性契約（経路ごとに必要）および必須挙動4 と一致する"
    - completeness: "★`--label`（filter_complex）経路は `-vf` 経路と**別経路**なので、必須挙動4（optional map）も dry-run 同一性も別途検証する必要がある（3回目 M-1 / 4回目 Major-1）。旧版は (3)(4)(7) を欠き、`--label-pos` は『同一性の土台が無い経路の上に乗った文字列 grep』だけで守られていた（実測: 座標を無視する実装が p2.10 / p3.3 / p_final.4 / p2.9 / p_final.3 を全て通過した）"
  - note: "★検証用ラベルは**白**（`color=c=white`）でなければならない。旧版は `color=c=red@0.6` を使っていたが、対象の `tmp/fixture_scenes.mp4` は先頭2秒が純赤であり、overlay が正しく効いてもピクセル差がゼロになって (2) の md5 検証が空振りする（実測確認済み）。実測値（2026-08-13・正しい実装）: duration=2.000000 / フレーム数はラベル有無で同一（60/60）/ ラベル矩形内の画素は t=0.05 で (255,75,52)・t=1.5 で (255,255,255)（fade 中の中間値）/ 10:20 と 300:300 の映像 md5 は異なる / dry-run を eval した出力と実 run 出力の映像 md5 は一致する。★`perl -e 'alarm shift; exec @ARGV' 60` でラップするのは、`overlay` に `shortest=1` を付けない実装が **FAIL ではなくハングする**ため（実測: 20秒経っても終了せず SIGALRM で強制終了・出力なし）。★fade の画素サンプルは `crop=200:80:20:30`（ラベル矩形 300x120 @ 10:20 の内側）で取り、G チャンネル差 30 以上を要求する"

**status**: pending
**max_iterations**: 10
**time_limit**: 120min
**priority**: high

---

### p3: ハイライト Reel 用スクリプトと手順書

**goal**: シーン検出・ラベル PNG 生成・overlay 合成のワークフロー3 一式を実装し、実動作を検証する

**depends_on**: [p2]

> **★ p3 と p4 は並行実行可能**（両者とも depends_on: [p2] のみで、互いに依存しない）。
> ただし両者とも `clip_export.sh` を**呼び出すだけで変更しない**（所有者は p2 / I-7 補足3）。
> ここで clip_export.sh の不具合を見つけたら p2 に差し戻すこと。

#### subtasks

- [ ] **p3.1**: `scripts/make_label_png.py` が日本語文字列を引数に実行でき、出力 PNG が mode=RGBA で、alpha=0 のピクセルと alpha>0 のピクセルの両方を含む
  - executor: claudecode
  - test_command: `P=.claude/skills/video-editing-ffmpeg/scripts/make_label_png.py; test -x $P || { echo FAIL-notexec; exit 0; }; rm -f tmp/p31.png; python3 $P --text 'スキーエルゴ' --out tmp/p31.png >/dev/null 2>&1; test -s tmp/p31.png || { echo FAIL-noout; exit 0; }; python3 -c "from PIL import Image; im=Image.open('tmp/p31.png'); a=im.getchannel('A').getextrema(); print('PASS' if im.mode=='RGBA' and a[0]==0 and a[1]>0 else 'FAIL:'+im.mode+str(a))"`
  - validations:
    - technical: "実行権限（I-7 補足2 の統一ルール）を検査し、RGBA かつ alpha の min=0 / max>0（＝透過と描画の両方がある）を実測する"
    - consistency: "I-1 の実在フォントパスを使い日本語が豆腐にならない"
    - completeness: "drawtext を一切使わずラベル生成が完結している"

- [ ] **p3.2**: `scripts/make_label_png.py` にフォント自動フォールバックが実装され、存在しないフォントパスを渡しても exit 0 で PNG を生成し、**その PNG の alpha に 0 のピクセルと 0 より大きいピクセルの両方が含まれる**（＝フォールバック時に空の透明 PNG を書いていない）
  - executor: claudecode
  - test_command: `rm -f tmp/p32.png; python3 .claude/skills/video-editing-ffmpeg/scripts/make_label_png.py --text 'テスト' --font /nonexistent/font.ttc --out tmp/p32.png >/dev/null 2>&1 || { echo FAIL-exit; exit 0; }; test -s tmp/p32.png || { echo FAIL-noout; exit 0; }; python3 -c "from PIL import Image; im=Image.open('tmp/p32.png'); a=im.getchannel('A').getextrema(); print('PASS' if im.mode=='RGBA' and a[0]==0 and a[1]>0 else 'FAIL-blank:'+im.mode+str(a))"`
  - validations:
    - technical: "存在しないフォント指定でも例外死せず PNG が生成され、★その PNG に実際に描画がある（alpha max>0）。旧版は `test -s` のみで、フォールバック時に**全透明の空 PNG を書く実装**を検出できなかった（4回目レビューの契約棚卸しで追加）"
    - consistency: "I-1 のフォント候補リストを順に試す実装になっている。p3.1 と同じ alpha アサートを使う"
    - completeness: "環境差（フォント未導入 Mac）でもスキルが動き、かつ**文字が出ている**ことを保証する"

- [ ] **p3.3**: **（受入検証のみ / 実装は p2.10 で完了済み）** `make_label_png.py` が生成した実 PNG（`tmp/p31.png`）を `--label` に渡して `clip_export.sh` を実行すると、出力 duration が 2.85〜3.15 に収まり（ラベル入力で動画長が伸びない）、**同一入力・同一区間をラベル無しで書き出した出力と映像 md5 が異なる**（＝実 PNG でもラベルが実際に焼き込まれている）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; test -s tmp/p31.png || { echo FAIL-nolabel; exit 0; }; rm -f tmp/p33.mp4 tmp/p33n.mp4; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 --label tmp/p31.png -o tmp/p33.mp4 >/dev/null 2>&1; test -f tmp/p33.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p33.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{exit !(d>=2.85 && d<=3.15)}' || { echo "FAIL-dur:$D"; exit 0; }; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/p33n.mp4 >/dev/null 2>&1 || { echo FAIL-nolabel-exit; exit 0; }; test -f tmp/p33n.mp4 || { echo FAIL-nolabel-noout; exit 0; }; ML=$(ffmpeg -v error -i tmp/p33.mp4 -map 0:v -f md5 - 2>/dev/null); MN=$(ffmpeg -v error -i tmp/p33n.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$ML" ] && [ -n "$MN" ] || { echo FAIL-nomd5; exit 0; }; [ "$ML" = "$MN" ] && { echo FAIL-label-invisible; exit 0; }; echo PASS`
  - validations:
    - technical: "I-5 の修正済み filter_complex 構成で overlay + fade が適用され長さが伸びず、★ピクセルが実際に変化する。★ここで FAIL した場合も clip_export.sh を p3 で編集してはならない（所有者は p2 / I-7 補足3）。p2 に差し戻すこと"
    - consistency: "I-3 の -t 配置ルールが2入力時にも守られている。合成対象が HLG フィクスチャなので tonemap + overlay の同時経路になる（p2.10 は SDR + overlay 経路）"
    - completeness: "Pillow 生成の実 PNG（アルファ勾配・縁取りあり）でも overlay が壊れないことを保証する。★duration だけでは『ラベルが一度も表示されない実装』を検出できない（3回目レビュー C-1）ため md5 差分アサートを追加した。実測確認済み（2026-08-13・900x160 の実ラベル PNG / 既定位置 y=H-400）: duration=3.000000 / フレーム数はラベル有無とも 90 で同一 / 映像 md5 は異なる"

- [ ] **p3.4**: `scripts/scene_scan.sh` が `tmp/fixture_scenes.mp4` に対し `pts_time` を含む行を2行以上出力し、その出力に `pts_time:2` と `pts_time:4` が**逐語で**含まれ、**`-t 0.99` を指定すると検出行が0行になる**（＝しきい値引数が実際に配線されている）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/scene_scan.sh; rm -f tmp/p34.txt tmp/p34hi.txt; bash $S -i tmp/fixture_scenes.mp4 -t 0.3 2>/dev/null > tmp/p34.txt; N=$(grep -c 'pts_time' tmp/p34.txt); [ "$N" -ge 2 ] || { echo "FAIL-count:$N"; exit 0; }; grep -qF 'pts_time:2' tmp/p34.txt || { echo FAIL-no2; exit 0; }; grep -qF 'pts_time:4' tmp/p34.txt || { echo FAIL-no4; exit 0; }; bash $S -i tmp/fixture_scenes.mp4 -t 0.99 2>/dev/null > tmp/p34hi.txt; NH=$(grep -c 'pts_time' tmp/p34hi.txt); [ "$NH" = "0" ] || { echo "FAIL-threshold-ignored:$NH"; exit 0; }; echo PASS`
  - validations:
    - technical: "★件数だけでなく検出時刻の値そのものを逐語照合する（`echo pts_time` を2回出すだけの偽実装を弾く）。実測確認済み: 本フィクスチャの showinfo 出力は厳密に `pts_time:2` と `pts_time:4` の2行"
    - consistency: "I-6 の実測（pts_time:2 / pts_time:4）と値・件数の両方が一致する"
    - completeness: "★しきい値の**配線**を実測する（`-t 0.3` → 2件 / `-t 0.99` → 0件。2026-08-13 実測）。旧版は completeness で『しきい値を引数で変更できる』と主張しながら、しきい値をハードコードした実装でも PASS していた（4回目レビューの契約棚卸しで追加）"

- [ ] **p3.5**: `scripts/scene_scan.sh` にサムネイル抽出モードがあり、`--thumbs tmp/thumbs` 指定時に `tmp/thumbs/` に PNG または JPG が2枚以上生成され、**その画像群に青優勢の1枚（＝検出時刻 t=2 のフレーム）と緑優勢の1枚（＝検出時刻 t=4 のフレーム）が両方含まれる**（＝検出時刻のフレームが書き出されている）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/scene_scan.sh; rm -rf tmp/thumbs; bash $S -i tmp/fixture_scenes.mp4 -t 0.3 --thumbs tmp/thumbs >/dev/null 2>&1; test -d tmp/thumbs || { echo FAIL-nodir; exit 0; }; N=$(ls tmp/thumbs/*.png tmp/thumbs/*.jpg 2>/dev/null | grep -c .); [ "$N" -ge 2 ] || { echo "FAIL-count:$N"; exit 0; }; python3 -c "from PIL import Image; import glob; px=[Image.open(p).convert('RGB').resize((1,1)).getpixel((0,0)) for p in glob.glob('tmp/thumbs/*.png')+glob.glob('tmp/thumbs/*.jpg')]; b=any(c[2]>c[0] and c[2]>c[1] for c in px); g=any(c[1]>c[0] and c[1]>c[2] for c in px); print('PASS' if b and g else 'FAIL-thumb-times:'+str(px))"`
  - validations:
    - technical: "★枚数だけでなく**内容**を実測する。fixture_scenes.mp4 は 赤(0-2s)/青(2-4s)/緑(4-6s) なので、検出時刻 t=2・t=4 のフレームを書き出した実装は青と緑の画像を生む。実測（2026-08-13）: 検出時刻ベースの実装 → (0,0,253) と (0,127,0) で PASS / 先頭付近のフレームを2枚出すだけの実装 → 赤のみで FAIL-thumb-times:R"
    - consistency: "出力先が tmp/ 配下でリポジトリを汚さない（p_final.7 が最終担保）。I-11 の `--thumbs`（検出時刻のフレームを書き出す）契約と一致する"
    - completeness: "★旧版は『検出時刻のフレームが画像として書き出される』と主張しながら、検出時刻と無関係な画像1枚でも PASS していた（4回目レビュー Minor-3）。目視確認 → 区間選定の導線が実際に成立することを保証する"

- [ ] **p3.6**: `references/highlight-reel.md` に `## 手順` の H2 見出しが1本存在し、その区間内に番号付きステップ行（`^[0-9]+.`）が5行以上ある
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/highlight-reel.md; test -f $F || { echo FAIL-nofile; exit 0; }; [ "$(grep -c '^## 手順' $F)" = "1" ] || { echo FAIL-heading; exit 0; }; N=$(awk '/^## 手順/{f=1;next} f&&/^## /{f=0} f' $F | grep -cE '^[0-9]+\.'); [ "$N" -ge 5 ] && echo PASS || echo "FAIL-steps:$N"`
  - validations:
    - technical: "手順見出しが1本、ステップ行が5行以上"
    - consistency: "I-8 のワークフロー3 の使用スクリプト順（scene_scan → make_label_png → clip_export → concat_clips）と一致する"
    - completeness: "HDR 素材時に tonemap+bt709 を必ず適用する旨が記載されている"

- [ ] **p3.7**: `references/highlight-reel.md` に `ffmpeg-pitfalls.md` への参照行と、`tonemap` および `make_label_png.py` の逐語文字列が含まれる
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/highlight-reel.md; grep -qF 'ffmpeg-pitfalls.md' $F && grep -qF 'tonemap' $F && grep -qF 'make_label_png.py' $F && echo PASS || echo FAIL`
  - validations:
    - technical: "3文字列すべてが存在する"
    - consistency: "落とし穴リファレンスへの導線が切れていない"
    - completeness: "drawtext 非依存であることが手順から読み取れる"

**status**: pending
**max_iterations**: 8
**time_limit**: 90min
**priority**: high

---

### p4: トーク動画用スクリプトと手順書

**goal**: 無音トリム（段階1）と mlx_whisper 判定カット（段階2）のワークフロー1・2 一式を実装し、実動作を検証する

**depends_on**: [p2]

> **★ p4 は p3 と並行実行可能**（互いに依存しない）。
> p4.2 は `clip_export.sh` / `concat_clips.sh` を**呼び出す**（変更しない。所有者は p2 / I-7 補足3）。

#### subtasks

- [ ] **p4.1**: `scripts/silence_scan.sh` が `tmp/fixture_silence.wav` に対し保持区間行を**TAB 区切り・小数3桁固定**で2行出力し（`^[0-9]+\.[0-9]{3}<TAB>[0-9]+\.[0-9]{3}$` に厳格一致）、**`-d 3.0` を指定すると1行になる**（＝2秒の無音が最小無音長未満として無視される＝ `-d` が実際に配線されている）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/silence_scan.sh; TAB=$(printf '\t'); PAT="^[0-9]+\.[0-9]{3}${TAB}[0-9]+\.[0-9]{3}$"; N=$(bash $S -i tmp/fixture_silence.wav -n -40dB -d 0.5 2>/dev/null | grep -cE "$PAT"); [ "$N" -ge 2 ] || { echo "FAIL-format-or-count:$N"; exit 0; }; ND=$(bash $S -i tmp/fixture_silence.wav -n -40dB -d 3.0 2>/dev/null | grep -cE "$PAT"); [ "$ND" = "1" ] || { echo "FAIL-d-ignored:$ND"; exit 0; }; echo PASS`
  - validations:
    - technical: "★区切り文字と桁数を**厳格に**照合する。旧版の `[[:space:],]` 許容パターンはカンマ区切り実装も通し、I-11 の『TAB 区切り固定・小数3桁』という契約を一切検証していなかった（実測 2026-08-13: 厳格パターンなら TAB 実装 → 2行 / 同じ出力をカンマに変えると 0行で検出）"
    - consistency: "I-6 の silencedetect 実測（start 1.999977 / end 4.000045）および I-11 の出力形式契約と一致する"
    - completeness: "★最小無音長 `-d` の**配線**を実測する（`-d 0.5` → 2行 `0.000\t2.000` / `4.000\t6.000`、`-d 3.0` → 1行 `0.000\t6.000`。2026-08-13 実測）。旧版は『しきい値(-n)と最小無音長(-d)を引数で変更できる』と主張しながら、引数を無視する実装でも PASS していた。※ `-n` の配線は意図的に未検証（I-13）"

- [ ] **p4.2**: ワークフロー1 の end-to-end: `tmp/fixture_silence_av.mp4`（映像+音声・中央2秒無音）に対し `silence_scan.sh` → `clip_export.sh`（保持区間ごと） → `concat_clips.sh` を**実際に実行**して mp4 を生成し、その出力の ffprobe duration が **3.8〜4.3 の範囲**に収まる
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts; rm -f tmp/p42_c1.mp4 tmp/p42_c2.mp4 tmp/p42_c3.mp4 tmp/p42_out.mp4 tmp/p42_ranges.txt tmp/p42_jobs.txt tmp/p42_list.txt 2>/dev/null || true; bash $S/silence_scan.sh -i tmp/fixture_silence_av.mp4 -n -40dB -d 0.5 2>/dev/null | grep -E '^[0-9]' > tmp/p42_ranges.txt; test -s tmp/p42_ranges.txt || { echo FAIL-noranges; exit 0; }; awk -F'[,\t ]+' 'NR<=2{printf "%s %.3f\n",$1,$2-$1}' tmp/p42_ranges.txt > tmp/p42_jobs.txt; n=0; : > tmp/p42_list.txt; while read -r s d; do n=$((n+1)); bash $S/clip_export.sh -i tmp/fixture_silence_av.mp4 -s "$s" -d "$d" -o "tmp/p42_c$n.mp4" >/dev/null 2>&1 || { echo FAIL-clip; exit 0; }; printf 'tmp/p42_c%s.mp4\n' "$n" >> tmp/p42_list.txt; done < tmp/p42_jobs.txt; [ "$n" -ge 2 ] || { echo "FAIL-nclips:$n"; exit 0; }; bash $S/concat_clips.sh -o tmp/p42_out.mp4 $(tr '\n' ' ' < tmp/p42_list.txt) >/dev/null 2>&1; test -f tmp/p42_out.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/p42_out.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{if(d>=3.8 && d<=4.3) print "PASS(dur=" d ")"; else print "FAIL-dur:" d}'`
  - validations:
    - technical: "★3スクリプトを実際にパイプライン実行し、生成された mp4 の duration を ffprobe で実測している（旧版はテキスト上の数値を awk で足すだけで、スクリプトを一度も実行していなかった）。★判定幅は 3.8〜4.3 に厳格化（旧版の `d>0 && d<6.0` は、パイプラインが壊れて 0.5 秒しか出なくても PASS してしまう緩さだった）"
    - consistency: "I-11 の TAB 区切り契約に従いつつ、awk -F'[,\\t ]+' で区切り文字に頑健。clip_export.sh へは -s <開始> -d <終了-開始> に変換して渡す"
    - completeness: "ワークフロー1（無音カット）の全経路 silence_scan → clip_export → concat_clips が end-to-end で動作することを保証する。rm は glob を使わず明示ファイル名列挙（zsh で `no matches found` エラーになるのを避ける）"
  - note: "実測値: 保持区間 0.000-2.000 / 4.000-6.000 → 2クリップ → concat 出力 duration = 4.023220（3.8〜4.3 の中央付近で PASS）。映像なしの fixture_silence.wav では clip_export.sh が使えないため、映像+音声の fixture_silence_av.mp4（I-10）を使う"

- [ ] **p4.3**: `scripts/transcribe.sh` が実行権限付きで存在し `bash -n` を通り、`--help` または引数なし実行で使用法を出力して exit 0 以外にならずに終了する（モデル DL を伴う実行はしない）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/transcribe.sh; test -x $S && bash -n $S && bash $S --help 2>&1 | grep -qiE 'usage|使い方' && echo PASS || echo FAIL`
  - validations:
    - technical: "構文エラーなし、--help が使用法を出す"
    - consistency: "I-1 の mlx_whisper オプション（--output-format / --language ja）を使っている"
    - completeness: "モデル未DL環境でもスクリプト自体の健全性を確認できる"

- [ ] **p4.4**: `scripts/transcribe.sh` を `mlx_whisper` が PATH 上に存在しない状態（`env PATH=/usr/bin:/bin`）で実行すると**非ゼロ終了**し、標準エラーに `mlx_whisper` を含む案内が出力される
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/transcribe.sh; test -f tmp/fixture_silence.wav || { echo FAIL-nofixture; exit 0; }; rm -f tmp/p44.err; env PATH=/usr/bin:/bin bash $S -i tmp/fixture_silence.wav >/dev/null 2>tmp/p44.err; rc=$?; [ "$rc" != "0" ] || { echo FAIL-zero-exit; exit 0; }; grep -qi 'mlx_whisper' tmp/p44.err || { echo FAIL-no-guidance; exit 0; }; echo PASS`
  - validations:
    - technical: "★挙動で検証する。旧版はソースの `grep -qE 'command -v mlx_whisper|which mlx_whisper'` のみで、コメント行1本（`# TODO: command -v mlx_whisper で存在チェックする`）だけのスクリプトでも PASS し、実際に呼ぶと rc=0 で契約（非ゼロ終了）に違反していた（4回目レビュー Minor-1・実測確認済み: 正しい実装 → rc=3 + 案内 / コメントのみ → rc=0 で FAIL-zero-exit）"
    - consistency: "I-1 の /opt/homebrew/bin/mlx_whisper 前提を環境依存にしすぎない。PATH を /usr/bin:/bin に絞ることで Homebrew 配下の mlx_whisper を不可視にして『未インストール環境』を再現する"
    - completeness: "他マシンで使ったときに原因が分かるエラー（stderr に mlx_whisper の語を含む案内）になっていることを実測する"

- [ ] **p4.5**: `references/talk-video-trim.md` に `## 段階1` と `## 段階2` の H2 見出しが各1本ずつ存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/talk-video-trim.md; [ "$(grep -c '^## 段階1' $F)" = "1" ] && [ "$(grep -c '^## 段階2' $F)" = "1" ] && echo PASS || echo FAIL`
  - validations:
    - technical: "両見出しが各1本ずつ存在する"
    - consistency: "I-8 のワークフロー1/2 と1対1で対応する"
    - completeness: "簡易版と高度版が明確に分離されている"

- [ ] **p4.6**: `## 段階1` 区間に `silencedetect` と `loudnorm` が、`## 段階2` 区間に `mlx_whisper` と「言い直し」「フィラー」が逐語で含まれ、段階2区間に「テロップは焼かない」旨（`焼か` を含む行）が存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/talk-video-trim.md; rm -f tmp/p46a.txt tmp/p46b.txt; awk '/^## 段階1/{f=1;next} f&&/^## /{f=0} f' $F > tmp/p46a.txt; awk '/^## 段階2/{f=1;next} f&&/^## /{f=0} f' $F > tmp/p46b.txt; test -s tmp/p46a.txt && test -s tmp/p46b.txt || { echo FAIL-nosection; exit 0; }; for s in silencedetect loudnorm; do grep -qF "$s" tmp/p46a.txt || { echo "FAIL-s1:$s"; exit 0; }; done; for s in mlx_whisper 言い直し フィラー 焼か; do grep -qF "$s" tmp/p46b.txt || { echo "FAIL-s2:$s"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "各区間に該当キーワードが存在する"
    - consistency: "I-8 の『テロップは画面に焼かない（判定にのみ使う）』方針と一致する"
    - completeness: "段階1が AI 不要、段階2が文字起こし利用と読み分けられる"

**status**: pending
**max_iterations**: 8
**time_limit**: 75min
**priority**: high

---

### p5: SKILL.md（ルーティング）の作成

**goal**: 3ワークフローへのルーティングと起動フレーズを備えた SKILL.md を作成し、references/scripts への導線を全て繋ぐ

**depends_on**: [p3, p4]

#### subtasks

- [ ] **p5.1**: `SKILL.md` の先頭 frontmatter（1行目 `---` から次の `---` まで）内の `name:` が `video-editing-ffmpeg` である
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; head -1 $F | grep -qx -- '---' && awk 'NR>1 && /^---$/{exit} NR>1' $F | grep -qx 'name: video-editing-ffmpeg' && echo PASS || echo FAIL`
  - validations:
    - technical: "frontmatter が1行目から始まり name が完全一致する"
    - consistency: "ディレクトリ名 video-editing-ffmpeg と一致する"
    - completeness: "既存スキル（threads-pdca）の frontmatter 形式と同じ"

- [ ] **p5.2**: frontmatter 内の `description:` 行に I-9 の起動フレーズ6個が全て逐語で含まれる
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; awk 'NR>1 && /^---$/{exit} NR>1' $F | grep '^description:' > tmp/p52.txt; for s in '動画を編集して' 'トーク動画を整えて' '無音をカットして' '言い直しをカットして' 'ハイライトReelを作って' '動画が真っ暗になる'; do grep -qF "$s" tmp/p52.txt || { echo "FAIL:$s"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "6フレーズすべてが description 行に存在する"
    - consistency: "I-9 と一字一句一致する"
    - completeness: "3ワークフローすべてに起動経路がある"

- [ ] **p5.3**: `SKILL.md` に `## ワークフロー1` `## ワークフロー2` `## ワークフロー3` の H2 見出しが各1本ずつ存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; for n in 1 2 3; do [ "$(grep -c "^## ワークフロー$n" $F)" = "1" ] || { echo FAIL; exit 0; }; done; echo PASS`
  - validations:
    - technical: "3見出しが各1本ずつ"
    - consistency: "I-8 のワークフロー定義3本と1対1対応"
    - completeness: "重複・欠落がない"

- [ ] **p5.4**: 各ワークフロー区間内に `references/` を含む行と `scripts/` を含む行がそれぞれ1行以上存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; rm -f tmp/w1.txt tmp/w2.txt tmp/w3.txt; for n in 1 2 3; do awk -v n="$n" '$0 ~ "^## ワークフロー" n {f=1;next} f&&/^## /{f=0} f' $F > tmp/w$n.txt; done; for f in tmp/w1.txt tmp/w2.txt tmp/w3.txt; do test -s $f || { echo "FAIL-nosection:$f"; exit 0; }; grep -qF 'references/' $f && grep -qF 'scripts/' $f || { echo "FAIL:$f"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "3区間すべてで両参照が存在する"
    - consistency: "I-7 の構成・I-8 の使用スクリプトと矛盾しない"
    - completeness: "progressive disclosure（SKILL.md → references）が成立する"

- [ ] **p5.5**: `SKILL.md` が参照する `references/*.md` と `scripts/*` のパスが全て実在する
  - executor: claudecode
  - test_command: `B=.claude/skills/video-editing-ffmpeg; rm -f tmp/p55.txt; grep -oE '(references|scripts)/[A-Za-z0-9_.-]+' $B/SKILL.md | sort -u > tmp/p55.txt; test -s tmp/p55.txt || { echo FAIL-norefs; exit 0; }; while read -r p; do test -e "$B/$p" || { echo "FAIL:$p"; exit 0; }; done < tmp/p55.txt; echo PASS`
  - validations:
    - technical: "参照パスがすべて実在する（リンク切れなし）"
    - consistency: "p1〜p4 で作成した7スクリプト・3リファレンスと一致する"
    - completeness: "存在しないファイルを案内していない"

- [ ] **p5.6**: `SKILL.md` の冒頭（`## ワークフロー1` より前）に `ffmpeg-pitfalls.md` を先に読む旨の行が存在し、`drawtext` が使えない旨が記載されている
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; rm -f tmp/p56.txt; awk '/^## ワークフロー1/{exit} {print}' $F > tmp/p56.txt; test -s tmp/p56.txt || { echo FAIL-nosection; exit 0; }; grep -qF 'ffmpeg-pitfalls.md' tmp/p56.txt && grep -qF 'drawtext' tmp/p56.txt && echo PASS || echo FAIL`
  - validations:
    - technical: "冒頭区間に両文字列が存在する"
    - consistency: "落とし穴が全ワークフロー共通の前提として提示される"
    - completeness: "スキル起動直後に地雷を踏まない導線になっている"

- [ ] **p5.7**: `SKILL.md` が 200 行以下である（ルーティングに徹し詳細は references に置く）
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; test -f $F || { echo FAIL-nofile; exit 0; }; wc -l < $F | awk '{if($1<=200) print "PASS"; else print "FAIL:"$1}'`
  - validations:
    - technical: "行数が 200 以下。★ファイル不在時も必ず FAIL-nofile を出力する（旧版は wc がエラーで無出力になり、他の test_command と挙動が不揃いだった）"
    - consistency: "既存 threads-pdca の SKILL.md と同程度の粒度"
    - completeness: "詳細が references に退避され情報が失われていない"

**status**: pending
**max_iterations**: 6
**time_limit**: 50min
**priority**: high

---

### p_final: 完了検証（必須）

> **goal.done_when（DW1〜DW7）が実際に満たされているか、フィクスチャを再生成した上で end-to-end で最終検証する。**
> **★ 加えて p_final.9 で、DW には現れないが I-11 契約に含まれる項目（`-r` のアスペクト維持 /
> `--label-pos` / fade-in）を最終成果物に対して再検証する（I-13 の棚卸し結果に基づく）。**

#### subtasks

- [ ] **p_final.0**: 検証用フィクスチャ**6本**（`tmp/fixture_hlg.mp4` / `tmp/fixture_hlg_sdrtag.mp4` / `tmp/fixture_scenes.mp4` / `tmp/fixture_silence.wav` / `tmp/fixture_silence_av.mp4` / `tmp/fixture_videoonly.mp4`）が I-10 のコマンドで再生成され、HLG フィクスチャの color_transfer が `arib-std-b67`・双子フィクスチャの color_transfer が `bt709` で**両者の pix_fmt が同一**であり、`fixture_scenes.mp4` と `fixture_silence_av.mp4` が音声ストリームを1本ずつ持ち、**`fixture_videoonly.mp4` の音声ストリームが0本である**
  - executor: claudecode
  - test_command: `for f in tmp/fixture_hlg.mp4 tmp/fixture_hlg_sdrtag.mp4 tmp/fixture_scenes.mp4 tmp/fixture_silence.wav tmp/fixture_silence_av.mp4 tmp/fixture_videoonly.mp4; do test -f $f || { echo "FAIL-missing:$f"; exit 0; }; done; ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=nw=1:nk=1 tmp/fixture_hlg.mp4 | grep -qx 'arib-std-b67' || { echo FAIL-hlg; exit 0; }; ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=nw=1:nk=1 tmp/fixture_hlg_sdrtag.mp4 | grep -qx 'bt709' || { echo FAIL-sdrtag-tag; exit 0; }; PA=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 tmp/fixture_hlg.mp4); PB=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 tmp/fixture_hlg_sdrtag.mp4); [ -n "$PA" ] && [ "$PA" = "$PB" ] || { echo "FAIL-sdrtag-pixfmt:$PA!=$PB"; exit 0; }; for f in tmp/fixture_scenes.mp4 tmp/fixture_silence_av.mp4; do [ "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 $f | grep -c .)" = "1" ] || { echo "FAIL-noaudio:$f"; exit 0; }; done; [ "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 tmp/fixture_videoonly.mp4 | grep -c .)" = "0" ] || { echo FAIL-videoonly-has-audio; exit 0; }; echo PASS`
  - validations:
    - technical: "6フィクスチャが存在し、HLG タグ・双子の SDR タグと pix_fmt 同一性・音声ストリーム本数（あり2本 / なし1本）が正しい"
    - consistency: "I-10 の生成コマンドから再現されている"
    - completeness: "★音声なしフィクスチャの『音声0本』アサートを含むため p_final.3(c) の -map \"0:a?\" 検証が骨抜きにならず、★双子の pix_fmt 同一性アサートを含むため p_final.3(d) の tonemap 検証が空振りしない"

- [ ] **p_final.1**: DW1 が満たされている（SKILL.md の name / 起動フレーズ6個 / ワークフロー H2 3本 / 各区間の references・scripts 参照）
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/SKILL.md; test -f $F || { echo FAIL-nofile; exit 0; }; awk 'NR>1 && /^---$/{exit} NR>1' $F | grep -qx 'name: video-editing-ffmpeg' || { echo FAIL-name; exit 0; }; D=$(awk 'NR>1 && /^---$/{exit} NR>1' $F | grep '^description:'); [ -n "$D" ] || { echo FAIL-nodesc; exit 0; }; for s in '動画を編集して' 'トーク動画を整えて' '無音をカットして' '言い直しをカットして' 'ハイライトReelを作って' '動画が真っ暗になる'; do echo "$D" | grep -qF "$s" || { echo "FAIL-phrase:$s"; exit 0; }; done; for n in 1 2 3; do [ "$(grep -c "^## ワークフロー$n" $F)" = "1" ] || { echo FAIL-h2; exit 0; }; done; rm -f tmp/f1.txt tmp/f2.txt tmp/f3.txt; for n in 1 2 3; do awk -v n="$n" '$0 ~ "^## ワークフロー" n {f=1;next} f&&/^## /{f=0} f' $F > tmp/f$n.txt; done; for f in tmp/f1.txt tmp/f2.txt tmp/f3.txt; do test -s $f || { echo "FAIL-nosection:$f"; exit 0; }; grep -qF 'references/' $f && grep -qF 'scripts/' $f || { echo "FAIL-ref:$f"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "name・6フレーズ・H2 3本・各区間参照の全条件が一括で PASS"
    - consistency: "p5.1〜p5.4 の個別検証と同じ結果になる"
    - completeness: "DW1 の全構成要素を漏れなく検証している"

- [ ] **p_final.2**: DW2 が満たされている（ffmpeg-pitfalls.md の H2 3本 / 逐語7文字列 / 落とし穴2 の NG・OK 両例）
  - executor: claudecode
  - test_command: `F=.claude/skills/video-editing-ffmpeg/references/ffmpeg-pitfalls.md; test -f $F || { echo FAIL-nofile; exit 0; }; for n in 1 2 3; do [ "$(grep -c "^## 落とし穴$n" $F)" = "1" ] || { echo FAIL-h2; exit 0; }; done; for s in 'drawtext' 'libfreetype' 'tonemap=mobius:param=0.5' 'colorprim=bt709:transfer=bt709:colormatrix=bt709' 'arib-std-b67' 'eq=gamma=1.15:brightness=0.03' 'overlay'; do grep -qF "$s" $F || { echo "FAIL-kw:$s"; exit 0; }; done; rm -f tmp/f4.txt; awk '/^## 落とし穴2/{f=1;next} f&&/^## /{f=0} f' $F > tmp/f4.txt; test -s tmp/f4.txt || { echo FAIL-nosection; exit 0; }; grep -qF -- '-i input.mp4 -t' tmp/f4.txt && grep -qF -- '-t 3 -i input.mp4' tmp/f4.txt && echo PASS || echo FAIL-example`
  - validations:
    - technical: "見出し3本・キーワード7個・NG/OK 両例が全て存在する"
    - consistency: "I-2〜I-4 の記述と逐語一致する"
    - completeness: "3つの詰まりどころが再発防止可能な粒度で残っている"

- [ ] **p_final.3**: DW3 が満たされている（(a) HLG フィクスチャから 3秒・bt709×3・**pix_fmt=yuv420p** の mp4 を実生成 / (b) `--dry-run` 出力に tonemap・eq・`-map "0:a?"` が逐語で含まれ、**その文字列を eval した出力と実 run 出力の映像 md5 が一致する** / (c) 音声なし入力でも成功する / (d) **双子フィクスチャ入力の出力と HLG 入力の出力の映像 md5 が異なる**）
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; test -x $S || { echo FAIL-notexec; exit 0; }; rm -f tmp/fin3.mp4 tmp/fin3b.mp4 tmp/fin3c.mp4 tmp/fin3d.mp4 tmp/fin3e.mp4; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/fin3.mp4 >/dev/null 2>&1; test -f tmp/fin3.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/fin3.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{exit !(d>=2.85 && d<=3.15)}' || { echo "FAIL-dur:$D"; exit 0; }; C=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer,color_space,color_primaries -of default=nw=1:nk=1 tmp/fin3.mp4 | sort -u | tr -d '\n'); [ "$C" = "bt709" ] || { echo "FAIL-color:$C"; exit 0; }; PF=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 tmp/fin3.mp4); [ "$PF" = "yuv420p" ] || { echo "FAIL-pixfmt:$PF"; exit 0; }; CMD=$(bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/fin3b.mp4 --dry-run 2>/dev/null); [ $? = 0 ] || { echo FAIL-dryrc; exit 0; }; test -f tmp/fin3b.mp4 && { echo FAIL-dryrun-wrote-file; exit 0; }; printf '%s' "$CMD" | grep -qF 'tonemap=mobius:param=0.5' || { echo FAIL-notonemap; exit 0; }; printf '%s' "$CMD" | grep -qF 'eq=gamma=1.15:brightness=0.03' || { echo FAIL-noeq; exit 0; }; printf '%s' "$CMD" | grep -qF -- '-map "0:a?"' || { echo FAIL-nooptmap; exit 0; }; DCMD=$(bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/fin3e.mp4 --dry-run 2>/dev/null); eval "$DCMD" </dev/null >/dev/null 2>&1 || { echo FAIL-dryrun-not-executable; exit 0; }; test -f tmp/fin3e.mp4 || { echo FAIL-dryrun-noout; exit 0; }; ME=$(ffmpeg -v error -i tmp/fin3e.mp4 -map 0:v -f md5 - 2>/dev/null); MR=$(ffmpeg -v error -i tmp/fin3.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$ME" ] && [ -n "$MR" ] || { echo FAIL-nomd5; exit 0; }; [ "$ME" = "$MR" ] || { echo "FAIL-dryrun-mismatch:$ME!=$MR"; exit 0; }; bash $S -i tmp/fixture_hlg_sdrtag.mp4 -s 1 -d 3 -o tmp/fin3d.mp4 >/dev/null 2>&1 || { echo FAIL-sdrtag-exit; exit 0; }; MS=$(ffmpeg -v error -i tmp/fin3d.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$MS" ] || { echo FAIL-sdrtag-nomd5; exit 0; }; [ "$MS" = "$MR" ] && { echo FAIL-tonemap-noop; exit 0; }; bash $S -i tmp/fixture_videoonly.mp4 -s 1 -d 2 -o tmp/fin3c.mp4 >/dev/null 2>&1 || { echo FAIL-videoonly-exit; exit 0; }; test -f tmp/fin3c.mp4 || { echo FAIL-videoonly-noout; exit 0; }; D3=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/fin3c.mp4); awk -v d="$D3" 'BEGIN{if(d>0) print "PASS"; else print "FAIL-videoonly-dur:" d}'`
  - validations:
    - technical: "実際にエンコードを走らせ duration・3色タグ・pix_fmt を実測し、--dry-run 文字列の逐語検証に加えて**その文字列が実処理と同一であること**を md5 で確認し、双子フィクスチャとの md5 差分で tonemap が実際にピクセルを変えていることを文字列非依存で確認し、音声なし入力の実行成功も確認している"
    - consistency: "I-4 の検証済みコマンドと同じ結果（duration=3.0 / bt709 / pix_fmt=yuv420p）になり、I-10 の双子フィクスチャ・I-11 の --dry-run 出力要件と一致する"
    - completeness: "★色タグ検査だけでは tonemap 未実装を検出できない（-x264-params だけで3タグは bt709 になる実測事実）。★さらに --dry-run 文字列の grep だけでも不十分（dry-run 文字列と実処理を別々に組み立てる実装で全 subtask が PASS した実測事実 / 3回目レビュー M-2）。DW3 レベルでは (a) pix_fmt・(b) dry-run↔実 run の md5 一致・(d) 双子フィクスチャの md5 差分という**3つの生成物ベース検証**で塞ぐ"

- [ ] **p_final.4**: DW4 が満たされている（make_label_png.py が RGBA 透過 PNG を生成し、それを合成した mp4 が生成され、**ラベル無し出力と映像 md5 が異なる**）
  - executor: claudecode
  - test_command: `P=.claude/skills/video-editing-ffmpeg/scripts/make_label_png.py; S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; test -x $P || { echo FAIL-notexec; exit 0; }; rm -f tmp/fin4.png tmp/fin4.mp4 tmp/fin4n.mp4; python3 $P --text 'ウォールボール' --out tmp/fin4.png >/dev/null 2>&1; test -s tmp/fin4.png || { echo FAIL-nopng; exit 0; }; python3 -c "from PIL import Image; im=Image.open('tmp/fin4.png'); a=im.getchannel('A').getextrema(); assert im.mode=='RGBA' and a[0]==0 and a[1]>0" 2>/dev/null || { echo FAIL-png; exit 0; }; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 --label tmp/fin4.png --label-pos 10:20 -o tmp/fin4.mp4 >/dev/null 2>&1; test -f tmp/fin4.mp4 || { echo FAIL-noout; exit 0; }; D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 tmp/fin4.mp4); [ -n "$D" ] || { echo FAIL-noprobe; exit 0; }; awk -v d="$D" 'BEGIN{exit !(d>0)}' || { echo "FAIL-mp4:$D"; exit 0; }; bash $S -i tmp/fixture_hlg.mp4 -s 1 -d 3 -o tmp/fin4n.mp4 >/dev/null 2>&1 || { echo FAIL-nolabel-exit; exit 0; }; test -f tmp/fin4n.mp4 || { echo FAIL-nolabel-noout; exit 0; }; ML=$(ffmpeg -v error -i tmp/fin4.mp4 -map 0:v -f md5 - 2>/dev/null); MN=$(ffmpeg -v error -i tmp/fin4n.mp4 -map 0:v -f md5 - 2>/dev/null); [ -n "$ML" ] && [ -n "$MN" ] || { echo FAIL-nomd5; exit 0; }; [ "$ML" = "$MN" ] && { echo FAIL-label-invisible; exit 0; }; echo PASS`
  - validations:
    - technical: "PNG の RGBA/alpha 実測と overlay 合成の実行に加えて、★合成結果がラベル無し出力と**ピクセルレベルで異なる**ことを実測している"
    - consistency: "drawtext 不在という前提（I-2）の回避策が機能している。I-5 の修正済みレシピ（-loop 1 / shortest=1）が実 PNG でも効いている"
    - completeness: "★旧版は duration > 0 しか見ておらず、ラベルが一度も表示されない実装でも PASS していた（3回目レビュー C-1）。DW4 の主張（ラベル合成ができている）を生成物で裏づける。`--label-pos 10:20` を明示指定して、既定位置（y=H-400）がラベル寸法によっては画面外に出るような偶発的空振りを避ける"

- [ ] **p_final.5**: DW5 が満たされている（4スクリプトの実行権限と bash -n / scene_scan 2行以上 / silence_scan 2行以上）
  - executor: claudecode
  - test_command: `B=.claude/skills/video-editing-ffmpeg/scripts; for s in scene_scan.sh silence_scan.sh concat_clips.sh transcribe.sh; do test -x $B/$s || { echo "FAIL-x:$s"; exit 0; }; bash -n $B/$s || { echo "FAIL-syntax:$s"; exit 0; }; done; N1=$(bash $B/scene_scan.sh -i tmp/fixture_scenes.mp4 -t 0.3 2>/dev/null | grep -c 'pts_time'); N2=$(bash $B/silence_scan.sh -i tmp/fixture_silence.wav -n -40dB -d 0.5 2>/dev/null | grep -cE '^[0-9]+\.?[0-9]*[[:space:],]+[0-9]+\.?[0-9]*$'); [ "$N1" -ge 2 ] && [ "$N2" -ge 2 ] && echo PASS || echo "FAIL:scene=$N1 silence=$N2"`
  - validations:
    - technical: "4本の構文検査と2本の実出力件数を実測している"
    - consistency: "I-6 の実測（pts_time 2件 / 無音1区間→保持2区間）と一致する"
    - completeness: "ワークフロー1・2・3 の入口スクリプトが全て動作する"

- [ ] **p_final.6**: DW6 が満たされている（talk-video-trim.md の段階1/2 見出しと区間キーワード / highlight-reel.md の手順見出しとステップ5行以上）
  - executor: claudecode
  - test_command: `T=.claude/skills/video-editing-ffmpeg/references/talk-video-trim.md; H=.claude/skills/video-editing-ffmpeg/references/highlight-reel.md; test -f $T && test -f $H || { echo FAIL-nofile; exit 0; }; [ "$(grep -c '^## 段階1' $T)" = "1" ] && [ "$(grep -c '^## 段階2' $T)" = "1" ] || { echo FAIL-stage; exit 0; }; awk '/^## 段階2/{f=1;next} f&&/^## /{f=0} f' $T | grep -qF 'mlx_whisper' || { echo FAIL-whisper; exit 0; }; [ "$(grep -c '^## 手順' $H)" = "1" ] || { echo FAIL-tejun; exit 0; }; N=$(awk '/^## 手順/{f=1;next} f&&/^## /{f=0} f' $H | grep -cE '^[0-9]+\.'); [ "$N" -ge 5 ] && echo PASS || echo "FAIL-steps:$N"`
  - validations:
    - technical: "見出し数・キーワード・ステップ行数を実測している"
    - consistency: "I-8 のワークフロー定義と各リファレンスが対応する"
    - completeness: "2リファレンスとも実用に足る手順が書かれている"

- [ ] **p_final.7**: DW7 が満たされている（**追跡済み差分 + 未追跡ファイルの和集合**で、既存スキルへの変更0件、かつ I-12 の除外集合に該当しない変更ファイル0件）
  - executor: claudecode
  - test_command: `LIST=$( { git -c core.quotepath=false diff --name-only 609cc09; git -c core.quotepath=false status --porcelain | sed 's/^...//' | sed 's/.* -> //'; } | tr -d '"' | grep -v '^$' | sort -u ); EX='^(\.claude/skills/video-editing-ffmpeg/|\.claude/agents/critic\.md$|\.claude/worktrees/|\.gitignore$|plan/playbook-video-editing-ffmpeg-skill\.md$|plan/playbook-setup-instagram-skills\.md$|state\.md$|tmp/|docs/repository-map\.yaml$)'; M=$(printf '%s\n' "$LIST" | grep '^\.claude/skills/' | grep -cv '^\.claude/skills/video-editing-ffmpeg/'); N=$(printf '%s\n' "$LIST" | grep -vE "$EX" | grep -c .); [ "$M" = "0" ] && [ "$N" = "0" ] && echo PASS || { echo "FAIL:other_skills=$M other_files=$N"; printf '%s\n' "$LIST" | grep -vE "$EX"; }`
  - validations:
    - technical: "★`git diff --name-only`（追跡済みのみ）に加えて `git status --porcelain`（未追跡を含む）も集合に入れている。本スキルは全ファイルが未追跡で始まるため、旧版の diff のみでは余計な未追跡ファイルの混入を一切検出できなかった"
    - consistency: "除外集合が I-12 の一覧および DW7 の文面と完全一致する（`docs/repository-map.yaml` = ft1 が再生成、`.gitignore` = ft0 が追記）"
    - completeness: "回帰（既存資産の破壊）と混入（想定外ファイルの追加）の両方を保証し、FAIL 時は違反ファイル名を出力する"
  - note: "実測確認済み: 現状の作業ツリーで M=0 / N=0 を返し、`docs/_stray_test.md` を置くと N=1 で検出する"

- [ ] **p_final.8**: state.md の `playbook.active` が `plan/playbook-video-editing-ffmpeg-skill.md`、`playbook.branch` が `feat/video-editing-ffmpeg-skill` で、git の現在ブランチと一致している
  - executor: claudecode
  - test_command: `grep -qF 'active: plan/playbook-video-editing-ffmpeg-skill.md' state.md && grep -qF 'branch: feat/video-editing-ffmpeg-skill' state.md && [ "$(git branch --show-current)" = "feat/video-editing-ffmpeg-skill" ] && echo PASS || echo FAIL`
  - validations:
    - technical: "state.md の2行と git ブランチ名が一致する"
    - consistency: "four-tuple coherence（focus / playbook / branch / phase）が保たれている"
    - completeness: "アーカイブ前提となる状態同期が完了している"

- [ ] **p_final.9**: **I-11 契約のうち DW1〜DW7 に現れない項目**（`-r` のアスペクト維持 / `--label-pos` の座標反映 / `--label` の fade-in）が、最終成果物でも生成物ベースで満たされている
  - executor: claudecode
  - test_command: `S=.claude/skills/video-editing-ffmpeg/scripts/clip_export.sh; L=tmp/lbl9.png; rm -f $L tmp/fin9r.mp4 tmp/fin9.mp4 tmp/fin9p.mp4; bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 -r 1080x1920 -o tmp/fin9r.mp4 >/dev/null 2>&1; test -f tmp/fin9r.mp4 || { echo FAIL-r-noout; exit 0; }; WH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/fin9r.mp4); [ "$WH" = "1080,1920" ] || { echo "FAIL-r-wh:$WH"; exit 0; }; SWH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 tmp/fixture_scenes.mp4); SW=${SWH%,*}; SH=${SWH#*,}; CD=$(ffmpeg -hide_banner -i tmp/fin9r.mp4 -vf cropdetect=limit=24:round=2 -frames:v 30 -f null - 2>&1 | grep -o 'crop=[0-9:]*' | tail -1); CW=$(printf '%s' "$CD" | cut -d= -f2 | cut -d: -f1); CH=$(printf '%s' "$CD" | cut -d= -f2 | cut -d: -f2); { [ -n "$CW" ] && [ -n "$CH" ] && [ "$CH" != "0" ] && [ -n "$SW" ] && [ -n "$SH" ]; } || { echo "FAIL-r-nocrop:$CD"; exit 0; }; awk -v cw="$CW" -v ch="$CH" -v sw="$SW" -v sh="$SH" 'BEGIN{r=cw/ch; s=sw/sh; d=(r-s)/s; if(d<0)d=-d; exit !(d<=0.02)}' || { echo "FAIL-r-stretched:$CD"; exit 0; }; { [ "$CW" = "1080" ] || [ "$CH" = "1920" ]; } || { echo "FAIL-r-notfitted:$CD"; exit 0; }; ffmpeg -y -f lavfi -i "color=c=white:s=300x120,format=rgba" -frames:v 1 $L >/dev/null 2>&1; test -s $L || { echo FAIL-nolabelpng; exit 0; }; perl -e 'alarm shift; exec @ARGV' 60 bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 --label $L --label-pos 10:20 -o tmp/fin9.mp4 >/dev/null 2>&1 || { echo FAIL-label-exit-or-hang; exit 0; }; bash $S -i tmp/fixture_scenes.mp4 -s 0 -d 2 --label $L --label-pos 300:300 -o tmp/fin9p.mp4 >/dev/null 2>&1 || { echo FAIL-pos2-exit; exit 0; }; M1=$(ffmpeg -v error -i tmp/fin9.mp4 -map 0:v -f md5 - 2>/dev/null); M2=$(ffmpeg -v error -i tmp/fin9p.mp4 -map 0:v -f md5 - 2>/dev/null); { [ -n "$M1" ] && [ -n "$M2" ]; } || { echo FAIL-nomd5; exit 0; }; [ "$M1" = "$M2" ] && { echo FAIL-labelpos-ignored; exit 0; }; GA=$(ffmpeg -v error -ss 0.05 -i tmp/fin9.mp4 -vf "crop=200:80:20:30,scale=1:1" -frames:v 1 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | od -An -tu1 | awk '{print $2}'); GB=$(ffmpeg -v error -ss 1.5 -i tmp/fin9.mp4 -vf "crop=200:80:20:30,scale=1:1" -frames:v 1 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | od -An -tu1 | awk '{print $2}'); { [ -n "$GA" ] && [ -n "$GB" ]; } || { echo FAIL-nopixel; exit 0; }; awk -v a="$GA" -v b="$GB" 'BEGIN{d=a-b; if(d<0)d=-d; exit !(d>=30)}' || { echo "FAIL-nofade:$GA/$GB"; exit 0; }; echo PASS`
  - validations:
    - technical: "★DW は SKILL.md / スクリプトの主要動作しか主張しておらず、I-11 の `-r` / `--label-pos` / fade は p2 の subtask でしか検証されていなかった。p2 完了後に clip_export.sh が変更されるとこれらは無検証のまま出荷される。本 subtask が最終成果物に対して同じ生成物アサートを再実行する（4回目レビューの契約棚卸しで新設）"
    - consistency: "p2.6（cropdetect 3点）と p2.10 の (3)(4) と同一のアサートを、最終成果物に対して再実行する"
    - completeness: "実測（2026-08-13・プロトタイプ実装で検証）: 正しい実装 → PASS / `scale=${W}:${H}` のみ → FAIL-r-stretched / 実行時だけ既定座標に差し替える実装 → FAIL-labelpos-ignored / fade を外した実装 → FAIL-nofade"

**status**: pending
**max_iterations**: 3
**time_limit**: 40min
**priority**: high

---

## final_tasks

> **★ `git add -A` は本 playbook では禁止（理由は I-12 参照）。**
> 別タスクの `plan/playbook-setup-instagram-skills.md`（exclusions で「触らない」と宣言済み）と
> `.claude/agents/critic.md`（別件の未コミット変更）が混入するため。
> （`.claude/worktrees/` は現在 `.git/info/exclude` により既に除外済みで status に現れない。
> ただしそれはローカル専用の除外なので、ft0 で `.gitignore` に一本化して恒久化する。I-12 参照）
>
> **★ `git commit` にも同じ pathspec を渡すこと。** `git add <明示パス> && git commit -m ...` の
> commit 側に pathspec が無いと **index 全体**がコミットされ、事前にステージされていた
> 無関係な変更が明示パス指定の防御を素通りして混入する（scratch リポジトリで実測確認済み）。

- [ ] **ft0**: `.claude/worktrees/` を .gitignore に追記して恒久化する（冪等）
  - command: `grep -qxF '.claude/worktrees/' .gitignore || printf '\n# Git worktrees (never commit)\n.claude/worktrees/\n' >> .gitignore`
  - verify: `grep -qxF '.claude/worktrees/' .gitignore || { echo FAIL-nogitignore; exit 0; }; git check-ignore -q .claude/worktrees 2>/dev/null || { echo FAIL-not-ignored; exit 0; }; git status --porcelain | grep -q '^?? \.claude/worktrees' && { echo FAIL-still-listed; exit 0; }; echo PASS`
  - 目的: 現状 `.git/info/exclude`（ローカル専用・共有されない）だけに頼っている除外を、追跡ファイルである `.gitignore` に移して他マシン・clone 後にも効くようにする。`.git/info/exclude` の既存行は触らない（二重指定は無害）
  - 注: verify の主判定は `grep -qxF '.claude/worktrees/' .gitignore`。`git check-ignore` は二重指定のため `.git/info/exclude:11` を出典として報告しうる（＝「無視されているか」だけの補助チェック）。実測: 現在 `.claude/worktrees` は実在ディレクトリで check-ignore rc=0 / status 非表示
  - status: pending

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - verify: `test -f docs/repository-map.yaml || { echo FAIL-nofile; exit 0; }; grep -qF 'video-editing-ffmpeg' docs/repository-map.yaml && echo PASS || echo FAIL-noskill`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイル（フィクスチャ・検証出力）を削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true; rm -rf tmp/thumbs`
  - verify: `N=$(find tmp/ -type f ! -name 'README.md' | grep -c .); [ "$N" = "0" ] && echo PASS || echo "FAIL-leftover:$N"`
  - status: pending

- [ ] **ft3**: 本タスクの成果物のみを**明示パス指定で** add し、**同じ pathspec を付けて** commit する
  - command: `git add .claude/skills/video-editing-ffmpeg plan/playbook-video-editing-ffmpeg-skill.md state.md docs/repository-map.yaml .gitignore && git commit -m "feat(skills): add video-editing-ffmpeg skill" -- .claude/skills/video-editing-ffmpeg plan/playbook-video-editing-ffmpeg-skill.md state.md docs/repository-map.yaml .gitignore`
  - verify: `git rev-parse --verify HEAD >/dev/null 2>&1 || { echo FAIL-nocommit; exit 0; }; git log -1 --pretty=%s | grep -qF 'video-editing-ffmpeg' || { echo FAIL-wrongcommit; exit 0; }; LEFT=$(git -c core.quotepath=false diff --cached --name-only | grep -vE '^(\.claude/skills/video-editing-ffmpeg/|plan/playbook-video-editing-ffmpeg-skill\.md$|state\.md$|docs/repository-map\.yaml$|\.gitignore$)' | grep . || true); [ -n "$LEFT" ] && { echo "PASS(WARN-staged-leftover: $(printf '%s' "$LEFT" | tr '\n' ' '))"; exit 0; }; echo PASS`
  - 禁止: `git add -A` / `git add .` / `git add -u` / pathspec 無しの `git commit`（I-12 参照）
  - 注（m-5 / 3回目レビュー）: pathspec 付き commit は「pathspec 外のステージ済み変更をコミットに含めない」だけで、**index からは外さない**（実測確認済み: 事前に `base.txt` / `other.txt` をステージした状態で pathspec 付き commit を実行すると、コミット内容は pathspec のみだが `git diff --cached` には両ファイルが残る）。残留したステージは後続の別ワークフローの `git commit` で意図せず混入しうるため、verify で検出して警告する。★警告は FAIL ではない（本 playbook の成果物コミット自体は正しく完了しているため）。警告が出た場合は `git restore --staged <該当ファイル>` で index から外してから次の作業に移ること
  - status: pending

- [ ] **ft4**: コミット結果を **allowlist** で検証する（成果物がコミットされ、許可外のファイルが1件も含まれない）
  - command: `git -c core.quotepath=false show --pretty=format: --name-only HEAD | grep -q '^\.claude/skills/video-editing-ffmpeg/' || { echo FAIL-noskill; exit 0; }; git -c core.quotepath=false show --pretty=format: --name-only HEAD | grep -v '^$' | grep -vE '^(\.claude/skills/video-editing-ffmpeg/|plan/playbook-video-editing-ffmpeg-skill\.md$|state\.md$|docs/repository-map\.yaml$|\.gitignore$)' | grep -q . && { echo FAIL-extra; git -c core.quotepath=false show --pretty=format: --name-only HEAD | grep -vE '^(\.claude/skills/video-editing-ffmpeg/|plan/playbook-video-editing-ffmpeg-skill\.md$|state\.md$|docs/repository-map\.yaml$|\.gitignore$)'; exit 0; }; echo PASS`
  - 期待: HEAD に含まれるのは許可5パターンのみ。★旧版は worktrees / 別タスク playbook / critic.md の3件だけを見る denylist で、それ以外の混入を検出できなかった（scratch リポジトリで allowlist 版の動作を実測確認済み）
  - status: pending

---

## notes

```yaml
★ 検証方針の絶対ルール（3回の FAIL 全ての根本原因。全 subtask に無条件で適用する）:
  - 必須挙動は「その挙動が壊れたとき、生成物（ピクセル / ストリーム構成 / pix_fmt）が変わること」で検証する。
    文字列 grep でしか守れていない必須挙動は、未検証とみなす。
  - 系: duration 範囲だけの検証も「生成物の検証」には当たらない。
    duration は overlay が全く効いていなくても、tonemap が無くても、
    映像ストリームが無くても変わらないため、必須挙動の担保にはならない。
  - 系: 文字列 grep を使ってよいのは、その文字列が実処理と一致していることを
    別途「生成物」で確認できている場合のみ（例: --dry-run 文字列は p2.9 の
    「dry-run を eval した出力と実 run 出力の映像 md5 一致」で実処理との同一性を担保しているので、
    その上に乗る tonemap / -map "0:a?" の grep は有効になる）。
  - 系: 「経路が増えたら検証も増やす」。-vf 経路と filter_complex 経路のように
    同じ必須挙動を通る経路が2本あるなら、必須挙動ごとに両経路を検証する
    （3回目 FAIL の M-1 はこれ。-vf 経路だけ -map "0:a?" が検証されていた）。
  - 系: 差分検証（A と B の md5 が異なる）を書くときは、
    ★対比が成立する素材を選ぶこと。同色ラベルを同色素材に重ねる、
    同一エンコード設定同士を比べる等は、実装が正しくても差が出ず検証が空振りする。
  - 系（4回目 FAIL の根本原因）: ★このルールは「今回指摘された箇所」ではなく
    **契約全体**に適用する。I-11 に契約項目を1つ足したら、I-13 の棚卸し表にも1行足し、
    「生成物で検証されているか / S なら土台の G はどれか / N なら理由は何か」を明記する。
    棚卸し表に載っていない契約項目は、未検証とみなす。
  - 系: ★オプション引数は「受け取れること」ではなく「**配線されていること**」を検証する。
    引数値を変えたら生成物（または標準出力）が変わることをアサートする
    （例: --label-pos 2座標の md5 差分 / scene_scan -t 0.99 → 0件 / silence_scan -d 3.0 → 1行）。
  - 系: ★必須挙動の欠落が **FAIL ではなくハング**になる場合がある
    （例: overlay の shortest=1 欠落 → -loop 1 の無限入力で終端しない）。
    その test_command は `perl -e 'alarm shift; exec @ARGV' <秒> bash ...` でラップし、
    ハングを FAIL に変換する（max_iterations のリトライが無限待ちで潰れるのを防ぐ）。

中間成果物:
  - tmp/ 配下の fixture_*.{mp4,wav}（videoonly / hlg_sdrtag を含む6本）、p*.mp4/png/txt/err、
    fin*.{mp4,png}、lbl*.png（p2.10 / p_final.9 の検証用ラベル・★白）、thumbs/ は全て中間成果物
  - tmp/ は .gitignore 済みで ft2 により削除される（リポジトリに残さない）
  - .claude/skills/video-editing-ffmpeg/ 配下は最終成果物（保持）

判断ログ:
  - スキルを2個に分けず1スキル3ワークフロー構成とした理由は I-7 に記載
  - 実素材（HYROX 大会動画）はリポジトリに入れず、合成フィクスチャで検証する（I-10）
  - 全ての ffmpeg 挙動は 2026-08-12 に実機実測済み（I-1〜I-6 の数値は実測値）

実行順序:
  - p1 → p2 →（p3 ‖ p4 並行可）→ p5 → p_final → final_tasks
  - p3 と p4 は互いに依存しないため並行実行してよい（I-7 補足3）
  - ただし clip_export.sh の所有者は p2 のみ。p3/p4 は呼ぶだけで変更しない
    （--label / --label-pos も p2 で実装・検証済みにする。p3.3 は受入検証のみ）

  ★ p2 への差し戻しが発生した場合の再実行範囲（必須）:
    - p2 側: p2.3 / p2.4 / p2.5 / p2.6 / p2.7 / p2.8 / p2.9 / p2.10 を**全て再実行**する
      （clip_export.sh を1行でも変更したら、同スクリプトに依存する検証は全て無効になる）
    - p3 側: 完了済みでも p3.3（--label 受入）を再実行する
    - p4 側: 完了済みでも p4.2（end-to-end）を再実行する
    - concat_clips.sh を変更した場合は p2.7 / p4.2 を再実行する
    - 再実行前に対象 subtask の status を pending に戻し、チェックボックスを外すこと
      （「p3/p4 は並行実行可能」＝「差し戻し後も完了扱いでよい」ではない）

test_command 設計方針（全 subtask 共通）:
  - 出力ファイルを生成する検証は、必ず先頭で rm -f / rm -rf して前回の残骸を消す
    （max_iterations リトライ中に、壊れたスクリプトが前回の成果物で偽 PASS するのを防ぐ）
  - 生成後は必ず test -f / test -s で存在を確認してから ffprobe にかける
    （ffprobe が無出力だと awk がレコード0件になり、FAIL 文字列すら出力されないため）
  - 判定は必ず PASS または FAIL-* のいずれかを標準出力に出す（無出力を作らない）
  - 節の切り出しは awk のフラグ方式 '/^## X/{f=1;next} f&&/^## /{f=0} f' を使う
    （範囲指定 /^## X/,/^## [^Y]/ は次の見出し名に依存して壊れやすいため）

reviewer 指摘の反映（2026-08-12 FAIL 判定 → 修正済み）:
  - C1: fixture_scenes.mp4 に音声トラックを追加 + clip_export.sh を -map "0:a?" 必須に（I-10 / I-11）
  - C2: ft3 の git add -A を明示パス指定 + 実 commit に変更、ft0 で .gitignore 対策（I-12 / final_tasks）
  - M1: p4.2 をワークフロー1 の実 end-to-end 実行に変更、fixture_silence_av.mp4 を追加
  - M2: 保持区間の区切りを TAB 固定に統一（I-11）+ 検証側 awk -F'[,\t ]+' で保険
  - M3: p2.7 を同一ソース・同一解像度の2クリップ結合に変更 + width/height 一致アサート
  - M4: 全 test_command に出力不在時の FAIL-noout 分岐を追加、p2.5 の握り潰しバグを修正
  - M5: 全 test_command に出力の事前削除（rm -f / rm -rf）を追加
  - M6: p_final.7 を git status --porcelain ベースに変更、除外集合に repository-map.yaml を明記
  - m1〜m7: 実行権限検査の統一 / rollback の rm -rf / p3・p4 並行明示 / description 1行注記 /
           awk 節切り出しの堅牢化 / I-12 の陳腐化解消 / scripts サブディレクトリが初の前例である旨

reviewer 指摘の反映（2回目 / 2026-08-12 FAIL 判定 → 修正済み）:
  - ★総括: 1回目の修正自体が新たな検証の穴を生んでいた（「修正が別の検証を無効化する」パターン）
  - M-1: 1回目の C1 修正（全フィクスチャに音声を追加）で「音声なし入力を通す test_command」が
         全滅し、-map 0:a のままの実装でも全 subtask が PASS する状態になっていた
         → I-10 に5本目 tmp/fixture_videoonly.mp4（音声0本）を追加、p2.8 を新設、
           p2.1 / p_final.0 に「音声0本」アサートを追加（フィクスチャの骨抜き防止）
  - M-2: HLG tonemap に肯定的検証が無かった（tonemap 無し実装でも -x264-params だけで
         3色タグが bt709 になるため p2.3/p2.4/p3.3/p_final.3/p_final.4 が全て PASS していた）
         → p2.9 を新設し --dry-run 出力の逐語検証（tonemap / eq / -map "0:a?"）を追加、
           DW3 と p_final.3 にも同じ文字列検証を組み込んだ
  - M-3: p2.5 の --dry-run 検証が否定形のみで、--dry-run を無視する実装でも PASS していた
         → 'ffmpeg' の肯定アサートと FAIL-dryrun-wrote-file を追加（p2.5 / p2.9 / p2.10）
  - M-4: --label が p3.3 でしか要求されておらず I-7 補足3（p2 が唯一の所有者）と矛盾していた
         → I-7 補足3 に --label/--label-pos も p2 所有と明記、p2.10 を新設（ffmpeg 生成の
           検証用 PNG を使用）、p3.3 を受入検証に限定、未検証だった --label-pos を p2.10 で検証、
           notes.実行順序 に p2 差し戻し時の再実行範囲を規定
  - M-5: ft3 の commit に pathspec が無く index 全体を巻き込む余地があった
         → commit にも同じ pathspec を付与、ft4 を denylist から allowlist 判定に変更
  - m-1: I-12 が現状と不一致（.claude/worktrees/ は .git/info/exclude:11 で除外済み）
         → I-12 を再実測で書き直し、.git/info/exclude はローカル専用なので触らず
           .gitignore に一本化する方針を明記、ft0 の verify を実効的なものに変更
  - m-2: p5.7 が SKILL.md 不在時に無出力 → FAIL-nofile 分岐を追加
  - m-3: p4.2 の duration 判定が緩すぎた（d>0 && d<6.0）→ 3.8〜4.3 に厳格化
  - m-4: p4.2 の rm グロブが zsh で no matches found → 明示ファイル名列挙に変更、
         ft1〜ft3 に verify を追加して ft0 とフォーマットを統一
  - 推奨: p3.4 を pts_time:2 / pts_time:4 の逐語一致に強化（件数だけの偽実装を弾く）

reviewer 指摘の反映（3回目 / 2026-08-12 FAIL 判定 → 2026-08-13 修正済み）:
  - ★総括（reviewer 所感）: 3回とも同じ根っこ。必須挙動を「文字列 grep」か「duration 範囲」で
    守ろうとしていた。symptom ごとに grep を足すので、経路が1つ増える（-vf → filter_complex）たびに
    増えた経路だけ無防備なまま残る。
    → notes 冒頭に「★検証方針の絶対ルール」を新設し、全 subtask に無条件で適用することにした。
      以降、必須挙動を新設・変更するときは必ずこのルールに照らすこと。
  - C-1（Critical）: I-5 のラベル合成レシピ自体に実バグがあり、ラベルが全編で一度も表示されなかった
    （PNG 1フレームに fade を掛け、alpha=0 の唯一のフレームが eof_action=repeat で繰り返される）。
    playbook 上のどの subtask（p2.10 / p3.3 / p_final.4 / DW4）も duration か dry-run 文字列しか
    見ていなかったため、テストが全部緑のまま出荷される状態だった。
    → I-5 / I-11 を `-loop 1 -framerate <入力fps> -i label.png` + `overlay=...:shortest=1` に修正、
      p2.10 / p3.3 / p_final.4 に「ラベルあり出力とラベルなし出力の映像 md5 が異なる」
      ピクセル検証を追加、DW4 にも同条件を明記
  - m-4（C-1 と同根）: p2.10 の検証用ラベルが `color=c=red@0.6` で、対象 fixture_scenes.mp4 の
    先頭2秒が純赤だったため、overlay が正しく効いてもピクセル差がゼロで検証が空振りしていた
    → 白（`color=c=white`）に変更。差分検証は対比の成立する素材で行う（絶対ルールの系）
  - M-1: `--label`（filter_complex）経路の `-map "0:a?"` が完全に未検証だった
    （p2.8 は --label 無しで呼び、p2.10 は overlay 座標しか grep していなかった）
    → p2.10 に (a) 音声なし入力 + --label の実行成功アサート、(b) dry-run への
      `-map "0:a?"` 逐語アサートを追加。I-11 必須挙動4 に「経路が2本あるので検証も2本」と明記
  - M-2: `--dry-run` 文字列と実行コマンドの同一性が、契約にも検証にも無かった。
    そのため p2.9 の逐語 grep は「検証されていない前提」の上に乗るだけの飾りだった
    → (1) p2.4 / p_final.3 に pix_fmt=yuv420p アサートを追加、
      (2) p2.9 / p_final.3 に「dry-run 文字列を eval した出力と実 run 出力の映像 md5 が一致する」
          検証を追加、I-11 に同一性を契約として明記（推奨実装＝1本の文字列を組み立てて
          echo するか eval するか、の分岐にする）
    ★ただし実測で判明した追加事実: pix_fmt アサート単体では
      「format=yuv420p は持つが tonemap は無い」実装を検出できない。
      → I-10 に双子フィクスチャ tmp/fixture_hlg_sdrtag.mp4（同一ピクセル・SDR タグ）を追加し、
        p2.4 / p_final.3 で「HLG 入力の出力と双子入力の出力の映像 md5 が異なる」ことを
        アサートする（tonemap を文字列に一切依存せず検証できる唯一の手段）。
        p2.1 / p2.2 / p_final.0 に双子の前提条件アサート（SDR タグ・pix_fmt 同一・probe=SDR）も追加
  - m-1: p2.8 の validations に書いていた「`-map 0:v` 忘れは p2.6/p2.7/p2.3 が検出する（実測確認済み）」
    が実測と食い違っていた（実際に検出するのは p2.4 と p2.6 のみ。p2.3 は duration=3.000000 で PASS）
    → 実測に合わせて訂正。「実測確認済み」と書いた記述が実測と違うのは
      以降のレビューの前提を壊すため、以後この種の記述は必ず実機で確認してから書く
  - m-2: p2.7 の `[ "$WA" = "$WB" ]` は映像ストリームが無いと空文字同士の比較で真になり空振りしていた
    → `[ -n "$WA" ]` を追加（この修正により p2.7 も `-map 0:v` 忘れを検出できるようになった）
  - m-3: I-5 脚注の `Stream map '0:a' matches no streams` が実測と不一致
    → ffmpeg 8.0.1 の実出力 `Stream map '' matches no streams.` に訂正（I-10 の記述が正しかった）
  - m-5: pathspec 付き commit でも、pathspec 外のステージ済み変更が index に残る
    → ft3 の verify に残留ステージの警告を追加（FAIL ではなく WARN）

reviewer 指摘の反映（4回目 / 2026-08-13 Critical 0・Major 2・Minor 3 → 修正済み）:
  - ★総括（reviewer 所感）: 残った2つの Major は、いずれも絶対ルールを
    「今回指摘された箇所」に適用しただけで、**契約全体には適用し切っていない**ことに起因する。
    → 対策として I-13「契約検証マトリクス」を新設し、I-11 の契約項目を1行ずつ
      「これは生成物で検証されているか？」で機械的に棚卸しした（36項目）。
      以降、I-11 に契約項目を追加・変更したら **必ず I-13 の行も追加・更新する**こと。
      未検証にする場合は I-13 に N として理由つきで明記する（黙って未検証にしない）。
  - Major-1: `--label-pos` が「同一性未検証の文字列 grep」だけで守られていた。
    eval 同一性を持つのは p2.9 / p_final.3（どちらも `--label` を渡さない `-vf` 経路）だけで、
    `overlay=x=10:y=20` の grep は土台の無い経路の上に乗っていた。
    実測: dry-run は要求どおりの座標を出し実行時だけ既定位置に差し替える実装で
    p2.10 / p3.3 / p_final.4 / p2.9 / p_final.3 が**全て PASS**した。
    → p2.10 に (3) 座標2種（10:20 / 300:300）の映像 md5 差分と
      (7) `--label` 経路の eval 同一性検証を追加。I-11 に
      「同一性検証は経路（-vf / filter_complex）ごとに個別に必要」と明記。
      p_final.9 を新設して最終成果物でも再確認する
  - Major-2: `-r` のアスペクト維持に検証が1つも無かった。
    実測: `scale=${W}:${H}` だけ（pad 無し・歪み）の実装で旧 p2.6 が PASS した。
    → p2.6 / p_final.9 に cropdetect ベースの3点アサート
      （比一致 / 出力辺への接触 / レターボックス存在）を追加。
      実測: 正 → crop=1080:810:0:554 / 歪み → crop=1080:1920:0:0（FAIL-stretched） /
      拡大なし → crop=640:480:220:720（FAIL-notfitted）
  - Minor-1: p4.4 が純粋なソース grep で、コメント行1本でも PASS していた（実測。rc=0 で契約違反）
    → `env PATH=/usr/bin:/bin` 実行で非ゼロ終了 + stderr の案内を実測する挙動検証に変更
  - Minor-2: `--label` の fade-in が md5 差分だけでは未検証だった（fade を外しても差分は出る）
    → p2.10 / p_final.9 にラベル矩形内の画素を t=0.05 / t=1.5 で比較するアサートを追加
      （実測: fade あり → G 値 75 vs 255 / fade なし → 255 vs 255 で FAIL-nofade）
  - Minor-3: `--thumbs`（p3.5）が枚数しか見ておらず検出時刻と無関係でも通っていた
    → 生成画像の代表色で「青（t=2）と緑（t=4）が両方ある」ことを要求（実測確認済み）。
      p2.7 の「concat リストが残骸を残さない」は**検証しない**と決め、
      validations の主張を撤回して I-13 #23 に N として記録した
  - ★棚卸しで追加発見し、併せて修正した項目（reviewer 指摘外）:
    - 必須挙動3「**常に** -x264-params」が HLG 経路でしか検証されていなかった → p2.5 に SDR 経路の3タグ実測を追加
    - p3.2（フォント fallback）が「空の全透明 PNG を書く実装」を通していた → alpha 実測を追加
    - p3.4 の `-t` / p4.1 の `-d` が「引数を無視する実装」を通していた → 配線を実測するアサートを追加
    - p4.1 が I-11 の「TAB 区切り・小数3桁固定」を検証していなかった（カンマ区切りも通していた）→ 厳格パターンに変更
    - `overlay` の `shortest=1` 欠落は FAIL ではなく**ハング**する（実測: 20秒で終わらない）
      → p2.10 / p_final.9 の最初の `--label` 実行を `perl -e 'alarm shift; exec @ARGV' 60` でラップ

未着手の別タスク（本 playbook のスコープ外）:
  - plan/playbook-setup-instagram-skills.md（未追跡ファイル。別途 pm 経由で処理）
  - ★ ft3 の明示パス指定により、このファイルは絶対にコミットされない（ft4 で検証）
```
