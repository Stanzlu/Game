"""The valley's committed map is what its generator draws (standard library only):
python3 -m unittest discover -s tools/art. B3 added the hedge gap and the markers 6 to 9 to the
generator so that `layout_slice_maps.py tal --write` loses nothing; this keeps it so."""
import os
import unittest

import layout_slice_maps as layout
import mapfile

TAL = os.path.join(mapfile.ROOT, "content", "maps", "tal.txt")


class TalLayoutTests(unittest.TestCase):
    def test_the_committed_valley_is_what_the_generator_draws(self):
        _, _, rows = mapfile.parse_map(TAL)
        self.assertEqual(rows, layout.tal().text().split("\n"), "run layout_slice_maps.py tal --write")


if __name__ == "__main__":
    unittest.main()
