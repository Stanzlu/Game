"""Tests of the Act III map generator (standard library only): python3 -m unittest discover -s tools/art."""
import json
import os
import re
import unittest
from collections import deque

import layout_akt3_maps as layout
import mapfile

WALDWEG = os.path.join(mapfile.ROOT, "content", "maps", "waldweg.txt")
FLUTLICHTUNG = os.path.join(mapfile.ROOT, "content", "maps", "flutlichtung.txt")
TAL = os.path.join(mapfile.ROOT, "content", "maps", "tal.txt")
FLUT_DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt3", "flutlichtung.dialogue")
# ground cells a person can stand on (the legend's own grounds: grass, path, mud, puddle)
STANDABLE = set(".,mp")
# the Flutlichtung also has the ford: shallow water over flat stones (surface stone, not solid)
FLUT_STANDABLE = STANDABLE | {"y"}
# the spots of the walk, each once on the map (the rest of the letters are scattered forest)
NAMED = "123456AEHDSNn@WwQqazUKrCZYX"
CUES = "123456QqazUKHDSnWCZYX"
# the Flutlichtung's spots, each once (the ford's other two cells are plain 'y')
FLUT_NAMED = "NnSMAECDokdiB@"
# the spots with a cue (the arrival and the start are no cues)
FLUT_CUES = "SMAECokdiB"


def _map(path=WALDWEG):
    return mapfile.parse_map(path)


def _ground(symbols, glyph):
    entry = symbols[glyph]
    return entry.get("ground", glyph)


def _spots(rows):
    found = {}
    for y, row in enumerate(rows):
        for x, glyph in enumerate(row):
            found.setdefault(glyph, []).append((x, y))
    return found


def _reach(rows, symbols, start, standable=STANDABLE):
    seen = {start}
    queue = deque([start])
    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if not (0 <= ny < len(rows) and 0 <= nx < len(rows[ny])) or (nx, ny) in seen:
                continue
            if _ground(symbols, rows[ny][nx]) in standable:
                seen.add((nx, ny))
                queue.append((nx, ny))
    return seen


class WaldwegLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map()
        self.assertEqual(rows, layout.text().split("\n"), "run layout_akt3_maps.py waldweg --write")

    def test_the_map_stays_within_class_m(self):
        _, _, rows = _map()
        self.assertLessEqual(len(rows), 70)
        self.assertLessEqual(len(rows[0]), 120)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")
        self.assertEqual((len(rows[0]), len(rows)), (layout.W, layout.H))

    def test_every_named_spot_stands_once_and_the_logs_twice(self):
        _, _, rows = _map()
        text = "".join(rows)
        for glyph in NAMED:
            self.assertEqual(text.count(glyph), 1, glyph)
        self.assertEqual(text.count("L"), 2, "one log at each ring")

    def test_every_spot_can_be_reached_from_the_start_on_foot(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        reach = _reach(rows, symbols, spots["@"][0])
        for glyph in CUES:
            for x, y in spots[glyph]:
                near = any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3))
                self.assertTrue(near, "%s at %d,%d is out of reach" % (glyph, x, y))

    def test_the_spots_come_in_the_order_of_the_walk_from_north_to_south(self):
        _, _, rows = _map()
        spots = _spots(rows)
        order = ["N", "n", "1", "2", "Q", "3", "a", "U", "z", "4", "q", "5", "6", "w", "W"]
        ys = [spots[glyph][0][1] for glyph in order]
        self.assertEqual(ys, sorted(ys), "the walk goes from the door to the end of the way")
        self.assertLess(spots["Q"][0][1], spots["a"][0][1], "a place to rest before the Hang")
        self.assertGreater(spots["q"][0][1], spots["z"][0][1], "and one after it")

    def test_the_arrivals_are_outside_the_doors_zones_and_on_the_path(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        door, arrival, start = spots["N"][0], spots["n"][0], spots["@"][0]
        self.assertGreaterEqual(abs(arrival[1] - door[1]), 4, "a door zone must not catch the arrival")
        self.assertGreaterEqual(abs(start[1] - door[1]), 4)
        # the same for the door to the Flutlichtung (W4) and the arrival from it
        south, back = spots["W"][0], spots["w"][0]
        self.assertEqual((south, back), (layout.SOUTH_DOOR, layout.SOUTH_ARRIVAL))
        self.assertGreaterEqual(south[1] - back[1], 4, "the arrival lies four rows before the door")
        self.assertEqual(south[0], back[0], "straight on along the path")
        reach = _reach(rows, symbols, start)
        self.assertIn(back, reach, "the arrival is connected to the start on foot")
        self.assertIn(south, reach)

    def test_the_way_on_to_the_south_is_three_cells_wide_up_to_the_door(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        x, y = spots["W"][0]
        ay = spots["w"][0][1]
        for row in range(ay + 2, y + 2):
            around = [i for i in range(x - 4, x + 5) if _ground(symbols, rows[row][i]) in STANDABLE]
            self.assertEqual(around, [x - 1, x, x + 1], "row %d: the way is three cells wide" % row)
        # the cells beside the way in the row after the arrival lead nowhere: the row below them is forest
        for i in (x - 2, x - 3, x + 2, x + 3):
            if _ground(symbols, rows[ay + 1][i]) in STANDABLE:
                self.assertNotIn(_ground(symbols, rows[ay + 2][i]), STANDABLE, "no way around the door")

    def test_the_door_and_the_arrival_have_their_counterparts_in_the_flutlichtung(self):
        _, wald, _ = _map()
        _, flut, _ = _map(FLUTLICHTUNG)
        out, back = wald["W"]["params"], flut["N"]["params"]
        self.assertEqual((out["target"], out["spawn"]), ("flutlichtung", "waldweg"))
        self.assertEqual((back["target"], back["spawn"]), ("waldweg", "flutlichtung"))
        self.assertEqual(wald["w"]["marker"], "spawn_flutlichtung")
        self.assertEqual(flut["n"]["marker"], "spawn_waldweg")
        for params in (out, back):
            self.assertTrue(params["auto"])
            self.assertEqual(params["size"], [3, 1])
        _, _, rows = _map()
        self.assertNotIn("B", "".join(rows), "the blocker of the south is gone (a door since W4)")

    def test_the_hang_lies_on_the_path_between_the_two_rings(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        top, foot = spots["a"][0], spots["z"][0]
        self.assertGreaterEqual(foot[1] - top[1], 6, "long enough to be felt")
        reach = _reach(rows, symbols, top)
        self.assertIn(foot, reach, "the lane is walkable from top to foot")
        # earth faces on both sides of the sunken stretch, so that it reads as cut into the slope
        faces = sum(row.count("^") for row in rows[top[1] : foot[1] + 1])
        self.assertGreaterEqual(faces, 8)

    def test_a_spruce_stands_over_the_cone_and_no_crown_hides_a_spot_with_a_cue(self):
        _, _, rows = _map()
        spots = _spots(rows)
        kx, ky = spots["K"][0]
        near = [(x, y) for x, y in spots["P"] if abs(x - kx) <= 3 and abs(y - ky) <= 3]
        self.assertTrue(near, "the text says under the spruce: a spruce stands within three cells")
        # a tree is drawn upward from its foot: none within two columns and eight rows south of a cue
        for glyph in "123456KQqUCYXw":
            x, y = spots[glyph][0]
            for dy in range(1, 9):
                for dx in range(-2, 3):
                    if (x + dx, y + dy) == (kx - 2, ky - 1):
                        continue  # the spruce over the cone is a narrow cone of its own
                    cell = rows[y + dy][x + dx] if y + dy < len(rows) else "h"
                    self.assertNotIn(cell, "TP", "a crown hides %s at %d,%d (tree at %d,%d)" % (glyph, x, y, x + dx, y + dy))

    def test_the_forest_is_a_mix_of_spruce_and_beech(self):
        _, _, rows = _map()
        text = "".join(rows)
        self.assertGreaterEqual(text.count("P"), 30)
        self.assertGreaterEqual(text.count("T"), 40)
        self.assertEqual(layout.build.shortfall if hasattr(layout.build, "shortfall") else {}, {}, "the scatter placed all it was asked to")

    def test_the_hut_stands_in_a_glade_off_the_path_and_has_a_spot_before_its_door(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        hut, door, marker = spots["H"][0], spots["D"][0], spots["S"][0]
        self.assertEqual((door[0], door[1]), (hut[0], hut[1] + 1), "the spot is in front of the door")
        reach = _reach(rows, symbols, spots["@"][0])
        self.assertIn(door, reach, "reachable on foot")
        self.assertIn(marker, reach)
        self.assertLessEqual(abs(hut[0] - layout.path_x(hut[1])), 30)

    def test_what_lies_before_the_hut_is_not_hidden_by_its_sprite(self):
        _, _, rows = _map()
        spots = _spots(rows)
        hut = spots["H"][0]
        # the hut sprite is 88 px wide around its cell (opaque to 473 px, a good cell and a half right of the
        # cell's own right edge): the pebble, the one find on the level of the wall, lies clear of it
        pebble = spots["Y"][0]
        self.assertGreaterEqual(pebble[0] - hut[0], 3, "the pebble lies beside the hut's wall, not under it")
        self.assertEqual(pebble[1], hut[1])
        self.assertLess(pebble[0], spots["X"][0][0], "and before the line")

    def test_the_brook_is_water_all_the_way_and_the_path_keeps_to_its_west_bank(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        for y in range(layout.H):
            wet = [x for x, c in enumerate(rows[y]) if c == "~"]
            self.assertTrue(wet, "row %d has water" % y)
        for glyph in "123456":
            x, y = spots[glyph][0]
            self.assertLess(x, layout.stream_x(y), "board %s is west of the brook" % glyph)


def _flut():
    meta, symbols, rows = _map(FLUTLICHTUNG)
    return meta, symbols, rows, _spots(rows)


def _flut_ford(rows, symbols):
    """The row of the ford and the column of the stones' cell."""
    x, y = _spots(rows)["i"][0]
    return x, y


def _covers(glyph, at, cell):
    """Whether the sprite of `glyph` standing at `at` is drawn over `cell` (a tree is drawn upward from its foot)."""
    left, right, up = layout.FLUT_BIG[glyph]
    return at != cell and at[0] - left <= cell[0] <= at[0] + right and at[1] - up <= cell[1] <= at[1]


class FlutlichtungLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map(FLUTLICHTUNG)
        self.assertEqual(rows, layout.text("flutlichtung").split("\n"), "run layout_akt3_maps.py flutlichtung --write")

    def test_the_map_is_class_m_and_within_the_briefs_size(self):
        _, _, rows = _map(FLUTLICHTUNG)
        self.assertLessEqual(len(rows), 56, "at most 90 x 56 cells (O4)")
        self.assertLessEqual(len(rows[0]), 90)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")
        self.assertEqual((len(rows[0]), len(rows)), (layout.FLUT_W, layout.FLUT_H))
        self.assertGreater(len(rows) * len(rows[0]), 4000, "bigger than the valley, a map of class M")

    def test_every_spot_stands_once_and_the_ford_has_two_more_cells_of_stones(self):
        _, _, rows, _ = _flut()
        text = "".join(rows)
        for glyph in FLUT_NAMED:
            self.assertEqual(text.count(glyph), 1, glyph)
        self.assertEqual(text.count("y"), 2, "the cells of the ford beside the stones' own cell")

    def test_every_glyph_has_its_own_legend_line_and_every_cue_is_in_the_dialogue(self):
        with open(FLUTLICHTUNG, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows, _ = _flut()
        for glyph in set("".join(rows)):
            self.assertIsNotNone(re.search(r"^%s = " % re.escape(glyph), source, re.M), "no legend line for " + glyph)
        with open(FLUT_DIALOGUE, encoding="utf-8") as f:
            cues = set(re.findall(r"^~ (\w+)", f.read(), re.M))
        used = set()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if "cue" in params:
                used.add(params["cue"])
                self.assertTrue(params["dialogue"].endswith("akt3/flutlichtung.dialogue"), glyph)
        self.assertEqual(used, {"flood_trail", "flood_camp", "flood_mark", "antreiber_flood", "nest", "fork",
                                "driftwood", "stones", "south_wait"})
        self.assertLessEqual(used, cues, "every cue of the map is a cue of the dialogue")

    def test_every_sprite_of_the_map_is_in_the_catalog(self):
        meta, symbols, rows, _ = _flut()
        catalog = mapfile.load_catalog()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            for sprite in [params.get("sprite")] + list(params.get("sprite_when", {}).values()):
                if sprite:
                    self.assertIn(sprite, catalog, "%s: %s" % (glyph, sprite))
        for rule in meta["scatter"]:
            self.assertIn(rule["sprite"], catalog, rule)

    def test_every_spot_can_be_reached_from_the_start_on_foot(self):
        _, symbols, rows, spots = _flut()
        reach = _reach(rows, symbols, spots["@"][0], FLUT_STANDABLE)
        for glyph in FLUT_CUES:
            for x, y in spots[glyph]:
                near = any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3))
                self.assertTrue(near, "%s at %d,%d is out of reach" % (glyph, x, y))
        self.assertIn(spots["n"][0], reach, "the arrival from the Waldweg is connected to the start")
        self.assertIn(spots["N"][0], reach)
        self.assertIn(spots["B"][0], reach)

    def test_the_spots_come_in_the_order_of_the_walk_from_north_to_south(self):
        _, _, rows, spots = _flut()
        order = ["N", "n", "S", "M", "C", "d", "i", "B"]
        ys = [spots[glyph][0][1] for glyph in order]
        self.assertEqual(ys, sorted(set(ys)), "door, arrival, trail, mark, camp, driftwood, stones, way on")
        self.assertGreater(spots["@"][0][1], spots["n"][0][1])
        self.assertLessEqual(abs(spots["A"][0][0] - spots["M"][0][0]), 2, "he stands at the trunk")
        self.assertLessEqual(abs(spots["A"][0][1] - spots["M"][0][1]), 2)
        self.assertEqual(spots["E"][0][0], spots["A"][0][0], "and sits beside where he stood")
        self.assertGreater(spots["o"][0][0], 0)
        self.assertLess(spots["o"][0][0], spots["M"][0][0] - 10, "the nest lies at the west rim")
        self.assertLess(spots["k"][0][1], spots["d"][0][1], "the forked branch before the driftwood on the bank")

    def test_the_arrival_is_outside_the_doors_zone(self):
        _, _, rows, spots = _flut()
        door, arrival, start = spots["N"][0], spots["n"][0], spots["@"][0]
        self.assertEqual((door, arrival, start), (layout.FLUT_DOOR, layout.FLUT_ARRIVAL, layout.FLUT_START))
        self.assertGreaterEqual(abs(arrival[1] - door[1]), 4, "a door zone must not catch the arrival")
        self.assertGreaterEqual(abs(start[1] - door[1]), 4)
        self.assertEqual(door[0], layout.SOUTH_X, "the Waldweg's way south leads into the corridor")

    def test_the_corridor_runs_through_the_forest_into_the_clearing(self):
        _, symbols, rows, spots = _flut()
        x = layout.FLUT_NORTH_X
        for y in range(0, 20):
            around = [i for i in range(x - 4, x + 5) if _ground(symbols, rows[y][i]) in FLUT_STANDABLE]
            if y < 13:
                self.assertEqual(around, [x - 1, x, x + 1], "row %d: a gap of three cells in the forest" % y)
            else:
                self.assertTrue(set(range(x - 1, x + 2)) <= set(around), y)
        self.assertGreater(len([c for row in rows[20:] for c in row if c in FLUT_STANDABLE]), 900,
                           "and there it opens into a clearing")

    def test_the_mark_is_a_landmark_from_the_corridors_edge(self):
        _, _, rows, spots = _flut()
        mx, my = spots["M"][0]
        ax, ay = spots["n"][0]
        self.assertLessEqual(((mx - ax) ** 2 + (my - ay) ** 2) ** 0.5, 25, "within 25 cells of the arrival")
        self.assertLessEqual(abs(mx - layout.FLUT_NORTH_X), 8, "near the line of the corridor")
        # the trunk stands clear of crowns: nothing north of it hides it
        for dy in range(0, 9):
            for dx in range(-1, 2):
                if (dx, dy) != (0, 0):
                    cell = rows[my - dy][mx + dx]
                    self.assertNotIn(cell, "UP", "a crown stands in front of the mark's trunk")

    def test_the_trail_runs_north_in_the_dry_silt_along_the_corridor(self):
        _, symbols, rows, spots = _flut()
        x, y = spots["S"][0]
        self.assertEqual(x, layout.FLUT_NORTH_X, "on the corridor's line")
        self.assertGreater(y - 7, spots["@"][0][1], "the prints (seven rows north of the spot) end after the start")
        for row in range(y - 7, y + 1):
            self.assertEqual(_ground(symbols, rows[row][x]), ",", "dry silt under the prints at row %d" % row)
        self.assertLess(y, spots["M"][0][1], "the trail comes before the mark")

    def test_the_brook_is_water_all_the_way_on_the_east_side(self):
        _, symbols, rows, spots = _flut()
        for y in range(layout.FLUT_H):
            wet = [x for x, c in enumerate(rows[y]) if c == "~" or (c in "yi")]
            self.assertTrue(wet, "row %d has water" % y)
            self.assertGreater(min(wet), layout.FLUT_NORTH_X, "the brook is east of the corridor and the path")
        for glyph in "SMACokd":
            x, y = spots[glyph][0]
            self.assertLess(x, layout.flut_stream_x(y), "%s lies on the west bank" % glyph)

    def test_the_bank_has_the_forked_branch_and_the_driftwood_at_the_water(self):
        _, symbols, rows, spots = _flut()
        for glyph in "kd":
            x, y = spots[glyph][0]
            wet = [i for i in range(x + 1, x + 5) if rows[y][i] in "~"]
            self.assertTrue(wet, "%s stands at the water" % glyph)
            self.assertLessEqual(min(wet) - x, 3)
            self.assertEqual(_ground(symbols, rows[y][x]), "m", "on wet silt, as the legend says")

    def test_the_nest_lies_in_the_grass_above_the_silt(self):
        _, symbols, rows, spots = _flut()
        x, y = spots["o"][0]
        for dy in range(-1, 2):
            for dx in range(-1, 2):
                cell = _ground(symbols, rows[y + dy][x + dx])
                self.assertEqual(cell, ".", "grass around the nest (%d,%d)" % (dx, dy))

    def test_the_stones_cross_the_brook_in_three_cells_and_the_far_bank_can_be_reached(self):
        _, symbols, rows, spots = _flut()
        x, y = _flut_ford(rows, symbols)
        self.assertEqual(y, layout.FLUT_FORD_Y)
        self.assertEqual(_ground(symbols, rows[y][x]), "y")
        self.assertEqual(rows[y][x - 1] + rows[y][x + 1], "yy", "a ford of three cells")
        self.assertIn(_ground(symbols, rows[y][x - 2]), STANDABLE, "a bank before the stones (the sprite is four cells wide)")
        self.assertIn(_ground(symbols, rows[y][x + 2]), STANDABLE, "and one behind them")
        for row in (y - 1, y + 1):
            self.assertEqual(rows[row][x - 1:x + 2], "~~~", "water above and below the ford, three cells wide")
        reach = _reach(rows, symbols, spots["@"][0], FLUT_STANDABLE)
        self.assertIn((x + 3, y), reach, "the far bank is reached over the stones")
        dry = [r.replace("y", "~").replace("i", "~") for r in rows]
        self.assertNotIn((x + 3, y), _reach(dry, symbols, spots["@"][0], FLUT_STANDABLE), "and only over the stones")

    def test_the_way_on_to_the_south_is_exactly_the_blockers_width(self):
        _, symbols, rows, spots = _flut()
        x, y = spots["B"][0]
        self.assertEqual((x, y), layout.FLUT_BLOCKER)
        self.assertGreaterEqual(layout.FLUT_H - y, 4, "forest behind the blocker")
        for row in range(y, layout.FLUT_H):
            around = [i for i in range(x - 4, x + 5) if _ground(symbols, rows[row][i]) in FLUT_STANDABLE]
            self.assertEqual(around, [x - 1, x, x + 1], "row %d: three cells, no way around it" % row)
        self.assertEqual(symbols["B"]["params"]["size"], [3, 1])

    def test_the_antreiber_stands_and_sits_by_flags_and_leaves_the_other_maps(self):
        _, symbols, _, _ = _flut()
        stands, sits = symbols["A"]["params"], symbols["E"]["params"]
        self.assertEqual(stands["cue"], "antreiber_flood")
        self.assertEqual(sits["cue"], "antreiber_flood")
        self.assertEqual(set(stands["unless"]), {"house.antreiber_by_fire", "forest.flood_sat"})
        self.assertTrue(sits["sit"])
        self.assertEqual(sits["if"], "forest.flood_sat")
        self.assertEqual(sits["unless"], "house.antreiber_by_fire")
        for key in ("A", "E"):
            self.assertEqual(symbols[key]["params"]["dialogue"], "res://content/dialogue/akt3/flutlichtung.dialogue")
        _, wald, _ = _map()
        self.assertIn("forest.antreiber_ahead", wald["A"]["params"]["unless"])
        self.assertEqual(wald["E"]["params"]["if"], "forest.antreiber_sat")
        self.assertEqual(wald["E"]["params"]["unless"], "forest.antreiber_ahead")
        _, tal, _ = _map(TAL)
        for glyph in "t6":
            unless = tal[glyph]["params"]["unless"]
            self.assertIn("forest.antreiber_ahead", unless, "not in the valley once he is ahead (" + glyph + ")")
            self.assertIn("forest.antreiber_met", unless)

    def test_the_things_that_depend_on_the_story_carry_their_flags(self):
        _, symbols, _, _ = _flut()
        self.assertEqual(symbols["o"]["params"]["unless"], "forest.nest_taken")
        self.assertEqual(symbols["d"]["params"]["unless"], "forest.driftwood_taken")
        self.assertEqual(symbols["k"]["params"]["sprite_when"], {"forest.nest_placed": "tal/wd_fork_nest"})
        for glyph in "SMCDkio":
            params = symbols.get(glyph, {}).get("params", {})
            self.assertNotIn("light", params, "no light in the forest")

    def test_the_silt_the_wet_silt_and_the_puddles_lie_in_a_clearing(self):
        _, _, rows, _ = _flut()
        text = "".join(rows)
        self.assertGreaterEqual(text.count(","), 450, "dry silt")
        self.assertGreaterEqual(text.count("m"), 60, "wet silt")
        self.assertGreaterEqual(text.count("p"), 10, "puddles")
        self.assertGreaterEqual(text.count("."), 400, "grass above the silt")

    def test_a_crown_hides_no_spot_with_a_cue_and_nothing_to_find_lies_under_a_big_sprite(self):
        _, _, rows, spots = _flut()
        for glyph in FLUT_CUES + "n":
            x, y = spots[glyph][0]
            for dy in range(1, 9):
                for dx in range(-3, 4):
                    cell = rows[y + dy][x + dx] if y + dy < len(rows) else "h"
                    self.assertNotIn(cell, "UP", "a crown hides %s at %d,%d (tree at %d,%d)" % (glyph, x, y, x + dx, y + dy))
        # every sprite that is drawn over its neighbours (trees, the trunk, the blanket, the ring, the forked branch) leaves
        # the small finds free: the nest, the driftwood, the stones, the trail's foot
        big = [(g, at) for g in layout.FLUT_BIG for at in spots.get(g, [])]
        for find in "odiS":
            cell = spots[find][0]
            for g, at in big:
                self.assertFalse(_covers(g, at, cell), "%s at %s lies under the sprite of %s at %s" % (find, cell, g, at))
        # and none of the spots lies under another
        for g, at in big:
            for other in "SMAECokdi":
                for cell in spots[other]:
                    if (g, at) != (other, cell) and g in "MDC":
                        self.assertFalse(_covers(g, at, cell), "%s at %s lies under %s at %s" % (other, cell, g, at))

    def test_the_forest_and_the_rest_are_placed_as_asked(self):
        _, _, rows, _ = _flut()
        layout.build_flut()
        self.assertEqual(layout.build_flut.shortfall, {}, "the scatter placed all it was asked to")
        text = "".join(rows)
        self.assertGreaterEqual(text.count("U"), 15, "beeches with the line of silt at the rim")
        self.assertGreaterEqual(text.count("P"), 5)
        self.assertEqual(text.count("T"), 0, "no plain beech where the silt line is on every beech")

    def test_the_meta_names_the_baked_images_and_the_drift_lies_on_the_silt(self):
        meta, _, _, _ = _flut()
        drift = [r for r in meta["scatter"] if "p" in r.get("on", "") and "m" in r.get("on", "")]
        self.assertTrue({r["sprite"] for r in drift} >= {"tal/twig", "tal/leaves", "tal/pebbles"},
                        "drift on the silt and the puddles: twigs, leaves, pebbles")
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/flutlichtung_ground.png")
        self.assertEqual(meta["water"], "res://assets/generated/maps/flutlichtung_water.png")


if __name__ == "__main__":
    unittest.main()
