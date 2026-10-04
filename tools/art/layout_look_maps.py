#!/usr/bin/env python3
"""Layout helper for the look-prototype maps (ADR-017).

Draws the [map] block of content/maps/look_elysia.txt and look_tal.txt from shapes
(curved paths, round ponds, wavy cliff edges), which is tedious to type by hand.
The map files stay the source of truth and can be edited directly; running this with
--write replaces their [map] block, so hand edits inside it are lost.

Usage: python3 tools/art/layout_look_maps.py elysia|tal|wald [--write]
Afterwards re-run tools/art/bake_ground.py for the map.
"""
import math
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


class Grid:
    def __init__(self, w, h, fill="."):
        self.w, self.h = w, h
        self.g = [[fill] * w for _ in range(h)]

    def set(self, x, y, c, only=None):
        if 0 <= x < self.w and 0 <= y < self.h:
            if only is None or self.g[y][x] in only:
                self.g[y][x] = c

    def get(self, x, y):
        return self.g[y][x] if 0 <= x < self.w and 0 <= y < self.h else None

    def ellipse(self, cx, cy, rx, ry, c, only=None, wobble=0.0, seed=0.0):
        for y in range(self.h):
            for x in range(self.w):
                a = math.atan2(y - cy, x - cx)
                r = 1.0 + wobble * math.sin(a * 3 + seed) * 0.5 + wobble * math.sin(a * 5 + seed * 2) * 0.3
                if ((x - cx) / (rx * r)) ** 2 + ((y - cy) / (ry * r)) ** 2 <= 1.0:
                    self.set(x, y, c, only)

    def path(self, pts, width, c, only=None):
        samples = []
        for i in range(len(pts) - 1):
            p0 = pts[max(i - 1, 0)]
            p1, p2 = pts[i], pts[i + 1]
            p3 = pts[min(i + 2, len(pts) - 1)]
            for s in range(40):
                t = s / 40
                t2, t3 = t * t, t * t * t
                samples.append(tuple(
                    0.5 * (2 * p1[k] + (-p0[k] + p2[k]) * t + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2
                           + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3) for k in (0, 1)))
        samples.append(pts[-1])
        for y in range(self.h):
            for x in range(self.w):
                d = min(math.hypot(x - sx, y - sy) for sx, sy in samples)
                if d <= width / 2:
                    self.set(x, y, c, only)

    def add_rails(self):
        """Railing placements along the north and south edges of every plank bridge."""
        for y in range(self.h):
            for x in range(self.w):
                if self.g[y][x] != "=":
                    continue
                if self.get(x, y - 1) not in ("=", "q"):
                    self.g[y][x] = "q"
                elif self.get(x, y + 1) not in ("=", "Q", None):
                    self.g[y][x] = "Q"

    def text(self):
        return "\n".join("".join(r) for r in self.g)


