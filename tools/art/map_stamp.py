#!/usr/bin/env python3
"""Checks that every baked ground image is as new as its map (standard library only).

Usage: python3 tools/art/map_stamp.py [--check]      report stale or missing bakes (exit 1)
       python3 tools/art/map_stamp.py --list         show the stamps
Stamps are written by tools/art/bake_ground.py after a bake; see tools/art/mapfile.py.
"""
import sys

import mapfile


def main():
    if "--list" in sys.argv:
        for name, value in sorted(mapfile.read_stamps().items()):
            print("%-22s %s" % (name, value[:16]))
        return 0
    problems = mapfile.check()
    for problem in problems:
        print("map stamps: " + problem)
    if problems:
        return 1
    print("map stamps ok (%d baked maps)" % len(mapfile.baked_maps()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
