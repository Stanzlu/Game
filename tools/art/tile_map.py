#!/usr/bin/env python3
"""Tiles a text map NX times to the right and NY times down (standard library only).

Usage: python3 tools/art/tile_map.py content/maps/tal.txt 2 2 spike_tmp/tal_2x2.txt
The large-map spike (T6, docs/PERFORMANCE.md) uses it to get a synthetic map of any size out of a real one:
same legend, same props and markers (every tile has its own), the baked images ([meta] ground, water,
treeline) pointing at files named after the output. A tool for measuring, not for making maps.
"""
import os
import re
import sys

BAKED_KEYS = ("ground", "water", "treeline")


def tile(text, nx, ny, name):
    """The map text tiled; the [meta] image paths become res://spike_tmp/<name>_<kind>.png."""
    if nx < 1 or ny < 1:
        raise ValueError("a map is tiled at least once each way")
    # the header line stands alone ("[map]" also appears in comments)
    parts = re.split(r"(?m)^\[map\]\s*$", text, maxsplit=1)
    if len(parts) != 2:
        raise ValueError("the map has no [map] block")
    head, body = parts
    for key in BAKED_KEYS:
        head = re.sub(r'(?m)^%s = "[^"]*"$' % key,
                      '%s = "res://spike_tmp/%s_%s.png"' % (key, name, key), head)
    # a mirror axis (Elysia) belongs to the first tile only; the spike maps are not symmetric
    head = re.sub(r"(?m)^symmetry = .*\n", "", head)
    lines = [line for line in body.replace("\r", "").split("\n")]
    rows = [line for line in lines if line.strip()]
    tiled = []
    for _ in range(ny):
        for row in rows:
            tiled.append(row * nx)
    return head + "[map]\n" + "\n".join(tiled) + "\n"


def main(argv):
    if len(argv) != 5:
        sys.exit(__doc__)
    path, nx, ny, out = argv[1], int(argv[2]), int(argv[3]), argv[4]
    with open(path, encoding="utf-8") as f:
        text = f.read()
    name = os.path.splitext(os.path.basename(out))[0]
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(tile(text, nx, ny, name))
    print("%s: %d x %d tiles of %s" % (out, nx, ny, path))


if __name__ == "__main__":
    main(sys.argv)
