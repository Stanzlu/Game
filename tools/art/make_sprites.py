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
import slice_props  # noqa: E402
from pixelart import ramp  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "props")
RES = "res://assets/generated/props"

EXTRA = {
    "elysia": {
        "bark": ramp("#2f1f2a", "#4d3036", "#71493f", "#966a4f", "#bd9168"),
        "white_wood": ramp("#5b5470", "#9a93a8", "#d2cdd4", "#f4f1ea", "#ffffff"),
        "iron": ramp("#1f1a2c", "#38304a", "#5a5070", "#857a96"),
        "glass": ramp("#c98a2e", "#ffd36e", "#fff2b8", "#fffbe8"),
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
        "bark": ramp("#1c1612", "#2e241d", "#45362a", "#5e4a39", "#7a624c"),
        "plank": ramp("#211915", "#352920", "#4c3b2d", "#66503d", "#82684f"),
        "roof": ramp("#1f2124", "#2e3135", "#41454b", "#575c63", "#71767d"),
        "thatch": ramp("#2a2316", "#403522", "#5a4b31", "#776441", "#968054"),
        "stone_wall": ramp("#25272a", "#36393d", "#4b4f54", "#63686e", "#80858b"),
        "iron": ramp("#141518", "#22252a", "#33373e", "#484d55"),
        "glass": ramp("#a8601c", "#f0a040", "#ffd27a", "#fff1c4"),
        "stem": ramp("#16241a", "#223523", "#304a2f", "#43623d"),
        "hoop": ramp("#1a1b1e", "#2a2c31", "#3d4048", "#53575f"),
    },
    "wald": {
        "bark": ramp("#0c0a12", "#17121d", "#241c2b", "#352a3d", "#4b3e53"),
        # birch bark in moonlight: almost white, with dark lenticel dashes
        "birch": ramp("#2e3238", "#5a6068", "#9aa2aa", "#d0d6dc", "#f0f4f6"),
        "stem": ramp("#0b1a1a", "#12302c", "#1d4a3c", "#2e6650"),
        "fern": ramp("#07120d", "#0d2018", "#153222", "#1f462f", "#2d5e3e"),
        # foxfire (bioluminescent fungi on rotten wood) glows a soft green
        "cap_cyan": ramp("#0e3a22", "#1b6a3c", "#3aa860", "#8ee0a0", "#e0ffe8"),
        # honey fungus clusters, honey-brown, no glow
        "cap_violet": ramp("#2a1a0e", "#4e3218", "#7a5226", "#a87a40", "#d4b07a"),
        # fly agaric: red cap with white spots, no glow
        "cap_pink": ramp("#3a0c0c", "#701812", "#a8261a", "#d84a34", "#fff4ea"),
        "moss": ramp("#0b1d14", "#12301e", "#1c462a", "#2a5e38"),
        "stalk": ramp("#3a3836", "#6a6662", "#a4a09a", "#dcd8d0"),
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


def save(style, name, canvases, anchor, emissive=None, **entry):
    """Writes one or more variants and registers the catalog entry.

    `emissive` (optional, one canvas per variant) holds only the pixels that glow; the game
    draws them above the night tint so they stay bright."""
    if not isinstance(canvases, list):
        canvases = [canvases]
    if emissive is not None and not isinstance(emissive, list):
        emissive = [emissive]
    textures, emit = [], []
    for i, c in enumerate(canvases):
        suffix = "" if len(canvases) == 1 else "_%d" % i
        file_name = "%s%s.png" % (name, suffix)
        pa.save_rgba(os.path.join(OUT, style, file_name), c.rgba())
        textures.append("%s/%s/%s" % (RES, style, file_name))
        if emissive is not None:
            emit_name = "%s_emit%s.png" % (name, suffix)
            pa.save_rgba(os.path.join(OUT, style, emit_name), emissive[i].rgba())
            emit.append("%s/%s/%s" % (RES, style, emit_name))
    data = {"textures": textures, "anchor": list(anchor)}
    if emit:
        data["emissive"] = emit
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


def tree(style, seed, leaves="foliage"):
    """Round tree: short trunk, crown of clustered leaf clumps (render_foliage)."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES[style], EXTRA[style]
    c = Canvas(64, 80)
    trunk(c, st, ex["bark"], 32, 42, 77, 8, rng)
    blobs = crown_blobs(rng, 32, 31, 21, 16, 12, 8, 12)
    alpha, value = pa.render_foliage((c.h, c.w), blobs, rng)
    ramp_colors = st[leaves] if leaves in st else ex[leaves]
    c.paint(alpha, ramp_colors, value, contrast=3.0, dither=False)
    if leaves == "blossom":
        for _ in range(26):
            y, x = int(rng.uniform(14, 44)), int(rng.uniform(12, 52))
            if alpha[y, x] and value[y, x] > 0.5:
                c.fill(c.rect(x, y, x + 1, y + 1), ramp_colors[-1])
    c.outline(st["outline"])
    return c


def natural_tree(style, seed, leaves="foliage", size="medium", canvas=None, crooked=0.0):
    """A less symmetric tree: leaning, tapering trunk with roots, branches forking into 3-5
    sub-crowns with gaps, so it reads as a real tree rather than a ball on a stick.

    `crooked` (0..1, the real world, Game Bible §12): the trunk leans hard and bows, one side
    of the crown is missing and a dead, bare branch sticks out on the other."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES[style], EXTRA[style]
    W, H, crown_r = {"small": (52, 66, 17), "medium": (68, 84, 23), "large": (88, 104, 29)}[size]
    if canvas is not None:
        W, H = canvas  # same canvas for all variants of an entry, so they share one anchor
    c = Canvas(W, H)
    cx, base = W / 2, H - 3
    bark = ex["bark"]
    lean = rng.uniform(-3, 3)
    bend, side = 0.0, 1.0
    if crooked:
        side = 1.0 if rng.random() < 0.5 else -1.0
        lean = side * (8.0 + 8.0 * crooked)
        bend = -side * (3.0 + 4.0 * crooked)
    fork_y = base - crown_r * 0.95
    crown_cy = fork_y - crown_r * 0.4
    # roots
    for side in (-1, 1):
        root = limb_mask(c, cx + side * 2, base - 5, cx + side * rng.uniform(6, 9), base, 4)
        c.paint(root, bark, 0.2 + 0.5 * c.cylinder(cx - 10, cx + 10), contrast=3.0, dither=False)
    # trunk, tapering and leaning
    tw = crown_r * 0.42
    trunk_m = np.zeros((H, W), bool)
    for y in range(int(fork_y), int(base)):
        t = (base - y) / max(base - fork_y, 1)
        x = cx + lean * t + bend * np.sin(np.pi * t)
        half = tw / 2 * (1 - 0.3 * t)
        trunk_m[y, int(round(x - half)):int(round(x + half)) + 1] = True
    grain = pa.value_noise(H, W, (6, 1), rng)
    c.paint(trunk_m, bark, 0.12 + 0.72 * c.cylinder(cx + lean / 2 - tw / 2 - 1, cx + lean / 2 + tw / 2 + 1)
            + 0.14 * (grain - 0.5), contrast=3.0, dither=False)
    # sub-crowns and the branches leading into them
    n_sub = rng.integers(3, 6)
    subs = []
    for k in range(n_sub):
        a = -np.pi / 2 + (k - (n_sub - 1) / 2) * 0.95 + rng.uniform(-0.2, 0.2)
        d = crown_r * rng.uniform(0.5, 0.8)
        sx, sy = cx + lean + np.cos(a) * d * 1.15, crown_cy + np.sin(a) * d * 0.75 + crown_r * 0.3
        subs.append((sy, sx, crown_r * rng.uniform(0.5, 0.68)))
        br = limb_mask(c, cx + lean, fork_y + 2, sx, sy + 2, max(2, tw * 0.6))
        c.paint(br, bark, 0.25 + 0.4 * c.cylinder(sx - 3, sx + 3), contrast=3.0, dither=False)
    subs.append((crown_cy - crown_r * 0.15, cx + lean, crown_r * 0.62))
    if crooked:
        # the crown thins out away from the lean: drop the outermost sub-crown on that side
        far = min(range(len(subs) - 1), key=lambda i: subs[i][1] * side)
        subs.pop(far)
        # a dead branch, bare and forked, reaching out against the lean
        y0 = fork_y + (base - fork_y) * 0.5
        x0 = cx + lean * 0.5 + bend
        x1, y1 = x0 - side * crown_r * 1.15, y0 - crown_r * 0.4
        dead = limb_mask(c, x0, y0, x1, y1, 3)
        dead |= limb_mask(c, x1 + side * crown_r * 0.3, y1 + crown_r * 0.1, x1 - side * 3, y1 - crown_r * 0.35, 2)
        c.paint(dead, bark, 0.3 + 0.35 * c.cylinder(min(x0, x1) - 2, max(x0, x1) + 2), contrast=3.0, dither=False)
    blobs = []
    for sy, sx, r in subs:
        for _ in range(4):
            blobs.append((sy + rng.uniform(-r * 0.3, r * 0.3), sx + rng.uniform(-r * 0.35, r * 0.35),
                          r * rng.uniform(0.62, 0.82)))
    alpha, value = pa.render_foliage((H, W), blobs, rng, small=(3.0, 5.0))
    colors = st[leaves] if leaves in st else ex[leaves]
    c.paint(alpha, colors, value, contrast=3.0, dither=False)
    if leaves == "blossom":
        for _ in range(30):
            y, x = int(rng.uniform(4, fork_y)), int(rng.uniform(4, W - 4))
            if alpha[y, x] and value[y, x] > 0.5:
                c.fill(c.rect(x, y, x + 1, y + 1), colors[-1])
    c.outline(st["outline"])
    return c


def bush(style, seed, leaves="foliage", w=26, h=22):
    rng = np.random.default_rng(seed)
    st = pa.STYLES[style]
    c = Canvas(w, h)
    blobs = [(h * 0.55, w * 0.5, w * 0.36), (h * 0.62, w * 0.3, w * 0.24), (h * 0.62, w * 0.7, w * 0.24),
             (h * 0.42, w * 0.45, w * 0.26)]
    alpha, value = pa.render_foliage((h, w), blobs, rng, small=(2.8, 4.2))
    c.paint(alpha, st[leaves], value, contrast=3.0, dither=False)
    c.outline(st["outline"])
    return c


def sacred_tree(seed=7):
    """Elysia's landmark: twisted dark trunk with roots, huge blossom crown, hanging wisteria."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["elysia"]
    W, H = 208, 190
    c = Canvas(W, H)
    cx, base = 104, 182
    bark = st["bark"]

    def strand(points, w0, w1, tone):
        pts = np.array(points, np.float32)
        n = 60
        for i in range(n + 1):
            t = i / n
            k = min(int(t * (len(pts) - 1)), len(pts) - 2)
            f = t * (len(pts) - 1) - k
            y, x = pts[k] * (1 - f) + pts[k + 1] * f
            r = (w0 + (w1 - w0) * t) / 2
            m = c.ellipse(x, y, r + 0.5, r * 0.8 + 0.5)
            c.paint(m, bark, tone + 0.55 * c.cylinder(x - r - 1, x + r + 1), contrast=3.0, dither=False)

    # roots spreading into the water, back ones first
    for side in (-1, 1):
        for k, (dx, dy, w) in enumerate(((58, -6, 7), (34, 2, 8), (76, 4, 5))):
            p0 = (base - 14, cx + side * 6)
            p1 = (base - 6 + dy * 0.3, cx + side * dx * 0.45)
            p2 = (base + dy * 0.5, cx + side * dx)
            strand([p0, p1, p2], w + 4, 3, 0.1 + 0.06 * k)
    # twisted trunk from three strands
    for i, phase in enumerate((0.0, 2.1, 4.2)):
        pts = []
        for t in np.linspace(0, 1, 7):
            y = base - 10 - t * 98
            x = cx + np.sin(t * 5.5 + phase) * 9 * (1 - t * 0.35) + (i - 1) * 7 * (1 - t * 0.5)
            pts.append((y, x))
        strand(pts, 17, 9, 0.12 + 0.08 * i)
    # branches into the crown
    for ex, ey in ((52, 58), (156, 58), (80, 44), (128, 44), (104, 36)):
        strand([(base - 104, cx), ((base - 104 + ey) / 2, (cx + ex) / 2 + rng.uniform(-6, 6)), (ey, ex)], 7, 3, 0.1)
    # blossom crown
    blobs = []
    # a filled core on a jittered grid (no holes), then a bumpy rim
    for gy in np.arange(30, 92, 14):
        for gx in np.arange(cx - 80, cx + 81, 16):
            if ((gx - cx) / 84) ** 2 + ((gy - 60) / 42) ** 2 <= 1.0:
                blobs.append((gy + rng.uniform(-4, 4), gx + rng.uniform(-5, 5), rng.uniform(14, 19)))
    for k in range(16):
        a = k / 16 * 2 * np.pi
        blobs.append((60 + np.sin(a) * 42, cx + np.cos(a) * 84, rng.uniform(11, 16)))
    alpha, value = pa.render_foliage((H, W), blobs, rng, small=(4.0, 6.5), density=1.2)
    c.paint(alpha, st["blossom"], value, contrast=3.0, dither=False)
    for _ in range(140):
        y, x = int(rng.uniform(16, 100)), int(rng.uniform(20, 188))
        if alpha[y, x] and value[y, x] > 0.55:
            c.fill(c.rect(x, y, x + 1, y + 1), st["blossom"][-1])
    # hanging wisteria strands below the crown edge
    bottom = np.full(W, -1)
    for x in range(W):
        ys = np.nonzero(alpha[:, x])[0]
        if len(ys):
            bottom[x] = ys.max()
    wis = st["wisteria"]
    for x in range(8, W - 8, 3):
        if bottom[x] < 0 or rng.random() < 0.2:
            continue
        side = abs(x - cx) / 100.0
        if rng.random() < 0.25:
            continue
        length = int(rng.uniform(6, 30) + 12 * side)
        y0 = bottom[x] - 6
        for k in range(0, length, 2):
            t = k / max(length, 1)
            wobble = int(round(np.sin(k * 0.6 + x) * 0.6))
            tone = 0.85 - 0.5 * t if k % 4 == 0 else 0.55 - 0.3 * t
            width = 2 if t < 0.6 else 1
            m = c.rect(x + wobble, y0 + k, x + wobble + width, y0 + k + 2)
            c.paint(m, wis, tone, dither=False)
    c.outline(st["outline"])
    return c


def marble_pillar(crystal=True):
    st = pa.STYLES["elysia"]
    c = Canvas(20, 48)
    m = st["marble"]
    c.paint(c.rect(4, 18, 16, 44), m, 0.15 + 0.85 * c.cylinder(3, 17), contrast=3.0, dither=False)
    c.paint(c.rect(4, 18, 16, 44) & ((c.xx.astype(int) % 4) == 1), m, 0.35, dither=False)
    c.paint(c.rect(2, 42, 18, 47), m, np.where(c.yy < 44, 0.85, 0.35), dither=False)
    c.paint(c.rect(2, 14, 18, 19), m, np.where(c.yy < 16, 0.95, 0.45), dither=False)
    if crystal:
        cr = st["crystal"]
        gem = (np.abs(c.xx + 0.5 - 10) * 1.4 + np.abs(c.yy + 0.5 - 8) * 0.8) <= 6.5
        left = c.xx < 10
        c.paint(gem, cr, np.where(left, 0.9, 0.45) + np.where(c.yy < 7, 0.1, -0.05), dither=False)
        c.fill(c.rect(8, 4, 9, 7), cr[-1])
    c.outline(st["outline"])
    return c


def crystal_pedestal():
    st = pa.STYLES["elysia"]
    c = Canvas(30, 50)
    m, cr = st["marble"], st["crystal"]
    c.paint(c.ellipse(15, 44, 14, 5), m, 0.25 + 0.7 * c.sphere(11, 42, 15, 6), dither=False)
    c.paint(c.rect(9, 30, 21, 44), m, 0.15 + 0.85 * c.cylinder(8, 22), contrast=3.0, dither=False)
    c.paint(c.ellipse(15, 30, 9, 3.5), m, 0.9, dither=False)
    gem = (np.abs(c.xx + 0.5 - 15) * 1.25 + np.abs(c.yy + 0.5 - 14) * 0.62) <= 9.5
    facet = np.where(c.xx < 15, 0.85, 0.4) + np.where(c.yy < 12, 0.12, -0.05)
    facet = np.where(np.abs(c.xx + 0.5 - 15) < 1.0, 1.0, facet)
    c.paint(gem, cr, facet, dither=False)
    c.fill(c.rect(12, 6, 13, 11), cr[-1])
    c.outline(st["outline"])
    return c


def foam(seed, w=24, h=12, style="elysia"):
    """White foam blob where a waterfall hits the water."""
    rng = np.random.default_rng(seed)
    c = Canvas(w, h)
    blobs = [(h * 0.55, w * 0.5, h * 0.42)] + [
        (h * 0.55 + rng.uniform(-1.5, 1.5), w * 0.5 + rng.uniform(-8, 8), rng.uniform(2.0, 3.5))
        for _ in range(7)
    ]
    for y, x, r in blobs:
        m = c.ellipse(x, y, r * 1.3, r * 0.8)
        c.paint(m, pa.STYLES[style]["water"], 0.7 + 0.3 * c.sphere(x - 1, y - 1, r * 1.3, r), dither=False)
    return c


def glow_flowers(seed):
    rng = np.random.default_rng(seed)
    st = pa.STYLES["elysia"]
    c = Canvas(18, 14)
    cr, vi = st["crystal"], st["flowers"][4]
    for k in range(4):
        x, y = int(rng.uniform(3, 14)), int(rng.uniform(4, 9))
        c.paint(c.rect(x, y + 1, x + 1, 13), EXTRA["elysia"]["stem"], 0.5, dither=False)
        col = cr if k % 2 == 0 else vi
        for dy, dx in ((0, -1), (0, 1), (-1, 0), (1, 0)):
            c.fill(c.rect(x + dx, y + dy, x + dx + 1, y + dy + 1), col[1])
        c.fill(c.rect(x, y, x + 1, y + 1), col[-1])
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


def reeds(seed, style="elysia"):
    rng = np.random.default_rng(seed)
    ex = dict(EXTRA["elysia"])
    if style != "elysia":
        ex["stem"] = pa.STYLES[style]["grass"][1:]
        ex["bark"] = pa.STYLES[style]["wood"]
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
            c.paint(c.rect(x - 1, int(top), x + 1, int(top) + 4), ex["bark"],
                    np.where(c.xx < x, 0.8, 0.4))
    c.outline(pa.STYLES[style]["outline"])
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


def fence_broken(seed, kind):
    """Tal fence that has seen weather (Game Bible §12): a rail hanging down from one nail,
    a leaning post with a split rail, or a post stump with its rail lying in the grass."""
    rng = np.random.default_rng(seed)
    ex, st = EXTRA["tal"], pa.STYLES["tal"]
    wood = ex["plank"]
    c = Canvas(18, 18)

    def rail(x0, y0, x1, y1, lit=0.6):
        m = limb_mask(c, x0, y0, x1, y1, 2)
        m |= limb_mask(c, x0, y0 + 1, x1, y1 + 1, 2)
        c.paint(m, wood, np.where(c.yy <= np.minimum(y0, y1) + 1, lit + 0.15, lit - 0.2), contrast=3)

    if kind == 0:
        # upper rail intact, lower rail torn off the far post and hanging into the grass
        c.paint(c.rect(1, 5, 18, 7), wood, np.where(c.yy == 5, 0.75, 0.45), contrast=3)
        rail(4, 11, 15, 16)
        c.paint(c.rect(1, 2, 5, 17), wood, np.where(c.xx < 3, 0.8, 0.4), contrast=3)
        c.paint(c.rect(2, 1, 4, 2), wood, 0.7)
    elif kind == 1:
        # the post leans over; the upper rail is split in the middle, the lower one sags
        for y in range(1, 17):
            dx = int(round((16 - y) * 0.22))
            c.paint(c.rect(1 + dx, y, 5 + dx, y + 1), wood, np.where(c.xx < 3 + dx, 0.8, 0.4), contrast=3)
        c.paint(c.rect(5, 5, 9, 7), wood, np.where(c.yy == 5, 0.75, 0.45), contrast=3)
        rail(11, 7, 18, 5)
        rail(4, 10, 18, 12, 0.5)
    else:
        # only a stump of the post is left; its rail lies diagonally in the grass
        c.paint(c.rect(1, 11, 5, 17), wood, np.where(c.xx < 3, 0.8, 0.4), contrast=3)
        c.paint(c.rect(1, 10, 2, 11), wood, 0.6)
        c.paint(c.rect(3, 10, 5, 11), wood, 0.7)
        rail(6, 14, 17, 16, 0.5)
        c.paint(c.rect(9, 5, 18, 7), wood, np.where(c.yy == 5, 0.7, 0.4), contrast=3)
    # a few dark knots and cracks
    for _ in range(3):
        y, x = int(rng.integers(2, 16)), int(rng.integers(2, 16))
        if c.a[y, x]:
            c.fill(c.rect(x, y, x + 1, y + 1), wood[0])
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
def house(lit=True):
    """The house in the valley. Unlit (slice: empty since spring) the windows are cold glass
    that only reflects the rainy sky, and the door lamp is out."""
    rng = np.random.default_rng(31)
    st, ex = pa.STYLES["tal"], EXTRA["tal"]
    glass = ex["glass"] if lit else ramp("#141a22", "#26323e", "#3e4e5c", "#6a7c88")
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
    c.paint(c.rect(61, 97, 63, 99), ex["glass"] if lit else ex["iron"], 0.9 if lit else 0.6)
    # windows with warm light and cross frames
    for wx in (20, 80):
        frame = c.rect(wx - 1, 82, wx + 17, 99)
        c.paint(frame, ex["plank"], 0.75)
        pane = c.rect(wx + 1, 84, wx + 15, 97)
        if lit:
            c.paint(pane, glass, 0.45 + 0.55 * c.sphere(wx + 6, 88, 10, 9), dither=True)
        else:  # a pale streak of sky across dark glass
            streak = ((c.xx - wx) + (c.yy - 84)) % 11 < 2
            c.paint(pane, glass, np.where(streak, 0.62, 0.18 + 0.2 * (c.yy - 84) / 13), dither=True)
        c.paint(c.rect(wx + 7, 84, wx + 9, 97), ex["plank"], 0.3)
        c.paint(c.rect(wx + 1, 90, wx + 15, 91), ex["plank"], 0.3)
        c.paint(c.rect(wx - 2, 99, wx + 18, 101), ex["plank"], 0.55)
        # flower box under the left window
        if wx == 20:
            c.paint(c.rect(wx, 101, wx + 16, 104), st["wood"], 0.35)
            for k in range(6):
                c.fill(c.rect(wx + 1 + k * 3, 99, wx + 3 + k * 3, 101), EXTRA["tal"]["stem"][2 + (k % 2)])
    # shutters beside the windows (vertical slats), a gutter under the eaves
    shutter = ramp("#14201e", "#1e3430", "#2c4a44", "#3e625a")
    for wx in (20, 80):
        for sx in (wx - 5, wx + 17):
            sm = c.rect(sx, 83, sx + 4, 98)
            c.paint(sm, shutter, np.where(((c.xx - sx) % 2) == 0, 0.65, 0.35), dither=False)
    c.paint(c.rect(2, wall_top + 4, 114, wall_top + 5), ex["iron"], 0.55, dither=False)
    c.paint(c.rect(104, wall_top + 4, 106, wall_bottom - 2), ex["iron"], np.where(c.xx < 105, 0.6, 0.3),
            dither=False)
    # stone door step and a small lamp beside the door
    c.paint(c.rect(46, wall_bottom - 1, 68, wall_bottom + 2), ex["stone_wall"], np.where(c.yy < wall_bottom, 0.8, 0.45),
            dither=False)
    c.paint(c.rect(68, 86, 72, 88), ex["iron"], 0.4, dither=False)
    c.paint(c.rect(69, 88, 72, 93), glass, 0.9 if lit else 0.35, dither=False)
    c.paint(c.rect(68, 93, 73, 94), ex["iron"], 0.4, dither=False)
    # moss creeping up the foundation, weathered planks
    moss = c.rect(x0 - 1, wall_bottom - 7, x1 + 1, wall_bottom + 3) & (pa.value_noise(H, W, 2, rng) > 0.62) & c.a
    c.paint(moss, st["foliage"], 0.55, dither=False)
    stain = wall & (pa.value_noise(H, W, (6, 2), rng) > 0.72)
    c.rgb[stain] *= 0.82
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


# --------------------------------------------------------------------------- wald (night forest)
def emissive_of(c, mask):
    """Canvas with only the masked (glowing) pixels of c."""
    e = Canvas(c.w, c.h)
    e.rgb[mask] = c.rgb[mask]
    e.a = mask & c.a
    return e


def forest_tree(seed, glow=False):
    """Old forest tree: thick dark trunk with roots, wide canopy. The `glow` variant is a
    birch: slim white trunk with dark dashes and a light, airy crown that catches the
    moonlight (what really shines in a forest at night)."""
    if glow:
        return birch(seed)
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["wald"], EXTRA["wald"]
    W, H = 88, 112
    c = Canvas(W, H)
    cx, base = 44, 108
    bark = st["bark"]
    for side in (-1, 1):
        root = limb_mask(c, cx + side * 3, base - 10, cx + side * 15, base - 1, 5)
        c.paint(root, bark, 0.15 + 0.6 * c.cylinder(cx - 18, cx + 18), contrast=3.0, dither=False)
    trunk_m = c.rect(cx - 7, 46, cx + 7, base - 2) | c.ellipse(cx, base - 4, 10, 4)
    grain = pa.value_noise(H, W, (8, 1), rng)
    c.paint(trunk_m, bark, 0.12 + 0.72 * c.cylinder(cx - 8, cx + 8) + 0.15 * (grain - 0.5), contrast=3.0,
            dither=False)
    moss = trunk_m & (pa.value_noise(H, W, 4, rng) > 0.7) & (c.xx < cx)
    c.paint(moss, ex["moss"], 0.6, dither=False)
    blobs = crown_blobs(rng, cx, 38, 38, 26, 16, 11, 16)
    alpha, value = pa.render_foliage((H, W), blobs, rng, small=(4.0, 6.0))
    leaves = st["foliage_blue"] if glow else st["foliage"]
    c.paint(alpha, leaves, value * (0.9 if glow else 1.0), contrast=3.0, dither=False)
    emit = None
    if glow:
        lit = alpha & (value > 0.6)
        tips = alpha & (pa.value_noise(H, W, 3, rng) > 0.78)
        c.paint(tips, leaves, 0.95, dither=False)
        emit_mask = lit | tips
    c.outline(st["outline"])
    if glow:
        emit = emissive_of(c, emit_mask)
    return c, emit


def birch(seed):
    """A birch at night: slim, slightly leaning white trunk with black lenticel dashes and
    a light crown. The moonlit bark and leaf tips are emissive, softly (no fantasy glow)."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["wald"], EXTRA["wald"]
    W, H = 88, 112
    c = Canvas(W, H)
    cx, base = 44, 108
    lean = rng.uniform(-0.12, 0.12)
    xs = c.xx + 0.5 - (cx + lean * (base - c.yy))
    trunk_m = (np.abs(xs) <= 3.6 - (base - c.yy) * 0.012) & (c.yy >= 30) & (c.yy < base)
    trunk_m |= c.ellipse(cx, base - 2, 6, 2.5)
    c.paint(trunk_m, ex["birch"], 0.25 + 0.75 * np.clip(0.5 - xs / 8.0, 0, 1), contrast=2.6, dither=False)
    dashes = trunk_m & (pa.value_noise(H, W, (1, 4), rng) > 0.72) & ((c.yy % 5) < 2)
    c.paint(dashes, st["bark"], 0.2, dither=False)
    base_dark = trunk_m & (c.yy > base - 12) & (pa.value_noise(H, W, 2, rng) > 0.45)
    c.paint(base_dark, st["bark"], 0.35, dither=False)
    # thin branches into the crown
    for side, y in ((-1, 44), (1, 52), (-1, 60), (1, 38)):
        br = limb_mask(c, cx + lean * (base - y), y, cx + side * rng.uniform(12, 18), y - 10, 2)
        c.paint(br, ex["birch"], 0.55, dither=False)
    blobs = crown_blobs(rng, cx, 36, 30, 24, 14, 8, 12)
    alpha, value = pa.render_foliage((H, W), blobs, rng, small=(3.0, 4.5))
    alpha &= pa.value_noise(H, W, 3, rng) > 0.22  # airy: the sky shows through
    c.paint(alpha, st["foliage_blue"], value, contrast=3.0, dither=False)
    c.outline(st["outline"])
    moonlit = (trunk_m & (xs < 0.5) & ~dashes) | (alpha & (value > 0.93))
    return c, emissive_of(c, moonlit)


def mossy_rock(seed, w=30, h=22):
    """A boulder under a thick cushion of moss, a few dew drops catching the moon."""
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["wald"], EXTRA["wald"]
    c = rock("wald", seed, w, h)
    body = c.a > 0
    top = body & (c.yy < h * 0.62) & (pa.value_noise(h, w, 4, rng) > 0.32)
    c.paint(top, ex["moss"], 0.35 + 0.6 * c.sphere(w * 0.4, h * 0.3, w * 0.5, h * 0.4), dither=False)
    dew = top & (pa.value_noise(h, w, 1.2, rng) > 0.86)
    c.fill(dew, np.array([200, 220, 236], np.float32))
    c.outline(st["outline"])
    return c


def limb_mask(c, x0, y0, x1, y1, width):
    m = np.zeros((c.h, c.w), bool)
    steps = max(int(abs(y1 - y0)), int(abs(x1 - x0)), 1)
    for i in range(steps + 1):
        t = i / steps
        x, y = x0 + (x1 - x0) * t, int(round(y0 + (y1 - y0) * t))
        w = width * (1 - 0.5 * t)
        xa = int(round(x - w / 2))
        if 0 <= y < c.h:
            m[y, max(xa, 0):max(xa + int(round(w)), 0)] = True
    return m


def mushrooms(seed, cap):
    rng = np.random.default_rng(seed)
    ex = EXTRA["wald"]
    c = Canvas(24, 20)
    caps = np.zeros((20, 24), bool)
    spots = [(12, 9, 5.5, 3.2), (6, 13, 3.5, 2.2), (18, 14, 3.2, 2.0), (9, 16, 2.4, 1.5)]
    for x, y, rx, ry in spots[:rng.integers(3, 5)]:
        stem = c.rect(x - 1, y, x + 1, 19)
        c.paint(stem, ex["stalk"], np.where(c.xx < x, 0.85, 0.5), dither=False)
        m = c.ellipse(x, y, rx, ry) & (c.yy <= y + 0.5)
        c.paint(m, ex[cap], 0.35 + 0.65 * c.sphere(x - 1, y - 1, rx + 1, ry + 1), dither=False)
        dots = m & (pa.value_noise(20, 24, 1.5, rng) > 0.78)
        c.paint(dots, ex[cap], 1.0, dither=False)
        caps |= m
    c.outline(pa.STYLES["wald"]["outline"])
    return c, emissive_of(c, caps)


def crystal_cluster(seed):
    rng = np.random.default_rng(seed)
    st = pa.STYLES["wald"]
    c = Canvas(30, 30)
    rock = c.ellipse(15, 24, 13, 6)
    c.paint(rock, st["rock"], 0.2 + 0.6 * c.sphere(11, 22, 14, 7), dither=False)
    glow = np.zeros((30, 30), bool)
    for k in range(rng.integers(3, 6)):
        bx = rng.uniform(7, 23)
        h = rng.uniform(9, 19)
        w = rng.uniform(2.5, 4.0)
        lean = rng.uniform(-0.35, 0.35)
        yb = 24
        xs = c.xx + 0.5 - (bx + lean * (yb - c.yy))
        body = (np.abs(xs) <= w * np.clip((c.yy - (yb - h)) / 3.0, 0, 1)) & (c.yy <= yb) & (c.yy >= yb - h)
        face = np.where(xs < 0, 0.85, 0.45) + np.where(np.abs(xs) < 0.6, 0.15, 0)
        c.paint(body, st["crystal"], face, dither=False)
        glow |= body
    c.outline(st["outline"])
    return c, emissive_of(c, glow)


def fern(seed):
    rng = np.random.default_rng(seed)
    ex = EXTRA["wald"]
    c = Canvas(26, 18)
    for k in range(7):
        a = np.pi * (0.15 + 0.7 * k / 6) + rng.uniform(-0.1, 0.1)
        length = rng.uniform(9, 13)
        for t in np.linspace(0, 1, 26):
            x = 13 - np.cos(a) * length * t
            y = 17 - np.sin(a) * length * t + (t * t) * 4
            leaf = 2.2 * (1 - t) + 0.6
            m = c.ellipse(x, y, leaf, 0.9)
            c.paint(m, ex["fern"], 0.35 + 0.55 * t, dither=False)
    c.outline(pa.STYLES["wald"]["outline"])
    return c


def fallen_log(seed):
    rng = np.random.default_rng(seed)
    st, ex = pa.STYLES["wald"], EXTRA["wald"]
    c = Canvas(48, 18)
    body = c.rect(4, 4, 44, 15)
    v = 0.15 + 0.75 * (1 - np.abs((c.yy - 9.5) / 6.0)) * np.where(c.yy < 9, 1.0, 0.7)
    c.paint(body, st["bark"], v + 0.1 * (pa.value_noise(18, 48, (1, 6), rng) - 0.5), dither=False)
    end = c.ellipse(44, 9.5, 3.5, 5.5)
    rings = (np.hypot(c.xx + 0.5 - 44, (c.yy + 0.5 - 9.5) * 0.65).astype(int) % 2) == 0
    c.paint(end, st["wood"], np.where(rings, 0.6, 0.45), dither=False)
    moss = body & (c.yy < 8) & (pa.value_noise(18, 48, 3, rng) > 0.45)
    c.paint(moss, ex["moss"], 0.7, dither=False)
    c.outline(st["outline"])
    return c


def light_beam(w=96, h=220):
    """Soft vertical light shaft for a clearing (additive). Stripes keep it pixel-like."""
    rng = np.random.default_rng(5)
    c = Canvas(w, h)
    t = c.yy / h
    half = (w * 0.26) + t * (w * 0.2)
    x = np.abs(c.xx + 0.5 - w / 2)
    inside = x <= half
    stripes = np.zeros(w)
    for _ in range(9):
        cx = rng.uniform(w * 0.2, w * 0.8)
        sw = rng.uniform(2, 7)
        stripes += np.exp(-((np.arange(w) - cx) / sw) ** 2) * rng.uniform(0.4, 1.0)
    a = np.clip(stripes[None, :] * 0.55 + 0.25, 0, 1) * np.clip(1 - x / np.maximum(half, 1), 0, 1) ** 0.6
    a *= np.clip(t * 4, 0, 1) * np.clip((1 - t) * 3, 0, 1)
    a = np.floor(a * 5) / 5  # banded alpha: reads as pixel art, not a smooth gradient
    col = pa.hex_rgb("#d0def4")  # moonlight
    c.rgb[:] = col
    c.a = inside & (a > 0)
    rgba = c.rgba()
    rgba[..., 3] = np.where(c.a, a * 150, 0)
    return rgba


# --------------------------------------------------------------------------- small scatter details
def grass_tuft(style, seed, w=14, h=13):
    """A natural bunch of blades: darker roots, lighter curved tips, no hard outline."""
    rng = np.random.default_rng(seed)
    g = pa.STYLES[style]["grass"]
    c = Canvas(w, h)
    for _ in range(rng.integers(6, 11)):
        x0 = w / 2 + rng.normal(0, 2.2)
        length = rng.uniform(4, h - 2)
        lean = rng.uniform(-0.5, 0.5)
        for t in np.linspace(0, 1, 16):
            y = h - 1 - t * length
            x = x0 + lean * t * length * 0.5 + lean * t * t * 2.5
            tone = 0.25 + 0.7 * t if rng.random() > 0.1 else 0.95
            c.paint(c.rect(int(x), int(y), int(x) + 1, int(y) + 1), g, tone, dither=False)
    roots = c.a & (c.yy >= h - 2)
    c.rgb[roots] = g[0]
    return c


def wildflowers(style, seed, w=12, h=12):
    rng = np.random.default_rng(seed)
    st = pa.STYLES[style]
    c = Canvas(w, h)
    fl = st["flowers"][rng.integers(len(st["flowers"]))]
    for _ in range(rng.integers(2, 5)):
        x = int(rng.uniform(2, w - 2))
        top = int(rng.uniform(2, h - 5))
        c.paint(c.rect(x, top + 1, x + 1, h), st["grass"], 0.45, dither=False)
        if rng.random() < 0.5:
            c.paint(c.rect(x + 1, top + 4, x + 2, top + 5), st["grass"], 0.7, dither=False)
        for dy, dx, i in ((0, 0, 2), (-1, 0, 1), (0, -1, 1), (0, 1, 0), (1, 0, 0)):
            if 0 <= top + dy < h and 0 <= x + dx < w:
                c.fill(c.rect(x + dx, top + dy, x + dx + 1, top + dy + 1), fl[i])
    return c


PEBBLE = {
    "elysia": ramp("#4e4a4e", "#7a746e", "#a8a094", "#d4ccbe"),
    "tal": ramp("#2a2b2c", "#3f4042", "#58595c", "#76777a"),
    "wald": ramp("#111020", "#1d1b30", "#2c2a44", "#423f5c"),
}


def pebbles(style, seed, w=10, h=6):
    rng = np.random.default_rng(seed)
    rk = PEBBLE[style]
    c = Canvas(w, h)
    for _ in range(rng.integers(1, 4)):
        x, y = rng.uniform(2, w - 2), rng.uniform(2, h - 2)
        rx, ry = rng.uniform(1.2, 2.4), rng.uniform(0.9, 1.5)
        m = c.ellipse(x, y, rx, ry)
        c.paint(m, rk, 0.3 + 0.65 * c.sphere(x - 0.7, y - 0.7, rx + 0.5, ry + 0.5), dither=False)
    c.outline(rk[0])
    return c


def twig(style, seed, w=12, h=6):
    rng = np.random.default_rng(seed)
    wood = pa.STYLES[style]["wood"]
    c = Canvas(w, h)
    y = rng.uniform(2, 4)
    slope = rng.uniform(-0.25, 0.25)
    for x in range(1, w - 1):
        yy = int(round(y + slope * (x - w / 2)))
        c.fill(c.rect(x, yy, x + 1, yy + 1), wood[2 if x % 3 else 3])
        c.fill(c.rect(x, yy + 1, x + 1, yy + 2), wood[0])
    bx = int(rng.uniform(4, w - 4))
    c.fill(c.rect(bx, int(y) - 1, bx + 1, int(y)), wood[2])
    return c


def small_mushrooms(style, seed, w=10, h=9):
    rng = np.random.default_rng(seed)
    st = pa.STYLES[style]
    caps = [ramp("#5a2a1e", "#8e4128", "#c26a3c", "#e8a070"), ramp("#4a3a2a", "#7a6040", "#a88a5c", "#d4ba8a")]
    cap = caps[rng.integers(len(caps))]
    if style == "tal":
        cap = cap * 0.92
    c = Canvas(w, h)
    for x, y, r in ((4, 4, 2.6), (7, 6, 1.8)):
        c.paint(c.rect(x - 0.5, y, x + 0.5, h - 1), EXTRA["wald"]["stalk"], 0.7, dither=False)
        m = c.ellipse(x, y, r, r * 0.65) & (c.yy <= y + 0.5)
        c.paint(m, cap, 0.3 + 0.7 * c.sphere(x - 0.6, y - 0.6, r + 0.5, r), dither=False)
    c.outline(st["outline"])
    return c


def fallen_leaves(style, seed, w=12, h=7):
    rng = np.random.default_rng(seed)
    colors = [ramp("#6a3a1a", "#a85a22", "#d8873a"), ramp("#6a5014", "#a8822a", "#d8b44a"),
              ramp("#5a2418", "#8a3a22", "#b85a34")]
    c = Canvas(w, h)
    for _ in range(rng.integers(3, 7)):
        col = colors[rng.integers(len(colors))]
        if style != "elysia":
            col = col * 0.75
        x, y = int(rng.uniform(1, w - 2)), int(rng.uniform(1, h - 2))
        c.fill(c.rect(x, y, x + 2, y + 1), col[1])
        c.fill(c.rect(x, y, x + 1, y + 1), col[2])
        c.fill(c.rect(x + 1, y + 1, x + 2, y + 2), col[0])
    return c


def bridge_rail(style):
    """One cell of bridge railing: a post on the left and two rails across (tiles side by side)."""
    st = pa.STYLES[style]
    wood = st["wood"]
    c = Canvas(18, 12)
    for y0 in (1, 5):
        c.paint(c.rect(1, y0, 18, y0 + 2), wood, np.where(c.yy == y0, 0.8, 0.45), dither=False)
    c.paint(c.rect(1, 0, 4, 12), wood, np.where(c.xx < 2, 0.85, np.where(c.xx > 2, 0.3, 0.55)), dither=False)
    c.outline(st["outline"])
    return c


def fog_bank(seed, w=180, h=44):
    """Soft ground fog in a few alpha bands (stays pixel art). Tinted by the scene."""
    rng = np.random.default_rng(seed)
    out = np.zeros((h, w, 4), np.float32)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    density = np.zeros((h, w), np.float32)
    for _ in range(9):
        cx, cy = rng.uniform(w * 0.15, w * 0.85), rng.uniform(h * 0.35, h * 0.65)
        rx, ry = rng.uniform(w * 0.12, w * 0.25), rng.uniform(h * 0.2, h * 0.32)
        density += np.clip(1 - ((xx - cx) / rx) ** 2 - ((yy - cy) / ry) ** 2, 0, 1)
    density = np.clip(density, 0, 1)
    bands = np.floor(density * 4) / 4
    b = pa.BAYER4[np.arange(h)[:, None] % 4, np.arange(w)[None, :] % 4]
    edge = (density * 4 - np.floor(density * 4)) > b
    bands = np.where(edge, bands + 0.25, bands)
    out[..., :3] = 255
    out[..., 3] = np.clip(bands, 0, 1) * 255
    return out


def floating_islet(seed, w=56, h=52):
    """Small floating island for the sky: grass cap, tapering mauve rock, hanging roots."""
    rng = np.random.default_rng(seed)
    st = pa.STYLES["elysia"]
    c = Canvas(w, h)
    cx, top = w / 2, 12
    noise = pa.value_noise(h, w, 4, rng)
    rock = np.zeros((h, w), bool)
    for y in range(top, h - 2):
        t = (y - top) / (h - 2 - top)
        half = (w * 0.46) * (1 - t) ** 1.4 + 1.5
        rock[y] = np.abs(np.arange(w) + 0.5 - cx - (noise[y] - 0.5) * 6 * t) <= half
    f1, f2, cid = pa.worley(h, w, (5, 9), rng, 0.8)
    v = 0.75 - 0.5 * np.clip((c.yy - top) / (h - top), 0, 1) + 0.4 * (pa.bump_light(np.clip((f2 - f1) / 2, 0, 1) * 2) - 0.5)
    v = np.where(f2 - f1 < 0.7, v - 0.25, v)
    c.paint(rock, st["cliff"], v, contrast=2.6, dither=False)
    cap = c.ellipse(cx, top + 1, w * 0.48, 6) & (c.yy <= top + 3 + (noise > 0.5))
    c.paint(cap, st["grass"], 0.35 + 0.6 * c.sphere(cx - 8, top - 3, w * 0.5, 8), dither=False)
    blobs = [(top - 4, cx + rng.uniform(-8, 8), rng.uniform(5, 8)) for _ in range(3)]
    alpha, value = pa.render_foliage((h, w), blobs, rng, small=(2.5, 3.5))
    c.paint(alpha, st["foliage"], value, contrast=3.0, dither=False)
    for _ in range(5):
        x = int(rng.uniform(cx - w * 0.3, cx + w * 0.3))
        y0 = top + 4
        length = int(rng.uniform(5, 14))
        for k in range(length):
            if y0 + k < h:
                c.fill(c.rect(x, y0 + k, x + 1, y0 + k + 1), st["foliage"][2 if k % 3 else 3])
    c.outline(st["outline"])
    return c


def rainbow(w=260, h=110):
    """Soft pixel rainbow arc for Elysia's sky (drawn translucent)."""
    out = np.zeros((h, w, 4), np.float32)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.hypot(xx + 0.5 - w / 2, (yy + 0.5 - h) * 1.0)
    bands = ["#ff6b6b", "#ffb15e", "#ffe66e", "#7ee08a", "#6ec0ff", "#9a86ff"]
    r0, bw = h - 34, 4
    for i, col in enumerate(bands):
        m = (d >= r0 + i * bw) & (d < r0 + (i + 1) * bw)
        out[m, :3] = pa.hex_rgb(col)
        out[m, 3] = 120
    fade = np.clip((h - yy) / (h * 0.55), 0, 1)
    out[..., 3] *= np.floor(fade * 4) / 4
    return out


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
    # a torn leaf blown through the valley (wind, Game Bible §12)
    px("leaf", ["ab.", "bbc", ".c."], {"a": ("#9a8a48", 255), "b": ("#6f6a30", 255), "c": ("#4a3c1e", 255)})
    px("sparkle", [".a.", "aba", ".a."], {"a": ("#fff3c4", 160), "b": ("#ffffff", 255)})
    # two frames stacked vertically (wings open / folded), used with vframes = 2
    px("butterfly", ["aa.aa", "abcba", ".bcb.", ".a.a.", ".....", ".bcb.", ".aca.", "....."],
       {"a": ("#ff9a3c", 255), "b": ("#ffd36e", 255), "c": ("#3a2a1c", 255)})
    # the gardener's golden butterflies (slice miniquest): bigger, so they read as the goal
    px("golden_butterfly", ["aa.....aa", "abba.abba", "abccdccba", ".abcdcba.", "..abdba..", ".aba.aba.",
                            "..a...a..", "...a.a...", "..abdba..", "..bcdcb..", "..acdca..", "...bdb...",
                            "...a.a...", "........."],
       {"a": ("#9a6410", 255), "b": ("#e8b030", 255), "c": ("#fff0a0", 255), "d": ("#4a2c10", 255)})
    px("puff", [".aaa.", "abbba", "abcba", "abbba", ".aaa."],
       {"a": ("#c8ccd4", 110), "b": ("#d8dce2", 170), "c": ("#e8ebef", 220)})
    px("mote", ["a"], {"a": ("#ffffff", 200)})
    px("firefly", [".a.", "aba", ".a."], {"a": ("#ffd36a", 120), "b": ("#fff6c8", 255)})
    # flying bird, two frames stacked (wings up / wings down)
    px("bird_fly", ["a.....a", ".a...a.", "..aba..", "...a...", ".......", ".......",
                    "..aba..", ".a...a.", "a.....a", "......."],
       {"a": ("#2a2436", 255), "b": ("#5a5068", 255)})
    px("bird_shadow", [".aaa.", "aaaaa", ".aaa."], {"a": ("#101018", 70)})
    # koi: two frames (tail left / right)
    px("koi", ["..abbaa.", ".abbbcaa", "..abbaa.", "........", "..abbaa.", "aabbbca.", "..abbaa."],
       {"a": ("#f08a3a", 255), "b": ("#fff4e8", 255), "c": ("#1c1424", 255)})
    px("fish_shadow", ["..aaaa.", ".aaaaaa", "..aaaa.", ".......", "..aaaa.", "aaaaaa.", "..aaaa."],
       {"a": ("#0a1018", 120)})
    px("dragonfly", [".a.a.", "abcba", ".a.a.", ".....", "a...a", ".bcb.", "a...a"],
       {"a": ("#cfeaff", 170), "b": ("#2a6fd0", 255), "c": ("#123a80", 255)})
    px("shadow_small", [".aaaaaaaa.", "aabbbbbbaa", "abbbbbbbba", "aabbbbbbaa", ".aaaaaaaa."],
       {"a": ("#1c1630", 50), "b": ("#1c1630", 95)})


# --------------------------------------------------------------------------- catalog
def build():
    for style in ("elysia", "tal", "wald", "haus"):
        os.makedirs(os.path.join(OUT, style), exist_ok=True)
    # elysia
    tree_entry = dict(shape={"circle": 6, "offset": [0, -2]}, sway=1.0, shadow=[28, 9])
    # trees: one size per catalog entry keeps anchors simple; species vary by palette
    for name, leaves, seeds in (("tree", "foliage", (1, 2)), ("tree_blue", "foliage_blue", (4, 5)),
                                ("tree_purple", "foliage_purple", (6, 7)), ("tree_blossom", "blossom", (8, 9))):
        variants = [natural_tree("elysia", seeds[0], leaves, "medium", (88, 104)),
                    natural_tree("elysia", seeds[1], leaves, "large", (88, 104)),
                    natural_tree("elysia", seeds[1] + 40, leaves, "small", (88, 104))]
        save("elysia", name, variants, (44, 101), **tree_entry)
    save("elysia", "bush", [bush("elysia", 80), bush("elysia", 81, "foliage_blue"),
                            bush("elysia", 82, "foliage_purple"), bush("elysia", 83)],
         (13, 19), shape={"circle": 7, "offset": [0, -3]}, sway=0.6, shadow=[11, 4])
    save("elysia", "sacred_tree", sacred_tree(), (104, 182), shape={"circle": 14, "offset": [0, -6]},
         shadow=[70, 16], sway=0.5, petal_rain={"extents": [84, 36], "offset": [0, -120], "amount": 16})
    save("elysia", "splash", foam(160, 34), (9, 6), flat=True,
         splash={"extents": [12, 3], "offset": [8, 0], "amount": 30})
    glow = "#8fe9f5"
    save("elysia", "pillar", marble_pillar(), (10, 46), shape={"circle": 6, "offset": [0, -2]},
         shadow=[8, 3], glow={"offset": [0, -38], "color": glow, "radius": 18})
    save("elysia", "crystal", crystal_pedestal(), (15, 47), shape={"circle": 11, "offset": [0, -3]},
         shadow=[13, 4], glow={"offset": [0, -33], "color": glow, "radius": 34})
    save("elysia", "glow_flower", [glow_flowers(90), glow_flowers(91), glow_flowers(92)], (9, 12),
         sway=1.0, glow={"offset": [0, -7], "color": "#a8eeff", "radius": 12})
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
    save("elysia", "islet", [floating_islet(75, 44, 40), floating_islet(76, 32, 30), floating_islet(77, 52, 44)],
         (0, 0))
    pa.save_rgba(os.path.join(OUT, "elysia", "rainbow.png"), rainbow())
    CATALOG["elysia/rainbow"] = {"textures": [RES + "/elysia/rainbow.png"], "anchor": [0, 0]}
    # tal
    save("tal", "house", house(), (58, 105), shape={"rect": [96, 40], "offset": [0, -12]},
         shadow=[52, 6], lights=[
             {"offset": [-30, -15], "color": "#ff8a45", "energy": 1.3, "range": 80},
             {"offset": [30, -15], "color": "#ff8a45", "energy": 1.3, "range": 80},
             {"offset": [12, -14], "color": "#ffb066", "energy": 0.7, "range": 40},
         ], smoke=[26, -102])
    # the same house empty and cold (slice: before the fire is lit)
    save("tal", "house_dark", house(lit=False), (58, 105), shape={"rect": [96, 40], "offset": [0, -12]},
         shadow=[52, 6])
    save("tal", "tree", [natural_tree("tal", 101, "foliage", "large", (88, 104)),
                         natural_tree("tal", 102, "foliage_blue", "medium", (88, 104)),
                         natural_tree("tal", 103, "foliage", "medium", (88, 104))], (44, 101),
         shape={"circle": 6, "offset": [0, -2]}, sway=1.0, shadow=[28, 9])
    save("tal", "tree_crooked", [natural_tree("tal", 104, "foliage", "medium", (100, 104), crooked=0.8),
                                 natural_tree("tal", 105, "foliage_blue", "medium", (100, 104), crooked=1.0),
                                 natural_tree("tal", 106, "foliage", "small", (100, 104), crooked=0.6)],
         (50, 101), shape={"circle": 6, "offset": [0, -2]}, sway=1.4, shadow=[26, 8])
    save("tal", "pine", [pine("tal", 110), pine("tal", 111)], (20, 68),
         shape={"circle": 5, "offset": [0, -2]}, sway=0.8, shadow=[16, 5])
    save("tal", "rock", [rock("tal", 120), rock("tal", 121, 22, 18)], (13, 16),
         shape={"rect": [18, 8], "offset": [0, -3]}, shadow=[12, 4])
    save("tal", "tall_grass", [tall_grass("tal", 130 + i) for i in range(3)], (9, 18), sway=2.5,
         surface="tall_grass", rustle=True)
    save("tal", "lantern", lantern("tal"), (6, 38), shape={"circle": 3, "offset": [0, -1]},
         shadow=[5, 2], lights=[{"offset": [0, -29], "color": "#ff8a45", "energy": 1.4, "range": 72}],
         flicker=True)
    save("tal", "barrel", barrel(140), (8, 18), shape={"circle": 6, "offset": [0, -2]}, shadow=[8, 3])
    save("tal", "woodpile", woodpile(141), (15, 18), shape={"rect": [26, 8], "offset": [0, -3]},
         shadow=[14, 3])
    save("tal", "fence", fence("tal", 150), (9, 14), shape={"rect": [16, 4], "offset": [0, -1]})
    save("tal", "fence_broken", [fence_broken(152 + k, k) for k in range(3)], (9, 14),
         shape={"rect": [16, 4], "offset": [0, -1]})
    save("tal", "fence_post", fence("tal", 151, vertical=True), (4, 22),
         shape={"rect": [4, 16], "offset": [0, -8]})
    save("tal", "bench", bench("tal"), (10, 18))
    save("tal", "splash", foam(161, 50, 12, "tal"), (9, 6), flat=True,
         splash={"extents": [20, 3], "offset": [16, 0], "amount": 34})
    # wald
    trees = [forest_tree(200 + i, glow=(i % 2 == 1)) for i in range(4)]
    save("wald", "tree", [t[0] for t in trees if t[1] is None], (44, 106),
         shape={"circle": 9, "offset": [0, -3]}, sway=0.5, shadow=[30, 9])
    glow_trees = [t for t in trees if t[1] is not None]
    # birches: their moonlit bark is the brightest thing in the forest (no light of their own)
    save("wald", "glow_tree", [t[0] for t in glow_trees], (44, 106), emissive=[t[1] for t in glow_trees],
         shape={"circle": 5, "offset": [0, -2]}, sway=0.6, shadow=[22, 7])
    # foxfire glows faintly green; honey fungus and fly agaric do not glow at all
    ms = [mushrooms(210 + k + 8, "cap_cyan") for k in range(2)]
    save("wald", "mushrooms_cyan", [m[0] for m in ms], (12, 18), emissive=[m[1] for m in ms],
         glow={"offset": [0, -7], "color": "#7ee0a0", "radius": 11})
    for cap in ("cap_violet", "cap_pink"):
        ms = [mushrooms(210 + k + len(cap), cap) for k in range(2)]
        save("wald", "mushrooms_" + cap[4:], [m[0] for m in ms], (12, 18))
    save("wald", "rock_mossy", [mossy_rock(220 + k) for k in range(2)], (15, 20),
         shape={"rect": [22, 8], "offset": [0, -3]}, shadow=[13, 4])
    save("wald", "fern", [fern(230 + k) for k in range(3)], (13, 17), sway=1.5,
         surface="tall_grass", rustle=True)
    save("wald", "log", fallen_log(240), (24, 15), shape={"rect": [40, 8], "offset": [0, -5]}, shadow=[22, 4])
    save("wald", "rock", [rock("wald", 250), rock("wald", 251, 22, 18)], (13, 16),
         shape={"rect": [18, 8], "offset": [0, -3]}, shadow=[12, 4])
    save("wald", "pine", [pine("wald", 260), pine("wald", 261)], (20, 68),
         shape={"circle": 5, "offset": [0, -2]}, sway=0.6, shadow=[16, 5])
    save("wald", "splash", foam(262, 50, 12, "wald"), (9, 6), flat=True,
         splash={"extents": [20, 3], "offset": [16, 0], "amount": 30})
    beam = light_beam()
    pa.save_rgba(os.path.join(OUT, "wald", "light_beam.png"), beam)
    CATALOG["wald/light_beam"] = {"textures": [RES + "/wald/light_beam.png"], "anchor": [48, 200],
                                  "beam": True, "lights": [{"offset": [0, -10], "color": "#bcd2f0",
                                                            "energy": 0.9, "range": 120}]}
    for style in ("elysia", "tal", "wald"):
        save(style, "grass_tuft", [grass_tuft(style, 500 + i) for i in range(5)], (7, 12), sway=1.0)
        save(style, "wildflowers", [wildflowers(style, 520 + i) for i in range(6)], (6, 11), sway=1.0)
        save(style, "pebbles", [pebbles(style, 540 + i) for i in range(4)], (5, 3), flat=True)
        save(style, "twig", [twig(style, 550 + i) for i in range(3)], (6, 3), flat=True)
        save(style, "leaves", [fallen_leaves(style, 560 + i) for i in range(4)], (6, 3), flat=True)
        save(style, "small_mushrooms", [small_mushrooms(style, 570 + i) for i in range(3)], (5, 8))
        if style != "elysia":
            save(style, "reeds", [reeds(580 + i, style) for i in range(2)], (8, 23), sway=2.0)
            save(style, "bush", [bush(style, 590 + i, "foliage") for i in range(2)] + [bush(style, 592, "foliage_blue")],
                 (13, 19), shape={"circle": 7, "offset": [0, -3]}, sway=0.6, shadow=[11, 4])
    for style in ("elysia", "tal", "wald"):
        rail = bridge_rail(style)
        # north rail: base on the top edge of its cell; south rail: base on the bottom edge
        save(style, "rail_n", rail, (9, 20), shape={"rect": [16, 3], "offset": [0, -7]})
        save(style, "rail_s", rail, (9, 4), shape={"rect": [16, 3], "offset": [0, 7]})
    pa.save_rgba(os.path.join(OUT, "fx", "fog.png"), fog_bank(300))
    particles()
    slice_props.build(sys.modules[__name__])
    # remove sprites (and their .import files) that are no longer part of the catalog
    used = {t[len(RES) + 1:] for e in CATALOG.values() for t in e["textures"] + e.get("emissive", [])}
    for style in ("elysia", "tal", "wald", "haus"):
        for name in sorted(os.listdir(os.path.join(OUT, style))):
            if name.endswith(".png") and "%s/%s" % (style, name) not in used:
                for stale in (name, name + ".import"):
                    path = os.path.join(OUT, style, stale)
                    if os.path.exists(path):
                        os.remove(path)
                print("removed stale sprite", "%s/%s" % (style, name))
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
