extends GutTest
## NPC walkers as performers: work at the first waypoint (Mira's net), footsteps on the walk
## cycle's contact frames, and a small bob while they talk.

const WALKER := preload("res://entities/npc/npc_walker.tscn")
const MIRA_SHEET := "res://entities/character/sheet_mira_look.tres"
const PLAIN_SHEET := "res://entities/character/sheet_elysian_look.tres"
const ROUTE := [[0, 0], [12, 0]]

var _saved_mode: GameState.UiMode


## Stands in for the dialogue box: the same group, `present`, `finished`, and (optionally) the
## `syllable` signal that the menus package adds to the real one.
class StubPresenter:
	extends Node
	signal finished
	signal syllable(character: String)

	func present(_resource: DialogueResource, _cue: String, _who: Node) -> void:
		pass


class SilentPresenter:
	extends Node
	signal finished

	func present(_resource: DialogueResource, _cue: String, _who: Node) -> void:
		pass


func before_each() -> void:
	_saved_mode = WorldState.ui_mode()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.set_ui_mode(_saved_mode)


func _walker(sheet: String, params := {}) -> NpcWalker:
	var npc: NpcWalker = WALKER.instantiate()
	add_child_autofree(npc)
	var all := {"sheet": sheet, "route": ROUTE, "pause": [30, 30], "speed": 60}
	all.merge(params, true)
	npc.apply_params(all)
	return npc


func _presenter(node: Node) -> Node:
	node.add_to_group(&"dialogue_presenter")
	add_child_autofree(node)
	return node


func test_a_walker_with_a_work_pose_works_at_the_first_waypoint() -> void:
	var npc := _walker(MIRA_SHEET)
	assert_true(CharacterSheet.has_work(npc.sprite.sprite_frames), "Mira's sheet has the pose")
	await wait_physics_frames(4)
	assert_true(
		String(npc.sprite.animation).begins_with("work_"),
		"lingering at waypoint 0: %s" % npc.sprite.animation
	)
	assert_eq(npc.facing, Facing.Dir.W, "towards the net")
	assert_true(npc.sprite.is_playing(), "the pose moves")


func test_the_work_facing_can_be_set_from_the_map() -> void:
	var npc := _walker(MIRA_SHEET, {"work_face": "s"})
	await wait_physics_frames(4)
	assert_eq(npc.sprite.animation, CharacterSheet.animation_name("work", Facing.Dir.S))


func test_a_walker_without_a_work_pose_only_stands() -> void:
	var npc := _walker(PLAIN_SHEET)
	assert_false(CharacterSheet.has_work(npc.sprite.sprite_frames), "older sheets still load")
	await wait_physics_frames(4)
	assert_true(
		String(npc.sprite.animation).begins_with("idle_"), "idle: %s" % npc.sprite.animation
	)


func test_work_only_happens_at_the_first_waypoint() -> void:
	var npc := _walker(MIRA_SHEET, {"pause": [0.2, 0.2], "speed": 120})
	var worked_at: Array[int] = []
	var seen_other_pause := false
	var resting_before := false
	for i in 140:
		await wait_physics_frames(1)
		var resting := npc._wait > 0.0 and npc._last_point == 1
		if String(npc.sprite.animation).begins_with("work_"):
			worked_at.append(npc._last_point)
		elif resting and resting_before:
			# (the first tick of a pause still shows the last step)
			seen_other_pause = true
			assert_true(
				String(npc.sprite.animation).begins_with("idle_"), "waits at waypoint 1 idle"
			)
		resting_before = resting
	assert_false(worked_at.is_empty(), "it worked")
	for point in worked_at:
		assert_eq(point, 0)
	assert_true(seen_other_pause, "and rested at the other point")


