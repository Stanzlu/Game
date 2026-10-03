#!/usr/bin/env python3
"""Procedural ambience loops for the look prototype (ADR-017): rain, garden, water, night forest.

Noise beds are synthesized in the frequency domain, so every loop is periodic and repeats
without a seam. Events (drops, bird chirps) wrap around the loop end for the same reason.
Writes 16-bit mono WAVs to assets/generated/audio/ plus .import files that enable looping.

Usage: .venv/bin/python tools/audio/make_ambience.py
"""
import os
import wave

import numpy as np

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "audio")
RATE = 22050

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
edit/loop_mode=2
edit/loop_begin=0
edit/loop_end=-1
compress/mode=2
"""


def shaped_noise(n, rng, lo, hi, tilt=0.0):
    """Periodic noise with energy between lo and hi Hz; tilt < 0 darkens (pink-ish)."""
    freqs = np.fft.rfftfreq(n, 1.0 / RATE)
    mag = ((freqs >= lo) & (freqs <= hi)).astype(np.float64)
    edge = 0.15
    mag = np.clip(mag + np.exp(-((freqs - lo) / (lo * edge + 1)) ** 2) + np.exp(-((freqs - hi) / (hi * edge + 1)) ** 2), 0, 1)
    mag *= np.where(freqs > 0, (np.maximum(freqs, 1) / 1000.0) ** tilt, 0)
    spec = mag * np.exp(1j * rng.uniform(0, 2 * np.pi, len(freqs)))
    x = np.fft.irfft(spec, n)
    return x / (np.max(np.abs(x)) + 1e-9)


def lfo(n, cycles, phase=0.0):
    """Periodic slow modulation in 0..1 with an integer number of cycles per loop."""
    t = np.arange(n) / n
    return 0.5 + 0.5 * np.sin(2 * np.pi * cycles * t + phase)


def add_wrapped(buf, start, sig):
    idx = (start + np.arange(len(sig))) % len(buf)
    np.add.at(buf, idx, sig)


def rain(seconds=12, seed=1):
    rng = np.random.default_rng(seed)
    n = RATE * seconds
    hiss = shaped_noise(n, rng, 400, 9000, tilt=-0.35) * 0.32
    body = shaped_noise(n, rng, 80, 700, tilt=-0.8) * 0.22
    swell = 0.8 + 0.2 * lfo(n, 2, 1.0)
    out = (hiss + body) * swell
    # individual drops: short filtered clicks at random times and loudness
    for _ in range(seconds * 140):
        length = rng.integers(60, 260)
        env = np.exp(-np.arange(length) / (length / 5.0))
        click = rng.normal(0, 1, length) * env
        click = np.convolve(click, [0.5, 0.5], "same")
        add_wrapped(out, rng.integers(0, n), click * rng.uniform(0.02, 0.12))
    # drips from the eaves: low, round plops
    for _ in range(seconds * 2):
        length = int(RATE * 0.08)
        t = np.arange(length) / RATE
        f = rng.uniform(350, 650) * (1 + 1.5 * np.exp(-t * 60))
        plop = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 45)
        add_wrapped(out, rng.integers(0, n), plop * rng.uniform(0.05, 0.12))
    return out


def chirp(rng):
    notes = rng.integers(2, 6)
    base = rng.uniform(2600, 4200)
    parts = []
    for k in range(notes):
        dur = rng.uniform(0.05, 0.11)
        t = np.arange(int(RATE * dur)) / RATE
        sweep = base * (1 + rng.uniform(-0.25, 0.35) * t / dur) + 300 * np.sin(2 * np.pi * rng.uniform(25, 45) * t)
        tone = np.sin(2 * np.pi * np.cumsum(sweep) / RATE)
        tone += 0.25 * np.sin(4 * np.pi * np.cumsum(sweep) / RATE)
        env = np.sin(np.pi * t / dur) ** 2
        parts.append(tone * env)
        parts.append(np.zeros(int(RATE * rng.uniform(0.03, 0.09))))
    return np.concatenate(parts)


def garden(seconds=16, seed=2):
    rng = np.random.default_rng(seed)
    n = RATE * seconds
    wind = shaped_noise(n, rng, 120, 1400, tilt=-0.9) * 0.16
    wind *= 0.45 + 0.55 * lfo(n, 2, 0.3) * lfo(n, 3, 2.0)
    leaves = shaped_noise(n, rng, 2000, 7000, tilt=-0.2) * 0.04 * lfo(n, 4, 1.2)
    out = wind + leaves
    for _ in range(9):
        call = chirp(rng) * rng.uniform(0.05, 0.12)
        add_wrapped(out, rng.integers(0, n), call)
    return out


def water(seconds=8, seed=3):
    rng = np.random.default_rng(seed)
    n = RATE * seconds
    bed = shaped_noise(n, rng, 300, 4000, tilt=-0.5) * 0.3
    out = bed * (0.75 + 0.25 * lfo(n, 5))
    for _ in range(seconds * 25):
        length = int(RATE * rng.uniform(0.01, 0.03))
        t = np.arange(length) / RATE
        f = rng.uniform(700, 2200) * (1 + t * 40)
        bubble = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 120)
        add_wrapped(out, rng.integers(0, n), bubble * rng.uniform(0.03, 0.1))
    return out


def forest_night(seconds=16, seed=4):
    """Crickets in pulsed trills, a low wind bed, a distant owl, a soft stream."""
    rng = np.random.default_rng(seed)
    n = RATE * seconds
    t = np.arange(n) / RATE
    wind = shaped_noise(n, rng, 90, 900, tilt=-1.0) * 0.12 * (0.6 + 0.4 * lfo(n, 2, 0.7))
    stream = shaped_noise(n, rng, 600, 5000, tilt=-0.4) * 0.05
    out = wind + stream
    for k in range(3):
        f = rng.uniform(3900, 4800)
        rate = rng.uniform(14, 22)
        # chirp groups: trill on for ~0.4 s, off for ~0.6 s, per cricket; integer cycles keep the loop seamless
        group = (np.sin(2 * np.pi * round(seconds * rng.uniform(0.9, 1.3)) * t / seconds + k) > 0.1)
        pulse = (np.sin(2 * np.pi * rate * t) > 0.3).astype(np.float64)
        out += np.sin(2 * np.pi * f * t) * pulse * group * rng.uniform(0.04, 0.07)
    for _ in range(2):
        length = int(RATE * 0.9)
        tt = np.arange(length) / RATE
        hoot = np.zeros(length)
        for start, dur, f0 in ((0.0, 0.32, 380), (0.45, 0.42, 340)):
            seg = (tt >= start) & (tt < start + dur)
            env = np.sin(np.pi * np.clip((tt - start) / dur, 0, 1)) ** 2
            hoot += np.sin(2 * np.pi * (f0 + 6 * np.sin(2 * np.pi * 5 * tt)) * tt) * env * seg
        add_wrapped(out, rng.integers(0, n), hoot * 0.09)
    return out


def write(name, signal):
    os.makedirs(OUT, exist_ok=True)
    signal = signal / (np.max(np.abs(signal)) + 1e-9) * 0.8
    pcm = (signal * 32767).astype("<i2")
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())
    imp = path + ".import"
    if not os.path.exists(imp):
        with open(imp, "w", encoding="utf-8") as f:
            f.write(IMPORT)
    print("wrote", os.path.relpath(path, ROOT))


if __name__ == "__main__":
    write("rain_loop", rain())
    write("garden_loop", garden())
    write("water_loop", water())
    write("forest_night_loop", forest_night())
