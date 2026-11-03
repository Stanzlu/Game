#!/usr/bin/env python3
"""Layout helper for the Act V maps (docs/akt5/REGIONSBRIEFE.md).

Draws the [map] block of content/maps/pass.txt (G1).

pass (96 x 58, class M, ADR-068): the ascent into the mountains. A path climbs from the south (the door from the road, in
a notch of the forest) to the north along a brook, in four turns. Below, a meadow at the forest's edge with the brook on
its east side (a plank bridge over it); above it four shelves, each under a band of rock, joined by short ramps at
alternating ends (east, west, east, west), so that every shelf is walked once in the other direction. The brook comes down
through the bands in small falls and crosses every shelf (a ford on the way); it rises in a pool at the foot of the
northern wall. The shelves lose their grass as they rise: meadow, scree among grass, scree, bare rock. The way ends in a
gap in the northern wall, closed by a rock fall (G2 puts the door into the high valley there). Nothing marks the way but
cairns, every dozen or so cells, each in sight of the one before, and the column of smoke of the plant, far away at the
top right.

Hand-written head (meta, legend) stays; only the [map] block is replaced.

Usage: python3 tools/art/layout_akt5_maps.py pass [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/pass.txt (once the layout is final: ADR-068).
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from layout_look_maps import Grid, wobble  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

W, H = 96, 58
DOOR_X = 56  # the door to the road, in a notch of the southern forest (five cells wide: 54 to 58)
DOOR_Y = 56
ARRIVAL = (DOOR_X, DOOR_Y - 1)
START = (47, 50)  # the start of a new run: west of the way, room to walk five cells east and five south (the benchmark does)
# the shelves, from south to north: nominal rows (y0, y1) and columns (x0, x1) of each (edges wander); the bands of rock lie between
SHELVES = [(44, 56, 8, 87), (34, 41, 15, 82), (24, 31, 11, 86), (14, 21, 15, 84), (4, 11, 13, 79)]
BAND_ROWS = [(42, 43), (32, 33), (22, 23), (12, 13)]  # the nominal rows of the bands (band j lies north of shelf j)
RAMP_X = [72, 22, 80, 22]  # the ramps' middle columns: east, west, east, west
RAMP_W = 5  # the ramps are broad (the path is three cells wide in their middle): a cairn at each end can see the next across it
# the brook: control points (x, y) and widths; it rises at the foot of the northern wall and leaves through the south
BROOK = [(63, 58), (63, 54), (63, 50.5), (62.5, 48), (61, 46), (58, 44.5), (55, 43), (53, 40.5), (51.5, 38), (49.5, 35), (47.5, 33),
         (45.5, 30), (44, 27.5), (42, 25), (40, 22.5), (38.5, 20), (37, 17), (35, 14.5), (33.5, 12.5), (32.5, 10), (31.5, 7.5), (31, 5.5)]
BROOK_W = [3.0, 3.0, 3.0, 3.0, 3.0, 2.8, 2.6, 2.6, 2.6, 2.6, 2.5, 2.5, 2.5, 2.5, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.3, 2.2]
PLANK_ROWS = (49, 50)  # the plank bridge over the brook: two rows of boards (y cells), the brook three cells wide there
# the path: waypoints; the ramps are straight and vertical in the band (the spline passes (rx, y) above and below)
PATH = [(56, 55), (55.5, 53), (55, 51), (57, 50.2), (60, 49.8), (63, 49.6), (66, 48.6), (69, 46.8), (71.5, 45), (72, 43.2),
        (72, 40.8), (70, 38.5), (65, 37.6), (59, 38.6), (54, 37.2), (49, 38), (44, 39.2), (38, 38), (32, 36.6), (27, 38),
        (23, 37), (22, 35), (22, 32.6), (22, 30.6), (24, 29.5), (28, 28.4), (32, 27), (37, 28.4), (43, 28), (49, 26.5),
        (55, 28), (61, 29.5), (67, 28), (73, 29), (78, 27.5), (80, 25), (80, 22.6), (80, 20.4), (77, 19.5), (72, 18),
        (66, 19.5), (60, 18), (54, 19), (48, 17.5), (42, 18.6), (36, 17.6), (30, 18.6), (26, 17.5), (23, 18), (22, 15),
        (22, 12.6), (22, 10.6), (25, 9.5), (28, 8), (31.5, 8.2), (37, 9.5), (43, 8), (49, 9), (55, 7.5), (60, 6.2),
        (64, 5.6), (66, 4.6)]
PATH_W = 2.9
NOTCH_X = 66  # the gap in the northern wall, five cells wide (64 to 68), three rows deep; the blocker lies in its mouth
NOTCH_ROWS = (1, 3)
BLOCKER = (NOTCH_X, 3)
ROCKFALL = (NOTCH_X, 2)
SMOKE = (88, 14)  # the foot of the column of smoke: on the rock of the north-east, it rises into the sky above the top right
# the fixed spots of the walk (x, y); None for y means: the first row of the shelf under the wall above it
SPOTS = {
    "cairn_first": (52, 50),     # the first cairn: west of the way, in sight of the arrival
    "net_boundary": (69, 44),    # Mira's trace, tidy: a post at the edge of the path
    "net_joined": (66, 51),      # on the side of the path she walks on: a branch at arm height
    "stone_silent": (68, 47),    # in the middle of the path: a flat stone
    "sign": (64, 35),            # the hand-painted sign
    "slate": (15, 28),           # the slate chip in the corner west of the ramp
    "ring": (68, None),          # the iron ring in the wall of band 2, on shelf 2
    "lookout": (73, 15),         # the rock with the view
}
SPOT_SHELF = {"ring": 2}

GROUND = {  # the ground each glyph of the map paints (the legend of pass.txt)
    ".": ".", ",": ",", "m": "m", "p": "p", "~": "~", "h": "h", "^": "^", "v": "v", "w": "w", "y": "y",
    "T": ".", "C": ".", "P": ".", "R": ".", "r": "m", "g": ".", "u": ".", "O": ".", "o": "m",
    "A": ".", "B": ".", "K": ".", "a": "m", "b": "m", "k": "m", "S": "m",
    "@": ".", "n": ",", "N": ",", "s": ",", "X": ",", "F": ",", "Z": "^",
    "1": ".", "2": ".", "3": ".", "4": ",", "5": ".", "6": "y", "7": ".", "8": ".", "9": ".",
}


def _centerline(points, widths=None):
    """A spline's centre line, sampled the way Grid.path does: [(x, y, width)]."""
    out = []
    for i in range(len(points) - 1):
        p0 = points[max(i - 1, 0)]
        p1, p2 = points[i], points[i + 1]
        p3 = points[min(i + 2, len(points) - 1)]
        for s in range(40):
            t = s / 40
            t2, t3 = t * t, t * t * t
            x, y = (0.5 * (2 * p1[k] + (-p0[k] + p2[k]) * t + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2
                           + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3) for k in (0, 1))
            w = (widths[i] + (widths[i + 1] - widths[i]) * t) if widths else 0.0
            out.append((x, y, w))
    out.append((points[-1][0], points[-1][1], widths[-1] if widths else 0.0))
    return out


