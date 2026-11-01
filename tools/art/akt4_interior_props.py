"""Props of the town hall seen from inside (Akt IV, S2, docs/akt4/REGIONSBRIEFE.md), drawn like akt3_props.py and
registered in the same catalog (style "tal", prefix `rh_`). Called from make_sprites.build(); `--preview out.png`
draws them on one sheet (3x) to look at, `--room out.png` lays the shell and the furniture of content/maps/rathaus.txt
over a plain floor (to check where things stand and where the lost things lie on their shelf).

The room is the hall of a small town where everything is in order: stamps in rows, notes sorted by colour, a clock that
is right, a banner that hangs straight. The order is the joke, and nobody in it is: the counter has a grille and a
window in it, the shelves of the lost-property office hold what nobody came back for (an umbrella, one boot, a hat on a
stand, a birdcage with nothing in it, each with a paper tag), the door to the mayor's office stands wide open against
the wall (a door a little too far open), and one of the waiting chairs is missing from the row (four dents in the
floor where it stood). No gold anywhere (the town's colours are slate blue and terracotta; gold is Elysia's).

The room is one flat shell under the furniture (like haus/shell): back wall with window, plan board, banner, clock, the
mayor's door, a map and a fire bucket; the side walls and the front wall with the door. The floor is baked from the map
(planks_h). The four things the clerk hands over lie on the shelf as props of their own (rh_glove, rh_key, rh_buttons,
rh_cup: 16 x 16 canvases, anchor (8, 16), the map lifts them onto the board they lie on and hides them with `unless`);
they carry no shadow in the catalog (a baked shadow would stay under nothing). The map is 28 x 20 cells, the room are the
cells 4 to 23 and 3 to 15 (20 x 13): the back wall rows 3 to 5, the floor rows 6 to 14, the front wall row 15.
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp

ROOM_W, ROOM_H = 320, 208  # 20 x 13 cells

PLASTER = ramp("#4e4034", "#7c6a56", "#a8957a", "#cfbf9e", "#ece0c0")
PANEL = ramp("#1e140e", "#33231a", "#503822", "#745034", "#9a7248")
BEAM = ramp("#1a110c", "#2e2016", "#4a3322", "#6e4e34")
BRASS = ramp("#3e260c", "#7c5018", "#bd8a28", "#ecc050", "#fff0a2")
BRONZE = ramp("#241a12", "#4e3a28", "#7c6040", "#a8885c", "#cfb482")  # the town's metal: duller and browner than Elysia's gold
IRON = ramp("#14161a", "#26292f", "#40454e", "#6a707a", "#9aa0aa")
PAPER = ramp("#7a7466", "#aaa28e", "#d6cfba", "#f2ecda", "#ffffff")
SLATE = ramp("#142028", "#1e3442", "#2e566a", "#4a8096")  # the town's blue
TERRACOTTA = ramp("#3a1812", "#68281c", "#98442a", "#c46c3a", "#e8985a")
CORK = ramp("#3e2a14", "#6c4a26", "#9c7040", "#c49a5c")
GLASS = ramp("#1c2a38", "#34506a", "#6c98b8", "#b8dcec", "#f0fbff")
YELLOW = ramp("#8a6a10", "#c8a022", "#f0cc48", "#fff0a0")
PINK = ramp("#8a2c48", "#c8587a", "#ee8aa6", "#ffc4d4")
BLUE = ramp("#2a4c88", "#4a7ac4", "#7aaae8", "#bcd6ff")
GREEN = ramp("#2a6a38", "#4a9a52", "#7cc678", "#bce8a8")
RED_WOOL = ramp("#3e1210", "#6e2420", "#a0402e", "#cc6a48")
TIN = ramp("#1e3050", "#2e5084", "#4a7cb8", "#86b0de")
CLAY = ramp("#4a3220", "#8a6244", "#c4966c", "#ecc8a0")
CREAM = ramp("#8a8068", "#bfb496", "#e4dabc", "#fbf4dc")
LEATHER = ramp("#1e120c", "#3e2616", "#6a4428", "#98683e")
FELT = ramp("#1a1c30", "#2c2e50", "#464a7c", "#6a70a8")
INK = ramp("#1a1030", "#2e1c52", "#4a2e84", "#7050b8")  # the ink pad: violet, never red (the clerk's stamp is red)
STAMP_RED = ramp("#4a0e10", "#8a1c1c", "#c43030", "#ee6a58")


def seg(c, x0, y0, x1, y1, r):
    """Mask of a thick line segment from (x0, y0) to (x1, y1): every pixel whose centre lies within `r` of it."""
    px, py = c.xx + 0.5, c.yy + 0.5
    dx, dy = x1 - x0, y1 - y0
    t = np.clip(((px - x0) * dx + (py - y0) * dy) / max(dx * dx + dy * dy, 1e-6), 0, 1)
    return np.hypot(px - (x0 + t * dx), py - (y0 + t * dy)) <= r


def _noise(c, cell, seed):
    return pa.value_noise(c.h, c.w, cell, np.random.default_rng(seed))


def _wood(c, mask, v, ramp_colors=PANEL, contrast=2.0):
    c.paint(mask, ramp_colors, v, contrast=contrast, dither=False)


# --------------------------------------------------------------------------- the shell
def _window(c, x0, y0, x1, y1, seed):
    """A tall window with the town's roofs behind it in daylight, a cross of bars and a sill."""
    rng = np.random.default_rng(seed)
    c.paint(c.rect(x0 - 3, y0 - 3, x1 + 3, y1 + 3), BEAM, 0.62, dither=False)
    c.paint(c.rect(x0 - 3, y0 - 3, x1 + 3, y0 - 2), BEAM, 0.95, dither=False)
    pane = c.rect(x0, y0, x1, y1)
    t = np.clip((c.yy - y0) / (y1 - y0), 0, 1)
    c.paint(pane, GLASS, 0.98 - 0.5 * t ** 1.2 + 0.05 * (_noise(c, 4, seed) - 0.5), contrast=1.6, dither=True)
    # two roofs and a chimney beyond, a smudge of cloud
    ridge = y1 - 8 - 3.2 * np.abs(np.sin((c.xx - x0) * 0.21 + 0.6))
    c.paint(pane & (c.yy > ridge), ramp("#2a3038", "#464e5a", "#6a7480"), 0.35 + 0.2 * (c.xx > (x0 + x1) / 2), dither=False)
    c.paint(c.rect(x0 + 4, y1 - 14, x0 + 6, y1 - 9) & pane, ramp("#2a3038", "#464e5a", "#6a7480"), 0.3, dither=False)
    cloud = c.ellipse(x0 + 14, y0 + 6, 5, 1.6) | c.ellipse(x0 + 11, y0 + 7, 3, 1.2)
    c.paint(cloud & pane, GLASS, 1.0, dither=False)
    mid_x, mid_y = (x0 + x1) // 2, (y0 + y1) // 2
    c.paint(c.rect(mid_x - 1, y0, mid_x + 1, y1), BEAM, np.where(c.xx < mid_x, 0.7, 0.4), dither=False)  # mullion
    c.paint(c.rect(x0, mid_y - 1, x1, mid_y + 1), BEAM, np.where(c.yy < mid_y, 0.8, 0.4), dither=False)  # transom
    c.paint(c.rect(x0 - 5, y1 + 3, x1 + 5, y1 + 6), BEAM, np.where(c.yy < y1 + 4, 0.95, 0.5), dither=False)  # sill
    c.paint(c.rect(x0 - 2, y1 + 6, x1 + 2, y1 + 8), BEAM, 0.15, dither=False)  # its shadow on the wall


