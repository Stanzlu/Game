class_name ElysiaReturn
extends Node
## Act VI, R2 (docs/akt6/REGIONSBRIEFE.md, O3, O4): the way back into Elysia, the mirror of the
## RiftSequence. In the valley a gap of light stands where she arrived in the rain; touching it
## shows it (`gap_look`), asks whether she wants to go through (`ConfirmMenu`, the safe answer is
## to stay: nothing pulls), and then: a step, the light grows (`gap_enter`), black, and Elysia.
## Nothing is carried over but the state: the interface is Elysia's again (`ui_mode`), the level and
## the experience stand where she left them (they are in the save), and what she lost at the first
## crossing is not given back (Plan 5.1). Elysia herself builds the corner of the picture up again
## on arrival (`ElysiaScene`, the same build-up as at the waking), and the music runs up with it.
##
## Respects the reduced flashing and the screen shake as every sequence of the game does (it uses no
## freeze frames and no shake of its own). Leaving the scene in the middle (loading a save) never
## keeps saving blocked.

signal finished

const DIALOGUE := "res://content/dialogue/akt6/spalt.dialogue"
const QUESTION := "RETURN_GAP_ASK"
const YES := "RETURN_GAP_YES"
const NO := "RETURN_GAP_NO"
const FADE_OUT := 1.4
const LAST_LINE_GOES := 0.2
const DARK_PAUSE := 0.6
## Elysia comes up slowly out of the dark, like the Real world at the first crossing.
const ARRIVAL_FADE := 3.0

var scene: GameScene
var rift: Rift
var actor: Node
## Tests shorten the pauses and stay in the scene.
var time_scale := 1.0
var travel := true
## The lock and save-block reason of this sequence alone.
var key := &""
var _running := false
var _asking := false


## Begins at the gap `from_rift`: the look, the question, the crossing. One at a time.
static func start(from_rift: Rift, who: Node) -> ElysiaReturn:
	var on_scene := (
		from_rift.get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene
	)
	if on_scene == null:
		Log.error(Log.Category.WORLD_STATE, "gap outside a game scene")
		return null
	if on_scene.get_node_or_null("ElysiaReturn") != null:
		return null
	var sequence := ElysiaReturn.new()
	sequence.name = "ElysiaReturn"
	sequence.scene = on_scene
	sequence.rift = from_rift
	sequence.actor = who
	on_scene.add_child(sequence)
	sequence.run.call_deferred()
	return sequence


func run() -> void:
	_running = true
	key = StringName("return_%d" % get_instance_id())
	# no group "cutscene" of its own: the cutscenes of the look and of the step, the question and the
	# fade cover every phase, and a conversation may be paused (MenuLayer.can_pause)
	var look := Cutscene.begin(scene)
	await look.say(DIALOGUE, "gap_look")
	# the box fades out in 0.1 s of a tree that is about to stand still for the question
	await look.wait(LAST_LINE_GOES)
	look.end()
	if not await _wants_to_go():
		# nothing happened: the gap is there to be touched again
		_running = false
		rift.reopen()
		queue_free()
		return
	scene.player.lock(key)
	SaveSystem.block(key)
	rift.touch(actor)
	var enter := Cutscene.begin(scene)
	await enter.say(DIALOGUE, "gap_enter")
	enter.end()
	ScreenFade.fade_out(FADE_OUT * time_scale)
	await _wait(FADE_OUT)
	await _wait(DARK_PAUSE)
	_cross_back()
	_running = false
	# the state has crossed, the scene has not: a save waiting from the sequence would write
	# Elysia's interface on the valley's map
	SaveSystem.discard_pending_autosave()
	SaveSystem.unblock(key)
	if travel:
		SceneTravel.pending_spawn = rift.spawn
		SceneTravel.arrival_fade = ARRIVAL_FADE
		var error := get_tree().change_scene_to_file(SceneRegistry.path(rift.target))
		if error != OK:
			_stay_after_all(error)
	finished.emit()


## The scene could not be changed: she stays in the valley, free, with the interface of the valley.
func _stay_after_all(error: int) -> void:
	Log.error(Log.Category.CONTENT, "return failed", {"target": rift.target, "error": error})
	WorldState.clear_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	scene.player.unlock(key)
	ScreenFade.fade_in(0.5)
	rift.reopen()


## The question over the game: yes is going through, no (and back) is staying. The tree stands
## still while it is open, as for every menu a prop opens (the shelf).
func _wants_to_go() -> bool:
	var tree := get_tree()
	var menu := ConfirmMenu.new()
	menu.name = "ConfirmReturn"
	scene.add_child(menu)
	tree.paused = true
	_asking = true
	menu.ask(QUESTION, YES, NO)
	var yes: bool = await menu.answered
	_asking = false
	tree.paused = false
	menu.queue_free()
	Log.info(Log.Category.WORLD_STATE, "gap asked", {"yes": yes})
	return yes


func _cross_back() -> void:
	WorldState.set_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func _wait(seconds: float) -> Signal:
	return NodeTimer.after(self, seconds * time_scale)


func _exit_tree() -> void:
	# Leaving mid-sequence (e.g. loading a save): never keep saving blocked or the game paused.
	if _asking and get_tree() != null:
		get_tree().paused = false
	_asking = false
	if _running:
		SaveSystem.unblock(key)
		_running = false
