#!/usr/bin/env python3
"""Layout helper for the vertical-slice maps (Phase 4, docs/PHASE4_PLAN.md).

Draws the [map] block of content/maps/tal.txt: the valley of the look prototype, wider in
the east for Mira's camp, with the story's obstacles built in: the bridge is broken in the
middle, a field of stepping stones crosses the stream north of it (flat ones hold, round
ones tip), and a fallen tree further up is the long, safe way round.

Also the two repeating pieces of the Antreiber's path (antreiber_tal, antreiber_tal_bench).

Usage: python3 tools/art/layout_slice_maps.py tal|antreiber_tal|antreiber_tal_bench [--write]
Afterwards re-run tools/art/bake_ground.py content/maps/<name>.txt.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from layout_look_maps import Grid, wobble  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
# The stepping-stone field (see tal()): F = flat stone that holds, o = round one that tips.
# Enter from the west bank in the middle row, leave to the east bank in the bottom row.
STONE_ROWS = (17, 18, 19)
STONE_X = 39
STONE_FIELD = ["oFFFo",
               "FFoFo",
               "ooFFF"]
LOG_ROW = 7


def tal():
    w, h = 68, 38
    g = Grid(w, h)
    for x in range(w):
        north = 2 + round(1.0 + wobble(x, (1.0, 3.3, 0.0), (0.7, 1.9, 1.0), (0.6, 7.1, 2.0)))
        south = 2 + round(0.6 + wobble(x, (0.8, 2.9, 0.5), (0.5, 5.3, 1.7)))
        for y in range(0, max(north, 1)):
            g.set(x, y, "h")
        for y in range(h - max(south, 2), h):
            g.set(x, y, "h")
        rock = round(1.3 + wobble(x, (0.9, 2.3, 0.4), (0.6, 4.1, 1.3)))
        for y in range(north, north + max(rock, 0)):
            g.set(x, y, "^")
    for y in range(h):
        west = 3 + round(0.4 + wobble(y, (1.1, 2.6, 0.3), (0.8, 4.7, 2.2), (0.4, 1.3, 0.9)))
        east = 3 + round(0.3 + wobble(y, (1.0, 3.1, 1.1), (0.7, 5.9, 0.2)))
        for x in range(0, max(west, 2)):
            g.set(x, y, "h")
        for x in range(w - max(east, 2), w):
            g.set(x, y, "h")
    # the trail leaves the valley to the west (towards the shed): an opening in the forest
    for y in range(22, 28):
        for x in range(0, 6):
            if g.get(x, y) == "h" and abs(y - 24.8) < 2.3:
                g.set(x, y, ".")
    # the stream, as in the look prototype
    stream = [(41, 2), (42.5, 6), (41.5, 9.5), (39.5, 13), (40.5, 17), (42.5, 20.5), (42.5, 23),
              (43.5, 26), (44.5, 30), (45.5, 38)]
    widths = [2.2, 2.4, 2.8, 3.4, 3.4, 3.2, 3.2, 2.6, 2.9, 3.3]
    g.path(stream, 3.0, "~", only=".^h", widths=widths)
    g.ellipse(38.6, 14.2, 2.6, 1.9, "~", only=".", wobble=0.6, seed=4)
    # wet ground and mud
    g.ellipse(22, 20.5, 4.2, 1.6, "m", only=".", wobble=0.7, seed=1)
    g.ellipse(35.5, 23.2, 2.6, 1.2, "m", only=".", wobble=0.7, seed=3)
    g.ellipse(9.5, 25.5, 2.2, 1.1, "m", only=".", wobble=0.8, seed=5)
    g.ellipse(51, 21.5, 3.2, 1.3, "m", only=".", wobble=0.6, seed=6)  # trodden round the camp
    # the trail: from the forest in the west past the house to the bridge, on to the camp
    trail = [(0, 24.8), (7, 24.5), (13, 23), (18, 21.2), (24, 20.6), (29, 21.4), (35, 22.4), (40, 22),
             (46, 22.3), (50, 21.6)]
    g.path(trail, 2.0, ",", only=".m", widths=[1.6, 1.7, 1.9, 2.1, 2.5, 2.3, 1.9, 2.1, 1.9, 1.6])
    g.path([(26, 15.5), (25.6, 17.5), (26.2, 20)], 2.0, ",", only=".m")  # to the house
    g.path([(14, 23.5), (12.5, 27), (10, 30.5)], 1.2, ",", only=".")  # a faint side track
    # Mira's own trodden paths: down to the water, up to where she gets wood
    g.path([(50, 21.6), (48.5, 19.5), (47, 18.5)], 1.2, ",", only=".m")
    g.path([(52, 20), (55, 15), (57, 11)], 1.1, ",", only=".")
    # the plank bridge, broken in the middle: only the ends on both banks are left
    for y in (21, 22, 23):
        for x in range(39, 47):
            if g.get(x, y) == "~":
                g.set(x, y, "=")
        row = [x for x in range(39, 47) if g.get(x, y) == "="]
        if row:
            g.set(min(row) - 1, y, "=")
            g.set(max(row) + 1, y, "=")
    gap = _bridge_gap(g)
    for y in (21, 22, 23):
        for x in gap:
            g.set(x, y, "y")  # walkable once Mira lays boards over it; blocked until then
    # a lower terrace in the south-east: the stream drops over its ragged edge
    for x in range(33, w - 2):
        top = 27 + round(wobble(x, (0.8, 2.1, 0.7), (0.5, 3.7, 0.1)))
        for y in range(top, top + 2):
            cell = g.get(x, y)
            if cell == ".":
                g.set(x, y, "^")
            elif cell == "~":
                g.set(x, y, "v")
    # vegetable beds in the yard; potatoes in the unfinished bottom row
    for y, x1 in ((11, 17), (12, 17), (13, 15)):
        for x in range(12, x1):
            g.set(x, y, "d")
    for x, y in [(13, 23), (20, 21), (24, 18), (27, 20), (31, 22), (8, 25), (36, 22), (49, 22)]:
        if g.get(x, y) in ".,m":
            g.set(x, y, "p")
    stones = _stepping_stones(g)
    log_cells = _fallen_tree(g)
    props = {
        "H": [(26, 12)],
        "D": [(26, 13)],
        "F": [(x, 16) for x in range(19, 34) if x not in (21, 25, 26, 27, 31)],
        "B": [(31, 16)],
        "E": [(19, y) for y in range(10, 16)] + [(33, y) for y in range(10, 16)],
        "T": [(9, 7), (13, 6), (49, 8), (8, 29), (22, 30), (35, 30), (6, 18), (16, 27), (61, 13),
              (59, 25), (55, 9)],
        "P": [(7, 6), (11, 8), (47, 7), (51, 10), (5, 30), (10, 31), (24, 31), (33, 31), (52, 31),
              (6, 21), (63, 18), (62, 8), (58, 30)],
        "C": [(5, 9), (11, 19), (14, 26), (19, 31), (49, 29), (37, 9)],
        "R": [(36, 13), (35, 14), (8, 12), (9, 13), (31, 27), (32, 28), (17, 30), (56, 24), (57, 25)],
        "g": [(8, 19), (9, 19), (9, 20), (16, 25), (17, 25), (17, 26), (29, 25), (30, 25), (30, 26),
              (35, 18), (46, 11), (47, 12), (58, 16), (59, 16), (54, 26)],
        "K": [(31, 13), (21, 13)],
        "W": [(30, 13)],
        "b": [(22, 14)],
        # Mira's camp on the east bank: tarp, fire, her fishing rod at the water
        "U": [(53, 17)],
        "c": [(51, 19)],
        "N": [(49, 18)],
        "r": [(48, 17)],
        # in the evening Mira sits on the other side of her fire; by day she keeps busy
        "M": [(52, 20)],
        # things to look at, smell and taste (the real world, Game Bible §12)
        "u": [(52, 17)],
        "z": [(52, 19)],
        "f": [(24, 17)],
        "a": [(58, 14)],
        "A": [(60, 21)],
        "I": [(21, 16)],
        "k": [(gap[0], 22)],
        "L": [(gap[1], 22)],
        "n": [(gap[2], 22)],
        "i": [(max(x for x in range(37, 52) if g.get(x, 22) == "=") + 1, 22)],
        "Y": [(log_cells[0], LOG_ROW)],
        "G": [(17, 9)],
        "O": [(30, 14)],
        "o": [(14, 13)],
        "1": [(58, 9)],
        "2": [(26, 14)],
        "3": [(3, 25)],
        "X": [(0, 25)],
        "Z": [(1, 25)],
        "V": [(2, 25)],
        "@": [(52, 22)],
        # until Mira was asked, the stream holds you back (her no is the valley's first beat)
        "J": [(log_cells[-1], LOG_ROW)],
        "j": [(STONE_X + len(STONE_FIELD[0]), STONE_ROWS[1])],
    }
    for c, pts in props.items():
        for x, y in pts:
            g.set(x, y, c)
    for (x, y), wobbly in stones.items():
        g.set(x, y, "s" if wobbly else "S")
    g.set(STONE_X + len(STONE_FIELD[0]), STONE_ROWS[2], "4")
    g.set(STONE_X - 1, STONE_ROWS[1], "5")
    # spray where the stream lands below the edge
    for y in range(h):
        for x in range(w):
            if g.get(x, y) == "~" and g.get(x, y - 1) == "v" and g.get(x - 1, y) != "x":
                g.set(x, y, "x")
                break
        else:
            continue
        break
    g.add_rails()
    return g


def _bridge_gap(g):
    """Columns of the bridge's middle that broke away (three planks wide)."""
    row = [x for x in range(37, 50) if g.get(x, 22) == "="]
    mid = (row[0] + row[-1]) // 2
    return [mid - 1, mid, mid + 1]


