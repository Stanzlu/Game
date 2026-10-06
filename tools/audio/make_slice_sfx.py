#!/usr/bin/env python3
"""Procedural sound effects for the vertical slice (Phase 4, 0 €): the Real world's foley.
A door that creaks, knocking, falling into the stream, a stepping stone that rocks, a match
and a fire catching, a fire crackling in the fireplace (loop), a cat, a goat, dry wood.

Like make_sfx.py (whose building blocks it uses): mono 16-bit 44.1 kHz, peak-normalized per
group, written with .import files to assets/generated/sfx/. The Real world is quiet and a
little uneven: no sound is in tune with anything, variants differ in timing and pitch.

Usage: .venv/bin/python tools/audio/make_slice_sfx.py [--only door] [--preview out.png]
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_sfx import (RATE, at, bandpass, env, highpass, knock, lowpass, mix, noise, preview,  # noqa: E402
                      reverb, secs, sine, write)


def room(x, wet=0.18, seconds=0.35):
    """A small wooden room (the house): short, dark reflections."""
    return reverb(x, seconds, wet, seed=11, bright=2500)


def outdoors(x, wet=0.08):
    return reverb(x, 0.25, wet, seed=13, bright=4000)


# --- Wood and doors ---------------------------------------------------------------------


def creak(seconds, rng, f0=180.0, f1=260.0, roughness=0.6):
    """A hinge or a board under load: stick-slip friction, a train of tiny impulses whose
    rate glides, through two wood resonances."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    rate = np.interp(t, [0, seconds * 0.3, seconds * 0.7, seconds],
                     [f0, f1, f1 * 0.9, f0 * 1.1]) * (1 + 0.04 * np.sin(2 * np.pi * 7 * t))
    phase = np.cumsum(rate / RATE)
    jitter = rng.uniform(0.0, roughness, n) * (np.diff(np.floor(phase), prepend=0) > 0)
    pulses = (np.diff(np.floor(phase), prepend=0) > 0).astype(float) * (1 - roughness * 0.5 + jitter)
    body = bandpass(pulses, 400, 1400) * 1.2 + bandpass(pulses, 1800, 3200) * 0.5
    shape = np.sin(np.pi * np.clip(t / seconds, 0, 1)) ** 0.6
    return body * shape


def door_open(rng):
    """Latch click, then the old door swings: a long rising creak, wood settling."""
    latch = mix(knock(1900, 0.05, rng, 0.9) * 0.6, at(knock(1400, 0.04, rng, 0.8) * 0.4, 0.03))
    swing = creak(0.9, rng, 150, 240, 0.5)
    thump = knock(110, 0.25, rng, 0.2) * 0.5
    return room(mix(latch, at(swing * 0.8, 0.12), at(thump, 0.95)))


def door_close(rng):
    """A short creak and the door falls into its frame: a dull thud, the latch."""
    swing = creak(0.35, rng, 220, 160, 0.4)
    thud = mix(knock(85, 0.35, rng, 0.3),
               0.4 * lowpass(noise(int(RATE * 0.3), rng), 300) * env(secs(0.3), 0.002, 0.06))
    latch = knock(2100, 0.04, rng, 0.9) * 0.5
    return room(mix(swing * 0.6, at(thud, 0.32), at(latch, 0.36)))


def door_knock(rng):
    """Three knocks on the door, knuckles on wet wood: not quite even, the last one softer."""
    times = [0.0, 0.24 + rng.uniform(-0.02, 0.02), 0.5 + rng.uniform(-0.03, 0.03)]
    hits = [knock(170 * rng.uniform(0.95, 1.05), 0.22, rng, 0.45) * a for a in (1.0, 0.9, 0.7)]
    return room(mix(*[at(h, s) for h, s in zip(hits, times)]), 0.25, 0.5)


def wood_drop(rng):
    """An armful of dry logs set down on the floor: a few hollow knocks, a rattle."""
    parts = []
    for k in range(6):
        f = rng.uniform(180, 520)
        parts.append(at(knock(f, 0.18, rng, rng.uniform(0.3, 0.7)) * rng.uniform(0.5, 1.0), k * 0.06 + rng.uniform(0, 0.04)))
    return room(mix(*parts))


# --- Water and stones -------------------------------------------------------------------


