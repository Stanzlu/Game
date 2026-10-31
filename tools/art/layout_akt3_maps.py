#!/usr/bin/env python3
"""Layout helper for the Act III maps (docs/akt3/REGIONSBRIEFE.md).

Draws the [map] block of content/maps/waldweg.txt (W2): the first forest of the real world. The brook of the
Bachlauf comes in from the north and goes on to the south; a worn path follows its west bank through a tall
forest of beech and spruce: past the way markers of the Antreiber, the first Rastplatz, the Hang (a sunken
lane with steps cut into it), the second Rastplatz, a spur to the hermit's hut in the west (its door leads
to the interior, W3) and on to the last marker with its blank board and the way south (a door to the
Flutlichtung since W4: a door on the path and an arrival four rows before it).
Hand-written head (meta, legend) stays; only the [map] block is replaced.

Flutlichtung (W4): the clearing the brook runs past, 88 x 54 cells (class M). A corridor of three cells leads in from the
north (the door to the Waldweg), the brook runs along its east side and widens the ground into a clearing of silt
(dry silt, wet silt along the water, puddles); beeches with a line of silt stand at its rim. From north to south: the
door, the arrival, the trail of one runner in the dry silt, the bleached trunk (the mark) with the Antreiber, the camp
(ring, kettle, blanket), then, along the brook, the driftwood and a ford of flat stones; a nest lies in the grass at the west
rim and a forked branch stands on the bank. The path leaves through a gap in the south edge (a blocker, which is
gone once the way is open since W5, and behind it a door to the Nachtwald).

Nachtwald (W5): a night in the wood, 46 x 36 cells (class S). A path comes in from the north (the door to the
Flutlichtung), runs south and then west for the length of a screen to a glade, in whose middle a small lantern stands
on the ground (a flat ring of light round it, a place to sit on its east side), and goes on to the south-west to a
door that leads home. Glow trees stand along the way, a rotten log in the glade's rim.

Usage: python3 tools/art/layout_akt3_maps.py waldweg|flutlichtung|nachtwald [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/<map>.txt (once the layout is final; the Waldweg needs none
for the door, because only cells of the path change their letter).
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from layout_look_maps import Grid, wobble  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

W, H = 100, 62
# The brook goes on from the Bachlauf's exit (53, 65) and leaves through the southern forest.
STREAM = [(53, 0), (53, 10), (57, 19), (60, 28), (57, 37), (52, 46), (54, 54), (58, 61)]
WIDTHS = [2.4, 2.4, 2.6, 2.8, 2.6, 2.4, 2.4, 2.4]
NORTH_X = 45  # the gap in the northern forest, three cells wide (44 to 46)
DOOR = (NORTH_X, 1)
ARRIVAL = (NORTH_X, 6)
START = (NORTH_X, 7)
SOUTH_X = 50  # the way on to the south, three cells wide (49 to 51)
SOUTH_DOOR = (SOUTH_X, 60)  # W4: the door to the Flutlichtung, in the gap of the southern forest
SOUTH_ARRIVAL = (SOUTH_X, 56)  # and the arrival from it, four rows before the door (beyond the sixth board)
HANG_Y = (27, 35)  # the sunken lane: markers at its top and its foot
REST_Y = (19, 41)  # the two Rastplätze: one before the Hang, one after it
POSTS = {"1": 9, "2": 15, "3": 24, "4": 38, "5": 49}  # the way markers of the Antreiber, by row
LAST_POST = (SOUTH_X - 2, 54)  # the sixth board, blank, where he stands
HUT = (27, 44)  # the hut in its glade, west of the path


def _centerline(stream, widths):
    """A brook's centre line, sampled the way Grid.path does: [(x, y, width)]."""
    out = []
    for i in range(len(stream) - 1):
        p0 = stream[max(i - 1, 0)]
        p1, p2 = stream[i], stream[i + 1]
        p3 = stream[min(i + 2, len(stream) - 1)]
        for s in range(40):
            t = s / 40
            t2, t3 = t * t, t * t * t
            x, y = (0.5 * (2 * p1[k] + (-p0[k] + p2[k]) * t + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2
                           + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3) for k in (0, 1))
            out.append((x, y, widths[i] + (widths[i + 1] - widths[i]) * t))
    out.append((stream[-1][0], stream[-1][1], widths[-1]))
    return out


