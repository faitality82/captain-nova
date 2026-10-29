"""Turn a high-res Imagen render into a 1x pixel-art sprite for SpaceTrader.

Pipeline: optional background-key (Imagen backgrounds are near-black, not
#000; only dark pixels connected to the image border are keyed, so dark
interior details like charred bun or black eyes survive) -> optional crop to
opaque bbox -> NEAREST downscale to --height -> palette quantize (no dither)
-> reapply alpha -> save RGBA PNG.

Usage:
  python tools/pixelize.py IN.png OUT.png --height 144 [--colors 32] [--no-key] [--no-crop]
"""
import argparse
from collections import deque

import numpy as np
from PIL import Image

KEY_THRESHOLD = 28  # max(R,G,B) below this counts as background


def key_background(img: Image.Image, threshold: int = KEY_THRESHOLD) -> Image.Image:
    """Key out dark pixels connected to the image border via 4-connected BFS.

    Dark pixels that are NOT reachable from the border (e.g. charred bun,
    black eyes inside the subject) are left opaque.
    """
    img = img.convert("RGBA")
    arr = np.array(img)
    dark = arr[:, :, :3].max(axis=2) < threshold
    h, w = dark.shape

    reachable = np.zeros_like(dark)
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if dark[y, x] and not reachable[y, x]:
                reachable[y, x] = True
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if dark[y, x] and not reachable[y, x]:
                reachable[y, x] = True
                q.append((x, y))

    while q:
        x, y = q.popleft()
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and dark[ny, nx] and not reachable[ny, nx]:
                reachable[ny, nx] = True
                q.append((nx, ny))

    arr[reachable] = (0, 0, 0, 0)
    return Image.fromarray(arr, mode="RGBA")


def pixelize(src: str, dst: str, height: int, colors: int = 32,
             key_black: bool = True, crop: bool = True) -> None:
    img = Image.open(src).convert("RGBA")
    if key_black:
        img = key_background(img)
    if crop:
        bbox = img.getchannel("A").getbbox()
        if bbox:
            img = img.crop(bbox)
    w, h = img.size
    scale = height / float(h)
    new_size = (max(1, round(w * scale)), height)
    img = img.resize(new_size, Image.Resampling.NEAREST)
    alpha = img.getchannel("A")
    rgb = img.convert("RGB").quantize(colors=colors, dither=Image.Dither.NONE).convert("RGB")
    out = rgb.convert("RGBA")
    out.putalpha(alpha)
    out.save(dst)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("src")
    p.add_argument("dst")
    p.add_argument("--height", type=int, required=True, help="output height in logical pixels")
    p.add_argument("--colors", type=int, default=32)
    p.add_argument("--no-key", action="store_true", help="keep the background (for plates)")
    p.add_argument("--no-crop", action="store_true")
    a = p.parse_args()
    if a.height < 1:
        p.error("--height must be >= 1")
    pixelize(a.src, a.dst, a.height, a.colors, key_black=not a.no_key, crop=not a.no_crop)
    print(f"wrote {a.dst}")


if __name__ == "__main__":
    main()
