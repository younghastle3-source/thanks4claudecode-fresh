# ffmpeg-pitfalls.md

このマシンの ffmpeg（8.0.1 / Homebrew）で実地検証済みの落とし穴8件。
全ワークフロー共通の中核知識であり、`video-editing-ffmpeg` スキルを使う前に必ず目を通すこと。

## 落とし穴1 — drawtext / subtitles が使えない

このマシンの ffmpeg には `libfreetype` / `libass` が入っておらず、`drawtext` フィルタも
`subtitles` フィルタも存在しない（`ffmpeg -hide_banner -filters | grep -cw drawtext` => 0）。

検証コマンド:

```
ffmpeg -hide_banner -filters | grep -cw drawtext  # => 0
```

回避策: Python（Pillow）でテロップ/ラベルを「透過PNG」として事前生成し、
ffmpeg の `overlay` フィルタで合成する。`scripts/make_label_png.py` がこれを行う。

## 落とし穴2 — `-t` の配置ミスで全編エンコードされる

`-ss S -i input.mp4 -t D -i label.png` のように書くと、`-t D` は `input.mp4` ではなく
2番目の入力 `label.png` の入力オプションとして解釈される。結果として動画側の長さ制限が
一切効かず、全編が再エンコードされてしまう。

実測（6秒素材を `-ss 1` で切り出した場合）:

- NG（`-t` を2番目の `-i` の前に置く）: `duration = 5.013991`
- OK（`-t` を対象の `-i` の直前に置く）: `duration = 3.000000`

NG例:

```
ffmpeg -ss 1 -i input.mp4 -t 3 -i label.png ...
```

OK例:

```
ffmpeg -ss 1 -t 3 -i input.mp4 -loop 1 -framerate 30 -i label.png ...
```

回避策: `-t` は必ず対象の `-i` の直前に置く。`-loop 1` / `-framerate` は
`label.png` 側の入力オプションであり、これらを足しても「`-t` が対象の `-i` の直前にある」
という構造は変わらない。

## 落とし穴3 — HDR(HLG) 素材が SDR 変換後に真っ暗になる

iPhone 等で撮影した HLG（`arib-std-b67`）/ BT.2020 タグ付き 10bit 素材を、
`-pix_fmt yuv420p` で 8bit 化しただけだと、コンテナの色タグ（`bt2020nc` / `arib-std-b67`）が
そのまま残り、プレイヤーが HDR として解釈してしまい画面が真っ暗になる。

このビルドには `zscale` フィルタが無いため、代わりに `tonemap` フィルタでトーンマップする。

回避策:

1. `tonemap=mobius:param=0.5` でトーンマップする（`tonemap` の入力は浮動小数へ変換する必要が
   あるため `format=gbrpf32le` を前段に置く）
2. `eq=gamma=1.15:brightness=0.03` で明るさを補正する
3. 出力時に `-x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709"` で
   libx264 の VUI タグを bt709 に上書きする（コンテナレベルの `-color_primaries` /
   `-color_trc` / `-colorspace` だけでは libx264 の VUI に反映されず不十分）

検証済み実コマンド（このまま動作する）:

```
ffmpeg -y -ss 1 -t 3 -i in.mp4 \
  -vf "format=gbrpf32le,tonemap=mobius:param=0.5,eq=gamma=1.15:brightness=0.03,format=yuv420p" \
  -c:v libx264 -preset veryfast -crf 20 \
  -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709" \
  -c:a aac -movflags +faststart out.mp4
```

検証結果: `pix_fmt=yuv420p` / `color_space=bt709` / `color_transfer=bt709` /
`color_primaries=bt709` / `duration=3.000000`

## 落とし穴4 — `concat_clips.sh`（`-c copy`）結合後、一部プレイヤーで再生が途中で止まる

