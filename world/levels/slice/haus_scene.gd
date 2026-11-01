class_name HausScene
extends LookScene
## The house from inside (beat 6, docs/PHASE4_PLAN.md): empty since spring, cold and still.
## Once the fire catches, the room warms, quiet music returns; a while later Mira knocks,
## warms herself, talks and goes again. The cat waits outside at the window.
## Story state lives in WorldState (house fire, flags); this script stages it.
## Sitting by the fire, the Antreiber comes in and finds something to do (ADR-042). Staying
## seated a moment is the answer, as on the way to the shed: then he sits down too, and
## later the cat sleeps on him. The cat gets a name if the player wants (Game Bible §28).
## The first safe moment (act2_safe) is the rest by the fire; whoever can hum the child's tune
## hears the song once, for a breath, when it has come (B5); and when Mira has gone, there is a
## small thing left to do by the fire (three deeds and a silence, each its own value, Game Bible
## §18): the answer sets a value.<id> flag, and the room answers in its own way.
## Mira's visit is staged in the room, not in the dark: the door opens, she comes in, sits
## down by the fire, and later gets up and goes (a GuestWalker; the map's seated Mira takes
## her place while she talks).
## The way home (Act III, W6, ADR-070) ends here: the room has changed (a bench stands in the
## corner and the Antreiber sits at it, wherever he was before; the map reads house.workbench),
## the first time she enters in the stage "home" the scene of the homecoming plays, the hermit comes
## as a guest if she asked him, and then the act is over: quietly, with a save, and no title.

## The homecoming (W6) goes from the wait for a quiet room to the end of the act, phase by phase.
enum HomePhase {
	OFF,
	WAIT,
	CALM,
	KNOCK,
	CHAIR,
	SETTLE,
	CLOSE,
	STAND,
	END,
}

