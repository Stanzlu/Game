#!/usr/bin/env python3
"""Procedural sound effects (ADR-017/ADR-023, 0 €): menu sounds in two skins, Elysia's
rewards (coins, XP, level up, chest, loot by rarity), quiet Real-world pickups, dialogue
voices and the glitches of the rift.

The two UI sets follow Game Bible §34/§35: Elysia is glassy, bright and perfectly in tune
(everything snaps to one major scale); the Real world is wood, paper and breath, short and
low. Every sound is mono 16-bit 44.1 kHz, peak-normalized per group, and written with an
.import file to assets/generated/sfx/. Variants are numbered (<name>_0.wav, _1.wav, ...)
and picked at random by SoundBank.

Usage: .venv/bin/python tools/audio/make_sfx.py [--only coin] [--preview out.png]
"""
import argparse
import os
import wave

import numpy as np

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "sfx")
RATE = 44100

IMPORT = """[remap]

importer="wav"
type="AudioStreamWAV"

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0
"""


# --- Building blocks ----------------------------------------------------------------


def secs(n):
    return np.arange(int(RATE * n)) / RATE


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12.0)


def env(t, attack, decay):
    """Fast attack, exponential decay (seconds)."""
    a = np.minimum(1.0, t / max(attack, 1e-4))
    return a * np.exp(-t / max(decay, 1e-4))


def sine(f, t, phase=0.0):
    if np.isscalar(f):
        return np.sin(2 * np.pi * f * t + phase)
    return np.sin(2 * np.pi * np.cumsum(f) / RATE + phase)


def tri(f, t):
    ph = (np.cumsum(np.broadcast_to(f, t.shape)) / RATE) % 1.0
    return 4 * np.abs(ph - 0.5) - 1


def square(f, t, duty=0.5):
    ph = (np.cumsum(np.broadcast_to(f, t.shape)) / RATE) % 1.0
    return np.where(ph < duty, 1.0, -1.0)


def lowpass(x, cutoff):
    """One-pole lowpass; cutoff may be an array (sweeps)."""
    cutoff = np.broadcast_to(np.asarray(cutoff, dtype=float), x.shape)
    a = np.exp(-2 * np.pi * cutoff / RATE)
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc = (1 - a[i]) * x[i] + a[i] * acc
        y[i] = acc
    return y


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def bandpass(x, low, high):
    return lowpass(highpass(x, low), high)


def noise(n, rng):
    return rng.uniform(-1, 1, n)


def pad_to(x, n):
    return np.pad(x, (0, max(0, n - len(x))))[:n] if len(x) < n else x


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def at(x, seconds, total=None):
    """Delays x by `seconds` (for sequencing notes)."""
    start = int(RATE * seconds)
    out = np.zeros(start + len(x) if total is None else int(RATE * total))
    end = min(len(out), start + len(x))
    out[start:end] += x[: end - start]
    return out


def reverb(x, seconds=0.6, wet=0.25, seed=3, bright=6000):
    """Short convolution reverb with a decaying noise tail."""
    rng = np.random.default_rng(seed)
    t = secs(seconds)
    ir = noise(len(t), rng) * np.exp(-t / (seconds / 4.5))
    ir = lowpass(ir, bright)
    ir /= np.sqrt(np.sum(ir**2)) + 1e-9
    tail = np.convolve(x, ir)[: len(x) + len(t)]
    return mix(x * (1 - wet * 0.5), tail * wet)


def fade_tail(x, seconds=0.02):
    n = min(len(x), int(RATE * seconds))
    x = x.copy()
    x[-n:] *= np.linspace(1, 0, n)
    return x


# --- Elysia: glass and gold (C major, quantized, bright) ----------------------------

C6 = 84


def glass(midi, seconds=0.5, bright=1.0, decay=0.18):
    """Glassy chime: sine with a few bell partials."""
    t = secs(seconds)
    f = hz(midi)
    sig = sine(f, t) + 0.35 * bright * sine(f * 2.0, t, 1.0) * np.exp(-t / (decay * 0.5))
    sig += 0.18 * bright * sine(f * 3.01, t, 2.0) * np.exp(-t / (decay * 0.3))
    return sig * env(t, 0.002, decay)


def sparkle(seconds, rng, density=60, low=5000, high=11000, decay=0.03):
    """Random tiny high blips (fairy dust)."""
    t = secs(seconds)
    out = np.zeros(len(t))
    count = int(density * seconds)
    for _ in range(count):
        start = rng.uniform(0, seconds * 0.8)
        f = rng.uniform(low, high)
        blip = sine(f, secs(0.06)) * env(secs(0.06), 0.001, decay) * rng.uniform(0.2, 0.6)
        out = mix(out, at(blip, start, seconds))
    return out[: len(t)] * np.exp(-t / (seconds * 0.5))


