#!/usr/bin/env python3
"""Layout helper for the Act V maps (docs/akt5/REGIONSBRIEFE.md).

Draws the [map] block of content/maps/pass.txt (G1) and content/maps/grat.txt (G2).

pass (96 x 58, class M, ADR-068): the ascent into the mountains. A path climbs from the south (the door from the road, in
a notch of the forest) to the north along a brook, in four turns. Below, a meadow at the forest's edge with the brook on
its east side (a plank bridge over it); above it four shelves, each under a band of rock, joined by short ramps at
alternating ends (east, west, east, west), so that every shelf is walked once in the other direction. The brook comes down
through the bands in small falls and crosses every shelf (a ford on the way); it rises in a pool at the foot of the
northern wall. The shelves lose their grass as they rise: meadow, scree among grass, scree, bare rock. The way ends in a
gap in the northern wall, closed by a rock fall (G2 puts the door into the high valley there). Nothing marks the way but
cairns, every dozen or so cells, each in sight of the one before, and the column of smoke of the plant, far away at the
top right.

grat (96 x 56, class M, ADR-068): the high valley above the pass. A basin between walls with a tarn in the middle (shallow along
its south and west shores), meadows and scree, thickets of mountain pine on the slopes, a marmot's slope east of the tarn and three
cairns that lead from the door in the south-west along the south shore to the Anlage in the north-east: a hall with a chimney in a
pocket of the rock, a fence from rock to rock in front of it with a gate (shut, blocker `plant_gate` in front) and a forecourt of
beaten earth. The Grat lies over the valley behind the blocker `ramp_wait` at the foot of the ramp in the north-west (G6 opens it):
a ledge along the northern wall, a rock island on it that the way goes round (north and south branch), the Spalte (a cleft three
cells wide and six deep opening on the south branch, above the Anlage) and, at the east end, a plateau of free ground (G8's door).
Nothing in the Grat is placed but the steps of the ramp and a few rocks and shrubs: G6 to G8 put their things into it.
G3 changed letters only, never ground (the stamp of the bake stays): the blocker at the gate goes with `grat.gate_open`, the gate changes its picture,
the door into the hall `maschine` (E, in front of the hall's own door) exists once the gate is open and its arrival (e, `spawn_maschine`) lies two cells in front of it.

Hand-written head (meta, legend) stays; only the [map] block is replaced.

Usage: python3 tools/art/layout_akt5_maps.py pass|grat [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/<map>.txt (once the layout is final: ADR-068).
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
NOTCH_X = 66  # the gap in the northern wall, five cells wide (64 to 68), three rows deep; the door to the high valley (G2) lies in its mouth
NOTCH_ROWS = (1, 3)
NORTH_DOOR = (NOTCH_X, 3)  # G1's blocker stood here and the fall of rock one row behind it; G2 put the door in their place (same ground)
NORTH_ARRIVAL = (NOTCH_X, 4)  # the arrival from the high valley, one cell south of the door
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
    "@": ".", "n": ",", "N": ",", "s": ",", "D": ",", "d": ",", "Z": "^",
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
    # ---- the end: the door to the high valley in the canyon's mouth (G2), the arrival one cell south of it
    put("D", *NORTH_DOOR)
    put("d", *NORTH_ARRIVAL)
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
    for glyph in "123456789DdnN@":
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
    cue_cells = [c for glyph in "123456789DdNn@s" for c in named.get(glyph, [])]
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
    while math.hypot(cur[0] - NORTH_DOOR[0], cur[1] - NORTH_DOOR[1]) >= 12:
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


# ============================================================================================ grat (G2)
# The high valley (96 x 56, class M). A basin between walls: a tarn in the middle, meadows and scree, a marmot's slope, three
# cairns that lead from the door in the south to the Anlage in the north-east (a hall with a chimney and a fence, in a pocket of
# the rock, its gate in the fence). The Grat lies over it, behind the blocker at the foot of the ramp in the north-west: a ledge
# along the northern wall, a cleft (the Spalte) above the Anlage with a detour round it, a plateau in the north-east.
GRAT_W, GRAT_H = 96, 56
GRAT_DOOR = (22, 54)  # the door back to the pass, in a notch of the southern wall (five cells wide: 20 to 24)
GRAT_ARRIVAL = (22, 48)  # six cells north of it: the valley opens before one
GRAT_START = (50, 46)  # a new run (--start=grat): far from every door; the benchmark walks right first, then down
GRAT_TOP = 20  # the first row of the valley floor under the northern wall (flat west of the ramp, so that its flanks stay rock)
GRAT_LAKE = (33.0, 32.0, 12.0, 8.0)  # the tarn: centre x, y and the radii
GRAT_RAMP_X = 16  # the ramp up to the Grat: five cells wide (14 to 18) through the wall's band, rows 8 to 19
GRAT_RAMP_BLOCKER = (GRAT_RAMP_X, 19)  # the blocker `ramp_wait`: the last ramp row, rock on both sides of it
GRAT_RAMP_HEAP = (GRAT_RAMP_X, 18)  # the scree heap in front of the steps (it goes with the blocker)
GRAT_RAMP_STEPS = (GRAT_RAMP_X, 14)
GRAT_POCKET = (69, 83, 31, 37)  # the yard of the Anlage, a pocket in the rock: x0, x1, y0, y1 (the hall is twelve cells wide, one and a half each side)
GRAT_FENCE_Y = 38  # the fence closes the pocket from rock to rock; the gate stands in the middle of it
GRAT_GATE = (76, 38)
GRAT_GATE_BLOCKER = (76, 39)  # three cells wide, covering the gate's row (offset 0, -1): one stops at the gate (until `grat.gate_open`, G3)
GRAT_HALL = (76, 34)
GRAT_HALL_DOOR = (76, 35)  # G3: the door into the hall `maschine` (`if grat.gate_open`, three cells wide and two rows deep, the hall's own door), one cell in front of the hall's wall
GRAT_YARD_ARRIVAL = (76, 37)  # G3: the arrival from the hall (marker `spawn_maschine`), two cells in front of that door and just inside the gate
GRAT_SMOKE = (78, 24)  # the foot of the column: the top of the chimney (ten rows above the hall, two cells east of its middle)
GRAT_SPALTE = (73, 75, 11, 16)  # the cleft: x0, x1, y0, y1 (three cells wide, six deep), opens on the ledge
GRAT_PLATEAU = (81, 91, 2, 10)  # x0, x1, y0, y1: free ground for G8's door
GRAT_ISLAND = (69, 76, 5, 7)  # the rock island on the ledge beside the cleft: the way forks round it (north branch, south branch)
GRAT_QUARTZ = (28, 23)  # the quartz in a fan of scree on the north bank of the tarn
GRAT_DEN = (52, 27)  # the marmot's den on its slope east of the tarn (the thimble lies in the dent one row below)
GRAT_FORECOURT = (76, 42, 11.0, 3.6)  # beaten earth in front of the gate: centre x, y, radii

# the walks (waypoints): from the door north-east to the forecourt, from the first bend to the ramp, and the Gratweg on the ledge
GRAT_PATH_MAIN = [(22, 53), (22, 50), (22, 47), (25, 45.5), (30, 44.5), (36, 44.2), (42, 44.8), (48, 44.2), (54, 43), (60, 42), (66, 41.4),
                  (72, 41.0), (76, 40.6)]
GRAT_PATH_RAMP = [(22, 47), (19, 43.5), (15.8, 40), (14, 35.5), (15.4, 31), (13.8, 26.5), (15.2, 22.5), (16, 19), (16, 15), (16, 11), (17, 9.6)]
GRAT_PATH_LEDGE = [(17, 9.6), (22, 8.6), (28, 7), (35, 6.2), (42, 7.4), (49, 6.2), (56, 5.8), (62, 6.8), (66, 8.2), (70, 9.0), (75, 9.2),
                   (79, 8.4), (83, 6.8), (88, 6.2)]
GRAT_PATH_NORTH = [(66, 8.2), (66.5, 4.6), (70, 3.4), (76, 3.4), (80, 5.0), (83, 6.8)]  # the detour round the island
GRAT_PATH_W = 2.9
GRAT_LEDGE_W = 2.5

GRAT_GROUND = {
    ".": ".", ",": ",", "m": "m", "p": "p", "~": "~", "w": "w", "h": "h", "^": "^",
    "L": ".", "l": "m", "O": ".", "o": "m", "R": ".", "r": "m", "S": "m", "g": ".", "u": ".",
    "D": ",", "d": ",", "@": ".", "1": ".", "2": ".", "3": ".", "q": ".", "7": ".", "H": ".", "Q": "m", "M": "m", "t": "m",
    "A": ",", "Z": "^", "f": ",", "G": ",", "X": ",", "Y": ",", "F": ",", "s": ",", "E": ",", "e": ",",
}
GRAT_BLOCKS = set("h^vOoAfGXY")  # a line of sight is stopped by solid ground and by what stands tall


def _gc(points):
    return _centerline(points)


_GPATHS = {"main": _gc(GRAT_PATH_MAIN), "ramp": _gc(GRAT_PATH_RAMP), "ledge": _gc(GRAT_PATH_LEDGE), "north": _gc(GRAT_PATH_NORTH)}
_GALL = [s for k in ("main", "ramp", "ledge", "north") for s in _GPATHS[k][::3]]


def grat_path_distance(x, y, which=None):
    """Distance of a cell from the nearest walk (all of them, or the one named)."""
    samples = _GALL if which is None else _GPATHS[which][::3]
    return min(math.hypot(x - sx, y - sy) for sx, sy, _ in samples)


def grat_path_samples():
    """The centre lines of all the walks of the high valley as one list of (x, y), about a quarter cell apart."""
    return [(x, y) for name in ("main", "ramp", "ledge", "north") for x, y, _ in _GPATHS[name]]


def grat_south(x):
    """The last row of the valley floor at column x."""
    return 50 + round(wobble(x, (1.2, 4.3, 0.5), (0.8, 2.1, 1.7)))


def grat_north(x):
    """The first row of the valley floor at column x (the northern wall's foot)."""
    if x <= 26:
        return GRAT_TOP
    return GRAT_TOP + round(wobble(x, (1.4, 5.1, 0.4), (0.9, 2.3, 1.2)))


def grat_west(y):
    return 9 + round(wobble(y, (1.6, 4.1, 0.8), (1.0, 2.2, 2.0)))


def grat_east(y):
    """The floor's east edge: a diagonal face of the rock above row 39, the whole width of the strip below it."""
    if y >= 39:
        return 91 + round(wobble(y, (1.0, 3.3, 0.2)))
    return 55 + round((y - GRAT_TOP) * 0.3) + round(wobble(y, (1.6, 3.7, 1.0), (1.1, 2.3, 0.4), (0.7, 1.3, 2.2)))


def grat_floor(x, y):
    if y < grat_north(x) or y > grat_south(x):
        return False
    return grat_west(y) <= x <= grat_east(y)


def grat_ledge(x):
    """Rows (top, bottom) of the Grat's ledge at column x."""
    top = 3 + round(wobble(x, (1.0, 5.7, 0.3), (0.7, 2.9, 1.1)))
    bot = 10 + round(wobble(x, (0.9, 4.9, 0.8), (0.6, 2.5, 0.4)))
    if 66 <= x <= 80:  # beside the cleft the ledge is broad: the island, a way on either side of it
        top, bot = 3, 10
    return top, bot


def grat_ledge_west(y):
    return 13 + round(wobble(y, (1.2, 2.7, 0.3), (0.8, 1.9, 1.4)))


def grat_scree(x, y, land_rock):
    """Gravel patches in the meadow near the rock (more of them the higher one stands)."""
    n = (math.sin(x / 5.3 + 1.3) * math.sin(y / 3.7 + 0.7) + 0.6 * math.sin((x + y) / 7.9)
         + 0.5 * math.sin((x - y) / 4.7 + 2.0) + 0.4 * math.sin(x / 2.3 + y / 3.1))
    if y < 12:  # on the ledge: more of it the farther east
        return n > max(0.35, 1.15 - (x - 13) * 0.012)
    return n > (0.55 if land_rock else 1.7)


def grat_land():
    g = Grid(GRAT_W, GRAT_H, "^")
    for y in range(GRAT_H):
        for x in range(GRAT_W):
            if grat_floor(x, y):
                g.set(x, y, ".")
    # the tarn, and shallow water along its south and west shores (one can walk into it)
    cx, cy, rx, ry = GRAT_LAKE
    g.ellipse(cx, cy, rx, ry, "~", only=".", wobble=0.12, seed=1.3)
    shore = []
    for y in range(GRAT_H):
        for x in range(GRAT_W):
            if g.get(x, y) == "." and (y >= 36 or x <= 22) and any(g.get(x + a, y + b) == "~" for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                shore.append((x, y))
    for x, y in shore:
        g.set(x, y, "w")
    # the notch of the door in the southern wall (a funnel down to the door's row)
    for y in range(GRAT_DOOR[1] - 3, GRAT_DOOR[1] + 1):
        half = 3 if y == GRAT_DOOR[1] - 3 else 2
        for x in range(GRAT_DOOR[0] - half, GRAT_DOOR[0] + half + 1):
            g.set(x, y, ",")
    # the Anlage's pocket in the rock (yard of beaten earth) and the row of the fence that closes it
    x0, x1, y0, y1 = GRAT_POCKET
    for y in range(y0, y1 + 2):
        for x in range(x0, x1 + 1):
            g.set(x, y, ",")
    # the Grat: the ledge along the northern wall, the plateau at its end, the cleft and the ramp up to it
    for y in range(2, 12):
        for x in range(13, 93):
            top, bot = grat_ledge(x)
            if top <= y <= bot and grat_ledge_west(y) <= x <= 91 + round(wobble(y, (0.8, 2.3, 0.6))):
                g.set(x, y, "m" if grat_scree(x, y, False) else ".")
    px0, px1, py0, py1 = GRAT_PLATEAU
    for y in range(py0, py1 + 1):
        for x in range(px0, px1 + 1):
            g.set(x, y, "m" if ((x * 73856093) ^ (y * 19349663)) % 9 == 0 else ".")
    ix0, ix1, iy0, iy1 = GRAT_ISLAND
    for y in range(iy0, iy1 + 1):
        for x in range(ix0, ix1 + 1):
            g.set(x, y, "^")
    sx0, sx1, sy0, sy1 = GRAT_SPALTE
    for y in range(sy0, sy1 + 1):
        for x in range(sx0, sx1 + 1):
            g.set(x, y, "m" if y in (sy0 + 1, sy1 - 1) else ",")
    for y in range(GRAT_RAMP_BLOCKER[1] + 0, 7, -1):
        for x in range(GRAT_RAMP_X - 2, GRAT_RAMP_X + 3):
            g.set(x, y, ",")
    # scree in the meadow under the walls, and along the slope of the rock in the east
    for y in range(GRAT_TOP, GRAT_H):
        for x in range(GRAT_W):
            if g.get(x, y) == ".":
                near = any(g.get(x + a, y + b) == "^" for a in range(-3, 4) for b in range(-3, 4))
                if grat_scree(x, y, near):
                    g.set(x, y, "m")
    # the fan of scree round the quartz and the marmot's slope: bare earth
    for (fx, fy), (frx, fry) in ((GRAT_QUARTZ, (4.5, 2.2)), (GRAT_DEN, (5.0, 3.4))):
        for y in range(GRAT_H):
            for x in range(GRAT_W):
                if g.get(x, y) == "." and ((x - fx) / frx) ** 2 + ((y - fy) / fry) ** 2 <= 1.0:
                    g.set(x, y, "m")
    # thickets of mountain pine (solid scrub) on the slopes, away from the walks and the tarn
    for cx, cy, rx, ry in ((11, 25, 4.0, 5.0), (10, 38, 3.5, 4.5), (11, 51, 4.0, 1.6), (36, 51, 6.0, 2.0), (58, 49.5, 5.0, 2.6),
                           (70, 49.5, 6.0, 2.4), (85, 47.5, 5.5, 3.5), (89, 41.5, 3.0, 3.0), (47, 21.5, 4.0, 1.6), (59, 33, 2.4, 3.0)):
        for y in range(GRAT_H):
            for x in range(GRAT_W):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0 and g.get(x, y) in ".m" and grat_path_distance(x, y) > 5.5 \
                        and math.hypot((x - GRAT_LAKE[0]) / GRAT_LAKE[2], (y - GRAT_LAKE[1]) / GRAT_LAKE[3]) > 1.25:
                    g.set(x, y, "h")
    # the forecourt of beaten earth in front of the gate, and the walks (over grass, scree and thicket's edge, never over water or rock)
    fx, fy, frx, fry = GRAT_FORECOURT
    for y in range(GRAT_FENCE_Y + 1, GRAT_H):
        for x in range(GRAT_W):
            if ((x - fx) / frx) ** 2 + ((y - fy) / fry) ** 2 <= 1.0 and g.get(x, y) in ".mh":
                g.set(x, y, ",")
    for name in ("main", "ramp"):
        for sx, sy, _ in _GPATHS[name]:
            r = GRAT_PATH_W / 2
            for y in range(int(math.floor(sy - r)), int(math.ceil(sy + r)) + 1):
                for x in range(int(math.floor(sx - r)), int(math.ceil(sx + r)) + 1):
                    if math.hypot(x - sx, y - sy) <= r and g.get(x, y) in ".mph" and (name == "main" or y >= GRAT_TOP - 1 or g.get(x, y) != "h"):
                        g.set(x, y, ",")
    for name in ("ledge", "north"):
        for sx, sy, _ in _GPATHS[name]:
            r = GRAT_LEDGE_W / 2
            for y in range(int(math.floor(sy - r)), int(math.ceil(sy + r)) + 1):
                for x in range(int(math.floor(sx - r)), int(math.ceil(sx + r)) + 1):
                    if math.hypot(x - sx, y - sy) <= r and g.get(x, y) in ".m":
                        g.set(x, y, ",")
    # a few puddles in the hollows of the walks
    for frac in (0.09, 0.21, 0.36, 0.5, 0.78):
        sx, sy, _ = _GPATHS["main"][int(frac * len(_GPATHS["main"]))]
        for dx in (0, 1):
            x, y = int(round(sx)) + dx, int(round(sy))
            if g.get(x, y) == ",":
                g.set(x, y, "p")
    return g


def grat_sight(g, a, b):
    """Is there a clear line between two cells (nothing solid or tall on it)?"""
    (x0, y0), (x1, y1) = a, b
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(1, n):
        t = i / n
        x, y = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t))
        if (x, y) in (a, b):
            continue
        if g.get(x, y) in GRAT_BLOCKS:
            return False
    return True