def _plan_board(c, x0, y0, x1, y1):
    """The plan board: cork in a wooden frame, a long plan strip on top and the notes in four colours, in columns,
    sorted, straight; one of them hangs by a single pin."""
    c.paint(c.rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), BEAM, np.where(c.yy < y0, 0.9, 0.55), dither=False)
    c.paint(c.rect(x0, y0, x1, y1), CORK, 0.55 + 0.25 * (_noise(c, 2, 7) - 0.5) - 0.12 * ((c.yy - y0) / (y1 - y0)), dither=True)
    # the plan: a long strip, three lines of dashes with a round mark in front of each
    c.paint(c.rect(x0 + 2, y0 + 2, x1 - 2, y0 + 12), PAPER, np.where(c.yy < y0 + 3, 0.95, 0.85), dither=False)
    for k in range(3):
        y = y0 + 4 + k * 3
        c.fill(c.rect(x0 + 3, y, x0 + 4, y + 1), STAMP_RED[2])
        for x in range(x0 + 6, x1 - 4, 3):
            c.fill(c.rect(x, y, x + 2, y + 1), PAPER[0] if (x + k) % 2 else PAPER[1])
    c.fill(c.rect(x0 + 1, y0 + 1, x0 + 3, y0 + 3), IRON[3])  # pin
    # the notes: four columns, three rows, each column one colour
    for col, color in enumerate((YELLOW, PINK, BLUE, GREEN)):
        for row in range(3):
            nx = x0 + 2 + col * 6
            ny = y0 + 14 + row * 5
            if col == 2 and row == 2:
                continue  # that one hangs loose (below)
            c.paint(c.rect(nx, ny, nx + 5, ny + 4), color, np.where(c.yy < ny + 1, 0.95, 0.6), dither=False)
            c.fill(c.rect(nx + 2, ny, nx + 3, ny + 1), IRON[2])  # the pin
            c.fill(c.rect(nx + 1, ny + 2, nx + 4, ny + 3), color[0])  # a scribbled line
    # the loose one: it hangs by one corner, a little turned
    lx, ly = x0 + 14, y0 + 24
    loose = (c.xx >= lx) & (c.xx < lx + 5) & (c.yy >= ly + (c.xx - lx) * 0.35) & (c.yy < ly + 4 + (c.xx - lx) * 0.35)
    c.paint(loose, BLUE, 0.7, dither=False)
    c.fill(c.rect(lx, ly - 1, lx + 1, ly), IRON[2])


def _banner(c, x0, y0, x1, y1):
    """The town's banner hangs straight from a brass rod: slate blue with a terracotta border and a fountain in cream."""
    c.paint(c.rect(x0 - 3, y0, x1 + 3, y0 + 2), BRONZE, np.where(c.yy < y0 + 1, 0.9, 0.45), dither=False)
    c.fill(c.rect(x0 - 4, y0, x0 - 2, y0 + 3), BRONZE[3])
    c.fill(c.rect(x1 + 2, y0, x1 + 4, y0 + 3), BRONZE[3])
    cx = (x0 + x1) / 2.0
    tail = (c.yy >= y1 - 6) & (np.abs(c.xx + 0.5 - cx) < (y1 - c.yy) * 1.2 + 1.5 - 0) & (c.yy < y1)
    cloth = (c.rect(x0, y0 + 2, x1, y1 - 6) | tail)
    c.paint(cloth, SLATE, 0.5 + 0.35 * c.cylinder(x0 - 8, x1 + 8) - 0.1 * ((c.yy - y0) / (y1 - y0)), dither=False)
    border = cloth & ~(c.rect(x0 + 2, y0 + 4, x1 - 2, y1 - 8) | (tail & (c.yy >= y1 - 6) & (np.abs(c.xx + 0.5 - cx) < (y1 - c.yy) * 1.2 - 1.5)))
    c.paint(border & (c.yy < y1 - 5), TERRACOTTA, 0.55 + 0.3 * (c.xx < cx), dither=False)
    # the fountain: a basin, a stem, two arcs of water falling
    bx, by = int(cx), y0 + 22
    c.paint(c.ellipse(cx, by + 4, 6.4, 2.4), PAPER, 0.85, dither=False)  # the basin, with its water
    c.paint(c.ellipse(cx, by + 3.4, 4.6, 1.2), SLATE, 0.15, dither=False)
    c.paint(c.rect(bx - 1, by - 1, bx + 1, by + 3), PAPER, 0.7, dither=False)  # the stem
    c.paint(c.ellipse(cx, by - 1.2, 3.4, 1.3), PAPER, 0.9, dither=False)  # the upper bowl
    c.fill(c.rect(bx - 1, by - 8, bx, by - 2), PAPER[4])  # the jet and the drops falling from it
    for dx, dy in ((-2, -7), (1, -7), (-3, -5), (2, -5), (-4, -3), (3, -3)):
        c.fill(c.rect(bx + dx, by + dy, bx + dx + 1, by + dy + 1), PAPER[3])


def _clock(c, cx, cy, r):
    """A round wall clock with a plain face, twelve dots, two hands and the right time (nobody here is ever late)."""
    c.paint(c.ellipse(cx, cy, r + 2.2, r + 2.2), BEAM, 0.45 + 0.4 * c.sphere(cx - 2, cy - 2, r + 3, r + 3), dither=False)
    c.paint(c.ellipse(cx, cy, r, r), CREAM, 0.7 + 0.3 * c.sphere(cx - 2, cy - 2, r + 2, r + 2), dither=False)
    for k in range(12):
        a = k / 12 * 2 * np.pi
        x, y = cx + np.sin(a) * (r - 1.6), cy - np.cos(a) * (r - 1.6)
        c.fill(c.rect(round(x - 0.5), round(y - 0.5), round(x - 0.5) + 1, round(y - 0.5) + 1), IRON[1] if k % 3 == 0 else IRON[2])
    for ang, ln, w in ((0.9 * np.pi, r - 4.5, 1.0), (0.12 * np.pi, r - 2.5, 0.8)):
        ex, ey = cx + np.sin(ang) * ln, cy - np.cos(ang) * ln
        t = np.linspace(0, 1, 18)
        for tt in t:
            x, y = cx + (ex - cx) * tt, cy + (ey - cy) * tt
            c.fill(c.rect(round(x - 0.5), round(y - 0.5), round(x - 0.5) + 1, round(y - 0.5) + 1), IRON[0])
    c.fill(c.rect(round(cx - 1), round(cy - 1), round(cx + 1), round(cy + 1)), BRASS[3])


