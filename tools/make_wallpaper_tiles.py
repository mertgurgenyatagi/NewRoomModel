"""Turns the raw wallpaper photos in wallpaper_textures/ into seamless tiles for Godot (room-godot/assets/wallpaper_*.jpg).

The source images are not seamless, so each one is cropped to one repeat plus an overlap strip, and the strip is cross-faded
into the start of the tile on both axes; wrapping the result then shows no hard seam. Run:  python tools/make_wallpaper_tiles.py
Prints the tile aspect (height / width) to put in WALLPAPERS in room-godot/main.gd.
"""
from PIL import Image
import numpy as np

SRC, OUT = "wallpaper_textures/", "room-godot/assets/"
# name: (crop x, crop y, tile width px, tile height px, overlap px, output width px)
# a and b are non-repeating art, so the whole image is used and blended. c repeats every ~1565 x 3760 px, so one repeat is cut.
JOBS = {
    "a": (0, 0, 4500, 3000, 400, 2048),
    "b": (0, 0, 4500, 3000, 400, 2048),
    "c": (0, 0, 1565, 3760, 140, 1024),
}


def blend_axis(t, ov, axis):
    """t has size W = tile + ov on this axis. Returns the tile, whose first ov rows are taken from the start strip on one side of a
    minimum-error seam and from the trailing strip on the other, so the cut follows the pattern instead of fading across it."""
    if axis == 1:
        return blend_axis(t.transpose(1, 0, 2), ov, 0).transpose(1, 0, 2)
    n = t.shape[0] - ov
    a, b = t[:ov], t[n:n + ov]                       # start strip, trailing strip (the same place, one repeat on)
    cost = ((a - b) ** 2).sum(axis=2)                # ov x width
    cost = np.asarray(cost, dtype=np.float64)
    w = cost.shape[1]
    acc = cost.copy()
    for x in range(1, w):
        prev = acc[:, x - 1]
        best = np.minimum(prev, np.minimum(np.r_[prev[1:], np.inf], np.r_[np.inf, prev[:-1]]))
        acc[:, x] += best
    cut = np.zeros(w, dtype=np.int64)
    cut[-1] = int(np.argmin(acc[:, -1]))
    for x in range(w - 2, -1, -1):
        r = cut[x + 1]
        lo, hi = max(0, r - 1), min(ov, r + 2)
        cut[x] = lo + int(np.argmin(acc[lo:hi, x]))
    rows = np.arange(ov)[:, None]
    f = np.clip((rows - cut[None, :]) / 6.0 + 0.5, 0, 1)[:, :, None]   # 0 above the cut (trailing strip), 1 below (start strip)
    out = t[:n].copy()
    out[:ov] = f * a + (1 - f) * b
    return out


for name, (x0, y0, tw, th, ov, ow) in JOBS.items():
    im = np.asarray(Image.open(f"{SRC}{name}.jpg").convert("RGB"), dtype=np.float32)
    crop = im[y0:y0 + th + ov, x0:x0 + tw + ov]
    tile = blend_axis(blend_axis(crop, ov, 0), ov, 1)
    img = Image.fromarray(np.clip(tile, 0, 255).astype(np.uint8))
    oh = round(ow * img.height / img.width)
    img = img.resize((ow, oh), Image.LANCZOS)
    img.save(f"{OUT}wallpaper_{name}.jpg", quality=90)
    print(name, img.size, "aspect", round(img.height / img.width, 4))
