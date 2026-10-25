#!/usr/bin/env python3
"""Large-map spike (T6, docs/PERFORMANCE.md): the cost of a map of any size, measured on synthetic maps.

Usage: .venv/bin/python tools/perf/map_spike.py [--source content/maps/tal.txt] [--sizes 1x1,2x1,2x2,3x3]
Tiles the source map (tools/art/tile_map.py), bakes the ground (time and memory of the baker), imports the
images and builds each map in a MapView headless (tools/perf/map_spike.gd: parse and build time, nodes,
memory, process time per frame). Prints a table for docs/PERFORMANCE.md. Everything it writes lies in
spike_tmp (not committed). Needs numpy and Pillow (requirements-art.txt) and Godot (tools/godot.sh).
"""
import argparse
import json
import os
import resource
import subprocess
import sys
import time

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SPIKE = os.path.join(ROOT, "spike_tmp")


def run(cmd):
    """(seconds, peak KB of the child, output) of a command."""
    before = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    started = time.time()
    done = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, timeout=900)
    seconds = time.time() - started
    peak = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    if done.returncode != 0:
        sys.exit("failed: %s\n%s%s" % (" ".join(cmd), done.stdout, done.stderr))
    return seconds, max(peak, before), done.stdout + done.stderr


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--source", default="content/maps/tal.txt")
    ap.add_argument("--sizes", default="1x1,2x1,2x2,3x3")
    args = ap.parse_args()
    os.makedirs(SPIKE, exist_ok=True)
    sizes = [tuple(int(n) for n in s.split("x")) for s in args.sizes.split(",")]
    baked = {}
    for nx, ny in sizes:
        name = "tal_%dx%d" % (nx, ny)
        out = os.path.join("spike_tmp", name + ".txt")
        run([sys.executable, "tools/art/tile_map.py", args.source, str(nx), str(ny), out])
        seconds, peak, _ = run([sys.executable, "tools/perf/spike_bake.py", out])
        png = os.path.getsize(os.path.join(SPIKE, name + "_ground.png"))
        baked[name] = (seconds, peak / 1024.0, png / 1048576.0)
        print("baked %s in %.0f s, %.0f MB peak, ground png %.1f MB" % ((name,) + baked[name]), file=sys.stderr)
    seconds, _, _ = run(["tools/godot.sh", "--headless", "--import"])
    print("imported in %.0f s" % seconds, file=sys.stderr)
    print("| Karte | Zellen | Zeichen | Bake (s) | Bake (MB) | PNG (MB) | Parse (ms) | Aufbau (ms) | Knoten | Speicher (MB) | Prozess (µs/Bild) |")
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for nx, ny in sizes:
        name = "tal_%dx%d" % (nx, ny)
        _, _, output = run(["tools/godot.sh", "--headless", "res://tools/perf/map_spike.tscn", "--",
                            "--map=res://spike_tmp/%s.txt" % name])
        line = [l for l in output.splitlines() if l.startswith("SPIKE ")]
        if not line:
            sys.exit("no result for %s:\n%s" % (name, output))
        r = json.loads(line[-1][len("SPIKE "):])
        b = baked[name]
        print("| %s | %d × %d | %d | %.0f | %.0f | %.1f | %s | %s | %d | %s | %d |" % (
            name, r["cells"][0], r["cells"][1], r["symbols"], b[0], b[1], b[2],
            r["parse_ms"], r["build_ms"], r["nodes"], r["static_mb"], r["frame_us"]))


if __name__ == "__main__":
    main()
