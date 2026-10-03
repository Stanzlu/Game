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

    def text(self):
        return "\n".join("".join(r) for r in self.g)


def elysia():
    """Sacred tree in a symmetric marble pool, a terrace with stairs and a waterfall into the
    pool, a stream that falls off the island edge into the clouds."""
    w, h = 64, 40
    g = Grid(w, h)
    # island edge in the south: wavy cliff, then sky
    edge = []
    for x in range(w):
        e = 32 + round(0.8 * math.sin(x / 4.0) + 0.6 * math.sin(x / 2.3 + 1))
        if 27 <= x <= 37:
            e = 34
        edge.append(e)
    for x in range(w):
        for y in range(edge[x], h):
            g.set(x, y, "^" if y < edge[x] + 3 else "%")
    # hedge border north and sides
    for x in range(w):
        bottom = 2 + round(0.6 * math.sin(x / 3.1) + 0.4 * math.sin(x / 1.7 + 2))
        for y in range(0, bottom):
            g.set(x, y, "h")
    for y in range(h):
        for x in (0, 1, w - 2, w - 1):
            if g.get(x, y) == ".":
                g.set(x, y, "h")
    # terrace: cliff face below it, stairs on the west side
    for x in range(2, w - 2):
        top = 9 - (1 if math.sin(x / 3.3) + 0.5 * math.sin(x / 1.6) > 0.6 else 0)
        for y in range(top, 11):
            g.set(x, y, "^", only=".")
    for x in (11, 12, 13):
        for y in (8, 9, 10):
            if g.get(x, y) == "^" or y == 10:
                g.set(x, y, "s")
    # meadows
    g.ellipse(7, 5, 4, 2, "f", only=".", wobble=0.4, seed=1)
    g.ellipse(55, 5, 4, 2, "f", only=".", wobble=0.4, seed=2)
    g.ellipse(9, 28, 4, 2.5, "f", only=".", wobble=0.4, seed=3)
    g.ellipse(56, 27, 3.5, 2.5, "f", only=".", wobble=0.4, seed=4)
    g.ellipse(20, 14, 2.5, 1.5, "f", only=".", wobble=0.4, seed=5)
    g.ellipse(45, 13, 2.5, 1.5, "f", only=".", wobble=0.4, seed=6)
    # marble ring and front platform, then the pool inside
    g.ellipse(32, 16.5, 8.4, 5.9, "M", only=".f")
    for y in (21, 22, 23):
        for x in range(27, 38):
            g.set(x, y, "M", only=".f")
    g.ellipse(32, 16.5, 6.3, 4.2, "~", only="M")
    # terrace stream and waterfall into the pool
    g.path([(45, 1), (45.5, 4), (44, 6.5), (43, 8.6)], 2.1, "~", only=".f")
    for y in (8, 9, 10):
        for x in (42, 43):
            if g.get(x, y) == "^":
                g.set(x, y, "v")

    # paths
    g.path([(3, 26), (10, 26), (18, 25), (26, 23.5)], 2.6, ",", only=".f")
    g.path([(38, 23.5), (46, 24), (54, 25), (61, 25)], 2.6, ",", only=".f")
    g.path([(32, 24), (32, 28), (32, 32)], 2.4, ",", only=".f")
    g.path([(12, 9), (12, 7), (14, 5), (22, 4)], 2.2, ",", only=".f")
    # stream from the pool to the island edge, falling into the sky
    # the waterfall's stream runs past the pool (which stays a closed, symmetric ring)
    g.path([(42.5, 10.5), (44, 14), (45, 19), (45.5, 25), (47, 29), (47.5, 33)], 2.2, "~", only=".f,")
    for y in range(25, h):
        if g.get(47, y) in ("^", "%"):
            g.set(47, y, "v")
            g.set(48, y, "v")
    for y in (23, 24, 25):
        for x in range(43, 48):
            if g.get(x, y) == "~":
                g.set(x, y, "=")
    # props: the sacred tree in the middle, symmetric pillars, crystal in front
    props = {
        "W": [(32, 17)],
        "I": [(24, 16), (40, 16), (27, 21), (37, 21)],
        "C": [(32, 22)],
        "T": [(4, 5), (47, 4), (8, 15), (57, 19), (19, 30)],
        "U": [(18, 4), (60, 7), (53, 14), (5, 21)],
        "P": [(27, 4), (14, 20), (59, 29), (42, 29)],
        "K": [(9, 3), (57, 4), (50, 20), (13, 28)],
        "o": [(16, 7), (31, 6), (48, 6), (22, 11), (46, 12), (23, 23), (41, 23), (29, 27), (35, 27),
              (6, 12), (58, 11), (26, 30), (38, 30), (52, 31), (17, 25)],
        "g": [(21, 15), (42, 15), (21, 19), (42, 19), (29, 25), (35, 25), (6, 6), (54, 6), (24, 3),
              (40, 4), (10, 30), (55, 28)],
        "Y": [(20, 6), (51, 8), (24, 27), (52, 26)],
        "O": [(30, 26), (34, 26), (30, 29), (34, 29)],
        "R": [(23, 30), (41, 31), (8, 30), (55, 30)],
        "w": [(27, 15), (36, 18), (29, 19), (35, 14)],
        "b": [(31, 33)],
        "F": [(x, 33) for x in range(26, 38) if x not in (31, 32)],
        "x": [(42, 11)],
        "@": [(10, 26)],
    }
    for c, pts in props.items():
        for x, y in pts:
            g.set(x, y, c)
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
    # Puddles on and next to the path.
    for x, y in [(13, 22), (20, 21), (24, 18), (31, 22), (27, 20), (9, 23)]:
        g.set(x, y, "p")
    # Props.
    props = {
        "H": [(26, 12)],
        "F": [(x, 16) for x in range(19, 34) if x not in (25, 26, 27)],
        "E": [(19, y) for y in range(10, 16)] + [(33, y) for y in range(10, 16)],
        "T": [(6, 8), (12, 6), (15, 28), (8, 30), (50, 9), (52, 30), (34, 30), (22, 30), (5, 16)],
        "P": [(9, 6), (16, 7), (47, 6), (52, 14), (4, 28), (29, 31), (49, 31), (36, 8)],
        "R": [(38, 13), (11, 15), (46, 16), (31, 27), (17, 31)],
        "g": [(8, 19), (9, 19), (15, 25), (16, 25), (30, 25), (31, 25), (35, 18), (48, 24), (12, 12), (47, 11)],
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
