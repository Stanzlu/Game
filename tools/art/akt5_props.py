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
way. No prop of the mountains has a light (the lamps of the hall, G3, are the exception). What the map places under `if`/`unless` carries no shadow in the catalog (shadow cells feed the
baked stamp of the map), and so do the things placed on cells of an older stamp (the chalk arrow and the cairns of the
road, which are `gb_arrow_chalk` and `gb_cairn_road`) and the things that later segments take away (the fall of rock at the end of the pass, which G2
replaced by a door, the heap of scree at the foot of the Grat's ramp in `grat`, which G6 opens, and the gate of the
Anlage, which G3 replaces by a door).

Hochtal (G2): the Anlage, a hall seen from the front (a long wall of cut stone, a slate roof, a tall chimney, a double door with
iron straps, a dial either side of it with no numerals, pipes down both ends), a palisade of iron bars one cell wide and the
gate that closes it; the mountain pines (Latschen) of the slopes; the sign at the entrance (a word in strokes and an arrow
under it); a flat stone at the water with the print of a small hand on it, still wet; a small round stone, a rock crystal
broken at its foot, the marmot's den (a rock with a round hole under it, earth thrown out in front, a spoon's handle, a button,
a cardboard hat and a dent where the thimble sits) and the thimble; and a shorter column of smoke. Everything is drawn to the
same palette as the valley; the Anlage is the only thing in the mountains that is square.

Die Anlage (G3, prefix `ma_`): the gate stands open (`gb_plant_gate_open`, the same cells as the shut one, nothing to walk into) and the hall of the
Wächter is a room of its own (content/maps/maschine.txt, Klasse S, zoom 1.5: 25 x 14 cells, 400 x 224 pixels). A flat shell paints the walls (a girder, cold
slate-grey stone, the bus bar and the twelve rods from the levers to the bolt of the small shut door, pipes, side walls, the front wall with its door); the
console (15 cells, flat, its collision is its shape) carries twelve levers, each a prop of its own with a number plate and a knob in a form of its own (up
and pulled), nine of them under a cloth (a prop of its own each); four dials with their needles as props of their own (the scene rotates and trembles
them), the worn dial of the fragment, the bolt indicator (the cue of the small door), six lamps (the only things in the Akt with `lights`, one each, and a
baked glow as fallback), two boilers, a pipe across the floor, the pipe that hisses and the puffs of steam (flat pictures the scene may move, fade or
leave out, never a flash). `--preview-hall out.png` lays all of it out (3x). Nothing here is a person and nothing says what the small door is.

Das Loslassen (G5): one lamp of the hall goes out and nobody mends it; `ma_lamp_hang_dark` is the hanging lamp on the same cell, the glass dark and cracked,
without glow, light or shadow.

Das Verstecken (G6): the Grat above the valley. A small signpost at the fork (`gb_fork_sign`: two planks, an arrow in charcoal on each, up and down, and five
and six strokes beside them that are no letters; both halves weigh the same), the hollow at the end of the cleft (`gb_cleft_alcove`: a block of the cliff's
warm grey stone with an arch cut into it, dark inside, a blanket rolled up on its floor, a crack from the upper left and a strip of light that ends at the
blanket's rim; no person, no shape: the player may stand on its cell) and the candle stub on the ground beside it (`gb_candle`, 10 x 12, no shadow, it goes
with a flag). The picture of the hollow in the 16 x 16 fragment is `tools/art/small/fragment_hiding.pix`, the stub's icon `curiosity_candle_stub.pix`.

Das Kind (G7): three quiet things and no person. The flat rock at the edge of the Grat that two can sit on (`gb_sit_rock`, 32 x 14, two cells, flat: its top
worn smooth and pale by many sitters, a darker front, the cliff's warm grey), the plain frame that hangs in the air round the two of them (`gb_picture_frame`,
24 x 24: wood, no hook, no shadow, no glow, and in it a dark empty ground of 16 x 16 at (4, 4) on which the scene lays the picture of a fragment; an empty
frame is the same frame without it) and the sprout in the bed in the valley (`gb_sprout`, 12 x 14: a stem and two leaves, light green, on a little dark earth;
a beginning and not a symbol: it does not shine and does not move). None of the three has a shadow in the catalog (the rock and the sprout stand on cells of an
older stamp, the frame hangs in the air).
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
def smoke(ms, height=168):
    """The smoke of the plant, far away: a thin pale column that rises straight and spreads a little as it climbs, the
    edges and the top dithered into the sky. Flat; 16 x `height` (168 for the pass, anchor (8, 166); 96 for the valley, where
    the plant stands close: anchor (8, 94))."""
    c = ms.Canvas(16, height)
    b = pa.BAYER4[np.arange(height)[:, None] % 4, np.arange(16)[None, :] % 4]
    for y in range(height):
        t = y / (height - 1.0)  # 0 at the top, 1 at the foot
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


# =========================================================================== Hochtal (G2): the Anlage and the things of the valley
BRASS = ramp("#3e2c0e", "#6e4e16", "#a8802c", "#dcb850")
QUARTZ = ramp("#56688a", "#9bb2d0", "#d2e2f2", "#f6fbff")
GLASS_COLD = ramp("#1c2a34", "#34505e", "#6a8c9c", "#b6d0da")  # a window on a clear day: the sky and the mountain in it
PEWTER = ramp("#2c2f36", "#565c68", "#8c94a2", "#c8d0dc")  # the thimble's metal
CARDBOARD = ramp("#4e3a1e", "#7e6236", "#a8844c", "#cfae6e")
PAINT_EYE = ramp("#6a8a98", "#a6c4d0", "#dcebf0", "#fbfdfd")
NEEDLES = ramp("#0f241d", "#1a3a2c", "#285238", "#3c6c48", "#639a5c")  # a mountain pine's dark blue-green