def centerline():
    """The Waldweg's brook centre line: [(x, y, width)]."""
    return _centerline(STREAM, WIDTHS)


def stream_x(y):
    """Centre column of the Waldweg's brook at row y (the sample nearest to it)."""
    return min(centerline(), key=lambda s: abs(s[1] - y))[0]


def bank(y, side, gap):
    """A point `gap` cells from the brook's centre line on the west (-1) or east (+1) bank."""
    return (round(stream_x(y) + side * gap, 1), y)


def path_x(y):
    """Column of the worn path at row y (west bank, a few cells from the water)."""
    return round(stream_x(y) - 5.0)


def forest():
    g = Grid(W, H)
    # the forest ring: thicker than the Bachlauf's (the way is a corridor through tall trees)
    for x in range(W):
        north = 5 + round(0.8 + wobble(x, (1.0, 3.3, 0.0), (0.7, 1.9, 1.0), (0.6, 7.1, 2.0)))
        south = 5 + round(0.4 + wobble(x, (0.8, 2.9, 0.5), (0.5, 5.3, 1.7)))
        for y in range(0, max(north, 1)):
            g.set(x, y, "h")
        for y in range(H - max(south, 2), H):
            g.set(x, y, "h")
    for y in range(H):
        west = 6 + round(0.4 + wobble(y, (1.1, 2.6, 0.3), (0.8, 4.7, 2.2), (0.4, 1.3, 0.9)))
        east = 6 + round(0.3 + wobble(y, (1.0, 3.1, 1.1), (0.7, 5.9, 0.2)))
        for x in range(0, max(west, 2)):
            g.set(x, y, "h")
        for x in range(W - max(east, 2), W):
            g.set(x, y, "h")
    # thickets inside: the land is a corridor along the water with glades off it
    for i, (cx, cy, rx, ry) in enumerate((
            (30, 14, 8, 6), (22, 28, 9, 7), (34, 36, 5, 4), (36, 52, 9, 4), (14, 12, 7, 6),
            (72, 10, 12, 7), (78, 26, 11, 8), (70, 42, 13, 7), (88, 50, 8, 6), (66, 54, 7, 4))):
        g.ellipse(cx, cy, rx, ry, "h", only=".", wobble=0.5, seed=i + 1)
    # the brook
    g.path(STREAM, 2.5, "~", only=".h", widths=WIDTHS)
    # the gap in the northern forest: the way back to the Bachlauf
    for y in range(0, 7):
        for x in range(NORTH_X - 1, NORTH_X + 2):
            g.set(x, y, ",")
    # the south: three cells wide through the southern forest
    for y in range(H - 8, H):
        for x in range(SOUTH_X - 1, SOUTH_X + 2):
            g.set(x, y, ",", only=".h")
    # wet places and a few glades
    g.ellipse(41.0, 22.0, 2.4, 1.3, "m", only=".", wobble=0.6, seed=2)
    g.ellipse(46.5, 43.0, 2.0, 1.0, "p", only=".", wobble=0.5, seed=3)
    g.ellipse(HUT[0], HUT[1] + 1, 7.0, 6.0, ".", only="h", wobble=0.4, seed=5)  # the hut's glade
    g.ellipse(40.0, 31.0, 4.5, 3.0, ".", only="h", wobble=0.5, seed=6)  # room beside the Hang
    # the worn path along the west bank
    ys = (8, 14, 21, 28, 35, 41, 47, 52)
    pts = [(NORTH_X, 3), (NORTH_X, 7)] + [(path_x(y), y) for y in ys] + [(SOUTH_X, 56), (SOUTH_X, 59)]
    g.path(pts, 2.0, ",", only=".mph", widths=[1.9, 1.9] + [1.9, 1.8, 1.9, 1.8, 1.9, 1.8, 1.9, 1.8] + [1.9, 1.9])
    # the spur to the hut: narrow, from the path to the glade
    g.path([(path_x(44), 44), (path_x(44) - 8, 44.5), (HUT[0] + 4, 46), (HUT[0], 46.5)], 1.6, ",", only=".mph")
    # the Hang: a sunken lane. Two short earth faces beside the path, so that the path reads as cut into the slope
    top, bottom = HANG_Y
    for y in range(top + 1, bottom):
        px = path_x(y)
        g.set(px - 2, y, "^", only=".h")
        g.set(px - 3, y, "^", only=".h")
    for y in range(top + 3, bottom - 2):
        g.set(path_x(y) + 2, y, "^", only=".h")
    return g


