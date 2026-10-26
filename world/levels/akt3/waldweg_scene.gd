class_name WaldwegScene
extends LookScene
## Act III, W2: the forest path (docs/akt3/REGIONSBRIEFE.md). A worn path along a brook through
## a tall forest, the Antreiber's way markers, two places to rest and the Hang, a sunken lane that
## is slow to climb until the player has rested once. Everything on the map lives in props with
## `if`/`unless`/`sprite_when` and in the dialogue; this script only slows the Hang and marks the
## beats of the walk. No cutscene, no lock, nothing here is needed to go on.

## The pace in the Hang while the player has not rested yet (the walking speed times this).
const HANG_PACE := 0.78

var _hang := Rect2i()


func _ready() -> void:
	super()
	_hang = _hang_rect()
	WorldState.flag_changed.connect(_on_flag_changed)
	WorldState.quest_changed.connect(_on_quest_changed)
	# the way on along the stream: the quest moves from the stream to the wood
	if WorldState.quest_stage("main_forest_way") == "brook":
		WorldState.advance_quest("main_forest_way", "wood")
	Beat.mark("waldweg_enter")


## The Hang's cells from the two markers at its top and its foot (the path between them is sunken).
func _hang_rect() -> Rect2i:
	var top: Array = map.data.find_marker("hang_top")
	var foot: Array = map.data.find_marker("hang_foot")
	if top.is_empty() or foot.is_empty():
		Log.error(Log.Category.CONTENT, "the Hang has no markers")
		return Rect2i()
	var a: Vector2i = top[0]["cell"]
	var b: Vector2i = foot[0]["cell"]
	var low := Vector2i(mini(a.x, b.x) - 2, mini(a.y, b.y))
	var high := Vector2i(maxi(a.x, b.x) + 2, maxi(a.y, b.y))
	return Rect2i(low, high - low + Vector2i.ONE)


func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var steep := (
		_hang.has_point(map.world_to_cell(player.global_position))
		and not WorldState.has_flag("forest.rested")
	)
	player.speed_scale = HANG_PACE if steep else 1.0


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"forest.rested":
			Beat.mark("forest_rest")
		"forest.antreiber_sat":
			Beat.mark("waldweg_tea")


## The last of the Antreiber's boards has been read and he has talked about the empty one.
func _on_quest_changed(quest_id: String, stage: String) -> void:
	if quest_id == "side_forest_marks" and stage == "done":
		Beat.mark("waldweg_marks")


func _exit_tree() -> void:
	if is_instance_valid(player):
		player.speed_scale = 1.0