`concat_clips.sh` は concat demuxer + `-c copy` で結合するため、各クリップの音声ストリームの
フレーム境界がクリップの切れ目と厳密には一致せず、結合時に決まって
`Non-monotonic DTS; previous: X, current: Y, changing to X+1` という警告が出る。
`ffmpeg -i out.mp4 -f null -` では警告のみでエラーにならず一見問題なく見えるが、
QuickTime / iOS 標準プレイヤー等 DTS の単調増加に厳密なプレイヤーでは、この警告が出た
境目（クリップの継ぎ目）で再生が固まる／止まることがある（実機で確認済み）。

回避策: `concat_clips.sh` で結合した後、必ず全体を再エンコードする（`-c copy` を使わない）。

```
ffmpeg -y -i concat_out.mp4 \
  -c:v libx264 -preset veryfast -crf 20 \
  -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709" \
  -c:a aac -ar 48000 -movflags +faststart \
  final.mp4
```

再エンコード後は `ffmpeg -i final.mp4 -f null - 2>&1 | grep -i "non.monoton"` で
警告が消えていることを確認してから納品する。

画質重視の場合は「`concat_clips.sh` で `-c copy` 結合 → 別途フル再エンコード」だと二重圧縮になるため、
最初から concat demuxer に直接 `-c:v libx264 ...`（`-c copy` を使わない）を渡して一発でエンコードする方が良い
（`concat_clips.sh` は使わず、同じ concat demuxer の呼び出しを自前で書く）。

## 落とし穴5 — SAR(サンプルアスペクト比)付き素材で `force_original_aspect_ratio` が黒帯／小さく写る

一部のアクションカメラ・サブカメラ書き出し（実例: 720x480, `sample_aspect_ratio=3:8`,
`display_aspect_ratio=9:16`）は、90°回転の Display Matrix ではなく非正方形ピクセル（SAR）で
縦動画を表現している。この場合 ffmpeg のデコーダは自動回転をせず、フィルタグラフ上の `iw`/`ih` は
生のピクセル値（例: 720x480、実質 3:2 の横長）のままになる。

`scale=1080:1920:force_original_aspect_ratio=decrease`（または `increase`）は `iw`/`ih` の比率のみで
計算され、SAR を考慮しないため、実際は 9:16 の縦動画なのに 3:2 の横長として扱われてしまい、
上下に大きな黒帯が入る（`increase` 指定時は逆に不要に大きくクロップされる）。回転済みの4K素材
（Display Matrix で自動回転される）ではこの問題は起きない — 発生するのは非正方形 SAR 素材のみ。

見分け方:

```
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,sample_aspect_ratio,display_aspect_ratio \
  input.mp4
# sample_aspect_ratio が 1:1 以外 かつ side_data に Display Matrix が無ければ該当
```

回避策: `scale`/`pad`/`crop` の前に `scale=iw*sar:ih,setsar=1` を挟み、SAR をピクセル寸法に
焼き込んで正方形ピクセル化してから通常のアスペクト比処理を行う。

```
ffmpeg -y -i in.mp4 -vf \
  "scale=iw*sar:ih,setsar=1,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" \
  -c:v libx264 -preset veryfast -crf 20 out.mp4
```

## 落とし穴6 — concat する各クリップの音声サンプルレートが揃っていないと、結合後の尺が水増しされる

各クリップを個別に `ffmpeg -c:a aac` で書き出す際、`-ar`（サンプルレート）を明示しないと
入力ソースのネイティブレート（例: 44100Hz）をそのまま引き継ぐ。素材によってソースのサンプル
レートが異なる（例: あるクリップは44100Hz、別のクリップは48000Hz）と、`concat` demuxer +
再エンコードで結合したときに **結合前は各クリップとも正しい尺なのに、結合後の合計尺だけ数秒
水増しされる**（フリーズや警告は出ない。動画の一部が実際より長く伸びる/間延びする形で症状が出る）。

見分け方: 結合後の尺を `ffprobe -show_entries format=duration` で見て、素材ごとの尺の単純合計と
比べる。合わない場合は各クリップの音声サンプルレートを比較する。

```
ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=nw=1:nk=1 clip.mp4
```

回避策: 個別クリップを書き出す全ての `ffmpeg -c:a aac` に `-ar 48000` を明示し、concat する
全クリップのサンプルレートを統一してから結合する。