def _stepping_stones(g):
    """A field of stones three rows deep across the stream. One 4-connected way of flat,
    mossy stones holds; every other stone is round and tips. Returns {cell: wobbly}."""
    x0 = STONE_X
    rows = STONE_ROWS
    for y in rows:
        for x in range(x0, x0 + len(STONE_FIELD[0])):
            g.set(x, y, "~")
        g.set(x0 - 1, y, ".")
        g.set(x0 + len(STONE_FIELD[0]), y, ".")
    stones = {}
    for dy, line in enumerate(STONE_FIELD):
        for dx, ch in enumerate(line):
            stones[(x0 + dx, rows[dy])] = ch == "o"
    return stones


def _fallen_tree(g):
    """Cells of the tree trunk lying across the stream at LOG_ROW (walkable)."""
    cols = [x for x in range(g.w) if g.get(x, LOG_ROW) == "~"]
    cells = list(range(cols[0] - 1, cols[-1] + 2))
    for x in cells:
        g.set(x, LOG_ROW, "y" if g.get(x, LOG_ROW) == "~" else g.get(x, LOG_ROW))
    return cells


def antreiber(bench):
    """One piece of the path that does not end (Antreiber, beat 5): forest on both sides, the
    trail through the middle. Pieces repeat endlessly, so both edge columns are identical in
    every piece and a tree stands on each seam. Every other piece has a bench and a sign."""
    w, h = 20, 23
    g = Grid(w, h)
    for x in range(w):
        inner = 0 < x < w - 1
        north = 3 + (round(1.2 + wobble(x + (7 if bench else 0), (1.0, 2.1, 0.3), (0.6, 1.3, 1.1))) if inner else 1)
        south = 3 + (round(1.2 + wobble(x + (3 if bench else 0), (0.9, 1.9, 0.9), (0.6, 1.1, 0.2))) if inner else 1)
        for y in range(0, north):
            g.set(x, y, "h")
        for y in range(h - south, h):
            g.set(x, y, "h")
    widths = [2.6, 2.8, 3.2, 2.9, 2.6] if not bench else [2.6, 3.0, 3.4, 3.0, 2.6]
    g.path([(-1, 11), (5, 11.2), (10, 10.8 if bench else 11.4), (15, 11.1), (20, 11)], 3.0, ",", only=".",
           widths=widths)
    for x in range(w):  # the seam: the same three path rows at both ends
        for y in range(9, 14):
            if x in (0, w - 1):
                g.set(x, y, "," if 10 <= y <= 12 else ".")
    g.ellipse(6 if bench else 13, 12.6, 1.8, 0.8, "m", only=",", wobble=0.6, seed=2 if bench else 5)
    for x, y in ([(4, 10), (14, 12)] if bench else [(8, 12), (17, 10)]):
        if g.get(x, y) == ",":
            g.set(x, y, "p")
    props = {"T": [(0, 5), (0, 17)], "P": [], "C": [], "R": [], "g": []}
    if bench:
        props["b"] = [(9, 9)]
        props["S"] = [(5, 9)]
        props["P"] += [(14, 5), (4, 17), (17, 17), (11, 6)]
        props["T"] += [(3, 6)]
        props["C"] += [(7, 4), (13, 17)]
        props["R"] += [(16, 15)]
        props["g"] += [(12, 8), (13, 8), (3, 14)]
    else:
        props["P"] += [(6, 5), (15, 17), (3, 17), (16, 4)]
        props["T"] += [(12, 4), (9, 18)]
        props["C"] += [(17, 6), (5, 16)]
        props["R"] += [(4, 15), (5, 15)]
        props["g"] += [(15, 8), (8, 14), (9, 14)]
    for c, pts in props.items():
        for x, y in pts:
            g.set(x, y, c)
    return g


def write(text, name="tal"):
    path = os.path.join(ROOT, "content", "maps", "%s.txt" % name)
    with open(path, encoding="utf-8") as f:
        head = f.read()
    head = head[:head.index("[map]\n") + len("[map]\n")]
    with open(path, "w", encoding="utf-8") as f:
        f.write(head + text + "\n")
    print("wrote [map] block of", os.path.relpath(path, ROOT))


if __name__ == "__main__":
    makers = {"tal": tal, "antreiber_tal": lambda: antreiber(False),
              "antreiber_tal_bench": lambda: antreiber(True)}
    if len(sys.argv) < 2 or sys.argv[1] not in makers:
        sys.exit("usage: layout_slice_maps.py %s [--write]" % "|".join(makers))
    grid = makers[sys.argv[1]]()
    if "--write" in sys.argv:
        write(grid.text(), sys.argv[1])
    else:
        print(grid.text())
