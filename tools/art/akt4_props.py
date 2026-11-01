"""Props for Act IV (docs/akt4/REGIONSBRIEFE.md), drawn like make_sprites.py and registered in the same
catalog (style "tal", so they share the atlas of the valley). Called from make_sprites.build();
`--preview out.png` draws them on one sheet (3x) to look at.

Straße (S1): the cart road from the valley to the town, a walk of small things and small jokes. Nothing here is a
person and nothing is a symbol; every piece has the shape of what it was made for, and the one animal that is in all of
it (a goat) is there only as its hoof prints in the dust and as the bell it left on a post. Signposts (one at the valley's
edge, one at the road's start with a second, crooked board), a milestone that feet have worn smooth, the post that holds
the goat's bell (the post and the bell are two props: the bell hangs on a nail of the post and is gone once it has been
taken), a scarecrow with a pot for a hat and a crow on the pot, a field notice with a joke on it, a bench that stands on a
stump and a stack of stones, apple trees, hay, the parapet of a stone bridge, the roofs of the town behind the hill (each
with the smoke of its chimney), and the roadworks at the end of the way: a rope across it on two posts and a heap of
cobbles with a hammer. No prop has a light. The ones that the map places under `if`/`unless` carry no shadow in the
catalog (shadow cells feed the baked stamp of the map).
"""
import os
import sys

import numpy as np

import pixelart as pa
from pixelart import ramp

SACK = ramp("#2c241a", "#4e3f2a", "#78633f", "#a38a58", "#cdb685")
STRAW = ramp("#4e3a14", "#80601e", "#b48c30", "#dcb84e", "#f4de86")
HAY = ramp("#5a4214", "#8e6a1e", "#c29a34", "#e6c458", "#f9e68e")
CORD = ramp("#4a4234", "#7a6e56", "#a89a7a", "#cfc29e")
BRASS = ramp("#3e260c", "#7c5018", "#bd8a28", "#ecc050", "#fff0a2")
IRON_DARK = ramp("#14161a", "#26292f", "#40454e", "#6a707a")
MOSS = ramp("#16261a", "#22382a", "#33503a", "#4a6c46")
LICHEN = ramp("#5a6648", "#7e8c5e", "#a2b27a")
APPLE_RED = ramp("#3e0e0c", "#7e1a14", "#bc3020", "#e8603a", "#ff9c6a")
APPLE_GOLD = ramp("#4a3a0c", "#8a6e18", "#c8a42c", "#e8cc50", "#fbeb92")
PLASTER = ramp("#463e36", "#78695a", "#a79882", "#cfc2a4", "#eee4c8")
TERRACOTTA = ramp("#3a1812", "#68281c", "#98442a", "#c46c3a", "#e8985a")
TOWN_STONE = ramp("#2e2b2c", "#4b4646", "#6e6862", "#928a7f", "#b8ae9e")
SHUTTER = ramp("#1a2c2a", "#2a4a44", "#3e6a5e", "#5e9078")
PANE = ramp("#16222c", "#243646", "#3a5468", "#6890a8")
CLOTH = ramp("#6a5a3a", "#a08c58", "#cdb97c", "#efe3b4")
BIRD = ramp("#0a0a10", "#1a1a24", "#2c2c3c", "#464658")
SPLAT = ramp("#8c8a80", "#c4c2b6", "#e6e4d8", "#fbfaf2")
CRATE_BLUE = ramp("#1e2c3e", "#34506e", "#4f7498", "#7aa0c0")


def _stone(ms, c, mask, value, seed, contrast=2.0):
    """Paint `mask` in the valley's stone with a little grain."""
    rng = np.random.default_rng(seed)
    c.paint(mask, pa.STYLES["tal"]["stone"], np.clip(value + 0.1 * (pa.value_noise(c.h, c.w, 3, rng) - 0.5), 0, 1),
            contrast=contrast)


# --------------------------------------------------------------------------- signposts
def sign(ms):
    """A weathered post with one arrow board that points west, along the road to the town; the words are worn to
    scratches. 32 x 36, anchor (15, 34)."""
    rng = np.random.default_rng(901)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(32, 36)
    grain = pa.value_noise(36, 32, (1, 5), rng)
    c.paint(c.rect(13, 8, 17, 35), ex["plank"], np.where(c.xx < 15, 0.62, 0.28) + 0.1 * (grain - 0.5), dither=False)
    board = c.rect(8, 6, 29, 16) | (c.rect(2, 6, 8, 16) & (np.abs(c.yy + 0.5 - 11) <= (c.xx - 1.5) * 0.9))
    c.paint(board, ex["plank"], 0.55 + 0.2 * (1 - (c.yy - 6) / 10) + 0.15 * (grain - 0.5), contrast=2.0)
    for x0, x1 in ((10, 14), (16, 19), (21, 26)):  # words worn to scratches
        c.paint(c.rect(x0, 9, x1, 10), ex["plank"], 0.1, dither=False)
        c.paint(c.rect(x0 + 1, 12, x1 - 1, 13), ex["plank"], 0.16, dither=False)
    c.paint(c.rect(9, 14, 28, 15), ex["plank"], 0.18, dither=False)  # a worn rule under them
    c.fill(c.rect(27, 7, 28, 8), ex["iron"][3])  # a nail
    c.fill(board & (pa.value_noise(36, 32, 1.5, rng) > 0.84), LICHEN[1])
    c.outline(st["outline"])
    return c