def swoosh(seconds, rng, f_from, f_to, q=0.5):
    """Filtered noise sweep."""
    t = secs(seconds)
    n = noise(len(t), rng)
    cut = np.geomspace(f_from, f_to, len(t))
    s = bandpass(n, cut * q, cut)
    shape = np.sin(np.pi * np.minimum(1, t / seconds)) ** 1.5
    return s * shape


def elysia_ui(rng):
    out = {}
    # move: tiny glass blip, alternating notes of the C major pentatonic
    for i, note in enumerate([C6 + 7, C6 + 9, C6 + 4, C6 + 12]):
        out[f"ui_elysia_move_{i}"] = glass(note, 0.16, 0.6, 0.05) * 0.8
    out["ui_elysia_confirm"] = mix(
        glass(C6 + 4, 0.5, 1.0, 0.12), at(glass(C6 + 11, 0.7, 1.0, 0.2), 0.07), sparkle(0.6, rng, 40) * 0.25
    )
    out["ui_elysia_back"] = mix(glass(C6 + 7, 0.4, 0.8, 0.1), at(glass(C6, 0.5, 0.8, 0.14), 0.06))
    out["ui_elysia_open"] = reverb(
        mix(
            swoosh(0.35, rng, 800, 9000) * 0.5,
            *[at(glass(C6 + n, 0.4, 0.8, 0.1) * 0.6, i * 0.04) for i, n in enumerate([0, 4, 7, 12])],
        ),
        0.5,
        0.3,
    )
    out["ui_elysia_close"] = reverb(
        mix(
            swoosh(0.3, rng, 7000, 900) * 0.45,
            *[at(glass(C6 + n, 0.35, 0.7, 0.08) * 0.5, i * 0.04) for i, n in enumerate([12, 7, 4])],
        ),
        0.4,
        0.25,
    )
    for i, note in enumerate([C6 + 12, C6 + 14]):
        out[f"ui_elysia_tick_{i}"] = glass(note, 0.08, 0.3, 0.02) * 0.6
    return out


# --- Real: wood, paper, breath (short, low, a little uneven) ------------------------


def knock(f, seconds, rng, hardness=0.5):
    """Wooden knock: damped resonance plus a click of filtered noise."""
    t = secs(seconds)
    body = sine(f, t) * env(t, 0.001, 0.035) + 0.4 * sine(f * 2.3, t) * env(t, 0.001, 0.015)
    click = bandpass(noise(len(t), rng), 1200, 4000 + 3000 * hardness) * env(t, 0.0005, 0.006)
    return body * 0.8 + click * 0.5


def paper(seconds, rng, up=True):
    t = secs(seconds)
    n = noise(len(t), rng)
    cut = np.geomspace(1500, 5000, len(t)) if up else np.geomspace(5000, 1500, len(t))
    s = bandpass(n, cut * 0.4, cut)
    grain = 0.6 + 0.4 * np.abs(lowpass(noise(len(t), rng), 40)) * 4
    return s * np.sin(np.pi * t / seconds) ** 2 * grain


def real_ui(rng):
    out = {}
    for i, f in enumerate([520, 560, 500]):
        out[f"ui_real_move_{i}"] = knock(f * rng.uniform(0.98, 1.02), 0.08, rng, 0.3) * 0.7
    out["ui_real_confirm"] = mix(knock(440, 0.12, rng, 0.6), at(knock(660, 0.14, rng, 0.4) * 0.7, 0.05))
    out["ui_real_back"] = mix(knock(392, 0.12, rng, 0.4), at(knock(294, 0.14, rng, 0.3) * 0.7, 0.05))
    out["ui_real_open"] = paper(0.22, rng, True) * 0.9
    out["ui_real_close"] = paper(0.2, rng, False) * 0.8
    for i in range(2):
        out[f"ui_real_tick_{i}"] = knock(700 + 60 * i, 0.05, rng, 0.2) * 0.6
    return out


# --- Elysia rewards ------------------------------------------------------------------


