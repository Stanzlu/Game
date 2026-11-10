class_name MiraLeaves
extends Node
## Act VI, R1 (docs/akt6/REGIONSBRIEFE.md, O10): Mira goes her own way. She stands at her old
## camp in the valley (the map's placement "Λ", from the first picture of the day after, while the
## flag `valley.mira_leaving` holds); once the player comes close she says that she goes, never
## where, in the tone of how the quarrel at the gate ended (the cue reads `city.mira_parted_*`), and
## goes: over the bridge, west, until she is out of sight. Then the flag `valley.mira_left` stands
## (the map takes the camp's Mira away and shows the empty place, `camp_empty`).
##
## A phase of the physics step (the pauses count play time). A game closed meanwhile has marked
## nothing (the cutscene blocks saving): she stands at the camp again and the scene plays again.

enum Part { WAIT, SAY, OFF }

const DIALOGUE := "res://content/dialogue/akt6/leere.dialogue"
const CUE := "mira_leaves"
const MIRA_SHEET := preload("res://entities/character/sheet_mira_look.tres")
## This close (in cells) the player stands before she begins; the lines wait for a quiet room.
const SPEAK_CELLS := 3.5
## Her way: from the camp to the bridge and over it (cells), and the speed of the walk.
const WAY: Array[Vector2i] = [
	Vector2i(48, 21), Vector2i(47, 22), Vector2i(39, 22), Vector2i(31, 22)
]
const SPEED := 42.0
const PAUSE_BEFORE := 0.5
const PAUSE_AFTER := 0.6
const BEAT := "act6_mira"
const QUEST := "main_return_way"

var _scene: GameScene
var _cut: Cutscene
var _mira: NpcWalker
var _part := Part.WAIT
var _clock := 0.0
var _busy := false


## True while she stands at the camp: the day after has begun, and she has not gone.
static func due() -> bool:
	return (
		WorldState.has_flag("valley.mira_leaving") and not WorldState.has_flag("valley.mira_left")
	)


static func attach(on: GameScene) -> MiraLeaves:
	var node := MiraLeaves.new()
	node.name = "MiraLeaves"
	node._scene = on
	on.add_child(node)
	return node


func _physics_process(delta: float) -> void:
	if _busy or _part == Part.OFF or _scene.player == null:
		return
	_clock += delta
	match _part:
		Part.WAIT:
			var mira := _find_mira()
			if mira != null and _near(mira) and _quiet():
				_mira = mira
				_cut = Cutscene.begin(_scene)
				_mira.talking = true
				_mira.facing = Facing.from_vector(
					_scene.player.global_position - _mira.global_position
				)
				_part = Part.SAY
				_clock = 0.0
		Part.SAY:
			if _clock >= PAUSE_BEFORE:
				_go()


## The map's Mira at the camp (an NpcWalker with the cue of this scene).
func _find_mira() -> NpcWalker:
	for node in _scene.map.entities.get_children():
		if (
			node is NpcWalker
			and (node as NpcWalker).cue == CUE
			and not node.is_queued_for_deletion()
		):
			return node as NpcWalker
	return null


func _near(mira: NpcWalker) -> bool:
	var reach := SPEAK_CELLS * _scene.map.data.tile_size
	return _scene.player.global_position.distance_to(mira.global_position) <= reach


func _quiet() -> bool:
	return not (
		_scene.dialogue_box.is_open()
		or MenuLayer.any_open(_scene.get_tree())
		or ScreenFade.is_covered()
		or ScreenFade.is_fading()
		or _scene.player.is_locked()
	)


## She speaks, then the flag takes the map's Mira away and the same Mira walks on as a guest, over
## the bridge and out of sight; one block at the end, so the autosave of the mark has it all.
func _go() -> void:
	_busy = true
	await _cut.say(DIALOGUE, CUE)
	var at := _mira.global_position
	var facing := _mira.facing
	WorldState.set_flag("valley.mira_left")
	var guest := GuestWalker.create(MIRA_SHEET)
	_scene.map.entities.add_child(guest)
	guest.global_position = at
	guest.face(facing)
	await _cut.wait(PAUSE_AFTER)
	var points: Array[Vector2] = []
	for cell in WAY:
		points.append(_scene.map.cell_to_world(cell))
	await guest.walk_to(points, SPEED)
	await guest.vanish()
	guest.queue_free()
	_busy = false
	_part = Part.OFF
	if WorldState.quest_stage(QUEST) == "empty":
		WorldState.advance_quest(QUEST, "gone")
	Beat.mark(BEAT)
	_cut.end()
