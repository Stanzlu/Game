#!/usr/bin/env python3
"""UI art for the Elysia skin and interactive objects (ADR-017/ADR-024): ornate gold 9-slice
panel, coin and sparkle icons, the glowing crack of the rift, Elysia's treasure chest
(closed/open) and the plain stone. The Real skin needs no art,
it is plain style boxes on purpose (Game Bible §34: "minimalistisch, ruhig, fast leer").
Also: item icons (16x16, assets/generated/items/<item id>.png), light rays behind rewards,
the quest marker, and the title logo.

Usage: .venv/bin/python tools/art/make_ui.py [--preview x.png]
"""
import argparse
import os

import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "ui")
OBJECTS = os.path.join(ROOT, "assets", "generated", "objects")
ITEMS = os.path.join(ROOT, "assets", "generated", "items")

GOLD_HI = (255, 240, 176, 255)
GOLD = (242, 200, 96, 255)
GOLD_MID = (204, 150, 56, 255)
GOLD_LO = (130, 84, 32, 255)
INK = (40, 22, 14, 255)
GEM = (120, 230, 240, 255)
GEM_HI = (230, 255, 255, 255)
PINK = (250, 150, 210, 255)


def save(name, img, folder=OUT):
    os.makedirs(folder, exist_ok=True)
    img.save(os.path.join(folder, name))
    print(os.path.join(folder, name), img.size)


def panel(size=32, corner=10):
    """Ornate frame: violet gradient, double gold border with bevel, gems in the corners."""
    a = np.zeros((size, size, 4), np.uint8)
    for y in range(size):
        t = y / (size - 1)
        a[y, :, :3] = np.array([34, 24, 58]) * (1 - t) + np.array([24, 18, 44]) * t
    a[..., 3] = 236
    # outer dark line, bright gold rim (light from top-left), inner thin line
    a[0, :], a[-1, :], a[:, 0], a[:, -1] = INK, INK, INK, INK
    a[1, 1:-1] = GOLD_HI
    a[1:-1, 1] = GOLD
    a[-2, 1:-1] = GOLD_LO
    a[1:-1, -2] = GOLD_MID
    a[1, 1] = GOLD_HI
    a[2, 2:-2] = INK
    a[-3, 2:-2] = INK
    a[2:-2, 2] = INK
    a[2:-2, -3] = INK
    a[4, 4:-4] = GOLD_MID
    a[-5, 4:-4] = GOLD_LO
    a[4:-4, 4] = GOLD_MID
    a[4:-4, -5] = GOLD_LO
    # corner ornaments: gold square with a gem, mirrored into all four corners
    orn = np.zeros((corner, corner, 4), np.uint8)
    orn[1:8, 1:8] = INK
    orn[2:7, 2:7] = GOLD
    orn[2, 2:7] = GOLD_HI
    orn[2:7, 2] = GOLD_HI
    orn[6, 2:7] = GOLD_LO
    orn[2:7, 6] = GOLD_LO
    orn[3:6, 3:6] = GEM
    orn[3, 3] = GEM_HI
    orn[5, 5] = (60, 140, 170, 255)
    for flip_y in (False, True):
        for flip_x in (False, True):
            o = orn[::-1] if flip_y else orn
            o = o[:, ::-1] if flip_x else o
            ys = slice(size - corner, size) if flip_y else slice(0, corner)
            xs = slice(size - corner, size) if flip_x else slice(0, corner)
            region = a[ys, xs]
            mask = o[..., 3] > 0
            region[mask] = o[mask]
    return Image.fromarray(a, "RGBA")


def coin(size=7):
    a = np.zeros((size, size, 4), np.uint8)
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            d = ((x - c) ** 2 + (y - c) ** 2) ** 0.5
            if d <= c + 0.3:
                a[y, x] = INK
            if d <= c - 0.7:
                a[y, x] = GOLD if (x + y) < size else GOLD_MID
    a[2, 2] = GOLD_HI
    a[2, 3] = GOLD_HI
    a[3, 2] = GOLD_HI
    return Image.fromarray(a, "RGBA")


def sparkle(size=7, color=(255, 250, 220, 255)):
    a = np.zeros((size, size, 4), np.uint8)
    c = size // 2
    for i in range(size):
        fade = 255 - abs(i - c) * 60
        a[c, i] = (*color[:3], fade)
        a[i, c] = (*color[:3], fade)
    a[c, c] = (255, 255, 255, 255)
    return Image.fromarray(a, "RGBA")


