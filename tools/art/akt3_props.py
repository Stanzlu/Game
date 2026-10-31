"""Props for Act III (docs/akt3/REGIONSBRIEFE.md), drawn like make_sprites.py and registered in the same
catalog (style "tal", so they share the atlas of the valley; the forest of the real world is the valley's
palette with taller trees). Called from make_sprites.build(); `--preview out.png` draws them on one sheet (2x).

Waldweg (W2): the tall forest (spruce and beech, a trunk and a high crown so that the path below stays in
view), the hermit's hut seen from the front (its door is wired by W3: a latch and no lock, Bible §14), a trunk
to sit on and a ring of stones with a kettle (the Rastplatz), the Antreiber's way markers (a post and a board
with a stripe of his faded red), a mossy stone and a fern. No prop here has a light: the forest builds no
PointLight2D before the first night map of the city (Plan 7).

Hut (W3): the hermit's room from inside (style "haus", the warm cabin of the valley, a smaller one: a plain
wooden room, a stove, a bare table, a bed under a wool blanket, a flute on pegs, one clean cup on a nail,
a window that always shows the same dusk), the open door that lies over the closed one, and three things
outside: a cup on a flat stone, branches across the spur, a clothesline with nothing on it.

Flood clearing (W4): the water line on beeches and a mark, the drowned camp, the blanket, one runner's trail, a nest,
a fork, driftwood and stepping stones.

Night wood (W5): glow trees, the lantern with its ring of light, a glowing log. Nothing here is a light: the glow is
baked into the emissive layer (drawn above the night tint, unshaded), like the mushrooms and wd_rest_lit.
"""
import os
import sys

import numpy as np

import pixelart as pa
import slice_props
from pixelart import ramp

BEECH_BARK = ramp("#2c2a29", "#4a4743", "#726d63", "#9a9486", "#c2baa6")
ANTREIBER_RED = ramp("#3e1214", "#6a1e1c", "#9a3426", "#c85a3a")
SHINGLE = ramp("#2a2018", "#42301f", "#5e4429", "#7e5c38")
MOSS = ramp("#16261a", "#22382a", "#33503a", "#4a6c46")
FERN = ramp("#173020", "#22452a", "#315f34", "#467c3e", "#6a9a48")
# the hut inside: one dusk that never changes in the window, clay, undyed wool, pale flute wood, light iron
DUSK_SKY = ramp("#1a2036", "#2e3a58", "#56627e", "#8f8a94", "#d29a72")
DUSK_TREES = ramp("#080e0c", "#0f1814", "#18251e", "#243529")
CLAY = ramp("#3e2416", "#6e422a", "#a06a3e", "#cc975c", "#ecc88e")
WOOL = ramp("#3a3026", "#5c4c3a", "#80684c", "#a28864", "#c4a982")
FLUTE_WOOD = ramp("#4a3018", "#7a5430", "#b08450", "#dcb678", "#f4dca4")
BRIGHT_IRON = ramp("#1e1e22", "#3a3c42", "#62666e", "#9aa0a8")
CORD = ramp("#4a4234", "#7a6e56", "#a89a7a", "#cfc29e")
TWIG_WOOD = ramp("#2a231d", "#463b30", "#6a5a46", "#8f7d62", "#b3a283")


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


