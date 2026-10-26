#!/usr/bin/env python3
"""Level check for the mix (part of tools/check.sh): nobody can listen in CI, so loudness is
measured. Fails (exit 1) when

- a generated sound is not within 0.5 dB of the loudness of its group (make_sfx.GROUPS,
  make_slice_sfx.GROUPS), peaks above the -1 dBFS ceiling, or carries DC / clicks at the ends;
- the footsteps differ in loudness (placeholders: STEP_LOUDNESS) or peak above -6 dBFS, or
  FootstepPlayer.SURFACE_DB drifts apart (a jump from grass to tall grass, ground > 6 dB apart);
- a place's ambience (content/audio/*.tres at the ambience level of its scene) is not at its
  target, or the places are further than 3 dB apart: the level of a room must not jump on a
  door;
- a class of sounds, at its call-site gain and bus trim, does not land in its window over the
  bed of the place where it is heard (the table below; call sites are compared, drift is only
  reported because the gains live in other scripts).

Usage: .venv/bin/python tools/audio/check_levels.py [--table]   (--table prints every number)
Measuring the real thing: tools/audio/measure.sh (a capture with sound, then loudness per second).
"""
import argparse
import glob
import math
import os
import re
import sys
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "placeholders"))
import loudness  # noqa: E402
import make_sfx  # noqa: E402
import make_slice_sfx  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SFX = os.path.join(ROOT, "assets", "generated", "sfx")
BEDS = os.path.join(ROOT, "assets", "generated", "audio")
STEPS = os.path.join(ROOT, "assets", "placeholder", "audio")

TOLERANCE_DB = 0.5
CEILING_DB = -1.0
STEP_LOUDNESS_DB = -19.0
STEP_PEAK_DB = -6.0
BUS_TRIM_DB = {"SFX": -2.0, "UI": 0.0, "Voice": 0.0, "Ambience": 0.0}

# File name pattern -> group. The group's loudness comes from the generators.
SFX_GROUPS = [
    (r"ui_elysia_", make_sfx.GROUPS["ui_elysia"]),
    (r"ui_real_", make_sfx.GROUPS["ui_real"]),
    (r"coin_\d", make_sfx.GROUPS["coin"]),
    (r"xp$", make_sfx.GROUPS["xp"]),
    (r"level_up$", make_sfx.GROUPS["level_up"]),
    (r"chest_open$", make_sfx.GROUPS["chest"]),
    (r"loot_", make_sfx.GROUPS["loot"]),
    (r"praise$", make_sfx.GROUPS["praise"]),
    (r"pickup_real_", make_sfx.GROUPS["pickup_real"]),
    (r"voice_", make_sfx.GROUPS["voice"]),
    (r"glitch_", make_sfx.GROUPS["glitch"]),
    (r"rift_touch$", make_sfx.GROUPS["rift"]),
    (r"rift_hum$", make_sfx.GROUPS["rift_hum"]),
    (r"door_open$|door_close$", make_slice_sfx.GROUPS["door"]),
    (r"door_knock$", make_slice_sfx.GROUPS["knock"]),
    (r"splash_fall$", make_slice_sfx.GROUPS["water"]),
    (r"stone_wobble$", make_slice_sfx.GROUPS["stone"]),
    (r"fire_light$", make_slice_sfx.GROUPS["fire"]),
    (r"wood_drop$", make_slice_sfx.GROUPS["wood"]),
    (r"goat_|frog_croak_", make_slice_sfx.GROUPS["animal"]),
    (r"cat_meow_", make_slice_sfx.GROUPS["cat"]),
    (r"child_hum_", make_slice_sfx.GROUPS["child_hum"]),
    (r"house_hum_", make_slice_sfx.GROUPS["house_hum"]),
    (r"hermit_flute_", make_slice_sfx.GROUPS["flute"]),
    (r"purr$", make_slice_sfx.GROUPS["purr"]),
    (r"sit$|stand$", make_slice_sfx.GROUPS["cloth"]),
    (r"bird$", make_slice_sfx.GROUPS["bird"]),
    (r"bark_", make_slice_sfx.GROUPS["bark"]),
]
# The rift's glitches tear open on purpose.
CLICK_OK = re.compile(r"^glitch_")
# Grouped one-shots of the soundscapes (make_nature.py) are tuned per event in the .tres.
SKIP = re.compile(r"^nature_")

