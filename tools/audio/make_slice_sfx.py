#!/usr/bin/env python3
"""Procedural sound effects for the vertical slice (Phase 4, 0 €): the Real world's foley.
A door that creaks, knocking, falling into the stream, a stepping stone that rocks, a match
and a fire catching, a cat (meowing, behind a door, purring), a goat, dry wood, sitting down
and standing up, a bird landing, the drover's call; the child in Elysia humming the motif
of the later main theme; the hermit's flute (Act III), Lio's lute in the street and Tess's
whistling in the workshop (Act IV). The fire in the fireplace is a bed (make_nature.py, nature_fire_bed).

Like make_sfx.py (whose building blocks it uses): mono 16-bit 44.1 kHz, loudness-normalized
per group (LUFS, see GROUPS), written with .import files to assets/generated/sfx/. The Real world is quiet and a
little uneven: no sound is in tune with anything, variants differ in timing and pitch.

Usage: .venv/bin/python tools/audio/make_slice_sfx.py [--only door] [--preview out.png]
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_music import ANSWER, DORIAN, MOTIF, degree, midi_hz  # noqa: E402
from make_sfx import (RATE, at, bandpass, env, highpass, knock, lowpass, mix, noise, preview,  # noqa: E402
                      reverb, secs, sine, write)
import make_nature  # noqa: E402


def fft_band(x, lo, hi, order=3):
    """Steep band-pass by FFT (Butterworth magnitude, zero phase): noise through the one-pole
    filters of make_sfx stays hissy, a purr or a rustle needs its band to be a band."""
    n = len(x)
    f = np.maximum(np.fft.rfftfreq(2 * n, 1.0 / RATE), 1.0)
    gain = 1.0 / np.sqrt(1 + (lo / f) ** (2 * order)) / np.sqrt(1 + (f / hi) ** (2 * order))
    return np.fft.irfft(np.fft.rfft(x, 2 * n) * gain, 2 * n)[:n]


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


def frog_croak(rng, variant):
    """Quaark: a frog on the bank, two or three rough pulses through a nasal throat. Frogs
    come close when one stands still (ADR-042); this is how one notices them."""
    base = rng.uniform(150, 190) * (1.0 if variant == 0 else 1.18)
    parts = []
    for k in range(2 + variant):
        length = rng.uniform(0.11, 0.16)

        def f0(t, b=base):
            return np.interp(t, [0, length], [b * 1.05, b * 0.9])

        formants = [(0.0, [(420, 160), (1100, 260), (2300, 400)]),
                    (1.0, [(360, 160), (950, 240), (2100, 400)])]
        t = secs(length)
        rattle = 1 - 0.6 * (0.5 + 0.5 * np.sign(np.sin(2 * np.pi * rng.uniform(32, 40) * t)))
        shape = np.minimum(1.0, t / 0.01) * np.clip((length - t) / 0.05, 0, 1)
        pulse = voiced(f0, length, rng, formants, (0.0, 0.0), 0.25) * rattle * shape
        parts.append(at(pulse, k * rng.uniform(0.17, 0.22)))
    return outdoors(mix(*parts), 0.12)


def munch(rng):
    """The goat chewing a potato: wet crunches."""
    parts = []
    for k in range(5):
        tb = secs(0.09)
        crunch = bandpass(noise(len(tb), rng), 800, 3500) * env(tb, 0.004, 0.03)
        parts.append(at(crunch * rng.uniform(0.5, 1.0), k * 0.22 + rng.uniform(0, 0.05)))
    return outdoors(mix(*parts))


def cat_meow_muffled(rng):
    """The cat's meow heard through the house door: the same voice, but dull (everything
    above ~1.2 kHz gone) and a little room in it."""
    return room(lowpass(lowpass(cat_meow(rng, 0), 1200), 1200), 0.3, 0.4)


def purr(rng):
    """A cat purring in your lap: low rumble pulsed at ~25 Hz, breathing in and out."""
    seconds = 1.2
    t = secs(seconds)
    n = len(t)
    rumble = fft_band(noise(n, rng), 80, 300)
    pulse = 0.55 + 0.45 * np.sin(2 * np.pi * 25.0 * t)
    breath = np.sin(np.pi * np.clip(t / seconds, 0, 1)) ** 0.8
    return rumble * pulse * breath


# --- Cloth, wood and wings ----------------------------------------------------------------


def cloth(seconds, rng, lo=500, hi=3000, grain=0.6):
    """A rustle of fabric: noise through a band, shaped as irregular little pushes."""
    t = secs(seconds)
    n = len(t)
    body = fft_band(noise(n, rng), lo, hi, 2)
    pushes = 0.5 + 0.5 * np.abs(lowpass(noise(n, rng), 45)) * 8 * grain
    return body * np.minimum(1.0, pushes) * np.sin(np.pi * np.clip(t / seconds, 0, 1)) ** 1.3


def sit(rng):
    """Sitting down on the bench: cloth settling, then the wood takes the weight."""
    thud = knock(110, 0.2, rng, 0.2) * 0.35
    return room(mix(cloth(0.28, rng), at(thud, 0.1)), 0.1, 0.25)


def stand(rng):
    """Getting up: a shorter rustle, the bench lets go with a faint tick."""
    tick = knock(180, 0.08, rng, 0.2) * 0.12
    return room(mix(cloth(0.18, rng, 600, 3200, 0.5), tick), 0.1, 0.25)


def bird_landing(rng, variant):
    """A bird lands: two wing beats (noise 1.5-4 kHz) and a short blackbird call."""
    beats = []
    for k in range(2):
        t = secs(0.06)
        beat = fft_band(noise(len(t), rng), 1500, 4000, 2) * np.sin(np.pi * t / 0.06) ** 1.5
        beats.append(at(beat * (0.8 - 0.25 * k), 0.07 * k))
    call_rng = np.random.default_rng(100 + variant)
    call = make_nature.blackbird(call_rng)[: int(make_nature.RATE * 0.7)]
    call = np.interp(np.arange(int(len(call) * RATE / make_nature.RATE)) / RATE,
                     np.arange(len(call)) / make_nature.RATE, call)
    call = call * np.minimum(1.0, np.arange(len(call)) / (0.02 * RATE))
    call = call * np.clip((len(call) - np.arange(len(call))) / (0.06 * RATE), 0, 1)
    return outdoors(mix(*beats, at(call * 0.5, 0.2)), 0.1)


def drover_call(rng, variant):
    """The drover's shout, dry and short: three hard knocks of a stick on wood. No voice,
    nobody here is meant to be heard as a person yet."""
    parts = []
    for k in range(3):
        f = rng.uniform(180, 260)
        parts.append(at(knock(f, 0.14, rng, 0.6) * (1.0 - 0.12 * k), k * (0.095 + 0.015 * variant)))
    return mix(*parts)[: int(RATE * 0.3)]


# --- The child ----------------------------------------------------------------------------


def child_hum(rng, phrase=MOTIF, unit=0.48, space=None):
    """The child in Elysia humming to itself, mouth closed: the motif that the valley loop and
    Mira's fire play later (Game Bible §35, §46), in the same D dorian. Unlike everything in
    Elysia it is not quite in time and not quite in tune."""
    t0 = 0.2
    times = [0.0]
    pitches = []
    for deg, eighths in phrase:
        f = midi_hz(degree(62, DORIAN, deg)) * rng.uniform(0.99, 1.01)
        length = eighths * unit * rng.uniform(0.9, 1.18)
        times += [t0, t0 + length - 0.07]
        pitches += [f, f]
        t0 += length
    total = t0 + 0.45
    times.append(total)
    pitches = [pitches[0] * 0.96] + pitches + [pitches[-1] * 0.93]

    def f0(t):
        return np.interp(t, times, pitches)

    hum = [(320, 200), (950, 260), (2500, 450)]
    t = secs(total)
    # closed lips: mostly the fundamental (a soft sine), a little voice texture on top
    pitch = f0(t) * (1 + 0.007 * np.sin(2 * np.pi * 5.0 * t))
    body = np.sin(2 * np.pi * np.cumsum(pitch) / RATE)
    texture = voiced(f0, total, rng, [(0.0, hum), (1.0, hum)], (5.0, 0.007), 0.05)
    sig = body * 0.7 + texture / (np.max(np.abs(texture)) + 1e-9) * 0.3
    # a little louder on the long notes, the breath fading at the end
    swell = 0.8 + 0.2 * np.interp(t, times, [0.0] + [0.0, 1.0] * len(phrase) + [0.0])
    shape = np.minimum(1.0, t / 0.15) * np.clip((total - t) / 0.5, 0, 1)
    out = lowpass(sig * swell * shape, 1800)
    return outdoors(out, 0.14) if space is None else space(out)


# --- The hermit ---------------------------------------------------------------------------

# D4, the key of the valley (D dorian): the degrees are those of the child's hum, one note family
HERMIT_ROOT = 62
# His tune: the motif (3-5-6-5-3-2), a breath, the end of the answer (3-2-1), so it comes home.
# (degree, eighths); degree 0 is a breath. Together about 7.9 s with HERMIT_UNIT.
HERMIT_TUNE = [(3, 1), (5, 1), (6, 2), (5, 1), (3, 1), (2, 2), (0, 1.5), (3, 1), (2, 1), (1, 3)]
HERMIT_UNIT = 0.45  # seconds per eighth: slower than the child (0.48 for the motif, but he holds longer)


def flute_note(freq, seconds, rng, vibrato=0.0, breath=0.05):
    """One note of a wooden flute: nearly a sine (a hollow second and a faint third and fourth
    partial), breath noise that swells with the tone and a small chiff at the start. The pitch
    scoops up from a hair under, drifts a little (about two cents) and only the long notes get a
    vibrato, late and shallow. `breath` is the noise level against the tone."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    scoop = 2 ** (-0.30 / 12 * np.exp(-t / 0.05))
    knots = np.linspace(0, seconds, max(int(seconds / 0.4), 1) + 1)
    drift = np.interp(t, knots, rng.normal(0, 0.0010, len(knots)))
    swing = vibrato * 0.0045 * np.clip((t - 0.3) / 0.4, 0, 1) * np.sin(2 * np.pi * rng.uniform(4.8, 5.4) * t)
    phase = 2 * np.pi * np.cumsum(freq * scoop * (1 + drift + swing)) / RATE
    tone = sum(a * np.sin(k * phase) for k, a in ((1, 1.0), (2, 0.30), (3, 0.10), (4, 0.03)))
    attack = np.minimum(1.0, t / 0.05)
    shape = np.sin(0.5 * np.pi * attack) ** 2 * np.clip((seconds - t) / 0.12, 0, 1)
    shape = shape * (1 + 0.04 * np.sin(2 * np.pi * rng.uniform(0.6, 1.1) * t + rng.uniform(0, 6.28)))
    air = fft_band(noise(n, rng), 1200, 4200, 2)
    air = air / (np.std(air) + 1e-9) * breath * np.std(tone)
    chiff = air * np.exp(-t / 0.035) * 2.2
    return tone * shape + air * shape + chiff * attack


