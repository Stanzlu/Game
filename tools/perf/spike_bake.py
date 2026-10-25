#!/usr/bin/env python3
"""Bakes a spike map without writing a stamp (T6): tools/art/bake_ground.py minus write_stamp.

Usage: .venv/bin/python tools/perf/spike_bake.py spike_tmp/tal_2x2.txt
The baker itself stays untouched on purpose: every change to bake_ground.py, pixelart.py or mapfile.py
outdates the stamp of every committed map (tools/art/mapfile.py).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art"))

import bake_ground  # noqa: E402
import pixelart as pa  # noqa: E402


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    meta, symbols, rows = bake_ground.parse_map(sys.argv[1])
    baker = bake_ground.Baker(meta, symbols, rows, bake_ground.DEFAULT_SEED)
    ground, water = baker.bake()
    pa.save_rgba(bake_ground.res_path(meta["ground"]), ground)
    if "water" in meta:
        pa.save_rgba(bake_ground.res_path(meta["water"]), water)
    if "treeline" in meta:
        pa.save_rgba(bake_ground.res_path(meta["treeline"]), bake_ground.bake_treeline(baker))
    print("baked %s (%dx%d)" % (sys.argv[1], baker.w, baker.h))


if __name__ == "__main__":
    main()
