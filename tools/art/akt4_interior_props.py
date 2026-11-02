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

Akt IV, S3 adds the florist's shop (prefix `fo_`, below the town hall's pieces, registered by `build_florist`): a small warm room, cream
plaster over a sage-green wainscot, honey wood, zinc and terracotta; the shell with a window to the lane, the binding table, the dried
bunch of peonies that hangs head down from the drying rail, two shelves, two rows of buckets with cut flowers, a big plant, a watering
can and a chest of drawers. The map content/maps/blumenladen.txt is 26 x 18 cells, the room are the cells 4 to 21 and 3 to 14 (18 x 12).
`--preview-florist out.png` draws the shell and all eight pieces (3x).

Akt IV, S4 adds the workshop (prefix `wk_`, below the florist's pieces, registered by `build_workshop`): raw pine, weathered boards, iron and
leather, sawdust; the shell with a window to the lane, a crossbeam with a tape measure, the plan of the house and the wall of small tools, the
work bench (five cells), two trestles with the board across them (the board is a prop of its own: it is gone once it is sawn), the unfinished
ladder, the saws on their board (the largest one is missing from its chalk outline), the rack of boards, a stool and the sawdust with two
kinds of footprints in it. The map content/maps/werkstatt.txt is 26 x 18 cells, the room are the cells 4 to 21 and 3 to 14 (18 x 12).
`--preview-workshop out.png` draws the shell and all nine pieces (3x).
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


# =========================================================================== S3: the florist's shop (prefix `fo_`)
# A small warm room where a man who looks like a warrior keeps flowers: cream plaster over a sage-green wainscot, honey wood, zinc
# and terracotta, a window to the lane with the house across it. Nothing here is a weapon and nothing is explained.
FO_W, FO_H = 288, 192  # 18 x 12 cells; the room's top left cell is the map cell (4, 3)

SAGE = ramp("#1c2e26", "#30503f", "#4c7658", "#74a27c")  # the painted wainscot
LEAF = ramp("#16301c", "#24502a", "#388040", "#5ca458")
LEAF_PALE = ramp("#2a4a30", "#4a7448", "#78a468", "#a8cc88")
ZINC = ramp("#2a2e34", "#4a5058", "#7a828c", "#aab2bc", "#d4dae0")
DRIED_ROSE = ramp("#4e2c34", "#84525c", "#b4838c", "#d9b0b6", "#f2dadc")
RAFFIA = ramp("#6a5a34", "#a08c58", "#cdb97c", "#efe3b4")
KRAFT = ramp("#4a3220", "#7a5a38", "#a88252", "#d0aa74")
LAVENDER = ramp("#3a2e5a", "#6a58a0", "#9a88d0", "#c8bcf0")
WHITE_BLOOM = ramp("#7a7480", "#b8b2bc", "#e8e4ec", "#ffffff")
TULIP = ramp("#5a1410", "#a02a1e", "#d8503a", "#f58c6a")
OCHRE = ramp("#4a3a1e", "#7a6234", "#a88a4e", "#cdb06e", "#e8d498")
SOIL = ramp("#1e140e", "#33241a", "#4e3a28", "#6e5640")
SHUTTER_DARK = ramp("#14221e", "#223e36", "#366256", "#548a76")
STRAW_S = ramp("#4e3a14", "#80601e", "#b48c30", "#dcb84e")


def _wood_tal(c, mask, v, contrast=2.0):
    """Honey wood of the valley: the shelves, the table, the chest."""
    c.paint(mask, pa.STYLES["tal"]["wood"], v, contrast=contrast, dither=False)


def _fo_window(c, x0, y0, x1, y1):
    """The window to the lane: morning light, across the lane an ochre house with a terracotta roof edge and a shuttered window,
    a strip of cobbles below, a mullion cross in cream-painted wood and a sill with three small pots on it."""
    pane = c.rect(x0, y0, x1, y1)
    t = np.clip((c.yy - y0) / (y1 - y0), 0, 1)
    c.paint(pane, GLASS, 0.98 - 0.35 * t, contrast=1.6, dither=False)
    c.paint(c.ellipse(x0 + 17, y0 + 4, 4.5, 1.5) & pane, GLASS, 1.0, dither=False)  # a smudge of cloud
    house = pane & (c.yy >= y0 + 7)
    c.paint(house, OCHRE, 0.5 + 0.14 * (c.xx < x0 + 12), dither=False)
    roof = pane & (c.yy >= y0 + 5) & (c.yy < y0 + 9) & (c.yy >= y0 + 5 + np.clip((c.xx - x0) * 0.04, 0, 2))
    c.paint(roof, TERRACOTTA, 0.62 - 0.18 * (c.yy >= y0 + 7), dither=False)
    c.paint(c.rect(x0 + 6, y0 + 10, x0 + 12, y0 + 17) & pane, SHUTTER_DARK, 0.5, dither=False)  # the window across the lane
    c.paint(c.rect(x0 + 7, y0 + 11, x0 + 11, y0 + 16) & pane, GLASS, 0.5, dither=False)
    c.paint(c.rect(x0 + 5, y0 + 10, x0 + 6, y0 + 17) & pane, SHUTTER_DARK, 0.9, dither=False)
    c.paint(c.rect(x0 + 12, y0 + 10, x0 + 13, y0 + 17) & pane, SHUTTER_DARK, 0.9, dither=False)
    c.paint(pane & (c.yy >= y1 - 4), ramp("#38363a", "#535056", "#716d70", "#94908c"), 0.35 + 0.2 * (((c.xx.astype(int) // 3) + (c.yy.astype(int) // 2)) % 2), dither=False)
    mid_x, mid_y = (x0 + x1) // 2, (y0 + y1) // 2
    frame = pa.STYLES["tal"]["wood"]
    c.paint(c.rect(x0 - 2, y0 - 2, x1 + 2, y0), CREAM, 0.95, dither=False)  # the frame, painted cream
    c.paint(c.rect(x0 - 2, y1, x1 + 2, y1 + 2), CREAM, 0.6, dither=False)
    c.paint(c.rect(x0 - 2, y0, x0, y1), CREAM, 0.8, dither=False)
    c.paint(c.rect(x1, y0, x1 + 2, y1), CREAM, 0.5, dither=False)
    c.paint(c.rect(mid_x - 1, y0, mid_x + 1, y1), CREAM, np.where(c.xx < mid_x, 0.85, 0.5), dither=False)
    c.paint(c.rect(x0, mid_y - 1, x1, mid_y + 1), CREAM, np.where(c.yy < mid_y, 0.9, 0.5), dither=False)
    c.paint(c.rect(x0 - 4, y1 + 2, x1 + 4, y1 + 5), frame, np.where(c.yy < y1 + 3, 0.95, 0.5), dither=False)  # the sill
    for k, (px, kind) in enumerate(((x0 + 1, 0), (x0 + 10, 1), (x0 + 19, 0))):  # three small pots on the sill
        c.paint(c.rect(px, y1 - 1, px + 6, y1 + 2), TERRACOTTA, np.where(c.xx < px + 3, 0.75, 0.4), dither=False)
        c.paint(c.rect(px - 1, y1 - 2, px + 7, y1 - 1), TERRACOTTA, 0.9, dither=False)
        for j in range(3):
            c.paint(seg(c, px + 3, y1 - 2, px + 3 + (j - 1) * 3, y1 - 6 - (j % 2), 0.8), LEAF, 0.5 + 0.2 * j, dither=False)
        if kind:
            c.fill(c.rect(px + 2, y1 - 8, px + 5, y1 - 6), PINK[2])


def _bunch(c, x, y, rng, tones):
    """A small bunch of herbs drying on the rail, hanging head down: a cord, a bast tie, a fan of stems and a few heads."""
    c.fill(c.rect(x, y, x + 1, y + 3), RAFFIA[1])
    c.fill(c.rect(x - 1, y + 3, x + 2, y + 4), RAFFIA[3])
    for k in range(5):
        sx = x - 2 + k
        c.fill(c.rect(sx, y + 4, sx + 1, y + 10 + (k % 2)), STRAW_S[2])
    for k, tone in enumerate(tones):
        hx = x - 3 + k * 2
        hy = y + 10 + (k % 2) * 2
        c.paint(c.ellipse(hx + 0.5, hy + 1.5, 1.7, 2.4), tone, 0.55 + 0.25 * (k % 2), dither=False)
        c.fill(c.rect(hx, hy, hx + 1, hy + 1), tone[3])


def _plaque(c, x0, y0, x1, y1):
    """A small hanging sign: a board with rounded corners on two short cords from nails, a pink peony painted on it. No letters."""
    for nx in (x0 + 3, x1 - 3):
        c.fill(c.rect(nx, y0 - 5, nx + 1, y0), CORD_ROPE[2])
        c.fill(c.rect(nx, y0 - 6, nx + 1, y0 - 5), IRON[3])
    board = c.rect(x0, y0, x1, y1) & ~(((c.xx < x0 + 1) | (c.xx >= x1 - 1)) & ((c.yy < y0 + 1) | (c.yy >= y1 - 1)))
    _wood_tal(c, board, np.where(c.yy < y0 + 1, 0.95, 0.66 - 0.12 * ((c.yy - y0) / (y1 - y0))))
    c.paint(c.rect(x0 + 1, y0 + 1, x1 - 1, y1 - 1), CREAM, 0.7 - 0.08 * ((c.yy - y0) / (y1 - y0)), dither=False)  # the painted field
    mx, my = (x0 + x1) // 2, (y0 + y1) // 2
    c.paint(c.ellipse(mx + 0.5, my, 4.2, 3.4), PINK, 0.6 + 0.3 * c.sphere(mx - 1, my - 1.5, 6, 5), dither=False)  # the peony
    c.paint(c.ellipse(mx + 0.5, my, 2.2, 1.8), PINK, 0.3, dither=False)
    c.fill(c.rect(mx, my - 1, mx + 1, my), PINK[3])
    c.paint(c.rect(x0 + 2, my + 3, mx - 1, my + 4), LEAF, 0.6, dither=False)
    c.paint(c.rect(mx + 3, my + 3, x1 - 2, my + 4), LEAF, 0.5, dither=False)


def _drying_rail(c, x0, x1, y):
    """A wooden pole on two brackets along the wall, with five small bunches hanging from it (the sixth is the prop fo_dried)."""
    rng = np.random.default_rng(611)
    for bx in (x0, x1 - 2):
        _wood_tal(c, c.rect(bx, y - 1, bx + 2, y + 5), 0.4)
    _wood_tal(c, c.rect(x0, y, x1, y + 2), np.where(c.yy < y + 1, 0.95, 0.5))
    for bx, tones in ((x0 + 8, (LAVENDER, LAVENDER, DRIED_ROSE)), (x0 + 20, (STRAW_S, DRIED_ROSE, STRAW_S)),
                      (x0 + 32, (LAVENDER, STRAW_S, LAVENDER)), (x0 + 70, (DRIED_ROSE, LAVENDER, DRIED_ROSE)),
                      (x0 + 82, (STRAW_S, STRAW_S, LAVENDER))):
        _bunch(c, bx, y + 2, rng, tones)


def fo_shell(ms):
    """The shop seen from the front, lying under everything (the floor is baked from the map): the back wall, cream plaster over a
    sage-green wainscot, with the window to the lane (map cells 8 and 9), a small sign (11), a drying rail with five little bunches
    (12 to 17; the prop fo_dried hangs from it in the cell 15), the beams above; the shelves (5 to 7 and 18 to 20) are props of
    their own. The side walls as dark timber, the front wall with the door in the cell 13. 288 x 192, anchor (8, 8): the room's
    top left cell is the map cell (4, 3)."""
    c = ms.Canvas(FO_W, FO_H)
    top, bottom = 8, 48
    xl, xr = 10, FO_W - 10
    grain = pa.value_noise(FO_H, FO_W, (2, 14), np.random.default_rng(601))
    stain = pa.value_noise(FO_H, FO_W, 9, np.random.default_rng(602))
    c.paint(c.rect(xl, top, xr, 30), CREAM, 0.88 - 0.22 * np.clip((c.yy - top) / 22.0, 0, 1) ** 1.4 + 0.08 * (grain - 0.5) - 0.1 * (stain > 0.74),
            contrast=1.8, dither=False)
    board = ((c.xx - xl) // 8).astype(int)
    wv = 0.52 + 0.06 * ((board * 7 + 3) % 5 - 2) / 2.0 + 0.1 * (grain - 0.5) - 0.18 * ((c.yy - 32) / 16.0)
    wv = np.where(((c.xx - xl) % 8) == 7, 0.06, np.where(((c.xx - xl) % 8) == 0, wv + 0.14, wv))
    c.paint(c.rect(xl, 32, xr, bottom), SAGE, wv, contrast=2.0, dither=False)
    c.paint(c.rect(xl, 30, xr, 32), CREAM, np.where(c.yy < 31, 0.98, 0.45), dither=False)  # the rail
    c.paint(c.rect(xl, bottom - 3, xr, bottom), SAGE, np.where(c.yy < bottom - 2, 0.6, 0.12), dither=False)  # the baseboard
    c.paint(c.rect(xl, bottom, xr, bottom + 3), BEAM, np.where(c.yy < bottom + 1, 0.2, 0.5), dither=False)  # the wall's shadow on the floor row
    c.a[(c.yy >= bottom + 1) & (c.yy < bottom + 3) & (c.xx >= xl) & (c.xx < xr)] = True
    c.paint(c.rect(0, 0, FO_W, top - 4), BEAM, 0.05, dither=False)
    c.paint(c.rect(4, top - 4, FO_W - 4, top), BEAM, np.where(c.yy < top - 2, 0.85, 0.45), dither=False)
    _fo_window(c, 72, 14, 98, 34)
    _plaque(c, 109, 16, 129, 32)
    _drying_rail(c, 134, 222, 12)
    for x0, x1, face, lit in ((0, 12, (4, 9), 0.7), (FO_W - 12, FO_W, (FO_W - 9, FO_W - 4), 0.5)):
        c.paint(c.rect(x0, top, x1, FO_H), BEAM, 0.05, dither=False)
        edge = 10 if x0 == 0 else FO_W - 12
        c.paint(c.rect(face[0], top, face[1], FO_H - 4), BEAM, lit - 0.3 * np.clip((c.yy - top) / (FO_H - 16.0 - top), 0.0, 1.0), dither=False)
        c.paint(c.rect(edge, top, edge + 2, FO_H - 4), BEAM, 0.3, dither=False)
    fy = FO_H - 16
    c.paint(c.rect(4, fy, FO_W - 4, FO_H), BEAM, np.where(c.yy < fy + 3, 0.8, 0.05), dither=False)
    face = c.rect(4, fy + 3, FO_W - 4, FO_H - 3)
    c.paint(face, CREAM, np.where(c.yy < fy + 8, 0.34, 0.26) + 0.08 * (grain - 0.5) + 0.05, contrast=2.0, dither=False)
    c.paint(face & (c.yy >= fy + 8), SAGE, 0.36 + 0.1 * (grain - 0.5) - 0.14 * (((c.xx - 4) % 8) == 7), dither=False)
    dx0, dx1 = 144, 160  # the doorway: room column 9 (the map cell 13)
    c.paint(c.rect(dx0 - 2, fy, dx0, FO_H), BEAM, 0.6, dither=False)
    c.paint(c.rect(dx1, fy, dx1 + 2, FO_H), BEAM, 0.6, dither=False)
    c.paint(c.rect(dx0 - 2, fy, dx1 + 2, fy + 3), BEAM, 0.8, dither=False)
    leaf = c.rect(dx0, fy + 3, dx1, FO_H - 1)
    plank = ((c.xx - dx0) // 4).astype(int)
    pv = 0.55 + 0.08 * (((plank * 7 + 3) % 5) / 4.0 - 0.5) + 0.16 * (grain - 0.5)
    pv = np.where(((c.xx - dx0) % 4) == 3, 0.1, np.where(((c.xx - dx0) % 4) == 0, pv + 0.1, pv))
    _wood_tal(c, leaf, pv)
    c.paint(c.rect(dx0 + 3, fy + 5, dx1 - 3, fy + 11), GLASS, 0.82 - 0.4 * ((c.yy - fy - 5) / 6.0), dither=False)  # a pane of glass in the door
    c.paint(c.rect(dx0 + 7, fy + 5, dx0 + 9, fy + 11), CREAM, 0.7, dither=False)
    c.paint(c.rect(dx1 - 5, fy + 9, dx1 - 2, fy + 12), BRASS, 0.8, dither=False)  # a round handle
    return c


# --------------------------------------------------------------------------- the florist's furniture
def _pot(c, cx, base, w, h, colors=TERRACOTTA, tone=0.7):
    """A flowerpot with its foot on `base`, `w` wide at the rim, `h` high, a lit rim and a lit left side."""
    x0 = cx - w // 2
    body = c.rect(x0 + 1, base - h + 2, x0 + w - 1, base) & (np.abs(c.xx + 0.5 - cx) <= (w / 2.0 - 1.0 - (base - c.yy) * 0.1))
    c.paint(body, colors, np.where(c.xx < cx, tone, tone - 0.35), dither=False)
    c.paint(c.rect(x0, base - h, x0 + w, base - h + 2), colors, 0.9, dither=False)


def _fan(c, cx, base, count, length, colors, spread=1.2, seed=0):
    """A fan of leaves or stems growing up from (cx, base)."""
    for k in range(count):
        ang = (k - (count - 1) / 2.0) / max(count - 1, 1) * spread * 2
        ln = length * (0.75 + 0.25 * ((k * 5 + seed) % 3) / 2.0)
        x1, y1 = cx + np.sin(ang) * ln * 0.8, base - np.cos(ang) * ln
        c.paint(seg(c, cx, base, x1, y1, 0.8), colors, 0.45 + 0.1 * (k % 3) + 0.25 * (x1 < cx), dither=False)


def _tag(c, x, y, w=6, h=5, lines=2):
    """A paper tag with a scribble of a Latin name on it (two or three dark strokes, no letters)."""
    c.paint(c.rect(x, y, x + w, y + h), PAPER, 0.9 - 0.1 * (c.yy > y + h - 2), dither=False)
    for k in range(lines):
        c.fill(c.rect(x + 1, y + 1 + k * 2, x + w - 1 - (k % 2), y + 2 + k * 2), IRON[1])


def _bloom(c, cx, cy, r, colors, tone=0.6):
    """A round flower head, lit from the top left, with a darker heart."""
    c.paint(c.ellipse(cx, cy, r, r * 0.92), colors, tone + 0.3 * c.sphere(cx - r * 0.4, cy - r * 0.5, r * 1.6, r * 1.6), dither=False)
    c.paint(c.ellipse(cx + 0.3, cy + 0.2, r * 0.45, r * 0.4), colors, 0.28, dither=False)
    c.fill(c.rect(round(cx - r * 0.5), round(cy - r * 0.6), round(cx - r * 0.5) + 1, round(cy - r * 0.6) + 1), colors[-1])


def fo_table(ms):
    """The binding table, four cells wide: a honey-wood front with two drawers and a hank of bast hanging from a nail, a lit top with a
    roll of kraft paper standing on it, a coil of bast, open shears, a receipt block with a pencil, a few cut stems and a glass with one
    peony in it. Orin stands behind it (the cell above the second one); the front's lower edge lies on the centre line of the cell.
    64 x 44, anchor (8, 40): the prop stands in the left cell of its row."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(621)
    c = ms.Canvas(64, 44)
    grain = pa.value_noise(44, 64, (1, 8), rng)
    _wood_tal(c, c.rect(0, 29, 64, 40), 0.5 + 0.1 * (grain - 0.5) - 0.2 * ((c.yy - 29) / 11.0))
    _wood_tal(c, c.rect(0, 22, 64, 29), np.where(c.yy < 24, 0.98, 0.8))
    _wood_tal(c, c.rect(0, 28, 64, 29), 0.3)
    for dx0 in (3, 31):  # two drawers with brass knobs
        c.paint(c.rect(dx0, 31, dx0 + 24, 38), st["wood"], 0.58 - 0.22 * ((c.yy - 31) / 7.0), dither=False)
        c.paint(c.rect(dx0, 31, dx0 + 24, 32), st["wood"], 0.92, dither=False)
        c.paint(c.rect(dx0 + 10, 33, dx0 + 14, 35), BRASS, 0.85, dither=False)
    c.paint(c.rect(0, 40, 64, 42), st["wood"], 0.1, dither=False)
    c.fill(c.rect(59, 29, 60, 32), IRON[3])  # a nail with a hank of bast on it
    hank = c.rect(57, 31, 62, 41) & ~((c.yy > 38) & (((c.xx.astype(int) * 3 + 1) % 4) == 0))  # a bundle of strands, frayed at the foot
    c.paint(hank, RAFFIA, np.where(((c.xx.astype(int) - 57) % 2) == 0, 0.8, 0.5) + 0.12 * (c.xx < 59), dither=False)
    c.paint(c.rect(57, 34, 62, 35), RAFFIA, 0.1, dither=False)  # the tie
    # on top: the roll of kraft paper, the coil of bast, the shears, the receipt block, a glass with a peony, stems at the front edge
    c.paint(c.rect(3, 12, 11, 26), KRAFT, 0.45 + 0.5 * c.cylinder(2, 12), dither=False)
    c.paint(c.ellipse(7, 12.5, 4.0, 1.4), KRAFT, 0.95, dither=False)
    c.paint(c.ellipse(7, 12.5, 1.4, 0.6), KRAFT, 0.25, dither=False)
    c.paint(c.ellipse(19.5, 21.0, 4.8, 2.6), RAFFIA, 0.6 + 0.35 * c.sphere(17, 18, 6, 4), dither=False)
    c.paint(c.ellipse(19.5, 20.5, 2.4, 1.1), RAFFIA, 0.2, dither=False)
    for k in range(3):
        c.fill(c.rect(15 + k * 3, 22 - (k % 2), 17 + k * 3, 23 - (k % 2)), RAFFIA[1])
    c.fill(c.rect(24, 23, 28, 24), RAFFIA[3])  # a loose end
    c.paint(seg(c, 31, 22, 39, 25, 0.7), ZINC, 0.85, dither=False)  # the shears: two blades crossing, red handles
    c.paint(seg(c, 31, 25, 39, 22, 0.7), ZINC, 0.5, dither=False)
    c.paint(seg(c, 39, 25, 42, 26, 1.0) | seg(c, 39, 22, 42, 21, 1.0), TERRACOTTA, 0.7, dither=False)
    c.paint(c.rect(45, 19, 51, 24), PAPER, 0.92, dither=False)  # the receipt block
    c.paint(c.rect(45, 23, 51, 25), PAPER, 0.4, dither=False)
    c.paint(c.rect(45, 19, 46, 24), TERRACOTTA, 0.6, dither=False)
    c.fill(c.rect(47, 20, 50, 21), IRON[1])
    c.paint(seg(c, 48, 18, 50, 21, 0.6), ramp("#8a6a10", "#c8a022", "#f0cc48", "#fff0a2"), 0.7, dither=False)  # the pencil
    c.paint(c.rect(54, 19, 59, 26), GLASS, 0.55 + 0.3 * (c.xx < 56), dither=False)  # a glass of water with one peony in it
    c.paint(c.rect(55, 22, 58, 26), GLASS, 0.3, dither=False)
    c.paint(seg(c, 56.5, 22, 56.5, 14, 0.5), LEAF, 0.5, dither=False)
    c.paint(c.ellipse(56.5, 12.5, 3.4, 3.0), PINK, 0.55 + 0.3 * c.sphere(55, 11, 5, 5), dither=False)
    c.paint(c.ellipse(56.8, 12.8, 1.4, 1.2), PINK, 0.25, dither=False)
    for sx, sy, ex, ey, col in ((12, 26, 25, 25, LEAF), (13, 27, 28, 26, LEAF_PALE)):  # cut stems at the front edge, with a leaf
        c.paint(seg(c, sx, sy, ex, ey, 0.6), col, 0.55, dither=False)
    c.paint(c.ellipse(27, 25.5, 2.2, 1.0), LEAF, 0.7, dither=False)
    c.paint(c.ellipse(13.5, 26.5, 1.8, 0.9), PINK, 0.8, dither=False)  # a fallen petal or two
    c.paint(c.ellipse(30.5, 26.8, 1.4, 0.7), PINK, 0.6, dither=False)
    c.outline(st["outline"])
    return c


def fo_dried(ms):
    """The dried bunch of peonies, hanging head down from the drying rail on a cord: the cut stems stick out above a bast tie (no card on
    it, nothing written), thin dry stems fan out under it and the dusty heads hang at the bottom in a cluster; three petals have come
    down. 24 x 64, anchor (12, 64): the map lifts it onto the rail (cell (15, 8), lift 14), so that the lowest petal lies on the table."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 64)
    stem = ramp("#2e2a14", "#5a5028", "#8a7c44", "#b8a868")
    c.fill(c.rect(11, 1, 12, 10), CORD_ROPE[2])  # the cord from the rail, with a loop at its end
    c.fill(c.rect(10, 0, 13, 1), CORD_ROPE[3])
    for k, (x, ln) in enumerate(((9, 4), (12, 6), (14, 5))):  # the cut ends of the stems above the tie
        c.paint(seg(c, 10.5 + k, 15, x + 0.5, 15 - ln, 0.5), stem, 0.6 + 0.1 * k, dither=False)
    for k, dx in enumerate((-6.5, -4, -1.5, 1, 3.5, 6)):  # the stems, fanning from the tie down to the heads
        c.paint(seg(c, 12, 17, 12 + dx, 33 - abs(dx) * 0.25, 0.5), stem, 0.35 + 0.12 * (k % 3) + 0.2 * (dx < 0), dither=False)
    for lx, ly, rot in ((6, 26, -0.6), (18, 27, 0.6), (9, 30, -0.3)):  # a few dried leaves caught between them
        c.paint(seg(c, lx, ly, lx + rot * 4, ly + 4, 1.0), ramp("#3a2410", "#6a4a20", "#9a7a38", "#c4a45a"), 0.5 + 0.1 * rot, dither=False)
    c.paint(c.rect(9, 14, 15, 18), RAFFIA, 0.55 + 0.35 * (c.yy < 15), dither=False)  # the bast tie
    c.paint(c.rect(9, 17, 15, 18), RAFFIA, 0.2, dither=False)
    c.paint(seg(c, 9, 17, 5.5, 23, 0.6), RAFFIA, 0.75, dither=False)  # the ends of the tie hang down: no card
    c.paint(seg(c, 15, 17, 18.5, 22, 0.6), RAFFIA, 0.55, dither=False)
    # the heads: dried peonies, faded to dusty rose, the middle one in front; rings and folds for the petals
    for hx, hy, r, tone in ((6.5, 36, 4.6, 0.42), (17.5, 36.5, 4.6, 0.38), (9, 44, 4.0, 0.34), (15.5, 44.5, 3.8, 0.4), (12, 39.5, 5.6, 0.62)):
        dist = np.hypot(c.xx + 0.5 - hx, (c.yy + 0.5 - hy) * 1.1)
        rings = (np.floor(dist * 0.95).astype(int) % 2) * 0.1
        head = c.ellipse(hx, hy, r, r * 0.92)
        c.paint(head, DRIED_ROSE, tone + rings + 0.3 * c.sphere(hx - 1.5, hy - 2, r * 1.5, r * 1.5), dither=False)
        c.paint(head & ~c.ellipse(hx, hy, r - 0.9, r * 0.92 - 0.9), DRIED_ROSE, 0.1, dither=False)  # a darker edge where it overlaps the next
        c.paint(c.ellipse(hx + 0.3, hy + 0.8, r * 0.38, r * 0.34), DRIED_ROSE, 0.14, dither=False)  # the dark heart
        for k in range(3):  # the edge of one petal over the next
            ang = k * 2.1 + hx
            c.paint(seg(c, hx + np.cos(ang) * r * 0.3, hy + np.sin(ang) * r * 0.3, hx + np.cos(ang) * r * 0.9, hy + np.sin(ang) * r * 0.8, 0.3),
                    DRIED_ROSE, 0.12, dither=False)
    c.outline(st["outline"])
    for px, py in ((5, 53), (18, 57), (11, 62)):  # petals that have come down, drawn after the outline so they stay small and loose
        c.paint(c.ellipse(px, py, 1.7, 1.0), DRIED_ROSE, 0.7, dither=False)
        c.fill(c.rect(px - 1, py, px, py + 1), DRIED_ROSE[1])
    return c


def fo_shelf(ms, kind=0):
    """A shelf of pots and tags against the back wall, three cells wide, three boards of honey wood (surfaces at y 14, 27 and 40).
    kind 0: a cactus whose sign is taller than it is, a pot of ivy trailing over the board, two succulents; a tray of seed packets,
    a row of seedlings, a plant that droops on its stick; a stack of nested pots, a fern, a sack of soil. kind 1: the same boards
    with other pots. Every pot has a tag with a Latin name in it (strokes). 48 x 44, anchor (8, 40): the prop stands in the left
    cell of its row."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(641 + kind)
    c = ms.Canvas(48, 44)
    _wood_tal(c, c.rect(0, 0, 48, 42), 0.3)
    _wood_tal(c, c.rect(3, 3, 45, 41), 0.12 + 0.05 * (pa.value_noise(44, 48, (1, 6), rng) - 0.5))  # the dark back
    for y in (14, 27, 40):
        _wood_tal(c, c.rect(0, y, 48, y + 3), np.where(c.yy < y + 1, 0.96, 0.55))
    _wood_tal(c, c.rect(0, 0, 48, 3), np.where(c.yy < 1, 0.98, 0.7))
    for px in (0, 45):
        _wood_tal(c, c.rect(px, 0, px + 3, 42), np.where((c.xx - px) < 1, 0.8, 0.5))
    _wood_tal(c, c.rect(0, 42, 48, 44), 0.1)
    if kind == 0:
        # top board: a cactus, its sign taller than it is, a pot of ivy, two succulents
        _pot(c, 8, 14, 7, 5)
        c.paint(c.ellipse(8, 7.5, 3.0, 3.6), ramp("#16301c", "#2a5a34", "#4a8a4a", "#8cc474"), 0.55 + 0.3 * c.sphere(7, 6, 5, 6), dither=False)
        for sy in (5, 7, 9):
            c.fill(c.rect(5, sy, 6, sy + 1), PAPER[2])
            c.fill(c.rect(10, sy - 1, 11, sy), PAPER[2])
        c.fill(c.rect(13, 2, 14, 14), PAPER[1])  # the stick of its sign
        _tag(c, 11, 3, 8, 6, 3)
        _pot(c, 25, 14, 9, 7)
        for k in range(7):  # the ivy
            x1 = 25 + (k - 3) * 2.2
            c.paint(seg(c, 25, 8, x1, 5 + (k % 2) * 2, 0.7), LEAF, 0.55 + 0.1 * (k % 3), dither=False)
        for k in range(4):  # and the tendrils trailing over the board's edge
            tx = 21 + k * 3
            c.paint(c.rect(tx, 14, tx + 1, 20 + (k * 3) % 5), LEAF, 0.45 + 0.1 * (k % 2), dither=False)
            c.paint(c.ellipse(tx + 0.5, 20 + (k * 3) % 5, 1.2, 1.2), LEAF_PALE, 0.7, dither=False)
        _pot(c, 36, 14, 6, 4)
        _pot(c, 43, 14, 6, 4, ZINC, 0.7)
        c.paint(c.ellipse(36, 8.5, 2.8, 2.2), LEAF_PALE, 0.6 + 0.3 * c.sphere(35, 7, 4, 3), dither=False)
        c.paint(c.ellipse(43, 9.5, 2.4, 2.0), PINK, 0.55 + 0.3 * c.sphere(42, 8, 3.6, 3), dither=False)
        _tag(c, 33, 15, 5, 5, 2)
        # middle board: a tray of seed packets, a row of seedlings, a plant on a stick that droops
        _wood_tal(c, c.rect(3, 22, 17, 27), 0.5, contrast=1.6)
        for k, col in enumerate((YELLOW, PINK, BLUE, GREEN, YELLOW, PINK, GREEN)):
            c.paint(c.rect(4 + k * 2, 17 + (k % 3), 6 + k * 2, 25), col, np.where(c.xx % 2 == 0, 0.85, 0.5), dither=False)
            c.fill(c.rect(4 + k * 2, 19 + (k % 3), 6 + k * 2, 20 + (k % 3)), PAPER[3])
        for k in range(4):
            _pot(c, 21 + k * 5, 27, 4, 3)
            c.paint(seg(c, 21 + k * 5, 24, 20 + k * 5, 20 - (k % 2), 0.5), LEAF, 0.6, dither=False)
            c.paint(seg(c, 21 + k * 5, 24, 23 + k * 5, 20 - (k % 2), 0.5), LEAF_PALE, 0.7, dither=False)
        _pot(c, 43, 27, 8, 6)
        c.fill(c.rect(40, 15, 41, 24), PAPER[1])  # the stick
        for k in range(4):  # the leaves hang down
            c.paint(seg(c, 41, 17 + k, 36 + k * 2, 23 + k * 0.5, 0.7), LEAF, 0.4 + 0.08 * k, dither=False)
        _tag(c, 40, 28, 5, 5, 2)
        # bottom board: nested pots leaning, a fern, a sack of soil with its top rolled down
        for k in range(3):
            _pot(c, 8 + (k % 2), 40 - k * 3, 9 - k, 4)
        c.paint(c.rect(6, 28, 11, 29), TERRACOTTA, 0.5, dither=False)
        _pot(c, 24, 40, 10, 8, TERRACOTTA, 0.75)
        for k in range(7):
            ang = (k - 3) * 0.42
            c.paint(seg(c, 24, 35, 24 + np.sin(ang) * 10, 35 - np.cos(ang) * 6, 0.7), ramp("#12301c", "#1f4c2a", "#33743a", "#58a050"), 0.5 + 0.08 * k, dither=False)
        _tag(c, 17, 41, 6, 4, 2)
        c.paint(c.rect(34, 30, 44, 40), KRAFT, 0.5 + 0.4 * c.cylinder(33, 45), dither=False)
        c.paint(c.rect(34, 29, 44, 32), KRAFT, 0.85 - 0.3 * (c.xx > 40), dither=False)
        c.paint(c.rect(37, 35, 41, 37), SOIL, 0.6, dither=False)
    else:
        for k, (x, w) in enumerate(((6, 8), (17, 10), (30, 8), (41, 6))):
            _pot(c, x, 14, w, 5 + (k % 2) * 2, TERRACOTTA if k % 2 == 0 else ZINC, 0.7)
            _fan(c, x, 9 - (k % 2) * 2, 5, 5 + k, LEAF, 1.0, k)
            _tag(c, x - 2, 15, 5, 5, 2)
        for k in range(5):
            _pot(c, 6 + k * 8, 27, 6, 4)
            _fan(c, 6 + k * 8, 23, 3, 5, LEAF_PALE, 0.9, k)
        _pot(c, 14, 40, 12, 9)
        _fan(c, 14, 31, 8, 12, LEAF, 1.3, 2)
        _pot(c, 36, 40, 8, 5, ZINC, 0.7)
    c.outline(st["outline"])
    return c


def _cut_flowers(c, cx, mouth, kind, seed):
    """Cut flowers standing in a bucket whose mouth is at y `mouth`: stems and leaves, then the heads. kind: peony pink, peony white,
    tulips (red and yellow), lavender, delphinium (blue spikes), daisies."""
    rng = np.random.default_rng(seed)
    n = {"peony": 4, "white": 4, "tulip": 5, "lavender": 6, "delphinium": 4, "daisy": 5}[kind]
    for k in range(n):
        dx = (k - (n - 1) / 2.0) * (6.0 / max(n - 1, 1)) * 1.4
        top = mouth - 14 - rng.integers(0, 6) - (3 if k % 2 else 0)
        c.paint(seg(c, cx + dx * 0.3, mouth, cx + dx, top, 0.55), LEAF, 0.45 + 0.12 * (k % 3), dither=False)
        if kind in ("peony", "white", "daisy", "tulip") and k % 2 == 0:  # a leaf on the stem
            c.paint(c.ellipse(cx + dx * 0.7 + (2 if k % 4 == 0 else -2), mouth - 6, 2.2, 1.0), LEAF_PALE, 0.55, dither=False)
        hx, hy = cx + dx, top
        if kind == "peony":
            _bloom(c, hx, hy, 3.6, PINK, 0.55)
        elif kind == "white":
            _bloom(c, hx, hy, 3.6, WHITE_BLOOM, 0.6)
        elif kind == "tulip":
            col = TULIP if k % 2 == 0 else YELLOW
            c.paint(c.ellipse(hx, hy, 2.0, 2.8), col, 0.6 + 0.3 * c.sphere(hx - 1, hy - 1.5, 3, 4), dither=False)
            c.paint(c.rect(hx - 1, hy - 3, hx, hy - 2), col, 0.9, dither=False)
            c.paint(c.rect(hx + 1, hy - 3, hx + 2, hy - 2), col, 0.4, dither=False)
        elif kind == "lavender":
            for j in range(5):
                c.paint(c.ellipse(hx + (j % 2) * 0.4, hy + j * 1.8, 1.1, 1.0), LAVENDER, 0.5 + 0.12 * j, dither=False)
        elif kind == "delphinium":
            for j in range(5):
                c.paint(c.ellipse(hx, hy + j * 2.2, 1.8 - j * 0.12, 1.3), BLUE, 0.5 + 0.1 * j, dither=False)
        else:
            for j in range(6):
                a = j * 1.047
                px, py = round(hx + np.cos(a) * 1.9), round(hy + np.sin(a) * 1.9)
                c.fill(c.rect(px, py, px + 1, py + 1), WHITE_BLOOM[3])
            c.fill(c.rect(round(hx), round(hy), round(hx) + 1, round(hy) + 1), YELLOW[2])


def fo_buckets(ms, kind=0):
    """A row of three buckets with cut flowers, three cells wide: a zinc pail, a wooden one with iron hoops and a cracked crock, each
    with its own flowers (kind 0: tulips, white peonies, lavender; kind 1: pink peonies, delphinium, daisies). 48 x 44, anchor (8, 38): the prop stands in the left cell of its row."""
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 44)
    kinds = (("tulip", "white", "lavender"), ("peony", "delphinium", "daisy"))[kind]
    for k, (bx, fl) in enumerate(zip((0, 16, 32), kinds)):
        cx = bx + 8
        _cut_flowers(c, cx, 26, fl, 650 + kind * 10 + k)
        body = c.rect(bx + 1, 24, bx + 15, 39) & (np.abs(c.xx + 0.5 - cx) <= 6.4 + (c.yy - 24) * -0.06)
        if k == 0:
            c.paint(body, ZINC, 0.3 + 0.7 * c.cylinder(bx, bx + 16), dither=False)
            c.paint(c.rect(bx + 2, 29, bx + 6, 33), ZINC, 0.95, dither=False)  # a dent
        elif k == 1:
            c.paint(body, ex["plank"], np.where(((c.xx.astype(int) - bx) % 3) == 2, 0.1, 0.24 + 0.55 * c.cylinder(bx, bx + 16)), dither=False)
            c.paint(c.rect(bx + 1, 28, bx + 15, 30) & body, ex["hoop"], 0.6, dither=False)
            c.paint(c.rect(bx + 1, 35, bx + 15, 37) & body, ex["hoop"], 0.6, dither=False)
        else:
            c.paint(body, TERRACOTTA, 0.3 + 0.6 * c.cylinder(bx, bx + 16), dither=False)
            c.paint(seg(c, bx + 9, 26, bx + 7, 38, 0.5), TERRACOTTA, 0.05, dither=False)  # the crack
        c.paint(c.rect(bx, 24, bx + 16, 26), ZINC if k == 0 else ex["plank"], 0.85, dither=False)
        c.paint(c.ellipse(cx, 39, 7, 1.4) & (c.yy > 38), st["stone"], 0.25, dither=False)
    c.outline(st["outline"])
    return c


def fo_plant(ms):
    """A big plant in a big terracotta pot, the one thing in the shop that has grown too large: a fiddle-leaf fig with a thick stem and
    nine leaves, a stick with a tag in the soil. 32 x 56, anchor (16, 52)."""
    st = pa.STYLES["tal"]
    bark = ms.EXTRA["tal"]["bark"]
    c = ms.Canvas(32, 56)
    c.paint(seg(c, 16, 38, 16, 18, 1.1), bark, 0.45, dither=False)
    for x0, y0, ang in ((16, 36, -1.1), (16, 32, 1.0), (16, 28, -0.9), (16, 25, 0.8), (16, 22, -0.5), (16, 19, 0.45), (16, 16, -0.2),
                        (16, 14, 0.2), (16, 12, 0.0)):
        lx, ly = x0 + np.sin(ang) * 8.5, y0 - 3.5 - abs(np.cos(ang)) * 3.5
        c.paint(seg(c, x0, y0 + 2, lx, ly, 0.5), bark, 0.4, dither=False)
        leaf = c.ellipse(lx + np.sin(ang) * 3.2, ly - 1.0, 4.6, 3.4) if abs(ang) > 0.45 else c.ellipse(lx + np.sin(ang) * 1.6, ly - 3.0, 3.4, 4.4)
        c.paint(leaf, LEAF, 0.42 + 0.46 * c.sphere(lx - 1.5, ly - 3, 8, 8) + 0.06 * (x0 % 2), dither=False)
        c.paint(seg(c, lx, ly, lx + np.sin(ang) * 5.5, ly - 1.2, 0.35) & leaf, LEAF_PALE, 0.85, dither=False)  # the pale vein
    _pot(c, 16, 52, 18, 14, TERRACOTTA, 0.72)
    c.paint(c.rect(9, 38, 23, 40), SOIL, 0.5, dither=False)
    c.fill(c.rect(21, 34, 22, 40), PAPER[1])  # the stick with its tag
    _tag(c, 19, 32, 6, 5, 2)
    c.outline(st["outline"])
    return c


def fo_can(ms):
    """A zinc watering can on the floor, spout to the west: a round body with a lip, a long spout with a rose, a handle over the back and
    a drop of water at the rose. 24 x 20, anchor (12, 17)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 20)
    body = c.rect(8, 7, 19, 17) & ~((c.yy > 15) & ((c.xx < 9) | (c.xx > 17)))
    c.paint(body, ZINC, 0.25 + 0.75 * c.cylinder(7, 20), dither=False)
    c.paint(c.ellipse(13.5, 7.5, 5.8, 1.6), ZINC, 0.95, dither=False)  # the lip
    c.paint(c.ellipse(13.5, 7.5, 3.8, 0.9), ZINC, 0.1, dither=False)
    c.paint(c.rect(8, 11, 19, 12), ZINC, 0.2, dither=False)  # a seam
    c.paint(seg(c, 9, 15, 3, 7, 1.0), ZINC, 0.55, dither=False)  # the spout, rising to the west
    c.paint(seg(c, 3, 7, 1.5, 4.5, 1.5), ZINC, 0.85, dither=False)  # the rose
    c.fill(c.rect(0, 6, 1, 7), ZINC[1])
    handle = (np.abs(np.hypot(c.xx + 0.5 - 19, (c.yy + 0.5 - 11) * 0.8) - 5.0) < 0.9) & (c.xx > 18)
    c.paint(handle, ZINC, 0.7, dither=False)
    c.paint(seg(c, 12, 5, 19, 6, 0.8), ZINC, 0.8, dither=False)  # the carrying bar over the top
    c.fill(c.rect(1, 8, 2, 9), GLASS[3])  # a drop of water
    c.outline(st["outline"])
    return c


def fo_chest(ms):
    """A small chest of drawers, two cells wide, honey wood with three drawers and brass knobs, a jar of twine on top, a little vase with one
    dried stem and a pair of gloves; short feet. 32 x 38, anchor (8, 34): the prop stands in the left cell of its row."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(32, 38)
    _wood_tal(c, c.rect(0, 14, 32, 34), 0.5 - 0.2 * ((c.yy - 14) / 20.0))
    _wood_tal(c, c.rect(0, 10, 32, 14), np.where(c.yy < 11, 0.98, 0.8))
    for k in range(3):
        y0 = 16 + k * 6
        _wood_tal(c, c.rect(2, y0, 30, y0 + 5), 0.6 - 0.2 * ((c.yy - y0) / 5.0))
        _wood_tal(c, c.rect(2, y0, 30, y0 + 1), 0.92)
        c.paint(c.rect(14, y0 + 2, 18, y0 + 4), BRASS, 0.85, dither=False)
    for fx in (2, 26):
        _wood_tal(c, c.rect(fx, 34, fx + 4, 37), 0.3)
    c.paint(c.rect(4, 4, 11, 10), GLASS, 0.5, dither=False)  # a jar of twine
    c.paint(c.ellipse(7.5, 7.5, 2.8, 2.4), RAFFIA, 0.7, dither=False)
    c.paint(c.rect(4, 3, 11, 5), ZINC, 0.8, dither=False)
    c.paint(c.rect(21, 5, 25, 10), CLAY, 0.6 + 0.3 * (c.xx < 23), dither=False)  # a little vase with one dried stem
    c.paint(c.rect(20, 4, 26, 6), CLAY, 0.9, dither=False)
    c.paint(seg(c, 23, 5, 26, 2, 0.5), STRAW_S, 0.6, dither=False)
    c.paint(c.ellipse(26.5, 2.4, 1.6, 1.4), DRIED_ROSE, 0.55, dither=False)
    c.paint(c.rect(13, 7, 19, 10), LEATHER, 0.55, dither=False)  # gardening gloves, lying flat
    c.paint(c.rect(13, 9, 19, 10), LEATHER, 0.25, dither=False)
    c.outline(st["outline"])
    return c


# =========================================================================== S4: the workshop (prefix `wk_`)
# Tess's workshop: raw pine and weathered boards, iron and leather, sawdust everywhere. A room that is used: every tool has its place and
# its outline on the wall, and one of the outlines is empty because the tool is in use. Nothing here explains Tess.
WK_W, WK_H = 288, 192  # 18 x 12 cells; the room's top left cell is the map cell (4, 3)

PINE = ramp("#4a3418", "#82602c", "#b88e48", "#dcb468", "#f4d890")  # raw pine, dusty
WEATHER = ramp("#2e241a", "#4e3e2c", "#76603f", "#9c8660", "#bca884")  # the weathered boards of the walls
STAIN = ramp("#1c130c", "#32241a", "#4e3822", "#6e4e30")  # the dark stained board behind the tools
STEEL = ramp("#16181c", "#2c3036", "#4c525c", "#7e8692", "#b4bcc6")
SAWDUST = ramp("#6e5230", "#a07e4c", "#cfae74", "#ecd6a2", "#faedc6")
RULE_Y = ramp("#4a3a0c", "#a88a1c", "#e2c23c", "#faea86")  # the folding rule and the tape: yellow
ENAMEL = ramp("#8c9098", "#bcc2ca", "#e6eaee", "#ffffff")


def _pine(c, mask, v, contrast=2.0):
    c.paint(mask, PINE, v, contrast=contrast, dither=False)


def _wk_window(c, x0, y0, x1, y1):
    """The window to the lane: a pale sky, two roofs and a chimney across the lane, a bar cross in raw pine and a sill on which a jar of
    pencils and a pair of gloves have been left."""
    pane = c.rect(x0, y0, x1, y1)
    t = np.clip((c.yy - y0) / (y1 - y0), 0, 1)
    c.paint(pane, GLASS, 0.98 - 0.4 * t, contrast=1.6, dither=False)
    c.paint(c.ellipse(x0 + 20, y0 + 4, 4.5, 1.4) & pane, GLASS, 1.0, dither=False)  # a smudge of cloud
    ridge = y1 - 7 - 3.0 * np.abs(np.sin((c.xx - x0) * 0.23 + 0.9))
    c.paint(pane & (c.yy > ridge), ramp("#3a2e26", "#58483a", "#7a6650"), 0.4 + 0.25 * (c.xx > (x0 + x1) / 2), dither=False)
    c.paint(c.rect(x0 + 18, y1 - 14, x0 + 20, y1 - 9) & pane, ramp("#3a2e26", "#58483a", "#7a6650"), 0.3, dither=False)  # a chimney
    mid_x, mid_y = (x0 + x1) // 2, (y0 + y1) // 2 + 1
    _pine(c, c.rect(x0 - 2, y0 - 2, x1 + 2, y0), np.where(c.yy < y0 - 1, 0.95, 0.6))  # the frame, raw pine
    _pine(c, c.rect(x0 - 2, y1, x1 + 2, y1 + 2), 0.45)
    _pine(c, c.rect(x0 - 2, y0, x0, y1), 0.8)
    _pine(c, c.rect(x1, y0, x1 + 2, y1), 0.4)
    _pine(c, c.rect(mid_x - 1, y0, mid_x + 1, y1), np.where(c.xx < mid_x, 0.85, 0.5))
    _pine(c, c.rect(x0, mid_y - 1, x1, mid_y + 1), np.where(c.yy < mid_y, 0.9, 0.5))
    _pine(c, c.rect(x0 - 4, y1 + 2, x1 + 4, y1 + 5), np.where(c.yy < y1 + 3, 0.98, 0.5))  # the sill
    # on the sill: a jar of pencils (glass, three stubs) and a pair of work gloves, one on top of the other
    c.paint(c.rect(x0 + 2, y1 - 6, x0 + 8, y1 + 2), GLASS, 0.5 + 0.3 * (c.xx < x0 + 5), dither=False)
    for k, tone in enumerate((RULE_Y[2], TERRACOTTA[3], PAPER[3])):
        c.fill(c.rect(x0 + 3 + k * 2, y1 - 9 - (k % 2), x0 + 4 + k * 2, y1 - 6), tone)
    c.paint(c.rect(x1 - 12, y1 - 1, x1 - 3, y1 + 2), LEATHER, 0.55 + 0.3 * (c.yy < y1), dither=False)
    c.paint(c.rect(x1 - 10, y1 - 3, x1 - 4, y1 - 1), LEATHER, 0.35, dither=False)


def _tool_wall(c, x0, y0, x1, y1):
    """The wall of small tools: a dark stained board, a rail with pegs, and on it a hammer, a try square, three chisels, a pair of pliers
    and a brace, each hung on its own nail."""
    c.paint(c.rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), PINE, np.where(c.yy < y0, 0.9, 0.4), dither=False)
    grain = pa.value_noise(c.h, c.w, (1, 8), np.random.default_rng(702))
    c.paint(c.rect(x0, y0, x1, y1), STAIN, 0.42 + 0.14 * (grain - 0.5) - 0.12 * ((c.yy - y0) / (y1 - y0)), dither=False)
    for gx in range(x0 + 11, x1, 11):  # plank joints
        c.paint(c.rect(gx, y0, gx + 1, y1), STAIN, 0.05, dither=False)
    # the hammer: a round-ended head, a handle of pale pine
    c.paint(c.rect(x0 + 5, y0 + 6, x0 + 7, y0 + 24), PINE, 0.6 + 0.3 * (c.xx < x0 + 6), dither=False)
    c.paint(c.rect(x0 + 2, y0 + 3, x0 + 11, y0 + 7), STEEL, 0.4 + 0.5 * (c.yy < y0 + 5), dither=False)
    c.paint(c.rect(x0 + 2, y0 + 3, x0 + 4, y0 + 7), STEEL, 0.85, dither=False)
    # the try square: a long blade and a short stock, a brass edge on the stock
    c.paint(c.rect(x0 + 15, y0 + 4, x0 + 17, y0 + 24), STEEL, 0.55 + 0.35 * (c.xx < x0 + 16), dither=False)
    c.paint(c.rect(x0 + 15, y0 + 4, x0 + 22, y0 + 8), PINE, np.where(c.yy < y0 + 5, 0.9, 0.35), dither=False)
    c.paint(c.rect(x0 + 21, y0 + 4, x0 + 22, y0 + 8), BRASS, 0.8, dither=False)
    # three chisels in a row: steel blade up, a handle with a leather ring
    for k in range(3):
        cx = x0 + 26 + k * 4
        c.paint(c.rect(cx, y0 + 3, cx + 2, y0 + 12), STEEL, 0.5 + 0.4 * (k % 2), dither=False)
        c.paint(c.rect(cx - 1, y0 + 12, cx + 3, y0 + 22), PINE if k != 1 else LEATHER, 0.55 + 0.3 * (k == 0), dither=False)
        c.fill(c.rect(cx - 1, y0 + 12, cx + 3, y0 + 13), STEEL[2])
    # pliers hanging by one handle below the hammer, a brace (a bent crank) below the chisels
    c.paint(seg(c, x0 + 6, y0 + 28, x0 + 4, y0 + 40, 1.0), STEEL, 0.6, dither=False)
    c.paint(seg(c, x0 + 6, y0 + 28, x0 + 9, y0 + 40, 1.0), STEEL, 0.4, dither=False)
    c.paint(c.rect(x0 + 3, y0 + 36, x0 + 11, y0 + 40), RED_WOOL, 0.55, dither=False)
    c.paint(seg(c, x0 + 22, y0 + 30, x0 + 22, y0 + 40, 0.9), STEEL, 0.55, dither=False)
    c.paint(seg(c, x0 + 22, y0 + 30, x0 + 30, y0 + 30, 0.9), STEEL, 0.55, dither=False)
    c.paint(seg(c, x0 + 30, y0 + 30, x0 + 30, y0 + 36, 0.9), STEEL, 0.55, dither=False)
    c.paint(c.ellipse(x0 + 30, y0 + 38, 2.4, 2.4), PINE, 0.7, dither=False)
    for nx, ny in ((x0 + 6, y0 + 3), (x0 + 16, y0 + 3), (x0 + 28, y0 + 3), (x0 + 6, y0 + 27), (x0 + 22, y0 + 29)):
        c.fill(c.rect(nx, ny, nx + 1, ny + 1), STEEL[4])  # the nails


def _plan(c, x0, y0, x1, y1):
    """A plan pinned to the wall: a house in elevation (a box, a roof, a chimney, a door) in ink on pale paper, a dimension line under it
    with a tick at each end, two more along the side, and a red pencil ring round the roof. No letters, no figures."""
    c.paint(c.rect(x0, y0, x1, y1), PAPER, 0.84 - 0.12 * ((c.yy - y0) / (y1 - y0)), dither=False)
    c.paint(c.rect(x0, y0, x1, y0 + 1), PAPER, 0.98, dither=False)
    ink = IRON[1]
    bx0, bx1, by0, by1 = x0 + 5, x1 - 7, y0 + 11, y1 - 7
    for rx0, ry0, rx1, ry1 in ((bx0, by0, bx1, by0 + 1), (bx0, by1 - 1, bx1, by1), (bx0, by0, bx0 + 1, by1), (bx1 - 1, by0, bx1, by1)):
        c.fill(c.rect(rx0, ry0, rx1, ry1), ink)
    mx = (bx0 + bx1) // 2
    for k in range(int((bx1 - bx0) / 2) + 1):  # the roof: two slopes
        c.fill(c.rect(bx0 + k, by0 - 1 - k * 2 // 3, bx0 + k + 1, by0 - k * 2 // 3), ink)
        c.fill(c.rect(bx1 - 1 - k, by0 - 1 - k * 2 // 3, bx1 - k, by0 - k * 2 // 3), ink)
    c.fill(c.rect(mx - 4, by1 - 7, mx - 2, by1), ink)  # a door
    c.fill(c.rect(mx - 2, by1 - 7, mx + 2, by1 - 6), ink)
    c.fill(c.rect(mx + 2, by1 - 7, mx + 4, by1), ink)
    c.fill(c.rect(bx1 - 5, by0 - 8, bx1 - 3, by0 - 3), ink)  # a chimney
    for x in range(bx0, bx1, 2):  # the dimension line under the house: dashes with a tick at each end
        c.fill(c.rect(x, by1 + 3, x + 1, by1 + 4), ink)
    for x in (bx0, bx1 - 1):
        c.fill(c.rect(x, by1 + 2, x + 1, by1 + 6), ink)
    for y in range(by0, by1, 2):  # and along the side
        c.fill(c.rect(bx1 + 3, y, bx1 + 4, y + 1), ink)
    for y in (by0, by1 - 1):
        c.fill(c.rect(bx1 + 2, y, bx1 + 6, y + 1), ink)
    ring = np.abs(np.hypot((c.xx + 0.5 - mx) / 1.0, (c.yy + 0.5 - (by0 - 5)) * 1.4) - 8.5) < 0.6
    c.paint(ring & (c.yy < by0 + 1) & (c.xx > bx0 - 2) & (c.xx < bx1 + 1) & (np.arange(c.w)[None, :] % 5 != 2), STAMP_RED, 0.55, dither=False)  # the pencil ring
    for px, py in ((x0 + 1, y0 + 1), (x1 - 2, y0 + 1)):
        c.fill(c.rect(px, py, px + 1, py + 1), STEEL[3])


def _tape(c, x, y):
    """A tape measure on a nail in the beam, hanging down with its end curled up a little: a yellow band with a dark tick on both edges."""
    c.fill(c.rect(x + 1, y - 1, x + 3, y + 1), STEEL[4])  # the nail
    band = c.rect(x, y + 1, x + 4, y + 21) | c.rect(x, y + 21, x + 4, y + 23) & ~c.rect(x, y + 22, x + 1, y + 23)
    c.paint(band, RULE_Y, np.where(c.xx < x + 2, 0.85, 0.55), dither=False)
    for ty in range(y + 2, y + 22, 2):
        c.fill(c.rect(x, ty, x + 1, ty + 1), RULE_Y[0])
        c.fill(c.rect(x + 3, ty, x + 4, ty + 1), RULE_Y[0])
    c.fill(c.rect(x + 1, y + 6, x + 3, y + 7), RULE_Y[0])  # a long tick at the foot
    c.fill(c.rect(x + 1, y + 14, x + 3, y + 15), RULE_Y[0])
    c.paint(c.rect(x + 4, y + 20, x + 7, y + 22), RULE_Y, 0.7, dither=False)  # the end curls up
    c.fill(c.rect(x + 6, y + 19, x + 7, y + 20), RULE_Y[3])


def wk_shell(ms):
    """The workshop seen from the front, lying under everything (the floor is baked from the map): the back wall of weathered boards with a
    crossbeam on which a tape measure hangs (map cell 6), the plan of the house (8), the window to the lane (10 to 12), the wall of small
    tools (13 to 15); the saws (15 to 17), the ladder (6) and the rack of boards (18 to 20) are props of their own. The side walls as dark
    timber, the front wall with the door in the cell 13. 288 x 192, anchor (8, 8): the room's top left cell is the map cell (4, 3)."""
    c = ms.Canvas(WK_W, WK_H)
    top, bottom = 8, 48
    xl, xr = 10, WK_W - 10
    grain = pa.value_noise(WK_H, WK_W, (2, 14), np.random.default_rng(701))
    stain = pa.value_noise(WK_H, WK_W, 9, np.random.default_rng(703))
    board = ((c.xx - xl) // 9).astype(int)
    bv = 0.6 + 0.06 * ((board * 7 + 3) % 5 - 2) / 2.0 + 0.12 * (grain - 0.5) - 0.26 * np.clip((c.yy - top) / 40.0, 0, 1) ** 1.3
    bv += 0.12 * np.exp(-((c.xx - 112.0) / 48.0) ** 2) * (1 - np.clip((c.yy - top) / 40.0, 0, 1))  # the light of the window
    bv = np.where(((c.xx - xl) % 9) == 8, 0.05, np.where(((c.xx - xl) % 9) == 0, bv + 0.12, bv)) - 0.1 * (stain > 0.76)
    c.paint(c.rect(xl, top, xr, bottom), WEATHER, bv, contrast=2.0, dither=False)
    c.paint(c.rect(xl, 31, xr, 33), PINE, np.where(c.yy < 32, 0.62, 0.22), dither=False)  # a batten across the boards
    c.paint(c.rect(xl, bottom - 3, xr, bottom), WEATHER, np.where(c.yy < bottom - 2, 0.5, 0.08), dither=False)  # the baseboard
    c.paint(c.rect(xl, bottom, xr, bottom + 3), BEAM, np.where(c.yy < bottom + 1, 0.2, 0.5), dither=False)  # the wall's shadow on the floor row
    c.a[(c.yy >= bottom + 1) & (c.yy < bottom + 3) & (c.xx >= xl) & (c.xx < xr)] = True
    c.paint(c.rect(0, 0, WK_W, top - 4), BEAM, 0.05, dither=False)
    c.paint(c.rect(4, top - 4, WK_W - 4, top), BEAM, np.where(c.yy < top - 2, 0.85, 0.45), dither=False)
    # the crossbeam under the roof, with its nail heads
    c.paint(c.rect(xl, top, xr, top + 7), BEAM, np.where(c.yy < top + 2, 0.9, 0.5 - 0.1 * ((c.yy - top) / 7.0)), dither=False)
    c.paint(c.rect(xl, top + 6, xr, top + 8), BEAM, 0.12, dither=False)
    for nx in range(24, xr, 40):
        c.fill(c.rect(nx, top + 3, nx + 1, top + 4), STEEL[3])
    _tape(c, 21, top + 7)
    _plan(c, 56, 14, 86, 42)
    _wk_window(c, 98, 16, 126, 36)
    _tool_wall(c, 136, 14, 174, 46)
    for x0, x1, face, lit in ((0, 12, (4, 9), 0.7), (WK_W - 12, WK_W, (WK_W - 9, WK_W - 4), 0.5)):
        c.paint(c.rect(x0, top, x1, WK_H), BEAM, 0.05, dither=False)
        edge = 10 if x0 == 0 else WK_W - 12
        c.paint(c.rect(face[0], top, face[1], WK_H - 4), BEAM, lit - 0.3 * np.clip((c.yy - top) / (WK_H - 16.0 - top), 0.0, 1.0), dither=False)
        c.paint(c.rect(edge, top, edge + 2, WK_H - 4), BEAM, 0.3, dither=False)
    fy = WK_H - 16
    c.paint(c.rect(4, fy, WK_W - 4, WK_H), BEAM, np.where(c.yy < fy + 3, 0.8, 0.05), dither=False)
    face = c.rect(4, fy + 3, WK_W - 4, WK_H - 3)
    fv = np.where(c.yy < fy + 8, 0.3, 0.22) + 0.08 * (grain - 0.5)
    c.paint(face, WEATHER, fv + 0.05, contrast=2.0, dither=False)
    c.paint(face & (c.yy >= fy + 8), WEATHER, 0.2 + 0.08 * (grain - 0.5) - 0.12 * (((c.xx - 4) % 9) == 8), dither=False)
    dx0, dx1 = 144, 160  # the doorway: room column 9 (the map cell 13)
    c.paint(c.rect(dx0 - 2, fy, dx0, WK_H), BEAM, 0.6, dither=False)
    c.paint(c.rect(dx1, fy, dx1 + 2, WK_H), BEAM, 0.6, dither=False)
    c.paint(c.rect(dx0 - 2, fy, dx1 + 2, fy + 3), BEAM, 0.8, dither=False)
    leaf = c.rect(dx0, fy + 3, dx1, WK_H - 1)
    plank = ((c.xx - dx0) // 4).astype(int)
    pv = 0.55 + 0.08 * (((plank * 7 + 3) % 5) / 4.0 - 0.5) + 0.16 * (grain - 0.5)
    pv = np.where(((c.xx - dx0) % 4) == 3, 0.1, np.where(((c.xx - dx0) % 4) == 0, pv + 0.1, pv))
    _pine(c, leaf, pv)
    for sy in (fy + 5, fy + 12):  # two iron straps and a latch
        c.paint(c.rect(dx0, sy, dx0 + 9, sy + 2), STEEL, 0.55, dither=False)
    c.paint(c.rect(dx1 - 5, fy + 8, dx1 - 2, fy + 11), STEEL, 0.8, dither=False)
    return c


def wk_bench(ms):
    """The work bench, five cells long: a thick top of pine with its worn middle, a heavy front board over a dark open space with a low
    shelf (a bucket of shavings, a sack), a vise at the left end with an offcut clamped upright in it, the plane with a curl of shaving
    beside it, the folding rule unfolded in a zigzag across the front, a tin of nails with a pencil and a mug at the right end. Tess
    stands behind the middle (the cell above the third one): in front of her it is all low. 80 x 44, anchor (40, 40): the prop stands
    in the middle cell of its row and the front's lower edge lies on that cell's centre line."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(711)
    c = ms.Canvas(80, 44)
    grain = pa.value_noise(44, 80, (1, 8), rng)
    # under the top: the dark open space, the legs and the low shelf
    c.paint(c.rect(0, 34, 80, 41), PINE, 0.12, dither=False)
    for lx in (1, 71):
        _pine(c, c.rect(lx, 30, lx + 8, 41), np.where(c.xx < lx + 2, 0.55, 0.3) + 0.1 * (grain - 0.5))
    c.paint(c.rect(9, 35, 71, 40), STAIN, 0.1, dither=False)
    _pine(c, c.rect(9, 37, 71, 39), np.where(c.yy < 38, 0.6, 0.22))  # the low shelf
    c.paint(c.rect(28, 31, 43, 38) & ((c.xx > 28) & (c.xx < 42)), STEEL, 0.3 + 0.4 * c.cylinder(27, 43), dither=False)  # a bucket of shavings
    c.paint(c.rect(27, 30, 44, 33), STEEL, 0.7, dither=False)
    for k in range(5):
        c.paint(c.ellipse(30 + k * 2.6, 30.5 - (k % 2), 2.0, 1.4), SAWDUST, 0.7 + 0.1 * (k % 2), dither=False)
    c.paint(c.rect(50, 32, 63, 38), CREAM, 0.45 + 0.3 * (c.xx < 56), dither=False)  # a sack, tied
    c.paint(c.rect(55, 30, 58, 33), CREAM, 0.3, dither=False)
    # the front board and the top
    _pine(c, c.rect(0, 29, 80, 35), 0.5 + 0.12 * (grain - 0.5) - 0.2 * ((c.yy - 29) / 6.0))
    c.paint(c.rect(0, 33, 80, 35), PINE, 0.1, dither=False)
    for kx in (19, 52):  # a knot in the board
        c.paint(c.ellipse(kx, 31.5, 2.2, 1.2), PINE, 0.2, dither=False)
    _pine(c, c.rect(0, 22, 80, 29), np.where(c.yy < 24, 0.98, 0.78) - 0.1 * np.exp(-((c.xx - 40.0) / 18.0) ** 2) * (c.yy > 23))
    _pine(c, c.rect(0, 28, 80, 29), 0.3)
    c.paint(c.rect(0, 22, 80, 23), PINE, 1.0, dither=False)  # the lit edge
    for gy in (24, 26):  # the grain along the top
        c.paint(c.rect(6, gy, 74, gy + 1) & (grain > 0.45), PINE, 0.66, dither=False)
    # the vise at the left end: an iron block on the front edge, a wooden jaw, a long screw with a handle pointing left
    c.paint(c.rect(4, 15, 15, 28), STEEL, 0.3 + 0.6 * c.cylinder(3, 16), dither=False)
    c.paint(c.rect(4, 15, 15, 17), STEEL, 0.9, dither=False)
    _pine(c, c.rect(5, 17, 14, 22), 0.45)
    c.paint(c.rect(0, 25, 5, 27), STEEL, 0.7, dither=False)  # the screw
    c.fill(c.rect(0, 23, 2, 29), STEEL[3])  # the handle bar
    c.fill(c.rect(0, 23, 2, 24), STEEL[4])
    offcut = c.rect(6, 8, 13, 18) & ~((c.xx - 6) * 0.9 + (c.yy - 8) < 2.5 - 2.0)  # an offcut clamped upright in the jaws, cut aslant at the top
    _pine(c, offcut, np.where(c.xx < 9, 0.9, 0.55))
    c.paint(c.rect(6, 12, 13, 13) & offcut, PINE, 0.12, dither=False)  # a pencil mark on it
    c.paint(c.rect(12, 9, 13, 18) & offcut, PINE, 0.2, dither=False)
    # the plane: a pale beech body, the iron sole, a tote handle behind it, the wedge; a curl of shaving at its mouth
    c.paint(c.rect(24, 17, 42, 23), PINE, np.where(c.yy < 19, 1.0, 0.7), dither=False)
    c.paint(c.rect(24, 22, 42, 23), STEEL, 0.5, dither=False)
    c.paint(c.rect(23, 18, 26, 22), PINE, 0.5, dither=False)
    c.paint(c.rect(34, 15, 37, 19), PINE, 0.85, dither=False)  # the wedge
    c.paint(c.rect(27, 14, 30, 19), LEATHER, 0.55 + 0.3 * (c.xx < 28), dither=False)  # the tote
    for r_, x_ in ((2.6, 46.5), (1.8, 49.0)):
        ring = np.abs(np.hypot(c.xx + 0.5 - x_, (c.yy + 0.5 - 18.5) * 1.1) - r_) < 0.7
        c.paint(ring & (c.xx > x_ - r_ - 1), SAWDUST, 0.9, dither=False)
    # the folding rule, unfolded in a zigzag across the front of the top
    pts = [(24, 26), (33, 24), (42, 26.5), (51, 24), (60, 26)]
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        c.paint(seg(c, ax, ay, bx, by, 0.8), RULE_Y, 0.8 - 0.3 * (ay < by), dither=False)
        for t_ in (0.25, 0.5, 0.75):
            c.fill(c.rect(round(ax + (bx - ax) * t_), round(ay + (by - ay) * t_), round(ax + (bx - ax) * t_) + 1, round(ay + (by - ay) * t_) + 1), RULE_Y[0])
    for jx, jy in pts[1:-1]:
        c.fill(c.rect(jx, round(jy), jx + 1, round(jy) + 1), STEEL[3])  # the brass joints
    # at the right end: a tin of nails with a few nails on the top beside it, a carpenter's pencil, a mug
    c.paint(c.rect(60, 17, 69, 24), STEEL, 0.4 + 0.5 * c.cylinder(59, 70), dither=False)
    c.paint(c.ellipse(64.5, 17.5, 4.6, 1.3), STEEL, 0.85, dither=False)
    c.paint(c.ellipse(64.5, 17.5, 3.4, 0.8), STEEL, 0.1, dither=False)
    for k in range(5):
        c.fill(c.rect(62 + k * 1.2, 15 - (k % 2), 63 + k * 1.2, 17), STEEL[4] if k % 2 else STEEL[3])  # nails sticking out of the tin
    for nx, ny in ((70, 24), (73, 25)):
        c.fill(c.rect(nx, ny, nx + 2, ny + 1), STEEL[3])
    c.paint(seg(c, 70, 20, 74, 17, 0.7), RULE_Y, 0.7, dither=False)  # the pencil
    c.fill(c.rect(74, 16, 75, 18), STEEL[4])
    c.paint(c.rect(74, 14, 79, 23), ENAMEL, 0.45 + 0.4 * (c.xx < 76), dither=False)  # the enamel mug
    c.paint(c.rect(74, 14, 79, 15), BLUE, 0.7, dither=False)
    c.paint(c.ellipse(76.5, 14.4, 2.6, 0.8), BEAM, 0.3, dither=False)
    c.outline(st["outline"])
    return c


def wk_trestle(ms):
    """A pair of trestles for sawing, old and much used: each is a beam of dark seasoned wood on two splayed legs with a cross rail, a deep saw
    kerf in the top of the beam (pale where it is new), a few curls of shavings on it and on the floor under it; the board lies across both (the
    prop wk_board). 48 x 28, anchor (24, 24): the prop stands in the middle cell of its row, the feet lie on that cell's centre line, the tops of
    the beams are 18 pixels above it."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(721)
    c = ms.Canvas(48, 28)
    grain = pa.value_noise(28, 48, (1, 6), rng)
    old = ramp("#22160e", "#3c2a1a", "#5c4228", "#82603a")
    for cx in (12, 36):
        for side in (-1, 1):  # the legs: splayed, a cross rail between them
            c.paint(seg(c, cx + side * 5, 11, cx + side * 8.5, 24, 1.5), old, np.where(side < 0, 0.72, 0.38), dither=False)
        c.paint(seg(c, cx - 6.6, 18, cx + 6.6, 18, 1.0), old, 0.4, dither=False)
        c.paint(c.rect(cx - 9, 6, cx + 9, 11), old, np.where(c.yy < 8, 0.95, 0.55) + 0.12 * (grain - 0.5), dither=False)  # the beam
        c.paint(c.rect(cx - 9, 10, cx + 9, 11), old, 0.1, dither=False)
        c.paint(c.rect(cx - 9, 6, cx + 9, 7), old, 1.0, dither=False)
        c.paint(c.rect(cx - 1, 6, cx + 1, 10), PINE, 0.2, dither=False)  # the saw kerf, pale at the bottom where it is new
        c.paint(c.rect(cx - 1, 9, cx + 1, 10), PINE, 0.7, dither=False)
        c.paint(c.rect(cx - 7, 7, cx - 3, 9) & (grain > 0.5), old, 0.25, dither=False)  # old marks of the saw
        c.fill(c.rect(cx - 8, 24, cx - 6, 25), old[1])  # the feet
        c.fill(c.rect(cx + 6, 24, cx + 8, 25), old[1])
    for x_, y_, r_ in ((18, 5.2, 1.8), (31, 6.2, 1.5), (7, 25.5, 1.8), (41, 26, 1.6)):  # curls of shavings
        ring = np.abs(np.hypot(c.xx + 0.5 - x_, (c.yy + 0.5 - y_) * 1.2) - r_) < 0.65
        c.paint(ring & (c.xx > x_ - r_ - 1), SAWDUST, 0.95, dither=False)
    c.outline(st["outline"])
    return c


def wk_board(ms):
    """The board for the house, lying across the two trestles: a fresh pine board three cells long, pale and a little proud of the old beams
    (a dark knot, the grain), a pencil line right across it where it is to be cut with a tick on the side that is wanted, and a first line,
    crooked, rubbed out. 48 x 12, anchor (40, 11): the map puts the glyph in the cell right of the trestles' middle cell and lifts the picture
    by 16 so that its lower edge lies on the beams."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(731)
    c = ms.Canvas(48, 12)
    grain = pa.value_noise(12, 48, (1, 7), rng)
    _pine(c, c.rect(1, 3, 47, 8), 0.92 + 0.12 * (grain - 0.5))  # the face, fresh and pale
    _pine(c, c.rect(1, 7, 47, 10), 0.5 + 0.12 * (grain - 0.5))  # the edge in front
    c.paint(c.rect(1, 3, 47, 4), PINE, 1.0, dither=False)
    c.paint(c.rect(1, 9, 47, 10), PINE, 0.14, dither=False)
    for gy in (5, 6):
        c.paint(c.rect(3, gy, 45, gy + 1) & (grain > 0.42), PINE, 0.7, dither=False)
    c.paint(c.ellipse(12, 5.5, 2.2, 1.1), PINE, 0.2, dither=False)  # a knot
    c.paint(c.rect(29, 3, 30, 10), STEEL, 0.15, dither=False)  # the pencil line across face and edge
    c.fill(c.rect(30, 3, 31, 4), STEEL[1])  # the tick on the side that is wanted
    c.fill(c.rect(31, 4, 32, 5), STEEL[1])
    c.fill(c.rect(32, 5, 33, 6), STEEL[1])
    c.paint(seg(c, 21, 3.5, 23, 7.5, 0.5), PINE, 0.55, dither=False)  # a first try, rubbed out
    c.outline(st["outline"])
    return c


def wk_ladder(ms):
    """A ladder that is not finished, leaning on the back wall: both rails are cut, the left one runs to the beam and the right one stops
    below it with two empty mortises above the last rung, four rungs are in, the places of the next two are marked with a pencil tick on
    both rails and two finished rungs lie on the floor at the foot. 38 x 52, anchor (14, 48): the foot stands on the cell's centre line,
    the top reaches the crossbeam."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(741)
    c = ms.Canvas(38, 52)
    grain = pa.value_noise(52, 38, (6, 1), rng)

    def rail(x_bottom, x_top, y_top, tone):
        m = seg(c, x_bottom, 48, x_top, y_top, 1.6)
        _pine(c, m, tone + 0.12 * (grain - 0.5), contrast=2.0)
        return m

    rail(5, 8, 4, 0.78)
    rail(22, 19.5, 13, 0.46)
    c.paint(c.rect(2, 47, 9, 49), PINE, 0.18, dither=False)  # the feet
    c.paint(c.rect(18, 47, 25, 49), PINE, 0.18, dither=False)
    for y_ in (41, 33, 25, 17):  # the four rungs that are in
        t_ = (48 - y_) / 44.0
        lx, rx = 5 + 3 * t_, 22 - 2.5 * t_
        _pine(c, c.rect(lx, y_, rx, y_ + 2), np.where(c.yy < y_ + 1, 0.95, 0.5))
        c.fill(c.rect(lx - 0.5, y_, lx + 0.5, y_ + 2), PINE[0])  # the joint
        c.fill(c.rect(rx - 0.5, y_, rx + 0.5, y_ + 2), PINE[0])
    for y_ in (9, 5):  # the empty mortises above the last rung on the right rail, and the ticks on both rails for the next rungs
        c.fill(c.rect(19, y_ + 5, 21, y_ + 7), PINE[0])
    for y_ in (13, 9):
        c.fill(c.rect(6, y_, 8, y_ + 1), STEEL[1])
        c.fill(c.rect(19, y_ + 4, 21, y_ + 5), STEEL[1])
    for y_, x_ in ((46, 26), (44, 28)):  # the two finished rungs on the floor
        _pine(c, c.rect(x_, y_, x_ + 11, y_ + 2), np.where(c.yy < y_ + 1, 0.95, 0.5))
        c.fill(c.rect(x_ + 1, y_, x_ + 2, y_ + 2), PINE[3])
    c.outline(st["outline"])
    return c


def wk_rack(ms):
    """A rack of boards against the back wall, three cells wide: two uprights of stained oak, three levels of boards lying in it, their long
    sides in front in strips of different tones and lengths, with the dark back showing where a board is shorter; the ends that stick out show
    the rings of the year; tall planks lean at the left; a tally on the right upright in strokes (four and a slash, twice) and a paper tag on a
    nail. 48 x 44, anchor (24, 40)."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(751)
    c = ms.Canvas(48, 44)
    grain = pa.value_noise(44, 48, (1, 6), rng)
    c.paint(c.rect(0, 0, 48, 42), STAIN, 0.2, dither=False)
    c.paint(c.rect(3, 3, 45, 41), STAIN, 0.06 + 0.05 * (grain - 0.5), dither=False)
    for y in (14, 27, 40):  # the supports
        c.paint(c.rect(0, y, 48, y + 3), STAIN, np.where(c.yy < y + 1, 0.9, 0.4), dither=False)
    # the boards: per level strips from the support upwards, (height, start, end, tone); tones from raw to dusty
    levels = ((14, ((3, 4, 41, 0.62), (3, 6, 36, 0.4), (4, 3, 42, 0.74))),
              (27, ((3, 5, 40, 0.5), (3, 4, 31, 0.7), (3, 8, 41, 0.38), (3, 3, 38, 0.6))),
              (40, ((5, 4, 42, 0.46), (5, 3, 36, 0.66), (2, 6, 40, 0.34))))
    for base, strips in levels:
        y = base
        for k, (h, x0, x1, tone) in enumerate(strips):
            top = y - h
            _pine(c, c.rect(x0, top, x1, y), tone + 0.16 * (grain - 0.5))
            c.paint(c.rect(x0, y - 1, x1, y), PINE, 0.08, dither=False)
            if k == len(strips) - 1:
                c.paint(c.rect(x0, top, x1, top + 1), PINE, 0.9, dither=False)
            ring = c.rect(x1, top, x1 + 1, y)  # the end grain
            c.paint(ring, PINE, 0.28, dither=False)
            if h >= 4:
                c.fill(c.rect(x1 - 1, top + 1, x1, top + 2), PINE[3])  # a ring catching the light
            y = top
    for k in range(3):  # tall planks leaning at the left edge
        x = 5 + k * 4
        _pine(c, c.rect(x, 3 + k, x + 3, 14), np.where(c.xx == x, 0.8, 0.46) - 0.08 * k)
        c.paint(c.rect(x + 2, 3 + k, x + 3, 14), PINE, 0.1, dither=False)
    for px in (0, 45):  # the uprights in front of everything
        c.paint(c.rect(px, 0, px + 3, 42), STAIN, np.where((c.xx - px) < 1, 0.82, 0.5), dither=False)
    for k in range(4):  # tally strokes on the right upright: four and a slash, twice
        c.fill(c.rect(36 + k * 2, 17, 37 + k * 2, 22), PAPER[3])
    c.fill(seg(c, 35, 21, 44, 18, 0.5), PAPER[3])
    for k in range(4):
        c.fill(c.rect(36 + k * 2, 30, 37 + k * 2, 35), PAPER[3])
    c.fill(c.rect(10, 29, 11, 31), STEEL[3])  # a nail with a paper tag on it
    c.paint(c.rect(8, 31, 14, 37), PAPER, 0.8, dither=False)
    c.fill(c.rect(9, 33, 13, 34), IRON[1])
    c.outline(st["outline"])
    return c


def wk_saws(ms):
    """The saws: a stained board on the wall with three saws (a hand saw with a worn handle, a back saw with a brass spine, a bow saw) and
    two clamps, each hanging inside its own outline drawn in chalk; the largest saw's outline is empty, because it is in use. Under it a low box
    of pine with clamps lying in it and a tin cup holding a pencil. 48 x 40, anchor (24, 40): the prop stands in the middle cell of the three,
    its box stands on that row's centre line, the board hangs two cells above."""
    st = pa.STYLES["tal"]
    rng = np.random.default_rng(761)
    c = ms.Canvas(48, 40)
    grain = pa.value_noise(40, 48, (1, 8), rng)
    # the board with a frame of pine
    _pine(c, c.rect(1, 1, 47, 30), np.where((c.yy < 3) | (c.xx < 3), 0.75, 0.3) - 0.1 * (c.yy > 27))
    c.paint(c.rect(3, 3, 45, 28), STAIN, 0.4 + 0.14 * (grain - 0.5), dither=False)
    # the chalk outline of the largest saw, which is not there (it is in use): a long tapered shape across the top of the board
    c.paint(seg(c, 5, 5, 31, 6, 0.6) | seg(c, 5, 10, 31, 8, 0.6) | seg(c, 31, 6, 31, 8, 0.6) | seg(c, 5, 5, 5, 10, 0.6), PAPER, 0.5, dither=False)
    # hand saw (second row of the board): a tapered blade, teeth along the lower edge, a worn dark handle with a hole for the hand
    blade = (c.xx >= 14) & (c.xx < 42) & (c.yy >= 12) & (c.yy < 20 - (c.xx - 14) * 0.12 + 0.0) & (c.yy >= 12 + (c.xx - 14) * 0.08)
    c.paint(blade, STEEL, 0.6 + 0.3 * (c.yy < 14), dither=False)
    teeth = (c.xx >= 15) & (c.xx < 41) & (c.yy >= 19.5 - (c.xx - 14) * 0.12) & (c.yy < 21.5 - (c.xx - 14) * 0.12) & (((c.xx.astype(int)) % 2) == 0)
    c.paint(teeth, STEEL, 0.5, dither=False)
    c.paint(c.rect(6, 12, 15, 22), LEATHER, 0.3 + 0.5 * (c.yy < 14), dither=False)
    c.paint(c.rect(8, 15, 12, 19), STAIN, 0.1, dither=False)  # the hole of the handle
    c.paint(c.rect(6, 12, 15, 13), LEATHER, 0.95, dither=False)
    # back saw: a short rectangular blade with a brass spine
    c.paint(c.rect(25, 22, 44, 28), STEEL, 0.55 + 0.35 * (c.yy < 24), dither=False)
    c.paint(c.rect(25, 22, 44, 24), BRASS, 0.7, dither=False)
    c.paint(c.rect(13, 22, 25, 28), LEATHER, 0.35 + 0.4 * (c.yy < 24), dither=False)
    c.paint(c.rect(15, 24, 21, 26), STAIN, 0.1, dither=False)
    # chalk outline of the back saw is hidden by the saw itself; the two clamps hang at the right of the first row: an iron bar, a fixed jaw,
    # a sliding jaw and a screw with a wooden handle
    for cx, tone in ((38, 0.5), (44, 0.72)):
        c.paint(c.rect(cx, 4, cx + 2, 20), STEEL, tone, dither=False)
        c.paint(c.rect(cx - 2, 4, cx + 4, 6), STEEL, 0.4, dither=False)
        c.paint(c.rect(cx - 2, 15, cx + 4, 17), STEEL, 0.85, dither=False)
        c.paint(c.rect(cx - 1, 19, cx + 3, 21), PINE, 0.7, dither=False)
    for nx, ny in ((7, 4), (30, 4), (15, 24), (36, 24), (38, 3), (44, 3)):
        c.fill(c.rect(nx, ny, nx + 1, ny + 1), STEEL[4])
    # the low box under the board: front, top edge, clamps lying in it, a tin cup with a pencil
    _pine(c, c.rect(0, 31, 48, 40), np.where(c.yy < 33, 0.9, 0.46) - 0.12 * ((c.yy - 31) / 9.0))
    c.paint(c.rect(0, 39, 48, 40), PINE, 0.08, dither=False)
    c.paint(c.rect(3, 34, 45, 38), STAIN, 0.12, dither=False)  # the dark opening of the box
    c.paint(seg(c, 6, 36, 20, 35, 0.9), STEEL, 0.6, dither=False)
    c.paint(seg(c, 22, 36.5, 33, 35.5, 0.9), STEEL, 0.45, dither=False)
    c.paint(c.rect(36, 27, 43, 33), STEEL, 0.4 + 0.5 * c.cylinder(35, 44), dither=False)  # the tin cup on the edge
    c.paint(c.ellipse(39.5, 27.4, 3.6, 1.0), STEEL, 0.85, dither=False)
    c.paint(seg(c, 39, 28, 41, 21.5, 0.6), RULE_Y, 0.7, dither=False)  # a pencil in it
    c.outline(st["outline"])
    return c


def wk_dust(ms):
    """Sawdust on the floor with the footprints of two people in it: a low, ragged heap with a few curls, a long trail of big boots with
    strides of seven pixels going west and, beside it, the shorter steps of someone in smaller shoes. The prints show the planks through the
    dust. 64 x 32, anchor (32, 24); flat, no shadow, no outline."""
    rng = np.random.default_rng(771)
    c = ms.Canvas(64, 32)
    n = pa.value_noise(32, 64, 4, rng)
    n2 = pa.value_noise(32, 64, 2, rng)
    dist = np.hypot((c.xx + 0.5 - 32) / 30.0, (c.yy + 0.5 - 17) / 11.5)
    heap = dist + 0.34 * (n - 0.5) < 1.0
    c.paint(heap, SAWDUST, 0.34 + 0.24 * (1 - dist) + 0.16 * (n2 - 0.5), dither=True)
    c.paint(heap & (dist < 0.5) & (n2 > 0.5), SAWDUST, 0.7, dither=False)
    for sx, sy in ((58, 28), (4, 9), (50, 6), (11, 27)):  # a few specks outside the heap
        c.fill(c.rect(sx, sy, sx + 1, sy + 1), SAWDUST[1])

    def rot_ellipse(x, y, ang, rl, rw):
        dx, dy = c.xx + 0.5 - x, c.yy + 0.5 - y
        u = dx * np.cos(ang) + dy * np.sin(ang)
        v = -dx * np.sin(ang) + dy * np.cos(ang)
        return (u / rl) ** 2 + (v / rw) ** 2 <= 1.0

    floor = ramp("#5a3f28", "#7a583a", "#94704a")

    def print_(x, y, ang, big):
        """A footprint: a sole and a heel with a gap between them, the toe towards `ang` (0 = east)."""
        rl, rw, gap = (2.7, 1.6, 4.4) if big else (1.9, 1.15, 3.2)
        dx, dy = np.cos(ang), np.sin(ang)
        sole = rot_ellipse(x, y, ang, rl, rw)
        heel = rot_ellipse(x - dx * gap, y - dy * gap, ang, rw * 0.9, rw * 0.9)
        c.paint((sole | heel) & heap, floor, 0.3, dither=False)

    for k, x in enumerate((52, 45, 38, 31, 24, 17)):  # the big boots, going west, left and right foot a little apart
        print_(x, 15 + (k % 2) * 4 - 1, np.pi, True)
    for k, x in enumerate((49, 44, 39, 34, 29)):  # the smaller steps close behind, a little further down
        print_(x, 24 + (k % 2) * 3, np.pi, False)
    return c


def wk_stool(ms):
    """A round three-legged stool of pine, its seat worn dark in the middle. 16 x 22, anchor (8, 19)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 22)
    for lx, tone in ((3.5, 0.62), (12.5, 0.34), (8, 0.46)):
        c.paint(seg(c, lx + (8 - lx) * 0.3, 11, lx + (lx - 8) * 0.25, 19, 1.1), PINE, tone, dither=False)
    c.paint(seg(c, 4.5, 15.5, 11.5, 15.5, 0.6), PINE, 0.25, dither=False)  # the rung
    c.paint(c.rect(2, 9, 14, 12) & (np.hypot((c.xx + 0.5 - 8) / 6.4, (c.yy + 0.5 - 9.5) / 3.0) <= 1.0), PINE, 0.42, dither=False)  # the thickness
    c.paint(c.ellipse(8, 8.8, 6.4, 3.0) & (c.yy < 11), PINE, 0.96, dither=False)  # the seat
    c.paint(c.ellipse(8, 8.8, 3.8, 1.5), PINE, 0.52, dither=False)  # worn dark in the middle
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
    build_florist(ms)
    build_workshop(ms)


def build_florist(ms):
    """Registers the florist's shop (S3, prefix fo_). The shell is flat; the furniture stands with the lower edge of its front on the centre
    line of its cell and casts a baked shadow on the shop's own floor (the map blumenladen is baked after it); the dried bunch hangs from
    the rail and has neither a shape nor a shadow: the map lifts it (lift 14) onto the rail above the table's right end."""
    ms.save("tal", "fo_shell", fo_shell(ms), (8, 8), flat=True)
    ms.save("tal", "fo_table", fo_table(ms), (8, 40), shape={"rect": [64, 12], "offset": [24, -6]}, shadow=[32, 3])
    ms.save("tal", "fo_dried", fo_dried(ms), (12, 64))
    ms.save("tal", "fo_shelf", [fo_shelf(ms, 0), fo_shelf(ms, 1)], (8, 40), shape={"rect": [48, 8], "offset": [16, -4]}, shadow=[24, 3])
    ms.save("tal", "fo_buckets", [fo_buckets(ms, 0), fo_buckets(ms, 1)], (8, 38), shape={"rect": [48, 8], "offset": [16, -3]}, shadow=[22, 4])
    ms.save("tal", "fo_plant", fo_plant(ms), (16, 52), shape={"circle": 6, "offset": [0, -3]}, shadow=[9, 3])
    ms.save("tal", "fo_can", fo_can(ms), (12, 17), shape={"circle": 4, "offset": [0, -2]}, shadow=[7, 2])
    ms.save("tal", "fo_chest", fo_chest(ms), (8, 34), shape={"rect": [32, 10], "offset": [8, -5]}, shadow=[16, 3])


def build_workshop(ms):
    """Registers the workshop (S4, prefix wk_). The shell, the floor dust and the board are flat or hang over the furniture and have neither a
    shape nor a shadow; the furniture stands with the lower edge of its front on the centre line of its cell and, standing in the middle cell
    of its width, casts a baked shadow on the workshop's own floor (the map werkstatt is baked after it; no other map uses the prefix wk_,
    so no other stamp changes). The board lies on the trestles: the map puts its glyph in the cell right of the trestles' and lifts it by 16."""
    ms.save("tal", "wk_shell", wk_shell(ms), (8, 8), flat=True)
    ms.save("tal", "wk_bench", wk_bench(ms), (40, 40), shape={"rect": [80, 12], "offset": [0, -6]}, shadow=[40, 3])
    ms.save("tal", "wk_trestle", wk_trestle(ms), (24, 24), shape={"rect": [44, 8], "offset": [0, -4]}, shadow=[22, 3])
    ms.save("tal", "wk_board", wk_board(ms), (40, 11))
    ms.save("tal", "wk_ladder", wk_ladder(ms), (14, 48), shape={"rect": [22, 8], "offset": [0, -4]}, shadow=[12, 2])
    ms.save("tal", "wk_rack", wk_rack(ms), (24, 40), shape={"rect": [48, 8], "offset": [0, -4]}, shadow=[24, 3])
    ms.save("tal", "wk_saws", wk_saws(ms), (24, 40), shape={"rect": [48, 8], "offset": [0, -4]}, shadow=[24, 3])
    ms.save("tal", "wk_dust", wk_dust(ms), (32, 24), flat=True)
    ms.save("tal", "wk_stool", wk_stool(ms), (8, 19), shape={"circle": 5, "offset": [0, -3]}, shadow=[7, 2])


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


def preview_florist(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    sheet = Image.new("RGBA", (FO_W + 20, FO_H + 130), (96, 120, 100, 255))
    floor = Image.new("RGBA", (FO_W, FO_H), (150, 104, 66, 255))
    sheet.alpha_composite(floor, (10, 10))
    sheet.alpha_composite(Image.fromarray(fo_shell(ms).rgba().astype(np.uint8), "RGBA"), (10, 10))
    x, y = 10, FO_H + 20
    for item in (fo_table(ms), fo_dried(ms), fo_shelf(ms, 0), fo_shelf(ms, 1), fo_buckets(ms, 0), fo_buckets(ms, 1), fo_plant(ms), fo_can(ms),
                 fo_chest(ms)):
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        if x + img.width > sheet.width:
            x, y = 10, y + 66
        sheet.alpha_composite(img, (x, y))
        x += img.width + 8
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


def preview_workshop(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    sheet = Image.new("RGBA", (WK_W + 20, WK_H + 150), (96, 120, 100, 255))
    floor = Image.new("RGBA", (WK_W, WK_H), (150, 104, 66, 255))
    sheet.alpha_composite(floor, (10, 10))
    sheet.alpha_composite(Image.fromarray(wk_shell(ms).rgba().astype(np.uint8), "RGBA"), (10, 10))
    x, y = 10, WK_H + 20
    for item in (wk_bench(ms), wk_trestle(ms), wk_board(ms), wk_ladder(ms), wk_rack(ms), wk_saws(ms), wk_dust(ms), wk_stool(ms)):
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        if x + img.width > sheet.width:
            x, y = 10, y + 50
        sheet.alpha_composite(img, (x, y))
        x += img.width + 8
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    elif len(sys.argv) == 3 and sys.argv[1] == "--preview-florist":
        preview_florist(sys.argv[2])
    elif len(sys.argv) == 3 and sys.argv[1] == "--preview-workshop":
        preview_workshop(sys.argv[2])
