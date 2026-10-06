"""Shared helpers for REAL's procedural pixel art (look prototype, ADR-017).

Everything works on numpy arrays. Colors are ramps (dark -> light) per material,
hue-shifted like hand-made pixel art: shadows cooler, highlights warmer.
Dev-only tooling: numpy + Pillow (requirements-dev.txt), never shipped in builds.
"""
import numpy as np
from PIL import Image

BAYER4 = (np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) + 0.5) / 16.0


def hex_rgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float32)


def ramp(*hexes):
    return np.stack([hex_rgb(h) for h in hexes])


# --------------------------------------------------------------------------- palettes
STYLES = {
    # Elysia: teal-leaning greens, violet shadows, warm light, white stone, turquoise water.
    "elysia": {
        "grass": ramp("#1f4b4a", "#2b6a53", "#3f8c56", "#6aaf58", "#a7d06a"),
        "grass_dry": ramp("#3a4a36", "#566a3e", "#7f8f4a", "#a9b062", "#d2cf86"),
        "grass_lush": ramp("#173f44", "#1f5a4c", "#2d7650", "#4f9a55", "#86c06a"),
        "path": ramp("#7a6555", "#a08a72", "#c4ad8c", "#e0cfab", "#f3e9cb"),
        "dirt": ramp("#6e5148", "#93705c", "#b69276", "#d4b693", "#ecd8b6"),
        "stone": ramp("#56526f", "#85819f", "#b4b1c6", "#dad8e4", "#f6f5fa"),
        "marble": ramp("#6b6788", "#9d9ab4", "#c9c7d8", "#e8e7ef", "#ffffff"),
        "water": ramp("#1a4a78", "#2177a0", "#2cabc2", "#69d9d6", "#cdf8ef"),
        "wood": ramp("#4e2f2c", "#774634", "#a2683f", "#c99358", "#e8c182"),
        "rock": ramp("#2f2840", "#4b3f5e", "#6e6082", "#9a8daa", "#cbc1d6"),
        "mud": ramp("#4e3a35", "#6c5145", "#8c6c58", "#ad8c70", "#cbab8a"),
        "foliage": ramp("#10322f", "#185243", "#22714f", "#3d9454", "#74b85e", "#b6dc78"),
        "foliage_blue": ramp("#16264a", "#1f3c6e", "#2b5a97", "#3f80bf", "#6aaee0", "#a9d8f4"),
        "foliage_purple": ramp("#271a45", "#3f2a6a", "#5c3f92", "#7f5bb8", "#a886d8", "#d3bcf0"),
        "blossom": ramp("#6e3462", "#9e5288", "#cf7fae", "#ecaccb", "#fbd5e5", "#fff3f8"),
        "wisteria": ramp("#4d3478", "#7454a6", "#9c7fcf", "#c3abe9", "#e6d9fb"),
        "bark": ramp("#18132a", "#2b2340", "#41365a", "#5f5278", "#8a7ca3"),
        "crystal": ramp("#1b6f9a", "#2fb3d8", "#7ee6f2", "#d7fbff", "#ffffff"),
        "cliff": ramp("#2a2140", "#43335a", "#644a6e", "#87627e", "#ad7f8c", "#d3a6a4"),
        "outline": hex_rgb("#1a1530"),
        "flowers": [ramp("#b2306f", "#f06ba6", "#ffd0e4"), ramp("#c98a1c", "#f7cf4a", "#fff3b0"),
                    ramp("#3b55c4", "#6f9ef5", "#cfe2ff"), ramp("#a9a6cf", "#efeefe", "#ffffff"),
                    ramp("#7b3cc0", "#b07cf0", "#e7d3ff")],
    },
    # Wald: a real forest at night (playtest 05.10.: natural like the real world). Moonlight
    # instead of fantasy glow: deep blue-greens, slate rock, dark water. What shines does so
    # in reality too: the white bark of birches, foxfire on rotten wood, fireflies.
    "wald": {
        "grass": ramp("#0d1514", "#14211d", "#1d2f27", "#293f32", "#3a5341"),
        "grass_dry": ramp("#131616", "#1d221f", "#2a3029", "#3a4134", "#4d5443"),
        "grass_lush": ramp("#0a1413", "#101f1a", "#172c23", "#213b2d", "#2f4f3b"),
        "path": ramp("#16141a", "#221e24", "#302a2f", "#423a3d", "#585050"),
        "dirt": ramp("#16141a", "#221e24", "#302a2f", "#423a3d", "#585050"),
        "stone": ramp("#141619", "#202327", "#2e3237", "#41464d", "#5a6068"),
        "water": ramp("#0a1220", "#101c30", "#182a44", "#24405e", "#4a6c8e"),
        "wood": ramp("#17130f", "#261f19", "#382d24", "#4d3e31", "#665341"),
        "rock": ramp("#151719", "#212428", "#30343a", "#43484f", "#5c6269"),
        "mud": ramp("#141116", "#1e1a1f", "#2b252a", "#3a3237", "#4c4247"),
        "foliage": ramp("#081110", "#0d1a17", "#13251f", "#1b3329", "#264534", "#365a43"),
        "foliage_blue": ramp("#141e1b", "#22302a", "#34463b", "#4c6150", "#6b8068", "#94a88e"),
        "foliage_purple": ramp("#120f14", "#1c1820", "#28222c", "#36303a", "#474050", "#5e5868"),
        "glow_cyan": ramp("#0e3a22", "#1b6a3c", "#3aa860", "#8ee0a0", "#e0ffe8"),
        "crystal": ramp("#2a3a4a", "#4a6070", "#7a90a0", "#b0c4d0", "#e8f2f8"),
        "bark": ramp("#0e0d0e", "#1a1718", "#272223", "#37302f", "#4a423f"),
        "cliff": ramp("#0f1113", "#181b1f", "#22262b", "#2e333a", "#3c424a", "#4f5660"),
        "outline": hex_rgb("#05060a"),
        "flowers": [ramp("#3a3a2a", "#6a6848", "#a8a47a"), ramp("#2a3448", "#4a5a78", "#8a9cbc"),
                    ramp("#3a2a3a", "#5e4a5e", "#90789a"), ramp("#4a4a50", "#7a7c86", "#b8bcc8"),
                    ramp("#2a3a30", "#4a6450", "#82a088")],
    },
    # Tal: the real world on an overcast, rainy day (playtest 05.10.: "natürlicher, wie in der
    # echten Welt"). Muted sap and olive greens, wet brown earth, neutral grey stone, a
    # grey-green stream. Evening and night come from DayLight's tint, like real light does.
    "tal": {
        "grass": ramp("#1e2a1c", "#2d3f25", "#41582e", "#5a7238", "#7a8f4a"),
        "grass_dry": ramp("#2c2c1f", "#43432b", "#5d5b37", "#7a7545", "#9a9258"),
        "grass_lush": ramp("#16241a", "#223521", "#314b29", "#436434", "#5d7e43"),
        "path": ramp("#2a221d", "#3f3329", "#574636", "#705b45", "#8c7458"),
        "dirt": ramp("#2a221d", "#3f3329", "#574636", "#705b45", "#8c7458"),
        "stone": ramp("#2a2c2e", "#404346", "#5a5d61", "#777a7e", "#9c9fa2"),
        "water": ramp("#18252c", "#243840", "#324e57", "#46676e", "#71939a"),
        "wood": ramp("#2a201b", "#3e3028", "#574436", "#715a47", "#8f765e"),
        "rock": ramp("#29292a", "#3d3d3f", "#555558", "#717174", "#939396"),
        "mud": ramp("#271f1a", "#382c24", "#4c3c30", "#624e3e", "#7b644f"),
        "foliage": ramp("#141e14", "#1d2d1c", "#2a4026", "#3a5731", "#4f6f3e", "#6b8a50"),
        "foliage_blue": ramp("#121c19", "#1a2a23", "#253b2e", "#33503a", "#466847", "#5f8257"),
        "foliage_purple": ramp("#1e1517", "#2e1f20", "#432d2a", "#5a3d35", "#744f42", "#8f6553"),
        "cliff": ramp("#1d1b19", "#2b2825", "#3d3934", "#524c45", "#6a6259", "#857b70"),
        "outline": hex_rgb("#111310"),
        "flowers": [ramp("#6e5a14", "#b39424", "#e3cb52"), ramp("#6f726b", "#a9ada3", "#dcdfd5"),
                    ramp("#5a2f45", "#8c4f6a", "#b87c94"), ramp("#2e4170", "#4d67a2", "#86a0d0"),
                    ramp("#6a2622", "#a23c30", "#cf6a52")],
    },
}


