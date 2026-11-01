#!/usr/bin/env python3
"""Layout helper for the Act IV maps (docs/akt4/REGIONSBRIEFE.md).

Draws the [map] block of content/maps/strasse.txt (S1): the cart road from the valley to the town, 96 x 56
cells (class M, ADR-068). It comes in through a gap in the forest at the east edge (the door to the valley) and
runs west in gentle bends: past a signpost, a goat's hoof prints in the dust, a field with a scarecrow and its
notice, over a small stone bridge across a brook, past the pasture whose corner post carries a bell, the milestone
and an orchard, to a hill with a bench at the west end, from which the smoke of the town's chimneys is seen above
the hedge. The road ends in a gap of the western forest, closed by a rope and a blocker (the paving work, until
S2 puts the door into the town there). Ruts of mud run along the road with a puddle here and there at its edge.
Hand-written head (meta, legend) stays; only the [map] block is replaced.

Usage: python3 tools/art/layout_akt4_maps.py strasse [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/strasse.txt (once the layout is final: ADR-068).
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from layout_look_maps import Grid, wobble  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

W, H = 96, 56
# The road: east edge to west edge, a cart track five cells wide that bends gently.
ROAD = [(95, 30), (88, 30), (81, 29), (74, 30), (66, 31), (59, 31), (52, 29), (44, 28), (36, 30), (28, 32), (21, 32),
        (13, 32), (6, 32), (0, 32)]
ROAD_W = 5.2
# The brook crosses the road at x of about 59 (a small stone bridge, three cells wide).
STREAM = [(62, 0), (62, 10), (61, 20), (60, 28), (59, 36), (60, 45), (63, 50), (66, 55)]
STREAM_W = [2.4, 2.4, 2.5, 2.6, 2.6, 2.5, 2.4, 2.4]
DOOR_X = 94  # the door to the valley, one cell from the edge; the arrival five cells before it; the start lies mid-road east of the bridge (the benchmark walks right first)
ARRIVAL_X, START_X = 89, 66
WEST_GAP = 4  # the blocker, with the rope one cell east of it; the arrival from the town seven cells east of it
ROPE_X = 5
CITY_X = 11
HILL_X = (10, 28)  # the hill: columns of the terrace (it ends in a slope to the east, where the road bends away)
TERRACE_Y = (25, 27)  # rows of the terrace on the hill
CLIFF_Y = (28, 29)  # the low earth step between road and terrace; a ramp of three cells goes up through it
RAMP_X = 20
HEDGE_Y = (22, 24)  # the band of hedge on the hill's crest (the pocket with the roofs lies behind it)
POCKET = (11, 32, 14, 21)  # x0, x1, y0, y1 of the meadow behind the hedge
# fields and fences
FIELD = (67, 85, 13, 22)  # the field with the scarecrow: x0, x1, y0, y1 (its outer extent)
FIELD_BEDS = [(67, 76, 13, 22), (79, 85, 14, 22)]  # the two beds of tilled soil in it, a grass strip between them
FIELD_FENCE_Y = 24
FIELD_GAP = (75, 76)
FIELD_FENCE_X = (65, 87)
PASTURE = (42, 54, 14, 24)  # the pasture north of the road with the hay: x0, x1, y0, y1 (the fence stands on x0 and x1 - 1)
PASTURE_FENCE_Y = 24
ORCHARD = (28, 46, 36, 50)  # the orchard south of the road: x0, x1, y0, y1
PADDOCK = (70, 89, 37, 49)  # the pasture in the south-east
PADDOCK_GAP = (76, 77)


def _centerline(points, widths=None):
    """A path's centre line, sampled the way Grid.path does: [(x, y, width)]."""
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


_ROAD = _centerline(ROAD)
_STREAM = _centerline(STREAM, STREAM_W)


def road_y(x):
    """Centre row of the road at column x (the sample nearest to it)."""
    return min(_ROAD, key=lambda s: abs(s[0] - x))[1]


def road_row(x):
    return int(round(road_y(x)))


