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
DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt5", "aufstieg.dialogue")
DIALOGUE_RES = "res://content/dialogue/akt5/aufstieg.dialogue"
# ground cells a person can stand on: grass, path, mud, puddle, the fords (shallow water over flat stones) and the planks over the brook
STANDABLE = set(".,mpwy")
# the path itself: path cells, puddles in it, the fords and the planks (the grass and the scree beside it are not)
WAY = set(",pwy")
# the spots of the walk, each once on the map (the rest of the letters are scattered)
NAMED = "Nn@XFZ123456789"
# the cues of the map by glyph (the contract of G1)
CUES = {"1": "cairn_first", "2": "mira_trace_boundary", "3": "mira_trace_joined", "4": "mira_trace_silent", "5": "view_smoke",
        "6": "plank_bridge", "7": "trail_sign", "8": "slate_chip", "9": "iron_ring", "X": "ridge_wait"}
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
            if "if" in params or "unless" in params or "sprite_when" in params or glyph in "FX":
                for sprite in sprites:
                    if sprite:
                        self.assertNotIn("shadow", catalog[sprite], "%s of %s would stay under nothing" % (sprite, glyph))
        self.assertNotIn("shadow", catalog["tal/gb_cairn_road"], "the road's cairns stand on the stamp of strasse")
        self.assertNotIn("shadow", catalog["tal/gb_rockfall"], "G2 takes the fall of rock away without a new bake")

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
        end = spots["X"][0]
        # the blocker's row (five cells) is the end for now: nothing north of it can be reached
        blocked = {(x, end[1]) for x in range(end[0] - 2, end[0] + 3)}
        reach = _reach(rows, symbols, spots["@"][0], blocked=blocked)
        for glyph in "nN":
            self.assertIn(spots[glyph][0], reach, glyph)
        self.assertIn((end[0], end[1] + 1), reach, "one steps up to the blocker")
        for x, y in reach:
            self.assertFalse(abs(x - end[0]) <= 2 and y <= end[1], "nothing beyond the blocker (G2 puts the door there) can be reached: %d,%d" % (x, y))
        for glyph in "12345678956":
            for x, y in spots[glyph]:
                near = any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3))
                self.assertTrue(near, "%s at %d,%d is out of reach" % (glyph, x, y))
        # the path itself (path cells, puddles in it, fords and planks) leads from the arrival to the blocker without a step on grass
        way = {(x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if _ground(symbols, c) in WAY}
        seen = {spots["n"][0]}
        queue = deque(seen)
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c = (x + dx, y + dy)
                if c in way and c not in seen and c not in blocked:
                    seen.add(c)
                    queue.append(c)
        self.assertIn((end[0], end[1] + 1), seen, "the path runs unbroken from the door to the blocker")

    def test_the_brook_cuts_every_shelf_and_only_planks_and_fords_cross_it(self):
        _, symbols, rows, spots = _pass()
        water = set("~vwy")
        for y in range(6, layout.H):
            self.assertTrue(any(c in water for c in rows[y]), "the brook runs through row %d" % y)
        # without the fords and the planks the brook splits the way: the end cannot be reached
        dry = [r.replace("w", "~").replace("y", "~") for r in rows]
        end = spots["X"][0]
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
        end = spots["X"][0]
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

    def test_the_end_is_a_gap_in_the_northern_wall_closed_by_a_blocker_and_a_fall_of_rock(self):
        _, symbols, rows, spots = _pass()
        bx, by = spots["X"][0]
        self.assertEqual(spots["X"][0], layout.BLOCKER)
        self.assertEqual(spots["F"][0], (bx, by - 1), "the fall of rock lies behind the blocker")
        params = symbols["X"]["params"]
        self.assertEqual((params["cue"], params["size"]), ("ridge_wait", [5, 1]))
        self.assertNotIn("if", params)
        self.assertNotIn("unless", params)
        # the blocker spans the whole gap: five ground cells, solid rock on both sides of them in the row
        cells = [rows[by][x] for x in range(bx - 2, bx + 3)]
        self.assertTrue(all(_ground(symbols, c) == "," for c in cells))
        self.assertEqual(rows[by][bx - 3], "^")
        self.assertEqual(rows[by][bx + 3], "^")
        # the gap is a canyon of cells the way goes on through (G2 puts the door where the blocker is): walkable up to row 1, the wall closed at row 0
        for y in range(1, by):
            for x in range(bx - 2, bx + 3):
                self.assertIn(_ground(symbols, rows[y][x]), ",", "the canyon above the blocker at %d,%d" % (x, y))
            self.assertEqual(rows[y][bx - 3], "^")
            self.assertEqual(rows[y][bx + 3], "^")
        self.assertEqual(set(rows[0]), {"^"}, "the northern wall is closed at the top")
        self.assertEqual(_png_size(mapfile.res_path(mapfile.load_catalog()["tal/gb_rockfall"]["textures"][0]))[0], 96)

    def test_no_crown_hides_a_spot_with_a_cue_and_none_stands_over_the_path(self):
        _, _, rows, spots = _pass()
        for glyph in list(CUES) + list("nN@"):
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


if __name__ == "__main__":
    unittest.main()
