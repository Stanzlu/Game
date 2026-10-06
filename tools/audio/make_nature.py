#!/usr/bin/env python3
"""Procedural nature sounds for the real world (Game Bible §12, ADR-034): beds and one-shots
that the Soundscape player (world/audio/soundscape_player.gd) layers at runtime.

Elysia keeps its single perfect loop (make_ambience.py, garden). The real world never
repeats: the beds here are event-free textures (rain, wind, leaves, a stream, crickets)
that play twice, panned left and right half a loop apart, while birds, drips, twigs and
creaks come as one-shots at random times from random directions. Every sound is modelled
on its physical source rather than drawn as a tone:

- rain: thousands of drop impacts with a log-normal loudness (many tiny, few big), a part
  of them landing in water as small resonating bubbles (Minnaert), over a low roar;
- wind: noise through slowly drifting resonances (the trees), gusts come at runtime;
- leaves: grains of crackle in bursts; stream: dense bubbles over a gurgle;
- crickets: real chirp/pulse structure per animal, at different rates and distances;
- birds: blackbird, robin, great tit, wood pigeon, crow and tawny owl from their song
  structure (note contours, trills, harmonics, rasp); a distant dog;
- everything far away gets a lowpass and an outdoor reverb tail.

Beds go to assets/generated/audio/nature_<name>_bed.wav (looping), one-shots to
assets/generated/sfx/nature_<name>_<n>.wav (SoundBank variants). 32 kHz mono, 16 bit.

Usage: .venv/bin/python tools/audio/make_nature.py
"""
import os
import wave