func test_the_walk_cycle_puts_a_foot_down_on_frames_0_and_2_only() -> void:
	var npc := _walker(PLAIN_SHEET, {"pause": [0, 0]})
	var steps := npc.get_node("Steps") as NpcSteps
	assert_not_null(steps, "a walker has footsteps")
	var frames: Array[int] = []
	steps.surface_provider = func(_at: Vector2) -> StringName:
		frames.append(npc.sprite.frame)
		return &"grass"
	# Elysians are silent in Elysia, so this is the real world
	await wait_seconds(1.5)
	assert_gt(frames.size(), 3, "it stepped")
	for frame in frames:
		assert_eq(frame % 2, 0, "contact frames only")
	assert_lt(steps.volume_db, FootstepPlayer.SURFACE_DB[&"grass"].x - 5.0, "under the player's")


func test_a_standing_walker_makes_no_steps() -> void:
	var npc := _walker(PLAIN_SHEET)
	var steps := npc.get_node("Steps") as NpcSteps
	var count := [0]
	steps.surface_provider = func(_at: Vector2) -> StringName:
		count[0] += 1
		return &"grass"
	npc.route.clear()
	await wait_seconds(0.8)
	assert_eq(count[0], 0)


func test_elysians_are_silent_but_the_child_is_not() -> void:
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	var npc := _walker(PLAIN_SHEET)
	assert_false(npc._steps_audible(), "no steps in Elysia")
	var child := ChildGuide.new()
	assert_true(child._steps_audible())
	child.free()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	assert_true(npc._steps_audible(), "steps in the real world")


func test_a_speaker_bobs_with_each_syllable_and_rests_after() -> void:
	var presenter := _presenter(StubPresenter.new())
	var npc := _walker(PLAIN_SHEET, {"cue": "x", "pause": [0, 0]})
	var rest := npc.sheet.feet_offset
	npc._on_talk(null)
	assert_true(npc.talking)
	presenter.syllable.emit("a")
	assert_eq(npc.sprite.offset, rest + Vector2(0, -NpcWalker.TALK_BOB_PIXELS), "up a pixel")
	presenter.syllable.emit("b")
	await wait_seconds(NpcWalker.TALK_BOB_SECONDS + 0.05)
	assert_eq(npc.sprite.offset, rest, "back down")
	presenter.finished.emit()
	assert_false(npc.talking)
	presenter.syllable.emit("c")
	assert_eq(npc.sprite.offset, rest, "no bob once the conversation is over")


func test_the_bob_is_not_faster_than_its_gap() -> void:
	var presenter := _presenter(StubPresenter.new())
	var npc := _walker(PLAIN_SHEET, {"cue": "x"})
	npc._on_talk(null)
	presenter.syllable.emit("a")
	assert_true(npc._bobbing, "a bob starts the gap")
	# a syllable inside the gap changes nothing, however many there are
	for i in 5:
		presenter.syllable.emit("b")
	assert_eq(npc.sprite.offset, npc.sheet.feet_offset + Vector2(0, -NpcWalker.TALK_BOB_PIXELS))
	await wait_seconds(NpcWalker.TALK_BOB_GAP + 0.2)
	assert_false(npc._bobbing, "the gap is over")
	assert_eq(npc.sprite.offset, npc.sheet.feet_offset)
	presenter.syllable.emit("c")
	assert_ne(npc.sprite.offset, npc.sheet.feet_offset, "bobs again after the gap")


func test_a_dialogue_box_without_the_signal_is_fine() -> void:
	var presenter := _presenter(SilentPresenter.new())
	var npc := _walker(PLAIN_SHEET, {"cue": "x"})
	npc._on_talk(null)
	assert_true(npc.talking)
	presenter.finished.emit()
	assert_false(npc.talking)
	assert_eq(npc.sprite.offset, npc.sheet.feet_offset)


func test_the_child_hums_more_often() -> void:
	assert_lte(ChildGuide.HUM_PAUSE.y, 8.0)
	assert_gte(ChildGuide.HUM_PAUSE.x, 4.0)
