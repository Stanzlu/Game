extends GutTest
## Act II, segment B1: the arrival. The cue `arrival_echo` says a gust and the ground to everyone,
## and one line more for each thing Elysia left in the save: at the fire nobody calls you to stay
## (or asks twice), in the puddles no ring repeats, the rain hums for a breath. Nothing is
## explained, nobody speaks. The scene that plays it is tested in test_akt2_ankunft_szene.

const ARRIVAL := "res://content/dialogue/akt2/ankunft.dialogue"


func _lines() -> PackedStringArray:
	return await DialogueWalk.play(ARRIVAL, "arrival_echo")


func _ids(ids: Array[String]) -> PackedStringArray:
	var texts: PackedStringArray = []
	for id in ids:
		texts.append(LineText.of(id))
	return texts


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()


func test_whoever_did_nothing_in_elysia_hears_the_gust_and_the_ground() -> void:
	assert_eq(await _lines(), _ids(["ank_gust_1", "ank_ground_1"]))


func test_the_fire_says_nobody_calls_you_to_stay_if_you_stayed_at_the_inn() -> void:
	WorldState.set_flag("elysia.inn_stayed")
	var seen := await _lines()
	assert_true(LineText.of("ank_fire_1") in seen)
	assert_false(LineText.of("ank_fire_2") in seen)


func test_the_fire_says_nobody_asks_twice_if_you_declined_the_room() -> void:
	WorldState.set_flag("elysia.inn_declined")
	var seen := await _lines()
	assert_true(LineText.of("ank_fire_2") in seen)
	assert_false(LineText.of("ank_fire_1") in seen)


func test_staying_wins_over_declining_and_the_fire_is_never_said_twice() -> void:
	# she declined the room and stayed the night after all: one line about the fire, the later act
	WorldState.set_flag("elysia.inn_declined")
	WorldState.set_flag("elysia.inn_stayed")
	var seen := await _lines()
	assert_true(LineText.of("ank_fire_1") in seen)
	assert_false(LineText.of("ank_fire_2") in seen)


func test_no_ring_repeats_on_the_puddle_if_you_said_it_was_the_same_feast() -> void:
	WorldState.set_flag("elysia.feast_noticed")
	assert_true(LineText.of("ank_rings_1") in await _lines())


func test_the_rain_hums_if_you_can_hum_the_childs_tune() -> void:
	WorldState.set_flag("melody.child_hum")
	assert_true(LineText.of("ank_hum_1") in await _lines())


func test_everything_set_the_echoes_follow_the_gust_and_the_ground_in_order() -> void:
	for flag: String in ["elysia.inn_stayed", "elysia.feast_noticed", "melody.child_hum"]:
		WorldState.set_flag(flag)
	var ids: Array[String] = [
		"ank_gust_1", "ank_ground_1", "ank_fire_1", "ank_rings_1", "ank_hum_1"
	]
	assert_eq(await _lines(), _ids(ids))


func test_the_echo_names_no_figure_and_explains_nothing() -> void:
	# narration only: nobody speaks, and no line is a question or an exclamation (STIL.md)
	for flag: String in [
		"elysia.inn_stayed", "elysia.feast_noticed", "melody.child_hum", "elysia.inn_declined"
	]:
		WorldState.set_flag(flag)
	var resource := load(ARRIVAL) as DialogueResource
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "arrival_echo")
	while line != null:
		assert_eq(line.character, "", "narration: %s" % line.text)
		assert_false(line.text.contains("?") or line.text.contains("!"), line.text)
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