def hermit_flute(rng, unit=HERMIT_UNIT, space=None):
    """The hermit's flute (Act III, W3): his tune once through, slow and a little uneven, in the
    small wooden room of the hut. Notes overlap a hair (legato), the last one is held and dies.
    Not a loop; no pitch spread when it is played (AudioDirector.sfx(..., 1.0)): a tune stays a tune."""
    pos = 0.4
    parts = []
    for deg, eighths in HERMIT_TUNE:
        length = eighths * unit * rng.uniform(0.96, 1.06)
        if deg > 0:
            f = midi_hz(degree(HERMIT_ROOT, DORIAN, deg)) * rng.uniform(0.996, 1.004)
            held = length + 0.06 + (0.35 if eighths >= 3 else 0.0)
            note = flute_note(f, held, rng, vibrato=1.0 if eighths >= 2 else 0.0)
            parts.append(at(note * rng.uniform(0.86, 1.0), pos + rng.normal(0, 0.012)))
        pos += length
    dry = mix(*parts)
    return room(dry, 0.22, 0.40) if space is None else space(dry)


# --- Lio -----------------------------------------------------------------------------------

# Lio plays in the street (Act IV, S2): a small lute, plucked with the thumb, in the key of the
# valley (D dorian) and cheerful rather than glossy. The rising figure 3-5-6-8 is what the ear
# can follow: he sets in with it twice (the first time he stops the third note before it can
# ring), then the tune goes round, the high note of the first round is pulled somewhere else
# (sharp, a bend that does not get back) and the phrase goes on as if nothing had happened; a
# second round, where the high note sits, and a cadence (3-2-1) bring it home.
LIO_ROOT = 62  # D4, as in the hermit's tune
LIO_UNIT = 0.30  # seconds per eighth: brisker than the child (0.48) and the hermit (0.45)
# (degree, eighths); degrees above 7 continue upwards (8 is the D above the root). Together
# about 7.9 s with LIO_UNIT, a breath between the rounds and a held end.
LIO_TUNE = [(3, 1), (5, 1), (6, 1), (8, 2), (6, 1), (5, 1), (3, 2),
            (3, 1), (5, 1), (6, 1), (8, 1), (9, 2), (8, 1), (6, 1), (5, 2),
            (3, 1), (2, 1), (1, 4)]