def sign_two(ms):
    """The signpost at the start of the road: a long arrow board that points west and, under it, a small board that
    hangs from one nail, sags to the right and points back to the east. 38 x 46, anchor (17, 44)."""
    rng = np.random.default_rng(903)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(38, 46)
    grain = pa.value_noise(46, 38, (1, 5), rng)
    c.paint(c.rect(15, 6, 20, 45), ex["plank"], np.where(c.xx < 17, 0.62, 0.28) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.rect(14, 4, 21, 7), ex["plank"], np.where(c.xx < 17, 0.8, 0.5), dither=False)
    top = c.rect(9, 7, 34, 18) | (c.rect(2, 7, 9, 18) & (np.abs(c.yy + 0.5 - 12.5) <= (c.xx - 1.5) * 0.85))
    c.paint(top, ex["plank"], 0.55 + 0.2 * (1 - (c.yy - 7) / 11) + 0.15 * (grain - 0.5), contrast=2.0)
    for x0, x1 in ((10, 15), (17, 20), (22, 27), (28, 32)):
        c.paint(c.rect(x0, 10, x1, 11), ex["plank"], 0.1, dither=False)
    c.paint(c.rect(11, 14, 31, 15), ex["plank"], 0.16, dither=False)
    c.fill(c.rect(31, 8, 32, 9), ex["iron"][3])
    # the small board: it hangs from a nail near its left end and sags, so that its right end is lower; a pointed end to the east
    sag = (c.xx - 15) * 0.22
    small = (c.xx >= 14) & (c.xx < 33) & (c.yy >= 22 + sag) & (c.yy < 30 + sag)
    tip = (c.xx >= 33) & (c.xx < 37) & (np.abs(c.yy - (26 + sag) + 0.5) <= (37 - c.xx) * 0.9 + 0.2)
    board = small | tip
    c.paint(board, ex["plank"], 0.5 + 0.2 * (1 - (c.yy - 22 - sag) / 8) + 0.15 * (grain - 0.5), contrast=2.0)
    for x0, x1 in ((17, 21), (23, 27)):
        c.paint(c.rect(x0, 25, x1, 26) & board, ex["plank"], 0.12, dither=False)
    c.fill(c.rect(15, 21, 17, 23), ex["iron"][3])  # the nail it hangs from
    c.fill(c.rect(21, 20, 22, 22), ex["iron"][2])  # and a bent one beside it that holds nothing
    c.fill(board & (pa.value_noise(46, 38, 1.5, rng) > 0.86), LICHEN[1])
    c.outline(st["outline"])
    return c


def milestone(ms):
    """A milestone that feet have worn smooth: a squat loaf of stone that leans a little, the face worn to a shallow
    hollow in which the lettering is only a few dents (nothing to read), a groove across the top where hands and boots
    rested, a chip out of one corner, moss and grass at the foot. 28 x 26, anchor (14, 24)."""
    rng = np.random.default_rng(905)
    st = pa.STYLES["tal"]
    c = ms.Canvas(28, 26)
    lean = (c.yy - 22) * 0.07
    body = (c.ellipse(14 + lean, 14.5, 10.4, 8.6) & (c.yy < 22)) | (c.rect(3.8, 14.5, 24.2, 22) & (np.abs(c.xx + 0.5 - 14 - lean) <= 10.4))
    c.paint(c.ellipse(14, 22.6, 12.4, 2.8), st["stone"], 0.3, dither=False)
    light = 0.2 + 0.58 * c.cylinder(3, 25) + 0.2 * np.clip((16 - c.yy) / 10, 0, 1) + 0.08 * (pa.value_noise(26, 28, 3, rng) - 0.5)
    c.paint(body, st["stone"], light, contrast=2.2)
    c.paint(c.ellipse(13.5, 9.0, 7.4, 1.8) & body, st["stone"], 0.94, dither=False)  # the top, worn smooth and pale
    c.paint(c.ellipse(15.5, 9.8, 4.4, 0.9) & body, st["stone"], 0.4, dither=False)  # the groove where boots rested
    panel = c.rect(6, 13, 22, 21) & body
    c.paint(panel, st["stone"], 0.62 - 0.12 * (c.yy - 13) / 8 + 0.06 * (c.xx < 13), contrast=2.0, dither=False)
    for y, x0, x1 in ((15, 8, 14), (17, 10, 17), (19, 8, 13)):  # dents where the letters were: rows, not words
        c.paint(c.rect(x0, y, x1, y + 1) & panel, st["stone"], 0.34, dither=False)
        c.paint(c.rect(x0 + 1, y + 1, x1 - 1, y + 2) & panel, st["stone"], 0.76, dither=False)
    c.paint(c.rect(6, 13, 22, 14) & panel, st["stone"], 0.88, dither=False)
    c.fill(c.rect(20, 11, 24, 14) & body & (c.xx + c.yy > 33), st["stone"][1])  # a chip out of the right shoulder
    moss = (c.ellipse(14, 22.4, 11.5, 3.2) & (c.yy > 19)) & (pa.value_noise(26, 28, 2, rng) > 0.38)
    c.paint(moss, MOSS, 0.55, dither=False)
    for gx in (3, 6, 21, 24):  # grass at its foot
        c.fill(c.rect(gx, 21, gx + 1, 24), pa.STYLES["tal"]["grass"][3])
        c.fill(c.rect(gx + 1, 22, gx + 2, 24), pa.STYLES["tal"]["grass"][2])
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the bell post
POST_NAIL = (3, 18)  # the nail's place relative to the foot of the post: 3 px to the right, 18 px up