_PATH = _centerline(PATH)
_BROOK = _centerline(BROOK, BROOK_W)


def stamp(g, samples, ch, width=None, only=None):
    """Sets every cell within half a width of a sample (each sample touches only its own neighbourhood)."""
    for sx, sy, sw in samples:
        r = (width if width is not None else sw) / 2
        for y in range(int(math.floor(sy - r)), int(math.ceil(sy + r)) + 1):
            for x in range(int(math.floor(sx - r)), int(math.ceil(sx + r)) + 1):
                if math.hypot(x - sx, y - sy) <= r:
                    g.set(x, y, ch, only)


def path_distance(x, y):
    """Distance of a cell from the path's centre line."""
    return min(math.hypot(x - sx, y - sy) for sx, sy, _ in _PATH[::3])


def brook_x(y):
    """Centre column of the brook at row y (the sample nearest to it)."""
    return min(_BROOK, key=lambda s: abs(s[1] - y))[0]


def brook_distance(x, y):
    """Distance of a cell's centre from the brook's edge (negative inside)."""
    return min(math.hypot(x - sx, y - sy) - sw / 2 for sx, sy, sw in _BROOK[::3])


def path_samples():
    """The path's centre line as one list of (x, y), south to north (about a quarter cell apart)."""
    return [(x, y) for x, y, _ in _PATH]


