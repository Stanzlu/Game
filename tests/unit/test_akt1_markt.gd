extends GutTest
## Act I, segment A3: the market of Elysia. Seven kinds of people stand twice around the fountain,
## the board hands out one errand that solves itself, the merchant sells for gold, the musician
## gives a melody, the hall of mirrors stays shut until A5, and the hero's quest finds its stage
## "market" from either side.

const MARKT := preload("res://world/levels/akt1/markt.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const DIALOGUE := "res://content/dialogue/akt1/markt.dialogue"
const TWINS: PackedStringArray = [
	"gatekeeper", "baker", "merchant", "florist", "tailor", "poet", "musician"
]
## Column of the mirror axis (content/maps/markt.txt, symmetry = 30), in pixels at the cell centre.
const AXIS_X := 30.0 * 16.0 + 8.0


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _market() -> MarktScene:
	var scene: MarktScene = MARKT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _props_with_cue(scene: GameScene, cue: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.get(&"cue") == cue or (node.has_meta(&"cue") and node.get_meta(&"cue") == cue):
			found.append(node)
	return found


# --- The place -------------------------------------------------------------------------


func test_seven_kinds_of_people_stand_twice_and_mirrored() -> void:
	var scene := await _market()
	for cue in TWINS:
		var people := _props_with_cue(scene, cue)
		assert_eq(people.size(), 2, "%s stands once on each side" % cue)
		if people.size() == 2:
			var sum: float = (
				(people[0] as Node2D).global_position.x + (people[1] as Node2D).global_position.x
			)
			assert_almost_eq(sum, 2.0 * AXIS_X, 0.5, "%s: the twins mirror each other" % cue)
			assert_almost_eq(
				(people[0] as Node2D).global_position.y,
				(people[1] as Node2D).global_position.y,
				0.5,
				"%s: in the same row" % cue
			)
	for cue: String in ["board", "fountain", "hall_door"]:
		assert_eq(_props_with_cue(scene, cue).size(), 1, "%s stands on the axis" % cue)
	assert_true(Beat.reached("market_enter"))
	assert_true(WorldState.has_flag("elysia.market_seen"))


func test_the_garden_stairs_and_the_gate_belong_together() -> void:
	var garden: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(garden)
	await wait_physics_frames(3)
	assert_false(garden.map.data.find_marker("spawn_markt").is_empty(), "the stairs give out here")
	var market := await _market()
	assert_false(market.map.data.find_marker("spawn_garden").is_empty(), "and the gate gives in")
	var doors := 0
	for node in market.map.entities.get_children():
		if node.get(&"target") == "elysia":
			doors += 1
	assert_eq(doors, 1, "one way back, up the stairs")


func test_the_hall_of_mirrors_is_shut_until_somebody_pushes() -> void:
	var scene := await _market()
	assert_eq(_props_with_cue(scene, "hall_door").size(), 1)
	assert_eq(_doors_to(scene, "spiegelhalle"), 0, "no way in while the doors are shut")
	var seen := await DialogueWalk.play(DIALOGUE, "hall_door", ["drücken"])
	assert_true(LineText.of("mk_hall_3") in seen, "they were never locked")
	assert_true(WorldState.has_flag("elysia.hall_open"))
	await wait_physics_frames(3)
	assert_eq(_doors_to(scene, "spiegelhalle"), 1, "the way in stands open")
	assert_eq(_props_with_cue(scene, "hall_door").size(), 1, "the front is still there, and open")
	assert_true(Beat.reached("market_hall_open"))


func test_waiting_for_tomorrow_opens_nothing() -> void:
	var answers := await DialogueWalk.answers(DIALOGUE, "hall_door")
	assert_eq(answers.size(), 2, "push or wait")
	var seen := await DialogueWalk.play(DIALOGUE, "hall_door", ["wiederkommen"])
	assert_true(LineText.of("mk_hall_1") in seen, "the sign says tomorrow")
	assert_true(LineText.of("mk_hall_4") in seen)
	assert_false(WorldState.has_flag("elysia.hall_open"))


func test_the_poet_has_one_more_thing_to_say_to_the_perceptive() -> void:
	var plain := await DialogueWalk.answers(DIALOGUE, "poet")
	assert_eq(plain.size(), 3)
	WorldState.set_facet("perception")
	var answers := await DialogueWalk.answers(DIALOGUE, "poet")
	assert_eq(answers.size(), 4, "he notices that it is yesterday's poem")
	var seen := await DialogueWalk.play(DIALOGUE, "poet", ["gestern auch gesagt"])
	assert_true(LineText.of("mk_poet_7") in seen)


func _doors_to(scene: GameScene, target: String) -> int:
	var count := 0
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion() and node.get(&"target") == target:
			count += 1
	return count


# --- The gatekeeper ----------------------------------------------------------------------


func test_the_gatekeeper_welcomes_once_and_then_only_nods() -> void:
	var xp: int = WorldState.state.elysia.xp
	var first := await DialogueWalk.play(DIALOGUE, "gatekeeper")
	assert_true(LineText.of("mk_gate_1") in first)
	assert_true(LineText.of("mk_gate_3") in first, "the hall opens tomorrow")
	assert_true(WorldState.has_flag("elysia.market_greeted"))
	assert_eq(WorldState.state.elysia.xp, xp + 150)
	var again := await DialogueWalk.play(DIALOGUE, "gatekeeper")
	assert_false(LineText.of("mk_gate_1") in again)
	assert_eq(again.size(), 1, "one short line")
	assert_eq(WorldState.state.elysia.xp, xp + 150, "nothing more to earn")


# --- The board: an errand that solves itself ---------------------------------------------


func test_the_board_offers_the_errand_and_may_be_left_alone() -> void:
	var answers := await DialogueWalk.answers(DIALOGUE, "board")
	assert_eq(answers.size(), 2, "take it or later")
	await DialogueWalk.play(DIALOGUE, "board", ["Später"])
	assert_false(WorldState.is_quest_started("side_elysia_board"))
	var seen := await DialogueWalk.play(DIALOGUE, "board", ["annehmen"])
	assert_true(LineText.of("mk_board_6") in seen)
	assert_eq(WorldState.quest_stage("side_elysia_board"), "bread")
	var short := await DialogueWalk.play(DIALOGUE, "board")
	assert_eq(short, PackedStringArray([LineText.of("mk_board_7")]), "the notice hangs on")


func test_bread_from_the_baker_to_the_tailor_pays_for_nothing() -> void:
	WorldState.start_quest("side_elysia_board")
	var waiting := await DialogueWalk.play(DIALOGUE, "tailor")
	assert_true(LineText.of("mk_tailor_1") in waiting, "she waits for the bread")
	await DialogueWalk.play(DIALOGUE, "baker")
	assert_true(WorldState.has_item("item_loaf"))
	assert_eq(WorldState.quest_stage("side_elysia_board"), "deliver")
	var xp: int = WorldState.state.elysia.xp
	var gold: int = WorldState.state.elysia.gold
	var seen := await DialogueWalk.play(DIALOGUE, "tailor")
	assert_true(LineText.of("mk_tailor_5") in seen, "she had the bread yesterday already")
	assert_false(WorldState.has_item("item_loaf"))
	assert_true(WorldState.is_quest_done("side_elysia_board"))
	assert_eq(WorldState.state.elysia.xp, xp + 3000)
	assert_eq(WorldState.state.elysia.gold, gold + 800)


func test_the_baker_gives_the_loaf_only_to_the_errand() -> void:
	var seen := await DialogueWalk.play(DIALOGUE, "baker")
	assert_false(WorldState.has_item("item_loaf"))
	assert_eq(seen.size(), 1, "one line of the baker's day")


func test_the_finished_board_has_the_same_notices_again() -> void:
	WorldState.start_quest("side_elysia_board")
	WorldState.advance_quest("side_elysia_board", "deliver")
	WorldState.advance_quest("side_elysia_board", "done")
	var seen := await DialogueWalk.play(DIALOGUE, "board")
	assert_eq(seen, PackedStringArray([LineText.of("mk_board_8")]))


# --- The merchant: gold for what changes nothing -----------------------------------------


func test_spending_gold_never_pays_out_more_than_there_is() -> void:
	WorldState.add_gold(100)
	assert_eq(WorldState.gold(), 100)
	assert_false(WorldState.spend_gold(101), "not enough")
	assert_false(WorldState.spend_gold(0))
	assert_false(WorldState.spend_gold(-5))
	assert_eq(WorldState.gold(), 100)
	assert_true(WorldState.spend_gold(100))
	assert_eq(WorldState.gold(), 0)


func test_the_merchant_sells_what_the_hero_can_pay() -> void:
	var broke := await DialogueWalk.answers(DIALOGUE, "merchant")
	assert_eq(broke.size(), 1, "with empty pockets only looking is left")
	WorldState.add_gold(200)
	var answers := await DialogueWalk.answers(DIALOGUE, "merchant")
	assert_eq(answers.size(), 3, "a compliment, the lucky charm, looking")
	await DialogueWalk.play(DIALOGUE, "merchant", ["Glücksbringer"])
	assert_true(WorldState.has_item("item_trinket"))
	assert_eq(WorldState.gold(), 50)
	var after := await DialogueWalk.answers(DIALOGUE, "merchant")
	assert_eq(after.size(), 2, "the charm is sold once, the compliment is left")
	await DialogueWalk.play(DIALOGUE, "merchant", ["Kompliment"])
	assert_true(WorldState.has_item("item_compliment"))
	assert_eq(WorldState.gold(), 40)


func test_a_coin_in_the_fountain_costs_ten_gold_and_asks_for_nothing() -> void:
	var poor := await DialogueWalk.answers(DIALOGUE, "fountain")
	assert_eq(poor.size(), 1, "without gold the fountain only splashes")
	WorldState.add_gold(25)
	var seen := await DialogueWalk.play(DIALOGUE, "fountain", ["Münze"])
	assert_true(LineText.of("mk_fountain_2") in seen)
	assert_eq(WorldState.gold(), 15)


# --- The melody --------------------------------------------------------------------------


func test_the_musician_gives_the_perfect_melody_once() -> void:
	await _market()
	var xp: int = WorldState.state.elysia.xp
	var answers := await DialogueWalk.answers(DIALOGUE, "musician")
	assert_eq(answers.size(), 3, "listen, walk on, silence")
	await DialogueWalk.play(DIALOGUE, "musician", ["Weitergehen"])
	assert_false(Collection.has_melody("elysia_perfect"), "walking on takes nothing")
	await DialogueWalk.play(DIALOGUE, "musician", ["Zuhören"])
	assert_true(Collection.has_melody("elysia_perfect"))
	assert_eq(Collection.melodies(), 1)
	assert_eq(WorldState.state.elysia.xp, xp + 1000)
	await wait_physics_frames(2)
	assert_true(Beat.reached("market_melody"))
	var later := await DialogueWalk.play(DIALOGUE, "musician")
	assert_eq(later, PackedStringArray([LineText.of("mk_music_5")]), "she plays on")


# --- The hero's quest --------------------------------------------------------------------


func test_the_market_is_the_stage_after_the_chest() -> void:
	WorldState.start_quest("main_elysia_hero")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	await _market()
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "market")
	assert_false(WorldState.is_quest_done("main_elysia_hero"), "the hall is the next stage")


func test_the_market_follows_the_inn() -> void:
	WorldState.start_quest("main_elysia_hero")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	WorldState.advance_quest("main_elysia_hero", "inn")
	await _market()
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "market")


func test_a_visit_before_the_chest_leaves_the_quest_alone_and_the_chest_catches_up() -> void:
	var garden: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(garden)
	await wait_physics_frames(3)
	WorldState.start_quest("main_elysia_hero")
	WorldState.set_flag("elysia.market_seen")
	WorldState.set_flag("elysia.inn_met")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "market", "the inn, then the town")