def post(ms, tied=False):
    """A fence post with a square cap and an iron nail in its front (the bell hangs from it). With `tied` the post of
    the roadworks: a loop of rope round the neck and a scrap of cloth. 12 x 34, anchor (6, 32)."""
    rng = np.random.default_rng(907 + (5 if tied else 0))
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(12, 34)
    grain = pa.value_noise(34, 12, (1, 6), rng)
    shaft = c.rect(3, 4, 9, 33)
    c.paint(shaft, ex["plank"], np.where(c.xx < 5, 0.72, np.where(c.xx > 7, 0.26, 0.5)) + 0.12 * (grain - 0.5),
            contrast=2.2, dither=False)
    c.paint(c.rect(2, 2, 10, 5), ex["plank"], np.where(c.xx < 5, 0.88, 0.55), dither=False)  # the cap
    c.paint(c.rect(3, 3, 9, 4), ex["plank"], 0.96, dither=False)
    c.paint(c.rect(4, 12, 5, 20), ex["plank"], 0.12, dither=False)  # a split
    c.paint(c.ellipse(6, 33, 5.2, 1.6), st["stone"], 0.3, dither=False)  # a few stones banked against the foot
    if tied:
        c.paint(c.rect(2, 6, 10, 8), CORD, 0.7, dither=False)
        c.paint(c.rect(2, 8, 10, 9), CORD, 0.25, dither=False)
        c.paint(c.rect(9, 8, 11, 17), CLOTH, 0.7, dither=False)  # a scrap of cloth on the rope's end
        c.paint(c.rect(9, 15, 11, 17), CLOTH, 0.4, dither=False)
    else:
        nx, ny = 6 + POST_NAIL[0], 32 - POST_NAIL[1]
        c.fill(c.rect(nx - 1, ny - 1, nx + 2, ny + 2), np.array([132, 138, 148], np.float32))  # the pale head of the nail
        c.fill(c.rect(nx, ny, nx + 1, ny + 1), np.array([60, 64, 72], np.float32))
        c.fill(c.rect(nx, ny + 2, nx + 2, ny + 4), np.array([150, 92, 52], np.float32))  # a rusty hook under it
    c.outline(st["outline"])
    return c