def elysia():
    """Elysia's garden, perfectly mirrored around the sacred tree (Game Bible §9: "Perfekte
    Symmetrie. Makellose Architektur."): marble pool in the middle, twin terrace streams with
    twin waterfalls and bridges, twin stairs, mirrored trees and flower beds, Elysians walking
    mirrored routes. Only the unremarkable stone and the rift exist once: the first flaws.

    The left half is drawn, the right half is its mirror (column x <-> 64 - x, axis = column 32,
    65 columns so that every column has its twin).
    """
    w, h = 65, 40
    axis = 32
    g = Grid(w, h)

    def mx(x):
        return 2 * axis - x

    # island edge in the south: wavy but symmetric cliff, then sky
    for x in range(w):
        d = abs(x - axis)
        e = 32 + round(0.8 * math.sin(d / 4.0) + 0.6 * math.sin(d / 2.3 + 1))
        if d <= 5:
            e = 34
        for y in range(e, h):
            g.set(x, y, "^" if y < e + 3 else "%")
    # hedge border north and sides
    for x in range(w):
        d = abs(x - axis)
        bottom = 2 + round(0.6 * math.sin(d / 3.1) + 0.4 * math.sin(d / 1.7 + 2))
        for y in range(0, bottom):
            g.set(x, y, "h")
    for y in range(h):
        for x in (0, 1, w - 2, w - 1):
            if g.get(x, y) == ".":
                g.set(x, y, "h")
    # terrace: cliff face below it, twin stairs
    for x in range(2, w - 2):
        d = abs(x - axis)
        top = 9 - (1 if math.sin(d / 3.3) + 0.5 * math.sin(d / 1.6) > 0.6 else 0)
        for y in range(top, 11):
            g.set(x, y, "^", only=".")
    for x in (11, 12, 13):
        for y in (8, 9, 10):
            for xx in (x, mx(x)):
                if g.get(xx, y) == "^" or y == 10:
                    g.set(xx, y, "s")
    # flower meadows (beds), mirrored
    for cx, cy, rx, ry in ((7, 5, 4, 2), (9, 28, 4, 2.5), (20, 14, 2.5, 1.5)):
        g.ellipse(cx, cy, rx, ry, "f", only=".")
        g.ellipse(mx(cx), cy, rx, ry, "f", only=".")
    # marble ring and front platform, then the pool inside
    g.ellipse(axis, 16.5, 8.4, 5.9, "M", only=".f")
    for y in (21, 22, 23):
        for x in range(27, 38):
            g.set(x, y, "M", only=".f")
    g.ellipse(axis, 16.5, 6.3, 4.2, "~", only="M")
    # paths: main path across the island, central path to the edge, terrace paths
    g.path([(3, 25), (10, 25.5), (18, 25), (26, 23.5)], 2.6, ",", only=".f")
    g.path([(mx(26), 23.5), (mx(18), 25), (mx(10), 25.5), (mx(3), 25)], 2.6, ",", only=".f")
    g.path([(axis, 24), (axis, 28), (axis, 32)], 2.4, ",", only=".f")
    terrace_paths = [
        [(12, 9), (12, 7), (14, 5), (22, 4)],
        [(mx(12), 9), (mx(12), 7), (mx(14), 5), (mx(22), 4)],
    ]
    # twin streams: from the terrace, falling into the garden, past the pool, off the edge
    for side in (1, -1):
        def sx(x):
            return x if side == 1 else mx(x)
        g.path([(sx(45), 1), (sx(45.5), 4), (sx(44), 6.5), (sx(43), 8.6)], 2.1, "~", only=".f")
        for y in (8, 9, 10):
            for x in (42, 43):
                if g.get(sx(x), y) == "^":
                    g.set(sx(x), y, "v")
        g.path([(sx(42.5), 10.5), (sx(44), 14), (sx(45), 19), (sx(45.5), 25), (sx(47), 29), (sx(47.5), 33)],
               2.2, "~", only=".f,")
        for y in range(25, h):
            for x in (47, 48):
                if g.get(sx(x), y) in ("^", "%"):
                    g.set(sx(x), y, "v")
        for y in (23, 24, 25):
            for x in range(43, 48):
                if g.get(sx(x), y) == "~":
                    g.set(sx(x), y, "=")
    # terrace paths after the streams; where they cross: small plank bridges
    for pts in terrace_paths:
        g.path(pts, 2.2, ",", only=".f")
        g.path(pts, 2.2, "=", only="~")
    # mirrored props: (symbol, x, y) on the left half; the right half gets the mirror
    pairs = {
        "I": [(24, 16), (27, 21)],
        "T": [(4, 5), (8, 15), (19, 30)],
        "U": [(15, 3), (5, 21)],
        "P": [(27, 4), (14, 20)],
        "K": [(9, 3), (13, 28)],
        "o": [(16, 7), (22, 11), (23, 23), (29, 27), (6, 12), (26, 30), (17, 26)],
        "g": [(21, 15), (21, 19), (29, 25), (6, 6), (24, 3), (10, 30)],
        "Y": [(20, 6), (24, 27)],
        "O": [(30, 26), (30, 29)],
        "R": [(23, 30), (8, 30)],
        "w": [(27, 15), (29, 19)],
        "x": [(22, 11)],
        "F": [(x, 33) for x in range(26, 31)],
        "E": [(13, 25), (24, 4)],
        "b": [(28, 32)],
    }
    for c, pts in pairs.items():
        for x, y in pts:
            g.set(x, y, c)
            # the mirrored Elysians walk the mirrored route ("e" in the legend)
            # a 2-tile bench mirrors to the cell left of its twin's first cell
            g.set(mx(x) - (1 if c == "b" else 0), y, "e" if c == "E" else c)
    # on the axis: the sacred tree, the crystal, the chest before it, the bench at the edge
    single = {
        "W": [(axis, 17)],
        "C": [(axis, 22)],
        "Z": [(axis, 23)],
        # the only things that exist once, off the axis
        "j": [(41, 17)],
        "X": [(60, 30)],
        "@": [(9, 25)],
    }
    for c, pts in single.items():
        for x, y in pts:
            g.set(x, y, c)
    g.add_rails()
    return g