def grat_build():
    """The grid with its placements: the named things first (door, cairns, finds, the Anlage, the blockers), then rocks, shrubs and scree."""
    g = grat_land()
    rng = random.Random(5802)
    named = {}
    shortfall = {}

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        assert g.get(x, y) == GRAT_GROUND[glyph], (glyph, x, y, g.get(x, y), GRAT_GROUND[glyph])
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    def pick(target, ground, lo, hi, apart=()):
        """The cell nearest to `target` on `ground` whose distance to the walks is between lo and hi and that keeps its neighbours free."""
        best = None
        for y in range(GRAT_H):
            for x in range(GRAT_W):
                if g.get(x, y) != ground or not (lo <= grat_path_distance(x, y) <= hi):
                    continue
                if any(g.get(x + a, y + b) not in ".m" for a in (-1, 0, 1) for b in (-1, 0, 1)):
                    continue
                if any(math.hypot(x - ax, y - ay) < 3 for ax, ay in apart):
                    continue
                d = math.hypot(x - target[0], y - target[1])
                if best is None or d < best[0]:
                    best = (d, x, y)
        assert best is not None, target
        return best[1], best[2]

    # ---- the door back to the pass and the arrival, the start
    put("D", *GRAT_DOOR)
    put("d", *GRAT_ARRIVAL)
    put("@", *GRAT_START)
    # ---- the Anlage: the hall at the back of its pocket, the chimney's smoke, the fence from rock to rock with the gate and its blocker
    put("A", *GRAT_HALL)
    put("Z", *GRAT_SMOKE)
    x0, x1, _, _ = GRAT_POCKET
    for x in range(x0, x1 + 1):
        if abs(x - GRAT_GATE[0]) > 1:
            put("f", x, GRAT_FENCE_Y)
    put("G", *GRAT_GATE)
    put("X", *GRAT_GATE_BLOCKER)
    # ---- G3: the door into the hall (it exists once the gate is open) and the arrival from it, both on beaten earth in the yard (the ground does not change)
    put("E", *GRAT_HALL_DOOR)
    put("e", *GRAT_YARD_ARRIVAL)
    # ---- the Grat's ramp: the steps, the scree heap and the blocker at its foot
    put("s", *GRAT_RAMP_STEPS)
    put("F", *GRAT_RAMP_HEAP)
    put("Y", *GRAT_RAMP_BLOCKER)
    # ---- the three cairns of the valley, each in sight of the one before (the first in sight of the arrival), the stone at the foot of the first
    c1 = pick((29, 47), ".", 2.0, 3.4)
    put("1", *c1)
    put("q", c1[0] + 1, c1[1] + 1)
    c2 = pick((42, 43), ".", 2.0, 3.6, apart=[c1])
    put("2", *c2)
    c3 = pick((55, 40), ".", 2.0, 3.6, apart=[c2])
    put("3", *c3)
    build_cairns = [c1, c2, c3]
    # ---- the sign at the entrance, the hand on the stone at the shore, the quartz in the scree, the marmot's den with the thimble
    put("7", *pick((15, 47), ".", 4.0, 7.0))
    sx = 36
    shore_y = max(y for y in range(GRAT_H) if g.get(sx, y) in "~w")
    put("H", sx, shore_y + 1)
    put("Q", *GRAT_QUARTZ)
    mx, my = GRAT_DEN
    put("M", mx, my)
    put("t", mx, my + 1)
    # ---- rocks, shrubs and scree: none on the walks, near a cue, on the plateau, in front of the cleft and the ramp's foot, in the yard
    cues = [c for glyph in "123q7HQMtDdXY" for c in named.get(glyph, [])]
    px0, px1, py0, py1 = GRAT_PLATEAU
    sx0, sx1, sy0, sy1 = GRAT_SPALTE
    shrubs = []

    def allowed(x, y, road, brook=0.0):
        if grat_path_distance(x, y) < road or any(math.hypot(x - cx, y - cy) < 2.8 for cx, cy in cues):
            return False
        if px0 - 2 <= x <= px1 + 2 and py0 - 1 <= y <= py1 + 1:
            return False
        if sx0 - 2 <= x <= sx1 + 2 and sy0 - 2 <= y <= sy1 + 1:
            return False
        if abs(x - GRAT_RAMP_X) <= 4 and GRAT_TOP - 4 <= y <= GRAT_TOP + 2:
            return False
        px_, py_, pw, ph = GRAT_POCKET[0], GRAT_POCKET[2], GRAT_POCKET[1] - GRAT_POCKET[0], GRAT_FENCE_Y - GRAT_POCKET[2]
        return not (px_ - 2 <= x <= px_ + pw + 2 and py_ - 1 <= y <= py_ + ph + 3)

    def scatter(glyphs, count, region, road=2.4, test=lambda x, y: True, apart=0, clearance=0):
        """`glyphs` is one glyph for grass, or a pair (on grass, on gravel); each cell takes the one that fits its ground."""
        on_grass, on_gravel = (glyphs, None) if len(glyphs) == 1 else (glyphs[0], glyphs[1])
        placed = tries = 0
        x0, x1, y0, y1 = region
        while placed < count and tries < 9000:
            tries += 1
            x, y = rng.randint(x0, x1), rng.randint(y0, y1)
            here = g.get(x, y)
            glyph = on_grass if here == "." else (on_gravel if here == "m" else None)
            if glyph is None or not allowed(x, y, road) or not test(x, y):
                continue
            if clearance and any(g.get(x + dx, y + dy) not in ".m,pw" for dy in range(-clearance, clearance + 1) for dx in range(-clearance, clearance + 1)):
                continue
            if apart and any(math.hypot(x - tx, y - ty) < apart for tx, ty in shrubs):
                continue
            g.set(x, y, glyph)
            if glyph in "Ll":
                shrubs.append((x, y))
            named.setdefault(glyph, []).append((x, y))
            placed += 1
        if placed < count:
            shortfall[glyphs] = (placed, count)

    def away_from_water(x, y):
        return all(g.get(x + dx, y + dy) not in "~w" for dx in range(-1, 2) for dy in range(-1, 2))

    scatter("Oo", 12, (10, 90, 21, 50), road=3.2, test=away_from_water, clearance=1)
    scatter("Oo", 5, (14, 90, 3, 10), road=3.0, clearance=1)
    scatter("Rr", 14, (10, 90, 21, 50), road=2.4, test=away_from_water)
    scatter("Rr", 8, (14, 90, 3, 10), road=2.2)
    scatter((None, "S"), 30, (10, 90, 3, 50), road=1.6)
    scatter("Ll", 30, (10, 90, 21, 50), road=2.8, test=away_from_water, apart=3.2, clearance=1)
    scatter("Ll", 6, (14, 80, 3, 10), road=2.8, apart=3.2, clearance=1)
    scatter("g", 14, (9, 90, 21, 50), road=2.4,
            test=lambda x, y: any(g.get(x + dx, y + dy) in "hw~" for dx in range(-3, 4) for dy in range(-3, 4)))
    scatter("u", 6, (9, 90, 21, 50), road=3.0, test=lambda x, y: any(g.get(x + dx, y + dy) == "h" for dx in range(-2, 3) for dy in range(-2, 3)))
    # ---- the cairns keep each other in sight, and the arrival sees the first
    chain = [GRAT_ARRIVAL] + build_cairns
    for a, b in zip(chain, chain[1:]):
        assert grat_sight(g, a, b), ("no sight", a, b)
    grat_build.cairns = build_cairns
    grat_build.shortfall = shortfall
    return g, named


grat_build.shortfall = {}
grat_build.cairns = []


BUILDERS = {"pass": build, "grat": grat_build}


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
        sys.exit("usage: layout_akt5_maps.py pass|grat [--write]")
    if "--write" in sys.argv:
        write(sys.argv[1])
    else:
        print(text(sys.argv[1]))
