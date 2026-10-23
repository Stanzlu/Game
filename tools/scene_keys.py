#!/usr/bin/env python3
"""Prints the scene keys of one list in core/scene_registry.gd (standard library only).

Usage: python3 tools/scene_keys.py smoke|benchmark
check.sh and smoke_export.sh loop over `smoke`; the lists live in one place, SceneRegistry.
"""
import os
import re
import sys

REGISTRY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "core", "scene_registry.gd")


def keys(name):
    with open(REGISTRY, encoding="utf-8") as f:
        text = f.read()
    match = re.search(r"const %s: PackedStringArray = \[(.*?)\]" % name.upper(), text, re.S)
    if match is None:
        raise SystemExit("scene_keys: no list %s in core/scene_registry.gd" % name.upper())
    found = re.findall(r'"([a-z_]+)"', match.group(1))
    if not found:
        raise SystemExit("scene_keys: the list %s is empty" % name.upper())
    return found


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    print(" ".join(keys(sys.argv[1])))
