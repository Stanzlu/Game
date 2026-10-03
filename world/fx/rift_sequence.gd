class_name RiftSequence
extends Node
## The first crossing out of Elysia (Game Bible §11, slice 18–25 min): the world stutters,
## Elysia's HUD falls apart piece by piece, the music runs down like a tape, silence, dark;
## then the Real world with rain. Afterwards the UI is in REAL mode and the inventory holds
## only the stone and a seed. Respects screen shake and reduced flashing.

signal finished

const PAUSE_BETWEEN_ELEMENTS := 0.8
const KEEP: PackedStringArray = ["item_stone", "item_seed"]

var scene: GameScene
var target := ""
## Tests shorten the pauses and stay in the scene.
var time_scale := 1.0
var travel := true
var _running := false


static func play(on_scene: GameScene, target_scene: String, autostart := true) -> RiftSequence:
	var sequence := RiftSequence.new()
	sequence.name = "RiftSequence"
	sequence.scene = on_scene
	sequence.target = target_scene
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
	add_to_group(&"cutscene")
	var calm := Settings.get_bool("display.reduce_flashing")
	scene.player.lock(&"cutscene")
	SaveSystem.block(&"cutscene")
	scene.view.shake(2.0, 1.4)
	AudioDirector.tape_stop(3.4 * time_scale)
	while scene.hud.vanish_next(calm):
		await _wait(PAUSE_BETWEEN_ELEMENTS)
	AudioDirector.set_ambience(null, -6.0, 1.6 * time_scale)
	await _wait(1.8)
	await ScreenFade.fade_out(1.6 * time_scale)
	await _wait(1.4)
	_cross_over()
	_running = false
	SaveSystem.unblock(&"cutscene")
	if travel:
		get_tree().change_scene_to_file(SceneRegistry.path(target))
	finished.emit()


func _cross_over() -> void:
	WorldState.set_flag("elysia.rift_crossed")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.reduce_inventory_to(KEEP)
	for item in KEEP:
		if not WorldState.has_item(item):
			WorldState.add_item(item)


func _wait(seconds: float) -> Signal:
	return NodeTimer.after(self, seconds * time_scale)


## While running, menus and the journal stay closed (MenuLayer.any_open).
func is_open() -> bool:
	return _running


func _exit_tree() -> void:
	# Leaving mid-sequence (e.g. loading a save): never keep saving blocked.
	if _running:
		SaveSystem.unblock(&"cutscene")
		_running = false
