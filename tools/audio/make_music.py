#!/usr/bin/env python3
"""Procedural music loops (placeholder, ADR-017/ADR-023): Elysia, valley, night forest, Antreiber.

All four share one motif (scale degrees 3-5-6-5-3-2), the fragment of the later main theme
(Game Bible §35). Elysia plays it perfectly quantized and bright; the valley plays it slower,
with human timing and a darker mode; the forest hides it in bells; the Antreiber rushes it.

Every loop is seamless: notes that run past the end wrap to the start, and filtering and
reverb are circular (frequency domain). Writes 16-bit stereo WAVs (22.05 kHz) to
assets/generated/music/ plus .import files with looping enabled.

Usage: .venv/bin/python tools/audio/make_music.py [--only elysia]
"""
import argparse
import os
import wave

import numpy as np

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "generated", "music")
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

# Motif as (scale degree, length in eighths): 3 5 6 5 | 3 2
MOTIF = [(3, 1), (5, 1), (6, 2), (5, 1), (3, 1), (2, 2)]
MAJOR = [0, 2, 4, 5, 7, 9, 11]
DORIAN = [0, 2, 3, 5, 7, 9, 10]


def midi_hz(m):
    return 440.0 * 2 ** ((m - 69) / 12.0)


def degree(root, scale, deg, octave=0):
    """MIDI note of a 1-based scale degree (degrees above 7 continue upwards)."""
    d = deg - 1
    return root + scale[d % 7] + 12 * (d // 7 + octave)


class Track:
    """Stereo loop buffer; notes wrap around the end."""

    def __init__(self, bpm, bars, beats_per_bar=4):
        self.bpm = bpm
        self.beat = 60.0 / bpm
        self.n = int(round(RATE * self.beat * beats_per_bar * bars))
        self.buf = np.zeros((2, self.n))

    def t(self, beats):
        return int(round(beats * self.beat * RATE))

    def add(self, start_beats, sig, pan=0.0, gain=1.0):
        """Adds a mono signal at a beat position, panned (-1 left .. 1 right), wrapped."""
        start = self.t(start_beats)
        idx = (start + np.arange(len(sig))) % self.n
        left = np.cos((pan + 1) * np.pi / 4) * gain
        right = np.sin((pan + 1) * np.pi / 4) * gain
        np.add.at(self.buf[0], idx, sig * left)
        np.add.at(self.buf[1], idx, sig * right)


# --- Instruments --------------------------------------------------------------------


def env_adsr(length, a, d, s, r, sustain_len):
    """Piecewise envelope in seconds; total length = a + d + sustain_len + r."""
    parts = []
    na, nd, ns, nr = (int(RATE * x) for x in (a, d, sustain_len, r))
    parts.append(np.linspace(0, 1, max(na, 1), endpoint=False))
    parts.append(np.linspace(1, s, max(nd, 1), endpoint=False))
    parts.append(np.full(max(ns, 0), s))
    parts.append(np.linspace(s, 0, max(nr, 1)))
    e = np.concatenate(parts)
    return e[:length] if length else e


def music_box(freq, seconds=2.2, bright=1.0):
    """Celesta-like: a few slightly inharmonic partials with fast, staggered decay."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    sig = np.zeros(n)
    for k, (ratio, amp, decay) in enumerate([(1, 1.0, 2.6), (2.01, 0.42 * bright, 4.5), (3.98, 0.2 * bright, 7.0), (6.3, 0.08 * bright, 11.0)]):
        sig += amp * np.sin(2 * np.pi * freq * ratio * t + k) * np.exp(-t * decay)
    attack = np.minimum(1, t / 0.003)
    return sig * attack * 0.5


def piano(freq, seconds=3.0, velocity=0.7, rng=None):
    """Soft upright piano for the real world (ADR-041): slightly stretched partials that die
    away faster the higher they are, two strings a hair apart, a felt hammer. Warm, a little
    uneven, nothing like Elysia's music box."""
    rng = rng or np.random.default_rng(0)
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    sig = np.zeros(n)
    for k in range(1, 9):
        fk = freq * k * np.sqrt(1 + 0.0004 * k * k)
        amp = (velocity ** (0.6 + 0.25 * k)) / k ** 1.3
        decay = 0.9 + 0.55 * k + freq / 900.0
        for detune in (0.9997, 1.0003):
            sig += 0.5 * amp * np.sin(2 * np.pi * fk * detune * t + rng.uniform(0, 6.28)) * np.exp(-t * decay)
    hammer = lowpass_np(rng.uniform(-1, 1, n) * np.exp(-t * 180.0), 0.08) * 0.15 * velocity
    attack = np.minimum(1, t / 0.004)
    return (sig + hammer) * attack * 0.42


def lowpass_np(x, alpha):
    """One-pole lowpass (alpha 0..1, smaller is darker)."""
    out = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc += alpha * (v - acc)
        out[i] = acc
    return out


def bell(freq, seconds=3.5, inharmonic=True):
    """FM-ish glass bell (inharmonic partials) for the forest."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    ratios = [(1, 1.0, 1.4), (2.76, 0.5, 2.4), (5.4, 0.25, 4.0), (8.93, 0.12, 6.0)] if inharmonic else [(1, 1, 1.5)]
    sig = sum(a * np.sin(2 * np.pi * freq * r * t) * np.exp(-t * d) for r, a, d in ratios)
    return sig * np.minimum(1, t / 0.002) * 0.45


def pluck(freq, seconds=2.5, rng=None, brightness=0.5):
    """Karplus-Strong plucked string (guitar-like) for the valley."""
    rng = rng or np.random.default_rng(0)
    n = int(RATE * seconds)
    period = max(int(RATE / freq), 2)
    buf = rng.uniform(-1, 1, period)
    # soften the excitation (darker, more like a thumb than a pick)
    for _ in range(int(3 * (1 - brightness)) + 1):
        buf = 0.5 * (buf + np.roll(buf, 1))
    out = np.zeros(n)
    decay = 0.996
    for i in range(n):
        j = i % period
        out[i] = buf[j]
        buf[j] = decay * 0.5 * (buf[j] + buf[(j + 1) % period])
    return out * 0.6


def pad(freqs, seconds, rng, attack=1.2, release=1.6, detune=0.004):
    """Warm pad: detuned saw-ish stacks per note; filtered later in the mix."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    sig = np.zeros(n)
    for f in freqs:
        for d in (-detune, 0.0, detune):
            ff = f * (1 + d)
            phase = rng.uniform(0, 2 * np.pi)
            # band-limited saw from 6 harmonics
            for h in range(1, 7):
                sig += np.sin(2 * np.pi * ff * h * t + phase * h) / h * 0.12
    env = env_adsr(n, attack, 0.5, 0.8, release, max(seconds - attack - 0.5 - release, 0))
    return sig * env[:n] / max(len(freqs), 1)


def soft_bass(freq, seconds):
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    sig = np.sin(2 * np.pi * freq * t) + 0.25 * np.sin(2 * np.pi * freq * 2 * t)
    env = np.minimum(1, t / 0.01) * np.exp(-t * 1.2)
    return sig * env * 0.55


def pulse_bass(freq, seconds):
    """Driving square-ish bass for the Antreiber."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    sq = sum(np.sin(2 * np.pi * freq * h * t) / h for h in (1, 3, 5, 7))
    env = np.minimum(1, t / 0.004) * np.exp(-t * 6.0)
    return sq * env * 0.4


def tick(rng, seconds=0.05, bright=1.0):
    """Hi-hat like noise tick."""
    n = int(RATE * seconds)
    noise = rng.normal(0, 1, n)
    noise = noise - np.convolve(noise, np.ones(4) / 4, "same")  # crude high-pass
    return noise * np.exp(-np.arange(n) / (n / 6)) * 0.18 * bright


# --- Circular effects -----------------------------------------------------------------


def circular_filter(x, lo=0.0, hi=None, tilt=0.0):
    """Zero-phase band filter in the frequency domain (keeps the loop seamless)."""
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1.0 / RATE)
    g = np.ones_like(f)
    if hi:
        g *= 1.0 / (1.0 + (f / hi) ** 4)
    if lo:
        g *= 1.0 / (1.0 + (lo / np.maximum(f, 1e-3)) ** 4)
    if tilt:
        g *= (np.maximum(f, 20) / 1000.0) ** tilt
    return np.fft.irfft(spec * g, len(x))


def circular_reverb(buf, seconds=2.8, mix=0.3, seed=7, damp=3000.0):
    """Stereo reverb by circular convolution with decaying, darkened noise."""
    rng = np.random.default_rng(seed)
    n = buf.shape[1]
    length = int(RATE * seconds)
    t = np.arange(length) / RATE
    out = np.zeros_like(buf)
    for ch in range(2):
        ir = rng.normal(0, 1, length) * np.exp(-t * 6.9 / seconds)
        ir = circular_filter(np.pad(ir, (0, max(n - length, 0)))[:n], hi=damp)
        ir[: int(RATE * 0.012)] *= np.linspace(0, 1, int(RATE * 0.012))
        ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
        wet = np.fft.irfft(np.fft.rfft(buf[ch]) * np.fft.rfft(ir), n)
        out[ch] = buf[ch] * (1 - mix) + wet * mix
    return out


def finish(track, name, reverb=0.3, rev_seconds=2.8, peak=0.82):
    mixed = circular_reverb(track.buf, rev_seconds, reverb)
    mixed = np.tanh(mixed / (np.max(np.abs(mixed)) + 1e-9) * 1.25) / np.tanh(1.25) * peak
    write(name, mixed)


def write(name, stereo):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + ".wav")
    data = (np.clip(stereo.T, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())
    # keep Godot's existing .import (it holds the uid); only new files get the template
    if not os.path.exists(path + ".import"):
        with open(path + ".import", "w") as f:
            f.write(IMPORT)
    print(f"{path}: {stereo.shape[1] / RATE:.1f} s")


# --- Tracks -----------------------------------------------------------------------------


def elysia(bars=8, name="elysia_loop"):
    """Bright, perfect, strictly quantized. I-vi-IV-V in C, the motif on bells, 16th arps.

    Shorter versions are the same music cut down to its first `bars` bars: the longer the
    player stays, the smaller Elysia's loop gets and the more its repetition shows
    (Game Bible §35 "Loops werden zunehmend wahrnehmbar")."""
    rng = np.random.default_rng(11)
    tr = Track(bpm=100, bars=bars)
    root = 60  # C4
    chords = [(1, [1, 3, 5, 7]), (6, [6, 8, 10, 12]), (4, [4, 6, 8, 10]), (5, [5, 7, 9, 13])]
    for bar in range(bars):
        chord_deg, tones = chords[(bar // 2) % 4]
        beat0 = bar * 4
        if bar % 2 == 0:
            freqs = [midi_hz(degree(root, MAJOR, d, -1)) for d in tones]
            tr.add(beat0, pad(freqs, tr.beat * 8 + 1.6, rng, attack=0.6), pan=0.0, gain=0.55)
            tr.add(beat0, soft_bass(midi_hz(degree(root - 12, MAJOR, chord_deg, -1)), tr.beat * 3), gain=0.9)
            tr.add(beat0 + 4, soft_bass(midi_hz(degree(root - 12, MAJOR, chord_deg, -1)), tr.beat * 3), gain=0.8)
        # perfectly even 16th arpeggio up and down
        arp = tones + tones[-2:0:-1]
        for i in range(16):
            m = degree(root, MAJOR, arp[i % len(arp)], 1 if i % 8 >= 4 else 0)
            tr.add(beat0 + i * 0.25, music_box(midi_hz(m), 1.2, 0.8), pan=-0.35 + 0.7 * (i % 2), gain=0.32)
    # motif on bells in bars 1-2 and 5-6, an answer an octave up in 7-8
    for start_bar, octave in [(0, 1), (4, 1), (6, 2)]:
        if start_bar >= bars:
            continue
        pos = start_bar * 4
        for deg, eighths in MOTIF:
            tr.add(pos, music_box(midi_hz(degree(root, MAJOR, deg, octave)), 2.6, 1.2), pan=0.15, gain=0.55)
            pos += eighths * 0.5
    # high sparkle on every downbeat (the loop "sparkles" exactly the same every time)
    for bar in range(bars):
        tr.add(bar * 4, music_box(midi_hz(degree(root, MAJOR, 5, 3)), 0.8, 0.5), pan=0.6, gain=0.18)
    tr.buf = np.stack([circular_filter(ch, lo=45, hi=7500) for ch in tr.buf])
    finish(tr, name, reverb=0.32, rev_seconds=3.2)


def elysia_stages():
    """Elysia's loop and its two shrunken stages (AudioDirector switches at the loop end)."""
    elysia()
    elysia(4, "elysia_half_loop")
    elysia(2, "elysia_quarter_loop")


def valley():
    """Sparse, human, D dorian. The motif slower, with timing and loudness that vary."""
    rng = np.random.default_rng(23)
    tr = Track(bpm=76, bars=8)
    root = 62  # D4
    progression = [1, 7, 4, 1, 3, 7, 4, 5]
    for bar, chord in enumerate(progression):
        beat0 = bar * 4
        notes = [degree(root - 12, DORIAN, chord + k, 0) for k in (0, 2, 4)]
        # fingerpicked pattern with human timing (±25 ms) and velocity
        for i, step in enumerate([0, 2, 1, 2]):
            jitter = rng.normal(0, 0.025) / tr.beat
            vel = rng.uniform(0.55, 0.9)
            tr.add(beat0 + i + 0.0 + jitter, pluck(midi_hz(notes[step] + (12 if step else 0)), 2.4, rng, 0.35), pan=-0.25 + 0.15 * step, gain=0.42 * vel)
        if bar % 2 == 0:
            tr.add(beat0, soft_bass(midi_hz(notes[0] - 12), tr.beat * 6), gain=0.5)
    # the motif on a soft piano, slow and slightly late, like someone playing it for
    # themselves (ADR-041); four bars later an answer that comes home (2-3-5-3-2-1)
    answer = [(2, 1), (3, 1), (5, 2), (3, 1), (2, 1), (1, 3)]
    for start, phrase, vel in ((8.0, MOTIF, 0.62), (24.0, answer, 0.55)):
        pos = start
        for deg, eighths in phrase:
            jitter = rng.normal(0.04, 0.03) / tr.beat
            v = vel * rng.uniform(0.85, 1.05)
            tr.add(pos + jitter, piano(midi_hz(degree(root, DORIAN, deg, 0)), 3.4, v, rng), pan=0.15, gain=0.7)
            pos += eighths * 0.75
    # the guitar still hums it once in the middle, quieter, under the piano's silence
    pos = 16.0
    for deg, eighths in MOTIF:
        jitter = rng.normal(0.04, 0.03) / tr.beat
        tr.add(pos + jitter, pluck(midi_hz(degree(root, DORIAN, deg, 0)), 3.0, rng, 0.55), pan=0.2, gain=0.35)
        pos += eighths * 0.75
    # a quiet hum underneath
    tr.add(0, pad([midi_hz(root - 12), midi_hz(root - 5)], tr.beat * 32, rng, attack=4.0, release=4.0, detune=0.002), gain=0.2)
    tr.buf = np.stack([circular_filter(ch, lo=50, hi=5200, tilt=-0.1) for ch in tr.buf])
    finish(tr, "valley_loop", reverb=0.26, rev_seconds=2.4)


def forest():
    """Night forest: low drone, sparse glass bells in A minor pentatonic, the motif hidden."""
    rng = np.random.default_rng(37)
    tr = Track(bpm=66, bars=8)
    root = 57  # A3
    penta = [0, 3, 5, 7, 10]
    tr.add(0, pad([midi_hz(root - 12), midi_hz(root - 5), midi_hz(root + 3)], tr.beat * 32, rng, attack=5.0, release=5.0, detune=0.003), gain=0.3)
    for k in range(14):
        pos = rng.uniform(0, 32)
        m = root + 12 + penta[rng.integers(0, 5)] + 12 * rng.integers(0, 2)
        tr.add(pos, bell(midi_hz(m), 4.0), pan=rng.uniform(-0.7, 0.7), gain=rng.uniform(0.18, 0.32))
    # the motif as distant bells (natural minor colour), bars 5-6
    pos = 18.0
    for deg, eighths in MOTIF:
        m = degree(root + 12, [0, 2, 3, 5, 7, 8, 10], deg, 0)
        tr.add(pos, bell(midi_hz(m), 4.5), pan=-0.3, gain=0.3)
        pos += eighths * 0.6
    tr.buf = np.stack([circular_filter(ch, lo=35, hi=6000) for ch in tr.buf])
    finish(tr, "forest_loop", reverb=0.45, rev_seconds=4.5)


def antreiber():
    """Relentless and bright: eighth-note pulse bass, ticking hats, the motif rushed upwards."""
    rng = np.random.default_rng(41)
    tr = Track(bpm=132, bars=8)
    root = 64  # E4
    progression = [1, 1, 6, 6, 4, 4, 5, 5]
    for bar, chord in enumerate(progression):
        beat0 = bar * 4
        bass = midi_hz(degree(root - 24, MAJOR, chord, 0))
        for i in range(8):
            tr.add(beat0 + i * 0.5, pulse_bass(bass * (2 if i % 4 == 3 else 1), 0.22), gain=0.55)
            tr.add(beat0 + i * 0.5 + 0.25, tick(rng, bright=1.2 if i % 2 else 0.7), pan=0.4, gain=0.8)
        tr.add(beat0, soft_bass(bass / 2, 0.3), gain=0.55)
        # motif every bar, each time a step higher: it never arrives
        pos = beat0
        for deg, eighths in MOTIF:
            tr.add(pos, music_box(midi_hz(degree(root, MAJOR, deg + bar % 4, 0)), 0.7, 1.4), pan=-0.2, gain=0.4)
            pos += eighths * 0.25
    tr.buf = np.stack([circular_filter(ch, lo=60, hi=8000) for ch in tr.buf])
    finish(tr, "antreiber_loop", reverb=0.15, rev_seconds=1.2)


TRACKS = {"elysia": elysia_stages, "valley": valley, "forest": forest, "antreiber": antreiber}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", choices=sorted(TRACKS))
    args = parser.parse_args()
    for name, fn in TRACKS.items():
        if args.only in (None, name):
            fn()