def rift(width=22, height=60, seed=5):
    """A thin vertical crack in the air: white core, cyan and violet glow, jagged path."""
    rng = np.random.default_rng(seed)
    a = np.zeros((height, width, 4), np.float64)
    x = width / 2
    path = []
    for y in range(height):
        x += rng.normal(0, 0.55)
        x = min(max(x, 6), width - 7)
        path.append(x)
    for y in range(height):
        taper = np.sin(np.pi * (y + 0.5) / height) ** 0.6
        for xx in range(width):
            d = abs(xx - path[y])
            glow = np.exp(-d / (2.6 * taper + 0.1)) * taper
            core = 1.0 if d < 0.8 * taper + 0.3 else 0.0
            col = np.array([0.55, 0.45, 1.0]) * glow + np.array([0.4, 0.95, 1.0]) * glow ** 2
            col = np.clip(col + core, 0, 1)
            alpha = np.clip(glow * 1.3 + core, 0, 1)
            a[y, xx] = (*col, alpha)
    q = (a * 255).round().astype(np.uint8)
    # quantize alpha to a few steps so it stays pixel art
    raw = q[..., 3].astype(np.int32)
    q[..., 3] = np.where(raw < 48, 0, np.minimum((raw // 64) * 64 + 63, 255)).astype(np.uint8)
    return Image.fromarray(q, "RGBA")


def chest():
    """Elysia's chest, 18x16 per frame, two frames side by side: closed, open (with glow)."""
    w, h = 18, 16
    frames = []
    for open_ in (False, True):
        a = np.zeros((h, w, 4), np.uint8)
        body_top = 7
        # body: white-violet wood with gold bands
        a[body_top:h - 1, 1:w - 1] = (236, 228, 250, 255)
        a[body_top:h - 1, 1] = (190, 172, 220, 255)
        a[h - 3:h - 1, 1:w - 1] = (200, 186, 230, 255)
        for x in (4, w - 5):
            a[body_top:h - 1, x] = GOLD
            a[body_top:h - 1, x + 1] = GOLD_MID
        a[body_top, 1:w - 1] = GOLD_HI
        # lock
        a[body_top + 2:body_top + 5, w // 2 - 1:w // 2 + 1] = GOLD
        a[body_top + 3, w // 2 - 1] = GEM
        if open_:
            # lid tilted back, warm light spilling out
            a[2:5, 2:w - 2] = (206, 190, 236, 255)
            a[2, 2:w - 2] = GOLD_HI
            a[5:body_top, 2:w - 2] = (255, 236, 150, 255)
            a[4:body_top, 4:w - 4] = (255, 250, 210, 255)
        else:
            a[3:body_top, 1:w - 1] = (226, 214, 246, 255)
            a[3, 2:w - 2] = GOLD_HI
            a[2, 3:w - 3] = GOLD
            for x in (4, w - 5):
                a[3:body_top, x] = GOLD
        # outline
        alpha = a[..., 3] > 0
        out = np.zeros_like(alpha)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            out |= np.roll(np.roll(alpha, dy, 0), dx, 1)
        a[out & ~alpha] = (60, 34, 70, 255)
        frames.append(a)
    return Image.fromarray(np.concatenate(frames, axis=1), "RGBA")


def stone():
    """An unremarkable grey stone, 8x6 (rarity: none)."""
    a = np.zeros((6, 8, 4), np.uint8)
    shape = ["..####..", ".######.", "########", "########", ".######.", "..####.."]
    for y, row in enumerate(shape):
        for x, c in enumerate(row):
            if c == "#":
                shade = 150 - 12 * y + (8 if x < 4 else -6)
                a[y, x] = (shade, shade, shade + 6, 255)
    a[1, 2] = (196, 196, 204, 255)
    a[0, 2:6] = (70, 70, 80, 255)
    a[5, 2:6] = (60, 60, 70, 255)
    a[1:5, 0] = (70, 70, 80, 255)
    a[1:5, 7] = (60, 60, 70, 255)
    return Image.fromarray(a, "RGBA")


def from_ascii(rows, palette):
    """Pixel icon from ASCII rows; '.' is transparent, other characters index the palette."""
    h, w = len(rows), len(rows[0])
    a = np.zeros((h, w, 4), np.uint8)
    for y, row in enumerate(rows):
        assert len(row) == w, (row, w)
        for x, c in enumerate(row):
            if c != ".":
                a[y, x] = palette[c]
    return Image.fromarray(a, "RGBA")


ICON_COMPLIMENT = [
    "................",
    "..oooo....oooo.*",
    ".oPPPPo..oPPPPo.",
    "oPHHPPPooPPPPPPo",
    "oPHHPPPPPPPPPPdo",
    "oPHPPPPPPPPPPPdo",
    "oPPPPPPPPPPPPddo",
    ".oPPPPPPPPPPPdo.",
    "..oPPPPPPPPPddo.",
    "...oPPPPPPPddo..",
    "....oPPPPPddo...",
    ".....oPPPddo....",
    "......oPddo.....",
    ".......oo.......",
    "................",
    "................",
]
ICON_STONE = [
    "................",
    "................",
    "................",
    "................",
    ".....oooooo.....",
    "...ooLLLggggo...",
    "..oLHLLgggggdo..",
    ".oLLLggggggggdo.",
    ".oLgggggggsgddo.",
    ".ogggsgggggdddo.",
    ".oggggggggddddo.",
    "..odggggdddddo..",
    "...oodddddddo...",
    ".....ooooooo....",
    "................",
    "................",
]
ICON_SEED = [
    "................",
    ".........G......",
    "........GGo.....",
    ".......oGo......",
    "......oBBBo.....",
    ".....oBLBBBo....",
    "....oBLLBBBBo...",
    "....oBLBBBBBo...",
    "...oBBLBBBBBdo..",
    "...oBBBBBBBBdo..",
    "...oBBBBBBBddo..",
    "....oBBBBBddo...",
    "....oBBBBddo....",
    ".....oBdddo.....",
    "......oooo......",
    "................",
]
QUEST_MARK = [
    ".oooo.",
    "oYYYYo",
    "oYHYYo",
    "oYYYYo",
    ".oYYo.",
    ".oYYo.",
    ".oYdo.",
    "..oo..",
    ".oooo.",
    "oYHYYo",
    "oYYddo",
    ".oooo.",
]


def item_icons():
    pink = {"o": (90, 20, 60, 255), "P": (255, 120, 180, 255), "H": (255, 230, 245, 255),
            "d": (200, 60, 130, 255), "*": (255, 250, 200, 255)}
    grey = {"o": (40, 40, 48, 255), "L": (176, 176, 186, 255), "H": (226, 226, 232, 255),
            "g": (136, 136, 148, 255), "s": (110, 110, 122, 255), "d": (96, 96, 108, 255)}
    seed = {"o": (54, 32, 20, 255), "B": (150, 96, 56, 255), "L": (204, 150, 96, 255),
            "d": (108, 66, 38, 255), "G": (120, 196, 90, 255)}
    return {
        "item_compliment.png": from_ascii(ICON_COMPLIMENT, pink),
        "item_stone.png": from_ascii(ICON_STONE, grey),
        "item_seed.png": from_ascii(ICON_SEED, seed),
    }


def quest_mark():
    pal = {"o": INK, "Y": GOLD, "H": GOLD_HI, "d": GOLD_MID}
    return from_ascii(QUEST_MARK, pal)


def rays(size=96, count=12, seed=2):
    """Soft light rays from the centre, white; tinted and rotated in the game."""
    rng = np.random.default_rng(seed)
    y, x = np.mgrid[0:size, 0:size] - (size - 1) / 2
    r = np.hypot(x, y) / (size / 2)
    ang = np.arctan2(y, x)
    widths = rng.uniform(0.35, 0.6, count)
    beam = np.zeros_like(r)
    for i in range(count):
        a0 = 2 * np.pi * i / count
        d = np.angle(np.exp(1j * (ang - a0)))
        beam = np.maximum(beam, np.clip(1 - np.abs(d) / (widths[i] * np.pi / count), 0, 1))
    glow = np.exp(-r * 2.2)
    alpha = np.clip(beam * (1 - r) * 0.9 + glow * 0.6, 0, 1) * (r < 1)
    # quantize to a few steps (pixel-art light)
    alpha = np.round(alpha * 6) / 6
    a = np.zeros((size, size, 4), np.uint8)
    a[..., :3] = 255
    a[..., 3] = (alpha * 255).astype(np.uint8)
    return Image.fromarray(a, "RGBA")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--preview")
    args = parser.parse_args()
    images = {
        "elysia_panel.png": panel(),
        "coin.png": coin(),
        "sparkle.png": sparkle(),
        "rift.png": rift(),
        "rays.png": rays(),
        "rays_large.png": rays(size=320, count=16, seed=4),
        "quest_mark.png": quest_mark(),
    }
    for name, img in images.items():
        save(name, img)
    save("chest.png", chest(), OBJECTS)
    save("stone.png", stone(), OBJECTS)
    for name, icon in item_icons().items():
        save(name, icon, ITEMS)
    if args.preview:
        sheet = Image.new("RGBA", (200, 80), (60, 60, 70, 255))
        x = 4
        for img in images.values():
            sheet.alpha_composite(img, (x, 4))
            x += img.width + 8
        sheet.resize((800, 320), Image.NEAREST).save(args.preview)
