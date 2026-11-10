"""Tests of the hall of the Wächter, content/maps/maschine.txt (Akt V, G3; standard library only): python3 -m unittest discover -s tools/art.

The map is written by hand (Klasse S, zoom 1.5, like werkstatt.txt): these tests pin what the contract and the brief ask of it: the room fits the
view, the twelve levers with their numbers and forms (three in use, nine under cloths), the console and the small door behind it, the four dials, the
six lamps, the Wächter, the cues, and a walk of the benchmark's square from the start that never touches the door.
"""
import ast
import hashlib
import math
import os
import re
import struct
import unittest

import mapfile

MASCHINE = os.path.join(mapfile.ROOT, "content", "maps", "maschine.txt")
GRAT = os.path.join(mapfile.ROOT, "content", "maps", "grat.txt")
DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "anlage.dialogue")
DIALOGUE_RES = "res://content/dialogue/akt5/anlage.dialogue"
PROPS_PY = os.path.join(mapfile.ROOT, "tools", "art", "akt5_props.py")
SHEET = os.path.join(mapfile.ROOT, "entities", "character", "sheet_waechter_look.tres")
DECOR = "res://world/props/decor.tscn"
LEVER = "res://world/props/console_lever.tscn"
GAUGE = "res://world/props/gauge.tscn"
# props the main hand builds for this segment: they may be missing while the art is checked on its own
PENDING_PROPS = {GAUGE}

# the room: the cells 4 to 28 and 4 to 17 of the map (25 x 14 cells = 400 x 224 pixels; 427 x 240 pixels are in view at zoom 1.5)
ROOM = (4, 4, 25, 14)
LEVER_COLS = [6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18]  # the room columns of the levers 1 to 12; the bolt indicator stands in 12
CONSOLE_COLS = (5, 19)
LEVER_GLYPHS = "abcdefghijkl"
CUES = {"waechter", "lever_idle", "small_door", "worn_dial", "gauges", "steam_pipe"}
PLAYER = (10, 5, -2)  # the player's collision: 10 x 5 pixels, its centre 2 above the feet (entities/player/player.tscn)
SPEED_SPRINT = 144.0  # entities/player/tuning/direkt.tres
SOLID_GROUNDS = "#W"


def _map():
    return mapfile.parse_map(MASCHINE)


def _placements(rows, symbols):
    found = []
    for y, row in enumerate(rows):
        for x, glyph in enumerate(row):
            if "prop" in symbols[glyph] or "marker" in symbols[glyph]:
                found.append((glyph, x, y, symbols[glyph]))
    return found


def _glyph_cells(rows, glyph):
    return [(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if c == glyph]


def _png_size(path):
    with open(path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])


def _gauge_constants():
    """GAUGE_NORMAL and GAUGE_ANCHOR from tools/art/akt5_props.py, read as text (the art tools need numpy, these tests do not)."""
    with open(PROPS_PY, encoding="utf-8") as f:
        source = f.read()
    out = {}
    for name in ("GAUGE_NORMAL", "GAUGE_ANCHOR"):
        out[name] = ast.literal_eval(re.search(r"^%s = (\{.*?\})" % name, source, re.M).group(1))
    return out


def _blockers(rows, symbols, catalog):
    """Rectangles (x0, y0, x1, y1 in map pixels) that stop the player: solid ground and the shapes of the props (a circle as its bounding square)."""
    rects = []
    for y, row in enumerate(rows):
        for x, glyph in enumerate(row):
            if symbols[glyph].get("ground", glyph) in SOLID_GROUNDS:
                rects.append((x * 16, y * 16, x * 16 + 16, y * 16 + 16))
    for glyph, x, y, entry in _placements(rows, symbols):
        sprite = entry.get("params", {}).get("sprite") or entry.get("params", {}).get("sprite_up")
        shape = catalog.get(sprite, {}).get("shape") if sprite else None
        if not shape:
            continue
        cx, cy = x * 16 + 8 + shape.get("offset", [0, 0])[0], y * 16 + 8 + shape.get("offset", [0, 0])[1]
        if "rect" in shape:
            w, h = shape["rect"]
        else:
            w = h = shape["circle"] * 2
        rects.append((cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2))
    return rects


def _box(px, py):
    w, h, off = PLAYER
    return px - w / 2, px + w / 2, py + off - h / 2, py + off + h / 2


