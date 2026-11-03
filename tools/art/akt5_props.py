"""Props for Act V (docs/akt5/REGIONSBRIEFE.md), drawn like make_sprites.py and registered in the same catalog (style "tal",
so they share the atlas of the valley; the mountains are the valley's palette with more stone). Called from
make_sprites.build(); `--preview out.png` draws them on one sheet (3x) to look at.

Aufstieg (G1): the climb into the mountains, a walk of small things and small jokes. Nothing here is a person; every piece
has the shape of what it was made for, and nothing says what it means. Cairns in three forms (two, three and five stones;
the stones are the valley's grey with a warm one among them), the big boulder and the loose scree, the wooden steps of the
ramps and the two planks over the brook, the hand-painted sign (its words are scribbles, a painted peak under them), a slate
chip with a scratched arrow, the iron ring in the rock wall (its inner edge worn bright by a rope), the chalk arrow on a
flat stone at the signpost of the road, the three traces of Mira (a tidy net knot on a post, a net on a low branch, a plain
flat stone), the thin column of smoke of the plant, the rock one stands on to see it and the fall of rock that closes the
way. No prop has a light. What the map places under `if`/`unless` carries no shadow in the catalog (shadow cells feed the
baked stamp of the map), and so do the things placed on cells of an older stamp (the chalk arrow and the cairns of the
road, which are `gb_arrow_chalk` and `gb_cairn_road`) and the things that G2 may take away (the fall of rock).
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp

SLATE = ramp("#1c222c", "#2f3946", "#485566", "#6a7a8c", "#94a4b4")
CHALK = ramp("#7c7a70", "#b0ad9e", "#d6d3c4", "#f3f1e6")
RUST = ramp("#2e140c", "#5c2a16", "#8e4420", "#bc6a30")
BRIGHT_IRON = ramp("#14161a", "#2a2d34", "#4a4f58", "#8a9098", "#c4cad2")
CORD = ramp("#4a4234", "#7a6e56", "#a89a7a", "#cfc29e")
NET_CORD = ramp("#3e3a2e", "#6c6650", "#a09878", "#d0c8a4")
LICHEN = ramp("#5a6648", "#7e8c5e", "#a2b27a", "#c4cf8e")
MOSS = ramp("#16261a", "#22382a", "#33503a", "#4a6c46")
SMOKE = ramp("#9aa8b0", "#bcc8cc", "#dce4e4", "#f4f7f2")
PAINT = ramp("#6a8a98", "#a6c4d0", "#dcebf0", "#fbfdfd")  # the sign painter's pale blue-white paint


def _poly(c, pts):
    """A mask: the convex polygon through `pts` (clockwise or not) on the canvas grid."""
    px, py = c.xx + 0.5, c.yy + 0.5
    sign = None
    inside = np.ones((c.h, c.w), bool)
    n = len(pts)
    for i in range(n):
        x0, y0 = pts[i]
        x1, y1 = pts[(i + 1) % n]
        cross = (x1 - x0) * (py - y0) - (y1 - y0) * (px - x0)
        if sign is None:
            area = sum(pts[k][0] * pts[(k + 1) % n][1] - pts[(k + 1) % n][0] * pts[k][1] for k in range(n))
            sign = 1.0 if area > 0 else -1.0
        inside &= cross * sign >= 0
    return inside


# --------------------------------------------------------------------------- the cairns
CAIRN_STONES = {
    # (cx, cy, rx, ry, tilt) from the bottom stone to the top one, in pixels of the canvas
    "a": [(8.0, 14.5, 6.6, 3.6), (8.6, 9.6, 4.0, 2.6)],
    "b": [(9.0, 22.5, 7.4, 3.9), (8.4, 17.2, 5.4, 3.0), (9.2, 12.4, 3.6, 2.4)],
    "c": [(9.0, 30.0, 7.8, 4.1), (9.6, 24.2, 6.0, 3.3), (8.6, 19.0, 4.6, 2.8), (9.4, 14.6, 3.2, 2.2), (9.0, 11.2, 1.8, 1.4)],
}


def cairn(ms, kind, seed):
    """A cairn: flat stones piled by hand, the biggest below, each smaller one a little off the middle of the last, the
    top one small and balanced; moss on the lowest stone and grass at the foot. The stones keep the valley's grey with one
    warmer stone among them. `a` 18 x 20 (anchor (9, 18)), `b` 18 x 28 (anchor (9, 26)), `c` 18 x 36 (anchor (9, 34))."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    stones = CAIRN_STONES[kind]
    h = {"a": 20, "b": 28, "c": 36}[kind]
    c = ms.Canvas(18, h)
    warm = int(rng.integers(0, len(stones)))
    for k, (cx, cy, rx, ry) in enumerate(stones):
        body = c.ellipse(cx, cy, rx, ry) | c.rect(cx - rx + 0.6, cy - ry * 0.4, cx + rx - 0.6, cy + ry * 0.4)
        noise = pa.value_noise(h, 18, 3, rng)
        light = 0.3 + 0.55 * c.sphere(cx - 1.0, cy - 0.5, rx + 1.5, ry + 1.5) + 0.12 * (noise - 0.5)
        ramp_k = st["rock"] if k != warm else st["cliff"]
        c.paint(body, ramp_k, np.clip(light + (0.06 if k == warm else 0.0), 0, 1), contrast=2.2, dither=False)
        # the dark seam under each stone, where the next one lies on it
        under = body & (c.yy >= cy + ry - 1.2)
        c.paint(under & c.a, ramp_k, 0.1, dither=False)
        c.paint(c.rect(cx - rx * 0.5, cy - ry * 0.9, cx + rx * 0.1, cy - ry * 0.55) & body, ramp_k, 0.92, dither=False)
    # moss and a few blades of grass at the foot
    bottom = stones[0]
    foot = c.ellipse(bottom[0], bottom[1] + 1.0, bottom[2] + 0.5, bottom[3] + 0.6) & (c.yy >= bottom[1] + 0.5)
    c.paint(foot & c.a & (pa.value_noise(h, 18, 2, rng) > 0.35), MOSS, 0.5, dither=False)
    for gx in (int(bottom[0] - bottom[2]), int(bottom[0] + bottom[2] - 1)):
        c.fill(c.rect(gx, int(bottom[1] + 1), gx + 1, int(bottom[1] + 4)), st["grass"][3])
        c.fill(c.rect(gx + 1, int(bottom[1] + 2), gx + 2, int(bottom[1] + 4)), st["grass"][2])
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- boulders, scree, the fall of rock
def boulder(ms, seed):
    """A big boulder, cracked, pale with lichen on its lit side; 38 x 30, anchor (19, 26)."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.rock("tal", seed, 38, 30, moss=False)
    body = c.a.copy()
    lichen = body & (pa.value_noise(30, 38, 2.2, rng) > 0.7) & (c.yy < 17)
    c.paint(lichen, LICHEN, 0.55 + 0.3 * pa.value_noise(30, 38, 1.5, rng), dither=False)
    # a crack from the top to the middle, dark with a lit edge
    x = 17 + int(rng.integers(0, 6))
    for y in range(7, 19):
        x += int(rng.integers(-1, 2))
        c.fill(c.rect(x, y, x + 1, y + 1) & body, st["rock"][0])
        c.fill(c.rect(x + 1, y, x + 2, y + 1) & body, st["rock"][4])
    c.outline(st["outline"])
    return c


def scree(ms, seed):
    """A patch of loose stones on the ground: flat flakes with a lit edge and a dark side, a few small ones between them,
    nothing round. 44 x 18, flat, anchor (22, 9)."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(44, 18)
    for k in range(int(rng.integers(6, 10))):
        cx, cy = rng.uniform(5, 39), rng.uniform(4, 14)
        r = rng.uniform(1.6, 3.8)
        n = int(rng.integers(4, 6))
        ang0 = rng.uniform(0, 6.28)
        pts = [(cx + np.cos(ang0 + 6.28 * i / n + rng.uniform(-0.3, 0.3)) * r * rng.uniform(0.7, 1.3),
                cy + np.sin(ang0 + 6.28 * i / n + rng.uniform(-0.3, 0.3)) * r * 0.55 * rng.uniform(0.7, 1.3)) for i in range(n)]
        mask = _poly(c, pts)
        c.paint(mask, st["rock"], 0.32 + 0.4 * rng.random() + 0.25 * (c.yy < cy), dither=False)
        c.paint(mask & (c.yy > cy + r * 0.3), st["rock"], 0.12, dither=False)
    c.outline(st["outline"])
    return c