def band_rows(j, x):
    """Rows (ya, yb) of band j at column x: the nominal two rows and up to two more, the edges wander (a cliff is never a line)."""
    ya, yb = BAND_ROWS[j]
    up = max(0.0, wobble(x, (1.0, 3.3, j), (0.8, 7.7, 2.0 * j), (0.5, 1.9, 0.7 * j)) + 0.6)
    down = max(0.0, wobble(x, (1.0, 4.1, 1.0 + j), (0.8, 6.1, 0.4 * j), (0.5, 2.3, 1.1 * j)) + 0.6)
    return ya - min(2, round(up)), yb + min(2, round(down))


def shelf_rows(k, x):
    """Rows (ya, yb) of shelf k at column x: between the band north of it and the band south of it."""
    y0, y1, _, _ = SHELVES[k]
    ya = band_rows(k, x)[1] + 1 if k < 4 else y0 + round(wobble(x, (0.8, 3.9, 0.7), (0.6, 8.3, 1.1)))
    yb = band_rows(k - 1, x)[0] - 1 if k > 0 else y1
    return ya, yb


def shelf_edges(k, y):
    """Ragged west and east edge (columns) of shelf k at row y."""
    _, _, x0, x1 = SHELVES[k]
    xl = x0 + round(wobble(y + 7 * k, (1.6, 2.7, 0.3 * k), (1.0, 5.1, 1.1), (0.8, 1.4, 2.0 + k)))
    xr = x1 + round(wobble(y + 3 * k, (1.6, 3.1, 1.7 + k), (1.1, 4.3, 0.2), (0.8, 1.7, 0.5 * k)))
    return xl, xr


def outer_ground(x, y):
    """What lies outside the shelves and the bands: forest below, rock above (a ragged line between them)."""
    line = 36 + round(wobble(x, (3.0, 6.3, 0.4), (2.0, 3.1, 1.3)))
    side = 14 - min(x, W - 1 - x)  # the flanks: forest reaches higher up the slope there, in tongues
    if side > -4:
        line = min(line, 24 + round(wobble(x, (4.0, 3.1, 0.9), (3.0, 1.7, 0.2), (2.0, 5.3, 1.4))) + max(0, -side) * 2)
    return "h" if y >= line else "^"


def scree(x, y, k):
    """Is the ground of shelf k bare gravel here? Patches that grow with the height (a smooth field of sines)."""
    n = (math.sin(x / 5.3 + 1.3) * math.sin(y / 3.7 + 0.7) + 0.6 * math.sin((x + y) / 7.9)
         + 0.5 * math.sin((x - y) / 4.7 + 2.0) + 0.4 * math.sin(x / 2.3 + y / 3.1))
    return n > (9.0, 1.35, 0.95, 0.55, 0.3)[k]


def spot(name):
    """The cell of a fixed spot (the ring's row is the shelf's first row under the wall)."""
    x, y = SPOTS[name]
    if y is None:
        y = shelf_rows(SPOT_SHELF[name], x)[0]
    return x, y


