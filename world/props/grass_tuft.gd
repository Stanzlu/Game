extends Node2D
## Tall grass: overrides the footstep surface and bends when something walks through.

@onready var _sprite: Sprite2D = $Sprite
@onready var _area: Area2D = $Area


func _ready() -> void:
	_area.collision_layer = PhysicsLayers.SURFACE
	_area.collision_mask = PhysicsLayers.PLAYER | PhysicsLayers.NPC
	_area.set_meta(&"surface", &"tall_grass")
	_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var side := signf(global_position.x - body.global_position.x)
	if side == 0.0:
		side = 1.0
	var tween := create_tween()
	_sprite.skew = side * 0.45
	tween.tween_property(_sprite, ^"skew", 0.0, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(
		Tween.EASE_OUT
	)
	SoundBank.play_at(self, "rustle", global_position, -12.0)
