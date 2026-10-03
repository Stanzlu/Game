#!/usr/bin/env python3
"""Bakes a text map into one painted ground texture (look prototype, ADR-017).

The text map stays the source of truth for collision and surfaces. This tool only paints:
organic borders between materials instead of a visible tile grid, shading, edge shadows,
hedge crowns, cliff faces and a water mask for the animated water shader.

Usage: .venv/bin/python tools/art/bake_ground.py content/maps/look_elysia.txt [--preview]
Outputs go to the paths in the map's [meta] block (res:// is the repo root).
Everything is painted as (ramp, index) pairs first and turned into colors at the end, so
light and shadow always stay inside the hand-picked palettes of tools/art/pixelart.py.
"""
import argparse
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixelart as pa  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
T = 16
MATERIALS = ["void", "grass", "path", "mud", "puddle", "cobble", "water", "planks_v", "planks_h",
             "hedge", "cliff", "marble", "stairs", "fall"]
M = {name: i for i, name in enumerate(MATERIALS)}
SURFACE_PAINT = {"grass": "grass", "dirt": "path", "stone": "cobble", "water": "water",
                 "wood": "planks_h", "puddle": "puddle"}
# Soft materials share one blur so their borders are comparable; (noise amplitude, bias).
SOFT = {"grass": (0.30, 0.0), "path": (0.30, 0.03), "mud": (0.40, 0.0), "cobble": (0.08, 0.06),
        "water": (0.18, -0.04), "cliff": (0.10, 0.0), "void": (0.10, 0.0)}
BLUR = 7
# Materials drawn as smooth shapes on top of the soft blend (plazas): (blur, threshold).
SMOOTH = {"cobble": (12, 0.5), "marble": (14, 0.5)}

# Pixel stamps for grass tufts: (dy, dx, index delta). Shadow row at the bottom.
TUFTS = [
    [(0, -1, 1), (0, 1, 1), (1, 0, 1), (2, -1, -1), (2, 0, -1), (2, 1, -1)],
    [(0, -2, 1), (0, 0, 2), (0, 2, 1), (1, -1, 1), (1, 1, 1), (2, -1, -1), (2, 0, -1), (2, 1, -1)],
    [(0, 0, 2), (1, 0, 1), (2, 0, -1)],
    [(0, 0, 1), (1, 0, 1), (0, 2, 1), (1, 1, 1), (2, 0, -1), (2, 1, -1)],
]


# --------------------------------------------------------------------------- map parsing
def res_path(path):
    return os.path.join(ROOT, path[len("res://"):]) if path.startswith("res://") else path


def parse_map(path):
    """Mirror of world/map/map_data.gd: [meta], [legend] and [map] blocks, ';' comments."""
    with open(os.path.join(ROOT, "content/maps/legend.json"), encoding="utf-8") as f:
        legend = json.load(f)
    symbols = dict(legend["symbols"])
    meta, rows, section, saw_header = {}, [], "map", False
    with open(path, encoding="utf-8") as f:
        for raw in f.read().replace("\r", "").split("\n"):
            s = raw.strip()
            if s in ("[legend]", "[map]", "[meta]"):
                section, saw_header = s[1:-1], True
                continue
            if s.startswith(";") and not (section == "map" and saw_header):
                continue
            if section in ("legend", "meta"):
                if not s:
                    continue
                if section == "legend":
                    # first character is the symbol (it may itself be '=')
                    symbols[s[0]] = json.loads(s[1:].strip()[1:])
                else:
                    key, _, value = s.partition("=")
                    meta[key.strip()] = json.loads(value)
            elif s:
                rows.append(raw.rstrip())
    return meta, symbols, rows


def paint_of(symbol, symbols):
    d = symbols[symbol]
    if "atlas" not in d:
        d = symbols[d["ground"]]
    if "paint" in d:
        return d["paint"]
    if d.get("solid") and d.get("surface") == "stone":
        return "cliff"
    return SURFACE_PAINT.get(d.get("surface", ""), "grass")


# --------------------------------------------------------------------------- helpers
def up(cells):
    return np.repeat(np.repeat(cells, T, 0), T, 1)