def _blocks(c, x0, y0, x1, y1, course, bw, ramp_k, rng, base=0.46, lit=0.14, stagger=True):
    """Ashlar: orderly courses of cut blocks, a dark joint under each course and between the blocks, the top edge of each lit."""
    area = c.rect(x0, y0, x1, y1)
    row = ((c.yy - y0) // course).astype(int)
    off = (row % 2) * (bw // 2) if stagger else 0
    col = ((c.xx - x0 + off) // bw).astype(int)
    tone = ((row * 7919 + col * 104729) % 97) / 97.0
    grain = pa.value_noise(c.h, c.w, 2.5, rng)
    v = base + 0.14 * (tone - 0.5) + 0.08 * (grain - 0.5)
    v = np.where((c.yy - y0) % course == 0, v + lit, v)
    v = np.where((c.yy - y0) % course == course - 1, 0.08, v)
    v = np.where(((c.xx - x0 + off) % bw) == bw - 1, 0.1, v)
    c.paint(area, ramp_k, v, contrast=2.0, dither=False)
    return area


def _disc(c, cx, cy, r):
    return np.hypot(c.xx + 0.5 - cx, c.yy + 0.5 - cy) <= r


def _gauge(c, cx, cy, r, angle, ex):
    """A round dial on the wall: an iron ring, a pale face with tick marks (no numerals), a needle, a glint on the glass."""
    c.paint(_disc(c, cx, cy, r + 2), BRIGHT_IRON, 0.25 + 0.55 * c.sphere(cx - 2, cy - 2, r + 3, r + 3), dither=False)
    face = _disc(c, cx, cy, r - 0.5)
    c.paint(face, CHALK, 0.72 + 0.2 * c.sphere(cx - 2, cy - 2, r + 2, r + 2), dither=False)
    for k in range(12):
        a = k / 12 * 2 * np.pi
        tx, ty = cx + np.cos(a) * (r - 2.2), cy + np.sin(a) * (r - 2.2)
        c.fill(c.rect(int(round(tx)), int(round(ty)), int(round(tx)) + 1, int(round(ty)) + 1), CHALK[0] * 0.5)
    nx, ny = cx + np.cos(angle) * (r - 2.5), cy + np.sin(angle) * (r - 2.5)
    for i in range(0, 11):
        t = i / 10
        x, y = int(round(cx + (nx - cx) * t)), int(round(cy + (ny - cy) * t))
        c.fill(c.rect(x, y, x + 1, y + 1), np.array([196, 58, 44], np.float32))
    c.fill(c.rect(int(cx) - 1, int(cy) - 1, int(cx) + 1, int(cy) + 1), ex["iron"][1])
    c.fill(c.rect(int(cx) - 5, int(cy) - 5, int(cx) - 3, int(cy) - 4), CHALK[3])


def plant_hall(ms):
    """The Anlage, seen from the front: a long hall of cut stone on a foundation of rough blocks, a slate roof with a lantern on its
    ridge and a tall chimney, a double door of dark wood with iron straps and a brass lock, a dial on either side of it, narrow windows
    with the sky in them, pipes down both ends that run along the foot of the wall. Everything is square and in its place; the only
    soft things are the rust under the flanges and a little moss. No lamp, no light. 192 x 168, anchor (96, 162) (the foot of the
    wall); the chimney stands two cells east of the middle, its cap at row 4: the smoke's cell is nine rows and a half above."""
    rng = np.random.default_rng(2001)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(192, 168)
    # ---- the wall of cut stone, in the shade of the eaves at its top
    _blocks(c, 8, 90, 184, 152, 8, 22, ex["stone_wall"], rng, base=0.5, lit=0.12)
    c.paint(c.rect(8, 90, 184, 96), ex["stone_wall"], 0.2, dither=False)
    c.paint(c.rect(8, 96, 184, 99), ex["stone_wall"], 0.32, dither=False)
    # ---- the foundation of rough blocks, moss in the joints
    f1, f2, cid = pa.worley(c.h, c.w, 7, rng)
    found = c.rect(6, 150, 186, 162)
    c.paint(found, ex["stone_wall"], np.where(f2 - f1 < 0.9, 0.08, 0.26 + 0.42 * pa.bump_light(np.clip(f2 - f1, 0, 3))), dither=False)
    c.paint(found & (pa.value_noise(c.h, c.w, 2, rng) > 0.74) & (c.yy < 158), st["foliage"], 0.3, dither=False)
    # ---- the roof: slate shingles in orderly rows, the ridge capped with iron, a lantern on it
    top, bot = 46, 92
    t = (c.yy - top) / (bot - top)
    roof = c.rect(0, top, 192, bot + 2) & (c.xx >= 22 - 20 * t) & (c.xx <= 170 + 20 * t)
    yy, xx = c.yy.astype(int), c.xx.astype(int)
    row = (yy - top) // 5
    ry = (yy - top) % 5
    sx = (xx + (row % 2) * 4) % 8
    shingle = ((row * 7919 + (xx + (row % 2) * 4) // 8 * 104729) % 97) / 97.0
    rv = 0.66 - 0.4 * (yy - top) / (bot - top) + 0.14 * (shingle - 0.5)
    rv = np.where(ry == 0, rv + 0.1, rv)
    rv = np.where(sx == 7, rv - 0.22, rv)
    rv = np.where(ry == 4, 0.06, rv)
    c.paint(roof, ex["roof"], rv, contrast=2.2, dither=False)
    c.paint(roof & (pa.value_noise(c.h, c.w, (1, 5), rng) > 0.88) & (ry == 1), ex["roof"], 0.95, dither=False)
    c.paint(c.rect(0, bot - 1, 192, bot + 2) & roof, ex["roof"], 0.12, dither=False)  # the eaves' dark edge
    c.paint(c.rect(22, 42, 170, 47), ex["iron"], np.where(c.yy <= 43, 0.85, 0.35), dither=False)  # the ridge cap
    # the lantern on the ridge: a small box with slats and a cap of its own
    c.paint(c.rect(62, 28, 88, 44), ex["iron"], np.where(c.xx < 70, 0.7, 0.4), dither=False)
    for y in range(31, 43, 3):
        c.fill(c.rect(64, y, 86, y + 1), ex["iron"][0])
    c.paint(c.rect(59, 25, 91, 29), ex["iron"], np.where(c.yy <= 26, 0.9, 0.4), dither=False)
    c.paint(c.rect(70, 20, 80, 26), ex["iron"], 0.5, dither=False)
    # ---- the chimney: square stone, two iron straps, a cap with the dark opening
    _blocks(c, 121, 8, 135, 74, 7, 14, ex["stone_wall"], rng, base=0.44, lit=0.1, stagger=False)
    c.paint(c.rect(121, 8, 135, 74) & (c.xx >= 131), ex["stone_wall"], 0.2, dither=False)  # its shaded east side
    for y in (26, 46):
        c.paint(c.rect(120, y, 136, y + 2), ex["iron"], 0.6, dither=False)
    c.paint(c.rect(117, 70, 139, 76), ex["iron"], np.where(c.yy < 72, 0.7, 0.3), dither=False)  # the flashing where it meets the slate
    c.paint(c.rect(118, 4, 138, 10), ex["stone_wall"], np.where(c.yy <= 5, 0.86, 0.5), dither=False)
    c.fill(c.ellipse(128, 6, 6.0, 1.7), ex["iron"][0])
    # ---- the windows: tall and narrow, with the clear sky in them
    for wx in (20, 158):
        c.paint(c.rect(wx - 2, 102, wx + 16, 134), ex["iron"], 0.5, dither=False)
        pane = c.rect(wx, 104, wx + 14, 130)
        c.paint(pane, GLASS_COLD, 0.2 + 0.7 * (1 - (c.yy - 104) / 26) + 0.08 * ((c.xx - wx) < 7), dither=False)
        for k in range(4):  # a pale streak of cloud across the glass
            c.fill(c.rect(wx + 2 + k, 108 + k * 2, wx + 6 + k, 109 + k * 2) & pane, GLASS_COLD[3])
        c.paint(c.rect(wx + 6, 104, wx + 8, 130), ex["iron"], 0.35, dither=False)
        c.paint(c.rect(wx, 116, wx + 14, 118), ex["iron"], 0.35, dither=False)
        c.paint(c.rect(wx - 3, 134, wx + 17, 137), ex["stone_wall"], 0.78, dither=False)  # the sill
    # ---- two dials, either side of the door; the needles do not agree
    _gauge(c, 56, 118, 9, -0.9, ex)
    _gauge(c, 136, 118, 9, -2.3, ex)
    # ---- the door: the stone jambs and lintel, a double leaf of dark wood, three iron straps with rivets, a brass lock
    c.paint(c.rect(73, 108, 119, 152), ex["stone_wall"], np.where(c.xx < 78, 0.78, 0.56), dither=False)
    c.paint(c.rect(73, 108, 119, 114), ex["stone_wall"], np.where(c.yy < 110, 0.9, 0.5), dither=False)
    c.paint(c.rect(92, 108, 100, 114), ex["stone_wall"], 0.85, dither=False)  # the keystone
    leaf = c.rect(78, 114, 114, 152)
    planks = ((c.xx - 78) // 6).astype(int)
    grain = pa.value_noise(c.h, c.w, (6, 1), rng)
    c.paint(leaf, ex["plank"], np.where(((c.xx - 78) % 6) == 5, 0.1, 0.28 + 0.1 * ((planks * 13) % 5) / 5.0 + 0.12 * (grain - 0.5)), dither=False)
    c.paint(c.rect(95, 114, 97, 152), ex["iron"], 0.3, dither=False)  # the gap between the leaves
    for y in (120, 134, 146):
        c.paint(c.rect(78, y, 114, y + 3), ex["iron"], np.where(c.yy == y, 0.75, 0.4), dither=False)
        for x in range(81, 113, 6):
            c.fill(c.rect(x, y + 1, x + 1, y + 2), BRIGHT_IRON[3])
    c.paint(c.rect(92, 138, 95, 144), BRASS, 0.7, dither=False)  # the lock, one leaf
    c.fill(c.rect(93, 139, 94, 140), BRASS[3])
    c.paint(c.rect(97, 138, 100, 144), BRASS, 0.5, dither=False)
    c.paint(c.rect(70, 152, 122, 156), ex["stone_wall"], np.where(c.yy < 153, 0.9, 0.55), dither=False)  # the steps
    c.paint(c.rect(66, 156, 126, 161), ex["stone_wall"], np.where(c.yy < 157, 0.8, 0.45), dither=False)
    # ---- the pipes: one at each end of the wall, up over the roof's edge, and along the foot of the wall to the door
    for px in (10, 174):
        c.paint(c.rect(px, 70, px + 5, 152), BRIGHT_IRON, np.where(c.xx < px + 2, 0.78, np.where(c.xx > px + 3, 0.2, 0.46)), dither=False)
        for fy in (96, 126, 146):
            c.paint(c.rect(px - 1, fy, px + 6, fy + 3), BRIGHT_IRON, np.where(c.yy == fy, 0.9, 0.3), dither=False)
            c.paint(c.rect(px + 1, fy + 3, px + 3, fy + 8), RUST, 0.55, dither=False)  # rust under the flange
        c.paint(c.rect(px - 1, 66, px + 6, 71), BRIGHT_IRON, 0.5, dither=False)
    for x0, x1 in ((15, 73), (119, 174)):
        c.paint(c.rect(x0, 144, x1, 149), BRIGHT_IRON, np.where(c.yy < 146, 0.8, np.where(c.yy > 147, 0.18, 0.46)), dither=False)
        for fx in range(x0 + 14, x1 - 6, 22):
            c.paint(c.rect(fx, 143, fx + 3, 150), BRIGHT_IRON, np.where(c.xx == fx, 0.9, 0.3), dither=False)
            c.paint(c.rect(fx, 150, fx + 2, 155), RUST, 0.5, dither=False)
    # a valve with a wheel on the left pipe
    c.paint(c.rect(37, 138, 43, 144), BRIGHT_IRON, 0.5, dither=False)
    c.paint(c.rect(39, 129, 41, 138), BRIGHT_IRON, 0.4, dither=False)
    c.paint(c.ellipse(40, 128, 6.0, 2.6) & ~c.ellipse(40, 128, 3.4, 1.2), RUST, 0.8, dither=False)  # the wheel's rim
    c.paint(c.rect(34, 127, 47, 129), RUST, 0.55, dither=False)  # a spoke across
    c.fill(c.rect(39, 127, 41, 129), BRIGHT_IRON[3])
    c.outline(st["outline"])
    return c


def plant_fence(ms):
    """One cell of the Anlage's fence: a palisade of iron bars with pointed heads between two rails, a post at its west edge, the
    bars straight and evenly spaced. 16 x 30, anchor (8, 24) (the foot of the bars): the next piece stands exactly beside it."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 30)
    for bx in (3, 7, 11):  # the bars, a pointed head each
        c.paint(c.rect(bx, 6, bx + 2, 25), BRIGHT_IRON, np.where(c.xx == bx, 0.82, 0.3), dither=False)
        c.fill(c.rect(bx, 4, bx + 2, 6), BRIGHT_IRON[3])
        c.fill(c.rect(bx, 3, bx + 1, 4), BRIGHT_IRON[4])
    for y in (10, 19):  # the rails
        c.paint(c.rect(0, y, 16, y + 2), BRIGHT_IRON, np.where(c.yy == y, 0.8, 0.28), dither=False)
    c.paint(c.rect(0, 1, 3, 26), BRIGHT_IRON, np.where(c.xx < 1, 0.85, 0.36), dither=False)  # the post
    c.fill(c.rect(0, 0, 3, 2), BRIGHT_IRON[4])
    c.paint(c.rect(1, 21, 2, 24), RUST, 0.55, dither=False)
    c.outline(st["outline"])
    return c


def _gate_plate(c):
    """The little brass sign on the left pillar of the gate (its words are the dialogue's): a plate with two lines of scratches. 8 x 6."""
    c.paint(c.rect(1, 22, 9, 28), BRASS, np.where(c.yy < 24, 0.85, 0.6), dither=False)
    c.fill(c.rect(2, 24, 8, 25), BRASS[1])
    c.fill(c.rect(2, 26, 7, 27), BRASS[1])
    c.fill(c.rect(1, 22, 2, 23), BRASS[3])


def plant_gate(ms):
    """The gate of the Anlage, shut: two pillars of stone with a ball on each, between them two leaves of iron bars with a brace, a
    chain through the middle and a lock hanging on it. 48 x 44, anchor (24, 38): it fills the three cells of its row."""
    rng = np.random.default_rng(2003)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 44)
    for x0 in (0, 38):
        _blocks(c, x0, 8, x0 + 10, 40, 6, 10, ex["stone_wall"], rng, base=0.5, lit=0.1, stagger=False)
        c.paint(c.rect(x0 - 1 if x0 else 0, 5, x0 + 10 if x0 == 0 else 48, 9), ex["stone_wall"], np.where(c.yy < 6, 0.9, 0.55), dither=False)
        ball = c.ellipse(x0 + 5, 3.5, 3.4, 3.2)
        c.paint(ball, ex["stone_wall"], 0.3 + 0.65 * c.sphere(x0 + 4, 2.5, 4, 4), dither=False)
    for lx0, lx1 in ((10, 24), (24, 38)):  # the leaves
        c.paint(c.rect(lx0, 12, lx1, 14), BRIGHT_IRON, np.where(c.yy == 12, 0.8, 0.3), dither=False)
        c.paint(c.rect(lx0, 34, lx1, 36), BRIGHT_IRON, np.where(c.yy == 34, 0.8, 0.3), dither=False)
        for bx in range(lx0 + 1, lx1 - 1, 4):
            c.paint(c.rect(bx, 14, bx + 2, 34), BRIGHT_IRON, np.where(c.xx == bx, 0.8, 0.28), dither=False)
            c.fill(c.rect(bx, 12, bx + 2, 13), BRIGHT_IRON[4])
    for lx0, lx1 in ((10, 24), (24, 38)):  # a middle rail across both leaves
        c.paint(c.rect(lx0, 23, lx1, 25), BRIGHT_IRON, np.where(c.yy == 23, 0.8, 0.3), dither=False)
    c.paint(c.rect(23, 14, 25, 34), ex["iron"], 0.35, dither=False)  # the gap between the leaves
    for x in range(18, 31, 2):  # the chain through both leaves
        c.fill(c.rect(x, 21, x + 1, 23), BRASS[1] if (x // 2) % 2 else BRASS[2])
    c.paint(c.rect(21, 25, 28, 32), BRASS, 0.72, dither=False)  # the lock, hanging from it
    c.fill(c.rect(22, 26, 24, 27), BRASS[3])
    c.fill(c.rect(24, 23, 25, 25), BRASS[2])
    c.fill(c.rect(24, 28, 25, 30), ex["iron"][0])
    c.paint(c.rect(10, 36, 38, 40), ex["stone_wall"], 0.38, dither=False)  # the sill
    _gate_plate(c)
    c.outline(st["outline"])
    return c


def dwarf_pine(ms, seed):
    """A mountain pine (Latsche): a low, wide shrub of dark blue-green needles spread along the ground, flatter than a bush, pale
    young growth on the tips, short strokes of needles on its lit side, a few bare brown stems at the foot. 48 x 32, anchor (24, 28)."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 32)
    for x0, side in ((16, 1), (30, -1)):  # stems from the foot
        for y in range(22, 29):
            x = x0 + (y - 22) // 3 * side
            c.fill(c.rect(x, y, x + 2, y + 1), ex["bark"][2])
    blobs = []
    for k in range(11):
        a = k / 10 * np.pi + rng.uniform(-0.12, 0.12)
        blobs.append((20.5 + rng.uniform(-2, 3) - 5 * np.sin(a), 24 + np.cos(a) * rng.uniform(15.5, 19.5), rng.uniform(5.0, 7.2)))
    blobs += [(16 + rng.uniform(-1.5, 1.5), 24 + rng.uniform(-7, 7), rng.uniform(6.0, 7.6)), (21, 24, 7.5)]
    alpha, value = pa.render_foliage((32, 48), blobs, rng, small=(2.2, 3.6))
    alpha &= c.yy < 28
    value = np.where(c.yy > 22, value * 0.7, value)
    c.paint(alpha, NEEDLES, 0.05 + 0.8 * value, contrast=3.0, dither=False)
    tips = alpha & (value > 0.78) & (pa.value_noise(32, 48, 2.5, rng) > 0.5)  # young growth, a paler green
    c.paint(tips, ramp("#3c6c48", "#639a5c", "#8cb870"), 0.6, dither=False)
    for _ in range(26):  # strokes of needles on the lit side
        x, y = int(rng.integers(5, 40)), int(rng.integers(6, 24))
        if alpha[y, x] and value[y, x] > 0.35:
            c.fill(c.rect(x, y, x + 2, y + 1) & alpha, NEEDLES[4] if value[y, x] > 0.6 else NEEDLES[3])
    c.outline(st["outline"])
    return c


def hand_stone(ms):
    """A flat grey stone at the water's edge, smooth, the top lit; on it the print of a small hand, darker, still wet: the palm, five
    fingers spread, a bright rim of water at the heel, a drop beside it. Flat; 34 x 22, anchor (17, 11)."""
    rng = np.random.default_rng(2005)
    st = pa.STYLES["tal"]
    c = ms.Canvas(34, 22)
    slab = _poly(c, [(2, 12), (5, 5), (14, 2), (26, 3), (32, 9), (30, 17), (20, 20), (8, 19)])
    c.paint(slab, st["rock"], 0.5 + 0.28 * (c.yy < 9) + 0.1 * (pa.value_noise(22, 34, 3, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(slab & (c.yy > 16), st["rock"], 0.14, dither=False)
    c.paint(slab & (c.xx + c.yy < 17), st["rock"], 0.86, dither=False)
    # the hand: a grid of its own (. empty, d wet dark, m wet middle, w the water's rim), heel at the bottom, fingers up and spread
    hand = ("......dd......",
            "...dd.dd.dd...",
            "...dd.dd.dd...",
            "...dd.dd.dd.dd",
            "...dd.dd.dd.dd",
            "...dd.dd.dd.dd",
            "..dddddddddddd",
            ".ddmmmmmmmmmdd",
            "ddmmmmmmmmmmdd",
            ".dmmmmmmmmmmd.",
            "..dmmmmmmmmd..",
            "...dmmmmmmd...",
            "....dmmmmd....",
            ".....wwww.....")
    ox, oy = 10, 4
    ramp_w = np.array([[44, 52, 62], [64, 76, 88], [120, 148, 168], [196, 224, 238]], np.float32)
    for j, line in enumerate(hand):
        for i, ch in enumerate(line):
            if ch == ".":
                continue
            x, y = ox + i, oy + j
            if 0 <= x < c.w and 0 <= y < c.h and slab[y, x]:
                col = {"d": ramp_w[0], "m": ramp_w[1], "w": ramp_w[3]}[ch]
                c.fill(c.rect(x, y, x + 1, y + 1), col)
    for i in (3, 6, 9, 12):  # the water on the fingertips, a glint on each
        c.fill(c.rect(ox + i, oy + 1 + (i == 6) * -1, ox + i + 1, oy + 2 + (i == 6) * -1) & slab, ramp_w[2])
    c.fill(c.rect(ox + 11, oy + 14, ox + 12, oy + 15) & slab, ramp_w[3])  # a drop that ran off the heel
    c.outline(st["outline"])
    return c


def round_stone(ms):
    """A small round stone, smooth, the grey of the cairns' stones with a green cast, a pale glint on its upper left, lying where the
    wind put it. Flat; 12 x 10, anchor (6, 5)."""
    rng = np.random.default_rng(2007)
    st = pa.STYLES["tal"]
    c = ms.Canvas(12, 10)
    body = c.ellipse(6, 5.2, 4.6, 3.8)
    c.paint(body, st["rock"], 0.46 + 0.5 * c.sphere(4.2, 3.2, 5, 4.2) + 0.06 * (pa.value_noise(10, 12, 2, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(body & (c.yy > 6.6), st["rock"], 0.12, dither=False)
    c.fill(c.rect(4, 3, 6, 4) & body, st["rock"][4])
    c.outline(st["outline"])
    return c


def quartz(ms):
    """A rock crystal in the scree, finger-long and broken at one end: one prism standing a little aslant, its point up and its foot
    a jagged break, pale blue-white, a bright facet on the left and a dark one on the right, two small shards beside it and a few
    chips of grey stone at its foot. 18 x 24, anchor (9, 22)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(18, 24)
    for cx, w, top, base, lean in ((9.5, 6, 3, 21, -0.1), (3.6, 3, 13, 21, -0.25), (14.6, 3, 15, 21, 0.2)):
        prism = np.zeros((c.h, c.w), bool)
        left = np.zeros((c.h, c.w), bool)
        for y in range(top, base):
            mid = cx + lean * (base - y)
            half = w / 2 * (min(1.0, 0.3 + (y - top) / 4.0))
            row = (c.yy == y) & (c.xx + 0.5 >= mid - half) & (c.xx + 0.5 <= mid + half)
            if y >= base - 2 and w == 6:  # the break at the foot of the big one: jagged
                row &= ((c.xx + y) % 3 != 0)
            prism |= row
            left |= row & (c.xx + 0.5 < mid - half + 1.8)
        shade_dark = c.xx + 0.5 > cx + lean * (base - c.yy) + w / 2 - 1.6
        c.paint(prism, QUARTZ, np.where(left, 0.95, np.where(shade_dark, 0.2, 0.62)), contrast=2.0, dither=False)
        c.fill(c.rect(int(cx + lean * (base - top - 5) - w / 2 + 1), top + 5, int(cx + lean * (base - top - 5) - w / 2 + 2), top + 10) & prism, QUARTZ[3])
    for x, y, w, h in ((1, 20, 4, 2), (13, 21, 4, 2), (6, 21, 5, 2)):
        c.paint(c.rect(x, y, x + w, y + h), st["rock"], 0.42 + 0.3 * (c.xx < x + 2), dither=False)
    c.outline(st["outline"])
    return c


def marmot_den(ms):
    """The marmot's den on its slope: a grassy mound with the dark mouth of the burrow in it, the earth thrown out in front, and on
    the earth what a marmot thinks is important (a spoon handle, a button, a hat made of cardboard), with a dent in
    the middle where one more thing lay; the thimble is a prop of its own that sits in it. 72 x 58, anchor (36, 36): the mouth lies
    a little above the cell, the earth below it down to the dent, which is 14 pixels under the anchor (the thimble's cell is one
    below, lifted by 2)."""
    rng = np.random.default_rng(2011)
    st = pa.STYLES["tal"]
    c = ms.Canvas(72, 58)
    # the apron of thrown-out earth and the pale pebbles in it
    earth = c.ellipse(36, 42, 31, 13) & (c.yy > 24)
    c.paint(earth, st["mud"], 0.5 + 0.2 * (pa.value_noise(58, 72, 4, rng) - 0.5) + 0.22 * (c.yy < 36), contrast=2.0, dither=False)
    c.paint(earth & (c.yy > 51), st["mud"], 0.16, dither=False)
    # the mound: a rock the burrow goes in under, lit from the left, grass on its top
    mound = c.ellipse(36, 22, 27, 15) & (c.yy < 33)
    f1, f2, cid = pa.worley(58, 72, 8, rng, 0.9)
    facet = ((cid * 7919) % 97) / 97.0
    c.paint(mound, st["rock"], 0.2 + 0.6 * c.sphere(28, 12, 30, 20) + 0.14 * (facet - 0.5) - np.where(f2 - f1 < 0.7, 0.2, 0.0), contrast=2.2, dither=False)
    c.paint(mound & (c.yy > 29), st["rock"], 0.08, dither=False)
    cap = mound & (c.yy < 11 + 7 * pa.value_noise(58, 72, 4, rng))
    c.paint(cap, st["grass"], 0.32 + 0.55 * c.sphere(28, 8, 30, 14), contrast=2.2, dither=False)
    # the mouth: a dark oval with a lit lip
    mouth = c.ellipse(36, 26, 9.5, 5.5)
    c.paint(c.ellipse(36, 26.5, 11.5, 6.8), st["mud"], 0.5 + 0.3 * (c.yy < 26), dither=False)
    c.fill(mouth, st["outline"] * 0.7)
    c.fill(c.ellipse(36, 27.5, 6.5, 3.2), np.array([14, 10, 12], np.float32))
    # the hoard
    for k in range(10):  # a spoon's handle and its bowl
        x, y = 12 + k, 44 - k // 5
        c.paint(c.rect(x, y, x + 1, y + 1), PEWTER, 0.8 - 0.3 * (k % 2), dither=False)
    c.paint(c.ellipse(11, 44.6, 3.0, 1.9), PEWTER, 0.9, dither=False)
    c.fill(c.ellipse(11.5, 44.3, 1.3, 0.8), PEWTER[3])
    c.paint(c.ellipse(22.5, 48.5, 3.6, 3.0), CHALK, 0.8 + 0.1 * c.sphere(21, 47, 5, 4), dither=False)  # a button without its trousers
    for dx, dy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
        c.fill(c.rect(int(22.5 + dx), int(48 + dy), int(22.5 + dx) + 1, int(48 + dy) + 1), CHALK[0] * 0.55)
    hat = _poly(c, [(52, 47), (55, 37), (58, 47)])  # a hat of cardboard, a cone, and its string
    c.paint(hat, CARDBOARD, np.where(c.xx < 55, 0.7, 0.35), contrast=2.0, dither=False)
    c.paint(c.rect(51, 46, 60, 48), CARDBOARD, 0.55, dither=False)
    c.fill(c.rect(55, 36, 56, 37), CHALK[2])
    c.fill(c.rect(58, 43, 61, 44), CARDBOARD[1])
    c.paint(c.ellipse(36, 51.5, 4.4, 1.9), st["mud"], 0.12, dither=False)  # the dent, where the thimble lay
    c.paint(c.ellipse(36, 51, 3.0, 1.1), st["mud"], 0.32, dither=False)
    c.outline(st["outline"])
    return c


def thimble(ms):
    """A thimble, standing, the open end down: pewter, a dome on top, the sides widening a little to the rim, dimples in rows, a glint.
    11 x 11, anchor (5, 10)."""
    c = ms.Canvas(11, 11)
    half = {1: 2.0, 2: 3.2, 3: 3.8, 4: 4.0, 5: 4.2, 6: 4.4, 7: 4.6, 8: 4.8, 9: 5.2}
    body = np.zeros((11, 11), bool)
    for y, h in half.items():
        body |= (c.yy == y) & (np.abs(c.xx + 0.5 - 5.5) <= h)
    c.paint(body, PEWTER, np.where(c.xx < 4, 0.92, np.where(c.xx > 6, 0.22, 0.6)), contrast=2.0, dither=False)
    for y in (3, 5, 7):
        for x in range(2 + (y // 2) % 2, 10, 2):
            c.fill(c.rect(x, y, x + 1, y + 1) & body, PEWTER[0])
    c.paint(c.rect(0, 9, 11, 10) & body, PEWTER, 0.88, dither=False)  # the rim
    c.paint(c.rect(0, 10, 11, 11) & ~body, PEWTER, 0.18, dither=False)
    c.fill(c.rect(4, 1, 5, 2), PEWTER[3])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def view_sign(ms):
    """The sign at the entrance of the valley: a post and a rectangular board nailed on a little askew, the word painted on it in
    letters of different sizes (strokes, nothing one can read), and under it a painted arrow pointing left, the paint run. The
    arrow is the sign's point. 38 x 46, anchor (19, 44)."""
    rng = np.random.default_rng(2013)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(38, 46)
    grain = pa.value_noise(46, 38, (1, 5), rng)
    post = c.rect(17, 8, 22, 45)
    c.paint(post, ex["plank"], np.where(c.xx < 19.5, 0.6, 0.26) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.ellipse(19.5, 44, 7, 1.8), st["stone"], 0.3, dither=False)
    tilt = (c.xx - 19) * 0.07
    board = (c.xx >= 3) & (c.xx < 35) & (c.yy >= 4 + tilt) & (c.yy < 26 + tilt)
    c.paint(board, ex["plank"], 0.58 + 0.14 * (1 - (c.yy - 4) / 22) + 0.14 * (grain - 0.5), contrast=2.0)
    c.paint(c.rect(3, 25, 35, 28) & board, ex["plank"], 0.1, dither=False)
    # the word: eight letters of different heights, a stroke and a crossbar each, the line running downhill
    for k, h in enumerate((7, 5, 8, 6, 4, 8, 5, 7)):
        x = int(5 + k * 3.6)
        y0 = int(7 + (x - 19) * 0.07) + (8 - h) // 2 + (k % 2)
        c.fill(c.rect(x, y0, x + 2, y0 + h), PAINT_EYE[2 + (k % 3 == 0)])
        c.fill(c.rect(x + 2, y0 + h // 2, x + 3, y0 + h // 2 + 1), PAINT_EYE[2])
    # the arrow under it, pointing left, with a drip off its tail
    ay = 20
    c.fill(c.rect(11, ay, 30, ay + 2), PAINT_EYE[3])
    for k in range(5):  # the head: its point at x 7, widening towards the shaft
        c.fill(c.rect(7 + k, ay - k + 1, 8 + k, ay + 2 + k - 1 + 1), PAINT_EYE[3])
    c.fill(c.rect(29, ay + 2, 30, ay + 7), PAINT_EYE[1])  # a drip
    c.fill(c.rect(5, 6, 7, 8) & board, ex["iron"][3])
    c.fill(c.rect(31, 6, 33, 8) & board, ex["iron"][3])
    c.outline(st["outline"])
    return c


# =========================================================================== Das Verstecken (G6): the fork, the hollow, the candle
CHARCOAL = ramp("#16141a", "#2a2628", "#4a4446", "#6e6666")  # a stick of charcoal drawn over wood: black, with a smudged grey
WAX = ramp("#5e5240", "#a89878", "#d0c29c", "#ebe0c0", "#faf6e6")  # old hard wax, the item icon's colours
WOOL = ramp("#3e2418", "#5e3a2a", "#8a5a3e", "#b98258")  # a rolled blanket: brown wool, as in the fragment
DAYLIGHT = ramp("#a89868", "#d8c48c", "#f3e8b8", "#fff6d8")  # the strip of light that falls through the crack


def _strokes(c, x0, step, heights, ink, bars=()):
    """Charcoal 'writing' that is not writing: one stroke per letter (a column of pixels, `heights` = (top row, bottom row) each), a
    crossbar on the strokes in `bars`, the strokes `step` pixels apart from `x0` on. Nothing in it can be read."""
    for k, (y0, y1) in enumerate(heights):
        x = x0 + k * step
        c.fill(c.rect(x, y0, x + 1, y1 + 1), ink[1] if k % 3 else ink[0])
        if k in bars:
            c.fill(c.rect(x + 1, y0 + 1, x + 2, y0 + 2), ink[1])


def fork_sign(ms):
    """The signpost at the fork of the Grat: one post, a weathered board on it in two planks, and on each plank an arrow drawn in charcoal
    (the upper one points up, the lower one down) with a few strokes beside it, a word each, no letter in them. The two halves weigh the
    same: the same arrow, the same length of word, no cross, no mark, nothing to say which way is better. 24 x 26, anchor (12, 24)."""
    rng = np.random.default_rng(2301)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(24, 26)
    grain = pa.value_noise(26, 24, (1, 5), rng)
    post = c.rect(10, 12, 14, 25)
    c.paint(post, ex["plank"], np.where(c.xx < 11.5, 0.5, 0.2) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.ellipse(12, 24.4, 6.5, 1.7), st["stone"], 0.3, dither=False)  # the stones heaped round its foot
    board = c.rect(2, 2, 22, 17)
    c.paint(board, ex["plank"], 0.64 + 0.12 * (1 - (c.yy - 2) / 15) + 0.12 * (grain - 0.5), contrast=2.0)
    c.paint(c.rect(2, 2, 22, 3), ex["plank"], 0.92, dither=False)  # the lit top edge
    c.paint(c.rect(2, 9, 22, 10), ex["plank"], 0.1, dither=False)  # the seam between the two planks
    c.paint(c.rect(2, 16, 22, 17), ex["plank"], 0.1, dither=False)
    # the upper arrow (point up) and the lower one (point down): a three-pixel head on a three-pixel shaft each, the shaft one stroke thick
    for x0, x1, y in ((5, 5, 3), (4, 6, 4), (3, 7, 5)):
        c.fill(c.rect(x0, y, x1 + 1, y + 1), CHARCOAL[1])
    c.fill(c.rect(5, 6, 6, 9), CHARCOAL[1])
    c.fill(c.rect(5, 10, 6, 13), CHARCOAL[1])
    for x0, x1, y in ((3, 7, 13), (4, 6, 14), (5, 5, 15)):
        c.fill(c.rect(x0, y, x1 + 1, y + 1), CHARCOAL[1])
    c.fill(c.rect(5, 3, 6, 4), CHARCOAL[0])
    c.fill(c.rect(5, 15, 6, 16), CHARCOAL[0])
    # the words beside them: five strokes beside the upper arrow, six beside the lower one
    _strokes(c, 10, 2, [(4, 7), (5, 7), (4, 7), (5, 8), (4, 7)], CHARCOAL, bars=(2,))
    _strokes(c, 9, 2, [(11, 14), (12, 14), (11, 14), (11, 15), (12, 14), (11, 14)], CHARCOAL, bars=(3,))
    for x, y in ((7, 8), (8, 13), (20, 6), (19, 15)):  # a smudge where a thumb was
        c.fill(c.rect(x, y, x + 1, y + 1) & board, CHARCOAL[3])
    c.fill(c.rect(21, 3, 22, 4), ex["iron"][3])
    c.fill(c.rect(21, 15, 22, 16), ex["iron"][3])
    c.outline(st["outline"])
    return c


def cleft_alcove(ms):
    """The hollow at the end of the cleft: a block of the cliff's own warm grey stone, rounded on top, and cut into its front an arch, just
    deep enough for someone small to crouch in. Inside it is dark; on the floor lies a blanket rolled up, its end towards the light; a thin
    crack runs down through the stone from the upper left into the hollow, and a strip of light falls aslant from it to the floor and
    ends at the rim of the blanket. Nothing and nobody else. 24 x 28, anchor (12, 26): the block's foot, the cell's middle at its sill."""
    rng = np.random.default_rng(2303)
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 28)
    body = (c.rect(1, 8, 23, 27) | c.ellipse(12, 12.5, 11.5, 9.5)) & ~(c.rect(0, 25, 2, 28) | c.rect(22, 25, 24, 28))
    f1, f2, cid = pa.worley(28, 24, 5, rng, 0.9)
    facet = ((cid * 7919) % 97) / 97.0
    v = 0.3 + 0.5 * c.sphere(8, 8, 17, 18) + 0.16 * (facet - 0.5) + 0.08 * (pa.value_noise(28, 24, 3, rng) - 0.5)
    v = np.where(f2 - f1 < 0.8, v - 0.2, v)  # the dark joints between the stones
    v = v + 0.16 * (cid != np.roll(cid, 1, 0)) - 0.14 * (cid != np.roll(cid, -1, 0))  # every stone lit along its top and dark under
    c.paint(body, st["cliff"], v, contrast=2.0, dither=False)
    c.paint(body & (c.yy >= 25), st["cliff"], 0.06, dither=False)  # the dark foot
    c.paint(body & (c.yy >= 23) & (c.yy < 25), st["cliff"], 0.78, dither=False)  # the sill, lit on its top
    # the arch cut into the front: its reveal lit on the upper left, dark on the lower right, then the hollow itself, almost black
    arch = (c.rect(6, 13, 18, 23) | c.ellipse(12, 13, 6, 5.6)) & body
    inner = (c.rect(7, 14, 17, 23) | c.ellipse(12, 13.6, 5, 5)) & arch
    reveal = arch & ~inner
    c.paint(reveal, st["cliff"], np.where((c.xx < 12) | (c.yy < 12), 0.92, 0.12), dither=False)
    c.fill(inner, np.array([20, 18, 22], np.float32))  # the back wall
    c.fill(inner & (c.yy >= 17), np.array([26, 24, 28], np.float32))  # a little lighter lower down
    c.fill(inner & (c.xx < 8.5), np.array([12, 11, 15], np.float32))  # the left side of the hollow in its own shadow
    c.fill(inner & (c.yy >= 21), np.array([56, 52, 54], np.float32))  # the floor of the hollow
    c.fill(inner & (c.yy >= 21) & (c.yy < 22), np.array([78, 73, 72], np.float32))  # its lit front edge
    # the blanket: a roll on the floor, lit on its left end, the end face a ring of wool
    roll = (c.ellipse(14.5, 19.6, 3.4, 2.7) | c.rect(12, 17, 17, 22)) & inner
    c.paint(roll, WOOL, 0.38 + 0.55 * c.sphere(12.5, 17.6, 6.5, 5.5), dither=False)
    c.paint(roll & (c.yy >= 21), WOOL, 0.06, dither=False)
    c.fill(c.rect(12, 18, 13, 20) & roll, WOOL[0])  # the coil of the end face
    c.fill(c.rect(11, 17, 12, 18) & roll, WOOL[3])
    # the crack through the stone (one pixel, from the block's upper left) and the strip of light in the hollow (two pixels, aslant): down to
    # the floor and along it to the rim of the roll
    for k, (x, y) in enumerate(((2, 7), (3, 8), (3, 9), (4, 10), (4, 11), (5, 12), (5, 13))):
        c.fill(c.rect(x, y, x + 1, y + 1) & body, DAYLIGHT[3 if k % 4 == 0 else 2])
    for y in range(13, 21):
        x = int(round(6 + (y - 13) * 4 / 8))
        c.fill(c.rect(x, y, x + 1, y + 1) & inner & ~roll, DAYLIGHT[2])
        c.fill(c.rect(x + 1, y, x + 2, y + 1) & inner & ~roll, DAYLIGHT[1])
    c.fill(c.rect(9, 21, 12, 22) & inner & ~roll, DAYLIGHT[1])  # the patch on the floor, to the roll's rim
    c.fill(c.rect(9, 21, 11, 22) & inner & ~roll, DAYLIGHT[2])
    c.outline(st["outline"])
    return c


def candle_stub(ms):
    """A candle stub on the ground, hardly two fingers high: old hard wax, the top pressed flat, one frozen drip down its side, a short dark
    wick with no soot on it, a little flat pool of wax at its foot. 10 x 12, anchor (5, 10)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(10, 12)
    body = c.rect(2, 4, 8, 10)
    c.paint(body, WAX, np.where(c.xx < 3.5, 0.9, np.where(c.xx >= 6, 0.22, 0.58)), contrast=2.0, dither=False)
    c.paint(c.ellipse(5, 4.4, 3.1, 1.7), WAX, 0.86, dither=False)  # the top, pressed flat
    c.fill(c.rect(5, 3, 6, 5), np.array([36, 30, 26], np.float32))  # the wick, a dark short line
    c.fill(c.rect(4, 4, 5, 5), WAX[1])  # the dip round its foot
    c.fill(c.rect(6, 5, 7, 8), WAX[3])  # the frozen drip down the front
    c.paint(c.ellipse(5, 10.4, 4.0, 1.3), WAX, 0.5, dither=False)  # the pool at the foot
    c.paint(c.ellipse(5, 10.8, 3.4, 0.9) & (c.xx > 5), WAX, 0.22, dither=False)
    c.outline(st["outline"])
    return c


def sit_rock(ms):
    """A flat block of the cliff's warm grey stone at the edge of the Grat, two cells wide, long enough for two to sit side by side: its top worn
    smooth and pale (a darker, even place where many have sat, no grit in it), a lit lip where the top meets the front, the front lower and
    darker with a few joints and a little lichen at its foot, the ends rounded by weather. Flat (it lies on the ground, figures stand above it).
    32 x 14, anchor (8, 7): the middle of the first cell, so that it covers the cell it stands on and the one to the east."""
    rng = np.random.default_rng(2401)
    st = pa.STYLES["tal"]
    c = ms.Canvas(32, 14)
    nx = (c.xx + 0.5 - 16.0) / 15.0
    ny = (c.yy + 0.5 - 5.0) / 4.0
    top = (np.abs(nx) ** 4 + np.abs(ny) ** 4) <= 1.0
    body = np.zeros_like(top)
    for k in range(5):  # the front: the top's shape drawn four rows lower as well, and every row between
        body |= np.roll(top, k, 0)
    front = body & ~top
    grain = pa.value_noise(14, 32, (3, 6), rng)
    lit = np.clip(1.0 - (c.xx + 0.5) / 40.0, 0, 1)  # lit from the left
    worn = c.ellipse(15.0, 5.2, 9.5, 2.6) & top  # the smooth place where people sit
    c.paint(top, st["cliff"], 0.62 + 0.1 * lit + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(worn, st["cliff"], 0.88, contrast=2.0, dither=False)  # no grit in it: smoother and paler than the rest
    c.paint(top & (c.xx < 4), st["cliff"], 0.92, contrast=2.0, dither=False)  # the left end catches the light
    c.paint(top & (c.xx >= 27), st["cliff"], 0.5, contrast=2.0, dither=False)
    for x, y in ((3, 3), (6, 6), (24, 2), (27, 5), (22, 7), (9, 2)):  # a little grit in the unworn rim of the top
        c.fill(c.rect(x, y, x + 1, y + 1) & top & ~worn, st["cliff"][2])
    # the front: lower and darker, lighter on the left, dark at the foot, the joints between the layers
    c.paint(front, st["cliff"], 0.34 + 0.16 * lit + 0.12 * (grain - 0.5) - 0.06 * (c.yy - 8) / 4.0, contrast=2.0, dither=False)
    c.paint(front & (c.yy >= 11), st["cliff"], 0.12, dither=False)
    for x, y0 in ((7, 9), (13, 10), (21, 9), (26, 10)):  # a joint: a dark line that runs down and breaks
        c.fill(c.rect(x, y0, x + 1, y0 + 2) & front, st["cliff"][0])
    c.fill(c.rect(9, 10, 12, 11) & front, st["cliff"][1])  # a layer's line along the front
    c.fill(c.rect(16, 9, 19, 10) & front, st["cliff"][4])
    # the lip: the front edge of the top, lit, one row
    lip = top & ~np.roll(top, -1, 0)
    c.paint(lip & (c.xx >= 3) & (c.xx < 28), st["cliff"], 0.97, contrast=2.0, dither=False)
    # lichen at the foot: a few pixels of the pale lichen green on the front, low on the left and on the right
    for x, y in ((4, 11), (5, 11), (5, 12), (23, 12), (24, 12), (24, 11), (25, 12)):
        c.fill(c.rect(x, y, x + 1, y + 1) & front, LICHEN[(x + y) % 2])
    c.outline(st["outline"])
    return c


def picture_frame(ms):
    """A plain frame for a picture that hangs in the air: four pieces of honey wood joined at the corners (the mitre a dark diagonal), lit on the
    upper left and dark on the lower right, the grain along each piece, a dark line round the whole and a dark line at the inner lip; no hook, no
    cord, no nail, no shadow, no glow. Inside, a ground of 16 x 16 pixels, dark and empty (a very faint rim at its top and its left, as if the
    frame cast one), at (4, 4): the scene lays the picture of a fragment over it. 24 x 24, anchor (12, 12): the middle."""
    rng = np.random.default_rng(2402)
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 24)
    wood = st["wood"]
    outer = c.rect(0, 0, 24, 24)
    inner = c.rect(4, 4, 20, 20)
    ring = outer & ~inner
    horiz = ring & ((c.yy < 4) | (c.yy >= 20))
    vert = ring & ~horiz
    g_h = pa.value_noise(24, 24, (1, 6), rng)  # the grain: long along the piece
    g_v = pa.value_noise(24, 24, (6, 1), rng)
    # lit from the upper left: the upper and left pieces lighter, the lower and right pieces darker
    side = np.where((c.yy < 4) | (c.xx < 4), 0.74, 0.46)
    c.paint(horiz, wood, side + 0.14 * (g_h - 0.5), contrast=2.0, dither=False)
    c.paint(vert, wood, side + 0.14 * (g_v - 0.5), contrast=2.0, dither=False)
    # the bevel: a bright row on the outer edge's inside (rows/columns 1) on the lit sides, a dark one on the shaded sides
    c.paint(ring & (((c.yy == 1) & (c.xx >= 1) & (c.xx < 23)) | ((c.xx == 1) & (c.yy >= 1) & (c.yy < 23))), wood, 0.94, contrast=2.0, dither=False)
    c.paint(ring & (((c.yy == 22) & (c.xx >= 1) & (c.xx < 23)) | ((c.xx == 22) & (c.yy >= 1) & (c.yy < 23))), wood, 0.2, contrast=2.0, dither=False)
    # the mitre at each corner: a dark diagonal, then the outer line round all of it
    for k in range(4):
        for (x, y) in ((k, k), (23 - k, k), (k, 23 - k), (23 - k, 23 - k)):
            c.fill(c.rect(x, y, x + 1, y + 1), wood[1])
    # the inner lip: one dark row all round the opening
    lip = ring & ((c.xx == 3) | (c.xx == 20) | (c.yy == 3) | (c.yy == 20)) & (c.xx >= 3) & (c.xx < 21) & (c.yy >= 3) & (c.yy < 21)
    c.fill(lip, wood[0])
    c.fill(c.rect(3, 3, 4, 4), wood[0])
    # the outer line: the style's outline colour on the outermost pixels
    c.fill(ring & ((c.xx == 0) | (c.xx == 23) | (c.yy == 0) | (c.yy == 23)), st["outline"])
    # the empty ground
    c.fill(inner, np.array([27.0, 30.0, 36.0], np.float32))
    c.fill(inner & (c.yy < 5) | inner & (c.xx < 5), np.array([19.0, 22.0, 27.0], np.float32))  # the rim the frame casts, one row/column
    return c


def sprout(ms):
    """A sprout in the bed: a short stem and two leaves opening like a pair of hands, light green (the lit leaf on the right a shade lighter, the
    left one turned a little away), on a low heap of dark earth with two pale crumbs in it. Nothing round it, no light on it, no dew. It is
    small and it is a beginning. 12 x 14, anchor (6, 12): the foot of the stem on the earth, the middle of the picture."""
    rng = np.random.default_rng(2403)
    st = pa.STYLES["tal"]
    c = ms.Canvas(12, 14)
    # the earth: a low heap, dark, a little lighter on its top-left; two pale crumbs
    heap = c.ellipse(6.0, 11.4, 4.9, 2.0) & (c.yy >= 10)
    c.paint(heap, st["mud"], 0.34 + 0.2 * (c.xx < 6) + 0.1 * (pa.value_noise(14, 12, 2, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(heap & (c.yy >= 12), st["mud"], 0.1, dither=False)
    c.fill(c.rect(3, 10, 4, 11) & heap, st["mud"][3])
    c.fill(c.rect(8, 11, 9, 12) & heap, st["mud"][3])
    # the stem: one pixel wide, lit, bent a hair to the left at the top
    for x, y in ((6, 10), (6, 9), (6, 8), (6, 7), (5, 6)):
        c.fill(c.rect(x, y, x + 1, y + 1), st["grass"][3])
    c.fill(c.rect(6, 10, 7, 11), st["grass"][2])
    # the two leaves: a pointed oval each, one open to the left and a little lower, one to the right and a little higher
    def leaf(cx, cy, rx, ry, angle):
        a = np.deg2rad(angle)
        dx, dy = c.xx + 0.5 - cx, c.yy + 0.5 - cy
        u = dx * np.cos(a) + dy * np.sin(a)
        v = -dx * np.sin(a) + dy * np.cos(a)
        return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0
    left = leaf(3.3, 5.6, 2.9, 1.5, -28.0) & ~c.rect(5, 0, 12, 14)
    right = leaf(8.6, 4.4, 3.1, 1.6, 30.0) & ~c.rect(0, 0, 5, 14)
    c.paint(left, st["grass"], 0.62 + 0.2 * (c.yy < 5.5), contrast=2.0, dither=False)
    c.paint(right, st["grass"], 0.82 + 0.14 * (c.yy < 4.5), contrast=2.0, dither=False)
    c.fill(c.rect(2, 6, 4, 7) & left, st["grass"][1])  # the underside of the left leaf, turned away
    c.fill(c.rect(8, 5, 10, 6) & right, st["grass"][2])  # a vein on the right leaf, the length of it
    c.fill(c.rect(5, 6, 6, 7), st["grass"][3])  # the stem reaches under the leaves
    c.outline(st["outline"])
    return c


# =========================================================================== Die Anlage (G3): the gate opens, the hall (prefix `ma_`)
# The hall of the Wächter, seen from the front like the workshop (Klasse S, zoom 1.5): a room of 25 x 14 cells (400 x 224 pixels, the map's room
# is the cells 4 to 28 and 4 to 17). The back wall (rows 0 to 2) is cold slate-grey cut stone under an iron girder, with the pipes along its
# top, four dials, two hanging lamps and, in the middle, the small shut door (12 x 18 pixels, child-sized) whose bolt is held by twelve thin
# rods that come up from the twelve levers of the console and meet in a bus bar under the girder. The console stands against the wall in the
# middle (15 cells, the cells 5 to 19 of the room, the levers in the cells 6 to 18 with a bolt indicator in the middle cell 12); it is a flat
# picture under everything (the levers stand on it, the player in front of it), its collision is the catalog shape. Nothing here is a person
# and nothing says what the door is for.
MA_W, MA_H = 400, 224  # 25 x 14 cells; the room's top left cell is the map cell (4, 4)
MA_CONSOLE_X0 = 5  # the console's first cell (room column) and its width in cells
MA_CONSOLE_W = 15
MA_LEVER_COLS = [6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18]  # the room column of lever n = 1 to 12 (the bolt indicator stands in 12)
MA_DOOR = (200, 47)  # the small door: the middle of its foot on the back wall's foot (x, y in room pixels)

HALL_STONE = ramp("#1a2026", "#28323a", "#3a4752", "#53626e", "#7a8c98")  # cold slate-grey cut stone
COPPER = ramp("#2e140a", "#5e2c14", "#9a5226", "#cf8040", "#efb070")
CLOTH = ramp("#4a4636", "#78745e", "#a6a288", "#d0ccb0", "#ebe7cc")  # linen gone grey: the cloth over the levers that are not in use
LAMP_GLASS = ramp("#6a4a14", "#b88628", "#f0c050", "#ffe49a", "#fff6d4")  # glass with a flame behind it
STEAM = ramp("#7c8a94", "#a4b2ba", "#cdd8dc", "#eef3f4")
NEEDLE_RED = ramp("#3a0c0e", "#7e1a1c", "#c43030", "#ee6a58")
NORMAL_GREEN = ramp("#0e2a18", "#1d5a30", "#3c8c4c", "#7cc07c")

# the form of each lever's knob (9 x 9, nine different and three more: never only a colour, Bible §50): disc, square, triangle, diamond,
# cross, ring, star, hexagon, dome, T-bar, bar, chevron
FORMS = {
    1: ("..xxxxx..", ".xxxxxxx.", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", ".xxxxxxx.", "..xxxxx.."),
    2: (".........", ".xxxxxxx.", ".xxxxxxx.", ".xxxxxxx.", ".xxxxxxx.", ".xxxxxxx.", ".xxxxxxx.", ".xxxxxxx.", "........."),
    3: ("....x....", "...xxx...", "...xxx...", "..xxxxx..", "..xxxxx..", ".xxxxxxx.", ".xxxxxxx.", "xxxxxxxxx", "xxxxxxxxx"),
    4: ("....x....", "...xxx...", "..xxxxx..", ".xxxxxxx.", "xxxxxxxxx", ".xxxxxxx.", "..xxxxx..", "...xxx...", "....x...."),
    5: ("...xxx...", "...xxx...", "...xxx...", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "...xxx...", "...xxx...", "...xxx..."),
    6: ("..xxxxx..", ".xx...xx.", "xx.....xx", "x.......x", "x.......x", "x.......x", "xx.....xx", ".xx...xx.", "..xxxxx.."),
    7: ("....x....", "....x....", ".x..x..x.", "..xxxxx..", "xxxxxxxxx", "..xxxxx..", ".x..x..x.", "....x....", "....x...."),
    8: ("...xxx...", ".xxxxxxx.", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", ".xxxxxxx.", "...xxx..."),
    9: (".........", "..xxxxx..", ".xxxxxxx.", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "........."),
    10: ("xxxxxxxxx", "xxxxxxxxx", "...xxx...", "...xxx...", "...xxx...", "...xxx...", "...xxx...", "...xxx...", "...xxx..."),
    11: (".........", ".........", ".xxxxxxx.", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", ".xxxxxxx.", ".........", "........."),
    12: ("xxxxxxxxx", "xxxxxxxxx", ".xxxxxxx.", ".xxxxxxx.", "..xxxxx..", "..xxxxx..", "...xxx...", "...xxx...", "....x...."),
}
DIGITS = {
    "0": ("xxx", "x.x", "x.x", "x.x", "xxx"), "1": (".x.", "xx.", ".x.", ".x.", "xxx"), "2": ("xxx", "..x", "xxx", "x..", "xxx"),
    "3": ("xxx", "..x", "xxx", "..x", "xxx"), "4": ("x.x", "x.x", "xxx", "..x", "..x"), "5": ("xxx", "x..", "xxx", "..x", "xxx"),
    "6": ("xxx", "x..", "xxx", "x.x", "xxx"), "7": ("xxx", "..x", ".x.", ".x.", ".x."), "8": ("xxx", "x.x", "xxx", "x.x", "xxx"),
    "9": ("xxx", "x.x", "xxx", "..x", "xxx"),
}
# the dials of the wall: where the mark "Normal" lies (degrees clockwise from straight up) and where the needle rests; all four stand on it
GAUGE_NORMAL = {1: 0.0, 2: -40.0, 3: 32.0, 4: 14.0}
GAUGE_ANCHOR = {1: (6, 36), 2: (6, 36), 3: (22, 36), 4: (22, 36)}  # the dial's picture is 28 x 28, its hub at (14, 14): needle_at is (14 - anchor x, -22)
GAUGE_STEP = {1: 25, 2: 20, 3: 25, 4: 25}  # the tick spacing of the scale (degrees); the scale runs from -125 to +125
LEVER_PLATE_Y = (41, 50)  # the number plate under a lever, in the lever's picture (rows)


def _pattern(c, pat, x0, y0):
    """A mask: the pattern of 'x' cells with its top left at (x0, y0)."""
    m = np.zeros((c.h, c.w), bool)
    for j, row in enumerate(pat):
        for i, ch in enumerate(row):
            if ch == "x" and 0 <= y0 + j < c.h and 0 <= x0 + i < c.w:
                m[y0 + j, x0 + i] = True
    return m


def _digits(c, x, y, text, ink):
    """Small numerals (3 x 5) for the plates of the levers: the number is the lever's name."""
    for k, ch in enumerate(text):
        c.fill(_pattern(c, DIGITS[ch], x + k * 4, y), ink)


def _rod(c, x, y0, y1, tone_ramp=BRIGHT_IRON):
    c.paint(c.rect(x, y0, x + 1, y1), tone_ramp, 0.62, dither=False)
    c.paint(c.rect(x + 1, y0, x + 2, y1), tone_ramp, 0.2, dither=False)


def hall_lever(ms, n, down):
    """Lever `n` of the console: a collar on the console's top, a stem and a knob in the form of its number, and a brass plate with the number
    on the front panel below it. Up (not pulled) the knob stands high above the collar; pulled it leans towards the player, in front of the
    console's edge, close above the plate. 16 x 52, anchor (8, 30): the collar's middle, the glyph's cell."""
    c = ms.Canvas(16, 52)
    live = n <= 3
    ink = BRIGHT_IRON[0]
    plate = c.rect(1, LEVER_PLATE_Y[0], 15, LEVER_PLATE_Y[1])
    c.paint(plate, BRASS, np.where(c.yy < LEVER_PLATE_Y[0] + 1, 0.98, np.where(c.yy >= LEVER_PLATE_Y[1] - 1, 0.12, 0.62)), dither=False)
    c.fill(c.rect(2, LEVER_PLATE_Y[0] + 1, 3, LEVER_PLATE_Y[0] + 2), BRASS[3])
    c.fill(c.rect(13, LEVER_PLATE_Y[0] + 1, 14, LEVER_PLATE_Y[0] + 2), BRASS[3])
    text = str(n)
    _digits(c, 8 - (len(text) * 4 - 1) // 2 - (0 if len(text) == 2 else 0), LEVER_PLATE_Y[0] + 2, text, ink)
    # the collar and the slot it moves in
    c.paint(c.ellipse(8, 30, 5.6, 2.8), BRIGHT_IRON, 0.3 + 0.5 * (c.yy < 30), dither=False)
    c.paint(c.ellipse(8, 30.4, 3.6, 1.5), BRIGHT_IRON, 0.04, dither=False)
    if down:
        c.paint(c.rect(7, 30, 9, 38), BRIGHT_IRON, 0.04, dither=False)  # the slot runs towards the player
        c.paint(c.rect(7, 27, 9, 33), BRIGHT_IRON, np.where(c.xx < 8, 0.8, 0.3), dither=False)
        y0 = 31
    else:
        c.paint(c.rect(7, 12, 9, 30), BRIGHT_IRON, np.where(c.xx < 8, 0.85, 0.28), dither=False)
        c.fill(c.rect(7, 27, 9, 28), BRIGHT_IRON[1])  # a collar ring on the stem
        y0 = 3
    knob_ramp = BRASS if live else BRIGHT_IRON
    m = _pattern(c, FORMS[n], 4, y0)
    c.paint(m, knob_ramp, np.clip(0.82 - 0.46 * ((c.xx - 4) + (c.yy - y0)) / 16.0, 0.1, 0.95), contrast=2.0, dither=False)
    c.paint(m & (~np.roll(m, -1, 0) | ~np.roll(m, -1, 1)), knob_ramp, 0.1, dither=False)
    c.paint(m & (~np.roll(m, 1, 0) | ~np.roll(m, 1, 1)), knob_ramp, 1.0, dither=False)
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_cover(ms):
    """The cloth over a lever that is not in use: linen gone grey, pulled over the stem and the knob (a bump on top, a skirt that steps out under it),
    folds that run down from the bump, a hem with a few jags, a string round the neck. It stops above the lever's number plate (the number stays
    readable). 16 x 36, anchor (8, 36); the map lifts it by 9 onto the lever from the cell below."""
    rng = np.random.default_rng(3011)
    c = ms.Canvas(16, 36)
    y = c.yy
    half = np.where(y < 3, 1.8 + (y - 2) * 1.2, np.where(y < 10, 3.6 + 0.08 * (y - 3), np.where(y < 13, 5.2, 5.4 + (y - 13) * 0.115)))
    hem = 31 + np.where((c.xx.astype(int) % 6) < 2, 2, np.where((c.xx.astype(int) % 6) < 4, 1, 0))
    body = (np.abs(c.xx + 0.5 - 8) <= half) & (y >= 2) & (y < hem)
    t = (c.xx + 0.5 - 8) / np.maximum(half, 1.0)  # -1 at the left edge, +1 at the right
    folds = np.abs(t * 3.0 + 0.35 * (y - 12) / 20.0) % 1.0
    c.paint(body, CLOTH, 0.64 + 0.3 * c.cylinder(1, 15) - 0.15 * (folds < 0.14) + 0.07 * (pa.value_noise(36, 16, 3, rng) - 0.5), contrast=2.0, dither=False)
    c.paint(body & (y >= 10) & (y < 12), CLOTH, 0.84 - 0.5 * (t > 0.2), dither=False)  # where the skirt steps out, a lit edge
    c.paint(body & (y >= hem - 2), CLOTH, 0.2, dither=False)  # the hem's shade
    c.paint(c.rect(4, 9, 12, 10) & body, CLOTH, 0.14, dither=False)  # the string round the neck
    c.fill(c.rect(10, 9, 12, 13) & body, CLOTH[0])  # its loose end
    tag = ramp("#6b6458", "#a79f8c", "#d9d2bc")  # a paper tag sewn on below the string: the one line of writing the dialogue reads
    c.fill(c.rect(5, 15, 11, 23) & body, tag[2])
    c.fill(c.rect(5, 15, 11, 16) & body, tag[1])
    c.fill(c.rect(6, 18, 10, 19) & body, tag[0])
    c.fill(c.rect(6, 20, 9, 21) & body, tag[0])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_console(ms):
    """The console: fifteen cells long against the back wall, a top of grey steel (dark where it meets the wall, a bright lip in front) with a
    slot for each lever and for the bolt indicator in the middle, a front panel of riveted plates with a recess for each lever's number plate, a
    plinth and, on the floor, a dithered shadow. Flat, under the levers. 240 x 40, anchor (120, 24): the middle of the front panel's row (the cell
    12, 4 of the room), the top starts 24 pixels above."""
    rng = np.random.default_rng(3021)
    c = ms.Canvas(240, 40)
    grain = pa.value_noise(40, 240, (1, 9), rng)
    top = c.rect(0, 0, 240, 16)
    c.paint(top, BRIGHT_IRON, 0.44 + 0.1 * (grain - 0.5) + 0.2 * (c.yy >= 12) - 0.16 * (c.yy < 3), dither=False)
    c.paint(c.rect(0, 15, 240, 16), BRIGHT_IRON, 0.96, dither=False)
    for x0 in (0, 224):  # the end blocks: the same steel, a brass corner on the outer side and a row of rivets
        edge = 0 if x0 == 0 else 15
        c.paint(c.rect(x0 + edge, 1, x0 + edge + 1, 16), BRASS, 0.55, dither=False)
        for ry in (4, 9):
            c.fill(c.rect(x0 + 6, ry, x0 + 7, ry + 1), BRIGHT_IRON[4])
            c.fill(c.rect(x0 + 9, ry, x0 + 10, ry + 1), BRIGHT_IRON[3])
    for col in MA_LEVER_COLS + [12]:  # the slots
        x = (col - MA_CONSOLE_X0) * 16 + 8
        c.paint(c.rect(x - 5, 5, x + 5, 11), BRIGHT_IRON, 0.05, dither=False)
        c.paint(c.rect(x - 5, 11, x + 5, 12), BRIGHT_IRON, 0.7, dither=False)
    panel = c.rect(0, 16, 240, 33)
    c.paint(panel, BRIGHT_IRON, 0.27 + 0.08 * (grain - 0.5) - 0.06 * ((c.yy - 16) / 17.0), dither=False)
    for k in range(0, 16):  # the seams between the plates, a rivet at each corner
        x = k * 16
        c.paint(c.rect(x, 16, x + 1, 33), BRIGHT_IRON, 0.05, dither=False)
        for ry in (18, 30):
            c.fill(c.rect(x + 2, ry, x + 3, ry + 1), BRIGHT_IRON[3])
            c.fill(c.rect(x + 13, ry, x + 14, ry + 1), BRIGHT_IRON[2])
    c.paint(c.rect(0, 16, 240, 17), BRIGHT_IRON, 0.08, dither=False)
    for col in MA_LEVER_COLS:  # the recess for each number plate
        x = (col - MA_CONSOLE_X0) * 16 + 8
        c.paint(c.rect(x - 7, 18, x + 7, 29), BRIGHT_IRON, 0.08, dither=False)
    c.paint(c.rect(0, 33, 240, 37), BRIGHT_IRON, np.where(c.yy < 34, 0.6, 0.12), dither=False)
    shadow = (c.yy >= 37) & (c.yy < 40) & (pa.BAYER4[np.arange(40)[:, None] % 4, np.arange(240)[None, :] % 4] < np.where(c.yy < 38, 0.7, 0.35))
    c.fill(shadow, HALL_STONE[0])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_bolt(ms):
    """The bolt indicator in the middle of the console: a small iron housing with a brass frame and a glass tube in which the pin of the bolt
    stands, down, in. 16 x 20, anchor (8, 16): the glyph's cell, close above the housing's foot."""
    c = ms.Canvas(16, 20)
    c.paint(c.rect(1, 4, 15, 17), BRIGHT_IRON, np.where(c.xx < 4, 0.62, np.where(c.xx > 12, 0.2, 0.4)), dither=False)
    c.paint(c.rect(1, 3, 15, 5), BRIGHT_IRON, 0.9, dither=False)
    c.paint(c.rect(5, 6, 11, 16), BRASS, np.where(c.xx < 6, 0.9, 0.5), dither=False)  # the frame
    c.paint(c.rect(6, 7, 10, 15), GLASS_COLD, 0.2 + 0.5 * (c.yy < 11), dither=False)  # the tube
    c.paint(c.rect(7, 10, 9, 15), BRIGHT_IRON, np.where(c.xx < 8, 0.7, 0.3), dither=False)  # the pin, down
    c.fill(c.rect(7, 9, 9, 10), BRASS[3])  # its brass tip
    c.fill(c.rect(6, 7, 7, 9), GLASS_COLD[3])  # a glint
    for rx, ry in ((2, 5), (13, 5), (2, 15), (13, 15)):
        c.fill(c.rect(rx, ry, rx + 1, ry + 1), BRIGHT_IRON[4])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def _polar(cx, cy, r, deg):
    """The point at radius r and `deg` degrees clockwise from straight up."""
    a = np.radians(deg)
    return cx + r * np.sin(a), cy - r * np.cos(a)


def hall_gauge(ms, k):
    """A dial of the Zeigerwand, without its needle (the needle is a prop of its own, hung on the hub): an iron mounting plate with four rivets,
    a brass ring, a pale face with the scale (ticks every so many degrees, no numerals) and the mark "Normal": a broad dark-green stub reaching
    from the middle of the face to the ring, which no tick looks like (a shape, never only a colour). 28 x 28, anchor (see GAUGE_ANCHOR): the dial's
    picture ends 8 pixels above the cell's centre; the hub is at (14, 14)."""
    c = ms.Canvas(28, 28)
    plate = c.rect(1, 1, 27, 27) & ~(((c.xx < 3) | (c.xx > 24)) & ((c.yy < 3) | (c.yy > 24)))
    c.paint(plate, BRIGHT_IRON, 0.3 + 0.35 * c.sphere(8, 8, 26, 26), dither=False)
    for rx, ry in ((3, 3), (24, 3), (3, 24), (24, 24)):
        c.fill(c.rect(rx, ry, rx + 1, ry + 1), BRIGHT_IRON[4])
    c.paint(_disc(c, 14, 14, 12), BRASS, 0.3 + 0.65 * c.sphere(10, 10, 14, 14), dither=False)
    face = _disc(c, 14, 14, 10)
    c.paint(face, CHALK, 0.8 + 0.18 * c.sphere(10, 10, 14, 14), dither=False)
    ink = BRIGHT_IRON[1]
    step = GAUGE_STEP[k]
    for a in range(-125, 126, step):
        long = (a % (2 * step) == 0) if k != 4 else False
        for r in np.arange(7.6 if long else 8.4, 9.8, 0.5):
            x, y = _polar(14, 14, r, a)
            c.fill(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), ink)
        if k == 4:  # this dial has dots in place of ticks
            x, y = _polar(14, 14, 8.6, a)
            c.fill(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), ink)
    if k == 3:  # a hatched arc at the far end of this scale, beyond the usual
        for a in range(95, 126, 6):
            for r in np.arange(5.8, 9.4, 0.6):
                x, y = _polar(14, 14, r, a)
                c.fill(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), RUST[2])
    # the mark "Normal": a broad stub from r = 4.5 to the ring, three pixels wide, a pale edge
    n = GAUGE_NORMAL[k]
    for r in np.arange(4.5, 10.4, 0.5):
        for off in (-1.3, 0.0, 1.3):
            x, y = _polar(14, 14, r, n)
            x2, y2 = _polar(0, 0, off, n + 90)
            c.fill(c.rect(int(round(x + x2)), int(round(y - y2)), int(round(x + x2)) + 1, int(round(y - y2)) + 1), NORMAL_GREEN[1] if off != 0 else NORMAL_GREEN[2])
    x, y = _polar(14, 14, 10.0, n)
    c.fill(c.rect(int(round(x)), int(round(y)), int(round(x)) + 1, int(round(y)) + 1), NORMAL_GREEN[3])
    c.fill(c.rect(11, 12, 13, 14), CHALK[3])  # a glint on the glass
    c.fill(c.rect(12, 11, 14, 12), CHALK[3])
    c.fill(c.rect(13, 13, 15, 15), BRIGHT_IRON[1])  # the hub's seat
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_needle(ms, k):
    """The needle of a dial, drawn pointing straight up from its hub, with a short tail and a brass hub cap: red, tapering to a point. 7 x 20,
    anchor (3, 13) = the hub; the tip is `13 - tip` pixels above it."""
    tip = {1: 3, 2: 4, 3: 3, 4: 4}[k]
    c = ms.Canvas(7, 20)
    for y in range(tip, 13):
        half = 0.5 + (y - tip) / (13.0 - tip) * 1.0
        c.fill(c.rect(int(round(3.5 - half)), y, int(round(3.5 + half)), y + 1), NEEDLE_RED[2] if y > tip + 1 else NEEDLE_RED[3])
    c.fill(c.rect(3, tip, 4, 13), NEEDLE_RED[3])
    c.fill(c.rect(2, 13, 5, 17), NEEDLE_RED[1])  # the tail
    c.fill(c.rect(3, 13, 4, 17), NEEDLE_RED[2])
    c.paint(_disc(c, 3.5, 13.5, 2.2), BRASS, 0.6 + 0.4 * c.sphere(2, 12, 4, 4), dither=False)
    c.fill(c.rect(3, 12, 4, 13), BRASS[4] if len(BRASS) > 4 else BRASS[3])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_worn_dial(ms):
    """The worn dial on the console's right end: a small dial on a bracket, tilted towards the player, its needle at rest on the mark "Normal";
    in the glass a groove, a pale scratch with a dark twin, worn by the needle that has swept this same stretch for years (the fragment). 16 x 18,
    anchor (8, 13)."""
    c = ms.Canvas(16, 18)
    c.paint(c.rect(2, 13, 14, 17), BRIGHT_IRON, np.where(c.yy < 14, 0.8, 0.22), dither=False)  # the bracket
    c.paint(c.ellipse(8, 7.5, 7.4, 6.8), BRASS, 0.3 + 0.65 * c.sphere(5, 4, 9, 9), dither=False)
    c.paint(c.ellipse(8, 7.5, 5.8, 5.3), CHALK, 0.82, dither=False)
    for a in range(-110, 111, 22):  # a bare scale
        x, y = _polar(8, 7.5, 4.4, a)
        c.fill(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), BRIGHT_IRON[1])
    for r in np.arange(0.5, 4.6, 0.5):  # the needle at rest, straight up
        c.fill(c.rect(8, int(7.5 - r), 9, int(7.5 - r) + 1), NEEDLE_RED[2])
    c.fill(c.rect(7, 7, 10, 9), BRASS[2])
    # the groove: a pale scratch just beside the needle's stretch, longer than the others, and a dark line next to it
    for r in np.arange(1.2, 5.2, 0.5):
        x, y = _polar(8, 7.5, r, 14)
        c.fill(c.rect(int(round(x)), int(round(y)), int(round(x)) + 1, int(round(y)) + 1), CHALK[3])
        c.fill(c.rect(int(round(x)) + 1, int(round(y)), int(round(x)) + 2, int(round(y)) + 1), BRIGHT_IRON[1])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def _lantern(c, cx, y0, h, lit=True):
    """A lantern: a cap, a cage of four iron bars round a glass with a flame, a foot. Returns the mask of the glass (the glow). `lit=False`
    is the same lantern gone out: the glass is cold slate-grey, soot under the cap, no flame."""
    glass = c.rect(cx - 4, y0 + 3, cx + 4, y0 + h - 3)
    if lit:
        c.paint(glass, LAMP_GLASS, 0.5 + 0.4 * (1.0 - np.abs(c.xx + 0.5 - cx) / 4.0) + 0.1 * (c.yy < y0 + h / 2), dither=False)
        c.fill(c.rect(cx - 1, y0 + 5, cx + 1, y0 + h - 6), LAMP_GLASS[4])
    else:
        c.paint(glass, SLATE, 0.2 + 0.3 * (1.0 - np.abs(c.xx + 0.5 - cx) / 4.0) + 0.08 * (c.yy < y0 + h / 2), dither=False)
        c.paint(c.rect(cx - 3, y0 + 3, cx + 4, y0 + 5), BRIGHT_IRON, 0.12, dither=False)  # soot under the cap
    for bx in (cx - 5, cx + 4):
        c.paint(c.rect(bx, y0 + 2, bx + 1, y0 + h - 2), BRIGHT_IRON, 0.3, dither=False)
    c.paint(c.rect(cx - 6, y0, cx + 6, y0 + 3), BRIGHT_IRON, np.where(c.yy < y0 + 1, 0.9, 0.35), dither=False)
    c.paint(c.rect(cx - 2, y0 - 2, cx + 2, y0), BRIGHT_IRON, 0.6, dither=False)
    c.paint(c.rect(cx - 6, y0 + h - 3, cx + 6, y0 + h), BRIGHT_IRON, np.where(c.yy < y0 + h - 2, 0.7, 0.2), dither=False)
    return glass


def hall_lamp_hang(ms):
    """A lamp that hangs from the girder on a chain: three links of chain, a lantern. 16 x 30, anchor (8, 30): the lantern's foot is the
    cell's centre; the chain reaches up to the girder. Returns the picture and the pixels that glow."""
    c = ms.Canvas(16, 30)
    for y in range(0, 10, 3):
        c.fill(c.rect(7, y, 9, y + 2), BRIGHT_IRON[2])
        c.fill(c.rect(7, y + 1, 8, y + 3), BRIGHT_IRON[3])
    glass = _lantern(c, 8, 10, 18)
    c.outline(pa.STYLES["tal"]["outline"])
    em = ms.Canvas(16, 30)
    em.fill(glass, LAMP_GLASS[3])
    return c, em


def hall_lamp_hang_dark(ms):
    """The hanging lamp gone out (G5: the one that fails while the levers fall, and that nobody mends): the same chain, cage, cap and foot on the same
    16 x 30 grid and the same anchor (8, 30) as `hall_lamp_hang`, so that it stands on the cell of the lit one; the glass is dark and has a fine crack
    (a dark line with a pale twin beside it, a short branch), no flame and nothing that glows (no emissive picture, no light). Returns the picture."""
    c = ms.Canvas(16, 30)
    for y in range(0, 10, 3):
        c.fill(c.rect(7, y, 9, y + 2), BRIGHT_IRON[2])
        c.fill(c.rect(7, y + 1, 8, y + 3), BRIGHT_IRON[3])
    _lantern(c, 8, 10, 18, lit=False)
    crack = [(10, 13), (10, 14), (9, 15), (9, 16), (9, 17), (8, 18), (8, 19), (7, 20), (7, 21), (6, 22)]
    for x, y in crack:
        c.fill(c.rect(x, y, x + 1, y + 1), SLATE[0])
        if x + 1 < 12:
            c.fill(c.rect(x + 1, y, x + 2, y + 1), SLATE[3])
    for x, y in ((9, 19), (10, 20), (10, 21)):  # a short branch to the right
        c.fill(c.rect(x, y, x + 1, y + 1), SLATE[0])
    c.fill(c.rect(11, 20, 12, 21), SLATE[3])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_lamp(ms):
    """A standing lamp: a round foot, an iron post with two collars, a lantern on a short arm. 16 x 46, anchor (8, 44). Returns the picture and the
    glowing pixels."""
    c = ms.Canvas(16, 46)
    c.paint(c.ellipse(8, 43, 6.0, 2.2), BRIGHT_IRON, 0.35 + 0.4 * (c.yy < 43), dither=False)
    c.paint(c.rect(7, 18, 9, 43), BRIGHT_IRON, np.where(c.xx < 8, 0.75, 0.24), dither=False)
    for y in (24, 36):
        c.paint(c.rect(5, y, 11, y + 2), BRIGHT_IRON, np.where(c.yy == y, 0.9, 0.3), dither=False)
    glass = _lantern(c, 8, 2, 17)
    c.paint(c.rect(6, 19, 10, 21), BRIGHT_IRON, 0.5, dither=False)
    c.outline(pa.STYLES["tal"]["outline"])
    em = ms.Canvas(16, 46)
    em.fill(glass, LAMP_GLASS[3])
    return c, em


def hall_tank(ms):
    """A boiler tank against the side: an upright iron cylinder with rivet bands, a dome on top with a pipe stub, a pressure dial, a valve wheel at
    its foot and a rust streak. 32 x 44, anchor (8, 40): the glyph's cell holds its left half; it stands on two cells."""
    rng = np.random.default_rng(3031)
    c = ms.Canvas(32, 44)
    body = c.rect(1, 10, 31, 41) | c.ellipse(16, 11, 15, 5.0)
    body &= c.yy < 41
    c.paint(body, BRIGHT_IRON, 0.12 + 0.82 * c.cylinder(1, 31) + 0.06 * (pa.value_noise(44, 32, 3, rng) - 0.5), contrast=2.2, dither=False)
    for y in (17, 28, 38):
        c.paint(c.rect(1, y, 31, y + 2), BRIGHT_IRON, np.where(c.yy == y, 0.9, 0.2), dither=False)
        for x in range(4, 30, 5):
            c.fill(c.rect(x, y, x + 1, y + 1), BRIGHT_IRON[4])
    c.paint(c.rect(13, 0, 19, 8), BRIGHT_IRON, np.where(c.xx < 15, 0.8, 0.26), dither=False)  # the pipe stub
    c.paint(c.rect(11, 6, 21, 9), BRIGHT_IRON, 0.7, dither=False)
    c.paint(_disc(c, 16, 23, 4.6), BRASS, 0.3 + 0.65 * c.sphere(14, 21, 6, 6), dither=False)  # the pressure dial
    c.paint(_disc(c, 16, 23, 3.2), CHALK, 0.85, dither=False)
    c.fill(c.rect(16, 21, 17, 24), NEEDLE_RED[2])
    c.paint(_disc(c, 24, 36, 2.6) & ~_disc(c, 24, 36, 1.2), RUST, 0.8, dither=False)  # the valve wheel
    c.fill(c.rect(23, 35, 25, 37), BRIGHT_IRON[3])
    c.paint(c.rect(6, 30, 8, 41), RUST, 0.5 + 0.2 * (c.yy > 36), dither=False)  # rust running down
    c.paint(c.rect(1, 41, 31, 44), BRIGHT_IRON, np.where(c.yy < 42, 0.55, 0.1), dither=False)  # the plinth
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_pipe_run(ms):
    """A pipe along the floor, five cells long: a fat iron pipe with a flange at each joint, a pale lit top, a bracket under it every two cells and
    a damp patch. 80 x 20, anchor (8, 14): the glyph's cell holds the left end."""
    rng = np.random.default_rng(3041)
    c = ms.Canvas(80, 20)
    pipe = c.rect(0, 2, 80, 13)
    c.paint(pipe, BRIGHT_IRON, 0.1 + 0.85 * c.cylinder(-30, 110) * 0 + 0.7 * ((13 - c.yy) / 11.0) + 0.06 * (pa.value_noise(20, 80, (2, 8), rng) - 0.5),
            contrast=2.0, dither=False)
    c.paint(c.rect(0, 2, 80, 4), BRIGHT_IRON, 0.96, dither=False)
    for fx in (0, 24, 48, 72):
        c.paint(c.rect(fx, 0, fx + 4, 15), BRIGHT_IRON, np.where(c.xx == fx, 0.9, 0.3), dither=False)
        for fy in (2, 6, 10, 13):
            c.fill(c.rect(fx + 1, fy, fx + 2, fy + 1), BRIGHT_IRON[4])
    for bx in (12, 36, 60):
        c.paint(c.rect(bx, 13, bx + 5, 17), BRIGHT_IRON, 0.3, dither=False)
    c.paint(c.ellipse(52, 15.5, 7.0, 1.6), BRIGHT_IRON, 0.05, dither=False)  # a damp patch under a joint
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_hiss_pipe(ms):
    """The pipe that hisses: an upright iron pipe with a collar and a valve wheel, bent over at the top into a nozzle that points up and to the
    right; a small brass cap on the nozzle. The steam is a prop of its own. 16 x 50, anchor (8, 46)."""
    c = ms.Canvas(16, 50)
    c.paint(c.rect(5, 14, 11, 46), BRIGHT_IRON, np.where(c.xx < 7, 0.8, np.where(c.xx > 9, 0.2, 0.46)), dither=False)
    c.paint(c.rect(3, 42, 13, 47), BRIGHT_IRON, np.where(c.yy < 43, 0.9, 0.2), dither=False)
    c.paint(c.rect(4, 26, 12, 28), BRIGHT_IRON, np.where(c.yy < 27, 0.9, 0.3), dither=False)
    c.paint(c.rect(4, 34, 12, 36), BRIGHT_IRON, np.where(c.yy < 35, 0.9, 0.3), dither=False)
    c.paint(_disc(c, 8, 30.5, 3.4) & ~_disc(c, 8, 30.5, 1.6), RUST, 0.85, dither=False)  # the valve wheel
    c.fill(c.rect(7, 29, 9, 32), BRIGHT_IRON[3])
    c.paint(c.rect(5, 8, 15, 14), BRIGHT_IRON, np.where(c.yy < 10, 0.85, 0.3), dither=False)  # the bend and the nozzle
    c.paint(c.rect(11, 4, 15, 11), BRIGHT_IRON, np.where(c.xx < 12, 0.8, 0.24), dither=False)
    c.paint(c.rect(10, 2, 16, 5), BRASS, np.where(c.yy < 3, 0.95, 0.5), dither=False)
    c.fill(c.rect(11, 2, 15, 3), BRASS[4] if len(BRASS) > 4 else BRASS[3])
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def hall_steam(ms, seed):
    """A puff of steam: a few round clouds clumped, the lit tops bright, the shaded undersides blue-grey, the edges dithered into the air.
    28 x 24, anchor (14, 22); a flat picture that the scene may move, fade or leave out."""
    rng = np.random.default_rng(seed)
    c = ms.Canvas(28, 24)
    blobs = [(14 + rng.uniform(-4, 4), 15 + rng.uniform(-2, 3), rng.uniform(6.5, 8.0))]
    for _ in range(4):
        blobs.append((14 + rng.uniform(-9, 9), 12 + rng.uniform(-6, 6), rng.uniform(3.8, 6.0)))
    value = np.zeros((24, 28), np.float32)
    alpha = np.zeros((24, 28), bool)
    b = pa.BAYER4[np.arange(24)[:, None] % 4, np.arange(28)[None, :] % 4]
    for cx, cy, r in sorted(blobs, key=lambda q: q[1]):
        d = np.hypot(c.xx + 0.5 - cx, c.yy + 0.5 - cy)
        core = d <= r * 0.8
        soft = (d <= r) & (b < 0.5 * (1.0 - (d / r - 0.8) / 0.2).clip(0, 1) + 0.25)
        m = core | soft
        light = 0.55 + 0.4 * ((cy - c.yy) / r).clip(-1, 1) * 0.5 + 0.12 * (c.xx < cx)
        value = np.where(m, light, value)
        alpha |= m
    c.paint(alpha, STEAM, np.clip(value, 0, 1), contrast=2.0, dither=False)
    return c


def hall_shell(ms):
    """The hall, seen from the front, lying under everything (the floor is baked from the map): an iron girder under the ceiling; the back wall
    (rows 0 to 2, x 16 to 384) of cold slate-grey cut stone with a bus bar under the girder, twelve thin rods hanging from it down to the twelve
    levers' knobs, a thicker one down to the bolt of the small door in the middle of the wall's foot (12 x 18 pixels, an arch of stone round
    it, two planks, a bar across it that its rod holds); pipes with flanges along the top of both wing walls; the two side walls as dark iron
    girders; the front wall (row 13) with a door of iron-strapped planks in the room column 3. 400 x 224, anchor (8, 8): the room's top left cell."""
    rng = np.random.default_rng(3051)
    st = pa.STYLES["tal"]
    c = ms.Canvas(MA_W, MA_H)
    grain = pa.value_noise(MA_H, MA_W, (2, 12), rng)
    # ---- the back wall
    _blocks(c, 16, 8, 384, 48, 8, 22, HALL_STONE, rng, base=0.46, lit=0.1)
    c.paint(c.rect(16, 8, 384, 16), HALL_STONE, 0.16, dither=False)  # in the shadow of the girder
    c.paint(c.rect(16, 16, 384, 20), HALL_STONE, 0.3, dither=False)
    c.paint(c.rect(16, 44, 384, 48), HALL_STONE, np.where(c.yy < 45, 0.7, 0.1), dither=False)  # the baseboard
    # ---- the girder under the ceiling and the bus bar
    c.paint(c.rect(0, 0, MA_W, 8), BRIGHT_IRON, np.where(c.yy < 2, 0.8, np.where(c.yy > 5, 0.14, 0.4)) + 0.06 * (grain - 0.5), dither=False)
    for rx in range(8, MA_W, 24):
        c.fill(c.rect(rx, 3, rx + 1, 4), BRIGHT_IRON[4])
    c.paint(c.rect(88, 9, 312, 13), BRIGHT_IRON, np.where(c.yy < 10, 0.9, np.where(c.yy > 11, 0.15, 0.5)), dither=False)  # the bus bar
    for bx in (92, 200, 308):
        c.paint(c.rect(bx - 2, 8, bx + 3, 14), BRIGHT_IRON, 0.6, dither=False)  # its brackets
    # ---- the twelve rods from the knobs up to the bus bar, and the thicker one to the bolt
    for col in MA_LEVER_COLS:
        x = col * 16 + 8
        _rod(c, x, 13, 30)
        c.paint(c.rect(x - 1, 13, x + 2, 15), BRIGHT_IRON, 0.7, dither=False)  # the clevis on the bar
    # ---- the small door: a stone arch, two planks, an iron bar across it; its right end is held by the thick rod that comes down beside the door
    dx, dy = MA_DOOR
    c.paint(c.rect(dx - 9, dy - 21, dx + 9, dy + 1), HALL_STONE, np.where(c.xx < dx, 0.7, 0.44), dither=False)
    c.paint(c.rect(dx - 9, dy - 21, dx + 9, dy - 19), HALL_STONE, 0.95, dither=False)
    arch = c.rect(dx - 6, dy - 18, dx + 6, dy + 1) & ~(((c.xx < dx - 4) | (c.xx >= dx + 4)) & (c.yy < dy - 15))
    wood = ramp("#3a2614", "#5a3c20", "#82592e", "#ad7e44")
    c.paint(arch, wood, np.where(((c.xx - (dx - 6)) % 6) == 5, 0.04, 0.5 + 0.14 * (grain - 0.5) + 0.2 * (c.xx < dx - 2)), dither=False)
    c.paint(c.rect(dx - 6, dy - 13, dx + 6, dy - 11), BRIGHT_IRON, 0.55, dither=False)  # a strap
    c.paint(c.rect(dx - 6, dy - 4, dx + 6, dy - 2), BRIGHT_IRON, 0.55, dither=False)
    c.fill(c.rect(dx + 2, dy - 9, dx + 4, dy - 7), BRASS[3])  # a round knob at a child's height
    c.paint(c.rect(dx - 11, dy - 9, dx + 12, dy - 7), BRIGHT_IRON, np.where(c.yy == dy - 9, 0.9, 0.3), dither=False)  # the bolt bar across
    c.paint(c.rect(dx - 13, dy - 11, dx - 10, dy - 5), BRIGHT_IRON, 0.5, dither=False)  # its staples in the wall
    c.paint(c.rect(dx + 10, dy - 11, dx + 13, dy - 5), BRIGHT_IRON, 0.5, dither=False)
    c.paint(c.rect(dx + 9, 13, dx + 12, dy - 9), BRIGHT_IRON, np.where(c.xx < dx + 10, 0.8, 0.22), dither=False)  # the thick rod, beside the door
    c.paint(c.rect(dx + 8, dy - 12, dx + 13, dy - 9), BRASS, 0.7, dither=False)  # and the clasp that holds the bar's end
    c.fill(c.rect(dx + 9, dy - 12, dx + 10, dy - 11), BRASS[3])
    # ---- the pipes along the top of both wings, with flanges, and the drops at the corners
    for x0, x1 in ((16, 90), (310, 384)):
        c.paint(c.rect(x0, 14, x1, 19), BRIGHT_IRON, np.where(c.yy < 15, 0.9, np.where(c.yy > 17, 0.16, 0.5)), dither=False)
        for fx in range(x0 + 6, x1 - 4, 20):
            c.paint(c.rect(fx, 13, fx + 3, 20), BRIGHT_IRON, np.where(c.xx == fx, 0.9, 0.3), dither=False)
            c.paint(c.rect(fx, 20, fx + 2, 24), RUST, 0.5, dither=False)
    for x in (18, 376):
        c.paint(c.rect(x, 8, x + 6, 48), BRIGHT_IRON, np.where(c.xx < x + 2, 0.8, np.where(c.xx > x + 3, 0.18, 0.46)), dither=False)
        for fy in (26, 40):
            c.paint(c.rect(x - 1, fy, x + 7, fy + 3), BRIGHT_IRON, np.where(c.yy == fy, 0.9, 0.3), dither=False)
    # ---- the shadow of the wall on the floor row
    sh = (c.yy >= 48) & (c.yy < 52) & (c.xx >= 14) & (c.xx < 386) & (pa.BAYER4[np.arange(MA_H)[:, None] % 4, np.arange(MA_W)[None, :] % 4] < np.where(c.yy < 50, 0.75, 0.35))
    c.fill(sh, HALL_STONE[0])
    # ---- the side walls: dark iron girders with rivets, a lit edge towards the room
    for x0, x1, lit_edge in ((0, 16, 14), (MA_W - 16, MA_W, MA_W - 16)):
        c.paint(c.rect(x0, 8, x1, MA_H), BRIGHT_IRON, 0.12, dither=False)
        face = (4, 12) if x0 == 0 else (MA_W - 12, MA_W - 4)
        c.paint(c.rect(face[0], 8, face[1], MA_H - 6), BRIGHT_IRON, 0.32 - 0.14 * np.clip((c.yy - 8) / 200.0, 0, 1) + 0.06 * (grain - 0.5), dither=False)
        c.paint(c.rect(lit_edge, 8, lit_edge + 2, MA_H - 6), BRIGHT_IRON, 0.62 if x0 == 0 else 0.2, dither=False)
        for ry in range(20, MA_H - 10, 24):
            c.fill(c.rect(face[0] + 3, ry, face[0] + 5, ry + 2), BRIGHT_IRON[4])
    # ---- the front wall with its door in the room column 3
    fy = MA_H - 16
    _blocks(c, 4, fy, MA_W - 4, MA_H - 2, 8, 22, HALL_STONE, rng, base=0.34, lit=0.08)
    c.paint(c.rect(4, fy, MA_W - 4, fy + 3), HALL_STONE, np.where(c.yy < fy + 1, 0.9, 0.5), dither=False)
    c.paint(c.rect(4, MA_H - 3, MA_W - 4, MA_H), BRIGHT_IRON, 0.08, dither=False)
    d0, d1 = 48, 64
    c.paint(c.rect(d0 - 3, fy, d0, MA_H), HALL_STONE, 0.7, dither=False)
    c.paint(c.rect(d1, fy, d1 + 3, MA_H), HALL_STONE, 0.3, dither=False)
    c.paint(c.rect(d0 - 3, fy, d1 + 3, fy + 3), HALL_STONE, 0.85, dither=False)
    leaf = c.rect(d0, fy + 3, d1, MA_H - 1)
    plank = ((c.xx - d0) // 4).astype(int)
    c.paint(leaf, ramp("#2a1c10", "#3e2a18", "#5a3e24", "#7a5634"), np.where(((c.xx - d0) % 4) == 3, 0.06, 0.46 + 0.1 * ((plank * 7 + 3) % 5) / 5.0 + 0.1 * (grain - 0.5)),
            dither=False)
    for sy in (fy + 5, fy + 11):
        c.paint(c.rect(d0, sy, d1, sy + 2), BRIGHT_IRON, 0.55, dither=False)
    c.paint(c.rect(d1 - 5, fy + 8, d1 - 2, fy + 11), BRIGHT_IRON, 0.85, dither=False)
    return c


def gate_open(ms):
    """The gate of the Anlage, open: the two stone pillars with their balls as before, the two leaves swung back against them (seen nearly edge-on,
    three bars and two rails each), the chain hanging loose from the left leaf with the lock open at its end, and nothing between the pillars
    but the ground. 48 x 44 like the shut gate, anchor (24, 38): it fills the same three cells."""
    rng = np.random.default_rng(3061)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 44)
    for x0 in (0, 38):
        _blocks(c, x0, 8, x0 + 10, 40, 6, 10, ex["stone_wall"], rng, base=0.5, lit=0.1, stagger=False)
        c.paint(c.rect(x0 - 1 if x0 else 0, 5, x0 + 10 if x0 == 0 else 48, 9), ex["stone_wall"], np.where(c.yy < 6, 0.9, 0.55), dither=False)
        ball = c.ellipse(x0 + 5, 3.5, 3.4, 3.2)
        c.paint(ball, ex["stone_wall"], 0.3 + 0.65 * c.sphere(x0 + 4, 2.5, 4, 4), dither=False)
    for lx0, lx1 in ((10, 15), (33, 38)):  # the leaves, swung back against the pillars: narrow, with a slant at the top
        c.paint(c.rect(lx0, 13, lx1, 15), BRIGHT_IRON, np.where(c.yy == 13, 0.8, 0.3), dither=False)
        c.paint(c.rect(lx0, 33, lx1, 35), BRIGHT_IRON, np.where(c.yy == 33, 0.8, 0.3), dither=False)
        c.paint(c.rect(lx0, 23, lx1, 25), BRIGHT_IRON, np.where(c.yy == 23, 0.8, 0.3), dither=False)
        for bx in range(lx0, lx1, 2):
            c.paint(c.rect(bx, 15, bx + 1, 33), BRIGHT_IRON, 0.5 if (bx - lx0) % 4 == 0 else 0.22, dither=False)
            c.fill(c.rect(bx, 13, bx + 1, 14), BRIGHT_IRON[4])
    for x in range(12, 18):  # the chain hanging from the left leaf, a loop of it on the ground
        y = 27 + (x - 12) * 2 // 3
        c.fill(c.rect(x, y, x + 1, y + 2), BRASS[1] if x % 2 else BRASS[2])
    for k in range(5):
        c.fill(c.rect(18 + k, 31 + (k % 2), 19 + k, 33 + (k % 2)), BRASS[1] if k % 2 else BRASS[2])
    c.paint(c.rect(22, 31, 26, 37), BRASS, 0.7, dither=False)  # the lock, lying open on the ground
    c.fill(c.rect(23, 32, 25, 33), BRASS[3])
    c.fill(c.rect(25, 29, 26, 32), BRASS[1])
    c.paint(c.rect(10, 36, 15, 40), ex["stone_wall"], 0.38, dither=False)  # the sill stones stay at the pillars
    c.paint(c.rect(33, 36, 38, 40), ex["stone_wall"], 0.38, dither=False)
    _gate_plate(c)
    c.outline(st["outline"])
    return c


def build_hall(ms):
    """Registers the sprites of the hall in the catalog (prefix `ma_`). The shell and the console are flat; the levers, the covers, the dials and
    the lamps stand on cells of their own. No catalog shadow on anything the story takes or changes (the covers, the open gate, the gauge needles
    are props of their own); the furniture of the hall stands on the floor of `maschine`, which is baked after it and is the only map with this
    prefix (no other stamp changes)."""
    ms.save("tal", "ma_shell", hall_shell(ms), (8, 8), flat=True)
    ms.save("tal", "ma_console", hall_console(ms), (120, 24), flat=True, shape={"rect": [240, 30], "offset": [0, -9]})
    for n in range(1, 13):
        ms.save("tal", "ma_lever_%d_up" % n, hall_lever(ms, n, False), (8, 30))
        ms.save("tal", "ma_lever_%d_down" % n, hall_lever(ms, n, True), (8, 30))
    ms.save("tal", "ma_lever_cover", hall_cover(ms), (8, 36))
    ms.save("tal", "ma_bolt", hall_bolt(ms), (8, 16))
    for k in range(1, 5):  # the dials of the left wing are drawn 8 pixels right of their cell, those of the right wing 8 pixels left (they fit between the side wall and the console)
        ms.save("tal", "ma_gauge_%d" % k, hall_gauge(ms, k), GAUGE_ANCHOR[k])
        ms.save("tal", "ma_needle_%d" % k, hall_needle(ms, k), (3, 13))
    ms.save("tal", "ma_worn_dial", hall_worn_dial(ms), (8, 13))
    lamp_light = {"offset": [0, -16], "color": "#ffd9a0", "energy": 0.9, "range": 96}
    pic, glow = hall_lamp_hang(ms)
    ms.save("tal", "ma_lamp_hang", pic, (8, 30), emissive=glow, lights=[lamp_light])
    # G5: the lamp that fails while the levers fall: the same picture gone dark, on the same cell. No light, no glow, no shadow (the map shows it `if`).
    ms.save("tal", "ma_lamp_hang_dark", hall_lamp_hang_dark(ms), (8, 30))
    pic, glow = hall_lamp(ms)
    ms.save("tal", "ma_lamp", pic, (8, 44), emissive=glow, shape={"circle": 4, "offset": [0, -2]}, shadow=[6, 2],
            lights=[{"offset": [0, -34], "color": "#ffd9a0", "energy": 0.85, "range": 88}])
    ms.save("tal", "ma_tank", hall_tank(ms), (8, 40), shape={"rect": [32, 12], "offset": [8, -6]}, shadow=[16, 3])
    ms.save("tal", "ma_pipe_run", hall_pipe_run(ms), (8, 14), shape={"rect": [80, 8], "offset": [32, -4]}, shadow=[40, 2])
    ms.save("tal", "ma_hiss_pipe", hall_hiss_pipe(ms), (8, 46), shape={"circle": 4, "offset": [0, -2]}, shadow=[6, 2])
    ms.save("tal", "ma_steam", [hall_steam(ms, 3071 + i) for i in range(3)], (9, 22))
    ms.save("tal", "gb_plant_gate_open", gate_open(ms), (24, 38))


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
    # Hochtal (G2). Things that go with a flag (the stone, the quartz, the thimble) or that G3 and G6 take away (the gate, the heap of
    # scree reuses `gb_rockfall`) have no shadow; the hall, the fence, the pines, the sign and the den stay and cast one or none.
    ms.save("tal", "gb_plant_hall", plant_hall(ms), (96, 162), shape={"rect": [176, 20], "offset": [0, -8]}, shadow=[92, 7])
    ms.save("tal", "gb_plant_fence", plant_fence(ms), (8, 24), shape={"rect": [16, 6], "offset": [0, -2]})
    ms.save("tal", "gb_plant_gate", plant_gate(ms), (24, 38), shape={"rect": [48, 8], "offset": [0, -2]})
    ms.save("tal", "gb_dwarf_pine", [dwarf_pine(ms, 2101), dwarf_pine(ms, 2102), dwarf_pine(ms, 2103)], (24, 28),
            shape={"circle": 6, "offset": [0, -3]}, sway=0.5, shadow=[17, 4])
    ms.save("tal", "gb_hand_stone", hand_stone(ms), (17, 11), flat=True)
    ms.save("tal", "gb_round_stone", round_stone(ms), (6, 5), flat=True)
    ms.save("tal", "gb_quartz", quartz(ms), (9, 22))
    ms.save("tal", "gb_marmot_den", marmot_den(ms), (36, 36), shape={"rect": [46, 12], "offset": [0, -14]})
    ms.save("tal", "gb_thimble", thimble(ms), (5, 10))
    ms.save("tal", "gb_sign_view", view_sign(ms), (19, 44), shape={"circle": 3, "offset": [0, -1]}, shadow=[7, 2])
    ms.save("tal", "gb_smoke_plant", smoke(ms, 96), (8, 94), flat=True)
    # Das Verstecken (G6). The candle goes with a flag and the hollow stands on a cell of the old stamp, so neither has a shadow in the catalog;
    # the sign stands on a cell of the stamp too (the fork), with a collision of its own like the other signs and no shadow.
    ms.save("tal", "gb_fork_sign", fork_sign(ms), (12, 24), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "gb_cleft_alcove", cleft_alcove(ms), (12, 26))
    ms.save("tal", "gb_candle", candle_stub(ms), (5, 10))
    # Das Kind (G7). The rock lies on cells of the old stamp, the sprout in the valley's bed and the frame in the air: none of them has a shadow, a
    # collision or a light in the catalog (the rock is flat, so figures stand above it; the player sits on it, nothing blocks her).
    ms.save("tal", "gb_sit_rock", sit_rock(ms), (8, 7), flat=True)
    ms.save("tal", "gb_picture_frame", picture_frame(ms), (12, 12))
    ms.save("tal", "gb_sprout", sprout(ms), (6, 12))
    build_hall(ms)


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [cairn(ms, "a", 1801), cairn(ms, "b", 1802), cairn(ms, "c", 1803), boulder(ms, 1811), boulder(ms, 1812)]
    items += [scree(ms, 1821), scree(ms, 1822), scree(ms, 1823), slate_chip(ms), chalk_arrow(ms), stone_mark(ms)]
    items += [net_post(ms), net_branch(ms), iron_ring(ms), trail_sign(ms), steps(ms), planks(ms), lookout(ms), rockfall(ms), smoke(ms)]
    items += [plant_hall(ms), plant_fence(ms), plant_gate(ms), dwarf_pine(ms, 2101), hand_stone(ms), round_stone(ms), quartz(ms), marmot_den(ms),
              thimble(ms), view_sign(ms), smoke(ms, 96), fork_sign(ms), cleft_alcove(ms), candle_stub(ms), sit_rock(ms), picture_frame(ms), sprout(ms)]
    sheet = Image.new("RGBA", (1400, 200), (96, 136, 88, 255))
    x = 6
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        if x + img.width > 1390:
            break
        sheet.alpha_composite(img, (x, 196 - img.height if img.height < 196 else 0))
        x += img.width + 6
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


def preview_hall(path):
    """`--preview-hall out.png`: the shell with the console, the levers (the first three live, pulled and not), the covers, the dials with their
    needles at rest, the lamps and the rest of the furniture laid out like content/maps/maschine.txt (3x), and under it every piece on its own."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image

    def img(canvas):
        return Image.fromarray(canvas.rgba().astype(np.uint8), "RGBA")

    sheet = Image.new("RGBA", (MA_W + 20, MA_H + 190), (96, 92, 84, 255))
    floor = Image.new("RGBA", (MA_W, MA_H), (128, 124, 116, 255))
    sheet.alpha_composite(floor, (10, 10))

    def put(pic, anchor, cell, lift=0):
        sheet.alpha_composite(pic, (10 + cell[0] * 16 + 8 - anchor[0], 10 + cell[1] * 16 + 8 - anchor[1] - lift))

    put(img(hall_shell(ms)), (8, 8), (0, 0))
    put(img(hall_console(ms)), (120, 24), (12, 4))
    for n, col in enumerate(MA_LEVER_COLS, 1):
        put(img(hall_lever(ms, n, n == 2)), (8, 30), (col, 3))
        if n > 3:
            put(img(hall_cover(ms)), (8, 36), (col, 4), 9)
    put(img(hall_bolt(ms)), (8, 16), (12, 3))
    put(img(hall_worn_dial(ms)), (8, 13), (19, 3))
    for k, col in zip(range(1, 5), (1, 3, 21, 23)):
        put(img(hall_gauge(ms, k)), GAUGE_ANCHOR[k], (col, 3))
        big = Image.new("RGBA", (31, 31), (0, 0, 0, 0))
        big.alpha_composite(img(hall_needle(ms, k)), (15 - 3, 15 - 13))
        put(big.rotate(-GAUGE_NORMAL[k], resample=Image.NEAREST, center=(15, 15)), (15 - (14 - GAUGE_ANCHOR[k][0]), 15), (col, 3), 22)
    put(img(hall_lamp_hang(ms)[0]), (8, 30), (5, 2))
    put(img(hall_lamp_hang(ms)[0]), (8, 30), (19, 2))
    for cell in ((5, 8), (19, 8), (1, 12), (23, 12)):
        put(img(hall_lamp(ms)[0]), (8, 44), cell)
    put(img(hall_tank(ms)), (8, 40), (1, 6))
    put(img(hall_tank(ms)), (8, 40), (22, 6))
    put(img(hall_pipe_run(ms)), (8, 14), (15, 9))
    put(img(hall_hiss_pipe(ms)), (8, 46), (3, 10))
    put(img(hall_steam(ms, 3071)), (9, 22), (3, 8), 8)
    x, y = 10, MA_H + 20
    for pic in (hall_lever(ms, 1, False), hall_lever(ms, 1, True), hall_cover(ms), hall_bolt(ms), hall_worn_dial(ms), hall_gauge(ms, 1), hall_gauge(ms, 2),
                hall_gauge(ms, 3), hall_gauge(ms, 4), hall_needle(ms, 1), hall_steam(ms, 3071), hall_steam(ms, 3072), hall_steam(ms, 3073),
                hall_hiss_pipe(ms), hall_tank(ms), gate_open(ms), plant_gate(ms), hall_lamp_hang(ms)[0], hall_lamp_hang_dark(ms)):
        im = img(pic)
        if x + im.width > sheet.width:
            x, y = 10, y + 58
        sheet.alpha_composite(im, (x, y))
        x += im.width + 6
    x, y = 10, y + 58
    for n in range(1, 13):
        for down in (False, True):
            im = img(hall_lever(ms, n, down))
            if x + im.width > sheet.width:
                x, y = 10, y + 56
            sheet.alpha_composite(im, (x, y))
            x += im.width + 2
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    elif len(sys.argv) > 2 and sys.argv[1] == "--preview-hall":
        preview_hall(sys.argv[2])
    else:
        sys.exit("usage: akt5_props.py --preview out.png | --preview-hall out.png")
