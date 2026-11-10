"""Tests of the first house from inside, content/maps/urhaus.txt (Akt V, G8; standard library only): python3 -m unittest discover -s tools/art.

The map is written by hand (Klasse S, zoom 1.5, like maschine.txt): these tests pin what the contract and the brief ask of it: the room fits the view,
the bed in the middle, the six rings of chalk with the six spots on their lines, the chalked-over window, the stick of chalk, the cues, and a walk of
the benchmark's square from the start that never touches the door.
"""
import math
import os
import re
import struct
import unittest

import mapfile

URHAUS = os.path.join(mapfile.ROOT, "content", "maps", "urhaus.txt")
GRAT = os.path.join(mapfile.ROOT, "content", "maps", "grat.txt")
DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "urhaus.dialogue")
DIALOGUE_RES = "res://content/dialogue/akt5/urhaus.dialogue"
DECOR = "res://world/props/decor.tscn"

# the room: the cells 4 to 28 and 4 to 17 of the map (25 x 14 cells = 400 x 224 pixels; 427 x 240 pixels are in view at zoom 1.5)
ROOM = (4, 4, 25, 14)
# the six rings, from the innermost: the cue of the spot on its line, the spot's glyph and cell, and the ring's bounding box in the picture's pixels
# (the picture of the rings starts with its top left corner in the cell (5, 7))
RINGS = [
    ("ring_room", "a", (18, 10), (168, 40, 216, 72)),
    ("ring_wall", "b", (20, 10), (136, 30, 248, 84)),
    ("ring_garden", "c", (22, 10), (104, 22, 280, 96)),
    ("ring_street", "d", (24, 10), (72, 14, 312, 108)),
    ("ring_town", "e", (26, 10), (40, 8, 344, 120)),
    ("ring_world", "f", (27, 10), (4, 2, 364, 156)),
]
RINGS_ORIGIN = (5, 7)
CUES = {"first_house", "window", "blue_chalk"} | {r[0] for r in RINGS}
PLAYER = (10, 5, -2)  # the player's collision: 10 x 5 pixels, its centre 2 above the feet (entities/player/player.tscn)
SPEED_SPRINT = 144.0  # entities/player/tuning/direkt.tres
SOLID_GROUNDS = "#W"


def _map():
    return mapfile.parse_map(URHAUS)


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


