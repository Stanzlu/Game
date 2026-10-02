class_name GameView
extends Node
## Renders the world pixel-perfect in a SubViewport and shows it as a sprite that can be
## shifted by fractions of a game pixel (ADR-012). Two camera modes for comparison:
## PIXEL moves in whole game pixels, SMOOTH scrolls at screen-pixel precision.
##
## No Camera2D: the view sets the viewport's canvas transform itself (same frame as the
## fractional shift). World nodes live under `world_root` and poll the Input singleton;
## the viewport does not receive input events. UI belongs in CanvasLayers of this scene.

enum CameraMode { PIXEL, SMOOTH }

const BASE_SIZE := Vector2i(640, 360)
## One extra game pixel on each side so a fractional shift never reveals an edge.
const BORDER := 1

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

var _cam_pos := Vector2.ZERO
var _lead := Vector2.ZERO
var _has_position := false


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


## Post-process for the whole world image (color grading, bloom, vignette; ADR-017).
func set_post_material(material: Material) -> void:
	display.material = material


## Follow this node (usually the player). Uses its interpolated_position() when available.
func follow(node: Node2D, snap_now: bool = true) -> void:
	target = node
	if snap_now:
		_has_position = false


func set_camera_mode(mode: CameraMode) -> void:
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
	var desired: Vector2 = feet.round() + _lead + Vector2(0, -8)
	if not _has_position:
		_cam_pos = desired
		_lead = Vector2.ZERO
		_has_position = true
	else:
		_cam_pos = CameraMath.smooth_toward(_cam_pos, desired, follow_sharpness, delta)
	if bounds.has_area():
		_cam_pos = CameraMath.clamp_to_bounds(_cam_pos, Vector2(BASE_SIZE) * 0.5, bounds)
	var parts := CameraMath.split(_cam_pos, camera_mode == CameraMode.SMOOTH)
	# Set the canvas transform directly: a Camera2D would apply the new position one
	# frame late while the fractional display shift applies immediately (visible jitter).
	camera_position = parts[0]
	var half_view := Vector2(viewport.size) * 0.5
	viewport.canvas_transform = Transform2D(0.0, half_view - camera_position)
	display.position = -Vector2.ONE * BORDER - parts[1]
