extends Node2D
## Something to pick up. Params: {"item": "<item id>", "flag": "<area.name>"}. Gone once
## taken; the flag keeps it gone after loading.

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


func _on_interacted(_actor: Node) -> void:
	WorldState.set_flag(flag)
	WorldState.add_item(item)
	queue_free()
