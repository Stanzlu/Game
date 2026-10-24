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
GLASS = ramp("#4f7088", "#82a9bd", "#bcdbe8", "#e6f5fa", "#ffffff")
DRY = ramp("#4a2a10", "#7a4a1c", "#a8742e", "#d0a050")
FEATHER = ramp("#8a96b0", "#bcc6dc", "#e6ecf8", "#ffffff")

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


ROSE = ramp("#7a2a4a", "#b04a72", "#e07a9c", "#ffb4c8", "#ffe0ea")
SUN = ramp("#c9822a", "#f2b44a", "#ffd97a", "#fff1b8", "#fffbe8")


def _roof(c, x0, y0, x1, y1, colors, inset=0.9, rows=4):
    """Staggered tiles seen from the front: lighter at the top, a dark line under each row, a hipped
    front that gets narrower towards the ridge."""
    cut = np.clip((y1 - 4 - c.yy) * inset, 0, (x1 - x0) / 2 - 6)
    roof = c.rect(x0, y0, x1, y1) & (c.xx >= x0 + cut) & (c.xx < x1 - cut)
    row = ((c.yy - y0) // rows).astype(int)
    stagger = ((c.xx + (row % 2) * 3) // 6).astype(int)
    shade = ((row * 7 + stagger * 13) % 5) / 5.0
    v = 0.8 - 0.4 * (c.yy - y0) / max(y1 - y0, 1) + 0.1 * (shade - 0.5)
    v = np.where(((c.yy - y0) % rows) == rows - 1, v - 0.28, v)
    v = np.where((((c.xx + (row % 2) * 3) % 6) == 5), v - 0.2, v)
    c.paint(roof, colors, v, contrast=2.0, dither=False)
    return roof


def _window(c, x, y, w, h, warm=True):
    """A round-headed window with a gold frame and a cross of bars."""
    frame = c.rect(x - 2, y - 2, x + w + 2, y + h + 2) & ((c.yy >= y + w / 2) | c.ellipse(x + w / 2, y + w / 2, w / 2 + 2, w / 2 + 2))
    c.paint(frame, GOLD, 0.6, dither=False)
    pane = c.rect(x, y, x + w, y + h) & ((c.yy >= y + w / 2) | c.ellipse(x + w / 2, y + w / 2, w / 2, w / 2))
    c.paint(pane, WARM_GLASS, 0.5 + 0.5 * c.sphere(x + w * 0.35, y + h * 0.4, w * 1.1, h * 1.1), dither=True, contrast=2.2)
    c.paint(c.rect(x + w // 2 - 1, y, x + w // 2 + 1, y + h), GOLD, 0.55, dither=False)
    c.paint(c.rect(x, y + h // 2, x + w, y + h // 2 + 2), GOLD, 0.55, dither=False)


def town_house(ms, kind):
    """A house of the street, seven cells wide: white plaster, a tiled roof in the colour of its trade,
    a shop window, a door, a sign on a bracket (bread, cloth or a flower). The twin on the other side
    of the street is the same house."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(112, 84)
    roof_colors = {"bread": GOLD, "cloth": ramp("#3a2058", "#5c3a86", "#8460b0", "#b090d8", "#dcc8f0"), "bloom": ROSE}[kind]
    wall = c.rect(6, 36, 106, 80)
    _plaster(c, wall, 36, 44)
    for x in range(6, 106, 20):
        c.paint(c.rect(x, 38, x + 1, 78), PLASTER, 0.45, dither=False)
    c.paint(c.rect(4, 76, 108, 82), st["marble"], np.where(c.yy < 77, 0.85, 0.45), contrast=2.0, dither=False)
    _roof(c, 0, 4, 112, 38, roof_colors)
    _trim(c, 0, 36, 112, 39)
    c.paint(c.rect(30, 2, 82, 6), GOLD, np.where(c.yy < 3, 0.85, 0.5), dither=False)
    # an attic window and a shop window on each side of the door
    _window(c, 48, 14, 16, 16)
    for wx in (14, 82):
        _window(c, wx, 50, 16, 20)
        c.paint(c.rect(wx - 3, 70, wx + 19, 73), TIMBER, np.where(c.yy < 71, 0.75, 0.4), dither=False)
    door = c.rect(47, 52, 65, 80) & ((c.yy >= 58) | c.ellipse(56, 58, 9, 6))
    c.paint(door, GOLD, 0.55, dither=False)
    inner = c.rect(49, 54, 63, 80) & ((c.yy >= 58) | c.ellipse(56, 58, 7, 4))
    c.paint(inner, TIMBER, np.where(((c.xx - 49) % 5) == 4, 0.25, 0.6), dither=False)
    c.fill(c.ellipse(60, 68, 1.5, 1.5), GOLD[3])
    c.paint(c.rect(44, 79, 68, 82), st["marble"], 0.7, dither=False)
    # the sign on its bracket, left of the door
    c.paint(c.rect(70, 44, 88, 46), st["iron"] if "iron" in st else GOLD, 0.5, dither=False)
    board = c.rect(72, 46, 86, 60)
    c.paint(board, TIMBER, 0.65, dither=False)
    c.paint(c.rect(72, 46, 86, 47), GOLD, 0.8, dither=False)
    if kind == "bread":
        c.paint(c.ellipse(79, 54, 5, 3.4), BREAD, 0.5 + 0.45 * c.sphere(77, 52, 6, 4), dither=False)
        for sx in (76, 79, 82):
            c.fill(c.rect(sx, 52, sx + 1, 55), BREAD[0])
    elif kind == "cloth":
        c.paint(c.rect(75, 49, 83, 58), ramp("#3a2058", "#5c3a86", "#8460b0", "#b090d8"), 0.55, dither=False)
        c.paint(c.rect(75, 53, 83, 54), GOLD, 0.8, dither=False)
    else:
        c.paint(c.ellipse(79, 51, 3, 3), ROSE, 0.7, dither=False)
        c.fill(c.ellipse(79, 51, 1, 1), SUN[3])
        c.fill(c.rect(79, 54, 80, 59), LEAF[2])
    c.outline(st["outline"])
    return c


def town_gate(ms):
    """The gate in the town wall: two round towers with teal cones and, between them, a golden arch with a
    sun on it; the passage is five cells wide (80 px) and 52 px high. 208 x 92, the passage's floor at y = 88."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(208, 92)
    for x0 in (0, 144):
        tower = c.rect(x0, 30, x0 + 64, 90)
        _plaster(c, tower, 30, 60)
        c.paint(tower & (c.xx < x0 + 8), PLASTER, 0.95, dither=False)
        c.paint(tower & (c.xx >= x0 + 54), PLASTER, 0.3, dither=False)
        _trim(c, x0, 30, x0 + 64, 33)
        _trim(c, x0, 56, x0 + 64, 58, 0.6)
        _roof(c, x0 - 3, 2, x0 + 67, 32, TILE, inset=0.8)
        c.paint(c.ellipse(x0 + 32, 3, 3.5, 3.5), GOLD, 0.35 + 0.65 * c.sphere(x0 + 31, 2, 4, 4), dither=False)
        _window(c, x0 + 24, 38, 16, 16)
        c.paint(c.rect(x0, 84, x0 + 64, 92), st["marble"], np.where(c.yy < 85, 0.85, 0.45), contrast=2.0, dither=False)
    # the arch over the passage
    arch = c.rect(64, 20, 144, 40) & ((c.yy <= 24) | ((c.xx < 72) | (c.xx >= 136)) | ~c.ellipse(104, 46, 36, 24) | (c.yy <= 22))
    span = c.rect(64, 22, 144, 38)
    c.paint(span, PLASTER, 0.8 - 0.3 * (c.yy - 22) / 16, dither=False)
    _trim(c, 64, 20, 144, 24, 0.85)
    _trim(c, 64, 36, 144, 39, 0.55)
    c.paint(c.ellipse(104, 26, 9, 9), SUN, 0.3 + 0.7 * c.sphere(101, 23, 10, 10), dither=False)
    for k in range(8):
        a = k * 0.785
        c.fill(c.rect(int(104 + 12 * np.cos(a)), int(26 + 12 * np.sin(a)) , int(104 + 12 * np.cos(a)) + 2, int(26 + 12 * np.sin(a)) + 2) & span, GOLD[3])
    c.outline(st["outline"])
    return c


def stall(ms, kind):
    """A market stall, three cells wide: a counter, a striped awning (teal or rose), the wares of its trade."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(52, 46)
    stripe = {"bread": TILE, "bloom": ROSE, "cloth": ramp("#3a2058", "#5c3a86", "#8460b0", "#b090d8", "#dcc8f0"), "wares": GOLD}[kind]
    # counter
    c.paint(c.rect(4, 30, 48, 44), PLASTER, np.where(c.xx % 11 < 1, 0.4, 0.75), dither=False)
    _trim(c, 3, 28, 49, 31, 0.8)
    _trim(c, 3, 42, 49, 45, 0.55)
    # posts and awning
    for px_ in (4, 47):
        c.paint(c.rect(px_, 6, px_ + 2, 30), TIMBER, np.where(c.xx == px_, 0.8, 0.45), dither=False)
    awning = c.rect(0, 4, 52, 16)
    band = ((c.xx // 6).astype(int) % 2) == 0
    c.paint(awning, stripe, np.where(band, 0.78, 0.3) - 0.12 * (c.yy - 4) / 12, contrast=1.8, dither=False)
    c.paint(c.rect(0, 14, 52, 17), stripe, np.where(band, 0.5, 0.2), dither=False)
    for k in range(9):  # the scalloped edge
        c.paint(c.ellipse(3 + k * 6, 17, 3, 2.2) & (c.yy >= 16), stripe, 0.7 if k % 2 == 0 else 0.3, dither=False)
    # wares on the counter
    if kind == "bread":
        for k, bx in enumerate((12, 21, 30, 39)):
            c.paint(c.ellipse(bx, 26, 4.2, 2.6), BREAD, 0.5 + 0.45 * c.sphere(bx - 1, 25, 5, 3), dither=False)
    elif kind == "bloom":
        for k, bx in enumerate((11, 20, 29, 38)):
            c.fill(c.rect(bx, 22, bx + 1, 27), LEAF[2])
            c.paint(c.ellipse(bx, 21, 3, 3), ROSE if k % 2 == 0 else SHEET, 0.65, dither=False)
            c.fill(c.ellipse(bx, 21, 1, 1), SUN[3])
    elif kind == "cloth":
        for k, bx in enumerate((10, 20, 30, 40)):
            col = ramp("#3a2058", "#5c3a86", "#8460b0", "#b090d8") if k % 2 == 0 else ROSE
            c.paint(c.rect(bx, 21, bx + 8, 28), col, 0.6, dither=False)
            c.paint(c.rect(bx, 24, bx + 8, 25), GOLD, 0.8, dither=False)
    else:  # wares of praise: golden cups and ribbons
        for k, bx in enumerate((12, 25, 38)):
            c.paint(c.rect(bx - 3, 23, bx + 4, 28), GOLD, 0.35 + 0.5 * (c.xx < bx), dither=False)
            c.paint(c.ellipse(bx, 22, 4.5, 2), GOLD, 0.8, dither=False)
            c.fill(c.rect(bx - 1, 18, bx + 1, 22), ROSE[2])
    c.outline(st["outline"])
    return c


def job_board(ms):
    """The job board: a wooden frame, three notes, one of them very large. 36 x 48."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(36, 48)
    for px_ in (3, 31):
        c.paint(c.rect(px_, 22, px_ + 3, 46), TIMBER, np.where(c.xx == px_, 0.8, 0.45), dither=False)
    c.paint(c.rect(0, 2, 36, 32), TIMBER, 0.55, dither=False)
    c.paint(c.rect(0, 2, 36, 4), GOLD, 0.85, dither=False)
    c.paint(c.rect(2, 5, 34, 30), SHEET, 0.7, dither=False)
    notes = [(4, 7, 11, 11), (13, 8, 24, 14), (22, 17, 32, 28), (5, 15, 17, 28)]
    for k, (x0, y0, x1, y1) in enumerate(notes):
        c.paint(c.rect(x0, y0, x1, y1), SHEET if k % 2 == 0 else SUN, 0.95, dither=False)
        for yy in range(y0 + 2, y1 - 1, 3):
            c.paint(c.rect(x0 + 1, yy, x1 - 1, yy + 1), TILE, 0.35, dither=False)
        c.fill(c.ellipse(x0 + 2, y0 + 1, 1.2, 1.2), ROSE[1])
    c.paint(c.rect(1, 30, 35, 33), TIMBER, 0.35, dither=False)
    c.outline(st["outline"])
    return c


def hall_front(ms, open_=False):
    """The Halle der Spiegel from the square, thirteen cells wide: white marble, a row of columns, a pediment with
    the sun and two tall golden doors, shut (or, with `open_`, pushed wide on a light hall). 208 x 112; the door
    cell is at the bottom centre."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(208, 112)
    cx = 104
    # the roof: a flat pediment with a gold sun
    ped = c.rect(4, 4, 204, 30) & (c.yy >= 4 + np.abs(c.xx - cx) * 0.18)
    c.paint(ped, PLASTER, 0.85 - 0.3 * (c.yy - 4) / 26, dither=False)
    _trim(c, 0, 28, 208, 33, 0.85)
    c.paint(c.ellipse(cx, 18, 11, 11), SUN, 0.3 + 0.7 * c.sphere(cx - 3, 15, 12, 12), dither=False)
    for k in range(10):
        a = k * 0.6283
        x, y = int(cx + 16 * np.cos(a)), int(18 + 16 * np.sin(a) * 0.8)
        c.fill(c.rect(x, y, x + 2, y + 2) & ped, GOLD[3])
    # the wall behind the columns
    wall = c.rect(8, 33, 200, 108)
    _plaster(c, wall, 33, 75)
    c.paint(c.rect(4, 100, 204, 110), st["marble"], np.where(c.yy < 101, 0.85, 0.45), contrast=2.0, dither=False)
    c.paint(c.rect(10, 108, 198, 112), st["marble"], 0.6, dither=False)
    # six columns
    for k in range(6):
        x = 14 + k * 34 if k < 3 else 208 - 14 - (5 - k) * 34 - 12
        col = c.rect(x, 34, x + 12, 102)
        c.paint(col, st["marble"], 0.35 + 0.65 * c.cylinder(x, x + 12), dither=False)
        c.paint(c.rect(x - 2, 32, x + 14, 37), GOLD, 0.6, dither=False)
        c.paint(c.rect(x - 2, 98, x + 14, 103), st["marble"], 0.55, dither=False)
    if open_:
        # the doors pushed back to the sides: the hall behind them is light, a mirror glints at the far end
        gap = c.rect(cx - 17, 44, cx + 17, 102) & ((c.yy >= 52) | c.ellipse(cx, 52, 17, 8))
        c.paint(gap, FLOOR, 0.85 - 0.5 * (c.yy - 44) / 58, dither=False)
        c.paint(c.rect(cx - 7, 56, cx + 7, 78) & gap, GLASS, 0.8, dither=False)
        for dx, w in ((cx - 21, 4), (cx + 17, 4)):
            c.paint(c.rect(dx, 46, dx + w, 102), GOLD, 0.55, dither=False)
            c.paint(c.rect(dx + 1, 48, dx + w - 1, 102), TIMBER, 0.5, dither=False)
    else:
        # two tall doors in the middle, shut, with a ring each
        for dx in (cx - 17, cx + 1):
            door = c.rect(dx, 44, dx + 16, 102) & ((c.yy >= 52) | c.ellipse(dx + 8, 52, 8, 8))
            c.paint(door, GOLD, 0.5, dither=False)
            inner = c.rect(dx + 2, 46, dx + 14, 102) & ((c.yy >= 52) | c.ellipse(dx + 8, 52, 6, 6))
            c.paint(inner, TIMBER, np.where(((c.yy - 46) % 8) == 7, 0.25, 0.58), dither=False)
        c.fill(c.ellipse(cx - 4, 76, 1.8, 1.8), GOLD[3])
        c.fill(c.ellipse(cx + 4, 76, 1.8, 1.8), GOLD[3])
    c.outline(st["outline"])
    return c


# --- The hall of mirrors, inside (A5) ------------------------------------------------------------------
# One map, 33 x 42 cells, symmetric about cell 16: the vestibule (rows 30-38), the gallery (rows 16-26) and the
# mirror room (rows 6-12), each behind a north wall face three rows high; the gates stand in the faces of the
# gallery and the vestibule (cells 15-17), the way out is the doorway in the bottom wall.
HALL_AXIS = 16 * PX + 8
HALL_W, HALL_H = 33 * PX, 42 * PX


def _hall_cell(x, y):
    return x * PX, y * PX


def _mirror_panel(c, x0, y0, x1, y1):
    """A tall mirror in a gold frame: pale glass with a slanting glint."""
    c.paint(c.rect(x0, y0, x1, y1), GOLD, 0.6, dither=False)
    glass = c.rect(x0 + 2, y0 + 2, x1 - 2, y1 - 2)
    shade = 0.45 + 0.5 * (1 - (c.yy - y0) / max(y1 - y0, 1))
    c.paint(glass, GLASS, shade, dither=True, contrast=1.4)
    glint = glass & (np.abs((c.xx - x0) - (c.yy - y0) * 0.5 - (x1 - x0) * 0.35) < 1.6)
    c.paint(glint, GLASS, 0.98, dither=False)


def _hall_face(c, x0, y0, x1, y1, gap=None, mirrors=True):
    """A north wall face from cell columns x0..x1 (inclusive) and rows y0..y1: plaster, cornice, skirting and,
    between pilasters, tall mirrors; `gap` is the (first, last) cell column left open for a gate."""
    px0, py0 = _hall_cell(x0, y0)
    px1, py1 = _hall_cell(x1 + 1, y1 + 1)
    _plaster(c, c.rect(px0, py0, px1, py1), py0, py1 - py0)
    c.paint(c.rect(px0, py1 - 3, px1, py1), PLASTER, 0.25, dither=False)
    _trim(c, px0, py0, px1, py0 + 3, 0.75)
    _trim(c, px0, py1 - 5, px1, py1 - 3, 0.6)
    if gap is not None:
        gx0, _ = _hall_cell(gap[0], y0)
        gx1, _ = _hall_cell(gap[1] + 1, y0)
        # the doorway: a light passage with a gold arch (the gate hides it until it is open)
        arch = c.rect(gx0 - 3, py0 + 4, gx1 + 3, py1) & ((c.yy >= py0 + 18) | c.ellipse((gx0 + gx1) / 2, py0 + 18, (gx1 - gx0) / 2 + 3, 14))
        c.paint(arch, GOLD, 0.6, dither=False)
        hole = c.rect(gx0, py0 + 6, gx1, py1) & ((c.yy >= py0 + 18) | c.ellipse((gx0 + gx1) / 2, py0 + 18, (gx1 - gx0) / 2, 12))
        c.paint(hole, FLOOR, 0.9 - 0.4 * (c.yy - py0) / (py1 - py0), dither=False)
    if mirrors:
        panel_w, step = 18, 30
        x = px0 + 8
        while x + panel_w <= px1 - 6:
            left, right = x, x + panel_w
            clear = gap is None or right < _hall_cell(gap[0], y0)[0] - 6 or left > _hall_cell(gap[1] + 1, y0)[0] + 6
            if clear:
                _mirror_panel(c, left, py0 + 7, right, py1 - 8)
            x += step


def hall_shell(ms):
    """The whole hall seen from above and the front: three north faces, the side walls and the bottom wall with
    the doorway. The floor is baked from the map."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(HALL_W, HALL_H)
    # the north faces: the mirror room (columns 8-24), the gallery (3-29) and the vestibule (3-29)
    _hall_face(c, 8, 3, 24, 5, mirrors=False)
    _hall_face(c, 3, 13, 29, 15, gap=(15, 17))
    _hall_face(c, 3, 27, 29, 29, gap=(15, 17))
    # the side walls of the three rooms
    for col, y0, y1 in ((8, 6, 13), (24, 6, 13), (3, 16, 27), (29, 16, 27), (3, 30, 40), (29, 30, 40)):
        x, py0 = _hall_cell(col, y0)
        _, py1 = _hall_cell(col, y1)
        c.paint(c.rect(x, py0, x + PX, py1), PLASTER, np.where(c.xx < x + 3, 0.85, 0.55), dither=False)
        _trim(c, x, py0, x + PX, py0 + 2, 0.7)
    # the bottom wall with the doorway in the middle (cells 15-17)
    bx0, by0 = _hall_cell(3, 39)
    bx1, by1 = _hall_cell(30, 41)
    c.paint(c.rect(bx0, by0, bx1, by1), PLASTER, np.where(c.yy < by0 + 4, 0.35, 0.8), dither=False)
    dx0, _ = _hall_cell(15, 39)
    dx1, _ = _hall_cell(18, 39)
    c.paint(c.rect(dx0 - 3, by0 - 2, dx1 + 3, by1), GOLD, 0.5, dither=False)
    c.paint(c.rect(dx0, by0, dx1, by1), FLOOR, 0.55, dither=False)
    c.outline(st["outline"])
    return c


def hall_gate(ms):
    """A gate of two mirrored leaves in the doorway of a north face: 48 x 48 (three cells, three rows), gold frame,
    a tall mirror in each leaf, rings in the middle. It opens by disappearing (the flag of its room)."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(48, 48)
    arch = c.rect(0, 4, 48, 48) & ((c.yy >= 18) | c.ellipse(24, 18, 24, 14))
    c.paint(arch, GOLD, 0.55, dither=False)
    for x0 in (3, 25):
        leaf = c.rect(x0, 7, x0 + 20, 48) & ((c.yy >= 18) | c.ellipse(x0 + 10, 18, 10, 11))
        c.paint(leaf, TIMBER, 0.55, dither=False)
        panel = c.rect(x0 + 3, 12, x0 + 17, 44) & ((c.yy >= 20) | c.ellipse(x0 + 10, 20, 7, 8))
        c.paint(panel, GLASS, 0.55 + 0.4 * (1 - (c.yy - 12) / 32), dither=True, contrast=1.4)
        c.paint(panel & (np.abs((c.xx - x0) - (c.yy - 12) * 0.5 - 6) < 1.4), GLASS, 0.98, dither=False)
    c.paint(c.rect(22, 7, 26, 48), GOLD, 0.7, dither=False)
    c.fill(c.ellipse(20, 32, 1.6, 1.6), GOLD[3])
    c.fill(c.ellipse(28, 32, 1.6, 1.6), GOLD[3])
    c.outline(st["outline"])
    return c


def hall_mirror(ms):
    """The great mirror of the last room: an oval in a gold frame, 48 x 48. It shows the hall behind the one who
    stands before it, the columns, the light, the dust in the air; the glass is lit and empty in the middle."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(48, 48)
    c.paint(c.ellipse(24, 24, 22, 23), GOLD, 0.35 + 0.6 * c.sphere(18, 14, 26, 26), dither=False)
    glass = c.ellipse(24, 24, 18, 19)
    c.paint(glass, GLASS, 0.5 + 0.45 * (1 - (c.yy - 5) / 38), dither=True, contrast=1.3)
    # the hall in the glass: two columns and the floor line, faint
    for cx in (12, 36):
        c.paint(c.rect(cx - 2, 10, cx + 2, 38) & glass, GLASS, 0.9, dither=False)
    c.paint(c.rect(0, 33, 48, 35) & glass, GLASS, 0.3, dither=False)
    c.paint(glass & (np.abs((c.xx - 6) - (c.yy - 6) * 0.6 - 10) < 2), GLASS, 0.99, dither=False)
    c.outline(st["outline"])
    return c


def odd_leaf(ms):
    """One dry leaf, brown and curled at the rim: the only thing in the hall that has changed."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(14, 10)
    leaf = c.ellipse(7, 5, 6, 3.4)
    c.paint(leaf, DRY, 0.45 + 0.5 * c.sphere(5, 3, 6, 4), dither=False)
    c.paint(c.rect(1, 5, 12, 6) & leaf, DRY, 0.25, dither=False)
    c.fill(c.rect(12, 5, 14, 6), DRY[1])
    c.outline(st["outline"])
    return c


def odd_feather(ms):
    """One feather, pale blue-grey, that a bird left on the marble."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(18, 8)
    vane = c.ellipse(9, 4, 8, 2.6)
    c.paint(vane, FEATHER, 0.55 + 0.4 * c.sphere(7, 3, 8, 3), dither=False)
    c.paint(c.rect(0, 4, 18, 5), FEATHER, 0.2, dither=False)
    c.outline(st["outline"])
    return c


def bunting(ms):
    """A string of small flags for the feast, 96 x 24 (six cells): it sags in the middle, the flags hang from it
    in the gold, teal and rose of Elysia, a little ball of light at each end."""
    st = pa.STYLES["elysia"]
    c = ms.Canvas(96, 24)
    colors = [GOLD, TILE, PINK, BLANKET]
    xs = np.arange(96)
    sag = (3 + 9 * (1 - ((xs - 47.5) / 47.5) ** 2)).astype(int)  # the string's drop at each column (higher in the middle)
    for x in range(96):
        y = 2 + 9 - int(sag[x] - 3)
        c.fill(c.rect(x, y, x + 1, y + 1), GOLD[2])
    for k, x in enumerate(range(6, 92, 8)):
        y = 2 + 9 - int(sag[x] - 3)
        flag = c.rect(x - 2, y + 1, x + 3, y + 7) & (c.yy < y + 7 - np.abs(c.xx - x) * 1.4)
        c.paint(flag, colors[k % 4], 0.8 - 0.1 * (c.yy - y) / 6, dither=False)
    for x in (2, 93):
        c.fill(c.ellipse(x, 4, 2.2, 2.2), GOLD[4])
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
    for kind in ("bread", "cloth", "bloom"):
        ms.save("elysia", "town_house_" + kind, town_house(ms, kind), (56, 76))
    ms.save("elysia", "town_gate", town_gate(ms), (104, 86))
    for kind in ("bread", "bloom", "cloth", "wares"):
        ms.save("elysia", "stall_" + kind, stall(ms, kind), (26, 38), shape={"rect": [48, 8], "offset": [0, -6]}, shadow=[24, 4])
    ms.save("elysia", "job_board", job_board(ms), (18, 44), shape={"rect": [30, 6], "offset": [0, -3]}, shadow=[14, 3])
    ms.save("elysia", "hall_front", hall_front(ms), (104, 104))
    ms.save("elysia", "hall_front_open", hall_front(ms, open_=True), (104, 104))
    ms.save("elysia", "hall_shell", hall_shell(ms), (HALL_AXIS, 8), flat=True)
    ms.save("elysia", "hall_gate", hall_gate(ms), (24, 40), shape={"rect": [48, 16], "offset": [0, 0]})
    ms.save("elysia", "hall_mirror", hall_mirror(ms), (24, 40))
    ms.save("elysia", "odd_leaf", odd_leaf(ms), (7, 6), shadow=[6, 2])
    ms.save("elysia", "odd_feather", odd_feather(ms), (9, 5), shadow=[8, 2])
    ms.save("elysia", "bunting", bunting(ms), (48, 20), sway=1.0)


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [inn_front(ms), inn_bar(ms), inn_table(ms), inn_hearth(ms, 0)[0], inn_bed(ms), inn_door(ms), guest_book(ms)]
    items += [town_house(ms, k) for k in ("bread", "cloth", "bloom")] + [town_gate(ms), hall_front(ms), job_board(ms)]
    items += [stall(ms, k) for k in ("bread", "bloom", "cloth", "wares")]
    shell = inn_shell(ms)
    sheet = Image.new("RGBA", (shell.w + 20, shell.h + 90 + 70 + 330), (110, 150, 120, 255))
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
