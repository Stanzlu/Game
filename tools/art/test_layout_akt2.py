"""Tests of the Act II map generator (standard library only): python3 -m unittest discover -s tools/art."""
import os
import unittest
from collections import deque

import layout_akt2_maps as layout
import mapfile

BACHLAUF = os.path.join(mapfile.ROOT, "content", "maps", "bachlauf.txt")
# ground cells a person can stand on (the legend's own grounds: grass, path, mud, puddle, log)
STANDABLE = set(".,mpy")


def _map():
    return mapfile.parse_map(BACHLAUF)


def _ground(symbols, glyph):
    entry = symbols[glyph]
    return entry.get("ground", glyph)


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


class BachlaufLayoutTests(unittest.TestCase):
    def test_the_committed_map_is_what_the_generator_draws(self):
        _, _, rows = _map()
        self.assertEqual(rows, layout.text().split("\n"), "run layout_akt2_maps.py bachlauf --write")

    def test_the_map_stays_within_class_m(self):
        _, _, rows = _map()
        self.assertLessEqual(len(rows), 70)
        self.assertLessEqual(len(rows[0]), 120)
        self.assertEqual({len(r) for r in rows}, {len(rows[0])}, "every row is as wide as the first")

    def test_every_named_spot_stands_once_and_the_trunks_twice(self):
        _, _, rows = _map()
        text = "".join(rows)
        for glyph in "1234567890$%&@8bWwQ":
            self.assertEqual(text.count(glyph), 1, glyph)
        self.assertEqual(text.count("Y"), 2, "one trunk over each ford")

    def test_every_spot_can_be_reached_from_the_start_on_foot(self):
        _, symbols, rows = _map()
        start = [(x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "@"][0]
        reach = _reach(rows, symbols, start)
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                if glyph in "1234567890$%&8bWwQ":
                    near = any((x + dx, y + dy) in reach for dx in range(-2, 3) for dy in range(-2, 3))
                    self.assertTrue(near, "%s at %d,%d is out of reach" % (glyph, x, y))

    def test_the_two_fords_are_the_only_way_over_the_stream(self):
        _, symbols, rows = _map()
        start = [(x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "@"][0]
        full = _reach(rows, symbols, start)
        no_logs = [r.replace("y", "~") for r in rows]
        dry = _reach(no_logs, symbols, start)
        east = [(x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "$"][0]
        self.assertIn(east, full)
        self.assertNotIn(east, dry, "without the logs the east bank is a world away")

    def test_a_trunk_reaches_across_each_ford(self):
        # the trunk sprite (tal/fallen_tree) is 86 px wide with its root plate on the first bank cell:
        # it covers the three cells of water after it and a bit of the far bank, no more
        _, _, rows = _map()
        for y in (layout.HEAD_FORD_Y, layout.SOUTH_FORD_Y):
            self.assertLessEqual(rows[y].count("y"), 3, "row %d: the log is as long as the ford" % y)
            self.assertEqual(rows[y].count("Y"), 1)

    def test_the_dry_channel_has_more_pebbles_than_its_one_spot(self):
        _, _, rows = _map()
        self.assertEqual("".join(rows).count("k"), 2, "two more rows of pebbles, no cue")

    def test_the_arrival_is_outside_the_doors_zone(self):
        _, _, rows = _map()
        spot = {}
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                spot.setdefault(glyph, (x, y))
        door, arrival = spot["%"], spot["&"]
        self.assertGreaterEqual(abs(arrival[1] - door[1]), 4, "a door zone of three cells must not catch the arrival")

    def test_the_arrival_from_the_wood_is_outside_the_south_doors_zone(self):
        _, _, rows = _map()
        spot = {}
        for y, row in enumerate(rows):
            for x, glyph in enumerate(row):
                spot.setdefault(glyph, (x, y))
        door, arrival = spot["W"], spot["w"]
        self.assertEqual(door, layout.SOUTH_DOOR)
        self.assertEqual(arrival, layout.SOUTH_ARRIVAL)
        self.assertGreaterEqual(abs(door[1] - arrival[1]), 4, "a door zone of three cells must not catch it")
        blocker = spot["Q"]
        self.assertEqual(blocker, (door[0], door[1] + 1), "the blocker shuts the gap right behind the door's cell")
        self.assertEqual(blocker[1], len(rows) - 1, "it stands in the last row: nothing lies below it")

    def test_the_weir_lies_across_the_whole_stream(self):
        _, _, rows = _map()
        weir_row = layout.WEIR_Y
        water = [x for x, c in enumerate(rows[weir_row]) if c in "v6"]
        self.assertGreaterEqual(len(water), 3)
        self.assertEqual(rows[weir_row - 1].count("~") + rows[weir_row - 1].count("5"), len(water))


if __name__ == "__main__":
    unittest.main()
