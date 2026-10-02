#!/usr/bin/env python3
"""Generates REAL's grey-box placeholder art and audio (Phase 1).

Standard library only, fixed seed: running it twice yields identical files.
All outputs are project-owned placeholders and listed in docs/PLACEHOLDERS.md.
Usage: python3 tools/placeholders/make_placeholders.py
"""
import math
import os
import random
import struct
import wave
import zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "placeholder")
SEED = 20261002

# Facing order shared with entities/character/facing.gd: E, SE, S, SW, W, NW, N, NE
DIRS = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)]
# Animation rows shared with entities/character/character_sheet.gd
STATES = [("idle", 2), ("walk", 4), ("run", 4), ("sit", 1)]
FRAME_W, FRAME_H = 16, 24
SHEET_COLS = 4


# --------------------------------------------------------------------------- raster
class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[(0, 0, 0, 0) for _ in range(w)] for _ in range(h)]

    def set(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            if len(c) == 4 and c[3] < 255 and self.px[y][x][3] > 0:
                a = c[3] / 255.0
                b = self.px[y][x]
                c = (int(c[0] * a + b[0] * (1 - a)), int(c[1] * a + b[1] * (1 - a)),
                     int(c[2] * a + b[2] * (1 - a)), max(b[3], c[3]))
            self.px[y][x] = c if len(c) == 4 else (*c, 255)

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.set(xx, yy, c)

    def ellipse(self, cx, cy, rx, ry, c):
        for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((xx - cx) / max(rx, 0.01)) ** 2 + ((yy - cy) / max(ry, 0.01)) ** 2 <= 1.0:
                    self.set(xx, yy, c)

    def line(self, x0, y0, x1, y1, c):
        steps = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        for i in range(steps + 1):
            t = i / max(steps, 1)
            self.set(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, c)

    def blit(self, other, ox, oy):
        for y in range(other.h):
            for x in range(other.w):
                c = other.px[y][x]
                if c[3] > 0:
                    self.set(ox + x, oy + y, c)

    def outline(self, c):
        """Adds a 1px outline around opaque pixels (readability on any ground)."""
        src = [row[:] for row in self.px]
        for y in range(self.h):
            for x in range(self.w):
                if src[y][x][3] == 0:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < self.w and 0 <= ny < self.h and src[ny][nx][3] >= 200:
                            self.px[y][x] = c
                            break

    def save_png(self, path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        raw = b"".join(b"\x00" + b"".join(struct.pack("4B", *p) for p in row) for row in self.px)

        def chunk(tag, data):
            body = tag + data
            return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

        png = b"\x89PNG\r\n\x1a\n"
        png += chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0))
        png += chunk(b"IDAT", zlib.compress(raw, 9))
        png += chunk(b"IEND", b"")
        with open(path, "wb") as f:
            f.write(png)


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c[:3]) + (255,)


# --------------------------------------------------------------------------- tiles
def make_tiles(rng):
    """16px atlas. Column order must match content/maps/legend.json."""
    names = ["grass", "grass_alt", "dirt", "stone", "wall", "water", "wood", "dark"]
    atlas = Canvas(16 * len(names), 16)
    for i, name in enumerate(names):
        t = Canvas(16, 16)
        if name in ("grass", "grass_alt"):
            base = (74, 122, 60)
            t.rect(0, 0, 16, 16, base)
            for _ in range(14 if name == "grass" else 22):
                x, y = rng.randrange(16), rng.randrange(16)
                t.set(x, y, shade(base, 0.78))
                t.set(x, y - 1, shade(base, 1.18))
        elif name == "dirt":
            base = (138, 106, 68)
            t.rect(0, 0, 16, 16, base)
            for _ in range(12):
                t.set(rng.randrange(16), rng.randrange(16), shade(base, rng.choice((0.8, 1.15))))
        elif name == "stone":
            base = (122, 122, 128)
            t.rect(0, 0, 16, 16, base)
            for y in (0, 8):
                t.line(0, y, 15, y, shade(base, 0.8))
            for x, y0 in ((0, 0), (8, 8)):
                t.line(x, y0, x, y0 + 7, shade(base, 0.8))
        elif name == "wall":
            base = (60, 60, 72)
            t.rect(0, 0, 16, 16, base)
            t.rect(0, 0, 16, 3, shade(base, 1.45))
            for y in (7, 12):
                t.line(0, y, 15, y, shade(base, 0.7))
            for x, y0 in ((5, 3), (12, 3), (2, 8), (9, 8), (6, 13), (13, 13)):
                t.line(x, y0, x, y0 + 3, shade(base, 0.7))
        elif name == "water":
            base = (46, 90, 138)
            t.rect(0, 0, 16, 16, base)
            for y in (3, 9, 14):
                for x in range(16):
                    if (x + y) % 6 < 3:
                        t.set(x, y + (1 if x % 6 < 2 else 0), shade(base, 1.35))
        elif name == "wood":
            base = (138, 90, 48)
            t.rect(0, 0, 16, 16, base)
            for y in (0, 5, 10, 15):
                t.line(0, y, 15, y, shade(base, 0.7))
            for x, y in ((3, 2), (11, 7), (6, 12)):
                t.set(x, y, shade(base, 0.6))
        else:
            t.rect(0, 0, 16, 16, (24, 24, 30))
        atlas.blit(t, i * 16, 0)
    atlas.save_png(os.path.join(OUT, "tiles", "greybox_tiles.png"))


