#!/usr/bin/env python3
"""Play-time model (standard library only): minutes from words, text speed and the way.

Usage: python3 tools/writing/calibrate.py                    the Slice at every text speed
       python3 tools/writing/calibrate.py --akt1             Act I at every text speed (its own baseline)
       python3 tools/writing/calibrate.py --record-akt1 run.log   write the baseline of Act I from an
                                                     autopilot run (tools/autopilot/akt1_full.json)
       python3 tools/writing/calibrate.py --log run.log      fit the model to a real run of the Slice (beat lines)
       python3 tools/writing/calibrate.py --akt1 --log run.log   the same for a human run of Act I
       python3 tools/writing/calibrate.py --segment WORDS LINES WALK_MINUTES   a planned segment
The model has three parts:
    reading  seen characters x seconds per character (the text speed of core/settings.gd) plus a
             pause per seen line to read it and press the key
    way      the autopilot's time without reading (calibration_baseline.json) times a factor for a
             first-time player who looks around
    seen     the share of the lines of a file a first-time player sees (answers branch, conditions
             pick one variant)
SEEN_SHARE, ADVANCE_PAUSE and WANDER are assumptions until a real log fits them (`--log`); the
baseline is measured. Plan 9.6 and 4.2 count minutes with this model instead of by feel.
"""
import json
import os
import re
import sys

import dialogue

HERE = os.path.dirname(os.path.abspath(__file__))
BASELINE = os.path.join(HERE, "calibration_baseline.json")
BASELINE_AKT1 = os.path.join(HERE, "calibration_akt1.json")
## Pixels a second of the walking pace of the default feel (entities/player/tuning/direkt.tres): the
## autopilot teleports where a player walks, so the pixels it skipped are turned back into seconds.
WALK_SPEED = 88.0
FINISHED_RE = re.compile(r"autopilot finished (\{.*\})")
SETTINGS = os.path.join(dialogue.ROOT, "core", "settings.gd")
SPEED_NAMES = ["langsam", "normal", "schnell", "sofort"]
SEEN_SHARE = 0.6
ADVANCE_PAUSE = 1.2
WANDER = 1.6
# The beat where the story leaves Elysia: before it the time is Elysia's, after it the real world's.
ELYSIA_ENDS = "rift_found"
BEAT_RE = re.compile(r'"beat":"(\w+)","minute":([\d.]+),"seconds":(\d+)')


def text_speeds():
    """Seconds per typed character for the four text speeds, read from core/settings.gd."""
    with open(SETTINGS, encoding="utf-8") as f:
        match = re.search(r"const TEXT_SPEEDS: Array\[float\] = \[([^\]]*)\]", f.read())
    return [float(v) for v in match.group(1).split(",")]


def baseline():
    with open(BASELINE, encoding="utf-8") as f:
        data = json.load(f)
    beats = {b["beat"]: b["seconds"] for b in data["beats"]}
    elysia = beats[ELYSIA_ENDS]
    return {"elysia": elysia, "real": data["end_seconds"] - elysia, "beats": beats}


def slice_sources():
    """The story dialogue of the Vertical Slice: everything but the segments of Act I (akt1/)."""
    return [s for s in dialogue.sources(story_only=True) if "/akt1/" not in s.path.replace(os.sep, "/")]


def akt1_sources():
    """The story dialogue of Act I: the segments (akt1/) and Elysia's garden (the Slice's elysia.dialogue)."""
    found = []
    for source in dialogue.sources(story_only=True):
        path = source.path.replace(os.sep, "/")
        if "/akt1/" in path or os.path.basename(path).startswith("elysia"):
            found.append(source)
    return found


def akt1_baseline():
    """The autopilot's Act I run: seconds, seconds with a conversation open, clicks, skipped pixels."""
    with open(BASELINE_AKT1, encoding="utf-8") as f:
        data = json.load(f)
    way = data["seconds"] - data["dialogue_seconds"] + data["route_px"] / WALK_SPEED
    return {"way": way, "data": data}


def akt1_estimate(speed_index, wander=WANDER, seen=SEEN_SHARE, pause=ADVANCE_PAUSE):
    """Minutes of Act I: its own way (the autopilot's run) plus reading all its story text."""
    floor = akt1_baseline()
    text = story_text(akt1_sources())
    lines = text["elysia"][0] + text["real"][0]
    characters = text["elysia"][1] + text["real"][1]
    return estimate(floor["way"], lines, characters, text_speeds()[speed_index], wander, seen, pause), lines


