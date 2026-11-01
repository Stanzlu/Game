"""Tests of the Act IV map generator (standard library only): python3 -m unittest discover -s tools/art."""
import os
import re
import unittest
from collections import deque

import layout_akt4_maps as layout
import mapfile

STRASSE = os.path.join(mapfile.ROOT, "content", "maps", "strasse.txt")
TAL = os.path.join(mapfile.ROOT, "content", "maps", "tal.txt")
DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt4", "strasse.dialogue")
DIALOGUE_RES = "res://content/dialogue/akt4/strasse.dialogue"
# ground cells a person can stand on (the legend's own grounds: grass, path, mud, puddle, tilled soil, cobbles)
STANDABLE = set(".,mpd_")
# the road itself: path, mud of the ruts, puddles, cobbles
ROAD = set(",mp_")
# spots of the walk, each once on the map (the rest of the letters are scattered forest, fences and hay)
NAMED = "Nn@BZsV1234S5 67b".replace(" ", "")
# the spots with a cue (the cue's name by glyph)
CUES = {"1": "signpost", "2": "goat_prints", "3": "field_notice", "4": "scarecrow", "5": "milestone", "6": "goat_bell",
        "7": "view_town", "B": "town_wait"}
# what may stand on the road's cells (a prop with a collision shape anywhere else would narrow the way)
ON_ROAD = ROAD | set("Nn@sBZXVqQ2x")


def _map(path=STRASSE):
    return mapfile.parse_map(path)


def _ground(symbols, glyph):
    return symbols[glyph].get("ground", glyph)


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


def _strasse():
    meta, symbols, rows = _map()
    return meta, symbols, rows, _spots(rows)


class StrasseLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map()
        self.assertEqual(rows, layout.text().split("\n"), "run layout_akt4_maps.py strasse --write")

    def test_the_map_is_class_m_and_within_the_briefs_size(self):
        _, _, rows = _map()
        self.assertLessEqual(len(rows), 60, "at most 100 x 60 cells (the brief, S1)")
        self.assertLessEqual(len(rows[0]), 100)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")
        self.assertEqual((len(rows[0]), len(rows)), (layout.W, layout.H))
        self.assertGreater(len(rows) * len(rows[0]), 4000, "bigger than the valley, a map of class M")

    def test_every_named_spot_stands_once_and_the_rope_has_two_posts(self):
        _, _, rows, spots = _strasse()
        text = "".join(rows)
        for glyph in NAMED:
            self.assertEqual(text.count(glyph), 1, glyph)
        self.assertEqual(text.count("X"), 2, "a post at each end of the rope")
        self.assertEqual(text.count("q"), text.count("Q"), "a parapet on each side of the bridge")
        self.assertGreaterEqual(text.count("x") + text.count("a"), 5, "the goat's way has more prints than the one with a cue")
        layout.build()
        self.assertEqual(layout.build.shortfall, {}, "the scatter placed all it was asked to")

    def test_the_spots_come_in_the_order_of_the_walk_from_east_to_west(self):
        _, _, _, spots = _strasse()
        order = ["N", "n", "@", "1", "2", "6", "5", "b", "B"]
        xs = [spots[glyph][0][0] for glyph in order]
        self.assertEqual(xs, sorted(xs, reverse=True), "door, arrival, start, sign, prints, bell, milestone, bench, rope")
        self.assertGreater(spots["n"][0][0], spots["@"][0][0], "the arrival is the one nearer to the door")
        self.assertLess(spots["B"][0][0], spots["s"][0][0], "the arrival from the town lies before the blocker")
        milestone = spots["5"][0][0]
        self.assertTrue(40 <= milestone <= 56, "the milestone stands about the middle of the road (x %d)" % milestone)
        self.assertGreater(spots["6"][0][0], milestone, "the bell is met before the stone")

    def test_every_glyph_has_its_own_legend_line_and_every_cue_is_the_contracts(self):
        with open(STRASSE, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows, spots = _strasse()
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

    def test_every_sprite_of_the_map_is_in_the_catalog_and_none_has_a_light(self):
        meta, symbols, rows, _ = _strasse()
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
            self.assertNotIn("lights", catalog[sprite], "no PointLight2D on the road: " + sprite)
        for sprite in ("tal/st_roofs_a", "tal/st_roofs_b", "tal/st_roofs_c"):
            self.assertIn("smoke", catalog[sprite], "the smoke of the town's chimneys")

    def test_every_spot_can_be_reached_from_the_start_on_foot(self):
        _, symbols, rows, spots = _strasse()
        reach = _reach(rows, symbols, spots["@"][0])
        for glyph in CUES:
            for x, y in spots[glyph]:
                near = any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3))
                self.assertTrue(near, "%s at %d,%d is out of reach" % (glyph, x, y))
        for glyph in "nNsBZ":
            self.assertIn(spots[glyph][0], reach, glyph)

    def test_the_way_from_east_to_west_is_one_road_and_only_the_deck_crosses_the_brook(self):
        _, symbols, rows, spots = _strasse()
        road = _reach(rows, symbols, spots["@"][0], ROAD)
        for glyph in "nNsBZ":
            self.assertIn(spots[glyph][0], road, "%s lies on the road" % glyph)
        columns = {}
        for x, y in road:
            columns.setdefault(x, []).append(y)
        for x in range(0, layout.W):
            self.assertGreaterEqual(len(columns.get(x, [])), 3, "the road is at least three cells wide at column %d" % x)
        dry = [r.replace("_", "~") for r in rows]
        self.assertNotIn(spots["B"][0], _reach(dry, symbols, spots["@"][0], STANDABLE - {"_"}),
                         "the brook runs through the whole map; the deck is the only way across")
        yc = layout.road_row(59)
        for y in range(layout.H):
            if not yc - 1 <= y <= yc + 1:  # the deck's three rows are the brook's only gap
                self.assertIn("~", rows[y], "row %d has water" % y)

    def test_nothing_with_a_collision_stands_on_the_road_but_what_belongs_there(self):
        _, symbols, rows, _ = _strasse()
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                if layout.road_distance(x, y) < layout.ROAD_W / 2 and 9 <= x <= layout.W - 8 and glyph != "~":
                    self.assertIn(glyph, ON_ROAD, "%s stands on the road at %d,%d" % (glyph, x, y))

    def test_the_arrivals_are_outside_the_doors_zones_and_on_the_road(self):
        _, symbols, rows, spots = _strasse()
        door, arrival, start = spots["N"][0], spots["n"][0], spots["@"][0]
        blocker, city = spots["B"][0], spots["s"][0]
        self.assertEqual(door, (layout.DOOR_X, layout.road_row(layout.DOOR_X)))
        self.assertGreaterEqual(abs(arrival[0] - door[0]), 4, "a door zone must not catch the arrival")
        self.assertGreaterEqual(abs(start[0] - door[0]), 4)
        self.assertGreaterEqual(abs(city[0] - blocker[0]), 4, "nor the zone the door to the town will have (S2)")
        for glyph in "nNs@":
            self.assertIn(_ground(symbols, glyph), ROAD, glyph)
        self.assertEqual(symbols["n"]["marker"], "spawn_tal")
        self.assertEqual(symbols["s"]["marker"], "spawn_stadt")
        self.assertEqual(symbols["@"]["marker"], "player_spawn")

    def test_the_door_and_the_blocker_cover_the_whole_width_of_the_road_in_their_columns(self):
        _, symbols, rows, spots = _strasse()
        for glyph in "NB":
            x, y = spots[glyph][0]
            around = [j for j in range(0, layout.H) if _ground(symbols, rows[j][x]) in STANDABLE or rows[j][x] in "ZXVqQ"]
            self.assertEqual(around, list(range(y - 2, y + 3)), "%s: five cells of road, forest above and below" % glyph)
            size = symbols[glyph]["params"]["size"]
            self.assertEqual(size[0], 1)
            self.assertGreaterEqual(size[1], 5, "%s spans the road" % glyph)
            self.assertEqual(size[1] % 2, 1, "centred on the road's middle row")
        door = symbols["N"]["params"]
        self.assertEqual((door["target"], door["spawn"]), ("tal", "strasse"))
        self.assertTrue(door["auto"])
        blocker = symbols["B"]["params"]
        self.assertEqual(blocker["cue"], "town_wait")
        self.assertNotIn("if", blocker)
        self.assertNotIn("unless", blocker, "a blocker that waits for S2, nothing else opens it")
        x, y = spots["B"][0]
        self.assertGreaterEqual(layout.W - 1 - x, 4)
        self.assertEqual({x for x, _ in spots["X"] + spots["Z"]}, {layout.ROPE_X}, "the rope hangs one cell east of the blocker")
        self.assertEqual(layout.ROPE_X, x + 1)

    def test_the_bridge_is_a_deck_of_three_rows_with_a_parapet_on_each_side(self):
        _, symbols, rows, spots = _strasse()
        yc = layout.road_row(59)
        b0, b1 = layout.bridge_columns()
        for x in range(b0, b1 + 1):
            self.assertEqual([rows[y][x] for y in range(yc - 1, yc + 2)], ["q", "_", "Q"], "column %d" % x)
        self.assertGreaterEqual(b1 - b0 + 1, 3)
        self.assertLessEqual(b1 - b0 + 1, 6, "a small bridge")
        for row in (yc - 2, yc + 2):
            wet = [x for x in range(b0, b1 + 1) if rows[row][x] == "~"]
            self.assertGreaterEqual(len(wet), 3, "water beside the deck in row %d, where the brook runs" % row)
        self.assertEqual(symbols["q"]["params"]["sprite"], "tal/st_parapet_n")
        self.assertEqual(symbols["Q"]["params"]["sprite"], "tal/st_parapet_s")
        self.assertEqual({_ground(symbols, g) for g in "qQ"}, {"_"})

    def test_ruts_and_puddles_run_along_the_road(self):
        _, _, rows, _ = _strasse()
        text = "".join(rows)
        self.assertGreaterEqual(text.count("m"), 90, "ruts of mud")
        self.assertGreaterEqual(text.count("p"), 12, "puddles in them and at the road's edge")
        self.assertGreaterEqual(text.count("d"), 100, "tilled soil in the fields")
        self.assertGreaterEqual(text.count("O"), 8, "an orchard")
        self.assertGreaterEqual(text.count("F") + text.count("E"), 100, "fences round the field, the pasture, the orchard")
        self.assertGreaterEqual(text.count("H"), 4, "hay")

    def test_no_crown_hides_a_spot_with_a_cue_and_none_stands_over_the_road(self):
        _, _, rows, spots = _strasse()
        # a tree is drawn upward from its foot: the oak (88 x 104 px) reaches three cells to each side and eight rows up, the
        # crooked one a little wider, the pine and the apple tree (40 and 56 px wide) two cells to each side and five up
        reach = {"T": (3, 8), "C": (3, 8), "P": (2, 5), "O": (2, 5)}
        for glyph in list(CUES) + list("nsxa@"):
            for x, y in spots[glyph]:
                for dy in range(1, 9):
                    for dx in range(-3, 4):
                        inside = y + dy < len(rows) and 0 <= x + dx < len(rows[0])
                        cell = rows[y + dy][x + dx] if inside else "h"
                        if cell in reach:
                            wide, high = reach[cell]
                            self.assertFalse(abs(dx) <= wide and dy <= high,
                                             "a crown hides %s at %d,%d (tree at %d,%d)" % (glyph, x, y, x + dx, y + dy))
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                if glyph in ",mp_" and x > 3:
                    for dy in range(1, 7):
                        for dx in (-1, 0, 1):
                            inside = y + dy < len(rows) and 0 <= x + dx < len(row)
                            cell = rows[y + dy][x + dx] if inside else "h"
                            if cell in "TCP" or (cell == "O" and dy <= 5):
                                self.fail("a crown over the road at %d,%d (tree at %d,%d)" % (x, y, x + dx, y + dy))

    def test_the_goats_bell_hangs_on_the_post_of_the_pasture_and_goes_with_the_flag(self):
        _, symbols, rows, spots = _strasse()
        post, bell = spots["S"][0], spots["6"][0]
        self.assertEqual(bell, (post[0], post[1] + 1), "the bell's cell lies below the post's: the sprite is lifted onto the nail")
        catalog = mapfile.load_catalog()
        self.assertEqual(catalog["tal/st_bell"]["anchor"], [1, 18 + 16], "the cord's top meets the nail (3 px east, 18 up)")
        self.assertEqual(symbols["6"]["params"]["unless"], "city.bell_taken", "the bell and its line are gone once it is taken")
        self.assertNotIn("shadow", catalog["tal/st_bell"], "no baked shadow under what the story takes away")
        self.assertNotIn("shadow", catalog["tal/st_post"])
        fence = [(x, y) for x, y in spots["E"] if abs(x - post[0]) <= 1 and abs(y - post[1]) <= 1]
        self.assertTrue(fence, "the post stands at a corner of the fence")
        reach = _reach(rows, symbols, spots["@"][0])
        self.assertTrue(any((bell[0] + dx, bell[1] + 1) in reach for dx in (-1, 0, 1)), "one steps up to it from the road side")

    def test_no_placement_changes_the_ground_it_stands_on(self):
        _, symbols, rows, _ = _strasse()
        land = layout.land()
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                self.assertEqual(_ground(symbols, glyph), land.get(x, y), "%s at %d,%d paints other ground than the layout drew" % (glyph, x, y))

    def test_the_things_are_spread_out_not_in_a_row(self):
        _, _, rows, spots = _strasse()
        ys = [spots[g][0][1] for g in "123456"]
        self.assertGreaterEqual(max(ys) - min(ys), 10, "north and south of the road, near and far")
        xs = sorted(spots[g][0][0] for g in "123456")
        gaps = [b - a for a, b in zip(xs, xs[1:])]
        self.assertLessEqual(max(gaps), 24, "something to find every few steps")

    def test_the_hill_has_a_ramp_a_bench_a_view_and_the_towns_roofs_behind_a_hedge(self):
        _, symbols, rows, spots = _strasse()
        reach = _reach(rows, symbols, spots["@"][0])
        bx, by = spots["b"][0]
        vx, vy = spots["7"][0]
        self.assertIn((vx, vy), reach, "the view is on foot")
        self.assertLess(vy, spots["B"][0][1], "up on the hill, above the road")
        self.assertLess(vx - bx, 6)
        # the earth step between road and terrace has a gap of three cells (the ramp), so the hill is climbed, not walked onto
        step_rows = [y for y, row in enumerate(rows) if "^" in row and 25 < y < 30]
        self.assertTrue(step_rows)
        for y in step_rows:
            ramp = [x for x in range(layout.HILL_X[0], layout.HILL_X[1] + 1) if rows[y][x] != "^"]
            self.assertTrue(set(range(layout.RAMP_X - 1, layout.RAMP_X + 2)) <= set(ramp), "the ramp in row %d" % y)
        # the roofs stand in a pocket of meadow that nobody can walk to: the hedge band along the crest is closed
        roofs = [pos for g in "JLM" for pos in spots[g]]
        self.assertGreaterEqual(len(roofs), 4, "many chimneys")
        for x, y in roofs:
            self.assertNotIn((x, y), reach, "the roofs lie behind the hedge")
            self.assertLess(y, by - 2)
            self.assertLessEqual(by - y, 9, "within the picture from the bench (nine rows)")
        self.assertEqual({symbols[g]["params"]["sprite"] for g in "JLM"}, {"tal/st_roofs_a", "tal/st_roofs_b", "tal/st_roofs_c"})

    def test_the_roadworks_at_the_west_end_are_a_rope_two_posts_cobbles_and_a_heap_of_stones(self):
        _, symbols, rows, spots = _strasse()
        bx, by = spots["B"][0]
        self.assertEqual(spots["Z"][0], (layout.ROPE_X, by))
        self.assertEqual(sorted(spots["X"]), [(layout.ROPE_X, by - 2), (layout.ROPE_X, by + 2)])
        self.assertEqual(symbols["Z"]["params"]["sprite"], "tal/st_rope")
        self.assertEqual(spots["V"][0][1], by - 2, "the heap stands at the road's edge")
        for y in range(by - 2, by + 3):
            self.assertEqual(rows[y][0], "_", "paving beyond the rope")
        catalog = mapfile.load_catalog()
        self.assertTrue(catalog["tal/st_rope"].get("flat"))

    def test_the_meta_names_the_baked_images(self):
        meta, _, _, _ = _strasse()
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/strasse_ground.png")
        self.assertEqual(meta["water"], "res://assets/generated/maps/strasse_water.png")
        for key in ("ground", "water"):
            self.assertTrue(os.path.exists(mapfile.res_path(meta[key])), meta[key])
        self.assertNotIn("treeline", meta)

    def test_what_the_story_takes_or_adds_casts_no_baked_shadow(self):
        _, symbols, rows, _ = _strasse()
        catalog = mapfile.load_catalog()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            sprites = [params.get("sprite")] + list(params.get("sprite_when", {}).values())
            if "if" in params or "unless" in params or "sprite_when" in params:
                for sprite in sprites:
                    if sprite:
                        self.assertNotIn("shadow", catalog[sprite], "%s of %s would stay under nothing" % (sprite, glyph))


