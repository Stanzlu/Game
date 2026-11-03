class_name StadtScene
extends LookScene
## Act IV, S2: the city (docs/akt4/REGIONSBRIEFE.md). Elysia's market with a contradiction: a
## gate whose keeper has a bad day, a square with a fountain (Mira sits at its rim), the board with
## the Gefällige's slips, the town hall, two shops with their doors, Lio playing in a corner,
## three stations of a perfect day that did not go to plan and a goat on a roof. The map and the
## dialogue tell all of it; this script only goes on with the hero's walk to the town, plays Lio's
## tune once he has played it and marks the beats. Since S4 it also keeps "Nichts" (Bible §44): once
## the board is sawn, Tess sits on her crate before the workshop, and whoever sits down on the bench
## beside her sits with her. The quest starts with the sitting and ends when she gets up: no beat,
## no praise, no counter. No cutscene, no lock, nothing here is needed.
## Since S6 the square has an evening (docs/akt4/REGIONSBRIEFE.md, O3, O10): once Lio has
## invited her ("Ich komme.", the quest stage "evening") the scene is loaded again as the
## evening of the concert, with the night look as exports of this scene (never the time of day
## of the world, that is global state), the people and things that stand only then (the map
## reads `city.evening`) and the concert, a cutscene (`Concert`). The shops and the town hall
## are shut then; the day comes back with the way home (S8).

const WERKSTATT := "res://content/dialogue/akt4/werkstatt.dialogue"
## The bench before the workshop (the player sits on it, Tess on the crate two cells east of it) and
## how close she has to be for the sitting to count as sitting with Tess.
const BENCH_CELL := Vector2i(25, 41)
const BENCH_REACH := 40.0
## The stages of the hero's way in which it is evening in the town.
const EVENING_STAGES: PackedStringArray = ["evening"]
const EVENING_AMBIENCE := "res://content/audio/tal_abend.tres"

var _asked := false
var _with_tess := false
## Lio has been said yes to: the scene goes over into the evening as soon as the talk is over.
var _invited := false
var _concert: Concert


## True while the story is in the evening of the town (on loading, `city.evening` follows it).
static func in_evening() -> bool:
	return WorldState.quest_stage("main_city_way") in EVENING_STAGES


func _ready() -> void:
	var evening := in_evening()
	if evening:
		_evening_look()
	# before the map is built: its placements read the flag
	WorldState.set_flag("city.evening", evening)
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	player.state_changed.connect(_on_player_state)
	# saving is allowed while she sits: a game loaded from then stands again, so "Nichts" is over
	if WorldState.quest_stage("side_city_nothing") == "sit":
		WorldState.set_flag("city.sat_with_tess")
		WorldState.advance_quest("side_city_nothing", "done")
	# the road ends here: the walk of the hero goes on from the road to the town
	if WorldState.quest_stage("main_city_way") == "west":
		WorldState.advance_quest("main_city_way", "town")
	Beat.mark("stadt_enter")
	if evening:
		Beat.mark("stadt_abend")
		if not Beat.reached(Concert.BEAT):
			_concert = Concert.attach(self)


func _physics_process(_delta: float) -> void:
	# the talk with Lio is over: the day goes (the scene is loaded again as the evening)
	if _invited and quiet():
		_invited = false
		SceneTravel.go(self, "stadt", "abend")


## Nothing is open: no line, no menu, no black. The evening starts and the day goes only then.
func quiet() -> bool:
	return not (
		dialogue_box.is_open()
		or MenuLayer.any_open(get_tree())
		or ScreenFade.is_covered()
		or ScreenFade.is_fading()
	)


## The look of the evening: warm lamps in a blue dusk (O3). Exports of this scene, set before it is
## built, and no time of day of the world: that would be left behind in the valley.
func _evening_look() -> void:
	day_preset = "keine"
	world_tint = Color(0.5, 0.55, 0.76)
	cloud_shadows = 0.0
	saturation = 0.92
	contrast = 1.06
	tint = Color(0.98, 0.98, 1.05)
	shadow_tint = Color(0.03, 0.03, 0.08)
	vignette = 0.34
	bloom = 0.9
	music = "silence"
	ambience = load(EVENING_AMBIENCE)
	ambience_db = -9.0


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "melody.lio_street":
		AudioDirector.sfx("lio_street", -2.0, 1.0)
		Beat.mark("stadt_lio")
	elif value and id == "city.concert_invited" and not WorldState.has_flag("city.evening"):
		_invited = true


## Sitting down on the bench beside Tess opens "Nichts" once per sitting; getting up ends it.
func _on_player_state(state: Player.State) -> void:
	if state == Player.State.SIT:
		_sat.call_deferred()
	elif _with_tess:
		_with_tess = false
		WorldState.set_flag("city.sat_with_tess")
		if WorldState.quest_stage("side_city_nothing") == "sit":
			WorldState.advance_quest("side_city_nothing", "done")


func _sat() -> void:
	if _asked or player.state != Player.State.SIT or not _beside_tess():
		return
	_asked = true
	_with_tess = true
	WorldState.start_quest("side_city_nothing")
	await Talk.present(self, WERKSTATT, "nothing", player)
	_asked = false


## True once the board is sawn (she is outside then) and the player sits on the workshop's bench.
func _beside_tess() -> bool:
	if not WorldState.has_flag("city.board_done") or WorldState.has_flag("city.evening"):
		return false
	var seat := map.cell_to_world(BENCH_CELL)
	return player.global_position.distance_to(seat) <= BENCH_REACH
