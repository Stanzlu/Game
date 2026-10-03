class_name ItemDef
extends Resource
## An item or curiosity as content, stored as content/items/<id>.tres.
## Texts come from content/locale/items.csv with derived keys <ID>_NAME and <ID>_DESC
## (e.g. ITEM_STONE_NAME, CURIOSITY_TINY_SPOON_DESC).

enum Kind { ITEM, CURIOSITY }

@export var id := ""
@export var kind := Kind.ITEM
@export_range(1, 999) var max_stack := 99
## Draft content with placeholder text. Must be false before a playtest build.
@export var draft := true


func name_key() -> String:
	return "%s_NAME" % id.to_upper()


func desc_key() -> String:
	return "%s_DESC" % id.to_upper()