def land():
    g = Grid(W, H, "^")
    for y in range(H):
        for x in range(W):
            g.set(x, y, outer_ground(x, y))
    # the shelves: grass or gravel; the bands between them are rock
    for k in range(5):
        for x in range(W):
            ya, yb = shelf_rows(k, x)
            for y in range(ya, yb + 1):
                xl, xr = shelf_edges(k, y)
                if xl <= x <= xr:
                    g.set(x, y, "m" if scree(x, y, k) else ".")
    for j in range(4):
        for x in range(W):
            top, bot = band_rows(j, x)
            for y in range(top, bot + 1):
                lo = shelf_edges(j, y)
                hi = shelf_edges(j + 1, y)
                if min(lo[0], hi[0]) <= x <= max(lo[1], hi[1]):
                    g.set(x, y, "^")
    # the southern forest's edge: ragged, the notch of the door in it
    for x in range(W):
        south = DOOR_Y + 1 - round(1.0 + wobble(x, (1.0, 3.1, 0.2), (0.7, 5.3, 1.0)))
        for y in range(south, H):
            g.set(x, y, "h")
    for y in range(DOOR_Y - 2, DOOR_Y + 1):
        for x in range(DOOR_X - 2 - (DOOR_Y - y), DOOR_X + 3 + (DOOR_Y - y)):
            g.set(x, y, ".")
    # groves of the forest reaching into the meadow, away from the way
    for cx, cy, rx, ry in ((16, 48, 7, 5), (24, 53, 5, 2.5), (82, 49, 6, 5), (74, 54, 4.5, 2.2), (37, 53, 3.5, 2.0), (15, 41, 4, 2.5),
                           (84, 41, 3, 2)):
        for y in range(H):
            for x in range(W):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0 and g.get(x, y) in ".m" and path_distance(x, y) > 6 and \
                        brook_distance(x, y) > 6:
                    g.set(x, y, "h")
    # the gap in the northern wall: a short canyon, five cells wide, down to the shelf
    for y in range(NOTCH_ROWS[0], 7):
        for x in range(NOTCH_X - 2, NOTCH_X + 3):
            g.set(x, y, ",")
    # the brook, through the forest at the south end too
    stamp(g, _BROOK, "~", only=".m,ph")
    # the path (not over the water, not through the bands but where the ramps are): it carves away what a bulge of a band put in its way
    for sx, sy, _ in _PATH:
        r = PATH_W / 2
        for y in range(int(math.floor(sy - r)), int(math.ceil(sy + r)) + 1):
            for x in range(int(math.floor(sx - r)), int(math.ceil(sx + r)) + 1):
                if math.hypot(x - sx, y - sy) <= r and (g.get(x, y) in ".mp" or (
                        g.get(x, y) == "^" and not any(ya <= y <= yb for ya, yb in BAND_ROWS))):
                    g.set(x, y, ",")
    for j, rx in enumerate(RAMP_X):
        for x in range(rx - RAMP_W // 2, rx + RAMP_W // 2 + 1):
            top, bot = band_rows(j, x)
            for y in range(top - 1, bot + 2):
                g.set(x, y, ",")
    # the falls: where the brook leaves a band, three cells of it drop (rock cells turn into falling water)
    for j in range(4):
        ya, yb = BAND_ROWS[j]
        cx = int(round(brook_x((ya + yb) / 2)))
        for x in range(cx - 1, cx + 2):
            top, bot = band_rows(j, x)
            for y in range(top, bot + 1):
                if g.get(x, y) == "^":
                    g.set(x, y, "v")
            for y in (top - 1, bot + 1):  # the brook above the fall and the pool it lands in (the foam is painted on water)
                if g.get(x, y) in ".m,p":
                    g.set(x, y, "~")
    # a few puddles in the hollows of the path (not near a spot of the walk)
    spots = [spot(name) for name in SPOTS]
    for frac in (0.07, 0.11, 0.3, 0.44, 0.52, 0.7, 0.88):
        sx, sy, _ = _PATH[int(frac * len(_PATH))]
        for dx in (0, 1):
            x, y = int(round(sx)) + dx, int(round(sy))
            if g.get(x, y) == "," and all(math.hypot(x - a, y - b) >= 3 for a, b in spots) and g.get(x, y - 1) != "^":
                g.set(x, y, "p")
    # a small patch of meadow at every fixed spot that stands on grass (nothing grows on the path itself)
    for name in SPOTS:
        sx, sy = spot(name)
        if name == "stone_silent":
            continue
        for y in range(sy - 1, sy + 2):
            for x in range(sx - 1, sx + 2):
                if g.get(x, y) in "m":
                    g.set(x, y, ".")
    # the fords and the plank bridge (ground like the rest: the committed map's cells are what land() draws, except where a prop stands)
    land.fords = [crossing(g, k)[0] for k in range(1, 5)]
    land.plank_x = planks(g)
    return g


land.fords = []
land.plank_x = 0


def crossing(g, k):
    """The ford of shelf k: where the path meets the brook, the water cells of three rows turn walkable (`w`)."""
    y0, y1, _, _ = SHELVES[k]
    best = None
    for sx, sy, _ in _PATH:
        if y0 <= sy <= y1:
            d = abs(brook_x(sy) - sx) if abs(sy - min(_BROOK, key=lambda s: abs(s[0] - sx) + abs(s[1] - sy))[1]) < 3 else 99
            if best is None or d < best[0]:
                best = (d, sx, sy)
    _, fx, fy = best
    fx, fy = int(round(fx)), int(round(fy))
    cells = []
    for y in range(fy - 1, fy + 2):
        for x in range(fx - 5, fx + 6):
            if g.get(x, y) == "~":
                g.set(x, y, "w")
                cells.append((x, y))
    return (fx, fy), cells


def planks(g):
    """The plank bridge: two rows of boards over three cells of the brook (`y`), a path cell at each end."""
    rows = []
    for y in PLANK_ROWS:
        water = [x for x in range(50, 75) if g.get(x, y) == "~"]
        x0 = int(round(sum(water) / len(water))) - 1
        for x in range(45, 80):  # a clean cut across: the brook is exactly three cells wide in these rows
            if g.get(x, y) == "~":
                g.set(x, y, ",")
        for x in range(x0, x0 + 3):
            g.set(x, y, "y")
        g.set(x0 - 1, y, ",")
        g.set(x0 + 3, y, ",")
        rows.append(x0)
    assert len(set(rows)) == 1, rows
    return rows[0]


BLOCKS = set("h^vTCPOo")


def sight(g, a, b):
    """Is there a clear line between two cells (nothing solid or tall on it)?"""
    (x0, y0), (x1, y1) = a, b
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(1, n):
        t = i / n
        x, y = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t))
        if (x, y) in (a, b):
            continue
        if g.get(x, y) in BLOCKS:
            return False
    return True