# Places: the .tres behind each, the ambience_db its scene asks for (day_light.gd presets,
# haus.tscn, look_wald.tscn) and the loudness the soundscape should sum to (LUFS, energy mean
# over a minute with the wind gusting: the day's rain is the reference, the rooms and the
# evening sit within 3 dB of each other so a door or the turn of the day does not jump).
PLACES = {
    "tal_regentag": ("tal_regentag.tres", -5.5, -25.2),
    "tal_abend": ("tal_abend.tres", -8.0, -25.7),
    "tal_nacht": ("tal_nacht.tres", -4.0, -25.1),
    "haus_kalt": ("haus_kalt.tres", -5.0, -24.8),
    "haus_feuer": ("haus_feuer.tres", -5.0, -26.2),
    "wald_nacht": ("wald_nacht.tres", -5.0, -25.6),
    "haus_abend": ("haus_abend.tres", -5.0, -25.5),
    "tal_morgen": ("tal_morgen.tres", -7.0, -25.7),
    "haus_morgen": ("haus_morgen.tres", -5.0, -25.5),
}
PLACE_TOLERANCE_DB = 1.5
PLACE_SPAN_DB = 3.0
# Model of the in-game level, fitted to two sets of captures of the six soundscapes (36 s each,
# before and after the level changes of polish round 2; residual at most 1 dB; the targets
# above are the measured values, tools/audio/bed_probe.gd): a bed plays twice (left and
# right) and the panner and the mono-to-stereo mix add BED_GAIN_DB to its file loudness;
# single event sounds add EVENT_GAIN_DB; beds that follow the wind swell with a typical gust,
# 0.5 * wind.
BED_GAIN_DB = 8.35
EVENT_GAIN_DB = 4.0
EVENT_RANDOM_DB = -2.0  # SoundscapePlayer._fire draws -5..+1 dB

# Reference level of Elysia: its music alone (TRACK_DB "elysia", measured in the game).
ELYSIA_MUSIC_LUFS = -20.0

# Sound classes as heard: (label, [file names], call-site gain dB, bus, place, lowest and
# highest margin over the place's bed in LU). In-game level = group loudness + call gain + bus
# trim (default_bus_layout.tres). The call gains are the recommendations of the polish round;
# the call sites are read below and any drift is reported (the gains live in other scripts).
# Real-world sounds must be heard over the bed (not buried, not shouting); Elysia is led by
# its music, so its sounds sit around it. The reward gains were measured in a capture of the
# reward stacks (butterflies, the gardener's reward, the chest): peaks at most -4.5 dBFS,
# short-term loudness at most -17 LUFS (the music alone is at -19).
CLASSES = [
    ("door open", ["door_open"], 0.0, "SFX", "haus_feuer", 2.0, 10.0),
    ("door close", ["door_close"], -3.0, "SFX", "haus_feuer", 0.0, 8.0),
    ("door knock", ["door_knock"], 0.0, "SFX", "haus_feuer", 2.0, 12.0),
    ("fire catches", ["fire_light"], 0.0, "SFX", "haus_feuer", 2.0, 12.0),
    ("wood set down", ["wood_drop"], 0.0, "SFX", "haus_feuer", 2.0, 10.0),
    ("sit down, get up", ["sit", "stand"], 0.0, "SFX", "tal_abend", 2.0, 8.0),
    ("cat", ["cat_meow_0", "cat_meow_muffled"], 0.0, "SFX", "haus_feuer", 2.0, 10.0),
    ("purr", ["purr"], 0.0, "SFX", "haus_feuer", 0.0, 8.0),
    ("song in the house", ["house_hum_0"], -2.0, "SFX", "haus_feuer", 0.0, 6.0),
    ("flute in the hut", ["hermit_flute_0"], -2.0, "SFX", "haus_abend", 0.0, 6.0),
    ("frogs, at the bank", ["frog_croak_0", "frog_croak_1"], -2.0, "SFX", "tal_regentag", 2.0, 8.0),
    ("goat", ["goat_bleat_0", "goat_munch"], -2.0, "SFX", "tal_abend", 2.0, 8.0),
    ("bird landing", ["bird"], -2.0, "SFX", "tal_regentag", 2.0, 10.0),
    ("drover's call", ["bark_0", "bark_1", "bark_2"], -1.0, "SFX", "tal_regentag", 2.0, 10.0),
    ("stone wobble", ["stone_wobble"], 0.0, "SFX", "tal_regentag", 0.0, 10.0),
    ("falling into the brook", ["splash_fall"], 0.0, "SFX", "tal_regentag", 2.0, 12.0),
    ("pick-up (Real)", ["pickup_real_0"], 0.0, "SFX", "tal_regentag", 0.0, 8.0),
    ("menu sounds (Real)", ["ui_real_move_0", "ui_real_confirm", "ui_real_open"], -4.0, "UI", "tal_regentag", -3.0, 4.0),
    ("dialogue voice (Real)", ["voice_warm_0", "voice_low_0", "voice_neutral_0"], -2.0, "Voice", "tal_regentag", 0.0, 8.0),
    ("menu sounds (Elysia)", ["ui_elysia_move_0", "ui_elysia_confirm", "ui_elysia_open"], -4.0, "UI", "elysia", -9.0, 0.0),
    ("dialogue voice (Elysia)", ["voice_elysia_0"], -1.0, "Voice", "elysia", -6.0, 2.0),
    ("coin", ["coin_0"], -10.0, "SFX", "elysia", -14.0, -6.0),
    ("experience", ["xp"], -6.0, "SFX", "elysia", -10.0, -2.0),
    ("level up", ["level_up"], -2.0, "SFX", "elysia", -8.0, 0.0),
    ("chest", ["chest_open"], -2.0, "SFX", "elysia", -8.0, 0.0),
    ("loot", ["loot_common", "loot_rare", "loot_epic", "loot_legendary"], -2.0, "SFX", "elysia", -9.0, -1.0),
    ("praise", ["praise"], -8.0, "SFX", "elysia", -14.0, -4.0),
    ("rift", ["rift_touch"], 0.0, "SFX", "elysia", -6.0, 4.0),
]
# Where the call gains are read from: sound -> regex for its call.
CALL_SITES = {
    "sfx": r'AudioDirector\.sfx\(\s*"(\w+)"(?:,\s*(-?[\d.]+))?',
    "play_at": r'SoundBank\.play_at\([^,]+,\s*"(\w+)",\s*[^,]+?(?:,\s*(-?[\d.]+))?\)',
}