def build():
    """The grid with the placements: the named spots first, then the trees keep their distance."""
    g = forest()
    rng = random.Random(53)

    def free(x, y, clearance):
        for dy in range(-clearance, clearance + 1):
            for dx in range(-clearance, clearance + 1):
                if g.get(x + dx, y + dy) not in (".",):
                    return False
        return True

    # a tall crown hides what lies behind it: no tree stands within two columns and eight rows south of a
    # spot with a cue (the sprites are drawn upward from the trunk's foot)
    reserved = []

    def hidden(x, y):
        return any(x0 <= x <= x1 and y0 <= y <= y1 for x0, x1, y0, y1 in reserved)

    def scatter(glyph, count, clearance, margin=5, region=None, tall=False):
        placed = 0
        tries = 0
        while placed < count and tries < 6000:
            tries += 1
            x0, x1, y0, y1 = region or (margin, W - margin, margin, H - margin)
            x, y = rng.randint(x0, x1 - 1), rng.randint(y0, y1 - 1)
            if tall and hidden(x, y):
                continue
            if free(x, y, clearance):
                g.set(x, y, glyph)
                placed += 1
        if placed < count:
            shortfall[glyph] = (placed, count)

    named = {}
    shortfall = {}

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        assert g.get(x, y) is not None, (glyph, x, y)
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    # the way markers: a post beside the path, east of it (toward the water), one cell clear of the track
    for glyph, y in POSTS.items():
        put(glyph, path_x(y) + 2, y)
    put("6", *LAST_POST)
    # the Antreiber, standing at the blank board (the map shows him sitting once he has been asked to sit)
    put("A", LAST_POST[0] + 2, LAST_POST[1] + 1)
    put("E", LAST_POST[0] + 3, LAST_POST[1] + 1)
    # the two places to rest: a fire ring with a kettle, a trunk beside it
    for glyph, y in zip("Qq", REST_Y):
        put(glyph, path_x(y) + 2, y)
        put("L", path_x(y) + 2, y + 2)
    # the Hang: the markers for the slow stretch, and the steps cut into it (a trace of the world)
    put("a", path_x(HANG_Y[0]), HANG_Y[0])
    put("z", path_x(HANG_Y[1]), HANG_Y[1])
    put("U", path_x(31) - 1, 31)
    # the hut: footprint in the glade, its door (W3: into the interior) and the marker before it
    put("H", *HUT)
    put("D", HUT[0], HUT[1] + 1)
    put("S", HUT[0] + 2, HUT[1] + 3)
    # a cone under a spruce and the mossy stones where the path bends
    put("K", path_x(18) - 2, 18)
    put("r", path_x(33) + 3, 33)
    # the door to the Bachlauf, the arrival and the start
    put("N", DOOR[0], DOOR[1])
    put("n", ARRIVAL[0], ARRIVAL[1])
    put("@", START[0], START[1])
    # the spruce over the cone: a trunk just northwest of it, the cone in front
    put("P", named["K"][0][0] - 2, named["K"][0][1] - 1)
    for glyph in "123456KQqU":
        for x, y in named[glyph]:
            reserved.append((x - 2, x + 2, y + 1, y + 8))
    # the forest: beech and spruce keep a few cells from the path, stones and ferns near it
    scatter("P", 40, 1, tall=True)
    scatter("T", 48, 2, tall=True)
    scatter("R", 14, 1)
    scatter("F", 40, 1)
    scatter("g", 18, 1)
    # W3, after the scatter so that the forest stays as it was: what lies before the hut's door (the cup of tea on
    # its stone, branches across the spur, a pebble with a hole, a washing line with nothing on it)
    for glyph, (x, y) in (
        ("C", (HUT[0] + 1, HUT[1] + 1)),
        ("Z", (HUT[0] + 4, HUT[1] + 2)),
        ("Y", (HUT[0] + 3, HUT[1])),
        ("X", (HUT[0] + 6, HUT[1])),
    ):
        assert g.get(x, y) in (".", ","), (glyph, x, y, g.get(x, y))
        put(glyph, x, y)
    # W4, the same way: the way on to the south is a door (it was a blocker until W4) and the arrival from it. Both
    # lie on path cells, so that the ground, the trees and the baked shadows stay as they were
    for glyph, (x, y) in (("W", SOUTH_DOOR), ("w", SOUTH_ARRIVAL)):
        assert g.get(x, y) == ",", (glyph, x, y, g.get(x, y))
        put(glyph, x, y)
    g.add_rails()
    build.shortfall = shortfall
    return g, named


