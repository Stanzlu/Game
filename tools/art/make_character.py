#!/usr/bin/env python3
"""Procedural character sheets for the look prototype (ADR-017).

Layout matches entities/character/character_sheet.gd: one row per state and facing
(state-major; facings in Facing.Dir order E, SE, S, SW, W, NW, N, NE), frames left to right.
West-facing rows are mirrored east-facing ones. Frame size 24x32, feet on y=30.

Each character is a design (palette plus hair, outfit and accessory choices). Parts are drawn
back to front with 4-tone ramps, light from the top left, clean flat shading (no dithering),
inner contour lines between overlapping parts and a colored outline.

Usage: .venv/bin/python tools/art/make_character.py [--preview scratch/chars.png]
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
# "look" is the long idle (Game Bible §36 "viele Idle-Animationen"): blink, glance to one
# side, to the other, blink. Its rows come last, so older sheets without them still work.
STATES = [("idle", 2), ("walk", 4), ("run", 4), ("sit", 1), ("look", 4)]
FACINGS = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]

DESIGNS = {
    # The protagonist: tidy, a little too perfect for Elysia. Teal jacket, satchel.
    "player": {
        "skin": ramp("#8a4b45", "#c47b63", "#eaae8a", "#ffd8b8"),
        "hair": ramp("#241520", "#4a2a2c", "#7a4634", "#b06e44", "#e0a466"),
        "top": ramp("#14304a", "#1d5670", "#2b8a96", "#62c4bb"),
        "inner": ramp("#7d6f86", "#b7aec0", "#e6e0e6", "#ffffff"),
        "belt": ramp("#2a1a1e", "#4c3029", "#76503a", "#a37a52"),
        "pants": ramp("#1d1a33", "#302c50", "#48446e", "#686490"),
        "boots": ramp("#1e1418", "#3d2822", "#664232", "#90674a"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#e88b7e"),
        "outline": pa.hex_rgb("#1d1428"),
        "hair_style": "tousled",
        "outfit": "jacket",
        "bag": "satchel",
    },
    # Elysians: flawless white and gold, all a little too alike (Game Bible §9).
    "elysian": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#6a4210", "#a8701c", "#d8a832", "#f4d46a", "#fff2b8"),
        "top": ramp("#7c7096", "#b8b0cc", "#e8e4f0", "#ffffff"),
        "inner": ramp("#8a6a18", "#c4982a", "#ecc84e", "#fff0a0"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#6e6688", "#a49cbc", "#d6d0e4", "#f6f4fb"),
        "boots": ramp("#5a4214", "#94701e", "#c89c34", "#ecd070"),
        "eye": pa.hex_rgb("#2a1f48"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#3a2e58"),
        "hair_style": "tousled",
        "outfit": "cape",
        "bag": "none",
    },
    # Mira: practical traveler in the valley. Mustard rain cape, auburn ponytail, backpack.
    "mira": {
        "skin": ramp("#7a4438", "#b56f55", "#dea27e", "#f6cfae"),
        "hair": ramp("#2a0f12", "#5a1f1c", "#8e3524", "#c1552e", "#e88a4a"),
        "top": ramp("#4a3214", "#7c5a1e", "#b08a2c", "#dcc05a"),
        "inner": ramp("#3a2c2a", "#5d4740", "#86685a", "#b08f7a"),
        "belt": ramp("#231518", "#432a22", "#6a4632", "#94694a"),
        "pants": ramp("#1f2224", "#33393c", "#4d5558", "#6e787a"),
        "boots": ramp("#1a1210", "#33241c", "#57402e", "#7d5e44"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#d97a68"),
        "outline": pa.hex_rgb("#1b1210"),
        "hair_style": "ponytail",
        "outfit": "cape",
        "bag": "backpack",
    },
}


def pose(state, frame):
    """Per-frame offsets. legs: (forward, lift) per leg; arms: swing per arm; bob: upper body."""
    p = {"bob": 0, "legs": ((0, 0), (0, 0)), "arms": (0, 0), "sit": False, "lean": 0, "hair": 0,
         "gaze": 0, "blink": False}
    if state == "idle":
        p["bob"] = frame
        p["hair"] = frame
    elif state == "look":
        p["blink"] = frame in (0, 3)
        p["gaze"] = {1: -1, 2: 1}.get(frame, 0)
        p["hair"] = 1 if frame == 2 else 0
    elif state in ("walk", "run"):
        big = 2 if state == "run" else 1
        if frame in (0, 2):
            s = 1 if frame == 0 else -1
            p["legs"] = ((s * big, 0 if s > 0 else big), (-s * big, big if s > 0 else 0))
            p["arms"] = (-s * big, s * big)
        else:
            p["bob"] = -1
            p["hair"] = 1
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


class Figure:
    """Draws one frame of a design. Parts go back to front; `line=True` adds inner contours."""

    def __init__(self, design, facing, p):
        self.d = design
        self.c = Canvas(FW, FH)
        self.facing = facing
        self.p = p
        self.side = facing == "E"
        self.back = facing in ("N", "NE")
        self.three = facing in ("SE", "NE")
        self.drawn = np.zeros((FH, FW), bool)

    def part(self, mask, mat, value, line=False):
        c = self.c
        colors = self.d[mat]
        v = np.broadcast_to(np.asarray(value, np.float32), (FH, FW))
        c.paint(mask, colors, np.clip(v, 0, 1), contrast=3.0, dither=False)
        if line:
            # contour where this part overlaps parts drawn before it
            edge = mask & ~(np.roll(mask, 1, 0) & np.roll(mask, -1, 0) & np.roll(mask, 1, 1)
                            & np.roll(mask, -1, 1))
            other = self.drawn & ~mask
            touching = (np.roll(other, 1, 0) | np.roll(other, -1, 0) | np.roll(other, 1, 1)
                        | np.roll(other, -1, 1))
            c.rgb[edge & touching] = colors[0]
        self.drawn |= mask

    def cyl(self, x0, x1, base=0.18, amt=0.78):
        return base + amt * self.c.cylinder(x0, x1)

    def draw(self):
        d, c, p = self.d, self.c, self.p
        side, back, three = self.side, self.back, self.three
        b = p["bob"]
        lean = p["lean"] if (side or three) else 0
        cx = 12.5 if (side or three) else 12.0
        hip = 23 + b
        ty0, ty1 = 15 + b, 23 + b

        # backpack behind the body (front views) / ponytail behind the head
        if d["bag"] == "backpack" and not back:
            bx = cx - 0.5 if not side else cx - 4 + lean
            pack = c.rect(bx - 4, ty0 + 0, bx + 4, ty0 + 7) if not side else c.rect(bx - 3, ty0, bx + 1, ty0 + 8)
            self.part(pack, "belt", 0.45)

        # legs
        if p["sit"]:
            if side:
                for k in (0, 1):
                    thigh = limb(c, cx - 1 + k, hip, cx + 4 + k, hip + 1, 3)
                    shin = limb(c, cx + 4 + k, hip + 1, cx + 4 + k, FEET, 3)
                    self.part(thigh | shin & (c.yy < FEET - 2), "pants", 0.45 + 0.15 * k)
                    self.part(shin & (c.yy >= FEET - 2), "boots", 0.5)
            else:
                for k, lx in enumerate((cx - 2, cx + 2)):
                    leg = limb(c, lx, hip, lx, hip + 3, 3)
                    boot = limb(c, lx, hip + 3, lx, hip + 5, 3)
                    self.part(leg, "pants", 0.6 - 0.15 * k, line=True)
                    self.part(boot, "boots", 0.55 - 0.1 * k)
        else:
            order = [(1, -0.12), (0, 0.12)] if side else [(0, 0.1), (1, -0.05)]
            for li, tint in order:
                fwd, lift = p["legs"][li]
                if side:
                    hx, fx = cx - 0.5 + lean, cx - 0.5 + fwd * 2
                else:
                    hx = cx - 2 + 4 * li
                    fx = hx + (fwd * 0.5 if three else 0)
                leg = limb(c, hx, hip, fx, FEET - lift, 3)
                boot = leg & (c.yy >= FEET - lift - 2)
                if side:
                    boot |= c.rect(int(round(fx + 1)), FEET - lift - 1, int(round(fx + 3)), FEET - lift + 1)
                self.part(leg & ~boot, "pants", self.cyl(hx - 2, hx + 2) + tint - 0.1)
                self.part(boot, "boots", 0.5 + tint + 0.25 * (c.yy == FEET - lift - 2))

        # far arm (side view) behind the torso
        if side:
            sw = p["arms"][1]
            far = limb(c, cx + lean, ty0 + 1, cx + lean + sw, ty0 + 7, 2)
            self.part(far, "top", 0.2)
            self.part(far & (c.yy >= ty0 + 6), "skin", 0.35)

        # torso
        if side:
            tx0, tx1 = cx - 3 + lean, cx + 3 + lean
        elif three:
            tx0, tx1 = cx - 4, cx + 3
        else:
            tx0, tx1 = cx - 4, cx + 4
        torso = c.rect(tx0, ty0, tx1, ty1)
        torso &= ~((c.yy == ty0) & ((c.xx < tx0 + 1) | (c.xx >= tx1 - 1)))
        if d["outfit"] == "cape":
            # wide cape over the shoulders, flaring toward the hem
            flare = (c.yy - ty0) * 0.35
            cape = (c.xx >= tx0 - 1 - flare) & (c.xx < tx1 + 1 + flare) & (c.yy >= ty0) & (c.yy < ty1)
            cape &= ~((c.yy == ty0) & ((c.xx < tx0) | (c.xx >= tx1)))
            torso = cape
        hem = c.rect(tx0 - 0.5, ty1 - 1, tx1 + 0.5, ty1)
        self.part(torso | hem, "top", self.cyl(tx0 - 1, tx1 + 1, 0.15, 0.8), line=True)
        if not back and d["outfit"] == "jacket":
            # open collar with a light shirt, jacket seam, belt with buckle
            if side:
                shirt = c.rect(tx1 - 2, ty0 + 1, tx1 - 1, ty0 + 5)
            else:
                mid = cx + (1 if three else 0)
                shirt = (np.abs(c.xx + 0.5 - mid) <= (3.2 - (c.yy - ty0) * 0.7)) & (c.yy >= ty0) & (c.yy < ty0 + 5)
            self.part(shirt, "inner", 0.75)
            belt = c.rect(tx0, ty1 - 3, tx1, ty1 - 2)
            self.part(belt, "belt", 0.5)
            if not side:
                self.part(c.rect(cx - 0.5 + (1 if three else 0), ty1 - 3, cx + 1.5 + (1 if three else 0), ty1 - 2),
                          "inner", 0.95)
        if d["outfit"] == "cape" and not back:
            # cape clasp and a dark inner lining at the opening
            mid = cx + (1 if three else 0)
            if not side:
                opening = (np.abs(c.xx + 0.5 - mid) <= 0.6 + (c.yy - ty0) * 0.25) & (c.yy >= ty0 + 2) & (c.yy < ty1)
                self.part(opening, "inner", 0.35)
                self.part(c.rect(mid - 1, ty0 + 1, mid + 1, ty0 + 2), "belt", 0.9)
        if d["bag"] == "satchel":
            if not side:
                # strap from the right shoulder to the left hip
                strap = np.abs((c.xx + 0.5 - (tx1 - 1)) + (c.yy - ty0) * 0.9) <= 0.7
                strap &= (c.yy >= ty0) & (c.yy < ty1 - 1) & torso
                self.part(strap, "belt", 0.55)
                if not back:
                    self.part(c.rect(tx0 - 2, ty1 - 4, tx0 + 1, ty1), "belt", 0.6, line=True)
            else:
                self.part(c.rect(tx0 - 2, ty1 - 5, tx0 + 1, ty1 - 1), "belt", 0.55, line=True)
        if d["bag"] == "backpack" and back:
            self.part(c.rect(cx - 4, ty0 + 1, cx + 4, ty0 + 8), "belt", self.cyl(cx - 5, cx + 5, 0.2, 0.6), line=True)
            self.part(c.rect(cx - 3, ty0 + 2, cx + 3, ty0 + 3), "belt", 0.8)

        # near arms
        if side:
            sw = p["arms"][0]
            near = limb(c, cx - 0.5 + lean, ty0 + 1, cx - 0.5 + lean + sw, ty0 + 7, 2)
            self.part(near, "top", 0.65, line=True)
            self.part(near & (c.yy >= ty0 + 6), "skin", 0.65)
        else:
            for k, ax in enumerate((tx0 - 1, tx1 + 1)):
                sw = p["arms"][k]
                end = ty0 + 6 + max(sw, -1)
                arm = limb(c, ax, ty0 + 1, ax, end, 2)
                hand = limb(c, ax, end, ax, end + 1, 2)
                tone = 0.72 if k == 0 else 0.4
                if three and k == 1:
                    tone = 0.3
                cuff = arm & (c.yy == end - 1)
                self.part(arm, "top", tone, line=True)
                self.part(cuff, "top", tone + 0.2)
                self.part(hand, "skin", tone)

        self.head(cx, lean, b)
        c.outline(d["outline"])
        return c

    def head(self, cx, lean, b):
        d, c, p = self.d, self.c, self.p
        side, back, three = self.side, self.back, self.three
        hx = cx + (0.5 if side else 0) + lean
        hy = 10.0 + b
        hb = p["hair"]  # hair settles a frame later than the head (bounce)
        # neck
        self.part(c.rect(hx - 1.5, hy + 4, hx + 1.5, hy + 6), "skin", 0.3)
        head = c.ellipse(hx, hy, 6.3, 6.0)
        self.part(head, "skin", 0.48 + 0.5 * c.sphere(hx - 1.5, hy - 1.5, 7, 7))
        hair_v = 0.1 + 0.72 * c.sphere(hx - 2.5, hy - 4, 9, 8)
        style = d["hair_style"]
        if back:
            hair = head | c.ellipse(hx, hy - 0.6, 7.2, 6.6)
            if facing_ne(self.facing):
                hair &= ~c.rect(hx + 4, hy + 1, hx + 7, hy + 6)
            hair |= c.rect(hx - 6, hy + 1, hx + 6, hy + 4 + hb) & c.ellipse(hx, hy + 1, 7.0, 6.0)
        elif side:
            cap = c.ellipse(hx - 0.5, hy - 1.2, 7.3, 6.5) & ((c.yy < hy - 1.0) | (c.xx < hx - 0.5))
            back_hair = c.rect(hx - 6.5, hy - 2, hx - 1.5, hy + 4 + hb) & c.ellipse(hx - 1, hy + 0.5, 7.2, 7.2)
            fringe = c.rect(hx + 1, hy - 2, hx + 6.5, hy - 0.5) & ((c.xx.astype(int) % 2) == 0)
            hair = cap | back_hair | fringe
        else:
            cap = c.ellipse(hx - (0.5 if three else 0), hy - 1.3, 7.3, 6.5) & (c.yy < hy - 1.8)
            # pointed bangs: a zigzag edge over the forehead
            zig = ((c.xx.astype(int) + (1 if three else 0)) % 3)
            bangs = c.rect(hx - 5.5, hy - 2.5, hx + 5.5, hy + 0.2 - (zig == 1) * 1.8 - (zig == 2) * 0.9)
            locks = c.rect(hx - 7, hy - 2, hx - 4.6, hy + 4 + hb) | c.rect(hx + 4.6, hy - 2, hx + 7, hy + 4 + hb)
            if three:
                locks = c.rect(hx - 7, hy - 2, hx - 4.2, hy + 4 + hb)
            hair = cap | (bangs & c.ellipse(hx, hy, 7.3, 7.3)) | (locks & c.ellipse(hx, hy + 0.5, 7.4, 7.4))
        if style == "tousled":
            # a strand sticking up and a few spikes on the crown
            hair |= c.rect(hx + (0 if not side else -1), hy - 8 + hb * 0, hx + 1 + (0 if not side else -1), hy - 6)
            hair |= c.rect(hx - 3, hy - 7, hx - 2, hy - 6)
        if style == "ponytail":
            tail_x = hx - 6 if side else hx + (5 if three else 0)
            if back or side:
                tail = limb(c, tail_x, hy - 2, tail_x - (1 if side else 0), hy + 6 + hb, 3)
                hair |= tail
            hair |= c.ellipse(hx, hy - 6.5, 2.2, 1.4)  # tie on top-back
        self.part(hair, "hair", hair_v, line=True)
        # glossy highlight band across the crown
        ring = np.abs(np.hypot(c.xx + 0.5 - (hx + 1), c.yy + 0.5 - (hy + 3)) - 8.4) < 0.55
        shine = hair & ring & (c.xx >= hx - 4) & (c.xx < hx) & (c.yy < hy - 3)
        c.rgb[shine] = d["hair"][4]
        if not back:
            ey = int(round(hy + 1))
            if side:
                eyes = [int(round(hx + 3))]
            elif three:
                eyes = [int(round(hx - 1)), int(round(hx + 3))]
            else:
                eyes = [int(round(hx - 3)), int(round(hx + 2))]
            eyes = [ex + p["gaze"] for ex in eyes]
            for ex in eyes:
                if p["blink"]:
                    # closed lids: a short dark line, skin where the eye was
                    c.fill(c.rect(ex, ey, ex + 1, ey + 1), d["skin"][2])
                    c.fill(c.rect(ex, ey + 1, ex + 1, ey + 2), d["eye"])
                    continue
                c.fill(c.rect(ex, ey, ex + 1, ey + 2), d["eye"])
                c.fill(c.rect(ex, ey, ex + 1, ey + 1), np.array([250, 248, 255], np.float32) * 0.6 + d["eye"] * 0.4)
            if not side:
                c.fill(c.rect(eyes[0] - 1, ey + 2, eyes[0], ey + 3), d["blush"])
                c.fill(c.rect(eyes[-1] + 1, ey + 2, eyes[-1] + 2, ey + 3), d["blush"])
                mx = int(round((eyes[0] + eyes[-1]) / 2 + 0.5))
                c.fill(c.rect(mx, ey + 3, mx + 1, ey + 4), d["skin"][1])
            else:
                c.fill(c.rect(int(round(hx + 6)), ey + 2, int(round(hx + 7)), ey + 3), d["skin"][2])


def facing_ne(f):
    return f == "NE"


def sheet(design):
    cols = max(n for _, n in STATES)
    rows = len(STATES) * len(FACINGS)
    out = np.zeros((rows * FH, cols * FW, 4), np.float32)
    row = 0
    for state, frames in STATES:
        for facing in FACINGS:
            for f in range(frames):
                src = {"W": "E", "SW": "SE", "NW": "NE"}.get(facing, facing)
                img = Figure(design, src, pose(state, f)).draw().rgba()
                if src != facing:
                    img = img[:, ::-1]
                out[row * FH:(row + 1) * FH, f * FW:(f + 1) * FW] = img
            row += 1
    return out


def preview(sheets, path):
    from PIL import Image
    tiles = []
    for data in sheets:
        img = Image.fromarray(data.astype(np.uint8), "RGBA")
        strip = Image.new("RGBA", (8 * 4 * FW + 7 * 8, 4 * FH), (96, 140, 110, 255))
        r = 0
        for si, (_, frames) in enumerate(STATES):
            for fi in range(8):
                for f in range(frames):
                    tile = img.crop((f * FW, r * FH, (f + 1) * FW, (r + 1) * FH))
                    strip.alpha_composite(tile, (fi * (4 * FW + 8) + f * FW, si * FH))
                r += 1
        tiles.append(strip)
    out = Image.new("RGBA", (tiles[0].width, sum(t.height + 8 for t in tiles)), (96, 140, 110, 255))
    y = 0
    for t in tiles:
        out.alpha_composite(t, (0, y))
        y += t.height + 8
    out.resize((out.width * 3, out.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--preview", help="write a scaled preview of all frames")
    args = ap.parse_args()
    made = []
    for name, design in DESIGNS.items():
        data = sheet(design)
        path = os.path.join(ROOT, "assets", "generated", "characters", name + ".png")
        pa.save_rgba(path, data)
        made.append(data)
        print("wrote", os.path.relpath(path, ROOT))
    if args.preview:
        preview(made, args.preview)
