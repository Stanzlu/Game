class_name CuriositySlot
extends Decor
## A place in the house for a curiosity (Act IV, S8; docs/akt4/REGIONSBRIEFE.md O9, O14): a
## board or a peg on the wall that Tess hung with her. Looking at it opens the menu of what the
## player carries (`ShelfMenu`); what stands there shows as the item's little picture above the
## board. Nothing counts and nothing is said about what was chosen. Params as for Decor
## ("sprite", "if", "unless") plus "slot" (shelf_3, shelf_4, wall_1, wall_2), "radius" (the
## reach of the look, 20) and "hang" (pixels from the cell's foot to the middle of the picture,
## 12).

const DIALOGUE := "res://content/dialogue/akt4/heimkehr.dialogue"
const ICON_DIR := "res://assets/generated/items/"

var slot_id := ""
var _icon: Sprite2D
var _busy := false


func apply_params(params: Dictionary) -> void:
	super(params)
	slot_id = str(params.get("slot", ""))
	_icon = Sprite2D.new()
	_icon.name = "Icon"
	_icon.position = Vector2(0, -float(params.get("hang", 12.0)))
	_icon.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(_icon)
	var area := Talk.add_area(
		self, "INTERACT_EXAMINE", float(params.get("radius", 20.0)), Vector2(0, 8)
	)
	area.interacted.connect(_on_interacted)
	WorldState.house_changed.connect(_refresh)
	_refresh()


## The item that stands here ("" if none).
func item_id() -> String:
	return WorldState.curiosity_in(slot_id)


func _refresh() -> void:
	var item := item_id()
	var path := ICON_DIR + item + ".png"
	_icon.texture = (
		load(path) as Texture2D if not item.is_empty() and ResourceLoader.exists(path) else null
	)
	_icon.visible = _icon.texture != null


func _on_interacted(actor: Node) -> void:
	_use.call_deferred(actor)


func _use(actor: Node) -> void:
	if _busy:
		return
	_busy = true
	var here := item_id()
	if ShelfMenu.carried().is_empty() and here.is_empty():
		await Talk.present(self, DIALOGUE, "slot_nothing", actor)
		_busy = false
		return
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP)
	var menu := ShelfMenu.new()
	menu.name = "ShelfMenu"
	menu.slot_id = slot_id
	scene.add_child(menu)
	var tree := get_tree()
	tree.paused = true
	menu.open()
	await menu.closed
	tree.paused = false
	var placed := menu.placed
	menu.queue_free()
	if placed:
		await Talk.present(self, DIALOGUE, "slot_placed", actor)
	_busy = false
