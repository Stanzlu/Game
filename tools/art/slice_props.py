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


# --------------------------------------------------------------------------- the valley
WATER_LINE = ramp("#2a3a40", "#3e555c", "#5a7a80", "#8aaab0")


def stone_flat(ms, seed):
    """A flat stepping stone that holds: broad dry top with moss and lichen, low sides,
    a dark wet band where it sits in the water."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(20, 14)
    noise = pa.value_noise(14, 20, 3, rng)
    side = c.ellipse(10, 8.5, 9, 4.6) & ((noise - 0.5) * 2 + c.yy > 3)
    c.paint(side, st["rock"], 0.18 + 0.25 * c.sphere(7, 6, 10, 6), contrast=2.0)
    top = c.ellipse(10, 6.5, 8.4, 3.6) & ((noise - 0.5) * 1.6 + c.yy > 2.5)
    c.paint(top, st["rock"], 0.55 + 0.3 * c.sphere(7, 5, 9, 5) + 0.1 * (noise - 0.5), contrast=2.0)
    moss = top & (pa.value_noise(14, 20, 2.5, rng) > 0.55)
    c.paint(moss, st["grass"], 0.45 + 0.4 * c.sphere(7, 5, 9, 5), contrast=1.8)
    lichen = top & ~moss & (pa.value_noise(14, 20, 1.2, rng) > 0.8)
    c.fill(lichen, np.array([150, 150, 120], np.float32))
    wet = side & (c.yy >= 10.5)
    c.paint(wet, st["water"], 0.35, dither=False)
    c.outline(st["outline"])
    ripple = c.ellipse(10, 11, 10.5, 2.6) & ~c.ellipse(10, 11, 9.5, 2.0) & ~c.a & (c.yy > 10)
    c.paint(ripple, WATER_LINE, 0.75, dither=False)
    return c


def stone_round(ms, seed):
    """A round stepping stone that tips: a dome of dark wet rock, a shine of water on top,
    no moss (the water washes over it), ripples where it rocks."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["tal"]
    c = ms.Canvas(18, 15)
    noise = pa.value_noise(15, 18, 3, rng)
    body = c.ellipse(9, 8, 7.2, 5.6) & ((noise - 0.5) * 1.5 + c.yy > 2)
    c.paint(body, st["water"], 0.08 + 0.55 * c.sphere(6.5, 5, 8, 6), contrast=2.2)
    sheen = body & c.ellipse(6.5, 5, 2.4, 1.3)
    c.fill(sheen, np.array([170, 196, 204], np.float32))
    c.fill(body & c.ellipse(6, 4.6, 0.9, 0.7), np.array([230, 240, 244], np.float32))
    c.outline(st["outline"])
    for r in (8.6, 10.0):
        ring = c.ellipse(9, 12.2, r, r * 0.28) & ~c.ellipse(9, 12.2, r - 0.9, r * 0.28 - 0.6) & ~c.a
        c.paint(ring & (c.yy > 11), WATER_LINE, 0.8 if r < 9 else 0.5, dither=False)
    return c


def fallen_tree(ms):
    """A spruce that came down across the stream, roots and all: the root plate with earth
    and stones on the west bank, the trunk bridging the water, broken branch stubs, moss."""
    rng = np.random.default_rng(71)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(86, 26)
    # trunk: a horizontal cylinder lit from above, tapering towards the east
    x0, x1 = 12, 84
    taper = np.clip((c.xx - x0) / (x1 - x0), 0, 1)
    half = 6.2 - 2.2 * taper
    cy = 13.0 + 0.6 * taper
    trunk = c.rect(x0, 0, x1, 26) & (np.abs(c.yy + 0.5 - cy) <= half)
    t = (c.yy + 0.5 - cy) / np.maximum(half, 1)
    light = np.sqrt(np.clip(1 - t * t, 0, 1)) * 0.75 + np.clip(-t, 0, 1) * 0.25
    grain = pa.value_noise(26, 86, (2, 9), rng)
    bark = 0.12 + 0.62 * light + 0.18 * (grain - 0.5)
    bark = np.where(((c.xx * 0.35 + c.yy * 1.7 + grain * 6) % 5) < 0.9, bark - 0.22, bark)
    c.paint(trunk, ex["bark"], bark, contrast=2.0)
    moss = trunk & (t < -0.25) & (pa.value_noise(26, 86, (3, 7), rng) > 0.5)
    c.paint(moss, st["grass"], 0.4 + 0.45 * light, contrast=1.8)
    # broken branch stubs sticking up and out
    for bx, length, lean in ((30, 6, -1), (47, 5, 1), (61, 4, -1), (73, 3, 1)):
        for k in range(length):
            yy = int(cy[0, bx] - half[0, bx] - k + 1)
            xx = bx + (k * lean) // 2
            c.paint(c.rect(xx, yy, xx + 2, yy + 1), ex["bark"], 0.55 - 0.05 * k, dither=False)
    # the tip: a few dry twigs
    for k, (dx, dy) in enumerate(((2, -3), (3, 2), (1, 4))):
        tip_y = int(cy[0, x1 - 1])
        c.paint(c.rect(x1 - 2 + dx, tip_y + dy - 1, x1 + dx, tip_y + dy), ex["bark"], 0.4, dither=False)
    # root plate: torn-up earth with roots sticking out in all directions, stones caught in it
    plate_noise = pa.value_noise(26, 86, 3, rng)
    a = np.arctan2(c.yy + 0.5 - 13, (c.xx + 0.5 - 9) * 1.8)
    radius = 1.0 + 0.22 * np.sin(a * 5 + 1.3) + 0.12 * np.sin(a * 9) + 0.25 * (plate_noise - 0.5)
    plate = (((c.xx + 0.5 - 9) / 6.5) ** 2 + ((c.yy + 0.5 - 13) / 10.5) ** 2) <= radius ** 2
    c.paint(plate, st["mud"], 0.22 + 0.4 * c.sphere(7, 9, 7, 11) + 0.2 * (plate_noise - 0.5), contrast=2.0)
    for ang in np.linspace(-2.6, 2.6, 9):
        for k in range(5, 12):
            x, y = 9 + np.cos(ang + np.pi) * k * 0.75, 13 + np.sin(ang + np.pi) * k * 1.15
            if 0 <= x < 86 and 0 <= y < 26:
                c.paint(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), ex["bark"], 0.45 - 0.02 * k, dither=False)
    roots = plate & (np.abs(np.sin((c.yy - 13) * 0.9 + c.xx * 0.4)) < 0.2)
    c.paint(roots, ex["bark"], 0.5, dither=False)
    pebbles = plate & (pa.value_noise(26, 86, 1.1, rng) > 0.86)
    c.paint(pebbles, st["rock"], 0.7, dither=False)
    c.outline(st["outline"])
    return c


