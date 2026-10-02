#!/usr/bin/env python3
"""Procedural character sheet for the look prototype (ADR-017).

Layout matches entities/character/character_sheet.gd: one row per state and facing
(state-major; facings in Facing.Dir order E, SE, S, SW, W, NW, N, NE), frames left to right.
West-facing rows are mirrored east-facing ones. Frame size 24x32, feet on y=30.

Usage: .venv/bin/python tools/art/make_character.py [--preview scratch/player.png]
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixelart as pa  # noqa: E402
from make_sprites import Canvas  # noqa: E402
from pixelart import ramp  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FW, FH = 24, 32
FEET = 30
STATES = [("idle", 2), ("walk", 4), ("run", 4), ("sit", 1)]
FACINGS = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]

PLAYER = {
    "skin": ramp("#8c4f42", "#c47d62", "#eab08a", "#ffd9b8"),
    "hair": ramp("#2a1a1f", "#4f2c26", "#7d4730", "#a8693d"),
    "top": ramp("#16364a", "#1f5e74", "#2f8f98", "#6cc6b8"),
    "belt": ramp("#2a1d1d", "#4a3328", "#6d4c38", "#8f6a4d"),
    "pants": ramp("#3d3550", "#6a6180", "#a39ab0", "#d8d0d6"),
    "boots": ramp("#21161a", "#3f2a25", "#634232", "#86603f"),
    "eye": pa.hex_rgb("#1c1630"),
    "outline": pa.hex_rgb("#22172a"),
}


def pose(state, frame):
    """Per-frame offsets. leg/arm entries: (forward, lift). bob moves the upper body."""
    p = {"bob": 0, "legs": ((0, 0), (0, 0)), "arms": (0, 0), "sit": False, "lean": 0}
    if state == "idle":
        p["bob"] = frame
    elif state in ("walk", "run"):
        big = 2 if state == "run" else 1
        if frame in (0, 2):
            s = 1 if frame == 0 else -1
            p["legs"] = ((s * big, 0 if s > 0 else big), (-s * big, big if s > 0 else 0))
            p["arms"] = (-s * big, s * big)
        else:
            p["bob"] = -1
            p["legs"] = ((0, 1 if state == "run" else 0), (0, 1 if state == "run" else 0))
        p["lean"] = 1 if state == "run" else 0
    elif state == "sit":
        p["sit"] = True
        p["bob"] = 3
    return p


def limb(c, x0, y0, x1, y1, width):
    """Mask of a straight limb from (x0, y0) to (x1, y1), `width` pixels wide."""
    m = np.zeros((c.h, c.w), bool)
    steps = max(int(abs(y1 - y0)), int(abs(x1 - x0)), 1)
    for i in range(steps + 1):
        t = i / steps
        x = x0 + (x1 - x0) * t
        y = int(round(y0 + (y1 - y0) * t))
        xa = int(round(x - width / 2))
        if 0 <= y < c.h:
            m[y, max(xa, 0):max(xa + width, 0)] = True
    return m


def figure(facing, p, pal):
    c = Canvas(FW, FH)
    side = facing == "E"
    back = facing in ("N", "NE")
    three = facing in ("SE", "NE")
    b = p["bob"]
    lean = p["lean"] if side or three else 0
    cx = 12.5 if (side or three) else 12.0
    hip = 23 + b
    parts = []

    # legs (behind everything else)
    if p["sit"]:
        if side:
            for k, dx in enumerate((0, 1)):
                thigh = limb(c, cx - 1 + dx, hip, cx + 4 + dx, hip + 1, 3)
                shin = limb(c, cx + 4 + dx, hip + 1, cx + 4 + dx, FEET, 3)
                parts.append((thigh | shin, "pants", 0.45 + 0.15 * k))
        else:
            for lx in (cx - 2, cx + 2):
                leg = limb(c, lx, hip, lx, hip + 3, 3)
                boot = limb(c, lx, hip + 3, lx, hip + 5, 3)
                parts.append((leg, "pants", 0.55))
                parts.append((boot, "boots", 0.5))
    else:
        if side:
            order = [(1, -0.1), (0, 0.15)]  # back leg darker, drawn first
            for li, tint in order:
                fwd, lift = p["legs"][li]
                hx = cx - 0.5 + lean
                fx = cx - 0.5 + fwd * 2
                leg = limb(c, hx, hip, fx, FEET - lift, 3)
                boot = leg & (c.yy >= FEET - lift - 2)
                toe = c.rect(int(round(fx + 1)), FEET - lift - 1, int(round(fx + 3)), FEET - lift + 1)
                parts.append((leg & ~boot, "pants", 0.5 + tint))
                parts.append((boot | toe, "boots", 0.5 + tint))
        else:
            for li, lx in enumerate((cx - 2, cx + 2)):
                fwd, lift = p["legs"][li]
                dx = fwd * 0.5 if three else 0
                leg = limb(c, lx, hip, lx + dx, FEET - lift, 3)
                boot = leg & (c.yy >= FEET - lift - 2)
                parts.append((leg & ~boot, "pants", 0.55 - 0.1 * li))
                parts.append((boot, "boots", 0.55 - 0.1 * li))

    # arms behind the torso (side view far arm)
    ty0, ty1 = 15 + b, 23 + b
    if side:
        swing = p["arms"][1]
        far = limb(c, cx + lean, ty0 + 1, cx + lean + swing, ty0 + 7, 2)
        parts.append((far, "top", 0.2))
        parts.append((far & (c.yy >= ty0 + 6), "skin", 0.3))

    # torso
    if side:
        tx0, tx1 = cx - 3 + lean, cx + 3 + lean
    elif three:
        tx0, tx1 = cx - 4, cx + 3
    else:
        tx0, tx1 = cx - 4, cx + 4
    torso = c.rect(tx0, ty0, tx1, ty1)
    torso &= ~((c.yy == ty0) & ((c.xx < tx0 + 1) | (c.xx >= tx1 - 1)))
    hem = c.rect(tx0 - 0.5, ty1 - 1, tx1 + 0.5, ty1)
    parts.append((torso | hem, "top", ("cyl", tx0 - 1, tx1 + 1)))
    belt = c.rect(tx0, ty1 - 3, tx1, ty1 - 2)
    parts.append((belt, "belt", 0.45))
    if not back and not side:
        collar = c.rect(cx - 1.5, ty0, cx + 1.5, ty0 + 2) & ~c.rect(cx - 0.5, ty0 + 1, cx + 0.5, ty0 + 2)
        parts.append((collar, "top", 0.95))

    # near arms
    if side:
        swing = p["arms"][0]
        near = limb(c, cx - 0.5 + lean, ty0 + 1, cx - 0.5 + lean + swing, ty0 + 7, 2)
        parts.append((near, "top", 0.7, "line"))
        parts.append((near & (c.yy >= ty0 + 6), "skin", 0.6))
    else:
        for k, ax in enumerate((tx0 - 1, tx1 + 1)):
            swing = p["arms"][k]
            dy = swing if not three else swing
            arm = limb(c, ax, ty0 + 1, ax, ty0 + 6 + max(dy, -1), 2)
            hand = limb(c, ax, ty0 + 6 + max(dy, -1), ax, ty0 + 7 + max(dy, -1), 2)
            tone = 0.75 if k == 0 else 0.4
            if three and k == 1:
                tone = 0.3
            parts.append((arm, "top", tone, "line"))
            parts.append((hand, "skin", tone))

    # head
    hx = cx + (0.5 if side else 0) + lean
    hy = 9.5 + b
    head = c.ellipse(hx, hy, 6.5, 6.2)
    parts.append((head, "skin", ("sphere", hx - 1, hy - 1, 7, 7)))
    # hair: cap plus side locks; back views are all hair
    if back:
        hair = head | c.ellipse(hx, hy - 0.5, 7, 6.5)
        if facing == "NE":
            hair &= ~c.rect(hx + 4, hy + 1, hx + 7, hy + 6)
    elif side:
        hair = (c.ellipse(hx - 0.5, hy - 1, 7, 6.2) & ((c.yy < hy - 1.5) | (c.xx < hx - 0.5))) & head \
            | (c.ellipse(hx - 1, hy - 1.3, 7.2, 6.4) & (c.yy < hy - 1))
        hair |= c.rect(hx - 6, hy - 2, hx - 2, hy + 4) & c.ellipse(hx - 1, hy, 7, 7)
    else:
        cap = c.ellipse(hx, hy - 1.2, 7.1, 6.3) & (c.yy < hy - 1.5)
        fringe_x = (c.xx.astype(int) % 3) == (1 if facing == "S" else 0)
        fringe = c.rect(hx - 5, hy - 2, hx + 5, hy - 1) & fringe_x
        locks = c.rect(hx - 7, hy - 2, hx - 4.5, hy + 4) | c.rect(hx + 4.5, hy - 2, hx + 7, hy + 4)
        if three:
            locks = c.rect(hx - 7, hy - 2, hx - 4, hy + 4)
            cap = c.ellipse(hx - 0.5, hy - 1.2, 7.2, 6.3) & (c.yy < hy - 1.5)
        hair = cap | fringe | (locks & c.ellipse(hx, hy, 7.2, 7))
    parts.append((hair, "hair", ("hair", hx - 2, hy - 3, 8, 7)))

    for part in parts:
        mask, mat = part[0], part[1]
        shade = part[2]
        if isinstance(shade, tuple) and shade[0] == "cyl":
            v = 0.2 + 0.75 * c.cylinder(shade[1], shade[2])
        elif isinstance(shade, tuple) and shade[0] == "sphere":
            v = 0.25 + 0.7 * c.sphere(*shade[1:])
        elif isinstance(shade, tuple) and shade[0] == "hair":
            v = 0.12 + 0.62 * c.sphere(*shade[1:])
        else:
            v = shade
        c.paint(mask, pal[mat], v, contrast=3.0, dither=False)
        if len(part) > 3 and part[3] == "line":
            c.inner_line(mask, pal[mat][0])

    # face: eyes and a hint of cheeks
    if not back:
        ey = int(round(hy + 1.5))
        if side:
            eyes = [int(round(hx + 3))]
        elif three:
            eyes = [int(round(hx - 1)), int(round(hx + 3))]
        else:
            eyes = [int(round(hx - 3)), int(round(hx + 2))]
        for ex in eyes:
            c.fill(c.rect(ex, ey, ex + 1, ey + 2), pal["eye"])
        if not side:
            c.fill(c.rect(eyes[0] - 1, ey + 2, eyes[0], ey + 3), pal["skin"][1])
    c.outline(pal["outline"])
    return c


def sheet(pal):
    cols = max(n for _, n in STATES)
    rows = len(STATES) * len(FACINGS)
    out = np.zeros((rows * FH, cols * FW, 4), np.float32)
    row = 0
    for state, frames in STATES:
        for facing in FACINGS:
            for f in range(frames):
                src = {"W": "E", "SW": "SE", "NW": "NE"}.get(facing, facing)
                img = figure(src, pose(state, f), pal).rgba()
                if src != facing:
                    img = img[:, ::-1]
                out[row * FH:(row + 1) * FH, f * FW:(f + 1) * FW] = img
            row += 1
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--preview", help="write a scaled preview of all frames")
    args = ap.parse_args()
    data = sheet(PLAYER)
    path = os.path.join(ROOT, "assets", "generated", "characters", "player.png")
    pa.save_rgba(path, data)
    print("wrote", os.path.relpath(path, ROOT))
    if args.preview:
        from PIL import Image
        img = Image.fromarray(data.astype(np.uint8), "RGBA")
        # rearrange: one row per state, facings side by side
        prev = Image.new("RGBA", (8 * 4 * FW + 7 * 8, 4 * FH), (120, 170, 120, 255))
        r = 0
        for si, (state, frames) in enumerate(STATES):
            for fi in range(8):
                for f in range(frames):
                    tile = img.crop((f * FW, r * FH, (f + 1) * FW, (r + 1) * FH))
                    prev.alpha_composite(tile, (fi * (4 * FW + 8) + f * FW, si * FH))
                r += 1
        prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST).save(args.preview)