def bell(ms):
    """The goat's bell on a short cord, ready to hang from the nail of the post (the map puts it on the cell below the
    post and the catalog anchor lifts it onto the nail): a cord, a small brass bell, a clapper. 10 x 16; the cord's top
    is at (4, 0)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(10, 16)
    c.paint(c.rect(4, 0, 5, 3), CORD, np.where(c.xx < 4.5, 0.8, 0.4), dither=False)
    c.fill(c.rect(3, 1, 4, 2), CORD[1])
    half = 1.8 + (c.yy - 3) * 0.5
    body = (c.yy >= 3) & (c.yy < 12) & (np.abs(c.xx + 0.5 - 5) <= half)
    c.paint(body, BRASS, 0.3 + 0.65 * c.cylinder(1.5, 8.5) - 0.05 * (c.yy - 3), contrast=2.0, dither=False)
    c.paint(c.rect(2, 10, 8, 12), BRASS, np.where(c.xx < 4, 0.7, 0.28), dither=False)  # the lip
    c.paint(c.rect(4, 12, 6, 14), IRON_DARK, 0.7, dither=False)  # the clapper
    c.paint(c.ellipse(5, 14.2, 1.5, 1.4), IRON_DARK, 0.85, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the goat's prints
def prints(ms, seed):
    """A short run of cloven hoof prints in the dust, going west: each print is two lobes of four by two pixels that
    run together towards the west (the points), a dark upper left wall and a lit lower rim, a hind print a little behind
    and beside each fore print, now and then one scuffed (a lobe missing its point). Flat; 48 x 16, anchor (24, 8)."""
    rng = np.random.default_rng(seed)
    path = pa.STYLES["tal"]["path"]
    c = ms.Canvas(48, 16)

    def hoof(x, y, scuff):
        upper = [(x + 1, y - 3), (x + 2, y - 3), (x + 3, y - 3), (x, y - 2), (x + 1, y - 2), (x + 2, y - 2), (x + 3, y - 2)]
        lower = [(x, y), (x + 1, y), (x + 2, y), (x + 3, y), (x + 1, y + 1), (x + 2, y + 1), (x + 3, y + 1)]
        if scuff:
            lower = [p for p in lower if p[0] > x]
        for px, py in upper + lower:
            c.fill(c.rect(px, py, px + 1, py + 1), path[1])
        for px, py in (upper[0], upper[3], lower[0]):
            c.fill(c.rect(px, py, px + 1, py + 1), path[0])  # the dark wall on the upper left
        for px, py in lower[4:]:
            c.fill(c.rect(px, py + 1, px + 1, py + 2), path[3])  # the lit rim under the lower lobe

    x = 41
    side = 1
    while x > 4:
        scuff = bool(rng.random() < 0.2)
        hoof(x, 7 + side * 2, scuff)
        hoof(x + 5, 8 + side * 2 + (1 if rng.random() < 0.5 else 0), False)
        x -= int(rng.integers(11, 14))
        side = -side
    return c


# --------------------------------------------------------------------------- the field
def scarecrow(ms):
    """A scarecrow on a post: sacking coat with a blue and a brown patch, straw at the wrists, a round sack for a head
    with a stitched crooked smile and two unequal buttons for eyes, a battered iron pot for a hat (its handle on one
    side, straw out of a hole) and on its arm, quite at home, a crow. Two mismatched boots hang under the coat.
    48 x 62, anchor (22, 58)."""
    rng = np.random.default_rng(911)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 62)
    grain = pa.value_noise(62, 48, (1, 4), rng)
    c.paint(c.rect(20, 14, 24, 58), ex["plank"], np.where(c.xx < 22, 0.6, 0.26) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.ellipse(22, 58, 6, 1.8), st["stone"], 0.3, dither=False)  # stones round the foot of the post
    # the crossbar, a little tilted, with the sleeves over it
    bar_y = lambda x: 21 + (x - 22) * 0.04  # noqa: E731
    c.paint(ms.limb_mask(c, 3, bar_y(3), 41, bar_y(41), 3), ex["plank"], 0.55, dither=False)
    for (sx, sy), (hx, hy), shade in (((15, 22), (5, 25), 0.0), (((29, 22)), (39, 25), -0.12)):
        sleeve = ms.limb_mask(c, sx, sy, hx, hy, 6)
        c.paint(sleeve, SACK, 0.55 + shade + 0.12 * (grain - 0.5) - 0.2 * (c.yy - sy) / 8, contrast=2.0)
    # straw at the wrists
    for x, sgn in ((4, -1), (40, 1)):
        for k in range(5):
            c.fill(c.rect(x + sgn * (k // 2) - 1, 20 + k * 1, x + sgn * (k // 2) + 1, 21 + k * 1), STRAW[2 + (k % 2)])
        c.paint(c.ellipse(x, 24, 2.4, 3.2), STRAW, 0.55, dither=False)
    # the coat: a sack that hangs from the shoulders, with a hem frayed at the bottom
    coat = c.ellipse(22, 33, 9.4, 13.4) | c.rect(13, 28, 31, 40)
    coat &= (c.yy < 46) & (c.yy > 21)
    c.paint(coat, SACK, 0.28 + 0.62 * c.cylinder(11, 33) + 0.08 * (grain - 0.5), contrast=2.0)
    c.paint(coat & (c.yy > 42), SACK, 0.22, dither=False)
    hem = (c.yy >= 43) & (c.yy < 46) & coat & (((c.xx.astype(int) % 3) == 0) | (c.yy < 44))
    c.paint(hem, SACK, 0.5, dither=False)
    c.paint(c.rect(16, 29, 22, 35), CRATE_BLUE, 0.55 + 0.2 * c.cylinder(16, 22), dither=False)  # a blue patch
    c.paint(c.rect(23, 36, 28, 40), SACK, 0.88, dither=False)  # a lighter brown one
    for px in range(16, 22, 2):  # stitches round the blue patch
        c.fill(c.rect(px, 29, px + 1, 30), SACK[0])
        c.fill(c.rect(px, 34, px + 1, 35), SACK[0])
    for px in range(23, 28, 2):
        c.fill(c.rect(px, 36, px + 1, 37), SACK[0])
        c.fill(c.rect(px, 39, px + 1, 40), SACK[0])
    c.paint(c.rect(21, 20, 24, 23), CORD, 0.6, dither=False)  # the rope at the neck
    # the legs: two sack trousers that end in boots which hang in the air, a brown boot and a grey-blue one
    for x0, boot in ((15, SACK), (24, CRATE_BLUE)):
        c.paint(c.rect(x0, 45, x0 + 5, 52), SACK, np.where(c.xx < x0 + 2, 0.55, 0.28), dither=False)
        c.paint(c.rect(x0 - (1 if x0 < 20 else 0), 51, x0 + 7, 56), boot, np.where(c.yy < 53, 0.4, 0.14), dither=False)
        c.paint(c.rect(x0 - 1 if x0 < 20 else x0 + 3, 54, x0 + 3 if x0 < 20 else x0 + 8, 56), boot, 0.1, dither=False)
    # the head: a round sack, tied at the neck, with button eyes and a stitched crooked smile
    head = c.ellipse(22, 13, 7.6, 7.2)
    c.paint(head, STRAW, 0.3 + 0.62 * c.sphere(19, 10, 9, 8.5), contrast=2.0)
    for k in range(6):  # straw sticking out of the neck
        c.fill(c.rect(17 + k * 2, 19, 18 + k * 2, 21 + (k % 2)), STRAW[3 - (k % 2)])
    c.fill(c.rect(18, 11, 20, 13), BIRD[1])
    c.fill(c.rect(18, 11, 19, 12), BIRD[3])
    c.fill(c.rect(24, 10, 27, 13), BIRD[0])  # the right button is bigger
    c.fill(c.rect(24, 10, 25, 11), BIRD[3])
    for k, (mx, my) in enumerate(((17, 16), (19, 17), (21, 17), (23, 16), (25, 15), (26, 14))):  # the crooked smile
        c.fill(c.rect(mx, my, mx + 1, my + 1), SACK[0])
    for mx, my in ((17, 15), (19, 16), (21, 16), (23, 15)):  # stitch ends
        c.fill(c.rect(mx, my, mx + 1, my + 1), SACK[1])
    # the pot for a hat: dented iron, a rim, one handle, straw out of a hole in its side
    pot = c.ellipse(22, 5.4, 8.4, 4.4) & (c.yy < 9)
    c.paint(pot, IRON_DARK, 0.18 + 0.7 * c.cylinder(13, 31), dither=False)
    c.paint(c.rect(13, 8, 32, 10), IRON_DARK, np.where(c.yy < 9, 0.7, 0.2), dither=False)  # the rim, wider than the pot
    c.paint(c.ellipse(22, 3.8, 5.0, 1.4), IRON_DARK, 0.06, dither=False)  # the dark opening on top
    c.paint(c.rect(30, 5, 33, 6) | c.rect(32, 5, 34, 9), IRON_DARK, 0.62, dither=False)  # the handle
    c.fill(c.rect(15, 5, 17, 7), STRAW[3])  # straw out of a hole
    c.fill(c.rect(14, 6, 16, 8), STRAW[2])
    c.fill(c.rect(19, 6, 20, 7), IRON_DARK[0])  # a dent
    # the crow on the scarecrow's right arm (the one nearest the pot): black, round, a pale beak and one bright eye; it looks at you
    body = c.ellipse(36.5, 16.2, 4.6, 3.2)
    c.paint(body, BIRD, 0.2 + 0.7 * c.sphere(35, 15, 5, 3.6), dither=False)
    c.paint(c.ellipse(40.5, 14.4, 2.0, 1.8), BIRD, 0.4, dither=False)  # the head
    c.fill(c.rect(42, 14, 45, 15), np.array([200, 180, 120], np.float32))  # the beak
    c.fill(c.rect(40, 13, 41, 14), np.array([250, 240, 200], np.float32))  # the eye
    c.fill(c.rect(31, 17, 34, 19), BIRD[2])  # the tail
    c.fill(c.rect(36, 19, 37, 21), np.array([120, 100, 80], np.float32))  # two thin legs on the arm
    c.fill(c.rect(38, 19, 39, 21), np.array([120, 100, 80], np.float32))
    c.outline(st["outline"])
    return c


def notice(ms):
    """A weathered board on a stake at the edge of the field, a little crooked, painted with a big exclamation mark and
    two lines of scrawl; the top has been used by a bird (a white splash that runs down the board). 30 x 36,
    anchor (14, 34)."""
    rng = np.random.default_rng(913)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(30, 36)
    grain = pa.value_noise(36, 30, (1, 5), rng)
    c.paint(c.rect(13, 14, 16, 35), ex["plank"], np.where(c.xx < 14.5, 0.6, 0.26) + 0.1 * (grain - 0.5), dither=False)
    tilt = (c.xx - 14) * 0.1
    board = (c.xx >= 2) & (c.xx < 27) & (c.yy >= 4 + tilt) & (c.yy < 19 + tilt)
    c.paint(board, ex["plank"], 0.62 + 0.18 * (1 - (c.yy - 4 - tilt) / 15) + 0.15 * (grain - 0.5), contrast=2.0)
    c.paint(board & (c.yy >= 4 + tilt) & (c.yy < 5.2 + tilt), ex["plank"], 0.9, dither=False)
    # the painted mark: a bar and a dot, in dark paint; beside it two lines of scrawl
    c.paint(c.rect(5, 7, 8, 14) & board, ex["plank"], 0.06, dither=False)
    c.paint(c.rect(5, 15, 8, 17) & board, ex["plank"], 0.06, dither=False)
    for y, x0, x1 in ((9, 11, 24), (13, 11, 20)):
        c.paint(c.rect(x0, y, x1, y + 1) & board, ex["plank"], 0.08, dither=False)
        c.paint(c.rect(x0 + 2, y + 1, x0 + 3, y + 2) & board, ex["plank"], 0.08, dither=False)
    # the bird's work
    drop = c.ellipse(21, 7, 3.4, 1.8) | c.rect(20, 8, 22, 13) | c.rect(21, 12, 23, 15)
    c.paint(drop & board, SPLAT, 0.75, dither=False)
    c.paint(c.ellipse(20, 6.5, 1.6, 0.8) & board, SPLAT, 1.0, dither=False)
    c.fill(c.rect(4, 3, 5, 6) & ~board, ex["iron"][3])  # a nail through the corner (the board is hung crooked)
    c.fill(board & (pa.value_noise(36, 30, 1.5, rng) > 0.86), LICHEN[1])
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the hill
def bench(ms):
    """A bench of two thick planks: the left leg is a stump, the right one a stack of three flat stones; the seat sags
    a pixel in the middle and is worn pale where people sit. 34 x 24, anchor (10, 18) (the same footprint as the valley's
    bench, whose scene it uses)."""
    rng = np.random.default_rng(915)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    wood = st["wood"]
    c = ms.Canvas(34, 24)
    grain = pa.value_noise(24, 34, (1, 6), rng)
    # the stump, cut across, with rings on its top and moss at the foot
    c.paint(c.rect(3, 12, 11, 22) | c.ellipse(7, 22, 5.4, 1.8), ex["bark"], 0.15 + 0.6 * c.cylinder(2, 12) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.ellipse(7, 12, 4.6, 1.8), wood, 0.7, dither=False)
    c.paint(c.ellipse(7, 12, 2.2, 0.8), wood, 0.45, dither=False)
    c.paint(c.rect(3, 19, 6, 22) & (pa.value_noise(24, 34, 2, rng) > 0.4), MOSS, 0.5, dither=False)
    # the stack of stones
    for k, (x0, x1, y0) in enumerate(((22, 32, 19), (23, 31, 15), (24, 30, 12))):
        s = c.rect(x0, y0, x1, y0 + 4) | c.ellipse((x0 + x1) / 2, y0 + 2, (x1 - x0) / 2 + 0.6, 2.4)
        c.paint(s, st["stone"], 0.28 + 0.14 * k + 0.4 * c.sphere(x0 + 2, y0, 8, 4), dither=False)
        c.paint(c.rect(x0 + 1, y0 + 3, x1 - 1, y0 + 4), st["stone"], 0.12, dither=False)
    # the seat: two planks, one before the other, the front one lit on its edge
    for y0, y1, lit in ((7, 11, 0.6), (11, 16, 0.5)):
        dip = np.round(1.0 - ((c.xx - 17) / 15.0) ** 2)  # the seat sags a pixel in the middle
        plank = (c.xx >= 1) & (c.xx < 33) & (c.yy >= y0 + dip) & (c.yy < y1 + dip)
        c.paint(plank, wood, lit + 0.2 * (grain - 0.5) + 0.12 * (c.yy < y0 + 1 + dip) - 0.08 * (c.yy >= y1 - 1 + dip), contrast=2.2)
    c.paint(c.ellipse(16, 12.5, 5.5, 1.6), wood, 0.86, dither=False)  # worn pale where one sits
    c.paint(c.rect(1, 16, 33, 17), wood, 0.12, dither=False)  # the dark lower edge of the front plank
    c.outline(st["outline"])
    return c


def apple_tree(ms, seed):
    """A small orchard tree: the valley's natural tree, smaller, with red and a few golden apples in its crown and two
    that have fallen into the grass. 56 x 70, anchor (28, 67)."""
    rng = np.random.default_rng(seed)
    c = ms.natural_tree("tal", seed, "foliage", "small", (56, 70))
    inner = c.a.copy()
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            inner &= np.roll(np.roll(c.a, dy, 0), dx, 1)
    spots = np.argwhere(inner & (c.yy < 46) & (c.yy > 8))
    rng.shuffle(spots)
    placed = []
    for y, x in spots:
        if any(abs(x - px) < 6 and abs(y - py) < 5 for px, py in placed):
            continue
        ramp_colors = APPLE_GOLD if len(placed) % 4 == 3 else APPLE_RED
        c.fill(c.rect(x, y, x + 2, y + 2), ramp_colors[2])
        c.fill(c.rect(x, y, x + 1, y + 1), ramp_colors[4])
        c.fill(c.rect(x + 1, y + 1, x + 2, y + 2), ramp_colors[0])
        placed.append((x, y))
        if len(placed) >= 9:
            break
    for fx, fy in ((rng.integers(14, 22), 66), (rng.integers(34, 42), 65)):  # two windfalls
        c.fill(c.rect(fx, fy, fx + 3, fy + 2), APPLE_RED[1])
        c.fill(c.rect(fx, fy, fx + 2, fy + 1), APPLE_RED[3])
    return c


def haystack(ms, seed, width):
    """A haystack: a domed cone of loose hay with a rope tied round it, a pole's tip out of the top, a few straws
    blown loose round the foot. 48 x 50, anchor (24, 46)."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(48, 50)
    base_y = 44
    streak = pa.value_noise(50, 48, (1, 9), rng)
    t = np.clip((c.yy - 6) / (base_y - 6), 0, 1)
    half = width * (1.0 - (1.0 - t) ** 1.6) + 1.6 * (1 - t)
    stack = (c.yy >= 6) & (c.yy <= base_y) & (np.abs(c.xx + 0.5 - 24) <= half)
    across = (c.xx + 0.5 - (24 - half)) / np.maximum(2 * half, 1)
    c.paint(stack, HAY, 0.86 - 0.62 * across + 0.4 * (streak - 0.5) - 0.18 * t, contrast=2.0)
    c.paint(c.ellipse(24, base_y, width + 1.2, 3.4), HAY, 0.2, dither=False)
    stack = c.a.copy()
    c.paint(stack & (c.yy > base_y - 3), HAY, 0.14, dither=False)
    for y, off in ((26, 0), (27, 1)):  # the rope round it
        band = stack & (c.yy == y)
        c.paint(band, CORD, np.where(c.xx < 24, 0.55, 0.3) - 0.05 * off, dither=False)
    c.paint(c.rect(23, 1, 25, 8), st["wood"], 0.55, dither=False)  # the pole's tip
    for k in range(7):  # loose straws at the foot
        x0 = int(rng.integers(5, 42))
        c.fill(c.rect(x0, base_y + 1 + (k % 3), x0 + int(rng.integers(3, 6)), base_y + 2 + (k % 3)), HAY[2 + k % 2])
    c.outline(st["outline"])
    return c