LIO_MISS = 3  # the note of LIO_TUNE that gets away
LIO_BREATH = 7  # the note after which he takes a breath (the second round)
LIO_END = len(LIO_TUNE) - 1
# The bass strings: (index of the melody note it sounds with, MIDI note, seconds after it).
LIO_BASS = [(0, 50, -0.10), (4, 45, 0.0), (6, 50, 0.0), (11, 43, 0.0), (14, 45, 0.0),
            (15, 50, 0.0), (17, 50, 0.0), (17, 57, 0.09)]


def lute_note(freq, seconds, rng, velocity=0.85, tau=0.95, bend=None, cut=None):
    """One note of a small gut-strung lute: a plucked string (partials with a thumb's comb of
    missing ones, the high ones dying first, a hair of inharmonicity), two strings of a course
    a few cents apart so that the note shimmers slowly, a chiff of the thumb and the knock of
    the wooden body at the start. `tau` is how long the fundamental rings; `bend` is a function
    of time (cents) for a string that is pulled; `cut` stops the string with the hand after that
    many seconds. The peak of the first moments is `velocity`."""
    n = int(RATE * seconds)
    t = np.arange(n) / RATE
    base = freq if bend is None else freq * 2 ** (bend(t) / 1200)
    place = rng.uniform(0.15, 0.21)  # where along the string the thumb plucks
    bright = 0.40 + 0.60 * velocity
    out = np.zeros(n)
    for side in (-1, 1):
        spread = 1 + side * rng.uniform(0.0005, 0.0012)
        for k in range(1, 15):
            ratio = k * np.sqrt(1 + 0.00015 * k * k)
            if np.max(base) * ratio * spread > 9000:
                break
            amp = abs(np.sin(np.pi * k * place)) / k**1.1 * bright ** (k - 1)
            hz_k = np.broadcast_to(base * ratio * spread, (n,))
            phase = 2 * np.pi * np.cumsum(hz_k) / RATE + rng.uniform(0, 2 * np.pi)
            out += amp * np.exp(-t * (1 + 0.55 * (k - 1)) / tau) * np.sin(phase)
    out *= np.minimum(1.0, t / 0.002)
    out = out / (np.max(np.abs(out[: int(RATE * 0.12)])) + 1e-9)
    m = int(RATE * 0.03)
    tm = np.arange(m) / RATE
    chiff = fft_band(noise(m, rng), 1500, 5500, 2) * np.exp(-tm / 0.004)
    thump = np.sin(2 * np.pi * rng.uniform(170, 210) * tm) * np.exp(-tm / 0.03)
    out[:m] += 0.28 * chiff / (np.max(np.abs(chiff)) + 1e-9) + 0.22 * thump
    if cut is None:
        out *= np.clip((seconds - t) / 0.08, 0, 1)
    else:
        out *= np.where(t > cut, np.exp(-(t - cut) / 0.012), 1.0)
    return out * velocity


