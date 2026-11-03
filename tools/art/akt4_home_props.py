"""Props for the homecoming of Akt IV (S8, docs/akt4/REGIONSBRIEFE.md, O9 and O14), drawn like akt3_props.py and registered
in the same catalog (style "haus", the house of slice_props). Called from make_sprites.build(); `--preview out.png` draws
them alone and in the room, with the offsets of the map applied.

Three small things for the house after Tess has been there: a bracket shelf and a peg on the wall, each a place where
the player can put one of her curiosities (the picture, 16 x 16, is a sprite of its own and comes later: these two draw
only the place), and the loaf she leaves on the table. All three are flat or sit on furniture and carry neither a `shape`
nor a `shadow` in the catalog: the map places them under if/unless and the baked floor of "haus" must keep its stamp
(no new bake).

  slot_shelf  20 x  8, anchor (10, 8): the board's upper face is the pixel row 1, its top edge lies 7 px above the anchor.
              An item with its anchor at bottom centre stands on it with `lift` 6 (its lower edge on the upper face).
  slot_peg     8 x  8, anchor ( 4, 0): the peg head is at (0, +1) .. (0, +2) from the anchor, the loop hangs to +6.
              A picture with its anchor at top centre hangs from the loop with `lift` -4 (its upper edge 4 px below).
  loaf        16 x 10, anchor (14, 10): NOT bottom centre, see `loaf`: the bread lies left of the cup of haus/table.
              On the table (cell 20, 12) it needs the cell below the table (20, 13) so that it sorts in front of it,
              and `lift` 27 (LOAF_LIFT; the derivation is in the docstring of `loaf`).
"""
import os
import sys

import numpy as np

import akt3_props
import akt4_interior_props as interior
import pixelart as pa
from pixelart import ramp

PINE = interior.PINE  # the raw pine of Tess's workshop: the boards are hers
LEATHER = interior.LEATHER
LINEN = interior.CREAM
CRUST = ramp("#3a2418", "#9a5c24", "#d6a04c", "#f4d68a")  # the palette of items/item_loaf: it is the loaf of the list
THREAD = np.array([112, 132, 156], np.float32)  # a blue hem thread, dull

# the table of haus.txt (glyph T) and where the loaf has to go: see `loaf`
TABLE_CELL = (20, 12)
LOAF_CELL = (20, 13)
LOAF_LIFT = 27


def slot_shelf(ms):
    """A small bracket shelf on the wall, seen from the front: a fresh pine board (a lit upper face of one row, a front
    face of three rows, together the four pixels of its thickness) on two short brackets, with two nails in the front.
    Nothing stands on it: the picture the player puts there (16 x 16) is drawn above the board, so the area over the
    board stays empty. 20 x 8, anchor (10, 8): bottom centre."""
    rng = np.random.default_rng(481)
    st = pa.STYLES["tal"]
    c = ms.Canvas(20, 8)
    grain = pa.value_noise(8, 20, (1, 6), rng)
    # the brackets first: a lit left edge, a shaded right edge, two rows under the board
    for bx in (3, 15):
        c.paint(c.rect(bx, 5, bx + 2, 7), PINE, np.where(c.xx == bx, 0.62, 0.34), dither=False)
    # the board: the upper face lit, the front face getting darker towards the underside
    c.paint(c.rect(1, 1, 19, 2), PINE, 1.0, dither=False)
    c.paint(c.rect(1, 2, 19, 5), PINE, np.where(c.yy < 3, 0.86, np.where(c.yy < 4, 0.7, 0.46)) + 0.1 * (grain - 0.5),
            dither=False)
    c.paint(c.rect(1, 2, 2, 5), PINE, 0.95, dither=False)  # the lit left end grain
    c.paint(c.rect(18, 2, 19, 5), PINE, 0.3, dither=False)  # the right end in the shade
    for nx in (3, 16):  # two nails, a light head each
        c.fill(c.rect(nx, 3, nx + 1, 4), akt3_props.NAIL)
    c.outline(st["outline"])
    return c