const DIALOGUE := "res://content/dialogue/slice/haus.dialogue"
## The answer to the Antreiber's ideas at the fire (Act II, B2).
const NEIN_DIALOGUE := "res://content/dialogue/akt2/nein.dialogue"
## The song in the house and the deeds by the fire (Act II, B5).
const FEUER_DIALOGUE := "res://content/dialogue/akt2/feuer.dialogue"
## The homecoming at the bench and the hermit's visit (Act III, W6).
const HEIMKEHR_DIALOGUE := "res://content/dialogue/akt3/heimkehr.dialogue"
## A breath of quiet before the song, and how long the window takes to turn to evening.
const SONG_PAUSE := 1.0
const EVENING_FALLS_SECONDS := 4.0
const COLD_TINT := Color(0.5, 0.56, 0.68)
## Once the fire burns, the room is lit by it: a dim warm base, and the fireplace's own
## flickering light gives the falloff (a bright flat tint made the corners as light as the
## hearth and everything one orange; ADR-041 still holds: honey and amber, not grey).
const WARM_TINT := Color(0.54, 0.48, 0.48)
## The room (cells): the camera stays centred on it instead of drifting over the black.
const ROOM := Rect2i(12, 5, 16, 12)
## Grey daylight from the rainy window: a cool counterpart to the fire on the floor below it.
const WINDOW_CELL := Vector2(23.5, 9.0)
const WINDOW_LIGHT := Color("#7d93c8")
const WINDOW_ENERGY := 0.45
## In the evening the rain has stopped and the low sun shines in warm and weaker.
const WINDOW_LIGHT_EVENING := Color("#e0a860")
const WINDOW_ENERGY_EVENING := 0.35
## The morning after it (Act III, ADR-070): the light is clear and cold, weaker than the rain's.
const WINDOW_LIGHT_MORNING := Color("#c4d8ec")
const WINDOW_ENERGY_MORNING := 0.4
## Night outside the walls: a soft dark ring round the room, so the house does not hang in a flat
## dark field. Alpha at the far edge, and the radius (px) where it is full.
const NIGHT_ALPHA := 0.8
const NIGHT_RADIUS := 256.0
## The window brightens for a moment when the door lets the outside in.
const DOOR_GLARE := 0.35
const DOOR_GLARE_SECONDS := 1.2
const COLD_AMBIENCE := preload("res://content/audio/haus_kalt.tres")
const WARM_AMBIENCE := preload("res://content/audio/haus_feuer.tres")
## Fire and quiet crickets, no rain on the roof any more (the day_preset is "abend").
const EVENING_AMBIENCE := preload("res://content/audio/haus_abend.tres")
## Fire and a bird outside, no crickets (the day_preset is "morgen", Act III).
const MORNING_AMBIENCE := preload("res://content/audio/haus_morgen.tres")
## Seconds the player sits by the burning fire before the quiet moment (Game Bible §45:
## after the fire comes rest); a little later Mira knocks.
const REST_BEFORE_KNOCK := 2.5
## Seconds of staying seated after the Antreiber spoke: then he sits down too.
const STAY_SEATED := 3.0
const ANTREIBER_ACTOR := preload("res://encounters/antreiber/antreiber_actor.tscn")
const ANTREIBER_SHEET := preload("res://entities/character/sheet_antreiber_look.tres")
const MIRA_SHEET := preload("res://entities/character/sheet_mira_look.tres")
const HERMIT_SHEET := preload("res://entities/character/sheet_einsiedler_look.tres")
const DOOR_CELL := Vector2i(19, 15)
## Where Mira sits (the map's placement "M"), looking at the fire, and the way there round
## the rug where the player sits.
const MIRA_CELL := Vector2i(15, 10)
const MIRA_WAY_IN: Array[Vector2i] = [Vector2i(16, 14), Vector2i(15, 12), MIRA_CELL]
const MIRA_SPEED_IN := 40.0
const MIRA_SPEED_OUT := 45.0
## The cat sleeps here once fed (the map's placement "k"); on the Antreiber's lap at the bench once
## the bench stands (the map's placement "Z").
const CAT_CELL := Vector2i(19, 10)
const BENCH_CAT_CELL := Vector2i(22, 15)
## The hermit's chair (the map's placement "C") and his way to it from the door, round the end of
## the table; he sits looking at the table, and goes the same way back.
const CHAIR_CELL := Vector2i(22, 12)
const HERMIT_WAY_IN: Array[Vector2i] = [Vector2i(21, 14), Vector2i(21, 13), CHAIR_CELL]
const HERMIT_SPEED_IN := 38.0
const HERMIT_SPEED_OUT := 42.0
## Play time (seconds) the homecoming waits between its steps: after the picture is up, after the
## knock, after the chair is down, after he sat, before the last lines, after he stood, after the
## door.
const HOME_CALM := 0.8
const HOME_KNOCK := 0.9
const HOME_CHAIR := 0.6
const HOME_SETTLE := 0.6
const HOME_BEAT := 0.6
const HOME_STAND := 0.5
const HOME_END := 0.8
## After loading the picture fades in for two seconds: Mira waits that long and a moment more.
const AFTER_LOAD_CALM := 1.5
const ANTREIBER_BLOCK := &"antreiber_visit"
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
var _home := HomePhase.OFF
var _home_clock := 0.0
## True while a line or a walk of the homecoming runs by itself; the phase goes on when it ended.
var _home_busy := false
var _home_cut: Cutscene
var _hermit: GuestWalker
var _window_light: PointLight2D
var _window_energy := WINDOW_ENERGY
var _cat_name_seen := ""


func _ready() -> void:
	var warm := WorldState.is_fire_lit()
	world_tint = WARM_TINT if warm else COLD_TINT
	ambience = _ambience(warm)
	# the valley's theme is Mira's: the morning after she went on has none
	music = "valley" if warm and not _morning() else "silence"
	# whoever looks closely sees one more spot in the room (the map's prop reads the flag)
	if WorldState.has_facet("perception"):
		WorldState.set_flag("house.looks_closely")
	# the way home (W6): a walk that reached the night and came to the house without the valley
	# (an old save) is home now; and whoever is home, or done, finds the bench in the corner. Both
	# before super(): the map reads the flags when it builds, the entry save must say it
	if WorldState.quest_stage("main_forest_way") == "night":
		WorldState.advance_quest("main_forest_way", "home")
	var stage := WorldState.quest_stage("main_forest_way")
	if stage in ["home", "done"]:
		WorldState.set_flag("house.workbench")
	if stage == "home":
		# a homecoming that was broken off plays again from the door: the chair comes with him
		WorldState.clear_flag("house.guest_hermit")
	super()
	_add_window_light()
	_add_night_surround()
	view.bounds = Rect2(
		Vector2(ROOM.position * map.data.tile_size), Vector2(ROOM.size * map.data.tile_size)
	)
	_cat_name_seen = WorldState.cat_name()
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
	if stage == "home":
		_home = HomePhase.WAIT
	if warm and not WorldState.has_flag("house.mira_visited"):
		# loaded a save between the fire and Mira's visit: the rest by the fire (and the
		# Antreiber, if he has not come yet) still comes first; Mira knocks in any case later
		if _antreiber_pending():
			_mira_later.call_deferred()
		else:
			_mira_coming = true
			_mira_visits.call_deferred()


