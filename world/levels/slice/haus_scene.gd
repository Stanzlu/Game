class_name HausScene
extends LookScene
## The house from inside (beat 6, docs/PHASE4_PLAN.md): empty since spring, cold and still.
## Once the fire catches, the room warms, quiet music returns; a while later Mira knocks,
## warms herself, talks and goes again. The cat waits outside at the window.
## Story state lives in WorldState (house fire, flags); this script stages it.

const DIALOGUE := "res://content/dialogue/slice/haus.dialogue"
const COLD_TINT := Color(0.5, 0.56, 0.68)
## The fire's glow fills the room: honey and amber, not grey (ADR-041).
const WARM_TINT := Color(1.0, 0.84, 0.66)
const COLD_AMBIENCE := preload("res://content/audio/haus_kalt.tres")
const WARM_AMBIENCE := preload("res://content/audio/haus_feuer.tres")
## Seconds the player sits by the burning fire before the quiet moment (Game Bible §45:
## after the fire comes rest); a little later Mira knocks.
const REST_BEFORE_KNOCK := 2.5
## Mira comes this many seconds after the fire at the latest, sitting or not.
@export var mira_after := 40.0

var _resting := 0.0
var _mira_coming := false


func _ready() -> void:
	var warm := WorldState.is_fire_lit()
	world_tint = WARM_TINT if warm else COLD_TINT
	ambience = WARM_AMBIENCE if warm else COLD_AMBIENCE
	music = "valley" if warm else "silence"
	super()
	WorldState.house_changed.connect(_on_house_changed)
	Beat.mark("house_entered")
	if not WorldState.is_quest_started("main_valley_shelter"):
		# crossed the stream without asking Mira: the house is still the goal
		WorldState.start_quest("main_valley_shelter")
		WorldState.advance_quest("main_valley_shelter", "house")
	if warm and not WorldState.has_flag("house.mira_visited"):
		# loaded a save between the fire and Mira's visit
		_mira_coming = true
		_mira_visits.call_deferred()


func _process(delta: float) -> void:
	if _mira_coming or player == null or not WorldState.is_fire_lit():
		return
	_resting = _resting + delta if player.state == Player.State.SIT else 0.0
	if _resting >= REST_BEFORE_KNOCK:
		_rest_by_the_fire()


## Sitting by the fire: a moment of warmth and rain on the roof, then the knock.
func _rest_by_the_fire() -> void:
	_mira_coming = true
	await Talk.present(self, DIALOGUE, "fire_rest", player)
	await NodeTimer.after(self, 2.0)
	_mira_visits()


func _on_house_changed() -> void:
	if WorldState.is_fire_lit() and not WorldState.has_flag("house.fire_lit"):
		WorldState.set_flag("house.fire_lit")
		_fire_catches()


## The fire catches: the room warms over a few seconds, the rain moves to the roof, music.
func _fire_catches() -> void:
	Beat.mark("fire")
	AudioDirector.sfx("fire_light")
	var tint := view.world_root.get_node_or_null("WorldTint") as CanvasModulate
	if tint != null:
		create_tween().tween_property(tint, ^"color", WARM_TINT, 5.0).set_trans(Tween.TRANS_SINE)
	AudioDirector.set_ambience(WARM_AMBIENCE, ambience_db, 4.0)
	AudioDirector.play_music("valley", 8.0)
	while dialogue_box.visible:
		await get_tree().process_frame
	await NodeTimer.after(self, mira_after)
	if not _mira_coming:
		_mira_coming = true
		_mira_visits()


func _mira_visits() -> void:
	if WorldState.has_flag("house.mira_visited") or not is_inside_tree():
		return
	while dialogue_box.visible or MenuLayer.any_open(get_tree()):
		await get_tree().process_frame
	var cut := Cutscene.begin(self)
	AudioDirector.sfx("door_knock")
	await cut.wait(0.9)
	await cut.say(DIALOGUE, "knock")
	await cut.wait(0.5)
	AudioDirector.sfx("door_open")
	await ScreenFade.fade_out(0.5)
	WorldState.set_flag("house.mira_knocked")
	await cut.wait(0.4)
	await ScreenFade.fade_in(0.7)
	Beat.mark("mira_visit")
	await cut.say(DIALOGUE, "mira_visit")
	await cut.wait(1.0)
	await ScreenFade.fade_out(0.9)
	WorldState.set_flag("house.mira_left")
	AudioDirector.sfx("door_close", -6.0)
	await cut.wait(0.8)
	await ScreenFade.fade_in(1.2)
	cut.end()