def record_akt1(log_path):
    """Writes calibration_akt1.json from the log of tools/autopilot/akt1_full.json."""
    with open(log_path, encoding="utf-8", errors="replace") as f:
        text = f.read()
    match = FINISHED_RE.search(text)
    if match is None:
        raise ValueError("the log has no 'autopilot finished' line (did the run reach its end?)")
    if "autopilot wait timed out" in text:
        raise ValueError("the run had a wait that timed out: its numbers say nothing (fix the run first)")
    numbers = json.loads(match.group(1))
    beats = [{"beat": name, "seconds": seconds} for name, seconds in parse_log(text)]
    data = {
        "_comment": "The Act I run of the autopilot (tools/autopilot/akt1_full.json, instant text, fixed 30 fps): "
                    "seconds of play in all, seconds with a conversation open, clicks (lines moved on) and the "
                    "straight-line pixels of the walks it skipped by teleporting. The way of calibrate.py --akt1.",
        "seconds": numbers["seconds"],
        "dialogue_seconds": numbers["dialogue_s"],
        "clicks": numbers["clicks"],
        "route_px": numbers["route_px"],
        "beats": beats,
    }
    with open(BASELINE_AKT1, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=1, ensure_ascii=False)
        f.write("\n")
    return data


def story_text(sources=None):
    """(lines, characters) of the story dialogue per world: elysia.dialogue, the rest is real."""
    totals = {"elysia": [0, 0], "real": [0, 0]}
    for source in sources if sources is not None else slice_sources():
        world = "elysia" if os.path.basename(source.path).startswith("elysia") else "real"
        for line in source.lines:
            totals[world][0] += 1
            totals[world][1] += len(line.text)
    return totals


def reading_seconds(lines, characters, seconds_per_char, seen=SEEN_SHARE, pause=ADVANCE_PAUSE):
    return seen * (characters * seconds_per_char + lines * pause)


def estimate(walk_seconds, lines, characters, seconds_per_char, wander=WANDER, seen=SEEN_SHARE,
             pause=ADVANCE_PAUSE):
    """Minutes for a stretch of the game: the way (times the wander factor) plus the reading."""
    return (walk_seconds * wander + reading_seconds(lines, characters, seconds_per_char, seen, pause)) / 60.0


def slice_estimate(speed_index, wander=WANDER, seen=SEEN_SHARE, pause=ADVANCE_PAUSE):
    floor = baseline()
    text = story_text()
    speed = text_speeds()[speed_index]
    parts = {}
    for world in ("elysia", "real"):
        parts[world] = estimate(floor[world], text[world][0], text[world][1], speed, wander, seen, pause)
    parts["total"] = parts["elysia"] + parts["real"]
    return parts


def parse_log(text):
    """[(beat, seconds)] from the beat lines of a run, in order."""
    return [(m.group(1), int(m.group(3))) for m in BEAT_RE.finditer(text)]


def fit(beats, speed_index, seen=SEEN_SHARE, pause=ADVANCE_PAUSE):
    """The wander factor that makes the model match a real run's total (seconds at its last beat)."""
    if not beats:
        raise ValueError("the log has no beat lines")
    actual = beats[-1][1]
    floor = baseline()
    text = story_text()
    speed = text_speeds()[speed_index]
    reading = sum(reading_seconds(text[w][0], text[w][1], speed, seen, pause) for w in text)
    walk = floor["elysia"] + floor["real"]
    return max((actual - reading) / walk, 1.0)


def fit_akt1(beats, speed_index, seen=SEEN_SHARE, pause=ADVANCE_PAUSE):
    """The wander factor that makes the model match a human run of Act I (seconds at its last beat)."""
    if not beats:
        raise ValueError("the log has no beat lines")
    text = story_text(akt1_sources())
    speed = text_speeds()[speed_index]
    reading = sum(reading_seconds(text[w][0], text[w][1], speed, seen, pause) for w in text)
    return max((beats[-1][1] - reading) / akt1_baseline()["way"], 1.0)


def per_beat_akt1(beats):
    """Real seconds against the autopilot's run of Act I for each beat they share."""
    with open(BASELINE_AKT1, encoding="utf-8") as f:
        floor = {b["beat"]: b["seconds"] for b in json.load(f)["beats"]}
    return [(name, seconds, floor[name]) for name, seconds in beats if name in floor and floor[name] > 0]