class ValleyCounterpartTests(unittest.TestCase):
    """The valley's side of the road: the door, the arrival and the signpost (all after the end of Act III)."""

    def test_the_door_the_arrival_and_the_signpost_stand_where_the_contract_says(self):
        _, tal, rows = _map(TAL)
        spots = _spots(rows)
        self.assertEqual(spots["<"], [(4, 25)])
        self.assertEqual(spots["%"], [(6, 25)])
        self.assertEqual(spots["$"], [(8, 23)])
        door = tal["<"]["params"]
        self.assertEqual((door["target"], door["spawn"]), ("strasse", "tal"))
        self.assertTrue(door["auto"])
        self.assertEqual(door["size"], [1, 9])
        self.assertEqual(door["if"], "chapter.act3")
        self.assertEqual(tal["%"]["marker"], "spawn_strasse")
        sign = tal["$"]["params"]
        self.assertEqual((sign["sprite"], sign["cue"], sign["dialogue"]), ("tal/st_sign", "signpost_tal", DIALOGUE_RES))
        self.assertEqual(sign["if"], "chapter.act3")
        # every cell keeps the ground it had, so that the baked valley (its stamp) does not change
        self.assertEqual(_ground(tal, "<"), ",")
        self.assertEqual(_ground(tal, "%"), ",")
        self.assertEqual(_ground(tal, "$"), ".")
        self.assertNotIn("shadow", mapfile.load_catalog()["tal/st_sign"])

    def test_the_valleys_arrival_is_no_door_zone_and_the_two_maps_name_each_other(self):
        _, tal, rows = _map(TAL)
        _, strasse, _ = _map(STRASSE)
        spots = _spots(rows)
        door, arrival = spots["<"][0], spots["%"][0]
        zone = 0.5  # the door's zone is one cell wide: its half width plus the player's body must not reach the arrival
        self.assertGreaterEqual((arrival[0] - door[0]) - zone, 1.5, "the arrival lies two cells from the door's cell")
        self.assertEqual(strasse["N"]["params"]["spawn"], "strasse")
        self.assertEqual(tal["<"]["params"]["spawn"], "tal")
        self.assertEqual(strasse["n"]["marker"], "spawn_" + tal["<"]["params"]["spawn"])
        self.assertEqual(tal["%"]["marker"], "spawn_" + strasse["N"]["params"]["spawn"])


if __name__ == "__main__":
    unittest.main()
