"""Tests of the pixel grid reader (standard library only; the PNG test needs Pillow)."""
import os
import tempfile
import unittest

import pixelgrid

GOOD = """# a tiny key
name: tiny_key
out: assets/generated/items
size: 4x4
palette: o=#1a1530 y=#f7cf4a
outline: o
---
.oo.
oyyo
oyyo
.oo.
"""


def picture(text):
    handle, path = tempfile.mkstemp(suffix=".pix")
    with os.fdopen(handle, "w", encoding="utf-8") as f:
        f.write(text)
    try:
        return pixelgrid.Picture(path)
    finally:
        os.remove(path)


class PictureTests(unittest.TestCase):
    def test_a_good_picture_has_no_problems(self):
        pic = picture(GOOD)
        self.assertEqual(pic.problems, [])
        self.assertEqual((pic.width, pic.height), (4, 4))
        self.assertEqual(pic.target(), os.path.join(pixelgrid.ROOT, "assets/generated/items/tiny_key.png"))

    def test_pixels_follow_the_palette(self):
        pixels = {(x, y): rgba for x, y, rgba in picture(GOOD).pixels()}
        self.assertEqual(pixels[(0, 0)], (0, 0, 0, 0))
        self.assertEqual(pixels[(1, 1)], (0xf7, 0xcf, 0x4a, 255))
        self.assertEqual(pixels[(1, 0)], (0x1a, 0x15, 0x30, 255))

    def test_a_wrong_size_is_found(self):
        self.assertTrue(any("rows" in p for p in picture(GOOD.replace("size: 4x4", "size: 4x5")).problems))
        wide = GOOD.replace("oyyo\noyyo", "oyyyo\noyyo")
        self.assertTrue(any("wide" in p for p in picture(wide).problems))

    def test_a_character_outside_the_palette_is_found(self):
        self.assertTrue(any("not in the palette" in p for p in picture(GOOD.replace("oyyo\noyyo", "oyzo\noyyo")).problems))

    def test_an_unused_colour_is_found(self):
        pic = picture(GOOD.replace("palette: o=#1a1530 y=#f7cf4a", "palette: o=#1a1530 y=#f7cf4a r=#ff0000"))
        self.assertTrue(any("never used" in p for p in pic.problems))

    def test_too_many_colours_are_found(self):
        keys = "abcdefghijklm"
        palette = " ".join("%s=#%02x0000" % (k, i + 1) for i, k in enumerate(keys))
        pic = picture("name: many\nout: x\nsize: 13x1\npalette: %s\n---\n%s\n" % (palette, keys))
        self.assertTrue(any("at most" in p for p in pic.problems))

    def test_an_open_outline_is_found(self):
        pic = picture(GOOD.replace("oyyo\noyyo", "oyyy\noyyo"))
        self.assertTrue(any("without the outline" in p for p in pic.problems), pic.problems)

    def test_an_empty_picture_is_found(self):
        pic = picture("name: nothing\nout: x\nsize: 2x1\npalette: o=#000000\n---\n..\n")
        self.assertTrue(any("empty" in p for p in pic.problems))

    def test_a_bad_name_and_a_bad_colour_are_found(self):
        self.assertTrue(any("snake_case" in p for p in picture(GOOD.replace("tiny_key", "Tiny Key")).problems))
        self.assertTrue(any("bad palette" in p for p in picture(GOOD.replace("#1a1530", "1a1530")).problems))

    def test_all_shipped_pictures_pass(self):
        errors = []
        for name in sorted(os.listdir(pixelgrid.SMALL)):
            if name.endswith(".pix"):
                errors += picture_file(os.path.join(pixelgrid.SMALL, name)).problems
        self.assertEqual(errors, [])

    @unittest.skipUnless(__import__("importlib").util.find_spec("PIL"), "Pillow is a development tool")
    def test_the_png_has_the_size_and_colours_of_the_picture(self):
        from PIL import Image

        pic = picture(GOOD)
        with tempfile.TemporaryDirectory() as folder:
            pic.out = folder
            path = pixelgrid.write_png(pic)
            image = Image.open(path).convert("RGBA")
            self.assertEqual(image.size, (4, 4))
            self.assertEqual(image.getpixel((1, 1)), (0xf7, 0xcf, 0x4a, 255))
            self.assertEqual(image.getpixel((0, 0))[3], 0)


def picture_file(path):
    return pixelgrid.Picture(path)


if __name__ == "__main__":
    unittest.main()