def planks_broken(ms):
    """What is left of the bridge's middle: two boards snapped off, hanging from the stump
    of a beam down into the stream, the water foaming where they go under."""
    rng = np.random.default_rng(17)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(30, 24)
    grain = pa.value_noise(24, 30, (1, 4), rng)
    # boards as slanted strips: (x at the top, top y, x at the bottom, bottom y, width)
    for k, (xt, yt, xb, yb, w) in enumerate(((6, 2, 11, 19, 5), (17, 4, 21, 20, 5))):
        u = np.clip((c.yy - yt) / (yb - yt), 0, 1)
        left = xt + (xb - xt) * u
        board = (c.yy >= yt) & (c.yy <= yb) & (c.xx >= left) & (c.xx < left + w)
        v = 0.55 - 0.35 * u + 0.15 * (grain - 0.5)
        v = np.where(np.abs(c.xx - left - w / 2) < 0.6, v - 0.2, v)  # the seam between planks
        c.paint(board, ex["plank"], v, contrast=2.0)
        # jagged snapped top
        for dx in range(w):
            if (dx + k) % 2 == 0:
                c.a[yt, int(xt) + dx] = False
        c.fill(board & (c.yy == yt + 2) & (np.abs(c.xx - left - 1) < 0.6), np.array([30, 26, 22], np.float32))
    # the stump of the beam they hung from
    c.paint(c.rect(2, 1, 28, 3), ex["bark"], np.where(c.yy < 2, 0.6, 0.3), dither=False)
    c.outline(st["outline"])
    foam = (c.ellipse(10, 20.5, 4.5, 1.4) | c.ellipse(21, 21.5, 4.5, 1.4)) & (c.yy > 19)
    c.fill(foam & ~c.a, np.array([170, 188, 194], np.float32))
    c.a |= foam
    return c


def planks_new(ms):
    """Mira's repair: three fresh, pale boards laid over the gap and lashed with wire."""
    rng = np.random.default_rng(19)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    fresh = ramp("#3a2c1e", "#5e4a32", "#8a7050", "#ae9470", "#c8b08a")
    c = ms.Canvas(54, 50)
    grain = pa.value_noise(50, 54, (1, 9), rng)
    for k, y0 in enumerate((3, 18, 33)):
        board = c.rect(0, y0, 54, y0 + 13)
        v = 0.5 + 0.25 * (1 - (c.yy - y0) / 13) + 0.15 * (grain - 0.5) + 0.05 * k
        c.paint(board, fresh, v, contrast=2.0)
        c.paint(c.rect(0, y0 + 12, 54, y0 + 13), fresh, 0.1, dither=False)
        for wx in (4, 48):
            c.paint(c.rect(wx, y0 + 1, wx + 2, y0 + 12), ex["iron"], np.where(c.yy % 2 == 0, 0.7, 0.35),
                    dither=False)
    c.outline(st["outline"])
    return c


