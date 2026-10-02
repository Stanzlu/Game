#!/usr/bin/env python3
"""Procedural prop sprites for the look prototype (ADR-017).

Writes PNGs to assets/generated/props/<style>/ and one catalog.json that tells
world/props/decor.gd how to place each sprite: anchor (pixel that sits on the map cell
center), collision shape, wind sway, lights, footstep surface, variants and the ground
shadow that tools/art/bake_ground.py paints under every placed prop.

Usage: .venv/bin/python tools/art/make_sprites.py [--sheet scratch/sheet.png]
Deterministic: fixed seeds per sprite, so re-running produces identical files.
"""
import argparse
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixelart as pa  # noqa: E402
from pixelart import ramp  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "props")
RES = "res://assets/generated/props"

EXTRA = {
    "elysia": {
        "bark": ramp("#3d2422", "#62392b", "#8a5636", "#b07a48", "#d3a86a"),
        "white_wood": ramp("#5b5470", "#9a93a8", "#d2cdd4", "#f4f1ea", "#ffffff"),
        "iron": ramp("#1f1a2c", "#38304a", "#5a5070", "#857a96"),
        "glass": ramp("#c98a2e", "#ffd36e", "#fff2b8", "#fffbe8"),
        "blossom": ramp("#8f2f5f", "#c64f86", "#ee86b2", "#ffbfd8", "#fff0f6"),
        "lily": ramp("#123f2e", "#1f6a3a", "#3b9446", "#76c25a"),
        "cloud": ramp("#a3a9d6", "#c4cbec", "#e3e8f8", "#f8faff", "#ffffff"),
        "petals": [ramp("#9c1f5a", "#e04a8a", "#ff8fbf", "#ffd0e4"),
                   ramp("#b8610a", "#f0a020", "#ffd04a", "#fff0a0"),
                   ramp("#3b2f9a", "#6a5ce0", "#a99cff", "#e0dbff"),
                   ramp("#9a8aa8", "#d8d0e4", "#f6f2ff", "#ffffff")],
        "center": ramp("#7a3e10", "#c8781c", "#f2b33a", "#ffe58a"),
        "stem": ramp("#164a30", "#24703a", "#3f9a44", "#7cc653"),
    },
    "tal": {
        "bark": ramp("#16100e", "#251915", "#38261d", "#4f3727", "#664a33"),
        "plank": ramp("#1a1210", "#2b1d17", "#3f2b20", "#56402e", "#6e553d"),
        "roof": ramp("#141518", "#1f2126", "#2c2f36", "#3c4049", "#50555f"),
        "thatch": ramp("#1d1810", "#2f2618", "#453823", "#5d4c30", "#786440"),
        "stone_wall": ramp("#1a1c21", "#282b32", "#383c45", "#4b505b", "#616773"),
        "iron": ramp("#0d0e10", "#1a1c20", "#2a2d33", "#3d4148"),
        "glass": ramp("#a8601c", "#f0a040", "#ffd27a", "#fff1c4"),
        "stem": ramp("#101b14", "#1a2b1f", "#27402c", "#3a5739"),
        "hoop": ramp("#121316", "#22252b", "#353942", "#4a4f59"),
    },
}

CATALOG = {}


