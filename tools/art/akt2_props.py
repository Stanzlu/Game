"""Props for Act II (docs/akt2/REGIONSBRIEFE.md), drawn like make_sprites.py and registered in the same
catalog (style "tal", so they share the atlas of the valley). Called from make_sprites.build();
`--preview out.png` draws them on one sheet (4x) to look at.

Bachlauf (B3): everything a stream leaves behind. Nothing here is a symbol; every piece has the shape
of what it was used for, and the one thing without a reason (hoof prints on a narrow beam) is a goat's.
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp

IRON = ramp("#1a1a1e", "#2a2b30", "#3e4047", "#565a62", "#7a7f88")
GLASS_BLUE = ramp("#17304a", "#2a5a8c", "#3f7fc0", "#8cc4ee", "#e6f5ff")
LEAD = ramp("#23262c", "#4a4f58", "#7a808a", "#b3b8c0")
CORK_RED = ramp("#6e1c14", "#a8322a", "#d4584a", "#f08a74")
CORK_WHITE = ramp("#8c887c", "#bcb8aa", "#e6e2d4", "#fbf8ee")
WILLOW = ramp("#3a2c16", "#5c4624", "#86683a", "#b08c52", "#d4b676")
MOSS_DARK = ramp("#16261a", "#22382a", "#33503a", "#4a6c46")


def post(ms):
    """A post at the bank, an iron hook high on it and a pale stripe in the wood below, long and
    round, where something hung for a long time. The hook is empty."""
    rng = np.random.default_rng(201)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(20, 38)
    grain = pa.value_noise(38, 20, (1, 5), rng)
    shaft = c.rect(5, 4, 11, 37)
    c.paint(shaft, ex["plank"], np.where(c.xx < 8, 0.58, 0.28) + 0.12 * (grain - 0.5), contrast=2.0, dither=False)
    # the weathered top, a little lighter on the left
    c.paint(c.rect(5, 3, 11, 5), ex["plank"], np.where(c.xx < 8, 0.82, 0.5), dither=False)
    # the pale stripe: wood that was never in the weather
    stripe = c.rect(6, 16, 10, 31)
    c.paint(stripe, ex["plank"], np.where(c.xx < 8, 1.0, 0.86) - 0.08 * grain, contrast=1.4, dither=False)
    # the hook: an iron arm out to the right and a curl up
    c.fill(c.rect(11, 9, 16, 11), IRON[2])
    c.fill(c.rect(11, 9, 16, 10), IRON[3])
    c.fill(c.rect(15, 5, 17, 11), IRON[2])
    c.fill(c.rect(15, 5, 16, 9), IRON[3])
    c.fill(c.rect(14, 5, 15, 6), IRON[2])
    lichen = shaft & (pa.value_noise(38, 20, 1.5, rng) > 0.84) & ~stripe
    c.fill(lichen, np.array([130, 140, 100], np.float32))
    c.outline(st["outline"])
    return c


def float_in_reeds(ms):
    """A cork float, red and white, the paint peeling, lying in the reeds with its tip pointing downstream
    (towards the bottom of the picture)."""
    rng = np.random.default_rng(202)
    st = pa.STYLES["tal"]
    c = ms.Canvas(22, 28)
    for k, ox in enumerate((0, 12)):
        c.blit(ms.reeds(590 + k, "tal"), ox, 2)
    # the float lies on the bank mud between the clumps, long axis along the stream
    cx, cy = 11, 21.5
    body = c.ellipse(cx, cy, 3.4, 5.4)
    light = c.sphere(cx - 1.2, cy - 2.4, 4.0, 6.2)
    upper = body & (c.yy < cy)
    lower = body & (c.yy >= cy)
    c.paint(upper, CORK_RED, 0.3 + 0.65 * light, dither=False, contrast=2.0)
    c.paint(lower, CORK_WHITE, 0.3 + 0.65 * light, dither=False, contrast=2.0)
    # peeling: a few bare cork patches
    bare = body & (pa.value_noise(28, 22, 1.4, rng) > 0.8)
    c.fill(bare, np.array([176, 140, 92], np.float32))
    # the little tip and the eye for the line
    c.fill(c.rect(10, 27, 12, 28), CORK_WHITE[1])
    c.fill(c.rect(10, 15, 12, 16), IRON[2])
    c.outline(st["outline"])
    return c


def _trap_body(ms, h, w, tilt):
    """A fish trap of willow, long as an arm: a wide mouth with a ring at the bottom, narrowing to a
    closed end at the top. `tilt` shears it (wedged crosswise to the stream)."""
    rng = np.random.default_rng(203)
    st = pa.STYLES["tal"]
    c = ms.Canvas(w + 12, h)
    cx = (w + 12) / 2.0
    for y in range(h):
        t = y / (h - 1.0)  # 0 closed end, 1 mouth
        half = 2.0 + 3.6 * t ** 1.3
        shift = tilt * (y - h / 2.0)
        x0, x1 = int(round(cx + shift - half)), int(round(cx + shift + half))
        weave = ((y // 2 + np.arange(x0, x1)) % 2).astype(float)
        for i, x in enumerate(range(x0, x1)):
            edge = (x - x0) / max(x1 - x0 - 1, 1)
            v = 0.3 + 0.55 * (1 - abs(edge * 2 - 1)) * 0.7 + 0.2 * weave[i] + 0.12 * (rng.random() - 0.5)
            c.paint(c.rect(x, y, x + 1, y + 1), WILLOW, min(v, 1.0), dither=False, contrast=1.6)
    # hoops: rings around the body
    for y in range(4, h - 2, 7):
        t = y / (h - 1.0)
        half = 2.0 + 3.6 * t ** 1.3
        shift = tilt * (y - h / 2.0)
        x0, x1 = int(round(cx + shift - half)), int(round(cx + shift + half))
        c.paint(c.rect(x0, y, x1, y + 1), WILLOW, 0.12, dither=False)
    # the mouth: a ring, dark inside
    half = 2.0 + 3.6
    shift = tilt * (h - 1 - h / 2.0)
    x0, x1 = int(round(cx + shift - half)), int(round(cx + shift + half))
    c.paint(c.rect(x0 + 1, h - 3, x1 - 1, h - 1), WILLOW, 0.05, dither=False)
    c.paint(c.rect(x0, h - 1, x1, h), WILLOW, 0.7, dither=False)
    c.outline(st["outline"])
    return c


def trap_stuck(ms):
    """The trap wedged crosswise behind the weir, half under water: a dark wet band at the foot, ripples."""
    c = _trap_body(ms, 30, 8, 0.28)
    st = pa.STYLES["tal"]
    wet = c.a & (c.yy >= 20)
    c.paint(wet, st["water"], 0.32, dither=False)
    for y, x0 in ((19, 3), (22, 14), (26, 2)):
        c.paint(c.rect(x0, y, x0 + 4, y + 1), st["water"], 0.8, dither=False)
    return c


def trap_free(ms):
    """The same trap lying free in the stream, mouth downstream, a comb gone from its belly."""
    c = _trap_body(ms, 30, 8, 0.0)
    st = pa.STYLES["tal"]
    wet = c.a & (c.yy >= 24)
    c.paint(wet, st["water"], 0.4, dither=False)
    for y, x0 in ((22, 2), (26, 15)):
        c.paint(c.rect(x0, y, x0 + 3, y + 1), st["water"], 0.8, dither=False)
    return c


def weir(ms):
    """A low weir across the stream: a timber beam on two posts, green with moss. Four pairs of hoof
    prints in the moss go all the way along the beam, one behind the other. Three cells wide (48 px)
    plus a post on each bank."""
    rng = np.random.default_rng(204)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(80, 26)
    grain = pa.value_noise(26, 80, (1, 6), rng)
    beam = c.rect(4, 9, 76, 15)
    c.paint(beam, ex["plank"], 0.5 + 0.25 * (c.yy < 11) - 0.2 * (c.yy >= 13) + 0.12 * (grain - 0.5),
            contrast=2.0, dither=False)
    # posts at both ends, no taller than the beam is wide: the sprite lies flat and the bank is walkable
    for x0 in (2, 72):
        c.paint(c.rect(x0, 8, x0 + 6, 17), ex["plank"], np.where(c.xx < x0 + 3, 0.6, 0.3), dither=False)
        c.paint(c.rect(x0, 8, x0 + 6, 10), ex["plank"], 0.8, dither=False)
    # moss on the top of the beam
    moss = c.rect(8, 9, 72, 12) & (pa.value_noise(26, 80, 3, rng) > 0.35)
    c.paint(moss, MOSS_DARK, 0.45 + 0.4 * pa.value_noise(26, 80, 2, rng), dither=False)
    # hoof prints: two dark dots, one behind the other, in a row along the beam
    for x in range(14, 68, 12):
        for dx in (0, 3):
            c.fill(c.rect(x + dx, 10, x + dx + 1, 12), np.array([34, 44, 30], np.float32))
    # the water below the beam: a dark wet band and a white edge where it falls
    wet = c.rect(6, 15, 74, 20)
    c.paint(wet, st["water"], 0.3 + 0.35 * pa.value_noise(26, 80, (1, 5), rng), dither=False)
    for x in range(8, 72, 7):
        c.fill(c.rect(x, 16, x + 3, 17), np.array([196, 220, 218], np.float32))
    c.outline(st["outline"])
    return c


def stumps(ms):
    """Two tree stumps at the bank, sat smooth, and a board across them. On the board two rings, where
    cups have stood. Both stumps face the water."""
    rng = np.random.default_rng(205)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(40, 30)
    for cx in (9, 31):
        side = c.rect(cx - 6, 14, cx + 6, 28) | c.ellipse(cx, 27, 6.4, 2.4)
        c.paint(side, ex["bark"], 0.25 + 0.5 * c.cylinder(cx - 6, cx + 6), contrast=2.2)
        top = c.ellipse(cx, 14, 6.4, 2.8)
        c.paint(top, ex["plank"], 0.7 + 0.2 * c.sphere(cx - 1, 13, 6, 2.6), dither=False)
        c.fill(c.ellipse(cx, 14, 3.5, 1.4) & (rng.random((30, 40)) > 0.5), ex["plank"][3])
    board = c.rect(2, 9, 38, 14)
    grain = pa.value_noise(30, 40, (1, 6), rng)
    c.paint(board, ex["plank"], 0.55 + 0.3 * (c.yy < 11) + 0.12 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(c.rect(2, 13, 38, 14), ex["plank"], 0.2, dither=False)
    # the two rings where a cup has stood: a pale circle and a dark rim, one on each side of the middle
    for rx in (13, 27):
        ring = c.ellipse(rx, 10.5, 2.6, 1.3) & ~c.ellipse(rx, 10.5, 1.4, 0.6)
        c.fill(ring & board, ex["plank"][4])
    c.outline(st["outline"])
    return c


def glass_in_shallows(ms):
    """A piece of blue glass in the shallows, rounded by the stream, wet and bluer for it."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(14, 9)
    c.paint(c.ellipse(7, 5.5, 6, 2.6), st["water"], 0.35, dither=False)
    g = c.ellipse(7, 4.5, 3.4, 2.2)
    c.paint(g, GLASS_BLUE, 0.3 + 0.7 * c.sphere(6, 3.5, 3.8, 2.6), dither=False)
    c.fill(c.rect(5, 3, 7, 4) & g, GLASS_BLUE[4])
    c.outline(st["outline"])
    return c


