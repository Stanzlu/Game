"""Text maps for the art tools (standard library only): parsing, what a bake depends on, stamps.

A baked ground image is only as good as the map it was baked from. `stamp()` hashes everything
a bake reads: the paint of every cell, the ground shadows of placed decor, the [meta] block
(without the runtime-only scatter rules), the seed and the sources of the baker itself.
`tools/art/map_stamps.json` holds the stamp of every committed bake; `tools/art/map_stamp.py
--check` (a step of tools/check.sh) tells when a map was edited and not baked again.
"""
import hashlib
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MAP_DIR = os.path.join(ROOT, "content", "maps")
STAMP_FILE = os.path.join(ROOT, "tools", "art", "map_stamps.json")
CATALOG = os.path.join(ROOT, "assets", "generated", "props", "catalog.json")
# Code that decides how a map is painted: a change there outdates every bake.
BAKER_SOURCES = ("bake_ground.py", "pixelart.py", "mapfile.py")
DEFAULT_SEED = 7
T = 16
SURFACE_PAINT = {"grass": "grass", "dirt": "path", "stone": "cobble", "water": "water",
                 "wood": "planks_h", "puddle": "puddle"}
# Meta keys the game reads at runtime only; changing them needs no new bake.
RUNTIME_META = ("scatter",)


def res_path(path):
    return os.path.join(ROOT, path[len("res://"):]) if path.startswith("res://") else path


def parse_map(path):
    """Mirror of world/map/map_data.gd: [meta], [legend] and [map] blocks, ';' comments."""
    with open(os.path.join(ROOT, "content/maps/legend.json"), encoding="utf-8") as f:
        legend = json.load(f)
    symbols = dict(legend["symbols"])
    meta, rows, section, saw_header = {}, [], "map", False
    with open(path, encoding="utf-8") as f:
        for raw in f.read().replace("\r", "").split("\n"):
            s = raw.strip()
            if s in ("[legend]", "[map]", "[meta]"):
                section, saw_header = s[1:-1], True
                continue
            if s.startswith(";") and not (section == "map" and saw_header):
                continue
            if section in ("legend", "meta"):
                if not s:
                    continue
                if section == "legend":
                    # first character is the symbol (it may itself be '=')
                    symbols[s[0]] = json.loads(s[1:].strip()[1:])
                else:
                    key, _, value = s.partition("=")
                    meta[key.strip()] = json.loads(value)
            elif s:
                rows.append(raw.rstrip())
    return meta, symbols, rows


def paint_of(symbol, symbols):
    d = symbols[symbol]
    if "atlas" not in d:
        d = symbols[d["ground"]]
    if "paint" in d:
        return d["paint"]
    if d.get("solid") and d.get("surface") == "stone":
        return "cliff"
    return SURFACE_PAINT.get(d.get("surface", ""), "grass")


def load_catalog():
    if not os.path.exists(CATALOG):
        return {}
    with open(CATALOG, encoding="utf-8") as f:
        return json.load(f)


def shadow_cells(rows, symbols, catalog):
    """Decor placements whose catalog entry asks for a ground shadow: (y, x, shadow) in pixels. A prop that
    is only there under a story condition ("if"/"unless", the feast tables, the leaf) casts none: a baked
    shadow would stay under nothing."""
    found = []
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            params = symbols[c].get("params", {})
            if "if" in params or "unless" in params:
                continue
            sprite = params.get("sprite")
            entry = catalog.get(sprite, {}) if sprite else {}
            if "shadow" in entry:
                found.append((y * T + T // 2, x * T + T // 2, entry["shadow"]))
    return found


def sources_hash():
    digest = hashlib.sha256()
    here = os.path.dirname(os.path.abspath(__file__))
    for name in BAKER_SOURCES:
        with open(os.path.join(here, name), "rb") as f:
            digest.update(name.encode() + b"\0" + f.read().replace(b"\r\n", b"\n") + b"\0")
    return digest.hexdigest()


def bake_inputs(map_path, seed=DEFAULT_SEED):
    """Everything a bake of this map reads, as plain data."""
    meta, symbols, rows = parse_map(map_path)
    return {
        "meta": {k: v for k, v in sorted(meta.items()) if k not in RUNTIME_META},
        "paints": [[paint_of(c, symbols) for c in row] for row in rows],
        "shadows": shadow_cells(rows, symbols, load_catalog()),
        "seed": seed,
        "baker": sources_hash(),
    }


def stamp(map_path, seed=DEFAULT_SEED):
    text = json.dumps(bake_inputs(map_path, seed), sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(text.encode()).hexdigest()


def map_name(map_path):
    return os.path.splitext(os.path.basename(map_path))[0]


def baked_maps():
    """Maps that name a ground image in [meta]: the ones that need a bake."""
    found = []
    for name in sorted(os.listdir(MAP_DIR)):
        path = os.path.join(MAP_DIR, name)
        if name.endswith(".txt") and "ground" in parse_map(path)[0]:
            found.append(path)
    return found


def read_stamps():
    if not os.path.exists(STAMP_FILE):
        return {}
    with open(STAMP_FILE, encoding="utf-8") as f:
        return json.load(f)


def write_stamp(map_path, seed=DEFAULT_SEED):
    stamps = read_stamps()
    stamps[map_name(map_path)] = stamp(map_path, seed)
    with open(STAMP_FILE, "w", encoding="utf-8", newline="\n") as f:
        json.dump(stamps, f, indent=1, sort_keys=True)
        f.write("\n")


def check():
    """Problems (empty if every baked map carries the stamp of its current inputs)."""
    problems = []
    stamps = read_stamps()
    maps = baked_maps()
    for path in maps:
        name = map_name(path)
        meta = parse_map(path)[0]
        if name not in stamps:
            problems.append("%s: no bake stamp, run tools/art/bake_ground.py content/maps/%s.txt"
                            % (name, name))
        elif stamps[name] != stamp(path):
            problems.append("%s: the map or the baker changed since the last bake, run "
                            "tools/art/bake_ground.py content/maps/%s.txt" % (name, name))
        for key in ("ground", "water", "treeline"):
            if key in meta and not os.path.exists(res_path(meta[key])):
                problems.append("%s: baked image %s is missing" % (name, meta[key]))
    known = {map_name(p) for p in maps}
    for name in stamps:
        if name not in known:
            problems.append("%s: stamp of a map that is not baked any more, remove it" % name)
    return problems