def rockfall(ms):
    """The fall of rock that fills the gap at the end of the way: a heap of angular boulders, the big ones below and to
    the sides, a few small ones on the slope, dust at its foot. 96 x 52, anchor (48, 40) (the glyph stands one row north of the blocker; the picture reaches from the top edge of the map down over the canyon's mouth)."""
    rng = np.random.default_rng(1601)
    st = pa.STYLES["tal"]
    c = ms.Canvas(96, 52)
    # the heap: three tiers of stones, back to front
    placements = []
    for row, (y_c, count, rmax) in enumerate(((22, 5, 9.0), (31, 6, 10.5), (41, 7, 11.5))):
        for i in range(count):
            span = 70 - 8 * (2 - row) * 0.4
            cx = 48 + (i - (count - 1) / 2) * span / max(count - 1, 1) + rng.uniform(-3, 3)
            placements.append((cx, y_c + rng.uniform(-2, 2), rng.uniform(0.7, 1.0) * rmax))
    for cx, cy, r in placements:
        n = int(rng.integers(5, 7))
        ang0 = rng.uniform(0, 6.28)
        pts = [(cx + np.cos(ang0 + 6.28 * i / n) * r * rng.uniform(0.75, 1.25), cy + np.sin(ang0 + 6.28 * i / n) * r * 0.72 * rng.uniform(0.75, 1.2))
               for i in range(n)]
        mask = _poly(c, pts)
        light = 0.25 + 0.45 * rng.random() + 0.3 * np.clip((cy - c.yy) / r, -0.5, 1)
        c.paint(mask, st["rock"], light, contrast=2.4, dither=False)
        c.paint(mask & (c.yy > cy + r * 0.35), st["rock"], 0.1, dither=False)
        c.paint(mask & (c.yy < cy - r * 0.45) & (c.xx < cx), st["rock"], 0.95, dither=False)
    # dust at the foot
    c.paint(c.ellipse(48, 47, 44, 3.2) & ~c.a, st["path"], 0.5, dither=True)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- wood: steps, planks, sign
