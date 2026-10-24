extends GutTest
## Act I, segment A2: the Gasthaus zum Immer. The host offers a meal, a room and a night, and each
## offer can be refused and comes back; the guest book is the second small quest; the night in the
## bed is the same morning again; the hero's quest finds its stage "inn" from either side.

const GASTHAUS := preload("res://world/levels/akt1/gasthaus.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const DIALOGUE := "res://content/dialogue/akt1/gasthaus.dialogue"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _inn() -> GasthausScene:
	var scene: GasthausScene = GASTHAUS.instantiate()
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


func test_the_hall_has_its_people_and_everything_twice() -> void:
	var scene := await _inn()
	assert_eq(_props_with_cue(scene, "host").size(), 1, "one host, on the axis")
	assert_eq(_props_with_cue(scene, "guest").size(), 4, "four guests at four tables")
	for cue: String in ["window", "back_door", "hearth", "guestbook", "room_locked", "bed"]:
		assert_eq(_props_with_cue(scene, cue).size(), 2, "%s stands once on each side" % cue)
	assert_eq(_props_with_cue(scene, "clock").size(), 1, "the clock hangs in the middle")
	assert_true(Beat.reached("inn_enter"))


func test_the_rooms_are_shut_until_the_host_says_so() -> void:
	var scene := await _inn()
	assert_eq(_props_with_cue(scene, "room_locked").size(), 2)
	WorldState.set_flag("elysia.inn_room")
	await wait_physics_frames(3)
	assert_eq(_props_with_cue(scene, "room_locked").size(), 0, "both doors stand open")


func test_the_camera_stays_inside_the_rooms() -> void:
	var scene := await _inn()
	var bounds: Rect2 = scene.view.bounds
	assert_eq(bounds.position, Vector2(0, 64))
	assert_eq(bounds.size, Vector2(656, 256))


# --- The host: three offers, each free to refuse --------------------------------------


func test_the_first_talk_welcomes_and_asks_for_the_guest_book() -> void:
	var seen := await DialogueWalk.play(DIALOGUE, "host", ["schau mich nur um"])
	assert_true(LineText.of("gh_host_1") in seen)
	assert_true(LineText.of("gh_host_4") in seen, "looking around is an answer")
	assert_true(WorldState.has_flag("elysia.inn_met"))
	assert_true(WorldState.is_quest_active("side_elysia_guestbook"))
	assert_false(WorldState.has_flag("elysia.inn_fed"), "nothing was eaten")


func test_the_second_talk_serves_bread_and_praises_the_hero() -> void:
	WorldState.set_flag("elysia.inn_met")
	var xp: int = WorldState.state.elysia.xp
	var seen := await DialogueWalk.play(DIALOGUE, "host", ["Brot"])
	assert_true(LineText.of("gh_meal_3") in seen)
	assert_true(LineText.of("gh_meal_6") in seen)
	assert_true(WorldState.has_flag("elysia.inn_fed"))
	assert_eq(WorldState.state.elysia.xp, xp + 300)


func test_the_room_may_be_refused_and_is_offered_again() -> void:
	WorldState.set_flag("elysia.inn_met")
	WorldState.set_flag("elysia.inn_fed")
	var first := await DialogueWalk.play(DIALOGUE, "host", ["weiter"])
	assert_true(LineText.of("gh_room_3") in first, "the line of the Betäuber (Game Bible §14)")
	assert_true(WorldState.has_flag("elysia.inn_declined"))
	assert_false(WorldState.has_flag("elysia.inn_room"), "refusing opens no door")
	var again := await DialogueWalk.play(DIALOGUE, "host", ["seh es mir an"])
	assert_true(LineText.of("gh_room_8") in again, "he asks again, kindly")
	assert_false(LineText.of("gh_room_1") in again, "and does not repeat himself word for word")
	assert_true(WorldState.has_flag("elysia.inn_room"))


func test_after_the_night_he_offers_to_keep_him_for_ever_and_lets_him_go() -> void:
	for flag: String in ["inn_met", "inn_fed", "inn_room", "inn_slept"]:
		WorldState.set_flag("elysia." + flag)
	var seen := await DialogueWalk.play(DIALOGUE, "host", ["Ich geh gleich"])
	assert_true(LineText.of("gh_slept_2") in seen)
	assert_true(LineText.of("gh_slept_4") in seen, "he holds the place, he never holds the guest")
	assert_false(WorldState.has_flag("elysia.inn_stayed"))
	await DialogueWalk.play(DIALOGUE, "host", ["bleib noch"])
	assert_true(WorldState.has_flag("elysia.inn_stayed"))
	var later := await DialogueWalk.play(DIALOGUE, "host", ["bleib noch"])
	assert_true(LineText.of("gh_slept_5") in later, "he is glad every time")


func test_every_answer_to_the_offers_leads_somewhere_of_its_own() -> void:
	WorldState.set_flag("elysia.inn_met")
	WorldState.set_flag("elysia.inn_fed")
	var answers := await DialogueWalk.answers(DIALOGUE, "host")
	assert_eq(answers.size(), 3, "accept, refuse, silence")


# --- The guest book: the second small quest ------------------------------------------


func test_signing_the_book_pays_for_nothing() -> void:
	WorldState.start_quest("side_elysia_guestbook")
	var xp: int = WorldState.state.elysia.xp
	var gold: int = WorldState.state.elysia.gold
	var seen := await DialogueWalk.play(DIALOGUE, "guestbook", ["noch einmal eintragen"])
	assert_true(LineText.of("gh_book_4") in seen)
	assert_true(WorldState.is_quest_done("side_elysia_guestbook"))
	assert_eq(WorldState.state.elysia.xp, xp + 2000)
	assert_eq(WorldState.state.elysia.gold, gold + 500)
	var after := await DialogueWalk.play(DIALOGUE, "guestbook")
	assert_eq(after, PackedStringArray([LineText.of("gh_book_3")]), "signed once, and that is that")


func test_the_book_can_be_left_alone() -> void:
	WorldState.start_quest("side_elysia_guestbook")
	await DialogueWalk.play(DIALOGUE, "guestbook", ["Lieber nicht"])
	assert_true(WorldState.has_flag("elysia.inn_book_seen"))
	assert_false(WorldState.is_quest_done("side_elysia_guestbook"))
	var second := await DialogueWalk.answers(DIALOGUE, "guestbook")
	assert_eq(second.size(), 2, "the offer stands, the second look gets the short text")


# --- The night ---------------------------------------------------------------------------


func test_sleeping_is_the_same_morning_and_nothing_stops_the_way_out() -> void:
	Settings.set_value("text.auto_advance", true, false)
	var scene := await _inn()
	WorldState.set_flag("elysia.inn_sleeping")
	await wait_until(func() -> bool: return WorldState.has_flag("elysia.inn_slept"), 20.0)
	await wait_until(func() -> bool: return Beat.reached("inn_slept"), 20.0)
	Settings.set_value("text.auto_advance", false, false)
	assert_false(WorldState.has_flag("elysia.inn_sleeping"), "the trigger is spent")
	assert_gte(WorldState.state.elysia.xp, 500)
	assert_false(scene.player.is_locked(), "the player is free again")


func test_the_bed_asks_before_it_puts_anyone_to_sleep() -> void:
	var answers := await DialogueWalk.answers(DIALOGUE, "bed")
	assert_eq(answers.size(), 2)
	var seen := await DialogueWalk.play(DIALOGUE, "bed", ["Stehen bleiben"])
	assert_true(LineText.of("gh_bed_3") in seen)
	assert_false(WorldState.has_flag("elysia.inn_sleeping"))


# --- The hero's quest ----------------------------------------------------------------------


func test_meeting_the_host_after_the_chest_gives_the_hero_quest_its_stage_inn() -> void:
	await _inn()
	WorldState.start_quest("main_elysia_hero")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	WorldState.set_flag("elysia.inn_met")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "inn", "the town is the next stage")
	assert_false(WorldState.is_quest_done("main_elysia_hero"))


func test_opening_the_chest_after_the_visit_finds_the_stage_for_itself() -> void:
	var scene: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.inn_met")
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.start_quest("main_elysia_hero")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "inn", "the inn was already behind him")


func test_the_door_in_the_garden_leads_here_and_the_way_back_exists() -> void:
	var garden: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(garden)
	await wait_physics_frames(3)
	assert_false(
		garden.map.data.find_marker("spawn_inn").is_empty(), "the inn's door gives out here"
	)
	var inn := await _inn()
	assert_false(inn.map.data.find_marker("spawn_door").is_empty(), "and the garden gives in here")