func _process(delta: float) -> void:
	if _mira_coming or player == null or not WorldState.is_fire_lit():
		return
	_resting = _resting + delta if player.state == Player.State.SIT else 0.0
	if _resting >= REST_BEFORE_KNOCK:
		_rest_by_the_fire()


func _physics_process(delta: float) -> void:
	if _home != HomePhase.OFF:
		_home_step(delta)


## True from the entry into the stage "home" until the act is over: the homecoming is waiting or
## playing.
func is_homecoming() -> bool:
	return _home != HomePhase.OFF


## The homecoming (W6), a phase of the physics step: the pauses count play time, the lines and the
## walks run by themselves (`_home_busy`) and hand the phase on when they have ended. A scene that
## is freed meanwhile leaves nothing behind that wakes up without it, and a game closed meanwhile
## has saved nothing of it (the cutscene blocks saving): the stage is still "home" and it plays
## again. Everyone gets the first and the last lines; whoever asked the hermit in the hut
## (forest.hermit_invited, only with care) gets his visit in between, and the act never depends
## on it.
func _home_step(delta: float) -> void:
	if _home_busy or player == null:
		return
	_home_clock += delta
	match _home:
		HomePhase.WAIT:
			# nothing starts while a line is up, a menu or another scene holds the room, or the
			# picture still comes back from the black of the door
			if _quiet() and not player.is_locked():
				_home_cut = Cutscene.begin(self)
				_home_to(HomePhase.CALM)
		HomePhase.CALM:
			if _home_clock >= HOME_CALM:
				_home_says_in()
		HomePhase.KNOCK:
			if _home_clock >= HOME_KNOCK:
				_hermit_comes()
		HomePhase.CHAIR:
			if _home_clock >= HOME_CHAIR:
				_hermit_sits()
		HomePhase.SETTLE:
			if _home_clock >= HOME_SETTLE:
				_hermit_says()
		HomePhase.CLOSE:
			if _home_clock >= HOME_BEAT:
				_home_says_close()
		HomePhase.STAND:
			if _home_clock >= HOME_STAND:
				_hermit_goes()
		HomePhase.END:
			if _home_clock >= HOME_END:
				_home_finishes()


func _home_to(phase: HomePhase) -> void:
	_home = phase
	_home_clock = 0.0


func _home_says_in() -> void:
	var cut := _home_cut
	_home_busy = true
	await cut.say(HEIMKEHR_DIALOGUE, "home_in")
	_home_busy = false
	if WorldState.has_flag("forest.hermit_invited"):
		AudioDirector.sfx("door_knock")
		_home_to(HomePhase.KNOCK)
	else:
		_home_to(HomePhase.CLOSE)


## The door opens and the hermit comes in with his chair, round the end of the table to where it
## goes; he sets it down there.
func _hermit_comes() -> void:
	_home_busy = true
	_hermit = _guest_at(DOOR_CELL, HERMIT_SHEET)
	AudioDirector.sfx("door_open")
	_glare()
	_hermit.appear()
	var way: Array[Vector2] = []
	for cell in HERMIT_WAY_IN:
		way.append(map.cell_to_world(cell))
	await _hermit.walk_to(way, HERMIT_SPEED_IN)
	AudioDirector.sfx("wood_drop")
	_home_busy = false
	_home_to(HomePhase.CHAIR)