# --- Flutlichtung (W4) -------------------------------------------------------------------------------------------
FLUT_W, FLUT_H = 88, 54
# the brook comes in beside the corridor, runs along the clearing's east edge and leaves in the south-east
FLUT_STREAM = [(58, 0), (58, 9), (62, 17), (66, 25), (66, 33), (62, 40), (60, 46), (64, 53)]
FLUT_WIDTHS = [2.4, 2.4, 2.6, 2.8, 2.8, 2.6, 2.4, 2.4]
FLUT_NORTH_X = 50  # the corridor from the Waldweg, three cells wide (49 to 51): the Waldweg's SOUTH_X
FLUT_DOOR = (FLUT_NORTH_X, 1)
FLUT_ARRIVAL = (FLUT_NORTH_X, 6)
FLUT_START = (FLUT_NORTH_X, 7)
FLUT_TRAIL = (FLUT_NORTH_X, 15)  # the foot of the runner's trail: the prints run seven rows north from it
FLUT_MARK = (44, 26)  # the bleached trunk without a crown; he stands at it and measures
FLUT_ANTREIBER = (45, 27)
FLUT_SEAT = (45, 28)  # where he sits once he has been offered tea
FLUT_CAMP = (40, 33)  # the ring (it reaches one cell east of its cell), the kettle on its side
FLUT_BLANKET = (43, 32)  # the stiff blanket on its post, east of the ring (its sprite covers cells 42 to 44)
FLUT_NEST = (26, 27)  # in the grass at the west rim, above the silt
FLUT_FORK_Y = 30  # the forked branch on the west bank
FLUT_DRIFT_Y = 37  # the driftwood on the bank
FLUT_FORD_Y = 42  # the flat stones across the brook (three cells of water, the stones' sprite is four cells wide)
FLUT_SOUTH_X = 34  # the way on to the south (W5), three cells wide (33 to 35)
FLUT_BLOCKER = (FLUT_SOUTH_X, 50)
# W5: behind the blocker the path ends in a door to the Nachtwald (the blocker is gone once the way is open), and the
# arrival from there lies four rows before it, north of the blocker. Both stand on cells of the path (',').
FLUT_NIGHT_DOOR = (FLUT_SOUTH_X, FLUT_H - 2)
FLUT_NIGHT_ARRIVAL = (FLUT_SOUTH_X, FLUT_H - 6)
# spots with a cue: no crown may hide them (the same rule as in the Waldweg, a column wider for the beeches)
FLUT_CUES = "SMAECokdi"
# the big sprites and the cells around their own cell that they cover: (columns left, columns right, rows up);
# the trunk 40 x 112 px, the blanket 48 x 64, the ring 40 x 36, a beech 96 x 128, a spruce 56 x 120 (cells of 16 px)
FLUT_BIG = {"M": (1, 1, 7), "D": (1, 1, 4), "C": (1, 1, 2), "U": (3, 3, 8), "P": (2, 2, 8)}


def flut_stream_x(y):
    """Centre column of the Flutlichtung's brook at row y."""
    return min(_centerline(FLUT_STREAM, FLUT_WIDTHS), key=lambda s: abs(s[1] - y))[0]


def flut_bank(y):
    """The last cell of the west bank at row y (one cell from the three cells of water)."""
    return int(round(flut_stream_x(y))) - 2


