#!/usr/bin/env python3
"""Small hand-made pixel images as text (ADR-057): a grid of characters, a key to the palette, a PNG out.

Usage: python3 tools/art/pixelgrid.py [--check] [FILE.pix ...]    (default: tools/art/small/*.pix)
Without --check the PNGs are written (Pillow, a development tool like the other generators);
--check only validates and needs the standard library, so check.sh can run it everywhere.

A .pix file:
    # comments start with #
    name: fragment_hallway           the PNG's name (snake_case, stable like every ID)
    out: assets/generated/fragments  folder of the PNG, relative to the project
    size: 16x16
    palette: o=#1a1530 w=#f6f5fa g=#85819f      at most MAX_COLORS colours
    outline: o                       optional: the colour every edge pixel must have
    ---
    ................                  '.' is transparent; one row per line, as wide as `size`
    ..oooooooooooo...

Rules the checker enforces (docs/PRODUKTIONSPLAN.md section 8, "Kleine Bilder von Hand"): the grid has
exactly the declared size, every character is '.' or in the palette, every palette colour is used,
colours are #rrggbb and few, the picture is not empty, and with `outline` every opaque pixel that
touches transparency (or the border of the image) wears the outline colour, so nothing is left open.
"""
import glob
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SMALL = os.path.join(ROOT, "tools", "art", "small")
MAX_COLORS = 12
NAME_RE = re.compile(r"^[a-z][a-z0-9_]*$")
COLOR_RE = re.compile(r"^#[0-9a-fA-F]{6}$")


class Picture:
    def __init__(self, path):
        self.path = path
        self.name = ""
        self.out = ""
        self.width = 0
        self.height = 0
        self.palette = {}
        self.outline = ""
        self.rows = []
        self.problems = []
        self._read()
        self._check()

    def _read(self):
        in_grid = False
        with open(self.path, encoding="utf-8") as f:
            for number, raw in enumerate(f.read().replace("\r", "").split("\n"), 1):
                line = raw.rstrip()
                if in_grid:
                    if line.strip() and not line.startswith("#"):
                        self.rows.append(line.strip())
                    continue
                if not line.strip() or line.lstrip().startswith("#"):
                    continue
                if line.strip() == "---":
                    in_grid = True
                    continue
                key, _, value = line.partition(":")
                key, value = key.strip(), value.strip()
                if key == "name":
                    self.name = value
                elif key == "out":
                    self.out = value
                elif key == "size":
                    match = re.fullmatch(r"(\d+)x(\d+)", value)
                    if match:
                        self.width, self.height = int(match.group(1)), int(match.group(2))
                    else:
                        self.problems.append("line %d: size must read 16x16" % number)
                elif key == "palette":
                    for entry in value.split():
                        char, _, color = entry.partition("=")
                        if len(char) != 1 or char == "." or not COLOR_RE.match(color):
                            self.problems.append("line %d: bad palette entry '%s'" % (number, entry))
                        else:
                            self.palette[char] = color.lower()
                elif key == "outline":
                    self.outline = value
                else:
                    self.problems.append("line %d: unknown key '%s'" % (number, key))

    def _check(self):
        problems = self.problems
        if not NAME_RE.match(self.name):
            problems.append("name must be snake_case")
        if not self.out:
            problems.append("out is missing")
        if self.width <= 0 or self.height <= 0:
            problems.append("size is missing")
            return
        if len(self.palette) > MAX_COLORS:
            problems.append("%d colours, at most %d" % (len(self.palette), MAX_COLORS))
        if len(self.rows) != self.height:
            problems.append("%d rows, size says %d" % (len(self.rows), self.height))
        used = set()
        for y, row in enumerate(self.rows):
            if len(row) != self.width:
                problems.append("row %d is %d wide, size says %d" % (y + 1, len(row), self.width))
            for x, char in enumerate(row):
                if char != "." and char not in self.palette:
                    problems.append("row %d, column %d: '%s' is not in the palette" % (y + 1, x + 1, char))
                used.add(char)
        for char in self.palette:
            if char not in used:
                problems.append("palette colour '%s' is never used" % char)
        if used <= {"."}:
            problems.append("the picture is empty")
        if self.outline:
            if self.outline not in self.palette:
                problems.append("outline '%s' is not in the palette" % self.outline)
            elif not problems:
                problems += self._open_edges()

    def _open_edges(self):
        found = []
        for y in range(self.height):
            for x in range(self.width):
                if self.rows[y][x] in (".", self.outline):
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    outside = not (0 <= nx < self.width and 0 <= ny < self.height)
                    if outside or self.rows[ny][nx] == ".":
                        found.append("row %d, column %d: '%s' touches transparency without the outline"
                                     % (y + 1, x + 1, self.rows[y][x]))
                        break
        return found

    def pixels(self):
        """[(x, y, (r, g, b, a))] of the picture, transparent pixels as alpha 0."""
        out = []
        for y, row in enumerate(self.rows):
            for x, char in enumerate(row):
                if char == ".":
                    out.append((x, y, (0, 0, 0, 0)))
                else:
                    color = self.palette[char]
                    out.append((x, y, (int(color[1:3], 16), int(color[3:5], 16), int(color[5:7], 16), 255)))
        return out

    def target(self):
        return os.path.join(ROOT, self.out, self.name + ".png")


def write_png(picture):
    from PIL import Image  # development tool only, like numpy in the other generators

    image = Image.new("RGBA", (picture.width, picture.height), (0, 0, 0, 0))
    for x, y, rgba in picture.pixels():
        image.putpixel((x, y), rgba)
    os.makedirs(os.path.dirname(picture.target()), exist_ok=True)
    image.save(picture.target())
    return picture.target()


def main(argv):
    check_only = "--check" in argv
    paths = [a for a in argv if not a.startswith("--")] or sorted(glob.glob(os.path.join(SMALL, "*.pix")))
    failed = 0
    names = set()
    for path in paths:
        picture = Picture(path)
        if picture.name in names:
            picture.problems.append("name '%s' is used twice" % picture.name)
        names.add(picture.name)
        label = os.path.relpath(path, ROOT)
        for problem in picture.problems:
            print("error: %s: %s" % (label, problem))
        if picture.problems:
            failed += 1
        elif not check_only:
            print("pixelgrid: wrote %s" % os.path.relpath(write_png(picture), ROOT))
    print("pixelgrid: %d pictures, %d with errors" % (len(paths), failed))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
