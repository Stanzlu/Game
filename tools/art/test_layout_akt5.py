"""Tests of the Act V map generator (standard library only): python3 -m unittest discover -s tools/art."""
import math
import os
import re
import struct
import unittest
from collections import deque

import layout_akt5_maps as layout
import mapfile

PASS = os.path.join(mapfile.ROOT, "content", "maps", "pass.txt")
STRASSE = os.path.join(mapfile.ROOT, "content", "maps", "strasse.txt")
GRAT = os.path.join(mapfile.ROOT, "content", "maps", "grat.txt")
DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "aufstieg.dialogue")
DIALOGUE_RES = "res://content/dialogue/akt5/aufstieg.dialogue"
# ground cells a person can stand on: grass, path, mud, puddle, the fords (shallow water over flat stones) and the planks over the brook
STANDABLE = set(".,mpwy")
# the path itself: path cells, puddles in it, the fords and the planks (the grass and the scree beside it are not)
WAY = set(",pwy")
# the spots of the walk, each once on the map (the rest of the letters are scattered)
NAMED = "NnDd@Z123456789"
# the cues of the map by glyph (the contract of G1; since G2 the end of the way is a door, no cue: `ridge_wait` stays in the dialogue as text)
CUES = {"1": "cairn_first", "2": "mira_trace_boundary", "3": "mira_trace_joined", "4": "mira_trace_silent", "5": "view_smoke",
        "6": "plank_bridge", "7": "trail_sign", "8": "slate_chip", "9": "iron_ring"}
CAIRNS = "ABKabk1"
# a line of sight is stopped by solid ground (forest, rock, falls) and by tall props (trees, boulders)
BLOCKS = set("h^vTCPOo")
TREES = {"T": (3, 8), "C": (3, 8), "P": (2, 5)}


def _map(path=PASS):
    return mapfile.parse_map(path)


def _ground(symbols, glyph):
    return symbols[glyph].get("ground", glyph)


def _spots(rows):
    found = {}
    for y, row in enumerate(rows):
        for x, glyph in enumerate(row):
            found.setdefault(glyph, []).append((x, y))
    return found


def _reach(rows, symbols, start, standable=STANDABLE, blocked=()):
    seen = {start}
    queue = deque([start])
    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if not (0 <= ny < len(rows) and 0 <= nx < len(rows[ny])) or (nx, ny) in seen or (nx, ny) in blocked:
                continue
            if _ground(symbols, rows[ny][nx]) in standable:
                seen.add((nx, ny))
                queue.append((nx, ny))
    return seen


def _sight(rows, a, b):
    (x0, y0), (x1, y1) = a, b
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(1, n):
        t = i / n
        x, y = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t))
        if (x, y) in (a, b):
            continue
        if rows[y][x] in BLOCKS:
            return False
    return True


def _png_size(path):
    with open(path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])


def _pass():
    meta, symbols, rows = _map()
    return meta, symbols, rows, _spots(rows)