def steps(ms):
    """The steps of a ramp: logs laid across the way, held by stakes, the earth packed between them and worn. Flat; 48 x 64
    (three cells wide, four rows), anchor (24, 32)."""
    rng = np.random.default_rng(1621)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 64)
    path = st["path"]
    c.paint(c.rect(2, 0, 46, 64), path, 0.5 + 0.1 * (pa.value_noise(64, 48, 3, rng) - 0.5), dither=True)
    grain = pa.value_noise(64, 48, (1, 7), rng)
    for k, y in enumerate(range(6, 62, 11)):
        c.paint(c.rect(1, y, 47, y + 3), ex["bark"], 0.82 + 0.12 * (grain - 0.5), dither=False)  # the log's lit top
        c.paint(c.rect(1, y + 3, 47, y + 7), ex["bark"], 0.34 + 0.2 * (grain - 0.5), contrast=2.0, dither=False)  # its front
        c.paint(c.rect(1, y + 6, 47, y + 7), ex["bark"], 0.08, dither=False)
        c.paint(c.ellipse(2.5, y + 4, 2.5, 3.0), ex["bark"], 0.74, dither=False)  # the cut end
        for sx in (9, 38):
            c.paint(c.rect(sx, y - 1, sx + 3, y + 8), ex["plank"], 0.7 - 0.1 * (sx > 20), dither=False)  # a stake
            c.fill(c.rect(sx + 1, y - 1, sx + 2, y), ex["iron"][3])
        # the worn tread above the log, lit
        c.paint(c.rect(3, y - 4, 45, y), path, 0.74 + 0.1 * (k % 2) - 0.1 * (grain - 0.5), dither=False)
    c.outline(st["outline"])
    return c


