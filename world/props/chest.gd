extends StaticBody2D
## Elysia's treasure chest. Params: {"flag": "<area.name>", "actions": [...]} (StateActions,
## e.g. loot, gold, XP, a quest step). Opens once; the flag keeps it open after loading.

var flag := ""
var actions: Array = []
var is_open := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	_interactable.interacted.connect(_on_interacted)


func apply_params(params: Dictionary) -> void:
	flag = str(params.get("flag", ""))
	actions = params.get("actions", [])
	if flag.is_empty():
		Log.error(Log.Category.CONTENT, "chest without flag")
	elif WorldState.has_flag(flag):
		_show_open()


func _on_interacted(_actor: Node) -> void:
	if is_open:
		return
	_show_open()
	WorldState.set_flag(flag)
	SoundBank.play_at(self, "lever", global_position, -2.0)
	StateActions.run(actions, "chest:" + flag)


func _show_open() -> void:
	is_open = true
	_sprite.frame = 1
	_interactable.enabled = false