def slot_peg(ms):
    """A wooden peg driven into the wall (its end seen from the front) with a small leather loop hanging from it: a
    picture hangs in the loop. Peg head 4 x 2, loop 4 x 4 with a dark hollow. 8 x 8, anchor (4, 0): top centre."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(8, 8)
    c.paint(c.rect(2, 1, 6, 2), PINE, 1.0, dither=False)  # the head: a lit top row ...
    c.paint(c.rect(2, 2, 6, 3), PINE, np.where(c.xx < 4, 0.86, 0.58), dither=False)  # ... and a front row, shaded to the right
    c.a[1, 2] = False  # the corners of the head are cut off
    c.a[1, 5] = False
    for x in (3, 4):  # the loop leaves the peg under its head
        c.paint(c.rect(x, 3, x + 1, 4), LEATHER, 1.0 if x == 3 else 0.78, dither=False)
    for y in (4, 5):  # the two sides: a lit one on the left, a shaded one on the right
        c.paint(c.rect(2, y, 3, y + 1), LEATHER, 0.94, dither=False)
        c.paint(c.rect(5, y, 6, y + 1), LEATHER, 0.62, dither=False)
    for x in (3, 4):  # the bottom of the loop
        c.paint(c.rect(x, 6, x + 1, 7), LEATHER, 0.8 if x == 3 else 0.5, dither=False)
    c.outline(st["outline"])
    return c


def loaf(ms):
    """A round loaf on a piece of linen: the dome in the crust colours of items/item_loaf with three diagonal cuts in
    pale crumb, under it the cloth, wider than the loaf, with a dull blue hem thread along its front. Flat to look at
    (the loaf has no height of its own beyond the dome), it is no `flat` sprite in the catalog: the table is drawn at
    the y of its cell, the loaf must sort in front of it.

    16 x 10, anchor (14, 10): bottom of the cloth, but not its middle: the anchor lies 6 px right of the centre, so the
    bread lies 6 px LEFT of the cell centre. The cup on haus/table stands at +7 px right of the table's centre and
    would half hide a bread centred on it; left of the cup it has 2 to 3 px of table between them.

    The derivation of the cell and the `lift` (the cell centre is the origin of both sprites, 16 px per cell):
      table  anchor (22, 24) at the centre of its cell (20, 12) = world (328, 200). Its upper face is the pixel rows
             4 to 13, which is y -20 .. -11 from the origin; the cup stands on rows 6 to 9; the front lip is row 14.
      The bread's last row (the outline under the cloth) goes on table row 12, i.e. its lower edge at y -11 from the
      table's origin = world 189. (Then one row of table, row 13, is left in front of it, and the dome reaches up
      to row 3, one pixel above the back edge: it is a lump on the table, not a print.)
      The loaf at the table's own cell would need lift 200 - 189 = 11, but then it sorts equal to the table (y 200) and
      lies under it. Cell (20, 13) has the centre y 216 (> 200, so the loaf is drawn in front of the table): lift
      216 - 189 = 27 (LOAF_LIFT). Not `flat` (z -5 would put it under the table), no shape (nobody bumps into bread)."""
    st = pa.STYLES["tal"]
    c = ms.Canvas(16, 10)
    # the cloth: three rows, the back row narrower; lit at the back, shaded at the front hem
    cloth = c.rect(3, 6, 13, 7) | c.rect(1, 7, 15, 9)
    c.paint(cloth, LINEN, np.where(c.yy < 7, 0.86, np.where(c.yy < 8, 0.68, 0.5)), dither=False)
    c.paint(c.rect(2, 8, 14, 9), LINEN, 0.46, dither=False)  # the hem face
    c.fill(c.rect(3, 8, 13, 9) & ((c.xx % 2) == 1), THREAD)  # the hem thread, stitched
    c.paint(c.rect(1, 7, 2, 9), LINEN, 0.9, dither=False)  # the lit left end
    c.paint(c.rect(7, 6, 8, 7), LINEN, 0.42, dither=False)  # a fold under the loaf
    # the loaf: a flat dome sitting on the cloth, light from the top left
    dome = c.ellipse(7.5, 4.6, 5.8, 3.8) & (c.yy <= 7)
    c.paint(dome, CRUST, 0.3 + 0.7 * c.sphere(5.5, 2.6, 8.0, 6.0), contrast=1.6, dither=False)
    c.paint(dome & (c.yy >= 7), CRUST, 0.05, dither=False)  # the seam where it rests on the cloth
    cuts = interior.seg(c, 4.6, 2.4, 5.9, 4.4, 0.5) | interior.seg(c, 7.2, 1.9, 8.5, 4.1, 0.5) \
        | interior.seg(c, 9.8, 2.4, 11.0, 4.4, 0.5)
    c.fill(cuts & dome, CRUST[3])
    c.outline(st["outline"])
    return c


def build(ms):
    """Registers the three sprites. The shelf and the peg lie flat on the wall (like plan_board); the loaf sorts with the
    furniture; none of them has a shape or a shadow."""
    ms.save("haus", "slot_shelf", slot_shelf(ms), (10, 8), flat=True)
    ms.save("haus", "slot_peg", slot_peg(ms), (4, 0), flat=True)
    ms.save("haus", "loaf", loaf(ms), (14, 10))


def room(ms, shelves=((14, 8), (16, 8)), pegs=((22, 7), (24, 7)), loaf_cell=LOAF_CELL, lift=LOAF_LIFT):
    """The room of the house as haus.txt could show it: the baked floor, shell, shelf, table with the loaf, the bed and
    the rug, two bracket shelves and two pegs on the wall, each with a stand-in picture (the curiosities of items/),
    placed with the offsets of the docstring (6 and -4). Returns the room at its own size, 256 x 192."""
    from PIL import Image
    root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
    props = os.path.join(root, "assets", "generated", "props", "haus")
    items = os.path.join(root, "assets", "generated", "items")
    world = Image.open(os.path.join(root, "assets", "generated", "maps", "haus_ground.png")).convert("RGBA")

    def png(folder, name):
        return Image.open(os.path.join(folder, name + ".png")).convert("RGBA")

    def canvas_img(canvas):
        return Image.fromarray(canvas.rgba().astype(np.uint8), "RGBA")

    def put(img, cell, anchor, lift=0):
        world.alpha_composite(img, (cell[0] * 16 + 8 - anchor[0], cell[1] * 16 + 8 - anchor[1] - lift))

    put(png(props, "shell"), (12, 5), (8, 8))
    put(png(props, "rug"), (17, 11), (22, 11))
    put(png(props, "shelf"), (19, 8), (17, 29))
    put(png(props, "fireplace_lit_0"), (16, 9), (26, 60))
    put(png(props, "bed"), (25, 11), (15, 40))
    put(png(props, "stool"), (16, 12), (6, 12))
    for cell, pic in zip(shelves, ("curiosity_comb", "curiosity_cone")):
        put(canvas_img(slot_shelf(ms)), cell, (10, 8))
        put(png(items, pic), cell, (8, 16), lift=6)
    for cell, pic in zip(pegs, ("curiosity_blue_glass", "curiosity_old_slip")):
        put(png(items, pic), cell, (8, 0), lift=-4)
        put(canvas_img(slot_peg(ms)), cell, (4, 0))
    put(png(props, "table"), TABLE_CELL, (22, 24))
    put(canvas_img(loaf(ms)), loaf_cell, (14, 10), lift=lift)
    return world.crop((192, 80, 448, 272))


def preview(path):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sprites as ms
    from PIL import Image
    scale = 4
    wall, board, floor = (62, 40, 28, 255), (122, 84, 59, 255), (150, 104, 66, 255)
    sheet = Image.new("RGBA", (256 + 40, 80 + 192 + 8), (74, 52, 36, 255))
    x = 8
    for item, bg in ((slot_shelf(ms), wall), (slot_peg(ms), wall), (loaf(ms), board), (loaf(ms), floor)):
        img = Image.fromarray(item.rgba().astype(np.uint8), "RGBA")
        sheet.paste(Image.new("RGBA", (img.width + 8, img.height + 8), bg), (x - 4, 8))
        sheet.alpha_composite(img, (x, 12))
        x += img.width + 16
    sheet.alpha_composite(room(ms), (20, 80))
    sheet.resize((sheet.width * scale, sheet.height * scale), Image.NEAREST).save(path)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
