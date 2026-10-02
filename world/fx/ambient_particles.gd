class_name AmbientParticles
extends CPUParticles2D
## Particles that drift through the visible part of the world (petals, light motes).
## The emitter follows the camera; particles stay in world space.

const FX_DIR := "res://assets/generated/props/fx/"

var view: GameView


static func petals(game_view: GameView) -> AmbientParticles:
	var p := AmbientParticles.new()
	p.name = "Petals"
	p.view = game_view
	p.texture = load(FX_DIR + "petal.png")
	p.amount = 26
	p.lifetime = 10.0
	p.preprocess = 10.0
	p.emission_rect_extents = Vector2(380, 220)
	p.direction = Vector2(1, 0.25)
	p.spread = 30.0
	p.gravity = Vector2(4, 7)
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 14.0
	p.angular_velocity_min = -120.0
	p.angular_velocity_max = 120.0
	var tints := Gradient.new()
	tints.set_color(0, Color(1, 1, 1))
	tints.set_color(1, Color(1.0, 0.82, 0.9))
	p.color_initial_ramp = tints
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.1, Color(1, 1, 1, 1))
	fade.add_point(0.85, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = fade
	return p


static func motes(game_view: GameView) -> AmbientParticles:
	var p := AmbientParticles.new()
	p.name = "Motes"
	p.view = game_view
	p.texture = load(FX_DIR + "mote.png")
	p.amount = 22
	p.lifetime = 6.0
	p.preprocess = 6.0
	p.emission_rect_extents = Vector2(340, 200)
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, -2)
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 6.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 0.85, 0))
	fade.add_point(0.5, Color(1, 1, 0.85, 0.85))
	fade.set_color(1, Color(1, 1, 0.85, 0))
	p.color_ramp = fade
	return p


func _init() -> void:
	z_index = 30
	process_priority = 10
	local_coords = false
	emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE


func _process(_delta: float) -> void:
	if view != null:
		position = view.camera_position