import numpy as np

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BED_DIR = os.path.join(ROOT, "assets", "generated", "audio")
SHOT_DIR = os.path.join(ROOT, "assets", "generated", "sfx")
RATE = 32000

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
edit/loop_mode={loop}
edit/loop_begin=0
edit/loop_end=-1
compress/mode=2
"""


# --- building blocks -------------------------------------------------------------------

def secs(x):
    return int(round(x * RATE))


def spectral(x, gain_fn, periodic=False):
    """Filters x by a gain over frequency (Hz -> gain). Non-periodic signals are padded so
    the filter does not wrap the tail around."""
    n = len(x)
    pad = 0 if periodic else n
    spec = np.fft.rfft(x, n + pad)
    freqs = np.fft.rfftfreq(n + pad, 1.0 / RATE)
    out = np.fft.irfft(spec * gain_fn(freqs), n + pad)
    return out[:n]


def band(lo, hi, slope=2.0):
    """Smooth band gain: rolls off below lo and above hi with `slope` (per octave-ish)."""
    def gain(f):
        f = np.maximum(f, 1.0)
        g = 1.0 / (1.0 + (lo / f) ** (2 * slope)) if lo > 0 else np.ones_like(f)
        if hi:
            g = g / (1.0 + (f / hi) ** (2 * slope))
        return g
    return gain


def tilt(db_per_octave, ref=1000.0):
    def gain(f):
        return (np.maximum(f, 20.0) / ref) ** (db_per_octave / 6.02)
    return gain


def noise(n, rng):
    return rng.normal(0.0, 1.0, n)


def periodic_noise(n, rng, gain_fn):
    """Noise shaped in the frequency domain with random phases: loops without a seam."""
    freqs = np.fft.rfftfreq(n, 1.0 / RATE)
    spec = gain_fn(freqs) * np.exp(1j * rng.uniform(0, 2 * np.pi, len(freqs)))
    spec[0] = 0
    x = np.fft.irfft(spec, n)
    return x / (np.std(x) + 1e-12)


def slow_mod(n, rng, cycles_max, depth=1.0):
    """Periodic slow modulation around 1 with random integer-cycle components."""
    t = np.arange(n) / n
    m = np.zeros(n)
    for c in range(1, cycles_max + 1):
        m += rng.uniform(0.3, 1.0) / c * np.sin(2 * np.pi * c * t + rng.uniform(0, 2 * np.pi))
    m /= np.max(np.abs(m)) + 1e-12
    return 1.0 + depth * m


def add_wrapped(buf, start, sig):
    idx = (start + np.arange(len(sig))) % len(buf)
    np.add.at(buf, idx, sig)


def add_at(buf, start, sig):
    end = min(len(buf), start + len(sig))
    if start < end:
        buf[start:end] += sig[:end - start]


def tone(freq, amp=None, harmonics=(1.0,), phase0=0.0):
    """Sine (plus harmonics) following an instantaneous frequency curve (Hz per sample)."""
    phase = phase0 + 2 * np.pi * np.cumsum(freq) / RATE
    out = np.zeros(len(freq))
    for k, h in enumerate(harmonics, start=1):
        if h:
            out += h * np.sin(k * phase)
    if amp is not None:
        out *= amp
    return out


def envelope(n, attack=0.01, release=0.05, shape=1.0):
    """Attack/release envelope; shape > 1 makes the body rounder."""
    e = np.ones(n)
    a, r = max(1, secs(attack)), max(1, secs(release))
    a, r = min(a, n), min(r, n)
    e[:a] = np.linspace(0, 1, a) ** shape
    e[n - r:] *= np.linspace(1, 0, r) ** shape
    return e


def curve(n, points):
    """Piecewise smooth curve through (t 0..1, value) points (cosine interpolation)."""
    t = np.linspace(0, 1, n)
    pts = sorted(points)
    out = np.zeros(n)
    for (t0, v0), (t1, v1) in zip(pts[:-1], pts[1:]):
        m = (t >= t0) & (t <= t1)
        u = (t[m] - t0) / max(t1 - t0, 1e-9)
        out[m] = v0 + (v1 - v0) * (0.5 - 0.5 * np.cos(np.pi * u))
    return out


def outdoor_reverb(x, rng, seconds=1.1, wet=0.25, dark=2500.0):
    """Sparse early reflections plus a dark, exponentially decaying tail (trees, hills)."""
    n = secs(seconds)
    t = np.arange(n) / RATE
    ir = noise(n, rng) * np.exp(-t * 6.9 / seconds)
    ir = spectral(ir, band(150, dark, 1.5))
    for _ in range(6):
        k = rng.integers(secs(0.02), secs(0.18))
        ir[k] += rng.uniform(-1, 1) * 3.0
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-12
    padded = np.concatenate([x, np.zeros(n)])
    size = len(padded) + n
    wet_sig = np.fft.irfft(np.fft.rfft(padded, size) * np.fft.rfft(ir, size), size)[:len(padded)]
    dry = np.concatenate([x, np.zeros(n)])
    return dry * (1 - wet) + wet_sig * wet * 2.0


def distance(x, rng, far):
    """far 0 = close, 1 = far away: duller, quieter direct sound, more reverb."""
    x = spectral(x, band(60 + 120 * far, 9000 - 6000 * far, 1.2))
    return outdoor_reverb(x, rng, seconds=0.9 + 0.8 * far, wet=0.15 + 0.45 * far, dark=4000 - 2200 * far)


def trim_tail(x, threshold=0.0015):
    peak = np.max(np.abs(x)) + 1e-12
    idx = np.nonzero(np.abs(x) > threshold * peak)[0]
    end = (idx[-1] + secs(0.05)) if len(idx) else len(x)
    x = x[:min(end, len(x))]
    fade = min(secs(0.04), len(x))
    x[-fade:] *= np.linspace(1, 0, fade)
    return x


# --- beds (periodic, event-free textures) ----------------------------------------------

def bed_rain(seconds=16, seed=11):
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    out = periodic_noise(n, rng, lambda f: band(60, 400, 1.0)(f) * tilt(-4)(f)) * 0.10  # distant roar
    out += periodic_noise(n, rng, lambda f: band(1500, 11000, 1.0)(f) * tilt(-2)(f)) * 0.035  # mist hiss
    # impacts on leaves, stone and wood: short noise ticks, colour varies per drop
    drops = 520 * seconds
    starts = rng.integers(0, n, drops)
    loud = np.exp(rng.normal(-2.4, 0.75, drops))
    grain = noise(secs(0.012), rng)
    for s, a in zip(starts, loud):
        length = int(rng.integers(secs(0.0015), secs(0.007)))
        shift = int(rng.integers(0, len(grain) - length))
        tick = grain[shift:shift + length] * np.exp(-np.arange(length) / (length / 4.0))
        if rng.random() < 0.5:
            tick = np.diff(tick, prepend=0.0)  # brighter: a hard surface
        add_wrapped(out, int(s), tick * a)
    # drops into water: tiny bubbles ringing up in pitch
    for _ in range(45 * seconds):
        length = secs(rng.uniform(0.008, 0.025))
        t = np.arange(length) / RATE
        f0 = rng.uniform(1800, 4500)
        ring = np.sin(2 * np.pi * np.cumsum(f0 * (1 + 12 * t)) / RATE) * np.exp(-t * rng.uniform(150, 320))
        add_wrapped(out, int(rng.integers(0, n)), ring * np.exp(rng.normal(-3.2, 0.5)))
    return out


def bed_wind(seconds=20, seed=12):
    """Wind through trees: low rumble plus three drifting resonances. No gusts: those come
    at runtime from the Soundscape player, so they never repeat."""
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    out = periodic_noise(n, rng, lambda f: band(25, 220, 1.2)(f)) * 0.30
    for center, width, level in ((380, 0.35, 0.16), (760, 0.3, 0.09), (1500, 0.25, 0.04)):
        res = periodic_noise(n, rng, lambda f, c=center, w=width: np.exp(-((np.log(np.maximum(f, 1) / c)) / w) ** 2))
        out += res * level * slow_mod(n, rng, 5, 0.6)
    return out


def bed_leaves(seconds=14, seed=13):
    """Rustling foliage: crackle grains in bursts (played louder in the gusts)."""
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    out = periodic_noise(n, rng, band(2500, 9000, 1.0)) * 0.02
    density = slow_mod(n, rng, 9, 0.9)
    density = np.clip(density, 0, None) ** 2
    cdf = np.cumsum(density)
    cdf /= cdf[-1]
    starts = np.searchsorted(cdf, rng.random(380 * seconds))
    grain = spectral(noise(secs(0.03), rng), band(1800, 10000, 1.0))
    for s in starts:
        length = int(rng.integers(secs(0.002), secs(0.012)))
        shift = int(rng.integers(0, len(grain) - length))
        g = grain[shift:shift + length] * np.hanning(length)
        add_wrapped(out, int(s), g * np.exp(rng.normal(-2.0, 0.6)))
    return out


def bed_stream(seconds=12, seed=14):
    """A brook a little way off: dense bubbles over a soft gurgle."""
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    out = periodic_noise(n, rng, lambda f: band(150, 1200, 1.0)(f) * tilt(-3)(f)) * 0.08
    out += periodic_noise(n, rng, band(2000, 7000, 1.0)) * 0.02
    for _ in range(140 * seconds):
        length = secs(rng.uniform(0.012, 0.05))
        t = np.arange(length) / RATE
        f0 = np.exp(rng.uniform(np.log(300), np.log(1900)))
        rise = rng.uniform(3, 14)
        bub = np.sin(2 * np.pi * np.cumsum(f0 * (1 + rise * t)) / RATE)
        bub *= np.exp(-t * rng.uniform(60, 160)) * (1 - np.exp(-t * 3000))
        add_wrapped(out, int(rng.integers(0, n)), bub * np.exp(rng.normal(-3.0, 0.6)))
    return spectral(out, band(80, 6000, 1.0), periodic=True)


def bed_roof(seconds=14, seed=16):
    """Rain heard from inside a wooden house: the roof turns the hiss into a dull drumming,
    single drops knock on the shingles above, a gutter trickles somewhere at the corner."""
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    out = periodic_noise(n, rng, lambda f: band(50, 700, 1.4)(f) * tilt(-5)(f)) * 0.14
    out += periodic_noise(n, rng, band(900, 3000, 1.0)) * 0.006
    taps = 260 * seconds
    starts = rng.integers(0, n, taps)
    loud = np.exp(rng.normal(-2.2, 0.7, taps))
    for s, a in zip(starts, loud):
        length = int(rng.integers(secs(0.004), secs(0.012)))
        t = np.arange(length) / RATE
        f0 = rng.uniform(260, 900)
        knock = np.sin(2 * np.pi * f0 * t) * np.exp(-t * rng.uniform(250, 600))
        add_wrapped(out, int(s), knock * a * 0.5)
    trickle = periodic_noise(n, rng, band(400, 2400, 1.0)) * slow_mod(n, rng, 6, 0.8) * 0.015
    out += trickle
    return spectral(out, lambda f: band(40, 5000, 1.0)(f), periodic=True)


def bed_fire(seconds=12, seed=17):
    """A fire in the fireplace: a soft breathing roar, crackles and pops, a hiss of sap."""
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    out = periodic_noise(n, rng, lambda f: band(30, 300, 1.2)(f)) * 0.22 * (0.8 + 0.2 * slow_mod(n, rng, 5, 1.0))
    out += periodic_noise(n, rng, band(2500, 7000, 1.0)) * 0.006 * slow_mod(n, rng, 7, 1.0)
    pops = 30 * seconds
    starts = rng.integers(0, n, pops)
    loud = np.exp(rng.normal(-1.6, 0.9, pops))
    grain = spectral(noise(secs(0.03), rng), band(1500, 9000, 1.0))
    for s, a in zip(starts, loud):
        length = int(rng.integers(secs(0.001), secs(0.009)))
        shift = int(rng.integers(0, len(grain) - length))
        pop = grain[shift:shift + length] * np.exp(-np.arange(length) / (length / 3.0))
        add_wrapped(out, int(s), pop * a)
        if rng.random() < 0.25:  # crackle clusters
            for k in range(int(rng.integers(2, 6))):
                add_wrapped(out, int(s) + int(rng.integers(secs(0.01), secs(0.08))) * (k + 1), pop * a * 0.4)
    return out


def bed_crickets(seconds=15, seed=15):
    """Field crickets near and far (chirps of 3-4 pulses) over a faint tree-cricket chorus."""
    rng = np.random.default_rng(seed)
    n = secs(seconds)
    t = np.arange(n) / RATE
    out = np.zeros(n)
    chorus_f = 2900.0
    am = 0.5 + 0.5 * np.sin(2 * np.pi * round(seconds * 48) / seconds * t)
    out += np.sin(2 * np.pi * chorus_f * t) * am * 0.012 * slow_mod(n, rng, 3, 0.4)
    for k in range(6):
        carrier = rng.uniform(4200, 5100)
        level = [0.10, 0.07, 0.05, 0.035, 0.025, 0.02][k]
        period = seconds / round(seconds * rng.uniform(1.6, 3.0))  # chirps per second, looped
        pulses = int(rng.integers(3, 5))
        pulse_len, gap = rng.uniform(0.010, 0.016), rng.uniform(0.012, 0.018)
        offset = rng.uniform(0, period)
        chirp_len = pulses * (pulse_len + gap)
        one = np.zeros(secs(chirp_len) + 1)
        for p in range(pulses):
            s = secs(p * (pulse_len + gap))
            m = secs(pulse_len)
            tt = np.arange(m) / RATE
            one[s:s + m] += np.sin(2 * np.pi * carrier * tt) * np.sin(np.pi * tt / pulse_len) ** 2
        c = offset
        while c < seconds:
            if rng.random() > 0.08:  # the odd missed chirp
                add_wrapped(out, secs(c), one * level * rng.uniform(0.85, 1.0))
            c += period
    return spectral(out, band(1500, 9000, 1.0), periodic=True)


# --- one-shots ---------------------------------------------------------------------------

def blackbird(rng):
    """Amsel: a slow, fluted phrase of 3-6 warbled notes, then a quiet squeaky twitter."""
    parts = []
    for _ in range(int(rng.integers(3, 7))):
        dur = rng.uniform(0.09, 0.32)
        n = secs(dur)
        base = rng.uniform(1500, 2600)
        shape = rng.choice(["rise", "fall", "arch", "dip", "flat"])
        pts = {"rise": [(0, 0.85), (1, 1.18)], "fall": [(0, 1.2), (1, 0.82)],
               "arch": [(0, 0.9), (0.5, 1.18), (1, 0.92)], "dip": [(0, 1.1), (0.5, 0.86), (1, 1.12)],
               "flat": [(0, 1.0), (1, 1.02)]}[shape]
        f = base * curve(n, pts) * (1 + 0.012 * np.sin(2 * np.pi * rng.uniform(18, 30) * np.arange(n) / RATE))
        note = tone(f, harmonics=(1.0, 0.12, 0.04)) * envelope(n, 0.015, 0.04, 1.6)
        parts += [note * rng.uniform(0.6, 1.0), np.zeros(secs(rng.uniform(0.03, 0.09)))]
    for _ in range(int(rng.integers(3, 9))):  # twitter coda
        n = secs(rng.uniform(0.025, 0.06))
        f0 = rng.uniform(4000, 7000)
        f = f0 * curve(n, [(0, 1.0), (1, rng.uniform(0.7, 1.3))])
        parts += [tone(f, harmonics=(1.0, 0.08)) * envelope(n, 0.004, 0.012) * 0.3, np.zeros(secs(rng.uniform(0.01, 0.04)))]
    return np.concatenate(parts)


def robin(rng):
    """Rotkehlchen: thin, high, fast warbles and trills that tumble up and down."""
    parts = []
    for _ in range(int(rng.integers(5, 10))):
        n = secs(rng.uniform(0.05, 0.16))
        f0 = rng.uniform(3000, 6800)
        f = f0 * curve(n, [(0, 1.0), (0.5, rng.uniform(0.75, 1.3)), (1, rng.uniform(0.7, 1.3))])
        if rng.random() < 0.45:  # trill
            f *= 1 + 0.08 * np.sin(2 * np.pi * rng.uniform(45, 80) * np.arange(n) / RATE)
        parts += [tone(f, harmonics=(1.0, 0.06)) * envelope(n, 0.006, 0.02) * rng.uniform(0.5, 1.0),
                  np.zeros(secs(rng.uniform(0.015, 0.07)))]
    return np.concatenate(parts)


def great_tit(rng):
    """Kohlmeise: 'zi-dä zi-dä zi-dä', a high short and a lower longer note, repeated."""
    hi, lo = rng.uniform(6200, 7400), rng.uniform(3900, 4700)
    parts = []
    for _ in range(int(rng.integers(3, 6))):
        n1, n2 = secs(rng.uniform(0.05, 0.07)), secs(rng.uniform(0.09, 0.13))
        a = tone(hi * curve(n1, [(0, 1.02), (1, 0.97)]), harmonics=(1.0, 0.05)) * envelope(n1, 0.004, 0.012)
        b = tone(lo * curve(n2, [(0, 1.04), (1, 0.95)]), harmonics=(1.0, 0.1)) * envelope(n2, 0.006, 0.03)
        parts += [a, np.zeros(secs(0.03)), b * 0.85, np.zeros(secs(rng.uniform(0.07, 0.11)))]
    return np.concatenate(parts)


def wood_pigeon(rng):
    """Ringeltaube: 'ru-RUUH-ru, ru-ru', soft breathy hoots."""
    pattern = [(0.22, 0.7), (0.42, 1.0), (0.2, 0.75), (0.16, 0.6), (0.16, 0.6)]
    base = rng.uniform(380, 460)
    parts = []
    for i, (dur, amp) in enumerate(pattern):
        n = secs(dur)
        f = base * curve(n, [(0, 0.92), (0.4, 1.06 if i == 1 else 1.0), (1, 0.9)])
        hoot = tone(f, harmonics=(1.0, 0.35, 0.08)) + spectral(noise(n, rng), band(300, 900, 1.0)) * 0.05
        parts += [hoot * envelope(n, 0.05, 0.08, 2.0) * amp, np.zeros(secs(0.09 if i != 2 else 0.35))]
    return spectral(np.concatenate(parts), band(150, 1600, 1.5))


def crow(rng):
    """Krähe: 2-4 harsh caws, a jittery pulse train through two formants."""
    parts = []
    for _ in range(int(rng.integers(2, 5))):
        n = secs(rng.uniform(0.22, 0.36))
        tt = np.arange(n) / RATE
        f = rng.uniform(520, 680) * curve(n, [(0, 1.08), (0.3, 1.0), (1, 0.86)])
        f *= 1 + 0.04 * noise(n, rng).cumsum() / np.sqrt(np.arange(1, n + 1))  # jitter
        saw = 2 * ((np.cumsum(f) / RATE) % 1.0) - 1
        raw = saw + 0.35 * noise(n, rng)
        formants = spectral(raw, lambda fr: np.exp(-((fr - 1250) / 380) ** 2) + 0.6 * np.exp(-((fr - 2500) / 600) ** 2))
        parts += [formants * envelope(n, 0.02, 0.07, 1.2) * np.exp(-tt * 1.5), np.zeros(secs(rng.uniform(0.25, 0.5)))]
    return np.concatenate(parts)


def owl(rng):
    """Waldkauz: 'huu-uh' ... pause ... 'hu, hu-hu-huuuuu' with a wavering long note."""
    base = rng.uniform(420, 520)
    parts = []
    n = secs(0.55)
    parts += [tone(base * curve(n, [(0, 0.95), (0.3, 1.05), (1, 0.93)]), harmonics=(1.0, 0.25)) * envelope(n, 0.06, 0.2, 1.8),
              np.zeros(secs(rng.uniform(1.2, 2.2)))]
    for dur in (0.1, 0.09, 0.09):
        m = secs(dur)
        parts += [tone(base * 0.98 * np.ones(m), harmonics=(1.0, 0.2)) * envelope(m, 0.015, 0.04) * 0.7, np.zeros(secs(0.06))]
    m = secs(1.1)
    tt = np.arange(m) / RATE
    wobble = 1 + 0.035 * np.sin(2 * np.pi * 7.5 * tt) * np.clip(tt * 3, 0, 1)
    parts.append(tone(base * 1.02 * wobble * curve(m, [(0, 1.0), (1, 0.94)]), harmonics=(1.0, 0.25)) * envelope(m, 0.05, 0.4, 1.5))
    return spectral(np.concatenate(parts), band(200, 2500, 1.5))


def dog(rng):
    """A dog somewhere down the valley: 2-3 barks."""
    parts = []
    for _ in range(int(rng.integers(2, 4))):
        n = secs(rng.uniform(0.12, 0.2))
        f = rng.uniform(330, 470) * curve(n, [(0, 1.15), (0.25, 1.0), (1, 0.8)])
        saw = 2 * ((np.cumsum(f) / RATE) % 1.0) - 1
        raw = saw + 0.6 * noise(n, rng)
        bark = spectral(raw, lambda fr: np.exp(-((fr - 900) / 400) ** 2) + 0.5 * np.exp(-((fr - 2000) / 700) ** 2))
        parts += [bark * envelope(n, 0.008, 0.08, 1.3), np.zeros(secs(rng.uniform(0.18, 0.35)))]
    return np.concatenate(parts)


def drip(rng):
    """A fat drop from the eaves into a puddle: click, then a ringing bubble."""
    n = secs(0.12)
    tt = np.arange(n) / RATE
    f0 = rng.uniform(700, 1500)
    ring = np.sin(2 * np.pi * np.cumsum(f0 * (1 + rng.uniform(4, 9) * tt)) / RATE) * np.exp(-tt * rng.uniform(35, 60))
    click = spectral(noise(secs(0.004), rng), band(1500, 9000)) * np.exp(-np.arange(secs(0.004)) / 20.0)
    out = ring * 0.8
    out[:len(click)] += click * 0.5
    return out


def twig(rng):
    """A dry twig breaking in the undergrowth: a sharp crack and a woody tick or two."""
    out = np.zeros(secs(0.15))
    for k in range(int(rng.integers(1, 3))):
        start = secs(k * rng.uniform(0.02, 0.05))
        m = secs(rng.uniform(0.004, 0.012))
        crack = noise(m, rng) * np.exp(-np.arange(m) / (m / 5.0))
        res_n = secs(0.05)
        tt = np.arange(res_n) / RATE
        body = np.sin(2 * np.pi * rng.uniform(900, 2600) * tt) * np.exp(-tt * 90) * 0.3
        add_at(out, start, crack)
        add_at(out, start, body)
    return spectral(out, band(500, 10000, 1.0))


def rustle(rng):
    """Something small moving through dry leaves: a short cluster of crackles."""
    n = secs(rng.uniform(0.4, 0.9))
    out = np.zeros(n)
    env = curve(n, [(0, 0.2), (0.3, 1.0), (0.7, 0.8), (1, 0.0)])
    for _ in range(int(n / RATE * 260)):
        s = int(rng.integers(0, n - secs(0.01)))
        m = int(rng.integers(secs(0.002), secs(0.01)))
        g = noise(m, rng) * np.hanning(m) * env[s]
        add_at(out, s, g * np.exp(rng.normal(-1.0, 0.5)))
    return spectral(out, band(1200, 9000, 1.0))


def creak(rng):
    """Old wood under load (fence board, branch): stick-slip pulses through a resonance."""
    n = secs(rng.uniform(0.45, 0.9))
    tt = np.arange(n) / RATE
    f = rng.uniform(70, 150) * curve(n, [(0, 0.85), (0.5, 1.15), (1, 0.95)])
    f *= 1 + 0.08 * np.sin(2 * np.pi * rng.uniform(3, 7) * tt)
    phase = np.cumsum(f) / RATE
    pulses = np.zeros(n)
    edges = np.nonzero(np.diff(np.floor(phase)) > 0)[0]
    for e in edges:
        m = min(secs(0.006), n - e)
        pulses[e:e + m] += np.exp(-np.arange(m) / 25.0) * rng.uniform(0.6, 1.0)
    body = spectral(pulses, lambda fr: np.exp(-((fr - rng.uniform(600, 900)) / 300) ** 2)
                    + 0.6 * np.exp(-((fr - 1900) / 500) ** 2) + 0.2)
    return body * envelope(n, 0.08, 0.15, 1.5)


SHOTS = {
    # name: (generator, variants, distance range 0..1)
    "blackbird": (blackbird, 5, (0.2, 0.7)),
    "robin": (robin, 4, (0.2, 0.6)),
    "tit": (great_tit, 3, (0.15, 0.6)),
    "pigeon": (wood_pigeon, 3, (0.4, 0.8)),
    "crow": (crow, 4, (0.55, 0.95)),
    "owl": (owl, 3, (0.4, 0.8)),
    "dog": (dog, 3, (0.85, 1.0)),
    "drip": (drip, 6, (0.0, 0.25)),
    "twig": (twig, 4, (0.1, 0.4)),
    "rustle": (rustle, 4, (0.1, 0.4)),
    "creak": (creak, 4, (0.05, 0.3)),
}

BEDS = {
    "rain": bed_rain,
    "wind": bed_wind,
    "leaves": bed_leaves,
    "stream": bed_stream,
    "crickets": bed_crickets,
    "roof": bed_roof,
    "fire": bed_fire,
}


def write(path, signal, loop):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    signal = signal / (np.max(np.abs(signal)) + 1e-9) * 0.85
    pcm = (signal * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())
    imp = path + ".import"
    if not os.path.exists(imp):
        with open(imp, "w", encoding="utf-8") as f:
            f.write(IMPORT.format(loop=2 if loop else 0))
    print("wrote", os.path.relpath(path, ROOT))


def main():
    for name, make in BEDS.items():
        write(os.path.join(BED_DIR, "nature_%s_bed.wav" % name), make(), loop=True)
    for name, (make, variants, (near, far)) in SHOTS.items():
        rng = np.random.default_rng(sum(map(ord, name)))
        for i in range(variants):
            dry = make(rng)
            wet = distance(dry, rng, rng.uniform(near, far))
            write(os.path.join(SHOT_DIR, "nature_%s_%d.wav" % (name, i)), trim_tail(wet), loop=False)


if __name__ == "__main__":
    main()