def lio_street(rng, unit=LIO_UNIT, space=None):
    """Lio's street music (Act IV, S2): see LIO_TUNE. Not a loop; no pitch spread when it is
    played (AudioDirector.sfx(..., 1.0)): a tune stays a tune, and the one wrong note is its own."""

    def pitch(deg):
        return midi_hz(degree(LIO_ROOT, DORIAN, deg)) * rng.uniform(0.998, 1.002)

    parts = []
    # the first attempt: two notes, then the third is stopped before it can ring
    for when, deg, vel, cut in ((0.35, 3, 0.78, None), (0.68, 5, 0.80, None), (1.03, 6, 0.70, 0.08)):
        note = lute_note(pitch(deg), 0.5 if cut else 2.4, rng, vel, cut=cut)
        parts.append(at(note, when + rng.normal(0, 0.008)))
    # a knuckle on the wood: again, from the top
    parts.append(at(knock(190, 0.12, rng, 0.2) * 0.10, 1.62))
    # the second attempt carries through
    pos = 2.20
    onsets = []
    for i, (deg, eighths) in enumerate(LIO_TUNE):
        stretch = 1.0
        if i in (LIO_MISS + 1, LIO_MISS + 2):
            stretch = 0.93  # on he goes, a little quicker
        elif i == LIO_END - 1:
            stretch = 1.15  # the cadence settles
        if i == LIO_BREATH:
            pos += 0.38
        onsets.append(pos)
        length = eighths * unit * stretch * rng.uniform(0.97, 1.04)
        vel = rng.uniform(0.76, 0.92)
        if i == LIO_MISS:
            # meant to be the high D: lands a semitone sharp and is pulled half-way back
            def pulled(t):
                return 105 - 55 * np.clip(t / 0.45, 0, 1) + 5 * np.sin(2 * np.pi * 5.5 * t)

            note = lute_note(pitch(deg), 2.4, rng, 0.95, bend=pulled)
        else:
            note = lute_note(pitch(deg), 3.4 if i == LIO_END else 2.4, rng, vel)
        parts.append(at(note, pos + rng.normal(0, 0.010)))
        pos += length
    for index, midi, late in LIO_BASS:
        note = lute_note(midi_hz(midi) * rng.uniform(0.998, 1.002), 3.0, rng, 0.62, tau=1.5)
        parts.append(at(note, onsets[index] + late + rng.normal(0, 0.008)))
    dry = mix(*parts)
    dry = mix(dry, 0.3 * fft_band(dry, 110, 320, 2))  # the wooden body
    return reverb(dry, 0.5, 0.18, seed=19, bright=3800) if space is None else space(dry)


