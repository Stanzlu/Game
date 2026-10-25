class_name RiftSequence
extends Node
## The first crossing out of Elysia (Game Bible §11, slice 18–25 min): the world stutters
## (the picture of the world freezes for a moment, again and again, while the HUD goes on),
## Elysia's HUD falls apart piece by piece, the music runs down like a tape, silence, dark;
## then the Real world with rain. Afterwards the UI is in REAL mode and the inventory holds
## only the stone and a seed. Respects screen shake and reduced flashing (no freezes then).
## Elysia itself does not decay: its world stays as it is (Game Bible §8, §9).

signal finished

const PAUSE_BETWEEN_ELEMENTS := 0.8
## How long the world's picture holds still at each stutter.
const STUTTER_SECONDS := 0.12
## Black between the fade-out and the new scene: long enough to be a breath, no longer.
const DARK_PAUSE := 0.6
const KEEP: PackedStringArray = ["item_stone", "item_seed"]
## The Real world comes up slowly out of the dark, rain first.
const ARRIVAL_FADE := 3.5

var scene: GameScene
var target := ""
## Spawn marker in the target ("" = its player_spawn), see SceneTravel.
var spawn := ""
## Tests shorten the pauses and stay in the scene.
var time_scale := 1.0
var travel := true
## The lock and save-block reason of this sequence alone.
var key := &""
var _running := false
var _frozen_mode := SubViewport.UPDATE_WHEN_VISIBLE
var _frozen := false


static func play(
	on_scene: GameScene, target_scene: String, autostart := true, spawn_marker := ""
) -> RiftSequence:
	var sequence := RiftSequence.new()
	sequence.name = "RiftSequence"
	sequence.scene = on_scene
	sequence.target = target_scene
	sequence.spawn = spawn_marker
	on_scene.add_child(sequence)
	if autostart:
		sequence.run.call_deferred()
	return sequence


func run() -> void:
	if not SceneRegistry.has(target):
		Log.error(Log.Category.CONTENT, "rift target unknown", {"target": target})
		queue_free()
		return
	Log.info(Log.Category.WORLD_STATE, "rift sequence start", {"target": target})
	_running = true
	key = StringName("rift_%d" % get_instance_id())
	add_to_group(&"cutscene")
	var calm := Settings.get_bool("display.reduce_flashing")
	scene.player.lock(key)
	SaveSystem.block(key)
	scene.view.shake(2.0, 1.4)
	AudioDirector.tape_stop(3.4 * time_scale)
	while scene.hud.vanish_next(calm):
		if not calm:
			_stutter()
		await _wait(PAUSE_BETWEEN_ELEMENTS)
	AudioDirector.set_ambience(null, -6.0, 1.6 * time_scale)
	await _wait(1.8)
	ScreenFade.fade_out(1.6 * time_scale)
	await _wait(1.6)
	await _wait(DARK_PAUSE)
	_cross_over()
	_running = false
	# the state has crossed over, the scene has not: a save waiting from the sequence would
	# write the Real state on Elysia's map; the valley saves on arrival anyway
	SaveSystem.discard_pending_autosave()
	SaveSystem.unblock(key)
	if travel:
		SceneTravel.pending_spawn = spawn
		SceneTravel.arrival_fade = ARRIVAL_FADE
		get_tree().change_scene_to_file(SceneRegistry.path(target))
	finished.emit()


func _cross_over() -> void:
	WorldState.set_flag("elysia.rift_crossed")
	# Act I is over for good: the chapter mark that the slots and the return in Act VI will read
	Chapter.mark("act1")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.reduce_inventory_to(KEEP)
	for item in KEEP:
		if not WorldState.has_item(item):
			# the stone was never taken (the beat was missed): it is in the pocket anyway
			Log.info(Log.Category.WORLD_STATE, "item handed over at the rift", {"item": item})
			WorldState.add_item(item, 1, false)


## The picture of the world holds still for a moment (the world itself runs on, the HUD too).
## Freezing the world viewport keeps its last image on the display.
func _stutter() -> void:
	if _frozen or scene.view == null:
		return
	var viewport := scene.view.viewport
	_frozen_mode = viewport.render_target_update_mode
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_frozen = true
	await _wait(STUTTER_SECONDS)
	_thaw()


func _thaw() -> void:
	if not _frozen:
		return
	_frozen = false
	if is_instance_valid(scene) and scene.view != null:
		scene.view.viewport.render_target_update_mode = _frozen_mode


func _wait(seconds: float) -> Signal:
	return NodeTimer.after(self, seconds * time_scale)


## While running, menus and the journal stay closed (MenuLayer.any_open).
func is_open() -> bool:
	return _running


func _exit_tree() -> void:
	_thaw()
	# Leaving mid-sequence (e.g. loading a save): never keep saving blocked.
	if _running:
		SaveSystem.unblock(key)
		_running = false
