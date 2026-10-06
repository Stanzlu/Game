class_name ElysiaScene
extends LookScene
## Elysia in the vertical slice (beats 1 and 2, docs/PHASE4_PLAN.md): waking up and being
## greeted, the butterfly miniquest with escalating rewards, the chest; then repetition,
## the reflection that is missing, the stone, the child and the hidden rift.
## Story state lives in WorldState flags; this script only reacts to them.

const DIALOGUE := "res://content/dialogue/slice/elysia.dialogue"
## XP for the first, second and third butterfly (Game Bible §10: rewards escalate).
const BUTTERFLY_XP: Array[int] = [100, 500, 2000]
const BUTTERFLY_OBJECTIVES: PackedStringArray = ["first", "second", "third"]
## Fallbacks (seconds of play) so nobody gets stuck: repetition starts on its own (with it
## the child appears), and the rift opens a while later even if the child was never followed.
const LOOPS_AFTER := 720.0
const RIFT_AFTER_LOOPS := 240.0
## The second task solves itself on the way there (ADR-042): the reward escalates, the deed
## shrinks to nothing (Game Bible §8, §10).
const FOUNTAIN_SOLVES_AFTER := 6.0
const FOUNTAIN_XP := 10000
const FOUNTAIN_GOLD := 2500

var _loops_time := -1.0


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	WorldState.objective_changed.connect(_on_objective_changed)
	WorldState.quest_changed.connect(_on_quest_changed)
	if not WorldState.has_flag("elysia.woke"):
		_wake.call_deferred()
	elif WorldState.has_flag("elysia.loops"):
		_loops_time = WorldState.state.playtime_seconds
	if WorldState.is_quest_active("side_elysia_fountain"):
		# loaded while the fountain was about to fix itself
		_fountain_solves_itself()


func _wake() -> void:
	Beat.mark("elysia_start")
	if not WorldState.has_item("item_seed"):
		# the seed was there before the first memory of Elysia (Game Bible §30)
		WorldState.add_item("item_seed", 1, false)
	var cut := Cutscene.begin(self)
	await cut.wait(1.4)
	await cut.say(DIALOGUE, "wake")
	cut.end()


func _process(_delta: float) -> void:
	var t := WorldState.state.playtime_seconds
	if not WorldState.has_flag("elysia.loops") and t > LOOPS_AFTER:
		WorldState.set_flag("elysia.loops")
	# the loop start is not saved: after a load the wait starts again, but never past the
	# latest possible start of the loops
	if (
		_loops_time >= 0.0
		and not WorldState.has_flag("elysia.rift_open")
		and (t - _loops_time > RIFT_AFTER_LOOPS or t > LOOPS_AFTER + RIFT_AFTER_LOOPS)
	):
		Log.info(Log.Category.WORLD_STATE, "rift opens without the child")
		WorldState.set_flag("elysia.rift_open")


func _on_quest_changed(quest_id: String, stage: String) -> void:
	if quest_id == "side_elysia_fountain" and stage == "check":
		_fountain_solves_itself()


## Somebody else fixed it, for you, before you got there.
func _fountain_solves_itself() -> void:
	# the clock starts once the gardener has finished talking: the player sets off, and then
	while dialogue_box != null and dialogue_box.visible:
		await get_tree().process_frame
	await NodeTimer.after(self, FOUNTAIN_SOLVES_AFTER)
	if not WorldState.is_quest_active("side_elysia_fountain"):
		return
	WorldState.advance_quest("side_elysia_fountain", "done")
	WorldState.add_xp(FOUNTAIN_XP)
	WorldState.add_gold(FOUNTAIN_GOLD)
	Beat.mark("fountain")


func _on_objective_changed(quest_id: String, _objective_id: String) -> void:
	if quest_id != "side_elysia_butterflies":
		return
	var caught := 0
	for objective in BUTTERFLY_OBJECTIVES:
		if WorldState.is_objective_done(quest_id, objective):
			caught += 1
	WorldState.add_xp(BUTTERFLY_XP[clampi(caught - 1, 0, BUTTERFLY_XP.size() - 1)])
	if caught == BUTTERFLY_OBJECTIVES.size():
		WorldState.advance_quest(quest_id, "return")
		Beat.mark("butterflies_caught")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"elysia.chest_tree_opened":
			Beat.mark("irritation")
			WorldState.set_flag("elysia.loops")
		"elysia.loops":
			_loops_time = WorldState.state.playtime_seconds
		"elysia.mirror_seen":
			Beat.mark("mirror")
		"elysia.stone_taken":
			Beat.mark("stone")
		"elysia.child_met":
			Beat.mark("child")
		"elysia.child_vanished":
			_child_vanishes()
		"elysia.rift_open":
			Beat.mark("rift_found")


## The child fades out by itself (its map placement ends with elysia.child_vanished).
func _child_vanishes() -> void:
	await NodeTimer.after(self, 1.2)
	WorldState.set_flag("elysia.rift_open")
