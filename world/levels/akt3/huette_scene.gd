class_name HuetteScene
extends LookScene
## Act III, W3: the hermit's hut from inside (docs/akt3/REGIONSBRIEFE.md, ADR-070 O6). A warm room
## with a table, a stool, a stove, a shelf with a flute and a window that always shows the same.
## Everything in it is optional: the door is never locked and never blocked. Whoever sits down on
## the stool is asked once per sitting (cue `stay`); every answer "stay" closes the picture in by a
## step (the zoom goes to 1.75, 2.0, 2.0 while she sits, never on a timer) and after the third the
## door opens and the game saves once. Standing up gives the picture back in the same moment; a
## loaded save never starts tight (sitting is not saved). Nothing else happens: no item, no stage,
## no sound that was not there (the flute plays once, at the first sitting).

const DIALOGUE := "res://content/dialogue/akt3/huette.dialogue"
## The room's cells: the camera stays centred on it at every zoom (it fits whole at 2.0).
const ROOM := Rect2i(9, 5, 14, 10)
## The picture's zoom after the first, second and third answer to staying.
const STAY_ZOOM: Array[float] = [1.75, 2.0, 2.0]
## The tint of the room: lit by the stove and one window at dusk (the house's warm tint).
const WARM_TINT := Color(0.54, 0.48, 0.48)
const EVENING_AMBIENCE := preload("res://content/audio/haus_abend.tres")

var _asked := false


func _ready() -> void:
	world_tint = WARM_TINT
	ambience = EVENING_AMBIENCE
	music = "silence"
	super()
	view.bounds = Rect2(
		Vector2(ROOM.position * map.data.tile_size), Vector2(ROOM.size * map.data.tile_size)
	)
	WorldState.flag_changed.connect(_on_flag_changed)
	player.state_changed.connect(_on_player_state)
	# the way through the wood: the smoke over the trees was the goal, and a hut is where it comes from
	WorldState.complete_objective("main_forest_way", "hermit")
	if WorldState.is_objective_done("main_forest_way", "flood"):
		WorldState.advance_quest("main_forest_way", "night")
	Beat.mark("huette_enter")


## Sitting down on the stool opens the question once per sitting; getting up takes the picture back.
func _on_player_state(state: Player.State) -> void:
	if state == Player.State.SIT:
		_ask.call_deferred()
	else:
		_picture(0)


func _ask() -> void:
	if _asked or player.state != Player.State.SIT:
		return
	_asked = true
	await Talk.present(self, DIALOGUE, "stay", player)
	_asked = false


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"forest.hut_stay_1":
			_picture(1)
		"forest.hut_stay_2":
			_picture(2)
		"forest.hut_stay_3":
			_picture(3)
			Beat.mark("huette_stay")
		"melody.hermit_flute":
			AudioDirector.sfx("hermit_flute", -2.0, 1.0)


## The picture after `step` answers (0 gives the room its own zoom back). It only closes in while
## she sits.
func _picture(step: int) -> void:
	if step > 0 and player.state != Player.State.SIT:
		return
	view.zoom_to(view_zoom if step == 0 else STAY_ZOOM[step - 1])
