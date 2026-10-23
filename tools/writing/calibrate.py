#!/usr/bin/env python3
"""Play-time model (standard library only): minutes from words, text speed and the way.

Usage: python3 tools/writing/calibrate.py                    the Slice at every text speed
       python3 tools/writing/calibrate.py --log run.log      fit the model to a real run (beat lines)
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


def story_text(sources=None):
    """(lines, characters) of the story dialogue per world: elysia.dialogue, the rest is real."""
    totals = {"elysia": [0, 0], "real": [0, 0]}
    for source in sources if sources is not None else dialogue.sources(story_only=True):
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
    speed_index = 1
    if "--log" in argv:
        with open(argv[argv.index("--log") + 1], encoding="utf-8", errors="replace") as f:
            beats = parse_log(f.read())
        factor = fit(beats, speed_index)
        print("run: %d beats, %.1f min at the last one" % (len(beats), beats[-1][1] / 60.0))
        print("fitted wander factor %.2f (assumed %.2f); put it in WANDER" % (factor, WANDER))
        print("%-18s %8s %10s %6s" % ("beat", "real s", "autopilot", "ratio"))
        for name, real, floor in per_beat(beats):
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
