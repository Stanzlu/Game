#!/usr/bin/env python3
"""Title screen art (ADR-017, own art, 0 €), two titles (ADR-030, Game Bible §10 and §56):

Before the rift the game pretends to be a classic fantasy RPG called ELYSIA: a perfectly
mirror-symmetric floating island with the world tree, twin waterfalls and an ornate gold
logo with a crystal. Only after the crossing does the start menu show REAL: quiet letters
(the crack runs through the A) over an evening valley with a crooked tree, a bench and a
broken fence.

The island is drawn like the terraces of the Elysia map: grass plateau, a thick earth wall
with an overhanging grass cap, then rock that tapers into the sky with hanging roots.

Writes assets/generated/title/{island,waterfall,valley,logo_elysia,logo_real}.png.
Usage: .venv/bin/python tools/art/make_title.py [--preview out.png]
Needs the prop sprites (run make_sprites.py first).
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixelart as pa  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "title")
PROPS = os.path.join(ROOT, "assets", "generated", "props", "elysia")
TAL_PROPS = os.path.join(ROOT, "assets", "generated", "props", "tal")
ST = pa.STYLES["elysia"]
TAL = pa.STYLES["tal"]


def prop(name, folder=PROPS):
    return Image.open(os.path.join(folder, name + ".png")).convert("RGBA")


def to_image(rgb, alpha):
    a = np.zeros(rgb.shape[:2] + (4,), np.uint8)
    a[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    a[..., 3] = np.where(alpha, 255, 0)
    return Image.fromarray(a, "RGBA")


def island_base(w=330, h=176, seed=11):
    """Plateau (seen slightly from above), earth wall with grass cap, tapering rock."""
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    rgb = np.zeros((h, w, 3), np.float32)
    alpha = np.zeros((h, w), bool)
    cx = w / 2
    top, plateau_h = 6, 44
    wall_h = 20
    wall_top = top + plateau_h - 8
    # plateau: a wide flattened ellipse
    plateau = ((xx + 0.5 - cx) / (w * 0.49)) ** 2 + ((yy + 0.5 - (top + plateau_h / 2)) / (plateau_h / 2)) ** 2 <= 1
    # rock body below the wall, tapering with a ragged outline
    noise = pa.value_noise(h, w, 6, rng)
    rock = np.zeros((h, w), bool)
    body_top = wall_top + 4
    for y in range(int(body_top), h - 1):
        t = (y - body_top) / (h - 1 - body_top)
        half = (w * 0.47) * (1 - t) ** 1.25 + 2
        wobble = (noise[y] - 0.5) * 14 * t
        rock[y] = np.abs(xx[y] + 0.5 - cx - wobble) <= half
    # earth wall: the plateau ellipse extended downwards by wall_h
    wall = np.zeros((h, w), bool)
    for dy in range(wall_h):
        shifted = np.roll(plateau, dy, axis=0)
        shifted[:dy] = False
        wall |= shifted
    wall &= ~plateau
    # paint rock (cells, darker towards the bottom)
    f1, f2, _ = pa.worley(h, w, (7, 12), rng, 0.8)
    v = 0.78 - 0.55 * np.clip((yy - body_top) / (h - body_top), 0, 1)
    v += 0.35 * (pa.bump_light(np.clip((f2 - f1) / 2, 0, 1) * 2) - 0.5)
    v = np.where(f2 - f1 < 0.6, v - 0.28, v)
    rgb[rock] = pa.shade(ST["cliff"], np.clip(v, 0, 1), dither=False, contrast=2.6)[rock]
    alpha |= rock
    # earth wall with vertical strata
    strata = pa.value_noise(h, w, (2, 14), rng)
    wv = 0.62 - 0.35 * np.clip((yy - wall_top) / wall_h, 0, 1) + 0.25 * (strata - 0.5)
    rgb[wall] = pa.shade(ST["cliff"], np.clip(wv, 0, 1), dither=True, contrast=2.4)[wall]
    alpha |= wall
    # plateau grass with soft light from the top left
    g_noise = pa.value_noise(h, w, 5, rng, octaves=2)
    gv = 0.55 + 0.25 * (g_noise - 0.5) - 0.18 * ((xx - cx) / w) - 0.1 * ((yy - top) / plateau_h)
    rgb[plateau] = pa.shade(ST["grass"], np.clip(gv, 0, 1), dither=True, contrast=2.2)[plateau]
    alpha |= plateau
    # grass cap hanging over the wall edge (bumpy)
    lip = np.roll(plateau, 2, axis=0) & ~plateau
    lip &= (pa.value_noise(h, w, (1, 4), rng) > 0.35)
    rgb[lip] = pa.shade(ST["grass"], np.full((h, w), 0.32), dither=False)[lip]
    alpha |= lip
    # hanging roots and vines from under the wall
    for _ in range(26):
        x = int(rng.uniform(cx - w * 0.42, cx + w * 0.42))
        ys = np.nonzero(alpha[:, x])[0]
        if len(ys) == 0:
            continue
        y0 = int(ys.max()) - int(rng.uniform(4, 26))
        length = int(rng.uniform(8, 30))
        vine = rng.random() < 0.5
        for k in range(length):
            y = y0 + k
            xx_k = x + int(round(np.sin(k * 0.35 + x) * 1.2))
            if 0 <= y < h and 0 <= xx_k < w:
                col = ST["foliage"][2 if k % 4 else 3] if vine else ST["bark"][1 if k % 3 else 2]
                rgb[y, xx_k] = col
                alpha[y, xx_k] = True
    img = to_image(rgb, alpha)
    rgba = np.array(img).astype(np.float32)
    pa.outline(rgba, ST["outline"])
    return Image.fromarray(rgba.astype(np.uint8), "RGBA"), (top, plateau_h, wall_top + wall_h)


def waterfall(h=150, w=14, seed=3):
    """Falling water strip, opaque. Colour and foam repeat every `h` rows, so the title can
    scroll it endlessly; the scroll shader fades it out towards the bottom (into the sky)."""
    rng = np.random.default_rng(seed)
    water = ST["water"]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    phase = rng.uniform(0, 2 * np.pi, (4, w))
    streaks = np.zeros((h, w), np.float32)
    for n in range(4):
        streaks += np.sin(2 * np.pi * (n + 2) * yy / h + phase[n][None, :]) / (n + 1)
    streaks = (streaks - streaks.min()) / (streaks.max() - streaks.min())
    v = 0.5 + 0.35 * (streaks - 0.5) + 0.25 * np.sin(xx / w * np.pi)
    rgb = pa.shade(water, np.clip(v, 0, 1), dither=True, contrast=2.0)
    edge = (xx < 1) | (xx >= w - 1)
    rgb[edge] = water[0]
    foam = streaks > 0.8
    rgb[foam] = (236, 248, 255)
    a = np.zeros((h, w, 4), np.uint8)
    a[..., :3] = rgb.astype(np.uint8)
    a[..., 3] = 255
    return Image.fromarray(a, "RGBA")


def island(seed=11):
    base, (top, plateau_h, wall_bottom) = island_base(seed=seed)
    w, h = base.size
    extra_top = 178
    canvas = Image.new("RGBA", (w, h + extra_top), (0, 0, 0, 0))
    canvas.alpha_composite(base, (0, extra_top))
    plateau_mid = extra_top + top + plateau_h // 2
    cx = w // 2

    def place(img, x, ground_y):
        canvas.alpha_composite(img, (int(x - img.width / 2), int(ground_y - img.height)))


    # grass detail on the plateau: tufts, wildflowers and pebbles, back to front
    rng = np.random.default_rng(seed + 1)
    rx, ry = w * 0.46, plateau_h * 0.42
    scatter = []
    for _ in range(70):
        ang, rad = rng.uniform(0, 2 * np.pi), np.sqrt(rng.uniform(0, 1))
        x, y = cx + np.cos(ang) * rad * rx, plateau_mid + np.sin(ang) * rad * ry
        kind = rng.choice(["grass_tuft_%d" % rng.integers(0, 5)] * 5 + ["wildflowers_%d" % rng.integers(0, 3)] * 2
                          + ["pebbles_%d" % rng.integers(0, 4)])
        scatter.append((y, x, kind))
    for y, x, kind in sorted(scatter):
        if os.path.exists(os.path.join(PROPS, kind + ".png")):
            place(prop(kind), x, y + 4)
    # back row (further up the plateau), then the tree, then the front row
    place(prop("tree_purple_0"), cx - 112, plateau_mid - 4)
    place(prop("tree_blossom_1"), cx + 116, plateau_mid - 2)
    place(prop("pillar"), cx - 64, plateau_mid + 2)
    place(prop("pillar"), cx + 64, plateau_mid + 2)
    tree = prop("sacred_tree")
    place(tree, cx, plateau_mid + 14)
    place(prop("crystal"), cx, plateau_mid + 22)
    for i, (dx, dy) in enumerate([(-130, 10), (-92, 16), (98, 15), (134, 9), (-40, 19), (44, 19)]):
        place(prop("bush_%d" % (i % 4)), cx + dx, plateau_mid + dy)
    for i, (dx, dy) in enumerate([(-110, 18), (122, 17), (-20, 21)]):
        place(prop("giant_flower_%d" % (i % 4)), cx + dx, plateau_mid + dy)
    # Elysia is perfectly symmetric (Game Bible §9): the right half is the left half mirrored
    arr = np.array(canvas)
    arr[:, w - w // 2:] = arr[:, :w // 2][:, ::-1]
    canvas = Image.fromarray(arr, "RGBA")
    # the water leaves the plateau at its right front rim (and, mirrored, at the left)
    rim_x = 128
    rim_y = extra_top + top + plateau_h / 2 + plateau_h / 2 * np.sqrt(1 - (rim_x / (w * 0.49)) ** 2)
    return canvas, (int(cx + rim_x - 7), int(rim_y) - 4)


GOLD = {"top": (255, 246, 220), "bottom": (240, 176, 70), "bands": 5, "light": (255, 255, 248),
        "dark": (196, 120, 40), "outline": (52, 24, 44), "shadow": (40, 20, 60, 150)}
# REAL after the crossing: quiet, unvarnished, almost paper (Game Bible §34 "Nach dem Riss")
QUIET = {"top": (238, 233, 222), "bottom": (205, 197, 182), "bands": 2, "light": (250, 248, 241),
         "dark": (160, 150, 136), "outline": (44, 38, 40), "shadow": (20, 16, 20, 90)}


def gild(mask, y0, letter_h, style):
    """Letters from a mask: banded vertical gradient, light top-left and dark bottom-right
    rims, a dark outline and a soft drop shadow."""
    H, W = mask.shape
    yy, _ = np.mgrid[0:H, 0:W]
    out = np.zeros((H, W, 4), np.float32)
    t = np.clip((yy - y0) / letter_h, 0, 1)
    band = np.floor(t * style["bands"]) / max(style["bands"] - 1, 1)
    band = np.clip(band, 0, 1)
    col = np.array(style["top"]) * (1 - band[..., None]) + np.array(style["bottom"]) * band[..., None]
    out[mask, :3] = col[mask]
    out[mask, 3] = 255
    up = mask & ~np.roll(mask, 1, 0)
    left = mask & ~np.roll(mask, 1, 1)
    down = mask & ~np.roll(mask, -1, 0)
    right = mask & ~np.roll(mask, -1, 1)
    out[up | left, :3] = style["light"]
    out[down | right, :3] = style["dark"]
    return out


def finish_logo(rgba, style):
    pa.outline(rgba, style["outline"])
    solid = rgba[..., 3] > 0
    shadow = np.roll(np.roll(solid, 3, 0), 1, 1) & ~solid
    rgba[shadow, :3] = style["shadow"][:3]
    rgba[shadow, 3] = style["shadow"][3]
    return Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA")


def draw_letter(d, ch, x, y0, h, s):
    """Serif capitals for ELYSIA; returns the advance width."""
    b = y0 + h - 1
    if ch == "E":
        d.rectangle([x, y0, x + s - 1, b], fill=255)
        d.rectangle([x, y0, x + 28, y0 + s - 1], fill=255)
        d.rectangle([x, y0 + h // 2 - s // 2, x + 21, y0 + h // 2 + s // 2 - 1], fill=255)
        d.rectangle([x, b - s + 1, x + 28, b], fill=255)
        d.rectangle([x + 26, y0 + s, x + 28, y0 + s + 3], fill=255)
        d.rectangle([x + 26, b - s - 3, x + 28, b - s], fill=255)
        d.rectangle([x - 3, y0, x - 1, y0 + 2], fill=255)
        d.rectangle([x - 3, b - 2, x - 1, b], fill=255)
        return 29
    if ch == "L":
        d.rectangle([x, y0, x + s - 1, b], fill=255)
        d.rectangle([x, b - s + 1, x + 27, b], fill=255)
        d.rectangle([x - 3, y0, x + s + 2, y0 + 2], fill=255)
        d.rectangle([x + 25, b - s - 3, x + 27, b - s], fill=255)
        d.rectangle([x - 3, b - 2, x - 1, b], fill=255)
        return 28
    if ch == "Y":
        m = y0 + h * 0.5
        d.polygon([(x, y0), (x + 10, y0), (x + 21, m), (x + 13, m)], fill=255)
        d.polygon([(x + 34, y0), (x + 24, y0), (x + 13, m), (x + 21, m)], fill=255)
        d.rectangle([x + 13, int(m) - 2, x + 21, b], fill=255)
        d.rectangle([x + 9, b - 2, x + 25, b], fill=255)
        d.rectangle([x - 2, y0, x + 12, y0 + 2], fill=255)
        d.rectangle([x + 22, y0, x + 36, y0 + 2], fill=255)
        return 35
    if ch == "S":
        r, mid = 11, y0 + h // 2
        top = Image.new("L", d.im.size, 0)
        bot = Image.new("L", d.im.size, 0)
        dt, db = ImageDraw.Draw(top), ImageDraw.Draw(bot)
        dt.rounded_rectangle([x, y0, x + 28, mid + s // 2 - 1], radius=r, fill=255)
        dt.rounded_rectangle([x + s, y0 + s, x + 28 - s, mid - s // 2 - 1], radius=3, fill=0)
        dt.rectangle([x + 28 - s + 1, y0 + s, x + 28, mid + s // 2 - 1], fill=0)
        db.rounded_rectangle([x, mid - s // 2, x + 28, b], radius=r, fill=255)
        db.rounded_rectangle([x + s, mid + s // 2, x + 28 - s, b - s], radius=3, fill=0)
        db.rectangle([x, mid - s // 2, x + s - 1, b - s], fill=0)
        both = np.maximum(np.array(top), np.array(bot))
        cur = np.array(d.im).reshape(both.shape)
        d.bitmap((0, 0), Image.fromarray(np.where(both > cur, both, 0).astype(np.uint8)), fill=255)
        d.rectangle([x + 25, y0 + s, x + 28, y0 + s + 4], fill=255)
        d.rectangle([x, b - s - 4, x + 3, b - s], fill=255)
        return 29
    if ch == "I":
        d.rectangle([x + 4, y0, x + 4 + s - 1, b], fill=255)
        d.rectangle([x, y0, x + s + 7, y0 + 3], fill=255)
        d.rectangle([x, b - 3, x + s + 7, b], fill=255)
        return 16
    if ch == "A":
        d.polygon([(x, b), (x + 16, y0), (x + 26, y0), (x + 42, b), (x + 32, b), (x + 21, y0 + 11),
                   (x + 10, b)], fill=255)
        d.rectangle([x + 9, y0 + 25, x + 33, y0 + 25 + s - 2], fill=255)
        d.rectangle([x - 3, b - 2, x + 13, b], fill=255)
        d.rectangle([x + 29, b - 2, x + 45, b], fill=255)
        return 45
    raise ValueError(ch)


def logo_elysia():
    """ELYSIA as a classic fantasy RPG logo: gold serif capitals, a floating crystal above,
    gold filigree to both sides and twinkling stars, all mirror-symmetric."""
    W, H = 264, 76
    letter_h, stroke, gap = 40, 8, 7
    word = "ELYSIA"
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    # measure, then center
    probe = Image.new("L", (W * 2, H), 0)
    total = sum(draw_letter(ImageDraw.Draw(probe), ch, 10, 0, letter_h, stroke) for ch in word)
    total += gap * (len(word) - 1)
    x = (W - total) // 2
    y0 = 26
    for ch in word:
        x += draw_letter(d, ch, x, y0, letter_h, stroke) + gap
    mask = np.array(img) > 0
    rgba = gild(mask, y0, letter_h, GOLD)
    cx = W // 2
    # filigree: thin gold lines from the crystal outwards, ending in a curl and a leaf
    fil = Image.new("L", (W, H), 0)
    fd = ImageDraw.Draw(fil)
    for side in (-1, 1):
        x0, x1 = cx + side * 12, cx + side * 92
        fd.line([(x0, 14), (x1, 14)], fill=255, width=2)
        fd.line([(x1, 14), (x1 + side * 10, 20)], fill=255, width=2)
        fd.ellipse([x1 + side * 10 - 3, 18, x1 + side * 10 + 3, 24], outline=255, width=2)
        fd.polygon([(cx + side * 40, 13), (cx + side * 48, 8), (cx + side * 52, 13)], fill=255)
        fd.polygon([(cx + side * 62, 15), (cx + side * 70, 20), (cx + side * 74, 15)], fill=255)
    fmask = (np.array(fil) > 0) & (rgba[..., 3] == 0)
    rgba[fmask, :3] = (236, 186, 84)
    rgba[fmask, 3] = 255
    top_edge = fmask & ~np.roll(fmask, 1, 0)
    rgba[top_edge, :3] = (255, 236, 170)
    # the crystal: a cut diamond with a light left face and a bright glint
    yy, xx = np.mgrid[0:H, 0:W]
    gem = (np.abs(xx + 0.5 - cx) / 8.0 + np.abs(yy + 0.5 - 13) / 12.0) <= 1.0
    left = gem & (xx < cx)
    rgba[gem, :3] = (80, 170, 220)
    rgba[left, :3] = (150, 230, 250)
    rgba[gem & (yy > 15) & (xx >= cx), :3] = (40, 110, 170)
    rgba[gem & (np.abs(xx - (cx - 3)) <= 0) & (yy >= 6) & (yy <= 9), :3] = (240, 255, 255)
    rgba[gem, 3] = 255
    # four-point stars at the filigree ends
    for side in (-1, 1):
        sx, sy = cx + side * 112, 9
        for dy, dx in ((0, 0), (-1, 0), (1, 0), (0, -1), (0, 1), (-2, 0), (2, 0)):
            rgba[sy + dy, sx + dx, :3] = (255, 250, 220)
            rgba[sy + dy, sx + dx, 3] = 255
    return finish_logo(rgba, GOLD)


def logo_real():
    """The true title after the crossing (ADR-035): "NACH ELYSIA". The same serif capitals as
    Elysia's logo, but unvarnished (no gold, no filigree), a thin crack through the Y (the
    rift) and, where Elysia's crystal floated, a small seedling (Game Bible §29/30: the seed
    is the central symbol). The word above is small and plain, like a note on paper."""
    W, H = 264, 76
    letter_h, stroke, gap = 40, 8, 7
    word = "ELYSIA"
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    probe = Image.new("L", (W * 2, H), 0)
    total = sum(draw_letter(ImageDraw.Draw(probe), ch, 10, 0, letter_h, stroke) for ch in word)
    total += gap * (len(word) - 1)
    x = (W - total) // 2
    y0 = 28
    y_left = 0
    for ch in word:
        if ch == "Y":
            y_left = x
        x += draw_letter(d, ch, x, y0, letter_h, stroke) + gap
    mask = np.array(img) > 0
    yy, xx = np.mgrid[0:H, 0:W]
    # the crack: a jagged line down through the Y, from the fork to the foot
    rng = np.random.default_rng(4)
    crack = np.zeros_like(mask)
    cxk = y_left + 17.0
    for y in range(y0 - 2, y0 + letter_h + 2):
        cxk += rng.choice([-1, 0, 0, 1])
        crack[y, int(cxk)] = True
        crack[y, int(cxk) + 1] = True
    rgba = gild(mask, y0, letter_h, QUIET)
    c_in = crack & mask
    rgba[c_in, :3] = (58, 50, 52)
    glint = c_in & (yy > y0 + 14) & (yy < y0 + 30) & (np.roll(c_in, 1, 1))
    rgba[glint, :3] = (170, 200, 210)
    # "NACH" small and plain above the left half of the word
    font = ImageFont.truetype(os.path.join(ROOT, "assets", "fonts", "jersey15", "Jersey15-Regular.ttf"), 20)
    small = Image.new("L", (W, H), 0)
    ImageDraw.Draw(small).text(((W - total) // 2 + 1, 4), "NACH", font=font, fill=255)
    smask = (np.array(small) > 127) & (rgba[..., 3] == 0)
    rgba[smask, :3] = (214, 206, 192)
    rgba[smask, 3] = 255
    rgba[smask & ~np.roll(smask, 1, 0), :3] = (246, 242, 233)
    # the seedling where the crystal was: a short stem and two leaves
    cx = W // 2
    stem_c, leaf_c, leaf_l = (96, 128, 70), (110, 150, 74), (160, 196, 106)
    for y in range(13, 24):
        rgba[y, cx, :3] = stem_c
        rgba[y, cx, 3] = 255
    for dx, dy in ((-1, 0), (-2, 0), (-3, -1), (-4, -1), (-2, -1), (-3, -2)):
        rgba[15 + dy, cx + dx, :3] = leaf_c
        rgba[15 + dy, cx + dx, 3] = 255
    for dx, dy in ((1, 0), (2, -1), (3, -1), (4, -2), (2, -2), (3, -3), (5, -3)):
        rgba[13 + dy, cx + dx, :3] = leaf_c
        rgba[13 + dy, cx + dx, 3] = 255
    rgba[14, cx - 3, :3] = leaf_l
    rgba[11, cx + 3, :3] = leaf_l
    # a little earth around the stem's foot
    for dx in range(-3, 4):
        rgba[24, cx + dx, :3] = (92, 74, 58)
        rgba[24, cx + dx, 3] = 255
    return finish_logo(rgba, QUIET)


def valley(w=640, h=200, seed=21):
    """Evening valley for the REAL title: far hills in haze, a nearer hill with a small house
    and one lit window, and the meadow in front with grass, flowers and pebbles. The tree,
    bench, lantern and fence are separate sprites in the game (they move in the wind)."""
    rng = np.random.default_rng(seed)
    rgb = np.zeros((h, w, 3), np.float32)
    alpha = np.zeros((h, w), bool)
    xx = np.arange(w)
    b = pa.BAYER4[np.arange(h)[:, None] % 4, np.arange(w)[None, :] % 4]

    def ridge(base, amp, seed_):
        r = np.random.default_rng(seed_)
        y = np.full(w, float(base))
        for k in range(1, 5):
            y += amp / k * np.sin(xx / (90.0 / k) + r.uniform(0, 6.3))
        return y

    layers = [(ridge(62, 14, 1), (112, 104, 140)), (ridge(96, 12, 2), (78, 84, 104)),
              (ridge(132, 8, 3), None)]
    yy = np.arange(h)[:, None]
    for top, color in layers[:2]:
        m = yy >= top[None, :]
        rgb[m] = color
        alpha |= m
        # haze: lighter near the top edge, dithered
        near = m & (yy < top[None, :] + 6) & (b < 0.5)
        rgb[near] = np.array(color) * 1.12
    # the small house far off on the second hill, one warm window
    hx = 300
    hy = int(layers[1][0][hx]) - 9
    rgb[hy + 3:hy + 10, hx - 6:hx + 7] = (52, 48, 62)
    for k in range(4):
        rgb[hy + k, hx - k - 2:hx + k + 3] = (44, 38, 52)
    alpha[hy:hy + 10, hx - 6:hx + 7] = True
    rgb[hy + 5:hy + 7, hx + 1:hx + 3] = (255, 196, 110)
    # meadow
    top = layers[2][0]
    m = yy >= top[None, :]
    g = pa.value_noise(h, w, 9, rng, octaves=2)
    depth = np.clip((yy - top[None, :]) / (h - top[None, :]).clip(1), 0, 1)
    v = 0.7 + 0.25 * (g - 0.5) - 0.3 * depth
    rgb[m] = pa.shade(TAL["grass"], np.clip(v, 0, 1), dither=True, contrast=2.4)[m]
    alpha |= m
    rim = m & ~np.roll(m, 1, 0)
    rgb[rim] = TAL["grass"][-1]
    out = np.zeros((h, w, 4), np.float32)
    out[..., :3] = rgb
    out[..., 3] = np.where(alpha, 255, 0)
    canvas = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA")
    # scatter: tufts, wildflowers and pebbles, back to front
    scatter = []
    for _ in range(140):
        x = rng.uniform(4, w - 4)
        y = rng.uniform(top[int(x)] + 6, h - 2)
        kind = rng.choice(["grass_tuft_%d" % rng.integers(0, 5)] * 6 + ["wildflowers_%d" % rng.integers(0, 6)] * 2
                          + ["pebbles_%d" % rng.integers(0, 4)])
        scatter.append((y, x, kind))
    for y, x, kind in sorted(scatter):
        if os.path.exists(os.path.join(TAL_PROPS, kind + ".png")):
            sp = prop(kind, TAL_PROPS)
            canvas.alpha_composite(sp, (int(x - sp.width / 2), int(y - sp.height)))
    return canvas


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--preview")
    args = parser.parse_args()
    os.makedirs(OUT, exist_ok=True)
    isl, fall_at = island()
    isl.save(os.path.join(OUT, "island.png"))
    fall = waterfall()
    fall.save(os.path.join(OUT, "waterfall.png"))
    ely = logo_elysia()
    ely.save(os.path.join(OUT, "logo_elysia.png"))
    real = logo_real()
    real.save(os.path.join(OUT, "logo_real.png"))
    val = valley()
    val.save(os.path.join(OUT, "valley.png"))
    for stale in ("logo.png", "logo.png.import"):
        if os.path.exists(os.path.join(OUT, stale)):
            os.remove(os.path.join(OUT, stale))
    # TitleBackground.FALL_AT must match this
    print("island", isl.size, "waterfall at", fall_at, "logos", ely.size, real.size, "valley", val.size)
    if args.preview:
        sky = Image.new("RGBA", (640, 360), (150, 200, 240, 255))
        ix = (640 - isl.width) // 2
        sky.alpha_composite(isl, (ix, 44))
        sky.alpha_composite(fall, (ix + fall_at[0], 44 + fall_at[1]))
        sky.alpha_composite(fall, (ix + isl.width - fall_at[0] - fall.width, 44 + fall_at[1]))
        sky.alpha_composite(ely, ((640 - ely.width) // 2, 4))
        eve = Image.new("RGBA", (640, 360), (230, 160, 120, 255))
        eve.alpha_composite(val, (0, 360 - val.height))
        eve.alpha_composite(real, (30, 22))
        both = Image.new("RGBA", (640, 720))
        both.alpha_composite(sky, (0, 0))
        both.alpha_composite(eve, (0, 360))
        both.resize((1280, 1440), Image.NEAREST).save(args.preview)
