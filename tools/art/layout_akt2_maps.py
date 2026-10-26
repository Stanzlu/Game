#!/usr/bin/env python3
"""Layout helper for the Act II maps (docs/akt2/REGIONSBRIEFE.md).

Draws the [map] block of content/maps/bachlauf.txt (B3): the stream below the valley, the first
big map of the game. A worn track leads along the stream on both banks in one loop (nothing to go
back over): down the west bank, over the log of the south ford, up the east bank and over the log
of the narrow ford at the head to where it began, a gap in the northern forest that leads back to
the valley. Since Act III (W2) the track also leaves from the south ford through a gap in the southern
forest, along the brook, to the forest map waldweg. Hand-written head (meta, legend) stays; only the
[map] block is replaced.

Usage: python3 tools/art/layout_akt2_maps.py bachlauf [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/bachlauf.txt (once the layout is final: a
cell that changes the paint repaints much of the picture).
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from layout_look_maps import Grid, wobble  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

W, H = 84, 66
# The stream comes from beyond the northern forest and leaves through the southern one.
STREAM = [(40, 0), (41, 9), (47, 19), (52, 28), (50, 38), (43, 47), (45, 56), (53, 65)]
WIDTHS = [2.4, 2.6, 3.0, 3.4, 3.2, 3.0, 3.2, 3.0]
POCKET_X = 35  # the gap in the northern forest, three cells wide (34 to 36)
DOOR = (POCKET_X, 1)
ARRIVAL = (POCKET_X, 6)
START = (POCKET_X, 7)
HEAD_FORD_Y = 9  # the narrow ford near the head: a trunk across the stream
SOUTH_FORD_Y = 56  # the south ford: three cells of water, as wide as the trunk reaches
WEIR_Y = 50  # the weir: one row of fall across the stream, the trap behind it
DRY_BED_Y = (27, 38)  # the dry channel on the east bank, as wide as the stream, rows from..to
SOUTH_X = 45  # Act III (W1/W2): the gap in the southern forest, three cells wide (44 to 46), the way on along the brook
SOUTH_DOOR = (SOUTH_X, 64)
SOUTH_ARRIVAL = (SOUTH_X, 60)


def centerline():
    """The stream's centre line, sampled the way Grid.path does: [(x, y, width)]."""
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
    """Centre column of the stream at row y (the sample nearest to it)."""
    return min(centerline(), key=lambda s: abs(s[1] - y))[0]


def bank(y, side, gap):
    """A point `gap` cells from the stream's centre line on the west (-1) or east (+1) bank."""
    return (round(stream_x(y) + side * gap, 1), y)


def water_cells(g, y):
    return [x for x in range(g.w) if g.get(x, y) in "~v"]


