class_name FootstepFx
extends Node2D
## Visual footstep feedback: splash rings in puddles, dust puffs when running on dirt.

const SPLASH := preload("res://assets/placeholder/props/splash.png")
const DUST := preload("res://assets/placeholder/props/dust.png")


func watch(walker: Node) -> void:
	if walker.has_signal(&"footstep"):
		walker.connect(&"footstep", _on_footstep)


func _on_footstep(surface: StringName, at: Vector2, running: bool) -> void:
	if surface == &"puddle":
		_spawn(SPLASH, 4, at + Vector2(0, -2), 0.32)
	elif running and (surface == &"dirt" or surface == &"stone"):
		_spawn(DUST, 3, at + Vector2(0, -2), 0.3)


func _spawn(texture: Texture2D, frames: int, at: Vector2, duration: float) -> void:
	var fx := Sprite2D.new()
	fx.texture = texture
	fx.hframes = frames
	fx.z_index = -4
	add_child(fx)
	fx.global_position = at
	var tween := fx.create_tween()
	tween.tween_property(fx, ^"frame", frames - 1, duration)
	tween.tween_callback(fx.queue_free)
