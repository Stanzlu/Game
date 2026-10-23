#!/usr/bin/env python3
"""Draws an overview picture of a text map: the baked ground with every placement marked.

Usage: .venv/bin/python tools/art/map_overview.py content/maps/tal.txt [--out build/map_overview]
For review by eye (needs Pillow, requirements-art.txt): spawns, doors, people, things to pick up,
cues and the symmetry axis, on a grid labelled every eight cells. The picture is not committed.
"""
import argparse
import os
import sys

from PIL import Image, ImageDraw

import mapfile

T = mapfile.T
KINDS = {
    "player_spawn": ((60, 220, 90), "Start"),
    "spawn": ((70, 210, 230), "Ankunft"),
    "door": ((255, 150, 40), "Tür"),
    "rift": ((230, 70, 220), "Riss"),
    "npc": ((70, 120, 255), "Figur"),
    "pickup": ((255, 255, 255), "Aufheben"),
    "cue": ((255, 225, 60), "Cue"),
    "stone": ((190, 190, 190), "Trittstein"),
}


def kind_of(placement):
    marker = placement.get("marker", "")
    prop = os.path.basename(placement.get("prop", ""))
    params = placement.get("params", {})
    if marker == "player_spawn":
        return "player_spawn"
    if marker.startswith("spawn_"):
        return "spawn"
    if prop == "door.tscn":
        return "door"
    if prop == "rift.tscn":
        return "rift"
    if prop in ("npc_walker.tscn", "child_guide.tscn"):
        return "npc"
    if prop == "pickup.tscn":
        return "pickup"
    if prop == "stepping_stone.tscn":
        return "stone"
    if "cue" in params:
        return "cue"
    return None


def placements(rows, symbols):
    found = []
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            entry = symbols[c]
            if "atlas" in entry:
                continue
            found.append({"cell": (x, y), "marker": entry.get("marker", ""), "prop": entry.get("prop", ""),
                          "params": entry.get("params", {})})
    return found


def draw(map_path, out_dir):
    meta, symbols, rows = mapfile.parse_map(map_path)
    name = mapfile.map_name(map_path)
    width, height = len(rows[0]), len(rows)
    ground = meta.get("ground")
    if ground and os.path.exists(mapfile.res_path(ground)):
        image = Image.open(mapfile.res_path(ground)).convert("RGBA")
        background = Image.new("RGBA", image.size, (40, 44, 56, 255))
        background.alpha_composite(image)
        image = background
    else:
        image = Image.new("RGBA", (width * T, height * T), (40, 44, 56, 255))
    layer = ImageDraw.Draw(image)
    for step in range(0, width + 1, 8):
        layer.line([(step * T, 0), (step * T, height * T)], fill=(255, 255, 255, 40))
        layer.text((step * T + 2, 2), str(step), fill=(255, 255, 255, 200))
    for step in range(0, height + 1, 8):
        layer.line([(0, step * T), (width * T, step * T)], fill=(255, 255, 255, 40))
        layer.text((2, step * T + 2), str(step), fill=(255, 255, 255, 200))
    counts = {}
    for placement in placements(rows, symbols):
        kind = kind_of(placement)
        if kind is None:
            continue
        counts[kind] = counts.get(kind, 0) + 1
        x, y = placement["cell"]
        color = KINDS[kind][0]
        cx, cy = x * T + T // 2, y * T + T // 2
        layer.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], outline=(0, 0, 0, 255), fill=color + (255,))
        label = placement["params"].get("cue") or placement["marker"] or os.path.basename(placement["prop"])
        if kind in ("cue", "door", "spawn", "npc"):
            layer.text((cx + 7, cy - 5), str(label)[:14], fill=(255, 255, 255, 255))
    axis = meta.get("symmetry")
    if axis is not None:
        ax = axis * T + T // 2
        for y in range(0, height * T, 8):
            layer.line([(ax, y), (ax, y + 4)], fill=(255, 60, 60, 255))
    legend_y = 14
    for kind, count in sorted(counts.items()):
        color, label = KINDS[kind]
        layer.ellipse([width * T - 150, legend_y, width * T - 140, legend_y + 10], fill=color + (255,))
        layer.text((width * T - 134, legend_y), "%s %d" % (label, count), fill=(255, 255, 255, 255))
        legend_y += 14
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, name + "_overview.png")
    image.convert("RGB").save(path)
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("map", nargs="+")
    parser.add_argument("--out", default=os.path.join(mapfile.ROOT, "build", "map_overview"))
    args = parser.parse_args()
    for map_path in args.map:
        print(draw(map_path, args.out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