def per_beat(beats):
    """Real seconds against the autopilot's for each beat the run shares with the baseline."""
    floor = baseline()["beats"]
    return [(name, seconds, floor[name]) for name, seconds in beats if name in floor and floor[name] > 0]


def main(argv):
    if "--segment" in argv:
        at = argv.index("--segment")
        words, lines, walk = float(argv[at + 1]), int(argv[at + 2]), float(argv[at + 3])
        for index, name in enumerate(SPEED_NAMES[:3]):
            minutes = estimate(walk * 60.0, lines, words * 6.5, text_speeds()[index])
            print("%-8s %5.1f min (%d Zeilen, %d Wörter, Weg %.1f min)" % (name, minutes, lines, words, walk))
        return 0
    if "--record-akt1" in argv:
        data = record_akt1(argv[argv.index("--record-akt1") + 1])
        print("Act I: %d s of play, %d s in conversations, %d clicks, %d px of teleports; %d beats"
              % (data["seconds"], data["dialogue_seconds"], data["clicks"], data["route_px"], len(data["beats"])))
        return 0
    if "--akt1" in argv and "--log" not in argv:
        floor = akt1_baseline()
        text = story_text(akt1_sources())
        lines = text["elysia"][0] + text["real"][0]
        print("Akt I: %d Zeilen, Weg ohne Lesen %.1f min (Autopilot %d s ohne Gespräche + %d px zu Fuß), "
              "angenommen: gesehen %.0f %%, Pause %.1f s, Umweg x%.1f"
              % (lines, floor["way"] / 60.0, floor["data"]["seconds"] - floor["data"]["dialogue_seconds"],
                 floor["data"]["route_px"], SEEN_SHARE * 100, ADVANCE_PAUSE, WANDER))
        print("Der Autopilot nahm den ersten Weg in jedem Gespräch und sah %d Zeilen (%.0f %% der Zeilen)"
              % (floor["data"]["clicks"], 100.0 * floor["data"]["clicks"] / lines))
        print("%-10s %8s" % ("Tempo", "Akt I"))
        for index, name in enumerate(SPEED_NAMES[:3]):
            minutes, _ = akt1_estimate(index)
            print("%-10s %7.1f min" % (name, minutes))
        upper, _ = akt1_estimate(0, wander=2.5, seen=1.0, pause=2.0)
        print("%-10s %7.1f min (langsam, alle Zeilen gesehen, Pause 2 s, Umweg x2,5: wer alles liest und sich verläuft)"
              % ("Obergrenze", upper))
        print("Dichte: %.1f Zeilen je Minute (Plan 9.6 rechnet mit 6)" % (lines / akt1_estimate(1)[0]))
        return 0
    speed_index = 1
    if "--log" in argv:
        with open(argv[argv.index("--log") + 1], encoding="utf-8", errors="replace") as f:
            beats = parse_log(f.read())
        act_one = "--akt1" in argv
        factor = fit_akt1(beats, speed_index) if act_one else fit(beats, speed_index)
        print("run: %d beats, %.1f min at the last one%s" % (len(beats), beats[-1][1] / 60.0,
              " (Akt I)" if act_one else " (Slice)"))
        print("fitted wander factor %.2f (assumed %.2f); put it in WANDER" % (factor, WANDER))
        print("%-18s %8s %10s %6s" % ("beat", "real s", "autopilot", "ratio"))
        for name, real, floor in (per_beat_akt1(beats) if act_one else per_beat(beats)):
            print("%-18s %8d %10d %6.1f" % (name, real, floor, real / floor))
        return 0
    text = story_text()
    floor = baseline()
    print("Slice: %d Zeilen, Weg ohne Lesen %.1f min (Autopilot), angenommen: gesehen %.0f %%, Pause %.1f s, Umweg x%.1f"
          % (text["elysia"][0] + text["real"][0], (floor["elysia"] + floor["real"]) / 60.0,
             SEEN_SHARE * 100, ADVANCE_PAUSE, WANDER))
    print("%-10s %8s %8s %8s" % ("Tempo", "Elysia", "Tal usw.", "gesamt"))
    for index, name in enumerate(SPEED_NAMES[:3]):
        parts = slice_estimate(index)
        print("%-10s %7.1f %8.1f %8.1f min" % (name, parts["elysia"], parts["real"], parts["total"]))
    lines = text["elysia"][0] + text["real"][0]
    total = slice_estimate(1)["total"]
    print("Dichte: %.1f Zeilen je Minute (Plan 9.6 rechnet mit 6)" % (lines / total))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
