class_name SkyLayer
extends Node2D
## Sky behind a floating map (Elysia, ADR-017): a dithered gradient that fills the view and
## clouds that drift slowly with horizontal parallax. Lives in the world, below the ground.

const SKY_SHADER := preload("res://world/shaders/sky.gdshader")
const MARGIN := 16.0

var view: GameView
var _rect: ColorRect
var _clouds: Array[Dictionary] = []
var _time := 0.0


func _init() -> void:
	z_index = -20
	process_priority = 10


func setup(game_view: GameView, top: Color, bottom: Color) -> void:
	view = game_view
	_rect = ColorRect.new()
	_rect.name = "Gradient"
	_rect.size = Vector2(GameView.BASE_SIZE) + Vector2.ONE * MARGIN * 2.0
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = SKY_SHADER
	mat.set_shader_parameter("top", top)
	mat.set_shader_parameter("bottom", bottom)
	_rect.material = mat
	add_child(_rect)


## Adds a sky object (cloud, floating islet, rainbow) at world height `y`; `parallax` < 1
## moves slower than the ground (far away). `bob` makes it float up and down in pixels.
func add_cloud(
	texture: Texture2D,
	x: float,
	y: float,
	speed: float,
	parallax: float,
	bob: float = 0.0,
	alpha: float = 1.0
) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	sprite.modulate = Color(1, 1, 1).lerp(Color(0.86, 0.9, 1.0), 1.0 - parallax)
	sprite.modulate.a = alpha
	add_child(sprite)
	_clouds.append(
		{"sprite": sprite, "x": x, "y": y, "speed": speed, "parallax": parallax, "bob": bob}
	)


func _process(delta: float) -> void:
	if view == null:
		return
	_time += delta
	var cam := view.camera_position
	var origin := cam - Vector2(GameView.BASE_SIZE) * 0.5
	_rect.position = origin - Vector2.ONE * MARGIN
	var span := float(GameView.BASE_SIZE.x)
	for cloud: Dictionary in _clouds:
		var sprite: Sprite2D = cloud["sprite"]
		var w := sprite.texture.get_width()
		var sx := (
			float(cloud["x"]) + float(cloud["speed"]) * _time - cam.x * float(cloud["parallax"])
		)
		sx = wrapf(sx, -w, span + w)
		var bob := float(cloud["bob"]) * sin(_time * 0.6 + float(cloud["x"]) * 0.01)
		sprite.position = Vector2(roundf(origin.x + sx), roundf(float(cloud["y"]) + bob))
