extends StaticBody2D
## Toggles linked nodes. Params: {"target": "<link id>"}; targets join group "link_<id>"
## and implement set_linked_state(on: bool).

var target := ""
var is_on := false

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	($Interactable as Interactable).interacted.connect(_on_interacted)


func apply_params(params: Dictionary) -> void:
	target = str(params.get("target", ""))


func _on_interacted(_actor: Node) -> void:
	is_on = not is_on
	_sprite.frame = 1 if is_on else 0
	SoundBank.play_at(self, "lever", global_position, -4.0)
	if target.is_empty():
		Log.warn(Log.Category.INTERACTION, "lever without target")
		return
	get_tree().call_group(StringName("link_" + target), &"set_linked_state", is_on)