def tal():
    w, h = 56, 36
    g = Grid(w, h)
    # Forest canopy border with a rock face below the northern forest.
    for x in range(w):
        top = 3 + round(0.8 * math.sin(x / 3.4) + 0.5 * math.sin(x / 1.9 + 1))
        for y in range(0, top):
            g.set(x, y, "h")
        for y in range(top, top + 2):
            g.set(x, y, "^")
    for y in range(h):
        for x in (0, 1, 2, w - 3, w - 2, w - 1):
            if g.get(x, y) in ".":
                g.set(x, y, "h")
    for x in range(w):
        for y in (h - 2, h - 1):
            g.set(x, y, "h")
    # Stream from the rock face down to the south.
    g.path([(41, 5), (42, 10), (40.5, 16), (42.5, 23), (45, 29), (45, 36)], 3.0, "~", only=".")
    # Mud patches.
    g.ellipse(22, 20, 5, 2, "m", only=".", wobble=0.5, seed=1)
    g.ellipse(36, 22, 3, 1.5, "m", only=".", wobble=0.5, seed=3)
    # Paths.
    g.path([(3, 23), (10, 23), (17, 21.5), (26, 21), (34, 22), (39, 22), (47, 22), (53, 23)], 2.4, ",",
           only=".m")
    g.path([(26, 15), (26, 21)], 2.2, ",", only=".m")
    for y in (21, 22, 23):
        for x in range(41, 45):
            g.set(x, y, "=")
    # A lower terrace in the south-east: the stream drops over its edge as a waterfall.
    for x in range(34, w - 3):
        top = 26 - (1 if math.sin(x / 2.7) > 0.3 else 0)
        for y in range(top, 28):
            cell = g.get(x, y)
            if cell == ".":
                g.set(x, y, "^")
            elif cell == "~":
                g.set(x, y, "v")
    # vegetable beds in the yard, west of the house
    for y in (11, 12, 13):
        for x in range(12, 17):
            g.set(x, y, "d")
    # Puddles on and next to the path.
    for x, y in [(13, 22), (20, 21), (24, 18), (31, 22), (27, 20), (9, 23)]:
        g.set(x, y, "p")
    # Props.
    props = {
        "H": [(26, 12)],
        "F": [(x, 16) for x in range(19, 34) if x not in (21, 25, 26, 27, 31)],
        # the real world is not kept: weathered fence segments and crooked trees (Bible §12)
        "B": [(21, 16), (31, 16)],
        "C": [(6, 8), (15, 28), (52, 30), (5, 16)],
        "E": [(19, y) for y in range(10, 16)] + [(33, y) for y in range(10, 16)],
        "T": [(12, 6), (8, 30), (50, 9), (34, 30), (22, 30)],
        "P": [(9, 6), (16, 7), (47, 6), (52, 14), (4, 28), (29, 31), (49, 31), (36, 8)],
        "R": [(38, 13), (8, 12), (46, 16), (31, 27), (17, 31)],
        "g": [(8, 19), (9, 19), (15, 25), (16, 25), (30, 25), (31, 25), (35, 18), (48, 24), (10, 15), (47, 11)],
        "l": [(24, 17)],
        "K": [(31, 13), (21, 13)],
        "W": [(30, 13)],
        "b": [(22, 14)],
        "N": [(28, 14)],
        "x": [(43, 28)],
        "@": [(26, 19)],
    }
    for c, pts in props.items():
        for x, y in pts:
            g.set(x, y, c)
    g.add_rails()
    return g