# --------------------------------------------------------------------------- characters
def draw_figure(body, head_col, hair, accent, d, state, frame):
    c = Canvas(FRAME_W, FRAME_H)
    dx, dy = d
    bob = 0
    leg_a, leg_b = 0, 0
    lean = 0
    if state == "idle":
        bob = 0 if frame == 0 else 1
    elif state in ("walk", "run"):
        phase = frame % 4
        bob = (0, 1, 0, 1)[phase] * (2 if state == "run" else 1)
        swing = (1, 0, -1, 0)[phase] * (2 if state == "run" else 1)
        leg_a, leg_b = swing, -swing
        lean = dx if state == "run" else 0
    sit = state == "sit"
    oy = 3 if sit else 0
    # shadow
    c.ellipse(8, 21.5, 5, 1.6, (0, 0, 0, 90))
    # legs
    if sit:
        c.rect(5 + max(dx, 0) * 2, 17, 2, 2, shade(body, 0.6))
        c.rect(9 + min(dx, 0) * 2, 17, 2, 2, shade(body, 0.6))
    else:
        c.rect(5, 17 + bob // 2, 2, 4 - max(leg_a, 0), shade(body, 0.6))
        c.rect(9, 17 + bob // 2, 2, 4 - max(leg_b, 0), shade(body, 0.6))
    # torso
    tx = 4 + lean
    c.rect(tx, 10 + bob + oy, 8, 8 - (1 if sit else 0), body)
    c.rect(tx, 10 + bob + oy, 8, 1, shade(body, 1.2))
    if dy >= 0:
        c.rect(tx + 3 + dx, 12 + bob + oy, 2, 3, accent)  # chest badge shows facing
    # arms
    arm = (1, 0, -1, 0)[frame % 4] if state in ("walk", "run") else 0
    c.rect(tx - 1, 11 + bob + oy + max(arm, 0), 1, 5, shade(body, 0.8))
    c.rect(tx + 8, 11 + bob + oy + max(-arm, 0), 1, 5, shade(body, 0.8))
    # head
    hx, hy = 8 + lean, 6 + bob + oy
    c.ellipse(hx - 0.5, hy, 4, 4, head_col)
    # hair: top band always; whole head when facing away (N, NE, NW);
    # the side facing away when looking sideways (E, W, SE, SW)
    for yy in range(hy - 4, hy + 5):
        for xx in range(hx - 5, hx + 4):
            vx, vy = xx - (hx - 0.5), yy - hy
            if vx * vx + vy * vy > 16:
                continue
            away = dy < 0 and not (dx != 0 and vx * dx > 2.0)
            side = dy >= 0 and dx != 0 and vx * dx < -0.5 and vy < 2
            if yy <= hy - 3 or away or side:
                c.set(xx, yy, hair)
    # eyes / face direction
    if dy >= 0 or dx != 0:
        ex, ey = hx - 0.5 + dx * 2.2, hy + 0.5 + max(dy, 0) * 0.8
        if dx == 0:
            c.set(ex - 1.5, ey, (24, 24, 30))
            c.set(ex + 1.5, ey, (24, 24, 30))
        else:
            c.set(ex, ey, (24, 24, 30))
            if dy > 0:
                c.set(ex - dx * 2, ey, (24, 24, 30))
    c.outline((24, 24, 30, 255))
    return c


def make_character(name, body, head_col, hair, accent):
    rows = sum(1 for _ in STATES) * len(DIRS)
    sheet = Canvas(FRAME_W * SHEET_COLS, FRAME_H * rows)
    row = 0
    for state, frames in STATES:
        for d in DIRS:
            for f in range(frames):
                sheet.blit(draw_figure(body, head_col, hair, accent, d, state, f), f * FRAME_W, row * FRAME_H)
            row += 1
    sheet.save_png(os.path.join(OUT, "characters", name + ".png"))


# --------------------------------------------------------------------------- props
def make_props(rng):
    p = lambda name: os.path.join(OUT, "props", name + ".png")
    ink = (24, 24, 30, 255)

    bench = Canvas(32, 16)
    wood = (150, 100, 56)
    bench.rect(2, 6, 28, 3, wood)
    bench.rect(2, 2, 28, 2, shade(wood, 0.85))
    for x in (4, 26):
        bench.rect(x, 9, 2, 5, shade(wood, 0.6))
    bench.ellipse(16, 14.5, 13, 1.5, (0, 0, 0, 70))
    bench.outline(ink)
    bench.save_png(p("bench"))

    sign = Canvas(16, 16)
    sign.rect(7, 8, 2, 7, (110, 76, 44))
    sign.rect(2, 2, 12, 7, (176, 134, 82))
    for y in (4, 6):
        sign.line(4, y, 11, y, (110, 76, 44))
    sign.outline(ink)
    sign.save_png(p("sign"))

    lever = Canvas(32, 16)
    for i, tilt in enumerate((-3, 3)):
        lever.rect(i * 16 + 4, 11, 8, 3, (90, 90, 100))
        lever.line(i * 16 + 8, 11, i * 16 + 8 + tilt, 4, (180, 180, 190))
        lever.ellipse(i * 16 + 8 + tilt, 4, 1.5, 1.5, (200, 70, 60))
    lever.outline(ink)
    lever.save_png(p("lever"))

    gate = Canvas(32, 16)
    for x in range(1, 16, 3):
        gate.rect(x, 1, 2, 14, (150, 150, 160))
    gate.rect(0, 2, 16, 2, (110, 110, 120))
    gate.rect(0, 11, 16, 2, (110, 110, 120))
    gate.rect(16, 13, 16, 2, (110, 110, 120, 140))  # open: only the threshold remains
    gate.outline(ink)
    gate.save_png(p("gate"))

    tuft = Canvas(16, 16)
    for i in range(7):
        x = 2 + i * 2
        h = rng.randrange(7, 12)
        col = shade((96, 156, 72), rng.choice((0.85, 1.0, 1.15)))
        tuft.line(x, 15, x + rng.choice((-1, 0, 1)), 15 - h, col)
    tuft.save_png(p("grass_tuft"))

    puddle = Canvas(16, 16)
    puddle.ellipse(8, 9, 6.5, 3.5, (70, 110, 156, 230))
    puddle.ellipse(6, 8, 2, 1, (150, 190, 220, 230))
    puddle.save_png(p("puddle"))

    splash = Canvas(64, 16)
    for f in range(4):
        r = 2 + f * 1.6
        a = 220 - f * 50
        for k in range(24):
            ang = k / 24 * math.tau
            splash.set(f * 16 + 8 + math.cos(ang) * r, 10 + math.sin(ang) * r * 0.45, (190, 220, 245, a))
        if f < 2:
            for k in (-1, 1):
                splash.set(f * 16 + 8 + k * (2 + f), 6 - f * 2, (190, 220, 245, 200))
    splash.save_png(p("splash"))

    bush = Canvas(16, 16)
    bush.ellipse(8, 9, 7, 6, (52, 98, 52))
    for _ in range(12):
        bush.set(rng.randrange(3, 13), rng.randrange(4, 14), (78, 132, 66))
    bush.outline(ink)
    bush.save_png(p("bush"))

    flag = Canvas(32, 32)
    for f in range(2):
        flag.rect(f * 16 + 3, 4, 2, 27, (200, 200, 205))
        wave_y = (0, 1)[f]
        for x in range(9):
            flag.line(f * 16 + 5 + x, 5 + (wave_y if x % 4 < 2 else 0), f * 16 + 5 + x, 11 + (wave_y if x % 4 < 2 else 0), (230, 190, 60))
    flag.outline(ink)
    flag.save_png(p("goal_flag"))

    bird = Canvas(16, 8)
    for f in range(2):
        bird.ellipse(f * 8 + 4, 4.5, 2.5, 2, (120, 92, 70))
        bird.set(f * 8 + 6, 3 + f, (230, 170, 60))
        bird.set(f * 8 + 4, 3, ink)
    bird.save_png(p("bird"))

    dust = Canvas(24, 8)
    for f in range(3):
        bird_r = 1.5 + f
        dust.ellipse(f * 8 + 4, 5, bird_r, bird_r * 0.6, (200, 190, 170, 170 - f * 50))
    dust.save_png(p("dust"))


# --------------------------------------------------------------------------- audio
RATE = 44100


def write_wav(path, samples):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    peak = max(1e-6, max(abs(s) for s in samples))
    scale = 0.5 / peak  # about -6 dBFS
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s * scale * 32767)) for s in samples))