def _mayor_door(c, x0, y0, x1, y1):
    """The door to the mayor's office, swung wide open against the wall: the dark room beyond with one chair and one
    hat on a hook, the leaf seen edge-on as a slab at the left with two hinges. A door a little too far open."""
    c.paint(c.rect(x0 - 3, y0 - 3, x1 + 3, y1), BEAM, np.where(c.yy < y0 - 1, 0.95, 0.6), dither=False)
    opening = c.rect(x0, y0, x1, y1)
    t = np.clip((c.yy - y0) / (y1 - y0), 0, 1)
    c.paint(opening, ramp("#0e0a0c", "#1c1416", "#33282a", "#54443e"), 0.15 + 0.5 * t ** 1.4, contrast=1.5, dither=True)
    # beyond: a chair back and a hat on a hook
    c.paint(c.rect(x1 - 9, y1 - 14, x1 - 3, y1 - 2), PANEL, 0.3, dither=False)
    c.paint(c.rect(x1 - 9, y1 - 14, x1 - 3, y1 - 12), PANEL, 0.5, dither=False)
    c.paint(c.ellipse(x0 + 8, y0 + 6, 3.4, 1.2), FELT, 0.4, dither=False)
    c.paint(c.rect(x0 + 6, y0 + 3, x0 + 10, y0 + 6), FELT, 0.3, dither=False)
    # the leaf, edge-on, with its two hinges; a long shadow of it on the floor
    leaf = c.rect(x0 - 3, y0 - 1, x0 + 3, y1)
    plank = ((c.yy - y0) // 4).astype(int)
    c.paint(leaf, PANEL, np.where(((c.yy - y0) % 4) == 3, 0.12, 0.52 + 0.05 * (plank % 2)) + 0.12 * (c.xx < x0 - 1), dither=False)
    c.paint(c.rect(x0 + 2, y0 - 1, x0 + 3, y1), PANEL, 0.85, dither=False)
    for hy in (y0 + 4, y1 - 8):
        c.paint(c.rect(x0 - 3, hy, x0 + 3, hy + 2), IRON, 0.75, dither=False)
    c.paint(c.rect(x0 + 3, y1 - 3, x1, y1), BEAM, 0.1, dither=False)


def _wall_map(c, x0, y0, x1, y1):
    """A map of the surroundings on parchment: a coast, a river with a bend, a dashed road to the town, pins."""
    c.paint(c.rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), BEAM, np.where(c.yy < y0, 0.85, 0.5), dither=False)
    c.paint(c.rect(x0, y0, x1, y1), CREAM, 0.72 + 0.25 * (_noise(c, 3, 11) - 0.5), dither=True)
    # the sea along the left edge, a river from the top with a bend, the dashed road, a few red pins
    sea = c.rect(x0, y0, x1, y1) & (c.xx < x0 + 5 + 2.5 * np.sin((c.yy - y0) * 0.5))
    c.paint(sea, BLUE, 0.4 + 0.2 * (c.yy < y0 + 8), dither=False)
    river_x = x0 + 12 + 4 * np.sin((c.yy - y0) * 0.35)
    c.paint(c.rect(x0, y0, x1, y1) & (np.abs(c.xx + 0.5 - river_x) < 0.8) & (c.xx > x0 + 7), BLUE, 0.55, dither=False)
    for k in range(4):
        c.fill(c.rect(x0 + 14 + k * 2, y1 - 8 + (k % 2) * 0, x0 + 15 + k * 2, y1 - 7), IRON[2])
    for px, py in ((x0 + 19, y0 + 6), (x0 + 11, y1 - 7)):
        c.fill(c.rect(px, py, px + 2, py + 2), STAMP_RED[2])
        c.fill(c.rect(px, py, px + 1, py + 1), STAMP_RED[3])
    c.fill(c.rect(x0 + 17, y0 + 12, x0 + 20, y0 + 14), PAPER[1])  # the town: a little square of roofs
    c.fill(c.rect(x0 + 18, y0 + 11, x0 + 19, y0 + 12), TERRACOTTA[3])
    c.fill(c.rect(x0 + 1, y0 + 1, x0 + 2, y0 + 2), IRON[2])
    c.fill(c.rect(x1 - 2, y0 + 1, x1 - 1, y0 + 2), IRON[2])


def _bucket(c, cx, y0):
    """A red fire bucket on a hook, a white band, a rope handle."""
    c.fill(c.rect(cx - 1, y0, cx + 1, y0 + 2), IRON[3])
    c.paint(c.rect(cx - 5, y0 + 5, cx + 5, y0 + 15) & ~(((c.yy - y0 - 5) > 7) & (np.abs(c.xx + 0.5 - cx) > 4 - (c.yy - y0 - 12) * 0)),
            RED_WOOL, 0.4 + 0.6 * c.cylinder(cx - 6, cx + 6), dither=False)
    c.paint(c.rect(cx - 5, y0 + 8, cx + 5, y0 + 10), PAPER, 0.8 - 0.3 * (c.xx > cx), dither=False)
    c.paint(c.rect(cx - 5, y0 + 4, cx + 5, y0 + 6), IRON, 0.5, dither=False)
    handle = (np.abs(np.hypot(c.xx + 0.5 - cx, (c.yy + 0.5 - (y0 + 5)) * 1.3) - 4.5) < 0.6) & (c.yy < y0 + 5)
    c.paint(handle, CORD_ROPE, 0.7, dither=False)


CORD_ROPE = ramp("#4a4234", "#7a6e56", "#a89a7a", "#cfc29e")


