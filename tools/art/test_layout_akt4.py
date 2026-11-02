"""Tests of the Act IV map generator (standard library only): python3 -m unittest discover -s tools/art."""
import importlib.util
import math
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
NAMED = "Nn@WsV1234S5 67b".replace(" ", "")
# the spots with a cue (the cue's name by glyph)
CUES = {"1": "signpost", "2": "goat_prints", "3": "field_notice", "4": "scarecrow", "5": "milestone", "6": "goat_bell",
        "7": "view_town"}
# what may stand on the road's cells (a prop with a collision shape anywhere else would narrow the way)
ON_ROAD = ROAD | set("Nn@sWVqQ2x")


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

    def test_every_named_spot_stands_once_and_the_rope_is_gone(self):
        _, _, rows, spots = _strasse()
        text = "".join(rows)
        for glyph in NAMED:
            self.assertEqual(text.count(glyph), 1, glyph)
        for glyph in "BZX":
            self.assertEqual(text.count(glyph), 0, "the rope, its posts and the blocker of S1 are gone: " + glyph)
        self.assertEqual(text.count("q"), text.count("Q"), "a parapet on each side of the bridge")
        self.assertGreaterEqual(text.count("x") + text.count("a"), 5, "the goat's way has more prints than the one with a cue")
        layout.build()
        self.assertEqual(layout.build.shortfall, {}, "the scatter placed all it was asked to")

    def test_the_spots_come_in_the_order_of_the_walk_from_east_to_west(self):
        _, _, _, spots = _strasse()
        # the start lies mid-road east of the bridge, since the benchmark walks right first and a start near
        # the door would take it back into the valley
        order = ["N", "n", "1", "2", "@", "6", "5", "b", "W"]
        xs = [spots[glyph][0][0] for glyph in order]
        self.assertEqual(xs, sorted(xs, reverse=True), "door, arrival, sign, prints, start, bell, milestone, bench, the door to the town")
        self.assertGreater(spots["N"][0][0] - spots["@"][0][0], 20, "the start is far from the door")
        self.assertGreater(spots["n"][0][0], spots["@"][0][0], "the arrival is the one nearer to the door")
        self.assertLess(spots["W"][0][0], spots["s"][0][0], "the arrival from the town lies before the door")
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
        for glyph in "nNsW":
            self.assertIn(spots[glyph][0], reach, glyph)

    def test_the_way_from_east_to_west_is_one_road_and_only_the_deck_crosses_the_brook(self):
        _, symbols, rows, spots = _strasse()
        road = _reach(rows, symbols, spots["@"][0], ROAD)
        for glyph in "nNsW":
            self.assertIn(spots[glyph][0], road, "%s lies on the road" % glyph)
        columns = {}
        for x, y in road:
            columns.setdefault(x, []).append(y)
        for x in range(0, layout.W):
            self.assertGreaterEqual(len(columns.get(x, [])), 3, "the road is at least three cells wide at column %d" % x)
        dry = [r.replace("_", "~") for r in rows]
        self.assertNotIn(spots["W"][0], _reach(dry, symbols, spots["@"][0], STANDABLE - {"_"}),
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
        blocker, city = spots["W"][0], spots["s"][0]
        self.assertEqual(door, (layout.DOOR_X, layout.road_row(layout.DOOR_X)))
        self.assertGreaterEqual(abs(arrival[0] - door[0]), 4, "a door zone must not catch the arrival")
        self.assertGreaterEqual(abs(start[0] - door[0]), 4)
        self.assertGreaterEqual(abs(city[0] - blocker[0]), 4, "nor the zone of the door to the town")
        for glyph in "nNs@":
            self.assertIn(_ground(symbols, glyph), ROAD, glyph)
        self.assertEqual(symbols["n"]["marker"], "spawn_tal")
        self.assertEqual(symbols["s"]["marker"], "spawn_stadt")
        self.assertEqual(symbols["@"]["marker"], "player_spawn")

    def test_the_doors_cover_the_whole_width_of_the_road_in_their_columns(self):
        _, symbols, rows, spots = _strasse()
        for glyph in "NW":
            x, y = spots[glyph][0]
            around = [j for j in range(0, layout.H) if _ground(symbols, rows[j][x]) in STANDABLE or rows[j][x] in "qQ"]
            self.assertEqual(around, list(range(y - 2, y + 3)), "%s: five cells of road, forest above and below" % glyph)
            size = symbols[glyph]["params"]["size"]
            self.assertEqual(size[0], 1)
            self.assertGreaterEqual(size[1], 5, "%s spans the road" % glyph)
            self.assertEqual(size[1] % 2, 1, "centred on the road's middle row")
            self.assertTrue(symbols[glyph]["params"]["auto"])
        door = symbols["N"]["params"]
        self.assertEqual((door["target"], door["spawn"]), ("tal", "strasse"))
        town = symbols["W"]["params"]
        self.assertEqual((town["target"], town["spawn"]), ("stadt", "strasse"), "the door's spawn names the scene it comes from")
        self.assertNotIn("if", town)
        self.assertNotIn("unless", town)
        x, y = spots["W"][0]
        self.assertGreaterEqual(layout.W - 1 - x, 4)
        self.assertEqual(x, layout.WEST_GAP)

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
        self.assertLess(vy, spots["W"][0][1], "up on the hill, above the road")
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

    def test_the_way_ends_in_the_door_to_the_town_with_paving_beyond_it(self):
        _, symbols, rows, spots = _strasse()
        bx, by = spots["W"][0]
        text = "".join(rows)
        for glyph in "ZXB":
            self.assertEqual(text.count(glyph), 0)
        self.assertEqual(spots["V"][0][1], by - 2, "the heap of cobbles still lies at the road's edge (its baked shadow is part of the ground's stamp)")
        for y in range(by - 2, by + 3):
            self.assertEqual(rows[y][0], "_", "paving beyond the door")
        self.assertEqual(spots["s"][0], (layout.CITY_X, layout.road_row(layout.CITY_X)))
        self.assertGreaterEqual(spots["s"][0][0] - bx, 7, "the arrival from the town lies seven cells before the door")

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


STADT = os.path.join(mapfile.ROOT, "content", "maps", "stadt.txt")
STADT_DIALOGUE = os.path.join(mapfile.ROOT, "content", "dialogue", "akt4", "stadt.dialogue")
STADT_DIALOGUE_RES = "res://content/dialogue/akt4/stadt.dialogue"
# the cues of the town by glyph (the contract of S2)
STADT_CUES = {"Z": "list_board", "y": "gef_square", "I": "gate", "M": "mira_square", "v": "citizen_1", "L": "lio_street",
              "Q": "fountain_rim", "%": "florist_wait", "&": "workshop_wait", "1": "day_wreath", "2": "day_lectern",
              "3": "day_table", "J": "goat_roof"}
STADT_SHEETS = {"I": "torwaechterin", "M": "mira", "y": "gefaelliger", "v": "buerger", "L": "lio"}
# what is there once and only once
STADT_ONCE = "@niN$!D" + "GUROQZIMyvLJ123%&FKOS" + "s"
FACADE_GLYPHS = "RFKabcdefjuwzGUt"
TREES = {"T": (3, 7), "C": (3, 7), "P": (2, 5)}


def _stadt():
    meta, symbols, rows = _map(STADT)
    return meta, symbols, rows, _spots(rows)


def _png_size(path):
    import struct
    with open(path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])


