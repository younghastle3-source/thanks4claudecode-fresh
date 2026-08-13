#!/usr/bin/env python3
"""make_label_png.py --text <文字列> --out <出力png> [--font <ttf/ttc>] [--size <px>] [--width <px>]

Pillow で日本語テロップ/ラベル用の透過 PNG を生成する。
このマシンの ffmpeg には drawtext / subtitles フィルタが無いため
（references/ffmpeg-pitfalls.md 落とし穴1）、テロップは事前に PNG として焼き、
ffmpeg の overlay フィルタで合成する。
"""
import argparse
import sys

from PIL import Image, ImageDraw, ImageFont

# I-1 で実在確認済みの日本語フォント候補（この順で試す）
FONT_CANDIDATES = [
    "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial Unicode.ttf",
]


def load_font(path, size):
    candidates = ([path] if path else []) + FONT_CANDIDATES
    for candidate in candidates:
        if not candidate:
            continue
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    # フォールバック（実運用では I-1 の候補が存在するため通常ここには来ない）
    return ImageFont.load_default()


def draw_label(draw, xy, text, font, stroke_width):
    try:
        draw.text(
            xy,
            text,
            font=font,
            fill=(255, 255, 255, 255),
            stroke_width=stroke_width,
            stroke_fill=(0, 0, 0, 255),
        )
    except TypeError:
        # ビットマップフォールバックフォントは stroke_width 非対応な場合がある
        draw.text(xy, text, font=font, fill=(255, 255, 255, 255))


def measure(draw, text, font, stroke_width):
    try:
        return draw.textbbox((0, 0), text, font=font, stroke_width=stroke_width)
    except TypeError:
        return draw.textbbox((0, 0), text, font=font)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--text", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--font", default=None)
    ap.add_argument("--size", type=int, default=64)
    ap.add_argument("--width", type=int, default=None)
    args = ap.parse_args()

    font = load_font(args.font, args.size)
    stroke_width = 4

    probe = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    probe_draw = ImageDraw.Draw(probe)
    bbox = measure(probe_draw, args.text, font, stroke_width)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    pad = 20
    width = args.width if args.width else max(text_w + pad * 2, 1)
    height = max(text_h + pad * 2, 1)

    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    x = (width - text_w) // 2 - bbox[0]
    y = (height - text_h) // 2 - bbox[1]
    draw_label(draw, (x, y), args.text, font, stroke_width)

    img.save(args.out)


if __name__ == "__main__":
    sys.exit(main())
