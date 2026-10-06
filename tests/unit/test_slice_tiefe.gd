# gdlint: ignore=max-public-methods
extends GutTest
## The slice deepened after the comparison with Explorers of Sky, HeartGold/SoulSilver,
## Black/White and Black 2/White 2 (ADR-042): Mira remembers the day at her fire, the puddle
## shows you, the stone gets a place, frogs come when one stands still, the Antreiber walks
## behind you and sits by the fire, the cat gets a name, the Real journal reads like a diary,
## and Elysia's second task solves itself.

const TAL := preload("res://world/levels/slice/tal.tscn")
const HAUS := preload("res://world/levels/slice/haus.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const WALKER := preload("res://entities/npc/npc_walker.tscn")
const TAL_DIALOGUE := "res://content/dialogue/slice/tal.dialogue"
const HAUS_DIALOGUE := "res://content/dialogue/slice/haus.dialogue"


func before_each() -> void:
	WorldState.new_game()
	SceneTravel.pending_spawn = ""


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	WorldState.new_game()
	SceneTravel.pending_spawn = ""
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## Texts of the answers the player can pick at the first choice of `cue`.
func _answers(path: String, cue: String) -> PackedStringArray:
	var resource := load(path) as DialogueResource
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null and line.responses.is_empty():
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	var texts: PackedStringArray = []
	if line != null:
		for r: DialogueResponse in line.responses:
			if r.is_allowed:
				texts.append(r.text)
	return texts


## Plays `cue` to its end, picking the answer that contains `pick` (else the first one).
func _play(path: String, cue: String, pick := "") -> PackedStringArray:
	var resource := load(path) as DialogueResource
	var seen: PackedStringArray = []
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null:
		seen.append(line.text)
		var next_id := line.next_id
		if not line.responses.is_empty():
			var chosen: DialogueResponse = null
			for r: DialogueResponse in line.responses:
				if r.is_allowed and (chosen == null or (not pick.is_empty() and pick in r.text)):
					chosen = r
			next_id = chosen.next_id
		line = await DialogueManager.get_next_dialogue_line(resource, next_id)
	return seen


func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.get(&"cue") == cue and not node.is_queued_for_deletion():
			return node
	for node in scene.map.find_children("*", "Decor", true, false):
		var area := node.get_node_or_null("Interactable")
		if area != null and node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


# --- Echo -----------------------------------------------------------------------------


func test_mira_remembers_the_day_at_her_fire() -> void:
	WorldState.add_memory("mira", "said_hero")
	WorldState.add_memory("mira", "asked_shelter")
	var seen := await _play(TAL_DIALOGUE, "evening_first")
	assert_true("Der Held von Elysia an meinem Feuer. Ich hätt's mir größer vorgestellt." in seen)
	assert_true("Ans Feuer passen zwei." in seen, "her first no comes back, warmer")


func test_one_tells_her_what_one_actually_did() -> void:
	WorldState.set_flag("valley.berries_eaten")
	WorldState.set_flag("valley.wood_taken")
	var answers := await _answers(TAL_DIALOGUE, "evening_day")
	assert_true("Die erste Brombeere war sauer." in answers)
	assert_true("Der Weg zum Schuppen wollte nicht aufhören." in answers)
	assert_false("Die Blumen am Weg riechen nach Honig." in answers, "one sense, not a list")
	assert_eq(answers.size(), 3, "berries, the path, silence")
	await _play(TAL_DIALOGUE, "evening_day", "Schuppen")
	assert_true(WorldState.has_memory("mira", "told_path"))


func test_a_no_without_reason_is_accepted() -> void:
	var seen := await _play(TAL_DIALOGUE, "evening_elysia", "nicht reden")
	assert_true("Gut." in seen)
	assert_true(WorldState.has_memory("mira", "kept_boundary"))
	assert_true(WorldState.has_facet("boundaries"), "Grenzen, invisibly (Game Bible §16, §17)")


func test_missing_elysia_is_met_without_judgment() -> void:
	var seen := await _play(TAL_DIALOGUE, "evening_elysia", "fehlt")
	assert_true("Klar." in seen)
	assert_true(WorldState.has_memory("mira", "missed_elysia"))


func test_who_asked_about_the_shell_can_guess_where_she_goes() -> void:
	var before := await _play(TAL_DIALOGUE, "ending", "Zum Meer?")
	assert_false("… Ja. Zum Meer." in before)
	assert_true("Zum Meer." in before, "the ending as in the Game Bible")
	WorldState.add_memory("mira", "asked_shell")
	var after := await _play(TAL_DIALOGUE, "ending", "Zum Meer?")
	assert_true("… Ja. Zum Meer." in after, "perception pays off (Game Bible §16)")
	assert_true(WorldState.has_memory("mira", "guessed_sea"))


func test_the_puddle_shows_you_in_the_evening() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var day: GameScene = TAL.instantiate()
	add_child_autofree(day)
	await wait_physics_frames(3)
	assert_null(_first(day, "puddle"), "in the rain the puddle shows nothing")
	day.queue_free()
	await wait_physics_frames(2)
	WorldState.set_flag("house.mira_visited")
	var evening: GameScene = TAL.instantiate()
	add_child_autofree(evening)
	await wait_physics_frames(3)
	assert_not_null(_first(evening, "puddle"))
	WorldState.set_flag("elysia.mirror_seen")
	var seen := await _play(TAL_DIALOGUE, "puddle")
	assert_true("Du hebst die Hand. Das Wasser hebt sie mit." in seen, "Elysia's water did not")
	assert_true(WorldState.has_flag("valley.reflection_seen"))


func test_the_stone_gets_a_place_on_the_shelf() -> void:
	WorldState.add_item("item_stone", 1, false)
	WorldState.add_item("curiosity_tiny_spoon", 1, false)
	var answers := await _answers(HAUS_DIALOGUE, "shelf")
	assert_true("Den Stein hineinlegen" in answers)
	await _play(HAUS_DIALOGUE, "shelf", "Stein")
	assert_eq(WorldState.curiosity_in("shelf_2"), "item_stone")
	assert_false(WorldState.has_item("item_stone"))
	await _play(HAUS_DIALOGUE, "shelf", "Löffel")
	assert_true(WorldState.has_flag("house.shelf_both"))
	var params := {
		"sprite": "haus/shelf",
		"sprite_when":
		{
			"house.shelf_both": "haus/shelf_spoon_stone",
			"house.shelf_filled": "haus/shelf_spoon",
			"house.shelf_stone": "haus/shelf_stone",
		},
	}
	assert_eq(Decor.variant_sprite(params), "haus/shelf_spoon_stone")
	assert_false(PropCatalog.entry("haus/shelf_spoon_stone").is_empty(), "the sprite exists")


func test_the_cold_house_brings_back_the_soup_once() -> void:
	WorldState.set_flag("elysia.soup_served")
	var seen := await _play(HAUS_DIALOGUE, "bed")
	assert_true(
		(
			"Für einen Moment denkst du an das Gasthaus drüben. An die Suppe, die immer warm war."
			in seen
		)
	)
	WorldState.set_fire_lit(true)
	seen = await _play(HAUS_DIALOGUE, "bed")
	assert_eq(seen.size(), 1, "by the fire the thought does not come")


# --- Innehalten -----------------------------------------------------------------------


func test_frogs_come_closer_when_one_stands_still() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.mira_met")
	var scene: GameScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var life: Node = scene.view.world_root.find_children("*", "AmbientLife", true, false)[0]
	var frogs: Array = life.get(&"_frogs")
	var frog: Dictionary = frogs[0]
	# stand on the bank a little way off the first frog
	var spot := Vector2.ZERO
	for cell: Vector2i in life.get(&"_bank_cells"):
		var at := scene.map.cell_to_world(cell)
		var d := at.distance_to(frog["pos"])
		if d > 70.0 and d < 110.0:
			spot = at
			break
	assert_ne(spot, Vector2.ZERO, "a bank spot near the frog")
	scene.player.teleport(spot)
	var start: float = (frog["pos"] as Vector2).distance_to(spot)
	await wait_seconds(AmbientLife.FROG_STILL_SECONDS + 4.0)
	var now: float = (frog["pos"] as Vector2).distance_to(scene.player.global_position)
	assert_lt(now, start, "it came closer")
	assert_gte(now, AmbientLife.FROG_SHY, "but not so close that it would flee")


func test_the_antreiber_follows_you_back_and_sits_by_the_path() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.mira_met")
	WorldState.set_flag("valley.wood_needed")
	WorldState.set_flag("valley.wood_taken")
	SceneTravel.pending_spawn = "west"
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(4)
	var follower: AntreiberActor = scene.get(&"_follower")
	assert_not_null(follower, "he came along")
	assert_lt(follower.global_position.x, scene.player.global_position.x, "behind, not ahead")
	await wait_until(func() -> bool: return WorldState.has_flag("valley.antreiber_rests"), 15.0)
	assert_true(WorldState.has_flag("valley.antreiber_rests"))
	await wait_physics_frames(3)
	var seated := _first(scene, "antreiber_west") as NpcWalker
	assert_not_null(seated)
	assert_true(seated.seated, "sitting by the path")


func test_staying_seated_lets_the_antreiber_sit_by_the_fire() -> void:
	Settings.set_value("text.auto_advance", true, false)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.wood_taken")
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	scene.player.sit_on(scene.map.cell_to_world(Vector2i(17, 11)), Facing.Dir.N)
	# with auto advance every line takes its time: fire, his ideas, him sitting down
	await wait_until(func() -> bool: return WorldState.has_flag("house.antreiber_by_fire"), 75.0)
	assert_true(WorldState.has_flag("house.antreiber_by_fire"))
	await wait_physics_frames(3)
	assert_not_null(_first(scene, "antreiber_rest"), "he stays by the fire")
	await wait_until(func() -> bool: return WorldState.has_flag("house.mira_knocked"), 40.0)
	assert_true(WorldState.has_flag("house.mira_knocked"), "Mira still comes")


func test_getting_up_sends_the_antreiber_off() -> void:
	Settings.set_value("text.auto_advance", true, false)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.wood_taken")
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	scene.player.sit_on(scene.map.cell_to_world(Vector2i(17, 11)), Facing.Dir.N)
	var arrived := func() -> bool:
		return not scene.map.entities.find_children("*", "AntreiberActor", true, false).is_empty()
	await wait_until(arrived, 20.0)
	# his ideas first, then the player gets up instead of staying seated
	await wait_until(func() -> bool: return scene.dialogue_box.visible, 20.0)
	await wait_until(func() -> bool: return not scene.dialogue_box.visible, 20.0)
	scene.player.stand_up()
	await wait_until(func() -> bool: return WorldState.has_flag("house.antreiber_left"), 20.0)
	assert_true(WorldState.has_flag("house.antreiber_left"))
	assert_false(WorldState.has_flag("house.antreiber_by_fire"))


func test_the_cat_sleeps_on_the_antreiber() -> void:
	WorldState.set_flag("house.antreiber_by_fire")
	WorldState.set_flag("house.cat_fed")
	var seen := await _play(HAUS_DIALOGUE, "antreiber_rest")
	assert_true("Er bleibt sitzen. Er wagt nicht, sich zu bewegen." in seen, "Game Bible §28")


func test_seated_npcs_stay_seated() -> void:
	var walker: NpcWalker = WALKER.instantiate()
	add_child_autofree(walker)
	walker.apply_params({"sit": true, "face": "w"})
	await wait_physics_frames(2)
	assert_true(str(walker.sprite.animation).begins_with("sit"))


# --- Bindung --------------------------------------------------------------------------


func test_the_cat_name_is_kept_and_saved() -> void:
	WorldState.set_cat_name("  ")
	assert_push_error("empty cat name refused")
	assert_eq(WorldState.cat_name(), "")
	WorldState.set_cat_name(" Donnerstag ")
	assert_eq(WorldState.cat_name(), "Donnerstag")
	var report: PackedStringArray = []
	var loaded := GameState.from_dict(WorldState.state.to_dict(), report)
	assert_eq(loaded.house.cat_name, "Donnerstag")
	assert_true(report.is_empty())


func test_naming_the_cat_in_the_house() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("house.cat_fed")
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.set_flag("house.cat_naming")
	await wait_physics_frames(2)
	var entry := scene.get_node_or_null("CatName") as NameEntry
	assert_not_null(entry, "the name entry opens")
	assert_true(get_tree().paused, "the world waits")
	assert_eq(entry.title_key, "CAT_NAME_TITLE")
	entry.field.text = "Ofenkatze"
	entry.call(&"_confirm")
	await wait_physics_frames(3)
	assert_false(get_tree().paused)
	assert_eq(WorldState.cat_name(), "Ofenkatze")
	assert_false(WorldState.has_flag("house.cat_naming"))
	assert_true(scene.dialogue_box.visible, "the cat agrees, more or less")


func test_mira_hears_the_cats_name() -> void:
	WorldState.set_flag("house.cat_fed")
	WorldState.set_cat_name("Asche")
	var answers := await _answers(TAL_DIALOGUE, "evening_day")
	assert_true("Asche wohnt jetzt bei mir." in answers)


func test_the_real_journal_reads_like_a_diary() -> void:
	WorldState.start_quest("side_valley_goat")
	WorldState.add_memory("mira", "asked_shelter")
	WorldState.add_memory("mira", "missed_elysia")
	assert_true("[ ]" in Journal.entry_text("side_valley_goat"), "Elysia keeps its check boxes")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	assert_false("[" in Journal.entry_text("side_valley_goat"), "a diary has none")
	var mira := Journal.person_text("mira")
	assert_string_contains(mira, "Sie hat Nein gesagt.")
	assert_string_contains(mira, "Sie hat Klar gesagt.")
	assert_lt(mira.find("Nein"), mira.find("Klar"), "in the order it happened")


# --- Elysia-Dichte --------------------------------------------------------------------


func test_elysias_second_task_solves_itself() -> void:
	WorldState.set_flag("elysia.woke")
	var scene: GameScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var xp := WorldState.state.elysia.xp
	WorldState.start_quest("side_elysia_fountain")
	assert_true(WorldState.is_quest_active("side_elysia_fountain"))
	await wait_seconds(ElysiaScene.FOUNTAIN_SOLVES_AFTER + 0.5)
	assert_true(WorldState.is_quest_done("side_elysia_fountain"), "nobody had to go there")
	assert_eq(WorldState.state.elysia.xp - xp, ElysiaScene.FOUNTAIN_XP)
	assert_gte(WorldState.elysia_level(), 26, "Game Bible §10: level 7, 14, 29 …")
