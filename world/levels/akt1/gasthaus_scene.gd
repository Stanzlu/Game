class_name GasthausScene
extends LookScene
## The Gasthaus zum Immer from inside (Act I, segment A2, docs/akt1/REGIONSBRIEFE.md): the host,
## who is the Betäuber's face (Game Bible §14), offers a meal, a room and a night; each offer is
## free to refuse and comes back kindly. Story state lives in WorldState flags; this script only
## stages what the flags say: the beats, the night in the room and the way back out.

const DIALOGUE := "res://content/dialogue/akt1/gasthaus.dialogue"
## The night: the light comes up from white like the first waking (ElysiaScene.WAKE_LIGHT), and
## nobody finds it strange that it is the same morning.
const SLEEP_LIGHT := Color(1.0, 0.98, 0.92)
const SLEEP_FADE_OUT := 1.8
const SLEEP_HOLD := 1.2
const SLEEP_FADE_IN := 2.6
const SLEEP_XP := 500
## The rooms and the hall (cells): the camera stays inside, not over the void around them.
const ROOMS := Rect2i(0, 4, 41, 16)

var director: ElysiaDirector


func _ready() -> void:
	super()
	view.bounds = Rect2(
		Vector2(ROOMS.position * map.data.tile_size), Vector2(ROOMS.size * map.data.tile_size)
	)
	director = ElysiaDirector.attach(self)
	WorldState.flag_changed.connect(_on_flag_changed)
	Beat.mark("inn_enter")
	if WorldState.has_flag("elysia.inn_sleeping"):
		# loaded in the middle of the night: it ends now
		_sleep.call_deferred()


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"elysia.inn_met":
			_arrive_in_the_quest()
		"elysia.inn_fed":
			Beat.mark("inn_fed")
		"elysia.inn_room":
			Beat.mark("inn_room")
		"elysia.inn_sleeping":
			_sleep()


## Meeting the host is the stage "inn" of the hero's quest, once the chest has been opened; opened
## after the visit, the chest finds the stage for itself (ElysiaScene).
func _arrive_in_the_quest() -> void:
	if WorldState.quest_stage("main_elysia_hero") == "celebrated":
		WorldState.advance_quest("main_elysia_hero", "inn")


## The night in the bed: the light goes white, the same morning comes back, the host's third offer
## waits outside the room (host_slept).
func _sleep() -> void:
	while dialogue_box != null and dialogue_box.is_open():
		await get_tree().process_frame
	if not WorldState.has_flag("elysia.inn_sleeping"):
		return
	var cut := Cutscene.begin(self)
	ScreenFade.fade_out(SLEEP_FADE_OUT, SLEEP_LIGHT)
	await cut.wait(SLEEP_FADE_OUT + SLEEP_HOLD)
	WorldState.set_flag("elysia.inn_slept")
	WorldState.clear_flag("elysia.inn_sleeping")
	ScreenFade.fade_in(SLEEP_FADE_IN)
	await cut.say(DIALOGUE, "woke")
	WorldState.add_xp(SLEEP_XP)
	Beat.mark("inn_slept")
	cut.end()
