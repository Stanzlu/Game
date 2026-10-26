"""Tests of the Act III map generator (standard library only): python3 -m unittest discover -s tools/art."""
import os
import unittest
from collections import deque

import layout_akt3_maps as layout
import mapfile

WALDWEG = os.path.join(mapfile.ROOT, "content", "maps", "waldweg.txt")
# ground cells a person can stand on (the legend's own grounds: grass, path, mud, puddle)
STANDABLE = set(".,mp")
# the spots of the walk, each once on the map (the rest of the letters are scattered forest)
NAMED = "123456AEHDSNn@BQqazUKrCZYX"
CUES = "123456QqazUKHDSnBCZYX"


def _map():
    return mapfile.parse_map(WALDWEG)


def _ground(symbols, glyph):
    entry = symbols[glyph]
    return entry.get("ground", glyph)


def _spots(rows):
    found = {}
    for y, row in enumerate(rows):
        for x, glyph in enumerate(row):
            found.setdefault(glyph, []).append((x, y))
    return found


def _reach(rows, symbols, start):
    seen = {start}
    queue = deque([start])
    while queue:
        x, y = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if not (0 <= ny < len(rows) and 0 <= nx < len(rows[ny])) or (nx, ny) in seen:
                continue
            if _ground(symbols, rows[ny][nx]) in STANDABLE:
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
        order = ["N", "n", "1", "2", "Q", "3", "a", "U", "z", "4", "q", "5", "6", "B"]
        ys = [spots[glyph][0][1] for glyph in order]
        self.assertEqual(ys, sorted(ys), "the walk goes from the door to the end of the way")
        self.assertLess(spots["Q"][0][1], spots["a"][0][1], "a place to rest before the Hang")
        self.assertGreater(spots["q"][0][1], spots["z"][0][1], "and one after it")

    def test_the_arrival_is_outside_the_doors_zone(self):
        _, _, rows = _map()
        spots = _spots(rows)
        door, arrival, start = spots["N"][0], spots["n"][0], spots["@"][0]
        self.assertGreaterEqual(abs(arrival[1] - door[1]), 4, "a door zone must not catch the arrival")
        self.assertGreaterEqual(abs(start[1] - door[1]), 4)

    def test_the_way_on_to_the_south_is_exactly_the_blockers_width(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        x, y = spots["B"][0]
        self.assertEqual((x, y), layout.BLOCKER)
        for row in (y, y + 1, y + 2):
            around = [i for i in range(x - 4, x + 5) if _ground(symbols, rows[row][i]) in STANDABLE]
            if row > y:
                self.assertEqual(around, [x - 1, x, x + 1], "south of it the way is three cells wide")
        # the cells beside the blocker in its own row lead nowhere: the row below them is forest
        for i in (x - 2, x - 3):
            if _ground(symbols, rows[y][i]) in STANDABLE:
                self.assertNotIn(_ground(symbols, rows[y + 1][i]), STANDABLE, "no way around it")

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
        for glyph in "123456KQqUCYX":
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

    def test_the_brook_is_water_all_the_way_and_the_path_keeps_to_its_west_bank(self):
        _, symbols, rows = _map()
        spots = _spots(rows)
        for y in range(layout.H):
            wet = [x for x, c in enumerate(rows[y]) if c == "~"]
            self.assertTrue(wet, "row %d has water" % y)
        for glyph in "123456":
            x, y = spots[glyph][0]
            self.assertLess(x, layout.stream_x(y), "board %s is west of the brook" % glyph)


if __name__ == "__main__":
    unittest.main()