def lowpass(samples, alpha):
    out, y = [], 0.0
    for s in samples:
        y += alpha * (s - y)
        out.append(y)
    return out


def highpass(samples, alpha):
    low = lowpass(samples, alpha)
    return [s - l for s, l in zip(samples, low)]


def env(n, attack, decay_pow=2.0):
    a = max(1, int(attack * RATE))
    return [min(1.0, i / a) * (1 - i / n) ** decay_pow for i in range(n)]


def noise_burst(rng, dur, lp, hp=None, attack=0.002, decay_pow=2.5):
    n = int(dur * RATE)
    s = [rng.uniform(-1, 1) for _ in range(n)]
    s = lowpass(s, lp)
    if hp:
        s = highpass(s, hp)
    e = env(n, attack, decay_pow)
    return [a * b for a, b in zip(s, e)]


def tone(freq, dur, decay_pow=3.0, attack=0.002, sweep=0.0):
    n = int(dur * RATE)
    e = env(n, attack, decay_pow)
    out, ph = [], 0.0
    for i in range(n):
        f = freq * (1 + sweep * i / n)
        ph += f / RATE
        out.append(math.sin(ph * math.tau) * e[i])
    return out


def mix(*parts):
    n = max(len(p) for p in parts)
    return [sum(p[i] for p in parts if i < len(p)) for i in range(n)]


