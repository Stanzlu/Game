"""Props for Act I (docs/akt1/REGIONSBRIEFE.md), drawn like make_sprites.py and registered in the same
catalog. Called from make_sprites.build(); `--preview out.png` draws them on one sheet (3x) to look at.

Elysia's rooms are as perfect as its garden: white plaster and marble, gold trim, teal tiles, light from
everywhere, and everything exists twice, once on each side of the middle (ADR-031).
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp

GOLD = ramp("#7a5a14", "#b8862a", "#e8b844", "#fff0a0", "#fffbe0")
TILE = ramp("#1b5560", "#2a7f86", "#46aaa6", "#7fd2bf", "#c4f1de")
PLASTER = ramp("#8d87a8", "#b8b3cb", "#dcd8e6", "#f1eff6", "#ffffff")
FLOOR = ramp("#9d98b6", "#c3bfd3", "#e3e0ec", "#f6f5fa", "#ffffff")
WARM_GLASS = ramp("#c9822a", "#f2b44a", "#ffd97a", "#fff1b8", "#fffbe8")
TIMBER = ramp("#6b4a3a", "#8d6a50", "#b08a66", "#d2ad82", "#ecd2a6")
BREAD = ramp("#7a4a1c", "#b0762e", "#d6a04c", "#f0cc78")
SHEET = ramp("#b9b2d8", "#dcd7ef", "#f4f1fb", "#ffffff")
BLANKET = ramp("#1f6a72", "#35959a", "#62c0b6", "#a8e6d2")
PINK = ramp("#9e5288", "#cf7fae", "#ecaccb", "#fbd5e5")
LEAF = ramp("#164a30", "#24703a", "#3f9a44", "#7cc653")

PX = 16  # one map cell
# Pixel columns inside the inn's shell (41 cells wide, symmetric about cell 20): everything on the left is mirrored.
AXIS_X = 20 * PX + 8
WINDOW_X = (12 * PX + 8, 28 * PX + 8)
SHELF_X = (16 * PX + 8, 24 * PX + 8)
DOOR_X = (18 * PX + 8, 22 * PX + 8)
HEARTH_X = (9 * PX + 8, 31 * PX + 8)


def _plaster(c, mask, top, height, seed=1):
    """Smooth white plaster, lit from above, with a very faint panel pattern."""
    t = np.clip((c.yy - top) / max(height, 1), 0, 1)
    c.paint(mask, PLASTER, 0.9 - 0.35 * t, contrast=1.6, dither=False)


def _trim(c, x0, y0, x1, y1, bright=0.7):
    c.paint(c.rect(x0, y0, x1, y1), GOLD, np.where(c.yy < y0 + 1, bright + 0.2, bright - 0.15), dither=False)


def inn_front(ms):
    """The Gasthaus zum Immer from the garden: 9 cells wide, 4 high, the door in the middle (cell 4).
    Symmetric to the pixel; the sign over the door is a sideways eight, the sign of always."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(144, 60)
    cx = 72
    # wall
    wall = c.rect(6, 22, 138, 56)
    _plaster(c, wall, 22, 34)
    for x in range(6, 138, 22):
        c.paint(c.rect(x, 24, x + 1, 54), PLASTER, 0.45, dither=False)
    # stone base
    c.paint(c.rect(4, 52, 140, 58), st["marble"], np.where(c.yy < 53, 0.85, 0.45), contrast=2.0, dither=False)
    # roof: teal tiles in staggered rows, a hipped front (narrower at the top)
    inset = np.clip((22 - c.yy) * 0.9, 0, 18)
    roof = c.rect(0, 2, 144, 25) & (c.xx >= inset) & (c.xx < 144 - inset)
    row = ((c.yy - 2) // 4).astype(int)
    stagger = ((c.xx + (row % 2) * 3) // 6).astype(int)
    shade = ((row * 7 + stagger * 13) % 5) / 5.0
    v = 0.8 - 0.4 * (c.yy - 2) / 23.0 + 0.1 * (shade - 0.5)
    v = np.where(((c.yy - 2) % 4) == 3, v - 0.28, v)
    v = np.where((((c.xx + (row % 2) * 3) % 6) == 5), v - 0.2, v)
    c.paint(roof, TILE, v, contrast=2.0, dither=False)
    _trim(c, 0, 24, 144, 27)
    # ridge and the finial: a golden sun
    c.paint(c.rect(14, 1, 130, 4), GOLD, np.where(c.yy < 2, 0.85, 0.5), dither=False)
    c.paint(c.ellipse(cx, 3, 4.5, 4.5), GOLD, 0.35 + 0.65 * c.sphere(cx - 1, 2, 5, 5), dither=False)
    # windows: round arches with warm light, a golden frame, a flower box
    for wx in (22, 104):
        frame = c.rect(wx - 2, 32, wx + 20, 52) & ((c.yy >= 36) | c.ellipse(wx + 9, 36, 11, 5))
        c.paint(frame, GOLD, 0.6, dither=False)
        pane = c.rect(wx, 34, wx + 18, 50) & ((c.yy >= 37) | c.ellipse(wx + 9, 37, 9, 4))
        c.paint(pane, WARM_GLASS, 0.5 + 0.5 * c.sphere(wx + 6, 40, 14, 14), dither=True, contrast=2.2)
        c.paint(c.rect(wx + 8, 34, wx + 10, 50), GOLD, 0.55, dither=False)
        c.paint(c.rect(wx, 42, wx + 18, 44), GOLD, 0.55, dither=False)
        c.paint(c.rect(wx - 3, 50, wx + 21, 53), TIMBER, np.where(c.yy < 51, 0.75, 0.4), dither=False)
        for k in range(6):
            fx = wx - 1 + k * 4
            c.paint(c.rect(fx, 47, fx + 3, 50), PINK if k % 2 == 0 else SHEET, 0.7, dither=False)
            c.fill(c.rect(fx + 1, 49, fx + 2, 51), LEAF[2])
    # the door: an arch in warm wood with a golden ring, two steps
    door = c.rect(cx - 9, 36, cx + 9, 57) & ((c.yy >= 41) | c.ellipse(cx, 41, 9, 6))
    c.paint(door, GOLD, 0.55, dither=False)
    inner = c.rect(cx - 7, 38, cx + 7, 57) & ((c.yy >= 41) | c.ellipse(cx, 41, 7, 4))
    c.paint(inner, TIMBER, np.where(((c.xx - (cx - 7)) % 5) == 4, 0.25, 0.62 - 0.2 * (c.yy - 38) / 19.0), dither=False)
    c.fill(c.rect(cx - 1, 38, cx + 1, 57), np.array([60, 40, 30], np.float32))  # the seam of the two leaves
    for hx in (cx - 4, cx + 3):
        c.fill(c.ellipse(hx, 49, 1.6, 1.6), GOLD[3])
    c.paint(c.rect(cx - 12, 56, cx + 12, 58), st["marble"], 0.8, dither=False)
    c.paint(c.rect(cx - 15, 58, cx + 15, 60), st["marble"], 0.6, dither=False)
    # the sign: a hanging board with a sideways eight
    c.paint(c.rect(cx - 12, 28, cx + 12, 35), TIMBER, 0.62, dither=False)
    c.paint(c.rect(cx - 12, 28, cx + 12, 29), GOLD, 0.8, dither=False)
    for ex_ in (cx - 6, cx + 6):
        ring = c.ellipse(ex_, 32, 5, 2.6) & ~c.ellipse(ex_, 32, 2.6, 1.0)
        c.paint(ring, GOLD, 0.9, dither=False)
    # lanterns at the door
    for lx in (cx - 17, cx + 17):
        c.paint(c.rect(lx - 2, 40, lx + 3, 48), WARM_GLASS, 0.85, dither=False)
        c.paint(c.rect(lx - 3, 39, lx + 4, 40), GOLD, 0.6, dither=False)
        c.paint(c.rect(lx - 3, 48, lx + 4, 49), GOLD, 0.6, dither=False)
    c.outline(st["outline"])
    return c


def inn_shell(ms):
    """The hall and the two rooms seen from above and the front, 41 x 16 cells from map cell (0, 4).
    Back wall (rows 5-7) with the shelves, the clock, two windows and two doors; side walls; front wall
    (row 18) with the open door; the walls of the rooms. The floor is baked from the map."""
    st = pa.STYLES["elysia"]
    W, H = 41 * PX, 16 * PX
    c = ms.Canvas(W, H)

    def cell(x, y):  # top-left of a map cell inside the sprite
        return x * PX, (y - 4) * PX

    # 1. the walls around the hall: back wall face (rows 5-7), side walls (columns 6 and 34), front (row 18)
    bx0, by0 = cell(6, 5)
    bx1, by1 = cell(35, 8)
    back = c.rect(bx0, by0, bx1, by1)
    _plaster(c, back, by0, by1 - by0)
    c.paint(c.rect(bx0, by1 - 3, bx1, by1), PLASTER, 0.25, dither=False)  # the skirting where it meets the floor
    _trim(c, bx0, by0, bx1, by0 + 3, 0.75)  # the cornice
    _trim(c, bx0, by1 - 5, bx1, by1 - 3, 0.6)
    # pilasters between the things on the wall
    for px_cell in (6, 34):
        x, _ = cell(px_cell, 5)
        c.paint(c.rect(x, by0 + 3, x + 6, by1 - 3), PLASTER, 0.55 + 0.3 * (c.xx == x), dither=False)
    # 2. two round-headed windows with warm light and the garden behind them (centred on cells 12 and 28)
    for wcx in WINDOW_X:
        x, y = wcx - 14, by0 + 2
        w, h = 28, 36
        arch = c.rect(x - 3, y + 4, x + w + 3, y + h + 2) & ((c.yy >= y + 16) | c.ellipse(x + w / 2, y + 16, w / 2 + 3, 12))
        c.paint(arch, GOLD, 0.6, dither=False)
        pane = c.rect(x, y + 7, x + w, y + h) & ((c.yy >= y + 16) | c.ellipse(x + w / 2, y + 16, w / 2, 9))
        garden = 0.35 + 0.65 * (1 - (c.yy - y) / h)
        c.paint(pane, WARM_GLASS, garden, dither=True, contrast=2.0)
        c.paint(c.rect(x + w // 2 - 1, y + 7, x + w // 2 + 1, y + h), GOLD, 0.55, dither=False)
        c.paint(c.rect(x, y + 22, x + w, y + 24), GOLD, 0.55, dither=False)
        c.paint(c.rect(x - 4, y + h, x + w + 4, y + h + 3), GOLD, np.where(c.yy < y + h + 1, 0.85, 0.45), dither=False)
    # 3. behind the bar: shelves with glasses, two shut doors and, between them, the clock
    for sx in SHELF_X:
        for row in range(2):
            sy = by0 + 17 + row * 13
            c.paint(c.rect(sx - 20, sy, sx + 20, sy + 2), TIMBER, 0.7, dither=False)
            for g in range(7):
                gx = sx - 19 + g * 6
                c.paint(c.rect(gx, sy - 7, gx + 4, sy), WARM_GLASS if (g + row) % 2 == 0 else TILE, 0.75, dither=False)
    for dcx in DOOR_X:
        x, y = dcx - 7, by0 + 12
        c.paint(c.rect(x - 1, y - 2, x + 15, by1 - 3), GOLD, 0.55, dither=False)
        c.paint(c.rect(x + 1, y, x + 13, by1 - 3), TIMBER, np.where(((c.xx - x) % 4) == 3, 0.3, 0.6), dither=False)
        c.fill(c.ellipse(x + 10, y + 13, 1.2, 1.2), GOLD[3])
    cx_, cy_ = AXIS_X, by0 + 17
    c.paint(c.ellipse(cx_, cy_, 10, 10), GOLD, 0.35 + 0.6 * c.sphere(cx_ - 2, cy_ - 2, 11, 11), dither=False)
    c.paint(c.ellipse(cx_, cy_, 7.5, 7.5), PLASTER, 0.95, dither=False)
    c.paint(c.rect(cx_ - 4, cy_ - 1, cx_ + 5, cy_ + 1), GOLD, 0.5, dither=False)
    # 4. side walls (the wall columns 6 and 34 between row 8 and the front wall, with the door gaps at row 13)
    for col in (6, 34):
        x, y0 = cell(col, 8)
        _, y1 = cell(col, 18)
        _, g0 = cell(col, 12)
        _, g1 = cell(col, 14)
        for a, b in ((y0, g0), (g1, y1)):
            c.paint(c.rect(x, a, x + PX, b), PLASTER, np.where(c.xx < x + 3, 0.85, 0.55), dither=False)
        _trim(c, x, y0, x + PX, y0 + 2, 0.7)
        _trim(c, x, g0 - 2, x + PX, g0, 0.7)
        _trim(c, x, g1, x + PX, g1 + 2, 0.7)
    # 5. front wall (row 18) with the open door at 20
    fx0, fy0 = cell(6, 18)
    fx1, fy1 = cell(35, 19)
    c.paint(c.rect(fx0, fy0, fx1, fy1), PLASTER, np.where(c.yy < fy0 + 4, 0.35, 0.8), dither=False)
    dx, _ = cell(20, 18)
    c.paint(c.rect(dx - 8, fy0 - 2, dx + 24, fy1), GOLD, 0.5, dither=False)
    c.paint(c.rect(dx - 5, fy0, dx + 21, fy1), FLOOR, 0.55, dither=False)
    # 6. the rooms: the back wall face (rows 9-10) and the outer walls, one on each side, twins
    for x0c, x1c in ((0, 6), (35, 41)):
        rx0, ry0 = cell(x0c, 9)
        rx1, ry1 = cell(x1c, 11)
        c.paint(c.rect(rx0, ry0, rx1, ry1), PLASTER, 0.85 - 0.3 * (c.yy - ry0) / (ry1 - ry0), dither=False)
        _trim(c, rx0, ry0, rx1, ry0 + 2, 0.7)
        c.paint(c.rect(rx0, ry1 - 2, rx1, ry1), PLASTER, 0.25, dither=False)
        # a small round window in each room
        wx = (rx0 + rx1) // 2
        c.paint(c.ellipse(wx, ry0 + 15, 9, 9), GOLD, 0.6, dither=False)
        c.paint(c.ellipse(wx, ry0 + 15, 7, 7), WARM_GLASS, 0.5 + 0.5 * c.sphere(wx - 2, ry0 + 12, 9, 9), dither=True)
        c.paint(c.rect(wx - 1, ry0 + 8, wx + 1, ry0 + 22), GOLD, 0.55, dither=False)
        # the wall above the room's door gap and the lower wall (row 15)
        lx0, ly0 = cell(x0c, 15)
        lx1, ly1 = cell(x1c, 16)
        c.paint(c.rect(lx0, ly0, lx1, ly1), PLASTER, np.where(c.yy < ly0 + 3, 0.35, 0.7), dither=False)
    for col in (0, 40):
        x, y0 = cell(col, 9)
        _, y1 = cell(col, 16)
        c.paint(c.rect(x, y0, x + PX, y1), PLASTER, 0.6, dither=False)
    c.outline(st["outline"])
    return c


def inn_bar(ms):
    """The counter: 11 cells long, white marble with a gold rail, polished; nothing stands on it."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(11 * PX, 30)
    top = c.rect(2, 4, 11 * PX - 2, 12)
    c.paint(top, st["marble"], 0.95 - 0.25 * (c.yy - 4) / 8, dither=False)
    c.paint(c.rect(0, 12, 11 * PX, 26), PLASTER, np.where(c.xx % 22 < 2, 0.4, 0.7), dither=False)
    _trim(c, 0, 12, 11 * PX, 14, 0.8)
    _trim(c, 0, 24, 11 * PX, 26, 0.55)
    c.paint(c.rect(0, 4, 11 * PX, 5), GOLD, 0.9, dither=False)
    c.outline(st["outline"])
    return c


def inn_table(ms):
    """A round table for two: marble top, a gold edge, a basket of bread, two stools. 40 x 34."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(40, 34)
    for sx in (5, 35):
        c.paint(c.ellipse(sx, 26, 5, 3.2), TIMBER, 0.55, dither=False)
        c.paint(c.ellipse(sx, 24.5, 5, 3.2), PINK, 0.55 + 0.4 * c.sphere(sx - 1, 23, 6, 4), dither=False)
        c.paint(c.rect(sx - 1, 27, sx + 1, 32), st["wood"], 0.4, dither=False)
    c.paint(c.rect(18, 20, 22, 32), st["marble"], np.where(c.xx < 20, 0.7, 0.4), dither=False)
    c.paint(c.ellipse(20, 31, 7, 2.2), st["marble"], 0.45, dither=False)
    top = c.ellipse(20, 15, 15, 7.5)
    c.paint(top, st["marble"], 0.55 + 0.4 * c.sphere(17, 12, 16, 8), contrast=2.0, dither=False)
    c.paint(top & ~c.ellipse(20, 14, 14, 6.5), GOLD, 0.75, dither=False)
    basket = c.ellipse(20, 14, 6, 3) & (c.yy >= 12)
    c.paint(basket, TIMBER, 0.55 + 0.3 * c.sphere(18, 13, 7, 4), dither=False)
    for bx in (17, 20, 23):
        c.paint(c.ellipse(bx, 11.5, 2.6, 1.8), BREAD, 0.5 + 0.45 * c.sphere(bx - 1, 11, 3, 2.2), dither=False)
    c.outline(st["outline"])
    return c


def inn_hearth(ms, frame=0):
    """A fire that has burnt since the house was built, in a marble hearth with a golden mantel.
    Returns (sprite, glow). The flames are the same on both sides and in every frame but the
    breathing of the light."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(48, 44)
    glow = ms.Canvas(48, 44)
    c.paint(c.rect(2, 4, 46, 12), st["marble"], 0.9, dither=False)
    _trim(c, 0, 3, 48, 6, 0.85)
    c.paint(c.rect(4, 12, 44, 42), st["marble"], np.where(c.xx < 8, 0.85, 0.6), dither=False)
    c.paint(c.rect(11, 18, 37, 42), ramp("#241c36", "#3a2e52"), 0.2, dither=False)
    # the fire: three flames, the middle the tallest
    shapes = [(24, 36, 8, 15 + (frame % 2)), (16, 37, 5, 8 + (frame % 3 == 1)), (32, 37, 5, 8 + (frame % 3 == 2))]
    for fx, fy, fw, fh in shapes:
        flame = c.ellipse(fx, fy, fw * 0.6, fh * 0.55) & (c.yy <= 40)
        t = np.clip((fy + fh * 0.55 - c.yy) / (fh * 1.1), 0, 1)
        c.paint(flame, ramp("#b8321c", "#f0701e", "#ffb83c", "#fff2a0"), 0.25 + 0.7 * t, dither=False)
        glow.paint(flame, ramp("#b8321c", "#f0701e", "#ffb83c", "#fff2a0"), 0.25 + 0.7 * t, dither=False)
    c.paint(c.rect(10, 40, 38, 43), GOLD, 0.4, dither=False)  # the iron grate below
    c.outline(st["outline"])
    return c, glow


def inn_bed(ms):
    """The bed in each room: a pillow in the middle, white linen, a teal blanket with a gold stripe,
    folded back to a line. 32 x 40, the head to the north."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(32, 40)
    c.paint(c.rect(1, 3, 31, 39), st["wood"], np.where(c.xx < 4, 0.8, 0.45), dither=False)  # the frame
    c.paint(c.rect(4, 6, 28, 37), SHEET, 0.95 - 0.2 * (c.yy - 6) / 31, dither=False)
    blanket = c.rect(4, 19, 28, 37)
    c.paint(blanket, BLANKET, 0.5 + 0.35 * (np.sin((c.xx - 4) * 0.5) * 0.5 + 0.5) * (1 - (c.yy - 19) / 36), dither=False)
    c.paint(c.rect(4, 27, 28, 29), GOLD, 0.7, dither=False)
    c.paint(c.rect(4, 19, 28, 22), SHEET, 1.0, dither=False)  # the fold
    c.paint(c.rect(4, 22, 28, 23), SHEET, 0.5, dither=False)
    for px_ in (6, 20):
        c.paint(c.ellipse(px_ + 3, 13, 5.5, 4.2), SHEET, 0.55 + 0.45 * c.sphere(px_ + 1, 11, 6.5, 5), dither=False)
    c.paint(c.rect(1, 0, 31, 5), st["wood"], np.where(c.yy < 2, 0.9, 0.6), dither=False)  # headboard
    c.paint(c.rect(1, 37, 31, 40), st["wood"], 0.5, dither=False)  # footboard
    c.outline(st["outline"])
    return c


def inn_door(ms):
    """A shut room door in the side wall: golden frame, wood, a ring for a handle. 16 x 32 (one cell wide, two high)."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(16, 32)
    c.paint(c.rect(0, 0, 16, 32), GOLD, 0.55, dither=False)
    c.paint(c.rect(2, 2, 14, 32), TIMBER, np.where(((c.yy - 2) % 6) == 5, 0.3, 0.6 - 0.2 * (c.xx - 2) / 12), dither=False)
    c.fill(c.ellipse(11, 19, 1.5, 1.5), GOLD[3])
    c.outline(st["outline"])
    return c


def guest_book(ms):
    """A lectern with the open guest book. 20 x 30."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(20, 30)
    c.paint(c.rect(8, 14, 12, 28), TIMBER, np.where(c.xx < 10, 0.7, 0.4), dither=False)
    c.paint(c.rect(4, 27, 16, 30), st["marble"], 0.6, dither=False)
    c.paint(c.rect(1, 6, 19, 15), GOLD, 0.55, dither=False)
    c.paint(c.rect(2, 3, 10, 13), SHEET, 0.95, dither=False)
    c.paint(c.rect(10, 3, 18, 13), SHEET, 0.8, dither=False)
    for y in (5, 7, 9, 11):
        c.paint(c.rect(3, y, 9, y + 1), TILE, 0.35, dither=False)
        c.paint(c.rect(11, y, 17, y + 1), TILE, 0.35, dither=False)
    c.outline(st["outline"])
    return c


def build(ms):
    ms.save("elysia", "inn_front", inn_front(ms), (72, 54))
    ms.save("elysia", "inn_shell", inn_shell(ms), (AXIS_X, 8), flat=True,
            lights=[{"offset": [wx - AXIS_X, 44 - 8], "color": "#ffd890", "energy": 0.5, "range": 120} for wx in WINDOW_X])
    ms.save("elysia", "inn_bar", inn_bar(ms), (88, 16), shape={"rect": [176, 6], "offset": [0, -6]}, shadow=[84, 4])
    ms.save("elysia", "inn_table", inn_table(ms), (20, 28), shape={"rect": [30, 10], "offset": [0, -6]}, shadow=[16, 4])
    frames = [inn_hearth(ms, f) for f in range(3)]
    ms.save("elysia", "inn_hearth", [f[0] for f in frames], (24, 40), emissive=[f[1] for f in frames],
            shape={"rect": [44, 8], "offset": [0, -4]}, flicker=True,
            lights=[{"offset": [0, -10], "color": "#ffb060", "energy": 1.1, "range": 110}])
    ms.save("elysia", "inn_bed", inn_bed(ms), (16, 30), shape={"rect": [30, 32], "offset": [0, -14]})
    ms.save("elysia", "inn_door", inn_door(ms), (8, 24), shape={"rect": [16, 32], "offset": [0, -8]})
    ms.save("elysia", "guest_book", guest_book(ms), (10, 26), shape={"circle": 4, "offset": [0, -2]}, shadow=[8, 2])


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [inn_front(ms), inn_bar(ms), inn_table(ms), inn_hearth(ms, 0)[0], inn_bed(ms), inn_door(ms), guest_book(ms)]
    shell = inn_shell(ms)
    sheet = Image.new("RGBA", (shell.w + 20, shell.h + 90 + 70), (110, 150, 120, 255))
    sheet.alpha_composite(Image.fromarray(shell.rgba().astype(np.uint8), "RGBA"), (10, 10))
    x = 10
    y = shell.h + 20
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        if x + img.width > sheet.width - 10:
            x, y = 10, y + 70
        sheet.alpha_composite(img, (x, y))
        x += img.width + 10
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