def coin(rng, variant):
    """The classic two-tone coin, a little different each time."""
    t1 = secs(0.07)
    t2 = secs(0.36)
    base = hz(C6 - 1 + variant)  # B5..
    a = square(base, t1, 0.25) * env(t1, 0.001, 0.2)
    b = square(base * 4 / 3, t2, 0.25) * env(t2, 0.001, 0.12)
    sig = mix(a, at(b, 0.065))
    sig = mix(lowpass(sig, 7000) * 0.35, sparkle(0.4, rng, 25, 7000, 12000) * 0.12)
    return sig


def xp_gain(rng):
    """Rising quantized arpeggio of glass notes with dust."""
    notes = [C6 - 12, C6 - 8, C6 - 5, C6, C6 + 4, C6 + 7]
    parts = [at(glass(n, 0.35, 0.9, 0.08) * (0.5 + 0.1 * i), i * 0.035) for i, n in enumerate(notes)]
    return reverb(mix(*parts, sparkle(0.6, rng, 50) * 0.3), 0.6, 0.3)


def brass(midi, seconds):
    """Bright synth brass: detuned saws through an opening filter."""
    t = secs(seconds)
    f = hz(midi)
    saw = np.zeros(len(t))
    for d in (-0.004, 0.0, 0.004):
        ph = (f * (1 + d) * t) % 1.0
        saw += 2 * ph - 1
    cut = 600 + 5000 * np.minimum(1, t / 0.08) * np.exp(-t / 0.9)
    shaped = lowpass(saw / 3, cut)
    a = np.minimum(1, t / 0.015)
    rel = np.minimum(1, (seconds - t) / 0.08)
    return shaped * a * np.clip(rel, 0, 1)


def level_up(rng):
    """Fanfare: quick arpeggio, held chord, shimmer and a final bell."""
    hits = [(C6 - 24, 0.0, 0.14), (C6 - 20, 0.1, 0.14), (C6 - 17, 0.2, 0.14), (C6 - 12, 0.3, 1.4)]
    parts = [at(brass(n, d), s) * 0.6 for n, s, d in hits]
    for n in (C6 - 20, C6 - 17):
        parts.append(at(brass(n, 1.1), 0.3) * 0.35)
    parts.append(at(glass(C6 + 12, 1.6, 1.0, 0.5), 0.3) * 0.5)
    parts.append(at(sparkle(1.4, rng, 70), 0.25) * 0.35)
    timp = secs(0.5)
    parts.append(at(sine(70 * np.exp(-timp * 3), timp) * env(timp, 0.002, 0.25), 0.3) * 0.7)
    return reverb(mix(*parts), 1.2, 0.3)


def chest_open(rng):
    """Wood creak, latch click, then a rising magical swell with sparkles."""
    t = secs(0.45)
    creak_f = 90 + 50 * np.sin(2 * np.pi * 3 * t) + 40 * t
    creak = bandpass(square(creak_f, t, 0.1) * 0.5 + noise(len(t), rng) * 0.2, 300, 2500)
    creak *= np.sin(np.pi * t / 0.45) * 0.6
    latch = knock(1800, 0.05, rng, 1.0) * 0.6
    swell = swoosh(0.9, rng, 400, 8000) * 0.35
    notes = [at(glass(C6 + n, 0.6, 0.8, 0.15) * 0.45, 0.45 + i * 0.06) for i, n in enumerate([0, 4, 7, 11, 14])]
    return reverb(mix(latch, at(creak, 0.03), at(swell, 0.3), *notes, at(sparkle(0.9, rng, 60) * 0.3, 0.5)), 0.9, 0.3)


def loot(rng, rarity):
    """Rarity fanfares: common pling .. legendary choir and bells."""
    if rarity == "common":
        return reverb(glass(C6 + 7, 0.5, 0.8, 0.15) * 0.8, 0.5, 0.2)
    if rarity == "rare":
        return reverb(mix(*[at(glass(C6 + n, 0.6, 1.0, 0.18) * 0.7, i * 0.07) for i, n in enumerate([0, 7, 12])]), 0.7, 0.3)
    if rarity == "epic":
        notes = [at(glass(C6 + n, 0.9, 1.0, 0.25) * 0.6, i * 0.06) for i, n in enumerate([-5, 0, 4, 7, 12])]
        return reverb(mix(*notes, at(sparkle(1.0, rng, 60) * 0.35, 0.1)), 0.9, 0.35)
    # legendary: a choir-like pad swell under bells
    t = secs(2.4)
    choir = np.zeros(len(t))
    for n in (C6 - 24, C6 - 17, C6 - 12, C6 - 8, C6 - 5):
        f = hz(n)
        for d in (-0.003, 0.0, 0.003):
            vib = 1 + 0.004 * np.sin(2 * np.pi * 5.2 * t + n)
            choir += np.sin(2 * np.pi * np.cumsum(np.full(len(t), f * (1 + d)) * vib) / RATE)
            choir += 0.3 * np.sin(4 * np.pi * np.cumsum(np.full(len(t), f * (1 + d)) * vib) / RATE)
    choir = lowpass(choir / 15, 3500) * np.minimum(1, t / 0.35) * np.minimum(1, (2.4 - t) / 0.8)
    bells = [at(glass(C6 + n, 1.4, 1.0, 0.45) * 0.5, 0.15 + i * 0.09) for i, n in enumerate([0, 4, 7, 12, 16, 19])]
    return reverb(mix(choir * 0.9, *bells, at(sparkle(2.0, rng, 80) * 0.4, 0.1)), 1.4, 0.35)


