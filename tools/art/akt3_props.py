"""Props for Act III (docs/akt3/REGIONSBRIEFE.md), drawn like make_sprites.py and registered in the same
catalog (style "tal", so they share the atlas of the valley; the forest of the real world is the valley's
palette with taller trees). Called from make_sprites.build(); `--preview out.png` draws them on one sheet (4x).

Waldweg (W2): the tall forest (spruce and beech, a trunk and a high crown so that the path below stays in
view), the hermit's hut seen from the front (its door is wired by W3: a latch and no lock, Bible §14), a trunk
to sit on and a ring of stones with a kettle (the Rastplatz), the Antreiber's way markers (a post and a board
with a stripe of his faded red), a mossy stone and a fern. No prop here has a light: the forest builds no
PointLight2D before the first night map of the city (Plan 7).
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp

BEECH_BARK = ramp("#2c2a29", "#4a4743", "#726d63", "#9a9486", "#c2baa6")
ANTREIBER_RED = ramp("#3e1214", "#6a1e1c", "#9a3426", "#c85a3a")
SHINGLE = ramp("#2a2018", "#42301f", "#5e4429", "#7e5c38")
MOSS = ramp("#16261a", "#22382a", "#33503a", "#4a6c46")
FERN = ramp("#173020", "#22452a", "#315f34", "#467c3e", "#6a9a48")


def spruce(ms, seed):
    """Hochwald spruce: bare trunk, six drooping tiers; 56 x 120, anchor (28, 116)."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(56, 120)
    ms.trunk(c, st, ex["bark"], 28, 70, 117, 6, rng)
    fol = st["foliage"]
    edge = pa.value_noise(c.h, c.w, (2, 2), rng)
    tiers = [(30, 9), (44, 13), (58, 17), (72, 20), (86, 23), (100, 25)]
    for i, (y_bottom, half) in enumerate(tiers):
        y_top = y_bottom - (18 if i else 20) + (4 if i == 0 else 0)
        y_top = 6 if i == 0 else tiers[i - 1][0] - 8
        t = np.clip((c.yy - y_top) / max(y_bottom - y_top, 1), 0, 1)
        jag = (edge - 0.5) * 3
        tri = (np.abs(c.xx + 0.5 - 28) <= half * t + jag) & (c.yy >= y_top) & (c.yy <= y_bottom + (edge * 3).astype(int))
        light = 0.22 + 0.5 * c.cylinder(28 - half - 2, 28 + half + 2) + 0.2 * (1 - t)
        c.paint(tri, fol, np.where((c.yy > y_bottom - 3) & tri, light - 0.3, light), contrast=2.2)
    c.outline(st["outline"])
    return c


