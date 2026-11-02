#!/usr/bin/env python3
"""Procedural character sheets for the look prototype (ADR-017).

Layout matches entities/character/character_sheet.gd: one row per state and facing
(state-major; facings in Facing.Dir order E, SE, S, SW, W, NW, N, NE), frames left to right.
West-facing rows are mirrored east-facing ones. Frame size 24x32, feet on y=30.

Each character is a design (palette plus hair, outfit and accessory choices). Parts are drawn
back to front with 4-tone ramps, light from the top left, clean flat shading (no dithering),
inner contour lines between overlapping parts and a colored outline.

Usage: .venv/bin/python tools/art/make_character.py [--preview scratch/chars.png]
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixelart as pa  # noqa: E402
from make_sprites import Canvas  # noqa: E402
from pixelart import ramp  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FW, FH = 24, 32
FEET = 30
# "look" is the long idle (Game Bible §36 "viele Idle-Animationen"): blink, glance to one
# side, to the other, blink. Its rows come last, so older sheets without them still work.
STATES = [("idle", 2), ("walk", 4), ("run", 4), ("sit", 1), ("look", 4)]
# "work" (two frames, hands in front of the body going up and down) is a state of its own after
# "look", only for the designs that ask for it (design["work"]): Mira mends her net. Sheets
# without it keep their size, and CharacterSheet reads what the texture has.
WORK_STATE = ("work", 2)
FACINGS = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]

DESIGNS = {
    # The protagonist: tidy, a little too perfect for Elysia. Teal jacket, satchel. The only
    # one with dark, side-swept hair and a cowlick that never lies flat: a small asymmetry
    # in a symmetric world (Game Bible §9, "eigener werden").
    "player": {
        "skin": ramp("#8a4b45", "#c47b63", "#eaae8a", "#ffd8b8"),
        "hair": ramp("#110f1c", "#1f1d33", "#33304e", "#4f4a6e", "#8a85ad"),
        "top": ramp("#14304a", "#1d5670", "#2b8a96", "#62c4bb"),
        "inner": ramp("#7d6f86", "#b7aec0", "#e6e0e6", "#ffffff"),
        "belt": ramp("#2a1a1e", "#4c3029", "#76503a", "#a37a52"),
        "pants": ramp("#1d1a33", "#302c50", "#48446e", "#686490"),
        "boots": ramp("#1e1418", "#3d2822", "#664232", "#90674a"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#e88b7e"),
        "outline": pa.hex_rgb("#1d1428"),
        "hair_style": "swept",
        "outfit": "jacket",
        "bag": "satchel",
    },
    # Elysians: flawless white and gold, all a little too alike (Game Bible §9): the same
    # neat, perfectly symmetric bob with a center parting.
    "elysian": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#6a4210", "#a8701c", "#d8a832", "#f4d46a", "#fff2b8"),
        "top": ramp("#7c7096", "#b8b0cc", "#e8e4f0", "#ffffff"),
        "inner": ramp("#8a6a18", "#c4982a", "#ecc84e", "#fff0a0"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#6e6688", "#a49cbc", "#d6d0e4", "#f6f4fb"),
        "boots": ramp("#5a4214", "#94701e", "#c89c34", "#ecd070"),
        "eye": pa.hex_rgb("#2a1f48"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#3a2e58"),
        "hair_style": "neat",
        "outfit": "cape",
        "bag": "none",
    },
    # The baker of Elysia's market: flour-white jacket and apron, a white flat cap of hair, a round and happy man.
    "baker": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#8a8aa0", "#b8b8cc", "#e0e0ec", "#ffffff", "#ffffff"),
        "top": ramp("#8a86a0", "#bfbbd2", "#eceaf4", "#ffffff"),
        "inner": ramp("#a89060", "#d8c088", "#f4e6b0", "#fffbe0"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#6e6688", "#a49cbc", "#d6d0e4", "#f6f4fb"),
        "boots": ramp("#5a4214", "#94701e", "#c89c34", "#ecd070"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#3a2e58"),
        "hair_style": "flattop",
        "outfit": "jacket",
        "build": "round",
        "apron": True,
        "bag": "none",
    },
    # The florist: a rose jacket and a ponytail the colour of the flowers she sells.
    "florist": {
        "skin": ramp("#7a4638", "#b8764f", "#dc9f72", "#f6c9a0"),
        "hair": ramp("#7a2a4a", "#b04a72", "#e07a9c", "#ffb4c8", "#ffe0ea"),
        "top": ramp("#9a3a60", "#d46a8c", "#f4a0ba", "#ffd0dc"),
        "inner": ramp("#e8e4f0", "#f4f0fa", "#ffffff", "#ffffff"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#6e6688", "#a49cbc", "#d6d0e4", "#f6f4fb"),
        "boots": ramp("#7a3a4a", "#b0607a", "#d890a8", "#f4c0d0"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#4a2a48"),
        "hair_style": "ponytail",
        "outfit": "jacket",
        "bag": "none",
    },
    # The tailor: a plum cape with a gold collar, neat dark hair.
    "tailor": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#2a1a3a", "#46305e", "#6a4c88", "#9478b0", "#c0a8d8"),
        "top": ramp("#3a2058", "#5c3a86", "#8460b0", "#b090d8"),
        "inner": ramp("#e8e4f0", "#f4f0fa", "#ffffff", "#ffffff"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#2a2238", "#40345a", "#5c4c80", "#7e6ca4"),
        "boots": ramp("#3a2a58", "#5a4486", "#8068b0", "#a890d4"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#2a1a3e"),
        "hair_style": "neat",
        "outfit": "cape",
        "bag": "none",
    },
    # The merchant (one on each side of the square): a green vest over a cream shirt, a bun, a round belly and an apron with many pockets.
    "merchant": {
        "skin": ramp("#7a4638", "#b8764f", "#dc9f72", "#f6c9a0"),
        "hair": ramp("#2a1a14", "#4a3020", "#6e4a30", "#94683e", "#c09060"),
        "top": ramp("#164a30", "#24703a", "#3f9a44", "#7cc653"),
        "inner": ramp("#9a9284", "#cfc6b4", "#f0e8d6", "#ffffff"),
        "belt": ramp("#5a3a10", "#8a6018", "#c49030", "#ecc860"),
        "pants": ramp("#2a2230", "#403448", "#5a4a62", "#78667e"),
        "boots": ramp("#1e1418", "#3d2822", "#664232", "#90674a"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#1a2a1e"),
        "hair_style": "bun",
        "outfit": "jacket",
        "build": "round",
        "apron": True,
        "bag": "none",
    },
    # The musician: a rust-coloured jacket, swept-back hair, a satchel for the instrument he never needs to tune.
    "musician": {
        "skin": ramp("#4a2a22", "#7a4a36", "#a8704e", "#d29a74"),
        "hair": ramp("#2a1a14", "#4a2e1c", "#7a4c2a", "#a8743e", "#d4a468"),
        "top": ramp("#6a2a18", "#a04a28", "#d27a44", "#f0a868"),
        "inner": ramp("#e8e4f0", "#f4f0fa", "#ffffff", "#ffffff"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#3a2a22", "#5a4234", "#7e6048", "#a48468"),
        "boots": ramp("#3a2418", "#5e3c28", "#8a5c3e", "#b48660"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#3a1e12"),
        "hair_style": "swept",
        "outfit": "jacket",
        "bag": "satchel",
    },
    # The keeper of the hall of mirrors: silver hair, a long cape of mirror-teal; calm, he has looked at the
    # same room for as long as the room has been there and can tell, in a glance, what does not match.
    "keeper": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#6a6c80", "#9496aa", "#c4c6d6", "#e8eaf4", "#ffffff"),
        "top": ramp("#1c4a58", "#2e7480", "#4ea4a8", "#8ad2c8"),
        "inner": ramp("#e8e4f0", "#f4f0fa", "#ffffff", "#ffffff"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#243a46", "#38586a", "#58849a", "#88b4c6"),
        "boots": ramp("#5a4214", "#94701e", "#c89c34", "#ecd070"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#16303a"),
        "hair_style": "neat",
        "outfit": "cape",
        "bag": "none",
    },
    # The mistress of the feast: a magenta jacket with gold, a high ponytail; she has never been
    # anywhere but at the start of the feast, which has no end.
    "festmaster": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#5a1a3a", "#8e2a5e", "#c64a8a", "#ee8cba", "#fcc8de"),
        "top": ramp("#6a1a52", "#a82a82", "#dc52b0", "#f8a0d8"),
        "inner": ramp("#a89060", "#d8c088", "#f4e6b0", "#fffbe0"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#3a1a46", "#5e2a74", "#8a4ea8", "#b88cd0"),
        "boots": ramp("#5a4214", "#94701e", "#c89c34", "#ecd070"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#3a1a3a"),
        "hair_style": "ponytail",
        "outfit": "jacket",
        "bag": "none",
    },
    # The poet: a long coat in night blue, tousled hair.
    "poet": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#3a3a56", "#5a5a80", "#8484aa", "#b0b0d0", "#dcdcf0"),
        "top": ramp("#1a2448", "#2e3e78", "#4a62a8", "#7a92d4"),
        "inner": ramp("#e8e4f0", "#f4f0fa", "#ffffff", "#ffffff"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#1e2238", "#2e3458", "#44507c", "#6674a4"),
        "boots": ramp("#1e2238", "#2e3458", "#44507c", "#6674a4"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#1a1e3a"),
        "hair_style": "tousled",
        "outfit": "cape",
        "bag": "none",
    },
    # The gatekeeper: broad, gold and white like the Elysians; he guards nothing and is very good at it.
    "gatekeeper": {
        "skin": ramp("#4a2a22", "#7a4a36", "#a8704e", "#d29a74"),
        "hair": ramp("#2a2218", "#46382a", "#6a5640", "#927a5a", "#bca482"),
        "top": ramp("#8a86a0", "#bfbbd2", "#eceaf4", "#ffffff"),
        "inner": ramp("#a89060", "#d8c088", "#f4e6b0", "#fffbe0"),
        "belt": ramp("#6a4c14", "#a87c22", "#dcb040", "#fbe48a"),
        "pants": ramp("#6e6688", "#a49cbc", "#d6d0e4", "#f6f4fb"),
        "boots": ramp("#5a4214", "#94701e", "#c89c34", "#ecd070"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#f0a090"),
        "outline": pa.hex_rgb("#3a2e58"),
        "hair_style": "flattop",
        "outfit": "jacket",
        "build": "athletic",
        "bag": "none",
    },
    # The host of Elysia's garden (the numbing protector's cameo, Game Bible §14): warm, round,
    # an apron over a burgundy vest; generous and charming, never sinister. A round belly and
    # a bun on top, so the host never reads as one more Elysian with the same bob.
    "host": {
        "skin": ramp("#8a4b40", "#c47e60", "#ebb08a", "#ffd9b6"),
        "hair": ramp("#2a1a14", "#4a3020", "#6e4a30", "#94683e", "#c09060"),
        "top": ramp("#3a1420", "#64222e", "#8e3840", "#b85a58"),
        "inner": ramp("#9a9284", "#cfc6b4", "#f0e8d6", "#ffffff"),
        "belt": ramp("#5a3a10", "#8a6018", "#c49030", "#ecc860"),
        "pants": ramp("#2a2230", "#403448", "#5a4a62", "#78667e"),
        "boots": ramp("#1e1418", "#3d2822", "#664232", "#90674a"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#f08878"),
        "outline": pa.hex_rgb("#2a1620"),
        "hair_style": "bun",
        "outfit": "jacket",
        "build": "round",
        "apron": True,
        "bag": "none",
    },
    # The child in Elysia (Game Bible §15): plain, a little too big jumper, no gold at all.
    # Smaller body, same head, uncombed hair sticking out. It is the only one there who casts
    # a reflection. The jumper is long and wide at the hem, the sleeves hang over the hands.
    "child": {
        "skin": ramp("#8a5048", "#c8846a", "#eeb894", "#ffe0c4"),
        "hair": ramp("#1e1612", "#3a2a20", "#5a4230", "#7e5e42", "#a88462"),
        "top": ramp("#26303e", "#3c4a5c", "#58687c", "#7e8ea0"),
        "inner": ramp("#3c4a5c", "#58687c", "#7e8ea0", "#a4b2c2"),
        "belt": ramp("#26303e", "#3c4a5c", "#58687c", "#7e8ea0"),
        "pants": ramp("#2a2018", "#40322a", "#5a4838", "#76604a"),
        "boots": ramp("#1a1412", "#2e2420", "#46382e", "#5e4c3e"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#e0907e"),
        "outline": pa.hex_rgb("#161214"),
        "hair_style": "tousled",
        "outfit": "jacket",
        "jumper": True,
        "child": True,
        "bag": "none",
    },
    # The Antreiber (Game Bible §14): helpful, efficient, fast, organised; later exhausting.
    # A faded red training jacket, a sweatband, a stopwatch on a lanyard, a flat-top crew cut,
    # broad shoulders: square and upright where the others are round.
    "antreiber": {
        "skin": ramp("#84483c", "#be7a5e", "#e6ac88", "#fcd6b4"),
        "hair": ramp("#1a1410", "#2e241c", "#46382c", "#64523e", "#8a7458"),
        "top": ramp("#3e1214", "#6a1e1c", "#9a3426", "#c85a3a"),
        "inner": ramp("#7a7c80", "#b4b6ba", "#e2e4e6", "#ffffff"),
        "belt": ramp("#3e1214", "#6a1e1c", "#9a3426", "#c85a3a"),
        "pants": ramp("#14161c", "#22262e", "#343a44", "#4c5460"),
        "boots": ramp("#6a6a6e", "#a2a2a6", "#d6d6d8", "#f6f6f6"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#e07a6a"),
        "outline": pa.hex_rgb("#1c1012"),
        "hair_style": "flattop",
        "outfit": "jacket",
        "build": "athletic",
        "headband": True,
        "stopwatch": True,
        "bag": "none",
    },
    # The Einsiedler (Akt III, W3): old, round, slow and friendly. Grey hair in a knot, an olive wool cape
    # worn soft, a linen shirt, no stopwatch and no hurry.
    "einsiedler": {
        "skin": ramp("#7a4638", "#b8764f", "#dc9f72", "#f6c9a0"),
        "hair": ramp("#4a463e", "#7a7468", "#aaa396", "#d2ccc0", "#f2eee4"),
        "top": ramp("#22261a", "#3c4426", "#667040", "#9aa468"),
        "inner": ramp("#7a6e5a", "#b0a48a", "#dcd2b8", "#f6efdc"),
        "belt": ramp("#2a1a14", "#4a3220", "#765036", "#a07a50"),
        "pants": ramp("#2a2420", "#443a30", "#665848", "#887866"),
        "boots": ramp("#1e1612", "#3a2a20", "#5c4430", "#80624a"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#d97a68"),
        "outline": pa.hex_rgb("#1b1410"),
        "hair_style": "bun", "outfit": "cape", "build": "round", "bag": "none",
    },
    # Mira: practical traveler in the valley. Mustard rain cape, auburn ponytail, backpack.
    "mira": {
        "skin": ramp("#7a4438", "#b56f55", "#dea27e", "#f6cfae"),
        "hair": ramp("#2a0f12", "#5a1f1c", "#8e3524", "#c1552e", "#e88a4a"),
        "top": ramp("#4a3214", "#7c5a1e", "#b08a2c", "#dcc05a"),
        "inner": ramp("#3a2c2a", "#5d4740", "#86685a", "#b08f7a"),
        "belt": ramp("#231518", "#432a22", "#6a4632", "#94694a"),
        "pants": ramp("#1f2224", "#33393c", "#4d5558", "#6e787a"),
        "boots": ramp("#1a1210", "#33241c", "#57402e", "#7d5e44"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#d97a68"),
        "outline": pa.hex_rgb("#1b1210"),
        "hair_style": "ponytail",
        "outfit": "cape",
        "bag": "backpack",
        "work": True,
    },
    # --- Akt IV, the town (S2): people with bad days, full hands and a hat with a feather. None is symmetric:
    # the keys hang on one hip, the note sits behind one ear, the hat is tilted, the basket hangs from one arm.
    # The gatekeeper of the town: a steel-grey coat to the knee with brass buttons, a flat cap, the arms crossed
    # over the chest and a bunch of keys on one hip; the eyebrows say the day has been long (Akt IV, O19).
    "torwaechterin": {
        "skin": ramp("#8a5a54", "#c48a78", "#e8b8a0", "#fbdcc8"),
        "hair": ramp("#1c1a20", "#363440", "#585566", "#827f94", "#b4b1c4"),
        "top": ramp("#1c2128", "#303a46", "#4e5c6c", "#7488a0"),
        "inner": ramp("#7a6e5a", "#b0a48a", "#dcd2b8", "#f6efdc"),
        "belt": ramp("#2a1a14", "#4a3220", "#765036", "#a07a50"),
        "pants": ramp("#16161c", "#26262e", "#3a3a46", "#52525e"),
        "boots": ramp("#14100e", "#2c2018", "#4a3626", "#6e5440"),
        "brass": ramp("#3e260c", "#7c5018", "#bd8a28", "#ecc050"),
        "hat": ramp("#12161c", "#222a34", "#3a4656", "#566a80"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#d08a7c"),
        "outline": pa.hex_rgb("#161a22"),
        "hair_style": "crew",
        "outfit": "jacket",
        "build": "athletic",
        "skirt": 5,
        "coat": True,
        "arms_pose": "crossed",
        "keys": True,
        "hat_kind": "cap",
        "brows": "stern",
        "bag": "none",
    },
    # The one with the list: a dusty-blue cardigan, a cream apron, notes of every colour stuck on him and one behind
    # his ear; his hands are never free (a stack of papers, a parcel on top).
    "gefaelliger": {
        "skin": ramp("#7a4a3c", "#b87a5a", "#e0a47e", "#f8cca6"),
        "hair": ramp("#3a2a18", "#6a4e2a", "#9a7840", "#c8a460", "#e8cf8c"),
        "top": ramp("#1e2e48", "#34507a", "#5882b0", "#8cb4dc"),
        "inner": ramp("#9a9284", "#cfc6b4", "#f0e8d6", "#ffffff"),
        "belt": ramp("#3a2412", "#6a4426", "#9a6c3e", "#c89a60"),
        "pants": ramp("#2a2420", "#443a30", "#665848", "#887866"),
        "boots": ramp("#2a1a14", "#4a3226", "#6e4e3a", "#94705a"),
        "paper": ramp("#8a8678", "#bdb8a6", "#e6e2d2", "#ffffff"),
        "parcel": ramp("#3a2412", "#6a4426", "#9a6c3e", "#c89a60"),
        "notes": [pa.hex_rgb("#f2d24e"), pa.hex_rgb("#ee8aa4"), pa.hex_rgb("#7ac0e8")],
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#e8887a"),
        "outline": pa.hex_rgb("#1c2438"),
        "hair_style": "tousled",
        "outfit": "jacket",
        "carry": True,
        "apron_long": True,
        "ear_item": "note",
        "bag": "none",
    },
    # Lio: a violet jerkin over a cream shirt, a straw-brown hat with a red feather (tilted), a lute on his back,
    # and in the sit row the lute lies across his lap: he sits to play.
    "lio": {
        "skin": ramp("#6a3a2c", "#a2603e", "#cf8c60", "#f0b88a"),
        "hair": ramp("#1a1210", "#33241c", "#553a28", "#7e583a", "#a8825a"),
        "top": ramp("#2a1c5a", "#4a38a0", "#7a64d4", "#aea0f4"),
        "inner": ramp("#9a9284", "#cfc6b4", "#f0e8d6", "#ffffff"),
        "belt": ramp("#4a2a10", "#7a4a1c", "#b0762e", "#dca458"),
        "pants": ramp("#4a3822", "#7a5e3a", "#a8884e", "#d0b070"),
        "boots": ramp("#3a2418", "#5e3c28", "#8a5c3e", "#b48660"),
        "hat": ramp("#3a2a18", "#6a4e2a", "#a07a42", "#d4aa64"),
        "feather": ramp("#6a1210", "#b02a1e", "#e85a30", "#ffa060"),
        "wood": ramp("#3a1e0c", "#74421c", "#b0742e", "#e0a85a"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#e8887a"),
        "outline": pa.hex_rgb("#241040"),
        "hair_style": "tousled",
        "outfit": "jacket",
        "lute": True,
        "hat_kind": "feather",
        "bag": "none",
    },
    # The clerk: a grey dress with a white collar, sleeve guards from elbow to wrist, round glasses, a pencil behind
    # one ear and a stamp with red ink in her left hand; hair in a tight bun.
    "beamtin": {
        "skin": ramp("#8a5a50", "#c28a74", "#e8b498", "#fbd8c0"),
        "hair": ramp("#2e2a2a", "#58504c", "#8a807a", "#b8aea6", "#e0d8d0"),
        "top": ramp("#34322e", "#5a5750", "#8a8678", "#bab5a4"),
        "inner": ramp("#9a9aa6", "#c8c8d2", "#eeeef4", "#ffffff"),
        "belt": ramp("#14100e", "#2a2220", "#443832", "#625248"),
        "pants": ramp("#34322e", "#5a5750", "#8a8678", "#bab5a4"),
        "boots": ramp("#14100e", "#2a2220", "#443832", "#625248"),
        "guards": ramp("#14100e", "#2a2220", "#443832", "#625248"),
        "frame": ramp("#1a1210", "#3a2a1c", "#8a6a38", "#c8a050"),
        "wood": ramp("#3a1e0c", "#74421c", "#b0742e", "#e0a85a"),
        "ink": ramp("#4a0e10", "#8a1c1c", "#c43030", "#ee6a58"),
        "paper": ramp("#8a8678", "#bdb8a6", "#e6e2d2", "#ffffff"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#d89080"),
        "outline": pa.hex_rgb("#26222a"),
        "hair_style": "bun",
        "outfit": "dress",
        "skirt": 6,
        "glasses": True,
        "ear_item": "pencil",
        "stamp": True,
        "bag": "none",
    },
    # A citizen: an oatmeal sweater, indigo trousers, a chin-length bob with a side parting and a wicker basket
    # on one arm with a leek and a loaf in it. Nobody in particular; that is the point.
    "buerger": {
        "skin": ramp("#7a4638", "#b8764f", "#dc9f72", "#f6c9a0"),
        "hair": ramp("#2a1810", "#4e3020", "#7a5236", "#a87a52", "#d0a47c"),
        "top": ramp("#4a3c2a", "#7a6446", "#aa9066", "#d4bc8c"),
        "inner": ramp("#9a9284", "#cfc6b4", "#f0e8d6", "#ffffff"),
        "belt": ramp("#2a1a14", "#4a3220", "#765036", "#a07a50"),
        "pants": ramp("#1a2236", "#2c3858", "#445280", "#6674a0"),
        "boots": ramp("#1e1418", "#3d2822", "#664232", "#90674a"),
        "wicker": ramp("#4a3010", "#7e5a20", "#b88a38", "#e0b860"),
        "leek": ramp("#173020", "#2c5a30", "#4c8a44", "#8cc460"),
        "bread": ramp("#5a3410", "#8e5a1c", "#c48a38", "#ecc070"),
        "eye": pa.hex_rgb("#1e1630"),
        "blush": pa.hex_rgb("#e0907e"),
        "outline": pa.hex_rgb("#2a1e18"),
        "hair_style": "bob",
        "outfit": "jacket",
        "basket": True,
        "bag": "none",
    },
    # Orin (Akt IV, S3): looks like a warrior and keeps flowers. Broad shoulders under leather pauldrons, a short beard, the
    # hair in a knot, a calm stance and no weapon; over the charcoal tunic he wears a green gardener's apron, and a few
    # threads of bast hang from his wrists and hands (he ties bouquets).
    "orin": {
        "skin": ramp("#7a4638", "#b8764f", "#dc9f72", "#f6c9a0"),
        "hair": ramp("#1c120e", "#3a2418", "#5e3e28", "#845a3c", "#b08660"),
        "top": ramp("#1c1e24", "#32363f", "#4d5462", "#737c8c"),
        "inner": ramp("#7a6e5a", "#b0a48a", "#dcd2b8", "#f6efdc"),
        "belt": ramp("#1e120c", "#3e2616", "#6a4428", "#98683e"),
        "pants": ramp("#2a2018", "#463628", "#6a5640", "#8c7860"),
        "boots": ramp("#1e1418", "#3d2822", "#664232", "#90674a"),
        "leather": ramp("#2a1608", "#5a3414", "#8e5c2c", "#c08a4e"),
        "whisker": ramp("#2a180e", "#58361e", "#855630", "#b08052"),
        "smock": ramp("#14301c", "#22562e", "#3a844a", "#68b472"),
        "raffia": ramp("#6a5a34", "#a08c58", "#cdb97c", "#efe3b4"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#d97a68"),
        "outline": pa.hex_rgb("#1c1410"),
        "hair_style": "bun",
        "outfit": "jacket",
        "build": "athletic",
        "bulk": True,
        "apron": True,
        "apron_mat": "smock",
        "pauldrons": True,
        "beard": True,
        "bast": True,
        "bag": "none",
    },
    # Tess (Akt IV, S4): an older craftswoman, sturdy and calm, no pose: she looks like someone who is about to say "Halt mal".
    # Grey hair in a knot under a terracotta kerchief, a pencil behind one ear, a faded blue shirt with the sleeves rolled up, a
    # leather apron down to the knee with a folding rule in its pocket, heavy boots; there is sawdust on her.
    "tess": {
        "skin": ramp("#85493c", "#bd7a58", "#dea17a", "#f5c8a4"),
        "hair": ramp("#85818f", "#a19dad", "#bfbbca", "#dad7e2", "#f4f3f8"),
        "top": ramp("#26384e", "#3f5a78", "#6283a2", "#92b0c8"),
        "inner": ramp("#8a8274", "#bdb4a0", "#e6dcc4", "#faf3dc"),
        "belt": ramp("#1e120c", "#3e2616", "#6a4428", "#98683e"),
        "pants": ramp("#241e14", "#3c3222", "#5a4a34", "#7c6a4c"),
        "boots": ramp("#1a1210", "#33231a", "#54382a", "#7a5440"),
        "hide": ramp("#2a1608", "#5a3414", "#8e5c2c", "#c08a4e"),
        "cloth": ramp("#4a1a12", "#8a3420", "#c05a34", "#ec9460"),
        "rule": ramp("#3a2a08", "#9a7a1c", "#dcb83a", "#f8e07a"),
        "sawdust": ramp("#8a6a3a", "#b8905a", "#dcb87c", "#f4dfa6"),
        "eye": pa.hex_rgb("#1a1226"),
        "blush": pa.hex_rgb("#d98270"),
        "outline": pa.hex_rgb("#22160f"),
        "hair_style": "bun",
        "outfit": "jacket",
        "bulk": True,
        "apron_craft": True,
        "rolled": True,
        "kerchief": True,
        "age_lines": True,
        "sawdust_on": True,
        "ear_item": "pencil",
        "bag": "none",
    },
}

# People of the real world in softer colours (ADR-041): the darkest tones lifted and warmed,
# a little less contrast, outlines a warm brown instead of near black. The Elysians and the
# host keep their crisp, bright perfection on purpose.
SOFT = ("player", "mira", "child", "antreiber", "einsiedler", "torwaechterin", "gefaelliger", "lio", "beamtin",
        "buerger", "orin", "tess")
WARM_DARK = pa.hex_rgb("#4a3028")


def soften(colors, lift=0.16):
    """Lifts dark tones towards a warm brown, more the darker they are; lights stay."""
    c = np.asarray(colors, np.float32)
    lum = (c @ np.array([0.299, 0.587, 0.114], np.float32))[..., None] / 255.0
    pull = lift * (1.0 - lum) ** 1.5
    return np.clip(c + (WARM_DARK + 60.0 - c) * pull, 0, 255)


for _name in SOFT:
    _d = DESIGNS[_name]
    for _key, _value in list(_d.items()):
        if isinstance(_value, np.ndarray) and _value.ndim == 2 and _value.shape[1] == 3:
            _d[_key] = soften(_value)
    _d["outline"] = np.clip(_d["outline"] * 0.55 + WARM_DARK * 0.45, 0, 255)


def pose(state, frame):
    """Per-frame offsets. legs: (forward, lift) per leg; arms: swing per arm; bob: upper body."""
    p = {"bob": 0, "legs": ((0, 0), (0, 0)), "arms": (0, 0), "sit": False, "lean": 0, "hair": 0,
         "gaze": 0, "blink": False, "work": None, "gait": False}
    if state == "work":
        # the hands in front of the body pull the thread, one up while the other goes down;
        # the head nods with it
        p["work"] = frame
        p["bob"] = frame
    elif state == "idle":
        p["bob"] = frame
        p["hair"] = frame
    elif state == "look":
        p["blink"] = frame in (0, 3)
        p["gaze"] = {1: -1, 2: 1}.get(frame, 0)
        p["hair"] = 1 if frame == 2 else 0
    elif state in ("walk", "run"):
        # Footfalls on frames 0 and 2 (the game plays the steps there): one foot lands in
        # front, the other pushes off behind. Frames 1 and 3 are the passing (walk) or airborne
        # (run) frames, mirror images of each other: the leg that pushed off swings forward,
        # the arms swing through the middle. Each leg runs the same four phases, the second
        # one two frames later.
        run = state == "run"
        p["gait"] = True
        big = 3 if run else 2  # stride: foot in front / behind (side view: twice in pixels)
        if run:
            # land, push back through the air, toe-off, swing forward through the air
            phases = ((big, 0), (-2, 2), (-big, 2), (2, 2))
        else:
            # land, roll under the body, toe-off, swing forward lifted
            phases = ((big, 0), (-1, 0), (-big, 1), (1, 1))
        p["legs"] = (phases[frame % 4], phases[(frame + 2) % 4])
        half = int(round(big / 2))
        p["arms"] = {0: (-big, big), 1: (-half, half), 2: (big, -big), 3: (half, -half)}[frame % 4]
        if frame in (0, 2):
            # contact: the body is at its lowest. The cycle's bounce is drawn downwards from
            # the passing frames instead of upwards from the contacts: the feet stay on y=30
            # and the crown stays inside the frame (a body a pixel higher cut the top of the
            # hair off, a flicker of two pixels at every step)
            p["bob"] = 1
        else:
            # passing (walk) or airborne (run, both feet leave the ground by 2 px, knees tucked)
            p["hair"] = 1
        p["lean"] = 1 if run else 0
    elif state == "sit":
        p["sit"] = True
        p["bob"] = 3
    return p


def shift_x(mask, dx):
    """`mask` moved dx pixels to the right; what comes in from the edge is empty."""
    out = np.zeros_like(mask)
    if dx > 0:
        out[:, dx:] = mask[:, :-dx]
    elif dx < 0:
        out[:, :dx] = mask[:, -dx:]
    else:
        out[:] = mask
    return out


def limb(c, x0, y0, x1, y1, width):
    """Mask of a straight limb from (x0, y0) to (x1, y1), `width` pixels wide."""
    m = np.zeros((c.h, c.w), bool)
    steps = max(int(abs(y1 - y0)), int(abs(x1 - x0)), 1)
    for i in range(steps + 1):
        t = i / steps
        x = x0 + (x1 - x0) * t
        y = int(round(y0 + (y1 - y0) * t))
        xa = int(round(x - width / 2))
        if 0 <= y < c.h:
            m[y, max(xa, 0):max(xa + width, 0)] = True
    return m


def seg(c, x0, y0, x1, y1, r):
    """Mask of a thick line segment from (x0, y0) to (x1, y1): every pixel whose centre lies within `r` of it."""
    px, py = c.xx + 0.5, c.yy + 0.5
    dx, dy = x1 - x0, y1 - y0
    t = np.clip(((px - x0) * dx + (py - y0) * dy) / max(dx * dx + dy * dy, 1e-6), 0, 1)
    return np.hypot(px - (x0 + t * dx), py - (y0 + t * dy)) <= r


class Figure:
    """Draws one frame of a design. Parts go back to front; `line=True` adds inner contours."""

    def __init__(self, design, facing, p):
        self.d = design
        self.c = Canvas(FW, FH)
        self.facing = facing
        self.p = p
        self.side = facing == "E"
        self.back = facing in ("N", "NE")
        self.three = facing in ("SE", "NE")
        # three-quarter back view (walking diagonally up): head turned toward the facing,
        # cheek and ear show at its edge, the near arm swings in front of the body
        self.back3 = facing == "NE"
        self.drawn = np.zeros((FH, FW), bool)
        self.hands = []  # (x, y) under each visible hand, for what hangs from it (bast)
        self.arms = []  # (mask, tone, hand row) of each visible near arm, for the sleeves rolled up (Tess)

    def part(self, mask, mat, value, line=False):
        c = self.c
        colors = self.d[mat]
        v = np.broadcast_to(np.asarray(value, np.float32), (FH, FW))
        c.paint(mask, colors, np.clip(v, 0, 1), contrast=3.0, dither=False)
        if line:
            # contour where this part overlaps parts drawn before it
            edge = mask & ~(np.roll(mask, 1, 0) & np.roll(mask, -1, 0) & np.roll(mask, 1, 1)
                            & np.roll(mask, -1, 1))
            other = self.drawn & ~mask
            touching = (np.roll(other, 1, 0) | np.roll(other, -1, 0) | np.roll(other, 1, 1)
                        | np.roll(other, -1, 1))
            c.rgb[edge & touching] = colors[0]
        self.drawn |= mask

    def cyl(self, x0, x1, base=0.18, amt=0.78):
        return base + amt * self.c.cylinder(x0, x1)

    # --- Akt IV: skirts and coats, crossed arms, carried things, the lute, the basket and the stamp ---
    def skirt(self, tx0, tx1, ty1):
        """A skirt or the tail of a long coat: from the waist down to the knee, flaring, swinging with the front leg."""
        d, c, p = self.d, self.c, self.p
        rows = d["skirt"]
        top = ty1 - 1
        bottom = ty1 + rows
        swing = p["legs"][0][0] * 0.4 if (p["gait"] and self.side) else 0.0
        mid = (tx0 + tx1) / 2.0 + swing * np.clip((c.yy - top) / rows, 0, 1)
        half = (tx1 - tx0) / 2.0 + 0.2
        flare = np.clip((c.yy - top) * (0.5 if self.side else 0.45), 0, 4)
        skirt = (np.abs(c.xx + 0.5 - mid) <= half + flare) & (c.yy >= top) & (c.yy < bottom)
        self.part(skirt, "top", self.cyl(tx0 - 3, tx1 + 3, 0.12, 0.8), line=True)
        self.part(skirt & (c.yy == bottom - 1), "top", 0.14)  # the hem, a darker line
        if d.get("coat") and not self.back and not self.side:
            # the front seam of the coat and its brass buttons
            seam = (np.abs(c.xx + 0.5 - (mid + (1 if self.three else 0))) < 0.6) & (c.yy >= ty1 - 4) & (c.yy < bottom - 1)
            self.part(seam, "top", 0.06)
            for by in (ty1 - 2, ty1 + 1):
                dot = c.rect(mid - 0.5 + (1 if self.three else 0), by, mid + 0.5 + (1 if self.three else 0), by + 1)
                self.part(dot, "brass", 0.85)

    def apron_long(self, tx0, tx1, ty1):
        """A long apron down to the knees over the trousers, with one big pocket and notes sticking out of it."""
        c, d = self.c, self.d
        if self.side:
            ap = c.rect(tx1 - 4.5, ty1 - 2, tx1 + 1.0, ty1 + 4)
        else:
            sh = 1 if self.three else 0
            ap = c.rect(tx0 + 1 + sh, ty1 - 2, tx1 - 0.5, ty1 + 4)
        self.part(ap, "inner", self.cyl(tx0, tx1, 0.45, 0.5), line=True)
        self.part(ap & (c.yy == ty1 + 3), "inner", 0.3)
        if not self.side:
            pocket = c.rect(tx0 + 2.5, ty1 + 0.5, tx0 + 6.5, ty1 + 2.5)
            self.part(pocket, "inner", 0.3)
            self.part(c.rect(tx0 + 2.5, ty1 + 0.5, tx0 + 6.5, ty1 + 1.0), "inner", 0.9)
            c.fill(c.rect(tx0 + 3, ty1 - 0.5, tx0 + 4, ty1 + 0.5), d["notes"][1])
            c.fill(c.rect(tx0 + 5, ty1 - 1, tx0 + 6, ty1 + 0.5), d["notes"][0])

    def keys(self, tx0, tx1, ty1, side):
        """A ring with a few keys on one hip."""
        c = self.c
        x = (tx0 + (3 if side else 1)) if not self.three else tx0 + 1
        ring = c.rect(x, ty1 - 2, x + 2, ty1 - 1) | c.rect(x, ty1 - 1, x + 1, ty1)
        self.part(ring, "brass", 0.9)
        for k, (dx, ln) in enumerate(((0, 4), (2, 3))):
            key = c.rect(x + dx, ty1, x + dx + 1, ty1 + ln)
            self.part(key, "brass", 0.85 - 0.3 * k)
            self.part(c.rect(x + dx + 1, ty1 + ln - 1, x + dx + 2, ty1 + ln), "brass", 0.5)

    def sleeve(self, mask, tone, hand=None, guard_from=None):
        """An arm of the coat; with `guards` the part from `guard_from` down is the sleeve guard."""
        d, c = self.d, self.c
        self.part(mask, "top", tone, line=True)
        if ("guards" in d) and guard_from is not None:
            self.part(mask & (c.yy >= guard_from), "guards", tone - 0.05, line=True)
        if hand is not None:
            self.part(hand, "skin", tone)

    def arms_crossed(self, cx, tx0, tx1, ty0, lean, ox):
        """Arms folded over the chest. Front: the upper arms hang from the shoulders and the forearms lie across,
        the right one over the left, its hand tucked under the other arm. Side: one forearm lies across the chest."""
        c = self.c
        if self.side:
            x0 = cx - 0.5 + lean
            upper = limb(c, x0, ty0 + 1, x0 - 0.5, ty0 + 5, 2)
            fore = c.rect(x0 - 2, ty0 + 4, x0 + 4.5, ty0 + 6.5)
            self.sleeve(upper | fore, 0.65, guard_from=ty0 + 4)
            self.part(c.rect(x0 + 3.5, ty0 + 4, x0 + 5.5, ty0 + 6.5), "skin", 0.65)
            return
        shift = 1 if self.three else 0
        left_upper = c.rect(tx0 - 2 - ox, ty0 + 1, tx0 - ox, ty0 + 6)
        left_fore = c.rect(tx0 - 2 - ox, ty0 + 5, tx1 - 3 + shift, ty0 + 7.5)
        right_upper = c.rect(tx1 + ox, ty0 + 1, tx1 + 2 + ox, ty0 + 5)
        right_fore = c.rect(tx0 + 2, ty0 + 4, tx1 + 2 + ox, ty0 + 6.5)
        self.sleeve(left_upper | left_fore, 0.72, guard_from=ty0 + 4)
        self.sleeve(right_upper, 0.4, guard_from=ty0 + 4)
        self.sleeve(right_fore, 0.56, guard_from=ty0 + 4)
        self.part(c.rect(tx0 + 0.5, ty0 + 4, tx0 + 2.5, ty0 + 6.5), "skin", 0.6)

    def arms_carry(self, cx, tx0, tx1, ty0, lean):
        """Both arms hold a stack of papers with a parcel on top, notes of every colour sticking out of it."""
        d, c = self.d, self.c
        if self.side:
            x0 = cx - 0.5 + lean
            arm = limb(c, x0, ty0 + 1, x0 + 1, ty0 + 6, 2)
            bx0, bx1 = x0 + 1.5, x0 + 7.5
            by0 = ty0 + 3
            far = False
        else:
            shift = 1 if self.three else 0
            for ax, tone in ((tx0 - 1, 0.72), (tx1 + 1, 0.4)):
                self.sleeve(limb(c, ax, ty0 + 1, ax, ty0 + 7, 2), tone, guard_from=ty0 + 4)
            bx0, bx1 = cx - 4.5 + shift, cx + 4.5 + shift
            by0 = ty0 + 3
            far = True
        # the stack: sheets (light rows with a darker edge), a cord, a parcel on top with a string
        stack = c.rect(bx0, by0 + 2, bx1, by0 + 6)
        rows = ((c.yy - by0 - 2) % 2) == 1
        self.part(stack, "paper", np.where(rows, 0.5, 0.9), line=True)
        self.part(stack & (c.yy == by0 + 5), "paper", 0.18)
        parcel = c.rect(bx0 + 1, by0, bx1 - 1.5, by0 + 2)
        self.part(parcel, "parcel", np.where(c.yy == by0, 0.9, 0.55), line=True)
        self.part(c.rect((bx0 + bx1) / 2 - 0.5, by0, (bx0 + bx1) / 2 + 0.5, by0 + 2), "belt", 0.25)
        for k, col in enumerate(d["notes"]):  # the notes: little coloured corners along the edge of the stack
            nx = bx0 + 1 + k * (bx1 - bx0 - 3) / 2.0
            c.fill(c.rect(round(nx), by0 + 3, round(nx) + 2, by0 + 4), col)
        # the hands at the ends of the stack
        if far:
            self.part(c.rect(bx0 - 1, by0 + 4, bx0 + 1, by0 + 6.5), "skin", 0.7)
            self.part(c.rect(bx1 - 1, by0 + 4, bx1 + 1, by0 + 6.5), "skin", 0.4)
        else:
            self.part(c.rect(bx0 - 1.5, by0 + 4, bx0 + 1, by0 + 6.5), "skin", 0.65)

    def lute_shape(self, bx, by, rx, ry, nx, ny, head, hands=()):
        """A lute: neck, body with a sound hole and a bridge, a bent head."""
        c = self.c
        body = c.ellipse(bx, by, rx, ry)
        neck = seg(c, bx, by, nx, ny, 1.0)
        self.part(neck & ~body, "wood", 0.2 + 0.2 * (c.xx < bx), line=True)
        self.part(seg(c, nx, ny, head[0], head[1], 1.0), "wood", 0.1, line=True)
        self.part(body, "wood", 0.3 + 0.7 * c.sphere(bx - 1.2, by - 1.4, rx * 1.2, ry * 1.2), line=True)
        self.part(body & ~c.ellipse(bx, by, rx - 0.9, ry - 0.9), "wood", 0.18)  # the rim
        c.fill(c.ellipse(bx + 0.4, by - 0.4, 1.2, 1.2), self.d["wood"][0])  # the sound hole
        for hx, hy in hands:
            self.part(c.rect(hx, hy, hx + 2, hy + 2), "skin", 0.6, line=True)

    def lute_back(self, cx, ty0, ty1, lean):
        """Slung on the back: from the front only the bulge of the body at the hip and the neck over the shoulder;
        in profile the body hangs behind the back and the neck rises behind the head."""
        if self.side:
            self.lute_shape(cx - 4.0 + lean, ty0 + 5.5, 2.6, 4.6, cx - 5.5 + lean, ty0 - 4.5, (cx - 7.5 + lean, ty0 - 6))
        else:
            sh = 1 if self.three else 0
            self.lute_shape(cx - 3.2 + sh, ty1 - 1.5, 3.8, 4.4, cx + 7.0 + sh, ty0 - 4.5, (cx + 9.0 + sh, ty0 - 5.5))

    def strap(self, tx0, tx1, ty0, ty1, torso):
        c = self.c
        strap = np.abs((c.xx + 0.5 - (tx1 - 1)) + (c.yy - ty0) * 0.9) <= 0.7
        strap &= (c.yy >= ty0) & (c.yy < ty1 - 1) & torso
        self.part(strap, "belt", 0.55)

    def lute_back_view(self, cx, ty0, ty1):
        """Seen from behind the lute lies across the back, its neck up over one shoulder."""
        sh = 1 if self.back3 else 0
        self.lute_shape(cx - 0.5 + sh, ty0 + 5.5, 4.6, 4.8, cx + 4.5 + sh, ty0 - 4.5, (cx + 6.5 + sh, ty0 - 5.5))

    def lute_lap(self, cx, ty0, ty1, lean):
        """Played sitting down: the body in the lap, the neck pointing out to one side, a hand on it and one over the strings."""
        if self.side:
            self.lute_shape(cx + 2.0 + lean, ty1 - 1.5, 4.4, 3.4, cx + 8.5 + lean, ty0 + 2.5, (cx + 9.0 + lean, ty0 + 0.5),
                            hands=((cx + 6.0 + lean, ty0 + 5), (cx + 1.0 + lean, ty1 - 4)))
        elif self.back:
            self.lute_shape(cx - 7.5, ty0 + 6, 3.8, 3.0, cx - 10, ty0 + 2, (cx - 10.5, ty0 + 0.5))
        else:
            sh = 1 if self.three else 0
            self.lute_shape(cx + 2.5 + sh, ty1 - 1.5, 4.8, 3.6, cx - 9.0 + sh, ty0 + 1.5, (cx - 10.0 + sh, ty0 - 1.0),
                            hands=((cx - 6.0 + sh, ty0 + 3), (cx + 0.5 + sh, ty1 - 4)))

    def basket(self, cx, tx0, tx1, ty0, lean):
        """A wicker basket hanging from the near hand, a leek and a loaf sticking out of it."""
        c = self.c
        if self.side:
            x = cx - 0.5 + lean
        else:
            x = tx1 + 1.5 + (1 if self.three else 0)
        top = ty0 + 8
        body = c.rect(x - 3.5, top, x + 3.5, top + 4)
        body &= ~((c.yy == top + 3) & ((c.xx < x - 3) | (c.xx >= x + 2.5)))
        weave = ((c.xx.astype(int) + c.yy.astype(int)) % 2) == 0
        self.part(c.rect(x - 1.5, top - 3, x + 0.5, top), "leek", 0.7, line=True)  # a leek
        self.part(c.rect(x - 0.5, top - 4, x + 0.5, top - 2), "leek", 0.35)
        loaf = c.ellipse(x + 1.8, top - 0.2, 2.2, 1.5)
        self.part(loaf, "bread", 0.2 + 0.7 * c.sphere(x + 1, top - 1, 2.6, 2.0), line=True)
        self.part(body, "wicker", np.where(weave, 0.62, 0.42) + 0.2 * (c.yy < top + 1), line=True)
        handle = (np.abs(np.hypot(c.xx + 0.5 - x, (c.yy + 0.5 - top) * 1.4) - 3.0) < 0.7) & (c.yy < top)
        self.part(handle, "wicker", 0.85)

    def stamp(self, tx0, ty0, lean, ox, swing):
        """A rubber stamp in the near hand: a wooden handle, a pad with red ink below it."""
        c = self.c
        if self.side:
            x = int(round(0.5 + 12.5 + lean + swing[0]))  # the near hand of the side view
            y = ty0 + 6
        else:
            x = tx0 - 1 - ox
            y = ty0 + 6 + int(np.clip(swing[0], -1, 2))
        self.part(c.rect(x - 1, y - 2, x + 1, y), "wood", 0.8, line=True)  # the knob
        self.part(c.rect(x - 2, y + 2, x + 2, y + 3), "wood", 0.5)  # the plate
        self.part(c.rect(x - 2, y + 3, x + 2, y + 4), "ink", 0.7, line=True)  # the pad with red ink
        self.part(c.rect(x - 1, y, x + 1, y + 2), "skin", 0.65)  # the hand around the handle

    def hat(self, hx, hy):
        """A hat on top of the hair: a cap with a visor or a brimmed hat with a feather."""
        d, c = self.d, self.c
        kind = d["hat_kind"]
        side, back, three = self.side, self.back, self.three
        sh = 0.5 if (three or self.back3) else 0
        if kind == "cap":
            crown = c.ellipse(hx - 0.5 + sh, hy - 4.6, 6.0, 3.2) & (c.yy < hy - 2.6)
            self.part(crown, "hat", 0.3 + 0.6 * c.sphere(hx - 2, hy - 7, 8, 5), line=True)
            if side:
                visor = c.rect(hx + 1, hy - 3.0, hx + 8, hy - 1.8)
            elif back:
                visor = c.rect(hx - 6, hy - 3.0, hx + 6, hy - 2.0)
            else:
                visor = c.rect(hx - 6.2 + sh, hy - 3.0, hx + 6.2 + sh, hy - 1.8)
            self.part(visor, "hat", np.where(c.yy < hy - 2.4, 0.62, 0.15), line=True)
            if not back:
                badge = c.rect(hx + (2.5 if side else -0.5) + sh, hy - 5.8, hx + (4 if side else 1.5) + sh, hy - 4.2)
                self.part(badge, "belt", 0.9)
            return
        # a brimmed hat, tilted: lower on one side
        tilt = 0.14
        cxh = hx - (0.5 if side else 0) + sh
        crown = c.ellipse(cxh, hy - 4.8, 5.6, 4.0) & (c.yy < hy - 3)
        brim_rx = 7.6 if side else 8.8
        centre = hy - 3.2 + (c.xx + 0.5 - hx) * tilt
        brim = (((c.xx + 0.5 - (hx + (1.0 if side else 0))) / brim_rx) ** 2 + ((c.yy + 0.5 - centre) / 1.9) ** 2) <= 1.0
        self.part(brim, "hat", 0.55 + 0.3 * c.sphere(hx - 3, hy - 4, 10, 4), line=True)
        self.part(crown, "hat", 0.35 + 0.6 * c.sphere(cxh - 2, hy - 7, 7, 5), line=True)
        band = crown & (c.yy >= hy - 5.0 + (c.xx + 0.5 - hx) * tilt)
        self.part(band, "hat", 0.1)
        self.part(band & (c.yy < hy - 4.0 + (c.xx + 0.5 - hx) * tilt), "belt", 0.7)
        # the feather: stuck in the band, sweeping out and back with a droop at the tip
        if side:
            x0, y0, x1, y1 = hx - 3.0, hy - 4.6, hx - 8.4, hy - 7.4
        else:
            x0, y0, x1, y1 = hx + 3.2, hy - 4.8, hx + 8.2, hy - 8.2
        feather = seg(c, x0, y0, (x0 + x1) / 2, (y0 + y1) / 2 - 1.0, 1.0) | seg(c, (x0 + x1) / 2, (y0 + y1) / 2 - 1.0, x1, y1, 0.9)
        self.part(feather, "feather", 0.35 + 0.6 * c.sphere(x0, y0 - 4, 9, 9), line=True)
        self.part(seg(c, x0, y0, x1, y1, 0.3) & feather, "feather", 0.95)  # the shaft catches the light

    # --- Akt IV, S3: Orin's leather pauldrons, bast threads and short beard ---
    def pauldrons(self, cx, tx0, tx1, ty0, lean):
        """Domes of leather over the shoulders, standing out to the sides of the trunk: the near one in profile, both from
        the front and the back. A lit crown, a lame across them, a dark rim and one rivet."""
        c = self.c
        if self.side:
            spots = [(cx + 0.3 + lean, 3.2)]
        else:
            sh = 0.5 if self.three else 0.0
            spots = [(tx0 - 1.6 + sh, 3.2), (tx1 + 1.6 + sh, 3.2)]
        for px, rx in spots:
            dome = c.ellipse(px, ty0 + 2.4, rx, 3.4) & (c.yy >= ty0 - 0.5)
            self.part(dome, "leather", 0.4 + 0.55 * c.sphere(px - 1.5, ty0 - 0.5, rx * 1.7, 5.5), line=True)
            self.part(dome & (c.yy == ty0 + 2), "leather", 0.18)  # the lame between the plates
            self.part(dome & (c.yy >= ty0 + 4), "leather", 0.1)  # the rim
            c.fill(c.rect(round(px - 1.5), ty0 + 0.5, round(px - 1.5) + 1, ty0 + 1.5) & dome, self.d["leather"][3])  # a rivet

    def bast_threads(self):
        """A band of bast round each wrist and a few threads hanging from the hands."""
        c, d = self.c, self.d
        for hx_, hy_ in self.hands:
            x = int(round(hx_))
            band = c.rect(x - 1, hy_ - 3, x + 1, hy_ - 2)
            c.fill(band & self.drawn, d["raffia"][2])
            for dx, ln, tone in ((-1, 3, 2), (0, 2, 3)):
                c.fill(c.rect(x + dx, hy_, x + dx + 1, hy_ + ln), d["raffia"][tone])

    def beard(self, hx, hy):
        """A short beard, a shade lighter than the hair: a cap over the chin and jaw with sideburns down the cheeks; the
        eyes and the blush (rows hy + 1 to hy + 3) stay clear and the mouth is a skin pixel in the middle."""
        c = self.c
        head = c.ellipse(hx, hy, 6.3, 6.0)
        if self.side:
            jaw = head & (c.yy >= hy + 4) & (c.xx + 0.5 >= hx - 2.5)
            burn = head & (c.yy >= hy) & (c.yy < hy + 4) & (c.xx + 0.5 >= hx - 3.5) & (c.xx + 0.5 < hx - 1.5)
            chin = c.rect(hx + 0.5, hy + 6, hx + 3.5, hy + 7)
            gap = c.rect(hx + 3, hy + 4, hx + 5, hy + 5)
        else:
            shift = 0.5 if self.three else 0.0
            jaw = head & (c.yy >= hy + 4)
            burn = head & (c.yy >= hy) & (c.yy < hy + 4) & (np.abs(c.xx + 0.5 - hx - shift) > 4.7)
            chin = c.rect(hx - 2 + shift, hy + 6, hx + 2 + shift, hy + 7)
            gap = c.rect(hx - 1 + shift, hy + 4, hx + 1 + shift, hy + 5)
        beard = (jaw | burn | chin) & ~gap
        self.part(beard, "whisker", 0.3 + 0.6 * c.sphere(hx - 2.5, hy - 1.0, 9, 8), line=False)

    # --- Akt IV, S4: Tess's leather apron, rolled sleeves, sawdust and kerchief ---
    def apron_craft(self, tx0, tx1, ty0, ty1):
        """A craftswoman's leather apron: a bib from the chest on two straps over the shoulders, down to the knee, with a
        deep pocket at the hip and a folding rule sticking out of it (a few segments, yellow with a dark joint)."""
        c, d = self.c, self.d
        sh = 1 if self.three else 0
        if self.side:
            apron = c.rect(tx1 - 3.5, ty0 + 2, tx1 + 1.0, ty1 + 4)
            self.part(apron, "hide", self.cyl(tx0, tx1, 0.4, 0.5), line=True)
            self.part(apron & (c.yy == ty1 + 3), "hide", 0.15)
            self.part(c.rect(tx1 - 2.5, ty1 - 1, tx1 + 0.5, ty1 + 1), "hide", 0.22)  # the pocket seen from the side
            c.fill(c.rect(tx1 - 1.5, ty1 - 3, tx1 - 0.5, ty1 - 1), d["rule"][3])
            return
        if self.back:
            # from behind only the straps, crossing between the shoulder blades, and the tie of the waist
            for k in range(2):
                strap = np.abs((c.xx + 0.5 - (cx_ := (tx0 + tx1) / 2.0 + sh)) + (1 - 2 * k) * (c.yy - ty0) * 0.8) <= 0.7
                self.part(strap & (c.yy >= ty0) & (c.yy < ty0 + 5) & (np.abs(c.xx + 0.5 - cx_) < 4.5), "belt", 0.4 + 0.1 * k)
            self.part(c.rect(tx0 + sh, ty0 + 5, tx1 + sh, ty0 + 6), "belt", 0.5)
            c.fill(c.rect(cx_ - 1.5, ty0 + 6, cx_ - 0.5, ty0 + 8), d["belt"][2])
            c.fill(c.rect(cx_ + 0.5, ty0 + 6, cx_ + 1.5, ty0 + 7.5), d["belt"][1])
            return
        bib = c.rect(tx0 + 2.5 + sh, ty0 + 2, tx1 - 2.5 + sh, ty0 + 5)
        skirt = c.rect(tx0 + 0.5 + sh, ty0 + 5, tx1 - 0.0 + sh, ty1 + 4)
        apron = bib | skirt
        self.part(apron, "hide", self.cyl(tx0, tx1, 0.4, 0.5), line=True)
        self.part(apron & (c.yy == ty1 + 3), "hide", 0.15)  # the hem
        self.part(c.rect(tx0 + 0.5 + sh, ty0 + 5, tx1 + sh, ty0 + 6), "belt", 0.55)  # the tie round the waist
        for sx in (tx0 + 3 + sh, tx1 - 3 + sh):  # the two straps up to the shoulders
            self.part(c.rect(sx, ty0, sx + 1, ty0 + 3), "belt", 0.35)
        pocket = c.rect(tx1 - 5.5 + sh, ty1 - 1, tx1 - 1.0 + sh, ty1 + 2)
        self.part(pocket, "hide", 0.24, line=True)
        self.part(c.rect(tx1 - 5.5 + sh, ty1 - 1, tx1 - 1.0 + sh, ty1), "hide", 0.7)  # its lit edge
        for k, (dx, tone) in enumerate(((0, 3), (1, 1))):  # the folding rule: two segments sticking out at an angle
            c.fill(c.rect(tx1 - 4.5 + sh + dx, ty1 - 3 - (k == 0), tx1 - 3.5 + sh + dx, ty1 - 1 + (k == 1)), d["rule"][tone])

    def rolled_sleeves(self, ty0):
        """The sleeves rolled up above the elbow: a lit roll, then bare forearms."""
        c = self.c
        for arm, tone, _end in self.arms:
            self.part(arm & (c.yy == ty0 + 3), "top", min(tone + 0.3, 1.0))  # the roll
            self.part(arm & (c.yy >= ty0 + 4), "skin", tone)

    def sawdust(self, ty0, ty1):
        """Sawdust on the shoulders and the forearms, a few specks on the apron: single pale pixels that move with the trunk."""
        c = self.c
        xs, ys = c.xx.astype(int), c.yy.astype(int) - ty0
        top = (((xs * 5 + ys * 3) % 9) == 0) & (ys >= 0) & (ys < 4)
        low = (((xs * 7 + ys * 2) % 29) == 3) & (ys >= 4) & (ys < ty1 - ty0 + 1)
        c.fill((top | low) & c.a, self.d["sawdust"][3])

    def kerchief(self, hx, hy, hair, head):
        """A kerchief over the crown and the knot of hair under it (a bulge at the back of the head): it ends in a straight
        band across the brow, the grey hair shows at the temples and the nape; in profile and from behind it is tied at the
        back with two short tails."""
        c = self.c
        dome = c.ellipse(hx - (0.5 if self.side else 0.0), hy - 1.0, 7.0, 6.9)
        if self.back:
            region = (dome | hair | head) & (c.yy < hy + 1.2) & c.ellipse(hx, hy - 0.4, 7.2, 7.6)
            region |= c.ellipse(hx, hy - 5.6, 3.6, 2.6)
        elif self.side:
            region = (dome & (c.yy < hy - 1.6)) | ((hair | head) & (c.xx + 0.5 < hx - 2.5) & (c.yy < hy + 0.8))
            region |= c.ellipse(hx - 4.4, hy - 4.4, 3.0, 3.0)
        else:
            region = dome & (c.yy < hy - 1.6)
        v = 0.45 + 0.5 * c.sphere(hx - 2.5, hy - 5, 10, 8)
        self.part(region, "cloth", v, line=True)
        # the lower edge of the band is a shade darker; a fold runs back from the temple
        lower = region & ~np.roll(region, -1, 0) & (c.yy > hy - 5)
        hem = region & np.roll(lower, -1, 0) & ~lower  # the folded hem: a lit line over the dark edge
        self.part(hem, "cloth", 0.82)
        self.part(lower, "cloth", 0.14)
        if not self.back:
            fold = region & (np.abs((c.xx + 0.5 - hx) * 0.55 - (c.yy + 0.5 - (hy - 3.6))) < 0.5) & (c.xx + 0.5 > hx - 1.0)
            self.part(fold, "cloth", 0.22)
        if self.back or self.side:
            kx = hx - (6.4 if self.side else 0.0)
            ky = hy - (1.6 if self.side else 0.2)
            self.part(c.rect(kx - 1.5, ky - 1, kx + 1.5, ky + 1.5), "cloth", 0.55, line=True)  # the knot
            self.part(c.rect(kx - 1.5, ky + 1.5, kx - 0.5, ky + 4.5), "cloth", 0.3)  # and its two tails
            self.part(c.rect(kx + 0.5, ky + 1.5, kx + 1.5, ky + 3.5), "cloth", 0.5)
        else:
            # a small tie at the temple, the two ends sticking out
            kx = hx + 5.4 + (0.5 if self.three else 0.0)
            self.part(c.rect(kx - 1.5, hy - 3.6, kx + 1.5, hy - 1.6), "cloth", 0.6, line=True)
            self.part(c.rect(kx + 1.5, hy - 4.4, kx + 3.0, hy - 3.0), "cloth", 0.5, line=True)
            self.part(c.rect(kx + 0.5, hy - 1.6, kx + 2.0, hy + 0.4), "cloth", 0.3, line=True)

    def face_extras(self, hx, hy, ey, eyes):
        """Brows, glasses: what sits on the face after the eyes."""
        d, c = self.d, self.c
        if d.get("brows") == "stern":
            brow = d["hair"][0]
            if self.side:
                c.fill(c.rect(eyes[0] - 1, ey - 1, eyes[0] + 2, ey), brow)
            else:
                for k, ex in enumerate(eyes):
                    inner = 1 if k == 0 else -1  # towards the nose: the inner end is lower
                    c.fill(c.rect(ex - (0 if inner > 0 else 1), ey - 1, ex + 1 + (1 if inner > 0 else 0), ey), brow)
                    c.fill(c.rect(ex - inner, ey - 2, ex - inner + 1, ey - 1), brow)
        if d.get("glasses"):
            frame = d["frame"]
            lens = [(eyes[0],)] if self.side else [(e,) for e in eyes]
            for (ex,) in lens:
                c.fill(c.rect(ex - 1, ey - 1, ex + 2, ey), frame[3])
                c.fill(c.rect(ex - 1, ey + 2, ex + 2, ey + 3), frame[2])
                c.fill(c.rect(ex - 1, ey, ex, ey + 2) | c.rect(ex + 1, ey, ex + 2, ey + 2), frame[2])
            if self.side:
                c.fill(c.rect(eyes[0] - 4, ey, eyes[0] - 1, ey + 1), frame[2])  # the temple
            elif len(eyes) == 2:
                c.fill(c.rect(eyes[0] + 2, ey, eyes[1] - 1, ey + 1), frame[2])  # the bridge

    def draw(self):
        d, c, p = self.d, self.c, self.p
        side, back, three = self.side, self.back, self.three
        b = p["bob"]
        lean = p["lean"] if (side or three) else 0
        cx = 12.5 if (side or three) else 12.0
        kid = 5 if d.get("child") else 0  # a child: same head, shorter body
        hip = 23 + b + (2 if kid else 0)
        ty0, ty1 = 15 + b + kid, 23 + b + (2 if kid else 0)
        # Akt IV: crossed arms only while standing or sitting, carried things keep the arms still, the lute
        # changes from the back to the lap when he sits
        crossed = d.get("arms_pose") == "crossed" and not p["gait"]
        carry = d.get("carry", False)
        lute = d.get("lute", False)
        lap = lute and p["sit"]
        swing = (0, 0) if (carry or d.get("basket")) else p["arms"]

        # backpack behind the body (front views) / ponytail behind the head
        if d["bag"] == "backpack" and not back:
            bx = cx - 0.5 if not side else cx - 4 + lean
            pack = c.rect(bx - 4, ty0 + 0, bx + 4, ty0 + 7) if not side else c.rect(bx - 3, ty0, bx + 1, ty0 + 8)
            self.part(pack, "belt", 0.45)

        # legs
        if p["sit"]:
            if side:
                for k in (0, 1):
                    thigh = limb(c, cx - 1 + k, hip, cx + 4 + k, hip + 1, 3)
                    shin = limb(c, cx + 4 + k, hip + 1, cx + 4 + k, FEET, 3)
                    self.part(thigh | shin & (c.yy < FEET - 2), "pants", 0.45 + 0.15 * k)
                    self.part(shin & (c.yy >= FEET - 2), "boots", 0.5)
            else:
                for k, lx in enumerate((cx - 2, cx + 2)):
                    leg = limb(c, lx, hip, lx, hip + 3, 3)
                    boot = limb(c, lx, hip + 3, lx, hip + 5, 3)
                    self.part(leg, "pants", 0.6 - 0.15 * k, line=True)
                    self.part(boot, "boots", 0.55 - 0.1 * k)
        else:
            order = [(1, -0.12), (0, 0.12)] if side else [(0, 0.1), (1, -0.05)]
            for li, tint in order:
                fwd, lift = p["legs"][li]
                if side:
                    # the far leg hangs from a hip a pixel further front and reaches a little
                    # shorter: with both legs alike, near-forward and far-forward were the same
                    # silhouette and the four frames read as a two-frame wobble
                    far = li == 1 and p["gait"]
                    hx = cx - 0.5 + lean + (1 if far else 0)
                    fx = hx + fwd * (1.5 if far else 2)
                else:
                    hx = cx - 2 + 4 * li
                    fx = hx + (fwd * 0.5 if three else 0)
                    if self.back3:
                        # stepping up and to the side: the stride also shows sideways
                        fx = hx + fwd * 0.8 + 0.5
                leg = limb(c, hx, hip, fx, FEET - lift, 3)
                boot = leg & (c.yy >= FEET - lift - 2)
                if side:
                    boot |= c.rect(int(round(fx + 1)), FEET - lift - 1, int(round(fx + 3)), FEET - lift + 1)
                self.part(leg & ~boot, "pants", self.cyl(hx - 2, hx + 2) + tint - 0.1)
                self.part(boot, "boots", 0.5 + tint + 0.25 * (c.yy == FEET - lift - 2))

        if lute and not back and not lap:
            self.lute_back(cx, ty0, ty1, lean)
        if lute and back and lap:
            self.lute_lap(cx, ty0, ty1, lean)

        # far arm (side view) behind the torso
        work = p["work"]
        if side and not (crossed or carry):
            sw = swing[1]
            if work is None:
                far = limb(c, cx + lean, ty0 + 1, cx + lean + sw, ty0 + 7, 2)
                hand_y = ty0 + 6
            else:
                # both hands reach forward at chest height, the far one a step behind the near one
                far = limb(c, cx + lean, ty0 + 1, cx + lean + 3, ty0 + 4 + 2 * work, 2)
                hand_y = ty0 + 4 + 2 * work
            self.part(far, "top", 0.2)
            self.part(far & (c.yy >= hand_y), "skin", 0.35)

        # torso
        if side:
            tx0, tx1 = cx - 3 + lean, cx + 3 + lean
        elif three:
            tx0, tx1 = cx - 4, cx + 3
        else:
            tx0, tx1 = cx - 4, cx + 4
        build = d.get("build", "")
        if build == "round":  # a round belly: a pixel wider, in profile it shows in front
            if side:
                tx1 += 1
            else:
                tx0, tx1 = tx0 - 1, tx1 + 1
        if d.get("bulk"):  # a mighty trunk: a pixel wider on both sides
            tx0, tx1 = tx0 - 1, tx1 + 1
        torso = c.rect(tx0, ty0, tx1, ty1)
        torso &= ~((c.yy == ty0) & ((c.xx < tx0 + 1) | (c.xx >= tx1 - 1)))
        if build == "round" and side:
            torso &= ~((c.xx >= tx1 - 1) & ((c.yy < ty0 + 2) | (c.yy >= ty1 - 1)))
        arm_out = 0
        if build == "athletic":
            # broad shoulders over a narrow waist; the arms hang a pixel out from the body
            if side:
                torso |= c.rect(tx1, ty0 + 1, tx1 + 1, ty0 + 4)  # chest
            else:
                torso |= c.rect(tx0 - 1, ty0 + 1, tx1 + 1, ty0 + 3)
                arm_out = 1
        if d["outfit"] == "cape":
            # wide cape over the shoulders, flaring toward the hem
            flare = (c.yy - ty0) * 0.35
            cape = (c.xx >= tx0 - 1 - flare) & (c.xx < tx1 + 1 + flare) & (c.yy >= ty0) & (c.yy < ty1)
            cape &= ~((c.yy == ty0) & ((c.xx < tx0) | (c.xx >= tx1)))
            torso = cape
        hem = c.rect(tx0 - 0.5, ty1 - 1, tx1 + 0.5, ty1)
        jumper = d.get("jumper", False)
        if jumper:  # a jumper a size too big: long and wide at the hem
            hem = c.rect(tx0 - 1, ty1 - 1, tx1 + 1, ty1 + 1)
        self.part(torso | hem, "top", self.cyl(tx0 - 1, tx1 + 1, 0.15, 0.8), line=True)
        if d.get("skirt"):
            self.skirt(tx0, tx1, ty1)
        if d.get("outfit") == "dress" and not back:
            # a plain round collar in white, a small brooch under it
            mid = cx + (1 if three else 0) + (1 if side else 0)
            collar = (np.abs(c.xx + 0.5 - mid) <= (2.6 if not side else 1.6)) & (c.yy >= ty0) & (c.yy < ty0 + 2)
            self.part(collar, "inner", 0.75)
            self.part(c.rect(mid - 0.5, ty0 + 2, mid + 0.5, ty0 + 3), "belt", 0.9)
            self.part(c.rect(tx0, ty1 - 3, tx1, ty1 - 2), "belt", 0.5)
        if not back and d["outfit"] == "jacket":
            # open collar with a light shirt, jacket seam, belt with buckle
            if side:
                shirt = c.rect(tx1 - 2, ty0 + 1, tx1 - 1, ty0 + 5)
            else:
                mid = cx + (1 if three else 0)
                shirt = (np.abs(c.xx + 0.5 - mid) <= (3.2 - (c.yy - ty0) * 0.7)) & (c.yy >= ty0) & (c.yy < ty0 + 5)
            self.part(shirt, "inner", 0.75)
            belt = c.rect(tx0, ty1 - 3, tx1, ty1 - 2)
            self.part(belt, "belt", 0.5)
            if not side:
                self.part(c.rect(cx - 0.5 + (1 if three else 0), ty1 - 3, cx + 1.5 + (1 if three else 0), ty1 - 2),
                          "inner", 0.95)
        if d.get("stopwatch") and not back:
            # a stopwatch on a lanyard, on the chest
            mid = cx + (1 if three else 0) + (1 if side else 0)
            lanyard = (np.abs(np.abs(c.xx + 0.5 - mid) - (3 - (c.yy - ty0) * 0.6)) < 0.5) & (c.yy >= ty0) & (c.yy < ty0 + 4)
            self.part(lanyard & torso, "boots", 0.3)
            self.part(c.ellipse(mid, ty0 + 5, 1.6, 1.6), "boots", 0.85, line=True)
        if d.get("apron") and not back:
            ax0 = tx0 + (1 if not side else 2)
            apron = c.rect(ax0, ty0 + 3, tx1 - (1 if not side else 0), ty1 + 1)
            if side:
                apron = c.rect(tx1 - 3, ty0 + 3, tx1 + 0.5, ty1 + 1)
            apron_mat = d.get("apron_mat", "inner")
            self.part(apron, apron_mat, self.cyl(tx0, tx1, 0.45, 0.5), line=True)
            if not side:
                self.part(c.rect(ax0 - 1, ty0 + 3, tx1 - 0, ty0 + 4), "belt", 0.6)
        if d.get("keys") and not back:
            self.keys(tx0, tx1, ty1, side)
        if d.get("apron_long") and not back:
            self.apron_long(tx0, tx1, ty1)
        if d.get("apron_craft"):
            self.apron_craft(tx0, tx1, ty0, ty1)
        if d["outfit"] == "cape" and not back:
            # cape clasp and a dark inner lining at the opening
            mid = cx + (1 if three else 0)
            if not side:
                opening = (np.abs(c.xx + 0.5 - mid) <= 0.6 + (c.yy - ty0) * 0.25) & (c.yy >= ty0 + 2) & (c.yy < ty1)
                self.part(opening, "inner", 0.35)
                self.part(c.rect(mid - 1, ty0 + 1, mid + 1, ty0 + 2), "belt", 0.9)
        if d["bag"] == "satchel":
            if not side:
                # strap from the right shoulder to the left hip
                strap = np.abs((c.xx + 0.5 - (tx1 - 1)) + (c.yy - ty0) * 0.9) <= 0.7
                strap &= (c.yy >= ty0) & (c.yy < ty1 - 1) & torso
                self.part(strap, "belt", 0.55)
                if not back or self.back3:
                    self.part(c.rect(tx0 - 2, ty1 - 4, tx0 + 1, ty1), "belt", 0.6, line=True)
            else:
                self.part(c.rect(tx0 - 2, ty1 - 5, tx0 + 1, ty1 - 1), "belt", 0.55, line=True)
        if lute and not lap and not back and not side:
            self.strap(tx0, tx1, ty0, ty1, torso)
        if lute and not lap and back:
            self.lute_back_view(cx, ty0, ty1)
        if d["bag"] == "backpack" and back:
            self.part(c.rect(cx - 4, ty0 + 1, cx + 4, ty0 + 8), "belt", self.cyl(cx - 5, cx + 5, 0.2, 0.6), line=True)
            self.part(c.rect(cx - 3, ty0 + 2, cx + 3, ty0 + 3), "belt", 0.8)

        # near arms
        if crossed and not back:
            self.arms_crossed(cx, tx0, tx1, ty0, lean, arm_out)
        elif carry and not back:
            self.arms_carry(cx, tx0, tx1, ty0, lean)
        elif side:
            sw = swing[0]
            if work is None:
                near = limb(c, cx - 0.5 + lean, ty0 + 1, cx - 0.5 + lean + sw, ty0 + 7, 2)
                hand_y = ty0 + (7 if jumper else 6)
            else:
                near = limb(c, cx - 0.5 + lean, ty0 + 1, cx + 3.5 + lean, ty0 + 6 - 2 * work, 2)
                hand_y = ty0 + 6 - 2 * work
            self.sleeve(near, 0.65, guard_from=ty0 + 4)
            self.part(near & (c.yy >= hand_y), "skin", 0.65)
            self.hands.append((cx - 0.5 + lean + sw + 1, hand_y + 1))
            self.arms.append((near, 0.65, hand_y))
        else:
            for k, ax in enumerate((tx0 - 1 - arm_out, tx1 + 1 + arm_out)):
                sw = swing[k]
                # seen from the front a swing only shortens or lengthens the arm a little
                end = ty0 + (4 if d.get("child") else 6) + int(np.clip(sw, -1, 2))
                arm = limb(c, ax, ty0 + 1, ax, end, 2)
                hand = limb(c, ax, end, ax, end + 1, 2)
                if work is not None:
                    # working: the forearms cross in front of the body, the hands alternate
                    # (from behind only the elbows move, the hands are hidden by the body)
                    wx = cx + (-1.5 if k == 0 else 1.5) + (1 if three else 0)
                    end = ty0 + 6 - 2 * (work if k == 0 else 1 - work)
                    arm = limb(c, ax, ty0 + 1, wx, end, 2)
                    hand = limb(c, wx, end, wx, end + 1, 2)
                    if back:
                        hand = np.zeros_like(hand)
                tone = 0.72 if k == 0 else 0.4
                if three and k == 1:
                    tone = 0.3
                if self.back3:
                    # far arm half hidden behind the back, near arm light and in front
                    tone = 0.25 if k == 0 else 0.7
                    if k == 0:
                        end = min(end, ty0 + 5)
                        arm = limb(c, ax + 1, ty0 + 2, ax + 1, end, 2)
                        hand = limb(c, ax + 1, end, ax + 1, end + 1, 2)
                cuff = arm & (c.yy == end - 1)
                self.sleeve(arm, tone, guard_from=ty0 + 4)
                self.part(cuff, "guards" if ("guards" in d) else "top", tone + 0.2)
                if jumper:  # the sleeve hangs over the hand
                    self.part(hand & (c.yy == end), "top", tone + 0.2)
                    hand = hand & (c.yy > end)
                self.part(hand, "skin", tone)
                self.hands.append((ax + 1, end + 1))
                self.arms.append((arm, tone, end))

        if d.get("pauldrons"):
            self.pauldrons(cx, tx0, tx1, ty0, lean)
        if d.get("bast"):
            self.bast_threads()
        if d.get("rolled"):
            self.rolled_sleeves(ty0)
        if d.get("sawdust_on"):
            self.sawdust(ty0, ty1)
        if lap and not back:
            self.lute_lap(cx, ty0, ty1, lean)
        if d.get("basket"):
            self.basket(cx, tx0, tx1, ty0, lean)
        if d.get("stamp") and not back:
            self.stamp(tx0, ty0, lean, arm_out, swing)

        self.head(cx, lean, b)
        c.outline(d["outline"])
        return c

    def head(self, cx, lean, b):
        d, c, p = self.d, self.c, self.p
        side, back, three = self.side, self.back, self.three
        hx = cx + (0.5 if side else 0) + lean + (0.5 if self.back3 else 0)
        hy = 10.0 + b + (5 if d.get("child") else 0)
        hb = p["hair"]  # hair settles a frame later than the head (bounce)
        # neck
        self.part(c.rect(hx - 1.5, hy + 4, hx + 1.5, hy + 6), "skin", 0.3)
        head = c.ellipse(hx, hy, 6.3, 6.0)
        self.part(head, "skin", 0.48 + 0.5 * c.sphere(hx - 1.5, hy - 1.5, 7, 7))
        hair_v = 0.1 + 0.72 * c.sphere(hx - 2.5, hy - 4, 9, 8)
        style = d["hair_style"]
        nape = {"swept": 2.5, "neat": 3.5, "crew": 1.0, "flattop": 1.0, "bun": 2.0}.get(style, 4)
        if back:
            hair = head | c.ellipse(hx, hy - 0.6, 7.2, 6.6)
            hair |= c.rect(hx - 6, hy + 1, hx + 6, hy + nape + hb) & c.ellipse(hx, hy + 1, 7.0, 6.0)
            if style == "swept":
                # short, tapered nape: the neck shows below it
                hair &= ~(c.rect(0, hy + 4, FW, FH) & (np.abs(c.xx + 0.5 - hx) < 2.5))
            if self.back3:
                # the face turns away to the upper right: cheek, jaw and ear at the edge
                hair &= ~(c.ellipse(hx + 5.2, hy + 2.2, 2.6, 3.6) & (c.yy >= hy - 0.5))
                ear = c.rect(hx + 3.5, hy + 0.5, hx + 4.5, hy + 2.5)
                hair &= ~ear
        elif side:
            cap = c.ellipse(hx - 0.5, hy - 1.2, 7.3, 6.5) & ((c.yy < hy - 1.0) | (c.xx < hx - 0.5))
            back_hair = c.rect(hx - 6.5, hy - 2, hx - 1.5, hy + nape + hb) & c.ellipse(hx - 1, hy + 0.5, 7.2, 7.2)
            if style in ("neat", "bob"):
                fringe = c.rect(hx + 1, hy - 2.5, hx + 6.3, hy - 0.8)
            elif style == "swept":
                # fringe swept forward over the brow, ending in a point
                fringe = c.rect(hx + 1, hy - 3, hx + 6.5, hy - 1) | c.rect(hx + 5, hy - 1, hx + 7, hy + 0.5)
            elif style in ("crew", "flattop"):
                fringe = c.rect(hx + 1, hy - 2.8, hx + 6.3, hy - 2)
            elif style == "bun":
                cap &= (c.yy < hy - 2.6) | (c.xx < hx + 2)  # combed back: the brow stays free
                fringe = np.zeros_like(cap)
            else:
                fringe = c.rect(hx + 1, hy - 2, hx + 6.5, hy - 0.5) & ((c.xx.astype(int) % 2) == 0)
            hair = cap | back_hair | fringe
        else:
            cap = c.ellipse(hx - (0.5 if three else 0), hy - 1.3, 7.3, 6.5) & (c.yy < hy - 1.8)
            if style == "bun":
                # combed back from a high hairline, short at the temples (bun on top, below)
                cap &= (c.yy < hy - 2.6) | (np.abs(c.xx + 0.5 - hx) > 4.5)
            if style == "neat":
                # straight, even bangs and locks down to the jaw on both sides
                bangs = c.rect(hx - 5.5, hy - 2.5, hx + 5.5, hy - 0.8)
                locks = c.rect(hx - 7, hy - 2, hx - 4.6, hy + 3.5) | c.rect(hx + 4.6, hy - 2, hx + 7, hy + 3.5)
            elif style == "swept":
                # one long fringe swept across the forehead, low over one brow, short sides
                lean_x = (c.xx + 0.5 - (hx - 5)) / 10.0
                edge = hy + 0.6 - np.clip(lean_x, 0, 1) * 3.2
                bangs = c.rect(hx - 5.8, hy - 2.5, hx + 5.5, hy + 1) & (c.yy < edge)
                bangs |= c.rect(hx - 6, hy - 1, hx - 4.5, hy + 1.5)  # tip over the brow
                locks = c.rect(hx - 7, hy - 2, hx - 5, hy + 1.5 + hb * 0.5) | c.rect(hx + 5, hy - 2, hx + 7, hy + 1)
            elif style in ("crew", "flattop"):
                # short crew cut: a thin straight hairline, the sides cropped close
                bangs = c.rect(hx - 5.5, hy - 2.5, hx + 5.5, hy - 1.8)
                locks = c.rect(hx - 6.8, hy - 2, hx - 5.6, hy) | c.rect(hx + 5.6, hy - 2, hx + 6.8, hy)
            elif style == "bun":
                bangs = np.zeros_like(cap)
                locks = c.rect(hx - 7, hy - 2.5, hx - 5.4, hy + 1.5) | c.rect(hx + 5.4, hy - 2.5, hx + 7, hy + 1.5)
            elif style == "bob":
                # a side parting: the fringe falls over the left brow a pixel lower, the left lock is a pixel longer
                bangs = c.rect(hx - 5.8, hy - 2.5, hx + 5.5, hy - 0.8) | c.rect(hx - 5.8, hy - 0.8, hx - 2, hy + 0.2)
                locks = c.rect(hx - 7, hy - 2, hx - 4.6, hy + 4) | c.rect(hx + 4.6, hy - 2, hx + 7, hy + 2.5)
                locks |= c.rect(hx - 7.6, hy + 3, hx - 6.4, hy + 5)  # the left lock flicks out at its end
            else:
                # pointed bangs: a zigzag edge over the forehead
                zig = ((c.xx.astype(int) + (1 if three else 0)) % 3)
                bangs = c.rect(hx - 5.5, hy - 2.5, hx + 5.5, hy + 0.2 - (zig == 1) * 1.8 - (zig == 2) * 0.9)
                locks = c.rect(hx - 7, hy - 2, hx - 4.6, hy + 4 + hb) | c.rect(hx + 4.6, hy - 2, hx + 7, hy + 4 + hb)
            if three:
                locks &= c.xx < hx
            hair = cap | (bangs & c.ellipse(hx, hy, 7.3, 7.3)) | (locks & c.ellipse(hx, hy + 0.5, 7.4, 7.4))
        if style == "swept":
            # the cowlick: one strand on the crown that never lies flat
            tip = 1 if side else 0
            hair |= c.rect(hx - 0.5 - tip, hy - 8, hx + 1 - tip, hy - 6)
            hair |= c.rect(hx + 1 - tip, hy - 9 + hb * 0, hx + 2.5 - tip, hy - 8)
        if style == "tousled":
            # a strand sticking up and a few spikes on the crown
            hair |= c.rect(hx + (0 if not side else -1), hy - 8 + hb * 0, hx + 1 + (0 if not side else -1), hy - 6)
            hair |= c.rect(hx - 3, hy - 7, hx - 2, hy - 6)
            # and tufts sticking out over the ears: nobody combed it
            if side:
                hair |= c.rect(hx - 8, hy - 2, hx - 6.5, hy)
            else:
                hair |= c.rect(hx - 8.3, hy - 3, hx - 6.6, hy - 1)
                if not three:
                    hair |= c.rect(hx + 6.6, hy - 2, hx + 8.3, hy)
        if style == "flattop":
            # a flat top: a square crown a pixel higher than the round head, soft corners
            x0 = hx - (6.5 if side else 5.5)
            top = c.rect(x0, hy - 8.6, hx + 5.5, hy - 3)
            top &= ~((c.yy < hy - 7.6) & ((c.xx < x0 + 1) | (c.xx >= hx + 4.5)))
            hair |= top
        bun = np.zeros_like(hair)
        if style == "bun" and not d.get("kerchief"):  # under a kerchief the knot is not a bump of its own
            # a round bun on the top of the head, a little back, tied off (see below)
            bx = hx - (2.5 if side else 0)
            bun = c.ellipse(bx, hy - 7.9, 2.4, 1.8)
            hair |= bun
        if style == "ponytail":
            tail_x = hx - 6 if side else hx + (5 if three else 0)
            if back or side:
                tail = limb(c, tail_x, hy - 2, tail_x - (1 if side else 0), hy + 6 + hb, 3)
                hair |= tail
            hair |= c.ellipse(hx, hy - 6.5, 2.2, 1.4)  # tie on top-back
        self.part(hair, "hair", hair_v, line=True)
        # glossy highlight band across the crown
        ring = np.abs(np.hypot(c.xx + 0.5 - (hx + 1), c.yy + 0.5 - (hy + 3)) - 8.4) < 0.55
        shine = hair & ring & (c.xx >= hx - 4) & (c.xx < hx) & (c.yy < hy - 3)
        c.rgb[shine] = d["hair"][4]
        if bun.any():
            # the tie: the bun's lowest row in the darkest tone, so it sits on the head as a
            # knot of its own instead of drawing the crown out into a point
            tie = bun & ~np.roll(bun, -1, 0)
            c.rgb[tie] = d["hair"][0]
        if style == "swept" and not back:
            # one lighter strand following the sweep of the fringe
            strand = hair & (np.abs((c.xx + 0.5 - hx) * 0.32 + (c.yy + 0.5 - (hy - 2.2))) < 0.5)
            strand &= (c.xx >= hx - 4) & (c.xx < hx + 4) & (c.yy >= hy - 4)
            c.rgb[strand] = d["hair"][3]
        if style == "bob" and not side and not back:
            # the side parting: a light line from the crown down over the left brow
            part = hair & (np.abs((c.xx + 0.5 - (hx - 2.0)) - (c.yy - (hy - 7.0)) * -0.35) < 0.55) & (c.yy < hy - 1) & (c.yy >= hy - 7)
            c.rgb[part] = d["hair"][4]
        if style == "neat" and not side:
            # the perfect center parting
            part = hair & (np.abs(c.xx + 0.5 - hx) < 0.6) & (c.yy < hy - 3) & (c.yy >= hy - 7)
            c.rgb[part] = d["hair"][1]
        if d.get("kerchief"):
            self.kerchief(hx, hy, hair, head)
        if d.get("headband"):
            # a sweatband across the brow, all the way round, but one pixel inside the head:
            # the head's own edge pixels (and the outline around them) stay, so the band never
            # pokes out of the silhouette; a muted light grey, not white, so it sits on the hair
            sil = hair | head
            inside = sil & shift_x(sil, 1) & shift_x(sil, -1)
            band = (c.yy >= hy - 3.6) & (c.yy < hy - 2.2) & inside
            self.part(band, "inner", 0.6)
            self.part(band & (c.yy >= hy - 2.8), "top", 0.75)
        if d.get("beard") and not back:
            self.beard(hx, hy)
        if d.get("hat_kind"):
            self.hat(hx, hy)
        item = d.get("ear_item")
        if item:
            # a note or a pencil tucked behind one ear (the character's left: right of the picture from the front)
            ex = hx - (2.5 if side else (-6 if back else 5.2))
            if item == "note":
                self.part(c.rect(ex, hy - 1, ex + 2.5, hy + 2.5), "paper", 0.85, line=True)
                c.fill(c.rect(ex + 0.5, hy, ex + 2, hy + 0.5), d["notes"][0])
            else:
                self.part(c.rect(ex + 0.5, hy - 3, ex + 1.5, hy + 1), "belt", 0.2)
                c.fill(c.rect(ex + 0.5, hy - 3, ex + 1.5, hy - 1), np.array([230, 190, 70], np.float32))
                c.fill(c.rect(ex + 0.5, hy - 1, ex + 1.5, hy), np.array([230, 150, 150], np.float32))
        if self.back3:
            c.fill(c.rect(hx + 3.5, hy + 0.5, hx + 4.5, hy + 2.5), d["skin"][1])  # ear
        if not back:
            ey = int(round(hy + 1))
            if side:
                eyes = [int(round(hx + 3))]
            elif three:
                eyes = [int(round(hx - 1)), int(round(hx + 3))]
            else:
                eyes = [int(round(hx - 3)), int(round(hx + 2))]
            eyes = [ex + p["gaze"] for ex in eyes]
            for ex in eyes:
                if p["blink"]:
                    # closed lids: a short dark line, skin where the eye was
                    c.fill(c.rect(ex, ey, ex + 1, ey + 1), d["skin"][2])
                    c.fill(c.rect(ex, ey + 1, ex + 1, ey + 2), d["eye"])
                    continue
                c.fill(c.rect(ex, ey, ex + 1, ey + 2), d["eye"])
                c.fill(c.rect(ex, ey, ex + 1, ey + 1), np.array([250, 248, 255], np.float32) * 0.6 + d["eye"] * 0.4)
            # no nose: a lone pixel read as a speck in the face and, in profile, as a little
            # outlined box (playtest 10.10.); eyes and blush carry the face
            if not side:
                c.fill(c.rect(eyes[0] - 1, ey + 2, eyes[0], ey + 3), d["blush"])
                c.fill(c.rect(eyes[-1] + 1, ey + 2, eyes[-1] + 2, ey + 3), d["blush"])
            if d.get("age_lines") and not side:
                # the lines of a face that has laughed outdoors for sixty years: one at the outer corner of each eye
                for ex, out in ((eyes[0], -1), (eyes[-1], 1)):
                    c.fill(c.rect(ex + 2 * out - (out < 0), ey + 1, ex + 2 * out - (out < 0) + 1, ey + 2), d["skin"][1])
            if d.get("brows") or d.get("glasses"):
                self.face_extras(hx, hy, ey, eyes)


def states_of(design):
    return STATES + ([WORK_STATE] if design.get("work") else [])


def sheet(design):
    states = states_of(design)
    cols = max(n for _, n in states)
    rows = len(states) * len(FACINGS)
    out = np.zeros((rows * FH, cols * FW, 4), np.float32)
    row = 0
    for state, frames in states:
        for facing in FACINGS:
            for f in range(frames):
                src = {"W": "E", "SW": "SE", "NW": "NE"}.get(facing, facing)
                img = Figure(design, src, pose(state, f)).draw().rgba()
                if src != facing:
                    img = img[:, ::-1]
                out[row * FH:(row + 1) * FH, f * FW:(f + 1) * FW] = img
            row += 1
    return out


def preview(designs, sheets, path):
    from PIL import Image
    tiles = []
    for design, data in zip(designs, sheets):
        states = states_of(design)
        img = Image.fromarray(data.astype(np.uint8), "RGBA")
        strip = Image.new("RGBA", (8 * 4 * FW + 7 * 8, len(states) * FH), (96, 140, 110, 255))
        r = 0
        for si, (_, frames) in enumerate(states):
            for fi in range(8):
                for f in range(frames):
                    tile = img.crop((f * FW, r * FH, (f + 1) * FW, (r + 1) * FH))
                    strip.alpha_composite(tile, (fi * (4 * FW + 8) + f * FW, si * FH))
                r += 1
        tiles.append(strip)
    out = Image.new("RGBA", (tiles[0].width, sum(t.height + 8 for t in tiles)), (96, 140, 110, 255))
    y = 0
    for t in tiles:
        out.alpha_composite(t, (0, y))
        y += t.height + 8
    out.resize((out.width * 3, out.height * 3), Image.NEAREST).save(path)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--preview", help="write a scaled preview of all frames")
    args = ap.parse_args()
    made = []
    for name, design in DESIGNS.items():
        data = sheet(design)
        path = os.path.join(ROOT, "assets", "generated", "characters", name + ".png")
        pa.save_rgba(path, data)
        made.append(data)
        print("wrote", os.path.relpath(path, ROOT))
    if args.preview:
        preview(list(DESIGNS.values()), made, args.preview)