def build():
    """The grid with the placements: the named spots first, the groves and the rocks, then the cairns that keep each other in sight."""
    g = land()
    rng = random.Random(5801)
    named = {}
    shortfall = {}
    reserved = []  # (x0, x1, y0, y1): no tall crown inside (a crown hides what lies behind it, south of its foot)
    trees = []

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        assert g.get(x, y) == GROUND[glyph], (glyph, x, y, g.get(x, y), GROUND[glyph])
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    def hidden(x, y):
        return any(x0 <= x <= x1 and y0 <= y <= y1 for x0, x1, y0, y1 in reserved)

    def free(x, y, clearance, ground="."):
        return all(g.get(x + dx, y + dy) in ground for dy in range(-clearance, clearance + 1)
                   for dx in range(-clearance, clearance + 1))

    def scatter(glyphs, count, clearance, region, test=lambda x, y: True, tall=False, apart=0, road=0.0, brook=0.0):
        """`glyphs` is one glyph for grass, or a pair (on grass, on gravel); each cell takes the one that fits its ground."""
        on_grass, on_gravel = (glyphs, None) if isinstance(glyphs, str) and len(glyphs) == 1 else (glyphs[0], glyphs[1])
        placed = tries = 0
        x0, x1, y0, y1 = region
        while placed < count and tries < 9000:
            tries += 1
            x, y = rng.randint(x0, x1), rng.randint(y0, y1)
            here = g.get(x, y)
            glyph = on_grass if here == "." else (on_gravel if here == "m" else None)
            if glyph is None or not free(x, y, clearance, ".m" if on_gravel else ".") or not test(x, y):
                continue
            if tall and hidden(x, y):
                continue
            if road and path_distance(x, y) < road:
                continue
            if brook and brook_distance(x, y) < brook:
                continue
            if apart and any(abs(x - tx) < apart and abs(y - ty) < apart for tx, ty in trees):
                continue
            g.set(x, y, glyph)
            if tall:
                trees.append((x, y))
            named.setdefault(glyph, []).append((x, y))
            placed += 1
        if placed < count:
            shortfall[glyphs] = (placed, count)

    build.fords = list(land.fords)
    build.plank_x = land.plank_x
    # ---- the door to the road, the arrival, the start
    put("N", DOOR_X, DOOR_Y)
    put("n", *ARRIVAL)
    put("@", *START)
    # ---- the end: the blocker in the canyon's mouth, the rock fall behind it
    put("X", *BLOCKER)
    put("F", *ROCKFALL)
    # ---- the smoke of the plant, on the rock of the north-east
    put("Z", *SMOKE)
    # ---- steps of wood on the ramps (at the middle of each band)
    for j, rx in enumerate(RAMP_X):
        top, bot = band_rows(j, rx)
        put("s", rx, (top + bot) // 2)
    # ---- the things on the way
    put("1", *spot("cairn_first"))
    put("2", *spot("net_boundary"))
    put("3", *spot("net_joined"))
    put("4", *spot("stone_silent"))
    put("5", *spot("lookout"))
    put("7", *spot("sign"))
    put("8", *spot("slate"))
    put("9", *spot("ring"))
    px = build.plank_x
    put("6", px + 1, PLANK_ROWS[0])
    # ---- no tall crown hides a spot with a cue, nor the path (a crown hides what lies behind it, south of its foot)
    for glyph in "123456789XnN@":
        for x, y in named.get(glyph, []):
            reserved.append((x - 3, x + 3, y + 1, y + 8))
    for sx, sy in path_samples()[::4]:
        reserved.append((int(sx) - 1, int(sx) + 1, int(sy) + 1, int(sy) + 6))
    # ---- the trees of the meadow and the pines of the lower shelves
    def meadow(x, y):
        return y >= 44
    scatter("T", 6, 1, (10, 86, 44, 54), tall=True, apart=5, road=6.0, brook=4.0, test=meadow)
    scatter("C", 1, 1, (10, 86, 44, 54), tall=True, apart=5, road=6.0, brook=4.0, test=meadow)
    scatter("P", 10, 1, (6, 90, 36, 55), tall=True, apart=3, road=5.0, brook=3.0,
            test=lambda x, y: any(g.get(x + dx, y + dy) == "h" for dx in range(-3, 4) for dy in range(-3, 4)))
    scatter("P", 4, 1, (12, 84, 24, 41), tall=True, apart=4, road=4.0, brook=3.0,
            test=lambda x, y: any(g.get(x + dx, y + dy) in "^h" for dx in range(-2, 3) for dy in range(-2, 3)))
    # ---- boulders and rocks: on the shelves, along the walls and in the scree
    scatter("Oo", 5, 1, (12, 84, 34, 41), apart=0, road=3.2, brook=2.5, tall=True)
    scatter("Oo", 6, 1, (12, 86, 24, 31), apart=0, road=3.2, brook=2.5, tall=True)
    scatter("Oo", 7, 1, (16, 84, 14, 21), apart=0, road=3.2, brook=2.5, tall=True)
    scatter("Oo", 7, 1, (14, 78, 4, 11), apart=0, road=3.2, brook=2.5, tall=True)
    scatter("Rr", 10, 0, (10, 86, 40, 55), road=3.0, brook=2.5)
    scatter("Rr", 16, 0, (12, 86, 4, 41), road=2.6, brook=2.0)
    scatter((None, "S"), 34, 0, (12, 86, 14, 41), road=1.8, brook=1.5)
    scatter("g", 18, 0, (8, 88, 14, 55), road=2.8,
            test=lambda x, y: any(g.get(x + dx, y + dy) in "h~" for dx in range(-3, 4) for dy in range(-3, 4)))
    scatter("u", 6, 1, (8, 88, 40, 55), road=3.5, test=lambda x, y: any(g.get(x + dx, y + dy) == "h" for dx in range(-2, 3) for dy in range(-2, 3)))
    # ---- the cairns: the first is fixed (it has a cue), each next one stands as far on the way as is still in sight of the last
    chosen = [spot("cairn_first")]
    samples = path_samples()
    sub = list(range(0, len(samples), 3))
    cue_cells = [c for glyph in "123456789XFNn@s" for c in named.get(glyph, [])]
    candidates = []
    for y in range(H):
        for x in range(W):
            if g.get(x, y) not in ".m" or any(g.get(x + a, y + b) in "~vhw" for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                continue
            d, i = min((math.hypot(x - samples[i][0], y - samples[i][1]), i) for i in sub)
            if 1.9 <= d <= 4.0 and brook_distance(x, y) >= 1.0 and all(math.hypot(x - cx, y - cy) >= 2.5 for cx, cy in cue_cells):
                candidates.append((i, x, y))
    candidates.sort(reverse=True)
    cur = chosen[0]
    progress = min((math.hypot(cur[0] - samples[i][0], cur[1] - samples[i][1]), i) for i in sub)[1]
    arc = [0.0]
    for i in range(1, len(samples)):
        arc.append(arc[-1] + math.hypot(samples[i][0] - samples[i - 1][0], samples[i][1] - samples[i - 1][1]))
    while math.hypot(cur[0] - BLOCKER[0], cur[1] - BLOCKER[1]) >= 12:
        pick = None
        for i, x, y in candidates:  # the farthest on the way first
            dist = math.hypot(x - cur[0], y - cur[1])
            if i > progress + 20 and 8.0 <= dist <= 16.0 and arc[i] - arc[progress] <= 26.0 and sight(g, cur, (x, y)):
                pick = (i, (x, y))
                break
        if pick is None:
            break
        progress, cur = pick
        chosen.append(cur)
    forms = "ABK"
    for x, y in chosen[1:]:
        glyph = forms[rng.randrange(3)] if g.get(x, y) == "." else "abk"[rng.randrange(3)]
        put(glyph, x, y)
    build.cairns = chosen
    build.shortfall = shortfall
    return g, named


build.shortfall = {}
build.cairns = []
build.fords = []
build.plank_x = 0


BUILDERS = {"pass": build}


def text(name="pass"):
    return BUILDERS[name]()[0].text()


def write(name="pass"):
    path = os.path.join(ROOT, "content", "maps", "%s.txt" % name)
    with open(path, encoding="utf-8") as f:
        head = f.read()
    head = head[:head.index("[map]\n") + len("[map]\n")]
    grid_text = text(name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(head + grid_text + "\n")
    print("wrote [map] block of", os.path.relpath(path, ROOT))
    shortfall = BUILDERS[name].shortfall
    if shortfall:
        print("note: the scatter placed fewer than asked (glyph: placed, asked):", shortfall)


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in BUILDERS:
        sys.exit("usage: layout_akt5_maps.py pass [--write]")
    if "--write" in sys.argv:
        write(sys.argv[1])
    else:
        print(text(sys.argv[1]))