def flut_forest():
    g = Grid(FLUT_W, FLUT_H, fill="h")
    # the clearing and its bays, then the ground the water covered: dry silt, wet silt along the brook, puddles
    g.ellipse(44, 28, 22, 14.5, ".", only="h", wobble=0.16, seed=11)
    g.ellipse(33, 40, 10, 6.5, ".", only="h", wobble=0.3, seed=12)  # the bay in the south-west, toward the way on
    # the west bank of the brook, a few cells wide, from the clearing's north edge to its south end
    carve = [(x - 2.5, y) for x, y in FLUT_STREAM[2:6]]
    g.path(carve, 2.0, ".", only="h", widths=[w + 4.5 for w in FLUT_WIDTHS[2:6]])
    g.ellipse(29, 17, 5, 3.5, ".", only="h", wobble=0.4, seed=14)  # high ground in the north-west
    g.ellipse(46, 29, 16, 10, ",", only=".", wobble=0.3, seed=21)
    g.ellipse(58, 30, 8, 12, ",", only=".", wobble=0.32, seed=22)
    g.ellipse(41, 38, 5, 3.5, ",", only=".", wobble=0.3, seed=23)
    # rises the water did not cover: islands of grass in the silt
    for cx, cy, rx, ry, seed in ((38, 25, 2.2, 1.5, 24), (54, 29, 2.6, 1.7, 25), (45, 35, 2.0, 1.4, 26)):
        g.ellipse(cx, cy, rx, ry, ".", only=",", wobble=0.4, seed=seed)
    # the corridor in from the Waldweg
    for y in range(0, 20):
        for x in range(FLUT_NORTH_X - 1, FLUT_NORTH_X + 2):
            g.set(x, y, ",", only="h.")
    # wet silt along the brook, a few wet places inland, puddles in the hollows
    g.path(FLUT_STREAM, 5.0, "m", only=".,", widths=[w + 3.4 for w in FLUT_WIDTHS])
    for cx, cy, rx, ry, seed in ((33, 30, 3.0, 2.0, 31), (51, 37, 3.5, 2.0, 32), (34, 24, 2.2, 1.5, 33)):
        g.ellipse(cx, cy, rx, ry, "m", only=",", wobble=0.5, seed=seed)
    for cx, cy, rx, ry, seed in ((37, 25, 1.7, 1.0, 41), (53, 34, 1.9, 1.1, 42), (44, 41, 1.6, 1.0, 43),
                                 (56, 24, 1.4, 1.0, 44), (31, 33, 1.5, 1.0, 45), (57, 41, 1.4, 0.9, 46)):
        g.ellipse(cx, cy, rx, ry, "p", only=",m", wobble=0.4, seed=seed)
    # the brook
    g.path(FLUT_STREAM, 2.5, "~", only=".h,mp", widths=FLUT_WIDTHS)
    # the ford: three cells of water walked on stones, a bank on each side and a small meadow on the east bank
    c = int(round(flut_stream_x(FLUT_FORD_Y)))
    for x in range(c - 4, c + 5):
        g.set(x, FLUT_FORD_Y, ".", only="h~")
    for row in (FLUT_FORD_Y - 1, FLUT_FORD_Y + 1):  # three cells of water on both sides of the ford
        for x in range(c - 1, c + 2):
            g.set(x, row, "~")
    for x in range(c - 1, c + 2):
        g.set(x, FLUT_FORD_Y, "y")
    g.set(c - 2, FLUT_FORD_Y, "m")
    g.ellipse(c + 6, FLUT_FORD_Y - 1, 6, 5, ".", only="h", wobble=0.3, seed=51)
    for x in range(c + 2, c + 5):
        g.set(x, FLUT_FORD_Y, ".", only="h~")
    # the way on to the south: a path out of the bay and a gap three cells wide through the forest of the south edge
    g.path([(40, 38), (37, 43), (FLUT_SOUTH_X, 46), (FLUT_SOUTH_X, 53)], 2.4, ",", only="h.mp")
    for y in range(46, FLUT_H):
        for x in range(FLUT_SOUTH_X - 1, FLUT_SOUTH_X + 2):
            g.set(x, y, ",", only=".h")
    return g