def beech(ms, seed):
    """Hochwald beech: long pale smooth trunk, three limbs, one high crown; 96 x 128, anchor (48, 124)."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(96, 128)
    cx, base = 48, 125
    lean = rng.uniform(-2, 2)
    for side in (-1, 1):
        root = ms.limb_mask(c, cx + side * 2, base - 6, cx + side * rng.uniform(7, 10), base, 4)
        c.paint(root, BEECH_BARK, 0.2 + 0.5 * c.cylinder(cx - 12, cx + 12), contrast=3.0, dither=False)
    trunk = np.zeros((c.h, c.w), bool)
    for y in range(58, base):
        t = (base - y) / (base - 58)
        x = cx + lean * t
        half = 4.2 * (1 - 0.25 * t)
        trunk[y, int(round(x - half)):int(round(x + half)) + 1] = True
    grain = pa.value_noise(c.h, c.w, (10, 1), rng)
    c.paint(trunk, BEECH_BARK, 0.15 + 0.7 * c.cylinder(cx + lean / 2 - 6, cx + lean / 2 + 6) + 0.1 * (grain - 0.5),
            contrast=2.6, dither=False)
    c.paint(trunk & (c.yy > base - 18) & (pa.value_noise(c.h, c.w, 3, rng) > 0.55) & (c.xx < cx + lean), MOSS, 0.55,
            dither=False)
    subs = []
    for k, a in enumerate((-2.5, -1.57, -0.65)):
        d = rng.uniform(20, 30)
        sx, sy = cx + lean + np.cos(a) * d * 1.3, 40 + np.sin(a) * d * 0.5 + 8
        limb = ms.limb_mask(c, cx + lean, 62, sx, sy + 4, 4)
        c.paint(limb, BEECH_BARK, 0.3 + 0.4 * c.cylinder(sx - 3, sx + 3), contrast=3.0, dither=False)
        subs.append((sy, sx, rng.uniform(15, 19)))
    subs.append((30, cx + lean, 21))
    blobs = []
    for sy, sx, r in subs:
        for _ in range(4):
            blobs.append((sy + rng.uniform(-r * .3, r * .3), sx + rng.uniform(-r * .35, r * .35), r * rng.uniform(.62, .82)))
    alpha, value = pa.render_foliage((c.h, c.w), blobs, rng, small=(3.4, 5.2))
    c.paint(alpha, st["foliage_blue" if seed % 2 else "foliage"], value, contrast=3.0, dither=False)
    c.outline(st["outline"])
    return c


def hut(ms):
    """The hermit's hut seen from the front: log walls, a steep shingle roof, a stone chimney, a closed plank door
    in the middle (x = anchor), one shuttered window; 88 x 84, anchor (44, 72), wall base 8 px under the anchor."""
    rng = np.random.default_rng(311)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(88, 84)
    wall_top, wall_bottom = 40, 80
    x0, x1 = 12, 76
    grain = pa.value_noise(c.h, c.w, (1, 8), rng)
    wall = c.rect(x0, wall_top, x1, wall_bottom)
    log = ((c.yy - wall_top) // 6).astype(int)
    v = 0.42 + 0.1 * ((((log * 2654435761) % 89) / 89.0) - 0.5) + 0.16 * (grain - 0.5)
    v = np.where(((c.yy - wall_top) % 6) == 5, 0.08, v)
    c.paint(wall, ex["bark"], v, contrast=2.0)
    for px in (x0, x1 - 4):  # log ends at the corners
        c.paint(c.rect(px, wall_top, px + 4, wall_bottom), ex["bark"], np.where(c.xx == px, 0.8, 0.5), dither=False)
    c.paint(c.rect(x0 - 1, wall_bottom - 4, x1 + 1, wall_bottom + 1), ex["stone_wall"], 0.4, dither=False)
    roof = c.rect(4, 8, 84, wall_top + 4)
    roof &= ~((c.yy < 18) & ((c.xx < 4 + (18 - c.yy)) | (c.xx > 83 - (18 - c.yy))))
    yy, xx = c.yy.astype(int), c.xx.astype(int)
    row, ry = (yy - 8) // 5, (yy - 8) % 5
    rv = 0.6 - 0.35 * (yy - 8) / (wall_top - 8) + 0.14 * ((((row * 7919 + (xx + (row % 2) * 3) // 5 * 104729) % 97) / 97.0) - 0.5)
    rv = np.where(ry == 0, rv + 0.12, np.where(ry == 4, 0.05, rv))
    c.paint(roof, SHINGLE, rv, contrast=2.2)
    c.paint(roof & (pa.value_noise(c.h, c.w, 3, rng) > 0.82), MOSS, 0.5, dither=False)
    chim = c.rect(58, 0, 68, 22)
    c.paint(chim, ex["stone_wall"], 0.25 + 0.6 * c.cylinder(57, 69))
    c.paint(c.rect(56, 0, 70, 3), ex["stone_wall"], 0.7)
    door = c.rect(37, 52, 51, wall_bottom)
    c.paint(door, st["wood"], np.where(((c.xx - 37) % 4) == 3, 0.1, 0.42 + 0.2 * (grain - 0.5)))
    c.paint(c.rect(35, 49, 53, 52), ex["plank"], 0.7)
    c.paint(c.rect(47, 66, 49, 68), ex["iron"], 0.7, dither=False)  # a plain latch, no lock
    win = c.rect(18, 54, 30, 66)
    c.paint(c.rect(17, 53, 31, 67), ex["plank"], 0.7)
    c.paint(win, ramp("#141a22", "#26323e", "#3e4e5c"), 0.3, dither=False)
    c.paint(c.rect(23, 54, 25, 66), ex["plank"], 0.3)
    c.outline(st["outline"])
    return c


def rest_log(ms):
    """A trunk section to sit on: 44 x 24, anchor (22, 18)."""
    rng = np.random.default_rng(321)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(44, 24)
    body = c.rect(4, 6, 40, 18) | c.ellipse(5, 12, 3.2, 6) | c.ellipse(40, 12, 3.2, 6)
    t = (c.yy + 0.5 - 12) / 6.5
    light = np.sqrt(np.clip(1 - t * t, 0, 1)) * 0.75 + np.clip(-t, 0, 1) * 0.25
    c.paint(body, ex["bark"], 0.12 + 0.62 * light + 0.12 * (pa.value_noise(24, 44, (1, 7), rng) - 0.5), contrast=2.0)
    seat = c.rect(8, 6, 38, 10)  # the top worn smooth by sitting
    c.paint(seat, ex["plank"], 0.62, dither=False)
    end = c.ellipse(5, 12, 2.6, 5)
    rings = (np.hypot(c.xx + 0.5 - 5, (c.yy + 0.5 - 12) * 0.6).astype(int) % 2) == 0
    c.paint(end, ex["plank"], np.where(rings, 0.55, 0.78), dither=False)
    c.paint(body & (c.yy > 14) & (pa.value_noise(24, 44, 2, rng) > 0.6), MOSS, 0.5, dither=False)
    c.outline(st["outline"])
    return c


def rest_fire(ms, lit):
    """Stone ring, ash, a tripod with a kettle. `lit` adds embers (emissive) and a little heat; no PointLight2D.
    32 x 36, anchor (16, 30)."""
    rng = np.random.default_rng(331)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(32, 36)
    e = ms.Canvas(32, 36)
    c.paint(c.ellipse(16, 27, 10, 4.6), ramp("#141210", "#221e1a", "#34302a"), 0.35 if lit else 0.5, dither=False)
    for k in range(9):
        a = k / 9 * 2 * np.pi
        x, y = 16 + np.cos(a) * 9.2, 27 + np.sin(a) * 4.2
        c.paint(c.ellipse(x, y, 2.5, 1.9), st["rock"], 0.3 + 0.5 * c.sphere(x - 1, y - 1, 3, 2.4), contrast=2.0)
    for sx in (-8, 0, 8):  # tripod
        c.paint(c.rect(16 + sx // 2 - (1 if sx < 0 else 0), 6, 16 + sx // 2 + 1, 28), ex["bark"], 0.45, dither=False)
    c.paint(c.rect(10, 5, 22, 7), ex["bark"], 0.5, dither=False)
    kettle = c.ellipse(16, 16, 5, 4.2)
    c.paint(kettle, ex["iron"], 0.2 + 0.7 * c.sphere(14, 14, 5, 4), dither=False)
    c.paint(c.rect(14, 10, 18, 12), ex["iron"], 0.5, dither=False)
    if lit:
        embers = ramp("#5a1a0c", "#b0401a", "#f08a30", "#ffd070")
        glow = c.ellipse(16, 26.5, 4, 1.8)
        c.paint(glow, embers, 0.4 + 0.6 * c.sphere(16, 26, 4, 2), dither=False)
        e.paint(glow, embers, 0.4 + 0.6 * c.sphere(16, 26, 4, 2), dither=False)
    c.outline(st["outline"])
    return c, e


def marker(ms, kind):
    """The Antreiber's way marker: a post, a board with a stripe of his faded red; 28 x 40, anchor (9, 38).
    "blank" is the last one: the same board with nothing written on it."""
    rng = np.random.default_rng({"arrow": 341, "tally": 342, "plain": 343, "blank": 344}[kind])
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(28, 40)
    c.paint(c.rect(7, 8, 11, 39), ex["plank"], np.where(c.xx < 9, 0.65, 0.3), dither=False)
    if kind == "arrow":
        board = c.rect(2, 6, 20, 15) | (c.rect(20, 6, 26, 15) & (np.abs(c.yy + 0.5 - 10.5) <= (26 - c.xx) * 0.9))
    else:
        board = c.rect(2, 6, 25, 15)
    grain = pa.value_noise(40, 28, (1, 5), rng)
    c.paint(board, ex["plank"], 0.62 + 0.15 * (grain - 0.5), contrast=2.0)
    c.paint(board & (c.yy < 9), ANTREIBER_RED, 0.55, dither=False)
    if kind == "tally":
        for x in range(4, 22, 3):
            c.paint(c.rect(x, 10, x + 1, 14), ex["plank"], 0.1, dither=False)
    elif kind != "blank":
        for x in range(4, 21, 2):
            c.paint(c.rect(x, 11, x + 1, 13), ex["plank"], 0.1, dither=False)
    c.outline(st["outline"])
    return c


def mossy_stone(ms, seed):
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(seed)
    c = ms.rock("tal", seed, 30, 22)
    top = c.a & (c.yy < 14) & (pa.value_noise(22, 30, 3, rng) > 0.3)
    c.paint(top, MOSS, 0.35 + 0.6 * c.sphere(12, 6, 15, 9), dither=False)
    c.outline(st["outline"])
    return c


def fern(ms, seed):
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(26, 18)
    for k in range(7):
        a = np.pi * (0.15 + 0.7 * k / 6) + rng.uniform(-0.1, 0.1)
        length = rng.uniform(9, 13)
        for t in np.linspace(0, 1, 26):
            x = 13 - np.cos(a) * length * t
            y = 17 - np.sin(a) * length * t + (t * t) * 4
            c.paint(c.ellipse(x, y, 2.2 * (1 - t) + 0.6, 0.9), FERN, 0.3 + 0.6 * t, dither=False)
    c.outline(st["outline"])
    return c


def cone(ms):
    """A spruce cone in the needles, the scales half open (the curiosity of the first stretch); 12 x 10, anchor (6, 8)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(12, 10)
    body = c.ellipse(6, 5, 4.6, 3.0)
    scales = ramp("#2a1a10", "#4e3220", "#7a5434", "#a87c4c")
    c.paint(body, scales, 0.35 + 0.45 * c.sphere(5, 4, 5, 3.6), dither=False)
    for x in (3, 5, 7, 9):
        c.paint(c.rect(x, 3, x, 7), scales, 0.12, dither=False)
    c.outline(st["outline"])
    return c