def splash_fall(rng):
    """Falling into the stream: the body hitting the water, a heavy slosh, bubbles rising,
    drips running off afterwards."""
    t = secs(1.6)
    n = len(t)
    hit = lowpass(noise(n, rng), np.geomspace(5000, 600, n)) * env(t, 0.003, 0.18)
    slosh = bandpass(noise(n, rng), 200, 1200) * env(t, 0.06, 0.35) * 0.8
    bubbles = np.zeros(n)
    for _ in range(26):
        start = rng.uniform(0.08, 0.9)
        f = rng.uniform(350, 900)
        tb = secs(0.05)
        blip = sine(f * (1 + 2.5 * tb / 0.05), tb) * env(tb, 0.002, 0.015)
        bubbles = mix(bubbles, at(blip * rng.uniform(0.1, 0.35), start, n / RATE))
    drips = np.zeros(n)
    for _ in range(9):
        tb = secs(0.04)
        drip = sine(rng.uniform(1200, 2200), tb) * env(tb, 0.001, 0.01)
        drips = mix(drips, at(drip * 0.15, rng.uniform(0.7, 1.5), n / RATE))
    sub = sine(55, t) * env(t, 0.005, 0.12) * 0.6
    return outdoors(mix(hit, slosh, bubbles, drips, sub))


def stone_wobble(rng):
    """A stone rocking on another under water: two dull clacks, a slosh."""
    clack = mix(knock(950, 0.06, rng, 0.8) * 0.8, knock(420, 0.1, rng, 0.4) * 0.6)
    clack2 = knock(1100, 0.05, rng, 0.7) * 0.5
    slosh = bandpass(noise(int(RATE * 0.4), rng), 300, 1500) * env(secs(0.4), 0.03, 0.12) * 0.5
    return outdoors(mix(clack, at(clack2, 0.11), at(slosh, 0.02)))


# --- Fire -------------------------------------------------------------------------------


def crackles(n, rng, density, loud=1.0):
    """Random pops and ticks of burning wood, some in short bursts."""
    out = np.zeros(n)
    count = int(density * n / RATE)
    for _ in range(count):
        pos = int(rng.uniform(0, n - 600))
        length = int(rng.uniform(40, 400))
        burst = highpass(noise(length, rng), rng.uniform(1500, 4000))
        burst *= np.exp(-np.arange(length) / (length * 0.25)) * rng.uniform(0.15, 1.0) ** 2 * loud
        out[pos:pos + length] += burst
        if rng.uniform() < 0.2:  # a little cluster
            for k in range(int(rng.integers(2, 5))):
                p2 = pos + int(rng.uniform(300, 2500)) * (k + 1)
                if p2 + length < n:
                    out[p2:p2 + length] += burst * rng.uniform(0.3, 0.7)
    return out


def fire_light(rng):
    """A match struck on the box, it flares; the kindling catches with a soft whoosh and
    the first crackles."""
    scratch_t = secs(0.18)
    scratch = bandpass(noise(len(scratch_t), rng), 2500, 7000) * env(scratch_t, 0.01, 0.06)
    flare_t = secs(0.5)
    flare = bandpass(noise(len(flare_t), rng), 600, 3000) * env(flare_t, 0.005, 0.12) * 0.8
    whoosh_t = secs(1.6)
    sweep = np.geomspace(150, 900, len(whoosh_t))
    whoosh = lowpass(noise(len(whoosh_t), rng), sweep) * np.sin(np.pi * np.clip(whoosh_t / 1.6, 0, 1)) ** 1.5
    first = crackles(int(RATE * 1.6), rng, 14, 0.6)
    return room(mix(scratch, at(flare, 0.15), at(whoosh * 1.4, 0.6), at(first, 0.9)), 0.12)


def fire_crackle(rng):
    """A fire in the fireplace, seamless 8 s loop: a low soft roar that breathes, crackles
    and pops at random, now and then a log settling."""
    seconds = 8.0
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    breath = 0.75 + 0.25 * np.sin(2 * np.pi * t / seconds * 3 + 0.4) * np.sin(2 * np.pi * t / seconds * 2)
    roar = lowpass(noise(n, rng), 260) * 2.2 * breath
    hiss = bandpass(noise(n, rng), 2500, 6000) * 0.05 * breath
    pops = crackles(n, rng, 22)
    settle = at(knock(140, 0.3, rng, 0.2) * 0.35, 5.1, seconds)
    loop = mix(roar, hiss, pops, settle)[:n]
    # make it seamless: crossfade the tail into the head
    fade = int(RATE * 0.5)
    ramp_in = np.linspace(0, 1, fade)
    loop[:fade] = loop[:fade] * ramp_in + loop[-fade:] * (1 - ramp_in)
    return loop[:-fade]


# --- Animals ----------------------------------------------------------------------------


