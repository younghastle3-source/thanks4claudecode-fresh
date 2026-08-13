# ffmpeg-pitfalls.md

このマシンの ffmpeg（8.0.1 / Homebrew）で実地検証済みの落とし穴3件。
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