def read_wav(path):
    with wave.open(path) as w:
        data = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32768.0
        return data, w.getframerate()


def is_loop(path):
    imp = path + ".import"
    return os.path.exists(imp) and "loop_mode=2" in open(imp, encoding="utf-8").read()


def group_target(name):
    for pattern, target in SFX_GROUPS:
        if re.match(pattern, name):
            return target
    return None


def check_files(report, failures):
    """Group loudness, ceiling, DC and clicks of every generated sound."""
    by_group = {}
    for path in sorted(glob.glob(os.path.join(SFX, "*.wav"))):
        name = os.path.basename(path)[:-4]
        if SKIP.match(name):
            continue
        x, rate = read_wav(path)
        loop = is_loop(path)
        got = loudness.lufs(x, rate, periodic=loop)
        peak = loudness.peak_db(x)
        target = group_target(name)
        report.append(f"{name:24s} {got:6.1f} LUFS  peak {peak:5.1f}  group {target}")
        if target is None:
            failures.append(f"{name}: no loudness group (add it to check_levels.SFX_GROUPS)")
            continue
        by_group.setdefault(target, []).append((name, got))
        if abs(got - target) > TOLERANCE_DB:
            failures.append(f"{name}: {got:.1f} LUFS, its group is at {target:.1f}")
        if peak > CEILING_DB + 0.1:
            failures.append(f"{name}: peaks at {peak:.1f} dBFS, over the {CEILING_DB:.0f} dBFS ceiling")
        if abs(float(np.mean(x))) > 0.002:
            failures.append(f"{name}: DC offset {np.mean(x):.4f}")
        if not loop and not CLICK_OK.match(name) and (abs(x[0]) > 0.02 or abs(x[-1]) > 0.02):
            failures.append(f"{name}: starts or ends on a click ({x[0]:.3f}, {x[-1]:.3f})")
        if loop:
            steps = np.abs(np.diff(x))
            if abs(x[0] - x[-1]) > max(4 * np.percentile(steps, 99), 0.01):
                failures.append(f"{name}: loop seam jumps ({x[0]:.3f} -> {x[-1]:.3f})")
    for target, members in by_group.items():
        values = [v for _, v in members]
        if max(values) - min(values) > 2.0:
            failures.append(f"group at {target:.0f} LUFS spans {max(values) - min(values):.1f} dB")


