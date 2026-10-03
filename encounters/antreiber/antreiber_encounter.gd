class_name AntreiberEncounter
extends GameScene
## Grey-box of "Der Weg, der nicht endet" (Phase 1). An endless path of repeated text-map
## segments; the goal flag recedes while the player moves. Standing still (or sitting on a
## bench) resolves it. Rules live in AntreiberModel; this scene only stages them.

const SEGMENT_TILES := Vector2i(20, 23)
const TILE := 16
const SEGMENT_PLAIN := "res://content/maps/antreiber_segment.txt"
const SEGMENT_BENCH := "res://content/maps/antreiber_segment_bench.txt"
const PATH_Y := 11 * TILE + 8
const ACTOR_SCENE := preload("res://encounters/antreiber/antreiber_actor.tscn")
const FLAG_SCENE := preload("res://world/props/goal_flag.tscn")
const BIRD_SCENE := preload("res://world/props/bird.tscn")
## The flag stays in view: it hovers near the right edge and recedes there.
const FLAG_MIN_AHEAD := 120.0
const FLAG_MAX_AHEAD := 250.0

@export var stillness_seconds := 3.0
@export var encounter_speed := 1.0

var model := AntreiberModel.new()
var antreiber: AntreiberActor
var flag: Node2D
var goal_reached := false
var _ground: Node2D
var _actors: Node2D
var _segments: Dictionary = {}
var _segment_texts: Dictionary = {}
var _last_player_pos := Vector2.ZERO


func _build_world() -> void:
	saveable = false
	_ground = Node2D.new()
	_ground.name = "Segments"
	view.world_root.add_child(_ground)
	_actors = Node2D.new()
	_actors.name = "Actors"
	_actors.y_sort_enabled = true
	view.world_root.add_child(_actors)
	_actors.add_child(fx)
	for path: String in [SEGMENT_PLAIN, SEGMENT_BENCH]:
		_segment_texts[path] = FileAccess.get_file_as_string(path)
	_ensure_segments(0.0)
	_add_boundaries()
	spawn_player(_actors, Vector2(2 * TILE + 8, PATH_Y))
	player.surface_provider = surface_at
	_last_player_pos = player.global_position
	var height := float(SEGMENT_TILES.y * TILE)
	view.bounds = Rect2(Vector2(-1.0e6, 0), Vector2(2.0e6, height))
	flag = FLAG_SCENE.instantiate()
	_actors.add_child(flag)
	flag.global_position = Vector2(player.global_position.x + model.goal_distance, PATH_Y - 10)
	antreiber = ACTOR_SCENE.instantiate()
	_actors.add_child(antreiber)
	antreiber.global_position = player.global_position + AntreiberActor.LEAD
	# Accessibility: longer timing windows and a calmer encounter (Game Bible §50).
	model.stillness_seconds = stillness_seconds * Settings.timing_factor()
	model.encounter_speed = encounter_speed * Settings.encounter_speed()
	model.resolved.connect(_on_resolved)
	Log.info(
		Log.Category.ENCOUNTER,
		"antreiber start",
		{"stillness_seconds": model.stillness_seconds, "speed": model.encounter_speed}
	)


func surface_at(world_pos: Vector2) -> StringName:
	var segment: MapView = _segments.get(_segment_index(world_pos.x))
	return segment.surface_at(world_pos) if segment != null else &"grass"


func _physics_process(delta: float) -> void:
	if player == null:
		return
	var moved := player.global_position.distance_to(_last_player_pos)
	_last_player_pos = player.global_position
	var input_active := not player.is_locked() and player.read_input().length() > 0.2
	var sitting := player.state == Player.State.SIT
	var sprinting := player.state == Player.State.RUN
	model.update(delta, moved, input_active, sprinting, sitting)
	_ensure_segments(player.global_position.x)
	if model.is_resolved():
		_check_goal()
		return
	player.speed_scale = model.speed_scale()
	var ahead := clampf(model.goal_distance, FLAG_MIN_AHEAD, FLAG_MAX_AHEAD)
	var flag_target := player.global_position.x + ahead
	flag.global_position.x = lerpf(flag.global_position.x, flag_target, 1.0 - exp(-6.0 * delta))
	antreiber.update_actor(player, model, delta)


func _on_resolved() -> void:
	Log.info(Log.Category.ENCOUNTER, "antreiber resolved", model.stats())
	WorldState.set_flag("encounter.antreiber_resolved")
	player.speed_scale = 1.0
	antreiber.resolve(player)
	var beside := Vector2(player.global_position.x + 30, PATH_Y - 10)
	var tween := create_tween()
	tween.tween_property(flag, ^"global_position", beside, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_land_bird)


func _land_bird() -> void:
	var bird: Node2D = BIRD_SCENE.instantiate()
	_actors.add_child(bird)
	bird.global_position = flag.global_position + Vector2(4, -27)
	bird.z_index = 5
	SoundBank.play_at(bird, "bird", bird.global_position, -8.0)


func _check_goal() -> void:
	if goal_reached or flag == null:
		return
	if player.global_position.distance_to(flag.global_position + Vector2(0, 10)) < 14.0:
		goal_reached = true
		Log.info(Log.Category.ENCOUNTER, "goal reached", model.stats())


func _segment_index(x: float) -> int:
	return floori(x / float(SEGMENT_TILES.x * TILE))


func _ensure_segments(player_x: float) -> void:
	var center := _segment_index(player_x)
	for index in range(center - 1, center + 3):
		if not _segments.has(index):
			_segments[index] = _build_segment(index)
	for index: int in _segments.keys():
		if index < center - 2 or index > center + 4:
			(_segments[index] as Node).queue_free()
			_segments.erase(index)


func _build_segment(index: int) -> MapView:
	var segment := MapView.new()
	segment.name = "Segment_%d" % index
	segment.props_parent = _actors
	segment.position = Vector2(index * SEGMENT_TILES.x * TILE, 0)
	_ground.add_child(segment)
	var path := SEGMENT_BENCH if posmod(index, 2) == 1 else SEGMENT_PLAIN
	segment.build_from_text(_segment_texts[path], path)
	return segment


## Invisible top and bottom walls along the whole endless path.
func _add_boundaries() -> void:
	for y: float in [-8.0, SEGMENT_TILES.y * TILE + 8.0]:
		var wall := StaticBody2D.new()
		wall.collision_layer = PhysicsLayers.WORLD
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(4.0e6, 16)
		shape.shape = rect
		wall.add_child(shape)
		wall.position = Vector2(0, y)
		view.world_root.add_child(wall)