## He sits; the chair appears under him (the map's prop reads the flag).
func _hermit_sits() -> void:
	WorldState.set_flag("house.guest_hermit")
	_hermit.sit_down(Facing.Dir.W)
	_home_to(HomePhase.SETTLE)


func _hermit_says() -> void:
	var cut := _home_cut
	_home_busy = true
	await cut.say(HEIMKEHR_DIALOGUE, "guest_enter")
	_home_busy = false
	_home_to(HomePhase.CLOSE)


## The last lines of the act, said to everyone (the first one only after the hermit's visit).
func _home_says_close() -> void:
	var cut := _home_cut
	_home_busy = true
	await cut.say(HEIMKEHR_DIALOGUE, "act3_close")
	_home_busy = false
	if _hermit != null:
		_hermit.stand_up()
		_home_to(HomePhase.STAND)
	else:
		_home_to(HomePhase.END)


## He gets up and goes the way he came, the chair stays; the door closes behind him.
func _hermit_goes() -> void:
	_home_busy = true
	var way: Array[Vector2] = []
	for i in range(HERMIT_WAY_IN.size() - 2, -1, -1):
		way.append(map.cell_to_world(HERMIT_WAY_IN[i]))
	way.append(map.cell_to_world(DOOR_CELL))
	await _hermit.walk_to(way, HERMIT_SPEED_OUT)
	AudioDirector.sfx("door_close", -3.0)
	await _hermit.vanish()
	_hermit.queue_free()
	_hermit = null
	_home_busy = false
	_home_to(HomePhase.END)


## The act ends, quietly: no black and no title (Act IV goes on from here). One block without a
## wait: the stage, the mark of the chapter and the beat are set together, and the autosave that
## they ask for is written when the scene lets go of the room, with all three in it.
func _home_finishes() -> void:
	_home_to(HomePhase.OFF)
	WorldState.advance_quest("main_forest_way", "done")
	Chapter.mark("act3")
	Beat.mark("act3_home")
	_home_cut.end()


## Sitting by the fire: a moment of warmth and rain on the roof, then the knock. The moment
## is told once (the cue sets house.rested): sitting down again after loading goes straight
## on to what was still to come.
func _rest_by_the_fire() -> void:
	_mira_coming = true
	if not WorldState.has_flag("house.rested"):
		await Talk.present(self, DIALOGUE, "fire_rest", player)
	await _sing()
	if _antreiber_pending():
		await _antreiber_visit()
	await NodeTimer.after(self, 2.0)
	_mira_visits()


## The song in the house (B5), once, for whoever can hum the tune from Elysia's garden: after the
## quiet by the fire, or, if there was none, after Mira has gone. The flag comes with the first line
## and the scene plays the sound with it; the way the player got here does not matter.
func _sing(cut: Cutscene = null) -> void:
	if not WorldState.has_flag("melody.child_hum") or Collection.has_melody("house_hum"):
		return
	if cut == null:
		await NodeTimer.after(self, SONG_PAUSE)
		await Talk.present(self, FEUER_DIALOGUE, "house_hum", player)
	else:
		await cut.wait(SONG_PAUSE)
		await cut.say(FEUER_DIALOGUE, "house_hum")


## The Antreiber's visit cannot be saved half way: a save would load into a room where he
## is not (yet) and would start it again, or leave him standing in it.
func _antreiber_visit() -> void:
	SaveSystem.block(ANTREIBER_BLOCK)
	await _antreiber_comes()
	SaveSystem.unblock(ANTREIBER_BLOCK)
	# marked once the visit is over: a mark inside it would queue an autosave that the scene's
	# exit flushes half way (refused, but not yet sitting)
	if WorldState.has_flag("house.antreiber_refused"):
		Beat.mark("act2_nein")