def build_flut():
    """The Flutlichtung: the named spots first, then the trees keep their distance from them and from the cues."""
    g = flut_forest()
    rng = random.Random(88)
    named = {}
    shortfall = {}
    reserved = []
    placed_trees = []

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        assert g.get(x, y) is not None, (glyph, x, y)
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    def hidden(x, y):
        return any(x0 <= x <= x1 and y0 <= y <= y1 for x0, x1, y0, y1 in reserved)

    def square(x, y, clearance):
        return [g.get(x + dx, y + dy) for dy in range(-clearance, clearance + 1)
                for dx in range(-clearance, clearance + 1)]

    def near(x, y, radius, glyphs):
        return any(g.get(x + dx, y + dy) in glyphs for dy in range(-radius, radius + 1)
                   for dx in range(-radius, radius + 1))

    def free(x, y, clearance):
        return g.get(x, y) == "." and all(c in (".", "h") for c in square(x, y, clearance))

    def scatter(glyph, count, clearance, test, apart=0, tall=False):
        placed = 0
        tries = 0
        while placed < count and tries < 6000:
            tries += 1
            x, y = rng.randint(4, FLUT_W - 5), rng.randint(4, FLUT_H - 5)
            if not free(x, y, clearance) or not test(x, y):
                continue
            if tall and hidden(x, y):
                continue
            if apart and any(abs(x - tx) < apart and abs(y - ty) < apart for tx, ty in placed_trees):
                continue
            g.set(x, y, glyph)
            if tall:
                placed_trees.append((x, y))
            placed += 1
        if placed < count:
            shortfall[glyph] = (placed, count)

    # the door, the arrival and the start
    put("N", *FLUT_DOOR)
    put("n", *FLUT_ARRIVAL)
    put("@", *FLUT_START)
    # what the flood left: the trail of one runner, the trunk, the Antreiber at it, the camp
    put("S", *FLUT_TRAIL)
    put("M", *FLUT_MARK)
    put("A", *FLUT_ANTREIBER)
    put("E", *FLUT_SEAT)
    put("C", *FLUT_CAMP)
    put("D", *FLUT_BLANKET)
    # the nest in the grass, the forked branch and the driftwood on the bank, the stones across the water
    put("o", *FLUT_NEST)
    put("k", flut_bank(FLUT_FORK_Y) - 1, FLUT_FORK_Y)
    put("d", flut_bank(FLUT_DRIFT_Y), FLUT_DRIFT_Y)
    put("i", flut_bank(FLUT_FORD_Y) + 2, FLUT_FORD_Y)
    # the way on to the south is closed (until W5)
    put("B", *FLUT_BLOCKER)
    for glyph in FLUT_CUES:
        for x, y in named[glyph]:
            reserved.append((x - 3, x + 3, y + 1, y + 8))
    # no crown over the corridor either (a beech reaches three cells to each side, eight rows up from its foot)
    reserved.append((FLUT_NORTH_X - 4, FLUT_NORTH_X + 4, 0, 28))
    # the beeches that carry the line of silt stand at the rim, where the silt ends; the high ground has spruce
    def rim(x, y):
        return near(x, y, 2, "h") and near(x, y, 6, ",mp")

    def high(x, y):
        return near(x, y, 2, "h") and not near(x, y, 3, ",mpy~")

    scatter("U", 18, 1, rim, apart=3, tall=True)
    scatter("P", 6, 1, high, apart=3, tall=True)
    scatter("R", 7, 1, lambda x, y: near(x, y, 3, "h"))
    scatter("F", 14, 1, lambda x, y: near(x, y, 3, "h"))
    scatter("g", 12, 1, lambda x, y: near(x, y, 4, "h"))
    # W5, after the scatter so that the forest and the baked shadows stay as they were: the door to the Nachtwald and
    # the arrival from it. Both lie on cells of the path, so that the ground (and the stamp) do not change
    for glyph, (x, y) in (("W", FLUT_NIGHT_DOOR), ("w", FLUT_NIGHT_ARRIVAL)):
        assert g.get(x, y) == ",", (glyph, x, y, g.get(x, y))
        put(glyph, x, y)
    build_flut.shortfall = shortfall
    return g, named


build_flut.shortfall = {}


# --- Nachtwald (W5) ----------------------------------------------------------------------------------------------
NACHT_W, NACHT_H = 44, 34
NACHT_NORTH_X = 37  # the gap in the northern forest, three cells wide (36 to 38): the way in from the Flutlichtung
NACHT_DOOR = (NACHT_NORTH_X, 1)
NACHT_ARRIVAL = (NACHT_NORTH_X, 6)
NACHT_START = (NACHT_NORTH_X, 7)
NACHT_LANTERN = (16, 21)  # on the ground in the middle of the glade
NACHT_POOL = (16, 20)  # the ring of light is drawn one cell lower than its cell (lift), round the lantern's foot
NACHT_FAR = (25, 20)  # the spot on the path where the little light is looked at, nine cells before the lantern
NACHT_GLOW_CUE = (33, 12)  # the glow tree to look at, beside the way down
NACHT_LOG = (10, 17)  # the rotten log in the glade's north-west rim
NACHT_HOME_X = 8  # the way on to the south-west, three cells wide (7 to 9)
NACHT_HOME_DOOR = (NACHT_HOME_X, NACHT_H - 2)
NACHT_HOME_CUE = (9, 28)  # on the path, the last stretch before the door, five rows from it
# the way: down from the door, then west for the length of a screen (so that the lantern shows from a good distance),
# through the glade's south side and on to the south-west
NACHT_PATH = [(37, 3), (37, 8), (37, 13), (34, 17), (29, 19.5), (24.5, 20.5), (21, 23), (15, 25.5), (11, 27.5), (8, 29.5),
              (8, 33)]
