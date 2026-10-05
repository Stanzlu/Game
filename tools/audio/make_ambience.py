#!/usr/bin/env python3
"""Elysia's ambience loop (ADR-017): the garden. The real world's sounds are layered at
runtime from tools/audio/make_nature.py (ADR-034).

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
    """Elysia's garden: a soft, even breeze and one bird phrase repeated on an exact beat,
    twice per loop, answered by its mirror image. Pretty at first, then too perfect: the
    real world (make_nature.py) never repeats like this (Game Bible §9)."""
    rng = np.random.default_rng(seed)
    n = RATE * seconds
    wind = shaped_noise(n, rng, 120, 1400, tilt=-0.9) * 0.14
    wind *= 0.7 + 0.3 * lfo(n, 4, 0.3)
    leaves = shaped_noise(n, rng, 2000, 7000, tilt=-0.2) * 0.03 * lfo(n, 4, 1.2)
    out = wind + leaves
    call = chirp(rng) * 0.1
    answer = chirp(rng) * 0.08
    beat = n // 4
    for k in range(4):
        add_wrapped(out, k * beat + RATE // 4, call if k % 2 == 0 else answer)
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
    write("garden_loop", garden())