def step_loudness(x, rate):
    """Energy of a short sound as if spread over 100 ms (STEP_LOUDNESS in make_placeholders)."""
    z = loudness.k_filtered(x, rate)
    return -0.691 + 10 * math.log10(float(np.sum(z**2)) / rate / 0.1 + 1e-20)


def surface_db():
    """SURFACE_DB of FootstepPlayer, read from the script."""
    text = open(os.path.join(ROOT, "world", "audio", "footstep_player.gd"), encoding="utf-8").read()
    block = text[text.index("const SURFACE_DB"):]
    block = block[: block.index("}")]
    table = {}
    for name, a, b in re.findall(r'&"(\w+)":\s*Vector2\(\s*(-?[\d.]+),\s*(-?[\d.]+)\s*\)', block):
        table[name] = (float(a), float(b))
    return table


def check_steps(report, failures):
    surfaces = {}
    for path in sorted(glob.glob(os.path.join(STEPS, "footstep_*.wav")) + glob.glob(os.path.join(STEPS, "rustle_*.wav"))):
        name = os.path.basename(path)[:-4]
        surface = re.sub(r"_\d+$", "", name).replace("footstep_", "")
        x, rate = read_wav(path)
        got = step_loudness(x, rate)
        peak = loudness.peak_db(x)
        surfaces.setdefault(surface, []).append((got, peak))
        if abs(got - STEP_LOUDNESS_DB) > 1.0:
            failures.append(f"{name}: step loudness {got:.1f}, expected {STEP_LOUDNESS_DB:.0f}")
        if peak > STEP_PEAK_DB + 0.1:
            failures.append(f"{name}: peaks at {peak:.1f} dBFS, over {STEP_PEAK_DB:.0f}")
    for surface, rows in surfaces.items():
        report.append(
            f"steps {surface:8s} loudness {min(r[0] for r in rows):.1f}..{max(r[0] for r in rows):.1f}"
            f"  peak {min(r[1] for r in rows):.1f}..{max(r[1] for r in rows):.1f}"
        )
    table = surface_db()
    ground = [table[s] for s in ("grass", "dirt", "stone", "wood", "puddle", "water") if s in table]
    for column, label in ((0, "walking"), (1, "running")):
        values = [row[column] for row in ground]
        if max(values) - min(values) > 6.0:
            failures.append(f"SURFACE_DB {label}: ground levels span {max(values) - min(values):.0f} dB")
        if "tall_grass" in table and abs(table["tall_grass"][column] - table["grass"][column]) > 3.0:
            failures.append(f"SURFACE_DB {label}: tall grass is more than 3 dB from grass")
    return table


def parse_def(path):
    """(wind, beds [(sound, db, gust)], events [(sound, mean interval s, db)]) of a .tres."""
    text = open(path, encoding="utf-8").read()
    wind = float(re.search(r"^wind = ([\d.]+)", text, re.M).group(1))
    beds = [(m[0], float(m[1]), float(m[2])) for m in
            re.findall(r'\{"sound": "(\w+)", "db": (-?[\d.]+), "gust": ([\d.]+)', text)]
    events = [(m[0], (float(m[1]) + float(m[2])) / 2, float(m[3])) for m in
              re.findall(r'\{"sound": "(\w+)", "every": \[([\d.]+), ([\d.]+)\], "db": (-?[\d.]+)', text)]
    return wind, beds, events


def event_energy(sound):
    """Mean K-weighted energy of one event sound (over its variants), per sample rate unit."""
    energies = []
    for path in sorted(glob.glob(os.path.join(SFX, f"nature_{sound}_[0-9].wav"))):
        x, rate = read_wav(path)
        energies.append(float(np.sum(loudness.k_filtered(x, rate) ** 2)) / rate)
    return float(np.mean(energies))


def predicted_place_lufs(tres, ambience_db):
    """Loudness of a soundscape as the player hears it (see BED_GAIN_DB): beds as energy, plus
    the events spread over their mean interval."""
    wind, beds, events = parse_def(os.path.join(ROOT, "content", "audio", tres))
    typical_gust = min(1.0, 0.5 * wind)
    energy = 0.0
    for sound, db, follow in beds:
        x, rate = read_wav(os.path.join(BEDS, f"nature_{sound}_bed.wav"))
        amplitude = (1 - follow) + follow * (0.18 + 1.1 * typical_gust)
        level = loudness.lufs(x, rate, periodic=True) + db + ambience_db + BED_GAIN_DB
        energy += 10 ** (level / 10) * amplitude**2
    for sound, interval, db in events:
        level = db + ambience_db + EVENT_RANDOM_DB + EVENT_GAIN_DB
        energy += event_energy(sound) / interval * 10 ** (level / 10)
    return 10 * math.log10(energy)


