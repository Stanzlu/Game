class_name ChildGuide
extends NpcWalker
## The child in Elysia (Game Bible §15, slice 10–18 min). It looks into the water (and has
## a reflection, unlike the protagonist). Once spoken to, it walks ahead along "guide"
## waypoints (cells relative to its spawn), waits whenever the player falls behind and,
## at the last one, asks its one question and fades away. Params like NpcWalker plus
## {"guide": [[dx, dy], ...], "start_flag": "<flag that sets it going>"}.

enum Step { WATCH, LEAD, WAIT_AT_END, GONE }

const KEEP_UP := 96.0
const CALL_DISTANCE := 40.0

var guide: Array[Vector2] = []
var start_flag := ""
var step := Step.WATCH
var _target := 0


func apply_params(params: Dictionary) -> void:
	super(params)
	guide.clear()
	for point: Variant in params.get("guide", []):
		var p: Array = point
		guide.append(Vector2(float(p[0]), float(p[1])) * tile_size)
	start_flag = str(params.get("start_flag", ""))
	facing = Facing.Dir.N
	if not start_flag.is_empty() and WorldState.has_flag(start_flag):
		_begin_lead()


func _ready() -> void:
	super()
	add_to_group(&"child_guide")
	WorldState.flag_changed.connect(_on_flag_changed)


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == start_flag and step == Step.WATCH:
		_begin_lead()


func _begin_lead() -> void:
	step = Step.LEAD
	_target = 0
	# it slips past the player instead of pushing against them on the way
	collision_mask = PhysicsLayers.WORLD


## The walk to the rift: ahead of the player, never out of sight.
func _physics_process(delta: float) -> void:
	if talking or step == Step.GONE:
		velocity = Vector2.ZERO
		_play("idle")
		return
	var player := _nearest_player()
	match step:
		Step.WATCH:
			velocity = Vector2.ZERO
			if (
				player != null
				and global_position.distance_to(player.global_position) < CALL_DISTANCE
			):
				facing = Facing.from_vector(player.global_position - global_position)
			else:
				facing = Facing.Dir.N
			_play("idle")
		Step.LEAD:
			_lead(delta, player)
		Step.WAIT_AT_END:
			velocity = Vector2.ZERO
			if player != null:
				facing = Facing.from_vector(player.global_position - global_position)
			_play("idle")


func _lead(delta: float, player: Node2D) -> void:
	if _target >= guide.size():
		step = Step.WAIT_AT_END
		return
	if player != null and global_position.distance_to(player.global_position) > KEEP_UP:
		# wait and look back until the player catches up
		velocity = Vector2.ZERO
		facing = Facing.from_vector(player.global_position - global_position)
		_play("idle")
		return
	var goal := _origin + guide[_target]
	var to_goal := goal - position
	if to_goal.length() <= ARRIVE_DISTANCE:
		_target += 1
		return
	velocity = to_goal.normalized() * speed
	var before := position
	move_and_slide()
	# blocked (a prop on the way): head for the next waypoint instead of walking on the spot
	if position.distance_to(before) < speed * delta * 0.25:
		_stuck_time += delta
		if _stuck_time > STUCK_SECONDS:
			_target += 1
			_stuck_time = 0.0
	else:
		_stuck_time = 0.0
	facing = Facing.from_vector_stable(facing, velocity)
	_play("walk")


## Its condition turned false (elysia.child_vanished, after its last line): it fades out
## where it stands; the scene opens the rift.
func leave() -> void:
	vanish()


## Fades out where it stands.
func vanish() -> void:
	if step == Step.GONE:
		return
	step = Step.GONE
	var interactable := get_node_or_null("Interactable") as Interactable
	if interactable != null:
		interactable.enabled = false
	var tween := create_tween()
	tween.tween_property(self, ^"modulate:a", 0.0, 1.6).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