def voiced(f0, seconds, rng, formants, vibrato=(0.0, 0.0), breath=0.1):
    """A voice: glottal pulses (sawtooth-ish) at pitch contour f0(t), through moving
    formants [(t, [(freq, bw)...]), ...] given as keyframes."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    pitch = f0(t) * (1 + vibrato[1] * np.sin(2 * np.pi * vibrato[0] * t))
    phase = np.cumsum(pitch / RATE) % 1.0
    src = (2 * phase - 1) - 0.4 * np.sin(2 * np.pi * phase * 2)
    src = src + breath * noise(n, rng)
    out = np.zeros(n)
    keys = [k for k, _ in formants]
    for i in range(len(formants[0][1])):
        f = np.interp(t / seconds, keys, [fs[i][0] for _, fs in formants])
        bw = np.interp(t / seconds, keys, [fs[i][1] for _, fs in formants])
        out += bandpass(src, np.maximum(f - bw / 2, 60), f + bw / 2) * (1.0 / (i + 1))
    return out


def cat_meow(rng, variant):
    """Mi-a-u: pitch rises then falls, the mouth opens (formants up) and closes."""
    peak = rng.uniform(680, 820) * (1.0 if variant == 0 else 1.12)
    length = rng.uniform(0.55, 0.75)

    def f0(t):
        return np.interp(t, [0, length * 0.35, length], [peak * 0.75, peak, peak * 0.62])

    formants = [(0.0, [(700, 300), (1700, 400), (3000, 600)]),
                (0.4, [(1100, 400), (2300, 500), (3500, 700)]),
                (1.0, [(600, 300), (1200, 400), (2800, 600)])]
    t = secs(length)
    shape = np.minimum(1.0, t / 0.05) * np.clip((length - t) / 0.15, 0, 1)
    return outdoors(voiced(f0, length, rng, formants, (6, 0.01), 0.05) * shape, 0.12)


def goat_bleat(rng, variant):
    """Mä-ä-äh: a goat's bleat, nasal, with the typical fast tremolo."""
    base = rng.uniform(290, 340) * (1.0 if variant == 0 else 0.86)
    length = rng.uniform(0.7, 0.95)

    def f0(t):
        return np.interp(t, [0, 0.08, length * 0.7, length], [base * 0.9, base * 1.08, base, base * 0.82])

    formants = [(0.0, [(600, 250), (1500, 300), (2600, 500)]),
                (0.2, [(850, 300), (1800, 350), (2700, 500)]),
                (1.0, [(750, 300), (1650, 350), (2600, 500)])]
    t = secs(length)
    tremolo = 1 - 0.55 * (0.5 + 0.5 * np.sin(2 * np.pi * rng.uniform(8.5, 10.5) * t))
    shape = np.minimum(1.0, t / 0.03) * np.clip((length - t) / 0.12, 0, 1)
    return outdoors(voiced(f0, length, rng, formants, (9.5, 0.03), 0.15) * tremolo * shape, 0.1)


def munch(rng):
    """The goat chewing a potato: wet crunches."""
    parts = []
    for k in range(5):
        tb = secs(0.09)
        crunch = bandpass(noise(len(tb), rng), 800, 3500) * env(tb, 0.004, 0.03)
        parts.append(at(crunch * rng.uniform(0.5, 1.0), k * 0.22 + rng.uniform(0, 0.05)))
    return outdoors(mix(*parts))


GROUPS = {"door": -6.0, "knock": -4.0, "water": -3.0, "stone": -6.0, "fire": -6.0, "fire_loop": -10.0,
          "animal": -6.0, "wood": -6.0}
LOOPS = {"fire_loop"}


def build(only=None):
    rng = np.random.default_rng(29)
    sounds = {
        "door_open": (door_open(rng), "door"),
        "door_close": (door_close(rng), "door"),
        "door_knock": (door_knock(rng), "knock"),
        "wood_drop": (wood_drop(rng), "wood"),
        "splash_fall": (splash_fall(rng), "water"),
        "stone_wobble": (stone_wobble(rng), "stone"),
        "fire_light": (fire_light(rng), "fire"),
        "fire_crackle": (fire_crackle(rng), "fire_loop"),
        "goat_munch": (munch(rng), "animal"),
    }
    for i in range(2):
        sounds["cat_meow_%d" % i] = (cat_meow(rng, i), "animal")
        sounds["goat_bleat_%d" % i] = (goat_bleat(rng, i), "animal")
    for name, (sig, group) in sounds.items():
        if only and not name.startswith(only):
            continue
        write(name, sig, GROUPS[group], loop=group in LOOPS)
    return sounds


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--only")
    parser.add_argument("--preview")
    args = parser.parse_args()
    built = build(args.only)
    if args.preview:
        preview(built, args.preview)