def haybale(ms, kind):
    """A bale of hay: kind 0 a block tied with two cords (a lit top and a front), kind 1 a round bale that lies on its
    side with the spiral of its end showing. 32 x 28, anchor (16, 25)."""
    rng = np.random.default_rng(917 + kind)
    st = pa.STYLES["tal"]
    c = ms.Canvas(32, 28)
    streak = pa.value_noise(28, 32, (1, 5), rng)
    if kind == 0:
        top = c.rect(4, 6, 28, 12)
        front = c.rect(3, 12, 28, 25)
        c.paint(top, HAY, 0.7 + 0.2 * (streak - 0.5) + 0.1 * (c.yy < 8), contrast=2.0)
        c.paint(front, HAY, 0.4 + 0.3 * (streak - 0.5) - 0.12 * (c.yy - 12) / 13, contrast=2.0)
        c.paint(c.rect(28, 7, 31, 25), HAY, 0.14 + 0.1 * (streak - 0.5), dither=False)  # the shaded end
        for x in (11, 21):
            c.paint(c.rect(x, 6, x + 1, 25), CORD, 0.3, dither=False)
            c.paint(c.rect(x - 1, 6, x, 25), CORD, 0.7, dither=False)
        c.paint(c.rect(4, 12, 28, 13), HAY, 0.88, dither=False)
    else:
        cyl = c.rect(4, 6, 24, 24)
        c.paint(cyl, HAY, 0.25 + 0.5 * c.cylinder(2, 26) + 0.2 * (streak - 0.5), contrast=2.0)  # the side
        end = c.ellipse(24, 15, 4.6, 9.4)
        rings = (np.hypot((c.xx + 0.5 - 24) * 1.8, c.yy + 0.5 - 15).astype(int) % 3) == 0
        c.paint(end, HAY, np.where(rings, 0.4, 0.78), dither=False)
        c.paint(c.ellipse(24, 15, 1.2, 1.6), HAY, 0.1, dither=False)
        c.paint(c.rect(4, 10, 24, 11), CORD, 0.4, dither=False)
        c.paint(c.rect(4, 18, 24, 19), CORD, 0.4, dither=False)
        c.paint(c.ellipse(15, 25, 11, 1.8), HAY, 0.12, dither=False)
    c.outline(st["outline"])
    return c


