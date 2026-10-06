class_name AmbientParticles
extends CPUParticles2D
## Particles that drift through the visible part of the world (petals, light motes, leaves).
## The emitter follows the camera; particles stay in world space.

const FX_DIR := "res://assets/generated/props/fx/"

var view: GameView
## Speed follows irregular gusts (wind in the real world).
var gusty := false
var _time := 0.0


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


static func fireflies(game_view: GameView) -> AmbientParticles:
	var p := AmbientParticles.new()
	p.name = "Fireflies"
	p.view = game_view
	p.texture = load(FX_DIR + "firefly.png")
	p.amount = 34
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.emission_rect_extents = Vector2(360, 210)
	p.direction = Vector2(1, 0)
	p.spread = 180.0
	p.gravity = Vector2(0, -1)
	p.initial_velocity_min = 3.0
	p.initial_velocity_max = 9.0
	p.angular_velocity_min = 0.0
	p.angular_velocity_max = 0.0
	# blinking: several bright pulses over a lifetime
	var blink := Gradient.new()
	blink.set_color(0, Color(1, 1, 1, 0))
	for i in 6:
		var t := 0.08 + i * 0.15
		blink.add_point(t, Color(1, 1, 1, 1.0))
		blink.add_point(t + 0.07, Color(1, 1, 1, 0.15))
	blink.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = blink
	return p


## Leaves torn off and blown through the valley in irregular gusts (Real world only).
static func leaves(game_view: GameView) -> AmbientParticles:
	var p := AmbientParticles.new()
	p.name = "Leaves"
	p.view = game_view
	p.gusty = true
	p.texture = load(FX_DIR + "leaf.png")
	p.amount = 16
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.emission_rect_extents = Vector2(380, 220)
	p.direction = Vector2(-1, 0.15)
	p.spread = 20.0
	p.gravity = Vector2(-18, 10)
	p.initial_velocity_min = 24.0
	p.initial_velocity_max = 52.0
	p.angular_velocity_min = -360.0
	p.angular_velocity_max = 360.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.08, Color(1, 1, 1, 1))
	fade.add_point(0.85, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = fade
	return p


func _init() -> void:
	z_index = 30
	process_priority = 10
	local_coords = false
	emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE


func _process(delta: float) -> void:
	if view != null:
		position = view.camera_position
	if gusty:
		# incommensurate sines: calm stretches, then a sudden push, never quite the same twice
		_time += delta
		var push := sin(_time * 0.37) + 0.6 * sin(_time * 0.91 + 1.3) + 0.3 * sin(_time * 2.3)
		speed_scale = clampf(0.55 + 0.45 * push, 0.25, 1.8)
		# the wind you hear: the leaves fly with the soundscape's gusts
		var heard := AudioDirector.wind_gust()
		if heard >= 0.0:
			speed_scale = lerpf(0.3, 1.8, heard)