# --------------------------------------------------------------------------- noise
def value_noise(h, w, cell, rng, octaves=1, persistence=0.5):
    """Smooth value noise in [0, 1] of shape (h, w); fractal when octaves > 1.
    `cell` is a size in pixels or a (cell_y, cell_x) pair for stretched noise (wood grain)."""
    total = np.zeros((h, w), np.float32)
    cy, cx = (float(cell[0]), float(cell[1])) if isinstance(cell, tuple) else (float(cell),) * 2
    amp, norm = 1.0, 0.0
    for _ in range(octaves):
        gh, gw = int(h / cy) + 3, int(w / cx) + 3
        grid = rng.random((gh, gw)).astype(np.float32)
        ys = np.arange(h, dtype=np.float32) / cy
        xs = np.arange(w, dtype=np.float32) / cx
        y0, x0 = np.floor(ys).astype(int), np.floor(xs).astype(int)
        fy, fx = ys - y0, xs - x0
        fy, fx = fy * fy * (3 - 2 * fy), fx * fx * (3 - 2 * fx)
        a = grid[y0][:, x0]
        b = grid[y0][:, x0 + 1]
        c2 = grid[y0 + 1][:, x0]
        d = grid[y0 + 1][:, x0 + 1]
        top = a + (b - a) * fx[None, :]
        bot = c2 + (d - c2) * fx[None, :]
        total += amp * (top + (bot - top) * fy[:, None])
        norm += amp
        amp *= persistence
        cy, cx = max(cy / 2.0, 1.0), max(cx / 2.0, 1.0)
    return total / norm