## He followed the player home and has ideas, and the player may answer (nein.dialogue): "Heute
## nicht." is taken and he sits down; "Morgen." is a date, and he goes to look at the roof. Without
## a word the old answer holds: staying seated lets him sit down too, getting up sends him off to
## find something to do outside.
func _antreiber_comes() -> void:
	var actor := ANTREIBER_ACTOR.instantiate() as AntreiberActor
	actor.sheet = ANTREIBER_SHEET
	actor.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	map.entities.add_child(actor)
	actor.global_position = map.cell_to_world(DOOR_CELL)
	AudioDirector.sfx("door_open")
	await actor.walk_to(map.cell_to_world(ANTREIBER_CELL), 40.0)
	actor.face(Facing.from_vector(player.global_position - actor.global_position))
	await Talk.present(self, DIALOGUE, "antreiber_fire", player)
	await Talk.present(self, NEIN_DIALOGUE, "antreiber_ask", player)
	if WorldState.has_flag("house.antreiber_postponed"):
		await _antreiber_leaves(actor)
		return
	var seated := 0.0
	var refused := WorldState.has_flag("house.antreiber_refused")
	while (
		not refused
		and seated < STAY_SEATED * Settings.timing_factor()
		and player.state == Player.State.SIT
	):
		await get_tree().process_frame
		if not get_tree().paused:
			seated += get_process_delta_time()
	if refused or player.state == Player.State.SIT:
		actor.sit_down(Facing.Dir.W)
		await Talk.present(self, DIALOGUE, "antreiber_sits", player)
		WorldState.set_flag("house.antreiber_by_fire")
		actor.queue_free()
		return
	await Talk.present(self, DIALOGUE, "antreiber_cheers", player)
	await _antreiber_leaves(actor)


## He goes out by the door; he is gone for the story once he heads for it (nothing can be saved
## meanwhile).
func _antreiber_leaves(actor: AntreiberActor) -> void:
	WorldState.set_flag("house.antreiber_left")
	await actor.walk_to(map.cell_to_world(DOOR_CELL), 55.0)
	AudioDirector.sfx("door_close", -3.0)
	actor.queue_free()


func _on_flag_changed(id: String, value: bool) -> void:
	if id == "house.cat_naming" and value:
		_name_the_cat()
	elif id == "house.cat_fed" and value:
		# she comes in through the window and curls up at the fire
		SoundBank.play_at(map.entities, "cat_meow", map.cell_to_world(_cat_cell()))
	elif id == "house.prints_seen" and value:
		Beat.mark("act2_blick")
	elif id == "house.rested" and value:
		_first_safe_moment()
	elif id == "melody.house_hum" and value:
		AudioDirector.sfx("house_hum", -2.0, 1.0)
	elif id == "value.freedom" and value:
		AudioDirector.sfx("door_open")
		_glare()
	elif id == "value.calm" and value:
		_evening_falls()


## The first time the fire holds and someone stays (Act II, act2_safe): the rest by the fire, or
## Mira's visit if nobody sat down before. The autosave of the mark comes when the box closes,
## before the Antreiber's visit sets its block (a mark after the cue itself would not).
func _first_safe_moment() -> void:
	Beat.mark("act2_safe")


## The cat gets a name, if the player wants one (Game Bible §28).
func _name_the_cat() -> void:
	while dialogue_box.is_open():
		await get_tree().process_frame
	var entry := NameEntry.new()
	entry.name = "CatName"
	entry.title_key = "CAT_NAME_TITLE"
	entry.suggestions = CAT_SUGGESTIONS
	entry.confirm_key = "CAT_NAME_CONFIRM"
	entry.back_key = "CAT_NAME_SKIP"
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
	var cat_name := WorldState.cat_name()
	if cat_name != _cat_name_seen:
		_cat_name_seen = cat_name
		if not cat_name.is_empty():
			# a name is a bit of attention: she purrs without waking up
			SoundBank.play_at(map.entities, "purr", map.cell_to_world(_cat_cell()))


## The fire catches: the wood is laid down, a moment later it takes (the fireplace flares
## up at the same moment), the room warms over a few seconds, the rain moves to the roof,
## music.
func _fire_catches() -> void:
	Beat.mark("fire")
	AudioDirector.sfx("wood_drop")
	_mira_later()
	await NodeTimer.after(self, Fireplace.IGNITE_DELAY)
	AudioDirector.sfx("fire_light")
	view.shake(1.5, 0.25)
	var tint := view.world_root.get_node_or_null("WorldTint") as CanvasModulate
	if tint != null:
		create_tween().tween_property(tint, ^"color", WARM_TINT, 5.0).set_trans(Tween.TRANS_SINE)
	AudioDirector.set_ambience(_ambience(true), ambience_db, 4.0)
	AudioDirector.play_music("valley", 8.0)