def praise(rng):
    """An Elysian's compliment: soft harp-like up-glissando."""
    notes = [C6 - 12 + n for n in (0, 2, 4, 7, 9, 12, 14, 16)]
    parts = [at(glass(n, 0.5, 0.6, 0.12) * 0.4, i * 0.025) for i, n in enumerate(notes)]
    return reverb(mix(*parts), 0.8, 0.35)


# --- Real world ------------------------------------------------------------------------


def real_pickup(rng, variant):
    """Picking up something small: a pebble click and cloth."""
    stone = knock(900 + 120 * variant, 0.06, rng, 0.9) * 0.7
    cloth = paper(0.18, rng, variant % 2 == 0) * 0.35
    return mix(stone, at(cloth, 0.04))


# --- Voices (dialogue blips) -----------------------------------------------------------


def blip(rng, kind, variant):
    t = secs(0.05)
    if kind == "elysia":
        f = hz(C6 - 12 + [0, 2, 4, 7, 9][variant % 5])
        sig = (tri(f, t) * 0.7 + sine(f * 2, t) * 0.3) * env(t, 0.002, 0.03)
        return lowpass(sig, 6000) * 0.6
    if kind == "warm":
        f = 220 * 2 ** (rng.uniform(-2, 3) / 12)
        sig = (tri(f, t) * 0.8 + sine(f * 0.5, t) * 0.4) * env(t, 0.004, 0.028)
        return lowpass(sig, 1800) * 0.7
    if kind == "low":
        f = 140 * 2 ** (rng.uniform(-2, 2) / 12)
        sig = (square(f, t, 0.3) * 0.5 + sine(f, t) * 0.5) * env(t, 0.003, 0.03)
        return lowpass(sig, 1400) * 0.6
    # neutral voice
    f = 300 * 2 ** (rng.uniform(-2, 2) / 12)
    sig = (tri(f, t) * 0.8 + sine(f * 2, t) * 0.2) * env(t, 0.003, 0.025)
    return lowpass(sig, 2600) * 0.6


# --- Rift --------------------------------------------------------------------------------


def glitch(rng, variant):
    """Digital tearing: bit-crushed noise and chirps, a few stutters."""
    seconds = 0.25 + 0.08 * variant
    t = secs(seconds)
    chirp_f = np.where((t * 40).astype(int) % 2 == 0, 1800, 600) * (1 + variant * 0.3)
    chirp = square(chirp_f, t, 0.5) * 0.3
    hiss = noise(len(t), rng) * 0.5
    sig = chirp + hiss
    # sample-and-hold crush
    hold = 8 + 6 * variant
    sig = np.repeat(sig[::hold], hold)[: len(t)]
    sig = np.round(sig * 4) / 4
    gate = ((t * (24 + 8 * variant)).astype(int) % 3 != 1).astype(float)
    return sig * gate * np.exp(-t / (seconds * 0.6)) * 0.6


def rift_hum(rng):
    """Seamless 4 s loop near the rift: a low beating drone, a thin high whine that swells,
    and sparse crackles. Every partial completes whole cycles in 4 s, so the loop is clean."""
    seconds = 4.0
    t = secs(seconds)
    drone = sine(55.0, t) + 0.7 * sine(55.5, t) + 0.25 * sine(110.25, t)
    whine = sine(1760.25, t) * (0.5 + 0.5 * np.sin(2 * np.pi * 0.25 * t)) * 0.08
    crackle = np.zeros(len(t))
    for _ in range(14):
        start = int(rng.uniform(0, len(t) - 800))
        burst = noise(400, rng) * env(secs(400 / RATE), 0.0005, 0.004)
        crackle[start:start + 400] += highpass(burst, 2000) * rng.uniform(0.2, 0.5)
    return lowpass(drone, 400) * 0.6 + whine + crackle


