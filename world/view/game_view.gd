class_name GameView
extends Node
## Renders the world pixel-perfect in a SubViewport and shows it as a sprite that can be
## shifted by fractions of a game pixel (ADR-012). Two camera modes for comparison:
## PIXEL moves in whole game pixels, SMOOTH scrolls at screen-pixel precision.
##
## No Camera2D: the view sets the viewport's canvas transform itself (same frame as the
## fractional shift). World nodes live under `world_root` and poll the Input singleton;
## the viewport does not receive input events. UI belongs in CanvasLayers of this scene.
##
## Zoom (ADR-043): world pixels can be drawn larger than the UI's. The world viewport then
## shrinks to `view_size` and the display sprite scales it up; with a zoom that is not a
## whole number the texture is filtered linearly and the display shader samples it sharp
## (sharp_sample.gdshaderinc), so pixels stay even at any window size.

enum CameraMode { PIXEL, SMOOTH }

const BASE_SIZE := Vector2i(640, 360)
## One extra game pixel on each side so a fractional shift never reveals an edge.
const BORDER := 1
const SHARP_SHADER := preload("res://world/shaders/sharp_display.gdshader")
## The camera looks at the target's body, not its feet.
const FOLLOW_OFFSET := Vector2(0, -8)

@export var camera_mode := CameraMode.SMOOTH
## How quickly the camera catches up (1/s). Higher = tighter.
@export var follow_sharpness := 14.0
## Pixels the camera leads in the walking direction.
@export var look_ahead := 14.0
@export var look_ahead_sharpness := 3.0

var viewport: SubViewport
var world_root: Node2D
var display: Sprite2D
## Integer world position at the center of the view (what a Camera2D position would be).
var camera_position := Vector2.ZERO
var target: Node2D
var bounds := Rect2()
## How many UI pixels one world pixel covers (1 = as before, Elysia; 1.5 = the real world).
var zoom := 1.0
## Size of the visible world in world pixels (BASE_SIZE / zoom, rounded up).
var view_size := BASE_SIZE

var _cam_pos := Vector2.ZERO
var _lead := Vector2.ZERO
var _has_position := false
var _shake_time := 0.0
var _shake_strength := 0.0
var _shake_length := 0.0


func _init() -> void:
	viewport = SubViewport.new()
	viewport.name = "WorldViewport"
	viewport.size = BASE_SIZE + Vector2i.ONE * BORDER * 2
	viewport.snap_2d_transforms_to_pixel = true
	viewport.canvas_item_default_texture_filter = (
		Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	)
	viewport.audio_listener_enable_2d = true
	world_root = Node2D.new()
	world_root.name = "World"
	viewport.add_child(world_root)
	display = Sprite2D.new()
	display.name = "WorldDisplay"
	display.centered = false
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Moved every frame in _process: physics interpolation would delay it by one tick.
	display.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func _ready() -> void:
	add_child(viewport)
	add_child(display)
	display.texture = viewport.get_texture()
	if display.material == null:
		display.material = _sharp_material()


## Sets the zoom (1 to 3). Call before the world is built; changing it later is possible but
## reallocates the world texture.
func set_zoom(value: float) -> void:
	zoom = clampf(value, 1.0, 3.0)
	view_size = Vector2i((Vector2(BASE_SIZE) / zoom).ceil())
	viewport.size = view_size + Vector2i.ONE * BORDER * 2
	display.scale = Vector2.ONE * zoom
	# whole-number zooms stay nearest (exact); others need the sharp linear sampling
	var whole := is_equal_approx(zoom, roundf(zoom))
	display.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST if whole else CanvasItem.TEXTURE_FILTER_LINEAR
	)
	_has_position = false


## Converts a world position to a position in the 640x360 UI space (for overlays that
## should keep the UI's pixel size while following something in the world).
func world_to_ui(world_position: Vector2) -> Vector2:
	return (world_position - camera_position + Vector2(view_size) * 0.5) * zoom


## Post-process for the whole world image (color grading, bloom, vignette; ADR-017).
func set_post_material(material: Material) -> void:
	display.material = material if material != null else _sharp_material()


static func _sharp_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = SHARP_SHADER
	return mat


## Follow this node (usually the player). Uses its interpolated_position() when available.
func follow(node: Node2D, snap_now: bool = true) -> void:
	target = node
	if snap_now:
		_has_position = false


## Screen shake in whole game pixels, fading out. Does nothing when the player turned
## screen shake off (accessibility).
func shake(strength: float, seconds: float) -> void:
	if not Settings.get_bool("display.screen_shake"):
		return
	_shake_strength = strength
	_shake_length = seconds
	_shake_time = seconds


func set_camera_mode(mode: CameraMode) -> void:
	if mode == camera_mode:
		return
	camera_mode = mode
	Log.info(Log.Category.UI, "camera mode", {"mode": CameraMode.keys()[mode]})


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var feet := target.global_position
	if target.has_method(&"interpolated_position"):
		feet = target.call(&"interpolated_position")
	var velocity: Vector2 = target.get("velocity") if "velocity" in target else Vector2.ZERO
	var lead_target := (
		velocity.normalized() * look_ahead if velocity.length() > 10.0 else Vector2.ZERO
	)
	_lead = CameraMath.smooth_toward(_lead, lead_target, look_ahead_sharpness, delta)
	# Following the rounded feet keeps the snapped player steady on screen.
	var desired: Vector2 = feet.round() + _lead + FOLLOW_OFFSET
	if not _has_position:
		_cam_pos = desired
		_lead = Vector2.ZERO
		_has_position = true
	else:
		_cam_pos = CameraMath.smooth_toward(_cam_pos, desired, follow_sharpness, delta)
	if bounds.has_area():
		_cam_pos = CameraMath.clamp_to_bounds(_cam_pos, Vector2(view_size) * 0.5, bounds)
	var shaken := _cam_pos
	if _shake_time > 0.0:
		_shake_time = maxf(_shake_time - delta, 0.0)
		var amount := _shake_strength * _shake_time / maxf(_shake_length, 0.001)
		shaken += Vector2(randf_range(-amount, amount), randf_range(-amount, amount)).round()
	var parts := CameraMath.split(shaken, camera_mode == CameraMode.SMOOTH)
	# Set the canvas transform directly: a Camera2D would apply the new position one
	# frame late while the fractional display shift applies immediately (visible jitter).
	camera_position = parts[0]
	var half_view := Vector2(viewport.size) * 0.5
	viewport.canvas_transform = Transform2D(0.0, half_view - camera_position)
	display.position = (-Vector2.ONE * BORDER - parts[1]) * zoom
