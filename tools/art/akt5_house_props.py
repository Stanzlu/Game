"""Props for Act V, G8 (Das ursprüngliche Haus; docs/akt5/REGIONSBRIEFE.md), drawn like akt5_props.py and registered in the same catalog (style "tal",
prefixes `gb_` outside and `uh_` inside). Called from make_sprites.build(); `--preview out.png` lays everything out (3x) to look at.

Outside, on the empty plateau of the Grat: the small house that was not there before (`gb_first_house`: upright boards, a gable roof of weathered shingles,
a low door, a window whose pane is fogged whitish-blue from inside, a flat stone for a threshold; crooked like a house built by hand; no chimney, no smoke, no
fence, no sign) and the summit book on its post (`gb_summit_book`: a small box with its lid propped open aslant, a thick swollen book in it, a pencil on a cord).

Inside (`urhaus`, Klasse S, zoom 1.5: 25 x 14 cells, 400 x 224 pixels, the room is the cells 4 to 28 and 4 to 17 of the map, like the hall of the Anlage): a flat
shell (`uh_shell`: warm upright boards, a strip of plaster under a beam, a baseboard, one hook, the side walls, the front wall with a plain closed plank door and
a round knob at a child's height; the floor, the cells 5 to 27 x 7 to 16, stays fully transparent: the baked floor lies under it), a small narrow bed with its head
to the north and nothing in it (`uh_bed`), the window in the back wall over the bed (`uh_window`: every pane scribbled over with blue chalk, only a thin rim of light
at the edges; `uh_window_clear`: the same frame with clear panes, pale sky above, grass and the edge of a mountain below and a streak of chalk left in one corner),
the six rings of blue chalk on the floor (`uh_chalk_rings`, flat, 368 x 160 pixels, top left corner = top left corner of the cell (5, 7): six closed hand-drawn loops,
one inside the other, each with a motif in its strokes, in the order room, wall, garden, street, town, world; the outermost is a double line that runs along the walls
and over the place of the door without a gap) and a stick of blue chalk on the floor (`uh_chalk`, flat). Nothing here is a person, nothing glows, and nothing
says what the rings are. The chalk is a cool light pastel blue, dusty at its edges, the lines two to three pixels thick, a little uneven, broken here and there and
drawn over again. None of the new catalog entries has a shadow (the stamp of `grat` must not change; `urhaus` is baked after them).
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp
from akt5_props import _poly

BOARD = ramp("#2e241c", "#4a3c30", "#6e5c48", "#907c62", "#b09c80")  # weathered boards of the house outside: grey-brown, no honey
SHINGLE = ramp("#2a2622", "#443e38", "#625a50", "#82786a", "#a29686")  # shingles: a muted grey-brown
CHALK = ramp("#7f9ab8", "#a7c0dc", "#c6daee", "#e2eef9", "#f4f9fd")  # the chalk: cool pastel blue, the first colour is its dust
CHALK_EDGE = np.array([44.0, 58.0, 84.0], np.float32)  # the dark blue line round the stick of chalk
ROOM_WOOD = ramp("#2a1e16", "#43311f", "#654a2e", "#86643e", "#a8845a")  # the warm boards of the room
PLASTER = ramp("#5a4c3c", "#8a7a64", "#b2a284", "#d2c4a4", "#e8dcc0")  # dusty plaster
LINEN = ramp("#6a6a70", "#9a9aa0", "#c4c4c4", "#e6e4dc", "#f6f4ee")
BLANKET = ramp("#2c3a4c", "#46586c", "#647c92", "#869eb2", "#a8bece")  # grey-blue, smoothed flat
BEAM = ramp("#1e140e", "#32231a", "#4e3822", "#6c4e30", "#8a6a44")
DULL_IRON = ramp("#1a1a1e", "#2e2f35", "#4a4d55", "#6e727c")
PAPER = ramp("#6a6050", "#a89e86", "#d4ccb2", "#eee8d2", "#faf6e6")
PENCIL = ramp("#5a3c10", "#a87a1c", "#d8a838", "#f0cc68")

RW, RH = 368, 160  # the chalk rings: 23 x 10 cells, the floor of the room
SW, SH = 400, 224  # the shell: 25 x 14 cells


# =========================================================================== outside
def first_house(ms):
    """The small house on the plateau, seen from the front: a wall of upright boards (four pixels each, a dark seam between them, a few boards a shade
    off), a low door (ten pixels wide, fourteen high: someone tall would have to stoop), a small window whose pane is fogged whitish-blue with the strokes
    of a flat hand across it, a flat stone for the threshold, a gable roof of grey-brown shingles in staggered rows with the ridge a pixel off true and the
    left eave a pixel lower. No chimney, no smoke, no fence, no number, no sign. 48 x 48, anchor (24, 40): the foot stands on the lower edge of its cell."""
    rng = np.random.default_rng(5001)
    st = pa.STYLES["tal"]
    c = ms.Canvas(48, 48)
    grain = pa.value_noise(48, 48, (6, 1), rng)
    # ---- the wall
    wall = c.rect(7, 22, 42, 46)
    idx = ((c.xx - 7) // 4).astype(int)
    tone = (((idx * 5 + 2) % 7) / 7.0 - 0.5) * 0.2
    lit = 0.6 - 0.2 * np.clip((c.xx - 7) / 35.0, 0, 1)
    c.paint(wall, BOARD, lit + tone + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(wall & (((c.xx - 7) % 4) == 3), BOARD, 0.06, dither=False)  # the seams between the boards
    for x, y in ((9, 33), (13, 29), (23, 27), (38, 41), (35, 24), (17, 39)):  # a knot, a nail
        c.fill(c.rect(x, y, x + 1, y + 1) & wall, BOARD[1])
    c.paint(wall & (c.yy < 26), BOARD, np.where(c.yy < 24, 0.1, 0.22), dither=False)  # in the shadow of the eave
    c.paint(wall & (c.yy >= 44), BOARD, 0.1, dither=False)  # the dark foot
    # ---- the low door: a leaf of boards, a lintel, a small round knob
    door = c.rect(19, 31, 29, 46)
    c.paint(c.rect(18, 30, 30, 46), BOARD, np.where(c.yy < 31, 0.9, np.where(c.xx < 19, 0.72, 0.3)), dither=False)  # the frame
    c.paint(door, BOARD, 0.26 + 0.08 * (grain - 0.5) + 0.06 * (((c.xx - 19) // 3) % 2), dither=False)
    c.paint(door & (((c.xx - 19) % 3) == 2), BOARD, 0.04, dither=False)
    c.paint(door & (c.yy < 33), BOARD, 0.08, dither=False)
    c.fill(c.rect(26, 39, 28, 41), DULL_IRON[3])  # the knob, low
    c.fill(c.rect(26, 39, 27, 40), DULL_IRON[1])
    # ---- the window: a pane fogged whitish-blue, flat strokes of a hand across it
    c.paint(c.rect(30, 26, 40, 37), BOARD, np.where((c.yy < 27) | (c.xx < 31), 0.82, 0.2), dither=False)  # the frame
    pane = c.rect(31, 27, 39, 36)
    streak = ((c.xx + c.yy * 0.6) % 5) < 1.3
    c.paint(pane, CHALK, np.where(streak, 0.9, 0.6) + 0.12 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(pane & (c.xx == 34), BOARD, 0.55, dither=False)  # the mullion: one board
    c.paint(c.rect(30, 36, 40, 38), BOARD, np.where(c.yy < 37, 0.95, 0.3), dither=False)  # the sill
    # ---- the threshold: one flat stone
    c.paint(c.rect(16, 44, 32, 47), st["stone"], np.where(c.yy < 45, 0.88, 0.5) + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    c.fill(c.rect(16, 46, 32, 47), st["stone"][1])
    c.fill(c.rect(16, 44, 17, 45), st["stone"][3])
    # ---- the roof: staggered rows of shingles, grey-brown, weathered; the ridge a pixel off true
    roof = _poly(c, [(2, 24), (11, 4), (38, 3), (46, 23)])
    row = np.floor((c.yy - 3) / 4.0).astype(int)
    col = np.floor((c.xx + (row % 2) * 2.5) / 5.0).astype(int)
    shade = (((row * 7 + col * 13) % 11) / 11.0 - 0.5) * 0.3
    v = 0.56 + shade + 0.14 * (1.0 - np.clip((c.xx - 2) / 44.0, 0, 1)) - 0.18 * np.clip((c.yy - 3) / 21.0, 0, 1) + 0.08 * (grain - 0.5)
    c.paint(roof, SHINGLE, v, contrast=2.0, dither=False)
    c.paint(roof & (((c.yy - 3) % 4) == 3), SHINGLE, 0.1, dither=False)  # the shadow under every row
    c.paint(roof & ((((c.xx + (row % 2) * 2.5) % 5) >= 4.5) | (((c.xx + (row % 2) * 2.5) % 5) < 0.5)) & (((c.yy - 3) % 4) < 3), SHINGLE, 0.2, dither=False)
    c.paint(roof & (c.yy < 5), SHINGLE, 0.78, dither=False)  # the ridge board, lit
    c.paint(roof & (c.yy >= 22), SHINGLE, 0.08, dither=False)  # the dark eave
    for x, y in ((15, 12), (27, 17), (34, 9), (9, 19), (21, 8), (40, 18)):  # a shingle gone, a dark gap
        c.fill(c.rect(x, y, x + 2, y + 1) & roof, SHINGLE[0])
    c.outline(st["outline"])
    return c


def summit_book(ms):
    """The summit book: a post of weathered wood with a stone or two at its foot, on top a small box whose lid is propped open aslant against the back (the
    inner face of the lid lit, a hinge at its foot), in the box a thick book lying open, the pages swollen and wavy, a few grey lines on the left page and none
    on the right, and on the left side of the box a pencil hanging from a cord. 16 x 24, anchor (8, 20): the foot of the post."""
    rng = np.random.default_rng(5002)
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 24)
    grain = pa.value_noise(24, 16, (4, 1), rng)
    # the post and the stones at its foot
    for cx, cy, rx, ry, v in ((5.5, 21.2, 2.6, 1.5, 0.5), (11.0, 21.4, 2.4, 1.3, 0.38)):  # two small stones
        c.paint(c.ellipse(cx, cy, rx, ry), st["stone"], v, dither=False)
        c.fill(c.rect(int(cx - 1), int(cy - 1), int(cx + 1), int(cy)) & c.ellipse(cx, cy, rx, ry), st["stone"][3])
    c.fill(c.rect(7, 20, 8, 22), st["grass"][3])
    c.fill(c.rect(9, 20, 10, 22), st["grass"][2])
    c.paint(c.rect(6, 12, 11, 21), BOARD, np.where(c.xx < 7.5, 0.62, 0.24) + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    # the lid, propped open aslant against the back: its inner face towards us, lit; a hinge at its foot
    lid = _poly(c, [(3, 4), (14, 4), (15, 0), (5, 0)])
    c.paint(lid, BOARD, 0.52 + 0.2 * np.clip((c.yy) / 5.0, 0, 1) * 0 + 0.1 * (grain - 0.5) + 0.14 * np.clip((15 - c.xx) / 12.0, 0, 1), contrast=2.0, dither=False)
    c.paint(lid & (c.yy < 1), BOARD, 0.9, dither=False)
    c.paint(lid & (c.yy >= 3), BOARD, 0.14, dither=False)
    c.fill(c.rect(5, 3, 7, 4), DULL_IRON[3])
    c.fill(c.rect(11, 3, 13, 4), DULL_IRON[3])
    # the book, open, lying in the box: pages swollen and wavy, the crease in the middle, a thick block of pages under them
    pages = c.rect(2, 4, 14, 9)
    wave = 0.05 * np.sin(c.xx * 1.1 + c.yy * 0.5)
    c.paint(pages & (c.xx < 8), PAPER, 0.8 + wave + 0.08 * (grain - 0.5), dither=False)
    c.paint(pages & (c.xx >= 8), PAPER, 0.9 + wave + 0.08 * (grain - 0.5), dither=False)
    c.paint(pages & ((c.xx == 7) | (c.xx == 8)), PAPER, 0.46, dither=False)  # the crease
    c.paint(pages & (c.yy >= 8), PAPER, 0.36, dither=False)  # the thick block of pages, seen from its edge
    for y, x1 in ((5, 7), (6, 6), (7, 7)):  # grey lines on the left page, none on the right
        c.fill(c.rect(3, y, x1, y + 1), np.array([104.0, 98.0, 86.0], np.float32))
    # the box under it: its front face, lit on the left
    c.paint(c.rect(1, 9, 15, 13), BOARD, np.where(c.yy < 10, 0.9, np.where(c.xx < 8, 0.62, 0.42)) + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(c.rect(1, 12, 15, 13), BOARD, 0.1, dither=False)
    c.fill(c.rect(7, 10, 9, 11), DULL_IRON[3])  # the little hasp
    # the cord and the pencil on the left side of the box
    for y in range(10, 13):
        c.fill(c.rect(0, y, 1, y + 1), BOARD[3])
    c.fill(c.rect(0, 13, 2, 18), PENCIL[2])
    c.fill(c.rect(0, 13, 1, 18), PENCIL[3])
    c.fill(c.rect(0, 18, 2, 19), DULL_IRON[1])
    c.outline(st["outline"])
    return c


# =========================================================================== inside: the shell
def room_shell(ms):
    """The room seen from the front, lying under everything (the floor is baked from the map and stays fully transparent here): a beam under the ceiling
    across the whole width, a strip of dusty plaster under it, then the back wall of warm upright boards (eight pixels each, a seam between them, nails
    now and then), a baseboard, one iron hook off to the left and nothing else (over the bed, the cell (16, 6), the wall is plain: the window is a prop of its
    own); the two side walls (the cells 4 and 28, each 16 pixels wide) with a lit inner edge on the left and a dark one on the right; the front wall (the
    row 17, the lowest 16 pixels) with a plain closed plank door in the column 7 (x 48 to 64) and a round knob at a child's height. 400 x 224, anchor (8, 8):
    the top left corner of the cell (4, 4)."""
    rng = np.random.default_rng(5003)
    c = ms.Canvas(SW, SH)
    grain = pa.value_noise(SH, SW, (3, 8), rng)
    fine = pa.value_noise(SH, SW, (6, 1), rng)
    # ---- the back wall: x 16 to 384, y 0 to 48
    back = c.rect(16, 0, 384, 48)
    idx = ((c.xx - 16) // 8).astype(int)
    tone = (((idx * 7 + 3) % 9) / 9.0 - 0.5) * 0.2
    c.paint(back, ROOM_WOOD, 0.52 + tone + 0.1 * (fine - 0.5) - 0.1 * np.clip((c.yy - 16) / 32.0, 0, 1), contrast=2.0, dither=False)
    c.paint(back & (((c.xx - 16) % 8) == 7), ROOM_WOOD, 0.05, dither=False)  # the seams
    c.paint(back & (((c.xx - 16) % 8) == 0), ROOM_WOOD, 0.74, dither=False)  # each board's lit edge
    for k in range(0, 46):  # a nail in some of the boards, high and low
        if (k * 5 + 1) % 7 in (0, 3):
            x = 16 + k * 8 + 4
            c.fill(c.rect(x, 24, x + 1, 25), ROOM_WOOD[0])
            c.fill(c.rect(x, 38, x + 1, 39), ROOM_WOOD[0])
    # ---- the strip of plaster under the beam, dusty, with a rail under it
    c.paint(c.rect(16, 7, 384, 15), PLASTER, 0.62 + 0.14 * (grain - 0.5) - 0.12 * np.clip((9 - c.yy) / 2.0, 0, 1), contrast=2.0, dither=False)
    c.paint(c.rect(16, 7, 384, 9), PLASTER, 0.28, dither=False)  # the beam's shadow on it
    for x in range(22, 384, 31):  # a crack of dust now and then
        c.fill(c.rect(x, 10, x + 1, 13), PLASTER[1])
    c.paint(c.rect(16, 15, 384, 17), ROOM_WOOD, np.where(c.yy < 16, 0.78, 0.2), dither=False)  # the rail
    # ---- the baseboard
    c.paint(c.rect(16, 43, 384, 48), ROOM_WOOD, np.where(c.yy < 44, 0.82, np.where(c.yy < 47, 0.42, 0.06)) + 0.06 * (fine - 0.5), dither=False)
    # ---- the hook: a small iron plate, a short stem and the curl of the hook; nothing on it
    c.paint(c.rect(91, 22, 95, 25), DULL_IRON, 0.5, dither=False)
    c.fill(c.rect(92, 22, 93, 23), DULL_IRON[3])
    c.paint(c.rect(92, 25, 94, 29), DULL_IRON, 0.45, dither=False)
    for x, y in ((94, 29), (95, 28), (95, 27)):
        c.fill(c.rect(x, y, x + 1, y + 1), DULL_IRON[2])
    c.fill(c.rect(93, 29, 94, 30), DULL_IRON[1])
    c.fill(c.rect(96, 28, 97, 31), ROOM_WOOD[0])  # its small shadow on the board
    # ---- the beam under the ceiling, across the whole width, over the side walls too
    c.paint(c.rect(0, 0, SW, 8), BEAM, np.where(c.yy < 1, 0.5, np.where(c.yy < 3, 0.78, np.where(c.yy > 5, 0.1, 0.44))) + 0.08 * (fine - 0.5), contrast=2.0, dither=False)
    for x in range(10, SW, 37):  # a check in the wood
        c.fill(c.rect(x, 3, x + 5 + (x % 3), 4), BEAM[1])
    # ---- the side walls: dark upright boards, the inner edge lit on the left and dark on the right
    for x0, x1 in ((0, 16), (SW - 16, SW)):
        c.paint(c.rect(x0, 8, x1, SH), ROOM_WOOD, 0.14 + 0.06 * (fine - 0.5), dither=False)
        face = (x0 + 6, x1) if x0 == 0 else (x0, x1 - 6)
        c.paint(c.rect(face[0], 8, face[1], SH - 6), ROOM_WOOD, 0.3 + 0.1 * (fine - 0.5) - 0.1 * np.clip((c.yy - 8) / 200.0, 0, 1), dither=False)
        c.paint(c.rect(face[0], 8, face[1], SH - 6) & (((c.xx - x0) % 5) == 4), ROOM_WOOD, 0.06, dither=False)
        edge = (14, 16) if x0 == 0 else (x0, x0 + 2)
        c.paint(c.rect(edge[0], 8, edge[1], SH - 6), ROOM_WOOD, 0.7 if x0 == 0 else 0.1, dither=False)
    # ---- the front wall, the lowest row: boards, a lit top, a dark foot, the plain plank door in the column 7
    fy = SH - 16
    c.paint(c.rect(16, fy, 384, SH), ROOM_WOOD, 0.46 + 0.05 * (fine - 0.5), dither=False)
    c.paint(c.rect(16, fy, 384, SH) & (((c.xx - 16) % 8) == 7), ROOM_WOOD, 0.05, dither=False)
    c.paint(c.rect(16, fy, 384, fy + 3), ROOM_WOOD, np.where(c.yy < fy + 1, 0.9, 0.55), dither=False)
    c.paint(c.rect(16, SH - 3, 384, SH), ROOM_WOOD, 0.06, dither=False)
    d0, d1 = 48, 64
    c.paint(c.rect(d0 - 3, fy, d0, SH), ROOM_WOOD, 0.74, dither=False)  # the jambs
    c.paint(c.rect(d1, fy, d1 + 3, SH), ROOM_WOOD, 0.24, dither=False)
    c.paint(c.rect(d0 - 3, fy, d1 + 3, fy + 3), ROOM_WOOD, 0.8, dither=False)  # the lintel
    leaf = c.rect(d0, fy + 3, d1, SH - 1)
    plank = ((c.xx - d0) // 4).astype(int)
    c.paint(leaf, ROOM_WOOD, np.where(((c.xx - d0) % 4) == 3, 0.04, 0.26 + 0.08 * ((plank * 7 + 3) % 5) / 5.0 + 0.05 * (fine - 0.5)), dither=False)
    c.fill(c.rect(d1 - 6, SH - 7, d1 - 3, SH - 4), DULL_IRON[3])  # the round knob, low
    c.fill(c.rect(d1 - 6, SH - 7, d1 - 5, SH - 6), PLASTER[4])
    c.fill(c.rect(d1 - 3, SH - 6, d1 - 2, SH - 3), ROOM_WOOD[0])  # its small shadow
    return c


# =========================================================================== inside: bed, window, chalk stick
def bed(ms):
    """A small narrow bed, its head to the north: a headboard of honey wood with an inset panel and a post at each end, a pillow with a faint dent in it
    where a head has not lain, a grey-blue blanket stroked smooth (one soft fold, no crease), the lower rail with its two feet. Nobody in it. 32 x 28,
    anchor (8, 20): the middle of the left of its two cells (the picture reaches half a cell to the left and one cell to the right)."""
    rng = np.random.default_rng(5004)
    st = pa.STYLES["tal"]
    c = ms.Canvas(32, 28)
    grain = pa.value_noise(28, 32, (1, 6), rng)
    # the headboard and its posts
    c.paint(c.rect(1, 0, 31, 9), ROOM_WOOD, np.where(c.yy < 1.5, 0.92, 0.5) + 0.12 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(c.rect(4, 2, 28, 8), ROOM_WOOD, 0.62 + 0.1 * (grain - 0.5), dither=False)  # the inset panel
    c.paint(c.rect(4, 2, 28, 3), ROOM_WOOD, 0.2, dither=False)
    c.paint(c.rect(1, 0, 4, 9) | c.rect(28, 0, 31, 9), ROOM_WOOD, np.where(c.xx < 16, 0.72, 0.32), dither=False)
    # the mattress with its blanket
    c.paint(c.rect(2, 9, 30, 25), BLANKET, 0.5 + 0.12 * (1.0 - np.clip((c.xx - 2) / 28.0, 0, 1)) - 0.12 * np.clip((c.yy - 9) / 16.0, 0, 1) + 0.04 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(c.rect(2, 9, 30, 11), LINEN, 0.7, dither=False)  # the sheet turned down at the head
    c.paint(c.rect(2, 11, 30, 12), LINEN, 0.3, dither=False)
    c.paint(c.rect(2, 17, 30, 18), BLANKET, 0.34, dither=False)  # one soft fold
    c.paint(c.rect(2, 18, 30, 19), BLANKET, 0.7, dither=False)
    c.paint(c.rect(2, 22, 30, 25), BLANKET, 0.3, dither=False)  # the blanket's hanging edge
    # the pillow, a faint dent
    pillow = c.ellipse(15, 12.2, 8.2, 3.6) | c.rect(9, 9, 21, 14)
    c.paint(pillow & c.rect(7, 9, 23, 15), LINEN, 0.78 + 0.1 * c.sphere(12, 10, 12, 8), dither=False, contrast=2.0)
    c.paint(c.ellipse(15, 12, 3.4, 1.3) & pillow, LINEN, 0.46, dither=False)
    c.paint(pillow & (c.yy >= 14), LINEN, 0.3, dither=False)
    # the lower rail and the feet
    c.paint(c.rect(1, 24, 31, 28), ROOM_WOOD, np.where(c.yy < 25, 0.9, 0.46) + 0.1 * (grain - 0.5), contrast=2.0, dither=False)
    c.paint(c.rect(1, 26, 31, 28), ROOM_WOOD, 0.14, dither=False)
    c.paint(c.rect(1, 24, 5, 28) | c.rect(27, 24, 31, 28), ROOM_WOOD, np.where(c.xx < 16, 0.7, 0.3), dither=False)
    c.outline(st["outline"])
    return c


def _frame(c, ex_rows=0):
    """The frame of the window: 24 x 24 plus the sill (to row 27), the mullions in a cross; returns the four pane boxes."""
    c.paint(c.rect(1, 0, 23, 24), ROOM_WOOD, np.where((c.yy < 1.5) | (c.xx < 2.5), 0.86, 0.36), contrast=2.0, dither=False)
    c.paint(c.rect(11, 2, 13, 22), ROOM_WOOD, np.where(c.xx < 12, 0.8, 0.3), dither=False)
    c.paint(c.rect(3, 11, 21, 13), ROOM_WOOD, np.where(c.yy < 12, 0.8, 0.3), dither=False)
    c.paint(c.rect(0, 24, 24, 27), ROOM_WOOD, np.where(c.yy < 25, 0.95, 0.4), contrast=2.0, dither=False)
    c.paint(c.rect(0, 26, 24, 27), ROOM_WOOD, 0.1, dither=False)
    return [(3, 2, 11, 11), (13, 2, 21, 11), (3, 13, 11, 22), (13, 13, 21, 22)]


def _scribble(c, box, rng):
    """One pane scribbled over with blue chalk: a base of the middle tone, then diagonal strokes two pixels wide in four tones, most of them rising to the
    right, a few the other way (stroke over stroke), and at last the rim of warm light the chalk did not reach: the left edge and most of the lower edge."""
    x0, y0, x1, y1 = box
    c.fill(c.rect(x0, y0, x1, y1), CHALK[0])
    w, h = x1 - x0, y1 - y0
    tones = (CHALK[0], CHALK[1], CHALK[1], CHALK[1], CHALK[1], CHALK[2], CHALK[2])
    for direction, count in ((1, 16), (-1, 9), (1, 12)):
        for _ in range(count):
            a = int(rng.integers(-h + 2, w))
            length = int(rng.integers(5, h + 3))
            col = tones[int(rng.integers(0, len(tones)))]
            for t in range(length):
                x = x0 + a + (t if direction > 0 else w - 1 - a - t)
                y = y1 - 1 - t
                for dx in (0, 1):
                    if x0 <= x + dx < x1 and y0 <= y < y1:
                        c.fill(c.rect(x + dx, y, x + dx + 1, y + 1), col)
    rim = np.array([248.0, 236.0, 200.0], np.float32)
    for y in range(y0, y1):
        if rng.random() < 0.8:
            c.fill(c.rect(x0, y, x0 + 1, y + 1), rim)
    for x in range(x0, x1):
        if rng.random() < 0.55:
            c.fill(c.rect(x, y1 - 1, x + 1, y1), rim)
        if rng.random() < 0.15:
            c.fill(c.rect(x, y0, x + 1, y0 + 1), rim)


def window(ms, clear):
    """The window in the back wall: a frame of honey wood with a cross (four panes) and a sill. `clear` False: every pane scribbled over with blue chalk, stroke
    over stroke in two directions, only a thin rim of warm light left at the edges. `clear` True: the same frame, the panes clear (a pale sky above, below
    it the edge of a mountain and a strip of grass), and in one corner a few streaks of chalk the hand did not reach. 24 x 28, anchor (12, 20)."""
    rng = np.random.default_rng(5005 if not clear else 5006)
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 28)
    panes = _frame(c)
    if not clear:
        for box in panes:
            _scribble(c, box, rng)
    else:
        # the scene across the four panes: pale sky, the edge of a mountain, grass
        inner = c.rect(3, 2, 21, 22)
        sky_v = 0.55 + 0.4 * np.clip((c.yy - 2) / 14.0, 0, 1)
        sky = ramp("#8fb4d2", "#b0cde2", "#cfe2ee", "#e8f2f6", "#f6fafb")
        c.paint(inner, sky, sky_v, dither=False)
        mountain = _poly(c, [(11, 18), (15, 14), (19, 11), (21, 10), (21, 18)])
        c.paint(mountain & inner, ramp("#4e6478", "#6c8498", "#8aa0b2", "#b0c0cc"), 0.5 + 0.17 * (c.xx < 16) - 0.1 * np.clip((c.yy - 11) / 8.0, 0, 1), contrast=2.0, dither=False)
        grass = inner & (c.yy >= 17)
        c.paint(grass, st["grass"], 0.55 + 0.25 * (1 - np.clip((c.yy - 17) / 5.0, 0, 1)) + 0.12 * (pa.value_noise(28, 24, 2, rng) - 0.5), contrast=2.0, dither=False)
        c.fill(c.rect(3, 17, 21, 18) & grass, st["grass"][3])
        # chalk the hand did not reach: streaks in the upper left corner of the upper left pane
        for k, (x, y) in enumerate(((3, 2), (4, 2), (5, 3), (6, 4), (3, 4), (4, 5), (3, 6), (5, 2), (4, 3))):
            c.fill(c.rect(x, y, x + 1, y + 1), CHALK[2 if k % 3 else 3])
        c.fill(c.rect(3, 3, 4, 4), CHALK[1])
        c.fill(c.rect(6, 3, 7, 4), CHALK[0])
        # the mullions stay on top
        c.paint(c.rect(11, 2, 13, 22), ROOM_WOOD, np.where(c.xx < 12, 0.8, 0.3), dither=False)
        c.paint(c.rect(3, 11, 21, 13), ROOM_WOOD, np.where(c.yy < 12, 0.8, 0.3), dither=False)
    c.outline(st["outline"])
    return c


def chalk_stick(ms):
    """A stick of blue chalk lying on the floor, a little over a finger long, rounded and worn at the right end, a breath of dust beside and under it. 12 x 6, anchor (6, 3)."""
    c = ms.Canvas(12, 6)
    body = c.rect(1, 1, 10, 4) & ~(c.rect(9, 1, 10, 2) | c.rect(9, 3, 10, 4))
    c.paint(body, CHALK, np.where(c.yy < 2, 0.92, np.where(c.yy < 3, 0.66, 0.38)), contrast=2.0, dither=False)
    c.fill(c.rect(1, 1, 3, 2), CHALK[4])
    c.fill(c.rect(9, 2, 10, 3), CHALK[1])
    c.fill(c.rect(6, 4, 7, 5), CHALK[0])  # dust
    c.fill(c.rect(8, 4, 10, 5), CHALK[0])
    c.fill(c.rect(10, 3, 11, 4), CHALK[0])
    rgba = c.rgba()
    pa.outline(rgba, CHALK_EDGE)
    c.rgb = rgba[..., :3]
    c.a = rgba[..., 3] > 0
    return c


# =========================================================================== inside: the six rings of chalk
# The inclusive extents (xa, ya, xb, yb) of the six rings in the picture (368 x 160): the contract's table, with the top edges of the outer five rings moved
# down by two or three pixels (30 -> 32, 22 -> 25, 14 -> 17, 8 -> 10; 2 stays) so that three pixels of floor stay between two rings at the top, where the room
# is narrowest; the bottoms and the sides are the contract's. The right-hand vertical lines stand at x = 216, 248, 280, 312, 344 and 360 on the row of the bed (y 56).
RINGS = [
    (168, 40, 216, 72),  # 1 room
    (136, 32, 248, 84),  # 2 wall
    (104, 25, 280, 96),  # 3 garden
    (72, 17, 312, 108),  # 4 street
    (40, 10, 344, 120),  # 5 town
    (4, 2, 364, 156),  # 6 world
]
PIN_X = (216, 248, 280, 312, 344, 360)  # where the six points of view stand, on the row y = 56


class Loop:
    """The centre line of a rounded rectangle, sampled every half pixel, clockwise from the end of the top left arc. A (bw x bh) stamp run along it covers
    exactly [xa, xb] x [ya, yb] on the outside. Arrays: x, y (float), nx, ny (the outward normal), s (arc length), side (0 top, 1 right, 2 bottom, 3 left, 4 a corner)."""

    def __init__(self, xa, ya, xb, yb, r, bw=3, bh=2):
        x0, y0 = xa + bw / 2.0, ya + bh / 2.0
        x1, y1 = xb + 1 - bw / 2.0, yb + 1 - bh / 2.0
        xs, ys, nxs, nys, sides = [], [], [], [], []

        def line(ax, ay, bx, by, n, side):
            length = float(np.hypot(bx - ax, by - ay))
            k = max(int(length / 0.5), 1)
            for i in range(k):
                t = i / k
                xs.append(ax + (bx - ax) * t)
                ys.append(ay + (by - ay) * t)
                nxs.append(n[0])
                nys.append(n[1])
                sides.append(side)

        def arc(cx, cy, a0, a1):
            k = max(int(r * abs(a1 - a0) / 0.5), 1)
            for i in range(k):
                a = a0 + (a1 - a0) * i / k
                xs.append(cx + r * np.cos(a))
                ys.append(cy + r * np.sin(a))
                nxs.append(np.cos(a))
                nys.append(np.sin(a))
                sides.append(4)

        h = np.pi / 2
        line(x0 + r, y0, x1 - r, y0, (0, -1), 0)
        arc(x1 - r, y0 + r, -h, 0)
        line(x1, y0 + r, x1, y1 - r, (1, 0), 1)
        arc(x1 - r, y1 - r, 0, h)
        line(x1 - r, y1, x0 + r, y1, (0, 1), 2)
        arc(x0 + r, y1 - r, h, 2 * h)
        line(x0, y1 - r, x0, y0 + r, (-1, 0), 3)
        arc(x0 + r, y0 + r, 2 * h, 3 * h)
        self.x, self.y = np.array(xs), np.array(ys)
        self.nx, self.ny = np.array(nxs), np.array(nys)
        self.side = np.array(sides)
        self.s = np.concatenate([[0.0], np.cumsum(np.hypot(np.diff(self.x), np.diff(self.y)))])
        self.length = float(self.s[-1] + 0.5)
        self.n = len(self.x)

    def wobble(self, rng, amp, scale=(1.0, 1.0), periods=(7, 17)):
        """Moves the line inwards by 0 to `amp` pixels, smoothly and a little differently every time (never outwards: the extents hold)."""
        w = np.zeros(self.n)
        for m in periods:
            w += np.sin(2 * np.pi * (m + rng.integers(0, 3)) * self.s / self.length + rng.uniform(0, 2 * np.pi)) * rng.uniform(0.5, 1.0)
        w = (w - w.min()) / max(w.max() - w.min(), 1e-6)
        d = amp * w
        return self.x - self.nx * d * scale[0], self.y - self.ny * d * scale[1]


def _stamp(mask, xs, ys, bw, bh, on=None, widths=None):
    for i in range(len(xs)):
        if on is not None and not on[i]:
            continue
        w = bw if widths is None else int(widths[i])
        ix = int(np.floor(xs[i] - w / 2.0 + 0.5))
        iy = int(np.floor(ys[i] - bh / 2.0 + 0.5))
        y0, y1, x0, x1 = max(iy, 0), min(iy + bh, RH), max(ix, 0), min(ix + w, RW)
        if y0 < y1 and x0 < x1:
            mask[y0:y1, x0:x1] = True


def _widths(loop, rng, lo=2, hi=3):
    """A stroke width in pixels for every sample, changing every ten or so pixels (the hand presses harder and lighter)."""
    out = np.zeros(loop.n, int)
    i = 0
    while i < loop.n:
        k = int(rng.integers(12, 28))
        out[i:i + k] = hi if rng.random() < 0.65 else lo
        i += k
    return out


def _breaks(loop, rng, count, length, avoid=None):
    """On/off flags: `count` breaks of about `length` pixels where the chalk was lifted (never on the points in `avoid`)."""
    on = np.ones(loop.n, bool)
    for _ in range(count):
        for _try in range(20):
            s0 = rng.uniform(0, loop.length)
            sel = (loop.s >= s0) & (loop.s < s0 + length)
            if avoid is not None and (avoid & sel).any():
                continue
            on &= ~sel
            break
    return on


def _dash_flags(loop, rng, on_range, off_h, off_v, phase):
    """Brick-like dashes along the loop: on for `on_range` pixels, off for `off_h` on the horizontal runs and `off_v` on the vertical ones."""
    flags = np.zeros(loop.n, bool)
    t = -phase
    on = True
    end = t + rng.uniform(*on_range)
    for i in range(loop.n):
        while loop.s[i] >= end:
            on = not on
            off = off_h if loop.side[i] in (0, 2) else off_v
            end += rng.uniform(*on_range) if on else off
        flags[i] = on
    return flags


def _line(mask, x0, y0, x1, y1):
    n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
    for i in range(n):
        t = i / max(n - 1, 1)
        x, y = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t))
        if 0 <= x < RW and 0 <= y < RH:
            mask[y, x] = True


def _pin(mask, x, rows=(54, 59), width=3):
    """The point of view stands on the right-hand line at the row of the bed: make sure the chalk is there."""
    mask[rows[0]:rows[1], x - width + 1:x + 1] = True


def chalk_rings(ms):
    """Six closed hand-drawn loops of blue chalk, one inside the other (368 x 160, flat, anchor (8, 8): the top left corner of the cell (5, 7)). The lines are two to three pixels
    thick, wobble a little, are lifted here and there and drawn over again (a pixel drawn over twice is brighter), dusty at their edges. 1 the room: a square round the bed, drawn
    over three times, with a bulge like a pillow at one corner; 2 the wall: two courses of short staggered strokes like the stones of a wall; 3 the garden: a wavy line with
    stems, small leaves and blossoms (crosses and rings); 4 the street: two parallel lines with small marks between them going in both directions; 5 the town: a row of small
    boxes with pointed roofs, house against house, no window open, no door left out; 6 the world: one line drawn twice, unbroken, along the walls and across the place of the door."""
    rng = np.random.default_rng(5101)
    weight = np.zeros((RH, RW), np.int8)

    def add(mask):
        weight[mask] += 1

    # ---- 1 the room: three passes round the bed, a bulge like a pillow at the north west corner
    xa, ya, xb, yb = RINGS[0]
    loop = Loop(xa, ya, xb, yb, 3)
    for k in range(3):
        m = np.zeros((RH, RW), bool)
        xs, ys = loop.wobble(rng, 1.2 if k else 0.4, periods=(5, 11))
        _stamp(m, xs, ys, 3, 2, on=_breaks(loop, rng, 2 if k else 0, 4), widths=_widths(loop, rng, 2, 3))
        if k == 0:
            _pin(m, xb)
        add(m)
    pil = np.zeros((RH, RW), bool)
    for t in np.linspace(0, 2 * np.pi, 80, endpoint=False):  # the pillow: a small flat loop on the corner, its line drawn twice
        x, y = 165 + 5.5 * np.cos(t), 43 + 3.4 * np.sin(t)
        pil[int(round(y)):int(round(y)) + 2, int(round(x)):int(round(x)) + 2] = True
    add(pil)
    add(pil)
    # ---- 2 the wall: two courses of short staggered strokes
    xa, ya, xb, yb = RINGS[1]
    outer = Loop(xa, ya, xb, yb, 5)
    inner = Loop(xa + 4, ya + 3, xb - 4, yb - 3, 3)
    m = np.zeros((RH, RW), bool)
    _stamp(m, outer.x, outer.y, 3, 2, on=_dash_flags(outer, rng, (4.6, 6.2), 4.0, 3.0, 0.0), widths=_widths(outer, rng))
    _pin(m, xb)
    add(m)
    m = np.zeros((RH, RW), bool)
    _stamp(m, inner.x, inner.y, 3, 2, on=_dash_flags(inner, rng, (4.6, 6.2), 4.0, 3.0, 3.0), widths=_widths(inner, rng))
    add(m)
    for lp in (outer, inner):  # some of the strokes drawn over a second time
        m = np.zeros((RH, RW), bool)
        sel = np.zeros(lp.n, bool)
        for s0 in rng.uniform(0, lp.length, 14):
            sel |= (lp.s >= s0) & (lp.s < s0 + 7)
        _stamp(m, lp.x, lp.y, 3, 2, on=sel, widths=_widths(lp, rng))
        add(m)
    # ---- 3 the garden: a wavy line with stems that grow inwards, small leaves and blossoms (crosses and rings)
    xa, ya, xb, yb = RINGS[2]
    loop = Loop(xa, ya, xb, yb, 7)
    for k in range(2):
        m = np.zeros((RH, RW), bool)
        xs, ys = loop.wobble(rng, 2.0, scale=(1.5, 0.45), periods=(int(loop.length / 14), int(loop.length / 8)))
        _stamp(m, xs, ys, 3, 2, on=_breaks(loop, rng, 3, 3, None), widths=_widths(loop, rng, 2, 3))
        if k == 0:
            _pin(m, xb)
            wx, wy = xs, ys
        add(m)
    reach = {0: 2, 1: 8, 2: 6, 3: 8}
    plants = np.zeros((RH, RW), bool)

    def dot(x, y):
        if 0 <= x < RW and 0 <= y < RH:
            plants[y, x] = True

    i, kind = 50, 0
    while i < loop.n - 50:
        side = int(loop.side[i])
        if side == 4:
            i += 6
            continue
        px, py, nx, ny = wx[i], wy[i], loop.nx[i], loop.ny[i]
        rch = reach[side]
        cx, cy = px - nx * rch, py - ny * rch
        ix, iy = int(round(cx)), int(round(cy))
        if rch > 3:  # a stem from the line to the blossom, a leaf or two on it
            _line(plants, int(round(px - nx * 2)), int(round(py - ny * 2)), ix, iy)
            tx, ty = -ny, nx
            for f in (0.35, 0.65):
                mx, my = px - nx * rch * f, py - ny * rch * f
                sgn = 1 if (kind + int(f * 10)) % 2 else -1
                dot(int(round(mx + tx * sgn * 1)), int(round(my + ty * sgn * 1)))
                dot(int(round(mx + tx * sgn * 2 - nx)), int(round(my + ty * sgn * 2 - ny)))
        if kind % 3 == 0:  # a cross
            for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
                dot(ix + dx, iy + dy)
        elif kind % 3 == 1:  # a ring
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
                dot(ix + dx, iy + dy)
        else:  # a small bud: a pair of pixels with a leaf either side
            for dx, dy in ((0, 0), (0, -1), (-1, 0), (1, 0)):
                dot(ix + dx, iy + dy)
        kind += 1
        i += int(rng.integers(10, 15)) * 2
    add(plants)
    add(plants & (rng.random((RH, RW)) < 0.6))
    # ---- 4 the street: two parallel lines, small marks between them going both ways
    xa, ya, xb, yb = RINGS[3]
    outer = Loop(xa, ya, xb, yb, 8, 3, 2)
    inner = Loop(xa + 7, ya + 4, xb - 7, yb - 4, 5, 3, 1)
    for lp, bh in ((outer, 2), (inner, 1)):
        for k in range(2):
            m = np.zeros((RH, RW), bool)
            xs, ys = lp.wobble(rng, 0.3 if bh == 2 else 1.2, scale=(1.0, 0.5), periods=(6, 13))
            _stamp(m, xs, ys, 3, bh, on=_breaks(lp, rng, 2 if k else 1, 3), widths=_widths(lp, rng, 2, 3))
            if k == 0 and lp is outer:
                _pin(m, xb)
            add(m)
    # the marks: along the middle of the gap (x xa+3 to xa+6 on the sides, y ya+2 and ya+3 above and below), pairs of dashes pointing clockwise and back
    mid = Loop(xa + 3, ya + 2, xb - 3, yb - 2, 7, 4, 2)
    marks = np.zeros((RH, RW), bool)
    k = 0
    for i in range(0, mid.n, 14):
        side = mid.side[i]
        if side == 4:
            continue
        x, y = mid.x[i], mid.y[i]
        direction = 1 if k % 2 == 0 else -1  # clockwise or against it
        tx, ty = {0: (1, 0), 1: (0, 1), 2: (-1, 0), 3: (0, -1)}[side]
        tx, ty = tx * direction, ty * direction
        lane = 0.8 if k % 2 == 0 else -0.8  # two lanes, one for each way
        px, py = x + (-ty) * lane * (1.2 if side in (1, 3) else 0.0), y + tx * lane * (0.0 if side in (1, 3) else 0.6)
        for j in range(0, 3):  # a dash of three pixels, the toe a pixel beyond
            xx, yy = int(round(px + tx * (j - 1))), int(round(py + ty * (j - 1)))
            if 0 <= xx < RW and 0 <= yy < RH:
                marks[yy, xx] = True
        xx, yy = int(round(px + tx * 2.4)), int(round(py + ty * 2.4))
        if 0 <= xx < RW and 0 <= yy < RH:
            marks[yy, xx] = True
        k += 1
    add(marks)
    # ---- 5 the town: houses against one another, roofs pointing out, no gap, no window open, no door left out
    xa, ya, xb, yb = RINGS[4]
    houses = np.zeros((RH, RW), bool)
    base = np.zeros((RH, RW), bool)
    hd = {0: 3, 2: 6, 1: 8, 3: 8}  # the depth of the houses on each side: roof and wall, from the roof tips in; the line they stand on lies behind them
    loop = Loop(xa + hd[3], ya + hd[0], xb - hd[1], yb - hd[2], 4, 2, 1)
    for k in range(2):
        m = np.zeros((RH, RW), bool)
        xs, ys = loop.wobble(rng, 0.0 if k == 0 else 0.0, periods=(9, 19))
        _stamp(m, xs, ys, 2, 1)
        base |= m
    add(base)
    add(base)

    def house_row(u_lo, u_hi, pitch, wall_h, roof_h, draw):
        """Houses along u from u_lo to u_hi: each is a box (its walls shared with the next one) with a pointed roof; `draw(u, v)` plots one pixel, v = 0 at the roof tips."""
        n = max(int(round((u_hi - u_lo) / pitch)), 1)
        p = (u_hi - u_lo) / n
        for h in range(n + 1):
            u = u_lo + h * p
            for v in range(roof_h, roof_h + wall_h + 1):  # the wall
                draw(int(round(u)), v)
            if h < n:
                un = u + p
                for t in range(0, int(round(p / 2)) + 1):  # the roof: two slopes up to the tip
                    v = roof_h - int(round(t * roof_h / max(p / 2, 1)))
                    draw(int(round(u + t)), v)
                    draw(int(round(un - t)), v)

    def plot(side):
        def draw(u, v):
            if side == 0:
                x, y = u, ya + v
            elif side == 2:
                x, y = u, yb - v
            elif side == 3:
                x, y = xa + v, u
            else:
                x, y = xb - v, u
            if 0 <= x < RW and 0 <= y < RH:
                houses[y, x] = True
        return draw

    house_row(xa + 14, xb - 14, 4, 0, 2, plot(0))
    house_row(xa + 14, xb - 14, 6, 2, 3, plot(2))
    house_row(ya + 14, yb - 14, 8, 3, 4, plot(3))
    house_row(ya + 14, yb - 14, 8, 3, 4, plot(1))
    houses[54:59, xb - 1:xb + 1] = True  # a roof tip at the point of view
    add(houses)
    add(houses)
    # ---- 6 the world: one line drawn twice, unbroken, over the place of the door
    xa, ya, xb, yb = RINGS[5]
    outer = Loop(xa, ya, xb, yb, 10, 2, 2)
    inner = Loop(xa + 4, ya + 3, xb - 4, yb - 3, 7, 2, 2)
    for lp in (outer, inner):
        for k in range(2):
            m = np.zeros((RH, RW), bool)
            xs, ys = lp.wobble(rng, 0.5 if k else 0.0, periods=(5, 13))
            _stamp(m, xs, ys, 2, 2)
            if k == 0 and lp is inner:
                _pin(m, xb - 4, width=2)
            add(m)
    # ---- the chalk itself: brighter where drawn over, dusty at the edges, ragged, with a few specks of dust beside the lines
    lvl = np.clip(weight, 0, 3).astype(int)
    on = lvl > 0
    edge = on & ~(np.roll(on, 1, 0) & np.roll(on, -1, 0) & np.roll(on, 1, 1) & np.roll(on, -1, 1))
    idx = np.where(on, lvl, 0)
    idx = np.where(edge, np.maximum(idx - 1, 0), idx)
    r = rng.random((RH, RW))
    idx = np.where(on & ~edge & (r < 0.07), np.maximum(idx - 1, 0), idx)
    idx = np.where(on & ~edge & (r > 0.95), np.minimum(idx + 1, 4), idx)
    protect = np.zeros_like(on)
    for x in PIN_X:  # the chalk at the six points of view is never ragged
        protect[54:59, x - 2:x + 1] = True
    keep = on & ~(edge & (lvl == 1) & ~protect & (rng.random((RH, RW)) < 0.22))
    near = np.zeros_like(on)
    for dy in (-2, -1, 0, 1, 2):
        for dx in (-2, -1, 0, 1, 2):
            near |= np.roll(np.roll(on, dy, 0), dx, 1)
    stray = near & ~on & (rng.random((RH, RW)) < 0.025)
    c = ms.Canvas(RW, RH)
    c.fill(keep, CHALK[idx][keep])
    c.fill(stray, CHALK[0])
    for x in PIN_X:  # a last check: the chalk is there
        assert c.a[54:59, x].all(), "no chalk at the point of view x=%d" % x
    return c


# =========================================================================== catalog
def build(ms):
    """Registers the sprites of G8 in the catalog. No shadow on any of them (the stamp of `grat` must not change; `urhaus` is baked after them)."""
    ms.save("tal", "gb_first_house", first_house(ms), (24, 40), shape={"rect": [48, 16], "offset": [0, 0]})
    ms.save("tal", "gb_summit_book", summit_book(ms), (8, 20), shape={"rect": [8, 6], "offset": [0, -1]})
    ms.save("tal", "uh_shell", room_shell(ms), (8, 8), flat=True)
    ms.save("tal", "uh_bed", bed(ms), (8, 20), shape={"rect": [30, 12], "offset": [8, -2]})
    ms.save("tal", "uh_window", window(ms, False), (12, 20))
    ms.save("tal", "uh_window_clear", window(ms, True), (12, 20))
    ms.save("tal", "uh_chalk_rings", chalk_rings(ms), (8, 8), flat=True)
    ms.save("tal", "uh_chalk", chalk_stick(ms), (6, 3), flat=True)


def preview(path):
    """`--preview out.png`: the room as the map lays it out (shell, rings, bed, window, chalk) over a floor colour, and the outside things beside it (3x)."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image

    def img(canvas):
        return Image.fromarray(canvas.rgba().astype(np.uint8), "RGBA")

    sheet = Image.new("RGBA", (SW + 120, SH + 4), (96, 136, 88, 255))
    floor = Image.new("RGBA", (368, 160), (114, 79, 56, 255))
    sheet.alpha_composite(floor, (16, 48))
    sheet.alpha_composite(img(chalk_rings(ms)), (16, 48))
    sheet.alpha_composite(img(room_shell(ms)), (0, 0))
    sheet.alpha_composite(img(bed(ms)), (16 + 176 - 8 + 8, 48 + 56 - 20))
    sheet.alpha_composite(img(window(ms, False)), (200 - 12, 40 - 20))
    sheet.alpha_composite(img(chalk_stick(ms)), (16 + 4 * 16 + 8 - 6, 48 + 8 * 16 + 8 - 3))
    sheet.alpha_composite(img(first_house(ms)), (SW + 8, 4))
    sheet.alpha_composite(img(summit_book(ms)), (SW + 64, 4))
    sheet.alpha_composite(img(window(ms, True)), (SW + 64, 40))
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    else:
        sys.exit("usage: akt5_house_props.py --preview out.png")
