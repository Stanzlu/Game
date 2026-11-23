class_name InnTable
extends Node
## Act VI, R5 (docs/akt6/REGIONSBRIEFE.md, O6): the table in the middle of the inn, for whoever
## came back. Whoever sits on one of its benches is asked once per sitting (cue `stay` of
## gasthaus.dialogue); every answer "stay" brings the next of three offers (food, music, rest) and
## closes the picture in by a step (while she sits, never on a timer); standing up gives the picture
## back in the same moment. Staying stays allowed without end and nothing gets better or worse;
## standing up is her own movement, never an answer in a menu. The pattern is the hut's
## (HuetteScene, ADR-070 O6); sitting is not saved, so a loaded game never begins tight.
##
## R6, the centre of the host's encounter: when she gets up from a bench with all three offers
## behind her (`elysia.stay_3`), he asks once, lightly, and lets her go with the soup (cue
## `stand_first` of aufstehen.dialogue, played once, `elysia.stood_up`); the walk moves on from the
## inn to the standing. Getting up earlier says nothing to anybody, and nothing is ever needed
## for it: the door was open all along, and the quest stage is no gate for the way out (R7).
##
## The first visit also moves the way back on: the hero's quest goes from the garden to the inn.

const DIALOGUE := "res://content/dialogue/akt6/gasthaus.dialogue"
const STAND_DIALOGUE := "res://content/dialogue/akt6/aufstehen.dialogue"
const QUEST := "main_return_way"
const ENTER_BEAT := "act6_inn"
const STAY_BEAT := "inn_stay"
const STAND_BEAT := "inn_stood"
## The picture's zoom after the first, second and third answer to staying (the hall's own is 1.5,
## the hut's steps too).
const STAY_ZOOM: Array[float] = [1.75, 2.0, 2.0]

var _scene: GameScene
var _asked := false
var _sitting := false
var _standing := false


## Puts the table into the inn for someone who has come back, nothing otherwise.
static func attach(on: GameScene) -> InnTable:
	if not WorldState.has_flag("elysia.returned"):
		return null
	var table := InnTable.new()
	table.name = "InnTable"
	table._scene = on
	on.add_child(table)
	return table


func _ready() -> void:
	_scene.player.state_changed.connect(_on_player_state)
	WorldState.flag_changed.connect(_on_flag_changed)
	if WorldState.quest_stage(QUEST) == "elysia":
		WorldState.advance_quest(QUEST, "inn")
	Beat.mark(ENTER_BEAT)


## Sitting down opens the question once per sitting; getting up takes the picture back.
func _on_player_state(state: Player.State) -> void:
	if state == Player.State.SIT:
		_sitting = true
		_ask.call_deferred()
	else:
		_picture(0)
		if _sitting:
			_sitting = false
			_stood_up.call_deferred()


func _ask() -> void:
	if _asked or _scene.player.state != Player.State.SIT:
		return
	_asked = true
	await Talk.present(_scene, DIALOGUE, "stay", _scene.player)
	_asked = false


## She got up from the bench: with all three offers behind her and for the first time, the host
## asks, lets go and hands her the soup. Nothing else about getting up is ever answered.
func _stood_up() -> void:
	if _standing or _scene.player.state == Player.State.SIT:
		return
	if not WorldState.has_flag("elysia.stay_3") or WorldState.has_flag("elysia.stood_up"):
		return
	_standing = true
	await Talk.present(_scene, STAND_DIALOGUE, "stand_first", _scene.player)
	_standing = false


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"elysia.stay_1":
			_picture(1)
		"elysia.stay_2":
			_picture(2)
		"elysia.stay_3":
			_picture(3)
			Beat.mark(STAY_BEAT)
		"elysia.stood_up":
			if WorldState.quest_stage(QUEST) == "inn":
				WorldState.advance_quest(QUEST, "stand")
			Beat.mark(STAND_BEAT)


## The picture after `step` answers (0 gives the hall its own zoom back). It only closes in while
## she sits.
func _picture(step: int) -> void:
	if step > 0 and _scene.player.state != Player.State.SIT:
		return
	_scene.view.zoom_to(_scene.view_zoom if step == 0 else STAY_ZOOM[step - 1])