NACHT_PATH_WIDTHS = [2.0] * len(NACHT_PATH)
NACHT_CORRIDOR = [4.0, 5.0, 6.5, 8.0, 8.0, 8.0, 8.5, 8.5, 6.0, 3.5, 3.5]  # how wide the carved way is, along it
# spots with a cue: no crown may hide them (a beech reaches three cells to each side, eight rows up from its foot)
NACHT_CUES = "KCYLQ"
# the ground each named spot stands on (what the legend says): path or grass
NACHT_GROUND = {"N": ",", "n": ",", "@": ",", "H": ",", "K": ".", "C": ",", "L": ".", "l": ".", "Y": ".", "Q": ","}


def nacht_forest():
    g = Grid(NACHT_W, NACHT_H, fill="h")
    # the wood is one dense wall of trunks: the way, a glade and a few bays are carved out of it, a little wider than
    # the path, so that trees can stand at the edge of the way (the glow trees among them)
    g.path(NACHT_PATH[1:-1], 6.0, ".", only="h", widths=NACHT_CORRIDOR[1:-1])
    # the glade: round, the lantern in its middle
    g.ellipse(NACHT_LANTERN[0], NACHT_LANTERN[1] - 0.5, 7.5, 5.5, ".", only="h", wobble=0.2, seed=5)
    # bays off the way: a nook beside the way down (the glow tree to look at), the log's corner, one in the south
    g.ellipse(32.5, 11.5, 3.2, 2.6, ".", only="h", wobble=0.3, seed=7)
    g.ellipse(10.5, 17.0, 3.0, 2.4, ".", only="h", wobble=0.3, seed=8)
    g.ellipse(25.0, 26.5, 3.6, 2.4, ".", only="h", wobble=0.3, seed=9)
    # the gap in the northern forest: the way in from the Flutlichtung
    for y in range(0, 7):
        for x in range(NACHT_NORTH_X - 1, NACHT_NORTH_X + 2):
            g.set(x, y, ",")
    # the gap in the south-west: the way home
    for y in range(NACHT_H - 5, NACHT_H):
        for x in range(NACHT_HOME_X - 1, NACHT_HOME_X + 2):
            g.set(x, y, ",", only=".h")
    # the worn path
    g.path(NACHT_PATH, 2.0, ",", only=".h", widths=NACHT_PATH_WIDTHS)
    return g


