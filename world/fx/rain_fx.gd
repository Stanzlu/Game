class_name RainFx
extends Node2D
## Rain over the visible part of the world (ADR-017): slanted streaks and short splashes.
## Particles live in world space, so they scroll with the ground when the camera moves.
## Add it to a CanvasLayer that follows the viewport, so a CanvasModulate on the world
## (night, rain) does not darken the drops.

const FX_DIR := "res://assets/generated/props/fx/"

var view: GameView


func _init() -> void:
	z_index = 40
	process_priority = 10


func setup(game_view: GameView, strength: float = 1.0) -> void:
	view = game_view
	var drops := CPUParticles2D.new()
	drops.name = "Drops"
	drops.texture = load(FX_DIR + "raindrop.png")
	drops.local_coords = false
	drops.amount = int(260 * strength)
	drops.lifetime = 1.25
	drops.preprocess = 1.25
	drops.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	drops.emission_rect_extents = Vector2(400, 6)
	drops.position = Vector2(40, -230)
	drops.direction = Vector2(-0.22, 1.0)
	drops.spread = 2.0
	drops.gravity = Vector2.ZERO
	drops.initial_velocity_min = 330.0
	drops.initial_velocity_max = 390.0
	drops.particle_flag_align_y = true
	drops.color = Color(0.78, 0.84, 0.92, 0.55)
	add_child(drops)
	var splashes := CPUParticles2D.new()
	splashes.name = "Splashes"
	splashes.texture = load(FX_DIR + "splash.png")
	splashes.local_coords = false
	splashes.amount = int(80 * strength)
	splashes.lifetime = 0.3
	splashes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	splashes.emission_rect_extents = Vector2(340, 196)
	splashes.gravity = Vector2.ZERO
	splashes.initial_velocity_min = 0.0
	splashes.initial_velocity_max = 0.0
	var fade := Gradient.new()
	fade.set_color(0, Color(0.8, 0.86, 0.94, 0.7))
	fade.set_color(1, Color(0.8, 0.86, 0.94, 0.0))
	splashes.color_ramp = fade
	add_child(splashes)


func _process(_delta: float) -> void:
	if view != null:
		position = view.camera_position


## Starts or stops the rain (drops already falling finish their way).
func set_raining(on: bool) -> void:
	for child in get_children():
		(child as CPUParticles2D).emitting = on


func is_raining() -> bool:
	return get_child_count() > 0 and (get_child(0) as CPUParticles2D).emitting
