extends StaticBody2D
## A gate that blocks the way until a linked lever opens it. Params: {"id": "...", "open": bool}

var is_open := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _shape: CollisionShape2D = $Shape


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD


func apply_params(params: Dictionary) -> void:
	var id := str(params.get("id", ""))
	if id.is_empty():
		Log.warn(Log.Category.CONTENT, "gate without id")
	else:
		add_to_group(StringName("link_" + id))
	_apply(bool(params.get("open", false)), false)


func set_linked_state(on: bool) -> void:
	_apply(on, true)


func _apply(open: bool, with_sound: bool) -> void:
	is_open = open
	_sprite.frame = 1 if open else 0
	_shape.set_deferred(&"disabled", open)
	if with_sound:
		SoundBank.play_at(self, "gate", global_position, -6.0)
