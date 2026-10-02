#!/usr/bin/env python3
"""Layout helper for the look-prototype maps (ADR-017).

Draws the [map] block of content/maps/look_elysia.txt and look_tal.txt from shapes
(curved paths, round ponds, wavy cliff edges), which is tedious to type by hand.
The map files stay the source of truth and can be edited directly; running this with
--write replaces their [map] block, so hand edits inside it are lost.

Usage: python3 tools/art/layout_look_maps.py elysia|tal [--write]
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
    w, h = 64, 40
    g = Grid(w, h)
    # Cliff edge: wavy line with a promontory (overlook) in the south-east.
    edge = []
    for x in range(w):
        e = 31 + round(0.8 * math.sin(x / 4.0) + 0.6 * math.sin(x / 2.3 + 1))
        if 37 <= x <= 51:
            e = 34 if 39 <= x <= 49 else 33
        edge.append(e)
    for x in range(w):
        for y in range(edge[x], h):
            g.set(x, y, "^" if y < edge[x] + 3 else "%")
    # Hedge border north and sides (until the cliff).
    for x in range(w):
        bottom = 3 + round(0.9 * math.sin(x / 3.1) + 0.5 * math.sin(x / 1.7 + 2))
        for y in range(0, bottom):
            g.set(x, y, "h")
    for y in range(h):
        for x in (0, 1, w - 2, w - 1):
            if g.get(x, y) == ".":
                g.set(x, y, "h")
    # Meadows (dense small flowers).
    g.ellipse(10, 8, 5, 3, "f", only=".", wobble=0.4, seed=1)
    g.ellipse(31, 27, 4, 2.5, "f", only=".", wobble=0.4, seed=2)
    g.ellipse(56, 23, 3.5, 3, "f", only=".", wobble=0.4, seed=3)
    g.ellipse(8, 27, 3.5, 2.5, "f", only=".", wobble=0.4, seed=4)
    g.ellipse(33, 6, 4, 2, "f", only=".", wobble=0.4, seed=5)
    # Pond with a wooden bridge.
    g.ellipse(44, 12, 8.2, 5.4, "~", only=".f", wobble=0.25, seed=0.7)
    # Paths.
    g.path([(3, 20), (9, 20), (14, 18.5), (17.5, 17.5)], 2.6, ",", only=".f")
    g.path([(26.5, 15.5), (31, 13.5), (35, 12.5)], 2.4, ",", only=".f")
    g.path([(53, 12.5), (55, 15), (52, 21), (46, 26), (44.5, 32)], 2.4, ",", only=".f")
    for y in (12, 13):
        for x in range(33, 56):
            if g.get(x, y) == "~":
                g.set(x, y, "=")
            elif g.get(x, y) in ".f":
                g.set(x, y, ",")
    # Plaza.
    g.ellipse(22, 16.5, 4.4, 3.6, "_", only=".f,")
    # Props (decor and furniture).
    props = {
        "U": [(22, 16)],
        "T": [(5, 5), (13, 4), (25, 4), (39, 4), (57, 6), (4, 13), (59, 15), (3, 24), (59, 28), (19, 27), (36, 22)],
        "Y": [(15, 11), (29, 11), (14, 23), (29, 21), (53, 19), (9, 9), (35, 27), (57, 24)],
        "O": [(17, 13), (27, 13), (17, 20), (27, 20)],
        "R": [(35, 29), (53, 30), (25, 30), (10, 30)],
        "l": [(16, 16), (34, 11), (56, 14), (42, 31)],
        "w": [(40, 9), (47, 15), (49, 10), (39, 15), (45, 8)],
        "b": [(21, 21), (43, 33)],
        "F": [(x, 33) for x in range(38, 51) if x not in (43, 44, 45)],
        "@": [(14, 19)],
    }
    for c, pts in props.items():
        for x, y in pts:
            g.set(x, y, c)
    edge_water = [(x, y) for y in range(h) for x in range(w) if g.get(x, y) == "~"
                  and any(g.get(x + dx, y + dy) in (".", "f") for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))]
    for i, (x, y) in enumerate(edge_water):
        if i % 5 == 2:
            g.set(x, y, "r")
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
    # Puddles on and next to the path.
    for x, y in [(13, 22), (20, 21), (24, 18), (31, 22), (27, 20), (9, 23)]:
        g.set(x, y, "p")
    # Props.
    props = {
        "H": [(26, 12)],
        "F": [(x, 16) for x in range(19, 34) if x not in (25, 26, 27)],
        "E": [(19, y) for y in range(10, 16)] + [(33, y) for y in range(10, 16)],
        "T": [(6, 8), (12, 6), (15, 28), (8, 30), (50, 9), (52, 27), (34, 29), (22, 30), (5, 16)],
        "P": [(9, 6), (16, 7), (47, 6), (52, 14), (4, 28), (29, 31), (49, 31), (36, 8)],
        "R": [(38, 13), (11, 15), (46, 16), (31, 27), (17, 31)],
        "g": [(8, 19), (9, 19), (15, 25), (16, 25), (30, 25), (31, 25), (35, 18), (48, 26), (12, 12), (44, 11)],
        "l": [(24, 17)],
        "K": [(31, 13), (21, 13)],
        "W": [(30, 13)],
        "b": [(22, 14)],
        "@": [(26, 19)],
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
    if which not in ("elysia", "tal"):
        sys.exit("usage: layout_look_maps.py elysia|tal [--write]")
    grid = elysia() if which == "elysia" else tal()
    if "--write" in sys.argv:
        write(which, grid.text())
    else:
        print(grid.text())
