class_name ShelfMenu
extends MenuLayer
## What stands on a shelf or hangs on a peg in the house (Act IV, S8; docs/akt4/REGIONSBRIEFE.md
## O9, O14): the curiosities the player carries, one row each, and a row to take back what is there.
## The menu changes the house through WorldState and nothing else; no number, no praise.

## The slot this menu is for (shelf_3, shelf_4, wall_1, wall_2).
var slot_id := ""
## True once something was put on the slot.
var placed := false


## The items that may stand on a shelf and are carried now, in a fixed order.
static func carried() -> PackedStringArray:
	var found: PackedStringArray = []
	for item_id: String in WorldState.state.inventory:
		var def := ContentDB.item(item_id)
		if def != null and def.can_be_placed() and WorldState.has_item(item_id):
			found.append(item_id)
	found.sort()
	return found


func _ready() -> void:
	title_key = "SHELF_TITLE"
	panel_width = 240
	super()


func _build() -> void:
	var here := WorldState.curiosity_in(slot_id)
	if not here.is_empty():
		list.add_action("SHELF_TAKE", _take_back)
	for item_id in carried():
		if item_id == here:
			continue
		var label := tr(ContentDB.item(item_id).name_key())
		list.add_action("", func() -> void: _place(item_id), true, label)
	list.add_action("MENU_BACK", close)


func _place(item_id: String) -> void:
	placed = WorldState.place_curiosity(slot_id, item_id)
	close()


func _take_back() -> void:
	WorldState.take_curiosity(slot_id)
	close()
