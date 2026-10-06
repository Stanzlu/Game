extends Node2D
## Something to pick up. Params: {"item": "<item id>", "flag": "<area.name>"}, optional
## "sprite" (prop catalog) instead of the pebble. Gone once taken; the flag keeps it gone
## after loading.

var item := ""
var flag := ""

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)


func apply_params(params: Dictionary) -> void:
	item = str(params.get("item", ""))
	flag = str(params.get("flag", ""))
	if not ContentDB.has_item(item) or flag.is_empty():
		Log.error(Log.Category.CONTENT, "invalid pickup", {"item": item, "flag": flag})
	elif WorldState.has_flag(flag):
		queue_free()
		return
	if params.has("sprite"):
		var entry := PropCatalog.entry(str(params["sprite"]))
		if not entry.is_empty():
			var sprite: Sprite2D = $Sprite
			sprite.texture = PropCatalog.texture_for(entry, global_position)
			var anchor: Array = entry.get("anchor", [0, 0])
			sprite.centered = false
			sprite.offset = -Vector2(float(anchor[0]), float(anchor[1]))


func _on_interacted(_actor: Node) -> void:
	WorldState.set_flag(flag)
	WorldState.add_item(item)
	queue_free()
