class_name SpiegelhalleScene
extends LookScene
## The hall of mirrors from inside (Act I, segment A5, docs/akt1/REGIONSBRIEFE.md): three rooms in
## which everything stands twice, almost. The gate of a room opens when the hero has noticed what
## lies on one side only (Perception, Game Bible §16); the last room has a mirror that shows the
## hall and not the hero. Story state lives in WorldState flags; this script only stages what the
## flags say: the beats, the gates' sound and the hero's quest stage.

## The rooms (cells): the camera stays inside, not over the void around them.
const ROOMS := Rect2i(3, 3, 27, 39)
## The sound of a gate swinging open: a door of the town, heard from far away.
const GATE_DB := -6.0

var director: ElysiaDirector


func _ready() -> void:
	super()
	view.bounds = Rect2(
		Vector2(ROOMS.position * map.data.tile_size), Vector2(ROOMS.size * map.data.tile_size)
	)
	director = ElysiaDirector.attach(self)
	WorldState.flag_changed.connect(_on_flag_changed)
	WorldState.set_flag("elysia.hall_seen")
	Beat.mark("hall_enter")
	_arrive_in_the_quest()


## Walking into the hall is the stage "hall" of the hero's quest, once the town was reached; entered
## before the chest, the chest finds the stage for itself (ElysiaScene).
func _arrive_in_the_quest() -> void:
	if WorldState.quest_stage("main_elysia_hero") == "market":
		WorldState.advance_quest("main_elysia_hero", "hall")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"elysia.hall_room_1":
			_gate_opens()
			Beat.mark("hall_room_1")
		"elysia.hall_room_2":
			_gate_opens()
			Beat.mark("hall_room_2")
		"fragment.empty_room":
			Beat.mark("trail_room")
		"elysia.hall_mirror_seen":
			Beat.mark("hall_mirror")
			if WorldState.has_facet("perception"):
				Beat.mark("perception")


## The room noticed what did not match: its gate swings open.
func _gate_opens() -> void:
	AudioDirector.sfx("door_open", GATE_DB)
	# written out whatever the captions setting says: the gate is the answer to what was noticed
	hud.show_caption("CAPTION_GATE")
	view.shake(0.6, 0.4)