def tarp(ms):
    """Mira's camp: an oilcloth ridge tarp pitched low against the rain. Seen from the front:
    the near slope from the ridge down to the pegged eave, the dark open end on the right
    with her bedroll and pack in the dry."""
    rng = np.random.default_rng(12)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    canvas = ramp("#1e2218", "#2e3422", "#424a2e", "#5a633c", "#747e4c")
    c = ms.Canvas(54, 38)
    ridge_y, eave_y = 9, 29
    rx0, rx1 = 9, 43  # ridge
    ex0, ex1 = 3, 47  # eave (wider: the slope comes towards us)
    u = np.clip((c.yy - ridge_y) / (eave_y - ridge_y), 0, 1)
    left, right = rx0 + (ex0 - rx0) * u, rx1 + (ex1 - rx1) * u
    sag = 1.6 * np.sin(np.clip((c.xx - ex0) / (ex1 - ex0), 0, 1) * np.pi)
    slope = (c.yy >= ridge_y) & (c.yy <= eave_y - sag) & (c.xx >= left) & (c.xx <= right)
    # the open end on the right: a dark triangle under the ridge, things inside
    end = (c.yy >= ridge_y) & (c.yy <= eave_y) & (c.xx > right) & (c.xx <= rx1 + (52 - rx1) * u)
    c.paint(end, ramp("#0c0d0a", "#16180f", "#22251a"), 0.35 + 0.4 * u, dither=False)
    c.paint(end & c.ellipse(48, 26, 4, 2.6), ramp("#2a1e1a", "#47302a", "#6a463a"), 0.6, dither=False)
    c.paint(end & c.ellipse(46, 21, 2.6, 3), canvas, 0.45, dither=False)
    # cloth: lit along the ridge, darker and wetter towards the eave, folds where it was packed
    fold = ((c.xx - left) % 9) < 1
    v = 0.78 - 0.55 * u + 0.08 * (pa.value_noise(38, 54, 4, rng) - 0.5)
    v = np.where(fold, v - 0.14, v)
    c.paint(slope, canvas, v, contrast=2.0)
    drip = slope & (pa.value_noise(38, 54, (5, 1.5), rng) > 0.72) & (u > 0.3)
    c.paint(drip, canvas, 0.18, dither=False)
    c.paint(slope & (c.yy > eave_y - sag - 1.2), canvas, 0.08, dither=False)  # hem
    # poles at both ends of the ridge, guy lines, pegs
    for px in (rx0 - 1, rx1):
        c.paint(c.rect(px, ridge_y - 4, px + 2, eave_y + 2), ex["bark"], np.where(c.xx == px, 0.7, 0.35),
                dither=False)
    line = ramp("#3a3326", "#6a6048", "#8a7e60")
    for (ax, ay, bx, by) in ((rx0 - 1, ridge_y - 3, 0, 20), (rx1 + 1, ridge_y - 3, 53, 20)):
        for i in range(16):
            t = i / 15
            x, y = int(ax + (bx - ax) * t), int(ay + (by - ay) * t)
            c.paint(c.rect(x, y, x + 1, y + 1), line, 0.7, dither=False)
        c.paint(c.rect(bx - 1 if bx else 0, by, (bx - 1 if bx else 0) + 2, by + 2), ex["bark"], 0.5, dither=False)
    c.outline(st["outline"])
    return c


def campfire(ms):
    """A small fire under the tarp's edge, kept going in the rain: a ring of stones, charred
    logs, embers that glow (emissive), a sooty kettle on a flat stone."""
    rng = np.random.default_rng(5)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(26, 20)
    e = ms.Canvas(26, 20)
    c.paint(c.ellipse(12, 13, 9, 4.6), ramp("#141210", "#221e1a", "#34302a"), 0.4, dither=False)  # ash
    embers_ramp = ramp("#5a1a0c", "#b0401a", "#f08a30", "#ffd070")
    for i, (x, y) in enumerate(((6, 12), (9, 15), (14, 15.5), (18, 13), (16, 10), (8, 9.5))):
        m = c.ellipse(x + 0.5, y, 2.6, 2.0)
        c.paint(m, st["rock"], 0.3 + 0.5 * c.sphere(x, y - 1, 3, 2.4), contrast=2.0)
    for (ax, ay, bx, by) in ((7, 14, 16, 10), (9, 10, 17, 14)):
        for i in range(10):
            u = i / 9
            m = c.ellipse(ax + (bx - ax) * u, ay + (by - ay) * u, 1.3, 1.3)
            c.paint(m, ramp("#0e0c0b", "#1e1915", "#2e251d"), 0.4, dither=False)
    glow = c.ellipse(12, 12, 3.6, 2.0)
    c.paint(glow, embers_ramp, 0.4 + 0.6 * c.sphere(12, 11.5, 3.6, 2.2), dither=False)
    e.paint(glow, embers_ramp, 0.4 + 0.6 * c.sphere(12, 11.5, 3.6, 2.2), dither=False)
    sparks = c.ellipse(12, 12, 5, 3) & (pa.value_noise(20, 26, 1.0, rng) > 0.85) & ~glow
    c.paint(sparks, embers_ramp, 0.75, dither=False)
    e.paint(sparks, embers_ramp, 0.75, dither=False)
    # kettle on a flat stone at the side
    c.paint(c.ellipse(22, 15, 3.6, 1.8), st["rock"], 0.5, dither=False)
    kettle = c.ellipse(22, 11.5, 3, 2.6) & (c.yy < 14)
    c.paint(kettle, ex["iron"], 0.2 + 0.7 * c.sphere(21, 10, 3, 3), dither=False)
    c.paint(c.rect(21, 7, 24, 8), ex["iron"], 0.5, dither=False)
    c.outline(st["outline"])
    return c, e


def net_rack(ms):
    """Two forked sticks and a pole with a fishing net hung to dry and be mended: Mira's
    own work at the camp (she does not wait for anyone)."""
    rng = np.random.default_rng(23)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(30, 30)
    for px in (3, 25):
        c.paint(c.rect(px, 5, px + 2, 29), ex["bark"], np.where(c.xx == px, 0.7, 0.35), dither=False)
        c.paint(c.rect(px - 1, 3, px, 6), ex["bark"], 0.55, dither=False)
        c.paint(c.rect(px + 2, 3, px + 3, 6), ex["bark"], 0.55, dither=False)
    c.paint(c.rect(1, 5, 29, 7), ex["bark"], np.where(c.yy < 6, 0.7, 0.35), dither=False)
    sag = 3.0 * np.sin(np.clip((c.xx - 5) / 20, 0, 1) * np.pi)
    net = c.rect(5, 7, 25, 25) & (c.yy <= 21 + sag)
    mesh = (((c.xx + c.yy) % 4) == 0) | (((c.xx - c.yy) % 4) == 0)
    rope = ramp("#3a3529", "#5e5640", "#857a5c", "#aa9e7c")
    c.paint(net & mesh, rope, 0.45 + 0.3 * (pa.value_noise(30, 30, 3, rng) - 0.5), dither=False)
    hole = net & c.ellipse(17, 15, 2.6, 2.2)
    c.a[hole] = False
    for fx in (7, 12, 17, 22):
        fy = int(21 + 3.0 * np.sin(np.clip((fx - 5) / 20, 0, 1) * np.pi))
        c.paint(c.rect(fx, fy, fx + 2, fy + 2), ramp("#6a3a20", "#a0602c", "#c88a44"), 0.6, dither=False)
    c.outline(st["outline"])
    return c


