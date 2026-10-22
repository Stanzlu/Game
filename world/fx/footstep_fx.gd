class_name FootstepFx
extends Node2D
## Visual footstep feedback: splash rings in puddles, dust puffs when running on dirt, and
## dark wet prints on mud in the rain.

const SPLASH := preload("res://assets/placeholder/props/splash.png")
const DUST := preload("res://assets/placeholder/props/dust.png")
## A print is 3x2 px, a foot to either side of the track, and dries out in a few seconds.
const PRINT_SIZE := Vector2i(3, 2)
const PRINT_ALPHA := 0.28
const PRINT_SIDE := 2.0
const PRINT_SECONDS := 4.0
const MAX_PRINTS := 40
const RAIN_PRESET := "regentag"

static var _print_texture: ImageTexture

var _mud_symbols: Dictionary = {}
var _map: MapView
var _prints: Array[Sprite2D] = []
var _left_foot := false


func _ready() -> void:
	# the effects node lives under the map's entities; the mud is what the map text paints
	_map = get_parent().get_parent() as MapView if get_parent() != null else null
	if _map != null and not _map.map_path.is_empty():
		_mud_symbols = _find_mud_symbols(_map.map_path)


func watch(walker: Node) -> void:
	if walker.has_signal(&"footstep"):
		walker.connect(&"footstep", _on_footstep)


func _on_footstep(surface: StringName, at: Vector2, running: bool) -> void:
	if surface == &"puddle":
		_spawn(SPLASH, 4, at + Vector2(0, -2), 0.32)
	else:
		if surface == &"dirt" and _is_wet_mud(at):
			_leave_print(at)
		if running and (surface == &"dirt" or surface == &"stone"):
			_spawn(DUST, 3, at + Vector2(0, -2), 0.3)


## Mud counts only in the rain, and only the cells the map text paints as mud (path and
## field are dirt too, but they stay dry-looking).
func _is_wet_mud(at: Vector2) -> bool:
	if _mud_symbols.is_empty() or WorldState.day_preset() != RAIN_PRESET:
		return false
	return _mud_symbols.has(_map.data.tile_symbol_at(_map.world_to_cell(at)))


func _leave_print(at: Vector2) -> void:
	if _print_texture == null:
		var image := Image.create_empty(PRINT_SIZE.x, PRINT_SIZE.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		_print_texture = ImageTexture.create_from_image(image)
	_left_foot = not _left_foot
	var side := -PRINT_SIDE if _left_foot else PRINT_SIDE
	var print_sprite := Sprite2D.new()
	print_sprite.texture = _print_texture
	print_sprite.centered = false
	print_sprite.modulate = Color(0.0, 0.0, 0.0, PRINT_ALPHA)
	print_sprite.z_index = -4
	add_child(print_sprite)
	print_sprite.global_position = (at + Vector2(side - 1.0, -1.0)).floor()
	_prints.append(print_sprite)
	while _prints.size() > MAX_PRINTS:
		var oldest: Sprite2D = _prints.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	var tween := print_sprite.create_tween()
	tween.tween_property(print_sprite, ^"modulate:a", 0.0, PRINT_SECONDS)
	tween.tween_callback(_drop_print.bind(print_sprite))


func _drop_print(print_sprite: Sprite2D) -> void:
	_prints.erase(print_sprite)
	print_sprite.queue_free()


## Symbols of the map text's own legend that are painted as mud.
static func _find_mud_symbols(path: String) -> Dictionary:
	var found := {}
	var in_legend := false
	for raw_line: String in FileAccess.get_file_as_string(path).split("\n"):
		var line := raw_line.strip_edges()
		if line in ["[legend]", "[map]", "[meta]"]:
			in_legend = line == "[legend]"
			continue
		if not in_legend or line.is_empty() or line.begins_with(";"):
			continue
		var eq := line.find("=", 1)
		var parsed: Variant = JSON.parse_string(line.substr(eq + 1)) if eq > 0 else null
		if parsed is Dictionary and str((parsed as Dictionary).get("paint", "")) == "mud":
			found[line.left(1)] = true
	return found


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
