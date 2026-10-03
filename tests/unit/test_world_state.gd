extends GutTest
## WorldState is the only writer: valid changes are applied, logged and signalled,
## invalid ones are refused without touching the state.

const ContentFixtures := preload("res://tests/unit/content_fixtures.gd")

var ws: WorldStateService


func before_each() -> void:
	ContentFixtures.use()
	ws = WorldStateService.new()


func after_each() -> void:
	ws.free()
	ContentDB.reload()


func test_flags_need_a_namespace_and_signal_changes() -> void:
	watch_signals(ws)
	ws.set_flag("valley.mira_met")
	assert_true(ws.has_flag("valley.mira_met"))
	assert_signal_emitted_with_parameters(ws, "flag_changed", ["valley.mira_met", true])
	ws.set_flag("mira_met")
	ws.set_flag("Valley.Mira")
	assert_push_error('invalid flag id {"flag":"mira_met"}')
	assert_push_error("Valley.Mira")
	assert_false(ws.has_flag("mira_met"))
	assert_eq(ws.state.flags.size(), 1)
	ws.clear_flag("valley.mira_met")
	assert_false(ws.has_flag("valley.mira_met"))
	assert_eq(ws.state.flags.size(), 0, "cleared flags are removed, not stored as false")


func test_quest_runs_only_along_defined_transitions() -> void:
	watch_signals(ws)
	assert_false(ws.advance_quest("side_test", "middle"), "not started yet")
	assert_true(ws.start_quest("side_test"))
	assert_false(ws.start_quest("side_test"), "starting twice does nothing")
	assert_eq(ws.quest_stage("side_test"), "start")
	assert_false(ws.advance_quest("side_test", "done"), "skipping a stage is refused")
	assert_true(ws.advance_quest("side_test", "middle"))
	assert_true(ws.is_quest_active("side_test"))
	assert_true(ws.advance_quest("side_test", "missed"))
	assert_true(ws.is_quest_done("side_test"))
	assert_eq(ws.quest_outcome("side_test"), "missed")
	assert_eq(ws.quest_history("side_test"), PackedStringArray(["start", "middle", "missed"]))
	assert_false(ws.advance_quest("side_test", "done"), "finished quests stay finished")
	assert_signal_emit_count(ws, "quest_changed", 3)


func test_unknown_quests_and_stages_are_refused() -> void:
	assert_false(ws.start_quest("side_nope"))
	assert_push_error("unknown quest")
	ws.start_quest("side_test")
	assert_false(ws.advance_quest("side_test", "nope"))
	assert_push_error("unknown stage")
	assert_eq(ws.quest_stage("side_test"), "start")


func test_objectives_belong_to_the_current_stage() -> void:
	ws.start_quest("side_test")
	assert_false(ws.complete_objective("side_test", "obj_a"), "objective of a later stage")
	assert_push_error("unknown objective")
	ws.advance_quest("side_test", "middle")
	assert_true(ws.complete_objective("side_test", "obj_a"))
	assert_false(ws.complete_objective("side_test", "obj_a"), "only once")
	assert_false(ws.complete_objective("side_test", "obj_x"))
	assert_push_error("obj_x")
	assert_true(ws.is_objective_done("side_test", "obj_a"))
	assert_false(ws.is_objective_done("side_test", "obj_b"))


func test_relationships_use_named_states_and_memories() -> void:
	assert_eq(ws.relationship_state("mira"), "stranger")
	watch_signals(ws)
	ws.set_relationship("mira", "cautious")
	ws.add_memory("mira", "door_silence")
	ws.add_memory("mira", "door_silence")
	assert_eq(ws.relationship_state("mira"), "cautious")
	assert_true(ws.has_memory("mira", "door_silence"))
	assert_signal_emit_count(ws, "relationship_changed", 2)
	ws.set_relationship("mira", "best_friends")
	ws.set_relationship("nobody", "close")
	ws.add_memory("mira", "Bad Id")
	assert_push_error("best_friends")
	assert_push_error("nobody")
	assert_push_error("invalid memory")
	assert_eq(ws.relationship_state("mira"), "cautious")
	assert_false(ws.state.relationships.has("nobody"))
	assert_eq(ws.state.relationships["mira"].memories.size(), 1)


func test_inventory_respects_stack_limits_and_unknown_items() -> void:
	assert_eq(ws.add_item("item_seed", 5), 3, "stack limit 3")
	assert_eq(ws.item_count("item_seed"), 3)
	assert_eq(ws.add_item("item_unknown"), 0)
	assert_push_error("invalid item")
	assert_false(ws.remove_item("item_seed", 4))
	assert_true(ws.remove_item("item_seed", 3))
	assert_false(ws.state.inventory.has("item_seed"), "empty stacks disappear")
	ws.add_item("item_stone")
	ws.add_item("item_seed")
	ws.reduce_inventory_to(["item_stone"])
	assert_eq(ws.state.inventory.keys(), ["item_stone"])


func test_curiosities_move_from_inventory_into_house_slots() -> void:
	assert_false(ws.place_curiosity("shelf_1", "curiosity_spoon"), "not owned")
	ws.add_item("curiosity_spoon")
	assert_false(ws.place_curiosity("shelf_1", "item_stone"), "only curiosities")
	assert_push_error("invalid curiosity")
	assert_true(ws.place_curiosity("shelf_1", "curiosity_spoon"))
	assert_eq(ws.curiosity_in("shelf_1"), "curiosity_spoon")
	assert_eq(ws.item_count("curiosity_spoon"), 0)


func test_elysia_progression_counts_level_ups() -> void:
	watch_signals(ws)
	assert_eq(ws.elysia_level(), 1)
	assert_eq(ws.add_xp(60), 2, "60 XP: level 3")
	assert_eq(ws.elysia_level(), 3)
	assert_eq(ws.add_xp(-5), 0)
	ws.add_gold(10)
	assert_eq(ws.state.elysia.gold, 10)
	assert_eq(GameState.level_for_xp(12500), 29)


func test_ui_mode_facets_house_and_places() -> void:
	watch_signals(ws)
	ws.set_ui_mode(GameState.UiMode.REAL)
	assert_true(ws.is_real())
	assert_signal_emitted(ws, "ui_mode_changed")
	ws.set_facet("courage")
	ws.set_facet("bravery")
	assert_push_error("unknown facet")
	assert_true(ws.has_facet("courage"))
	assert_eq(ws.state.facets.size(), 1)
	ws.set_fire_lit(true)
	assert_true(ws.is_fire_lit())
	ws.discover("valley_bridge")
	ws.discover("valley_bridge")
	assert_eq(ws.state.discovered, PackedStringArray(["valley_bridge"]))


func test_new_game_replaces_everything() -> void:
	watch_signals(ws)
	ws.set_flag("valley.x")
	ws.add_playtime(12.5)
	ws.new_game()
	assert_false(ws.has_flag("valley.x"))
	assert_eq(ws.state.playtime_seconds, 0.0)
	assert_signal_emitted(ws, "state_replaced")