## The soundscape of the room: cold, warm with rain on the roof, or in the evening warm
## with crickets and no rain (the weather turned while Mira was here).
func _ambience(warm: bool) -> Resource:
	if not warm:
		return COLD_AMBIENCE
	if _morning():
		return MORNING_AMBIENCE
	return EVENING_AMBIENCE if _dry() else WARM_AMBIENCE


## The rain is over: the evening after it, and the morning after the evening (Act III, ADR-070).
func _dry() -> bool:
	return WorldState.day_preset() in ["abend", "morgen"]


## The morning after the evening at the fire (Act III): dry, but its own light and sound.
func _morning() -> bool:
	return WorldState.day_preset() == "morgen"


func _add_window_light() -> void:
	var evening := _dry()
	_window_energy = WINDOW_ENERGY_EVENING if evening else WINDOW_ENERGY
	var light := WINDOW_LIGHT_EVENING if evening else WINDOW_LIGHT
	if _morning():
		_window_energy = WINDOW_ENERGY_MORNING
		light = WINDOW_LIGHT_MORNING
	_window_light = PointLight2D.new()
	_window_light.name = "WindowLight"
	_window_light.texture = Decor.light_texture()
	_window_light.color = light
	_window_light.energy = _window_energy
	_window_light.texture_scale = 88.0 / 32.0
	_window_light.position = WINDOW_CELL * float(map.data.tile_size)
	map.entities.add_child(_window_light)