def stream_x(y):
    """Centre column of the brook at row y."""
    return min(_STREAM, key=lambda s: abs(s[1] - y))[0]


def road_distance(x, y):
    """Distance of a cell from the road's centre line."""
    return min(math.hypot(x - sx, y - sy) for sx, sy, _ in _ROAD[::4])


def bridge_columns():
    """The columns of the brook's water on the road's centre row: the deck lies over them."""
    yc = road_row(59)
    cols = [x for x in range(40, 80) if abs(x - stream_x(yc)) <= STREAM_W[3] / 2 + 0.35]
    return min(cols) - 1, max(cols) + 1


def block_end(y):
    """East edge of the forest block round the town's pocket at row y: ragged, never a straight line."""
    return 38 + round(0.5 + wobble(y, (1.5, 2.4, 0.5), (1.0, 5.3, 1.7), (0.6, 1.4, 2.0)))


def land():
    g = Grid(W, H)
    # the forest ring: thick at the north and south, thinner at the east and west, ragged at the inner edge (bays and
    # bulges, so that the edge is never a straight line along the cells)
    for x in range(W):
        north = 5 + round(1.2 + wobble(x, (1.5, 3.3, 0.0), (1.0, 1.9, 1.0), (0.9, 7.1, 2.0), (0.8, 12.0, 0.4)))
        south = 5 + round(0.8 + wobble(x, (1.3, 2.9, 0.5), (0.9, 5.3, 1.7), (0.8, 11.0, 2.5)))
        for y in range(0, max(north, 1)):
            g.set(x, y, "h")
        for y in range(H - max(south, 2), H):
            g.set(x, y, "h")
    for y in range(H):
        west = 7 + round(0.8 + wobble(y, (1.4, 2.6, 0.3), (1.0, 4.7, 2.2), (0.8, 1.3, 0.9), (0.7, 9.0, 1.1)))
        east = 6 + round(1.4 + wobble(y, (1.8, 3.1, 1.1), (1.2, 5.9, 0.2), (1.0, 8.3, 2.0)))
        for x in range(0, max(west, 2)):
            g.set(x, y, "h")
        for x in range(W - max(east, 2), W):
            g.set(x, y, "h")
    # the north-west block: the hill with the town's pocket behind it. A band of hedge along the crest, a small meadow
    # behind it (the town's outskirts, nobody can get there) and forest round it
    hx0, hx1 = HILL_X
    for y in range(0, HEDGE_Y[1] + 1):
        for x in range(0, block_end(y)):
            g.set(x, y, "h")
    px0, px1, py0, py1 = POCKET
    g.ellipse((px0 + px1) / 2, (py0 + py1) / 2 + 0.5, (px1 - px0) / 2 + 0.7, (py1 - py0) / 2 + 0.7, ".", only="h", wobble=0.12, seed=3)
    for y in range(HEDGE_Y[0], HEDGE_Y[1] + 1):  # the hedge band along the crest stays closed
        for x in range(0, block_end(y)):
            g.set(x, y, "h")
    # the brook
    g.path(STREAM, 2.5, "~", only=".h", widths=STREAM_W)
    yc = road_row(59)
    # the fields
    for x0, x1, y0, y1 in FIELD_BEDS:
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                g.set(x, y, "d", only=".")
    # the road
    g.path(ROAD, ROAD_W, ",", only=".mph^", widths=None)
    # the hill: an earth step along the terrace's south edge, a ramp of three cells where the path climbs
    for x in range(hx0, hx1 + 1):
        for y in range(CLIFF_Y[0], CLIFF_Y[1] + 1):
            g.set(x, y, "^", only=".")
    for y in range(CLIFF_Y[0], CLIFF_Y[1] + 1):
        for x in range(RAMP_X - 1, RAMP_X + 2):
            g.set(x, y, ",")
    # the terrace is meadow (the ramp's path runs up to the bench)
    for y in range(TERRACE_Y[0], TERRACE_Y[1] + 1):
        for x in range(hx0, hx1 + 1):
            g.set(x, y, ".", only=".h")
    for y in range(TERRACE_Y[0], TERRACE_Y[1] + 1):
        for x in range(RAMP_X - 1, RAMP_X + 2):
            g.set(x, y, ",")
    # the west end: the road runs between forest on both sides; the paving is laid as far as the rope, a few stones short of it
    for x in range(0, 5):
        yr = road_row(x)
        for k, y in enumerate(range(yr - 2, yr + 3)):
            if x <= (3, 4, 3, 4, 2)[k]:
                g.set(x, y, "_")
    # the bridge: a deck of three rows over the brook, wider by a cell at each end
    b0, b1 = bridge_columns()
    for x in range(b0, b1 + 1):
        for y in range(yc - 1, yc + 2):
            g.set(x, y, "_")
    # ruts along the road: two lines of mud that break off now and then, puddles in them and at the edge
    for x in range(9, W - 9):
        if b0 - 1 <= x <= b1 + 1:
            continue
        yr = road_y(x)
        for side, phase in ((-1, 0.0), (1, 2.1)):
            if wobble(x, (1.0, 4.3, phase), (0.8, 1.7, phase + 1.0)) > -0.55:
                y = int(round(yr + side * 1.0))
                if g.get(x, y) == ",":
                    g.set(x, y, "m")
    for x0, side in ((18, 1), (34, -1), (44, 1), (70, -1), (79, 1), (84, -1), (27, -1), (51, 1)):
        yr = road_row(x0)
        for dx in (0, 1):
            g.set(x0 + dx, yr + side * 2, "p", only=",m")
        g.set(x0 + 1, yr + side * 1, "p", only=",m")
    for x0, side in ((30, 1), (62, -1), (73, 1)):  # a puddle in a rut
        g.set(x0, road_row(x0) + side, "p", only="m")
    # the gaps at the edges: the road runs on between the forest
    return g


