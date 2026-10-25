"""Tests of the bake stamps (standard library only): python3 -m unittest discover -s tools/art."""
import os
import shutil
import tempfile
import unittest

import mapfile


class StampTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.maps = os.path.join(self.tmp, "maps")
        os.makedirs(self.maps)
        self.path = os.path.join(self.maps, "haus.txt")
        shutil.copy(os.path.join(mapfile.MAP_DIR, "haus.txt"), self.path)
        self.saved = (mapfile.MAP_DIR, mapfile.STAMP_FILE, mapfile.sources_hash)
        mapfile.MAP_DIR = self.maps
        mapfile.STAMP_FILE = os.path.join(self.tmp, "stamps.json")
        mapfile.write_stamp(self.path)

    def tearDown(self):
        mapfile.MAP_DIR, mapfile.STAMP_FILE, mapfile.sources_hash = self.saved
        shutil.rmtree(self.tmp)

    def edit(self, old, new):
        with open(self.path, encoding="utf-8") as f:
            text = f.read()
        self.assertIn(old, text)
        with open(self.path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text.replace(old, new, 1))

    def test_a_fresh_bake_is_current(self):
        self.assertEqual(mapfile.check(), [])

    def test_a_painted_cell_makes_the_bake_stale(self):
        self.edit("############SWWWWWWWWWWWWWWW", "############SWWWWWWWWWWWWWW_")
        problems = mapfile.check()
        self.assertEqual(len(problems), 1)
        self.assertIn("changed since the last bake", problems[0])

    def test_a_prop_parameter_leaves_the_bake_alone(self):
        self.edit('"cue": "table"', '"cue": "table2"')
        self.assertEqual(mapfile.check(), [])

    def test_scatter_rules_leave_the_bake_alone(self):
        self.edit('style = "tal"', 'style = "tal"\nscatter = [{"sprite": "tal/pebbles"}]')
        self.assertEqual(mapfile.check(), [])

    def test_the_style_makes_the_bake_stale(self):
        self.edit('style = "tal"', 'style = "elysia"')
        self.assertEqual(len(mapfile.check()), 1)

    def test_a_changed_baker_outdates_every_bake(self):
        mapfile.sources_hash = lambda: "another baker"
        self.assertEqual(len(mapfile.check()), 1)

    def test_another_seed_is_another_bake(self):
        self.assertNotEqual(mapfile.stamp(self.path, 7), mapfile.stamp(self.path, 8))

    def test_a_map_without_a_stamp_is_reported(self):
        os.remove(mapfile.STAMP_FILE)
        problems = mapfile.check()
        self.assertEqual(len(problems), 1)
        self.assertIn("no bake stamp", problems[0])

    def test_a_stamp_without_a_map_is_reported(self):
        os.remove(self.path)
        problems = mapfile.check()
        self.assertEqual(len(problems), 1)
        self.assertIn("not baked any more", problems[0])

    def test_the_committed_stamps_are_current(self):
        mapfile.MAP_DIR, mapfile.STAMP_FILE, mapfile.sources_hash = self.saved
        self.assertEqual(mapfile.check(), [])




class SymbolTests(unittest.TestCase):
    """Symbols outside ASCII (T6, ADR-068): the parser of the art tools and MapData read the same file."""

    FIXTURE = os.path.join(mapfile.ROOT, "tests", "fixtures", "maps", "unicode_symbols.txt")

    def test_symbols_outside_ascii_are_cells(self):
        meta, symbols, rows = mapfile.parse_map(self.FIXTURE)
        self.assertEqual(rows, ["日日日日日", "日ö😀€日", "日€Ωö日", "日日日日日"])
        for symbol in "ö€日😀Ω":
            self.assertIn(symbol, symbols)
        self.assertEqual(symbols["😀"]["marker"], "player_spawn")
        self.assertEqual(sum(row.count("😀") + row.count("Ω") for row in rows), 2, "two markers")

    def test_trailing_blanks_of_a_row_are_cut_off(self):
        # MapData does the same (tests/unit/test_map_data.gd): both see the same width
        path = os.path.join(tempfile.mkdtemp(), "blanks.txt")
        with open(path, "w", encoding="utf-8") as f:
            f.write("[map]\n..  \n..\t\n..\n")
        _, _, rows = mapfile.parse_map(path)
        self.assertEqual(rows, ["..", "..", ".."])

    def test_a_row_is_as_long_as_its_symbols_not_its_bytes(self):
        _, _, rows = mapfile.parse_map(self.FIXTURE)
        self.assertEqual({len(row) for row in rows}, {5})
        self.assertGreater(len(rows[1].encode("utf-8")), 5)


if __name__ == "__main__":
    unittest.main()
