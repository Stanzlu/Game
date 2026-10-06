class_name HausScene
extends LookScene
## The house from inside (beat 6, docs/PHASE4_PLAN.md): empty since spring, cold and still.
## Once the fire catches, the room warms, quiet music returns; a while later Mira knocks,
## warms herself, talks and goes again. The cat waits outside at the window.
## Story state lives in WorldState (house fire, flags); this script stages it.
## Sitting by the fire, the Antreiber comes in and finds something to do (ADR-042). Staying
## seated a moment is the answer, as on the way to the shed: then he sits down too, and
## later the cat sleeps on him. The cat gets a name if the player wants (Game Bible §28).

const DIALOGUE := "res://content/dialogue/slice/haus.dialogue"
const COLD_TINT := Color(0.5, 0.56, 0.68)
## The fire's glow fills the room: honey and amber, not grey (ADR-041).
const WARM_TINT := Color(1.0, 0.84, 0.66)
const COLD_AMBIENCE := preload("res://content/audio/haus_kalt.tres")
const WARM_AMBIENCE := preload("res://content/audio/haus_feuer.tres")
## Seconds the player sits by the burning fire before the quiet moment (Game Bible §45:
## after the fire comes rest); a little later Mira knocks.
const REST_BEFORE_KNOCK := 2.5
## Seconds of staying seated after the Antreiber spoke: then he sits down too.
const STAY_SEATED := 3.0
const ANTREIBER_ACTOR := preload("res://encounters/antreiber/antreiber_actor.tscn")
const ANTREIBER_SHEET := preload("res://entities/character/sheet_antreiber_look.tres")
const DOOR_CELL := Vector2i(19, 15)
## His place by the fire (the map's placement "a" takes over once he sits).
const ANTREIBER_CELL := Vector2i(18, 10)
const CAT_SUGGESTIONS: PackedStringArray = [
	"CAT_NAME_SUGGESTION_1",
	"CAT_NAME_SUGGESTION_2",
	"CAT_NAME_SUGGESTION_3",
	"CAT_NAME_SUGGESTION_4"
]
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
	WorldState.flag_changed.connect(_on_flag_changed)
	if WorldState.has_flag("house.cat_naming"):
		# saved while the name entry was open: it opens again when asked again
		WorldState.clear_flag("house.cat_naming")
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
	if (
		WorldState.has_flag("valley.wood_taken")
		and not WorldState.has_flag("house.antreiber_by_fire")
		and not WorldState.has_flag("house.antreiber_left")
	):
		await _antreiber_comes()
	await NodeTimer.after(self, 2.0)
	_mira_visits()


## He followed the player home and has ideas. Staying seated lets him sit down too; getting
## up sends him off to find something to do outside.
func _antreiber_comes() -> void:
	var actor := ANTREIBER_ACTOR.instantiate() as AntreiberActor
	actor.sheet = ANTREIBER_SHEET
	actor.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	map.entities.add_child(actor)
	actor.global_position = map.cell_to_world(DOOR_CELL)
	AudioDirector.sfx("door_open", -10.0)
	await actor.walk_to(map.cell_to_world(ANTREIBER_CELL), 40.0)
	actor.face(Facing.from_vector(player.global_position - actor.global_position))
	await Talk.present(self, DIALOGUE, "antreiber_fire", player)
	var seated := 0.0
	while seated < STAY_SEATED * Settings.timing_factor() and player.state == Player.State.SIT:
		await get_tree().process_frame
		if not get_tree().paused:
			seated += get_process_delta_time()
	if player.state == Player.State.SIT:
		actor.sit_down(Facing.Dir.W)
		await Talk.present(self, DIALOGUE, "antreiber_sits", player)
		WorldState.set_flag("house.antreiber_by_fire")
		actor.queue_free()
		return
	await Talk.present(self, DIALOGUE, "antreiber_cheers", player)
	await actor.walk_to(map.cell_to_world(DOOR_CELL), 55.0)
	AudioDirector.sfx("door_close", -10.0)
	WorldState.set_flag("house.antreiber_left")
	actor.queue_free()


func _on_flag_changed(id: String, value: bool) -> void:
	if id == "house.cat_naming" and value:
		_name_the_cat()


## The cat gets a name, if the player wants one (Game Bible §28).
func _name_the_cat() -> void:
	while dialogue_box.visible:
		await get_tree().process_frame
	var entry := NameEntry.new()
	entry.name = "CatName"
	entry.title_key = "CAT_NAME_TITLE"
	entry.suggestions = CAT_SUGGESTIONS
	add_child(entry)
	entry.chosen.connect(func(cat: String) -> void: WorldState.set_cat_name(cat))
	get_tree().paused = true
	entry.open()
	await entry.closed
	get_tree().paused = false
	# `closed` comes before `chosen`: let the name arrive first
	await get_tree().process_frame
	WorldState.clear_flag("house.cat_naming")
	entry.queue_free()
	if not WorldState.cat_name().is_empty():
		await Talk.present(self, DIALOGUE, "cat_named", player)


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
