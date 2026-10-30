#!/usr/bin/env python3
"""Layout helper for the Act III maps (docs/akt3/REGIONSBRIEFE.md).

Draws the [map] block of content/maps/waldweg.txt (W2): the first forest of the real world. The brook of the
Bachlauf comes in from the north and goes on to the south; a worn path follows its west bank through a tall
forest of beech and spruce: past the way markers of the Antreiber, the first Rastplatz, the Hang (a sunken
lane with steps cut into it), the second Rastplatz, a spur to the hermit's hut in the west (its door leads
to the interior, W3) and on to the last marker with its blank board and the way south (a blocker until W4).
Hand-written head (meta, legend) stays; only the [map] block is replaced.

Usage: python3 tools/art/layout_akt3_maps.py waldweg [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/waldweg.txt (once the layout is final).
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
BLOCKER = (SOUTH_X, 57)
HANG_Y = (27, 35)  # the sunken lane: markers at its top and its foot
REST_Y = (19, 41)  # the two Rastplätze: one before the Hang, one after it
POSTS = {"1": 9, "2": 15, "3": 24, "4": 38, "5": 49}  # the way markers of the Antreiber, by row
LAST_POST = (SOUTH_X - 2, 54)  # the sixth board, blank, where he stands
HUT = (27, 44)  # the hut in its glade, west of the path


def centerline():
    """The brook's centre line, sampled the way Grid.path does: [(x, y, width)]."""
    out = []
    for i in range(len(STREAM) - 1):
        p0 = STREAM[max(i - 1, 0)]
        p1, p2 = STREAM[i], STREAM[i + 1]
        p3 = STREAM[min(i + 2, len(STREAM) - 1)]
        for s in range(40):
            t = s / 40
            t2, t3 = t * t, t * t * t
            x, y = (0.5 * (2 * p1[k] + (-p0[k] + p2[k]) * t + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2
                           + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3) for k in (0, 1))
            out.append((x, y, WIDTHS[i] + (WIDTHS[i + 1] - WIDTHS[i]) * t))
    out.append((STREAM[-1][0], STREAM[-1][1], WIDTHS[-1]))
    return out


def stream_x(y):
    """Centre column of the brook at row y (the sample nearest to it)."""
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
    # the way on to the south is closed (until W4): a blocker across the path
    put("B", *BLOCKER)
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
    g.add_rails()
    build.shortfall = shortfall
    return g, named


def text():
    return build()[0].text()


def write(name="waldweg"):
    path = os.path.join(ROOT, "content", "maps", "%s.txt" % name)
    with open(path, encoding="utf-8") as f:
        head = f.read()
    head = head[:head.index("[map]\n") + len("[map]\n")]
    with open(path, "w", encoding="utf-8") as f:
        f.write(head + text() + "\n")
    print("wrote [map] block of", os.path.relpath(path, ROOT))
    if build.shortfall:
        print("note: the scatter placed fewer than asked (glyph: placed, asked):", build.shortfall)


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] != "waldweg":
        sys.exit("usage: layout_akt3_maps.py waldweg [--write]")
    if "--write" in sys.argv:
        write(sys.argv[1])
    else:
        print(text())