def _opaque_blocks(path):
    """The sprite's opaque pixels as a set of (x, y) (needs Pillow, which every art tool has)."""
    from PIL import Image
    im = Image.open(path).convert("RGBA")
    px = im.load()
    return {(x, y) for y in range(im.height) for x in range(im.width) if px[x, y][3] > 0}


class StadtLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map(STADT)
        self.assertEqual(rows, layout.text("stadt").split("\n"), "run layout_akt4_maps.py stadt --write")

    def test_the_map_is_class_m_and_within_the_briefs_size(self):
        _, _, rows = _map(STADT)
        self.assertLessEqual(len(rows), 64, "at most 112 x 64 cells (the contract, S2)")
        self.assertLessEqual(len(rows[0]), 112)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")
        self.assertEqual((len(rows[0]), len(rows)), (layout.SW, layout.SH))
        self.assertGreater(len(rows) * len(rows[0]), 4000, "bigger than the valley, a map of class M")
        layout.build_stadt()
        self.assertEqual(layout.build_stadt.shortfall, {}, "the scatter placed all it was asked to")
        meta, _, _, _ = _stadt()
        self.assertEqual(meta["style"], "tal")
        self.assertEqual(meta["ground"], "res://assets/generated/maps/stadt_ground.png")
        self.assertNotIn("water", meta, "no water in the town")
        self.assertTrue(os.path.exists(mapfile.res_path(meta["ground"])))
        self.assertNotIn("treeline", meta)

    def test_every_glyph_has_its_legend_line_and_no_placement_changes_the_ground(self):
        with open(STADT, encoding="utf-8") as f:
            source = f.read()
        _, symbols, rows, _ = _stadt()
        land = layout.stadt_land()
        for glyph in set("".join(rows)):
            self.assertIsNotNone(re.search(r"^%s = " % re.escape(glyph), source, re.M), "no legend line for " + glyph)
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                self.assertEqual(_ground(symbols, glyph), land.get(x, y), "%s at %d,%d paints other ground than the layout drew" % (glyph, x, y))
                if glyph in layout.STADT_GROUND:
                    self.assertEqual(layout.STADT_GROUND[glyph], _ground(symbols, glyph), glyph)

    def test_what_belongs_there_once_stands_once_and_the_rest_in_numbers(self):
        _, _, rows, spots = _stadt()
        text = "".join(rows)
        for glyph in STADT_ONCE:
            if glyph in "Ss":
                continue
            self.assertEqual(text.count(glyph), 1, glyph)
        for glyph in "Ss":
            self.assertEqual(text.count(glyph), 1, "one stall of each: " + glyph)
        self.assertEqual(text.count("W"), 20 + 17, "wall pieces: twenty along the north, sixteen and one along the south")
        self.assertEqual(text.count("|"), 18, "nine pieces on each side wall")
        self.assertEqual(text.count("t"), 4, "a tower at each corner")
        self.assertGreaterEqual(text.count("l"), 8, "lamp posts (dark lanterns)")
        self.assertGreaterEqual(sum(text.count(g) for g in "abcdefjuwz"), 14, "houses")
        placed = sum(1 for row in rows for ch in row if ch not in ".,mp_h")
        self.assertLess(placed, 520, "a map of class M builds in about half a second: keep the nodes in check")

    def test_the_cues_are_the_contracts_and_the_dialogue_has_them(self):
        _, symbols, rows, _ = _stadt()
        used = {}
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if "cue" in params:
                used[glyph] = params["cue"]
                self.assertEqual(params["dialogue"], STADT_DIALOGUE_RES, glyph)
        self.assertEqual(used, STADT_CUES)
        if os.path.exists(STADT_DIALOGUE):
            with open(STADT_DIALOGUE, encoding="utf-8") as f:
                cues = set(re.findall(r"^~ (\w+)", f.read(), re.M))
            self.assertLessEqual(set(used.values()), cues, "every cue of the map is a cue of the dialogue")

    def test_the_people_are_walkers_with_the_contracts_sheets_and_two_of_them_sit(self):
        _, symbols, rows, spots = _stadt()
        for glyph, sheet in STADT_SHEETS.items():
            params = symbols[glyph]["params"]
            self.assertTrue(symbols[glyph]["prop"].endswith("npc_walker.tscn"), glyph)
            self.assertEqual(params["sheet"], "res://entities/character/sheet_%s_look.tres" % sheet)
            self.assertIn(params["face"], "nesw")
            self.assertEqual(bool(params.get("sit")), glyph in "ML", "Mira sits on the fountain's rim and Lio on his crate: " + glyph)
            self.assertIn(_ground(symbols, glyph), "_,", glyph)
        goat = symbols["J"]
        self.assertTrue(goat["prop"].endswith("goat.tscn"))
        self.assertEqual(goat["params"]["perch"], layout.hall_perch(spots["J"][0][1]), "its feet end on the parapet's top")
        hx = spots["R"][0][0]
        self.assertTrue(hx - 5 <= spots["J"][0][0] <= hx + 5, "under the roof of the town hall")
        self.assertEqual(spots["J"][0][1], spots["D"][0][1], "on the row before the facade")

    def test_the_doors_and_the_blockers_and_the_markers_are_the_contracts(self):
        _, symbols, rows, spots = _stadt()
        east = symbols["N"]["params"]
        self.assertEqual((east["target"], east["spawn"], east["auto"], east["size"]), ("strasse", "stadt", True, [1, 7]))
        hall = symbols["D"]["params"]
        self.assertEqual((hall["target"], hall["spawn"]), ("rathaus", "stadt"))
        self.assertNotIn("auto", hall, "the town hall's door is used with a key press like the house's")
        for glyph, cue in (("%", "florist_wait"), ("&", "workshop_wait")):
            params = symbols[glyph]["params"]
            self.assertTrue(symbols[glyph]["prop"].endswith("blocker.tscn"))
            self.assertEqual(params["cue"], cue)
            self.assertNotIn("if", params)
            self.assertNotIn("unless", params, "nothing opens a blocker but the segment that puts the door there")
            self.assertEqual(params["size"][1], 1)
            self.assertIn(_ground(symbols, glyph), "_,", "S3 and S4 put a door on this cell: no bake needed")
        for glyph, marker in (("@", "player_spawn"), ("n", "spawn_strasse"), ("i", "spawn_rathaus"), ("$", "spawn_blumenladen"),
                              ("!", "spawn_werkstatt")):
            self.assertEqual(symbols[glyph]["marker"], marker)

    def test_the_start_is_on_the_square_far_from_every_door_with_room_to_walk_right_then_down(self):
        _, symbols, rows, spots = _stadt()
        start = spots["@"][0]
        x0, y0, x1, y1 = layout.PLATZ
        self.assertTrue(x0 <= start[0] <= x1 and y0 <= start[1] <= y1, "on the square")
        for glyph in "ND":
            door = spots[glyph][0]
            self.assertGreaterEqual(math.hypot(start[0] - door[0], start[1] - door[1]), 20, "the benchmark walks right, then down: stay away from " + glyph)
            self.assertGreaterEqual(abs(start[0] - door[0]) + abs(start[1] - door[1]), 20)
        for dx in range(1, 8):
            self.assertIn(_ground(symbols, rows[start[1]][start[0] + dx]), STANDABLE, "a free walk of seven cells to the right")
        self.assertEqual(spots["@"], [layout.START_S])

    def test_the_arrivals_stand_clear_of_the_doors_zones(self):
        _, symbols, rows, spots = _stadt()
        east, arrival = spots["N"][0], spots["n"][0]
        self.assertGreaterEqual(east[0] - arrival[0], 3, "a door zone must not catch the arrival (outside, before the gate)")
        self.assertEqual(east, (layout.EAST_DOOR_X, layout.DOOR_ROW))
        self.assertGreater(arrival[1], layout.WALL_S, "the arrival lies outside the wall")
        hall_door, hall_arrival = spots["D"][0], spots["i"][0]
        self.assertGreaterEqual(hall_arrival[1] - hall_door[1], 2)
        for glyph, blocker in (("$", "%"), ("!", "&")):
            bx, by = spots[blocker][0]
            mx, my = spots[glyph][0]
            self.assertEqual(mx, bx)
            self.assertTrue(2 <= my - by <= 3, "the arrival lies two cells before the shop's blocker")

    def test_everything_is_reachable_on_foot_from_the_start_and_the_gate_is_the_only_way_in(self):
        _, symbols, rows, spots = _stadt()
        reach = _reach(rows, symbols, spots["@"][0])
        for glyph in "niN$!D":
            self.assertIn(spots[glyph][0], reach, glyph)
        for glyph in list(STADT_CUES) + list("OZ123"):
            for x, y in spots[glyph]:
                self.assertTrue(any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3)), "%s at %d,%d" % (glyph, x, y))
        # the arch is the only gap in the wall: blocked, the outside is cut off
        shut = [list(r) for r in rows]
        for y in range(layout.GATE_ROWS[0], layout.GATE_ROWS[1] + 1):
            for x in range(layout.GATE_X - 2, layout.GATE_X + 3):
                shut[y][x] = "h"
        reach_shut = _reach(["".join(r) for r in shut], symbols, spots["@"][0])
        self.assertNotIn(spots["n"][0], reach_shut, "the gate is the only way in")
        self.assertNotIn(spots["N"][0], reach_shut)
        # no walkable cell is cut off: every cell the map offers to stand on is part of the one walk
        walk = {(x, y) for y, row in enumerate(rows) for x, ch in enumerate(row) if _ground(symbols, ch) in STANDABLE}
        self.assertEqual(walk - reach, set(), "no pocket the player cannot leave")

    def test_the_gate_is_a_passage_of_five_cells_through_a_wall_two_cells_thick_and_the_walls_join(self):
        _, symbols, rows, spots = _stadt()
        gx = layout.GATE_X
        self.assertEqual(spots["G"], [(gx, layout.WALL_S)])
        for y in range(layout.GATE_ROWS[0], layout.GATE_ROWS[1] + 1):
            standable = [x for x in range(layout.SW) if _ground(symbols, rows[y][x]) in STANDABLE]
            self.assertEqual(standable, list(range(gx - 2, gx + 3)), "row %d: only the arch is open in the wall" % y)
        for x in range(12, 91):  # the south wall is solid but at the gate
            if not gx - 2 <= x <= gx + 2:
                for y in range(layout.GATE_ROWS[0], layout.GATE_ROWS[1] + 1):
                    self.assertEqual(_ground(symbols, rows[y][x]), "h", "the wall at %d,%d" % (x, y))
        north = [x for x, ch in enumerate(rows[layout.WALL_N]) if ch == "W"]
        self.assertEqual(north, list(range(12, 92, 4)), "pieces of four cells, end to end")
        south = [x for x, ch in enumerate(rows[layout.WALL_S]) if ch == "W"]
        self.assertEqual(south, list(range(12, gx - 5, 4)) + [gx + 6], "end to end up to the gate's pier, one piece east of it")
        for col in (layout.WALL_W, layout.WALL_E):
            runs = [y for y in range(layout.SH) if rows[y][col] == "|"]
            self.assertEqual(runs, list(range(11, 44, 4)))
        for y, x in ((layout.WALL_N, layout.WALL_W), (layout.WALL_N, layout.WALL_E), (layout.WALL_S, layout.WALL_W), (layout.WALL_S, layout.WALL_E)):
            self.assertEqual(rows[y][x], "t")

    def test_the_square_has_room_for_a_small_stage_before_the_town_hall(self):
        _, symbols, rows, spots = _stadt()
        door = spots["D"][0]
        stage = [(x, y) for x in range(door[0] - 4, door[0] + 5) for y in range(door[1] + 1, door[1] + 6)]
        for x, y in stage:
            self.assertIn(_ground(symbols, rows[y][x]), STANDABLE, "the stage's floor at %d,%d" % (x, y))
        pult = spots["2"][0]
        for x, y in stage:
            glyph = rows[y][x]
            self.assertTrue(glyph in "_" or (x, y) in (pult, spots["i"][0]), "nothing stands on the stage but what S6 may move: %s at %d,%d" % (glyph, x, y))
        self.assertGreaterEqual(spots["i"][0][1] - door[1], 2)

    def test_the_lanes_are_at_least_four_wide_and_two_figures_pass_the_shops(self):
        _, symbols, rows, spots = _stadt()
        catalog = mapfile.load_catalog()
        solid_props = set()
        for glyph, cells in spots.items():
            params = symbols[glyph].get("params", {})
            if params.get("sprite") and "shape" in catalog.get(params["sprite"], {}) or symbols[glyph].get("prop", "").endswith("blocker.tscn"):
                solid_props.update(cells)
        for x in range(layout.CONNECTOR_X[0], layout.PLATZ[0]):  # the lane to the florist
            free = [y for y in range(layout.SH) if _ground(symbols, rows[y][x]) in STANDABLE and (x, y) not in solid_props
                    and layout.LANE_Y[0] <= y <= layout.LANE_Y[1]]
            self.assertGreaterEqual(len(free), 3, "two figures pass at column %d" % x)
            self.assertEqual(len([y for y in range(layout.LANE_Y[0], layout.LANE_Y[1] + 1) if _ground(symbols, rows[y][x]) in STANDABLE]), 4)
        for x in range(layout.CONNECTOR_X[0], layout.STREET_X[0]):  # the lane to the workshop
            free = [y for y in range(layout.SLANE_Y[0], layout.SLANE_Y[1] + 1) if _ground(symbols, rows[y][x]) in STANDABLE and (x, y) not in solid_props]
            self.assertGreaterEqual(len(free), 3, "two figures pass at column %d" % x)
        for y in range(layout.LANE_Y[0], layout.GATE_ROWS[1] + 1):  # the gate street
            wide = [x for x in range(layout.SW) if _ground(symbols, rows[y][x]) in STANDABLE and layout.STREET_X[0] <= x <= layout.STREET_X[1]]
            self.assertEqual(wide, list(range(layout.STREET_X[0], layout.STREET_X[1] + 1)), "row %d" % y)
        # the two shops: the blocker before each door, the door of the shop at its middle column
        fx = spots["F"][0]
        kx = spots["K"][0]
        self.assertEqual(spots["%"][0], (fx[0], fx[1] + 1))
        self.assertEqual(spots["&"][0], (kx[0], kx[1] + 1))
        self.assertGreater(fx[1], layout.LANE_Y[0] - 2)
        self.assertGreaterEqual(fx[0] - 6, layout.CONNECTOR_X[0])
        self.assertGreater(kx[0] - 4, layout.CONNECTOR_X[1], "the workshop's plot starts east of the connector")

    def test_every_building_stands_on_solid_ground_with_solid_plot_behind_it_and_nobody_walks_behind_one(self):
        if importlib.util.find_spec("PIL") is None:
            self.skipTest("needs Pillow")
        _, symbols, rows, spots = _stadt()
        catalog = mapfile.load_catalog()
        for glyph in FACADE_GLYPHS + "Zs" + "S":
            for gx, gy in spots[glyph]:
                params = symbols[glyph]["params"]
                entry = catalog[params["sprite"]]
                tex = mapfile.res_path(entry["textures"][0])
                opaque = _opaque_blocks(tex)
                ax, ay = entry["anchor"]
                ox, oy = gx * 16 + 8 - ax, gy * 16 + 8 - ay  # the sprite's top-left corner in the map's pixels
                rect = entry.get("shape", {}).get("rect")
                if glyph not in "ZsS":
                    self.assertEqual(_ground(symbols, glyph), "h" if glyph != "G" else "_", "a building's foot is a solid cell: " + glyph)
                for cy in range(max(0, oy // 16), gy + 1):
                    for cx in range(max(0, ox // 16), min(layout.SW, (ox + 224) // 16)):
                        if _ground(symbols, rows[cy][cx]) not in STANDABLE:
                            continue
                        if glyph == "G" and layout.GATE_X - 2 <= cx <= layout.GATE_X + 2 and cy >= layout.GATE_ROWS[0] - 1:
                            continue  # the arch and the cells before its crown: a person walks under it
                        if (cx, cy) == (gx, gy):
                            continue
                        if rect:  # a player cannot stand where the prop's own collision (and his own body) is
                            sx, sy = entry["shape"].get("offset", [0, 0])
                            if abs(cx * 16 + 8 - (gx * 16 + 8 + sx)) < rect[0] / 2 + 6 and abs(cy * 16 + 8 - (gy * 16 + 8 + sy)) < rect[1] / 2 + 6:
                                continue
                        # the player's body: about eight pixels round the cell's centre, a tall figure reaches a bit higher
                        covered = sum(1 for dx in range(-4, 4) for dy in range(-6, 4)
                                      if (cx * 16 + 8 + dx - ox, cy * 16 + 8 + dy - oy) in opaque)
                        self.assertEqual(covered, 0, "%s at %d,%d hides the walkable cell %d,%d" % (glyph, gx, gy, cx, cy))

    def test_no_crown_hides_a_walkable_cell_and_no_tree_stands_on_one(self):
        _, symbols, rows, spots = _stadt()
        for glyph, (wide, high) in TREES.items():
            for x, y in spots.get(glyph, []):
                self.assertEqual(_ground(symbols, glyph), "h", "trees stand in the solid forest")
                for dy in range(1, high + 1):
                    for dx in range(-wide, wide + 1):
                        cx, cy = x + dx, y - dy
                        if 0 <= cy < len(rows) and 0 <= cx < len(rows[0]):
                            self.assertNotIn(_ground(symbols, rows[cy][cx]), STANDABLE, "%s at %d,%d hides %d,%d" % (glyph, x, y, cx, cy))

    def test_the_stations_the_fountain_and_the_rim_patch_sit_where_the_story_wants_them(self):
        _, symbols, rows, spots = _stadt()
        catalog = mapfile.load_catalog()
        fx, fy = spots["O"][0]
        self.assertEqual((fx, fy), layout.FOUNTAIN)
        self.assertEqual(spots["Q"][0], (fx - 1, fy + 2), "the rim patch lies over the fountain's rim, south-west of it")
        ax, ay = catalog["tal/st_fountain"]["anchor"]
        self.assertEqual(catalog["tal/st_fountain_rim"]["anchor"], [-16 - 14 + ax, 32 - 70 + ay], "the patch's pixel at its cell centre meets the rim")
        self.assertNotIn("shadow", catalog["tal/st_fountain_rim"])
        mx, my = spots["M"][0]
        self.assertEqual(my, fy + 1, "Mira sits on the cell before the rim's front")
        self.assertLessEqual(abs(mx - fx), 2)
        self.assertGreater(spots["Z"][0][1], 0)
        self.assertLess(spots["Z"][0][1], fy - 6, "the board stands north of the fountain, against the plot behind it")
        self.assertEqual(spots["y"][0], (spots["Z"][0][0], spots["Z"][0][1] + 2), "he stands at his board")
        for x in range(spots["Z"][0][0] - 2, spots["Z"][0][0] + 3):
            self.assertEqual(_ground(symbols, rows[spots["Z"][0][1] - 1][x]), "h", "no pocket behind the board")
        self.assertEqual(spots["Y"][0], (spots["L"][0][0], spots["L"][0][1] - 1), "Lio's crate lies one cell north of his seat")
        self.assertEqual(catalog["tal/st_seat_crate"]["anchor"][1], -7)
        self.assertTrue(catalog["tal/st_seat_crate"].get("flat"), "the sitter is drawn over it")
        self.assertEqual(spots["1"][0][1] - fy, 0)
        self.assertLessEqual(abs(spots["1"][0][0] - fx), 6, "the wreath at the fountain")
        self.assertLessEqual(abs(spots["2"][0][1] - spots["D"][0][1]), 4, "the lectern before the town hall")
        for g in "123":
            self.assertEqual(symbols[g]["params"]["dialogue"], STADT_DIALOGUE_RES)

    def test_every_sprite_of_the_map_is_in_the_catalog_and_none_has_a_light(self):
        meta, symbols, rows, _ = _stadt()
        catalog = mapfile.load_catalog()
        sprites = set()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if params.get("sprite"):
                sprites.add(params["sprite"])
        sprites.update(rule["sprite"] for rule in meta["scatter"])
        for sprite in sprites:
            self.assertIn(sprite, catalog, sprite)
            self.assertNotIn("lights", catalog[sprite], "the town by day has no PointLight2D: " + sprite)
        for sprite in sprites:
            if sprite.startswith("tal/st_") and "wall" not in sprite and "gate" not in sprite:
                self.assertTrue(os.path.exists(mapfile.res_path(catalog[sprite]["textures"][0])), sprite)
        self.assertIn("smoke", catalog["tal/st_house_a"], "the chimneys smoke")
        for name in ("st_florist", "st_workshop", "st_town_hall"):
            self.assertIn("tal/" + name, sprites)

    def test_what_the_story_adds_casts_no_baked_shadow_and_free_standing_things_do(self):
        _, symbols, rows, _ = _stadt()
        catalog = mapfile.load_catalog()
        for glyph in set("".join(rows)):
            params = symbols[glyph].get("params", {})
            if "if" in params or "unless" in params or "sprite_when" in params:
                self.assertNotIn("shadow", catalog.get(params.get("sprite", ""), {}), glyph)
        for name in FACADE_GLYPHS:
            sprite = symbols[name]["params"]["sprite"]
            self.assertNotIn("shadow", catalog[sprite], "a building's foot is solid ground: " + sprite)
        for sprite in ("tal/st_fountain", "tal/st_stall_fruit", "tal/st_board", "tal/st_lamp_post"):
            self.assertIn("shadow", catalog[sprite])

    def test_the_outside_is_a_road_with_ruts_before_a_door_at_the_edge_of_the_map(self):
        _, symbols, rows, spots = _stadt()
        x, y = spots["N"][0]
        around = [j for j in range(layout.SH) if _ground(symbols, rows[j][x]) in STANDABLE]
        self.assertEqual(around, list(range(y - 2, y + 3)), "five cells of road at the door, forest above and below")
        self.assertEqual(x, layout.SW - 2)
        text = "".join(rows)
        self.assertGreaterEqual(text.count("m"), 10, "ruts")
        self.assertGreaterEqual(text.count("p"), 3, "puddles")
        road = _reach(rows, symbols, spots["n"][0], set(",mp_"))
        self.assertIn(spots["N"][0], road)
        self.assertIn((layout.GATE_X, layout.GATE_ROWS[1]), road, "the road runs into the gate")

    def test_the_map_is_baked_and_its_neighbours_stamps_stand(self):
        problems = [p for p in mapfile.check() if p.startswith("stadt:") or p.startswith("strasse:")]
        self.assertEqual(problems, [])

    def test_the_town_halls_scene_names_this_map_back(self):
        path = os.path.join(mapfile.ROOT, "content", "maps", "rathaus.txt")
        if not os.path.exists(path):
            self.skipTest("rathaus.txt is the interior's own")
        _, symbols, rows = _map(path)
        markers = {d.get("marker") for d in symbols.values()}
        self.assertIn("spawn_stadt", markers, "the door of the town hall comes back to the square")
        doors = [d["params"] for d in symbols.values() if d.get("prop", "").endswith("door.tscn")]
        self.assertTrue(any((p["target"], p["spawn"]) == ("stadt", "rathaus") for p in doors))


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