def rift_touch(rng):
    """A deep, wrong whoomp: falling sine, sub rumble and a reversed shimmer."""
    t = secs(1.6)
    fall = sine(160 * np.exp(-t * 2.2) + 30, t) * env(t, 0.01, 0.6)
    rumble = lowpass(noise(len(t), rng), 120) * 3 * env(t, 0.05, 0.7)
    shimmer = sparkle(0.8, rng, 60, 3000, 9000)[::-1] * 0.4
    return reverb(mix(at(shimmer, 0.0), at(fall + rumble, 0.6)), 1.2, 0.35, bright=3000)


# --- Output -----------------------------------------------------------------------------


def normalize(x, peak_db=-3.0):
    peak = np.max(np.abs(x)) + 1e-9
    return x / peak * 10 ** (peak_db / 20)


def write(name, x, peak_db, loop=False):
    os.makedirs(OUT, exist_ok=True)
    x = normalize(x, peak_db) if loop else fade_tail(normalize(x, peak_db))
    data = (np.clip(x, -1, 1) * 32767).astype("<i2")
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())
    with open(path + ".import", "w", encoding="utf-8") as f:
        f.write(IMPORT.replace("edit/loop_mode=0", "edit/loop_mode=2") if loop else IMPORT)
    print(f"{path}  {len(x) / RATE:.2f}s")


# Peak level per group: UI quiet, rewards loud (Elysia overdoes it), Real quiet.
GROUPS = {
    "ui_elysia": -6.0,
    "ui_real": -9.0,
    "coin": -6.0,
    "xp": -5.0,
    "level_up": -3.0,
    "chest": -4.0,
    "loot": -3.0,
    "praise": -7.0,
    "pickup_real": -9.0,
    "voice": -10.0,
    "glitch": -6.0,
    "rift": -3.0,
    "rift_hum": -8.0,
}
LOOPS = {"rift_hum"}


def build(only=None):
    rng = np.random.default_rng(7)
    sounds = {}
    sounds.update({k: (v, "ui_elysia") for k, v in elysia_ui(rng).items()})
    sounds.update({k: (v, "ui_real") for k, v in real_ui(rng).items()})
    for i in range(4):
        sounds[f"coin_{i}"] = (coin(rng, i % 3), "coin")
    sounds["xp"] = (xp_gain(rng), "xp")
    sounds["level_up"] = (level_up(rng), "level_up")
    sounds["chest_open"] = (chest_open(rng), "chest")
    for rarity in ("common", "rare", "epic", "legendary"):
        sounds[f"loot_{rarity}"] = (loot(rng, rarity), "loot")
    sounds["praise"] = (praise(rng), "praise")
    for i in range(3):
        sounds[f"pickup_real_{i}"] = (real_pickup(rng, i), "pickup_real")
    for kind in ("elysia", "warm", "low", "neutral"):
        for i in range(5):
            sounds[f"voice_{kind}_{i}"] = (blip(rng, kind, i), "voice")
    for i in range(3):
        sounds[f"glitch_{i}"] = (glitch(rng, i), "glitch")
    sounds["rift_touch"] = (rift_touch(rng), "rift")
    sounds["rift_hum"] = (rift_hum(rng), "rift_hum")
    for name, (sig, group) in sounds.items():
        if only and not name.startswith(only):
            continue
        write(name, sig, GROUPS[group], loop=group in LOOPS)
    return sounds


def preview(sounds, path):
    """Waveform overview of all sounds (visual check without listening)."""
    from PIL import Image, ImageDraw

    names = list(sounds)
    w, row = 900, 22
    img = Image.new("RGB", (w, row * len(names)), (20, 20, 26))
    d = ImageDraw.Draw(img)
    for i, name in enumerate(names):
        x = normalize(sounds[name][0])
        y0 = i * row + row // 2
        d.text((4, y0 - 6), name, fill=(150, 150, 170))
        span = w - 170
        step = max(1, int(RATE * 2.5 / span))
        for px in range(min(span, len(x) // step)):
            seg = x[px * step : (px + 1) * step]
            amp = float(np.max(np.abs(seg))) * (row // 2 - 2)
            d.line([(170 + px, y0 - amp), (170 + px, y0 + amp)], fill=(240, 200, 110))
    img.save(path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--only")
    parser.add_argument("--preview")
    args = parser.parse_args()
    built = build(args.only)
    if args.preview:
        preview(built, args.preview)