# --------------------------------------------------------------------------- canvas
class Canvas:
    """Small RGBA canvas. Shapes are boolean masks over the canvas grid."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.rgb = np.zeros((h, w, 3), np.float32)
        self.a = np.zeros((h, w), bool)
        self.yy, self.xx = np.mgrid[0:h, 0:w].astype(np.float32)

    def ellipse(self, cx, cy, rx, ry):
        return ((self.xx + 0.5 - cx) / rx) ** 2 + ((self.yy + 0.5 - cy) / ry) ** 2 <= 1.0

    def rect(self, x0, y0, x1, y1):
        return (self.xx >= x0) & (self.xx < x1) & (self.yy >= y0) & (self.yy < y1)

    def paint(self, mask, colors, value, contrast=2.5, dither=True):
        v = np.broadcast_to(np.asarray(value, np.float32), (self.h, self.w))
        c = pa.shade(colors, np.clip(v, 0, 1), dither=dither, contrast=contrast)
        self.rgb[mask] = c[mask]
        self.a |= mask

    def fill(self, mask, color):
        self.rgb[mask] = color
        self.a |= mask

    def sphere(self, cx, cy, rx, ry):
        nx = (self.xx + 0.5 - cx) / rx
        ny = (self.yy + 0.5 - cy) / ry
        nz = np.sqrt(np.clip(1 - nx * nx - ny * ny, 0, 1))
        return pa.sphere_light(nx, ny, nz)

    def cylinder(self, x0, x1):
        """Light across a vertical cylinder spanning x0..x1 (lit from the left)."""
        t = np.clip((self.xx + 0.5 - x0) / max(x1 - x0, 1), 0, 1) * 2 - 1
        nz = np.sqrt(np.clip(1 - t * t, 0, 1))
        return pa.sphere_light(t, np.zeros_like(t), nz)

    def outline(self, color, diagonal=False):
        rgba = self.rgba()
        pa.outline(rgba, color, diagonal=diagonal)
        self.rgb = rgba[..., :3]
        self.a = rgba[..., 3] > 0

    def inner_line(self, mask, color):
        """Dark contour where `mask` borders other opaque pixels (separates overlapping parts)."""
        edge = mask & ~(np.roll(mask, 1, 0) & np.roll(mask, -1, 0) & np.roll(mask, 1, 1)
                        & np.roll(mask, -1, 1))
        self.rgb[edge & self.a] = color

    def rgba(self):
        out = np.zeros((self.h, self.w, 4), np.float32)
        out[..., :3] = self.rgb
        out[..., 3] = self.a * 255.0
        return out

    def blit(self, other, ox, oy):
        sel = other.a
        ys, xs = np.nonzero(sel)
        ty, tx = ys + oy, xs + ox
        ok = (ty >= 0) & (ty < self.h) & (tx >= 0) & (tx < self.w)
        self.rgb[ty[ok], tx[ok]] = other.rgb[ys[ok], xs[ok]]
        self.a[ty[ok], tx[ok]] = True


def save(style, name, canvases, anchor, **entry):
    """Writes one or more variants and registers the catalog entry."""
    if not isinstance(canvases, list):
        canvases = [canvases]
    textures = []
    for i, c in enumerate(canvases):
        file_name = "%s%s.png" % (name, "" if len(canvases) == 1 else "_%d" % i)
        pa.save_rgba(os.path.join(OUT, style, file_name), c.rgba())
        textures.append("%s/%s/%s" % (RES, style, file_name))
    data = {"textures": textures, "anchor": list(anchor)}
    data.update({k: v for k, v in entry.items() if v is not None})
    CATALOG["%s/%s" % (style, name)] = data


# --------------------------------------------------------------------------- trees and plants
def crown_blobs(rng, cx, cy, rx, ry, count, rmin, rmax):
    blobs = []
    for _ in range(count):
        a = rng.uniform(0, 2 * np.pi)
        d = np.sqrt(rng.uniform(0, 1))
        blobs.append((cy + np.sin(a) * d * ry, cx + np.cos(a) * d * rx, rng.uniform(rmin, rmax)))
    # an outer ring makes the silhouette bumpy but round
    for k in range(10):
        a = k / 10 * 2 * np.pi + rng.uniform(-0.2, 0.2)
        blobs.append((cy + np.sin(a) * ry * 0.95, cx + np.cos(a) * rx * 0.95, rng.uniform(rmin, rmax) * 0.8))
    return blobs


def trunk(c, st, bark, x_mid, y_top, y_base, width, rng):
    t = c.rect(x_mid - width / 2, y_top, x_mid + width / 2, y_base)
    flare = c.ellipse(x_mid, y_base - 1.5, width / 2 + 3, 2.5)
    shape = t | flare
    grain = pa.value_noise(c.h, c.w, (6, 1), rng)
    c.paint(shape, bark, 0.15 + 0.7 * c.cylinder(x_mid - width / 2 - 2, x_mid + width / 2 + 2)
            + 0.15 * (grain - 0.5), contrast=2.0)
    return shape


def tree(style, seed, blossom=False):
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES[style], EXTRA[style]
    c = Canvas(64, 80)
    trunk(c, st, ex["bark"], 32, 40, 77, 8, rng)
    # two small branches into the crown
    blobs = crown_blobs(rng, 32, 30, 22, 17, 16, 7, 11)
    leaves = ex["blossom"] if blossom else st["foliage"]
    rgb, alpha, value = pa.render_blobs((c.h, c.w), blobs, leaves, rng, leaf_cell=4)
    c.paint(alpha, leaves, value, contrast=2.0)
    if style == "elysia" and not blossom:
        # a few blossoms / fruits catching the light
        for _ in range(9):
            y, x = int(rng.uniform(16, 40)), int(rng.uniform(14, 50))
            if alpha[y, x] and value[y, x] > 0.45:
                fl = EXTRA["elysia"]["petals"][rng.integers(0, 2)]
                c.fill(c.rect(x, y, x + 2, y + 2), fl[2])
                c.fill(c.rect(x, y, x + 1, y + 1), fl[3])
    c.outline(st["outline"])
    return c


def pine(style, seed):
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES[style], EXTRA[style]
    c = Canvas(40, 72)
    trunk(c, st, ex["bark"], 20, 52, 69, 5, rng)
    tiers = [(10, 7), (22, 11), (34, 15), (46, 18)]
    fol = st["foliage"]
    edge = pa.value_noise(c.h, c.w, (2, 2), rng)
    for i, (y_bottom, half) in enumerate(tiers):
        y_top = y_bottom - 16 if i else 1
        t = np.clip((c.yy - y_top) / max(y_bottom - y_top, 1), 0, 1)
        jag = (edge - 0.5) * 3
        tri = (np.abs(c.xx + 0.5 - 20) <= half * t + jag) & (c.yy >= y_top) & (c.yy <= y_bottom + (edge * 3).astype(int))
        light = 0.25 + 0.5 * c.cylinder(20 - half - 2, 20 + half + 2) + 0.2 * (1 - t)
        droop = (c.yy > y_bottom - 3) & tri
        c.paint(tri, fol, np.where(droop, light - 0.3, light), contrast=2.2)
    c.outline(st["outline"])
    return c


def giant_flower(seed, petals):
    rng = np.random.default_rng(seed)
    ex = EXTRA["elysia"]
    c = Canvas(32, 48)
    # stem with a slight curve and two leaves
    for y in range(18, 46):
        x = 16 + int(round(np.sin(y / 9.0) * 1.2))
        c.paint(c.rect(x - 1, y, x + 2, y + 1), ex["stem"], np.where(c.xx < x, 0.8, 0.45))
    for side, y0 in ((-1, 34), (1, 28)):
        leaf = c.ellipse(16 + side * 6, y0, 6, 2.6)
        c.paint(leaf, ex["stem"], 0.3 + 0.6 * c.sphere(16 + side * 6, y0 - 1, 6, 3))
    # petals around the head
    hx, hy = 16, 13
    n = 7
    for k in range(n):
        a = k / n * 2 * np.pi + 0.3
        px, py = hx + np.cos(a) * 7, hy + np.sin(a) * 5.5
        m = c.ellipse(px, py, 5.2, 4.2)
        c.paint(m, petals, 0.25 + 0.75 * c.sphere(px - 1, py - 1, 6, 5), contrast=2.2)
        c.inner_line(m, petals[0])
    disc = c.ellipse(hx, hy, 4.2, 3.6)
    c.paint(disc, ex["center"], 0.2 + 0.8 * c.sphere(hx - 1, hy - 1, 4.5, 4))
    for _ in range(5):
        x, y = int(rng.uniform(hx - 2, hx + 2)), int(rng.uniform(hy - 1, hy + 2))
        c.fill(c.rect(x, y, x + 1, y + 1), ex["center"][0])
    c.outline(pa.STYLES["elysia"]["outline"])
    return c


def topiary(seed):
    rng = np.random.default_rng(seed)
    st = pa.STYLES["elysia"]
    c = Canvas(30, 32)
    blobs = []
    for _ in range(26):
        a, d = rng.uniform(0, 2 * np.pi), np.sqrt(rng.uniform(0, 1)) * 9
        blobs.append((15 + np.sin(a) * d, 15 + np.cos(a) * d, rng.uniform(3, 4.5)))
    rgb, alpha, value = pa.render_blobs((c.h, c.w), blobs, st["foliage"], rng, leaf_cell=3,
                                        outline_rim=False)
    ball = c.ellipse(15, 15, 12, 12)
    body = alpha | ball
    light = c.sphere(15, 15, 12, 12)
    v = 0.1 + 0.75 * light + 0.25 * (value - 0.5)
    c.paint(body & c.ellipse(15, 15, 12.5, 12.5), st["foliage"], v, contrast=2.2)
    # tiny flowers sprinkled on the lit side
    for _ in range(6):
        y, x = int(rng.uniform(6, 18)), int(rng.uniform(6, 20))
        if c.a[y, x] and light[y, x] > 0.55:
            c.fill(c.rect(x, y, x + 1, y + 1), EXTRA["elysia"]["petals"][3][3])
    # short trunk below
    c.paint(c.rect(13, 26, 17, 31), EXTRA["elysia"]["bark"], c.cylinder(13, 17))
    c.outline(st["outline"])
    return c


def tall_grass(style, seed, w=18, h=20):
    rng = np.random.default_rng(seed)
    st = pa.STYLES[style]
    c = Canvas(w, h)
    blades = rng.integers(7, 11)
    for k in range(blades):
        x0 = w / 2 + rng.normal(0, 3)
        lean = rng.uniform(-0.35, 0.35)
        length = rng.uniform(9, h - 3)
        for t in np.linspace(0, 1, 24):
            y = h - 2 - t * length
            x = x0 + lean * t * length * 0.6 + lean * (t * t) * 4
            shade = 0.25 + 0.65 * t
            c.paint(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), st["grass"], shade, dither=False)
    c.outline(st["outline"])
    return c


def reeds(seed):
    rng = np.random.default_rng(seed)
    ex = EXTRA["elysia"]
    c = Canvas(16, 26)
    for k in range(6):
        x0 = 8 + rng.normal(0, 2.5)
        top = rng.uniform(3, 10)
        lean = rng.uniform(-0.2, 0.2)
        for y in range(int(top), 24):
            x = int(x0 + lean * (24 - y))
            c.paint(c.rect(x, y, x + 1, y + 1), ex["stem"], 0.3 + 0.5 * (24 - y) / 24, dither=False)
        if k % 2 == 0:
            x = int(x0 + lean * (24 - top))
            c.paint(c.rect(x - 1, int(top), x + 1, int(top) + 4), EXTRA["elysia"]["bark"],
                    np.where(c.xx < x, 0.8, 0.4))
    c.outline(pa.STYLES["elysia"]["outline"])
    return c


def lily_pad(seed, flower):
    rng = np.random.default_rng(seed)
    ex = EXTRA["elysia"]
    c = Canvas(14, 10)
    pad = c.ellipse(7, 5, 6.2, 4.0)
    notch = (np.abs(c.xx + 0.5 - 7 - (c.yy + 0.5 - 5) * 0.9) < 1.0) & (c.yy < 5)
    pad &= ~notch
    c.paint(pad, ex["lily"], 0.3 + 0.6 * c.sphere(6, 4, 7, 5))
    if flower:
        fl = ex["petals"][0]
        c.fill(c.rect(8, 3, 11, 5), fl[2])
        c.fill(c.rect(9, 2, 10, 3), fl[3])
        c.fill(c.rect(9, 3, 10, 4), ex["center"][3])
    c.outline(ex["lily"][0])
    return c


# --------------------------------------------------------------------------- stone and furniture
def rock(style, seed, w=26, h=20, moss=True):
    rng = np.random.default_rng(seed)
    st = pa.STYLES[style]
    c = Canvas(w, h)
    noise = pa.value_noise(h, w, 4, rng)
    body = c.ellipse(w / 2, h / 2 + 1.5, w / 2 - 1.5, h / 2 - 2) & ((noise - 0.5) * 6 + c.yy > 1)
    f1, f2, cid = pa.worley(h, w, 6, rng, 0.9)
    facet = ((cid * 7919) % 97) / 97.0
    light = c.sphere(w / 2 - 2, h / 2, w / 2, h / 2)
    v = 0.12 + 0.75 * light + 0.15 * (facet - 0.5)
    v = np.where(f2 - f1 < 0.9, v - 0.25, v)
    c.paint(body, st["rock"], v, contrast=2.2)
    if moss:
        top = body & (c.yy < h * 0.42 + (noise - 0.5) * 5)
        c.paint(top, st["grass"], 0.35 + 0.6 * light, contrast=2.0)
    c.outline(st["outline"])
    return c


def lantern(style):
    ex, st = EXTRA[style], pa.STYLES[style]
    c = Canvas(12, 40)
    c.paint(c.rect(5, 12, 7, 38), ex["iron"], np.where(c.xx < 6, 0.8, 0.3))
    c.paint(c.rect(3, 36, 9, 39), ex["iron"], 0.3)
    c.paint(c.rect(2, 4, 10, 6), ex["iron"], 0.6)
    glass = c.rect(3, 6, 9, 12)
    c.paint(glass, ex["glass"], 0.35 + 0.65 * c.sphere(5, 8, 5, 5), dither=False)
    c.paint(c.rect(5, 6, 7, 12), ex["iron"], 0.2)
    c.paint(c.rect(1, 2, 11, 4), ex["iron"], np.where(c.xx < 6, 0.7, 0.35))
    c.paint(c.rect(4, 0, 8, 2), ex["iron"], 0.5)
    c.paint(c.rect(2, 12, 10, 13), ex["iron"], 0.4)
    c.outline(st["outline"])
    return c


def fence(style, seed, vertical=False):
    rng = np.random.default_rng(seed)
    ex, st = EXTRA[style], pa.STYLES[style]
    wood = ex["white_wood"] if style == "elysia" else ex["plank"]
    if vertical:
        # north-south run: rails seen edge-on as one line going up, a post per cell
        c = Canvas(8, 30)
        c.paint(c.rect(3, 0, 5, 24), wood, np.where(c.xx < 4, 0.6, 0.3))
        c.paint(c.rect(1, 14, 7, 29), wood, np.where(c.xx < 3, 0.8, np.where(c.xx > 5, 0.25, 0.5)))
        c.paint(c.rect(2, 13, 6, 14), wood, 0.85)
        c.outline(st["outline"])
        return c
    c = Canvas(18, 18)
    tilt = rng.integers(-1, 2) if style == "tal" else 0
    for y0 in (5, 10):
        c.paint(c.rect(1, y0 + tilt * (c.xx > 9), 18, y0 + 2 + tilt * (c.xx > 9)), wood,
                np.where(c.yy == y0, 0.75, 0.45), contrast=3)
    c.paint(c.rect(1, 2, 5, 17), wood, np.where(c.xx < 3, 0.8, 0.4), contrast=3)
    c.paint(c.rect(2, 1, 4, 2), wood, 0.7)
    if style == "elysia":
        c.paint(c.rect(9, 3, 12, 15), wood, np.where(c.xx < 10, 0.85, 0.5), contrast=3)
        c.paint(c.rect(10, 2, 11, 3), wood, 0.85)
    c.outline(st["outline"])
    return c


def bench(style):
    ex, st = EXTRA[style], pa.STYLES[style]
    wood = st["wood"]
    c = Canvas(34, 24)
    for y0 in (2, 6):
        c.paint(c.rect(2, y0, 32, y0 + 3), wood, np.where(c.yy == y0, 0.8, 0.5), contrast=3)
    c.paint(c.rect(1, 12, 33, 16), wood, np.where(c.yy == 12, 0.85, 0.5), contrast=3)
    c.paint(c.rect(1, 16, 33, 17), wood, 0.15)
    for x0 in (4, 27):
        c.paint(c.rect(x0, 2, x0 + 3, 23), ex["iron"], np.where(c.xx == x0, 0.8, 0.35))
    c.outline(st["outline"])
    return c


def fountain():
    st, ex = pa.STYLES["elysia"], EXTRA["elysia"]
    c = Canvas(60, 52)
    cx = 30
    outer = c.ellipse(cx, 38, 28, 12)
    c.paint(outer, st["stone"], 0.25 + 0.65 * c.sphere(cx - 6, 34, 30, 14), contrast=2.2)
    wall = outer & (c.yy >= 38)
    c.paint(wall, st["stone"], 0.2 + 0.4 * c.cylinder(2, 58), contrast=2.2)
    water = c.ellipse(cx, 37, 24, 9)
    c.paint(water, st["water"], 0.45 + 0.4 * (1 - c.sphere(cx, 37, 24, 9)), contrast=2.0)
    ring = water & ~c.ellipse(cx, 37.5, 22, 7.5)
    c.paint(ring & (c.yy < 37), st["water"], 0.15)
    for x, y in ((18, 36), (40, 39), (27, 41), (35, 34)):
        c.fill(c.rect(x, y, x + 3, y + 1), st["water"][4])
    # pillar and top bowl
    c.paint(c.rect(27, 14, 33, 37), st["stone"], 0.15 + 0.8 * c.cylinder(26, 34), contrast=2.2)
    bowl = c.ellipse(cx, 14, 11, 4.5)
    c.paint(bowl, st["stone"], 0.3 + 0.6 * c.sphere(cx - 3, 12, 12, 6))
    c.paint(c.ellipse(cx, 13.5, 8, 2.5), st["water"], 0.7)
    c.paint(c.rect(29, 4, 31, 13), st["water"], 0.95, dither=False)
    c.fill(c.rect(29, 3, 31, 4), st["water"][4])
    # falling water curtains from the bowl rim
    for x in (20, 22, 38, 40):
        c.paint(c.rect(x, 16, x + 1, 33), st["water"], np.where((c.yy % 4) == 0, 0.95, 0.7), dither=False)
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- tal: house and props
def house():
    rng = np.random.default_rng(31)
    st, ex = pa.STYLES["tal"], EXTRA["tal"]
    W, H = 116, 116
    c = Canvas(W, H)
    wall_top, wall_bottom = 70, 113
    x0, x1 = 10, 106
    # wall: horizontal planks
    wall = c.rect(x0, wall_top, x1, wall_bottom)
    plank = ((c.yy - wall_top) // 5).astype(int)
    tone = ((plank * 2654435761) % 89) / 89.0
    grain = pa.value_noise(H, W, (1, 8), rng)
    v = 0.42 + 0.12 * (tone - 0.5) + 0.18 * (grain - 0.5)
    v = np.where(((c.yy - wall_top) % 5) == 4, 0.08, v)
    c.paint(wall, ex["plank"], v, contrast=2.0)
    # corner posts
    for px in (x0, x1 - 5, 56):
        if px == 56:
            continue
        c.paint(c.rect(px, wall_top, px + 5, wall_bottom), ex["plank"], np.where(c.xx == px, 0.85, 0.55))
    # stone foundation
    found = c.rect(x0 - 1, wall_bottom - 5, x1 + 1, wall_bottom + 3)
    f1, f2, cid = pa.worley(H, W, 5, rng)
    c.paint(found, ex["stone_wall"], np.where(f2 - f1 < 0.9, 0.1, 0.35 + 0.4 * pa.bump_light(np.clip(f2 - f1, 0, 3))))
    # roof: wet slate shingles seen from above, staggered rows, overhanging the wall
    roof = c.rect(2, 12, 114, wall_top + 4)
    roof &= ~((c.yy < 22) & ((c.xx < 2 + (22 - c.yy)) | (c.xx > 113 - (22 - c.yy))))
    yy, xx = c.yy.astype(int), c.xx.astype(int)
    row = (yy - 12) // 5
    ry = (yy - 12) % 5
    sx = (xx + (row % 2) * 3) % 6
    shingle = ((row * 7919 + (xx + (row % 2) * 3) // 6 * 104729) % 97) / 97.0
    rv = 0.62 - 0.38 * (yy - 12) / (wall_top - 12) + 0.16 * (shingle - 0.5)
    rv = np.where(ry == 0, rv + 0.12, rv)
    rv = np.where(sx == 5, rv - 0.25, rv)
    rv = np.where(ry == 4, 0.05, rv)
    c.paint(roof, ex["roof"], rv, contrast=2.2)
    wet = roof & (pa.value_noise(H, W, (1, 5), rng) > 0.86) & (ry == 1)
    c.paint(wet, ex["roof"], 0.95, dither=False)
    ridge = c.rect(4, 11, 112, 15)
    c.paint(ridge, ex["thatch"], np.where(c.yy <= 12, 0.8, 0.35))
    moss = roof & (pa.value_noise(H, W, 3, rng) > 0.86) & (c.yy > 24) & (c.yy < wall_top - 4)
    c.paint(moss, st["foliage"], 0.45)
    c.paint(c.rect(2, wall_top + 2, 114, wall_top + 4), ex["roof"], 0.3, dither=False)
    # chimney
    chim = c.rect(78, 0, 90, 26)
    c.paint(chim, ex["stone_wall"], np.where(f2 - f1 < 0.9, 0.1, 0.25 + 0.6 * c.cylinder(77, 91)))
    c.paint(c.rect(76, 0, 92, 3), ex["stone_wall"], 0.7)
    # door
    door = c.rect(49, 84, 65, wall_bottom)
    c.paint(door, st["wood"], np.where(((c.xx - 49) % 4) == 3, 0.1, 0.45 + 0.2 * (grain - 0.5)))
    c.paint(c.rect(47, 81, 67, 84), ex["plank"], 0.7)
    c.paint(c.rect(61, 97, 63, 99), ex["glass"], 0.9)
    # windows with warm light and cross frames
    for wx in (20, 80):
        frame = c.rect(wx - 1, 82, wx + 17, 99)
        c.paint(frame, ex["plank"], 0.75)
        pane = c.rect(wx + 1, 84, wx + 15, 97)
        c.paint(pane, ex["glass"], 0.45 + 0.55 * c.sphere(wx + 6, 88, 10, 9), dither=True)
        c.paint(c.rect(wx + 7, 84, wx + 9, 97), ex["plank"], 0.3)
        c.paint(c.rect(wx + 1, 90, wx + 15, 91), ex["plank"], 0.3)
        c.paint(c.rect(wx - 2, 99, wx + 18, 101), ex["plank"], 0.55)
        # flower box under the left window
        if wx == 20:
            c.paint(c.rect(wx, 101, wx + 16, 104), st["wood"], 0.35)
            for k in range(6):
                c.fill(c.rect(wx + 1 + k * 3, 99, wx + 3 + k * 3, 101), EXTRA["tal"]["stem"][2 + (k % 2)])
    # shadow of the eaves on the wall
    eave = c.rect(x0, wall_top + 6, x1, wall_top + 9) & c.a
    c.rgb[eave] *= 0.55
    c.outline(st["outline"])
    return c


def barrel(seed):
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], EXTRA["tal"]
    c = Canvas(16, 20)
    body = c.ellipse(8, 11, 7, 9) & c.rect(1, 3, 15, 19)
    staves = ((c.xx - 1) % 3) == 2
    c.paint(body, ex["plank"], np.where(staves, 0.15, 0.2 + 0.7 * c.cylinder(1, 15)), contrast=2.2)
    for y0 in (6, 15):
        c.paint(c.rect(1, y0, 15, y0 + 1) & body, ex["hoop"], 0.2 + 0.7 * c.cylinder(1, 15))
    top = c.ellipse(8, 4, 6.5, 2.5)
    c.paint(top, ex["plank"], 0.6)
    c.paint(c.ellipse(8, 4.3, 4.5, 1.6), st["water"], 0.4)
    c.outline(st["outline"])
    return c


def woodpile(seed):
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["tal"], EXTRA["tal"]
    c = Canvas(30, 20)
    logs = [(5, 15), (11, 15), (17, 15), (23, 15), (8, 10), (14, 10), (20, 10), (11, 5), (17, 5)]
    for x, y in logs:
        side = c.rect(x - 3, y - 3, x + 4, y + 3)
        c.paint(side, ex["bark"], 0.3)
        end = c.ellipse(x + 0.5, y, 3.2, 3.2)
        rings = np.hypot(c.xx + 0.5 - x - 0.5, c.yy + 0.5 - y)
        c.paint(end, st["wood"], np.where((rings.astype(int) % 2) == 0, 0.65, 0.5) + 0.2 * c.sphere(x - 1, y - 1, 4, 4) - 0.1)
        c.inner_line(end, st["wood"][0])
    c.outline(st["outline"])
    return c


# --------------------------------------------------------------------------- sky and particles
def cloud(seed, w, h):
    rng = np.random.default_rng(seed)
    ex = EXTRA["elysia"]
    c = Canvas(w, h)
    blobs = []
    for _ in range(int(w / 7)):
        x = rng.uniform(w * 0.15, w * 0.85)
        r = rng.uniform(h * 0.22, h * 0.42) * (1 - abs(x - w / 2) / w)
        blobs.append((h * 0.62 - rng.uniform(0, h * 0.25), x, r))
    for y, x, r in blobs:
        m = c.ellipse(x, y, r, r)
        c.paint(m, ex["cloud"], 0.3 + 0.75 * c.sphere(x - r * 0.3, y - r * 0.4, r * 1.2, r * 1.2), contrast=2.5)
    flat = c.yy > h * 0.72
    c.a &= ~flat
    base = c.rect(0, int(h * 0.62), w, int(h * 0.72)) & c.a
    c.rgb[base] = ex["cloud"][1]
    return c


def particles():
    out = os.path.join(OUT, "fx")
    os.makedirs(out, exist_ok=True)

    def px(name, rows, colors):
        h, w = len(rows), len(rows[0])
        img = np.zeros((h, w, 4), np.float32)
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    col, alpha = colors[ch]
                    img[y, x, :3] = pa.hex_rgb(col)
                    img[y, x, 3] = alpha
        pa.save_rgba(os.path.join(out, name + ".png"), img)

    px("raindrop", ["a", "a", "b", "b", "c"], {"a": ("#b9c8d6", 90), "b": ("#c9d6e2", 150), "c": ("#e2ecf4", 200)})
    px("splash", [".a.a.", "a...a", ".bbb."], {"a": ("#c9d6e2", 170), "b": ("#9fb2c4", 120)})
    px("ripple", [".aaa.", "a...a", ".aaa."], {"a": ("#9fb4c4", 140)})
    px("petal", ["ab", "bc"], {"a": ("#ffd0e4", 255), "b": ("#ff8fbf", 255), "c": ("#e04a8a", 255)})
    px("sparkle", [".a.", "aba", ".a."], {"a": ("#fff3c4", 160), "b": ("#ffffff", 255)})
    # two frames stacked vertically (wings open / folded), used with vframes = 2
    px("butterfly", ["aa.aa", "abcba", ".bcb.", ".a.a.", ".....", ".bcb.", ".aca.", "....."],
       {"a": ("#ff9a3c", 255), "b": ("#ffd36e", 255), "c": ("#3a2a1c", 255)})
    px("puff", [".aaa.", "abbba", "abcba", "abbba", ".aaa."],
       {"a": ("#c8ccd4", 110), "b": ("#d8dce2", 170), "c": ("#e8ebef", 220)})
    px("mote", ["a"], {"a": ("#ffffff", 200)})
    px("shadow_small", [".aaaaaaaa.", "aabbbbbbaa", "abbbbbbbba", "aabbbbbbaa", ".aaaaaaaa."],
       {"a": ("#1c1630", 50), "b": ("#1c1630", 95)})


# --------------------------------------------------------------------------- catalog
def build():
    for style in ("elysia", "tal"):
        os.makedirs(os.path.join(OUT, style), exist_ok=True)
    # elysia
    save("elysia", "tree", [tree("elysia", 1), tree("elysia", 2), tree("elysia", 3, blossom=True)],
         (32, 76), shape={"circle": 6, "offset": [0, -2]}, sway=1.0, shadow=[22, 7])
    save("elysia", "giant_flower", [giant_flower(10 + i, EXTRA["elysia"]["petals"][i]) for i in range(4)],
         (16, 45), shape={"circle": 4, "offset": [0, -1]}, sway=2.0, shadow=[9, 3])
    save("elysia", "topiary", [topiary(20), topiary(21)], (15, 29),
         shape={"circle": 9, "offset": [0, -4]}, shadow=[12, 4])
    save("elysia", "rock", [rock("elysia", 30), rock("elysia", 31, 22, 18)], (13, 16),
         shape={"rect": [18, 8], "offset": [0, -3]}, shadow=[12, 4])
    save("elysia", "lantern", lantern("elysia"), (6, 38), shape={"circle": 3, "offset": [0, -1]},
         shadow=[5, 2])
    save("elysia", "lily_pad", [lily_pad(40, False), lily_pad(41, True), lily_pad(42, False)], (7, 5),
         flat=True, bob=1.0)
    save("elysia", "reeds", [reeds(50), reeds(51)], (8, 23), sway=2.0)
    save("elysia", "fence", fence("elysia", 60), (9, 14), shape={"rect": [16, 4], "offset": [0, -1]})
    save("elysia", "bench", bench("elysia"), (10, 18))
    save("elysia", "fountain", fountain(), (30, 42), shape={"circle": 23, "offset": [0, -5]},
         shadow=[28, 6], sparkle=True, loop_sound="res://assets/generated/audio/water_loop.wav")
    save("elysia", "cloud", [cloud(70, 120, 46), cloud(71, 176, 60), cloud(72, 96, 38)], (0, 0))
    # tal
    save("tal", "house", house(), (58, 105), shape={"rect": [96, 40], "offset": [0, -12]},
         shadow=[52, 6], lights=[
             {"offset": [-30, -15], "color": "#ffb85c", "energy": 1.1, "range": 72},
             {"offset": [30, -15], "color": "#ffb85c", "energy": 1.1, "range": 72},
         ], smoke=[26, -102])
    save("tal", "tree", [tree("tal", 101), tree("tal", 102)], (32, 76),
         shape={"circle": 6, "offset": [0, -2]}, sway=1.0, shadow=[22, 7])
    save("tal", "pine", [pine("tal", 110), pine("tal", 111)], (20, 68),
         shape={"circle": 5, "offset": [0, -2]}, sway=0.8, shadow=[16, 5])
    save("tal", "rock", [rock("tal", 120), rock("tal", 121, 22, 18)], (13, 16),
         shape={"rect": [18, 8], "offset": [0, -3]}, shadow=[12, 4])
    save("tal", "tall_grass", [tall_grass("tal", 130 + i) for i in range(3)], (9, 18), sway=2.5,
         surface="tall_grass", rustle=True)
    save("tal", "lantern", lantern("tal"), (6, 38), shape={"circle": 3, "offset": [0, -1]},
         shadow=[5, 2], lights=[{"offset": [0, -29], "color": "#ffc070", "energy": 1.2, "range": 64}],
         flicker=True)
    save("tal", "barrel", barrel(140), (8, 18), shape={"circle": 6, "offset": [0, -2]}, shadow=[8, 3])
    save("tal", "woodpile", woodpile(141), (15, 18), shape={"rect": [26, 8], "offset": [0, -3]},
         shadow=[14, 3])
    save("tal", "fence", fence("tal", 150), (9, 14), shape={"rect": [16, 4], "offset": [0, -1]})
    save("tal", "fence_post", fence("tal", 151, vertical=True), (4, 22),
         shape={"rect": [4, 16], "offset": [0, -8]})
    save("tal", "bench", bench("tal"), (10, 18))
    particles()
    with open(os.path.join(OUT, "catalog.json"), "w", encoding="utf-8") as f:
        json.dump(CATALOG, f, indent=1, sort_keys=True)
        f.write("\n")


def contact_sheet(path):
    """All sprites on one sheet (for reviewing the look), 3x scale."""
    from PIL import Image
    tiles = []
    for key, entry in sorted(CATALOG.items()):
        for tex in entry["textures"]:
            tiles.append(Image.open(os.path.join(ROOT, tex[len("res://"):])))
    cols, pad = 8, 6
    cw = max(t.width for t in tiles) + pad
    chh = max(t.height for t in tiles) + pad
    rows = (len(tiles) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cw, rows * chh), (110, 150, 120, 255))
    for i, t in enumerate(tiles):
        sheet.alpha_composite(t, ((i % cols) * cw + pad // 2, (i // cols) * chh + pad // 2))
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--sheet", help="write a contact sheet PNG for review")
    args = ap.parse_args()
    build()
    print("wrote %d catalog entries to %s" % (len(CATALOG), os.path.relpath(OUT, ROOT)))
    if args.sheet:
        contact_sheet(args.sheet)