def beech(ms, seed, mark=None, bark=BEECH_BARK):
    """Hochwald beech: long pale smooth trunk, three limbs, one high crown; 96 x 128, anchor (48, 124).
    `mark(c, centre_of_y, base)` (optional, draws without random numbers of the tree) lays something over the
    finished tree before the outline: the flood line of the Flutlichtung (flood_beech), the glow of the night wood
    (glow_tree). `bark` is the ramp of trunk, roots and limbs (the glow trees have a dark one)."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(96, 128)
    cx, base = 48, 125
    lean = rng.uniform(-2, 2)
    for side in (-1, 1):
        root = ms.limb_mask(c, cx + side * 2, base - 6, cx + side * rng.uniform(7, 10), base, 4)
        c.paint(root, bark, 0.2 + 0.5 * c.cylinder(cx - 12, cx + 12), contrast=3.0, dither=False)
    trunk = np.zeros((c.h, c.w), bool)
    for y in range(58, base):
        t = (base - y) / (base - 58)
        x = cx + lean * t
        half = 4.2 * (1 - 0.25 * t)
        trunk[y, int(round(x - half)):int(round(x + half)) + 1] = True
    grain = pa.value_noise(c.h, c.w, (10, 1), rng)
    c.paint(trunk, bark, 0.15 + 0.7 * c.cylinder(cx + lean / 2 - 6, cx + lean / 2 + 6) + 0.1 * (grain - 0.5),
            contrast=2.6, dither=False)
    c.paint(trunk & (c.yy > base - 18) & (pa.value_noise(c.h, c.w, 3, rng) > 0.55) & (c.xx < cx + lean), MOSS, 0.55,
            dither=False)
    subs = []
    for k, a in enumerate((-2.5, -1.57, -0.65)):
        d = rng.uniform(20, 30)
        sx, sy = cx + lean + np.cos(a) * d * 1.3, 40 + np.sin(a) * d * 0.5 + 8
        limb = ms.limb_mask(c, cx + lean, 62, sx, sy + 4, 4)
        c.paint(limb, bark, 0.3 + 0.4 * c.cylinder(sx - 3, sx + 3), contrast=3.0, dither=False)
        subs.append((sy, sx, rng.uniform(15, 19)))
    subs.append((30, cx + lean, 21))
    blobs = []
    for sy, sx, r in subs:
        for _ in range(4):
            blobs.append((sy + rng.uniform(-r * .3, r * .3), sx + rng.uniform(-r * .35, r * .35), r * rng.uniform(.62, .82)))
    alpha, value = pa.render_foliage((c.h, c.w), blobs, rng, small=(3.4, 5.2))
    c.paint(alpha, st["foliage_blue" if seed % 2 else "foliage"], value, contrast=3.0, dither=False)
    if mark is not None:
        mark(c, lambda y: cx + lean * (base - y) / (base - 58), base)
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


# --------------------------------------------------------------------------- the hut inside (W3)
HUT_W, HUT_H = 224, 160  # the room: 14 x 10 cells; the walls are the cells 0 and 13, the back wall rows 0 to 2


def hut_shell(ms):
    """The hermit's room seen from the front, lying under everything (the floor is baked from the map):
    the back wall of logs with a shelf (a flute rests on two pegs), a window with one fixed dusk (two trunks),
    a nail with one clean cup; the side walls as dark timber; the front wall with a closed plank door
    (room column 3) and beside it an iron bolt that hangs loose (column 4). 224 x 160, anchor (8, 8)."""
    rng = np.random.default_rng(411)
    logs_ramp, beam = slice_props.LOGS, slice_props.BEAM
    c = ms.Canvas(HUT_W, HUT_H)
    top, bottom = 8, 48
    xl, xr = 10, HUT_W - 10
    # back wall: five rows of round logs, lit from above, darker towards the floor
    wall = c.rect(xl, top, xr, bottom)
    row = ((c.yy - top) // 8).astype(int)
    ry = (c.yy - top) % 8
    grain = pa.value_noise(HUT_H, HUT_W, (2, 14), rng)
    v = 0.62 - 0.45 * (ry / 7.0) ** 1.6 + 0.12 * (grain - 0.5) - 0.05 * row
    v = np.where(ry == 7, 0.04, v)
    c.paint(wall, logs_ramp, v, contrast=2.0)
    cracks = wall & (pa.value_noise(HUT_H, HUT_W, (1, 6), rng) > 0.87) & (ry > 1) & (ry < 6)
    c.paint(cracks, logs_ramp, 0.12, dither=False)
    for cx in (12, HUT_W - 12):  # log ends in the corners
        for k in range(5):
            m = c.ellipse(cx, top + 4 + k * 8, 4, 3.8)
            c.paint(m, logs_ramp, 0.35 + 0.45 * c.sphere(cx - 1, top + 3 + k * 8, 4, 4), dither=False)
            c.paint(m & c.ellipse(cx, top + 4 + k * 8, 1.6, 1.4), logs_ramp, 0.25, dither=False)
    # baseboard shadow where the wall meets the floor
    c.paint(c.rect(xl, bottom, xr, bottom + 3), beam, np.where(c.yy < bottom + 1, 0.2, 0.5), dither=False)
    c.a[(c.yy >= bottom + 1) & (c.yy < bottom + 3) & (c.xx >= xl) & (c.xx < xr)] = True
    # the beam along the wall top, the dark of the loft above it
    c.paint(c.rect(0, 0, HUT_W, top - 4), beam, 0.05, dither=False)
    c.paint(c.rect(4, top - 4, HUT_W - 4, top), beam, np.where(c.yy < top - 2, 0.75, 0.4), dither=False)
    # the window (room column 4): glass 16 wide, one dusk, two trunks, a bar across and one down. Never changes.
    wx0, wx1, wy0, wy1 = 64, 80, 14, 34
    c.paint(c.rect(wx0 - 3, wy0 - 3, wx1 + 3, wy1 + 3), beam, 0.6, dither=False)
    pane = c.rect(wx0, wy0, wx1, wy1)
    t = np.clip((c.yy - wy0) / (wy1 - wy0), 0, 1)
    c.paint(pane, DUSK_SKY, 0.28 + 0.78 * t ** 1.15, contrast=1.7, dither=True)
    ridge = 0.8 + 0.05 * np.sin(c.xx * 1.1) + 0.04 * np.sin(c.xx * 2.3 + 1.0)
    c.paint(pane & (t > ridge), DUSK_TREES, 0.25, dither=False)
    for x0, x1, lit in ((66, 69, 0.5), (75, 78, 0.4)):  # the two trunks, bare and dark
        c.paint(c.rect(x0, wy0, x1, wy1), DUSK_TREES, np.where(c.xx < x0 + 1, lit, 0.1), dither=False)
    c.paint(c.rect(69, 19, 71, 20) | c.rect(77, 26, 79, 27), DUSK_TREES, 0.1, dither=False)  # a stub each
    c.paint(c.rect(71, wy0, 73, wy1), beam, 0.55, dither=False)
    c.paint(c.rect(wx0 - 5, wy1 + 2, wx1 + 5, wy1 + 5), logs_ramp, np.where(c.yy < wy1 + 3, 0.7, 0.35), dither=False)
    # the shelf (room column 2): a board on two brackets, a bowl and a tin on it
    c.paint(c.rect(27, 17, 53, 20), logs_ramp, np.where(c.yy < 18, 0.95, 0.55), dither=False)
    for bx in (30, 49):
        c.paint(c.rect(bx, 20, bx + 2, 23), logs_ramp, 0.3, dither=False)
    bowl = c.ellipse(34, 15.5, 4.2, 3.0) & (c.yy >= 14)
    c.paint(bowl, CLAY, 0.25 + 0.6 * c.sphere(33, 14, 4.5, 3.4), dither=False)
    jar = ramp("#2a3438", "#46585c", "#6a8286", "#9ab4b8")
    c.paint(c.rect(44, 12, 50, 17), jar, 0.25 + 0.6 * c.cylinder(44, 50), dither=False)
    c.paint(c.rect(44, 11, 50, 13), slice_props.LOGS, 0.7, dither=False)
    # the flute lies on two wooden pegs under the shelf: pale wood, four holes, a darker mouthpiece
    for px in (33, 47):
        c.paint(c.rect(px, 30, px + 2, 35), logs_ramp, np.where(c.xx == px, 0.6, 0.25), dither=False)
    flute = c.rect(28, 28, 52, 32)
    c.paint(flute, FLUTE_WOOD, np.where(c.yy < 29, 0.85, np.where(c.yy < 31, 0.6, 0.3)), dither=False)
    c.paint(c.rect(28, 28, 32, 32), FLUTE_WOOD, np.where(c.yy < 29, 0.5, 0.22), dither=False)
    c.fill(c.rect(32, 29, 33, 31), np.array([34, 22, 14], np.float32))  # the window of the whistle
    for hx in (38, 42, 46, 50):
        c.fill(c.rect(hx, 29, hx + 1, 30), np.array([42, 28, 18], np.float32))
    # the nail (room column 6) with one small clean cup hanging by its handle: pale, smooth, never used
    c.paint(c.rect(106, 20, 109, 22), BRIGHT_IRON, 0.85, dither=False)  # the head of the nail
    c.paint(c.rect(107, 22, 108, 23), BRIGHT_IRON, 0.45, dither=False)
    cup = c.rect(99, 24, 106, 32) & ~((c.yy > 30) & ((c.xx < 100) | (c.xx > 104)))
    c.paint(cup, CLAY, 0.6 + 0.4 * c.cylinder(98, 107) - 0.1 * np.clip((c.yy - 24) / 8.0, 0, 1), dither=False)
    c.paint(c.rect(99, 24, 106, 25), CLAY, 0.95, dither=False)  # the rim
    c.paint(c.rect(100, 26, 101, 29), CLAY, 0.98, dither=False)  # a single streak of light on the glaze
    c.paint(c.rect(106, 22, 109, 23) | c.rect(108, 23, 109, 28) | c.rect(106, 27, 109, 28), CLAY, 0.45, dither=False)  # the handle
    # one bundle of herbs under the beam, the way a hermit keeps them
    for hx in (124, 134):
        c.fill(c.rect(hx, top - 2, hx + 1, top + 4), np.array([150, 130, 96], np.float32))
        bunch = c.ellipse(hx + 0.5, top + 9, 3.0, 5.0) & (c.yy >= top + 4)
        herb = ramp("#1e3a1c", "#2f5a2a", "#4c7c3a", "#74a052") if hx == 124 else ramp("#4a4214", "#7a6c20", "#a89434", "#d2bc56")
        c.paint(bunch, herb, 0.3 + 0.5 * c.sphere(hx - 1, top + 7, 3.5, 5), dither=False)
    # side walls: timber seen from above, one lit from the window side, one in shade
    for x0, x1, face, lit in ((0, 12, (4, 9), 0.7), (HUT_W - 12, HUT_W, (HUT_W - 9, HUT_W - 4), 0.5)):
        c.paint(c.rect(x0, top, x1, HUT_H), beam, 0.05, dither=False)
        edge = 10 if x0 == 0 else HUT_W - 12
        c.paint(c.rect(face[0], top, face[1], HUT_H - 4),
                beam, lit - 0.3 * np.clip((c.yy - top) / (HUT_H - 16.0 - top), 0.0, 1.0), dither=False)
        c.paint(c.rect(edge, top, edge + 2, HUT_H - 4), beam, 0.3, dither=False)
    # the front wall (the last row, y 144 to 160): a lit cap, a face of logs, and the closed plank door
    fy = HUT_H - 16
    front = c.rect(4, fy, HUT_W - 4, HUT_H)
    c.paint(front, beam, np.where(c.yy < fy + 3, 0.8, 0.05), dither=False)
    face = c.rect(4, fy + 3, HUT_W - 4, HUT_H - 3)
    fv = 0.34 - 0.08 * ((c.yy - fy - 3) % 7 == 6) + 0.08 * (grain - 0.5)
    c.paint(face, logs_ramp, np.where(((c.yy - fy - 3) % 7) == 6, 0.06, fv + 0.1), contrast=2.0)
    dx0, dx1 = 48, 64  # the doorway: room column 3
    c.paint(c.rect(dx0 - 2, fy, dx0, HUT_H), beam, 0.6, dither=False)  # posts
    c.paint(c.rect(dx1, fy, dx1 + 2, HUT_H), beam, 0.6, dither=False)
    c.paint(c.rect(dx0 - 2, fy, dx1 + 2, fy + 3), beam, 0.8, dither=False)  # lintel
    leaf = c.rect(dx0, fy + 3, dx1, HUT_H - 1)
    plank = ((c.xx - dx0) // 4).astype(int)
    pv = 0.5 + 0.08 * (((plank * 7 + 3) % 5) / 4.0 - 0.5) + 0.16 * (grain - 0.5)
    pv = np.where(((c.xx - dx0) % 4) == 3, 0.1, np.where(((c.xx - dx0) % 4) == 0, pv + 0.1, pv))
    c.paint(leaf, logs_ramp, pv, dither=False)
    for sy in (fy + 5, fy + 12):  # two strap hinges and a plain latch bar, no lock
        c.paint(c.rect(dx0, sy, dx0 + 7, sy + 2), BRIGHT_IRON, 0.65, dither=False)
    c.paint(c.rect(dx1 - 6, fy + 9, dx1 - 1, fy + 11), BRIGHT_IRON, 0.75, dither=False)
    c.paint(c.rect(dx1 - 3, fy + 11, dx1 - 1, fy + 13), logs_ramp, 0.85, dither=False)
    # the bolt beside it (room column 4): a plate with two rivets on the wall and a bar that hangs loose from
    # its end, pointing down, with a little foot: it is not shot, the door is only closed
    c.paint(c.rect(67, fy + 4, 74, fy + 7), BRIGHT_IRON, np.where(c.yy < fy + 5, 0.9, 0.55), dither=False)
    c.fill(c.rect(68, fy + 5, 69, fy + 6) | c.rect(72, fy + 5, 73, fy + 6), np.array([24, 22, 26], np.float32))
    c.paint(c.rect(72, fy + 7, 74, fy + 14), BRIGHT_IRON, np.where(c.xx < 73, 0.95, 0.6), dither=False)
    c.paint(c.rect(70, fy + 12, 72, fy + 14), BRIGHT_IRON, 0.75, dither=False)
    return c


def hut_stove(ms):
    """A small iron stove against the back wall: a pipe up into the loft, a kettle for tea on the plate, a fire
    door with a glowing slit, a few split logs beside it. Returns (canvas, glow); 44 x 56, anchor (22, 52)."""
    rng = np.random.default_rng(421)
    st = pa.STYLES["tal"]
    c = ms.Canvas(44, 56)
    e = ms.Canvas(44, 56)
    iron = BRIGHT_IRON
    # the pipe, with a collar where it meets the loft
    pipe = c.rect(26, 0, 31, 30)
    c.paint(pipe, iron, 0.2 + 0.7 * c.cylinder(26, 31), dither=False)
    c.paint(c.rect(25, 12, 32, 14), iron, 0.55, dither=False)
    c.paint(c.rect(25, 0, 32, 2), iron, 0.4, dither=False)
    # the body: a box with a lit top plate, rounded by a cylinder light across it
    body = c.rect(8, 31, 36, 48)
    c.paint(c.rect(7, 27, 37, 32), iron, 0.82, dither=False)  # the top plate
    c.paint(c.rect(7, 31, 37, 32), iron, 0.35, dither=False)
    c.paint(body, iron, 0.18 + 0.55 * c.cylinder(6, 38) + 0.06 * (pa.value_noise(56, 44, 3, rng) - 0.5), dither=False)
    c.paint(c.rect(8, 45, 36, 48), iron, 0.12, dither=False)
    # the fire door: a frame, a glowing slit with bars, a handle
    c.paint(c.rect(12, 34, 27, 45), iron, 0.1, dither=False)
    flame = ramp("#6a1a08", "#c0400e", "#f08020", "#ffc040", "#fff0a0")
    slit = c.rect(14, 36, 25, 42)
    heat = np.clip(1 - (c.yy - 36) / 6.0 + 0.25 * (pa.value_noise(56, 44, 2, rng) - 0.5), 0, 1)
    c.paint(slit, flame, 0.25 + 0.7 * heat, dither=False)
    e.paint(slit, flame, 0.25 + 0.7 * heat, dither=False)
    for bx in (17, 21):
        c.paint(c.rect(bx, 36, bx + 1, 42), iron, 0.15, dither=False)
        e.a[36:42, bx] = False  # the bars do not glow
    c.paint(c.rect(27, 38, 30, 41), iron, 0.7, dither=False)  # the handle
    c.paint(c.rect(30, 34, 35, 45), iron, 0.08, dither=False)  # a vent in the side
    for vy in (36, 39, 42):
        c.paint(c.rect(31, vy, 35, vy + 1), iron, 0.3, dither=False)
    for lx in (10, 31):  # legs
        c.paint(c.rect(lx, 48, lx + 3, 52), iron, np.where(c.xx == lx, 0.5, 0.15), dither=False)
    # the kettle for tea on the plate: dented iron, a spout, a lid with a knob, the handle over it
    kettle = c.ellipse(15, 22, 6.0, 5.0) & (c.yy <= 27)
    c.paint(kettle, iron, 0.2 + 0.75 * c.sphere(13, 20, 6, 5), dither=False)
    c.paint(c.rect(8, 18, 10, 21) | c.rect(7, 16, 9, 19), iron, 0.5, dither=False)  # spout
    c.paint(c.rect(12, 15, 18, 17), iron, 0.6, dither=False)  # lid
    c.paint(c.rect(14, 13, 16, 15), iron, 0.85, dither=False)  # knob
    handle = (np.abs(np.hypot(c.xx + 0.5 - 15, (c.yy + 0.5 - 20) * 1.15) - 6.2) < 0.7) & (c.yy < 19)
    c.paint(handle, iron, 0.7, dither=False)
    # split logs on the floor beside it
    for k, y in enumerate((50.0, 46.0, 42.0)):
        for j in range(2 - (k == 2)):
            x0 = 35 + j * 0.5 + (k % 2)
            m = c.rect(x0, y - 2, x0 + 6, y + 1.5)
            c.paint(m, slice_props.LOGS, 0.4 + 0.3 * (1 - (c.yy - (y - 2)) / 3.5), dither=False)
            c.paint(c.ellipse(x0 + 6, y - 0.25, 1.5, 1.8), slice_props.LOGS, 0.85, dither=False)
    c.outline(st["outline"])
    return c, e


def hut_table(ms):
    """A rough table with a drawer and nothing on it (the table of the house has a cup painted on): a plain
    top, worn pale where hands rest. 44 x 30, anchor (22, 24)."""
    rng = np.random.default_rng(431)
    st = pa.STYLES["tal"]
    logs_ramp = slice_props.LOGS
    c = ms.Canvas(44, 30)
    grain = pa.value_noise(30, 44, (1, 8), rng)
    for lx in (8, 31):
        c.paint(c.rect(lx, 14, lx + 3, 26), logs_ramp, np.where(c.xx == lx, 0.6, 0.3), dither=False)
    c.paint(c.rect(6, 4, 38, 14), logs_ramp, 0.52 + 0.25 * (1 - (c.yy - 4) / 10) + 0.12 * (grain - 0.5), contrast=2.0)
    c.paint(c.rect(6, 4, 38, 5), logs_ramp, 0.9, dither=False)  # the lit front edge of the top
    c.paint(c.rect(6, 14, 38, 17), logs_ramp, 0.22, dither=False)
    c.paint(c.rect(18, 14, 26, 17), logs_ramp, 0.4, dither=False)  # drawer
    c.fill(c.rect(21, 15, 23, 16), np.array([140, 120, 80], np.float32))
    c.outline(st["outline"])
    return c


def hut_bed(ms):
    """A narrow bed against the wall under one plain wool blanket (the house has a quilt), a flat pillow, the
    blanket turned down at the head. 30 x 44, anchor (15, 40)."""
    rng = np.random.default_rng(433)
    st = pa.STYLES["tal"]
    logs_ramp = slice_props.LOGS
    c = ms.Canvas(30, 44)
    c.paint(c.rect(1, 2, 29, 42), logs_ramp, np.where((c.xx < 3) | (c.xx > 26), 0.55, 0.3), dither=False)
    c.paint(c.rect(4, 4, 26, 12), ramp("#8a8678", "#b4b0a0", "#d8d4c4", "#f2eedc"), 0.5 + 0.35 * c.sphere(12, 6, 12, 6),
            dither=False)
    blanket = c.rect(3, 12, 27, 40)
    folds = pa.value_noise(44, 30, (3, 12), rng)  # soft folds across the bed
    c.paint(blanket, WOOL, 0.5 + 0.2 * (folds - 0.5) + 0.2 * (1 - (c.yy - 12) / 28) - 0.06 * c.cylinder(2, 28), dither=False)
    c.paint(c.rect(3, 12, 27, 16), WOOL, np.where(c.yy < 14, 0.9, 0.68), dither=False)  # turned down at the head
    c.paint(c.rect(3, 33, 27, 35), WOOL, 0.2, dither=False)  # a dark stripe at the foot
    c.paint(c.rect(3, 36, 27, 37), WOOL, 0.2, dither=False)
    c.outline(st["outline"])
    return c


def hut_door_open(ms):
    """The doorway of the front wall with the leaf swung inward, lying over the closed door of the shell: the
    dusk outside in the opening, the leaf as a narrow slab of planks at the hinge, and a warm spill of light on
    the ground outside. 16 x 32, anchor (8, 24): the top half is the doorway cell, the bottom the row below."""
    rng = np.random.default_rng(435)
    st = pa.STYLES["tal"]
    logs_ramp, beam = slice_props.LOGS, slice_props.BEAM
    c = ms.Canvas(16, 32)
    opening = c.rect(0, 3, 16, 15)
    t = np.clip((c.yy - 3) / 12.0, 0, 1)
    c.paint(opening, DUSK_SKY, 0.3 + 0.7 * t ** 1.1, contrast=1.7, dither=True)
    ridge = 0.62 + 0.12 * np.sin(c.xx * 1.3 + 0.5) + 0.06 * np.sin(c.xx * 2.9)
    c.paint(opening & (t > ridge), DUSK_TREES, 0.3 + 0.4 * t, dither=False)  # the forest beyond, one dark edge
    c.paint(c.rect(0, 13, 16, 15), ramp("#2a2a1c", "#46422a", "#6a5e3a"), 0.4 + 0.3 * (c.xx > 6), dither=True)  # the path
    leaf = c.rect(0, 3, 5, 16) & (c.xx < 5 - (c.yy - 3) * 0.12)
    plank = ((c.yy - 3) // 4).astype(int)
    c.paint(leaf, logs_ramp, np.where(((c.yy - 3) % 4) == 3, 0.1, 0.42 + 0.05 * (plank % 2)), dither=False)
    c.paint(c.rect(4, 3, 5, 15), logs_ramp, 0.8, dither=False)  # the lit edge of the leaf
    c.paint(c.rect(0, 3, 16, 5), beam, 0.8, dither=False)  # the lintel stays
    # the spill: warm light fanning out over the ground outside, fading into the dark (no hard edge: what is
    # too dim is left out and the black of the map shows)
    d = np.clip((c.yy - 16) / 15.0, 0, 1)
    half = 5.5 + 2.8 * d
    across = np.abs(c.xx + 0.5 - 9.5) / half
    value = 0.98 - 0.98 * d ** 0.7 - 0.2 * across
    spill = c.rect(0, 16, 16, 32) & (across <= 1) & (value > 0.12)
    glow = ramp("#1a1008", "#4a2c12", "#9a6224", "#e0a850", "#f6d890")
    c.paint(spill, glow, np.clip(value, 0, 1), dither=True)
    c.paint(c.rect(0, 15, 16, 16), beam, 0.1, dither=False)
    return c


def hut_cup(ms):
    """A clay cup with something dark and hot in it, standing on a flat stone beside the door; 16 x 12, anchor (8, 10)."""
    rng = np.random.default_rng(441)
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 12)
    stone = c.ellipse(8, 9, 7.6, 2.6)
    c.paint(stone, st["stone"], 0.35 + 0.5 * c.sphere(6, 7.5, 8, 3) + 0.08 * (pa.value_noise(12, 16, 3, rng) - 0.5),
            contrast=2.0)
    cup = c.rect(5, 3, 11, 9) & ~((c.yy > 7) & ((c.xx < 6) | (c.xx > 9)))
    c.paint(cup, CLAY, 0.4 + 0.55 * c.cylinder(4, 12), dither=False)
    c.paint(c.ellipse(8, 3.6, 3.0, 1.1), ramp("#1c120c", "#3a2416", "#5c3a20"), 0.65, dither=False)  # the tea
    c.paint(c.rect(11, 4, 13, 5) | c.rect(12, 5, 14, 7) | c.rect(11, 7, 13, 8), CLAY, 0.45, dither=False)  # handle
    c.outline(st["outline"])
    return c


def hut_pipe(ms):
    """The elder pipe lying on the window sill: a pale piece of pipe wood with one hole and a darker underside;
    14 x 4, drawn by the map from the next cell (anchor (23, 7)) so that it lies on the sill of the window in column 4."""
    c = ms.Canvas(14, 4)
    c.paint(c.rect(0, 0, 14, 3), FLUTE_WOOD, np.where(c.yy < 1, 0.9, 0.62), dither=False)
    c.paint(c.rect(0, 2, 14, 3), FLUTE_WOOD, 0.3, dither=False)
    c.fill(c.rect(8, 1, 9, 2), np.array([42, 28, 18], np.float32))  # the one hole
    return c


def hut_branches(ms):
    """A few branches lying across the spur: weathered grey-brown, one forked, a twig or two, a little moss
    where they touch the ground; flat, 48 x 14, anchor (24, 7)."""
    rng = np.random.default_rng(443)
    st = pa.STYLES["tal"]
    c = ms.Canvas(48, 14)
    moss = ramp("#16261a", "#22382a", "#33503a")

    def limb(x0, y0, x1, y1, r):
        steps = int(max(abs(x1 - x0), abs(y1 - y0))) * 2
        mask = np.zeros((c.h, c.w), bool)
        for i in range(steps + 1):
            k = i / steps
            mask |= c.ellipse(x0 + (x1 - x0) * k, y0 + (y1 - y0) * k + 0.5 * np.sin(k * 4 + x0), r, r)
        return mask

    grain = pa.value_noise(14, 48, (1, 5), rng)
    # lower branches first: the long one across, a second one crossing it, a forked one on top, twigs
    parts = [(1.5, 10, 40.5, 8, 1.6), (6, 3.5, 45.5, 10.5, 1.3), (16, 12, 34, 4.5, 1.1),
             (30, 7.6, 37, 2.2, 0.8), (10, 6, 14, 2, 0.7), (24, 9.4, 28, 12.6, 0.7)]
    for x0, y0, x1, y1, r in parts:
        mask = limb(x0, y0, x1, y1, r)
        near = mask | np.roll(mask, 1, 0) | np.roll(mask, -1, 0) | np.roll(mask, 1, 1) | np.roll(mask, -1, 1)
        c.fill(near & c.a & ~mask, TWIG_WOOD[0])  # a dark seam where it lies over an older branch
        along = (c.xx + 0.5 - x0) / max(abs(x1 - x0), 1.0)
        centre = y0 + (y1 - y0) * np.clip(along, 0, 1)
        lit = np.clip(0.7 - (c.yy + 0.5 - centre) / (r + 0.6) * 0.4, 0.3, 1.0)  # lit from above
        c.paint(mask, TWIG_WOOD, lit + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(c.rect(1, 9, 8, 12) & c.a & (pa.value_noise(14, 48, 2, rng) > 0.55), moss, 0.45, dither=False)
    c.paint(c.rect(34, 8, 46, 12) & c.a & (pa.value_noise(14, 48, 2, rng) > 0.6), moss, 0.4, dither=False)
    c.outline(st["outline"])
    return c


def hut_line(ms):
    """A clothesline between two posts with wooden pegs at even spacing and nothing on it; 48 x 28, anchor (24, 26)."""
    rng = np.random.default_rng(445)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 28)
    for px in (3, 41):
        post = c.rect(px, 3, px + 4, 27)
        c.paint(post, ex["plank"], np.where(c.xx < px + 1, 0.8, np.where(c.xx > px + 2, 0.22, 0.52))
                + 0.1 * (pa.value_noise(28, 48, (6, 1), rng) - 0.5), dither=False)
        c.paint(c.rect(px - 1, 3, px + 5, 5), ex["plank"], 0.7, dither=False)  # a worn top
        c.paint(c.ellipse(px + 2, 26.5, 5, 1.6), st["stone"], 0.35, dither=False)  # the foot, a few stones
    xs = np.arange(7, 41)

    def sag(x):
        return 8.0 + 3.4 * (1 - ((x - 23.5) / 17.0) ** 2)

    for x in xs:
        y = int(round(sag(x)))
        c.fill(c.rect(x, y, x + 1, y + 1), CORD[2])
        if x % 2 == 0:
            c.fill(c.rect(x, y + 1, x + 1, y + 2), CORD[1])
    for x in (10, 15, 20, 25, 30, 35):  # pegs at even spacing, open end down
        y = int(round(sag(x + 0.5)))
        c.paint(c.rect(x, y - 1, x + 2, y + 5), ex["plank"], np.where(c.xx == x, 0.75, 0.4), dither=False)
        c.fill(c.rect(x, y + 3, x + 2, y + 4), np.array([30, 22, 16], np.float32))
        c.fill(c.rect(x, y + 4, x + 1, y + 5), ex["plank"][0])
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the flood clearing (W4)
# One water line for everything on the clearing: it stands FLOOD_LINE_ABOVE_FOOT pixels over the foot (the anchor)
# of every trunk, post and stake, higher than a head (the player is about 26 px tall). Below it a crust of dry silt
# and a veil of silt that gets darker towards the roots; the line itself is the crust's top edge, 4 px thick.
# Nothing here glows, nothing here has a light; the only red is the Antreiber's chalk (ANTREIBER_RED) and only in
# one 1 px stripe, on the hem of the blanket.
FLOOD_LINE_ABOVE_FOOT = 40
SILT = ramp("#4a3f32", "#6e6046", "#948564", "#b8a984", "#d6c9a6")
SILT_WET = ramp("#2a2018", "#3e3024", "#574634", "#725c44")
BLEACHED = ramp("#3a3733", "#6a665e", "#9a9588", "#c4bdab", "#e4dec9")
DRIED_STEM = ramp("#2e2a14", "#4a4420", "#6e6430", "#908442", "#b0a45c")
NEST_MOSS = ramp("#1c3018", "#2e4c26", "#46702e", "#6c9a40")


def flood_band(c, rng, xc_of, base, line, half=5.2, reach=12):
    """The flood line on a trunk: a crust of dried silt (4 px, the line itself), a veil of silt with a vertical grain
    below it, getting darker towards the roots (the last 6 px are wet), a sharp dark top edge, a few flecks over it,
    and flotsam caught at the edge (two twigs, a tuft of grass; the stream came from the left)."""
    grain = pa.value_noise(c.h, c.w, (9, 1), rng)
    near = np.abs(c.xx + 0.5 - np.vectorize(xc_of)(np.clip(c.yy, 0, c.h - 1))) <= reach
    below = c.a & (c.yy >= line) & near
    t = np.clip((c.yy - line) / max(base - line, 1), 0, 1)
    crust = below & (c.yy < line + 4)
    v = 0.46 + 0.44 * (grain - 0.5) - 0.22 * t
    c.paint(below, SILT, np.where(crust, 0.72 + 0.1 * (grain - 0.5), v), contrast=2.0, dither=False)
    wet = below & (c.yy > base - 6)
    c.paint(wet, SILT_WET, 0.5 - 0.25 * (c.yy - (base - 6)) / 6, dither=False)
    xc_edge = xc_of(line - 1)
    edge = c.a & (c.yy == line - 1) & (np.abs(c.xx + 0.5 - xc_edge) <= half)
    c.paint(edge, SILT, 0.0, dither=False)
    flecks = c.a & (c.yy == line - 2) & (rng.random((c.h, c.w)) > 0.72) & (np.abs(c.xx + 0.5 - xc_of(line - 2)) <= half - 0.7)
    c.paint(flecks, SILT, 0.35, dither=False)
    x0 = int(round(xc_of(line + 1) - half))
    c.fill(c.rect(x0 - 5, line, x0 + 1, line + 1), TWIG_WOOD[2])
    c.fill(c.rect(x0 - 3, line + 1, x0 + 1, line + 2), TWIG_WOOD[1])
    c.fill(c.rect(x0 - 2, line - 2, x0 + 1, line - 1), CORD[2])
    c.fill(c.rect(x0 - 4, line + 2, x0 - 1, line + 3), CORD[1])


def flood_beech(ms, seed):
    """A hochwald beech with the flood line on its trunk (the clearing's beeches all carry it at the same height);
    96 x 128, anchor (48, 124), line at y = 84. The tree itself is drawn exactly like wd_beech."""
    rng = np.random.default_rng(seed + 100)
    line = 124 - FLOOD_LINE_ABOVE_FOOT
    return beech(ms, seed, mark=lambda c, xc_of, base: flood_band(c, rng, xc_of, base, line))


def flood_mark(ms):
    """The flood mark: a dead trunk bleached grey and without a crown, broken off at the top in three splinters, one
    stub of a limb, the flood line (crust and veil) and ONE horizontal cut in the crust (a blade drawn once across
    the trunk, 10 px, a pale chip under it; no number, no date). 40 x 112, anchor (20, 108), line at y = 68."""
    rng = np.random.default_rng(761)
    st = pa.STYLES["tal"]
    c = ms.Canvas(40, 112)
    cx, base, top = 20, 109, 14
    line = 108 - FLOOD_LINE_ABOVE_FOOT

    def centre(y):
        return cx + 0.6 * np.sin(y * 0.21)

    trunk = np.zeros((c.h, c.w), bool)
    for y in range(top, base):
        t = (base - y) / (base - top)
        half = 5.6 * (1 - 0.3 * t) + (0.8 if y > base - 6 else 0)
        trunk[y, int(round(centre(y) - half)):int(round(centre(y) + half)) + 1] = True
    for dx, h in ((-3, 8), (2, 5), (4, 9)):  # the broken top: three splinters
        trunk[top - h + 3:top + 1, cx + dx - 1:cx + dx + 1] |= True
    grain = pa.value_noise(c.h, c.w, (12, 1), rng)
    c.paint(trunk, BLEACHED, 0.18 + 0.7 * c.cylinder(cx - 8, cx + 8) + 0.14 * (grain - 0.5), contrast=2.4, dither=False)
    cracks = trunk & (pa.value_noise(c.h, c.w, (6, 1), rng) > 0.8) & (c.xx > cx - 3)
    c.paint(cracks, BLEACHED, 0.1, dither=False)
    c.paint(ms.limb_mask(c, cx - 3, 40, cx - 11, 36, 4), BLEACHED, 0.55, dither=False)  # the stub of a limb
    flood_band(c, rng, centre, base, line, half=5.4, reach=9)
    # the cut: dark in the pale crust (rows line+2 and line+3), a lighter chip right under it, dark ends
    cut_y = line + 2
    c.paint(c.rect(cx - 5, cut_y, cx + 5, cut_y + 2), BLEACHED, 0.0, dither=False)
    c.paint(c.rect(cx - 4, cut_y + 2, cx + 4, cut_y + 3), BLEACHED, 1.0, dither=False)
    c.paint(c.rect(cx - 6, cut_y - 1, cx - 5, cut_y + 3) | c.rect(cx + 5, cut_y - 1, cx + 6, cut_y + 3), SILT, 0.1, dither=False)
    c.outline(st["outline"])
    return c


def flood_ring(ms):
    """The camp, drowned: a ring of stones with dried silt where the ash was (cracked like a dry bed), two stones
    washed out of the ring, a tripod of which two legs stand askew and the third lies across the silt, the empty
    hook still hanging at the crossing, the kettle on its side with half of it in the silt, its lid beside it.
    No ash, no embers. 40 x 36, anchor (16, 30)."""
    rng = np.random.default_rng(771)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(40, 36)
    ground = c.ellipse(16, 27.5, 9.6, 4.4)
    c.paint(ground, SILT, 0.42 + 0.3 * (pa.value_noise(36, 40, 3, rng) - 0.5), contrast=2.0, dither=False)
    # dried cracks: a long one across with two branches, 1 px lines in the dark of the silt
    for pts in (((8, 28), (11, 27), (14, 28), (17, 27), (20, 28), (24, 27)), ((14, 28), (13, 30), (14, 32)),
                ((17, 27), (18, 25), (17, 24)), ((20, 28), (21, 30))):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            n = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(n + 1):
                x, y = int(round(ax + (bx - ax) * i / n)), int(round(ay + (by - ay) * i / n))
                c.paint(c.rect(x, y, x + 1, y + 1) & ground, SILT, 0.12, dither=False)
    for k in range(9):
        a = k / 9 * 2 * np.pi
        r = 1.0 if k not in (2, 6) else 1.5  # two stones were washed out of the ring
        x, y = 16 + np.cos(a) * 9.4 * r, 27.5 + np.sin(a) * 4.4 * r
        c.paint(c.ellipse(x, y, 3.0, 2.3), st["rock"], 0.35 + 0.55 * c.sphere(x - 1, y - 1, 3.4, 2.7), contrast=2.0)
        c.paint(c.ellipse(x, y + 1.6, 2.4, 0.8), SILT, 0.5, dither=False)  # silt up the foot of the stone
    # the tripod: two legs stand askew and cross at the top, the empty hook hangs from the crossing, a third leg
    # lies across the silt in front of the ring
    c.paint(ms.limb_mask(c, 7, 27, 15, 6, 2.6), ex["bark"], 0.45, dither=False)
    c.paint(ms.limb_mask(c, 22, 27, 14, 6, 2.6), ex["bark"], 0.55, dither=False)
    c.paint(c.rect(13, 5, 17, 8), ex["bark"], 0.3, dither=False)  # the lashing where they cross
    c.paint(c.rect(15, 8, 16, 14), BRIGHT_IRON, 0.8, dither=False)  # a hook on a chain, nothing hangs on it
    c.paint(c.rect(15, 13, 18, 14) | c.rect(17, 13, 18, 16), BRIGHT_IRON, 0.8, dither=False)
    for xx0, xx1 in ((6, 10), (20, 24)):  # silt on the feet of the two standing legs
        c.paint(c.rect(xx0, 25, xx1, 29), SILT, 0.5, dither=False)
    c.paint(ms.limb_mask(c, 4, 33, 23, 31, 2.8), ex["bark"], 0.4, dither=False)  # the third leg, lying
    # the kettle lies on its side, the opening towards the ring, half of it in the silt; the lid next to it
    kettle = c.ellipse(32.4, 28.6, 5.8, 4.6)
    c.paint(kettle, BRIGHT_IRON, 0.3 + 0.65 * c.sphere(30, 26.5, 6.2, 5.0), dither=False)
    c.paint(c.ellipse(27.8, 28.6, 2.4, 4.0), BRIGHT_IRON, 0.9, dither=False)  # the rim of the opening
    c.paint(c.ellipse(27.4, 28.6, 1.5, 3.1), BRIGHT_IRON, 0.0, dither=False)  # the dark opening
    c.paint(kettle & (c.yy >= 30.5), SILT, 0.5, dither=False)  # the lower half stands in the silt
    c.paint(c.rect(36, 26, 40, 27) | c.rect(38, 24, 40, 27), BRIGHT_IRON, 0.65, dither=False)  # the spout
    c.paint(c.rect(29, 22, 36, 23) | c.rect(28, 23, 29, 26) | c.rect(36, 23, 37, 25), BRIGHT_IRON, 0.7, dither=False)  # the bail
    c.paint(c.ellipse(25, 34, 3.0, 1.2), BRIGHT_IRON, 0.65, dither=False)  # the lid
    c.paint(c.rect(24, 33, 26, 34), BRIGHT_IRON, 0.95, dither=False)  # its knob
    c.outline(st["outline"])
    return c


def flood_blanket(ms):
    """A blanket hung over the arm of a stake, stiff with silt, folded in two: a long front panel and a shorter,
    darker back panel to its right. The top fold above the line is still pale wool, everything below it is soaked
    through and dried (the weave still shows, two creases run down from the arm), one lower corner stands out like a
    board. The hem is a folded band, frayed under it, and along it runs ONE 1 px stripe of the Antreiber's chalk,
    drawn straight with a ruler. 48 x 64, anchor (24, 60), line at y = 20."""
    rng = np.random.default_rng(781)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 64)
    line = 60 - FLOOD_LINE_ABOVE_FOOT
    xi, yi = c.xx.astype(int), c.yy.astype(int)
    for y in range(12, 60):  # the stake, leaning a little; silt on it from the line down
        x = int(round(24 - (y - 12) * 0.04))
        c.paint(c.rect(x - 2, y, x + 2, y + 1), ex["bark"], np.where(c.xx < x, 0.6, 0.32), dither=False)
        if y >= line:
            c.paint(c.rect(x - 2, y, x + 2, y + 1), SILT, np.where(c.xx < x, 0.5, 0.3), dither=False)
    noise = pa.value_noise(64, 48, (6, 2), rng)
    weave = rng.random((64, 48)) > 0.86

    def panel(left, right, top, bottom, tone, wave):
        sides = (xi >= left + np.round(wave * np.sin(c.yy * 0.5)).astype(int)) & \
                (xi < right + np.round(wave * np.sin(c.yy * 0.4 + 1)).astype(int))
        return sides & (yi >= top) & (yi < bottom)

    # the back panel (behind the arm, shorter, darker)
    back = panel(27, 38, 14, 38, 0.0, 1.0)
    c.paint(back, WOOL, 0.4 + 0.15 * np.sin(c.xx * 1.3), contrast=2.0, dither=False)
    c.paint(back & (yi >= line), SILT, 0.28 + 0.2 * noise, contrast=1.8, dither=False)
    c.paint(back & (yi >= line) & (yi < line + 3), SILT, 0.6, dither=False)
    c.paint(back & (yi >= 35), SILT, 0.5, dither=False)  # its hem
    c.paint(ms.limb_mask(c, 7, 14, 41, 12, 3.0), ex["bark"], 0.55, dither=False)  # the arm
    # the front panel, folded over the arm
    hem_y = 46 - np.clip((c.xx - 24) * 0.9, 0, 6)  # one lower corner is lifted: stiff
    front = panel(11, 30, 12, 60, 0.0, 1.0) & (c.yy < hem_y)
    folds = 0.5 + 0.2 * np.sin(c.xx * 1.15 + 0.4) + 0.1 * (pa.value_noise(64, 48, 3, rng) - 0.5)
    c.paint(front, WOOL, folds - 0.1 * np.clip((c.yy - 14) / 30, 0, 1), contrast=2.0, dither=False)
    soaked = front & (yi >= line)
    c.paint(soaked, SILT, 0.4 + 0.2 * noise + 0.1 * (folds - 0.5), contrast=1.8, dither=False)
    c.paint(front & weave, WOOL, 0.28, dither=False)
    c.paint(soaked & weave, SILT, 0.16, dither=False)  # the weave shows through the silt
    for x0, x1 in ((22, 17), (26, 28)):  # two stiff creases down from the arm: a dark edge and a lit one beside it
        for y in range(16, 41):
            x = int(round(x0 + (x1 - x0) * (y - 16) / 24.0))
            c.paint(c.rect(x, y, x + 1, y + 1) & front, SILT if y >= line else WOOL, 0.1, dither=False)
            c.paint(c.rect(x + 1, y, x + 2, y + 1) & front, SILT if y >= line else WOOL, 0.85, dither=False)
    c.paint(front & (yi < line), WOOL, 0.9 - 0.12 * (c.yy - 12) / 8, dither=False)  # the dry top fold, pale
    c.paint(front & (yi < 14), WOOL, 1.0, dither=False)  # lit top of the roll
    c.paint(front & (yi >= line) & (yi < line + 3), SILT, 0.82, dither=False)  # the crust: the line itself
    c.paint(front & (yi == line - 1), SILT, 0.0, dither=False)  # a sharp top edge to the silt
    tip = front & (c.xx >= 25) & (hem_y < 46) & (c.yy >= hem_y - 7)
    c.paint(tip, SILT, 0.84, dither=False)  # the lifted corner, its dry underside showing
    c.paint(tip & (c.yy >= hem_y - 7) & (c.yy < hem_y - 6), SILT, 0.1, dither=False)
    hem = front & (yi >= 41) & (c.yy < hem_y) & ~tip
    c.paint(hem, SILT, 0.62, dither=False)  # the hem, a folded band
    c.paint(front & (yi == 41) & ~tip, SILT, 0.92, dither=False)  # its pressed top edge
    c.paint(c.rect(13, 42, 24, 43) & front, ANTREIBER_RED, 0.25, dither=False)  # ONE stripe of chalk, ruled straight
    frayed = (c.yy >= hem_y) & (c.yy < hem_y + 3) & (xi >= 12) & (xi < 29)
    n = (rng.random((64, 48)) * 3.4).astype(int)
    c.paint(frayed & (c.yy < hem_y + n) & ((xi % 2) == 0), SILT, 0.6, dither=False)
    c.outline(st["outline"])
    wet = c.ellipse(24, 59.6, 7.0, 1.7) & ~c.a & (rng.random((64, 48)) > 0.25)  # a little wet silt round the foot
    c.paint(wet, SILT_WET, 0.45, dither=False)
    return c


def flood_prints(ms):
    """The trail of one runner in dry silt, going north (up) the way the player came: a sole with a broad ball
    (7 x 5 px) and a heel (5 x 4 px) with a gap between them, the toes turned out a little, left and right of one
    line, a long stride (15 px) and behind each one a few flecks thrown backwards. The first ones are deep (dark
    floor, a lit far wall), then shallower, the last ones hardly there. Only opaque pixels in the mud tones of the
    style. Flat; 24 x 112, anchor (12, 108): the deepest one lies at the foot, the faintest at the head."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 112)
    mud, path = st["mud"], st["path"]
    ball = [".XXXXX.", "XXXXXXX", "XXXXXXX", "XXXXXXX", ".XXXXX."]
    heel = [".XXXXX.", ".XXXXX.", ".XXXXX.", "..XXX.."]
    stride, top = 15, 97
    for i in range(7):
        left = i % 2 == 0
        deep, faint = i < 3, i >= 5
        floor = mud[0] if deep else (mud[1] if not faint else mud[2])
        shallow = mud[1] if deep else mud[2]
        lit = path[3] if deep else (path[2] if not faint else None)
        x0, y0 = (3 if left else 14), top - i * stride
        out = -1 if left else 1  # the toes turn out
        pixels = {}
        for r, row in enumerate(ball):
            for k, ch in enumerate(row):
                if ch != "." and not (faint and r > 3):
                    pixels[(x0 + k + (out if r < 2 else 0), y0 + r)] = floor
        if not faint:
            for r, row in enumerate(heel):
                for k, ch in enumerate(row):
                    if ch != ".":
                        pixels[(x0 + k, y0 + 6 + r)] = shallow
        for (x, y), color in pixels.items():
            wall = (x + 1, y) not in pixels or (x, y + 1) not in pixels  # the far wall, lit from the upper left
            c.fill(c.rect(x, y, x + 1, y + 1), lit if (wall and lit is not None) else color)
        spray = ((x0 + 1, y0 + 11), (x0 + 5, y0 + 12)) if not faint else ((x0 + 3, y0 + 5),)
        for x, y in spray:
            c.fill(c.rect(x, y, x + 1, y + 1), mud[1] if deep else mud[2])
    return c


def nest(ms):
    """An empty bird's nest lying in the grass: a bowl of woven dry stems with a little living moss on its
    underside, the hollow dark and empty, three stems sticking out. 16 x 10, anchor (8, 8)."""
    rng = np.random.default_rng(791)
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 10)
    xi, yi = c.xx.astype(int), c.yy.astype(int)
    rim = c.ellipse(8, 4.2, 5.9, 2.9)
    bowl = (c.ellipse(8, 5.8, 5.9, 3.6) & (c.yy >= 4)) | rim
    strands = ((xi * 2 + yi * 3 + (yi // 2) * 2) % 5) / 4.0  # diagonal stems of changing tone
    c.paint(bowl, DRIED_STEM, 0.22 + 0.5 * strands + 0.12 * (rng.random((10, 16)) - 0.5) + 0.12 * (c.yy < 6), contrast=1.4, dither=False)
    c.paint(rim & ~c.ellipse(8, 4.5, 4.0, 1.6), DRIED_STEM, 0.45 + 0.5 * strands, contrast=1.4, dither=False)  # the woven rim
    c.paint(c.ellipse(8, 4.5, 4.0, 1.6), DRIED_STEM, 0.0, dither=False)  # the hollow
    c.paint(c.rect(5, 4, 10, 5), DRIED_STEM, 0.08, dither=False)
    moss = bowl & (c.yy >= 7) & (pa.value_noise(10, 16, 2.5, rng) > 0.5)
    c.paint(moss, NEST_MOSS, 0.5 + 0.3 * c.sphere(5, 5, 9, 5), dither=False)
    c.fill(c.rect(4, 3, 6, 4) | c.rect(10, 3, 12, 4), NEST_MOSS[2])  # two tufts of moss in the rim
    c.fill(c.rect(1, 5, 3, 6), DRIED_STEM[3])  # a stem sticking out to the left
    c.fill(c.rect(12, 2, 15, 3), DRIED_STEM[2])  # one to the upper right
    c.fill(c.rect(13, 7, 15, 8), DRIED_STEM[1])  # and one low on the right
    c.outline(st["outline"])
    return c


def _limb(c, pts, widths, ramp_colors, contrast=2.2):
    """A round limb along a polyline, lit from the upper left; `widths` is the width at each point."""
    mask = np.zeros((c.h, c.w), bool)
    value = np.zeros((c.h, c.w), np.float32)
    light = np.array([-0.55, -0.65, 0.52], np.float32)
    light /= np.linalg.norm(light)
    for (ax, ay), (bx, by), wa, wb in zip(pts, pts[1:], widths, widths[1:]):
        steps = int(max(abs(bx - ax), abs(by - ay), 1) * 3)
        tx, ty = bx - ax, by - ay
        n = np.hypot(tx, ty) or 1.0
        nx, ny = -ty / n, tx / n
        for i in range(steps + 1):
            k = i / steps
            x, y, half = ax + tx * k, ay + ty * k, (wa + (wb - wa) * k) / 2
            dx, dy = c.xx + 0.5 - x, c.yy + 0.5 - y
            u = (dx * nx + dy * ny) / half
            inside = (dx * dx + dy * dy <= half * half + 0.3)
            lam = np.clip(u * (nx * light[0] + ny * light[1]) + np.sqrt(np.clip(1 - u * u, 0, 1)) * light[2], 0, 1)
            mask |= inside
            value = np.where(inside, 0.12 + 0.8 * lam, value)
    c.paint(mask, ramp_colors, value, contrast=contrast, dither=False)
    return mask


def fork(ms, with_nest):
    """A limb standing up from the bank and forking in a wide Y over the water: weathered grey-brown, a little moss
    where it leaves the ground, one short twig. With `with_nest` the nest from the quest lies in the crotch, the way
    a nest lies that was always there: the prongs pass in front of its sides. 32 x 40, anchor (16, 37)."""
    rng = np.random.default_rng(793)
    st = pa.STYLES["tal"]
    c = ms.Canvas(32, 40)
    c.paint(c.ellipse(16, 37, 6.4, 2.0), TWIG_WOOD, 0.25, dither=False)  # roots flare into the bank
    _limb(c, [(16, 38), (15, 31), (16, 27)], [7, 6, 5.5], TWIG_WOOD)
    _limb(c, [(16, 27), (9, 18), (4, 8)], [5, 3.6, 2.4], TWIG_WOOD)
    _limb(c, [(16, 27), (23, 19), (28, 10)], [4.8, 3.4, 2.2], TWIG_WOOD)
    _limb(c, [(7, 14), (2, 12)], [2, 1.2], TWIG_WOOD)  # the short twig
    grain = pa.value_noise(40, 32, (4, 1), rng)
    c.paint(c.a & (grain > 0.74), TWIG_WOOD, 0.18, dither=False)  # a few dark cracks along the limbs
    moss = c.a & (c.yy >= 34) & (pa.value_noise(40, 32, 2, rng) > 0.4)
    c.paint(moss, MOSS, 0.5, dither=False)
    c.fill(c.rect(3, 7, 6, 8), TWIG_WOOD[4])  # the pale cut ends, where it has broken
    c.fill(c.rect(27, 9, 30, 10), TWIG_WOOD[4])
    if with_nest:
        before = (c.rgb.copy(), c.a.copy())
        c.blit(nest(ms), 8, 20)
        flank = before[1] & ((c.xx < 11) | (c.xx > 21)) & (c.yy >= 20) & (c.yy < 27)
        c.rgb[flank] = before[0][flank]  # the prongs pass in front of the nest's sides
    c.outline(st["outline"])
    return c


def driftwood(ms):
    """A piece of driftwood on the shore: silver-grey, worn smooth by water, a side branch and a knot with its
    rings, the broken end a little lighter. 16 x 12, anchor (8, 9)."""
    rng = np.random.default_rng(795)
    st = pa.STYLES["tal"]
    silver = BLEACHED[:4]  # no near-white: a piece of wood, not a bone
    c = ms.Canvas(16, 12)
    _limb(c, [(2.4, 9.6), (8, 8.2), (13.6, 7.0)], [4.0, 3.8, 2.8], silver)
    _limb(c, [(8.5, 8), (10, 2.6)], [2.6, 1.5], silver)  # the side branch
    c.paint(c.a & (pa.value_noise(12, 16, (1, 3), rng) > 0.6), silver, 0.1, dither=False)  # grain
    c.paint(c.ellipse(5, 8.8, 1.5, 1.2), silver, 0.05, dither=False)  # the knot
    c.paint(c.ellipse(5, 8.8, 0.6, 0.5), silver, 0.6, dither=False)
    c.paint(c.ellipse(2.3, 9.6, 1.2, 1.7), silver, 0.9, dither=False)  # the broken end
    c.outline(st["outline"])
    return c


def stepping_stones(ms):
    """Four flat slabs across the stream, one step apart (16 px), their tops at one height: they did not fall
    there, somebody carried and laid them. Each shows a pale flat top and a dark edge of its thickness, a ring of
    ripples where the water goes around it (the stream comes from the north), a few pebbles wedged under it.
    Flat; 64 x 16, anchor (40, 8): the anchor is the centre of the THIRD stone, so that the four stones lie on four
    cells in a row (the cells -2, -1, 0, +1 from the anchor cell) with their centres on the cell centres."""
    rng = np.random.default_rng(797)
    st = pa.STYLES["tal"]
    water = st["water"]
    stones = ms.Canvas(64, 16)
    centres = (8, 24, 40, 56)
    widths = (6.2, 6.8, 6.0, 6.5)
    for k, cx in enumerate(centres):
        rx = widths[k]
        def slab(cy, ry, cx=cx, rx=rx):
            return (np.abs(stones.xx + 0.5 - cx) / rx) ** 3 + (np.abs(stones.yy + 0.5 - cy) / ry) ** 3 <= 1.0

        side = slab(8.6, 3.0)
        stones.paint(side, st["stone"], 0.26 + 0.1 * (pa.value_noise(16, 64, 2, rng) - 0.5), dither=False)  # the thickness
        top = slab(6.8, 2.9)
        light = 0.66 + 0.2 * stones.sphere(cx - 2, 5.5, rx * 1.5, 4.0) + 0.1 * (pa.value_noise(16, 64, 2, rng) - 0.5)
        stones.paint(top, st["stone"], light, contrast=2.0, dither=False)  # the flat top
        stones.paint(top & (stones.yy < 5.6) & (stones.xx < cx), st["stone"], 0.92, dither=False)  # the lit edge
        if k == 2:
            stones.paint(top & (stones.xx > cx + 1) & (stones.yy > 5), MOSS, 0.5, dither=False)  # moss on one of them
        stones.paint(stones.rect(cx - 3, 11, cx + 3, 12), st["rock"], 0.2, dither=False)  # pebbles wedged under it
    stones.outline(st["outline"])
    c = ms.Canvas(64, 16)
    for k, cx in enumerate(centres):
        ring = c.ellipse(cx, 8.2, widths[k] + 2.6, 5.0) & ~c.ellipse(cx, 8.2, widths[k] + 1.2, 3.7)
        c.paint(c.ellipse(cx, 9.4, widths[k] + 0.8, 3.8), water, 0.0, dither=False)  # the dark of the wet
        c.fill(ring & (((c.xx.astype(int) + (c.yy.astype(int) < 8) * 1) % 3) != 0), water[3])  # a broken ring of ripples
        c.fill(ring & (c.yy < 5) & (np.abs(c.xx + 0.5 - cx) < 3), water[4])  # a bright swell on the upstream side
    c.blit(stones, 0, 0)
    return c


# --------------------------------------------------------------------------- the night wood (W5)
# The Nachtwald has no light source: nothing here is a PointLight2D (Plan 7 puts the light off until the first night
# map of the city). What glows is baked into the emissive layer, which the game draws above the night tint, unshaded
# (like the cyan mushrooms and wd_rest_lit): the trees and the log glow a cool, matt green (foxfire; a wood full of
# them must not blind, so only a few pixels reach the bloom threshold of the grade), the lantern is the one warm
# light of the wood, small and still. Nothing flickers: one picture of the flame, one ring of light on the ground.
GLOW_BARK = ramp("#0e1214", "#182022", "#252f31", "#364442", "#4d605b")
FOXFIRE = ramp("#0f2e2c", "#1a5446", "#2b7f66", "#4aa888", "#80d0ac")
ROTTEN = ramp("#1a1612", "#2e261c", "#483c2c", "#64543c", "#86724f")
PUNK = ramp("#16221f", "#222f2a", "#34433b")  # the same patches of the log when nothing glows any more
LANTERN_IRON = ramp("#14161a", "#2a2d34", "#454a54", "#6e7480")
LANTERN_LIGHT = {"g": "#80461a", "G": "#be6c26", "F": "#f2a63c", "f": "#fff0a8"}  # glass dim, glass, flame, core
POOL = ramp("#2a190b", "#47290f", "#6e4a1c", "#9a6c2c")  # the ring of light on the ground, matt amber
GLOW_TREES = [(801, 0.42, 0.30, 0.12), (803, 0.32, 0.26, 0.22)]  # seed, trunk, limb, crown share: bark-lit, crown-lit
LANTERN_ROWS = [
    "...iiii...",
    "..i....i..",
    "..iiiiii..",
    ".IIIIIIIi.",
    ".igGGGGgi.",
    ".igGFFGgi.",
    ".igFffFgi.",
    ".igFffFgi.",
    ".igGFFGgi.",
    ".iggggggi.",
    ".bbbbbbbb.",
    "..bBbbbb..",
]


def _palette_hits(c, colors):
    """Index of the ramp colour each opaque pixel of `c` has (-1 where it has none of them)."""
    hit = np.full((c.h, c.w), -1, int)
    for k, col in enumerate(colors):
        hit[np.all(np.abs(c.rgb - col) < 0.5, axis=-1) & c.a] = k
    return hit


def _thicken(mask):
    """Drops the pixels of a patch that have fewer than two neighbours (no stray single pixels, no hairlines)."""
    n = np.zeros(mask.shape, int)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        n += np.roll(np.roll(mask, dy, 0), dx, 1)
    return mask & (n >= 2)


def _rim(mask):
    """The pixels of a patch that touch something outside it (its edge, 4-neighbourhood)."""
    inner = mask.copy()
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        inner &= np.roll(np.roll(mask, dy, 0), dx, 1)
    return mask & ~inner


def _bleed(c, e, patch, surface):
    """The glow spills a little onto the wood beside it: the pixels of `surface` right next to a patch, every other
    one in the darkest foxfire colour (a checker), so that the edge of a patch is soft and not cut."""
    near = np.zeros(patch.shape, bool)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        near |= np.roll(np.roll(patch, dy, 0), dx, 1)
    near &= surface & ~patch & (((c.xx + c.yy) % 2) == 0)
    _glow_into(c, e, near, np.zeros(patch.shape, int))


def _glow_into(c, e, mask, index):
    """Lights the masked pixels: foxfire colours `index` (array) on the sprite and on its emissive layer."""
    col = FOXFIRE[np.clip(index, 0, len(FOXFIRE) - 1)]
    c.rgb[mask] = col[mask]
    c.a |= mask
    e.rgb[mask] = col[mask]
    e.a |= mask


def glow_tree(ms, seed, trunk_share, limb_share, crown_share):
    """A beech of the night wood: the same tree as wd_beech with dark, wet bark (it stands against the dark as a
    silhouette) whose lichen glows matt green: streaks of foxfire down the trunk and along the limbs (their share of
    the bark is `trunk_share` and `limb_share`), and a few leaf clumps of the crown whose lit side glows
    (`crown_share` of the lit leaves). Returns (sprite, emissive); 96 x 128, anchor (48, 124), like wd_beech."""
    rng = np.random.default_rng(seed + 200)
    st = pa.STYLES["tal"]
    foliage = st["foliage_blue" if seed % 2 else "foliage"]
    e = ms.Canvas(96, 128)

    def mark(c, centre, base):
        bark = _palette_hits(c, GLOW_BARK) >= 0
        leaf = _palette_hits(c, foliage)
        mid = np.array([centre(min(max(y, 58), base)) for y in range(c.h)])[:, None]
        trunk = bark & (np.abs(c.xx + 0.5 - mid) <= 5.0) & (c.yy >= 58) & (c.yy < base - 4)
        streaks = pa.value_noise(c.h, c.w, (12, 2.4), rng)  # long and thin: the glow runs with the grain
        lumps = pa.value_noise(c.h, c.w, 3.0, rng)
        patch = _thicken(trunk & (streaks > 1 - trunk_share)) | _thicken(bark & ~trunk & (lumps > 1 - limb_share))
        tone = pa.value_noise(c.h, c.w, 2.2, rng)
        index = np.where(tone > 0.84, 3, 2)
        index = np.where(_rim(patch) | (tone < 0.22), 1, index)
        foot = _thicken(bark & (c.yy >= base - 6) & (pa.value_noise(c.h, c.w, 2.5, rng) > 0.46))
        _glow_into(c, e, patch | foot, np.where(foot & ~patch, 1, index))
        _bleed(c, e, patch | foot, bark)
        spots = (leaf >= 2) & (pa.value_noise(c.h, c.w, 3.2, rng) > 1 - crown_share)
        spots = _thicken(spots)
        _glow_into(c, e, spots, np.where(leaf >= 4, 2, 1))

    c = beech(ms, seed, mark=mark, bark=GLOW_BARK)
    return c, e


def _sheet_of(c, rows, colors, ox, oy):
    """Draws a hand-made grid of characters (one colour each, '.' is transparent) onto `c` at (ox, oy)."""
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                c.rgb[oy + y, ox + x] = colors[ch]
                c.a[oy + y, ox + x] = True


def _pool(c, e, cx, cy, rx, ry, levels, close_to_edge=0.0):
    """A ring of matt light on the ground, drawn on both layers: concentric bands of POOL, the brightest in the
    middle, every step ordered-dithered into the next so that it reads as a soft round pool and not as a target.
    `levels` is how many POOL colours it uses (the last ones); pixels under the dither of the first band are left
    out, so the edge is a broken line of dots."""
    d = np.hypot((c.xx + 0.5 - cx) / rx, (c.yy + 0.5 - cy) / ry)
    thr = np.tile(pa.BAYER4, (c.h // 4 + 1, c.w // 4 + 1))[:c.h, :c.w]
    q = np.floor(np.clip(1 - d, 0, 1) ** 0.85 * levels + thr).astype(int)
    q = np.minimum(q, levels)
    lit = (d <= 1.0) & (q >= 1)
    col = POOL[len(POOL) - levels + np.clip(q - 1, 0, levels - 1)]
    for layer in (c, e):
        layer.rgb[lit] = col[lit]
        layer.a |= lit


def lantern(ms):
    """The small lantern on the ground of the night wood: an iron frame with a ring on top, a dim glass cage around
    one calm flame (pale core, amber body), a base plate. The glass and the flame are the emissive layer, one picture
    (no flicker), and a few dots of amber on the ground right around its foot (the large ring of light on the
    ground is wd_lantern_pool, a flat prop, so that it never lies over a person sitting beside the lantern).
    Returns (sprite, emissive); 28 x 24, anchor (14, 20): the lantern itself is 12 x 14 px with its outline."""
    st = pa.STYLES["tal"]
    c, e = ms.Canvas(28, 24), ms.Canvas(28, 24)
    colors = {"i": LANTERN_IRON[2], "I": LANTERN_IRON[3], "b": LANTERN_IRON[2], "B": LANTERN_IRON[3]}
    for ch, hexcolor in LANTERN_LIGHT.items():
        colors[ch] = pa.hex_rgb(hexcolor)
    _sheet_of(c, LANTERN_ROWS, colors, 9, 7)
    glow = np.zeros((24, 28), bool)
    for y, row in enumerate(LANTERN_ROWS):
        for x, ch in enumerate(row):
            if ch in LANTERN_LIGHT:
                glow[7 + y, 9 + x] = True
    c.outline(st["outline"])
    solid = c.a.copy()  # the frame stands in front of its own ring of light
    halo, halo_e = ms.Canvas(28, 24), ms.Canvas(28, 24)
    _pool(halo, halo_e, 14, 19.4, 11.5, 3.6, 2)
    free = halo_e.a & ~solid
    for layer, source in ((c, halo), (e, halo_e)):
        layer.rgb[free] = source.rgb[free]
        layer.a |= free
    e.rgb[glow] = c.rgb[glow]
    e.a |= glow
    return c, e


def lantern_pool(ms):
    """The ring of light of the lantern on the ground: matt amber, brightest at the foot of the lantern, ordered
    dither between the steps; flat (the game draws it under everyone, so it never covers a person who sits beside
    the lantern, and it is baked, not a light). Returns (sprite, emissive); 80 x 32, anchor (40, 16)."""
    c, e = ms.Canvas(80, 32), ms.Canvas(80, 32)
    _pool(c, e, 40, 16, 37, 14.4, 4)
    return c, e


def foxfire_log(ms, lit):
    """A fallen trunk, rotten through: dark bark with ochre punk showing where it has crumbled, a skin of moss along
    the top, the cut face of the root end to the left with its rings, the other end broken off in splinters. In its
    lower half and along two cracks the wood glows matt green (foxfire; `lit`); `lit=False` is the same log after
    somebody has taken a piece: the patches are dull and dark, and one pale notch of fresh wood shows where it was
    broken out. 60 x 26, anchor (30, 20)."""
    rng = np.random.default_rng(821)
    st = pa.STYLES["tal"]
    c, e = ms.Canvas(60, 26), ms.Canvas(60, 26)
    cy, x0, x1 = 13.5, 8, 54
    along = np.clip((c.xx - x0) / (x1 - x0), 0, 1)
    rad = 6.6 + 0.9 * (1 - along) + 0.5 * np.sin(c.xx * 0.43) + 0.3 * np.sin(c.xx * 1.1 + 2)
    t = (c.yy + 0.5 - cy) / rad
    body = (np.abs(t) <= 1.0) & (c.xx >= x0) & (c.xx < x1)
    splinter = (c.xx >= 49 + 5 * (pa.value_noise(c.h, c.w, (2, 9), rng) - 0.5) * 2) & (c.yy < cy)
    body &= ~((c.xx >= 50) & (c.yy < cy - 2) & (pa.value_noise(c.h, c.w, (3, 6), rng) > 0.5))
    body &= ~((c.xx >= 52) & (c.yy > cy + 3))
    body &= ~((c.xx >= 53) & splinter)
    light = np.sqrt(np.clip(1 - t * t, 0, 1)) * 0.7 + np.clip(-t, 0, 1) * 0.3
    grain = pa.value_noise(c.h, c.w, (1, 8), rng)
    c.paint(body, ROTTEN, 0.12 + 0.6 * light + 0.16 * (grain - 0.5), contrast=2.0, dither=False)
    crumbled = body & (t > -0.2) & (pa.value_noise(c.h, c.w, (3, 7), rng) > 0.64)
    c.paint(crumbled, ROTTEN, 0.5 + 0.2 * (grain - 0.5), dither=False)  # punk: paler, ochre, where the bark has gone
    moss = body & (t < -0.25) & (pa.value_noise(c.h, c.w, (3, 5), rng) > 0.42)
    c.paint(moss, MOSS, 0.3 + 0.5 * light, dither=False)
    face = c.ellipse(x0, cy, 3.4, rad[int(cy), x0] + 0.2)  # the cut face of the root end
    rings = (np.hypot(c.xx + 0.5 - x0, (c.yy + 0.5 - cy) * 0.55).astype(int) % 2) == 0
    c.paint(face, ROTTEN, np.where(rings, 0.55, 0.78), dither=False)
    c.paint(c.rect(x0 - 3, cy - 0.5, x0 + 1, cy + 0.5) & face, ROTTEN, 0.2, dither=False)  # a heart crack
    # the foxfire: a few patches along the grain in the lower half and a vein that joins them; rim darker
    patches = np.zeros((c.h, c.w), bool)
    for px, py, rx, ry in ((17, 16.2, 5.6, 2.3), (29, 13.8, 4.2, 1.7), (37, 16.6, 6.2, 2.5), (46.5, 15, 3.6, 2.0),
                           (23, 19.4, 3.2, 1.2), (43, 11, 2.6, 1.3)):
        wob = pa.value_noise(c.h, c.w, 2.5, rng)
        patches |= (c.ellipse(px, py, rx, ry) | c.ellipse(px, py, rx * 0.6, ry * 1.5) & (wob > 0.5)) & body & (t > -0.55)
    veins = np.zeros((c.h, c.w), bool)
    for ax, ay, bx, by in ((43, 16, 46, 14), (10, 16, 13, 15), (24, 11, 27, 10)):
        for i in range(12):
            veins[int(round(ay + (by - ay) * i / 11)), int(round(ax + (bx - ax) * i / 11))] = True
    patches = _thicken(patches | (veins & body))
    tone = pa.value_noise(c.h, c.w, 2.0, rng)
    index = np.where(tone > 0.74, 3, 2)
    index = np.where(_rim(patches), 1, index)
    if lit:
        _glow_into(c, e, patches, index)
        _bleed(c, e, patches, body)
    else:
        c.paint(patches, PUNK, np.where(_rim(patches), 0.1, 0.45 + 0.4 * (tone - 0.5)), dither=False)
        c.paint(c.rect(33, 11, 37, 14) & body, TWIG_WOOD, np.where(c.xx < 35, 0.95, 0.7), dither=False)
        c.paint(c.rect(33, 11, 37, 12) & body, TWIG_WOOD, 0.35, dither=False)
    c.outline(st["outline"])
    return c, e



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
    # the hut (W3): the room is one flat shell under the furniture (like haus/shell); the open door lies over the
    # closed one and shows the same doorway; wd_hut_cup, wd_hut_branches and wd_line carry no shadow (shadow cells
    # feed the baked map stamp of waldweg)
    ms.save("haus", "hut_shell", hut_shell(ms), (8, 8), flat=True,
            lights=[{"offset": [72, 40], "color": "#e8b070", "energy": 0.4, "range": 80}])
    stove, glow = hut_stove(ms)
    ms.save("haus", "hut_stove", stove, (22, 52), emissive=glow, flicker=True,
            lights=[{"offset": [0, -14], "color": "#ff9a4a", "energy": 1.4, "range": 130}],
            shape={"rect": [40, 10], "offset": [0, -4]})
    ms.save("haus", "hut_table", hut_table(ms), (22, 24), shape={"rect": [34, 8], "offset": [0, -6]}, shadow=[18, 4])
    ms.save("haus", "hut_bed", hut_bed(ms), (15, 40), shape={"rect": [28, 30], "offset": [0, -16]})
    ms.save("haus", "hut_door_open", hut_door_open(ms), (8, 24), flat=True)
    ms.save("haus", "hut_pipe", hut_pipe(ms), (23, 7), flat=True)
    ms.save("tal", "wd_hut_cup", hut_cup(ms), (8, 10))
    ms.save("tal", "wd_hut_branches", hut_branches(ms), (24, 7), flat=True)
    ms.save("tal", "wd_line", hut_line(ms), (24, 26))
    # the flood clearing (W4): every beech carries the flood line at the same height (the spruces stand on higher ground); the flood mark, the camp, the
    # blanket and the trail say what happened there without anyone in it; the nest, the fork, the driftwood and
    # the stepping stones are the gentle things. Only the trees and the mark have a shadow (it feeds the baked
    # map stamp of flutlichtung); everything the map places under if/unless has none.
    ms.save("tal", "wd_flood_beech", [flood_beech(ms, 751 + k) for k in range(3)], (48, 124),
            shape={"circle": 6, "offset": [0, -2]}, sway=0.8, shadow=[30, 9])
    ms.save("tal", "wd_flood_mark", flood_mark(ms), (20, 108), shape={"circle": 5, "offset": [0, -2]}, shadow=[14, 5])
    ms.save("tal", "wd_flood_ring", flood_ring(ms), (16, 30), shape={"circle": 8, "offset": [0, -2]})
    ms.save("tal", "wd_flood_blanket", flood_blanket(ms), (24, 60), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "wd_flood_prints", flood_prints(ms), (12, 108), flat=True)
    ms.save("tal", "wd_nest", nest(ms), (8, 8))
    ms.save("tal", "wd_fork", fork(ms, False), (16, 37), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "wd_fork_nest", fork(ms, True), (16, 37), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "wd_driftwood", driftwood(ms), (8, 9))
    ms.save("tal", "wd_stones", stepping_stones(ms), (40, 8), flat=True)
    # the night wood (W5): no PointLight2D anywhere, the glow is the emissive layer (drawn above the night tint). The
    # glow trees are two beeches (shadow: they stand in the baked stamp of nachtwald); the lantern is small, its
    # ring of light on the ground is a flat prop of its own; the log carries no shadow, and a second, dark one
    # (wd_foxfire_log_dim) is what lies there after a piece has been taken
    trees = [glow_tree(ms, *spec) for spec in GLOW_TREES]
    ms.save("tal", "wd_glow_tree", [t[0] for t in trees], (48, 124), emissive=[t[1] for t in trees],
            shape={"circle": 6, "offset": [0, -2]}, sway=0.5, shadow=[30, 9])
    lamp, lamp_glow = lantern(ms)
    ms.save("tal", "wd_lantern", lamp, (14, 20), emissive=lamp_glow, shape={"circle": 3, "offset": [0, -1]})
    pool, pool_glow = lantern_pool(ms)
    ms.save("tal", "wd_lantern_pool", pool, (40, 16), emissive=pool_glow, flat=True)
    log, log_glow = foxfire_log(ms, True)
    ms.save("tal", "wd_foxfire_log", log, (30, 20), emissive=log_glow, shape={"rect": [40, 8], "offset": [0, -4]})
    ms.save("tal", "wd_foxfire_log_dim", foxfire_log(ms, False)[0], (30, 20),
            shape={"rect": [40, 8], "offset": [0, -4]})


def night_strip(ms, width, height):
    """The night wood as the scene shows it, roughly: the ground and every sprite multiplied by the world tint of
    nachtwald.tscn (0.5, 0.55, 0.74, the palette of the prototype look_wald; the scene sets exports and no day_preset),
    every emissive layer drawn on top unshaded and unchanged (no grade, no bloom: this is only to judge whether the
    glow is legible against the tint and does not blind). Left to right:
    the two glow trees, an ordinary beech and spruce next to them, the log (glowing and dark), the lantern in its
    ring of light."""
    from PIL import Image
    tint = np.array([0.5, 0.55, 0.74])
    strip = Image.new("RGBA", (width, height), tuple(int(v) for v in pa.STYLES["tal"]["grass"][1] * tint) + (255,))
    foot = height - 20
    trees = [glow_tree(ms, *spec) for spec in GLOW_TREES]
    lamp, lamp_glow = lantern(ms)
    pool, pool_glow = lantern_pool(ms)
    log, log_glow = foxfire_log(ms, True)
    parts = [(trees[0][0], trees[0][1], 48, 124, 56), (trees[1][0], trees[1][1], 48, 124, 150),
             (beech(ms, 711), None, 48, 124, 244), (spruce(ms, 701), None, 28, 116, 310),
             (log, log_glow, 30, 20, 380), (foxfire_log(ms, False)[0], None, 30, 20, 440),
             (pool, pool_glow, 40, 16, 540), (lamp, lamp_glow, 14, 20, 540)]
    for base, glow, ax, ay, x in parts:
        top = (x - ax, foot - ay)
        tinted = base.rgba().copy()
        tinted[..., :3] *= tint
        strip.alpha_composite(Image.fromarray(tinted.astype(np.uint8), "RGBA"), top)
        if glow is not None:
            strip.alpha_composite(Image.fromarray(glow.rgba().astype(np.uint8), "RGBA"), top)
    return strip


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [spruce(ms, 701), spruce(ms, 702), beech(ms, 711), beech(ms, 712), hut(ms), rest_log(ms),
             rest_fire(ms, False)[0], rest_fire(ms, True)[0]]
    items += [marker(ms, kind) for kind in ("arrow", "tally", "plain", "blank")]
    items += [mossy_stone(ms, 731), fern(ms, 741)]
    indoor = [hut_stove(ms)[0], hut_table(ms), hut_bed(ms), hut_door_open(ms)]
    outdoor = [hut_cup(ms), hut_branches(ms), hut_line(ms)]
    sheet = Image.new("RGBA", (780, 150 + 170), (96, 136, 88, 255))
    x = 8
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, 148 - img.height if img.height < 148 else 0))
        x += img.width + 6
    # the hut's room on a floor of planks, the furniture where the map puts it, then the three outside props
    room = Image.new("RGBA", (HUT_W, HUT_H), (74, 52, 36, 255))
    shell = Image.fromarray(hut_shell(ms).rgba().astype(np.uint8), "RGBA")
    room.alpha_composite(shell)
    stove, glow = hut_stove(ms)
    for img, pos in ((stove, (168 - 22, 56 - 52)), (hut_table(ms), (112 + 8 - 22, 80 + 8 - 24)),
                     (hut_bed(ms), (176 + 8 - 15, 112 + 8 - 40))):
        room.alpha_composite(Image.fromarray(img.rgba().astype(np.uint8), "RGBA"), pos)
    sheet.alpha_composite(room, (8, 156))
    x = 8 + HUT_W + 10
    for item in indoor + outdoor:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, 156 + 150 - img.height if img.height < 150 else 156))
        x += img.width + 8
    # the flood clearing: dry silt (left strip) and grass (right strip) behind the same row, the stones on water
    flood = [flood_beech(ms, 751), flood_beech(ms, 752), flood_mark(ms), flood_ring(ms), flood_blanket(ms),
             flood_prints(ms), nest(ms), fork(ms, False), fork(ms, True), driftwood(ms), stepping_stones(ms)]
    strip_h = 150
    strips = []
    for ground in ((118, 94, 70, 255), (72, 112, 52, 255)):
        strip = Image.new("RGBA", (sheet.width, strip_h), ground)
        x = 8
        for item in flood:
            img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
            if item is flood[-1]:
                strip.alpha_composite(Image.new("RGBA", (img.width, img.height), tuple(pa.STYLES["tal"]["water"][2].astype(int)) + (255,)), (x, strip_h - img.height - 2))
            strip.alpha_composite(img, (x, strip_h - 2 - img.height if img.height < strip_h - 2 else 0))
            x += img.width + 8
        strips.append(strip)
    strips.append(night_strip(ms, sheet.width, strip_h + 20))
    full = Image.new("RGBA", (sheet.width, sheet.height + sum(s.height for s in strips)))
    full.alpha_composite(sheet, (0, 0))
    y = sheet.height
    for strip in strips:
        full.alpha_composite(strip, (0, y))
        y += strip.height
    full.resize((full.width * 2, full.height * 2), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