def planks(ms):
    """Two planks over the brook, each a thick board with its grain lengthwise, an end on each bank and a pale worn middle;
    a gap of two pixels between them (the water shows). Flat; 80 x 32 (five cells, two rows), anchor (40, 8)."""
    rng = np.random.default_rng(1631)
    ex = ms.EXTRA["tal"]
    c = ms.Canvas(80, 32)
    grain = pa.value_noise(32, 80, (1, 9), rng)
    for y0, y1, seed_shift in ((2, 15, 0), (17, 30, 3)):
        board = c.rect(4, y0, 76, y1)
        worn = 1.0 - np.abs(c.xx - 40) / 36.0  # the middle is walked pale
        c.paint(board, ex["plank"], 0.5 + 0.22 * worn + 0.16 * (grain - 0.5) + 0.12 * (c.yy < y0 + 2) - 0.14 * (c.yy >= y1 - 2),
                contrast=2.2, dither=False)
        c.paint(c.rect(4, y1 - 1, 76, y1), ex["plank"], 0.08, dither=False)
        c.paint(c.rect(75, y0, 76, y1), ex["plank"], 0.78, dither=False)
        for kx in (22 + 3 * seed_shift, 54 - 2 * seed_shift):  # a knot
            c.paint(c.ellipse(kx, (y0 + y1) / 2, 2.6, 1.8), ex["plank"], 0.14, dither=False)
            c.paint(c.ellipse(kx, (y0 + y1) / 2 - 0.4, 1.2, 0.8), ex["plank"], 0.34, dither=False)
        for nx in (8, 70):  # nails at the ends
            c.fill(c.rect(nx, y0 + 4, nx + 2, y0 + 6), ex["iron"][3])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def trail_sign(ms):
    """A hand-made sign on a crooked post: a board nailed on a little askew, the words painted in pale blue-white paint
    by someone who ran out of board (three lines of scribbles, the last one squeezed, a drip), and under them a painted
    peak with a flag. 30 x 44, anchor (15, 42)."""
    rng = np.random.default_rng(1641)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(30, 44)
    grain = pa.value_noise(44, 30, (1, 5), rng)
    lean = (c.yy - 40) * 0.05
    post = c.rect(13, 8, 18, 43) & (np.abs(c.xx + 0.5 - 15.5 - lean) <= 2.6)
    c.paint(post, ex["plank"], np.where(c.xx < 15 + lean, 0.6, 0.26) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.ellipse(15.5, 42, 6.5, 1.8), st["stone"], 0.3, dither=False)
    tilt = (c.xx - 15) * 0.1
    board = (c.xx >= 2) & (c.xx < 28) & (c.yy >= 5 + tilt) & (c.yy < 23 + tilt)
    c.paint(board, ex["plank"], 0.58 + 0.14 * (1 - (c.yy - 5) / 18) + 0.14 * (grain - 0.5), contrast=2.0)
    c.paint(c.rect(2, 22, 28, 24) & board, ex["plank"], 0.1, dither=False)
    for k, (y, x0, x1) in enumerate(((8, 5, 25), (12, 5, 21), (15, 5, 26))):  # the words: strokes, no letters
        xs = np.arange(x0, x1, 2 + (k % 2))
        for i, x in enumerate(xs):
            yy = int(y + (x - 15) * 0.1) + (i % 2)
            c.fill(c.rect(x, yy, x + 2, yy + 2), PAINT[2 + (i % 3 == 0)])
    c.fill(c.rect(24, 17, 25, 22), PAINT[1])  # a drip
    # the peak under the words, with a flag on its tip
    peak = _poly(c, [(8, 21.5), (14, 17.5), (20, 21.5)])
    c.fill(peak, PAINT[3])
    c.fill(c.rect(14, 14, 15, 18), PAINT[2])
    c.fill(c.rect(15, 14, 18, 16), np.array([200, 80, 60], np.float32))
    c.fill(c.rect(4, 6, 6, 8), ex["iron"][3])
    c.fill(c.rect(24, 6, 26, 8), ex["iron"][3])
    c.outline(st["outline"])
    return c