def bachlauf():
    g = Grid(W, H)
    # the forest ring, as in the valley: uneven and a few cells thick
    for x in range(W):
        north = 3 + round(0.8 + wobble(x, (1.0, 3.3, 0.0), (0.7, 1.9, 1.0), (0.6, 7.1, 2.0)))
        south = 3 + round(0.4 + wobble(x, (0.8, 2.9, 0.5), (0.5, 5.3, 1.7)))
        for y in range(0, max(north, 1)):
            g.set(x, y, "h")
        for y in range(H - max(south, 2), H):
            g.set(x, y, "h")
    for y in range(H):
        west = 4 + round(0.4 + wobble(y, (1.1, 2.6, 0.3), (0.8, 4.7, 2.2), (0.4, 1.3, 0.9)))
        east = 4 + round(0.3 + wobble(y, (1.0, 3.1, 1.1), (0.7, 5.9, 0.2)))
        for x in range(0, max(west, 2)):
            g.set(x, y, "h")
        for x in range(W - max(east, 2), W):
            g.set(x, y, "h")
    # the stream
    g.path(STREAM, 3.0, "~", only=".h", widths=WIDTHS)
    # the gap in the northern forest: the way back to the valley
    for y in range(0, 7):
        for x in range(POCKET_X - 1, POCKET_X + 2):
            g.set(x, y, ",")
    # the gap in the southern forest (Act III): the way on, along the brook, into the forest
    for y in range(60, H):
        for x in range(SOUTH_X - 1, SOUTH_X + 2):
            g.set(x, y, ",", only=".h")
    # a pool the stream leaves behind and a few wet places
    g.ellipse(32.0, 36.0, 1.9, 1.0, "p", only=".", wobble=0.5, seed=2)
    g.ellipse(58.5, 44.0, 2.4, 1.4, "m", only=".", wobble=0.7, seed=3)
    g.ellipse(24.0, 22.0, 4.0, 2.0, "m", only=".", wobble=0.7, seed=5)
    g.ellipse(57.5, 12.0, 2.6, 1.3, "m", only=".", wobble=0.6, seed=7)
    # the track, west bank first: a narrow trodden line that never leaves the stream by more than a few cells
    west = [(POCKET_X, 3), (POCKET_X, 8)] + [bank(y, -1, 5.6) for y in (14, 21, 29, 37, 44, 51)] + \
        [bank(56, -1, 4.0)]
    g.path(west, 2.0, ",", only=".mph", widths=[1.9, 1.8, 1.7, 1.8, 2.0, 1.8, 1.7, 1.8, 1.9])
    east = [bank(56, 1, 4.0), bank(50, 1, 5.6), bank(42, 1, 5.8), bank(33, 1, 6.0), bank(25, 1, 5.8),
            bank(17, 1, 5.4), bank(12, 1, 4.6), bank(9.5, 1, 4.0)]
    g.path(east, 2.0, ",", only=".mph", widths=[1.9, 1.7, 1.8, 2.0, 1.8, 1.7, 1.8, 1.9])
    # the two fords: a trunk across the stream on the track (walkable water), the landings on both banks
    for y in (HEAD_FORD_Y, SOUTH_FORD_Y):
        for x in water_cells(g, y):
            g.set(x, y, "y")
        cols = [x for x in range(W) if g.get(x, y) == "y"]
        for x in (min(cols) - 2, min(cols) - 1, max(cols) + 1, max(cols) + 2):
            g.set(x, y, ",", only=".mph")
    # the way from the south ford on into the gap (Act III)
    g.path([bank(56, -1, 4.0), (43.5, 58.5), (SOUTH_X, 61)], 2.0, ",", only=".mph")
    # the way from the end of the west leg to the south ford, and from the head ford to the pocket
    g.path([bank(8.5, 1, 3.8), (POCKET_X + 3, 8.5), (POCKET_X, 8)], 2.0, ",", only=".mph")
    # the weir: the stream falls one row over a beam
    for x in water_cells(g, WEIR_Y):
        g.set(x, WEIR_Y, "v")
    # a short spur through the reeds to the shallows (blue glass), and a lookout on the east slope
    g.path([bank(44, -1, 5.6), bank(41.5, -1, 3.2), bank(41, -1, 2.6)], 1.2, ",", only=".mh")
    g.path([bank(48, 1, 5.7), (bank(47, 1, 5.7)[0] + 6, 46), (bank(47, 1, 5.7)[0] + 10, 44)], 1.4, ",", only=".mh")
    # the dry channel on the east bank: as wide as the stream, no water in it
    top, bottom = DRY_BED_Y
    chan = [(round(stream_x(y) + 9.0, 1), y) for y in range(top, bottom + 1, 3)]
    g.path(chan, 3.0, "m", only=".h")
    return g


