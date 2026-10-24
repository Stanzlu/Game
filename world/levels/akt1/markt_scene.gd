class_name MarktScene
extends LookScene
## The market of Elysia (Act I, segment A3, docs/akt1/REGIONSBRIEFE.md): the town behind the garden
## stairs. The hall of mirrors stands shut in the north until A5, seven kinds of people stand twice
## around the fountain, the board hands out one errand that solves itself. Story state lives in
## WorldState flags; this script only stages what they say: the beats and the hero's quest stage.

var director: ElysiaDirector


func _ready() -> void:
	super()
	director = ElysiaDirector.attach(self)
	WorldState.flag_changed.connect(_on_flag_changed)
	WorldState.quest_changed.connect(_on_quest_changed)
	WorldState.set_flag("elysia.market_seen")
	Beat.mark("market_enter")
	_arrive_in_the_quest()


## Setting foot in the town is the stage "market" of the hero's quest, once the chest has been
## opened; opened after the visit, the chest finds the stage for itself (ElysiaScene).
func _arrive_in_the_quest() -> void:
	var stage := WorldState.quest_stage("main_elysia_hero")
	if stage == "celebrated" or stage == "inn":
		WorldState.advance_quest("main_elysia_hero", "market")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"melody.elysia_perfect":
			Beat.mark("market_melody")
		"elysia.hall_open":
			# set by the hall itself (A5): the doors on the map are gone by now
			Beat.mark("market_hall_open")


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
