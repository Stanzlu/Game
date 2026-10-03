#!/usr/bin/env python3
"""Title screen art (ADR-017, own art, 0 €): a large floating island of Elysia with the
world tree, built from the prop sprites of make_sprites.py, and the REAL logo.

The island is drawn like the terraces of the Elysia map: grass plateau, a thick earth wall
with an overhanging grass cap, then rock that tapers into the sky with hanging roots, and
a waterfall falling off the edge. The logo has pixel letters with a gold rim and a thin
crack through the A (the rift; Game Bible §11).

Writes assets/generated/title/{island,waterfall,logo}.png.
Usage: .venv/bin/python tools/art/make_title.py [--preview out.png]
Needs the prop sprites (run make_sprites.py first).
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixelart as pa  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "title")
PROPS = os.path.join(ROOT, "assets", "generated", "props", "elysia")
ST = pa.STYLES["elysia"]


def prop(name):
    return Image.open(os.path.join(PROPS, name + ".png")).convert("RGBA")


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
    # the water leaves the plateau at its right front rim
    rim_x = 128
    rim_y = extra_top + top + plateau_h / 2 + plateau_h / 2 * np.sqrt(1 - (rim_x / (w * 0.49)) ** 2)
    return canvas, (int(cx + rim_x - 7), int(rim_y) - 4)


def logo():
    """REAL in pixel letters: cream to gold, dark outline, top-left highlight, drop shadow,
    and a thin crack through the A with a cyan glint."""
    W, H = 200, 64
    stroke, letter_h = 9, 44
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    x0, y0 = 10, 8
    gap = 8
    # R
    x = x0
    d.rectangle([x, y0, x + stroke - 1, y0 + letter_h - 1], fill=255)
    d.rounded_rectangle([x, y0, x + 34, y0 + 24], radius=11, fill=255)
    d.rounded_rectangle([x + stroke, y0 + stroke, x + 34 - stroke, y0 + 24 - stroke], radius=4, fill=0)
    d.polygon([(x + 14, y0 + 22), (x + 24, y0 + 22), (x + 38, y0 + letter_h - 1), (x + 28, y0 + letter_h - 1)], fill=255)
    # E
    x += 38 + gap
    d.rectangle([x, y0, x + stroke - 1, y0 + letter_h - 1], fill=255)
    d.rectangle([x, y0, x + 30, y0 + stroke - 1], fill=255)
    d.rectangle([x, y0 + letter_h // 2 - stroke // 2, x + 24, y0 + letter_h // 2 + stroke // 2], fill=255)
    d.rectangle([x, y0 + letter_h - stroke, x + 30, y0 + letter_h - 1], fill=255)
    # A
    x += 30 + gap
    a_left = x
    d.polygon([(x, y0 + letter_h - 1), (x + 17, y0), (x + 27, y0), (x + 44, y0 + letter_h - 1),
               (x + 34, y0 + letter_h - 1), (x + 22, y0 + 12), (x + 10, y0 + letter_h - 1)], fill=255)
    d.rectangle([x + 10, y0 + 27, x + 34, y0 + 27 + stroke - 2], fill=255)
    # L
    x += 44 + gap
    d.rectangle([x, y0, x + stroke - 1, y0 + letter_h - 1], fill=255)
    d.rectangle([x, y0 + letter_h - stroke, x + 30, y0 + letter_h - 1], fill=255)
    mask = np.array(img) > 0
    yy, xx = np.mgrid[0:H, 0:W]
    # crack through the A: a jagged line from top to bottom
    rng = np.random.default_rng(4)
    crack = np.zeros_like(mask)
    cxk = a_left + 21.0
    for y in range(y0 - 2, y0 + letter_h + 2):
        cxk += rng.choice([-1, 0, 0, 1])
        crack[y, int(cxk)] = True
        crack[y, int(cxk) + 1] = True
    out = np.zeros((H, W, 4), np.float32)
    # banded gradient cream -> gold
    t = np.clip((yy - y0) / letter_h, 0, 1)
    band = np.floor(t * 5) / 4
    top_c = np.array([255, 246, 220])
    bot_c = np.array([240, 176, 70])
    col = top_c * (1 - band[..., None]) + bot_c * band[..., None]
    out[mask, :3] = col[mask]
    out[mask, 3] = 255
    # highlight on top-left inner edges, darker on bottom-right edges
    up = mask & ~np.roll(mask, 1, 0)
    left = mask & ~np.roll(mask, 1, 1)
    down = mask & ~np.roll(mask, -1, 0)
    right = mask & ~np.roll(mask, -1, 1)
    out[up | left, :3] = (255, 255, 248)
    out[down | right, :3] = (196, 120, 40)
    # the crack: dark, with a cyan glint in the middle
    c_in = crack & mask
    out[c_in, :3] = (60, 30, 50)
    glint = c_in & (yy > y0 + 14) & (yy < y0 + 30) & (np.roll(c_in, 1, 1))
    out[glint, :3] = (150, 240, 255)
    # outline and drop shadow
    rgba = out.copy()
    pa.outline(rgba, (52, 24, 44))
    solid = rgba[..., 3] > 0
    shadow = np.roll(np.roll(solid, 3, 0), 1, 1) & ~solid
    rgba[shadow, :3] = (40, 20, 60)
    rgba[shadow, 3] = 150
    return Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--preview")
    args = parser.parse_args()
    os.makedirs(OUT, exist_ok=True)
    isl, fall_at = island()
    isl.save(os.path.join(OUT, "island.png"))
    fall = waterfall()
    fall.save(os.path.join(OUT, "waterfall.png"))
    lg = logo()
    lg.save(os.path.join(OUT, "logo.png"))
    # TitleBackground.FALL_AT must match this
    print("island", isl.size, "waterfall at", fall_at, "logo", lg.size)
    if args.preview:
        sky = Image.new("RGBA", (640, 360), (150, 200, 240, 255))
        sky.alpha_composite(isl, (300, 26))
        sky.alpha_composite(fall, (300 + fall_at[0], 26 + fall_at[1]))
        sky.alpha_composite(lg, (30, 30))
        sky.resize((1280, 720), Image.NEAREST).save(args.preview)