def parapet(ms, north):
    """One cell of the stone bridge's parapet: a low wall of dressed stones with a rounded coping, the face to the
    south. 18 x 14; the north one stands on the cell's north edge (anchor (9, 22)), the south one on its south edge
    (anchor (9, 6)); the same footprint as the rails of the wooden bridge."""
    rng = np.random.default_rng(919 if north else 921)
    st = pa.STYLES["tal"]
    c = ms.Canvas(18, 14)
    wall = c.rect(0, 3, 18, 14)
    course = (c.yy - 3) // 5
    joint_x = np.where((course % 2) == 0, (c.xx % 9) == 0, ((c.xx + 4) % 9) == 0)
    v = 0.5 - 0.1 * ((c.yy - 3) / 11) + 0.12 * (pa.value_noise(14, 18, 2, rng) - 0.5)
    v = np.where(((c.yy - 3) % 5) == 4, 0.1, v)
    v = np.where(joint_x, 0.16, v)
    c.paint(wall, st["stone"], v, contrast=2.0, dither=False)
    c.paint(c.rect(0, 1, 18, 4), st["stone"], np.where(c.yy < 2, 0.98, 0.78), dither=False)  # the coping
    c.paint(c.rect(0, 4, 18, 5), st["stone"], 0.2, dither=False)
    c.paint(wall & (pa.value_noise(14, 18, 2, rng) > 0.72) & (c.yy > 9), MOSS, 0.5, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the town behind the hill
def _house(ms, c, rng, x0, x1, base, wall_h, roof_h, chimney_dx, windows=2, roof_hip=False, door=True):
    """One town house seen from the front: plaster wall with shuttered windows and a door, a terracotta roof above it
    (tile rows, lit on its left half), a chimney of stone on the roof. Returns the chimney top (x, y)."""
    top = base - wall_h
    wall = c.rect(x0, top, x1, base)
    grain = pa.value_noise(c.h, c.w, (3, 3), rng)
    c.paint(wall, PLASTER, 0.52 + 0.14 * (grain - 0.5) - 0.12 * ((c.yy - top) / max(wall_h, 1)), contrast=2.0, dither=False)
    c.paint(c.rect(x1 - 3, top, x1, base), PLASTER, 0.2, dither=False)
    c.paint(c.rect(x0, base - 2, x1, base), TOWN_STONE, 0.4, dither=False)  # the plinth
    xs = np.linspace(x0 + 4, x1 - 8, windows)
    for wx in xs:
        wx = int(round(wx))
        wy = top + 4
        c.paint(c.rect(wx - 2, wy, wx, wy + 7), SHUTTER, 0.5, dither=False)
        c.paint(c.rect(wx + 5, wy, wx + 7, wy + 7), SHUTTER, 0.3, dither=False)
        c.paint(c.rect(wx, wy, wx + 5, wy + 7), PANE, 0.55 - 0.12 * ((c.yy - wy) / 7), dither=False)
        c.paint(c.rect(wx + 2, wy, wx + 3, wy + 7), PLASTER, 0.9, dither=False)
        c.paint(c.rect(wx, wy + 3, wx + 5, wy + 4), PLASTER, 0.9, dither=False)
        c.paint(c.rect(wx - 1, wy + 7, wx + 6, wy + 8), PLASTER, 0.95, dither=False)
    if door:
        dx = x1 - 9
        c.paint(c.rect(dx, base - 9, dx + 5, base - 2), ms.EXTRA["tal"]["plank"], 0.4, dither=False)
        c.fill(c.rect(dx + 3, base - 6, dx + 4, base - 5), BRASS[3])
    # the roof: a trapezoid over the wall, tile rows lit on the left
    ridge = top - roof_h
    cx = (x0 + x1) / 2
    inset = 6 if roof_hip else 1
    half = (x1 - x0) / 2 + 2
    t = np.clip((c.yy - ridge) / max(top + 2 - ridge, 1), 0, 1)
    roof = (c.yy >= ridge) & (c.yy < top + 2) & (np.abs(c.xx + 0.5 - cx) <= inset + (half - inset) * t + (0 if roof_hip else 0.5))
    row = ((c.yy - ridge) // 3).astype(int)
    tile_x = np.where((row % 2) == 0, c.xx, c.xx + 2) // 4
    v = 0.66 - 0.3 * ((c.yy - ridge) / max(roof_h + 2, 1)) + 0.12 * ((((row * 7919 + tile_x * 104729) % 97) / 97.0) - 0.5)
    v = np.where(((c.yy - ridge) % 3) == 2, v - 0.18, v)
    v = np.where(c.xx < cx, v + 0.1, v - 0.06)
    c.paint(roof, TERRACOTTA, np.clip(v, 0, 1), contrast=2.0, dither=False)
    c.paint(c.rect(x0 - 2, top, x1 + 2, top + 2) & (np.abs(c.xx + 0.5 - cx) <= half + 1), TERRACOTTA, 0.2, dither=False)  # the eaves
    c.paint(c.rect(int(cx) - 1, ridge, int(cx) + 2, ridge + 1), TERRACOTTA, 0.95, dither=False)
    # the chimney, on the roof's right side
    chx = int(cx + chimney_dx)
    cht = ridge - 6
    c.paint(c.rect(chx, cht, chx + 5, ridge + 5), TOWN_STONE, 0.3 + 0.5 * c.cylinder(chx - 1, chx + 6), dither=False)
    c.paint(c.rect(chx - 1, cht, chx + 6, cht + 2), TOWN_STONE, 0.78, dither=False)
    c.paint(c.rect(chx + 1, cht, chx + 4, cht + 1), TOWN_STONE, 0.05, dither=False)
    return chx + 2, cht


def roofs(ms, kind):
    """The edge of the town, seen over the hedge: plastered houses with terracotta roofs and a chimney each, drawn from
    their foot (the hedge hides the rest). kind 0: one tall house, kind 1: two low ones side by side, kind 2: a house
    with a hipped roof and a small outbuilding. 76 x 70, anchor (38, 66); the sprite has one chimney whose smoke the
    catalog sets (smoke point returned)."""
    rng = np.random.default_rng(923 + kind)
    st = pa.STYLES["tal"]
    c = ms.Canvas(76, 70)
    smoke = None
    if kind == 0:
        smoke = _house(ms, c, rng, 18, 58, 66, 24, 20, 8, windows=3)
    elif kind == 1:
        _house(ms, c, rng, 4, 34, 66, 18, 16, -6, windows=2, door=False)
        smoke = _house(ms, c, rng, 36, 72, 66, 22, 18, 7, windows=2)
    else:
        smoke = _house(ms, c, rng, 14, 54, 66, 20, 17, -8, windows=3, roof_hip=True)
        sh = ms.Canvas(76, 70)
        _house(ms, sh, rng, 54, 72, 66, 12, 9, 0, windows=1, door=False)
        c.blit(sh, 0, 0)
    c.outline(st["outline"])
    return c, smoke


# --------------------------------------------------------------------------- the roadworks
def rope(ms):
    """A rope across the road between its two posts, tied with scraps of cloth, hanging in a slight bow. It lies in the
    dust (flat) and runs north to south: 16 x 72, anchor (8, 36); the ends meet the posts at y = 4 and y = 68."""
    c = ms.Canvas(16, 72)
    xs = {}
    for y in range(4, 69):
        t = (y - 4) / 64.0
        x = 8 + int(round(2.4 * np.sin(np.pi * t) * -1 + 0.5 * np.sin(t * 9)))
        xs[y] = x
        c.fill(c.rect(x, y, x + 2, y + 1), CORD[2 if (y % 4) < 2 else 1])
        c.fill(c.rect(x + 2, y, x + 3, y + 1), CORD[0])
    for y in (16, 30, 44, 56):  # scraps of cloth knotted to the rope, fluttering a little to the east
        x = xs[y]
        c.paint(c.rect(x + 3, y, x + 7, y + 3), CLOTH, 0.7 - 0.2 * ((y // 14) % 2), dither=False)
        c.paint(c.rect(x + 4, y + 3, x + 6, y + 5), CLOTH, 0.4, dither=False)
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def cobbles(ms):
    """A heap of cobbles at the edge of the road and a hammer lying across it: round grey and brown stones, the big
    ones at the foot, the hammer's iron head and its wooden handle. 36 x 24, anchor (18, 21)."""
    rng = np.random.default_rng(927)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(36, 24)
    c.paint(c.ellipse(18, 20.5, 15, 3.2), st["stone"], 0.2, dither=False)
    stones = []
    for row, (y, count, r) in enumerate(((19, 5, 3.6), (14, 4, 3.4), (9, 3, 3.2), (5, 1, 3.0))):
        for k in range(count):
            x = 18 + (k - (count - 1) / 2) * (r * 2.1) + rng.uniform(-1, 1)
            stones.append((x, y + rng.uniform(-1, 1), r * rng.uniform(0.9, 1.1)))
    ramps = (st["stone"], st["rock"], st["cliff"])
    for k, (x, y, r) in enumerate(stones):
        m = c.ellipse(x, y, r, r * 0.85)
        c.paint(m, ramps[k % 3], 0.3 + 0.6 * c.sphere(x - 1.2, y - 1.2, r * 1.2, r * 1.0) + 0.1 * (rng.random() - 0.5), dither=False)
        c.paint(c.ellipse(x, y + r * 0.7, r * 0.8, 0.8) & m, ramps[k % 3], 0.1, dither=False)
    c.paint(ms.limb_mask(c, 6, 21, 28, 13, 2.4), ex["plank"], 0.55, dither=False)  # the handle across the heap
    c.paint(c.rect(26, 9, 32, 17) & (c.xx > 26 + (c.yy - 9) * 0.0), IRON_DARK, 0.7, dither=False)  # the head
    c.paint(c.rect(26, 9, 32, 11), IRON_DARK, 0.95, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- catalog
def build(ms):
    """Registers the sprites of Act IV in the catalog (no light anywhere). The post and the bell are two props; the
    bell's anchor lifts it onto the post's nail: the map puts the bell on the cell below the post, whose centre is
    16 px south of the post's foot, and the cord's top (pixel (4, 0)) must meet the nail 3 px east and 18 px above that
    foot, so the anchor is (4 - 3, 18 + 16) = (1, 34)."""
    ms.save("tal", "st_sign", sign(ms), (15, 34), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "st_sign_two", sign_two(ms), (17, 44), shape={"circle": 3, "offset": [0, -1]}, shadow=[7, 2])
    ms.save("tal", "st_milestone", milestone(ms), (14, 24), shape={"circle": 7, "offset": [0, -3]}, shadow=[12, 3])
    ms.save("tal", "st_post", post(ms), (6, 32), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "st_rope_post", post(ms, tied=True), (6, 32), shape={"circle": 3, "offset": [0, -1]})
    ms.save("tal", "st_bell", bell(ms), (1, 18 + 16))
    ms.save("tal", "st_prints", [prints(ms, 931 + k) for k in range(2)], (24, 8), flat=True)
    ms.save("tal", "st_scarecrow", scarecrow(ms), (22, 58), shape={"circle": 3, "offset": [0, -1]}, shadow=[12, 3])
    ms.save("tal", "st_notice", notice(ms), (14, 34), shape={"circle": 3, "offset": [0, -1]}, shadow=[8, 2])
    ms.save("tal", "st_bench", bench(ms), (10, 18))
    ms.save("tal", "st_apple", [apple_tree(ms, 941 + k) for k in range(3)], (28, 67),
            shape={"circle": 4, "offset": [0, -2]}, sway=0.6, shadow=[20, 6])
    ms.save("tal", "st_haystack", [haystack(ms, 951, 15.5), haystack(ms, 952, 13.5)], (24, 46),
            shape={"circle": 8, "offset": [0, -2]}, shadow=[18, 5])
    ms.save("tal", "st_haybale", [haybale(ms, 0), haybale(ms, 1)], (16, 25),
            shape={"rect": [26, 8], "offset": [0, -3]}, shadow=[14, 4])
    ms.save("tal", "st_parapet_n", parapet(ms, True), (9, 22), shape={"rect": [16, 4], "offset": [0, -7]})
    ms.save("tal", "st_parapet_s", parapet(ms, False), (9, 6), shape={"rect": [16, 4], "offset": [0, 7]})
    for kind, name in enumerate(("a", "b", "c")):
        canvas, smoke = roofs(ms, kind)
        ms.save("tal", "st_roofs_" + name, canvas, (38, 66), smoke=[smoke[0] - 38, smoke[1] - 66])
    ms.save("tal", "st_rope", rope(ms), (8, 36), flat=True)
    ms.save("tal", "st_cobbles", cobbles(ms), (18, 21), shape={"rect": [28, 8], "offset": [0, -3]}, shadow=[16, 4])


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    items = [sign(ms), sign_two(ms), milestone(ms), post(ms), post(ms, True), bell(ms), prints(ms, 931), prints(ms, 932),
             scarecrow(ms), notice(ms), bench(ms), cobbles(ms), rope(ms)]
    items += [parapet(ms, True), parapet(ms, False), haybale(ms, 0), haybale(ms, 1), haystack(ms, 951, 15.5), haystack(ms, 952, 13.5)]
    big = [apple_tree(ms, 941), apple_tree(ms, 942), apple_tree(ms, 943)] + [roofs(ms, k)[0] for k in range(3)]
    sheet = Image.new("RGBA", (860, 230), (96, 136, 88, 255))
    x = 6
    for item in items:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, 100 - min(img.height, 100)) if img.height <= 100 else (x, 0))
        x += img.width + 6
        if x > 820:
            break
    x = 6
    for item in big:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.alpha_composite(img, (x, 226 - img.height))
        x += img.width + 6
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