# --- Tess ------------------------------------------------------------------------------------

# Tess whistles while she measures (Act IV, S4): to herself, between the work, not for anyone. Not
# the valley's D dorian but F mixolydian, high (F5 is the root, a whistle lives between 600 and
# 1300 Hz), and a line that only goes down: from the D above, in two sighs, the second one
# leaves its last note a third of a semitone low and does not mind, then a trill (G and A,
# nine turns) and the root, held, that sags at the end as a breath does.
TESS_ROOT = 77  # F5


def workshop(x):
    """The workshop: wood, sawdust and tools, so a dry room. A pure tone meets a random room as a
    room mode, a note at one pitch comes out several dB louder than its neighbour; the seed was
    picked (of 200) for the flattest response on the notes of the tune, and the tail is thin."""
    return reverb(x, 0.34, 0.14, seed=42, bright=2800)
# (semitones over the root, units, cents off (0: a few cents at random), a rest after in units);
# the trill and the last note are added in tess_whistle.
TESS_TUNE = [(9, 1.5, 0, 0.0), (7, 0.5, 0, 0.0), (5, 1.0, 0, 0.0), (4, 1.5, 0, 0.0), (2, 1.5, 0, 1.6),
             (5, 1.0, 0, 0.0), (4, 1.0, 0, 0.0), (2, 1.5, -38, 0.0)]
TESS_UNIT = 0.42  # seconds per unit
TESS_TRILL = (2, 4)  # the two notes of the trill (semitones over the root)
TESS_TURNS = 9  # notes of the trill (it begins on the lower one)
TESS_TURN = 0.113  # seconds per note of the trill