def make_audio(rng):
    a = lambda name: os.path.join(OUT, "audio", name + ".wav")
    for i in range(4):
        v = rng.uniform(0.9, 1.1)
        write_wav(a(f"footstep_grass_{i}"), noise_burst(rng, 0.09 * v, 0.18, 0.02, 0.004))
        write_wav(a(f"footstep_dirt_{i}"), mix(noise_burst(rng, 0.07 * v, 0.25, 0.01), tone(90 * v, 0.06, 4)))
        write_wav(a(f"footstep_stone_{i}"), mix(noise_burst(rng, 0.05 * v, 0.7, 0.2, 0.001, 4), tone(420 * v, 0.03, 5)))
        write_wav(a(f"footstep_wood_{i}"), mix(tone(170 * v, 0.12, 3), tone(340 * v, 0.06, 4), noise_burst(rng, 0.03, 0.5, 0.1)))
        write_wav(a(f"footstep_puddle_{i}"), mix(noise_burst(rng, 0.16 * v, 0.45, 0.08, 0.004, 1.6), tone(700 * v, 0.05, 3, sweep=0.6)))
        write_wav(a(f"rustle_{i}"), noise_burst(rng, 0.24 * v, 0.35, 0.15, 0.03, 1.4))
    write_wav(a("splash"), mix(noise_burst(rng, 0.35, 0.5, 0.06, 0.003, 1.3), tone(520, 0.12, 2, sweep=0.8)))
    write_wav(a("ui_move"), tone(880, 0.04, 2))
    write_wav(a("ui_confirm"), tone(660, 0.05, 2) + tone(990, 0.08, 2))
    write_wav(a("ui_back"), tone(660, 0.05, 2) + tone(440, 0.08, 2))
    write_wav(a("lever"), mix(noise_burst(rng, 0.05, 0.8, 0.3, 0.001, 5), tone(300, 0.08, 4)))
    write_wav(a("gate"), tone(140, 0.45, 1.2, attack=0.02, sweep=0.5))
    write_wav(a("sit"), noise_burst(rng, 0.12, 0.12, 0.01, 0.01, 2))
    write_wav(a("bird"), tone(2400, 0.07, 2, sweep=0.3) + [0.0] * 2000 + tone(2700, 0.09, 2, sweep=-0.2))
    for i in range(3):
        blips = []
        for _ in range(rng.randrange(3, 6)):
            blips += tone(rng.uniform(320, 480), 0.035, 1.5) + [0.0] * 600
        write_wav(a(f"bark_{i}"), blips)


def main():
    rng = random.Random(SEED)
    make_tiles(rng)
    make_character("player", (232, 224, 208), (240, 214, 190), (92, 64, 44), (90, 140, 200))
    make_character("npc", (170, 196, 222), (236, 212, 188), (200, 180, 120), (240, 240, 240))
    make_character("antreiber", (208, 96, 42), (230, 200, 170), (40, 40, 48), (250, 220, 80))
    make_props(rng)
    make_audio(rng)
    print("placeholders written to", os.path.relpath(OUT, ROOT))


if __name__ == "__main__":
    main()