def shell(ms):
    """The room seen from the front, lying under everything (the floor is baked from the map): the back wall, plaster over
    a dark wainscot, with the window (map cells 8 and 9), the plan board (10, 11), the fire bucket (12), the banner (13),
    the clock (14), the mayor's door (16, 17) and the map (18, 19); the shelves (5 to 7 and 20 to 22) are props of
    their own. The side walls as dark timber, the front wall with the door in the cell 13 (the axis of the room: door,
    runner, counter window, banner). 320 x 208, anchor (8, 8): the room's top left cell is the map cell (4, 3)."""
    c = ms.Canvas(ROOM_W, ROOM_H)
    top, bottom = 8, 48
    xl, xr = 10, ROOM_W - 10
    grain = pa.value_noise(ROOM_H, ROOM_W, (2, 14), np.random.default_rng(461))
    # plaster above, wainscot below (vertical boards, a rail between them)
    plaster = c.rect(xl, top, xr, 30)
    stain = pa.value_noise(ROOM_H, ROOM_W, 9, np.random.default_rng(462))
    c.paint(plaster, PLASTER, 0.88 - 0.3 * np.clip((c.yy - top) / 22.0, 0, 1) ** 1.4 + 0.1 * (grain - 0.5) - 0.12 * (stain > 0.72), contrast=1.8, dither=False)
    wains = c.rect(xl, 32, xr, bottom)
    board = ((c.xx - xl) // 8).astype(int)
    wv = 0.5 + 0.06 * ((board * 7 + 3) % 5 - 2) / 2.0 + 0.1 * (grain - 0.5) - 0.18 * ((c.yy - 32) / 16.0)
    wv = np.where(((c.xx - xl) % 8) == 7, 0.06, np.where(((c.xx - xl) % 8) == 0, wv + 0.14, wv))
    c.paint(wains, PANEL, wv, contrast=2.0, dither=False)
    c.paint(c.rect(xl, 30, xr, 32), PANEL, np.where(c.yy < 31, 0.95, 0.4), dither=False)  # the rail
    c.paint(c.rect(xl, bottom - 3, xr, bottom), PANEL, np.where(c.yy < bottom - 2, 0.55, 0.12), dither=False)  # the baseboard
    # the shadow of the wall on the floor row, and the beam above with the dark of the loft over it
    c.paint(c.rect(xl, bottom, xr, bottom + 3), BEAM, np.where(c.yy < bottom + 1, 0.2, 0.5), dither=False)
    c.a[(c.yy >= bottom + 1) & (c.yy < bottom + 3) & (c.xx >= xl) & (c.xx < xr)] = True
    c.paint(c.rect(0, 0, ROOM_W, top - 4), BEAM, 0.05, dither=False)
    c.paint(c.rect(4, top - 4, ROOM_W - 4, top), BEAM, np.where(c.yy < top - 2, 0.85, 0.45), dither=False)
    # what hangs on it
    _window(c, 68, 14, 92, 34, 471)
    _plan_board(c, 100, 12, 124, 42)
    _bucket(c, 134, 14)
    _banner(c, 144, 9, 160, 46)
    _clock(c, 171, 22, 6.5)
    _mayor_door(c, 196, 16, 220, 48)
    _wall_map(c, 228, 12, 250, 38)
    # side walls: timber seen from above, one lit from the window side, one in shade
    for x0, x1, face, lit in ((0, 12, (4, 9), 0.7), (ROOM_W - 12, ROOM_W, (ROOM_W - 9, ROOM_W - 4), 0.5)):
        c.paint(c.rect(x0, top, x1, ROOM_H), BEAM, 0.05, dither=False)
        edge = 10 if x0 == 0 else ROOM_W - 12
        c.paint(c.rect(face[0], top, face[1], ROOM_H - 4), BEAM, lit - 0.3 * np.clip((c.yy - top) / (ROOM_H - 16.0 - top), 0.0, 1.0), dither=False)
        c.paint(c.rect(edge, top, edge + 2, ROOM_H - 4), BEAM, 0.3, dither=False)
    # the front wall (the last row): a lit cap, a face of plaster over a wainscot, and the closed door in the cell 9
    fy = ROOM_H - 16
    c.paint(c.rect(4, fy, ROOM_W - 4, ROOM_H), BEAM, np.where(c.yy < fy + 3, 0.8, 0.05), dither=False)
    face = c.rect(4, fy + 3, ROOM_W - 4, ROOM_H - 3)
    fv = np.where(c.yy < fy + 8, 0.34, 0.24) + 0.08 * (grain - 0.5)
    c.paint(face, PLASTER, fv + 0.05, contrast=2.0, dither=False)
    c.paint(face & (c.yy >= fy + 8), PANEL, 0.36 + 0.1 * (grain - 0.5) - 0.14 * (((c.xx - 4) % 8) == 7), dither=False)
    dx0, dx1 = 144, 160  # the doorway: room column 9 (the map cell 13), on the axis of the counter window and the banner
    c.paint(c.rect(dx0 - 2, fy, dx0, ROOM_H), BEAM, 0.6, dither=False)
    c.paint(c.rect(dx1, fy, dx1 + 2, ROOM_H), BEAM, 0.6, dither=False)
    c.paint(c.rect(dx0 - 2, fy, dx1 + 2, fy + 3), BEAM, 0.8, dither=False)
    leaf = c.rect(dx0, fy + 3, dx1, ROOM_H - 1)
    plank = ((c.xx - dx0) // 4).astype(int)
    pv = 0.5 + 0.08 * (((plank * 7 + 3) % 5) / 4.0 - 0.5) + 0.16 * (grain - 0.5)
    pv = np.where(((c.xx - dx0) % 4) == 3, 0.1, np.where(((c.xx - dx0) % 4) == 0, pv + 0.1, pv))
    c.paint(leaf, PANEL, pv, dither=False)
    for sy in (fy + 5, fy + 12):
        c.paint(c.rect(dx0, sy, dx0 + 7, sy + 2), IRON, 0.65, dither=False)
    c.paint(c.rect(dx1 - 5, fy + 8, dx1 - 2, fy + 11), BRASS, 0.8, dither=False)  # a round handle
    return c


# --------------------------------------------------------------------------- furniture
def counter(ms):
    """The counter across the hall, eighteen cells wide: a front of panels, a lit top, a brass grille above it with a
    window three cells wide in the middle (cells 12 to 14 of the map: the clerk stands in it), a hand bell and a little
    plate on the sill, a row of plan strips on the left, forms in colour order on the right. 288 x 44, anchor (8, 40):
    the prop stands in the left cell of the row and the front's lower edge lies on that cell's centre line."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(288, 44)
    fy0, fy1 = 28, 40  # the front
    grain = pa.value_noise(44, 288, (1, 10), np.random.default_rng(481))
    front = c.rect(0, fy0, 288, fy1)
    panel = ((c.xx // 24) % 2).astype(int)
    c.paint(front, PANEL, 0.46 + 0.06 * panel + 0.1 * (grain - 0.5) - 0.2 * ((c.yy - fy0) / 12.0), dither=False)
    for gx in range(0, 288, 24):  # the panel frames: a groove at both ends of each
        c.paint(c.rect(gx, fy0, gx + 1, fy1), PANEL, 0.1, dither=False)
        c.paint(c.rect(gx + 3, fy0 + 2, gx + 21, fy0 + 3), PANEL, 0.78, dither=False)
        c.paint(c.rect(gx + 3, fy1 - 3, gx + 21, fy1 - 2), PANEL, 0.18, dither=False)
    c.paint(c.rect(0, fy1 - 1, 288, fy1), PANEL, 0.08, dither=False)
    top = c.rect(0, 22, 288, fy0)
    c.paint(top, PANEL, np.where(c.yy < 24, 0.98, 0.78) - 0.06 * (grain > 0.7), dither=False)
    c.paint(c.rect(0, fy0 - 1, 288, fy0), PANEL, 0.3, dither=False)  # the lower edge of the top
    # the grille behind the counter's edge (drawn on a canvas of its own and put under the counter, so the thin bars get
    # no outline): slim brass bars every six pixels with a rail at the top and one low, the window (px 112 to 160) open
    g = ms.Canvas(288, 44)
    for x in range(1, 288, 6):
        if 110 <= x < 162:
            continue
        g.paint(g.rect(x, 7, x + 1, 22), BRONZE, 0.55, dither=False)
        g.paint(g.rect(x, 7, x + 1, 9), BRONZE, 0.9, dither=False)
    for x0, x1 in ((0, 112), (160, 288)):
        g.paint(g.rect(x0, 5, x1, 7), BRONZE, np.where(g.yy < 6, 0.95, 0.4), dither=False)
        g.paint(g.rect(x0, 14, x1, 15), BRONZE, 0.35, dither=False)
        g.paint(g.rect(x0, 21, x1, 22), BRONZE, 0.3, dither=False)
    for px in (110, 160):  # the posts that frame the window: open at the top, so the clerk's head is not cut by a bar
        g.paint(g.rect(px, 4, px + 3, 22), BRONZE, np.where(g.xx == px, 0.95, 0.45), dither=False)
        g.paint(g.rect(px - 1, 3, px + 4, 5), BRONZE, 0.95, dither=False)
    # on the counter: a hand bell at the window, a little blank plate, plan strips on the left, forms in colour order
    bell = c.ellipse(150, 21, 3.4, 3.0) & (c.yy < 24)
    c.paint(bell, BRASS, 0.3 + 0.7 * c.sphere(149, 19, 4, 4), dither=False)
    c.paint(c.rect(149, 17, 151, 19), BRASS, 0.9, dither=False)
    c.paint(c.rect(120, 23, 134, 27), BRONZE, np.where(c.yy < 24, 0.95, 0.5), dither=False)
    for k, color in enumerate((YELLOW, PINK, BLUE, GREEN)):
        x = 172 + k * 10
        c.paint(c.rect(x, 22, x + 8, 26), color, np.where(c.yy < 23, 0.95, 0.55), dither=False)
        c.paint(c.rect(x + 1, 25, x + 7, 26), color, 0.25, dither=False)
    for k in range(5):
        x = 14 + k * 9
        c.paint(c.rect(x, 22, x + 7, 24 + (k % 2)), PAPER, 0.9 - 0.12 * (k % 2), dither=False)
        c.paint(c.rect(x, 24 + (k % 2), x + 7, 26), PAPER, 0.4, dither=False)
    c.outline(st["outline"])
    g.blit(c, 0, 0)
    return g


def shelf(ms, kind):
    """Shelves against the back wall, three cells wide, three boards. kind "lost": the lost-property shelf of the town,
    an umbrella leaning in a corner, one boot, a hat on a hat stand, a birdcage with nothing in it, a scarf, a lantern,
    a stack of boxes; every piece has a paper tag on a string (blank) and four places on the boards are left empty:
    the top board at x 8 to 20 (the glove, 16 x 16 canvas in the cell column 5), the middle board at x 6 to 18 (the tin)
    and x 22 to 30 (the key), the bottom board at x 22 to 32 (the cup). "records": ledgers and folders with spines in
    colour order, a stack of forms, an inkwell, the most orderly shelf there is, with one folder pushed in upside down.
    48 x 48, anchor (8, 44): the boards' surfaces lie at y 16, 31 and 44."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(491 if kind == "lost" else 493)
    c = ms.Canvas(48, 48)
    grain = pa.value_noise(48, 48, (1, 6), rng)
    # frame, back, boards
    c.paint(c.rect(0, 0, 48, 46), PANEL, 0.2, dither=False)
    c.paint(c.rect(3, 4, 45, 44), PANEL, 0.1 + 0.05 * (grain - 0.5), dither=False)  # the dark back
    for y in (16, 31, 44):
        c.paint(c.rect(0, y, 48, y + 3), PANEL, np.where(c.yy < y + 1, 0.95, 0.55), dither=False)
    c.paint(c.rect(0, 0, 48, 4), PANEL, np.where(c.yy < 1, 0.98, 0.7), dither=False)
    for px in (0, 45):
        c.paint(c.rect(px, 0, px + 3, 46), PANEL, np.where((c.xx - px) < 1, 0.8, 0.5), dither=False)
    c.paint(c.rect(0, 46, 48, 48), PANEL, 0.12, dither=False)
    if kind == "lost":
        # top board: the umbrella leaning in the left corner is not here: the glove's place is x 8..20; right side: a hat on
        # a stand, and a lantern
        c.paint(c.rect(26, 10, 28, 16), LEATHER, 0.4, dither=False)  # the hat stand's foot
        c.paint(c.ellipse(27, 8.5, 6.5, 1.8), FELT, 0.4 + 0.4 * (c.xx < 27), dither=False)  # the hat's brim
        c.paint(c.ellipse(27, 6.5, 3.6, 3.0) & (c.yy < 8), FELT, 0.5 + 0.4 * c.sphere(25, 5, 5, 4), dither=False)
        c.paint(c.rect(23, 7, 31, 8), FELT, 0.15, dither=False)
        lan = c.rect(35, 7, 41, 16)
        c.paint(lan, IRON, 0.25 + 0.4 * c.cylinder(34, 42), dither=False)
        c.paint(c.rect(36, 9, 40, 14), BRASS, 0.7 - 0.3 * (c.xx > 38), dither=False)
        c.paint(c.rect(34, 6, 42, 8), IRON, 0.6, dither=False)
        c.paint(c.rect(37, 4, 39, 6), IRON, 0.8, dither=False)
        # middle board: one boot (the tin's place is x 6..18 and the key's x 22..30), a rolled scarf at the right
        c.paint(c.rect(33, 21, 38, 31), LEATHER, 0.35 + 0.5 * c.cylinder(32, 39), dither=False)  # the leg of the boot
        c.paint(c.rect(33, 27, 43, 31), LEATHER, 0.3 + 0.4 * (c.yy < 29), dither=False)  # the foot
        c.paint(c.rect(33, 21, 38, 22), LEATHER, 0.9, dither=False)
        c.paint(c.ellipse(41.5, 28, 2.5, 2.8) & (c.xx > 40), RED_WOOL, 0.55, dither=False)
        # bottom board: a stack of boxes on the left, a birdcage (nothing in it) on the right
        for k, (w, y0) in enumerate(((11, 38), (9, 33))):
            c.paint(c.rect(4, y0, 4 + w, y0 + (44 - 38 if k == 0 else 5)), CLAY, np.where(c.yy < y0 + 1, 0.95, 0.55 - 0.12 * k), dither=False)
        cage = c.ellipse(38, 35.5, 5.5, 5.0) & (c.yy < 44)
        c.paint(cage & ~c.ellipse(38, 35.5, 4.2, 3.8), BRASS, 0.7, dither=False)
        for bx in (34, 36, 38, 40, 42):
            c.paint(c.rect(bx, 31, bx + 1, 44), BRASS, 0.5, dither=False)
        c.paint(c.rect(33, 41, 44, 44), BRASS, 0.55, dither=False)
        c.paint(c.rect(37, 29, 39, 31), BRASS, 0.9, dither=False)
        c.paint(c.rect(37, 38, 39, 39), BRASS, 0.95, dither=False)  # the perch
        # the paper tags on strings: one hangs from the front of every board, a few from the pieces
        for tx, ty in ((22, 18), (11, 33), (30, 33), (13, 46)):
            c.fill(c.rect(tx, ty - 1, tx + 1, ty + 1), CORD_ROPE[1])
            c.paint(c.rect(tx - 1, ty + 1, tx + 3, ty + 4), PAPER, 0.85, dither=False)
    else:
        # ledgers and folders with spines in colour order (the colours of the notes), a stack of forms, an inkwell, one
        # folder pushed in upside down
        order = (YELLOW, PINK, BLUE, GREEN)
        x = 4
        for k in range(10):
            w = 3 + (k % 3 == 0)
            color = order[min(k * 4 // 10, 3)]
            h = 11 - (k % 4 == 1) * 2
            c.paint(c.rect(x, 16 - h, x + w, 16), color, np.where(c.xx == x, 0.9, 0.55 - 0.15 * (c.xx >= x + w - 1)), dither=False)
            c.paint(c.rect(x, 16 - h + 2, x + w, 16 - h + 3), PAPER, 0.7, dither=False)
            x += w
        x = 4
        for k in range(8):
            w = 4
            color = order[min(k * 4 // 8, 3)]
            h = 12 - (k % 3 == 2) * 3
            if k == 5:
                c.paint(c.rect(x, 31 - h, x + w, 31), color, 0.4, dither=False)  # the upside-down one: its spine is blank
                c.paint(c.rect(x, 31 - h, x + w, 31 - h + 2), PAPER, 0.8, dither=False)
            else:
                c.paint(c.rect(x, 31 - h, x + w, 31), color, np.where(c.xx == x, 0.9, 0.55 - 0.15 * (c.xx >= x + w - 1)), dither=False)
                c.paint(c.rect(x, 31 - h + 3, x + w, 31 - h + 4), PAPER, 0.7, dither=False)
            x += w + (k % 2)
        for k in range(5):  # a leaning stack of forms
            c.paint(c.rect(36 + (k % 2), 28 - k * 2, 44 + (k % 2), 30 - k * 2), PAPER, 0.9 - 0.15 * (k % 2), dither=False)
        ink = c.ellipse(31, 27.5, 2.8, 2.6) & (c.yy < 31)
        c.paint(ink, INK, 0.3 + 0.6 * c.sphere(30, 26, 3.4, 3.4), dither=False)
        c.paint(c.rect(30, 24, 32, 25), INK, 0.85, dither=False)  # the neck of the bottle
        c.fill(c.rect(31, 17, 32, 24), PAPER[3])  # a quill
        c.fill(c.rect(32, 17, 33, 20), PAPER[1])
        for k in range(8):
            w = 4
            color = order[(k + 1) % 4]
            c.paint(c.rect(4 + k * 5, 44 - 9, 4 + k * 5 + w, 44), color, np.where(c.xx == 4 + k * 5, 0.9, 0.5), dither=False)
        c.paint(c.rect(4, 44 - 9, 44, 44 - 8), PANEL, 0.2, dither=False)
    c.outline(st["outline"])
    return c


def desk(ms):
    """A desk seen from the front, three cells wide: a lit top with the ink pad (violet), a stamp rack with a lot of stamps
    (a row of wooden knobs, every one in its place), three stacks of paper, a lamp and a pen in a cup; two drawers with
    brass knobs. 48 x 44, anchor (8, 40) (the prop stands in the left cell of its row)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(48, 44)
    grain = pa.value_noise(44, 48, (1, 8), np.random.default_rng(501))
    c.paint(c.rect(0, 30, 48, 40), PANEL, 0.46 + 0.1 * (grain - 0.5) - 0.18 * ((c.yy - 30) / 10.0), dither=False)
    c.paint(c.rect(0, 22, 48, 30), PANEL, np.where(c.yy < 24, 0.98, 0.8), dither=False)
    c.paint(c.rect(0, 29, 48, 30), PANEL, 0.3, dither=False)
    for dx0 in (3, 25):  # drawers with brass knobs
        c.paint(c.rect(dx0, 32, dx0 + 20, 38), PANEL, 0.62 - 0.2 * ((c.yy - 32) / 6.0), dither=False)
        c.paint(c.rect(dx0, 32, dx0 + 20, 33), PANEL, 0.9, dither=False)
        c.paint(c.rect(dx0 + 8, 34, dx0 + 12, 36), BRASS, 0.85, dither=False)
    # on top: the ink pad with a stamp pressed to it, the rack of stamps behind, the stacks of paper, the lamp
    c.paint(c.rect(6, 23, 18, 28), FELT, 0.4, dither=False)
    c.paint(c.rect(7, 24, 17, 27), INK, 0.55 + 0.25 * (c.yy < 25), dither=False)
    c.paint(c.rect(10, 19, 14, 24), PANEL, 0.8, dither=False)  # the stamp on the pad, its handle
    c.paint(c.rect(9, 17, 15, 20), PANEL, 0.95, dither=False)
    c.paint(c.rect(22, 21, 34, 24), PANEL, 0.35, dither=False)  # the rack: a bar with a row of stamps standing in it
    for k in range(6):
        sx = 23 + k * 2
        c.paint(c.rect(sx, 15 + (k % 2), sx + 1, 21), PANEL, 0.8 - 0.2 * (k % 2), dither=False)
        c.paint(c.rect(sx, 14 + (k % 2), sx + 2, 16 + (k % 2)), PANEL, 0.95, dither=False)
    for k, (x, n) in enumerate(((37, 4), (40, 6), (43, 3))):  # three stacks of different height
        for j in range(n):
            c.paint(c.rect(x, 24 - j * 2, x + 4, 26 - j * 2), PAPER, 0.92 - 0.2 * (j % 2), dither=False)
    c.paint(c.rect(1, 21, 4, 24), PANEL, 0.4, dither=False)  # the pen cup
    c.fill(c.rect(2, 16, 3, 22), PAPER[4])
    c.fill(c.rect(1, 17, 2, 21), STAMP_RED[2])
    c.paint(c.rect(0, 40, 48, 42), PANEL, 0.1, dither=False)
    c.outline(st["outline"])
    return c


def chair(ms, kind=0):
    """A waiting chair seen from the side, looking west: a plain wooden seat with a high back on the east side. 16 x 24,
    anchor (8, 20). The room has four places on the east wall and three chairs (kind 1 is the chair with one leg a little
    short that wobbles: no, the same chair; the fourth place is a dent in the floor, rh_dents)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 24)
    wood = PANEL
    c.paint(c.rect(11, 2, 14, 20), wood, np.where(c.xx < 12, 0.8, 0.45), dither=False)  # the back post
    for y in (4, 9):
        c.paint(c.rect(11, y, 14, y + 2), wood, 0.95 - 0.2 * (y > 5), dither=False)
    c.paint(c.rect(3, 12, 14, 15), wood, np.where(c.yy < 13, 0.98, 0.62), dither=False)  # the seat
    for lx in (4, 12):
        c.paint(c.rect(lx, 15, lx + 2, 20), wood, np.where(c.xx == lx, 0.55, 0.28), dither=False)
    c.paint(c.rect(4, 17, 13, 18), wood, 0.2, dither=False)  # the stretcher
    c.outline(st["outline"])
    return c


def dents(ms):
    """Where the fourth chair stood: four pale dents in the floor and one dark rub mark, nothing else. 16 x 16, anchor
    (8, 8). Flat, no shadow."""
    c = ms.Canvas(16, 16)
    for dx, dy in ((4, 4), (11, 4), (4, 11), (11, 11)):
        c.paint(c.ellipse(dx, dy, 1.6, 1.2), PANEL, 0.1, dither=False)
        c.paint(c.rect(dx - 1, dy - 1, dx, dy), PANEL, 0.6, dither=False)
    return c


def bin_(ms):
    """A waste-paper bin of woven cane full of crumpled paper, a ball on the rim and one on the floor. 20 x 22, anchor (10, 19)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(20, 22)
    body = c.rect(3, 9, 17, 19) & ~((c.yy > 16) & ((c.xx < 4) | (c.xx > 15)))
    weave = ((c.xx.astype(int) + c.yy.astype(int)) % 2) == 0
    c.paint(body, ramp("#4a3010", "#7e5a20", "#b88a38", "#e0b860"), np.where(weave, 0.55, 0.38) + 0.3 * c.cylinder(2, 18), dither=False)
    c.paint(c.rect(3, 9, 17, 11), ramp("#4a3010", "#7e5a20", "#b88a38", "#e0b860"), np.where(c.yy < 10, 0.95, 0.6), dither=False)
    for (x, y, r) in ((7, 8, 3.2), (11, 7, 3.4), (14, 8.5, 2.8), (9.5, 5, 2.6)):
        c.paint(c.ellipse(x, y, r, r), PAPER, 0.3 + 0.5 * c.sphere(x - 1, y - 1.5, r + 1, r + 1), dither=False)
        c.fill(c.rect(round(x), round(y) - 1, round(x) + 1, round(y)), PAPER[0])
        c.fill(c.rect(round(x) - 2, round(y), round(x), round(y) + 1), PAPER[0])
    c.paint(c.ellipse(18.5, 19.5, 2.2, 2.0), PAPER, 0.4 + 0.4 * c.sphere(17.5, 18.5, 3, 3), dither=False)
    c.outline(st["outline"])
    return c


def runner(ms):
    """A runner from the door to the counter, five cells long: slate blue with a terracotta border and a pale worn strip in
    the middle where everyone walks, fringe at both ends, one stain. 16 x 80, anchor (8, 8): it lies flat on the floor of
    the five cells in front of the counter, a little narrower than the cell so the planks show on both sides."""
    rng = np.random.default_rng(511)
    c = ms.Canvas(16, 80)
    body = c.rect(1, 1, 15, 79)
    weave = ((c.xx.astype(int) + (c.yy.astype(int) // 2)) % 2) == 0
    worn = np.exp(-((c.xx + 0.5 - 8) / 2.6) ** 2)
    c.paint(body, SLATE, 0.46 + 0.07 * weave + 0.28 * worn * (0.6 + 0.5 * pa.value_noise(80, 16, 3, rng)) - 0.06 * (c.xx > 11), dither=False)
    border = body & ((c.xx < 3) | (c.xx >= 13))
    c.paint(border, TERRACOTTA, 0.5 + 0.08 * weave - 0.14 * (c.xx >= 13), dither=False)
    c.paint(body & ((c.xx == 3) | (c.xx == 12)), PAPER, 0.5, dither=False)
    for y in (0, 79):
        for x in range(1, 15, 2):
            c.fill(c.rect(x, y, x + 1, y + 1), PAPER[1] if (x // 2) % 2 else PAPER[2])
    c.paint(c.ellipse(9.5, 47, 2.4, 1.8), SLATE, 0.14, dither=True)  # a stain
    return c


def plant(ms):
    """A fern in a terracotta pot, the one plant of the hall that is not in order: a frond hangs over the rim, one has gone
    brown, and a stick holds a paper label with nothing on it. 20 x 28, anchor (10, 24)."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(521)
    c = ms.Canvas(20, 28)
    fern = ramp("#12301c", "#1f4c2a", "#33743a", "#58a050", "#8cd070")
    pot = c.rect(4, 17, 16, 25) & ~((c.yy > 22) & ((c.xx < 5) | (c.xx > 14)))
    c.paint(pot, TERRACOTTA, 0.3 + 0.7 * c.cylinder(3, 17), dither=False)
    c.paint(c.rect(3, 16, 17, 19), TERRACOTTA, np.where(c.yy < 17, 0.98, 0.6), dither=False)
    for k, (ang, ln, col) in enumerate(((-1.25, 12, fern), (-0.75, 13, fern), (-0.3, 14, fern), (0.15, 14, fern), (0.65, 13, fern),
                                        (1.2, 11, fern))):
        x1, y1 = 10 + np.sin(ang) * ln * 0.75, 17 - np.cos(ang) * ln
        frond = seg(c, 10, 17, x1, y1, 0.8)
        c.paint(frond, col, 0.4 + 0.5 * (1 - (c.yy - y1) / max(17 - y1, 1)), dither=False)
        for t in np.linspace(0.35, 1.0, 4):  # leaflets
            lx, ly = 10 + (x1 - 10) * t, 17 + (y1 - 17) * t
            c.paint(c.rect(lx - 2, ly, lx + 2, ly + 1), col, 0.55, dither=False)
    brown = ramp("#3a2410", "#6a4a20", "#9a7a38", "#c4a45a")
    c.paint(seg(c, 10, 17, 3.5, 7, 0.8), brown, 0.5, dither=False)  # the dead frond
    c.paint(seg(c, 10, 17, 17.5, 20.5, 0.8) & (c.yy < 24), fern, 0.45, dither=False)  # the one that hangs over the rim
    c.fill(c.rect(14, 12, 15, 20), PAPER[2])  # the stick
    c.paint(c.rect(13, 10, 18, 14), PAPER, 0.9, dither=False)  # the blank label
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the lost things (16 x 16, anchor (8, 16))
def glove(ms):
    """A lost glove in dull red wool, fingers a little spread, a darker cuff, lying on its back. 16 x 16, anchor (8, 16)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 16)
    palm = c.ellipse(8, 11.5, 3.6, 3.2)
    c.paint(palm, RED_WOOL, 0.35 + 0.6 * c.sphere(7, 10, 5, 4.5), dither=False)
    for k, (fx, top_y, w) in enumerate(((5, 5, 1.7), (7, 4, 1.7), (9, 4, 1.7), (11.4, 5.4, 1.6))):
        finger = c.rect(fx - w / 2, top_y, fx + w / 2, 11)
        c.paint(finger, RED_WOOL, 0.5 + 0.35 * (c.xx < fx), dither=False)
    c.paint(c.rect(3, 10, 5, 12) | c.ellipse(4, 11.5, 2.0, 1.4), RED_WOOL, 0.55, dither=False)  # the thumb
    c.paint(c.rect(5.5, 13, 11, 15), RED_WOOL, np.where(c.yy < 14, 0.28, 0.15), dither=False)  # the cuff
    c.paint(c.rect(5.5, 13, 11, 14), RED_WOOL, 0.85, dither=False)
    c.fill(c.rect(7, 8, 8, 9), RED_WOOL[3])  # one loose thread end
    c.outline(st["outline"])
    return c


def brass_key(ms):
    """A big brass key lying on the board: a round bow, a shaft and two teeth. 16 x 16, anchor (8, 16)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 16)
    bow = c.ellipse(4.5, 12.2, 3.0, 2.8) & ~c.ellipse(4.5, 12.2, 1.2, 1.1)
    c.paint(bow, BRASS, 0.4 + 0.6 * c.sphere(3.5, 11, 4, 4), dither=False)
    c.paint(c.rect(7, 11.5, 14, 13.5), BRASS, np.where(c.yy < 12.5, 0.95, 0.5), dither=False)
    c.paint(c.rect(11, 13.5, 13, 15.5), BRASS, 0.6, dither=False)
    c.paint(c.rect(13, 13.5, 14.5, 14.8), BRASS, 0.5, dither=False)
    c.outline(st["outline"])
    return c


def button_tin(ms):
    """A round tin of buttons: the lid is off and leans on the tin, a few buttons of every colour lie in front. 16 x 16, anchor (8, 16)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 16)
    body = c.ellipse(7, 12.5, 5.6, 3.0) | c.rect(1.4, 9, 12.6, 12.5)
    body &= c.yy < 15.6
    c.paint(body, TIN, 0.35 + 0.6 * c.cylinder(0.5, 13.5), dither=False)
    c.paint(c.rect(1.4, 9, 12.6, 10.5), TIN, 0.9, dither=False)  # rim
    c.paint(c.ellipse(7, 9.2, 5.2, 1.7), ramp("#201208", "#3a2412", "#5c3c20"), 0.5, dither=False)  # the inside
    for k, (bx, by, col) in enumerate(((5.5, 8.8, YELLOW), (8, 8.4, PINK), (9.5, 9.2, GREEN))):
        c.paint(c.ellipse(bx, by, 1.4, 1.1), col, 0.8, dither=False)
    lid = (np.abs(c.xx + 0.5 - 13.0) < 1.4) & (c.yy >= 5.5) & (c.yy < 14.5)
    c.paint(lid, TIN, 0.25 + 0.6 * (c.xx < 13.0), dither=False)
    for bx, by, col in ((2.5, 14.5, BLUE), (9.5, 15, TERRACOTTA)):
        c.paint(c.ellipse(bx, by, 1.3, 0.9), col, 0.75, dither=False)
        c.fill(c.rect(round(bx) - 1, round(by) - 1, round(bx), round(by)), PAPER[4])
    c.rgb = np.roll(c.rgb, 1, axis=1)  # one pixel to the right: it lies clear of the post of the shelf
    c.a = np.roll(c.a, 1, axis=1)
    c.outline(st["outline"])
    return c


def cracked_cup(ms):
    """A cup of cream glaze with a blue band and a crack from the rim down to the foot, a handle on the right. 16 x 16, anchor (8, 16)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 16)
    cup = c.rect(3, 6, 11, 15) & ~((c.yy > 13) & ((c.xx < 4) | (c.xx > 9)))
    c.paint(cup, CREAM, 0.4 + 0.6 * c.cylinder(2, 12), dither=False)
    c.paint(c.rect(3, 6, 11, 7.5), CREAM, 0.98, dither=False)
    c.paint(c.rect(3, 9, 11, 10.5), TIN, 0.5 + 0.3 * (c.xx < 7), dither=False)
    c.paint(c.ellipse(7, 7, 3.2, 0.9), ramp("#201208", "#3a2412", "#5c3c20"), 0.4, dither=False)  # the inside
    handle = (np.abs(np.hypot(c.xx + 0.5 - 12, (c.yy + 0.5 - 10) * 1.15) - 2.6) < 0.8) & (c.xx > 10.5)
    c.paint(handle, CREAM, 0.55, dither=False)
    crack = [(7, 7), (7, 8), (6, 9), (6, 10), (7, 11), (7, 12), (6, 13), (6, 14)]  # the crack, down to the foot
    for x, y in crack:
        c.fill(c.rect(x, y, x + 1, y + 1), np.array([40, 28, 24], np.float32))
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- registration
def build(ms):
    """Registers the sprites of the town hall in the catalog. The shell is flat; the furniture stands with the lower edge
    of its front on the centre line of its cell; the four lost things are conditional (the map hides them with `unless`)
    and the dents lie flat: none of these casts a baked shadow."""
    ms.save("tal", "rh_shell", shell(ms), (8, 8), flat=True)
    ms.save("tal", "rh_counter", counter(ms), (8, 40), shape={"rect": [288, 12], "offset": [136, -6]})
    ms.save("tal", "rh_shelf_lost", shelf(ms, "lost"), (8, 44), shape={"rect": [48, 8], "offset": [16, -4]}, shadow=[24, 3])
    ms.save("tal", "rh_shelf_records", shelf(ms, "records"), (8, 44), shape={"rect": [48, 8], "offset": [16, -4]}, shadow=[24, 3])
    ms.save("tal", "rh_desk", desk(ms), (8, 40), shape={"rect": [48, 12], "offset": [16, -6]}, shadow=[24, 3])
    ms.save("tal", "rh_chair", chair(ms), (8, 20), shape={"rect": [12, 6], "offset": [0, -3]}, shadow=[7, 2])
    ms.save("tal", "rh_dents", dents(ms), (8, 8), flat=True)
    ms.save("tal", "rh_bin", bin_(ms), (10, 19), shape={"circle": 6, "offset": [0, -4]}, shadow=[8, 2])
    ms.save("tal", "rh_plant", plant(ms), (10, 24), shape={"circle": 6, "offset": [0, -3]}, shadow=[8, 2])
    ms.save("tal", "rh_runner", runner(ms), (8, 8), flat=True)
    ms.save("tal", "rh_glove", glove(ms), (8, 16))
    ms.save("tal", "rh_key", brass_key(ms), (8, 16))
    ms.save("tal", "rh_buttons", button_tin(ms), (8, 16))
    ms.save("tal", "rh_cup", cracked_cup(ms), (8, 16))


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    sheet = Image.new("RGBA", (ROOM_W + 20, ROOM_H + 130), (96, 120, 100, 255))
    shell_img = Image.fromarray(shell(ms).rgba().astype(np.uint8), "RGBA")
    floor = Image.new("RGBA", (ROOM_W, ROOM_H), (120, 84, 56, 255))
    sheet.alpha_composite(floor, (10, 10))
    sheet.alpha_composite(shell_img, (10, 10))
    x, y = 10, ROOM_H + 20
    for item in (shelf(ms, "lost"), shelf(ms, "records"), desk(ms), chair(ms), dents(ms), bin_(ms), plant(ms), glove(ms),
                 brass_key(ms), button_tin(ms), cracked_cup(ms), runner(ms)):
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, y))
        x += img.width + 8
    counter_img = Image.fromarray(counter(ms).rgba().astype(np.uint8), "RGBA")
    sheet.alpha_composite(counter_img, (10, ROOM_H + 78))
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
