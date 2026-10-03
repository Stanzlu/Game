class_name FogDrift
extends Node2D
## Low banks of fog drifting slowly across the map (look prototype). Pixel-banded texture,
## tinted and dimmed with the world; wraps around the map width.

const TEXTURE := preload("res://assets/generated/props/fx/fog.png")

var _banks: Array[Dictionary] = []
var _area := Rect2()


func _init() -> void:
	z_index = 25


func setup(area: Rect2, count: int, color: Color, seed_value: int = 3) -> void:
	_area = area
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = TEXTURE
		sprite.centered = true
		sprite.modulate = color
		sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(sprite)
		var bank := {
			"sprite": sprite,
			"x": rng.randf_range(area.position.x, area.end.x),
			"y": rng.randf_range(area.position.y + 40.0, area.end.y - 40.0),
			"speed": rng.randf_range(3.0, 7.0),
		}
		_banks.append(bank)


func _process(delta: float) -> void:
	var width := _area.size.x + 200.0
	for bank: Dictionary in _banks:
		bank["x"] = float(bank["x"]) + float(bank["speed"]) * delta
		var x := wrapf(float(bank["x"]), _area.position.x - 100.0, _area.position.x - 100.0 + width)
		(bank["sprite"] as Sprite2D).position = Vector2(roundf(x), float(bank["y"]))
