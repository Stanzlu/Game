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
    # Wald: forest at night. Near-black teal ground, violet rock, bioluminescent blues, magenta
    # crystals, warm firefly gold. Light comes from the glowing things, not from the sky.
    "wald": {
        "grass": ramp("#0a171c", "#0f2428", "#153330", "#1e453a", "#2c5a45"),
        "grass_dry": ramp("#12151c", "#1c2226", "#2a3029", "#3a4231", "#4e563c"),
        "grass_lush": ramp("#08141c", "#0c2026", "#112e30", "#183f3a", "#235448"),
        "path": ramp("#17121d", "#241b28", "#352834", "#4a3a44", "#645058"),
        "dirt": ramp("#17121d", "#241b28", "#352834", "#4a3a44", "#645058"),
        "stone": ramp("#141527", "#202239", "#30334d", "#464a66", "#626785"),
        "water": ramp("#08112a", "#0d1b42", "#142d60", "#1f4a88", "#4b86c4"),
        "wood": ramp("#1b1216", "#30201d", "#493126", "#674632", "#8a6243"),
        "rock": ramp("#151226", "#221d3a", "#322b50", "#463d69", "#605688"),
        "mud": ramp("#140f18", "#201822", "#30242e", "#43343e", "#5b4852"),
        "foliage": ramp("#071118", "#0b1b25", "#112935", "#183a46", "#225058", "#31686a"),
        "foliage_blue": ramp("#0c1c38", "#14355e", "#1f5389", "#3880b6", "#6bb5e0", "#b8e8fc"),
        "foliage_purple": ramp("#120d24", "#1d1539", "#2a1f52", "#3b2c6e", "#52408c", "#7262ab"),
        "glow_cyan": ramp("#0e4656", "#18869c", "#38c4d6", "#8eeef4", "#e2ffff"),
        "crystal": ramp("#3e0e46", "#801c84", "#c43cbe", "#f07ae4", "#ffd0fb"),
        "bark": ramp("#0c0a12", "#17121d", "#241c2b", "#352a3d", "#4b3e53"),
        "cliff": ramp("#110e1c", "#1a152a", "#261e3a", "#33294e", "#443764", "#5a4a80"),
        "outline": hex_rgb("#05060c"),
        "flowers": [ramp("#1c3a7a", "#3a6cc8", "#9cc8ff"), ramp("#4a2a8a", "#8a5ad8", "#dcc0ff"),
                    ramp("#145a6a", "#2aa8b8", "#a8f2f6"), ramp("#6a2a6a", "#b44cb0", "#f2b0ee"),
                    ramp("#3a4a7a", "#6a80b8", "#c6d4f2")],
    },
    # Tal: night after rain. Deep blue and violet shadows, teal greens, reddish earth.
    "tal": {
        "grass": ramp("#101c27", "#16302f", "#1f4339", "#2d5945", "#457252"),
        "grass_dry": ramp("#181c24", "#26302c", "#36432f", "#4b5838", "#646e45"),
        "grass_lush": ramp("#0c1824", "#112a2e", "#183c36", "#225041", "#356850"),
        "path": ramp("#211820", "#33252a", "#4a3533", "#644940", "#836252"),
        "dirt": ramp("#211820", "#33252a", "#4a3533", "#644940", "#836252"),
        "stone": ramp("#1c1e2b", "#2b2e40", "#3e4258", "#575c74", "#787e96"),
        "water": ramp("#0d1832", "#13284c", "#1b3d6b", "#2b5c8f", "#5a8fc0"),
        "wood": ramp("#25181a", "#3d2622", "#5a3a2c", "#7d553b", "#a3764f"),
        "rock": ramp("#1a1a28", "#2a2a3c", "#3d3c53", "#56546e", "#76738f"),
        "mud": ramp("#1d151b", "#2c2023", "#3f2e2e", "#56403b", "#71574c"),
        "foliage": ramp("#0a1119", "#0e1d27", "#152c34", "#1e4042", "#2c5752", "#437162"),
        "foliage_blue": ramp("#0a1020", "#0f1a33", "#16284a", "#203a63", "#305380", "#4a719c"),
        "foliage_purple": ramp("#120d1f", "#1d1533", "#2a1f4a", "#3b2c63", "#513f80", "#6d5a9c"),
        "cliff": ramp("#13121c", "#1e1b2b", "#2b263b", "#3b344e", "#4f4664", "#685d7e"),
        "outline": hex_rgb("#0b0c14"),
        "flowers": [ramp("#4e2c59", "#7a4f88", "#a77bb8"), ramp("#5e5634", "#8a7f4a", "#b4a86d"),
                    ramp("#2c4170", "#4a679c", "#7a98c8"), ramp("#6a7086", "#959bb0", "#c3c8d8"),
                    ramp("#5c2f45", "#874d68", "#b27a92")],
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