def lead_weight(ms):
    """A fishing weight in the grass at the foot of the post: lead, a notch for the line."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(12, 11)
    body = c.ellipse(6, 6.5, 3.6, 3.4)
    c.paint(body, LEAD, 0.25 + 0.75 * c.sphere(5, 5, 4.2, 4), dither=False)
    c.fill(c.rect(5, 1, 7, 4), LEAD[1])
    c.fill(c.rect(5, 2, 7, 3), LEAD[0])
    c.fill(c.rect(6, 4, 7, 5) & body, LEAD[0])
    c.outline(st["outline"])
    return c


def dry_pebbles(ms):
    """Pebbles in a dry channel, all lying the same way, the way the water once turned them."""
    rng = np.random.default_rng(206)
    st = pa.STYLES["tal"]
    c = ms.Canvas(48, 14)
    rock = st["rock"]
    for k in range(9):
        x = 4 + k * 5 + rng.uniform(-1, 1)
        y = 4 + (k % 3) * 3 + rng.uniform(-0.6, 0.6)
        m = c.ellipse(x, y, 2.6, 1.5)
        c.paint(m, rock, 0.3 + 0.6 * c.sphere(x - 1, y - 0.8, 3, 2), dither=False)
    c.outline(st["outline"])
    return c


def build(ms):
    ms.save("tal", "bl_post", post(ms), (8, 36), shape={"circle": 3, "offset": [0, -1]}, shadow=[6, 2])
    ms.save("tal", "bl_float", float_in_reeds(ms), (11, 26), sway=1.0)
    ms.save("tal", "bl_trap_stuck", trap_stuck(ms), (10, 28), flat=True)
    ms.save("tal", "bl_trap_free", trap_free(ms), (10, 28), flat=True)
    ms.save("tal", "bl_weir", weir(ms), (40, 18), flat=True)
    ms.save("tal", "bl_stumps", stumps(ms), (20, 27), shape={"rect": [34, 8], "offset": [0, -3]}, shadow=[18, 3])
    ms.save("tal", "bl_glass", glass_in_shallows(ms), (7, 6), flat=True)
    ms.save("tal", "bl_weight", lead_weight(ms), (6, 8), shadow=[4, 2])
    ms.save("tal", "bl_dry_pebbles", dry_pebbles(ms), (24, 9), flat=True)


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [post(ms), float_in_reeds(ms), trap_stuck(ms), trap_free(ms), stumps(ms), glass_in_shallows(ms),
             lead_weight(ms), dry_pebbles(ms)]
    big = weir(ms)
    sheet = Image.new("RGBA", (420, 120), (100, 140, 92, 255))
    x = 8
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, 6))
        x += img.width + 8
    sheet.alpha_composite(Image.fromarray(big.rgba().astype(np.uint8), "RGBA"), (8, 70))
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
