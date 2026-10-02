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
    "elysia": {
        "grass": ramp("#245a40", "#347d46", "#529f4b", "#86c35a", "#c3e486"),
        "path": ramp("#a06c49", "#c99a69", "#e6c58e", "#f6e3b2", "#fff6dc"),
        "dirt": ramp("#7a4c34", "#a06a45", "#c6905c", "#e2b77f", "#f5daa6"),
        "stone": ramp("#4f4a63", "#77718a", "#a19cad", "#cbc7cc", "#f0ede6"),
        "water": ramp("#17457f", "#2370b0", "#36a0d6", "#76d3ee", "#d6f6ff"),
        "wood": ramp("#5a3127", "#874d30", "#b5743d", "#d9a259", "#f1cf86"),
        "rock": ramp("#3a2f4b", "#5c4d6d", "#857799", "#b3a7c4", "#e3dbeb"),
        "mud": ramp("#5a3a2a", "#7a5136", "#9d6c47", "#c08d5d", "#ddb37c"),
        "foliage": ramp("#0f2f2c", "#17493a", "#226b3f", "#3a9442", "#6fbf45", "#b4e05c"),
        "cliff": ramp("#2e2238", "#4b3448", "#714c58", "#9a6b66", "#c2927a", "#e6c29a"),
        "outline": hex_rgb("#1c1630"),
        "flowers": [ramp("#c2246a", "#ff6fae", "#ffd2e7"), ramp("#d98a00", "#ffd23f", "#fff3a8"),
                    ramp("#2d5fd6", "#5aa8ff", "#c7e4ff"), ramp("#b8b8d8", "#f4f4ff", "#ffffff"),
                    ramp("#c22d2d", "#ff5a52", "#ffc0b0")],
    },
    "tal": {
        "grass": ramp("#18291f", "#24402b", "#355a38", "#4c7444", "#6c8d55"),
        "path": ramp("#2a211c", "#3e3027", "#574334", "#735a43", "#937654"),
        "dirt": ramp("#2a211c", "#3e3027", "#574334", "#735a43", "#937654"),
        "stone": ramp("#262a33", "#3a3f4a", "#525865", "#6f7684", "#939aa6"),
        "water": ramp("#152331", "#1e3446", "#2b4c62", "#456e84", "#7c9fae"),
        "wood": ramp("#291b15", "#43291e", "#633f2b", "#875b3d", "#a87a52"),
        "rock": ramp("#22252c", "#353943", "#4c515d", "#686f7b", "#8e95a0"),
        "mud": ramp("#241c16", "#372a21", "#4c3a2d", "#64503e", "#806952"),
        "foliage": ramp("#0a120f", "#101e17", "#172b1f", "#22392a", "#304b35", "#455f43"),
        "cliff": ramp("#16181d", "#22252c", "#2f333c", "#3f444f", "#535a66", "#6c7480"),
        "outline": hex_rgb("#0f1114"),
        "flowers": [ramp("#5e3a5c", "#8b5d87", "#b58ab0"), ramp("#6d6234", "#9c8e4c", "#c4b774"),
                    ramp("#3c4f6e", "#5d7699", "#8ea6c4"), ramp("#7c8088", "#a9adb5", "#d3d6db"),
                    ramp("#6a3434", "#955050", "#bd7a74")],
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


def render_blobs(shape, blobs, ramp_colors, rng, clip=None, leaf_cell=4, outline_rim=True):
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
        v = 0.08 + 0.62 * lam + 0.3 * (leaf[y0:y1, x0:x1] - 0.5) + 0.12
        if outline_rim:
            rim = (t > 0.86) & ((dx + dy) > 0)
            v = np.where(rim, np.minimum(v, 0.1), v)
        sub = value[y0:y1, x0:x1]
        sub[inside] = v[inside]
        alpha[y0:y1, x0:x1] |= inside
    rgb = shade(ramp_colors, np.clip(value, 0, 1))
    return rgb, alpha, value
