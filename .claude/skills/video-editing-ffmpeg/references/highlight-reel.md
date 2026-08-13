# highlight-reel.md

長尺素材からハイライト Reel（テロップ/ラベル付き）を作る手順。
HDR(HLG) 素材の場合は `ffmpeg-pitfalls.md` の落とし穴3（tonemap + bt709 強制）を
必ず適用すること。テロップは `drawtext` が使えないため `make_label_png.py` で
PNG として事前生成し overlay 合成する（`ffmpeg-pitfalls.md` 落とし穴1）。

## 手順

1. `scripts/scene_scan.sh -i <input> -t 0.3 --thumbs tmp/thumbs` でシーン変化の
   候補時刻（`pts_time:<秒>`）を検出し、同時に `tmp/thumbs/` にサムネイルを書き出す。
2. `tmp/thumbs/` のサムネイルを目視で確認し、採用する区間（開始秒・長さ）を選定する。
3. `scripts/make_label_png.py --text "<テロップ文言>" --out tmp/label.png` で
   透過ラベル PNG を生成する（日本語対応・alpha 付き）。
4. `scripts/probe_color.sh -i <input>` 相当の判定（`clip_export.sh` 内部で自動実行される）で
   HLG かどうかを確認する。HLG であれば `clip_export.sh` が自動的に
   `tonemap=mobius:param=0.5` + `eq=gamma=1.15:brightness=0.03` + bt709 強制を適用する。
5. 選定した区間ごとに `scripts/clip_export.sh -i <input> -s <開始> -d <長さ> --label tmp/label.png --label-pos <x:y> -o <clipN.mp4>` を呼び出し、ラベル付きクリップを書き出す。
6. `scripts/concat_clips.sh -o <output.mp4> <clip1.mp4> <clip2.mp4> ...` で複数クリップを
   結合する。
7. 出力を再生確認し、ラベルが正しい位置・タイミングで表示されているかを目視で確認する。

補足: `clip_export.sh` の `--label` は PNG を `-loop 1 -framerate <入力fps>` で
静止画ループ入力として読み込み、`overlay` に `shortest=1` を付けて動画側の終端で
終わらせる。この指定が無いとハングする（`ffmpeg-pitfalls.md` 参照）。