def _door_zone(symbols, glyph, spots):
    """The cells a door's zone touches fully: one row high, `size[0]` cells wide, centred on the glyph's cell."""
    x, y = spots[glyph][0]
    w = symbols[glyph]["params"]["size"][0]
    return [(x + d, y) for d in range(-(w // 2), w // 2 + 1)]


class PassLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map()
        self.assertEqual(rows, layout.text().split("\n"), "run layout_akt5_maps.py pass --write")

    def test_the_map_is_class_m_and_within_the_briefs_size(self):
        _, _, rows = _map()
        self.assertLessEqual(len(rows), 60, "at most 100 x 60 cells (the brief, G1)")
        self.assertLessEqual(len(rows[0]), 100)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")
        self.assertEqual((len(rows[0]), len(rows)), (layout.W, layout.H))
        self.assertGreater(len(rows) * len(rows[0]), 4000, "bigger than the valley, a map of class M")

    def test_every_named_spot_stands_once_and_the_scatter_placed_all_it_was_asked_to(self):
        _, _, rows, spots = _pass()
        text = "".join(rows)
        for glyph in NAMED:
            self.assertEqual(text.count(glyph), 1, glyph)
        self.assertEqual(text.count("s"), 4, "the steps of the four ramps")
        layout.build()
        self.assertEqual(layout.build.shortfall, {}, "the scatter placed all it was asked to")

    def test_every_glyph_has_its_own_legend_line_and_every_cue_is_the_contracts(self):
        with open(PASS, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows, spots = _pass()
        for glyph in set("".join(rows)):
            self.assertIsNotNone(re.search(r"^%s = " % re.escape(glyph), source, re.M), "no legend line for " + glyph)
        used = {}
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if "cue" in params:
                used[glyph] = params["cue"]
                self.assertEqual(params["dialogue"], DIALOGUE_RES, glyph)
        self.assertEqual(used, CUES)
        if os.path.exists(DIALOGUE):
            with open(DIALOGUE, encoding="utf-8") as f:
                cues = set(re.findall(r"^~ (\w+)", f.read(), re.M))
            self.assertLessEqual(set(used.values()), cues, "every cue of the map is a cue of the dialogue")

    def test_the_legend_grounds_are_the_generators_and_no_placement_changes_the_ground_it_stands_on(self):
        _, symbols, rows, _ = _pass()
        land = layout.land()
        for glyph in set("".join(rows)):
            self.assertEqual(_ground(symbols, glyph), layout.GROUND[glyph], glyph)
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                self.assertEqual(_ground(symbols, glyph), land.get(x, y), "%s at %d,%d paints other ground than the layout drew" % (glyph, x, y))

    def test_every_sprite_of_the_map_is_in_the_catalog_and_none_has_a_light(self):
        meta, symbols, rows, _ = _pass()
        catalog = mapfile.load_catalog()
        sprites = set()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if params.get("sprite"):
                sprites.add(params["sprite"])
            sprites.update(params.get("sprite_when", {}).values())
        sprites.update(rule["sprite"] for rule in meta["scatter"])
        for sprite in sprites:
            self.assertIn(sprite, catalog, sprite)
            self.assertNotIn("lights", catalog[sprite], "no PointLight2D in the mountains of G1: " + sprite)
        for sprite in ("tal/gb_planks", "tal/gb_steps", "tal/gb_smoke", "tal/gb_slate", "tal/gb_arrow_chalk"):
            self.assertTrue(catalog[sprite].get("flat"), sprite + " lies on the ground")
            self.assertNotIn("sway", catalog[sprite])
        self.assertNotIn("smoke", catalog["tal/gb_smoke"], "the plant's smoke is a picture, not a particle effect: it does not flicker")
        for entry in catalog["tal/gb_smoke"]["textures"]:
            self.assertTrue(os.path.exists(mapfile.res_path(entry)), entry)

    def test_what_the_story_takes_or_adds_and_what_g2_may_remove_casts_no_baked_shadow(self):
        _, symbols, rows, _ = _pass()
        catalog = mapfile.load_catalog()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            sprites = [params.get("sprite")] + list(params.get("sprite_when", {}).values())
            if "if" in params or "unless" in params or "sprite_when" in params:
                for sprite in sprites:
                    if sprite:
                        self.assertNotIn("shadow", catalog[sprite], "%s of %s would stay under nothing" % (sprite, glyph))
        self.assertNotIn("shadow", catalog["tal/gb_cairn_road"], "the road's cairns stand on the stamp of strasse")
        self.assertNotIn("shadow", catalog["tal/gb_rockfall"], "the heap of scree at the foot of the Grat's ramp (grat) is taken away by G6 without a new bake")

    def test_the_door_the_arrival_and_the_start_are_at_the_south_end(self):
        _, symbols, rows, spots = _pass()
        door, arrival, start = spots["N"][0], spots["n"][0], spots["@"][0]
        self.assertEqual(door, (layout.DOOR_X, layout.DOOR_Y))
        self.assertEqual(arrival, (door[0], door[1] - 1), "the arrival lies one cell north of the door")
        params = symbols["N"]["params"]
        self.assertEqual((params["target"], params["spawn"], params["auto"], params["size"]), ("strasse", "pass", True, [5, 1]))
        self.assertNotIn("if", params)
        self.assertEqual(symbols["n"]["marker"], "spawn_strasse", "the marker is named after the scene one comes from")
        self.assertEqual(symbols["@"]["marker"], "player_spawn")
        for x, y in _door_zone(symbols, "N", spots):
            self.assertIn(rows[y][x], ".,N", "the whole zone lies on the notch's ground (%d,%d)" % (x, y))
        # the zone is one row high: the arrival (a row above, feet 4.5 px under its centre) is not in it
        self.assertEqual(symbols["N"]["params"]["size"][1], 1)
        # the start: far enough from the door, and the benchmark's square (right 1.6 s, down 1 s, left, up) lies on walkable ground
        self.assertGreaterEqual(math.hypot(start[0] - door[0], start[1] - door[1]), 4)
        sx, sy = start
        for x in range(sx, sx + 10):
            self.assertIn(_ground(symbols, rows[sy][x]), STANDABLE, "east of the start, %d" % x)
            self.assertIn(_ground(symbols, rows[sy + 5][x]), STANDABLE, "the lower side of the benchmark's square, %d" % x)
        for y in range(sy, sy + 6):
            self.assertIn(_ground(symbols, rows[y][sx]), STANDABLE)
            self.assertIn(_ground(symbols, rows[y][sx + 9]), STANDABLE)
        # the strasse's side of the door
        _, s_symbols, s_rows = _map(STRASSE)
        s_spots = _spots(s_rows)
        self.assertEqual(s_symbols[s_rows[s_spots["D"][0][1]][s_spots["D"][0][0]]]["params"]["target"], "pass")
        self.assertEqual(s_symbols["D"]["params"]["spawn"], "strasse", "the door's spawn names the scene it comes from")
        self.assertEqual(s_symbols["r"]["marker"], "spawn_pass")

    def test_the_way_is_one_path_from_the_door_to_the_end_and_every_spot_can_be_reached_on_foot(self):
        _, symbols, rows, spots = _pass()
        end = spots["D"][0]
        reach = _reach(rows, symbols, spots["@"][0])
        for glyph in "nNdD":
            self.assertIn(spots[glyph][0], reach, glyph)
        for cell in _door_zone(symbols, "D", spots):
            self.assertIn(cell, reach, "the whole zone of the door to the high valley can be walked into: %s" % (cell,))
        self.assertIn((end[0], end[1] + 1), reach, "one steps up to the door")
        for glyph in "12345678956":
            for x, y in spots[glyph]:
                near = any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3))
                self.assertTrue(near, "%s at %d,%d is out of reach" % (glyph, x, y))
        # the path itself (path cells, puddles in it, fords and planks) leads from the arrival to the door without a step on grass
        way = {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if _ground(symbols, c) in WAY}
        seen = {spots["n"][0]}
        queue = deque(seen)
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c = (x + dx, y + dy)
                if c in way and c not in seen:
                    seen.add(c)
                    queue.append(c)
        self.assertIn((end[0], end[1] + 1), seen, "the path runs unbroken from the door to the high valley")

    def test_the_brook_cuts_every_shelf_and_only_planks_and_fords_cross_it(self):
        _, symbols, rows, spots = _pass()
        water = set("~vwy")
        for y in range(6, layout.H):
            self.assertTrue(any(c in water for c in rows[y]), "the brook runs through row %d" % y)
        # without the fords and the planks the brook splits the way: the end cannot be reached
        dry = [r.replace("w", "~").replace("y", "~") for r in rows]
        end = spots["D"][0]
        reach = _reach(dry, symbols, spots["@"][0], STANDABLE - {"w", "y"})
        self.assertNotIn((end[0], end[1] + 1), reach, "the brook has to be crossed")
        # every shelf has its ford: the path meets the brook in shelves 1 to 4 and the planks are on the meadow
        self.assertEqual(len(layout.land.fords), 4)
        for (fx, fy), (k, (y0, y1, _, _)) in zip(layout.land.fords, list(enumerate(layout.SHELVES))[1:]):
            self.assertTrue(y0 <= fy <= y1, "the ford of shelf %d lies on it" % k)
            self.assertIn(rows[fy][fx], "w", "the ford's middle")
            self.assertLessEqual(layout.path_distance(fx, fy), 1.5, "the ford lies on the path")
        # the plank bridge: two rows of three `y` cells, a path cell at each end, the picture covers the five cells, the cue stands on it
        x0 = layout.land.plank_x
        for y in layout.PLANK_ROWS:
            self.assertEqual("".join(rows[y][x0 - 1:x0 + 4]).replace("6", "y"), ",yyy,", "row %d" % y)
        self.assertEqual(spots["6"][0], (x0 + 1, layout.PLANK_ROWS[0]))
        catalog = mapfile.load_catalog()
        planks = catalog["tal/gb_planks"]
        self.assertEqual(planks["anchor"], [40, 8], "five cells wide, two rows: the glyph's cell is the second of the five")
        self.assertEqual(_png_size(mapfile.res_path(planks["textures"][0])), (80, 32))
        # the falls: where the brook leaves a band, there is water above and below
        falls = {}
        for x, y in [c for c, in [((x, y),) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "v"]]:
            falls.setdefault(x, []).append(y)
        self.assertGreaterEqual(len(falls), 9, "four falls, three cells wide each")
        for x, ys in falls.items():
            top, bottom = min(ys), max(ys)
            self.assertEqual(ys, list(range(top, bottom + 1)))
            self.assertIn(rows[top - 1][x], "~vw", "water falls from above")
            self.assertIn(rows[bottom + 1][x], "~w", "water lands below, where the foam is")

    def test_four_shelves_four_ramps_and_the_steps_on_them(self):
        _, symbols, rows, spots = _pass()
        self.assertEqual(len(spots["s"]), 4)
        ordered = sorted(spots["s"], key=lambda c: -c[1])  # from the south
        self.assertEqual([x for x, _ in ordered], layout.RAMP_X)
        sides = [x > layout.W // 2 for x, _ in ordered]
        self.assertEqual(sides, [True, False, True, False], "east, west, east, west: every shelf is walked the other way")
        for x, y in ordered:
            for dy in (-3, 3):
                cells = [rows[y + dy][x + dx] for dx in (-1, 0, 1)]
                self.assertTrue(all(_ground(symbols, c) in STANDABLE for c in cells), "path above and below the steps at %d,%d" % (x, y))
            col = "".join(rows[yy][x] for yy in range(y - 6, y + 7))
            self.assertNotIn("^", col, "the ramp is cut straight through the band")
        for x, y in ordered:
            self.assertEqual(symbols["s"]["params"]["sprite"], "tal/gb_steps")
        catalog = mapfile.load_catalog()
        self.assertEqual(_png_size(mapfile.res_path(catalog["tal/gb_steps"]["textures"][0])), (48, 64))
        # the shelves lose their grass as they rise
        counts = []
        for y0, y1 in ((44, 56), (34, 41), (24, 31), (14, 21), (4, 11)):
            counts.append(sum(row.count("m") for row in rows[y0:y1 + 1]))
        self.assertEqual(counts[0], 0, "the meadow has no scree")
        self.assertGreater(counts[4], counts[1], "more gravel on the top shelf than on the first")

    def test_the_cairns_keep_each_other_in_sight_all_the_way_up(self):
        _, symbols, rows, spots = _pass()
        cairns = [c for glyph in CAIRNS for c in spots.get(glyph, [])]
        samples = layout.path_samples()
        sub = range(0, len(samples), 3)

        def along(c):
            return min(sub, key=lambda i: math.hypot(c[0] - samples[i][0], c[1] - samples[i][1]))

        cairns.sort(key=along)
        self.assertEqual(cairns[0], spots["1"][0], "the first cairn is the one with the cue")
        self.assertGreaterEqual(len(cairns), 12)
        self.assertLessEqual(len(cairns), 28)
        # the first is in sight of the arrival; each next one is in sight of the one before (nothing solid or tall between them)
        chain = [spots["n"][0]] + cairns
        for a, b in zip(chain, chain[1:]):
            dist = math.hypot(a[0] - b[0], a[1] - b[1])
            self.assertLessEqual(dist, 18, "%s to %s is too far apart" % (a, b))
            self.assertTrue(_sight(rows, a, b), "no sight from %s to %s" % (a, b))
        for a, b in zip(cairns, cairns[1:]):
            self.assertGreaterEqual(math.hypot(a[0] - b[0], a[1] - b[1]), 7, "%s and %s stand too close together" % (a, b))
        end = spots["D"][0]
        self.assertLessEqual(math.hypot(cairns[-1][0] - end[0], cairns[-1][1] - end[1]), 14, "the last cairn is near the end of the way")
        for x, y in cairns:
            self.assertGreaterEqual(layout.path_distance(x, y), 1.8, "a cairn stands beside the path, not in it: %d,%d" % (x, y))
            self.assertIn(_ground(symbols, rows[y][x]), ".m")
            neighbours = [rows[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
            self.assertTrue(any(_ground(symbols, c) in STANDABLE for c in neighbours), "a cairn can be reached")
        sprites = {symbols[g]["params"]["sprite"] for g in CAIRNS}
        self.assertEqual(sprites, {"tal/gb_cairn_a", "tal/gb_cairn_b", "tal/gb_cairn_c"}, "three forms")
        forms = {rows[y][x].lower() for x, y in cairns if rows[y][x] != "1"}
        self.assertEqual(forms, {"a", "b", "k"}, "all three forms are in use")
        # nothing but cairns, the smoke and the light shows the way: no arrow and no compass in the map (the chalk arrow is the road's)
        for glyph in set("".join(rows)):
            sprite = symbols[glyph].get("params", {}).get("sprite", "")
            self.assertNotIn("arrow", sprite)

    def test_miras_three_traces_are_one_each_with_one_condition_and_lie_near_the_path_before_the_first_ramp(self):
        _, symbols, rows, spots = _pass()
        conditions = {}
        for glyph, sprite in (("2", "tal/gb_net_post"), ("3", "tal/gb_net_branch"), ("4", "tal/gb_stone_mark")):
            params = symbols[glyph]["params"]
            self.assertEqual(params["sprite"], sprite)
            self.assertNotIn("unless", params)
            self.assertIsInstance(params["if"], str, "exactly one condition")
            conditions[glyph] = params["if"]
        self.assertEqual(conditions, {"2": "city.mira_parted_boundary", "3": "city.mira_parted_joined", "4": "city.mira_parted_silent"})
        (bx, by), (jx, jy), (sx, sy) = spots["2"][0], spots["3"][0], spots["4"][0]
        # boundary: near the path, tidy (a post two or three cells off); joined: on the walker's side, nearer; silent: in the middle of the path
        self.assertTrue(2.0 <= layout.path_distance(bx, by) <= 3.6)
        self.assertTrue(1.5 <= layout.path_distance(jx, jy) <= 3.6)
        self.assertLessEqual(layout.path_distance(sx, sy), 1.0)
        self.assertIn(rows[sy][sx], "4")
        self.assertEqual(_ground(symbols, "4"), ",", "the flat stone lies on the path")
        ramp0 = max(spots["s"], key=lambda c: c[1])
        for x, y in ((bx, by), (jx, jy), (sx, sy)):
            self.assertGreater(y, ramp0[1], "on the meadow, before the first ramp")
            self.assertLessEqual(math.hypot(x - spots["6"][0][0], y - spots["6"][0][1]), 12, "just beyond the plank bridge")
        self.assertLessEqual(max(math.hypot(a[0] - b[0], a[1] - b[1]) for a in ((bx, by), (jx, jy), (sx, sy)) for b in ((bx, by), (jx, jy), (sx, sy))), 9)
        # the traces and the first cairn have no shadow in the baked ground (conditional props cast none); the net sprites are not flat (they stand up)
        catalog = mapfile.load_catalog()
        self.assertFalse(catalog["tal/gb_net_post"].get("flat"))
        self.assertTrue(catalog["tal/gb_stone_mark"].get("flat"))

    def test_the_things_to_find_are_where_the_contract_says(self):
        _, symbols, rows, spots = _pass()
        # the view: the lookout on the upper half, and the smoke of the plant far to its upper right
        vx, vy = spots["5"][0]
        zx, zy = spots["Z"][0]
        self.assertLess(vy, layout.H // 2, "the view is on the upper half")
        self.assertGreaterEqual(zx, 70)
        self.assertLessEqual(zy, 20)
        self.assertGreater(zx, vx)
        self.assertLess(zy, vy)
        self.assertLessEqual(math.hypot(zx - vx, zy - vy), 25, "the smoke is in the picture from the lookout")
        self.assertEqual(_ground(symbols, "Z"), "^", "the smoke rises from the rock")
        catalog = mapfile.load_catalog()
        smoke = catalog["tal/gb_smoke"]
        w, h = _png_size(mapfile.res_path(smoke["textures"][0]))
        self.assertGreaterEqual(zy * 16 + 8 - smoke["anchor"][1], 0, "the whole column lies inside the map")
        self.assertGreaterEqual(h, 128, "a tall thin column")
        self.assertLessEqual(w, 24)
        # the iron ring hangs on the wall: rock directly north of its cell, grass under it
        rx, ry = spots["9"][0]
        self.assertEqual(rows[ry - 1][rx], "^")
        self.assertEqual(rows[ry - 2][rx], "^")
        self.assertEqual(_ground(symbols, "9"), ".")
        # the slate chip goes with its flag; the sign stands beside the path; the first cairn near the arrival
        self.assertEqual(symbols["8"]["params"]["unless"], "mountain.slate_taken")
        self.assertNotIn("if", symbols["8"]["params"])
        self.assertTrue(2.0 <= layout.path_distance(*spots["7"][0]) <= 4.0)
        self.assertGreater(layout.path_distance(*spots["8"][0]), 5.0, "the slate chip lies off the way, a find")
        self.assertLessEqual(math.hypot(spots["1"][0][0] - spots["n"][0][0], spots["1"][0][1] - spots["n"][0][1]), 8)
        for glyph, sprite in (("5", "tal/gb_lookout"), ("7", "tal/gb_sign_trail"), ("9", "tal/gb_iron_ring"), ("1", "tal/gb_cairn_c")):
            self.assertEqual(symbols[glyph]["params"]["sprite"], sprite)
        # the things of the walk are spread out along the way, a few steps from one to the next
        order = sorted((spots[g][0] for g in "1267589"), key=lambda c: -c[1])
        for a, b in zip(order, order[1:]):
            self.assertLessEqual(a[1] - b[1], 16, "something to see every few rows")

    def test_the_end_is_a_gap_in_the_northern_wall_with_the_door_to_the_high_valley(self):
        _, symbols, rows, spots = _pass()
        text = "".join(rows)
        for glyph in "XF":
            self.assertNotIn(glyph, text, "G1's blocker and fall of rock are gone (G2): " + glyph)
        bx, by = spots["D"][0]
        self.assertEqual(spots["D"][0], layout.NORTH_DOOR, "the door stands where the blocker stood")
        self.assertEqual(spots["d"][0], (bx, by + 1), "the arrival lies one cell south of the door")
        self.assertEqual(spots["d"][0], layout.NORTH_ARRIVAL)
        params = symbols["D"]["params"]
        self.assertEqual((params["target"], params["spawn"], params["auto"], params["size"]), ("grat", "pass", True, [5, 1]))
        self.assertNotIn("if", params)
        self.assertNotIn("unless", params)
        self.assertEqual(symbols["d"]["marker"], "spawn_grat", "the marker is named after the scene one comes from")
        self.assertEqual(_ground(symbols, "D"), ",", "the door stands on the ground the blocker had: no new bake")
        self.assertEqual(_ground(symbols, "d"), ",")
        # the door spans the whole gap: five ground cells, solid rock on both sides of them in the row
        cells = [rows[by][x] for x in range(bx - 2, bx + 3)]
        self.assertTrue(all(_ground(symbols, c) == "," for c in cells))
        self.assertEqual(rows[by][bx - 3], "^")
        self.assertEqual(rows[by][bx + 3], "^")
        # the gap is a canyon of cells the way used to go on through (the heap of G1 is gone): walkable up to row 1, the wall closed at row 0
        for y in range(1, by):
            for x in range(bx - 2, bx + 3):
                self.assertIn(_ground(symbols, rows[y][x]), ",", "the canyon above the door at %d,%d" % (x, y))
            self.assertEqual(rows[y][bx - 3], "^")
            self.assertEqual(rows[y][bx + 3], "^")
        self.assertEqual(set(rows[0]), {"^"}, "the northern wall is closed at the top")
        # the other side of the door: the high valley's arrival from the pass lies at its south edge
        _, g_symbols, g_rows = _map(GRAT)
        g_spots = _spots(g_rows)
        self.assertEqual(g_symbols[g_rows[g_spots["D"][0][1]][g_spots["D"][0][0]]]["params"]["target"], "pass")
        self.assertEqual(g_symbols["D"]["params"]["spawn"], "grat", "the door's spawn names the scene it comes from")
        self.assertEqual(g_symbols["d"]["marker"], "spawn_pass")

    def test_no_crown_hides_a_spot_with_a_cue_and_none_stands_over_the_path(self):
        _, _, rows, spots = _pass()
        for glyph in list(CUES) + list("nNdD@"):
            for x, y in spots[glyph]:
                for dy in range(1, 9):
                    for dx in range(-3, 4):
                        inside = y + dy < len(rows) and 0 <= x + dx < len(rows[0])
                        cell = rows[y + dy][x + dx] if inside else "h"
                        if cell in TREES:
                            wide, high = TREES[cell]
                            self.assertFalse(abs(dx) <= wide and dy <= high,
                                             "a crown hides %s at %d,%d (tree at %d,%d)" % (glyph, x, y, x + dx, y + dy))
        for x, y in layout.path_samples()[::4]:
            x, y = int(x), int(y)
            for dy in range(1, 7):
                for dx in (-1, 0, 1):
                    inside = y + dy < len(rows) and 0 <= x + dx < len(rows[0])
                    cell = rows[y + dy][x + dx] if inside else "h"
                    self.assertNotIn(cell, "TCP", "a crown over the path at %d,%d (tree at %d,%d)" % (x, y, x + dx, y + dy))

    def test_the_meta_names_the_baked_images_and_the_ground_was_baked_from_this_map(self):
        meta, _, _, _ = _pass()
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/pass_ground.png")
        self.assertEqual(meta["water"], "res://assets/generated/maps/pass_water.png")
        for key in ("ground", "water"):
            self.assertTrue(os.path.exists(mapfile.res_path(meta[key])), meta[key])
        self.assertNotIn("treeline", meta)
        self.assertEqual(_png_size(mapfile.res_path(meta["ground"])), (layout.W * 16, layout.H * 16))
        self.assertEqual(mapfile.stamp(PASS), mapfile.read_stamps()["pass"], "run tools/art/bake_ground.py content/maps/pass.txt")

    def test_the_picture_of_the_ground_follows_the_map_the_brook_is_water_and_the_bands_are_rock(self):
        meta, symbols, rows, _ = _pass()
        text = "".join(rows)
        self.assertGreaterEqual(text.count("^"), 1200, "the mountain's rock")
        self.assertGreaterEqual(text.count("h"), 800, "the forest below")
        self.assertGreaterEqual(text.count("v"), 20, "four falls")
        self.assertGreaterEqual(text.count("O") + text.count("o"), 15, "boulders")
        self.assertGreaterEqual(text.count("S"), 20, "loose scree on the ground")
        self.assertGreaterEqual(text.count("p"), 4, "puddles in the path")
        for glyph, paint in (("v", "fall"), ("w", "water"), ("y", "water"), ("^", "cliff"), ("h", "hedge"), ("m", "mud")):
            self.assertEqual(symbols[glyph]["paint"], paint)
        # only paints the baker already has (no new kind: the baker's sources are unchanged)
        for glyph in set("".join(rows)):
            self.assertIn(mapfile.paint_of(glyph, symbols), ("grass", "path", "mud", "puddle", "water", "hedge", "cliff", "fall"))



# ============================================================================================================== grat (G2)
GRAT_DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "hochtal.dialogue")
GRAT_DIALOGUE_RES = "res://content/dialogue/akt5/hochtal.dialogue"
# G3: the blocker at the gate asks the Anlage's own dialogue (the cue `gate`); the cue `plant_gate` of hochtal.dialogue stays there as text
GRAT_ANLAGE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "anlage.dialogue")
GRAT_ANLAGE_RES = "res://content/dialogue/akt5/anlage.dialogue"
# G6: the things on the Grat ask the cleft's own dialogue
GRAT_SPALTE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "spalte.dialogue")
GRAT_SPALTE_RES = "res://content/dialogue/akt5/spalte.dialogue"
GRAT_SPALTE_GLYPHS = "VBCIJP"
# the glyphs that stand once on the map
GRAT_NAMED = "Dd@123q7HQMtAZGXYFsEeVBCIJP"
# the cues of the map by glyph (the contract of G2)
GRAT_CUES = {"1": "cairn_1", "2": "cairn_2", "3": "cairn_3", "q": "stone_pick", "7": "valley_sign", "H": "hand_stone", "Q": "quartz",
             "M": "marmot_den", "X": "gate", "Y": "ramp_wait",
             "V": "ledge_view", "B": "fork_sign", "C": "cleft_mouth", "I": "hiding_place", "J": "candle", "P": "plateau_edge"}
# things a person cannot walk through, whatever the ground: the hall, the fence, the gate, the blockers
GRAT_SOLID_PROPS = set("AfGXY")
# a line of sight is stopped by solid ground and by what stands tall
GRAT_BLOCKS = set("h^vOoAfGXY")
GRAT_TALL = set("Oo")


def _grat():
    meta, symbols, rows = _map(GRAT)
    return meta, symbols, rows, _spots(rows)


def _cells(rows, symbols, glyphs, standable=STANDABLE):
    return {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if c in glyphs and _ground(symbols, c) in standable}


def _blocked_by_props(rows, extra=()):
    """The cells of what is solid by its prop (the blockers cover their zone; the one at the gate covers the gate's row)."""
    cells = {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if c in GRAT_SOLID_PROPS}
    gx, gy = layout.GRAT_GATE_BLOCKER
    cells |= {(x, gy - 1) for x in range(gx - 1, gx + 2)} | {(x, gy) for x in range(gx - 1, gx + 2)}
    rx, ry = layout.GRAT_RAMP_BLOCKER
    cells |= {(x, ry) for x in range(rx - 2, rx + 3)}
    return cells | set(extra)


class GratLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map(GRAT)
        self.assertEqual(rows, layout.text("grat").split("\n"), "run layout_akt5_maps.py grat --write")

    def test_the_map_is_class_m_within_the_briefs_size_and_keeps_its_node_count_in_check(self):
        _, _, rows = _map(GRAT)
        self.assertEqual((len(rows[0]), len(rows)), (layout.GRAT_W, layout.GRAT_H))
        self.assertEqual((layout.GRAT_W, layout.GRAT_H), (96, 56))
        self.assertLessEqual(len(rows), 70, "at most 120 x 70 cells (class M, ADR-068)")
        self.assertLessEqual(len(rows[0]), 120)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")
        self.assertGreater(len(rows) * len(rows[0]), 4000, "bigger than the valley, a map of class M")
        placed = sum(1 for row in rows for c in row if c not in ".,m~h^wp")
        self.assertLess(placed, 320, "a map of class M builds in about half a second: keep the nodes in check")
        layout.grat_build()
        self.assertEqual(layout.grat_build.shortfall, {}, "the scatter placed all it was asked to")

    def test_every_named_thing_stands_once(self):
        _, symbols, rows, spots = _grat()
        text = "".join(rows)
        for glyph in GRAT_NAMED:
            self.assertEqual(text.count(glyph), 1, glyph)
        self.assertEqual(text.count("f"), layout.GRAT_POCKET[1] - layout.GRAT_POCKET[0] + 1 - 3, "the fence: one piece a cell, but the gate's three")
        self.assertEqual(len(spots["1"]) + len(spots["2"]) + len(spots["3"]), 3, "three cairns")
        for glyph in "Kabk":
            self.assertNotIn(glyph, text, "no other cairns than the three with a cue: " + glyph)

    def test_every_glyph_has_its_own_legend_line_and_every_cue_is_the_contracts(self):
        with open(GRAT, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows, spots = _grat()
        for glyph in set("".join(rows)):
            self.assertIsNotNone(re.search(r"^%s = " % re.escape(glyph), source, re.M), "no legend line for " + glyph)
        used = {}
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if "cue" in params:
                used[glyph] = params["cue"]
                expected = GRAT_ANLAGE_RES if glyph == "X" else GRAT_SPALTE_RES if glyph in GRAT_SPALTE_GLYPHS else GRAT_DIALOGUE_RES
                self.assertEqual(params["dialogue"], expected, glyph)
        self.assertEqual(used, GRAT_CUES)
        self.assertEqual(len(set(used.values())), len(used), "no cue twice")
        valley = [g for g in used if g != "X" and g not in GRAT_SPALTE_GLYPHS]
        for path, glyphs in ((GRAT_DIALOGUE, valley), (GRAT_ANLAGE, ["X"]), (GRAT_SPALTE, list(GRAT_SPALTE_GLYPHS))):
            if os.path.exists(path):
                with open(path, encoding="utf-8") as f:
                    cues = set(re.findall(r"^~ (\w+)", f.read(), re.M))
                self.assertLessEqual({used[g] for g in glyphs}, cues, "every cue of the map is a cue of its dialogue")

    def test_the_legend_grounds_are_the_generators_and_no_placement_changes_the_ground_it_stands_on(self):
        _, symbols, rows, _ = _grat()
        land = layout.grat_land()
        for glyph in set("".join(rows)):
            self.assertEqual(_ground(symbols, glyph), layout.GRAT_GROUND[glyph], glyph)
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                self.assertEqual(_ground(symbols, glyph), land.get(x, y), "%s at %d,%d paints other ground than the layout drew" % (glyph, x, y))
        for glyph, paint in (("~", "water"), ("w", "water"), ("^", "cliff"), ("h", "hedge"), ("m", "mud"), (",", "path"), (".", "grass"), ("p", "puddle")):
            self.assertEqual(symbols[glyph]["paint"], paint)
        for glyph in set("".join(rows)):  # only paints the baker already has (no new kind: the baker's sources are unchanged)
            self.assertIn(mapfile.paint_of(glyph, symbols), ("grass", "path", "mud", "puddle", "water", "hedge", "cliff", "fall"))

    def test_every_sprite_is_in_the_catalog_has_no_light_and_the_new_ones_have_their_pictures(self):
        meta, symbols, rows, _ = _grat()
        catalog = mapfile.load_catalog()
        sprites = set()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if params.get("sprite"):
                sprites.add(params["sprite"])
            sprites.update(params.get("sprite_when", {}).values())
        sprites.update(rule["sprite"] for rule in meta["scatter"])
        for sprite in sprites:
            self.assertIn(sprite, catalog, sprite)
            self.assertNotIn("lights", catalog[sprite], "no PointLight2D in the mountains (O3): " + sprite)
            for entry in catalog[sprite]["textures"]:
                self.assertTrue(os.path.exists(mapfile.res_path(entry)), entry)
        self.assertEqual(_png_size(mapfile.res_path(catalog["tal/gb_plant_hall"]["textures"][0])), (192, 168))
        self.assertEqual(catalog["tal/gb_plant_hall"]["anchor"], [96, 162])
        self.assertEqual(_png_size(mapfile.res_path(catalog["tal/gb_plant_fence"]["textures"][0])), (16, 30), "one cell of fence")
        self.assertEqual(_png_size(mapfile.res_path(catalog["tal/gb_plant_gate"]["textures"][0]))[0], 48, "the gate fills three cells")
        self.assertEqual(len(catalog["tal/gb_dwarf_pine"]["textures"]), 3, "three mountain pines")
        for sprite in ("tal/gb_hand_stone", "tal/gb_round_stone", "tal/gb_smoke_plant", "tal/gb_steps", "tal/gb_rockfall"):
            if sprite != "tal/gb_rockfall":
                self.assertTrue(catalog[sprite].get("flat"), sprite + " lies on the ground")
            self.assertNotIn("sway", catalog[sprite])
        self.assertNotIn("smoke", catalog["tal/gb_smoke_plant"], "the plant's smoke is a picture, not a particle effect: it does not flicker")
        # the pictures of the small things: the fragment of the hand, the stone's, the quartz's and the thimble's icons
        for out, name in (("fragments", "fragment_hand"), ("items", "item_restless_stone"), ("items", "curiosity_quartz"), ("items", "curiosity_thimble")):
            path = os.path.join(mapfile.ROOT, "assets", "generated", out, name + ".png")
            self.assertTrue(os.path.exists(path), path)
            self.assertEqual(_png_size(path), (16, 16))

    def test_what_goes_with_a_flag_or_is_taken_away_later_casts_no_baked_shadow(self):
        _, symbols, rows, _ = _grat()
        catalog = mapfile.load_catalog()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            sprites = [params.get("sprite")] + list(params.get("sprite_when", {}).values())
            if "if" in params or "unless" in params or "sprite_when" in params or glyph in "GFsXYq":
                for sprite in sprites:
                    if sprite:
                        self.assertNotIn("shadow", catalog[sprite], "%s of %s would stay under nothing" % (sprite, glyph))
        for glyph, flag in (("q", "grat.stone_taken"), ("Q", "grat.quartz_taken"), ("t", "grat.thimble_taken")):
            params = symbols[glyph]["params"]
            self.assertEqual(params["unless"], flag, glyph)
            self.assertNotIn("if", params)
        for glyph in "XYG":
            self.assertNotIn("if", symbols[glyph].get("params", {}), "the blockers and the gate are there until their segment takes them away")
        self.assertEqual(symbols["J"]["params"]["unless"], "grat.candle_taken", "the candle is gone once it is taken")
        self.assertEqual(symbols["Y"]["params"]["unless"], "plant.letgo", "the blocker of the ramp goes with the letting go (G6)")
        self.assertEqual(symbols["F"]["params"]["unless"], "plant.letgo", "and so does the heap of scree before the steps")
        self.assertEqual(symbols["X"]["params"]["unless"], "grat.gate_open", "the blocker at the gate goes with the flag the knocking sets (G3)")
        self.assertNotIn("shadow", catalog["tal/gb_plant_gate_open"], "the open gate is a look the story changes: no baked shadow")
        self.assertNotIn("cue", symbols["t"]["params"], "the thimble is taken at the den (its cue), the thimble itself is a picture")

    def test_the_door_the_arrival_and_the_start_are_at_the_south_end_far_from_every_door(self):
        _, symbols, rows, spots = _grat()
        door, arrival, start = spots["D"][0], spots["d"][0], spots["@"][0]
        self.assertEqual(door, layout.GRAT_DOOR)
        self.assertEqual(arrival, layout.GRAT_ARRIVAL)
        params = symbols["D"]["params"]
        self.assertEqual((params["target"], params["spawn"], params["auto"], params["size"]), ("pass", "grat", True, [5, 1]))
        self.assertNotIn("if", params)
        self.assertEqual(symbols["d"]["marker"], "spawn_pass", "the marker is named after the scene one comes from")
        self.assertEqual(symbols["@"]["marker"], "player_spawn")
        self.assertGreaterEqual(door[1], layout.GRAT_H - 3, "the door is in the southern wall")
        self.assertGreaterEqual(math.hypot(arrival[0] - door[0], arrival[1] - door[1]), 5, "the arrival lies at least five cells from the door back")
        for x, y in _door_zone(symbols, "D", spots):
            self.assertIn(rows[y][x], ",D", "the whole zone lies on the notch's ground (%d,%d)" % (x, y))
            self.assertEqual(rows[y][door[0] - 3], "^")
        self.assertEqual(symbols["D"]["params"]["size"][1], 1)
        # the doors of the map: the one in the south and the future one at the gate (G3); the start is far from both (the benchmark walks right first, then down)
        doors = [door, layout.GRAT_GATE_BLOCKER, layout.GRAT_HALL_DOOR]
        for dx, dy in doors:
            self.assertGreaterEqual(math.hypot(start[0] - dx, start[1] - dy), 20, "the benchmark walks right, then down: stay away from %s" % ((dx, dy),))
            self.assertGreaterEqual(abs(start[0] - dx) + abs(start[1] - dy), 20)
        self.assertEqual(start, layout.GRAT_START)
        sx, sy = start
        for x in range(sx, sx + 11):  # the benchmark's square (right 1.6 s, down 1 s, left, up) lies on walkable ground
            self.assertIn(_ground(symbols, rows[sy][x]), STANDABLE, "east of the start, %d" % x)
        for y in range(sy, sy + 4):  # (the southern wall stops the second leg a few cells down: nothing there but rock)
            self.assertIn(_ground(symbols, rows[y][sx]), STANDABLE)
        # walking right from the start never meets a door or a blocker's zone before something solid (a rock, a cairn) or the wall stops the walker
        for x in range(sx, len(rows[sy])):
            glyph = rows[sy][x]
            if glyph in GRAT_BLOCKS or glyph in "123":
                break
            self.assertNotIn(glyph, "DXYE", "the first run to the right meets no door")
        # the pass's side of the door
        _, p_symbols, p_rows = _map()
        p_spots = _spots(p_rows)
        self.assertEqual(p_symbols["D"]["params"]["target"], "grat")
        self.assertEqual(p_symbols["d"]["marker"], "spawn_grat")
        self.assertEqual(len(p_spots["D"]), 1)

    def test_everything_with_a_cue_can_be_reached_from_the_start_and_the_yard_and_the_grat_cannot(self):
        _, symbols, rows, spots = _grat()
        blocked = _blocked_by_props(rows)
        reach = _reach(rows, symbols, spots["@"][0], blocked=blocked)
        for glyph in "Dd":
            self.assertIn(spots[glyph][0], reach, glyph)
        for cell in _door_zone(symbols, "D", spots):
            self.assertIn(cell, reach)
        for glyph in "123q7HQMt":
            for x, y in spots[glyph]:
                near = any((x + dx, y + dy) in reach for dx in range(-1, 2) for dy in range(-1, 2))
                self.assertTrue(near, "%s at %d,%d cannot be walked up to" % (glyph, x, y))
        gx, gy = layout.GRAT_GATE_BLOCKER
        for x in range(gx - 1, gx + 2):
            self.assertIn((x, gy + 1), reach, "one stands in front of the gate: %d" % x)
        rx, ry = layout.GRAT_RAMP_BLOCKER
        for x in range(rx - 2, rx + 3):
            self.assertIn((x, ry + 1), reach, "one stands at the foot of the ramp: %d" % x)
        # the yard of the Anlage is closed: the fence, the gate (and the blocker before it) and the rock round it
        x0, x1, y0, y1 = layout.GRAT_POCKET
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.assertNotIn((x, y), reach, "the yard of the Anlage cannot be entered: %d,%d" % (x, y))
        # the Grat (the ramp, the ledge, the cleft, the plateau: every walkable cell above the valley's floor) lies behind the blocker `ramp_wait`
        sx0, sx1, sy0, sy1 = layout.GRAT_SPALTE
        grat_cells = {(x, y) for y in range(0, 11) for x in range(layout.GRAT_W) if _ground(symbols, rows[y][x]) in STANDABLE}
        grat_cells |= {(x, y) for y in range(sy0, sy1 + 1) for x in range(sx0, sx1 + 1)}  # the cleft
        grat_cells |= {(x, y) for y in range(11, ry + 1) for x in range(rx - 2, rx + 3)}  # the ramp, up to the blocker's row
        self.assertGreater(len(grat_cells), 350, "a broad Grat is laid out, though it cannot be reached yet")
        self.assertEqual(grat_cells & reach, set(), "nothing of the Grat can be reached while the blocker stands")
        # and with the blocker gone all of it can: one walk up the ramp, the ledge, both branches round the island, the cleft, the plateau
        open_reach = _reach(rows, symbols, spots["@"][0], blocked=_blocked_by_props(rows) - {(x, ry) for x in range(rx - 2, rx + 3)})
        self.assertEqual({c for c in grat_cells if c not in open_reach}, set(), "once the blocker is gone every cell of the Grat can be reached")
        # the pocket stays closed even then (only the open gate lets one in: G3, see the test of the hall door)
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.assertNotIn((x, y), open_reach)

    def test_the_way_to_the_gate_is_one_path_from_the_door_over_the_forecourt(self):
        _, symbols, rows, spots = _grat()
        gx, gy = layout.GRAT_GATE_BLOCKER
        way = {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if _ground(symbols, c) in WAY and c not in GRAT_SOLID_PROPS}
        seen = {spots["d"][0]}
        queue = deque(seen)
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c = (x + dx, y + dy)
                if c in way and c not in seen:
                    seen.add(c)
                    queue.append(c)
        self.assertIn((gx, gy + 1), seen, "the path runs unbroken from the arrival to the gate, on no grass")
        self.assertIn((layout.GRAT_RAMP_BLOCKER[0], layout.GRAT_RAMP_BLOCKER[1] + 1), seen, "and from the arrival to the foot of the ramp")
        # beaten earth in front of the gate: a plaza, not only a path
        plaza = [(x, y) for y in range(gy + 1, gy + 7) for x in range(gx - 10, gx + 11) if rows[y][x] == ","]
        self.assertGreaterEqual(len(plaza), 70, "the forecourt")
        for x in range(gx - 4, gx + 5):
            self.assertEqual(rows[gy + 1][x], "," if x != gx else "X" if rows[gy + 1][x] == "X" else ",", "the forecourt reaches up to the gate: %d" % x)

    def test_three_cairns_each_in_sight_of_the_one_before_and_the_first_in_sight_of_the_arrival(self):
        _, symbols, rows, spots = _grat()
        cairns = [spots[g][0] for g in "123"]
        arrival = spots["d"][0]
        self.assertEqual(cairns, layout.grat_build.cairns, "the numbers run along the way")
        self.assertLessEqual(math.hypot(cairns[0][0] - arrival[0], cairns[0][1] - arrival[1]), 18, "the first stands near the arrival")
        self.assertTrue(_gsight(rows, arrival, cairns[0]), "no sight from the arrival to the first cairn")
        for a, b in zip(cairns, cairns[1:]):
            dist = math.hypot(a[0] - b[0], a[1] - b[1])
            self.assertTrue(8 <= dist <= 16, "%s to %s: %.1f cells (eight to sixteen)" % (a, b, dist))
            self.assertTrue(_gsight(rows, a, b), "no sight from %s to %s" % (a, b))
        for x, y in cairns:
            self.assertTrue(1.8 <= layout.grat_path_distance(x, y) <= 3.6, "a cairn stands beside the way, not in it: %d,%d" % (x, y))
            self.assertEqual(_ground(symbols, rows[y][x]), ".")
            neighbours = [rows[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
            self.assertTrue(any(_ground(symbols, c) in STANDABLE for c in neighbours), "a cairn can be reached")
        # they lead along the south shore to the Anlage: each farther east than the last, the last nearer to the gate than the first
        xs = [c[0] for c in cairns]
        self.assertEqual(xs, sorted(xs))
        gate = layout.GRAT_GATE
        self.assertLess(math.hypot(cairns[2][0] - gate[0], cairns[2][1] - gate[1]), math.hypot(cairns[0][0] - gate[0], cairns[0][1] - gate[1]))
        self.assertEqual([symbols[g]["params"]["sprite"] for g in "123"], ["tal/gb_cairn_c", "tal/gb_cairn_b", "tal/gb_cairn_a"], "three forms")
        # the small round stone lies at the foot of the first, one cell down and to the right
        qx, qy = spots["q"][0]
        self.assertEqual((qx - cairns[0][0], qy - cairns[0][1]), (1, 1))
        self.assertEqual(symbols["q"]["params"]["sprite"], "tal/gb_round_stone")
        self.assertGreaterEqual(symbols["q"]["params"]["lift"], 4, "it sits at the cairn's foot, not a cell below it")
        for x, y in cairns:
            self.assertEqual(symbols[rows[y][x]]["params"].get("if"), None)

    def test_the_tarn_lies_in_the_middle_of_the_basin_with_a_shallow_south_shore_and_the_hand_on_the_stone_at_it(self):
        _, symbols, rows, spots = _grat()
        water = [(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if c == "~"]
        self.assertGreaterEqual(len(water), 250, "a tarn")
        cx, cy = sum(x for x, _ in water) / len(water), sum(y for _, y in water) / len(water)
        self.assertTrue(24 <= cx <= 48 and 24 <= cy <= 40, "in the middle of the basin: %.1f,%.1f" % (cx, cy))
        shallow = [(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if c == "w"]
        self.assertGreaterEqual(len(shallow), 20, "a shore one can walk into")
        for x, y in shallow:
            self.assertTrue(any(rows[y + dy][x + dx] in "~w" for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))), "shallow water lies at the water: %d,%d" % (x, y))
        self.assertTrue(any(y >= 38 for _, y in shallow), "the south shore is shallow")
        self.assertNotIn("v", "".join(rows), "no brook and no fall: the brook of the pass does not come here")
        hx, hy = spots["H"][0]
        self.assertEqual(_ground(symbols, "H"), ".")
        self.assertTrue(any(rows[hy + dy][hx + dx] == "w" for dx in range(-2, 3) for dy in range(-2, 2)), "the hand lies at the water's edge")
        self.assertTrue(any(rows[hy - 1][hx + dx] in "w~" for dx in (-1, 0, 1)), "the water is just north of the stone")
        self.assertIn((hx, hy + 1), _reach(rows, symbols, spots["@"][0], blocked=_blocked_by_props(rows)), "and one can step up to it from the south")
        params = symbols["H"]["params"]
        self.assertEqual(params["sprite"], "tal/gb_hand_stone")
        self.assertNotIn("if", params)
        self.assertNotIn("unless", params, "the hand is there for the second look too: its second view is one line")
        self.assertLessEqual(layout.grat_path_distance(hx, hy), 6.0, "close to the way, not a long detour")

    def test_the_finds_the_quartz_in_the_scree_and_the_marmots_den_with_the_thimble_in_the_dent(self):
        _, symbols, rows, spots = _grat()
        qx, qy = spots["Q"][0]
        self.assertEqual(_ground(symbols, "Q"), "m", "the quartz lies in the scree")
        self.assertGreaterEqual(sum(rows[qy + dy][qx + dx] in "mS" for dx in range(-2, 3) for dy in range(-2, 3)), 5)
        self.assertTrue(any(rows[qy + dy][qx + dx] == "^" for dx in range(-4, 5) for dy in range(-4, 5)) or layout.grat_path_distance(qx, qy) > 7, "off the way: a find")
        mx, my = spots["M"][0]
        self.assertEqual(spots["t"][0], (mx, my + 1), "the thimble sits in the dent below the mouth")
        self.assertEqual(_ground(symbols, "M"), "m")
        self.assertEqual(_ground(symbols, "t"), "m")
        slope = sum(rows[y][x] in "mSrol" for y in range(my - 4, my + 5) for x in range(mx - 6, mx + 7))
        self.assertGreaterEqual(slope, 30, "a slope of bare earth round the den")
        self.assertGreater(mx, layout.GRAT_LAKE[0] + layout.GRAT_LAKE[2], "the den lies east of the tarn")
        self.assertEqual(symbols["M"]["params"]["sprite"], "tal/gb_marmot_den")
        catalog = mapfile.load_catalog()
        self.assertEqual(catalog["tal/gb_marmot_den"]["anchor"], [36, 36])
        self.assertEqual(_png_size(mapfile.res_path(catalog["tal/gb_marmot_den"]["textures"][0])), (72, 58))
        # the dent in the picture is 16 pixels under the anchor: the thimble's cell is one row below, the thimble lifted by its params
        self.assertEqual(symbols["t"]["params"]["lift"], 2)
        # nobody to see: the marmot is a trace, never a prop that moves or speaks
        for glyph in set("".join(rows)):
            self.assertNotIn("marmot", symbols[glyph].get("params", {}).get("sprite", "").replace("marmot_den", ""))

    def test_the_valley_sign_stands_at_the_entrance_and_looks_at_the_wall(self):
        _, symbols, rows, spots = _grat()
        sx, sy = spots["7"][0]
        arrival = spots["d"][0]
        self.assertLessEqual(math.hypot(sx - arrival[0], sy - arrival[1]), 10, "at the entrance")
        self.assertEqual(symbols["7"]["params"]["sprite"], "tal/gb_sign_view")
        # the board points left (west): within a few cells to its left there is only the rock (and scrub in front of it): a view of a wall
        row = rows[sy]
        wall = max(x for x in range(0, sx) if row[x] == "^")
        self.assertLessEqual(sx - wall, 10, "the arrow points at a wall")
        self.assertTrue(1.5 <= layout.grat_path_distance(sx, sy) <= 8.0)

    def test_the_anlage_is_a_hall_in_a_pocket_of_the_rock_with_a_fence_from_rock_to_rock_and_a_gate_that_is_shut(self):
        _, symbols, rows, spots = _grat()
        hx, hy = spots["A"][0]
        self.assertEqual((hx, hy), layout.GRAT_HALL)
        x0, x1, y0, y1 = layout.GRAT_POCKET
        catalog = mapfile.load_catalog()
        hall = catalog["tal/gb_plant_hall"]
        hall_w = _png_size(mapfile.res_path(hall["textures"][0]))[0]
        self.assertGreaterEqual((x1 - x0 + 1) * 16, 176 + 16, "the pocket holds the hall's wall with a cell to spare on each side")
        self.assertGreaterEqual(hx - x0, 5)
        self.assertGreaterEqual(x1 - hx, 5)
        self.assertEqual(hall["shape"]["rect"][0], 176, "its collision is the wall's width")
        self.assertLessEqual(hall["shape"]["rect"][0], hall_w)
        self.assertEqual(_ground(symbols, "A"), ",")
        self.assertEqual(symbols["A"]["params"]["sprite"], "tal/gb_plant_hall")
        # the pocket: beaten earth in the rock, rock on every side but the south, where the fence closes it
        for y in range(y0, y1 + 2):
            self.assertEqual(rows[y][x0 - 1], "^", "rock west of the pocket, row %d" % y)
            self.assertEqual(rows[y][x1 + 1], "^", "rock east of the pocket, row %d" % y)
            for x in range(x0, x1 + 1):
                self.assertIn(_ground(symbols, rows[y][x]), ",", "the yard is beaten earth: %d,%d" % (x, y))
        for x in range(x0, x1 + 1):
            self.assertEqual(rows[y0 - 1][x], "^", "rock behind the hall (the wall)")
        # the fence: one piece in every cell of its row but the gate's three, the gate in the middle, the blocker before it
        fy = layout.GRAT_FENCE_Y
        gx, gy = spots["G"][0]
        self.assertEqual((gx, gy), layout.GRAT_GATE)
        self.assertEqual(gy, fy)
        self.assertEqual(gx, (x0 + x1) // 2, "the gate stands in the middle")
        for x in range(x0, x1 + 1):
            self.assertEqual(rows[fy][x], "G" if x == gx else "f" if abs(x - gx) > 1 else rows[fy][x], "fence row, %d" % x)
            if abs(x - gx) == 1:
                self.assertEqual(_ground(symbols, rows[fy][x]), ",")
        self.assertEqual(rows[fy][x0 - 1], "^")
        self.assertEqual(rows[fy][x1 + 1], "^")
        self.assertEqual(catalog["tal/gb_plant_gate"]["anchor"][0] * 2, 48)
        self.assertEqual(spots["X"][0], (gx, gy + 1), "the blocker stands in front of the gate")
        params = symbols["X"]["params"]
        self.assertEqual((params["size"], params["offset"], params["cue"]), ([3, 1], [0, -1], "gate"), "it covers the three cells of the gate's row")
        self.assertEqual(params["unless"], "grat.gate_open", "it gives way once the gate is open (G3)")
        self.assertEqual(symbols["G"]["params"]["sprite_when"], {"grat.gate_open": "tal/gb_plant_gate_open"}, "and the gate stands open")
        for x, y in _door_zone(symbols, "X", spots):
            self.assertEqual(_ground(symbols, rows[y][x]), ",", "the forecourt in front of the gate")
        # the chimney's top and the foot of the smoke are the same point, the column rises straight over rock
        zx, zy = spots["Z"][0]
        self.assertEqual((zx, zy), layout.GRAT_SMOKE)
        cap_x = hx * 16 + 8 - hall["anchor"][0] + 128  # the chimney stands at x 121 to 135 of the picture: its middle is 128
        cap_y = hy * 16 + 8 - hall["anchor"][1] + 4  # the cap's top row is row 4
        smoke = catalog["tal/gb_smoke_plant"]
        foot_x = zx * 16 + 8
        foot_y = zy * 16 + 8 - smoke["anchor"][1] + _png_size(mapfile.res_path(smoke["textures"][0]))[1]
        self.assertLessEqual(abs(cap_x - foot_x), 4, "the smoke rises from the chimney")
        self.assertLessEqual(abs(cap_y - foot_y), 4)
        self.assertEqual(_ground(symbols, "Z"), "^", "it rises over the rock")
        self.assertGreaterEqual(zy * 16 + 8 - smoke["anchor"][1], 0)
        self.assertLessEqual(_png_size(mapfile.res_path(smoke["textures"][0]))[0], 24)
        self.assertLess(_png_size(mapfile.res_path(smoke["textures"][0]))[1], 168, "shorter than the pass's column")
        self.assertEqual(symbols["Z"]["params"]["sprite"], "tal/gb_smoke_plant")

    def test_the_ramp_is_five_cells_wide_through_the_band_with_steps_a_heap_and_the_blocker_at_its_foot(self):
        _, symbols, rows, spots = _grat()
        rx, ry = spots["Y"][0]
        self.assertEqual((rx, ry), layout.GRAT_RAMP_BLOCKER)
        params = symbols["Y"]["params"]
        self.assertEqual((params["cue"], params["size"]), ("ramp_wait", [5, 1]))
        self.assertNotIn("if", params)
        self.assertEqual(params["unless"], "plant.letgo", "G6: the keeper's entry of the letting go takes the blocker away")
        cells = [rows[ry][x] for x in range(rx - 2, rx + 3)]
        self.assertTrue(all(_ground(symbols, c) == "," for c in cells))
        self.assertEqual(rows[ry][rx - 3], "^")
        self.assertEqual(rows[ry][rx + 3], "^", "rock on both sides of the blocker's row")
        self.assertEqual(spots["F"][0], (rx, ry - 1), "the heap of scree lies behind the blocker")
        self.assertEqual(symbols["F"]["params"]["sprite"], "tal/gb_rockfall")
        sx, sy = spots["s"][0]
        self.assertEqual((sx, sy), layout.GRAT_RAMP_STEPS)
        self.assertEqual(symbols["s"]["params"]["sprite"], "tal/gb_steps")
        self.assertLess(sy, ry - 3, "the steps lie above the heap")
        for y in range(8, ry + 1):  # the ramp runs straight up through the band: five cells of ground between rock
            for x in range(rx - 2, rx + 3):
                self.assertEqual(_ground(symbols, rows[y][x]), ",", "the ramp at %d,%d" % (x, y))
            if y >= 12:
                self.assertEqual(rows[y][rx - 3], "^")
                self.assertEqual(rows[y][rx + 3], "^")
        self.assertEqual(rx, layout.GRAT_RAMP_X)
        self.assertLess(rx, layout.GRAT_W // 3, "the ramp is in the west")
        self.assertLess(ry, layout.GRAT_H // 2, "and in the north")
        self.assertLessEqual(rx + 2, layout.grat_west(layout.GRAT_TOP) + 12)

    def test_the_grat_is_a_ledge_with_an_island_to_go_round_a_cleft_three_cells_wide_above_the_anlage_and_a_free_plateau(self):
        _, symbols, rows, spots = _grat()
        ix0, ix1, iy0, iy1 = layout.GRAT_ISLAND
        sx0, sx1, sy0, sy1 = layout.GRAT_SPALTE
        px0, px1, py0, py1 = layout.GRAT_PLATEAU
        # the ledge along the northern wall runs from the ramp to the plateau at the east end
        open_reach = _reach(rows, symbols, (layout.GRAT_RAMP_X, 10))
        for x in range(16, px1 + 1):
            self.assertTrue(any((x, y) in open_reach for y in range(2, 11)), "the ledge is walked at every column: %d" % x)
        # the island: rock, and the way goes round it on both sides, each at least two cells wide
        for y in range(iy0, iy1 + 1):
            for x in range(ix0, ix1 + 1):
                self.assertEqual(rows[y][x], "^", "the rock island at %d,%d" % (x, y))
        for xs in range(ix0 - 2, ix1 + 3):
            north = [y for y in range(0, iy0) if (xs, y) in open_reach]
            south = [y for y in range(iy1 + 1, sy0) if (xs, y) in open_reach]
            self.assertGreaterEqual(len(north), 2, "the north branch, column %d" % xs)
            self.assertGreaterEqual(len(south), 2, "the south branch, column %d" % xs)
        without_north = _reach(rows, symbols, (layout.GRAT_RAMP_X, 10), blocked={(x, y) for x in range(ix0 - 2, ix1 + 3) for y in range(0, iy0)})
        without_south = _reach(rows, symbols, (layout.GRAT_RAMP_X, 10), blocked={(x, y) for x in range(ix0 - 2, ix1 + 3) for y in range(iy1 + 1, sy0)})
        self.assertIn((px0 + 2, py0 + 2), without_north, "the plateau can be reached by the south branch alone")
        self.assertIn((px0 + 2, py0 + 2), without_south, "and by the north branch alone: a detour beside the cleft")
        # the cleft: three cells wide, six deep, opening on the south branch of the ledge, rock on both sides and at the bottom, all walkable
        self.assertEqual(sx1 - sx0 + 1, 3)
        self.assertEqual(sy1 - sy0 + 1, 6)
        for y in range(sy0, sy1 + 1):
            for x in range(sx0, sx1 + 1):
                self.assertIn(_ground(symbols, rows[y][x]), STANDABLE, "the cleft at %d,%d" % (x, y))
                self.assertIn((x, y), open_reach)
            self.assertEqual(rows[y][sx0 - 1], "^", "rock on the west side of the cleft")
            self.assertEqual(rows[y][sx1 + 1], "^", "and on the east")
        for x in range(sx0, sx1 + 1):
            self.assertEqual(rows[sy1 + 1][x], "^", "the cleft ends in the rock")
            self.assertIn(rows[sy0 - 1][x], ".,mpC", "its mouth lies on the ledge (G6: the middle cell is a spot to look from)")
        gx = layout.GRAT_HALL[0]
        self.assertTrue(abs((sx0 + sx1) / 2 - gx) <= 6, "above the Anlage: over the hall")
        self.assertGreater(layout.GRAT_HALL[1] - sy1, 10)
        # the plateau: an open stretch of ground, nothing placed on it, for the door of the first house (G8)
        for y in range(py0, py1 + 1):
            for x in range(px0, px1 + 1):
                self.assertIn(rows[y][x], ".,m", "the plateau is bare ground: %d,%d" % (x, y))
                self.assertIn((x, y), open_reach)
        self.assertGreaterEqual((px1 - px0 + 1) * (py1 - py0 + 1), 90)
        self.assertGreaterEqual(px0, 80, "in the north-east")
        # nothing is placed in the cleft or on the island's ground but ground itself
        for y in range(sy0, sy1 + 1):
            for x in range(sx0, sx1 + 1):
                self.assertIn(rows[y][x], ",m", "the cleft is free for G6")

    def test_no_boulder_hides_a_thing_with_a_cue_and_nothing_stands_on_the_way(self):
        _, symbols, rows, spots = _grat()
        for glyph in "123q7HQMtXYDd":
            for x, y in spots[glyph]:
                for dy in range(-3, 4):
                    for dx in range(-3, 4):
                        if math.hypot(dx, dy) < 2.7 and 0 <= y + dy < len(rows):
                            self.assertNotIn(rows[y + dy][x + dx], GRAT_TALL | set("L"), "%s at %d,%d has a boulder or a shrub at %d,%d" % (glyph, x, y, x + dx, y + dy))
        for x, y in layout.grat_path_samples()[::4]:
            x, y = int(round(x)), int(round(y))
            for dx in (-1, 0, 1):
                self.assertNotIn(rows[y][x + dx], "OoLlRrgu", "something on the way at %d,%d" % (x + dx, y))

    def test_the_meta_names_the_baked_images_and_the_ground_was_baked_from_this_map(self):
        meta, _, _, _ = _grat()
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/grat_ground.png")
        self.assertEqual(meta["water"], "res://assets/generated/maps/grat_water.png")
        for key in ("ground", "water"):
            self.assertTrue(os.path.exists(mapfile.res_path(meta[key])), meta[key])
        self.assertNotIn("treeline", meta)
        self.assertEqual(_png_size(mapfile.res_path(meta["ground"])), (layout.GRAT_W * 16, layout.GRAT_H * 16))
        self.assertEqual(mapfile.stamp(GRAT), mapfile.read_stamps()["grat"], "run tools/art/bake_ground.py content/maps/grat.txt")

    def test_the_picture_of_the_ground_follows_the_map_rock_around_a_basin_with_a_tarn_scree_and_scrub(self):
        _, symbols, rows, _ = _grat()
        text = "".join(rows)
        self.assertGreaterEqual(text.count("^"), 2000, "the walls")
        self.assertGreaterEqual(text.count("h"), 120, "scrub on the slopes")
        self.assertGreaterEqual(text.count("m") + text.count("S"), 120, "scree")
        self.assertGreaterEqual(text.count("L") + text.count("l"), 25, "mountain pines")
        self.assertGreaterEqual(text.count("O") + text.count("o"), 8, "boulders")
        self.assertGreaterEqual(text.count("p"), 4, "puddles in the path")
        self.assertGreater(text.count(".") , 900, "meadows")
        # the basin is wider than it is high at the lake's height, and the ledge is a stretch along the northern wall
        self.assertGreaterEqual(sum(1 for c in rows[5] if c in STANDABLE), 60, "the ledge runs along the wall")

    def test_g3_the_gate_opens_into_the_yard_and_the_door_to_the_hall_stands_in_front_of_the_halls_own_door(self):
        meta, symbols, rows, spots = _grat()
        catalog = mapfile.load_catalog()
        x0, x1, y0, y1 = layout.GRAT_POCKET
        hx, hy = layout.GRAT_HALL
        # the door: three cells wide, two deep, on the cell right in front of the hall, only with the gate open
        self.assertEqual(len(spots["E"]), 1)
        ex, ey = spots["E"][0]
        self.assertEqual((ex, ey), layout.GRAT_HALL_DOOR)
        self.assertEqual((ex, ey), (hx, hy + 1), "in front of the hall's own door, one cell south of its foot")
        params = symbols["E"]["params"]
        self.assertEqual(symbols["E"]["prop"], "res://world/props/door.tscn")
        self.assertEqual((params["target"], params["spawn"], params["auto"], params["size"], params["if"]), ("maschine", "grat", True, [3, 2], "grat.gate_open"))
        self.assertNotIn("unless", params)
        self.assertEqual(_ground(symbols, "E"), ",", "beaten earth, no change of ground: the bake stays")
        self.assertEqual(rows[ey][ex - 1:ex + 2], ",E,")
        # its zone (the glyph's cell, 24 pixels to each side and 16 up and down) lies in front of the hall's collision, so that touching the hall
        # is touching the door, and does not reach the arrival
        hall = catalog["tal/gb_plant_hall"]["shape"]
        origin_y = hy * 16 + 8
        wall_bottom = origin_y + hall["offset"][1] + hall["rect"][1] / 2  # the lowest pixel row the hall's collision covers
        zone_top, zone_bottom = ey * 16 + 8 - 16, ey * 16 + 8 + 16
        self.assertLessEqual(zone_top, wall_bottom + 0.5, "the zone touches the hall's wall")
        self.assertGreater(zone_bottom, wall_bottom + 4.5, "and reaches past the pixel where the player's feet stop at the wall, so that standing at the wall is standing in the zone")
        self.assertEqual(zone_bottom - zone_top, 32)
        # the marker: named after the scene one comes from, in the yard, outside the zone
        self.assertEqual(len(spots["e"]), 1)
        ax, ay = spots["e"][0]
        self.assertEqual((ax, ay), layout.GRAT_YARD_ARRIVAL)
        self.assertEqual(symbols["e"]["marker"], "spawn_maschine")
        self.assertEqual(_ground(symbols, "e"), ",")
        self.assertTrue(x0 <= ax <= x1 and y0 <= ay <= y1, "the arrival lies in the yard")
        self.assertGreaterEqual(ay, ey + 2, "two cells in front of the door: the player's feet are outside its zone")
        self.assertGreater(ay * 16 + 8 - 4.5, zone_bottom)
        # the hall's side of the door: `maschine` answers with `spawn_grat` and a door back with spawn `maschine`
        maschine = os.path.join(mapfile.ROOT, "content", "maps", "maschine.txt")
        _, m_symbols, m_rows = _map(maschine)
        self.assertEqual(m_symbols["D"]["params"]["target"], "grat")
        self.assertEqual(m_symbols["D"]["params"]["spawn"], "maschine")
        self.assertEqual(m_symbols["1"]["marker"], "spawn_grat")
        # the gate: shut it keeps the yard closed (see above); open (blocker and gate gone) one walks from the start over the forecourt and through the gate to the door
        gx, gy = layout.GRAT_GATE_BLOCKER
        gate_cells = {(x, y) for x in range(gx - 1, gx + 2) for y in (gy - 1, gy)}
        open_reach = _reach(rows, symbols, spots["@"][0], blocked=_blocked_by_props(rows) - gate_cells)
        self.assertIn((ax, ay), open_reach, "with the gate open one can walk to the arrival")
        for x in range(ex - 1, ex + 2):
            for y in (ey, ey + 1):
                self.assertIn((x, y), open_reach, "and into the door's zone: %d,%d" % (x, y))
        shut_reach = _reach(rows, symbols, spots["@"][0], blocked=_blocked_by_props(rows))
        for cell in [(ax, ay), (ex, ey)]:
            self.assertNotIn(cell, shut_reach, "shut, the yard cannot be reached")
        # the blocker and the gate belong together: the blocker gives way with the flag that changes the gate's picture
        self.assertEqual(symbols["X"]["params"]["unless"], list(symbols["G"]["params"]["sprite_when"])[0])


def _gsight(rows, a, b):
    (x0, y0), (x1, y1) = a, b
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(1, n):
        t = i / n
        x, y = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t))
        if (x, y) in (a, b):
            continue
        if rows[y][x] in GRAT_BLOCKS:
            return False
    return True


if __name__ == "__main__":
    unittest.main()
