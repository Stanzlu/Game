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

Stadt (S2): the town of the real world, Elysia's market with a contradiction (nothing repeats, nothing is symmetric, every
house leans a little and every wall is patched with another stone). Fronts of ten houses, a florist's and a workshop's
(each shop with its own extras: awning, sign, pots; saw, hoist, sawdust), the town hall with a parapet a goat can stand on,
the wall (four-cell runs, a run for the side walls, corner towers), the gate with its low open arch and the guard's hut,
the fountain (and a patch with the worn hollows that lies over its rim), the notice board with its sixteen sheets, two
stalls, the three stations of "Ein perfekter Tag" (wreath, lectern, table with bread and salt and sparrows), crates,
barrels, dark lamp posts, pails of peonies, a woodstack, a sawhorse, pots and the crate Lio sits on. Houses and shops carry no
shadow in the catalog (their foot is the map's solid ground); a few things stand outside the image grid on purpose
(anchors below the picture: the rim patch and the seat crate sit over or under something that lies on another cell).
Called from make_sprites.build(); `--preview out.png` draws Act IV's pieces, `--preview-town out.png` the town's.
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
DUCK = ramp("#7a8096", "#b2b8cc", "#e2e6f0", "#ffffff")
DUCK_BILL = ramp("#7a3a10", "#c8641c", "#f09a2c", "#ffc860")
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


# --------------------------------------------------------------------------- the town (S2)
# The town of the real world is Elysia's market with a contradiction: nothing repeats, nothing is symmetric, every
# house leans a little, every wall is patched with a different stone, and what is used shows it. The pieces are drawn
# as fronts (the way the valley's house is), a house is as wide as its footprint of cells (16 px each) plus the eaves,
# and its anchor lies on the centre of its middle footprint cell with the wall's foot on that cell's south edge.
# Nothing here is a light (the lamp posts hold dark lanterns: the light is S6's); props that the map puts under
# `if`/`unless` carry no shadow in the catalog.
PAPER = [ramp("#7a6e50", "#b8aa80", "#e0d4a8", "#f6edc8"), ramp("#7a7248", "#b6ac62", "#dcd286", "#f4eca8"),
         ramp("#4e6070", "#7e98aa", "#aac4d4", "#d2e6ee"), ramp("#7a4a4a", "#b27a76", "#d8a6a0", "#f0c8c2"),
         ramp("#4e6a50", "#7a9a74", "#a6c49c", "#cfe4c4")]
AWNING_RED = ramp("#3e1814", "#74302a", "#a24c3c", "#cc7a62")
AWNING_GREEN = ramp("#16281f", "#274636", "#40705a", "#6a9c80")
PEONY = ramp("#5a1630", "#9a2a54", "#d65a82", "#f2a0b8", "#fde0e8")
PEONY_WHITE = ramp("#6a5a62", "#b0a0aa", "#e6dce0", "#fff6f8")
LEAF = ramp("#16301c", "#24502a", "#388040", "#5ca458")
BREAD = ramp("#4a2a10", "#7e4a1c", "#b87a34", "#dca458", "#f2cc88")
SPARROW = ramp("#2a1c10", "#4e3620", "#7e5c38", "#a88858")
LINEN = ramp("#7a746a", "#b4aea0", "#dcd6c6", "#f4f0e4")
SLATE = ramp("#1c2228", "#2c363e", "#44525a", "#66787e")
FLAG_GREEN = ramp("#1a3024", "#2c5a3e", "#488a5c", "#78b484")


def _ashlar(c, rng, x0, y0, x1, y1, colors, course=6, wmin=9, wmax=15, base=0.5, spread=0.1, lit=0.12, shade=None, clip=None):
    """Dressed stone in courses with broken joints: every block has its own tone, a lit top edge and a dark joint under
    and beside it; a slow shade makes the left side lighter."""
    v = np.full((c.h, c.w), base, np.float32)
    mask = np.zeros((c.h, c.w), bool)
    mask[y0:y1, x0:x1] = True
    y = y0
    while y < y1:
        ch = max(min(course + int(rng.integers(-1, 2)), y1 - y), 1)
        x = x0 - int(rng.integers(0, wmax))
        while x < x1:
            bw = int(rng.integers(wmin, wmax + 1))
            xa, xb = max(x, x0), min(x + bw, x1)
            if xb > xa:
                v[y:y + ch, xa:xb] = base + spread * (rng.random() * 2 - 1)
                v[y, xa:xb] += 0.14
                if ch > 2:
                    v[y + ch - 1, xa:xb] -= 0.26
                if x >= x0:
                    v[y:y + ch, x] -= 0.2
            x += bw
        y += ch
    v += lit * (1 - (c.xx - x0) / max(x1 - x0, 1)) - lit / 2
    if shade is not None:
        v += shade
    if clip is not None:
        mask &= clip
    c.paint(mask, colors, np.clip(v, 0, 1), contrast=2.0, dither=False)
    return mask


def _flags(c, x, y, w, h, tone=0.55):
    """A strip of flagstones (the walkway of a wall, a step): staggered slabs."""
    mask = c.rect(x, y, x + w, y + h)
    v = np.full((c.h, c.w), tone, np.float32)
    for k, yy in enumerate(range(y, y + h, 5)):
        v[yy, x:x + w] -= 0.16
        for xx in range(x + (k % 2) * 6, x + w, 12):
            v[yy:yy + 5, xx] -= 0.16
    c.paint(mask, TOWN_STONE, np.clip(v, 0, 1), contrast=2.0, dither=False)


def _wall_h(ms, seed, kind):
    """One piece of the town wall, four cells long, seen from the south: the face of dressed stone with a plinth, the
    front battlement (merlons 10 px wide on a period of 16, so that the pieces join), the walkway behind it and the
    back parapet. kind 0 weathered; 1 patched with a plaster repair and one merlon broken off; 2 with ivy hanging from
    the top. 64 x 48, anchor (8, 40): the glyph stands on the west cell of the four."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(64, 48)
    _ashlar(c, rng, 0, 26, 64, 48, ex["stone_wall"], course=6, wmin=9, wmax=15, base=0.5, spread=0.1)
    c.paint(c.rect(0, 44, 64, 48), ex["stone_wall"], 0.28 + 0.1 * (pa.value_noise(48, 64, 2, rng) - 0.5), dither=False)  # the plinth
    c.paint(c.rect(0, 25, 64, 27), ex["stone_wall"], np.where(c.yy < 26, 0.92, 0.3), dither=False)  # the coping's lip
    # the walkway and the back parapet
    c.paint(c.rect(0, 0, 64, 4), ex["stone_wall"], np.where(c.yy < 1, 0.9, 0.42), dither=False)
    _flags(c, 0, 4, 64, 12)
    # the front merlons, 10 px wide on a period of 16, with a lit top and a shaded right edge
    for k in range(4):
        mx = k * 16 + 3
        if kind == 1 and k == 2:
            _ashlar(c, rng, mx, 20, mx + 10, 26, ex["stone_wall"], course=5, wmin=5, wmax=10, base=0.45)  # a stump
            c.paint(c.rect(mx + 1, 20, mx + 6, 22), ex["stone_wall"], 0.9, dither=False)
            c.fill(c.rect(mx + 7, 22, mx + 10, 25), ex["stone_wall"][1])
            continue
        _ashlar(c, rng, mx, 14, mx + 10, 26, ex["stone_wall"], course=6, wmin=5, wmax=10, base=0.52)
        c.paint(c.rect(mx, 14, mx + 10, 16), ex["stone_wall"], np.where(c.yy < 15, 0.98, 0.8), dither=False)
        c.paint(c.rect(mx + 8, 16, mx + 10, 26), ex["stone_wall"], 0.2, dither=False)
    for k in range(4):  # the walkway runs on between them
        c.paint(c.rect(k * 16 + 13, 18, k * 16 + 19, 26), TOWN_STONE, 0.45 - 0.1 * ((c.yy - 18) / 8), dither=False)
    if kind == 1:  # a repair in plaster that has lost its colour, with a brick showing
        patch = c.rect(14, 32, 32, 42) & (np.abs(c.xx - 23) + np.abs(c.yy - 37) * 1.6 < 14)
        c.paint(patch, PLASTER, 0.55 + 0.1 * (pa.value_noise(48, 64, 2, rng) - 0.5), dither=False)
        c.paint(c.rect(21, 36, 27, 39) & patch, TERRACOTTA, 0.5, dither=False)
        c.paint(c.rect(21, 36, 27, 37) & patch, TERRACOTTA, 0.85, dither=False)
    if kind == 2:  # ivy over the top and down the face
        ivy = (c.yy < 24 + 12 * np.clip(np.sin(c.xx * 0.31 + 1.0) * 0.5 + 0.5, 0, 1) + 5 * (pa.value_noise(48, 64, 3, rng) - 0.5)) \
            & (c.xx > 22) & (c.xx < 52) & (c.yy > 12)
        c.paint(ivy, LEAF, 0.35 + 0.5 * pa.value_noise(48, 64, 2, rng), contrast=2.0)
    for sx in (6 + int(rng.integers(0, 6)), 40 + int(rng.integers(0, 8))):  # rain stains below the coping
        c.paint(c.rect(sx, 28, sx + 2, 34 + int(rng.integers(0, 6))), ex["stone_wall"], 0.2, dither=False)
    if kind == 0:  # an arrow slit
        sx = 22 + int(rng.integers(0, 12))
        c.paint(c.rect(sx, 32, sx + 3, 40), ex["stone_wall"], 0.06, dither=False)
    c.paint(c.ellipse(32, 47, 30, 2.5) & (c.yy > 44), MOSS, 0.4, dither=False)
    c.outline(st["outline"])
    return c


def _wall_v(ms, seed):
    """A piece of the wall that runs north to south: seen from the south it is its walkway between a battlement
    on each side (the wall is as high as the others, so the top lies one wall height above its foot), and the face of the
    south end at the bottom, where the next piece covers it. 24 x 92, anchor (12, 84): the glyph stands on the south
    cell of four; the strip covers those four cells and the 28 px above them."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(24, 92)
    c.paint(c.rect(0, 0, 24, 64), ex["stone_wall"], 0.42, dither=False)
    _flags(c, 5, 0, 14, 64)
    for k in range(4):  # merlons on both sides, a period of 16 (staggered by half)
        for x0, off in ((0, 3), (19, 11)):
            my = k * 16 + off
            _ashlar(c, rng, x0, my, x0 + 5, min(my + 10, 64), ex["stone_wall"], course=5, wmin=5, wmax=6, base=0.52)
            c.paint(c.rect(x0, my, x0 + 5, my + 2), ex["stone_wall"], 0.95, dither=False)
    _ashlar(c, rng, 0, 64, 24, 92, ex["stone_wall"], course=6, wmin=9, wmax=13, base=0.48)
    c.paint(c.rect(0, 64, 24, 66), ex["stone_wall"], 0.9, dither=False)
    c.paint(c.rect(0, 88, 24, 92), ex["stone_wall"], 0.26, dither=False)
    c.paint(c.rect(0, 64, 24, 92) & (pa.value_noise(92, 24, 2, rng) > 0.8), MOSS, 0.45, dither=False)
    c.outline(st["outline"])
    return c


def wall_tower(ms):
    """A corner tower of the wall: a drum of dressed stone three cells wide with arrow slits, a banded slate cone and a
    faded green flag that has been mended once. 56 x 104, anchor (28, 96): the glyph stands on the middle cell of the
    three at the foot."""
    rng = np.random.default_rng(1007)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(56, 104)
    body = c.rect(4, 44, 52, 104)
    body &= (np.abs(c.xx + 0.5 - 28) <= 24 - 2.2 * np.clip((c.yy - 94) / 10, 0, 1))
    _ashlar(c, rng, 4, 44, 52, 104, ex["stone_wall"], course=6, wmin=8, wmax=13, base=0.4, shade=0.5 * c.cylinder(2, 54) - 0.2,
            clip=body)
    for sx, sy in ((14, 62), (36, 78), (24, 52)):  # arrow slits, none on a line
        c.paint(c.rect(sx, sy, sx + 3, sy + 10), ex["stone_wall"], 0.04, dither=False)
        c.paint(c.rect(sx - 1, sy - 1, sx + 4, sy), ex["stone_wall"], 0.9, dither=False)
    c.paint(c.rect(2, 40, 54, 46), ex["stone_wall"], np.where(c.yy < 42, 0.9, 0.35), dither=False)  # the corbel under the cone
    cone = (c.yy >= 6) & (c.yy < 42) & (np.abs(c.xx + 0.5 - 28) <= 26 * (c.yy - 6) / 36 + 1)
    rows = ((c.yy - 6) // 4).astype(int)
    tiles = ((rows * 7919 + ((c.xx + (rows % 2) * 2) // 4) * 104729) % 97) / 97.0
    c.paint(cone, SLATE, np.clip(0.62 - 0.3 * (c.yy - 6) / 36 + 0.25 * (tiles - 0.5) + 0.3 * (c.xx < 28) - 0.15, 0, 1),
            contrast=2.0, dither=False)
    c.paint(cone & ((c.yy - 6) % 4 == 3), SLATE, 0.05, dither=False)
    c.paint(c.rect(27, 0, 29, 8), ex["iron"], 0.6, dither=False)  # the pole
    flag = c.rect(29, 1, 43, 8) & (c.yy < 2 + 5 * (c.xx - 29) / 14 + 3) | c.rect(29, 1, 36, 7)
    c.paint(flag, FLAG_GREEN, np.where(c.xx < 33, 0.7, 0.45) - 0.1 * ((c.xx + c.yy) % 5 == 0), dither=False)
    c.paint(c.rect(34, 3, 38, 6), FLAG_GREEN, 0.9, dither=False)  # the mended patch
    c.outline(st["outline"])
    return c


def gate(ms):
    """The town's gate seen from the south: two stout piers of dressed stone with a battlement, joined over a flattened arch
    by a bridge of the same wall walk; a small green flag on the east pier. The arch is open: the passage behind it is the
    cobbles of the map, and whoever walks through stays in view; its opening is five cells wide (80 px) and 48 px high, a
    portcullis hangs raised in the crown. Only 76 px high: nothing taller may stand over the cells north of it. 192 x 76,
    anchor (96, 68): the glyph stands on the passage's middle cell in the wall's south row (the foot lies 8 px under it)."""
    rng = np.random.default_rng(1013)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    W, H = 192, 76
    c = ms.Canvas(W, H)
    left, right = 8, 184
    ox0, ox1 = 56, 136
    cx = (ox0 + ox1) / 2
    top = 26
    _ashlar(c, rng, left, top, right, H, ex["stone_wall"], course=7, wmin=10, wmax=17, base=0.5)
    # the battlement along the top, on a period of 16 like the wall's, and the walkway behind it
    for mx in range(left + 3, right - 8, 16):
        _ashlar(c, rng, mx, 14, mx + 10, top, ex["stone_wall"], course=6, wmin=5, wmax=10, base=0.52)
        c.paint(c.rect(mx, 14, mx + 10, 16), ex["stone_wall"], np.where(c.yy < 15, 0.98, 0.8), dither=False)
        c.paint(c.rect(mx + 8, 16, mx + 10, top), ex["stone_wall"], 0.2, dither=False)
    c.paint(c.rect(left, 20, right, top), ex["stone_wall"], 0.44, dither=False)  # the walkway between the crenels
    c.paint(c.rect(left, top - 2, right, top), ex["stone_wall"], 0.9, dither=False)
    c.paint(c.rect(left, top, right, top + 1), ex["stone_wall"], 0.2, dither=False)
    # the arch: a flattened semicircle, its crown 48 px above the foot
    arch = c.rect(ox0, 48, ox1, H) | (c.ellipse(cx, 48, 40, 20) & (c.yy < 48))
    c.a &= ~arch
    ring = (c.ellipse(cx, 48, 46, 26) & ~c.ellipse(cx, 48, 40, 20)) & (c.yy < 48)
    k = (np.arctan2(c.yy - 48, c.xx - cx) * 9).astype(int)
    c.paint(ring, ex["stone_wall"], np.where(k % 2 == 0, 0.78, 0.6), dither=False)
    c.paint(ring & (np.abs(c.xx - cx) < 3), ex["stone_wall"], 0.97, dither=False)
    c.paint(c.rect(ox0 - 5, 48, ox0, H) | c.rect(ox1, 48, ox1 + 5, H), ex["stone_wall"], 0.18, dither=False)  # the jambs in shade
    inner = c.ellipse(cx, 48, 40, 20) & ~c.ellipse(cx, 48, 40, 12) & (c.yy < 48)
    c.paint(inner, ex["stone_wall"], 0.1, dither=False)  # the dark under the crown
    bars = inner & (((c.xx.astype(int) - ox0) % 7) < 2) | inner & ((c.yy.astype(int) % 8) == 0)
    c.paint(bars, ex["iron"], 0.35, dither=False)  # the raised portcullis
    # the piers: a plinth, a lit edge, moss
    c.paint(c.rect(left, H - 5, ox0 - 5, H) | c.rect(ox1 + 5, H - 5, right, H), ex["stone_wall"],
            0.26 + 0.08 * (pa.value_noise(H, W, 3, rng) - 0.5), dither=False)
    c.paint(c.rect(left, H - 7, right, H) & (pa.value_noise(H, W, 2, rng) > 0.7) & c.a & ~arch, MOSS, 0.4, dither=False)
    # a pole on the east pier with a green flag that has been mended once
    px = 164  # on the east pier: the cells north of it are solid, none of them is walked on
    c.paint(c.rect(px, 0, px + 2, 14), ex["iron"], 0.6, dither=False)
    c.paint(c.rect(px + 2, 1, px + 14, 7), FLAG_GREEN, np.where(c.xx < px + 8, 0.62, 0.4), dither=False)
    c.paint(c.rect(px + 5, 2, px + 9, 5), FLAG_GREEN, 0.92, dither=False)
    c.outline(st["outline"])
    return c


def guard_hut(ms):
    """The guard's hut beside the gate: a shed of grey boards with a lean-to roof of slate, a hatch with a shelf under it
    (a mug and a ledger), a hook with a bunch of keys and a bell, a stool that is not in use. 72 x 72, anchor (36, 64):
    the glyph stands on the middle of its three footprint cells."""
    rng = np.random.default_rng(1019)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(72, 72)
    grain = pa.value_noise(72, 72, (1, 7), rng)
    wall = c.rect(8, 30, 64, 72)
    plank = ((c.xx - 8) // 5).astype(int)
    tone = ((plank * 2654435761) % 89) / 89.0
    c.paint(wall, ex["plank"], 0.34 + 0.12 * (tone - 0.5) + 0.12 * (grain - 0.5) - 0.1 * (c.yy - 30) / 42, contrast=2.0, dither=False)
    c.paint(wall & (((c.xx - 8) % 5) == 4), ex["plank"], 0.08, dither=False)
    c.paint(c.rect(8, 66, 64, 72), TOWN_STONE, 0.34, dither=False)
    # the lean-to roof: slate, sloping to the front
    roof = (c.yy >= 10 + (c.xx - 4) * 0.0) & (c.yy < 36) & (c.xx >= 4) & (c.xx < 68)
    rows = ((c.yy - 10) // 4).astype(int)
    tiles = ((rows * 7919 + ((c.xx + (rows % 2) * 2) // 5) * 104729) % 97) / 97.0
    c.paint(roof, SLATE, np.clip(0.64 - 0.28 * (c.yy - 10) / 26 + 0.28 * (tiles - 0.5) + 0.1 * (c.xx < 36), 0, 1), contrast=2.0, dither=False)
    c.paint(roof & ((c.yy - 10) % 4 == 3), SLATE, 0.05, dither=False)
    c.paint(c.rect(2, 34, 70, 38), ex["plank"], np.where(c.yy < 35, 0.78, 0.3), dither=False)
    # the hatch: a wide window with a shutter propped up on a stick, the shelf under it
    c.paint(c.rect(14, 42, 40, 58), ex["plank"], 0.62, dither=False)
    c.paint(c.rect(16, 44, 38, 56), PANE, 0.22, dither=False)
    c.paint(c.rect(16, 44, 38, 47), PANE, 0.08, dither=False)
    c.paint(c.rect(12, 38, 42, 43), ex["plank"], 0.82, dither=False)  # the shutter, hinged at the top and propped open
    c.paint(c.rect(41, 40, 43, 50), ex["plank"], 0.5, dither=False)  # its stick
    c.paint(c.rect(10, 58, 44, 61), ex["plank"], np.where(c.yy < 59, 0.88, 0.4), dither=False)  # the shelf
    c.paint(c.ellipse(18, 56.5, 3, 2.5), ex["hoop"], 0.7, dither=False)  # a mug
    c.fill(c.rect(21, 55, 23, 58), ex["hoop"][2])
    c.paint(c.rect(28, 56, 38, 59), PAPER[0], 0.7, dither=False)  # a ledger lying open
    c.fill(c.rect(33, 56, 34, 59), PAPER[0][0])
    # the door on the right, ajar-looking: a darker plank door with a hook, keys and a bell
    c.paint(c.rect(46, 44, 58, 66), ex["plank"], 0.2, dither=False)
    c.paint(c.rect(46, 44, 58, 46), ex["plank"], 0.5, dither=False)
    c.fill(c.rect(55, 56, 57, 58), BRASS[3])
    for kx in (60, 62, 64):
        c.fill(c.rect(kx, 46, kx + 1, 52), ex["iron"][3])
        c.fill(c.rect(kx - 1, 52, kx + 2, 54), ex["iron"][2])
    c.fill(c.rect(59, 44, 65, 46), ex["iron"][2])
    c.paint(c.ellipse(61, 58, 3, 3), BRASS, 0.7, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the houses
OCHRE = ramp("#4a3a1e", "#7a6234", "#a88a4e", "#cdb06e", "#e8d498")
GREYBLUE = ramp("#2e3a40", "#566670", "#8496a0", "#aebcc0", "#d2dcdc")
ROSE = ramp("#4a2e2c", "#7e5450", "#aa7c74", "#cfa49a", "#ecd0c4")
SHUTTER_BLUE = ramp("#16222e", "#26405a", "#3c6486", "#5e8aaa")
SHUTTER_OCHRE = ramp("#3a2a10", "#6a4c1c", "#9a7430", "#c49c4a")


def _tile_roof(c, rng, mask, y_top, y_bottom, cx, colors, moss=False, patches=3):
    """Roof tiles in staggered rows of four px: every tile has its tone, the left side is lit, a few tiles are new."""
    rows = ((c.yy - y_top) // 4).astype(int)
    tiles = ((rows * 7919 + ((c.xx + (rows % 2) * 2) // 5) * 104729) % 97) / 97.0
    v = 0.66 - 0.32 * (c.yy - y_top) / max(y_bottom - y_top, 1) + 0.26 * (tiles - 0.5) + 0.1 * (c.xx < cx)
    v = np.where(((c.yy - y_top) % 4) == 3, 0.05, v)
    for _ in range(patches):
        px, py = int(rng.integers(8, max(c.w - 16, 9))), int(rng.integers(int(y_top) + 2, max(int(y_bottom) - 6, int(y_top) + 3)))
        v = np.where((c.xx >= px) & (c.xx < px + 10) & (c.yy >= py) & (c.yy < py + 4) & (((c.yy - y_top) % 4) != 3), 0.9, v)
    c.paint(mask, colors, np.clip(v, 0, 1), contrast=2.0, dither=False)
    if moss:
        c.paint(mask & (pa.value_noise(c.h, c.w, 3, rng) > 0.82), MOSS, 0.5, dither=False)


def _window(c, rng, ex, x, y, w, h, kind="open", shutter=SHUTTER, box=False):
    """A window with its frame, a cross of bars and a sill, drawn a pixel or two off true (nothing is level): kind
    "open" (one shutter stands open, the other is half closed), "shut" (both shutters closed), "curtain", "dark" (an empty
    room), "plain"."""
    x += int(rng.integers(-1, 2))
    y += int(rng.integers(-1, 2))
    c.paint(c.rect(x - 1, y - 1, x + w + 1, y + h + 1), PLASTER, 0.86, dither=False)
    pane = c.rect(x, y, x + w, y + h)
    glass = 0.5 - 0.2 * ((c.yy - y) / h) + 0.18 * (((c.xx - x) + (c.yy - y)) % 9 < 2)
    c.paint(pane, PANE, 0.1 if kind == "dark" else glass, dither=False)
    if kind != "shut":
        c.paint(c.rect(x + w // 2, y, x + w // 2 + 1, y + h), PLASTER, 0.9, dither=False)
        c.paint(c.rect(x, y + int(h * 0.45), x + w, y + int(h * 0.45) + 1), PLASTER, 0.9, dither=False)
    sw = max(w // 2, 3)
    if kind == "open":
        c.paint(c.rect(x - 1 - sw, y - 1, x - 1, y + h + 1), shutter, np.where(((c.xx - x) % 2) == 0, 0.6, 0.34), dither=False)
        c.paint(c.rect(x + w + 1, y - 1, x + w + 1 + sw, y + 2 + h // 2), shutter, np.where(((c.xx - x) % 2) == 0, 0.5, 0.3), dither=False)
    elif kind == "shut":
        c.paint(c.rect(x, y, x + w, y + h), shutter, np.where(((c.xx - x) % 3) == 0, 0.3, 0.58), dither=False)
        c.paint(c.rect(x, y + h // 2, x + w, y + h // 2 + 1), shutter, 0.16, dither=False)
    elif kind == "curtain":
        c.paint(c.rect(x, y, x + w // 2 + 1, y + h), CLOTH, np.where(((c.xx - x) % 3) == 0, 0.5, 0.78), dither=False)
    c.paint(c.rect(x - 2, y + h + 1, x + w + 2, y + h + 3), TOWN_STONE, np.where(c.yy <= y + h + 1, 0.92, 0.4), dither=False)
    if box:
        c.paint(c.rect(x - 1, y + h + 3, x + w + 1, y + h + 7), ex["plank"], np.where(c.yy < y + h + 4, 0.7, 0.3), dither=False)
        flowers = pa.STYLES["tal"]["flowers"]
        for k in range(w // 2 + 1):
            fx = x + k * 2 - 1 + int(rng.integers(0, 2))
            c.fill(c.rect(fx, y + h, fx + 2, y + h + 3), LEAF[1 + int(rng.integers(0, 3))])
            c.fill(c.rect(fx, y + h - 1, fx + 1, y + h), flowers[int(rng.integers(0, len(flowers)))][2])


def _door(c, rng, ex, x, foot, w=12, h=21, arch=True, step=True, bar=False):
    """A plank door in a frame with a lintel, a brass handle and a worn step; `foot` is the wall's foot row."""
    top = foot - h
    frame = c.rect(x - 2, top - 2, x + w + 2, foot)
    if arch:
        frame |= c.ellipse(x + w / 2, top + 2, w / 2 + 2.2, 5.5) & (c.yy < top + 2)
    c.paint(frame, TOWN_STONE, np.where((c.yy < top) | (c.xx < x), 0.9, 0.52), dither=False)
    door = c.rect(x, top, x + w, foot)
    if arch:
        door |= c.ellipse(x + w / 2, top + 2, w / 2, 4.2) & (c.yy < top + 2)
    grain = pa.value_noise(c.h, c.w, (1, 6), rng)
    c.paint(door, ex["plank"], np.where(((c.xx - x) % 4) == 3, 0.1, 0.34 + 0.14 * (grain - 0.5)) - 0.1 * ((c.yy - top) / h), dither=False)
    c.paint(c.rect(x, top + int(h * 0.3), x + w, top + int(h * 0.3) + 2), ex["iron"], 0.5, dither=False)  # a strap hinge
    c.paint(c.rect(x, top + int(h * 0.7), x + w, top + int(h * 0.7) + 2), ex["iron"], 0.5, dither=False)
    if bar:
        c.paint(c.rect(x - 3, top + int(h * 0.5), x + w + 3, top + int(h * 0.5) + 3), ex["plank"], 0.62, dither=False)
    c.fill(c.rect(x + w - 4, foot - 11, x + w - 2, foot - 9), BRASS[3])
    if step:
        c.paint(c.rect(x - 4, foot - 2, x + w + 4, foot), TOWN_STONE, np.where(c.yy < foot - 1, 0.86, 0.38), dither=False)


def _chimney(c, ex, x, top, base):
    """A stone chimney that leans a pixel; returns the smoke point."""
    c.paint(c.rect(x, top, x + 7, base), ex["stone_wall"], 0.25 + 0.6 * c.cylinder(x - 1, x + 8), dither=False)
    c.paint(c.rect(x - 1, top, x + 8, top + 2), ex["stone_wall"], 0.8, dither=False)
    c.paint(c.rect(x + 2, top, x + 5, top + 1), ex["stone_wall"], 0.05, dither=False)
    return x + 3, top


def _wall_surface(c, rng, ex, x0, y0, x1, y1, colors, stains=True):
    """Plaster that has weathered unevenly: a damp stain rising from the plinth, dark runs under the eaves, now and then a
    patch where the render has fallen off and the brick shows."""
    n = pa.value_noise(c.h, c.w, (4, 3), rng)
    height = max(y1 - y0, 1)
    v = 0.58 + 0.16 * (n - 0.5) - 0.1 * ((c.yy - y0) / height)
    c.paint(c.rect(x0, y0, x1, y1), colors, np.clip(v, 0, 1), contrast=2.0, dither=False)
    c.paint(c.rect(x1 - 3, y0, x1, y1), colors, 0.2, dither=False)  # the shaded side
    if stains:
        damp = c.rect(x0, y1 - 10, x1, y1 - 4) & (pa.value_noise(c.h, c.w, 3, rng) > 0.5)
        c.paint(damp, colors, 0.3, dither=False)
        for _ in range(2):
            rx = int(rng.integers(x0 + 6, max(x1 - 14, x0 + 7)))
            ry = int(rng.integers(y0 + 6, max(y1 - 22, y0 + 7)))
            rw, rh = int(rng.integers(5, 10)), int(rng.integers(4, 8))
            c.paint(c.rect(rx, ry, rx + rw, ry + rh), TERRACOTTA, 0.38, dither=False)
            c.paint(c.rect(rx, ry, rx + rw, ry + 1), TERRACOTTA, 0.7, dither=False)
            c.fill(c.rect(rx + 1, ry + rh // 2, rx + 3, ry + rh // 2 + 1), TERRACOTTA[1])


def _frame_work(c, rng, ex, x0, y0, x1, y1, colors):
    """Timber framing over plaster: a post every sixteen px, a sill beam, a brace in two bays; beams a little off true."""
    _wall_surface(c, rng, ex, x0, y0, x1, y1, colors, stains=False)
    beam = ex["plank"]
    c.paint(c.rect(x0, y0, x1, y0 + 3), beam, np.where(c.yy < y0 + 1, 0.5, 0.26), dither=False)
    c.paint(c.rect(x0, y1 - 3, x1, y1), beam, np.where(c.yy < y1 - 2, 0.5, 0.26), dither=False)
    xs = list(range(x0, x1, 16)) + [x1 - 3]
    for k, px in enumerate(xs):
        c.paint(c.rect(px, y0, px + 3, y1), beam, np.where(c.xx < px + 1, 0.5, 0.26), dither=False)
        if k % 2 == 0 and k + 1 < len(xs):
            m = ms_limb(c, px + 3, y1 - 3, xs[k + 1], y0 + 3, 3)
            c.paint(m, beam, 0.34, dither=False)


def ms_limb(c, x0, y0, x1, y1, width):
    import make_sprites as ms
    return ms.limb_mask(c, x0, y0, x1, y1, width)


def _banner(c, x, y, h, colors=FLAG_GREEN):
    """A banner that hangs from a pole stuck out of the wall, its foot cut in two tails of different length."""
    c.paint(c.rect(x - 1, y, x + 14, y + 2), pa.STYLES["tal"]["wood"], 0.6, dither=False)
    shape = c.rect(x, y + 2, x + 12, y + 2 + h)
    shape &= ~((c.xx >= x + 5) & (c.xx < x + 7) & (c.yy > y + 2 + h - 8))
    shape &= ~((c.xx >= x + 7) & (c.yy > y + 2 + h - 3))
    c.paint(shape, colors, np.where(c.xx < x + 6, 0.6, 0.36), dither=False)
    c.paint(c.rect(x + 4, y + 6, x + 9, y + 10), colors, 0.92, dither=False)


def town_house(ms, seed, cells, floors, style):
    """A town house seen from the front, drawn from its footprint (`cells` wide; the anchor is on the middle cell, the foot
    of the wall on the south edge of that cell). `style` is a dict: wall (a colour ramp), frame (timber on the upper
    floors), roof ("band" with ridge parallel to the street, "gable" with the gable end to the street), roof_colors,
    door (offset of the door from the middle, in px), shop (a larger window instead of the left one), shutter (the ramp),
    boxes (flower boxes), laundry (a line of washing under the eaves), chimney (offset in px or None).
    Returns the canvas and the smoke point (or None)."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    fw = cells * 16
    W = fw + 16
    floor_h = [30] + [26] * (floors - 1)
    wall_h = sum(floor_h) + 2
    roof_kind = style.get("roof", "band")
    roof_h = 22 if roof_kind == "band" else int(fw * 0.42) + 6
    H = roof_h + wall_h + 16
    c = ms.Canvas(W, H)
    x0, x1 = 8, 8 + fw
    foot = H
    top = foot - wall_h
    colors = style.get("wall", PLASTER)
    # the floors: the ground floor in render, the upper ones in timber framing when asked (they overhang by two px)
    _wall_surface(c, rng, ex, x0, top, x1, foot, colors)
    if style.get("frame"):
        _frame_work(c, rng, ex, x0 - 2, top, x1 + 2, foot - floor_h[0], colors)
        c.paint(c.rect(x0 - 3, foot - floor_h[0], x1 + 3, foot - floor_h[0] + 3), ex["plank"], np.where(c.yy < foot - floor_h[0] + 1, 0.6, 0.24), dither=False)
    c.paint(c.rect(x0, foot - 5, x1, foot), TOWN_STONE, 0.34 + 0.1 * (pa.value_noise(H, W, 3, rng) - 0.5), dither=False)  # the plinth
    c.paint(c.rect(x0, foot - 5, x1, foot - 4), TOWN_STONE, 0.7, dither=False)
    # the roof
    cx = W / 2 + style.get("ridge", 2)
    smoke = None
    if roof_kind == "band":
        ridge_y = roof_h - 20 + 1.6 * np.sin(c.xx * 0.09 + seed)
        roof = (c.yy >= ridge_y) & (c.yy < top + 3) & (c.xx >= 3) & (c.xx < W - 3)
        taper = np.clip((top - c.yy) * 0.5, 0, 8)
        roof &= np.abs(c.xx + 0.5 - cx) <= (W / 2 - 3) - taper * 0.7
        _tile_roof(c, rng, roof, roof_h - 20, top + 3, cx, style.get("roof_colors", TERRACOTTA), moss=style.get("moss", False))
        c.paint(c.rect(1, top - 1, W - 1, top + 3), ex["plank"], np.where(c.yy < top, 0.6, 0.22), dither=False)  # the eaves
        c.paint(c.rect(int(cx) - 14, roof_h - 21, int(cx) + 14, roof_h - 19), style.get("roof_colors", TERRACOTTA), 0.95, dither=False)  # ridge
        ch = style.get("chimney", -14)
        if ch is not None:
            smoke = _chimney(c, ex, int(cx + ch), 2, roof_h - 10 + 4)
    else:
        apex_x = cx
        half = (W - 6) / 2
        gable = (c.yy >= 2) & (c.yy < top + 3) & (np.abs(c.xx + 0.5 - apex_x) <= half * (c.yy - 2) / max(top + 3 - 2, 1) + 0.5)
        inner = gable & (np.abs(c.xx + 0.5 - apex_x) <= (half - 5) * (c.yy - 2) / max(top + 3 - 2, 1) + 0.5) & (c.yy > 8)
        _wall_surface(c, rng, ex, 6, 2, W - 6, top + 3, colors, stains=False)
        c.a &= ~(c.rect(0, 0, W, top + 3) & ~(gable | c.rect(x0, top, x1, top + 3)))
        c.rgb[c.rect(0, 0, W, top + 3) & ~(gable | c.rect(x0, top, x1, top + 3))] = 0
        edge = gable & ~inner
        c.paint(edge, style.get("roof_colors", TERRACOTTA), np.where(c.xx < apex_x, 0.62, 0.34), dither=False)  # the bargeboards
        c.paint(c.rect(int(apex_x) - 1, 0, int(apex_x) + 1, 6), ex["plank"], 0.55, dither=False)  # the hoist beam's end at the apex
        c.fill(c.rect(int(apex_x) + 1, 3, int(apex_x) + 6, 4), ex["plank"][3])
        c.fill(c.rect(int(apex_x) + 5, 4, int(apex_x) + 6, 9), CORD[2])
        _window(c, rng, ex, int(apex_x) - 4 + int(rng.integers(-2, 3)), roof_h - 8, 9, 11, kind="shut", shutter=style.get("shutter", SHUTTER))
        c.paint(c.rect(1, top - 1, W - 1, top + 3), ex["plank"], np.where(c.yy < top, 0.6, 0.22), dither=False)
    # windows: spread over each floor, none where the door is
    door_x = W // 2 + style.get("door", 0) - 6
    shut = style.get("shutter", SHUTTER)
    kinds = ["open", "open", "shut", "curtain", "open", "dark", "curtain"]
    for fl in range(floors):
        fy = foot - sum(floor_h[:fl + 1]) + 6
        slots = max(2, cells - 2) if fl else max(2, cells - 2)
        for k in range(slots):
            wx = x0 + 6 + int((fw - 12 - 9) * (k + 0.5) / slots) - 4 + int(rng.integers(-2, 3))
            if fl == 0 and abs(wx + 4 - (door_x + 6)) < 14:
                continue
            kind = kinds[int(rng.integers(0, len(kinds)))]
            if fl == 0 and style.get("shop") and wx < door_x:
                c.paint(c.rect(wx - 3, fy + 2, wx + 17, fy + 20), PLASTER, 0.86, dither=False)
                c.paint(c.rect(wx - 2, fy + 3, wx + 16, fy + 19), PANE, 0.5 - 0.2 * ((c.yy - fy) / 20), dither=False)
                c.paint(c.rect(wx - 2, fy + 11, wx + 16, fy + 12), PLASTER, 0.8, dither=False)
                continue
            _window(c, rng, ex, wx, fy + (3 if fl == 0 else 2), 8, 12 if fl == 0 else 11, kind=kind, shutter=shut,
                    box=bool(style.get("boxes")) and bool(rng.integers(0, 2)))
    dw = style.get("door_w", 12)
    if dw > 12:
        door_x -= (dw - 12) // 2
    _door(c, rng, ex, door_x, foot - 4, w=dw, h=20, arch=bool(style.get("arch", True)), bar=bool(style.get("bar", False)))
    if style.get("extra"):
        style["extra"](c, rng, ex, dict(x0=x0, x1=x1, foot=foot, top=top, door_x=door_x, door_w=dw, W=W, H=H))
    if style.get("laundry"):
        ly = top + 14
        c.paint(c.rect(x0 + 6, ly, x1 - 6, ly + 1), CORD, 0.5, dither=False)
        for k, lx in enumerate(range(x0 + 14, x1 - 20, 15)):
            col = [LINEN, AWNING_RED, CRATE_BLUE, LINEN][k % 4]
            c.paint(c.rect(lx, ly + 1, lx + 8, ly + 10 - (k % 2) * 3), col, np.where(c.xx < lx + 4, 0.7, 0.4), dither=False)
    c.outline(st["outline"])
    return c, smoke


def _florist_extra(c, rng, ex, g):
    """The florist's front: a faded green and cream awning over the shop window, scalloped at its edge and sagging on one
    side, a hanging sign with a painted peony beside the door, a window full of pots."""
    ax0, ax1 = g["x0"] + 4, g["door_x"] - 3
    ay = g["foot"] - 33
    for x in range(ax0, ax1):
        sag = int((x - ax0) * 0.04)
        stripe = ((x - ax0) // 6) % 2
        c.paint(c.rect(x, ay + sag, x + 1, ay + 9 + sag), AWNING_GREEN if stripe else PLASTER, np.where(c.yy < ay + sag + 1, 0.85, 0.55 - 0.12 * ((c.yy - ay - sag) / 9)), dither=False)
        if (x - ax0) % 6 in (1, 2, 3, 4):
            c.paint(c.rect(x, ay + 9 + sag, x + 1, ay + 11 + sag), AWNING_GREEN if stripe else PLASTER, 0.4, dither=False)
    for k in range(3):  # pots in the window
        px = ax0 + 6 + k * 12
        c.paint(c.rect(px, g["foot"] - 18, px + 7, g["foot"] - 11), TERRACOTTA, 0.55, dither=False)
        c.paint(c.ellipse(px + 3.5, g["foot"] - 21, 5, 4), PEONY if k != 1 else PEONY_WHITE, 0.6 + 0.1 * k, dither=False)
        c.fill(c.rect(px + 2, g["foot"] - 22, px + 4, g["foot"] - 20), PEONY[4] if k != 1 else PEONY_WHITE[3])
    bx = g["door_x"] + g["door_w"] + 5  # the hanging sign
    c.paint(c.rect(bx - 1, g["foot"] - 44, bx + 15, g["foot"] - 42), ex["iron"], 0.6, dither=False)
    c.paint(c.rect(bx + 1, g["foot"] - 42, bx + 2, g["foot"] - 39), CORD, 0.6, dither=False)
    c.paint(c.rect(bx + 12, g["foot"] - 42, bx + 13, g["foot"] - 40), CORD, 0.6, dither=False)
    c.paint(c.rect(bx, g["foot"] - 40, bx + 14, g["foot"] - 29), ex["plank"], 0.7, dither=False)
    c.paint(c.ellipse(bx + 7, g["foot"] - 35, 4, 3.5), PEONY, 0.65, dither=False)
    c.fill(c.rect(bx + 6, g["foot"] - 36, bx + 8, g["foot"] - 34), PEONY[4])
    c.fill(c.rect(bx + 4, g["foot"] - 32, bx + 10, g["foot"] - 31), LEAF[2])


def _workshop_extra(c, rng, ex, g):
    """The workshop's front: a signboard with a saw painted on it, a hoist beam with a pulley under the eaves on the right,
    a pile of sawdust against the door, a soot-stained chimney, one leaf of the doors standing a hand's breadth open."""
    sx, sy = g["x0"] + 8, g["foot"] - 44
    c.paint(c.rect(sx, sy, sx + 30, sy + 14), ex["plank"], 0.55, dither=False)
    c.paint(c.rect(sx, sy, sx + 30, sy + 1), ex["plank"], 0.85, dither=False)
    c.paint(c.rect(sx + 3, sy + 7, sx + 27, sy + 10), ex["iron"], 0.75, dither=False)  # the blade
    for k in range(12):
        c.fill(c.rect(sx + 3 + k * 2, sy + 10, sx + 4 + k * 2, sy + 12), ex["iron"][3])
    c.paint(c.rect(sx + 23, sy + 3, sx + 28, sy + 8), ex["plank"], 0.25, dither=False)  # the handle
    hx = g["x1"] - 22  # the hoist
    c.paint(c.rect(hx, g["top"] + 6, hx + 22, g["top"] + 9), ex["plank"], 0.6, dither=False)
    c.paint(c.ellipse(hx + 20, g["top"] + 12, 3, 3), ex["iron"], 0.7, dither=False)
    c.fill(c.rect(hx + 20, g["top"] + 12, hx + 21, g["top"] + 13), ex["iron"][0])
    c.paint(c.rect(hx + 21, g["top"] + 14, hx + 22, g["top"] + 34), CORD, 0.5, dither=False)
    c.paint(c.rect(hx + 18, g["top"] + 34, hx + 25, g["top"] + 38), ex["iron"], 0.55, dither=False)  # a hook with a block
    dust = c.ellipse(g["door_x"] + g["door_w"] / 2 - 6, g["foot"] - 4, 16, 3) & (c.yy > g["foot"] - 7)
    c.paint(dust, HAY, 0.85, dither=False)
    c.paint(dust & (c.xx < g["door_x"] + 4), HAY, 0.6, dither=False)
    c.paint(c.rect(g["door_x"] + g["door_w"] // 2 - 1, g["foot"] - 24, g["door_x"] + g["door_w"] // 2 + 1, g["foot"] - 5), ex["iron"], 0.04, dither=False)  # the gap


def town_hall(ms):
    """The town hall: a broad front of pale stone, a ground floor of dark dressed stone with a double door and barred windows,
    a balcony over the door, a clock without numerals, a flat roof with a parapet whose top is wide enough for a goat
    to stand on, one finial missing, a drainpipe and two banner poles (one banner is gone). 192 x 152, anchor (96, 144):
    the glyph stands on the middle of its eleven footprint cells; the parapet's top lies at y 8."""
    rng = np.random.default_rng(1031)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    W, H = 192, 152
    c = ms.Canvas(W, H)
    x0, x1 = 8, 184
    top_wall = 31
    ground_top = 104
    # the upper floors: pale render with quoins
    _wall_surface(c, rng, ex, x0, top_wall, x1, ground_top, PLASTER, stains=False)
    for y in range(top_wall + 4, ground_top - 6, 12):  # quoins at the corners, alternating long and short
        for k, (qx0, qx1) in enumerate(((x0, x0 + 9 + 4 * ((y // 12) % 2)), (x1 - 9 - 4 * (1 - (y // 12) % 2), x1))):
            c.paint(c.rect(qx0, y, qx1, y + 10), TOWN_STONE, 0.58 + 0.1 * k, dither=False)
            c.paint(c.rect(qx0, y, qx1, y + 1), TOWN_STONE, 0.9, dither=False)
            c.paint(c.rect(qx0, y + 9, qx1, y + 10), TOWN_STONE, 0.2, dither=False)
    c.paint(c.rect(x0, ground_top - 3, x1, ground_top + 1), TOWN_STONE, np.where(c.yy < ground_top - 2, 0.9, 0.35), dither=False)  # string course
    # the ground floor: dark dressed stone
    _ashlar(c, rng, x0, ground_top + 1, x1, H, ex["stone_wall"], course=8, wmin=12, wmax=20, base=0.46, spread=0.1)
    c.paint(c.rect(x0, H - 6, x1, H), ex["stone_wall"], 0.24 + 0.08 * (pa.value_noise(H, W, 3, rng) - 0.5), dither=False)
    # barred windows on the ground floor (arched), not evenly spaced
    for wx in (26, 54, 130, 160):
        c.paint(c.rect(wx - 2, 117, wx + 12, 140), TOWN_STONE, 0.8, dither=False)
        c.paint(c.rect(wx, 119, wx + 10, 138) | (c.ellipse(wx + 5, 119, 5, 3.5) & (c.yy < 119)), PANE, 0.2, dither=False)
        for bx in range(wx + 1, wx + 10, 3):
            c.paint(c.rect(bx, 116, bx + 1, 138), ex["iron"], 0.5, dither=False)
        c.paint(c.rect(wx - 3, 139, wx + 13, 142), TOWN_STONE, np.where(c.yy < 140, 0.92, 0.36), dither=False)
    # the double door with its arch, steps and two bracket lanterns (dark)
    door = c.rect(84, 120, 108, 148) | (c.ellipse(96, 120, 12, 9) & (c.yy < 120))
    c.paint(c.rect(80, 114, 112, 148) | (c.ellipse(96, 118, 16, 12) & (c.yy < 118)), TOWN_STONE, 0.78, dither=False)
    grain = pa.value_noise(H, W, (1, 6), rng)
    c.paint(door, ex["plank"], np.where(((c.xx - 84) % 4) == 3, 0.1, 0.36 + 0.14 * (grain - 0.5)) - 0.08 * (c.yy - 110) / 40, dither=False)
    c.paint(door & (c.xx >= 95) & (c.xx < 97), ex["plank"], 0.06, dither=False)
    for yy in (126, 136):
        c.paint(door & (c.yy >= yy) & (c.yy < yy + 2), ex["iron"], 0.5, dither=False)
    c.fill(c.rect(92, 134, 94, 137), BRASS[3])
    c.fill(c.rect(98, 134, 100, 137), BRASS[2])
    c.paint(c.rect(74, 144, 118, 148), TOWN_STONE, np.where(c.yy < 145, 0.88, 0.4), dither=False)  # the steps
    c.paint(c.rect(70, 148, 122, 152), TOWN_STONE, np.where(c.yy < 149, 0.82, 0.3), dither=False)
    for lx in (73, 117):
        c.paint(c.rect(lx, 118, lx + 6, 120), ex["iron"], 0.6, dither=False)
        c.paint(c.rect(lx + 1, 120, lx + 5, 128), ex["iron"], 0.15, dither=False)
        c.paint(c.rect(lx + 2, 121, lx + 4, 127), PANE, 0.18, dither=False)
    # the second floor: tall windows, a balcony over the door
    for wx, kind, shut in ((22, "open", SHUTTER), (50, "shut", SHUTTER), (136, "open", SHUTTER), (162, "dark", SHUTTER)):
        _window(c, rng, ex, wx, 70, 11, 24, kind=kind, shutter=shut)
    c.paint(c.rect(150, 91, 160, 94), TERRACOTTA, 0.55, dither=False)  # a pot on a sill
    c.paint(c.ellipse(155, 88, 4, 3.5), PEONY_WHITE, 0.55, dither=False)
    c.paint(c.rect(88, 68, 104, 100) | (c.ellipse(96, 70, 8, 6) & (c.yy < 70)), TOWN_STONE, 0.78, dither=False)
    c.paint(c.rect(90, 70, 102, 100) | (c.ellipse(96, 72, 6, 4) & (c.yy < 72)), PANE, 0.2, dither=False)
    c.paint(c.rect(95, 70, 97, 100), PLASTER, 0.9, dither=False)
    c.paint(c.rect(90, 70, 94, 100), CLOTH, np.where(((c.xx - 90) % 2) == 0, 0.5, 0.72), dither=False)  # a curtain
    c.paint(c.rect(76, 100, 116, 106), TOWN_STONE, np.where(c.yy < 101, 0.92, 0.42), dither=False)  # the balcony slab
    c.paint(c.rect(74, 104, 118, 108), TOWN_STONE, 0.3, dither=False)
    c.paint(c.rect(78, 92, 114, 94), ex["iron"], 0.7, dither=False)  # the rail
    for rx in range(78, 115, 4):
        c.paint(c.rect(rx, 93, rx + 1, 100), ex["iron"], 0.5, dither=False)
    # the third floor: small windows and the clock
    for wx, kind in ((24, "open"), (52, "plain"), (140, "shut"), (164, "open")):
        _window(c, rng, ex, wx, 40, 9, 12, kind=kind, shutter=SHUTTER_OCHRE)
    cx, cy = 96, 48
    c.paint(c.ellipse(cx, cy, 15, 15), TOWN_STONE, 0.8 - 0.2 * ((c.yy - cy) / 15), dither=False)
    c.paint(c.ellipse(cx, cy, 12, 12), CLOTH, 0.72 - 0.12 * ((c.xx - cx) / 12), dither=False)
    for k in range(12):
        ang = k * np.pi / 6
        c.fill(c.rect(int(cx + 9.5 * np.sin(ang)), int(cy - 9.5 * np.cos(ang)), int(cx + 9.5 * np.sin(ang)) + (2 if k % 3 == 0 else 1), int(cy - 9.5 * np.cos(ang)) + (2 if k % 3 == 0 else 1)), ex["iron"][1])
    c.paint(ms.limb_mask(c, cx, cy, cx - 5, cy - 6, 2), ex["iron"], 0.2, dither=False)  # the hour hand, not quite where it should be
    c.paint(ms.limb_mask(c, cx, cy, cx + 8, cy - 3, 2), ex["iron"], 0.2, dither=False)
    c.fill(c.rect(cx - 1, cy - 1, cx + 1, cy + 1), BRASS[3])
    # the parapet: a cornice, a blind arcade and a coping wide enough to stand on; a stone is missing, one finial is gone
    c.paint(c.rect(x0 - 3, 26, x1 + 3, 31), TOWN_STONE, np.where(c.yy < 27, 0.9, 0.4), dither=False)
    _ashlar(c, rng, x0 - 1, 12, x1 + 1, 26, TOWN_STONE, course=7, wmin=14, wmax=22, base=0.55)
    for ax in range(x0 + 6, x1 - 8, 16):
        c.paint(c.rect(ax, 15, ax + 9, 25) | (c.ellipse(ax + 4.5, 15, 4.5, 3) & (c.yy < 15)), TOWN_STONE, 0.28, dither=False)
    c.paint(c.rect(x0 - 2, 8, x1 + 2, 13), TOWN_STONE, np.where(c.yy < 10, 0.97, 0.7), dither=False)
    c.paint(c.rect(x0 - 2, 12, x1 + 2, 13), TOWN_STONE, 0.2, dither=False)
    for fx, whole in ((x0 + 2, True), (x1 - 8, False)):
        if whole:
            c.paint(c.ellipse(fx + 3, 4, 4, 4), TOWN_STONE, 0.4 + 0.5 * c.sphere(fx + 2, 3, 5, 5), dither=False)
            c.paint(c.rect(fx, 6, fx + 7, 9), TOWN_STONE, 0.62, dither=False)
        else:
            c.paint(c.rect(fx, 6, fx + 7, 9), TOWN_STONE, 0.5, dither=False)
            c.paint(c.rect(fx + 1, 4, fx + 5, 6), TOWN_STONE, 0.85, dither=False)  # only the broken stump
    c.paint(c.rect(18, 31, 20, 118), ex["iron"], np.where(c.xx < 19, 0.6, 0.3), dither=False)  # the drainpipe
    for py in range(40, 118, 22):
        c.paint(c.rect(17, py, 22, py + 2), ex["iron"], 0.5, dither=False)
    _banner(c, 8, 72, 28)
    c.paint(c.rect(171, 72, 186, 74), pa.STYLES["tal"]["wood"], 0.6, dither=False)  # the other pole: its banner is gone
    c.paint(c.rect(184, 72, 186, 80), CORD, 0.5, dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the square
FOUNTAIN_RIM_AT = (-1, 2)  # the cell of the rim patch, relative to the fountain's: south-west of it, in front of its rim
FOUNTAIN_PATCH = (14, 70, 54, 92)  # the rim's front-left stretch in the fountain's image: x0, y0, x1, y1
FOUNTAIN_ANCHOR = (56, 80)


def _note(c, cx, cy, w, h, ang, colors, tone, lines=0, strike=0, pin=True, rng=None):
    """A sheet of paper pinned to the board, a little off true: `lines` rows of scribble, `strike` strokes across it."""
    u = (c.xx + 0.5 - cx) * np.cos(ang) + (c.yy + 0.5 - cy) * np.sin(ang)
    v = -(c.xx + 0.5 - cx) * np.sin(ang) + (c.yy + 0.5 - cy) * np.cos(ang)
    sheet = (np.abs(u) <= w / 2) & (np.abs(v) <= h / 2)
    c.paint(sheet, colors, np.clip(tone + 0.12 * (v < -h / 2 + 1.2) - 0.12 * (u > w / 2 - 1.2), 0, 1), dither=False)
    ink = np.zeros_like(sheet)
    for k in range(lines):
        row = -h / 2 + 2.4 + k * 2.2
        ink |= sheet & (np.abs(v - row) < 0.55) & (u > -w / 2 + 1.5) & (u < w / 2 - 1.5 - 2.6 * ((k * 5 + int(w)) % 3))
    c.paint(ink, colors, 0.04, dither=False)
    for k in range(strike):
        ink2 = sheet & (np.abs(v - (-h / 2 + 2.5 + k * 2.5 + 0.5 * np.sin(u))) < 0.6) & (np.abs(u) < w / 2 - 0.5)
        c.paint(ink2, ramp("#2a1410", "#5a2018", "#8e3024", "#b44a3a"), 0.45, dither=False)
    if pin:
        px, py = int(cx - np.sin(ang) * 0 + 0.5), int(cy - h / 2 + 1.5)
        c.fill(c.rect(px, py, px + 1, py + 1), np.array([200, 70, 60], np.float32))
    return sheet


def board(ms):
    """The notice board of the one who cannot say no: two posts with a small roof, and on the board sixteen sheets in many
    hands and papers (no two the same size, none straight): most are scribbled, one is blank, one is struck through again
    and again, one has come loose at the top and hangs by a single pin, and a corner is torn. There is no figure on it and no
    digit; two larger sheets above and a curve of small ones below nod, if one wants to see it. 80 x 76, anchor (40, 68)."""
    rng = np.random.default_rng(1101)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(80, 76)
    grain = pa.value_noise(76, 80, (1, 5), rng)
    for px in (8, 68):
        c.paint(c.rect(px, 18, px + 5, 69), ex["plank"], np.where(c.xx < px + 2, 0.62, 0.26) + 0.1 * (grain - 0.5), dither=False)
    c.paint(c.ellipse(11, 69, 7, 2), st["stone"], 0.3, dither=False)
    c.paint(c.ellipse(71, 69, 7, 2), st["stone"], 0.3, dither=False)
    boardm = c.rect(4, 14, 76, 62)
    c.paint(boardm, ex["plank"], 0.42 + 0.14 * (grain - 0.5) - 0.08 * (c.yy - 14) / 48, dither=False)
    c.paint(boardm & (((c.yy - 14) % 8) == 7), ex["plank"], 0.08, dither=False)
    c.paint(c.rect(4, 14, 76, 16), ex["plank"], 0.8, dither=False)
    c.paint(c.rect(4, 60, 76, 62), ex["plank"], 0.2, dither=False)
    c.paint(c.rect(4, 14, 6, 62), ex["plank"], 0.75, dither=False)
    c.paint(c.rect(74, 14, 76, 62), ex["plank"], 0.16, dither=False)
    # the little roof of boards
    roof = c.rect(1, 6, 79, 14) & (c.yy >= 6 + (np.abs(c.xx - 40) * 0.0))
    c.paint(roof, ex["plank"], np.where(c.yy < 8, 0.85, np.where(c.yy > 12, 0.2, 0.5)), dither=False)
    c.paint(c.rect(1, 12, 79, 14), ex["plank"], 0.14, dither=False)
    # sixteen sheets: (cx, cy, w, h, angle in degrees, paper, tone, scribble rows, strokes)
    sheets = [
        (14, 24, 11, 14, -7, 0, 0.75, 4, 0), (27, 22, 13, 9, 5, 2, 0.7, 3, 0), (40, 25, 10, 13, -3, 3, 0.7, 4, 0),
        (53, 22, 12, 10, 8, 1, 0.75, 3, 0), (66, 25, 11, 13, -6, 4, 0.7, 4, 0),
        (17, 38, 12, 9, 9, 1, 0.72, 3, 0), (29, 40, 9, 13, -5, 0, 0.8, 0, 0), (41, 38, 13, 10, 3, 2, 0.7, 3, 0),
        (54, 40, 10, 12, -9, 3, 0.7, 4, 3), (66, 39, 12, 9, 6, 4, 0.72, 3, 0),
        (12, 52, 10, 9, -4, 4, 0.7, 3, 0), (24, 53, 11, 8, 7, 0, 0.78, 2, 0), (36, 54, 12, 8, -2, 1, 0.74, 3, 0),
        (49, 53, 10, 9, 5, 2, 0.72, 2, 0), (61, 52, 11, 9, -7, 3, 0.7, 3, 0), (71, 50, 8, 10, 4, 0, 0.78, 3, 0),
    ]
    for cx, cy, w, h, deg, paper, tone, lines, strike in sheets:
        _note(c, cx, cy, w, h, np.radians(deg), PAPER[paper], tone, lines=lines, strike=strike)
    # one has come loose at the top and hangs by a single pin; a corner of another is torn off
    c.paint(c.rect(40, 29, 44, 31), PAPER[0], 0.35, dither=False)
    c.paint(c.rect(56, 30, 60, 33) & (c.xx - 56 + c.yy - 30 > 3), ex["plank"], 0.4, dither=False)
    c.fill(c.rect(68, 13, 76, 15), ex["plank"][1])
    c.paint(c.rect(9, 16, 12, 20), PAPER[1], 0.55, dither=False)  # a scrap under the eaves
    c.outline(st["outline"])
    return c


def _fountain_canvas(ms, worn):
    """The fountain: a wide basin of dressed stone on a plinth, the water in it, a stout column with a bowl and two iron
    spouts (the water falls in two thin threads), moss and a chip. With `worn`, the front-left rim has three smooth,
    deep hollows where pails and jugs have stood. 112 x 100, anchor (56, 80)."""
    rng = np.random.default_rng(1103)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(112, 100)
    cx, cy = 56, 52
    outer = c.ellipse(cx, cy, 52, 25)
    wall = (c.ellipse(cx, cy + 12, 52, 25) & (c.yy >= cy)) | outer
    _ashlar(c, rng, 4, cy, 108, 90, TOWN_STONE, course=7, wmin=10, wmax=16, base=0.5, clip=wall & (c.yy >= cy))
    c.paint(wall & (c.yy >= cy) & (c.yy > cy + 20), TOWN_STONE, 0.22, dither=False)
    top = outer
    c.paint(top, TOWN_STONE, 0.62 + 0.3 * c.sphere(cx - 12, cy - 6, 56, 28) - 0.18 * (np.hypot((c.xx - cx) / 52, (c.yy - cy) / 25) < 0.78), contrast=2.2, dither=False)
    water = c.ellipse(cx, cy, 44, 19)
    c.paint(water, st["water"], 0.5 + 0.3 * (1 - c.sphere(cx, cy, 44, 19)), contrast=2.0, dither=False)
    for wx, wy, ww in ((30, 55, 8), (70, 60, 6), (46, 63, 9), (82, 52, 5), (22, 50, 4)):  # glints on the water
        c.fill(c.rect(wx, wy, wx + ww, wy + 1), st["water"][4])
    # the column, its bowl, two spouts and their threads
    c.paint(c.rect(50, 20, 62, 54), TOWN_STONE, 0.18 + 0.7 * c.cylinder(48, 64), contrast=2.2, dither=False)
    for y in range(24, 52, 7):
        c.paint(c.rect(50, y, 62, y + 1), TOWN_STONE, 0.14, dither=False)
    bowl = c.ellipse(cx, 18, 14, 6)
    c.paint(bowl, TOWN_STONE, 0.4 + 0.5 * c.sphere(cx - 4, 16, 16, 8), dither=False)
    c.paint(c.ellipse(cx, 17, 11, 3.8), st["water"], 0.62, dither=False)
    c.paint(c.rect(53, 9, 59, 18) | c.ellipse(cx, 9, 3, 2), TOWN_STONE, 0.75, dither=False)  # the finial of the column
    for sx, d in ((41, -1), (71, 1)):
        c.paint(c.rect(sx, 20, sx + 5, 23), ex["iron"], 0.7, dither=False)
        for y in range(23, 54):
            c.fill(c.rect(sx + 2 + d * (y - 23) // 14, y, sx + 3 + d * (y - 23) // 14, y + 1), st["water"][4 if y % 4 else 3])
    # the rim: lit on the left, a lip that overhangs, one chipped stone, moss at the waterline
    c.paint(outer & ~c.ellipse(cx, cy, 46, 21), TOWN_STONE, 0.86, dither=False)
    c.paint(outer & ~c.ellipse(cx, cy, 46, 21) & (c.xx > cx + 20), TOWN_STONE, 0.6, dither=False)
    c.paint(c.rect(88, 36, 94, 40) & outer, TOWN_STONE, 0.12, dither=False)
    c.paint((c.ellipse(cx, cy, 46, 21) & ~c.ellipse(cx, cy, 44, 19)) & (c.yy < cy), MOSS, 0.6, dither=False)
    c.paint(wall & (c.yy > cy + 12) & (pa.value_noise(100, 112, 2, rng) > 0.66), MOSS, 0.45, dither=False)
    c.paint(c.rect(4, 88, 108, 91) & wall, TOWN_STONE, 0.16, dither=False)
    if worn:
        for hx, hy, hw in ((24, 76, 7), (35, 79, 6), (45, 81, 5)):  # deep, smooth hollows on the rim's front-left stretch
            hollow = c.ellipse(hx, hy, hw, 2.6)
            c.paint(hollow, TOWN_STONE, 0.14 + 0.1 * (c.xx < hx), dither=False)
            c.paint(c.ellipse(hx + 0.6, hy + 1.2, hw - 1.2, 1.4) & hollow, TOWN_STONE, 0.82, dither=False)
    c.outline(st["outline"])
    return c


def fountain(ms):
    return _fountain_canvas(ms, False)


def fountain_rim(ms):
    """The worn stretch of the fountain's rim as a patch that lies over it (the map puts it on the cell south-west of the
    fountain's; the catalog anchor brings it onto the rim). 40 x 22."""
    full = _fountain_canvas(ms, True)
    x0, y0, x1, y1 = FOUNTAIN_PATCH
    c = ms.Canvas(x1 - x0, y1 - y0)
    c.rgb = full.rgb[y0:y1, x0:x1].copy()
    c.a = full.a[y0:y1, x0:x1].copy()
    # only where the hollows are: the rest of the patch must not repaint the rim
    base = _fountain_canvas(ms, False)
    same = (np.abs(base.rgb[y0:y1, x0:x1] - c.rgb).sum(axis=2) < 1) & (base.a[y0:y1, x0:x1] == c.a)
    c.a &= ~same
    return c


def rim_anchor():
    """The anchor of the rim patch: the patch's cell lies FOUNTAIN_RIM_AT cells from the fountain's, and the patch's pixel
    at the cell centre must sit where the fountain image has it."""
    dx, dy = FOUNTAIN_RIM_AT
    x0, y0, _, _ = FOUNTAIN_PATCH
    return (dx * 16 - x0 + FOUNTAIN_ANCHOR[0], dy * 16 - y0 + FOUNTAIN_ANCHOR[1])


def stall(ms, kind):
    """A market stall: a trestle counter under a slanted canopy on two posts. kind 0 sells fruit (crates of apples, pears
    and plums), kind 1 sells cloth (bolts that lean against the back, one unrolled over the counter). Both have a canopy that
    has been patched with another colour. 88 x 80, anchor (44, 72)."""
    rng = np.random.default_rng(1111 + kind)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(88, 80)
    grain = pa.value_noise(80, 88, (1, 5), rng)
    awning = AWNING_RED if kind == 0 else AWNING_GREEN
    for px in (8, 76):
        c.paint(c.rect(px, 14, px + 4, 72), ex["plank"], np.where(c.xx < px + 2, 0.6, 0.26) + 0.1 * (grain - 0.5), dither=False)
    # what is sold, behind the counter
    if kind == 1:
        for k, (bx, tone, col) in enumerate(((14, 0.6, CRATE_BLUE), (22, 0.62, OCHRE), (30, 0.6, ROSE), (60, 0.6, GREYBLUE), (68, 0.64, AWNING_GREEN))):
            c.paint(c.rect(bx, 30, bx + 8, 56), col, np.where(c.xx < bx + 3, tone + 0.12, tone - 0.1), dither=False)
            c.paint(c.ellipse(bx + 4, 30, 4, 1.6), col, 0.92, dither=False)
    # the counter
    c.paint(c.rect(4, 52, 84, 72), ex["plank"], 0.38 + 0.12 * (grain - 0.5), dither=False)
    c.paint(c.rect(4, 52, 84, 55), ex["plank"], np.where(c.yy < 53, 0.88, 0.62), dither=False)
    c.paint(c.rect(4, 55, 84, 72) & (((c.xx - 4) % 11) == 10), ex["plank"], 0.08, dither=False)
    if kind == 0:
        for k, (bx, fr) in enumerate(((10, APPLE_RED), (36, APPLE_GOLD), (62, ramp("#2a1a3a", "#4e3466", "#7a5c92", "#a690b8")))):
            c.paint(c.rect(bx, 44, bx + 18, 54), ex["plank"], 0.5, dither=False)
            for fx in range(bx + 2, bx + 17, 4):
                fy = 43 - ((fx + k) % 3)
                c.paint(c.ellipse(fx + 1.5, fy + 2, 2.6, 2.6), fr, 0.5 + 0.12 * ((fx * 7) % 3) + 0.2 * c.sphere(fx, fy, 4, 4), dither=False)
    else:
        c.paint(c.rect(34, 50, 58, 58), CLOTH, np.where(c.xx < 44, 0.7, 0.45), dither=False)  # a cloth thrown over the counter
        c.paint(c.rect(34, 58, 58, 62) & (((c.xx - 34) // 3) % 2 == 0), CLOTH, 0.4, dither=False)
    # the canopy: slanted, striped, one stripe patched; scalloped hem
    ridge = 6
    canopy = (c.yy >= ridge + (c.xx - 2) * 0.03) & (c.yy < 30 + (c.xx - 2) * 0.03) & (c.xx >= 2) & (c.xx < 86)
    stripe = ((c.xx.astype(int) - 2) // 7) % 2
    col = np.where(stripe == 0, 0.62, 0.84)
    c.paint(canopy, awning, np.clip(col - 0.3 * (c.yy - ridge) / 24, 0, 1), dither=False)
    c.paint(canopy & (stripe == 1), PLASTER, np.clip(0.8 - 0.3 * (c.yy - ridge) / 24, 0, 1), dither=False)
    c.paint(canopy & (c.xx >= 44) & (c.xx < 56) & (c.yy > 12) & (c.yy < 24), ramp("#3a2a10", "#6a4c1c", "#9a7430", "#c49c4a"), 0.6, dither=False)  # a patch
    for x in range(2, 86):
        if ((x - 2) % 7) in (1, 2, 3, 4, 5):
            c.paint(c.rect(x, 30 + int((x - 2) * 0.03), x + 1, 33 + int((x - 2) * 0.03)), awning if ((x - 2) // 7) % 2 == 0 else PLASTER, 0.38, dither=False)
    c.paint(c.rect(2, ridge - 1 + 0, 86, ridge + 1), ex["plank"], 0.7, dither=False)
    c.paint(c.ellipse(44, 74, 40, 4) & (c.yy > 72), st["stone"], 0.3, dither=False)
    c.outline(st["outline"])
    return c


def wreath(ms):
    """A wreath of leaves and twigs with a faded red ribbon, standing on a little easel of two crossed sticks; something has
    been eating it: a bite out of the lower left, ragged ends, one flower gone. 36 x 44, anchor (18, 40)."""
    rng = np.random.default_rng(1121)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(36, 44)
    for x0, x1 in ((6, 18), (30, 18)):  # the easel
        c.paint(ms.limb_mask(c, x0, 14, x1, 40, 3), ex["plank"], 0.5, dither=False)
    c.paint(c.rect(11, 30, 25, 32), ex["plank"], 0.35, dither=False)
    cx, cy = 18, 19
    ring = c.ellipse(cx, cy, 14, 14) & ~c.ellipse(cx, cy, 7.5, 7.5)
    bite = c.ellipse(8, 28, 6.5, 5.2) | c.ellipse(11, 31, 4.5, 3.4)
    bite |= c.rect(5, 24, 9, 27) & (c.xx + c.yy > 29)
    leaves = ring & ~bite
    n = pa.value_noise(44, 36, 2, rng)
    c.paint(leaves, LEAF, 0.3 + 0.55 * n + 0.2 * c.sphere(cx - 4, cy - 5, 18, 18), contrast=2.0)
    for k in range(40):  # twigs and single leaves that stick out of the ring
        a = rng.uniform(0, 2 * np.pi)
        r = rng.uniform(12, 15.5)
        px, py = int(cx + r * np.cos(a)), int(cy + r * np.sin(a))
        if 0 <= px < 35 and 0 <= py < 43 and not bite[py, px]:
            c.fill(c.rect(px, py, px + 2, py + 1), LEAF[1 + int(rng.integers(0, 3))])
    flowers = ramp("#7a6a14", "#c8a82c", "#f0d85a", "#fff2a0")
    for ang in (-1.9, -0.9, 0.5, 1.4):  # four flowers; a fifth was where the bite is
        px, py = int(cx + 10.5 * np.cos(ang)), int(cy + 10.5 * np.sin(ang))
        c.paint(c.ellipse(px, py, 2.6, 2.6), flowers, 0.7, dither=False)
        c.fill(c.rect(px, py, px + 1, py + 1), flowers[3])
    c.paint(c.rect(15, 4, 21, 7), AWNING_RED, 0.7, dither=False)  # the ribbon: a knot and two ends, one chewed short
    c.paint(c.rect(13, 6, 16, 12), AWNING_RED, 0.6, dither=False)
    c.paint(c.rect(20, 6, 23, 10), AWNING_RED, 0.45, dither=False)
    c.outline(st["outline"])
    return c


def lectern(ms):
    """A lectern with a sloped top and a shelf under it, on three splayed legs; the left one is too short, and has been
    propped up on a stack of three books (so the whole thing leans). 36 x 52, anchor (18, 46)."""
    rng = np.random.default_rng(1123)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(36, 52)
    for x0, x1, y1 in ((10, 6, 44), (26, 30, 46)):
        c.paint(ms.limb_mask(c, x0, 22, x1, y1, 3), ex["plank"], 0.45, dither=False)
    c.paint(c.rect(17, 22, 20, 44), ex["plank"], np.where(c.xx < 18, 0.62, 0.28), dither=False)
    c.paint(c.rect(9, 33, 29, 36), ex["plank"], 0.55, dither=False)  # the shelf
    slope = c.rect(3, 8, 33, 22) & (c.yy >= 8 + (33 - c.xx) * 0.06)
    c.paint(slope, ex["plank"], 0.7 - 0.25 * (c.yy - 8) / 14 + 0.1 * (pa.value_noise(52, 36, 2, rng) - 0.5), dither=False)
    c.paint(c.rect(3, 20, 33, 23), ex["plank"], 0.3, dither=False)
    c.paint(c.rect(3, 8, 33, 10), ex["plank"], 0.92, dither=False)
    c.paint(c.rect(12, 3, 26, 8), PAPER[0], 0.7, dither=False)  # a page left on it, curled
    c.fill(c.rect(12, 7, 26, 8), PAPER[0][1])
    c.paint(c.rect(14, 4, 24, 5), PAPER[0], 0.18, dither=False)
    c.paint(c.rect(14, 6, 21, 7), PAPER[0], 0.18, dither=False)
    for k, (bw, col) in enumerate(((10, CRATE_BLUE), (9, AWNING_RED), (11, SHUTTER_OCHRE))):  # the stack under the left leg
        by = 44 - 3 * (k + 1) + 1
        c.paint(c.rect(1 + k % 2, by, 1 + k % 2 + bw, by + 3), col, 0.6, dither=False)
        c.paint(c.rect(1 + k % 2, by, 1 + k % 2 + bw, by + 1), PAPER[0], 0.8, dither=False)
    c.paint(c.ellipse(18, 47, 14, 2.4) & (c.yy > 45), st["stone"], 0.3, dither=False)
    c.outline(st["outline"])
    return c


def bread_table(ms):
    """A trestle table under a white cloth (one corner trails on the ground), a round loaf on a board, a small bowl of salt and
    four sparrows: two on the table's edge, one on the loaf, one on the ground in front of it; their crumbs. 64 x 44,
    anchor (32, 38)."""
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(64, 44)
    for x0 in (8, 50):  # the trestles
        c.paint(ms.limb_mask(c, x0, 22, x0 - 3, 40, 3), ex["plank"], 0.4, dither=False)
        c.paint(ms.limb_mask(c, x0, 22, x0 + 3, 40, 3), ex["plank"], 0.32, dither=False)
    c.paint(c.rect(2, 16, 62, 26), ex["plank"], 0.5, dither=False)
    cloth = c.rect(0, 14, 64, 28) | c.rect(3, 26, 18, 40) & (c.yy < 40 - (c.xx - 3) * 0.15)
    cloth &= ~(c.rect(54, 26, 64, 28))
    c.paint(cloth, LINEN, np.where(c.yy < 17, 0.95, 0.74 - 0.16 * ((c.xx.astype(int) % 7) == 0) - 0.08 * (c.yy - 17) / 12), dither=False)
    c.paint(c.rect(0, 27, 64, 28) & cloth, LINEN, 0.3, dither=False)
    c.paint(c.rect(6, 40, 18, 41) & cloth, LINEN, 0.3, dither=False)
    c.paint(c.rect(18, 8, 44, 16), ex["plank"], 0.7, dither=False)  # the board
    c.paint(c.ellipse(31, 9.5, 11, 5.5), BREAD, 0.5 + 0.3 * c.sphere(28, 6, 12, 7), dither=False)
    for k in range(3):  # the cuts in the crust
        c.paint(c.rect(26 + k * 4, 6 + k % 2, 28 + k * 4, 9 + k % 2), BREAD, 0.9, dither=False)
    c.paint(c.ellipse(52, 13.5, 4.5, 2.8), ex["plank"], 0.5, dither=False)  # the salt in its bowl
    c.paint(c.ellipse(52, 12, 3.2, 1.6), LINEN, 0.98, dither=False)
    c.fill(c.rect(51, 11, 52, 12), np.array([255, 255, 255], np.float32))
    def sparrow(x, y, face):
        c.paint(c.ellipse(x, y, 3.4, 2.6), SPARROW, 0.35 + 0.3 * (c.yy < y), dither=False)
        c.paint(c.ellipse(x + face * 3, y - 1.8, 1.9, 1.7), SPARROW, 0.55, dither=False)
        c.fill(c.rect(x + face * 5, y - 2, x + face * 5 + 1, y - 1), np.array([190, 160, 90], np.float32))
        c.fill(c.rect(x + face * 3, y - 3, x + face * 3 + 1, y - 2), np.array([20, 20, 20], np.float32))
        c.fill(c.rect(x - face * 4, y, x - face * 7, y + 1), SPARROW[1])
        c.fill(c.rect(x - 1, y + 2, x, y + 4), np.array([120, 90, 70], np.float32))
        c.fill(c.rect(x + 1, y + 2, x + 2, y + 4), np.array([120, 90, 70], np.float32))
    sparrow(9, 12, 1)
    sparrow(58, 12, -1)
    sparrow(36, 3, -1)
    sparrow(26, 38, 1)
    for cx_, cy_ in ((40, 12), (42, 14), (44, 11), (32, 35), (36, 37)):
        c.fill(c.rect(cx_, cy_, cx_ + 1, cy_ + 1), BREAD[3])
    c.outline(st["outline"])
    return c


def crate(ms, kind):
    """A crate of grey planks with iron corners: kind 0 one crate, kind 1 two, the upper one askew. 28 x 30, anchor (14, 26)."""
    rng = np.random.default_rng(1131 + kind)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(28, 30)

    def box(x0, y0, w, h, tilt=0):
        face = c.rect(x0, y0 + 4, x0 + w, y0 + h)
        lid = c.rect(x0 + tilt, y0, x0 + w + tilt, y0 + 5)
        c.paint(lid, ex["plank"], np.where(c.yy < y0 + 1, 0.9, 0.62), dither=False)
        c.paint(face, ex["plank"], 0.4 + 0.1 * (pa.value_noise(30, 28, (1, 4), rng) - 0.5), dither=False)
        for k in range(3):
            c.paint(c.rect(x0, y0 + 5 + k * 5, x0 + w, y0 + 6 + k * 5) & face, ex["plank"], 0.08, dither=False)
        for px in (x0, x0 + w - 3):
            c.paint(c.rect(px, y0 + 4, px + 3, y0 + h), ex["plank"], 0.58 if px == x0 else 0.22, dither=False)
        c.fill(c.rect(x0 + 1, y0 + 6, x0 + 2, y0 + 7), ex["iron"][3])
    if kind == 0:
        box(4, 8, 20, 19)
    else:
        box(3, 13, 22, 14)
        box(6, 2, 16, 12, tilt=2)
    c.paint(c.ellipse(14, 27, 12, 2.2) & (c.yy > 26), st["stone"], 0.3, dither=False)
    c.outline(st["outline"])
    return c


def barrel(ms, kind):
    """A barrel of grey staves with three iron hoops and a lid; kind 1 stands open with a ladle in it and a rain-dark rim.
    22 x 30, anchor (11, 27)."""
    rng = np.random.default_rng(1137 + kind)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(22, 30)
    body = c.ellipse(11, 17, 9.5, 12) & c.rect(1, 6, 21, 29)
    staves = ((c.xx.astype(int) - 1) % 3) == 2
    c.paint(body, ex["plank"], np.where(staves, 0.12, 0.22 + 0.6 * c.cylinder(1, 21) + 0.1 * (pa.value_noise(30, 22, 2, rng) - 0.5)), contrast=2.2, dither=False)
    for y0 in (9, 17, 25):
        c.paint(c.rect(1, y0, 21, y0 + 2) & body, ex["hoop"], 0.2 + 0.7 * c.cylinder(1, 21), dither=False)
    top = c.ellipse(11, 7, 9, 3.4)
    c.paint(top, ex["plank"], 0.62, dither=False)
    if kind == 1:
        c.paint(c.ellipse(11, 7.2, 6.6, 2.2), st["water"], 0.35, dither=False)
        c.paint(ms.limb_mask(c, 14, 8, 19, 1, 2), ex["plank"], 0.5, dither=False)
        c.paint(c.ellipse(19, 2, 2.2, 1.4), ex["iron"], 0.6, dither=False)
    else:
        c.paint(c.ellipse(11, 7.2, 5, 1.6), ex["plank"], 0.4, dither=False)
    c.paint(c.ellipse(11, 29, 9, 1.8) & (c.yy > 28), st["stone"], 0.3, dither=False)
    c.outline(st["outline"])
    return c


def lamp_post(ms):
    """An iron lamp post with a scrolled bracket and a lantern whose glass is dark: nothing burns in it by day. 18 x 72,
    anchor (9, 68)."""
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(18, 72)
    c.paint(c.rect(7, 18, 11, 66), ex["iron"], np.where(c.xx < 9, 0.7, 0.25), dither=False)
    c.paint(c.rect(5, 58, 13, 68), ex["iron"], np.where(c.xx < 9, 0.6, 0.3), dither=False)
    c.paint(c.rect(4, 64, 14, 68), ex["iron"], 0.4, dither=False)
    c.paint(c.rect(6, 28, 12, 30), ex["iron"], 0.75, dither=False)  # a collar
    c.paint(ms.limb_mask(c, 9, 40, 2, 34, 2), ex["iron"], 0.6, dither=False)  # a scrolled bracket that holds nothing now
    c.paint(c.ellipse(3, 34, 2, 2), ex["iron"], 0.6, dither=False)
    c.paint(c.rect(4, 2, 14, 6), ex["iron"], 0.8, dither=False)  # the lantern's cap
    c.paint(c.rect(6, 0, 12, 3), ex["iron"], 0.9, dither=False)
    c.paint(c.rect(5, 6, 13, 18), PANE, 0.2 + 0.4 * (c.xx < 8), dither=False)
    c.paint(c.rect(8, 6, 10, 18), ex["iron"], 0.5, dither=False)
    c.paint(c.rect(4, 17, 14, 20), ex["iron"], 0.6, dither=False)
    c.paint(c.ellipse(9, 67, 8, 2) & (c.yy > 66), st["stone"], 0.3, dither=False)
    c.outline(st["outline"])
    return c


def buckets(ms):
    """Three pails in front of a shop, full of peonies (pink, white, a deep one) with a few petals on the ground; one pail is
    dented tin, one wood, one a cracked crock. 56 x 40, anchor (28, 34)."""
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(56, 40)
    for bx, col, kind in ((3, PEONY, "tin"), (20, PEONY_WHITE, "wood"), (37, ramp("#3a0e22", "#701c40", "#a83860", "#d870a0", "#f2b0cc"), "crock")):
        stems = c.rect(bx + 3, 8, bx + 13, 24)
        c.paint(stems & (((c.xx.astype(int) + bx) % 3) == 0), LEAF, 0.5, dither=False)
        for k in range(4):
            fx, fy = bx + 3 + (k * 3 + (bx % 5)) % 10, 8 + (k * 5) % 9
            c.paint(c.ellipse(fx + 1.5, fy, 4.2, 3.8), col, 0.5 + 0.12 * k + 0.2 * c.sphere(fx, fy - 1, 6, 6), dither=False)
            c.paint(c.ellipse(fx + 1.5, fy, 2.0, 1.8), col, 0.28, dither=False)
            c.fill(c.rect(fx + 1, fy - 1, fx + 2, fy), col[-1])
        body = c.rect(bx, 20, bx + 16, 36) & (np.abs(c.xx + 0.5 - bx - 8) <= 7 + (c.yy - 20) * -0.1 + 1)
        if kind == "tin":
            c.paint(body, ex["iron"], 0.25 + 0.7 * c.cylinder(bx, bx + 16), dither=False)
            c.paint(c.rect(bx + 2, 25, bx + 6, 29), ex["iron"], 0.9, dither=False)  # a dent
        elif kind == "wood":
            c.paint(body, ex["plank"], np.where(((c.xx.astype(int) - bx) % 3) == 2, 0.1, 0.22 + 0.55 * c.cylinder(bx, bx + 16)), dither=False)
            c.paint(c.rect(bx, 24, bx + 16, 26) & body, ex["hoop"], 0.6, dither=False)
            c.paint(c.rect(bx, 32, bx + 16, 34) & body, ex["hoop"], 0.6, dither=False)
        else:
            c.paint(body, TERRACOTTA, 0.3 + 0.6 * c.cylinder(bx, bx + 16), dither=False)
            c.paint(ms.limb_mask(c, bx + 9, 22, bx + 7, 34, 1), TERRACOTTA, 0.05, dither=False)  # the crack
        c.paint(c.rect(bx - 1, 20, bx + 17, 22), ex["iron"] if kind == "tin" else ex["plank"], 0.7, dither=False)
    for px, py in ((6, 37), (31, 38), (49, 36), (14, 38)):  # petals
        c.fill(c.rect(px, py, px + 2, py + 1), PEONY[3])
    c.outline(st["outline"])
    return c


def woodstack(ms):
    """A stack of split logs, end grain to the front, under a leaning board that keeps the rain off; a few logs tumbled at the
    foot. 56 x 44, anchor (28, 38)."""
    rng = np.random.default_rng(1151)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(56, 44)
    c.paint(c.rect(2, 36, 54, 40), ex["plank"], 0.3, dither=False)
    for row, (y, count) in enumerate(((31, 8), (24, 8), (17, 7), (10, 6))):
        for k in range(count):
            x = 6 + k * 6.2 + (3 if row % 2 else 0) + rng.uniform(-0.6, 0.6)
            r = rng.uniform(3.0, 3.8)
            c.paint(c.rect(int(x - r), int(y - r), int(x + r), int(y + r + 1)) | c.ellipse(x, y, r + 0.4, r + 0.4), ex["bark"], 0.3, dither=False)
            end = c.ellipse(x + 0.4, y, r, r)
            rings = (np.hypot(c.xx + 0.5 - x, c.yy + 0.5 - y).astype(int) % 2) == 0
            c.paint(end, st["wood"], np.where(rings, 0.68, 0.5) + 0.1 * (rng.random() - 0.5) + 0.12 * c.sphere(x - 1, y - 1, r + 1, r + 1) - 0.1, dither=False)
    for lx, ly in ((10, 40), (46, 41)):  # tumbled logs
        c.paint(c.ellipse(lx, ly, 5, 2.6), ex["bark"], 0.4, dither=False)
        c.paint(c.ellipse(lx + 3.6, ly, 1.6, 2.2), st["wood"], 0.7, dither=False)
    c.paint(ms.limb_mask(c, 6, 2, 12, 34, 6), ex["plank"], 0.5, dither=False)  # the board leaning on it
    c.outline(st["outline"])
    return c


def sawhorse(ms):
    """A sawhorse (two crossed pairs of legs and a beam) with a plank across it, half sawn through, the saw still in the kerf and
    a drift of sawdust under it. 48 x 34, anchor (24, 30)."""
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(48, 34)
    for x0 in (10, 34):
        c.paint(ms.limb_mask(c, x0, 16, x0 - 5, 30, 3), ex["plank"], 0.42, dither=False)
        c.paint(ms.limb_mask(c, x0, 16, x0 + 5, 30, 3), ex["plank"], 0.3, dither=False)
    c.paint(c.rect(4, 12, 44, 17), ex["plank"], np.where(c.yy < 13, 0.8, 0.5), dither=False)
    c.paint(c.rect(1, 9, 42, 12), ex["plank"], np.where(c.yy < 10, 0.95, 0.68), dither=False)  # the plank on top
    c.paint(c.rect(26, 9, 28, 12), ex["plank"], 0.02, dither=False)  # the kerf
    c.paint(c.rect(22, 3, 34, 6), ex["iron"], 0.8, dither=False)  # the saw in it
    for k in range(6):
        c.fill(c.rect(23 + k * 2, 6, 24 + k * 2, 7), ex["iron"][3])
    c.paint(c.rect(32, 0, 36, 4), ex["plank"], 0.3, dither=False)
    dust = c.ellipse(24, 31, 14, 2.6) & (c.yy > 28)
    c.paint(dust, HAY, 0.85, dither=False)
    c.outline(st["outline"])
    return c


def seat_crate(ms):
    """A crate that someone sits on: the map puts it on the cell NORTH of the player's seat, and the catalog anchor (which lies
    below the image) brings it under the sitter; it is `flat`, so the sitter is drawn over it. 28 x 18."""
    rng = np.random.default_rng(1163)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(28, 18)
    c.paint(c.rect(2, 2, 26, 8), ex["plank"], np.where(c.yy < 3, 0.9, 0.66), dither=False)
    c.paint(c.rect(2, 8, 26, 17), ex["plank"], 0.36 + 0.1 * (pa.value_noise(18, 28, (1, 4), rng) - 0.5), dither=False)
    for y in (11, 14):
        c.paint(c.rect(2, y, 26, y + 1), ex["plank"], 0.08, dither=False)
    for px in (2, 23):
        c.paint(c.rect(px, 8, px + 3, 17), ex["plank"], 0.55 if px == 2 else 0.2, dither=False)
    c.outline(st["outline"])
    return c


def pots(ms, kind):
    """A flowerpot or two at a doorstep: kind 0 a clay pot with a green fan, kind 1 two pots, one with something dried. 24 x 22,
    anchor (12, 19)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(24, 22)
    spots = ((8, 7),) if kind == 0 else ((6, 7), (16, 5))
    for k, (px, ph) in enumerate(spots):
        c.paint(c.rect(px - ph // 2 + 1, 13, px + ph // 2 + 3, 19), TERRACOTTA, np.where(c.xx < px + 1, 0.7, 0.35), dither=False)
        c.paint(c.rect(px - ph // 2, 12, px + ph // 2 + 4, 14), TERRACOTTA, 0.82, dither=False)
        for j in range(5):
            c.paint(ms.limb_mask(c, px + 2, 13, px + 2 + (j - 2) * 2, 5 + abs(j - 2), 2), LEAF if not (kind == 1 and k == 1) else OCHRE, 0.6 + 0.08 * j, dither=False)
    c.outline(st["outline"])
    return c


def duck(ms):
    """An ordinary white duck in profile, standing on the cobbles and looking west: a plump body with a pointed tail, a short neck,
    an orange bill and two orange legs with flat feet, one dark eye. It does what ducks do, nothing else (Akt IV, S3: nobody
    explains it). The shadow is part of the picture (a flat patch of darker cobble under the feet): the catalog gives it no
    shadow, so the baked stamp of the town stays as it is. Canvas 16 x 16 (the duck itself is 14 x 13), anchor (8, 14)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 16)
    c.paint(c.ellipse(7.5, 13.6, 6.4, 1.5) & (c.yy > 12.4), st["stone"], 0.26, dither=False)  # the shadow, under everything
    d = ms.Canvas(16, 16)
    # the body as a grid (x 0 to 15, y 0 to 13; the outline comes round it): head, a thin neck, a round body with the breast to
    # the front (west), the back rising to a pointed tail, then the legs and the flat feet below
    grid = ("................",
            ".....##.........",
            "....####........",
            "....####........",
            "....####........",
            ".....###........",
            ".....####.....#.",
            "....#########.##",
            "...###########..",
            "...###########..",
            "....##########..",
            ".....########...",
            "................")
    body = np.zeros((16, 16), bool)
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            body[y, x] = ch == "#"
    light = 0.62 + 0.38 * d.sphere(6.0, 3.5, 11, 8.5)
    d.paint(body, DUCK, np.where(d.yy >= 10, light - 0.2, light), dither=False)
    d.paint(d.rect(6, 12, 7, 13) | d.rect(9, 12, 10, 13), DUCK_BILL, 0.6, dither=False)  # the legs
    d.paint(d.rect(4, 13, 8, 14) | d.rect(7, 13, 11, 14), DUCK_BILL, 0.85, dither=False)  # the flat feet
    d.paint(d.rect(1, 3, 4, 5), DUCK_BILL, np.where(d.yy < 4, 0.85, 0.5), dither=False)  # the bill
    d.fill(d.rect(5, 2, 6, 3), np.array([20, 18, 30], np.float32))  # the eye
    d.paint(d.rect(5, 9, 12, 10) & body, DUCK, 0.3, dither=False)  # the folded wing: its lower edge in shade
    d.outline(st["outline"])
    c.blit(d, 0, 0)
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
    build_town(ms)


# the houses of the town: (name, seed, footprint cells, floors, style); the cells, in px, are what the map has to leave free
HOUSES = [
    ("st_house_a", 2001, 5, 2, dict(wall=OCHRE, boxes=True, chimney=-16, laundry=True)),
    ("st_house_b", 2002, 7, 2, dict(wall=PLASTER, frame=True, roof_colors=SLATE, moss=True, door=18, boxes=True)),
    ("st_house_c", 2003, 5, 3, dict(wall=GREYBLUE, roof="gable", roof_colors=TERRACOTTA, shutter=SHUTTER_BLUE, door=-8)),
    ("st_house_d", 2004, 7, 2, dict(wall=ROSE, shutter=SHUTTER_OCHRE, chimney=20, door=-14)),
    ("st_house_e", 2005, 7, 2, dict(wall=PLASTER, roof="gable", roof_colors=SLATE, shutter=SHUTTER_BLUE, door=12, boxes=True)),
    ("st_house_f", 2006, 5, 2, dict(wall=GREYBLUE, roof_colors=SLATE, shutter=SHUTTER_OCHRE, moss=True, chimney=8, door=-10)),
    ("st_house_g", 2007, 9, 2, dict(wall=OCHRE, frame=True, roof_colors=TERRACOTTA, boxes=True, door=22, laundry=True, chimney=-30)),
    ("st_house_h", 2008, 5, 2, dict(wall=PLASTER, roof_colors=TERRACOTTA, shutter=SHUTTER_BLUE, boxes=True, chimney=14, door=10)),
    ("st_house_i", 2009, 7, 2, dict(wall=OCHRE, frame=True, roof_colors=SLATE, moss=True, shutter=SHUTTER_BLUE, door=-20, boxes=True)),
    ("st_house_k", 2010, 5, 2, dict(wall=ROSE, roof_colors=SLATE, shutter=SHUTTER, laundry=True, chimney=-12, door=14)),
]
FLORIST = (2011, 7, 2, dict(wall=ROSE, shop=True, boxes=True, door=6, extra=_florist_extra, chimney=18))
WORKSHOP = (2012, 9, 2, dict(wall=PLASTER, roof_colors=SLATE, shutter=SHUTTER_OCHRE, door_w=26, bar=True, arch=False, door=0,
                              extra=_workshop_extra, moss=True, chimney=30))


def build_town(ms):
    """Registers the town's sprites (S2). Houses and shops carry no shadow (their foot is the map's solid ground); what stands
    free on the cobbles does. The glyph of a facade stands on the middle cell of its footprint, the anchor is the centre of
    that cell (the wall's foot lies 8 px under it)."""
    walls = [_wall_h(ms, 1101 + k, k) for k in range(3)]
    ms.save("tal", "st_wall_h", walls, (8, 40))
    ms.save("tal", "st_wall_v", _wall_v(ms, 1104), (12, 84))
    ms.save("tal", "st_wall_tower", wall_tower(ms), (28, 96))
    ms.save("tal", "st_gate", gate(ms), (96, 68))
    ms.save("tal", "st_guard_hut", guard_hut(ms), (36, 64))
    for name, seed, cells, floors, style in HOUSES:
        canvas, smoke = town_house(ms, seed, cells, floors, style)
        ms.save("tal", name, canvas, (canvas.w // 2, canvas.h - 8), smoke=[smoke[0] - canvas.w // 2, smoke[1] - (canvas.h - 8)] if smoke else None)
    for name, spec in (("st_florist", FLORIST), ("st_workshop", WORKSHOP)):
        seed, cells, floors, style = spec
        canvas, smoke = town_house(ms, seed, cells, floors, style)
        ms.save("tal", name, canvas, (canvas.w // 2, canvas.h - 8), smoke=[smoke[0] - canvas.w // 2, smoke[1] - (canvas.h - 8)] if smoke else None)
    hall = town_hall(ms)
    ms.save("tal", "st_town_hall", hall, (96, 144))
    ms.save("tal", "st_board", board(ms), (40, 68), shape={"rect": [64, 8], "offset": [0, -4]}, shadow=[30, 4])
    ms.save("tal", "st_fountain", fountain(ms), FOUNTAIN_ANCHOR, shape={"rect": [100, 60], "offset": [0, -22]}, shadow=[48, 8])
    ms.save("tal", "st_fountain_rim", fountain_rim(ms), rim_anchor())
    ms.save("tal", "st_stall_fruit", stall(ms, 0), (44, 72), shape={"rect": [76, 14], "offset": [0, -8]}, shadow=[36, 6])
    ms.save("tal", "st_stall_cloth", stall(ms, 1), (44, 72), shape={"rect": [76, 14], "offset": [0, -8]}, shadow=[36, 6])
    ms.save("tal", "st_wreath", wreath(ms), (18, 40), shape={"circle": 5, "offset": [0, -2]}, shadow=[8, 3])
    ms.save("tal", "st_lectern", lectern(ms), (18, 46), shape={"circle": 6, "offset": [0, -2]}, shadow=[12, 3])
    ms.save("tal", "st_bread_table", bread_table(ms), (32, 38), shape={"rect": [56, 10], "offset": [0, -6]}, shadow=[28, 4])
    ms.save("tal", "st_crate", [crate(ms, 0), crate(ms, 1)], (14, 26), shape={"rect": [20, 8], "offset": [0, -3]}, shadow=[11, 3])
    ms.save("tal", "st_barrel", [barrel(ms, 0), barrel(ms, 1)], (11, 27), shape={"circle": 7, "offset": [0, -3]}, shadow=[10, 3])
    ms.save("tal", "st_lamp_post", lamp_post(ms), (9, 68), shape={"circle": 3, "offset": [0, -1]}, shadow=[6, 2])
    ms.save("tal", "st_buckets", buckets(ms), (28, 34), shape={"rect": [48, 8], "offset": [0, -3]}, shadow=[22, 4])
    ms.save("tal", "st_woodstack", woodstack(ms), (28, 38), shape={"rect": [52, 10], "offset": [0, -4]}, shadow=[26, 4])
    ms.save("tal", "st_sawhorse", sawhorse(ms), (24, 30), shape={"rect": [40, 8], "offset": [0, -4]}, shadow=[20, 3])
    ms.save("tal", "st_seat_crate", seat_crate(ms), (14, -7), flat=True)
    ms.save("tal", "st_pots", [pots(ms, 0), pots(ms, 1)], (12, 19))
    # S3: the duck by the florist's pots; its shadow is painted into the picture (no catalog shadow: the town's stamp stays)
    ms.save("tal", "st_duck", duck(ms), (8, 14), shape={"circle": 4, "offset": [0, -3]})


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


def preview_town(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    pieces = [town_hall(ms), gate(ms), guard_hut(ms), wall_tower(ms), _wall_h(ms, 1101, 0), _wall_h(ms, 1102, 1), _wall_h(ms, 1103, 2),
              _wall_v(ms, 1104)]
    pieces += [town_house(ms, seed, cells, floors, style)[0] for _, seed, cells, floors, style in HOUSES]
    pieces += [town_house(ms, *FLORIST)[0], town_house(ms, *WORKSHOP)[0]]
    pieces += [board(ms), fountain(ms), fountain_rim(ms), stall(ms, 0), stall(ms, 1), wreath(ms), lectern(ms), bread_table(ms),
               crate(ms, 0), crate(ms, 1), barrel(ms, 0), barrel(ms, 1), lamp_post(ms), buckets(ms), woodstack(ms), sawhorse(ms),
               seat_crate(ms), pots(ms, 0), pots(ms, 1), duck(ms)]
    width, x, y, row_h = 1000, 6, 6, 0
    placed = []
    for item in pieces:
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        if x + img.width + 6 > width:
            x, y, row_h = 6, y + row_h + 6, 0
        placed.append((img, x, y))
        x += img.width + 6
        row_h = max(row_h, img.height)
    sheet = Image.new("RGBA", (width, y + row_h + 6), (92, 120, 84, 255))
    for img, px, py in placed:
        sheet.alpha_composite(img, (px, py))
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    elif len(sys.argv) == 3 and sys.argv[1] == "--preview-town":
        preview_town(sys.argv[2])