def build_nacht():
    """The Nachtwald: the named spots first, then the trees keep their distance from them and from the cues."""
    g = nacht_forest()
    rng = random.Random(95)
    named = {}
    shortfall = {}
    reserved = []
    placed_trees = []

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        # the glyph stands for the ground it replaces (the legend's "ground"): the baked ground does not change
        assert g.get(x, y) == NACHT_GROUND[glyph], (glyph, x, y, g.get(x, y))
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    def hidden(x, y):
        return any(x0 <= x <= x1 and y0 <= y <= y1 for x0, x1, y0, y1 in reserved)

    def free(x, y, clearance):
        return g.get(x, y) == "." and all(
            g.get(x + dx, y + dy) in (".", "h") for dy in range(-clearance, clearance + 1)
            for dx in range(-clearance, clearance + 1))

    def scatter(glyphs, count, clearance, test=lambda x, y: True, apart=0, tall=False):
        """`count` placements of the glyphs in turn (a string of one glyph, or two that alternate)."""
        placed = 0
        tries = 0
        while placed < count and tries < 6000:
            tries += 1
            x, y = rng.randint(4, NACHT_W - 5), rng.randint(4, NACHT_H - 5)
            if not free(x, y, clearance) or not test(x, y):
                continue
            glyph = glyphs[placed % len(glyphs)]
            if tall and hidden(x, y):
                continue
            if apart and any(abs(x - tx) < apart and abs(y - ty) < apart for tx, ty in placed_trees):
                continue
            g.set(x, y, glyph)
            if tall:
                placed_trees.append((x, y))
            placed += 1
        if placed < count:
            shortfall[glyphs] = (placed, count)

    # the door, the arrival and the start in the north; the way home in the south-west
    put("N", *NACHT_DOOR)
    put("n", *NACHT_ARRIVAL)
    put("@", *NACHT_START)
    put("H", *NACHT_HOME_DOOR)
    # what there is to see: the glow tree beside the way down, the little light far off, the lantern in the glade (its
    # ring of light one cell above it), the log in the rim of the glade, the last stretch before the door
    put("K", *NACHT_GLOW_CUE)
    put("C", *NACHT_FAR)
    put("L", *NACHT_LANTERN)
    put("l", *NACHT_POOL)
    put("Y", *NACHT_LOG)
    put("Q", *NACHT_HOME_CUE)
    # a crown hides what lies behind it: no tree within three columns and eight rows south of a spot with a cue
    for glyph in NACHT_CUES:
        for x, y in named[glyph]:
            reserved.append((x - 3, x + 3, y + 1, y + 8))
    # and none over the way in
    reserved.append((NACHT_NORTH_X - 4, NACHT_NORTH_X + 4, 0, 14))
    lx, ly = NACHT_LANTERN
    # nor over the place where she sits (on the lantern's east side, a cell and a half from it): the crown of a beech
    # reaches three cells to each side and eight rows up, and the sitter's head must stay in the picture
    reserved.append((lx - 1, lx + 4, ly + 1, ly + 8))
    placed_trees.append(NACHT_GLOW_CUE)  # the glow tree to look at is one of the trees

    def in_glade(x, y):
        """Inside the lantern's room: nothing grows here, so that she can walk up to it and sit down beside it. The
        log's corner is kept clear too (the sprite is four cells wide)."""
        round_room = ((x - lx) / 6.3) ** 2 + ((y - ly + 0.5) / 4.4) ** 2 <= 1.0
        return round_room or (abs(x - NACHT_LOG[0]) <= 3 and abs(y - NACHT_LOG[1]) <= 2)

    def tree(glyph, x, y):
        """A named tree: only on grass, outside the crown reserve of the cues and clear of the others."""
        x, y = int(round(x)), int(round(y))
        if (free(x, y, 0) and not hidden(x, y) and not in_glade(x, y)
                and not any(abs(x - tx) < 2 and abs(y - ty) < 2 for tx, ty in placed_trees)):
            g.set(x, y, glyph)
            placed_trees.append((x, y))
            named.setdefault(glyph, []).append((x, y))
            return True
        return False

    # the glow trees are the guide: every few steps along the way, three to five cells off it, on alternating sides
    samples = _centerline(NACHT_PATH, NACHT_PATH_WIDTHS)
    walked, next_at, side = 0.0, 12.0, 1
    for (x0, y0, _), (x1, y1, _) in zip(samples, samples[1:]):
        walked += math.hypot(x1 - x0, y1 - y0)
        if walked < next_at:
            continue
        dx, dy = x1 - x0, y1 - y0
        norm = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / norm, dx / norm
        for turn in (side, -side):
            if any(tree("G", x1 + turn * nx * off, y1 + turn * ny * off) for off in (3.0, 3.5, 2.5, 4.0, 4.5)):
                break
        next_at += 5.0
        side = -side
    # and round the glade, on its rim, but never in the lantern's crown reserve
    for angle in (-100, -60, 160, 130, 40, -20):
        a = math.radians(angle)
        for grow in (1.0, 1.1, 0.9):
            if tree("G", lx + math.cos(a) * 6.9 * grow, ly - 0.5 + math.sin(a) * 4.9 * grow):
                break
    # the forest: spruce and beech keep a few cells from the cues, stones and ferns near the trees
    outside = lambda x, y: not in_glade(x, y)
    scatter("PT", 18, 0, outside, tall=True, apart=2)
    scatter("R", 8, 1, outside)
    scatter("F", 7, 1, outside)
    scatter("g", 4, 0, outside)
    build_nacht.shortfall = shortfall
    return g, named


build_nacht.shortfall = {}

BUILDERS = {"waldweg": build, "flutlichtung": build_flut, "nachtwald": build_nacht}


def text(name="waldweg"):
    return BUILDERS[name]()[0].text()


def write(name="waldweg"):
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
        sys.exit("usage: layout_akt3_maps.py waldweg|flutlichtung|nachtwald [--write]")
    if "--write" in sys.argv:
        write(sys.argv[1])
    else:
        print(text(sys.argv[1]))
