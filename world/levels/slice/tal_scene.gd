class_name TalScene
extends LookScene
## The valley in the vertical slice (beats 3, 4 and 7, docs/PHASE4_PLAN.md): arriving out of
## the rift in the rain, Mira's first no, the way across the stream; in the evening the
## goat, Mira's fire and the end of the prototype. Story state lives in WorldState flags;
## this script only reacts to them.
## Back from the shed with the wood, the Antreiber walks behind the player for a stretch,
## slower than before and without a word, and then sits down by the path (ADR-042).

const DIALOGUE := "res://content/dialogue/slice/tal.dialogue"
const MAIN_MENU := "res://core/boot/boot.tscn"
## Cells west of this column are the house side of the stream.
const STREAM_COLUMN := 38
## Where the protagonist sits at Mira's fire for the last scene (cell, facing).
const FIRE_SEAT := Vector2i(50, 20)
const GOAT_OBJECTIVES: PackedStringArray = ["goat", "potato"]
const ANTREIBER_ACTOR := preload("res://encounters/antreiber/antreiber_actor.tscn")
const ANTREIBER_SHEET := preload("res://entities/character/sheet_antreiber_look.tres")
## Where the Antreiber sits down by the path (the map shows him there from then on).
const ANTREIBER_SEAT := Vector2i(6, 23)
## He follows this long, or until the player is this far into the valley (column).
const FOLLOW_SECONDS := 7.0
const FOLLOW_UNTIL_COLUMN := 13

var _follower: AntreiberActor
var _follow_time := 0.0


func _ready() -> void:
	# after Mira's visit it is evening; the stored time of day (the rainy day of the first
	# visit) would otherwise win over the scene's preset
	if WorldState.has_flag("house.mira_visited") and WorldState.day_preset() in ["", "regentag"]:
		WorldState.set_day_preset("abend")
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	if not WorldState.has_flag("valley.arrived"):
		WorldState.set_flag("valley.arrived")
		Beat.mark("valley_arrival")
	if WorldState.has_flag("house.mira_visited"):
		Beat.mark("evening")
	if (
		WorldState.has_flag("valley.wood_taken")
		and not WorldState.has_flag("valley.antreiber_rests")
	):
		_antreiber_follows.call_deferred()


func _process(delta: float) -> void:
	if _follower == null or player == null:
		return
	_follower.trail(player, delta)
	_follow_time += delta
	var far := player.global_position.x > FOLLOW_UNTIL_COLUMN * map.data.tile_size
	if _follow_time > FOLLOW_SECONDS or far:
		_antreiber_sits()


## Back from the shed: he comes along, behind the player this time.
func _antreiber_follows() -> void:
	if player == null:
		return
	var seat := map.cell_to_world(ANTREIBER_SEAT)
	if player.global_position.distance_to(seat) > 6.0 * map.data.tile_size:
		# loaded somewhere else in the valley: he is already sitting by the path
		WorldState.set_flag("valley.antreiber_rests")
		return
	_follower = ANTREIBER_ACTOR.instantiate() as AntreiberActor
	_follower.sheet = ANTREIBER_SHEET
	_follower.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	map.entities.add_child(_follower)
	_follower.global_position = player.global_position + Vector2(-AntreiberActor.TRAIL_DISTANCE, 2)


func _antreiber_sits() -> void:
	var actor := _follower
	_follower = null
	await actor.walk_to(map.cell_to_world(ANTREIBER_SEAT), 30.0)
	actor.sit_down(Facing.Dir.W)
	await NodeTimer.after(self, 0.3)
	# the map's placement takes over (it stays there on every later visit)
	WorldState.set_flag("valley.antreiber_rests")
	actor.queue_free()


func _physics_process(_delta: float) -> void:
	if player == null or WorldState.has_flag("valley.crossed"):
		return
	if player.global_position.x < STREAM_COLUMN * map.data.tile_size:
		WorldState.set_flag("valley.crossed")
		Beat.mark("crossed")
		if WorldState.quest_stage("main_valley_shelter") == "cross":
			WorldState.advance_quest("main_valley_shelter", "house")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"valley.mira_met":
			Beat.mark("first_no")
		"valley.goat_met":
			_goat_objective("goat")
		"valley.potato_taken":
			_goat_objective("potato")
		"valley.ending":
			_play_ending()


func _goat_objective(objective: String) -> void:
	if not WorldState.is_quest_active("side_valley_goat"):
		return
	WorldState.complete_objective("side_valley_goat", objective)
	for needed in GOAT_OBJECTIVES:
		if not WorldState.is_objective_done("side_valley_goat", needed):
			return
	WorldState.advance_quest("side_valley_goat", "trade")


## Beat 7: Mira makes room at her fire. "Morgen gehe ich weiter." Black. The title.
func _play_ending() -> void:
	Beat.mark("ending")
	while dialogue_box.visible:
		await get_tree().process_frame
	var cut := Cutscene.begin(self)
	await cut.wait(0.6)
	await ScreenFade.fade_out(1.2)
	player.teleport(map.cell_to_world(FIRE_SEAT) + Vector2(0, 2))
	player.sit_on(player.global_position, Facing.Dir.E)
	view.follow(player)
	AudioDirector.play_music("valley", 3.0)
	await cut.wait(0.6)
	await ScreenFade.fade_in(1.6)
	await cut.wait(1.2)
	await cut.say(DIALOGUE, "ending")
	await cut.wait(2.0)
	WorldState.set_flag("slice.finished")
	# the save remembers the ending (the start menu shows the Real title from now on)
	SaveSystem.unblock(&"cutscene")
	SaveSystem.request_autosave("slice_finished")
	SaveSystem.block(&"cutscene")
	Log.info(
		Log.Category.WORLD_STATE,
		"vertical slice finished",
		{"minute": snappedf(WorldState.state.playtime_seconds / 60.0, 0.1)}
	)
	await ScreenFade.fade_out(2.5)
	var card := TitleCard.play(self, "END_OF_SLICE")
	await card.finished
	cut.end()
	get_tree().change_scene_to_file(MAIN_MENU)