def build():
    """The grid with the placements: props for the forest and meadows, then the named spots."""
    g = bachlauf()
    rng = random.Random(41)
    walk = set(",y")

    def free(x, y, clearance):
        for dy in range(-clearance, clearance + 1):
            for dx in range(-clearance, clearance + 1):
                if g.get(x + dx, y + dy) not in (".",):
                    return False
        return True

    def scatter(glyph, count, clearance, margin=4, region=None):
        placed = 0
        tries = 0
        while placed < count and tries < 4000:
            tries += 1
            x0, x1, y0, y1 = region or (margin, W - margin, margin, H - margin)
            x, y = rng.randint(x0, x1 - 1), rng.randint(y0, y1 - 1)
            if free(x, y, clearance):
                g.set(x, y, glyph)
                placed += 1

    # the named spots first, so the trees keep their distance
    named = {}

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        assert g.get(x, y) is not None, (glyph, x, y)
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    # the post with the empty hook at the start of the track, the lead weight in the grass at its foot
    put("1", POCKET_X - 2, 9)
    put("2", POCKET_X - 3, 10)
    put("3", POCKET_X - 2, 10)
    # the float in the reeds on the west bank, the glass in the shallows after the short spur
    fx = stream_x(30) - 3
    put("4", fx, 30)
    put("0", stream_x(41) - 2.0, 41)
    # the weir with the trap behind it: beam and goat's prints, the wedged trap one row below
    wx = [x for x in range(W) if g.get(x, WEIR_Y) == "v"]
    put("6", wx[len(wx) // 2], WEIR_Y)
    put("7", min(wx) - 2, WEIR_Y)
    below = [x for x in range(W) if g.get(x, WEIR_Y + 2) == "~"]
    put("5", below[0], WEIR_Y + 2)
    # two stumps with a board on the west bank, the dry channel and its pebbles on the east
    put("8", stream_x(23) - 3, 23)
    put("9", stream_x(32) + 9.0, 32)
    # more pebbles in the same channel, all turned the same way (no cue: the spot is the one above)
    for y in (28, 36):
        x, y = int(round(stream_x(y) + 9.0)), y
        g.set(x, y, "k")
    # the lookout: where the way back is to be seen
    put("$", bank(47, 1, 5.7)[0] + 10, 44)
    # the trunks of the two fords: root plate on the west bank, anchored at the first bank cell
    for y in (HEAD_FORD_Y, SOUTH_FORD_Y):
        put("Y", min(x for x in range(W) if g.get(x, y) == "y") - 1, y)
    # a bench at the lookout
    put("b", bank(47, 1, 5.7)[0] + 9, 45)
    # the door to the valley and the markers
    put("%", DOOR[0], DOOR[1])
    put("&", ARRIVAL[0], ARRIVAL[1])
    put("@", START[0], START[1])
    # the door south (Act III, gated by the morning after) and its arrival
    put("W", *SOUTH_DOOR)
    put("w", *SOUTH_ARRIVAL)
    # trees: pines and trees in the forest margins, crooked ones in the meadow, rocks and tall grass by the water
    scatter("T", 26, 2)
    scatter("P", 20, 2)
    scatter("C", 8, 2)
    scatter("R", 12, 1)
    scatter("g", 26, 1)
    # reeds along the water: the stream's edge, a cell off the bank
    for y in range(7, H - 6, 4):
        for side in (-1, 1):
            if rng.random() < 0.35:
                continue
            ry = y + rng.randint(-1, 1)
            x = round(stream_x(ry) + side * rng.choice((2.6, 3.0, 3.4)))
            if g.get(x, ry) == "." and not (abs(ry - 30) < 3 and side < 0):
                g.set(x, ry, "j")
    g.add_rails()
    return g, named


def text():
    return build()[0].text()


def write(name="bachlauf"):
    path = os.path.join(ROOT, "content", "maps", "%s.txt" % name)
    with open(path, encoding="utf-8") as f:
        head = f.read()
    head = head[:head.index("[map]\n") + len("[map]\n")]
    with open(path, "w", encoding="utf-8") as f:
        f.write(head + text() + "\n")
    print("wrote [map] block of", os.path.relpath(path, ROOT))


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] != "bachlauf":
        sys.exit("usage: layout_akt2_maps.py bachlauf [--write]")
    if "--write" in sys.argv:
        write(sys.argv[1])
    else:
        print(text())