def tess_whistle(rng, unit=TESS_UNIT, space=None):
    """Tess's whistling (Act IV, S4): see TESS_TUNE. One breath, one oscillator: the pitch is a
    curve (notes slide into each other, a note after a rest is scooped up from a hair under, the
    long ones carry a shallow late vibrato, the last one sags), the tone is nearly a sine with a
    faint second partial, and the air is noise around the tone (it follows the pitch) and a hiss
    above it that comes with the start of a note. Not a loop; no pitch spread when it is played
    (AudioDirector.sfx(..., 1.0)): a tune stays a tune, and the low note is its own."""
    notes = []  # (start, end, semitones, cents off, after a rest)
    pos = 0.35
    after_rest = True
    for semis, units, off, rest in TESS_TUNE:
        length = units * unit * rng.uniform(0.97, 1.05)
        if off == 0:
            off = float(np.clip(rng.normal(0, 6), -11, 11))  # a whistle is never quite on the note
        notes.append((pos, pos + length, semis, off, after_rest))
        pos += length + rest * unit
        after_rest = rest > 0
    for k in range(TESS_TURNS):
        length = TESS_TURN * rng.uniform(0.94, 1.06)
        notes.append((pos, pos + length, TESS_TRILL[k % 2], float(rng.normal(-8, 4)), False))
        pos += length
    final = (pos, pos + 1.5, 0, -4.0, False)  # the root, held and let go
    notes.append(final)
    total = final[1] + 0.12

    # the pitch curve in cents over the root, built from breakpoints: (time, cents)
    knots = []
    for i, (s, e, semis, off, rested) in enumerate(notes):
        cents = 100.0 * semis + off
        glide = 0.018 if i >= len(TESS_TUNE) and i < len(notes) - 1 else 0.06
        if rested:
            knots += [(s, cents - 45), (s + 0.09, cents)]  # scooped up from under
        else:
            knots += [(s + glide, cents)]
        knots += [(e - 0.02, cents)] if i < len(notes) - 1 else [(e - 0.60, cents), (e, cents - 130)]
    ts = np.array([k[0] for k in knots])
    cs = np.array([k[1] for k in knots])
    order = np.argsort(ts, kind="stable")
    t = np.arange(int(RATE * total)) / RATE
    cents = np.interp(t, ts[order], cs[order])
    # long notes carry a late, shallow vibrato; the pitch wanders a few cents on its own
    depth = np.zeros_like(t)
    for s, e, semis, off, rested in notes:
        if e - s >= 0.8:
            ramp = np.interp(t, [s, s + 0.35, s + 0.75, e - 0.10, e], [0, 0, 1, 1, 0])
            depth = np.maximum(depth, ramp)
    cents = cents + depth * 11 * np.sin(2 * np.pi * rng.uniform(5.0, 5.6) * t)
    wander_t = np.linspace(0, total, int(total / 0.4) + 2)
    cents = cents + np.interp(t, wander_t, rng.normal(0, 3.0, len(wander_t)))
    smooth = int(RATE * 0.012)
    cents = np.convolve(np.pad(cents, smooth, mode="edge"), np.ones(smooth) / smooth, mode="same")[smooth:-smooth]
    freq = midi_hz(TESS_ROOT) * 2 ** (cents / 1200)
    phase = 2 * np.pi * np.cumsum(freq) / RATE

    # the breath: up quickly, a little swell, down; a rest is silence. Between the turns of the
    # trill the breath dips but does not stop.
    breaks = [(0.0, 0.0)]
    for i, (s, e, semis, off, rested) in enumerate(notes):
        trill = len(TESS_TUNE) <= i < len(notes) - 1
        level = rng.uniform(0.86, 1.0) if not trill else 0.80 + 0.12 * np.sin(np.pi * (i - len(TESS_TUNE) + 0.5) / TESS_TURNS)
        last = i == len(notes) - 1
        next_rest = (not last) and i + 1 < len(notes) and notes[i + 1][0] - e > 0.2
        if rested or i == 0:
            breaks += [(s - 0.03, 0.0), (s + 0.045, level)]
        elif trill:
            breaks += [(s + 0.006, level * 0.80), (s + 0.04, level)]
        else:
            breaks += [(s + 0.02, level * 0.72), (s + 0.07, level)]  # a soft dip where one note takes the next
        if last:
            breaks += [(e - 0.70, level * 0.9), (e - 0.05, level * 0.25), (e, 0.0)]
        elif next_rest:
            breaks += [(e - 0.12, level * 0.9), (e + 0.03, 0.0)]
        else:
            breaks += [(e - 0.03, level)]
    breaks.append((total, 0.0))
    bt = np.array([b[0] for b in breaks])
    bv = np.array([b[1] for b in breaks])
    order = np.argsort(bt, kind="stable")
    amp = np.interp(t, bt[order], bv[order])
    amp = amp * (1 + 0.04 * np.sin(2 * np.pi * 0.7 * t + rng.uniform(0, 6.28)))

    tone = np.sin(phase) + 0.045 * np.sin(2 * phase + 0.7) + 0.012 * np.sin(3 * phase + 1.9)
    # air around the tone: low noise carried up to the pitch by the oscillator, so it follows it
    carrier = fft_band(noise(len(t), rng), 20, 240, 2)
    carrier = carrier / (np.std(carrier) + 1e-9)
    near = carrier * np.sin(phase + 0.4) * 1.4
    hiss = fft_band(noise(len(t), rng), 2200, 6500, 2)
    hiss = hiss / (np.std(hiss) + 1e-9)
    sig_std = float(np.std(tone * amp)) + 1e-9
    breath = amp**0.8
    puff = np.zeros_like(t)
    for s, e, semis, off, rested in notes:
        if rested:
            m = (t >= s - 0.02) & (t < s + 0.12)
            puff[m] = np.exp(-(t[m] - (s - 0.02)) / 0.03)
    out = tone * amp + sig_std * (0.085 * near * breath + 0.020 * hiss * breath + 0.060 * hiss * puff)
    out = out * np.minimum(1.0, t / 0.01)
    return workshop(out) if space is None else space(out)