def slate_chip(ms):
    """A chip of slate, thin and angular, with an arrow scratched into its face (light on dark, the point up); a pale
    break along one edge. Flat; 20 x 14, anchor (10, 7)."""
    rng = np.random.default_rng(1651)
    c = ms.Canvas(20, 14)
    chip = _poly(c, [(2, 8), (5, 3), (13, 2), (18, 5), (17, 11), (8, 12)])
    c.paint(chip, SLATE, 0.46 + 0.3 * (c.yy < 7) + 0.14 * (pa.value_noise(14, 20, 3, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(chip & (c.yy > 10), SLATE, 0.12, dither=False)
    c.paint(chip & (c.xx + c.yy < 11), SLATE, 0.88, dither=False)  # the pale break
    for x, y0, y1 in ((10, 4, 10),):  # the arrow's shaft
        c.fill(c.rect(x, y0, x + 1, y1), SLATE[4])
    for dx in (1, 2):  # and its head
        c.fill(c.rect(10 - dx, 4 + dx, 11 - dx, 5 + dx), SLATE[4])
        c.fill(c.rect(10 + dx, 4 + dx, 11 + dx, 5 + dx), SLATE[4])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def chalk_arrow(ms):
    """A flat stone, a hand's width across, with a chalk arrow drawn on it, the point up (north). Flat; 26 x 20, anchor
    (13, 10)."""
    rng = np.random.default_rng(1661)
    st = pa.STYLES["tal"]
    c = ms.Canvas(26, 20)
    slab = _poly(c, [(2, 11), (4, 4), (14, 2), (23, 5), (24, 13), (15, 18), (6, 17)])
    c.paint(slab, st["rock"], 0.5 + 0.28 * (c.yy < 8) + 0.12 * (pa.value_noise(20, 26, 3, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(slab & (c.yy > 14), st["rock"], 0.14, dither=False)
    chalk = CHALK[3]
    c.fill(c.rect(13, 6, 15, 15) & slab, chalk)  # the shaft, two strokes thick
    c.fill(c.rect(14, 8, 15, 16) & slab, CHALK[2])
    for dx in (1, 2, 3):  # the head: two strokes down from the point
        c.fill(c.rect(13 - dx, 5 + dx, 14 - dx, 6 + dx), chalk)
        c.fill(c.rect(14 + dx, 5 + dx, 15 + dx, 6 + dx), chalk)
    c.fill(c.rect(12, 4, 16, 5), CHALK[2])
    c.fill(c.rect(9, 14, 12, 15), CHALK[1])  # a smudge where a thumb was
    c.outline(st["outline"])
    return c


def iron_ring(ms):
    """An iron ring in a block of the rock wall: a staple driven into dressed stone, the ring hanging in it, its upper inner
    edge rubbed bright and smooth by a rope that was hauled through it for years, a rust stain below. The block's picture
    is the wall's own (dark stone with a lit top edge). 22 x 26, anchor (11, 26): it hangs on the wall cell above the cell
    the glyph stands on."""
    rng = np.random.default_rng(1671)
    st = pa.STYLES["tal"]
    c = ms.Canvas(22, 26)
    block = c.rect(1, 1, 21, 20)
    c.paint(block, st["cliff"], 0.38 + 0.12 * (pa.value_noise(26, 22, 3, rng) - 0.5) - 0.12 * (c.yy - 1) / 19, contrast=2.0, dither=False)
    c.paint(c.rect(1, 1, 21, 3), st["cliff"], 0.7, dither=False)
    c.paint(c.rect(1, 19, 21, 20), st["cliff"], 0.08, dither=False)
    c.paint(c.rect(10, 18, 13, 26), RUST, 0.45, dither=False)  # the rust stain running down from the staple
    c.paint(c.rect(11, 20, 12, 24), RUST, 0.7, dither=False)
    # the staple and the ring: a torus seen from the front
    ring_outer = c.ellipse(11, 12.5, 6.4, 6.6)
    ring_inner = c.ellipse(11, 12.5, 3.6, 3.7)
    ring = ring_outer & ~ring_inner
    c.paint(ring, BRIGHT_IRON, 0.25 + 0.6 * c.sphere(8.5, 9.5, 9, 9), dither=False)
    worn = ring & (c.yy > 9.5) & (c.yy < 17) & (np.hypot(c.xx + 0.5 - 11, c.yy + 0.5 - 12.5) < 4.8)  # the inner edge, rubbed bright
    c.fill(worn & (np.hypot(c.xx + 0.5 - 11, c.yy + 0.5 - 12.5) < 4.4), BRIGHT_IRON[4])
    c.paint(c.rect(9, 3, 13, 7), BRIGHT_IRON, 0.35, dither=False)  # the staple
    c.fill(c.rect(10, 4, 12, 5), BRIGHT_IRON[3])
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- Mira's traces
def net_piece(c, x0, y0, w, h, sag=0.0, tidy=True, seed=0):
    """A piece of fishing net: a diamond mesh of cord between two corners, tidy (straight lines) or slack (a sag)."""
    rng = np.random.default_rng(seed)
    step = 3
    for i in range(0, w + 1, step):
        for j in range(0, h + 1, step):
            x, y = x0 + i, y0 + j + (sag * np.sin(np.pi * i / max(w, 1)) if not tidy else 0)
            x, y = int(round(x)), int(round(y))
            if (i // step + j // step) % 2 == 0:
                c.fill(c.rect(x, y, x + 2, y + 1), NET_CORD[2])
                c.fill(c.rect(x, y + 1, x + 1, y + 3), NET_CORD[1])
            else:
                c.fill(c.rect(x, y, x + 1, y + 2), NET_CORD[2])
                c.fill(c.rect(x + 1, y + 1, x + 3, y + 2), NET_CORD[1])


def net_post(ms):
    """Mira's trace for 'boundary': a weathered post at the edge of the path, a net knotted to its nail, the cord drawn
    tight, the ends cut straight and short. Tidy. 16 x 36, anchor (8, 34)."""
    rng = np.random.default_rng(1681)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(16, 36)
    grain = pa.value_noise(36, 16, (1, 6), rng)
    c.paint(c.rect(5, 6, 11, 35), ex["plank"], np.where(c.xx < 7.5, 0.7, np.where(c.xx > 9, 0.24, 0.48)) + 0.12 * (grain - 0.5), dither=False)
    c.paint(c.rect(4, 4, 12, 7), ex["plank"], np.where(c.xx < 8, 0.86, 0.54), dither=False)
    c.paint(c.ellipse(8, 35, 6, 1.6), st["stone"], 0.3, dither=False)
    net_piece(c, 4, 14, 8, 12, tidy=True, seed=3)  # the net: a square of mesh, tied at the nail
    c.paint(c.rect(7, 12, 9, 16), CORD, 0.7, dither=False)  # the knot
    c.fill(c.rect(7, 12, 9, 13), CORD[3])
    c.fill(c.rect(7, 11, 8, 12), ex["iron"][3])  # the nail's head
    c.outline(st["outline"])
    return c


def net_branch(ms):
    """Mira's trace for 'joined': a low forked branch, upright, at the height of an arm, a net hung over its fork and
    tied loosely, a loop of cord hanging below it. 30 x 38, anchor (15, 36)."""
    rng = np.random.default_rng(1691)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(30, 38)
    bark = ex["bark"]
    c.paint(c.rect(13, 14, 18, 37), bark, np.where(c.xx < 15, 0.62, 0.26) + 0.1 * (pa.value_noise(38, 30, (1, 5), rng) - 0.5), dither=False)
    for x0, y0, x1, y1 in ((15, 15, 8, 3), (16, 15, 23, 5)):  # the two forks
        steps_n = max(abs(y1 - y0), abs(x1 - x0))
        for i in range(steps_n + 1):
            t = i / steps_n
            x, y = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t))
            c.paint(c.rect(x - 1, y, x + 2, y + 1), bark, 0.66 if x1 < x0 else 0.44, dither=False)
    c.paint(c.ellipse(15.5, 36.5, 6.5, 1.8), st["stone"], 0.3, dither=False)
    net_piece(c, 6, 12, 18, 13, sag=3.0, tidy=False, seed=7)  # the net over the fork, slack
    c.paint(c.rect(13, 12, 18, 15), CORD, 0.6, dither=False)  # a loose tie
    c.fill(c.rect(11, 14, 12, 21), CORD[1])  # a loop that hangs from it
    c.fill(c.rect(12, 20, 15, 21), CORD[1])
    c.outline(st["outline"])
    return c


def stone_mark(ms):
    """Mira's trace for 'silent': a flat stone, smooth and pale, bigger than the stones round it, lying in the middle of the
    path; nothing under it, nothing on it. Flat; 24 x 16, anchor (12, 8)."""
    rng = np.random.default_rng(1701)
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 16)
    stone = c.ellipse(12, 8, 9.6, 5.4) & (c.yy < 13.2)
    c.paint(stone, st["rock"], 0.64 + 0.28 * c.sphere(10, 6.5, 11, 7) - 0.1 * (c.yy - 6) / 6
            + 0.05 * (pa.value_noise(16, 24, 3, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(c.ellipse(11, 6.2, 5.2, 1.5) & stone, st["rock"], 0.97, dither=False)
    c.paint(stone & (c.yy > 11), st["rock"], 0.2, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the smoke, the lookout
def smoke(ms):
    """The smoke of the plant, far away: a thin pale column that rises straight and spreads a little as it climbs, the
    edges and the top dithered into the sky. Flat; 16 x 168, anchor (8, 166)."""
    c = ms.Canvas(16, 168)
    b = pa.BAYER4[np.arange(168)[:, None] % 4, np.arange(16)[None, :] % 4]
    for y in range(168):
        t = y / 167.0  # 0 at the top, 1 at the foot
        half = 2.6 + 3.4 * (1.0 - t)  # spreads as it climbs
        sway = 0.9 * np.sin(y / 17.0)
        for x in range(16):
            d = abs(x + 0.5 - 8 - sway)
            core = d <= half * 0.5
            soft = d <= half
            fade = min(1.0, t * 1.6, (1.0 - t) * 6.0 + 0.2)  # thins at the top, a little at the foot
            if core and b[y, x] < fade * 1.15:
                c.fill(c.rect(x, y, x + 1, y + 1), SMOKE[3 if d < half * 0.25 else 2])
            elif soft and b[y, x] < fade * 0.55:
                c.fill(c.rect(x, y, x + 1, y + 1), SMOKE[1])
    return c


def lookout(ms):
    """A flat-topped rock at the edge of a shelf, the top worn pale and smooth by those who stood on it to look, the
    front dark and split, lichen, a tuft of grass in a crack. 60 x 36, anchor (30, 30)."""
    rng = np.random.default_rng(1711)
    st = pa.STYLES["tal"]
    c = ms.Canvas(60, 36)
    face = _poly(c, [(3, 14), (9, 10), (51, 10), (57, 14), (55, 31), (47, 34), (13, 34), (5, 31)])
    top = _poly(c, [(3, 14), (9, 8), (51, 8), (57, 14), (49, 17), (11, 17)])
    noise = pa.value_noise(36, 60, 4, rng)
    c.paint(face, st["rock"], 0.22 + 0.22 * (c.yy < 22) + 0.2 * (noise - 0.5) - 0.1 * (c.yy - 17) / 17, contrast=2.0, dither=False)
    for x in (18, 31, 43):  # splits in the front
        c.paint(c.rect(x, 18, x + 1, 33) & face, st["rock"], 0.04, dither=False)
        c.paint(c.rect(x + 1, 18, x + 2, 30) & face, st["rock"], 0.6, dither=False)
    c.paint(top, st["rock"], 0.82 + 0.1 * (noise - 0.5) - 0.12 * (c.yy - 8) / 9, contrast=2.0, dither=False)
    c.paint(c.ellipse(30, 12.5, 14, 2.6) & top, st["rock"], 0.97, dither=False)  # the worn middle
    c.paint(top & (pa.value_noise(36, 60, 2.4, rng) > 0.74), LICHEN, 0.5, dither=False)
    c.paint(face & (pa.value_noise(36, 60, 2.4, rng) > 0.76) & (c.yy < 26), LICHEN, 0.35, dither=False)
    c.fill(c.rect(24, 29, 25, 34), st["grass"][3])  # grass in a crack at the foot
    c.fill(c.rect(26, 31, 27, 34), st["grass"][2])
    c.paint(c.ellipse(30, 34, 28, 2.0) & ~c.a, st["rock"], 0.2, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- catalog
def build(ms):
    """Registers the sprites of Act V in the catalog (no light anywhere). What the map places under `if`/`unless`, what stands
    on the cells of the road's older stamp (the chalk arrow, the road's cairns) and what G2 may take away (the fall of rock)
    has no catalog shadow, so that no shadow is baked under something that may be gone (or into a stamp that must not change)."""
    cairn_shape = {"circle": 4, "offset": [0, -1]}
    ms.save("tal", "gb_cairn_a", cairn(ms, "a", 1801), (9, 18), shape=cairn_shape, shadow=[7, 2])
    ms.save("tal", "gb_cairn_b", cairn(ms, "b", 1802), (9, 26), shape=cairn_shape, shadow=[7, 2])
    ms.save("tal", "gb_cairn_c", cairn(ms, "c", 1803), (9, 34), shape=cairn_shape, shadow=[7, 2])
    ms.save("tal", "gb_cairn_road", cairn(ms, "b", 1804), (9, 26), shape=cairn_shape)  # the road's: it stands on the road's stamp
    ms.save("tal", "gb_boulder", [boulder(ms, 1811), boulder(ms, 1812)], (19, 26), shape={"rect": [30, 8], "offset": [0, -3]},
            shadow=[17, 4])
    ms.save("tal", "gb_scree", [scree(ms, 1821 + k) for k in range(3)], (22, 9), flat=True)
    ms.save("tal", "gb_rockfall", rockfall(ms), (48, 40))
    ms.save("tal", "gb_steps", steps(ms), (24, 32), flat=True)
    ms.save("tal", "gb_planks", planks(ms), (40, 8), flat=True)
    ms.save("tal", "gb_sign_trail", trail_sign(ms), (15, 42), shape={"circle": 3, "offset": [0, -1]}, shadow=[7, 2])
    ms.save("tal", "gb_slate", slate_chip(ms), (10, 7), flat=True)
    ms.save("tal", "gb_iron_ring", iron_ring(ms), (11, 26))
    ms.save("tal", "gb_arrow_chalk", chalk_arrow(ms), (13, 10), flat=True)
    ms.save("tal", "gb_net_post", net_post(ms), (8, 34), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "gb_net_branch", net_branch(ms), (15, 36), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "gb_stone_mark", stone_mark(ms), (12, 8), flat=True)
    ms.save("tal", "gb_smoke", smoke(ms), (8, 166), flat=True)
    ms.save("tal", "gb_lookout", lookout(ms), (30, 30), shape={"rect": [48, 8], "offset": [0, -4]}, shadow=[26, 5])


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [cairn(ms, "a", 1801), cairn(ms, "b", 1802), cairn(ms, "c", 1803), boulder(ms, 1811), boulder(ms, 1812)]
    items += [scree(ms, 1821), scree(ms, 1822), scree(ms, 1823), slate_chip(ms), chalk_arrow(ms), stone_mark(ms)]
    items += [net_post(ms), net_branch(ms), iron_ring(ms), trail_sign(ms), steps(ms), planks(ms), lookout(ms), rockfall(ms), smoke(ms)]
    sheet = Image.new("RGBA", (760, 200), (96, 136, 88, 255))
    x = 6
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        if x + img.width > 750:
            break
        sheet.alpha_composite(img, (x, 196 - img.height if img.height < 196 else 0))
        x += img.width + 6
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    else:
        sys.exit("usage: akt5_props.py --preview out.png")