def build():
    """The grid with the placements: the named spots first, then the trees keep their distance."""
    g = land()
    rng = random.Random(97)
    named = {}
    shortfall = {}
    reserved = []  # (x0, x1, y0, y1): no tall crown inside (a crown hides what lies behind it, south of its foot)
    trees = []

    def put(glyph, x, y):
        x, y = int(round(x)), int(round(y))
        assert g.get(x, y) is not None, (glyph, x, y)
        g.set(x, y, glyph)
        named.setdefault(glyph, []).append((x, y))

    def hidden(x, y):
        return any(x0 <= x <= x1 and y0 <= y <= y1 for x0, x1, y0, y1 in reserved)

    def free(x, y, clearance):
        return all(g.get(x + dx, y + dy) == "." for dy in range(-clearance, clearance + 1)
                   for dx in range(-clearance, clearance + 1))

    def scatter(glyph, count, clearance, region, test=lambda x, y: True, tall=False, apart=0, road=0.0):
        placed = 0
        tries = 0
        x0, x1, y0, y1 = region
        while placed < count and tries < 8000:
            tries += 1
            x, y = rng.randint(x0, x1), rng.randint(y0, y1)
            if not free(x, y, clearance) or not test(x, y):
                continue
            if tall and hidden(x, y):
                continue
            if road and road_distance(x, y) < road:
                continue
            if apart and any(abs(x - tx) < apart and abs(y - ty) < apart for tx, ty in trees):
                continue
            g.set(x, y, glyph)
            if tall:
                trees.append((x, y))
            named.setdefault(glyph, []).append((x, y))
            placed += 1
        if placed < count:
            shortfall[glyph] = (placed, count)

    # ---- the door to the valley, the arrival and the start: on the road, five cells apart
    put("N", DOOR_X, road_row(DOOR_X))
    put("n", ARRIVAL_X, road_row(ARRIVAL_X))
    put("@", START_X, road_row(START_X))
    # ---- the west end: the rope's two posts and the rope, the blocker behind them, the arrival from the town
    yr = road_row(WEST_GAP)
    put("B", WEST_GAP, yr)
    put("Z", ROPE_X, yr)
    put("X", ROPE_X, yr - 2)
    put("X", ROPE_X, yr + 2)
    put("s", CITY_X, road_row(CITY_X))
    put("V", 9, road_row(9) - 2)  # the paving stones, stacked at the road's edge
    # ---- the signpost, south of the road, a few steps from the arrival
    put("1", 84, road_row(84) + 3)
    # ---- the goat's hoof prints: from the paddock's gap over the road to the field's gap, then along the road (prints
    # on grass are the glyph a, on the road the glyph x: the baked ground under them stays what it was)
    def print_at(x, y):
        put("x" if g.get(x, y) == "," else "a", x, y)

    print_at(PADDOCK_GAP[0], road_row(76) + 4)
    put("2", 77, road_row(77))
    print_at(FIELD_GAP[0], road_row(76) - 4)
    print_at(66, road_row(66) + 3)
    print_at(50, road_row(50) - 3)
    print_at(33, road_row(33) + 2)
    # ---- the field: the scarecrow in its middle, the notice at the fence on the road side
    put("4", 72, 20)
    put("3", FIELD_FENCE_X[0] + 5, FIELD_FENCE_Y + 3)
    # ---- the bridge parapets
    b0, b1 = bridge_columns()
    yc = road_row(59)
    for x in range(b0, b1 + 1):
        put("q", x, yc - 1)
        put("Q", x, yc + 1)
    # ---- the pasture north of the road: the bell hangs on the corner post at the road's side
    put("S", PASTURE[1] - 1, PASTURE_FENCE_Y)
    put("6", PASTURE[1] - 1, PASTURE_FENCE_Y + 1)
    # ---- the milestone on the south verge, about the middle of the road
    put("5", 47, road_row(47) + 3)
    # ---- the hill: the bench and the view; the way up
    put("b", 17, 26)
    put("7", 20, 25)
    # ---- fences: horizontal runs of F, posts E on the vertical sides and at the corners
    def fence_h(x0, x1, y, gap=()):
        for x in range(x0, x1 + 1):
            if x not in gap and g.get(x, y) == ".":
                put("F", x, y)

    def fence_v(x, y0, y1):
        for y in range(y0, y1 + 1):
            if g.get(x, y) == ".":
                put("E", x, y)

    fence_h(FIELD_FENCE_X[0], FIELD_FENCE_X[1], FIELD_FENCE_Y, FIELD_GAP)
    fence_v(FIELD_FENCE_X[0], FIELD[2] - 1, FIELD_FENCE_Y - 1)
    fence_v(FIELD_FENCE_X[1], FIELD[2] - 1, FIELD_FENCE_Y - 1)
    fence_h(PASTURE[0], PASTURE[1] - 2, PASTURE_FENCE_Y, (44, 45))
    fence_v(PASTURE[0], PASTURE[2], PASTURE_FENCE_Y - 1)
    fence_v(PASTURE[1] - 1, PASTURE[2], PASTURE_FENCE_Y - 1)
    px0, px1, py0, py1 = PADDOCK
    fence_h(px0 - 1, px1, py0 - 1, PADDOCK_GAP)
    fence_v(px0 - 1, py0, py1)
    ox0, ox1, oy0, oy1 = ORCHARD
    fence_h(ox0, ox1, oy0, (36, 37))
    fence_v(ox0, oy0 + 1, oy1)
    fence_v(ox1, oy0 + 1, oy1)
    # ---- the roofs behind the hedge, the town's outskirts
    for glyph, (x, y) in (("J", (15, 20)), ("L", (22, 19)), ("M", (28, 20)), ("J", (19, 17))):
        put(glyph, x, y)
    for x, y in ((11, 25), (14, 27), (24, 25), (27, 27), (30, 26)):
        put("u", x, y)
    # ---- hay: stacks and bales in the pasture, a few bales at the paddock
    for glyph, (x, y) in (("H", (46, 19)), ("H", (51, 20)), ("Y", (48, 22)), ("Y", (52, 17)), ("H", (44, 15)),
                          ("Y", (49, 16)), ("H", (73, 44)), ("Y", (80, 45)), ("Y", (82, 42))):
        put(glyph, x, y)
    # ---- no tall crown hides a spot with a cue (a crown hides what lies behind it, south of its foot)
    for glyph in "123456789xaqQ7b@nsBZ":
        for x, y in named.get(glyph, []):
            reserved.append((x - 3, x + 3, y + 1, y + 8))
    # a crown does not stand over the road either: nothing within three columns and eight rows south of it
    for y in range(H):
        for x in range(W):
            if g.get(x, y) in ",m_p":
                reserved.append((x - 1, x + 1, y + 1, y + 6))
    # ---- orchard: apple trees in loose rows
    for ry, row in enumerate(range(oy0 + 4, oy1, 4)):
        for x in range(ox0 + 3 + (ry % 2) * 2, ox1 - 1, 4):
            tx, ty = x + rng.randint(-1, 1), row + rng.randint(-1, 1)
            if g.get(tx, ty) == "." and all(g.get(tx + dx, ty + dy) in (".", "h") for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
                put("O", tx, ty)
    # ---- the forest and the meadow: oaks, crooked trees and pines keep their distance from the road and the cues
    scatter("T", 9, 2, (6, W - 8, 8, H - 8), tall=True, apart=5, road=7.0, test=lambda x, y: not (
        FIELD[0] - 2 <= x <= FIELD[1] + 2 and FIELD[2] - 2 <= y <= FIELD_FENCE_Y + 2 or
        PADDOCK[0] - 2 <= x <= PADDOCK[1] + 2 and PADDOCK[2] - 2 <= y <= PADDOCK[3] + 2 or
        ORCHARD[0] - 2 <= x <= ORCHARD[1] + 2 and ORCHARD[2] - 2 <= y <= ORCHARD[3] + 2))
    scatter("C", 3, 2, (6, W - 8, 8, H - 8), tall=True, apart=5, road=7.0, test=lambda x, y: not (
        FIELD[0] - 2 <= x <= FIELD[1] + 2 and FIELD[2] - 2 <= y <= FIELD_FENCE_Y + 2 or
        PADDOCK[0] - 2 <= x <= PADDOCK[1] + 2 and PADDOCK[2] - 2 <= y <= PADDOCK[3] + 2 or
        ORCHARD[0] - 2 <= x <= ORCHARD[1] + 2 and ORCHARD[2] - 2 <= y <= ORCHARD[3] + 2))
    scatter("P", 12, 1, (4, W - 5, 4, H - 5), tall=True, apart=3, road=6.0,
            test=lambda x, y: any(g.get(x + dx, y + dy) == "h" for dx in range(-3, 4) for dy in range(-3, 4)))
    scatter("R", 9, 1, (6, W - 7, 6, H - 7), road=5.0)
    scatter("g", 26, 0, (6, W - 7, 6, H - 7), road=3.5,
            test=lambda x, y: any(g.get(x + dx, y + dy) in "h~" for dx in range(-3, 4) for dy in range(-3, 4)))
    # the pocket: a few trees among the roofs
    scatter("T", 3, 1, (POCKET[0] + 1, POCKET[1] - 1, POCKET[2], POCKET[3]), tall=False, apart=0,
            test=lambda x, y: all(abs(x - rx) > 3 or abs(y - ry) > 2 for r in "JLM" for rx, ry in named.get(r, [])))
    build.shortfall = shortfall
    return g, named


build.shortfall = {}


BUILDERS = {"strasse": build}


def text(name="strasse"):
    return BUILDERS[name]()[0].text()


def write(name="strasse"):
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
        sys.exit("usage: layout_akt4_maps.py strasse [--write]")
    if "--write" in sys.argv:
        write(sys.argv[1])
    else:
        print(text(sys.argv[1]))