## A dark radial gradient centred on the room: clear inside the walls, darker towards the
## edge of the picture (the room's corners darken a little, like a lamp-lit room does).
func _add_night_surround() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, NIGHT_ALPHA))
	gradient.add_point(0.5, Color(0, 0, 0, 0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256
	var night := Sprite2D.new()
	night.name = "NightSurround"
	night.texture = texture
	night.scale = Vector2.ONE * NIGHT_RADIUS / 128.0
	night.position = Vector2(ROOM.get_center() * map.data.tile_size)
	night.z_index = 100
	night.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	view.world_root.add_child(night)


## Watching the fire until it gets dark: the rain is over, the window turns from grey to the
## low evening sun, and the room's sounds follow (the house has no DayLight of its own; the
## stored time of day is what the Bachlauf and the valley go on from).
func _evening_falls() -> void:
	WorldState.set_day_preset("abend")
	_window_energy = WINDOW_ENERGY_EVENING
	var tween := create_tween().set_parallel()
	tween.tween_property(_window_light, ^"color", WINDOW_LIGHT_EVENING, EVENING_FALLS_SECONDS)
	tween.tween_property(_window_light, ^"energy", _window_energy, EVENING_FALLS_SECONDS)
	AudioDirector.set_ambience(_ambience(true), ambience_db, EVENING_FALLS_SECONDS)


## The door lets the outside in: the window light swells for a moment.
func _glare() -> void:
	var tween := create_tween()
	tween.tween_property(
		_window_light, ^"energy", _window_energy + DOOR_GLARE, DOOR_GLARE_SECONDS * 0.4
	)
	tween.tween_property(_window_light, ^"energy", _window_energy, DOOR_GLARE_SECONDS * 0.6)


## Mira comes `mira_after` seconds after the fire at the latest, sitting or not.
func _mira_later() -> void:
	while dialogue_box.is_open():
		await get_tree().process_frame
	await NodeTimer.after(self, mira_after)
	if not _mira_coming:
		_mira_coming = true
		_mira_visits()


func _antreiber_pending() -> bool:
	return (
		WorldState.has_flag("valley.wood_taken")
		and not WorldState.has_flag("house.antreiber_by_fire")
		and not WorldState.has_flag("house.antreiber_left")
		and not WorldState.has_flag("forest.antreiber_ahead")
		# at the bench he has long since come in: he never comes to the fire again
		and not WorldState.has_flag("house.workbench")
	)


## Where the fed cat lies: at the fire, or on the Antreiber's lap once the bench stands (her sound
## follows the picture).
func _cat_cell() -> Vector2i:
	return BENCH_CAT_CELL if WorldState.has_flag("house.workbench") else CAT_CELL


## True while nothing may start: a line is open, a menu is up or the picture fades.
func _quiet() -> bool:
	return not (
		dialogue_box.is_open()
		or MenuLayer.any_open(get_tree())
		or ScreenFade.is_covered()
		or ScreenFade.is_fading()
	)


func _mira_visits() -> void:
	if WorldState.has_flag("house.mira_visited") or not is_inside_tree():
		return
	# after loading the picture is still fading in: no knocking into the black
	var calm := false
	while not _quiet():
		calm = calm or ScreenFade.is_covered() or ScreenFade.is_fading()
		await get_tree().process_frame
	if calm:
		await NodeTimer.after(self, AFTER_LOAD_CALM)
		while not _quiet():
			await get_tree().process_frame
	# Mira knocks after mira_after in any case: if nobody sat down, her staying is the first safe
	# moment (house.rested stays the rest by the fire's own, so that cue can still be told later)
	_first_safe_moment()
	var cut := Cutscene.begin(self)
	AudioDirector.sfx("door_knock")
	await cut.wait(0.9)
	await cut.say(DIALOGUE, "knock")
	await cut.wait(0.5)
	await _mira_comes_in(cut)
	Beat.mark("mira_visit")
	await cut.say(DIALOGUE, "mira_visit")
	await cut.wait(1.0)
	await _mira_goes(cut)
	await _sing(cut)
	await cut.say(FEUER_DIALOGUE, "fire_values")
	cut.end()
	# marked once the visit is over, as act2_nein: the autosave of a mark inside it waits for the end
	Beat.mark("act2_werte")


## The door opens, Mira steps in out of the rain, goes round the rug to the fire and sits.
## Once she sits, the map's seated Mira (house.mira_seated) takes her place.
func _mira_comes_in(cut: Cutscene) -> void:
	var guest := _guest_at(DOOR_CELL)
	AudioDirector.sfx("door_open")
	_glare()
	WorldState.set_flag("house.mira_knocked")
	guest.appear()
	var way: Array[Vector2] = []
	for cell in MIRA_WAY_IN:
		way.append(map.cell_to_world(cell))
	await guest.walk_to(way, MIRA_SPEED_IN)
	guest.sit_down(Facing.Dir.E)
	await cut.wait(0.6)
	WorldState.set_flag("house.mira_seated")
	guest.queue_free()


## After the talk she gets up, goes to the door and out; the door closes behind her.
func _mira_goes(cut: Cutscene) -> void:
	var seat := _seated_mira()
	var guest := _guest_at(MIRA_CELL)
	guest.sit_down(Facing.Dir.E, false)
	if seat != null:
		seat.visible = false
	await cut.wait(0.3)
	guest.stand_up()
	await cut.wait(0.5)
	var way: Array[Vector2] = []
	for i in range(MIRA_WAY_IN.size() - 2, -1, -1):
		way.append(map.cell_to_world(MIRA_WAY_IN[i]))
	way.append(map.cell_to_world(DOOR_CELL))
	await guest.walk_to(way, MIRA_SPEED_OUT)
	AudioDirector.sfx("door_close", -3.0)
	await guest.vanish()
	guest.queue_free()
	WorldState.set_flag("house.mira_left")
	await cut.wait(0.8)


func _guest_at(cell: Vector2i, sheet: CharacterSheet = MIRA_SHEET) -> GuestWalker:
	var guest := GuestWalker.create(sheet)
	map.entities.add_child(guest)
	guest.global_position = map.cell_to_world(cell)
	return guest


## The map's Mira on her seat (an NpcWalker with the cue "mira").
func _seated_mira() -> NpcWalker:
	for node in map.entities.get_children():
		if node is NpcWalker and (node as NpcWalker).cue == "mira":
			return node as NpcWalker
	return null


func _exit_tree() -> void:
	# a scene that is left while he is still coming must not keep saving blocked
	SaveSystem.unblock(ANTREIBER_BLOCK)