def _hits(px, py, rects):
    """Does the player standing with his feet at (px, py) overlap any of the rectangles?"""
    x0, x1, y0, y1 = _box(px, py)
    return any(x0 < r[2] and x1 > r[0] and y0 < r[3] and y1 > r[1] for r in rects)


def _walk(start, direction, seconds, rects, speed=SPEED_SPRINT, step=0.5):
    """From `start` (his feet) in a straight line for `seconds`: the point where he stops, and every point he passes."""
    px, py = start
    path = []
    for _ in range(int(seconds * speed / step)):
        nx, ny = px + direction[0] * step, py + direction[1] * step
        if _hits(nx, ny, rects):
            break
        px, py = nx, ny
        path.append((px, py))
    return (px, py), path


class MaschineMapTests(unittest.TestCase):
    def test_the_map_is_a_room_of_class_s_that_fits_the_view_at_zoom_one_and_a_half(self):
        meta, symbols, rows = _map()
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/maschine_ground.png")
        self.assertEqual({len(r) for r in rows}, {33})
        self.assertEqual(len(rows), 22)
        rx, ry, rw, rh = ROOM
        door = _glyph_cells(rows, "D")[0]
        self.assertLessEqual(rw * 16 * 1.5, 640, "the room's width fits the view (640 pixels at zoom 1.5)")
        self.assertLessEqual(rh * 16 * 1.5, 360, "and its height (360 pixels at zoom 1.5)")
        # outside the room only void, the walls in a ring, the floor inside
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                inside = rx <= x < rx + rw and ry <= y < ry + rh
                if not inside:
                    self.assertEqual(glyph, "#", "void outside the room at %d,%d" % (x, y))
                    continue
                wall = (y < ry + 3 or y == ry + rh - 1 or x in (rx, rx + rw - 1)) and (x, y) != door  # the door's cell is floor
                ground = symbols[glyph].get("ground", glyph)
                self.assertEqual(ground in SOLID_GROUNDS, wall, "walls round the floor at %d,%d" % (x, y))
        self.assertEqual(symbols["_"]["paint"], "planks_h")
        self.assertEqual(symbols["#"]["paint"], "void")
        self.assertEqual(symbols["W"]["paint"], "void")
        for glyph in set("".join(rows)):
            self.assertIn(mapfile.paint_of(glyph, symbols), ("void", "planks_h"), "only paints the baker has: " + glyph)

    def test_the_floor_was_baked_from_this_map(self):
        meta, _, _ = _map()
        path = mapfile.res_path(meta["ground"])
        self.assertTrue(os.path.exists(path), path)
        self.assertEqual(_png_size(path), (33 * 16, 22 * 16))
        self.assertEqual(mapfile.stamp(MASCHINE), mapfile.read_stamps()["maschine"], "run tools/art/bake_ground.py content/maps/maschine.txt")

    def test_the_shell_is_the_room_and_lies_in_its_first_cell(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        self.assertEqual(_glyph_cells(rows, "S"), [(ROOM[0], ROOM[1])])
        entry = catalog["tal/ma_shell"]
        self.assertTrue(entry.get("flat"), "under everything")
        self.assertEqual(entry["anchor"], [8, 8], "its top left corner is the cell's top left corner")
        self.assertEqual(_png_size(mapfile.res_path(entry["textures"][0])), (ROOM[2] * 16, ROOM[3] * 16))
        self.assertEqual(symbols["S"]["params"], {"sprite": "tal/ma_shell"})
        self.assertNotIn("shadow", entry)

    def test_every_glyph_has_its_own_legend_line_and_every_prop_scene_exists(self):
        with open(MASCHINE, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows = _map()
        for glyph in set("".join(rows)):
            self.assertIsNotNone(re.search(r"^%s = " % re.escape(glyph), source, re.M), "no legend line for " + glyph)
        for glyph, _, _, entry in _placements(rows, symbols):
            prop = entry.get("prop")
            if prop and prop not in PENDING_PROPS:
                self.assertTrue(os.path.exists(mapfile.res_path(prop)), prop)

    def test_every_sprite_is_in_the_catalog_with_its_picture(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        sprites = set()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            for key in ("sprite", "sprite_up", "sprite_down", "needle"):
                if params.get(key):
                    sprites.add(params[key])
            sprites.update(params.get("sprite_when", {}).values())
        self.assertGreater(len(sprites), 40, "a hall in its final density: the levers (24 pictures), the dials, the lamps, the steam")
        for sprite in sprites:
            self.assertIn(sprite, catalog, sprite)
            # the potato is the valley's picture (G5): the pickup of a side quest, nothing of the hall's own
            self.assertTrue(sprite.startswith("tal/ma_") or sprite == "tal/potato", "the prefix of the hall: " + sprite)
            for texture in catalog[sprite]["textures"] + catalog[sprite].get("emissive", []):
                self.assertTrue(os.path.exists(mapfile.res_path(texture)), texture)

    def test_door_start_and_arrival(self):
        _, symbols, rows = _map()
        placements = _placements(rows, symbols)
        doors = [p for p in placements if p[3].get("prop", "").endswith("door.tscn")]
        self.assertEqual(len(doors), 1)
        glyph, dx, dy, entry = doors[0]
        params = entry["params"]
        self.assertEqual((params["target"], params["spawn"], params["auto"], params["sound"]), ("grat", "maschine", True, "door_close"))
        self.assertNotIn("size", params, "a door of one cell like the other rooms")
        rx, ry, rw, rh = ROOM
        self.assertEqual(dy, ry + rh - 1, "in the front wall")
        self.assertEqual(symbols[glyph]["ground"], "_", "the door's cell is floor")
        self.assertEqual(_glyph_cells(rows, "1"), [(dx, dy - 2)], "two cells in front of the door, like the other rooms")
        self.assertEqual(symbols["1"]["marker"], "spawn_grat", "named after the scene one comes from; grat.txt has `spawn_maschine` for the way back")
        start = _glyph_cells(rows, "@")
        self.assertEqual(len(start), 1)
        self.assertEqual(symbols["@"]["marker"], "player_spawn")
        self.assertGreater(math.hypot(start[0][0] - dx, start[0][1] - dy), 20, "more than twenty cells from the door (the benchmark walks a square from the start)")
        self.assertEqual(sorted(symbols[p[0]]["marker"] for p in placements if "marker" in p[3]), ["player_spawn", "spawn_grat"])

    def test_the_benchmarks_square_from_the_start_never_touches_the_door(self):
        """The Leistungstest walks right 1.6 s, down 1.0 s, left 1.6 s, up 1.0 s, sprinting (core/benchmark/benchmark_runner.gd), over and over."""
        _, symbols, rows = _map()
        rects = _blockers(rows, symbols, mapfile.load_catalog())
        sx, sy = _glyph_cells(rows, "@")[0]
        door = _glyph_cells(rows, "D")[0]
        zone = (door[0] * 16 - 2, door[1] * 16 - 2, door[0] * 16 + 18, door[1] * 16 + 18)  # the door's cell with two pixels to spare
        pos = (sx * 16 + 8, sy * 16 + 8)
        self.assertFalse(_hits(pos[0], pos[1], rects), "the start is on free ground")
        visited = []
        for _ in range(4):
            for direction, seconds in (((1, 0), 1.6), ((0, 1), 1.0), ((-1, 0), 1.6), ((0, -1), 1.0)):
                pos, path = _walk(pos, direction, seconds, rects)
                visited += path
        for px, py in visited:
            x0, x1, y0, y1 = _box(px, py)
            self.assertFalse(x0 < zone[2] and x1 > zone[0] and y0 < zone[3] and y1 > zone[1], "the benchmark's square touches the door at %s" % ((px, py),))
        self.assertGreater(len(visited), 400, "and it does walk (not stuck at the start)")
        self.assertLess(max(y for _, y in visited), (door[1] - 3) * 16, "it stays in the upper part of the room, far from the front wall")

    def test_cues_are_the_contracts_and_every_one_is_in_the_dialogue(self):
        _, symbols, rows = _map()
        used = {}
        for glyph, _, _, entry in _placements(rows, symbols):
            params = entry.get("params", {})
            if "cue" in params:
                used.setdefault(params["cue"], set()).add(glyph)
                self.assertEqual(params["dialogue"], DIALOGUE_RES, glyph)
        self.assertEqual(set(used), CUES)
        self.assertEqual(used["lever_idle"], set(LEVER_GLYPHS[3:]), "the nine levers that stand still")
        self.assertEqual(used["small_door"], {"K"})
        self.assertEqual(used["worn_dial"], {"Z"})
        self.assertEqual(used["gauges"], {"Q"})
        self.assertEqual(used["steam_pipe"], {"V"})
        self.assertEqual(used["waechter"], {"A"})
        if os.path.exists(DIALOGUE):
            with open(DIALOGUE, encoding="utf-8") as f:
                cues = set(re.findall(r"^~ (\w+)", f.read(), re.M))
            self.assertLessEqual(CUES, cues, "every cue of the map is a cue of anlage.dialogue")

    def test_everything_with_a_cue_can_be_reached_and_one_can_stand_in_front_of_each_lever(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        walkable = {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if symbols[c].get("ground", c) not in SOLID_GROUNDS}
        start = _glyph_cells(rows, "@")[0]
        seen, queue = {start}, [start]
        while queue:
            x, y = queue.pop()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c = (x + dx, y + dy)
                if c in walkable and c not in seen:
                    seen.add(c)
                    queue.append(c)
        self.assertEqual(seen, walkable, "no island: every floor cell is connected (the shapes of the props only close the way to the console)")
        for glyph, x, y, entry in _placements(rows, symbols):
            params = entry.get("params", {})
            if "cue" in params or entry.get("prop", "").endswith(("door.tscn", "npc_walker.tscn")) or entry.get("marker", "").startswith("spawn_"):
                near = any(abs(x - sx) + abs(y - sy) <= 2 for sx, sy in seen)
                self.assertTrue(near, "%s at %d,%d cannot be reached (MapLint: within two cells of a floor cell)" % (glyph, x, y))
        # in front of a lever: the player stops at the console's edge; the lever's talk zone (its radius) and his sensor (radius 18) must meet there
        rects = _blockers(rows, symbols, catalog)
        for glyph in LEVER_GLYPHS + "KZ":
            (x, y), = _glyph_cells(rows, glyph)
            radius = symbols[glyph]["params"].get("radius", 16)
            px, py = x * 16 + 8, y * 16 + 8 + 60
            while not _hits(px, py - 0.5, rects) and py > y * 16 + 8:
                py -= 0.5
            reach = py - (y * 16 + 8)  # from the cell's centre to where he stands in front of it
            self.assertLessEqual(reach, radius + 18, "%s: standing at the console's edge he reaches its zone" % glyph)
            self.assertGreater(reach, 20, "and he does stand in front of the console, not on it")

    def test_twelve_levers_in_a_row_each_with_its_number_and_form_three_in_use_nine_under_a_cloth(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        rx, ry, _, _ = ROOM
        cells = []
        up_files = set()
        for n, glyph in enumerate(LEVER_GLYPHS, 1):
            found = _glyph_cells(rows, glyph)
            self.assertEqual(len(found), 1, "lever %d (%s) once" % (n, glyph))
            cells.append(found[0])
            entry = symbols[glyph]
            params = entry["params"]
            self.assertEqual(entry["prop"], LEVER)
            self.assertEqual(entry["ground"], "_")
            self.assertEqual(params["n"], n)
            self.assertEqual(params["active"], n <= 3, "levers 1, 2 and 3 are in use, the others stand still")
            self.assertEqual((params["sprite_up"], params["sprite_down"]), ("tal/ma_lever_%d_up" % n, "tal/ma_lever_%d_down" % n))
            self.assertEqual(params["radius"], 12)
            self.assertEqual("cue" in params, n > 3, "a still lever can be looked at (lever_idle), one in use is pulled")
            for key in ("sprite_up", "sprite_down"):
                sprite = catalog[params[key]]
                self.assertEqual(_png_size(mapfile.res_path(sprite["textures"][0])), (16, 52), "the same measures up and down")
                self.assertEqual(sprite["anchor"], [8, 30])
                self.assertNotIn("shadow", sprite, "no shadow: it stands on the console, which lies over the floor")
                self.assertNotIn("shape", sprite, "the console is the barrier")
            files = []
            for key in ("sprite_up", "sprite_down"):
                with open(mapfile.res_path(catalog[params[key]]["textures"][0]), "rb") as f:
                    files.append(hashlib.sha1(f.read()).hexdigest())
            self.assertNotEqual(files[0], files[1], "pulled looks different from up: lever %d" % n)
            up_files.add(files[0])
        self.assertEqual(len(up_files), 12, "twelve different pictures: the number on the plate and a form of its own on the knob")
        # in one row (the room's row 3), side by side, left to right, with the bolt indicator in the gap in the middle
        self.assertEqual({y - ry for _, y in cells}, {3})
        self.assertEqual([x - rx for x, _ in cells], LEVER_COLS)
        self.assertEqual(sorted(set(range(6, 19)) - set(LEVER_COLS)), [12])
        # the cloths: one for each lever that stands still, in the row below it, lifted onto it, and none for the three in use
        # (since G4 the cloths come off wave by wave: m for the levers 4 to 6, n for 7 to 9, o for 10 to 12, each with its own flag)
        cloths = sorted(_glyph_cells(rows, "m") + _glyph_cells(rows, "n") + _glyph_cells(rows, "o"))
        self.assertEqual(cloths, sorted((x, y + 1) for (x, y) in cells[3:]), "one cloth below each of the nine still levers")
        for glyph, group, flag in (("m", cells[3:6], "plant.wave_two"), ("n", cells[6:9], "plant.wave_three"), ("o", cells[9:12], "plant.wave_four")):
            self.assertEqual(sorted(_glyph_cells(rows, glyph)), sorted((x, y + 1) for (x, y) in group), "the cloths of the wave that takes them off: " + glyph)
            self.assertEqual(symbols[glyph]["params"]["unless"], flag, "the cloths %s go with %s" % (glyph, flag))
        params = symbols["m"]["params"]
        self.assertEqual((symbols["m"]["prop"], params["sprite"], params["lift"]), (DECOR, "tal/ma_lever_cover", 9))
        self.assertNotIn("cue", params, "the lever beneath it speaks")
        self.assertNotIn("if", params, "a cloth goes when its wave comes, it never waits for a flag to appear")
        cover = catalog["tal/ma_lever_cover"]
        self.assertEqual(_png_size(mapfile.res_path(cover["textures"][0])), (16, 36))
        self.assertEqual(cover["anchor"], [8, 36])
        for key in ("shadow", "shape", "lights"):
            self.assertNotIn(key, cover, "what the story takes away leaves no baked shadow and no collision")
        # the cloth ends above the lever's number plate (rows 41 to 49 of the lever's picture, whose anchor is row 30): 16 for the row below, less the lift
        cloth_foot = 16 - params["lift"]
        plate_top = 41 - 30
        self.assertLess(cloth_foot, plate_top, "the plate with the number stays free")

    def test_the_console_is_flat_under_the_levers_fifteen_cells_wide_against_the_wall_and_blocks_the_way(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        rx, ry, _, _ = ROOM
        (cx, cy), = _glyph_cells(rows, "C")
        self.assertEqual((cx - rx, cy - ry), (12, 4), "the middle of its front row")
        entry = catalog["tal/ma_console"]
        self.assertTrue(entry.get("flat"), "the levers stand on it and sort before it")
        self.assertEqual(_png_size(mapfile.res_path(entry["textures"][0])), (240, 40))
        self.assertEqual(entry["anchor"], [120, 24])
        left = cx * 16 + 8 - entry["anchor"][0]
        self.assertEqual((left - ROOM[0] * 16) // 16, CONSOLE_COLS[0], "it begins in the room's column 5")
        self.assertEqual((left + 240 - ROOM[0] * 16) // 16 - 1, CONSOLE_COLS[1], "and ends in the column 19")
        top = cy * 16 + 8 - entry["anchor"][1]
        self.assertEqual(top, (ry + 3) * 16, "its top starts at the foot of the back wall (the room's row 3)")
        shape = entry["shape"]
        self.assertEqual(shape["rect"][0], 240, "its collision is as wide as the console")
        self.assertLessEqual(top, cy * 16 + 8 + shape["offset"][1] - shape["rect"][1] / 2 + 0.01, "it covers the top from the wall")
        self.assertNotIn("shadow", entry, "flat: its own picture carries the shadow")
        # the levers stand on it, the worn dial on its right end, the bolt indicator in the middle
        for glyph in LEVER_GLYPHS + "KZ":
            (x, y), = _glyph_cells(rows, glyph)
            self.assertTrue(left <= x * 16 + 8 < left + 240, glyph)
        # nothing behind it: the wall is the room's rows 0 to 2
        for x in range(ROOM[0], ROOM[0] + ROOM[2]):
            for y in range(ROOM[1], ROOM[1] + 3):
                self.assertEqual(symbols[rows[y][x]].get("ground", rows[y][x]), "W")

    def test_the_small_door_is_in_the_back_wall_above_the_bolt_indicator_and_its_rods_come_from_the_levers(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        (kx, _), = _glyph_cells(rows, "K")
        params = symbols["K"]["params"]
        self.assertEqual((params["sprite"], params["cue"]), ("tal/ma_bolt", "small_door"))
        self.assertGreaterEqual(params["radius"], 14)
        self.assertEqual(kx - ROOM[0], 12, "in the gap of the lever row, on the room's middle column")
        self.assertEqual(_png_size(mapfile.res_path(catalog["tal/ma_bolt"]["textures"][0])), (16, 20))
        with open(PROPS_PY, encoding="utf-8") as f:
            source = f.read()
        # the door itself is painted in the shell, at (200, 47) of the room (the middle of its foot), 12 x 18 pixels: nothing to walk to
        self.assertIn("MA_DOOR = (200, 47)", source)
        self.assertEqual(200, (kx - ROOM[0]) * 16 + 8, "the door stands over the bolt indicator")
        # one rod from each lever's knob to the bus bar, in the lever's column
        self.assertIn("for col in MA_LEVER_COLS:", source)
        self.assertIn("MA_LEVER_COLS = %s" % LEVER_COLS, source)

    def test_four_dials_all_at_normal_one_of_them_trembles_and_the_worn_dial_is_a_plain_prop(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        constants = _gauge_constants()
        gauges = []
        for glyph in "PQRT":
            (x, y), = _glyph_cells(rows, glyph)
            entry = symbols[glyph]
            self.assertEqual(entry["prop"], GAUGE)
            gauges.append((glyph, x, y, entry["params"]))
        self.assertEqual({y - ROOM[1] for _, _, y, _ in gauges}, {3})
        for k, (glyph, x, y, params) in enumerate(gauges, 1):
            self.assertEqual(params["sprite"], "tal/ma_gauge_%d" % k)
            self.assertEqual(params["needle"], "tal/ma_needle_%d" % k)
            dial = catalog[params["sprite"]]
            needle = catalog[params["needle"]]
            self.assertEqual(_png_size(mapfile.res_path(dial["textures"][0])), (28, 28))
            self.assertEqual(dial["anchor"], list(constants["GAUGE_ANCHOR"][k]))
            self.assertEqual(params["needle_at"], [14 - dial["anchor"][0], 14 - dial["anchor"][1]], "the hub of the dial's picture, from its anchor")
            self.assertEqual(needle["anchor"], [3, 13], "the needle's anchor is its hub")
            self.assertEqual(params["angle"], constants["GAUGE_NORMAL"][k], "the needle rests on the mark `Normal` of its dial")
            self.assertEqual(params["tremble"], glyph == "Q", "exactly one dial trembles")
            self.assertEqual(params["amplitude"], 1.5)
            for sprite in (dial, needle):
                for key in ("shadow", "shape", "lights"):
                    self.assertNotIn(key, sprite)
            self.assertEqual(dial["anchor"][1] - 28, 8, "the dial's picture ends 8 pixels above its cell's centre: it hangs on the wall")
        # two at the left wing, two at the right, between the side wall (x 16 and 384) and the console (x 80 to 320)
        for glyph, x, y, params in gauges:
            left = (x - ROOM[0]) * 16 + 8 - catalog[params["sprite"]]["anchor"][0]
            self.assertGreaterEqual(left, 16, "inside the side wall: " + glyph)
            self.assertLessEqual(left + 28, 400 - 16, glyph)
            self.assertTrue(left + 28 <= 80 or left >= 320, "beside the console: " + glyph)
        self.assertEqual([g[1] - ROOM[0] for g in gauges], [1, 3, 21, 23])
        self.assertEqual(symbols["Q"]["params"]["cue"], "gauges")
        for glyph in "PRT":
            self.assertNotIn("cue", symbols[glyph]["params"])
        # the worn dial on the console's right end: a plain prop with the cue and no needle prop (the fragment)
        (zx, zy), = _glyph_cells(rows, "Z")
        params = symbols["Z"]["params"]
        self.assertEqual((symbols["Z"]["prop"], params["sprite"], params["cue"]), (DECOR, "tal/ma_worn_dial", "worn_dial"))
        self.assertNotIn("needle", params)
        self.assertEqual((zx - ROOM[0], zy - ROOM[1]), (CONSOLE_COLS[1], 3), "on the right end block")

    def test_six_lamps_each_with_one_light_and_a_glow_and_nothing_else_casts_light(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        # G5: the left one is Y (it goes dark with plant.defect), the right one stays H
        self.assertEqual(len(_glyph_cells(rows, "H")) + len(_glyph_cells(rows, "Y")), 2, "two hang from the girder")
        self.assertEqual(len(_glyph_cells(rows, "Y")), 1)
        self.assertEqual(len(_glyph_cells(rows, "L")), 4, "four stand in the room")
        lights = 0
        for glyph, _, _, entry in _placements(rows, symbols):
            e = catalog.get(entry.get("params", {}).get("sprite", ""), {})
            lights += len(e.get("lights", []))
            if "lights" in e:
                self.assertIn(glyph, "HLY", "only the lamps carry lights")
                self.assertTrue(e.get("emissive"), "the lamps' glow is baked as well (the fallback without a light)")
                self.assertEqual(len(e["lights"]), 1)
                self.assertEqual(set(e["lights"][0]), {"offset", "color", "energy", "range"})
        self.assertEqual(lights, 6, "at most six PointLight2D (the brief's O3)")
        self.assertEqual(symbols["H"]["ground"], "W", "the hanging lamps hang on wall cells")
        for _, y in _glyph_cells(rows, "H") + _glyph_cells(rows, "Y"):
            self.assertEqual(y - ROOM[1], 2)
        # G5: the left hanging lamp goes dark with plant.defect, in a picture without a light or a glow
        self.assertEqual(symbols["Y"]["ground"], "W")
        self.assertEqual(symbols["Y"]["params"]["sprite"], "tal/ma_lamp_hang")
        self.assertEqual(symbols["Y"]["params"]["sprite_when"], {"plant.defect": "tal/ma_lamp_hang_dark"})
        dark = catalog["tal/ma_lamp_hang_dark"]
        self.assertNotIn("lights", dark)
        self.assertNotIn("emissive", dark)
        self.assertNotIn("shadow", dark, "no shadow in the catalog: the stamp stays")
        (yx, yy), = _glyph_cells(rows, "Y")
        self.assertEqual((yx - ROOM[0], yy - ROOM[1]), (5, 2), "the left one of the two")
        # G5: the potato by the hissing pipe, only after the letting go (the valley's picture, a pickup)
        (px, py), = _glyph_cells(rows, "p")
        self.assertEqual(symbols["p"]["prop"], "res://world/props/pickup.tscn")
        self.assertEqual(symbols["p"]["params"], {"item": "item_potato", "flag": "plant.potato_taken", "sprite": "tal/potato", "if": "plant.letgo"})
        (vx, vy), = _glyph_cells(rows, "V")
        self.assertLessEqual(abs(px - vx) + abs(py - vy), 3, "it lies by the pipe it rolled out of")
        for _, y in _glyph_cells(rows, "L"):
            self.assertGreaterEqual(y - ROOM[1], 8, "the standing lamps keep clear of the console")

    def test_steam_the_hissing_pipe_the_boilers_and_the_pipe_across_the_floor(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        # the steam: flat puffs of their own (the scene may move them, fade them or leave them out), above the nozzle of the hissing pipe and a flange
        steam = _glyph_cells(rows, "s")
        self.assertGreaterEqual(len(steam), 2)
        self.assertEqual(symbols["s"]["params"]["sprite"], "tal/ma_steam")
        self.assertGreater(symbols["s"]["params"]["lift"], 0)
        self.assertNotIn("cue", symbols["s"]["params"])
        self.assertEqual(len(catalog["tal/ma_steam"]["textures"]), 3, "three puffs")
        for key in ("shadow", "shape", "lights", "smoke"):
            self.assertNotIn(key, catalog["tal/ma_steam"], "steam casts no shadow, has no body and is a picture, not a particle node")
        (vx, vy), = _glyph_cells(rows, "V")
        self.assertIn((vx, vy - 2), steam, "the puff stands two rows above the hissing pipe, on its nozzle")
        self.assertEqual((symbols["V"]["params"]["sprite"], symbols["V"]["params"]["cue"]), ("tal/ma_hiss_pipe", "steam_pipe"))
        for glyph in "NU":
            self.assertTrue(catalog[symbols[glyph]["params"]["sprite"]]["shape"], glyph)
        self.assertEqual(len(_glyph_cells(rows, "N")), 2, "a boiler at each side")
        self.assertEqual(len(_glyph_cells(rows, "U")), 1)

    def test_the_waechter_is_a_standing_figure_at_the_left_end_of_the_console(self):
        _, symbols, rows = _map()
        (ax, ay), = _glyph_cells(rows, "A")
        entry = symbols["A"]
        params = entry["params"]
        self.assertEqual(entry["prop"], "res://entities/npc/npc_walker.tscn")
        self.assertEqual(params["sheet"], "res://entities/character/sheet_waechter_look.tres")
        self.assertEqual((params["dialogue"], params["cue"]), (DIALOGUE_RES, "waechter"))
        self.assertTrue(params["glance"])
        self.assertEqual(params["face"], "e", "he looks along the console")
        self.assertNotIn("route", params, "he stands still")
        self.assertNotIn("pause", params)
        self.assertEqual((ax - ROOM[0], ay - ROOM[1]), (4, 4), "beside the console's left end (the console begins in column 5)")
        self.assertTrue(os.path.exists(SHEET))
        with open(SHEET, encoding="utf-8") as f:
            text = f.read()
        self.assertIn("res://assets/generated/characters/waechter.png", text)
        self.assertIn("frame_size = Vector2i(24, 32)", text)
        w, h = _png_size(os.path.join(mapfile.ROOT, "assets", "generated", "characters", "waechter.png"))
        self.assertEqual((w, h), (4 * 24, 5 * 8 * 32), "four columns, five states (idle, walk, run, sit, look) of eight facings")
        self.assertEqual(_png_size(os.path.join(mapfile.ROOT, "assets", "generated", "characters", "tess.png"))[0], w, "the same layout as Tess's sheet")
        rects = _blockers(rows, symbols, mapfile.load_catalog())
        self.assertFalse(_hits(ax * 16 + 8, ay * 16 + 8, rects), "he does not stand in the console's collision")

    def test_nothing_that_goes_away_later_or_changes_casts_a_baked_shadow_and_the_furniture_does(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if "if" in params or "unless" in params or "sprite_when" in params or glyph in "mabcdefghijklKZPQRTsH":
                for key in ("sprite", "sprite_up", "sprite_down", "needle"):
                    if params.get(key):
                        self.assertNotIn("shadow", catalog[params[key]], "%s of %s would stay under nothing" % (params[key], glyph))
        for glyph in "LNUV":  # the furniture of the floor casts its shadow on the floor of this room
            self.assertIn("shadow", catalog[symbols[glyph]["params"]["sprite"]], glyph)
        # the prefix `ma_` is only used by this map: no other stamp changes by these sprites
        maps_dir = os.path.join(mapfile.ROOT, "content", "maps")
        for name in sorted(os.listdir(maps_dir)):
            if name.endswith(".txt") and name != "maschine.txt":
                with open(os.path.join(maps_dir, name), encoding="utf-8") as f:
                    self.assertNotIn("tal/ma_", f.read(), name)

    def test_the_fragment_of_the_worn_dial_has_its_picture_and_the_open_gate_its_measures(self):
        catalog = mapfile.load_catalog()
        picture = os.path.join(mapfile.ROOT, "assets", "generated", "fragments", "fragment_worn_dial.png")
        self.assertTrue(os.path.exists(picture))
        self.assertEqual(_png_size(picture), (16, 16))
        self.assertTrue(os.path.exists(os.path.join(mapfile.ROOT, "tools", "art", "small", "fragment_worn_dial.pix")))
        shut, opened = catalog["tal/gb_plant_gate"], catalog["tal/gb_plant_gate_open"]
        self.assertEqual(shut["anchor"], opened["anchor"], "the same cells")
        self.assertEqual(_png_size(mapfile.res_path(shut["textures"][0])), _png_size(mapfile.res_path(opened["textures"][0])), "the same measures")
        for key in ("shape", "shadow", "lights", "smoke", "emissive"):
            self.assertNotIn(key, opened, "one walks through the open gate, and the story changes its look: " + key)

    def test_the_hall_is_reached_from_the_high_valley_and_leads_back_to_it(self):
        _, symbols, rows = _map()
        _, g_symbols, g_rows = mapfile.parse_map(GRAT)
        self.assertEqual((g_symbols["E"]["params"]["target"], g_symbols["E"]["params"]["spawn"]), ("maschine", "grat"))
        self.assertEqual(g_symbols["e"]["marker"], "spawn_maschine")
        self.assertEqual(symbols["D"]["params"]["spawn"], "maschine", "the marker of grat is `spawn_maschine`: the scene one comes from")
        self.assertEqual(_glyph_cells(g_rows, "e")[0][1], _glyph_cells(g_rows, "E")[0][1] + 2)
        self.assertEqual(_glyph_cells(rows, "D")[0][1], ROOM[1] + ROOM[3] - 1)


if __name__ == "__main__":
    unittest.main()
