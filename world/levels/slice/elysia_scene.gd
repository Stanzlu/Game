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
const BUTTERFLY_QUEST := "side_elysia_butterflies"
## Repetition starts once the chest is open and the butterflies are back, whichever comes
## last: the chest lies on the main path, and opening it on the way must not cut the
## miniquest short. Fallbacks (seconds of play) so nobody gets stuck: repetition starts on its
## own (with it the child appears), and the rift opens a while later even if the child was
## never followed.
const LOOPS_AFTER := 720.0
const RIFT_AFTER_LOOPS := 150.0
## The second task solves itself on the way there (ADR-042): the reward escalates, the deed
## shrinks to nothing (Game Bible §8, §10).
const FOUNTAIN_SOLVES_AFTER := 3.0
const FOUNTAIN_XP := 10000
const FOUNTAIN_GOLD := 2500
## The waking (Game Bible §56 style, but in light): the world opens out of white, the hero
## sits for a moment, gets up, and the one who greets turns to them. About 3 s before the first
## line, with the corner of the HUD building up on the way.
const WAKE_LIGHT := Color(1.0, 0.98, 0.92)
const WAKE_LIGHT_HOLD := 0.4
const WAKE_FADE_SECONDS := 2.6
const WAKE_SIT_SECONDS := 1.2
const WAKE_TURN_SECONDS := 0.4
## The cue of the greeter on the map (content/maps/elysia.txt, letters N and n).
const GREETER_CUE := "favor"
## The rift opening on its own is far away: a soft rumble and a little shake, so it is noticed.
const RIFT_OPENS_DB := -6.0

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
	var greeter := _greeter()
	# seated before the cutscene locks the hero, so the lock keeps the pose
	player.sit_on(player.global_position, Facing.Dir.S)
	var cut := Cutscene.begin(self)
	hud.hold_back()
	if greeter != null:
		# looks off into the garden until the hero is up
		greeter.talking = true
		greeter.facing = Facing.Dir.S
	ScreenFade.fade_out(0.0, WAKE_LIGHT)
	# the fade-in clears quickly at first: hold the white a moment so it reads as light
	await cut.wait(WAKE_LIGHT_HOLD)
	ScreenFade.fade_in(WAKE_FADE_SECONDS)
	await cut.wait(WAKE_SIT_SECONDS - WAKE_LIGHT_HOLD)
	player.stand_up()
	_turn_to_each_other(cut, greeter)
	await hud.reveal_elysia()
	await cut.say(DIALOGUE, "wake")
	if is_instance_valid(greeter):
		greeter.talking = false
	cut.end()


## The hero and the greeter look at each other (a moment after the hero got up).
func _turn_to_each_other(cut: Cutscene, greeter: NpcWalker) -> void:
	await cut.wait(WAKE_TURN_SECONDS)
	if greeter == null or not is_instance_valid(greeter) or not is_instance_valid(player):
		return
	player.facing = Facing.from_vector(greeter.global_position - player.global_position)
	greeter.facing = Facing.from_vector(player.global_position - greeter.global_position)


## The one who greets: the walker with the greeter's cue standing nearest to the hero.
func _greeter() -> NpcWalker:
	var nearest: NpcWalker = null
	for node in map.entities.get_children():
		var walker := node as NpcWalker
		if walker == null or walker.cue != GREETER_CUE:
			continue
		if (
			nearest == null
			or (
				walker.global_position.distance_squared_to(player.global_position)
				< nearest.global_position.distance_squared_to(player.global_position)
			)
		):
			nearest = walker
	return nearest


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
		_announce_rift()


## Nobody followed the child: the rift opens in its corner all the same. A rumble, a short shake
## and its caption (whatever the captions setting says), so it is not a silent change on the map.
func _announce_rift() -> void:
	view.shake(1.0, 0.8)
	AudioDirector.sfx("rift_touch", RIFT_OPENS_DB)
	hud.show_caption("CAPTION_RIFT", _rift_position())


## Where the rift stands on the map, or null.
func _rift_position() -> Variant:
	for placement: Dictionary in map.data.placements:
		if str(placement["prop"]).ends_with("rift.tscn"):
			return map.cell_to_world(placement["cell"])
	return null


func _on_quest_changed(quest_id: String, stage: String) -> void:
	if quest_id == "side_elysia_fountain" and stage == "check":
		_fountain_solves_itself()
	elif quest_id == "side_elysia_butterflies" and stage == "done":
		_start_loops_when_ready()


## The hero has had everything Elysia offers (the chest, the miniquest): it starts repeating.
func _start_loops_when_ready() -> void:
	if WorldState.has_flag("elysia.loops"):
		return
	if (
		WorldState.has_flag("elysia.chest_tree_opened")
		and WorldState.is_quest_done("side_elysia_butterflies")
	):
		Beat.mark("irritation")
		WorldState.set_flag("elysia.loops")


## Somebody else fixed it, for you, before you got there.
func _fountain_solves_itself() -> void:
	# the clock starts once the gardener has finished talking: the player sets off, and then
	while dialogue_box != null and dialogue_box.is_open():
		await get_tree().process_frame
	await NodeTimer.after(self, FOUNTAIN_SOLVES_AFTER)
	if not WorldState.is_quest_active("side_elysia_fountain"):
		return
	WorldState.advance_quest("side_elysia_fountain", "done")
	WorldState.add_xp(FOUNTAIN_XP)
	WorldState.add_gold(FOUNTAIN_GOLD)
	Beat.mark("fountain")


func _on_objective_changed(quest_id: String, _objective_id: String) -> void:
	if quest_id != BUTTERFLY_QUEST:
		return
	var caught := 0
	for objective in BUTTERFLY_OBJECTIVES:
		if WorldState.is_objective_done(BUTTERFLY_QUEST, objective):
			caught += 1
	WorldState.add_xp(BUTTERFLY_XP[clampi(caught - 1, 0, BUTTERFLY_XP.size() - 1)])
	if caught == BUTTERFLY_OBJECTIVES.size():
		WorldState.advance_quest(BUTTERFLY_QUEST, "return")
		Beat.mark("butterflies_caught")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"elysia.chest_tree_opened":
			_start_loops_when_ready()
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