def worley(h, w, cell, rng, jitter=0.9):
    """Returns (f1, f2, cell_id) for a jittered grid of feature points (cobbles, pebbles).
    `cell` may be (cell_y, cell_x) for stretched cells (rock slabs); distances are then measured
    in units of the smaller cell axis, so cells stay elongated."""
    sy, sx = (cell if isinstance(cell, tuple) else (cell, cell))
    gh, gw = h // sy + 3, w // sx + 3
    pts = (np.stack(np.meshgrid(np.arange(gh), np.arange(gw), indexing="ij"), -1).astype(np.float32)
           + 0.5 + (rng.random((gh, gw, 2)).astype(np.float32) - 0.5) * jitter) * np.array([sy, sx], np.float32)
    ids = rng.permutation(gh * gw).reshape(gh, gw)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cy, cx = (yy // sy).astype(int), (xx // sx).astype(int)
    m = float(min(sy, sx))
    f1 = np.full((h, w), 1e9, np.float32)
    f2 = np.full((h, w), 1e9, np.float32)
    cid = np.zeros((h, w), np.int64)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            ny, nx = np.clip(cy + dy, 0, gh - 1), np.clip(cx + dx, 0, gw - 1)
            p = pts[ny, nx]
            d = np.hypot((yy - p[..., 0]) * (m / sy), (xx - p[..., 1]) * (m / sx))
            closer = d < f1
            f2 = np.where(closer, f1, np.minimum(f2, d))
            cid = np.where(closer, ids[ny, nx], cid)
            f1 = np.where(closer, d, f1)
    return f1, f2, cid


def box_blur(a, r, passes=2):
    """Approximate gaussian blur with repeated box blurs (edges clamp)."""
    out = a.astype(np.float32)
    for _ in range(passes):
        for axis in (0, 1):
            pad = [(0, 0)] * out.ndim
            pad[axis] = (r + 1, r)
            p = np.pad(out, pad, mode="edge")
            cs = np.cumsum(p, axis=axis)
            hi = np.take(cs, np.arange(2 * r + 1, p.shape[axis]), axis=axis)
            lo = np.take(cs, np.arange(0, p.shape[axis] - 2 * r - 1), axis=axis)
            out = (hi - lo) / (2 * r + 1)
    return out


# --------------------------------------------------------------------------- shading
def quantize(value, n, contrast=1.0, dither=True, offset=(0, 0)):
    """Maps value (0..1) to ramp indices 0..n-1. Contrast > 1 keeps flat color areas and
    restricts ordered dithering to narrow bands between them (less noisy than plain dither)."""
    v = np.clip(value, 0.0, 0.9999) * (n - 1)
    base = np.floor(v)
    frac = np.clip((v - base - 0.5) * contrast + 0.5, 0.0, 1.0)
    if dither:
        h, w = np.shape(value)
        oy, ox = offset
        b = np.tile(BAYER4, (h // 4 + 2, w // 4 + 2))[oy % 4:oy % 4 + h, ox % 4:ox % 4 + w]
        idx = base + (frac > b)
    else:
        idx = base + (frac > 0.5)
    return np.clip(idx, 0, n - 1).astype(np.int32)


def shade(ramp_colors, value, dither=True, offset=(0, 0), contrast=1.0):
    """Maps value (0..1 per pixel) onto a ramp with optional ordered dithering."""
    return ramp_colors[quantize(value, len(ramp_colors), contrast, dither, offset)]


def bump_light(height, strength=1.0, light=(-0.55, -0.65, 0.52)):
    """Lambert term for a height field (cobbles, pebbles, slabs): 0.5 = flat, >0.5 lit."""
    gy, gx = np.gradient(height.astype(np.float32))
    nx, ny, nz = -gx * strength, -gy * strength, np.ones_like(gx)
    n = np.sqrt(nx * nx + ny * ny + nz * nz)
    flat = sphere_light(np.zeros(1), np.zeros(1), np.ones(1), light)[0]
    lit = sphere_light(nx / n, ny / n, nz / n, light)
    return np.clip(0.5 + (lit - flat), 0, 1)


def sphere_light(nx, ny, nz, light=(-0.55, -0.65, 0.52)):
    """Lambert term for a normal field; light comes from the top left like in most pixel art."""
    l = np.array(light, np.float32)
    l /= np.linalg.norm(l)
    return np.clip(nx * l[0] + ny * l[1] + nz * l[2], 0, 1)


def outline(rgba, color, alpha_threshold=128, diagonal=False):
    """Adds a 1px outline around opaque pixels (in place)."""
    a = rgba[..., 3] >= alpha_threshold
    grown = a.copy()
    shifts = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    if diagonal:
        shifts += [(1, 1), (1, -1), (-1, 1), (-1, -1)]
    padded = np.pad(a, 1)
    h, w = a.shape
    for dy, dx in shifts:
        grown |= padded[1 - dy:1 - dy + h, 1 - dx:1 - dx + w]
    edge = grown & ~a
    rgba[edge, :3] = color
    rgba[edge, 3] = 255
    return rgba


def save_rgba(path, rgba):
    import os
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA").save(path, optimize=True)


def save_rgb(path, rgb):
    h, w, _ = rgb.shape
    rgba = np.concatenate([rgb, np.full((h, w, 1), 255, np.float32)], -1)
    save_rgba(path, rgba)


def render_blobs(shape, blobs, ramp_colors, rng, clip=None, leaf_cell=4, outline_rim=True,
                 leaf_weight=0.16):
    """Paints overlapping leafy spheres (tree crowns, hedges, bushes) back to front.

    blobs: list of (cy, cx, r). Lower blobs (larger cy) are drawn last, so they overlap the
    ones behind them like clumps seen from above. Returns (rgb, alpha, value) arrays.
    """
    h, w = shape
    value = np.zeros((h, w), np.float32)
    alpha = np.zeros((h, w), bool)
    f1, f2, _ = worley(h, w, leaf_cell, rng, 1.0)
    leaf = bump_light(np.clip(1.0 - f1 / (leaf_cell * 0.75), 0, 1) * 3.0)
    edge_noise = value_noise(h, w, 3, rng)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    for cy, cx, r in sorted(blobs, key=lambda b: b[0]):
        y0, y1 = int(max(cy - r - 2, 0)), int(min(cy + r + 3, h))
        x0, x1 = int(max(cx - r - 2, 0)), int(min(cx + r + 3, w))
        if y0 >= y1 or x0 >= x1:
            continue
        dy = yy[y0:y1, x0:x1] - cy
        dx = xx[y0:y1, x0:x1] - cx
        d = np.hypot(dx, dy)
        reff = r * (0.88 + 0.24 * edge_noise[y0:y1, x0:x1])
        inside = d <= reff
        if clip is not None:
            inside &= clip[y0:y1, x0:x1]
        t = np.clip(d / np.maximum(reff, 1e-3), 0, 1)
        nz = np.sqrt(np.clip(1 - t * t, 0, 1))
        lam = sphere_light(dx / max(r, 1), dy / max(r, 1), nz)
        lf = leaf[y0:y1, x0:x1]
        v = 0.14 + 0.7 * lam + leaf_weight * 2 * (lf - 0.5)
        # crisp highlight clusters on the lit side read as leaves, not as noise
        v = np.where((lam > 0.72) & (lf > 0.62), v + 0.16, v)
        if outline_rim:
            rim = (t > 0.86) & ((dx + dy) > 0)
            v = np.where(rim, np.minimum(v, 0.1), v)
        sub = value[y0:y1, x0:x1]
        sub[inside] = v[inside]
        alpha[y0:y1, x0:x1] |= inside
    rgb = shade(ramp_colors, np.clip(value, 0, 1))
    return rgb, alpha, value


def render_foliage(shape, blobs, rng, clip=None, small=(3.5, 5.5), density=1.1):
    """Hand-drawn style foliage: every big blob is filled with small leaf clumps.

    Each clump gets local sphere shading and a dark lower-right rim; the big blob's light
    sets the overall tone. Gives clearly separated clusters instead of noisy texture.
    Returns (alpha, value) with value in 0..1 (quantize with high contrast).
    """
    h, w = shape
    value = np.zeros((h, w), np.float32)
    alpha = np.zeros((h, w), bool)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    # base silhouettes in shadow tone, so gaps between clumps read as depth, not holes
    for cy, cx, r in sorted(blobs, key=lambda b: b[0]):
        y0, y1 = int(max(cy - r - 1, 0)), int(min(cy + r + 2, h))
        x0, x1 = int(max(cx - r - 1, 0)), int(min(cx + r + 2, w))
        if y0 >= y1 or x0 >= x1:
            continue
        gy, gx = (yy[y0:y1, x0:x1] + 0.5 - cy) / r, (xx[y0:y1, x0:x1] + 0.5 - cx) / r
        gt = np.hypot(gx, gy)
        inside = gt <= 0.92
        if clip is not None:
            inside &= clip[y0:y1, x0:x1]
        big = sphere_light(gx, gy, np.sqrt(np.clip(1 - np.clip(gt, 0, 1) ** 2, 0, 1)))
        sub = value[y0:y1, x0:x1]
        sub[inside] = (0.02 + 0.45 * big)[inside]
        alpha[y0:y1, x0:x1] |= inside
    clumps = []
    for cy, cx, r in blobs:
        n = max(3, int(density * (r * r) / (small[0] * small[1]) * 1.6))
        for _ in range(n):
            a = rng.uniform(0, 2 * np.pi)
            d = np.sqrt(rng.uniform(0, 1)) * r * 0.78
            clumps.append((cy + np.sin(a) * d, cx + np.cos(a) * d, rng.uniform(*small), cy, cx, r))
    for y, x, r, by, bx, br in sorted(clumps, key=lambda c: c[0]):
        y0, y1 = int(max(y - r - 1, 0)), int(min(y + r + 2, h))
        x0, x1 = int(max(x - r - 1, 0)), int(min(x + r + 2, w))
        if y0 >= y1 or x0 >= x1:
            continue
        dy, dx = yy[y0:y1, x0:x1] + 0.5 - y, xx[y0:y1, x0:x1] + 0.5 - x
        d = np.hypot(dx, dy)
        inside = d <= r
        if clip is not None:
            inside &= clip[y0:y1, x0:x1]
        t = np.clip(d / r, 0, 1)
        local = sphere_light(dx / r, dy / r, np.sqrt(np.clip(1 - t * t, 0, 1)))
        gy, gx = (yy[y0:y1, x0:x1] - by) / br, (xx[y0:y1, x0:x1] - bx) / br
        gt = np.clip(np.hypot(gx, gy), 0, 1)
        big = sphere_light(gx, gy, np.sqrt(np.clip(1 - gt * gt, 0, 1)))
        v = 0.1 + 0.62 * big + 0.36 * (local - 0.45)
        rim = (t > 0.78) & ((dx + dy) > 0.5)
        v = np.where(rim, v - 0.22, v)
        sub = value[y0:y1, x0:x1]
        sub[inside] = v[inside]
        alpha[y0:y1, x0:x1] |= inside
    return alpha, np.clip(value, 0, 1)