def potato(ms):
    """A potato plant at the end of the bed, one tuber showing where the rain washed the
    soil away. Bemerkenswert durchschnittlich."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(18, 16)
    leaf = ramp("#1a2a18", "#2a4024", "#3d5a30", "#557a3e")
    for (x, y, rx, ry) in ((9, 5, 3.4, 2.4), (5, 7, 3, 2.2), (13, 7, 3, 2.2), (8, 9, 2.6, 2), (11, 3, 2.2, 1.8)):
        c.paint(c.ellipse(x, y, rx, ry), leaf, 0.3 + 0.6 * c.sphere(x - 1, y - 1, rx + 1, ry + 1), dither=False)
    tuber = c.ellipse(11, 12.5, 3.4, 2.4)
    c.paint(tuber, ramp("#4a3624", "#7a5a38", "#a88050", "#c8a070"), 0.3 + 0.65 * c.sphere(10, 11.5, 3.6, 2.6),
            dither=False)
    c.fill(tuber & c.ellipse(12.5, 13, 0.6, 0.5), np.array([70, 50, 32], np.float32))
    c.outline(st["outline"])
    return c


def goat(ms, frame, holding):
    """A shaggy valley goat seen from the side, facing left, chewing (frame 0/1: jaw up or
    down). `holding`: "boot" (Mira's boot hanging from its mouth), "potato" or None."""
    rng = np.random.default_rng(41)
    st = pa.STYLES["tal"]
    coat = ramp("#2e2a26", "#4e4740", "#756c62", "#a09588", "#c8beb0")
    dark = ramp("#141210", "#26221e", "#3a342e")
    horn = ramp("#2a2620", "#4e463a", "#7a6e5a", "#a49880")
    c = ms.Canvas(32, 26)
    fur = pa.value_noise(26, 32, (2, 3), rng)
    # legs (far pair darker), hooves
    for lx, far in ((10, True), (13, False), (21, True), (24, False)):
        c.paint(c.rect(lx, 17, lx + 2, 24), dark, 0.35 if far else 0.6, dither=False)
        c.paint(c.rect(lx, 24, lx + 2, 25), dark, 0.1, dither=False)
    # body: barrel with a shaggy underside, short tail up at the back
    body = c.ellipse(18, 13.5, 9.5, 5.6)
    body |= c.ellipse(18, 17, 8, 2.4) & ((fur > 0.45) | (c.xx % 3 == 0))
    c.paint(body, coat, 0.25 + 0.6 * c.sphere(16, 11, 10, 6) + 0.15 * (fur - 0.5), contrast=2.0)
    c.paint(c.rect(27, 8, 29, 11), coat, 0.7, dither=False)
    # neck and head, lowered a little; jaw moves with the frame
    jaw = 1 if frame else 0
    neck = c.ellipse(9.5, 10.5, 3.6, 4.2)
    c.paint(neck, coat, 0.3 + 0.55 * c.sphere(8, 9, 4, 4.5), contrast=2.0)
    head = c.ellipse(5.5, 8.5, 4.2, 3.0)
    c.paint(head, coat, 0.35 + 0.55 * c.sphere(4.5, 7.5, 4.5, 3.2), contrast=2.0)
    muzzle = c.ellipse(2.4, 10.0 + jaw * 0.6, 2.2, 1.6)
    c.paint(muzzle, coat, 0.45, dither=False)
    c.paint(c.rect(4, 12 + jaw, 6, 15 + jaw), coat, 0.55, dither=False)  # beard
    c.fill(c.rect(5, 7, 6, 8), np.array([30, 24, 16], np.float32))  # eye (sideways pupil)
    c.fill(c.rect(4, 7, 5, 8), np.array([150, 120, 50], np.float32))
    c.paint(c.rect(8, 6, 12, 7), coat, 0.3, dither=False)  # ear sticking out sideways
    for k in range(5):  # horns sweeping back
        c.paint(c.rect(6 + k, 5 - k // 2 - (1 if k > 2 else 0), 7 + k, 6 - k // 2), horn, 0.4 + 0.1 * k,
                dither=False)
    if holding == "boot":
        boot = ramp("#20140e", "#3e2618", "#5e3c24", "#7e5434")
        c.paint(c.rect(0, 11 + jaw, 4, 18 + jaw), boot, 0.55, dither=False)  # shaft
        c.paint(c.rect(0, 17 + jaw, 6, 20 + jaw), boot, 0.4, dither=False)  # foot
        c.paint(c.rect(0, 20 + jaw, 6, 21 + jaw), dark, 0.2, dither=False)  # sole
        c.paint(c.rect(1, 12 + jaw, 3, 13 + jaw), boot, 0.9, dither=False)
    elif holding == "potato":
        c.paint(c.ellipse(1.5, 11.5 + jaw, 2.0, 1.6), ramp("#4a3624", "#7a5a38", "#a88050"), 0.6, dither=False)
    c.outline(st["outline"])
    return c


def boot_icon_sprite(ms):
    """Mira's boot on its own (for the ground and the item icon): worn leather, a chewed rim."""
    st = pa.STYLES["tal"]
    boot = ramp("#20140e", "#3e2618", "#5e3c24", "#7e5434", "#9a6a44")
    c = ms.Canvas(14, 16)
    c.paint(c.rect(3, 1, 9, 11), boot, 0.3 + 0.6 * c.cylinder(3, 9), dither=False)
    c.paint(c.rect(3, 10, 13, 14), boot, 0.3 + 0.5 * c.sphere(7, 11, 7, 4), dither=False)
    c.paint(c.rect(3, 14, 13, 15), ramp("#141210", "#26221e"), 0.4, dither=False)
    for x in (4, 6, 8):
        c.a[1, x] = False  # chewed
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- the house
LOGS = ramp("#160f0b", "#241913", "#35261c", "#4a3627", "#634a35", "#7d5f44")
BEAM = ramp("#0e0a08", "#1a1310", "#2a2019", "#3b2d22")
NIGHT_GLASS = ramp("#0c1018", "#141c28", "#22303f", "#3a4c5c", "#5e7484")


def shell(ms):
    """The room seen from above and the front: the back wall of round logs with a window,
    the side walls as dark timber, the front wall with the open door. Lies under everything
    (the floor is baked from the map). 256x192: cells (12, 5) to (27, 16)."""
    rng = np.random.default_rng(81)
    st = pa.STYLES["tal"]
    c = ms.Canvas(256, 192)
    wall_top, wall_bottom = 14, 64
    # back wall: stacked logs, each lit from above, darker towards the floor
    logs = c.rect(10, wall_top, 246, wall_bottom)
    row = ((c.yy - wall_top) // 8).astype(int)
    ry = (c.yy - wall_top) % 8
    grain = pa.value_noise(192, 256, (2, 14), rng)
    v = 0.62 - 0.45 * (ry / 7.0) ** 1.6 + 0.12 * (grain - 0.5) - 0.06 * row
    v = np.where(ry == 7, 0.04, v)
    c.paint(logs, LOGS, v, contrast=2.0)
    cracks = logs & (pa.value_noise(192, 256, (1, 6), rng) > 0.86) & (ry > 1) & (ry < 6)
    c.paint(cracks, LOGS, 0.12, dither=False)
    # log ends at both corners (round, saw marks)
    for cx in (12, 244):
        for k in range(6):
            m = c.ellipse(cx, wall_top + 4 + k * 8, 4, 3.8)
            c.paint(m, LOGS, 0.35 + 0.45 * c.sphere(cx - 1, wall_top + 3 + k * 8, 4, 4), dither=False)
            c.paint(m & c.ellipse(cx, wall_top + 4 + k * 8, 1.6, 1.4), LOGS, 0.25, dither=False)
    # baseboard shadow where the wall meets the floor
    c.paint(c.rect(10, wall_bottom, 246, wall_bottom + 3), BEAM, np.where(c.yy < wall_bottom + 1, 0.2, 0.5),
            dither=False)
    c.a[(c.yy >= wall_bottom + 1) & (c.yy < wall_bottom + 3) & (c.xx >= 10) & (c.xx < 246)] = True
    # top: the beam along the wall top, darkness of the loft above
    c.paint(c.rect(0, 0, 256, wall_top - 4), BEAM, 0.05, dither=False)
    c.paint(c.rect(4, wall_top - 4, 252, wall_top), BEAM, np.where(c.yy < wall_top - 2, 0.75, 0.4), dither=False)
    # window in the back wall (cells 22-23): night-blue glass with rain, cross bars, a sill
    wx0, wx1, wy0, wy1 = 164, 188, 22, 50
    c.paint(c.rect(wx0 - 3, wy0 - 3, wx1 + 3, wy1 + 4), BEAM, 0.6, dither=False)
    glass = c.rect(wx0, wy0, wx1, wy1)
    streak = ((c.xx * 0.3 + c.yy) % 9) < 1.2
    c.paint(glass, NIGHT_GLASS, np.where(streak, 0.62, 0.2 + 0.25 * (1 - (c.yy - wy0) / (wy1 - wy0))), dither=True)
    c.paint(c.rect((wx0 + wx1) // 2 - 1, wy0, (wx0 + wx1) // 2 + 1, wy1), BEAM, 0.5, dither=False)
    c.paint(c.rect(wx0, (wy0 + wy1) // 2 - 1, wx1, (wy0 + wy1) // 2 + 1), BEAM, 0.5, dither=False)
    c.paint(c.rect(wx0 - 5, wy1 + 3, wx1 + 5, wy1 + 6), LOGS, np.where(c.yy < wy1 + 4, 0.7, 0.35), dither=False)
    # cobweb in the corner: nobody has lived here since spring
    web = (c.rect(14, wall_top, 30, wall_top + 14) & ((np.abs((c.xx - 14) - (c.yy - wall_top)) < 0.6)
                                                     | (np.abs(np.hypot(c.xx - 14, c.yy - wall_top) - 7) < 0.5)
                                                     | (np.abs(np.hypot(c.xx - 14, c.yy - wall_top) - 12) < 0.5)))
    c.fill(web & (c.xx >= 14), np.array([120, 118, 112], np.float32))
    # side walls: thick timber seen from above, darkness beyond
    for x0, x1, edge in ((0, 12, 10), (244, 256, 244)):
        c.paint(c.rect(x0, wall_top, x1, 192), BEAM, 0.05, dither=False)
        c.paint(c.rect(min(edge, x1 - 2), wall_top, min(edge, x1 - 2) + 2, 180), BEAM, 0.7, dither=False)
    # front wall: a beam with the open doorway in cell 19 (x 112..128)
    front = c.rect(4, 176, 252, 186) & ~c.rect(112, 170, 128, 192)
    c.paint(front, BEAM, np.where(c.yy < 178, 0.8, 0.35), dither=False)
    c.paint(c.rect(0, 186, 256, 192) & ~c.rect(112, 176, 128, 192), BEAM, 0.05, dither=False)
    c.paint(c.rect(110, 172, 112, 190), BEAM, 0.6, dither=False)  # door posts
    c.paint(c.rect(128, 172, 130, 190), BEAM, 0.6, dither=False)
    c.paint(c.rect(112, 186, 128, 192), NIGHT_GLASS, 0.3, dither=True)  # outside: wet dark
    return c


def fireplace(ms, lit, frame=0):
    """A fieldstone fireplace against the back wall: chimney breast, mantel beam with a note
    pinned to it, the firebox, a hearth slab on the floor. Cold: grey ash and a charred end
    of a log. Lit: flames (frame 0-2) with their glow on the stones. Returns (canvas, glow)."""
    rng = np.random.default_rng(91)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(52, 66)
    e = ms.Canvas(52, 66)
    stone = ex["stone_wall"]
    f1, f2, cid = pa.worley(66, 52, 6, rng)
    tone = ((cid * 7919) % 97) / 97.0
    body = c.rect(4, 0, 48, 56)
    v = 0.25 + 0.4 * c.cylinder(4, 48) + 0.18 * (tone - 0.5)
    v = np.where(f2 - f1 < 0.8, 0.06, v)
    c.paint(body, stone, v, contrast=2.0)
    # mantel beam with the note
    c.paint(c.rect(1, 24, 51, 29), LOGS, np.where(c.yy < 26, 0.7, 0.35), dither=False)
    c.paint(c.rect(32, 19, 39, 25), ramp("#8a8270", "#b8ae96", "#dcd2b8"), np.where(c.xx < 35, 0.7, 0.5),
            dither=False)
    c.paint(c.rect(33, 21, 38, 22), ramp("#3a3630", "#5a554a"), 0.5, dither=False)
    c.paint(c.rect(33, 23, 36, 24), ramp("#3a3630", "#5a554a"), 0.5, dither=False)
    # firebox: dark arch
    box = c.rect(14, 34, 38, 54) & ~((c.yy < 38) & (np.abs(c.xx + 0.5 - 26) > 9 + (c.yy - 34)))
    c.paint(box, ramp("#060504", "#100c0a", "#1c1612"), 0.35 * (c.yy - 34) / 20, dither=False)
    # hearth slab
    hearth = c.rect(2, 54, 50, 64)
    c.paint(hearth, stone, np.where(c.yy < 56, 0.75, 0.42) + 0.1 * (tone - 0.5), contrast=2.0)
    if lit:
        flame = ramp("#6a1a08", "#c0400e", "#f08020", "#ffc040", "#fff0a0")
        shift = [0.0, 1.3, -1.1][frame % 3]
        # logs
        for (ax, ay, bx, by) in ((17, 52, 34, 49), (19, 49, 35, 52)):
            for i in range(12):
                u = i / 11
                m = c.ellipse(ax + (bx - ax) * u, ay + (by - ay) * u, 1.6, 1.6)
                c.paint(m, ramp("#140c08", "#2a1a10", "#3e2818"), 0.5, dither=False)
        # tongues of flame: noise-shaped, taller in the middle, flickering per frame
        fn = pa.value_noise(66, 52, (3, 2), np.random.default_rng(100 + frame))
        height = 15 - np.abs(c.xx + 0.5 - 26 - shift) * 1.1 + (fn - 0.5) * 9
        tongue = (c.yy <= 50) & (c.yy >= 50 - height) & (np.abs(c.xx + 0.5 - 26) < 10) & box
        heat = np.clip(1 - (50 - c.yy) / np.maximum(height, 1), 0, 1)
        c.paint(tongue, flame, 0.25 + 0.75 * heat, dither=False)
        e.paint(tongue, flame, 0.25 + 0.75 * heat, dither=False)
        embers = c.rect(16, 50, 36, 54) & (fn > 0.45)
        c.paint(embers, flame, 0.55, dither=False)
        e.paint(embers, flame, 0.55, dither=False)
        # warm light on the hearth and the lower stones
        warm = (hearth | (body & (c.yy > 40))) & c.ellipse(26, 54, 26, 14)
        c.rgb[warm] = np.clip(c.rgb[warm] * np.array([1.35, 1.12, 0.85], np.float32), 0, 255)
    else:
        ash = c.ellipse(26, 52, 9, 2.6) & box
        c.paint(ash, ramp("#2a2826", "#45423e", "#6a6660", "#8a857e"), 0.3 + 0.5 * c.sphere(24, 51, 9, 3),
                dither=True)
        for i in range(10):
            u = i / 9
            m = c.ellipse(19 + 12 * u, 50.5 - u, 1.5, 1.5)
            c.paint(m, ramp("#0c0908", "#1c1611", "#2c241c"), 0.5, dither=False)
    c.outline(st["outline"])
    return c, e


def table(ms):
    """A rough table with a drawer and two stools; a cup nobody washed."""
    rng = np.random.default_rng(55)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(44, 30)
    grain = pa.value_noise(30, 44, (1, 8), rng)
    for lx in (8, 31):
        c.paint(c.rect(lx, 14, lx + 3, 26), LOGS, np.where(c.xx == lx, 0.6, 0.3), dither=False)
    c.paint(c.rect(6, 4, 38, 14), LOGS, 0.5 + 0.25 * (1 - (c.yy - 4) / 10) + 0.12 * (grain - 0.5), contrast=2.0)
    c.paint(c.rect(6, 14, 38, 17), LOGS, 0.22, dither=False)
    c.paint(c.rect(18, 14, 26, 17), LOGS, 0.4, dither=False)  # drawer
    c.fill(c.rect(21, 15, 23, 16), np.array([140, 120, 80], np.float32))
    c.paint(c.ellipse(29, 8, 2.4, 1.6), ramp("#5a5650", "#8a857a", "#b8b2a4"), 0.6, dither=False)  # cup
    for sx in (0, 37):  # stools
        c.paint(c.ellipse(sx + 3.5, 21, 3.6, 2.2), LOGS, 0.6, dither=False)
        c.paint(c.rect(sx + 1, 22, sx + 2, 28), LOGS, 0.3, dither=False)
        c.paint(c.rect(sx + 5, 22, sx + 6, 28), LOGS, 0.3, dither=False)
    c.outline(st["outline"])
    return c


def bed(ms):
    """A narrow bed against the wall, a grey wool blanket, a flat pillow."""
    rng = np.random.default_rng(57)
    st = pa.STYLES["tal"]
    wool = ramp("#1e2228", "#2e343c", "#444c56", "#5e6874", "#7a8490")
    c = ms.Canvas(30, 44)
    c.paint(c.rect(1, 2, 29, 42), LOGS, np.where((c.xx < 3) | (c.xx > 26), 0.55, 0.3), dither=False)
    c.paint(c.rect(4, 4, 26, 12), ramp("#6a645a", "#8e877a", "#b0a898"), 0.55 + 0.3 * c.sphere(12, 6, 12, 6),
            dither=False)
    blanket = c.rect(3, 12, 27, 40)
    folds = pa.value_noise(44, 30, (4, 2), rng)
    c.paint(blanket, wool, 0.35 + 0.35 * (folds - 0.5) + 0.2 * (1 - (c.yy - 12) / 28), contrast=2.0)
    c.paint(c.rect(3, 12, 27, 14), wool, 0.75, dither=False)
    c.outline(st["outline"])
    return c


def shelf(ms, spoon):
    """A shelf on the wall: two boards, a few empty jars, a book without a cover, and one
    empty compartment. With the spoon: it stands there as if it always had."""
    rng = np.random.default_rng(61)
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(34, 30)
    c.paint(c.rect(1, 1, 33, 29), LOGS, 0.14, dither=False)  # back of the niche
    for y in (12, 26):
        c.paint(c.rect(0, y, 34, y + 3), LOGS, np.where(c.yy == y, 0.75, 0.45), dither=False)
    c.paint(c.rect(0, 1, 2, 29), LOGS, 0.5, dither=False)
    c.paint(c.rect(32, 1, 34, 29), LOGS, 0.5, dither=False)
    glass = ramp("#2a3438", "#46585c", "#6a8286", "#9ab4b8")
    for x in (4, 10):
        jar = c.rect(x, 4, x + 5, 12)
        c.paint(jar, glass, 0.3 + 0.5 * c.cylinder(x, x + 5), dither=False)
        c.paint(c.rect(x, 3, x + 5, 5), ex["iron"], 0.5, dither=False)
    c.paint(c.rect(18, 5, 22, 12), ramp("#3a2a20", "#5a4030", "#7a5a40"), np.where(c.xx < 19, 0.7, 0.45),
            dither=False)  # the book
    c.paint(c.rect(4, 19, 12, 26), ramp("#4a4038", "#6a5c4e", "#8a7a68"), 0.5, dither=False)  # a tin
    if spoon:
        metal = ramp("#5a5e62", "#8c9296", "#c4cacc", "#eef2f2")
        c.paint(c.ellipse(24, 22.5, 1.6, 1.2), metal, 0.7, dither=False)
        c.paint(c.rect(24, 23, 25, 26), metal, 0.5, dither=False)
    c.outline(st["outline"])
    return c


def rug(ms):
    """A rag rug in faded colours in front of the fire."""
    rng = np.random.default_rng(63)
    c = ms.Canvas(44, 22)
    m = c.ellipse(22, 11, 21, 10)
    stripes = [ramp("#3a1e1c", "#5a2e28", "#7a4438"), ramp("#2a3036", "#3e4852", "#566270"),
               ramp("#3a3424", "#5a5034", "#7a6e48")]
    ring = (np.hypot((c.xx - 22) / 21, (c.yy - 11) / 10) * 6).astype(int)
    for k in range(7):
        sel = m & (ring == k)
        c.paint(sel, stripes[k % 3], 0.45 + 0.2 * (pa.value_noise(22, 44, 2, rng) - 0.5), dither=True)
    c.outline(pa.STYLES["tal"]["outline"])
    return c


def bucket(ms):
    """A tin bucket under the leak in the roof, half full; a ring on the water."""
    st, ex = pa.STYLES["tal"], ms.EXTRA["tal"]
    c = ms.Canvas(16, 16)
    c.paint(c.rect(3, 5, 13, 15), ex["hoop"], 0.25 + 0.6 * c.cylinder(3, 13), dither=False)
    c.paint(c.ellipse(8, 5.5, 5, 2), ramp("#18252c", "#2c3e46", "#4a6268", "#7a9aa0"),
            np.where(c.ellipse(8, 5.5, 2.5, 1), 0.85, 0.4), dither=False)
    c.paint(c.rect(3, 9, 13, 10), ex["hoop"], 0.15, dither=False)
    c.outline(st["outline"])
    return c


def cat(ms, pose):
    """The cat. "window": sitting outside on the sill, a dark shape against the night glass,
    eyes catching the firelight. "sleep": curled up on the rug, tail around the nose."""
    st = pa.STYLES["tal"]
    fur = ramp("#120e0c", "#221a16", "#382c24", "#54443a", "#74604e")
    if pose == "window":
        c = ms.Canvas(16, 18)
        body = c.ellipse(8, 12, 5, 5.5) | c.ellipse(8, 5.5, 3.6, 3.2)
        body |= c.rect(4, 1, 6, 4) & (c.yy >= 6 - (c.xx - 3) * 1.2)
        body |= c.rect(10, 1, 12, 4) & (c.yy >= 6 - (13 - c.xx) * 1.2)
        c.paint(body, fur, 0.2 + 0.3 * c.sphere(6, 4, 8, 10), dither=False)
        c.fill(c.rect(6, 5, 7, 6) | c.rect(9, 5, 10, 6), np.array([230, 190, 70], np.float32))
        c.paint(c.rect(12, 14, 15, 16), fur, 0.35, dither=False)  # tail over the sill
        c.outline(st["outline"])
        return c
    c = ms.Canvas(20, 12)
    body = c.ellipse(10, 7, 8, 4.4)
    c.paint(body, fur, 0.3 + 0.55 * c.sphere(8, 5, 9, 5), dither=False)
    head = c.ellipse(5, 6, 3.4, 3)
    c.paint(head, fur, 0.4 + 0.5 * c.sphere(4, 5, 3.5, 3), dither=False)
    c.paint(c.rect(3, 2, 4, 4), fur, 0.5, dither=False)
    c.paint(c.rect(6, 2, 7, 4), fur, 0.5, dither=False)
    tail = c.ellipse(9, 10, 6, 1.4) & (c.yy > 9)
    c.paint(tail, fur, 0.55, dither=False)
    c.fill(c.rect(4, 6, 6, 7), np.array([20, 16, 14], np.float32))  # closed eyes
    c.outline(st["outline"])
    return c


def build(ms):
    ms.save("elysia", "feast_table", feast_table(ms), (22, 26),
            shape={"rect": [38, 8], "offset": [0, -6]}, shadow=[22, 5])
    # valley (slice): stepping stones lie flat in the water, the player walks over them
    ms.save("tal", "stone_flat", [stone_flat(ms, s) for s in (3, 4, 5)], (10, 8), flat=True)
    ms.save("tal", "stone_round", [stone_round(ms, s) for s in (6, 7)], (9, 9), flat=True)
    ms.save("tal", "fallen_tree", fallen_tree(ms), (22, 13), flat=True)
    ms.save("tal", "planks_broken", planks_broken(ms), (15, 14), flat=True)
    ms.save("tal", "planks_new", planks_new(ms), (43, 25), flat=True)
    ms.save("tal", "tarp", tarp(ms), (26, 31), shape={"rect": [44, 10], "offset": [0, -6]}, shadow=[24, 4])
    fire, embers = campfire(ms)
    ms.save("tal", "campfire", fire, (12, 14), emissive=embers, flicker=True, smoke=[0, -6],
            lights=[{"offset": [0, -4], "color": "#ff7a30", "energy": 1.1, "range": 72}],
            shape={"circle": 7, "offset": [0, -1]})
    ms.save("tal", "net_rack", net_rack(ms), (15, 28), shape={"rect": [26, 4], "offset": [0, -1]}, shadow=[13, 3])
    ms.save("tal", "potato", potato(ms), (9, 13))
    ms.save("tal", "goat_boot", [goat(ms, f, "boot") for f in (0, 1)], (17, 24), shadow=[11, 3])
    ms.save("tal", "goat_potato", [goat(ms, f, "potato") for f in (0, 1)], (17, 24), shadow=[11, 3])
    ms.save("tal", "boot", boot_icon_sprite(ms), (7, 14))
    # the house inside (slice beat 6)
    ms.save("haus", "shell", shell(ms), (8, 8), flat=True,
            lights=[{"offset": [168, 32], "color": "#7f9cc4", "energy": 0.45, "range": 96}])
    cold, _ = fireplace(ms, False)
    ms.save("haus", "fireplace_cold", cold, (26, 60), shape={"rect": [46, 10], "offset": [0, -4]})
    lit = [fireplace(ms, True, f) for f in range(3)]
    ms.save("haus", "fireplace_lit", [f[0] for f in lit], (26, 60), emissive=[f[1] for f in lit],
            shape={"rect": [46, 10], "offset": [0, -4]},
            lights=[{"offset": [0, -14], "color": "#ff8a3a", "energy": 1.6, "range": 190}], flicker=True)
    ms.save("haus", "table", table(ms), (22, 24), shape={"rect": [34, 8], "offset": [0, -6]}, shadow=[18, 4])
    ms.save("haus", "bed", bed(ms), (15, 40), shape={"rect": [28, 30], "offset": [0, -16]})
    ms.save("haus", "shelf", shelf(ms, False), (17, 29), flat=True)
    ms.save("haus", "shelf_spoon", shelf(ms, True), (17, 29), flat=True)
    ms.save("haus", "rug", rug(ms), (22, 11), flat=True)
    ms.save("haus", "bucket", bucket(ms), (8, 14), shape={"circle": 5, "offset": [0, -3]})
    ms.save("haus", "cat_window", cat(ms, "window"), (0, 22), flat=True)
    ms.save("haus", "cat_sleep", cat(ms, "sleep"), (10, 10))
