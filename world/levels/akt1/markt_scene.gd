class_name MarktScene
extends LookScene
## The market of Elysia (Act I, segments A3 and A6, docs/akt1/REGIONSBRIEFE.md): the town behind
## the garden stairs. The hall of mirrors stands in the north, its doors open when pushed; seven
## kinds of people stand twice around the fountain; the board hands out one errand that solves
## itself; and once the hall was noticed the town stands in its feast state. Story state lives in
## WorldState flags; this script only stages what they say: the beats and the hero's quest stage.

var director: ElysiaDirector


func _ready() -> void:
	# the town is in its feast state from the moment the hall was noticed, before the map is built
	if WorldState.has_flag("elysia.hall_mirror_seen"):
		WorldState.set_flag("elysia.feast")
	super()
	director = ElysiaDirector.attach(self)
	WorldState.flag_changed.connect(_on_flag_changed)
	WorldState.quest_changed.connect(_on_quest_changed)
	WorldState.set_flag("elysia.market_seen")
	Beat.mark("market_enter")
	if WorldState.has_flag("elysia.feast"):
		_feast_begins()
	_arrive_in_the_quest()


## Setting foot in the town is the stage "market" of the hero's quest, once the chest has been
## opened; opened after the visit, the chest finds the stage for itself (ElysiaScene).
func _arrive_in_the_quest() -> void:
	var stage := WorldState.quest_stage("main_elysia_hero")
	if stage == "celebrated" or stage == "inn":
		WorldState.advance_quest("main_elysia_hero", "market")
	elif stage == "feast" and WorldState.has_flag("elysia.feast_toast"):
		# a save from the feast (A6): the glass was raised, the repetition is on
		WorldState.advance_quest("main_elysia_hero", "repeat")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"melody.elysia_perfect":
			Beat.mark("market_melody")
		"fragment.hallway":
			Beat.mark("trail_hallway")
		"elysia.hall_open":
			# pushed open at the doors (A5): the front shows the open doors by now
			Beat.mark("market_hall_open")
		"elysia.feast":
			_feast_begins()
		"elysia.feast_toast":
			Beat.mark("feast")
			WorldState.advance_quest("main_elysia_hero", "feast")
			# the director starts the sentences at the same toast (ElysiaDirector, ADR-062)
			WorldState.advance_quest("main_elysia_hero", "repeat")


## The market stands in its feast state (the props of the feast follow the flag by themselves).
func _feast_begins() -> void:
	Beat.mark("feast_enter")


## The errand on the board: taken, the loaf in the hands, delivered.
func _on_quest_changed(quest_id: String, stage: String) -> void:
	if quest_id != "side_elysia_board":
		return
	match stage:
		"bread":
			Beat.mark("market_board")
		"deliver":
			Beat.mark("market_bread")
		"done":
			Beat.mark("market_board_done")