def wald():
    """Forest at night: a clearing with a light beam, a rock ledge with a waterfall and
    crystals, a stream with a log bridge, glowing trees and mushrooms."""
    w, h = 56, 38
    g = Grid(w, h)
    # thick forest border with a wavy inner edge
    for x in range(w):
        top = 3 + round(1.2 * math.sin(x / 3.7) + 0.7 * math.sin(x / 1.9 + 1))
        bottom = h - 3 - round(1.0 * math.sin(x / 4.1 + 2) + 0.6 * math.sin(x / 2.2))
        for y in range(0, max(top, 2)):
            g.set(x, y, "h")
        for y in range(bottom, h):
            g.set(x, y, "h")
    for y in range(h):
        left = 3 + round(1.0 * math.sin(y / 3.3) + 0.5 * math.sin(y / 1.7))
        right = w - 4 - round(1.0 * math.sin(y / 2.9 + 1))
        for x in range(0, left):
            g.set(x, y, "h")
        for x in range(right, w):
            g.set(x, y, "h")
    # rock ledge in the north-east, stream falls over it into a pool
    for x in range(30, w - 3):
        top = 9 - (1 if math.sin(x / 2.5) > 0.2 else 0)
        for y in range(top, 11):
            g.set(x, y, "^", only=".")
    g.path([(41, 1), (41.5, 4), (40.5, 7.5)], 2.2, "~", only=".")
    for y in range(7, 11):
        for x in (39, 40, 41):
            if g.get(x, y) == "^":
                g.set(x, y, "v")
    g.ellipse(40.5, 13.5, 3.6, 2.3, "~", only=".", wobble=0.3, seed=2)
    g.path([(40, 14), (37, 18), (33, 22.5), (31, 27), (29.5, 32), (29, 38)], 2.3, "~", only=".")
    # the clearing: soft meadow with glowing flowers
    g.ellipse(17, 19, 7.5, 5.5, "f", only=".", wobble=0.25, seed=4)
    # paths
    g.path([(3, 27), (8, 26), (12, 23.5)], 2.4, ",", only=".f")
    g.path([(23, 21), (28, 22.5), (36, 23), (44, 22), (52, 21)], 2.4, ",", only=".f")
    for y in (22, 23, 24):
        for x in range(30, 35):
            g.set(x, y, "=")
    props = {
        "Z": [(17, 19)],
        "G": [(9, 12), (25, 13), (11, 29), (46, 28), (50, 14), (22, 31)],
        "T": [(6, 18), (27, 17), (36, 29), (16, 9), (44, 17)],
        "P": [(5, 7), (49, 6), (8, 33), (52, 32), (34, 14)],
        "c": [(12, 15), (22, 24), (10, 22), (44, 25), (38, 31), (13, 30)],
        "u": [(23, 15), (11, 19), (47, 30), (26, 27), (50, 17)],
        "k": [(20, 25), (24, 18), (8, 13), (37, 26), (45, 15)],
        "X": [(32, 12), (45, 11), (48, 12), (36, 11), (27, 30)],
        "n": [(7, 21), (14, 26), (26, 20), (33, 18), (41, 27), (19, 13), (30, 15), (5, 25), (48, 24),
              (16, 33), (39, 34), (24, 34)],
        "l": [(19, 28)],
        "R": [(29, 26), (42, 19), (35, 33)],
        "x": [(39, 11)],
        "@": [(5, 27)],
    }
    for c, pts in props.items():
        for x, y in pts:
            g.set(x, y, c)
    g.add_rails()
    return g


def write(which, text):
    path = os.path.join(ROOT, "content", "maps", "look_%s.txt" % which)
    with open(path, encoding="utf-8") as f:
        head = f.read()
    head = head[:head.index("[map]\n") + len("[map]\n")]
    with open(path, "w", encoding="utf-8") as f:
        f.write(head + text + "\n")
    print("wrote [map] block of", os.path.relpath(path, ROOT))


if __name__ == "__main__":
    which = sys.argv[1]
    makers = {"elysia": elysia, "tal": tal, "wald": wald}
    if which not in makers:
        sys.exit("usage: layout_look_maps.py elysia|tal|wald [--write]")
    grid = makers[which]()
    if "--write" in sys.argv:
        write(which, grid.text())
    else:
        print(grid.text())