def shift(a, dy, dx, fill=False):
    out = np.full_like(a, fill)
    h, w = a.shape
    ys, yd = (slice(0, h - dy), slice(dy, h)) if dy >= 0 else (slice(-dy, h), slice(0, h + dy))
    xs, xd = (slice(0, w - dx), slice(dx, w)) if dx >= 0 else (slice(-dx, w), slice(0, w + dx))
    out[yd, xd] = a[ys, xs]
    return out


def within_below(mask, n):
    """Pixels that have `mask` within n pixels above them (shadow cast downwards)."""
    out = np.zeros_like(mask)
    for k in range(1, n + 1):
        out |= shift(mask, k, 0)
    return out


def near(mask, n):
    out = mask.copy()
    for k in range(1, n + 1):
        out |= shift(mask, k, 0) | shift(mask, -k, 0) | shift(mask, 0, k) | shift(mask, 0, -k)
    return out


def centered(noise):
    return (noise - 0.5) * 2.0


# --------------------------------------------------------------------------- baking
class Baker:
    def __init__(self, meta, symbols, rows, seed):
        self.style_name = meta.get("style", "elysia")
        self.style = pa.STYLES[self.style_name]
        self.rng = np.random.default_rng(seed)
        self.ch, self.cw = len(rows), len(rows[0])
        self.h, self.w = self.ch * T, self.cw * T
        cells = np.zeros((self.ch, self.cw), np.int32)
        self.meadow_cells = np.zeros((self.ch, self.cw), np.float32)
        for y, row in enumerate(rows):
            for x, c in enumerate(row):
                paint = paint_of(c, symbols)
                if paint == "meadow":
                    self.meadow_cells[y, x] = 1.0
                    paint = "grass"
                cells[y, x] = M[paint]
        self.cells = cells
        # decor placements whose catalog entry asks for a ground shadow
        self.shadows = []
        catalog_path = os.path.join(ROOT, "assets", "generated", "props", "catalog.json")
        catalog = json.load(open(catalog_path, encoding="utf-8")) if os.path.exists(catalog_path) else {}
        for y, row in enumerate(rows):
            for x, c in enumerate(row):
                sprite = symbols[c].get("params", {}).get("sprite")
                entry = catalog.get(sprite, {}) if sprite else {}
                if "shadow" in entry:
                    self.shadows.append((y * T + T // 2, x * T + T // 2, entry["shadow"]))
        self.ramps = []
        self.ramp_ids = {}
        for name in ("grass", "path", "mud", "stone", "water", "wood", "foliage", "cliff"):
            self._ramp(name, self.style[name])
        self._ramp("marble", self.style.get("marble", self.style["stone"]))
        for i, fl in enumerate(self.style["flowers"]):
            self._ramp("flower%d" % i, fl)
        self.rid = np.zeros((self.h, self.w), np.int32)
        self.idx = np.zeros((self.h, self.w), np.int32)

    def _ramp(self, name, colors):
        self.ramp_ids[name] = len(self.ramps)
        self.ramps.append(colors)

    def n(self, name):
        return len(self.ramps[self.ramp_ids[name]])

    def put(self, mask, name, value, contrast=2.5, dither=True):
        idx = pa.quantize(value, self.n(name), contrast, dither)
        self.rid[mask] = self.ramp_ids[name]
        self.idx[mask] = idx[mask]

    def noise(self, cell, octaves=2):
        return pa.value_noise(self.h, self.w, cell, self.rng, octaves)

    def labels(self):
        score = np.full((len(MATERIALS), self.h, self.w), -9.0, np.float32)
        ragged = centered(self.noise(6)) * 0.75 + centered(self.noise(2, 1)) * 0.25
        # puddle cells blend like the path they lie on; the puddle itself is drawn below
        cells = np.where(self.cells == M["puddle"], M["path"], self.cells)
        for name, i in M.items():
            onehot = (cells == i).astype(np.float32)
            if not onehot.any():
                continue
            if name in SMOOTH:
                continue
            if name in SOFT:
                amp, bias = SOFT[name]
                own = centered(self.noise(6)) * 0.75 + centered(self.noise(2, 1)) * 0.25
                score[i] = pa.box_blur(up(onehot), BLUR, 3) + (own * 0.6 + ragged * 0.4) * amp + bias
            else:
                score[i] = up(onehot) * 3.0 - 1.0
        lab = np.argmax(score, 0)
        for name, (blur, threshold) in SMOOTH.items():
            onehot = (cells == M[name]).astype(np.float32)
            if onehot.any():
                smooth = pa.box_blur(up(onehot), blur, 3) + centered(self.noise(3, 1)) * 0.02
                lab = np.where(smooth > threshold, M[name], lab)
        # puddles: flat irregular ellipses on top of whatever ground the soft blend chose
        wobble = centered(self.noise(3, 1))
        yy, xx = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        for cy, cx in zip(*np.nonzero(self.cells == M["puddle"])):
            py = cy * T + 8 + self.rng.uniform(-2, 2)
            px = cx * T + 8 + self.rng.uniform(-2, 2)
            ry, rx = self.rng.uniform(3.0, 4.5), self.rng.uniform(7.0, 10.0)
            y0, y1, x0, x1 = int(py - 8), int(py + 9), int(px - 14), int(px + 15)
            e = ((yy[y0:y1, x0:x1] - py) / ry) ** 2 + ((xx[y0:y1, x0:x1] - px) / rx) ** 2
            inside = e + wobble[y0:y1, x0:x1] * 0.35 < 1.0
            lab[y0:y1, x0:x1][inside] = M["puddle"]
        return lab

    # ------------------------------------------------------------------ materials
    def bake(self):
        lab = self.labels()
        self.lab = lab
        is_ = {name: lab == i for name, i in M.items()}
        self._grass(is_["grass"] | is_["puddle"])
        self._path(is_["path"])
        self._mud(is_["mud"] | is_["puddle"])
        self._cobble(is_["cobble"])
        self._planks(is_)
        self._marble(is_["marble"])
        self._stairs(is_["stairs"])
        deep = self._water(is_)
        self._fall(is_["fall"])
        self._puddles(is_["puddle"])
        self._edges(is_)
        self._meadow(is_["grass"])
        self._grass_clumps(is_["grass"])
        self._hedge(lab)
        self._cliff(lab)
        self._prop_shadows()

        table = np.zeros((len(self.ramps), 6, 3), np.float32)
        for i, r in enumerate(self.ramps):
            table[i, :len(r)] = r
            table[i, len(r):] = r[-1]
        idx = np.clip(self.idx, 0, 5)
        for i, r in enumerate(self.ramps):
            sel = self.rid == i
            idx[sel] = np.clip(idx[sel], 0, len(r) - 1)
        rgb = table[self.rid, idx]
        alpha = np.where(self.lab == M["void"], 0.0, 255.0)
        # waterfalls dropping into the sky fade out over the last cells of the map (dithered)
        fall = self.lab == M["fall"]
        b = pa.BAYER4[np.arange(self.h)[:, None] % 4, np.arange(self.w)[None, :] % 4]
        fade = np.clip((self.h - np.arange(self.h)[:, None]) / (3.0 * T), 0, 1)
        alpha = np.where(fall & (fade < b), 0.0, alpha)
        ground = np.concatenate([rgb, alpha[..., None]], -1)
        water = np.zeros((self.h, self.w, 4), np.float32)
        wt, pd = self.lab == M["water"], self.lab == M["puddle"]
        water[..., 0] = (wt | pd | fall) * 255.0
        water[..., 1] = deep * 255.0 * wt + fall * 128.0
        # B: 255 puddle, 128 waterfall, 0 open water
        water[..., 2] = pd * 255.0 + fall * 128.0
        water[..., 3] = 255.0
        return ground, water

    def _grass(self, g):
        big = self.noise(36, 3)
        mid = self.noise(11, 2)
        v = 0.5 + 0.13 * centered(big) + 0.07 * centered(mid)
        self.put(g, "grass", v, contrast=3.0)
        # tufts in loose clusters: shapes, not per-pixel noise
        n = self.h * self.w // 420
        cy = self.rng.integers(3, self.h - 3, n)
        cx = self.rng.integers(3, self.w - 3, n)
        dens = self.noise(20, 1)
        gid = self.ramp_ids["grass"]
        for y0, x0 in zip(cy, cx):
            k = 2 + int(dens[y0, x0] * 6)
            for _ in range(k):
                y = int(y0 + self.rng.normal(0, 3.0))
                x = int(x0 + self.rng.normal(0, 4.0))
                stamp = TUFTS[self.rng.integers(len(TUFTS))]
                for dy, dx, d in stamp:
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < self.h and 0 <= xx < self.w and g[yy, xx] and self.rid[yy, xx] == gid:
                        self.idx[yy, xx] = min(max(self.idx[yy, xx] + d, 0), 4)
        if self.style_name == "elysia":
            m = self.h * self.w // 700
            ys = self.rng.integers(1, self.h - 2, m)
            xs = self.rng.integers(1, self.w - 1, m)
            for y, x in zip(ys, xs):
                if g[y, x] and g[y + 1, x]:
                    k = self.rng.integers(len(self.style["flowers"]))
                    self.rid[y, x], self.idx[y, x] = self.ramp_ids["flower%d" % k], 2
                    self.idx[y + 1, x] = max(self.idx[y + 1, x] - 1, 0)

    def _path(self, p):
        soft = pa.box_blur(p.astype(np.float32), 5)
        v = 0.5 + 0.1 * centered(self.noise(14)) + 0.2 * (soft - 0.5)
        self.put(p, "path", v, contrast=3.0)
        f1, _, cid = pa.worley(self.h, self.w, 6, self.rng, 0.9)
        pick = (cid % 100) < 30
        size = 1.0 + (cid % 7) / 6.0
        peb = (f1 < size) & pick & p
        lit = pa.bump_light(np.clip(size - f1, 0, 2) * pick, 1.4)
        pid = np.where(lit > 0.56, 4, np.where(lit < 0.44, 1, 3))
        self.idx[peb] = pid[peb]

    def _mud(self, md):
        v = 0.47 + 0.12 * centered(self.noise(9)) + 0.06 * centered(self.noise(3, 1))
        self.put(md, "mud", v, contrast=2.0)
        sheen = (self.noise((2, 5), 1) > 0.84) & md
        self.idx[sheen] = 3

    def _cobble(self, cb):
        if not cb.any():
            return
        f1, f2, cid = pa.worley(self.h, self.w, 6, self.rng, 0.75)
        gap = f2 - f1
        height = np.clip((gap - 0.9) / 2.5, 0, 1)
        light = pa.bump_light(height * 2.5)
        tone = ((cid * 7919) % 97) / 97.0
        v = 0.56 + 0.08 * centered(tone) + 0.4 * (light - 0.5)
        v = np.where(gap < 1.1, 0.04, v)
        self.put(cb, "stone", v, contrast=2.5)
        # curb: light ring of edge stones with a dark outer line
        edge = near(~cb, 2) & cb
        self.idx[edge] = 3
        self.idx[near(~cb, 1) & cb] = 4
        self.idx[shift(~cb, -1, 0) & cb] = 1
        out = near(cb, 1) & ~cb & (self.lab != M["water"])
        self.rid[out] = self.ramp_ids["stone"]
        self.idx[out] = 0

    def _planks(self, is_):
        for name, vertical in (("planks_v", True), ("planks_h", False)):
            pk = is_[name]
            if not pk.any():
                continue
            yy, xx = np.mgrid[0:self.h, 0:self.w]
            along, across = (yy, xx) if vertical else (xx, yy)
            board = across // 5
            seam = (across % 5) == 4
            grain = self.noise((9, 1) if vertical else (1, 9), 2)
            btone = ((board * 2654435761) % 89) / 89.0
            v = 0.56 + 0.1 * centered(btone) + 0.14 * centered(grain)
            self.put(pk, "wood", v, contrast=2.0)
            self.idx[seam & pk] = 0
            nail = (((along % 16) == 2) | ((along % 16) == 13)) & ((across % 5) == 2)
            self.idx[nail & pk] = 1
            ahead = (1, 0) if vertical else (0, 1)
            start = pk & ~shift(pk, ahead[0], ahead[1])
            end = pk & ~shift(pk, -ahead[0], -ahead[1])
            self.idx[start] = 4
            self.idx[end] = 0
            self.idx[shift(end, -1, 0) & pk & ~end] = 1
            self.planks = pk if not hasattr(self, "planks") else self.planks | pk

    def _marble(self, mb):
        """White stone slabs in staggered rows with a bright curb (Elysia's architecture)."""
        if not mb.any():
            return
        yy, xx = np.mgrid[0:self.h, 0:self.w]
        row = yy // 8
        slab = (xx + (row % 2) * 6) // 12
        tone = ((row * 7919 + slab * 104729) % 97) / 97.0
        v = 0.66 + 0.08 * centered(tone) + 0.05 * centered(self.noise(9))
        seam = ((yy % 8) == 7) | (((xx + (row % 2) * 6) % 12) == 11)
        v = np.where(seam, 0.38, v)
        v = np.where(((yy % 8) == 0) & ~seam, v + 0.12, v)
        self.put(mb, "marble", v, contrast=3.0, dither=False)
        edge = near(~mb, 2) & mb
        self.idx[edge] = 4
        self.idx[near(~mb, 1) & mb] = 3
        self.idx[shift(~mb, -1, 0) & mb] = 1
        low = shift(mb, 1, 0) & ~mb & ~near(self.lab == M["water"], 0)
        self.rid[low] = self.ramp_ids["marble"]
        self.idx[low] = 0

    def _stairs(self, st):
        """Stone steps down a cliff: light treads, dark risers, darker side walls."""
        if not st.any():
            return
        yy = np.mgrid[0:self.h, 0:self.w][0]
        v = np.where((yy % 5) == 4, 0.15, np.where((yy % 5) == 0, 0.85, 0.62))
        ramp_name = "marble" if "marble" in self.style else "stone"
        self.put(st, ramp_name, v, contrast=3.0, dither=False)
        walls = st & (near(~st, 2) & ~(shift(~st, 2, 0) | shift(~st, -2, 0)))
        self.idx[walls] = 1
        self.idx[st & near(~st, 0) & ~shift(st, 0, 1)] = 0
        self.idx[st & ~shift(st, 0, -1)] = 0

    def _fall(self, fl):
        """Waterfall: vertical streaks, white lip on top, foam where it lands."""
        if not fl.any():
            return
        col = (self.noise((40, 1), 1) * 3).astype(int)
        v = 0.45 + 0.13 * col + 0.08 * centered(self.noise((14, 1), 1))
        self.put(fl, "water", np.clip(v, 0, 1), contrast=3.0, dither=False)
        self.idx[fl & ~shift(fl, 1, 0)] = 4
        self.idx[fl & ~shift(fl, 2, 0) & shift(fl, 1, 0)] = 3
        self.idx[fl & (~shift(fl, 0, 1) | ~shift(fl, 0, -1))] = 1
        # foam where the fall lands: bright core, dithered spray around it
        pool = self.lab == M["water"]
        core = pool & within_below(fl, 4)
        spray = pool & near(core, 3) & ~core
        b = pa.BAYER4[np.arange(self.h)[:, None] % 4, np.arange(self.w)[None, :] % 4]
        self.idx[core] = 4
        self.idx[spray & (b < 0.6)] = 4
        self.idx[spray & (b >= 0.6)] = 3

    def _water(self, is_):
        wt = is_["water"]
        depth = pa.box_blur(wt.astype(np.float32), 9)
        deep = np.clip((depth - 0.5) * 2.0, 0, 1)
        v = 0.8 - 0.68 * deep + 0.05 * centered(self.noise(12))
        self.put(wt, "water", v, contrast=2.0)
        planks = getattr(self, "planks", np.zeros_like(wt))
        land = ~wt & ~is_["void"] & ~planks & ~is_["fall"]
        bank = within_below(land, 4) & wt
        self.idx[bank] = np.maximum(self.idx[bank] - 1, 0)
        self.idx[within_below(land, 2) & wt] = 0
        foam = near(land, 1) & wt & ~within_below(land, 3)
        self.idx[foam] = 4
        under_bridge = within_below(planks, 5) & wt
        self.idx[under_bridge] = np.maximum(self.idx[under_bridge] - 2, 0)
        glint = (self.noise((1, 7), 1) > 0.9) & (deep > 0.25) & wt
        self.idx[glint] = 3
        return deep

    def _puddles(self, pd):
        if not pd.any():
            return
        # dark sky reflection, a light streak, dark bank on top and a wet light rim below
        v = 0.42 + 0.06 * centered(self.noise(5))
        self.put(pd, "water", v, contrast=2.0)
        streak = pd & (self.noise((1, 5), 1) > 0.62) & shift(pd, 2, 0) & shift(pd, -1, 0)
        self.idx[streak] = 3
        self.idx[pd & ~shift(pd, 1, 0)] = 0
        mud = self.ramp_ids["mud"]
        top_rim = shift(pd, -1, 0) & ~pd
        low_rim = shift(pd, 1, 0) & ~pd
        side = (shift(pd, 0, 1) | shift(pd, 0, -1)) & ~pd & ~top_rim & ~low_rim
        for mask, i in ((top_rim, 0), (side, 1), (low_rim, 3)):
            self.rid[mask], self.idx[mask] = mud, i

    def _edges(self, is_):
        g = is_["grass"]
        low = is_["path"] | is_["mud"] | is_["cobble"]
        self.idx[within_below(g, 1) & low] -= 2
        self.idx[(within_below(g, 3) & ~within_below(g, 1)) & low] -= 1
        lip = g & shift(low, -1, 0)
        self.idx[lip] = np.minimum(self.idx[lip] + 1, 4)
        self.idx[:] = np.maximum(self.idx, 0)

    def _grass_clumps(self, g):
        """Leafy bright grass clumps in patches (lush detail like hand-made tilesets)."""
        density = self.noise(26, 2)
        area = g & ~near(~g, 5)
        blobs = []
        for cy in range(4, self.h - 4, 9):
            for cx in range(4, self.w - 4, 9):
                y = int(cy + self.rng.uniform(-4, 4))
                x = int(cx + self.rng.uniform(-4, 4))
                if not area[y, x] or self.meadow_cells[y // T, x // T] > 0:
                    continue
                if density[y, x] < 0.58 or self.rng.random() < 0.35:
                    continue
                for _ in range(self.rng.integers(2, 6)):
                    blobs.append((y + self.rng.uniform(-3, 3), x + self.rng.uniform(-5, 5),
                                  self.rng.uniform(2.6, 4.0)))
        if not blobs:
            return
        alpha, value = pa.render_foliage((self.h, self.w), blobs, self.rng, small=(2.0, 3.0))
        alpha &= area
        gid = self.ramp_ids["grass"]
        idx = pa.quantize(np.clip(value * 0.8 + 0.28, 0, 1), self.n("grass"), 3.0, dither=False)
        self.rid[alpha] = gid
        self.idx[alpha] = idx[alpha]
        # dark outline below and right of each clump
        rim = (shift(alpha, 1, 0) | shift(alpha, 0, 1)) & ~alpha & g
        self.idx[rim] = 0

    def _meadow(self, g):
        if self.meadow_cells.sum() == 0:
            return
        density = pa.box_blur(up(self.meadow_cells), 6) + centered(self.noise(6)) * 0.3
        area = g & (density > 0.5)
        blobs = []
        for cy in range(0, self.h, 5):
            for cx in range(0, self.w, 5):
                y = cy + self.rng.uniform(-2, 2)
                x = cx + self.rng.uniform(-2, 2)
                iy, ix = int(np.clip(y, 0, self.h - 1)), int(np.clip(x, 0, self.w - 1))
                if area[iy, ix]:
                    blobs.append((y, x, self.rng.uniform(2.6, 4.2)))
        _, alpha, value = pa.render_blobs((self.h, self.w), blobs, self.style["foliage"], self.rng,
                                          leaf_cell=3)
        bush = alpha & g
        idx = pa.quantize(np.clip(value + 0.12, 0, 1), self.n("foliage"), 2.0)
        self.rid[bush] = self.ramp_ids["foliage"]
        self.idx[bush] = idx[bush]
        # blossoms on the upper half of each little bush, colors in drifts
        drift = self.noise(18, 1)
        nfl = len(self.style["flowers"])
        for y, x, r in sorted(blobs):
            if self.rng.random() < 0.15:
                continue
            fy, fx = int(y - r * 0.4), int(x + self.rng.uniform(-1, 1))
            if not (1 <= fy < self.h - 1 and 1 <= fx < self.w - 1):
                continue
            k = int(drift[fy, fx] * nfl) % nfl if self.rng.random() < 0.85 else self.rng.integers(nfl)
            fid = self.ramp_ids["flower%d" % k]
            for dy, dx, i in ((0, 0, 2), (-1, 0, 1), (1, 0, 0), (0, -1, 1), (0, 1, 0)):
                self.rid[fy + dy, fx + dx], self.idx[fy + dy, fx + dx] = fid, i
        # soft shadow under the meadow edge
        sh = within_below(bush, 1) & g & ~bush
        self.idx[sh] = np.maximum(self.idx[sh] - 1, 0)

    def _hedge(self, lab):
        hd = lab == M["hedge"]
        if not hd.any():
            return
        blobs = []
        for cy in range(0, self.h, 8):
            for cx in range(0, self.w, 8):
                y = cy + self.rng.uniform(-3, 3)
                x = cx + self.rng.uniform(-3, 3)
                iy, ix = int(np.clip(y, 0, self.h - 1)), int(np.clip(x, 0, self.w - 1))
                if hd[iy, ix]:
                    blobs.append((y, x, self.rng.uniform(6.5, 11.0)))
        reach = pa.box_blur(hd.astype(np.float32), 5) + centered(self.noise(5)) * 0.2
        clip = (hd | (reach > 0.12)) & (lab != M["void"]) & (lab != M["cliff"]) & (lab != M["fall"])
        alpha, value = pa.render_foliage((self.h, self.w), blobs, self.rng, clip=clip)
        fid = self.ramp_ids["foliage"]
        self.rid[hd] = fid
        self.idx[hd] = 0
        idx = pa.quantize(value, self.n("foliage"), 3.0, dither=False)
        self.rid[alpha] = fid
        self.idx[alpha] = idx[alpha]
        cover = alpha | hd
        below = within_below(cover, 6) & ~cover & (lab != M["void"])
        b = pa.BAYER4[np.arange(self.h)[:, None] % 4, np.arange(self.w)[None, :] % 4]
        d1 = within_below(cover, 2) & below
        self.idx[d1] -= 2
        self.idx[below & ~d1 & (b < 0.55)] -= 1
        side = near(cover, 2) & ~cover & ~below & (lab != M["void"])
        self.idx[side] -= 1
        self.idx[:] = np.maximum(self.idx, 0)

    def _prop_shadows(self):
        """Soft palette shadows under trees, rocks and furniture (light from the top left)."""
        b = pa.BAYER4[np.arange(self.h)[:, None] % 4, np.arange(self.w)[None, :] % 4]
        yy, xx = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        for cy, cx, (rx, ry) in self.shadows:
            y0, y1 = max(int(cy - ry - 2), 0), min(int(cy + ry + 3), self.h)
            x0, x1 = max(int(cx - rx - 2), 0), min(int(cx + rx + 4), self.w)
            e = ((yy[y0:y1, x0:x1] + 0.5 - cy) / ry) ** 2 + ((xx[y0:y1, x0:x1] + 0.5 - cx - 2) / rx) ** 2
            core = e < 0.55
            rim = (e < 1.0) & ~core & (b[y0:y1, x0:x1] < 0.6)
            sub = self.idx[y0:y1, x0:x1]
            sub[core] -= 2
            sub[rim] -= 1
            np.maximum(sub, 0, out=sub)

    def _cliff(self, lab):
        """Cliff faces in layered stone (wide flat slabs), a rounded grass cap with hanging
        vines on top, ambient occlusion under the cap and a contact shadow at the foot."""
        cl = lab == M["cliff"]
        if not cl.any():
            return
        f1, f2, cid = pa.worley(self.h, self.w, (7, 16), self.rng, 0.7)
        slab = np.clip((f2 - f1) / 2.2, 0, 1)
        light = pa.bump_light(slab * 2.2, 1.2)
        tone = ((cid * 7919) % 97) / 97.0
        top = np.zeros((self.h, self.w), np.float32)
        run = np.zeros((self.h, self.w), np.float32)
        for x in range(self.w):
            col = cl[:, x]
            y = 0
            while y < self.h:
                if col[y]:
                    y0 = y
                    while y < self.h and col[y]:
                        y += 1
                    top[y0:y, x] = np.arange(y - y0)
                    run[y0:y, x] = y - y0
                else:
                    y += 1
        rel = np.where(run > 0, top / np.maximum(run, 1), 0)
        v = 0.74 - 0.42 * rel + 0.1 * centered(tone) + 0.5 * (light - 0.5)
        v = np.where(slab < 0.14, v - 0.26, v)
        v = np.where(top < 4, v - 0.22, v)
        v = np.where(top < 2, v - 0.2, v)
        self.put(cl, "cliff", np.clip(v, 0, 1), contrast=2.6, dither=False)
        # rounded grass cap: scallops of 8-14 px hanging over the edge, light rim on top
        grass = (lab == M["grass"]) | (lab == M["hedge"])
        gid = self.ramp_ids["grass"]
        fid = self.ramp_ids["foliage"]
        period = 11.0
        phase = self.noise((1, 30), 1) * 6.0
        vine = self.noise((1, 1), 1)
        for x in range(self.w):
            col = cl[:, x]
            for y0 in np.nonzero(col[1:] & ~col[:-1])[0] + 1:
                if not grass[y0 - 1, x]:
                    continue
                u = ((x + phase[y0, x] * period) % period) / (period / 2.0) - 1.0
                n = 3 + int(round(3.5 * np.sqrt(max(0.0, 1.0 - u * u))))
                for k in range(n):
                    if y0 + k < self.h and cl[y0 + k, x]:
                        self.rid[y0 + k, x] = gid
                        self.idx[y0 + k, x] = 3 if k < n - 2 else (2 if k < n - 1 else 1)
                # light rim on the grass right above the edge
                for k in (1, 2):
                    if y0 - k >= 0 and grass[y0 - k, x] and self.rid[y0 - k, x] == gid:
                        self.idx[y0 - k, x] = 4 if k == 1 else max(self.idx[y0 - k, x], 3)
                yb = y0 + n
                if yb < self.h and cl[yb, x]:
                    self.idx[yb, x] = 0
                # hanging vines here and there
                if vine[y0, x] > 0.93:
                    length = 5 + int(vine[min(y0 + 3, self.h - 1), x] * 14)
                    for k in range(length):
                        yy = yb + 1 + k
                        if yy < self.h and cl[yy, x]:
                            self.rid[yy, x] = fid
                            self.idx[yy, x] = 3 if k % 3 == 0 else 2
                            if k % 3 == 1 and x + 1 < self.w and cl[yy, x + 1]:
                                self.rid[yy, x + 1], self.idx[yy, x + 1] = fid, 4
        # jagged bottom above void: hanging rocks with a dark outline
        void = lab == M["void"]
        bottom = cl & shift(void, -1, 0)
        jag = (((cid * 104729) % 13) - 2).clip(0, 9)
        for x in range(self.w):
            for y in np.nonzero(bottom[:, x])[0]:
                cut = int(jag[y, x])
                if cut > 0:
                    self.lab[y - cut + 1:y + 1, x] = M["void"]
                self.idx[y - cut, x] = 0
        # contact shadow where the cliff meets ground below, darker right at the foot
        foot = within_below(cl, 4) & ~cl & (self.lab != M["void"]) & (self.lab != M["fall"])
        self.idx[foot] = np.maximum(self.idx[foot] - 1, 0)
        foot1 = within_below(cl, 1) & foot
        self.idx[foot1] = np.maximum(self.idx[foot1] - 1, 0)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("map")
    ap.add_argument("--seed", type=int, default=7)
    ap.add_argument("--preview-dir", help="also write <name>_preview.png (sky behind void) here")
    args = ap.parse_args()
    meta, symbols, rows = parse_map(args.map)
    if "ground" not in meta:
        sys.exit("map has no [meta] ground path: %s" % args.map)
    baker = Baker(meta, symbols, rows, args.seed)
    ground, water = baker.bake()
    pa.save_rgba(res_path(meta["ground"]), ground)
    if "water" in meta:
        pa.save_rgba(res_path(meta["water"]), water)
    print("baked %s -> %s (%dx%d)" % (args.map, meta["ground"], baker.w, baker.h))
    if args.preview_dir:
        from PIL import Image
        sky = np.array([150, 205, 235], np.float32) if baker.style_name == "elysia" else np.zeros(3)
        a = ground[..., 3:4] / 255.0
        prev = ground[..., :3] * a + sky * (1 - a)
        name = os.path.splitext(os.path.basename(args.map))[0]
        img = Image.fromarray(prev.clip(0, 255).astype(np.uint8))
        img.save(os.path.join(args.preview_dir, name + "_preview.png"))


if __name__ == "__main__":
    main()
