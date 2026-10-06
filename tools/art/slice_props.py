"""Props for the vertical slice (Phase 4, docs/PHASE4_PLAN.md), drawn in the same way as
make_sprites.py and registered in the same catalog. Called from make_sprites.build().
"""
import numpy as np

import pixelart as pa
from pixelart import ramp


def feast_table(ms):
    """Elysia's host table: white marble, a gold rim, a steaming tureen, fruit in gold bowls.
    Everything perfect and arranged symmetrically."""
    st, ex = pa.STYLES["elysia"], ms.EXTRA["elysia"]
    c = ms.Canvas(44, 30)
    top = c.rect(2, 12, 42, 20)
    c.paint(top, st["marble"], 0.55 + 0.35 * (c.yy < 14), contrast=2.2, dither=False)
    c.paint(c.rect(2, 20, 42, 23), st["marble"], 0.25, dither=False)
    c.paint(c.rect(2, 19, 42, 20), ramp("#8a6418", "#c8962c", "#f0c850", "#fff0a0"), 0.7, dither=False)
    for x0 in (5, 36):
        c.paint(c.rect(x0, 23, x0 + 3, 29), st["marble"], np.where(c.xx == x0, 0.75, 0.35), dither=False)
    gold = ramp("#7a5a14", "#b8862a", "#e8b844", "#fff0a0")
    # tureen in the middle, steam above
    pot = c.ellipse(22, 11, 6, 4.5) & (c.yy >= 8)
    c.paint(pot, gold, 0.3 + 0.65 * c.sphere(20, 9, 7, 5), dither=False)
    c.paint(c.rect(17, 7, 27, 9), gold, 0.85, dither=False)
    for x in (19, 22, 25):
        c.fill(c.rect(x, 3 + (x % 2), x + 1, 6), np.array([235, 235, 245], np.float32))
    # two fruit bowls, mirrored
    fruit = [ramp("#7a1a2a", "#c03040", "#f06070", "#ffc0c8"), ramp("#6a5010", "#c09018", "#f0d040", "#fff6b0"),
             ramp("#3a1a5a", "#6a3a9a", "#a070d0", "#e0c8ff")]
    for cx in (10, 34):
        c.paint(c.ellipse(cx, 13, 5, 2.2) & (c.yy >= 12), gold, 0.55, dither=False)
        for k, (dx, dy) in enumerate(((-2, 10.5), (1, 10), (3, 11.5), (0, 8.5))):
            m = c.ellipse(cx + dx, dy, 1.8, 1.8)
            c.paint(m, fruit[k % 3], 0.35 + 0.6 * c.sphere(cx + dx - 0.5, dy - 0.5, 2.2, 2.2), dither=False)
    c.outline(st["outline"])
    return c


def build(ms):
    ms.save("elysia", "feast_table", feast_table(ms), (22, 26),
            shape={"rect": [38, 8], "offset": [0, -6]}, shadow=[22, 5])
