class_name TalScene
extends LookScene
## The valley in the vertical slice (beats 3, 4 and 7, docs/PHASE4_PLAN.md): arriving out of
## the rift in the rain, Mira's first no, the way across the stream; in the evening the
## goat, Mira's fire and the end of the prototype. Story state lives in WorldState flags;
## this script only reacts to them.
## Back from the shed with the wood, the Antreiber walks behind the player for a stretch,
## slower than before and without a word, and then sits down by the path (ADR-042).

const DIALOGUE := "res://content/dialogue/slice/tal.dialogue"
const ARRIVAL_DIALOGUE := "res://content/dialogue/akt2/ankunft.dialogue"
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
## How long the camera takes to look up to the mountains at the end, and how long the
## mountains stay in view before Mira answers and again before the screen goes dark.
const MOUNTAIN_PAN_SECONDS := 4.0
const MOUNTAIN_HOLD_SECONDS := 2.5
const SEA_HOLD_SECONDS := 2.5
## The first steps that call up the arrival echo (B1): this far on foot, in cells. A jump of
## more than ECHO_JUMP pixels between two physics frames is a teleport and no step.
const ECHO_STEPS := 2.0
const ECHO_JUMP := 8.0
## A gust is waited for this long (play time) before the echo goes on without one.
const ECHO_GUST_SECONDS := 4.0
const ECHO_GUST_MIN := 0.5

var _follower: AntreiberActor
var _follow_time := 0.0
var _mountain_tween: Tween


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
	if not Beat.reached("arrival_echo") and not WorldState.has_flag("valley.mira_met"):
		_arrival_echo.call_deferred()
	if WorldState.has_flag("house.mira_visited"):
		Beat.mark("evening")
	if (
		WorldState.has_flag("valley.wood_taken")
		and not WorldState.has_flag("valley.antreiber_rests")
	):
		_antreiber_follows.call_deferred()
	# a save from the moment Mira made room at her fire (the game closed during the last
	# scene): the ending plays again instead of leaving the slice unfinishable
	if WorldState.has_flag("valley.ending") and not Chapter.reached("slice"):
		_play_ending.call_deferred()


## B1: after the first steps a gust goes through the wet leaves (the real world's wind, which the
## leaves and the soundscape follow), and the valley says what Elysia never said (ARRIVAL_DIALOGUE).
## It plays once, a teleport is no step, and it gives way when Mira is met first.
func _arrival_echo() -> void:
	var tree := get_tree()
	var walked := 0.0
	var last := player.global_position
	while walked < ECHO_STEPS * map.data.tile_size:
		await tree.physics_frame
		if not is_inside_tree() or WorldState.has_flag("valley.mira_met"):
			return
		var step := player.global_position.distance_to(last)
		last = player.global_position
		# only the way over the rift is answered: a valley entered any other way has no Act I behind it
		if step < ECHO_JUMP and Chapter.reached("act1"):
			walked += step
	while _echo_waits():
		await tree.physics_frame
		if not is_inside_tree() or WorldState.has_flag("valley.mira_met"):
			return
	var cut := Cutscene.begin(self)
	var waited := 0.0
	while _calm() and waited < ECHO_GUST_SECONDS:
		await tree.physics_frame
		waited += get_physics_process_delta_time()
	await cut.say(ARRIVAL_DIALOGUE, "arrival_echo")
	cut.end()
	Beat.mark("arrival_echo")


## True while nothing may start: a line is up, a menu is open, the player is held, or the picture
## still comes back from the black of the rift (the player may walk before it has).
func _echo_waits() -> bool:
	return (
		dialogue_box.is_open()
		or player.is_locked()
		or MenuLayer.any_open(get_tree())
		or ScreenFade.is_covered()
		or ScreenFade.is_fading()
	)


## True while a soundscape plays and its wind is down (-1 without one: nothing to wait for).
func _calm() -> bool:
	var gust := AudioDirector.wind_gust()
	return gust >= 0.0 and gust < ECHO_GUST_MIN


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
		"valley.mountains_seen":
			_look_to_the_mountains()


func _goat_objective(objective: String) -> void:
	if not WorldState.is_quest_active("side_valley_goat"):
		return
	WorldState.complete_objective("side_valley_goat", objective)
	for needed in GOAT_OBJECTIVES:
		if not WorldState.is_objective_done("side_valley_goat", needed):
			return
	WorldState.advance_quest("side_valley_goat", "trade")


## The camera follows Mira's look north, over the treeline to the mountains (ADR-043).
func _look_to_the_mountains() -> void:
	if _mountain_tween != null:
		return
	var look := Node2D.new()
	look.name = "MountainsLook"
	view.world_root.add_child(look)
	# placed so the camera does not move until the look rises
	look.global_position = view.camera_position - GameView.FOLLOW_OFFSET
	view.follow(look, false)
	var top := view.bounds.position.y + view.view_size.y * 0.5 - GameView.FOLLOW_OFFSET.y
	# kept so the ending can wait for the mountains to be in full view before it goes on
	_mountain_tween = create_tween()
	_mountain_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_mountain_tween.tween_property(look, ^"global_position:y", top, MOUNTAIN_PAN_SECONDS)
	# the sun's beams belong to the meadow; over the open sky they would only stripe it
	if day_light != null and day_light.rays != null:
		create_tween().tween_property(day_light.rays, ^"strength", 0.1, MOUNTAIN_PAN_SECONDS)


## Beat 7: Mira makes room at her fire. "Morgen gehe ich weiter." The camera looks up to the
## mountains and stays there; only then she says "Zum Meer." Black. The title.
func _play_ending() -> void:
	Beat.mark("ending")
	while dialogue_box.is_open():
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
	# a save from the last scene replays it with the flag already set: no signal, no look
	if WorldState.has_flag("valley.mountains_seen"):
		_look_to_the_mountains()
	# her answer only means something with the mountains in full view (Game Bible §56): the
	# look is never cut short by the dark, however fast the lines were clicked through
	if _mountain_tween != null and _mountain_tween.is_running():
		await _mountain_tween.finished
	await cut.wait(MOUNTAIN_HOLD_SECONDS)
	await cut.say(DIALOGUE, "ending_sea")
	await cut.wait(SEA_HOLD_SECONDS)
	Chapter.mark("slice")
	# the save remembers the ending (the start menu shows the Real title from now on)
	SaveSystem.unblock(cut.key)
	SaveSystem.request_autosave("slice_finished")
	SaveSystem.block(cut.key)
	Log.info(
		Log.Category.WORLD_STATE,
		"vertical slice finished",
		{"minute": snappedf(WorldState.state.playtime_seconds / 60.0, 0.1)}
	)
	await ScreenFade.fade_out(2.5)
	var card := TitleCard.play(self, "")
	await card.finished
	cut.end()
	get_tree().change_scene_to_file(MAIN_MENU)
