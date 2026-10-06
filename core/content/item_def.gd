class_name ItemDef
extends Resource
## An item or curiosity as content, stored as content/items/<id>.tres.
## Texts come from content/locale/items.csv with derived keys <ID>_NAME and <ID>_DESC
## (e.g. ITEM_STONE_NAME, CURIOSITY_TINY_SPOON_DESC).

enum Kind { ITEM, CURIOSITY }
## Elysia's loot rarity. NONE is shown as "Seltenheit: —" (the stone; Game Bible slice beat 2).
enum Rarity { NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const ICON_DIR := "res://assets/generated/items/"
const RARITY_COLORS: Array[Color] = [
	Color(0.62, 0.62, 0.64),
	Color(0.93, 0.93, 0.9),
	Color(0.5, 0.92, 0.5),
	Color(0.45, 0.7, 1.0),
	Color(0.82, 0.55, 1.0),
	Color(1.0, 0.68, 0.22),
]

@export var id := ""
@export var kind := Kind.ITEM
@export_range(1, 999) var max_stack := 99
@export var rarity := Rarity.COMMON
## An ordinary item that may still stand on a shelf like a curiosity (the stone from Elysia:
## the first thing of one's own in the house).
@export var placeable := false
## Draft content with placeholder text. Must be false before a playtest build.
@export var draft := true


## Curiosities and placeable items can be put into the house's curiosity slots.
func can_be_placed() -> bool:
	return kind == Kind.CURIOSITY or placeable


func name_key() -> String:
	return "%s_NAME" % id.to_upper()


func desc_key() -> String:
	return "%s_DESC" % id.to_upper()


## RARITY_NONE, RARITY_COMMON, … (text, never colour alone).
func rarity_key() -> String:
	return "RARITY_%s" % str(Rarity.keys()[rarity])


func rarity_color() -> Color:
	return RARITY_COLORS[rarity]


## 16x16 icon by convention: assets/generated/items/<id>.png (null if there is none yet).
func icon() -> Texture2D:
	var path := "%s%s.png" % [ICON_DIR, id]
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## Loot fanfare by rarity (tools/audio/make_sfx.py): common .. legendary.
func loot_sound() -> String:
	match rarity:
		Rarity.LEGENDARY:
			return "loot_legendary"
		Rarity.EPIC:
			return "loot_epic"
		Rarity.RARE, Rarity.UNCOMMON:
			return "loot_rare"
	return "loot_common"