def build(ms):
    ms.save("tal", "wd_spruce", [spruce(ms, 701 + k) for k in range(3)], (28, 116),
            shape={"circle": 5, "offset": [0, -2]}, sway=0.5, shadow=[18, 6])
    ms.save("tal", "wd_beech", [beech(ms, 711 + k) for k in range(3)], (48, 124),
            shape={"circle": 6, "offset": [0, -2]}, sway=0.8, shadow=[30, 9])
    ms.save("tal", "wd_hut", hut(ms), (44, 72), shape={"rect": [64, 24], "offset": [0, -4]}, shadow=[34, 6],
            smoke=[19, -69])
    ms.save("tal", "wd_rest_log", rest_log(ms), (22, 18), shape={"rect": [38, 8], "offset": [0, -4]}, shadow=[20, 4])
    cold, _ = rest_fire(ms, False)
    lit, emit = rest_fire(ms, True)
    ms.save("tal", "wd_rest_cold", cold, (16, 30), shape={"circle": 8, "offset": [0, -2]}, shadow=[12, 4])
    ms.save("tal", "wd_rest_lit", lit, (16, 30), emissive=emit, shape={"circle": 8, "offset": [0, -2]}, shadow=[12, 4],
            smoke=[0, -26])
    for kind in ("arrow", "tally", "plain", "blank"):
        ms.save("tal", "wd_marker_" + kind, marker(ms, kind), (9, 38), shape={"circle": 3, "offset": [0, -1]},
                shadow=[6, 2])
    ms.save("tal", "wd_stone_mossy", [mossy_stone(ms, 731 + k) for k in range(2)], (15, 19),
            shape={"rect": [20, 8], "offset": [0, -3]}, shadow=[13, 4])
    ms.save("tal", "wd_cone", cone(ms), (6, 8), shadow=[4, 2])
    ms.save("tal", "wd_fern", [fern(ms, 741 + k) for k in range(3)], (13, 17), sway=1.5, surface="tall_grass",
            rustle=True)


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [spruce(ms, 701), spruce(ms, 702), beech(ms, 711), beech(ms, 712), hut(ms), rest_log(ms),
             rest_fire(ms, False)[0], rest_fire(ms, True)[0]]
    items += [marker(ms, kind) for kind in ("arrow", "tally", "plain", "blank")]
    items += [mossy_stone(ms, 731), fern(ms, 741)]
    sheet = Image.new("RGBA", (780, 150), (96, 136, 88, 255))
    x = 8
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, 148 - img.height if img.height < 148 else 0))
        x += img.width + 6
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