def check_places(report, failures):
    got = {}
    for place, (tres, ambience_db, target) in PLACES.items():
        got[place] = predicted_place_lufs(tres, ambience_db)
        report.append(f"place {place:14s} bed {got[place]:6.1f} LUFS (target {target:.1f})")
        if abs(got[place] - target) > PLACE_TOLERANCE_DB:
            failures.append(f"{place}: bed at {got[place]:.1f} LUFS, target {target:.1f}")
    span = max(got.values()) - min(got.values())
    if span > PLACE_SPAN_DB:
        failures.append(f"places are {span:.1f} dB apart (more than {PLACE_SPAN_DB:.0f})")
    return got


def group_loudness(name):
    target = group_target(name)
    if target is None:
        raise KeyError(name)
    return target


def call_gains():
    """Literal gains at the call sites: sound -> [(file, dB)]."""
    found = {}
    for path in glob.glob(os.path.join(ROOT, "**", "*.gd"), recursive=True):
        rel = os.path.relpath(path, ROOT)
        if rel.startswith(("addons", ".venv", ".godot", ".claude", "tests")):
            continue
        text = open(path, encoding="utf-8").read()
        for kind, pattern in CALL_SITES.items():
            for name, gain in re.findall(pattern, text):
                found.setdefault(name, []).append((rel, float(gain) if gain else 0.0))
    return found


def check_classes(report, failures, notes, places):
    """In-game level of each class over the bed of its place, and the steps."""
    beds = dict(places)
    beds["elysia"] = ELYSIA_MUSIC_LUFS
    gains = call_gains()
    for label, names, call_db, bus, place, low, high in CLASSES:
        bed = beds[place]
        for name in names:
            level = group_loudness(name) + call_db + BUS_TRIM_DB[bus]
            margin = level - bed
            report.append(f"class {label:26s} {name:18s} {level:6.1f} LUFS  {margin:+5.1f} LU over {place}")
            if not low <= margin <= high:
                failures.append(f"{label} ({name}): {margin:+.1f} LU over {place}, expected {low:+.0f}..{high:+.0f}")
        base = re.sub(r"_\d$", "", names[0])
        for rel, gain in gains.get(base, []):
            if abs(gain - call_db) > 0.05:
                notes.append(f"call site {rel}: {base} at {gain:+.1f} dB, the table says {call_db:+.1f}")
    # footsteps: file loudness + SURFACE_DB + SFX trim over the bed of the ground's place
    surfaces = surface_db()
    homes = {"grass": "tal_regentag", "tall_grass": "tal_regentag", "dirt": "tal_regentag",
             "stone": "tal_regentag", "wood": "haus_feuer", "puddle": "tal_regentag", "water": "tal_regentag"}
    for surface, (walk, run) in surfaces.items():
        # tall grass: a 0.24 s rustle that measures louder over 100 ms than it sounds
        shift = 4.0 if surface == "tall_grass" else 0.0
        for label, db, low, high in (("walking", walk, -4.0 - shift, 4.0), ("running", run, -1.0 - shift, 8.0)):
            margin = STEP_LOUDNESS_DB + db + BUS_TRIM_DB["SFX"] - beds[homes[surface]]
            report.append(f"class steps {surface:10s} {label:8s} {margin:+5.1f} LU over {homes[surface]}")
            if not low <= margin <= high:
                failures.append(f"steps on {surface} {label}: {margin:+.1f} LU over the bed, expected {low:+.0f}..{high:+.0f}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--table", action="store_true", help="print every measured number")
    args = parser.parse_args()
    report, failures, notes = [], [], []
    check_files(report, failures)
    check_steps(report, failures)
    places = check_places(report, failures)
    check_classes(report, failures, notes, places)
    if args.table:
        print("\n".join(report))
    for line in notes:
        print("note:", line)
    if failures:
        print("check_levels: FAILED")
        for line in failures:
            print("  -", line)
        return 1
    print(f"check_levels: ok ({len(report)} measurements)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