class UrhausMapTests(unittest.TestCase):
    def test_the_map_is_a_room_of_class_s_that_fits_the_view_at_zoom_one_and_a_half(self):
        meta, symbols, rows = _map()
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/urhaus_ground.png")
        self.assertEqual({len(r) for r in rows}, {33})
        self.assertEqual(len(rows), 22)
        rx, ry, rw, rh = ROOM
        door = _glyph_cells(rows, "D")[0]
        self.assertLessEqual(rw * 16 * 1.5, 640, "the room's width fits the view (640 pixels at zoom 1.5)")
        self.assertLessEqual(rh * 16 * 1.5, 360, "and its height (360 pixels at zoom 1.5)")
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                inside = rx <= x < rx + rw and ry <= y < ry + rh
                if not inside:
                    self.assertEqual(glyph, "#", "void outside the room at %d,%d" % (x, y))
                    continue
                wall = (y < ry + 3 or y == ry + rh - 1 or x in (rx, rx + rw - 1)) and (x, y) != door
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
        self.assertEqual(mapfile.stamp(URHAUS), mapfile.read_stamps()["urhaus"], "run tools/art/bake_ground.py content/maps/urhaus.txt")

    def test_the_shell_is_the_room_and_lies_in_its_first_cell(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        self.assertEqual(_glyph_cells(rows, "S"), [(ROOM[0], ROOM[1])])
        entry = catalog["tal/uh_shell"]
        self.assertTrue(entry.get("flat"), "under everything")
        self.assertEqual(entry["anchor"], [8, 8], "its top left corner is the cell's top left corner")
        self.assertEqual(_png_size(mapfile.res_path(entry["textures"][0])), (ROOM[2] * 16, ROOM[3] * 16))
        self.assertEqual(symbols["S"]["params"], {"sprite": "tal/uh_shell"})
        self.assertNotIn("shadow", entry)

    def test_every_glyph_has_its_own_legend_line_and_every_prop_scene_exists(self):
        with open(URHAUS, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows = _map()
        for glyph in set("".join(rows)):
            self.assertIsNotNone(re.search(r"^%s = " % re.escape(glyph), source, re.M), "no legend line for " + glyph)
        for glyph, _, _, entry in _placements(rows, symbols):
            prop = entry.get("prop")
            if prop:
                self.assertTrue(os.path.exists(mapfile.res_path(prop)), prop)

    def test_every_sprite_is_in_the_catalog_with_its_picture_and_casts_no_baked_shadow(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        sprites = set()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if params.get("sprite"):
                sprites.add(params["sprite"])
            sprites.update(params.get("sprite_when", {}).values())
        self.assertEqual(
            sprites,
            {"tal/uh_shell", "tal/uh_bed", "tal/uh_chalk_rings", "tal/uh_window", "tal/uh_window_clear", "tal/uh_chalk"},
        )
        for sprite in sprites:
            self.assertTrue(sprite.startswith("tal/uh_"), "the prefix of the house: " + sprite)
            self.assertIn(sprite, catalog, sprite)
            self.assertNotIn("shadow", catalog[sprite], "no baked shadow: nothing here is baked into the floor")
            self.assertNotIn("lights", catalog[sprite], "no light in the mountains (O3)")
            for texture in catalog[sprite]["textures"]:
                self.assertTrue(os.path.exists(mapfile.res_path(texture)), texture)
        sizes = {"uh_bed": ((32, 28), [8, 20]), "uh_window": ((24, 28), [12, 20]), "uh_window_clear": ((24, 28), [12, 20]),
                 "uh_chalk_rings": ((368, 160), [8, 8]), "uh_chalk": ((12, 6), [6, 3])}
        for name, (size, anchor) in sizes.items():
            entry = catalog["tal/" + name]
            self.assertEqual(_png_size(mapfile.res_path(entry["textures"][0])), size, name)
            self.assertEqual(entry["anchor"], anchor, name)
        self.assertTrue(catalog["tal/uh_chalk_rings"].get("flat"), "the rings lie on the floor")
        self.assertNotIn("shape", catalog["tal/uh_chalk_rings"], "and one walks over them")
        self.assertIn("shape", catalog["tal/uh_bed"], "the bed is a body")

    def test_door_start_and_arrival(self):
        _, symbols, rows = _map()
        placements = _placements(rows, symbols)
        doors = [p for p in placements if p[3].get("prop", "").endswith("door.tscn")]
        self.assertEqual(len(doors), 1)
        glyph, dx, dy, entry = doors[0]
        params = entry["params"]
        self.assertEqual((params["target"], params["spawn"], params["auto"], params["sound"]), ("grat", "urhaus", True, "door_close"))
        self.assertNotIn("size", params, "a door of one cell like the other rooms")
        rx, ry, rw, rh = ROOM
        self.assertEqual(dy, ry + rh - 1, "in the front wall")
        self.assertEqual(symbols[glyph]["ground"], "_", "the door's cell is floor")
        self.assertEqual(_glyph_cells(rows, "1"), [(dx, dy - 2)], "two cells in front of the door, like the other rooms")
        self.assertEqual(symbols["1"]["marker"], "spawn_grat", "named after the scene one comes from; grat.txt has `spawn_urhaus` for the way back")
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
        self.assertEqual(used["first_house"], {"B"})
        self.assertEqual(used["window"], {"Y"})
        self.assertEqual(used["blue_chalk"], {"k"})
        for cue, glyph, _, _ in RINGS:
            self.assertEqual(used[cue], {glyph})
        if os.path.exists(DIALOGUE):
            with open(DIALOGUE, encoding="utf-8") as f:
                cues = set(re.findall(r"^~ (\w+)", f.read(), re.M))
            self.assertLessEqual(CUES, cues, "every cue of the map is a cue of urhaus.dialogue")

    def test_the_six_spots_lie_in_the_bed_row_each_on_the_line_of_its_ring(self):
        _, symbols, rows = _map()
        bed = _glyph_cells(rows, "B")
        self.assertEqual(bed, [(16, 10)], "the bed in the middle: its left cell carries the glyph")
        ox, oy = RINGS_ORIGIN
        boxes = [r[3] for r in RINGS]
        for i, (cue, glyph, cell, (x0, y0, x1, y1)) in enumerate(RINGS):
            self.assertEqual(_glyph_cells(rows, glyph), [cell], cue)
            self.assertEqual(cell[1], bed[0][1], "all in the row of the bed")
            centre = ((cell[0] - ox) * 16 + 8, (cell[1] - oy) * 16 + 8)
            self.assertLessEqual(abs(centre[0] - x1), 6, "%s: on the right line of its ring" % cue)
            self.assertTrue(y0 < centre[1] < y1, "and between its top and bottom lines")
            self.assertEqual(symbols[glyph]["params"]["radius"], 14)
            self.assertNotIn("sprite", symbols[glyph]["params"], "an invisible spot, no body")
            if i:  # nested: each box lies round the one before it, a hand's breadth between the lines
                px0, py0, px1, py1 = boxes[i - 1]
                self.assertTrue(x0 < px0 and y0 < py0 and x1 > px1 and y1 > py1, "%s lies round the ring before it" % cue)
                self.assertGreaterEqual(min(px0 - x0, py0 - y0, x1 - px1, y1 - py1), 4, "room for a line between the rings")
        # the outermost ring runs along the walls and fills the picture: its box is the floor
        w, h = 368, 160
        x0, y0, x1, y1 = boxes[-1]
        self.assertTrue(x0 <= 6 and y0 <= 4 and x1 >= w - 6 and y1 >= h - 6)
        self.assertEqual(_glyph_cells(rows, "R"), [RINGS_ORIGIN], "the picture of the rings starts in the first floor cell of the back row")

    def test_the_bed_the_spots_and_the_chalk_can_be_reached_and_the_bed_leaves_room_beside_it(self):
        _, symbols, rows = _map()
        catalog = mapfile.load_catalog()
        walkable = {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if symbols[c].get("ground", c) not in SOLID_GROUNDS}
        start = _glyph_cells(rows, "@")[0]
        seen, queue = {start}, [start]
        rects = _blockers(rows, symbols, catalog)
        while queue:
            x, y = queue.pop()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c = (x + dx, y + dy)
                if c in walkable and c not in seen:
                    seen.add(c)
                    queue.append(c)
        self.assertEqual(seen, walkable, "no island: every floor cell is connected")
        bx, by = _glyph_cells(rows, "B")[0]
        for cell in ((bx - 1, by), (bx + 2, by), (bx, by - 1), (bx + 1, by - 1), (bx, by + 1), (bx + 1, by + 1)):
            cx, cy = cell[0] * 16 + 8, cell[1] * 16 + 8
            self.assertFalse(_hits(cx, cy, rects), "one can stand beside the bed at %s" % (cell,))
        for cell in ((bx, by), (bx + 1, by)):
            self.assertTrue(_hits(cell[0] * 16 + 8, cell[1] * 16 + 8, rects), "and not on it: %s" % (cell,))
        for glyph in "abcdefk":
            (x, y), = _glyph_cells(rows, glyph)
            self.assertFalse(_hits(x * 16 + 8, y * 16 + 8, rects), "%s can be stood on" % glyph)
        # the window sits in the back wall over the bed's first cell, the player reaches it from the row in front of the wall
        (wx, wy), = _glyph_cells(rows, "Y")
        self.assertEqual(wx, bx)
        self.assertEqual(wy, ROOM[1] + 2, "the last row of the back wall")
        self.assertEqual(symbols["Y"]["ground"], "W")
        self.assertEqual(symbols["Y"]["params"]["sprite_when"], {"urhaus.window_clear": "tal/uh_window_clear"})
        self.assertEqual(symbols["k"]["params"]["unless"], "urhaus.chalk_taken")
        self.assertEqual(symbols["Y"]["params"]["radius"], 24)

    def test_the_grats_door_and_the_way_back_agree(self):
        with open(GRAT, encoding="utf-8") as f:
            grat = f.read()
        self.assertIn('"target": "urhaus", "spawn": "grat"', grat)
        self.assertIn('marker": "spawn_urhaus"', grat, "grat.txt has the arrival for the door of this room")


if __name__ == "__main__":
    unittest.main()