# Loudness per group (LUFS, K-weighted), see make_sfx.GROUPS: the Real world's foley sits a
# few dB over the beds (-27 LUFS) so that doors, steps and animals are heard. The door,
# water and stone targets are what their sharp peaks allow under the -1 dBFS ceiling.
GROUPS = {"door": -18.0, "knock": -15.0, "water": -15.5, "stone": -18.0, "fire": -16.0,
          "animal": -17.0, "wood": -17.0, "child_hum": -18.0, "house_hum": -20.0, "cat": -17.0, "purr": -20.0,
          "cloth": -18.0, "bird": -16.0, "bark": -17.0, "flute": -20.0, "lute": -20.0, "whistle": -21.0}
LOOPS = set()


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
        "goat_munch": (munch(rng), "animal"),
    }
    for i in range(2):
        sounds["cat_meow_%d" % i] = (cat_meow(rng, i), "cat")
        sounds["goat_bleat_%d" % i] = (goat_bleat(rng, i), "animal")
    # its own random stream, so the sounds above stay as they were
    hum_rng = np.random.default_rng(31)
    for i in range(2):
        sounds["child_hum_%d" % i] = (child_hum(hum_rng), "child_hum")
    # the song in the house (Act II, B5): its own stream again
    home_rng = np.random.default_rng(43)
    sounds["house_hum_0"] = (child_hum(home_rng, ANSWER, 0.30, lambda x: room(x, 0.25, 0.45)), "house_hum")
    # frogs get their own random stream too (ADR-042)
    frog_rng = np.random.default_rng(37)
    for i in range(2):
        sounds["frog_croak_%d" % i] = (frog_croak(frog_rng, i), "animal")
    # the sounds of the second polish round get their own random stream as well
    new_rng = np.random.default_rng(41)
    sounds["cat_meow_muffled"] = (cat_meow_muffled(new_rng), "cat")
    sounds["purr"] = (purr(new_rng), "purr")
    sounds["sit"] = (sit(new_rng), "cloth")
    sounds["stand"] = (stand(new_rng), "cloth")
    sounds["bird"] = (bird_landing(new_rng, 0), "bird")
    for i in range(3):
        sounds["bark_%d" % i] = (drover_call(new_rng, i), "bark")
    # the hermit's flute (Act III, W3): its own random stream again
    flute_rng = np.random.default_rng(47)
    sounds["hermit_flute_0"] = (hermit_flute(flute_rng), "flute")
    # Lio's lute (Act IV, S2): its own random stream again
    lute_rng = np.random.default_rng(53)
    sounds["lio_street_0"] = (lio_street(lute_rng), "lute")
    # Tess's whistling (Act IV, S4): its own random stream again
    whistle_rng = np.random.default_rng(59)
    sounds["tess_whistle_0"] = (tess_whistle(whistle_rng), "whistle")
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
