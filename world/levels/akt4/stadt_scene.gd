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

const WERKSTATT := "res://content/dialogue/akt4/werkstatt.dialogue"
## The bench before the workshop (the player sits on it, Tess on the crate two cells east of it) and
## how close she has to be for the sitting to count as sitting with Tess.
const BENCH_CELL := Vector2i(25, 41)
const BENCH_REACH := 40.0

var _asked := false
var _with_tess := false


func _ready() -> void:
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


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "melody.lio_street":
		AudioDirector.sfx("lio_street", -2.0, 1.0)
		Beat.mark("stadt_lio")


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
	if not WorldState.has_flag("city.board_done"):
		return false
	var seat := map.cell_to_world(BENCH_CELL)
	return player.global_position.distance_to(seat) <= BENCH_REACH
