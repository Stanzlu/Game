#!/usr/bin/env python3
"""Loudness per second of a captured wav (K-weighted, 1 s windows, both channels), with the
events of an autopilot file (game time) beside it. How the mix is measured by ear-less
review: tools/audio/measure.sh records the sound, this reads it.

Usage: timeline.py frame.wav [autopilot.json|-] [from_s] [to_s]
       timeline.py frame.wav - --segments 36 4   (mean loudness per 36 s segment, 4 s skipped)
"""
import json
import sys
import wave

import numpy as np

sys.path.insert(0, __file__.rsplit("/", 1)[0])
import loudness  # noqa: E402


def read(path):
    with wave.open(path) as w:
        width, channels, rate = w.getsampwidth(), w.getnchannels(), w.getframerate()
        raw = w.readframes(w.getnframes())
    if width == 2:
        data = np.frombuffer(raw, "<i2").astype(float) / 32768.0
    elif width == 4:
        data = np.frombuffer(raw, "<i4").astype(float) / 2147483648.0
    else:
        raise SystemExit(f"{path}: {width * 8}-bit wav not supported")
    return data.reshape(-1, channels).T, rate


def main():
    path = sys.argv[1]
    auto = sys.argv[2] if len(sys.argv) > 2 else "-"
    channels, rate = read(path)
    energy = sum(loudness.k_filtered(c, rate) ** 2 for c in channels)
    peak = np.max(np.abs(channels), axis=0)
    if "--segments" in sys.argv:
        seconds, skip = (float(v) for v in sys.argv[sys.argv.index("--segments") + 1:][:2])
        for i in range(int(len(energy) / (seconds * rate))):
            a, b = int((i * seconds + skip) * rate), int((i + 1) * seconds * rate)
            level = -0.691 + 10 * np.log10(np.mean(energy[a:b]) + 1e-20)
            print(f"segment {i}: {level:6.1f} LUFS  peak {20 * np.log10(peak[a:b].max() + 1e-9):6.1f}")
        return
    first = float(sys.argv[3]) if len(sys.argv) > 3 else 0.0
    last = float(sys.argv[4]) if len(sys.argv) > 4 else 1e9
    events = {}
    if auto != "-":
        data = json.load(open(auto))
        for e in data if isinstance(data, list) else data.get("events", []):
            text = e.get("log") or ",".join(f"{k}={v}" for k, v in e.items() if k != "t")
            events.setdefault(int(e.get("t", 0)), []).append(text)
    for s in range(len(energy) // rate):
        if s < first or s > last:
            continue
        level = -0.691 + 10 * np.log10(np.mean(energy[s * rate:(s + 1) * rate]) + 1e-20)
        top = 20 * np.log10(peak[s * rate:(s + 1) * rate].max() + 1e-9)
        bar = "#" * int(max(0, (level + 60) / 1.5))
        print(f"{s:4d}s {level:7.1f} LUFS pk {top:6.1f} {bar:40s} {' | '.join(events.get(s, []))}")


if __name__ == "__main__":
    main()