## 落とし穴7 — concat する各クリップの映像フレームレートが揃っていないと、音声とズレたまま尺だけ合う

落とし穴6の音声版とは別に、**映像側のフレームレート**も揃っていないと壊れる。実例: HLG素材（4K, 60000/1001）から作ったクリップに `fps=30000/1001` を指定した一方、別の SDR 素材（30fps）から作ったクリップには `fps=30` を指定してしまい、両者が混在した状態で concat した。

症状が特に紛らわしい: 結合後の**コンテナ全体の尺（`format=duration`）は音声ストリームの長さで正しく見える**が、実際には**映像ストリームだけ大幅に短く終わっており**（例: 音声55.7秒に対し映像は28.5秒しかない）、後半のクリップの映像が正しい表示時間より大幅に圧縮されて早送りのように詰め込まれる。`format=duration` だけを見て「尺が合っているから正常」と判断すると見逃す。

見分け方:

```
ffprobe -v error -select_streams v:0 -show_entries stream=duration,r_frame_rate,avg_frame_rate -of default=nw=1 out.mp4
ffprobe -v error -select_streams a:0 -show_entries stream=duration -of default=nw=1 out.mp4
# 映像と音声の duration が大きく食い違っていたら要注意。r_frame_rate が全クリップで揃っているかも確認する
```

回避策: このリポジトリの動画編集では **`30000/1001` に統一する**（`fps=30` ではなく必ず `fps=30000/1001`）。
静止画から作るカード（`color=c=black:...`）や `-loop 1` のラベル入力の `-framerate` も含め、
concat する全クリップの `fps`/`-framerate` 指定を一箇所も漏らさず `30000/1001` に揃える。

## 落とし穴8 — SAR付き素材をcropしても、`setsar=1`を忘れると出力ファイル全体が歪んで表示される

落とし穴5（SAR付き素材の黒帯・誤クロップ）と混同しやすいが別の症状。`scale=iw*sar:ih,setsar=1,scale=W:H:force_original_aspect_ratio=increase,crop=W:H` のように**入力側**のSAR補正だけを入れて、**出力直前**に改めて`setsar=1`を明示しないと、pixelの縦横比計算自体は正しくても、書き出したファイルのコンテナに元素材のSAR（例: `3:8`）がそのまま残ることがある。

実例: `sample_aspect_ratio=3:8`付きの720x480素材をcrop後、1080x1920に正しくフィットさせたつもりが、`ffprobe`で最終出力を見ると`sample_aspect_ratio=3:8`のまま、`display_aspect_ratio=27:128`という壊れた値になっていた。これをiOSの標準プレイヤー等SAR/DARを厳密に解釈するプレイヤーで再生すると、**中身の映像は歪んでいないのに、再生画面自体が画面幅の一部だけを使う細長い帯（左右に黒帯）に圧縮されて表示される**。ユーザー側は「映像が歪んで伸び縮みしている」と報告してくるが、フレームを静止画として書き出す（`ffmpeg -ss ... -frames:v 1 out.jpg`）と一見正常に見えるため気づきにくい（静止画書き出しツールの多くはSARを無視するため）。

`concat`で複数クリップを結合する場合はさらに厄介: 1本でもSARが1:1でないクリップが混ざっていると、結合後の**ファイル全体**のSARがそれを引き継いでしまうことがある（他のクリップは正しくSAR 1:1でも無関係に上書きされうる）。

見分け方:

```
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,sample_aspect_ratio,display_aspect_ratio \
  final_output.mp4
# sample_aspect_ratio が 1:1 以外なら、SARが正しくリセットされていない
```

回避策: SAR補正が絡む全てのクリップで、**crop直後にもう一度`setsar=1`を明示**する（`scale=iw*sar:ih,setsar=1,...,crop=W:H,setsar=1`）。さらに`concat`後の最終出力にも念のため`-vf "setsar=1"`を通して、コンテナのSARを確実に1:1へ固定してから納品する。
