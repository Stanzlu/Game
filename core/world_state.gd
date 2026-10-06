# gdlint: ignore=max-public-methods
class_name WorldStateService
extends Node
## Autoload "WorldState": the only place that changes game state. Every change is checked
## against content (quests, items, NPCs), logged under WORLD_STATE and announced with a
## typed signal. Dialogues use the same methods in conditions and mutations, e.g.
## `if WorldState.has_flag("valley.mira_met")` or `do WorldState.start_quest("side_x")`.
## Reads never change anything; invalid writes are refused with a log entry, never silently.

signal flag_changed(id: String, value: bool)
signal quest_changed(quest_id: String, stage: String)
signal objective_changed(quest_id: String, objective_id: String)
signal relationship_changed(npc_id: String)
signal inventory_changed(item_id: String, count: int)
## An item was added (Elysia shows a loot popup, the Real world a quiet line).
signal item_received(item_id: String, amount: int)
signal house_changed
signal ui_mode_changed(mode: GameState.UiMode)
## Elysia's reward layer changed: XP and gold gained, levels gained (for the popups).
signal progression_changed(xp_gained: int, gold_gained: int, levels_gained: int)
## The whole state was replaced (new game or loaded save).
signal state_replaced

var state := GameState.new()

# --- Lifecycle -------------------------------------------------------------------------


func new_game() -> void:
	replace_state(GameState.new())
	Log.info(Log.Category.WORLD_STATE, "new game")


func replace_state(new_state: GameState) -> void:
	var old_mode := state.ui_mode
	state = new_state
	state_replaced.emit()
	if state.ui_mode != old_mode:
		ui_mode_changed.emit(state.ui_mode)


func add_playtime(seconds: float) -> void:
	if seconds > 0.0 and is_finite(seconds):
		state.playtime_seconds += seconds


func set_location(map: String, position: Vector2) -> void:
	state.player.map = map
	state.player.position = position


# --- Story flags -----------------------------------------------------------------------


## The protagonist's name (chosen at the start). Dialogue lines use {{WorldState.player_name()}}.
func player_name() -> String:
	return state.player.name if not state.player.name.is_empty() else tr("PLAYER_DEFAULT_NAME")


func set_player_name(new_name: String) -> void:
	var clean := new_name.strip_edges().left(GameState.MAX_NAME_LENGTH)
	state.player.name = clean
	Log.info(Log.Category.WORLD_STATE, "player name", {"name": clean})


func has_flag(id: String) -> bool:
	return state.flags.get(id, false)


func set_flag(id: String, value := true) -> void:
	if not GameState.is_flag_id(id):
		Log.error(Log.Category.WORLD_STATE, "invalid flag id", {"flag": id})
		return
	if has_flag(id) == value:
		return
	if value:
		state.flags[id] = true
	else:
		state.flags.erase(id)
	Log.info(Log.Category.WORLD_STATE, "flag", {"flag": id, "value": value})
	flag_changed.emit(id, value)


func clear_flag(id: String) -> void:
	set_flag(id, false)


# --- Quests ----------------------------------------------------------------------------


## Current stage ID or "" if the quest has not started.
func quest_stage(quest_id: String) -> String:
	var q: GameState.QuestProgress = state.quests.get(quest_id)
	return q.stage if q != null else ""


func is_quest_started(quest_id: String) -> bool:
	return state.quests.has(quest_id)


func is_quest_active(quest_id: String) -> bool:
	return is_quest_started(quest_id) and not is_quest_done(quest_id)


func is_quest_done(quest_id: String) -> bool:
	var def := ContentDB.quest(quest_id)
	var stage := quest_stage(quest_id)
	return def != null and not stage.is_empty() and def.stage(stage).is_final()


## Outcome ID of a finished quest ("" while running or not started).
func quest_outcome(quest_id: String) -> String:
	return (
		ContentDB.quest(quest_id).stage(quest_stage(quest_id)).outcome
		if is_quest_done(quest_id)
		else ""
	)


func quest_history(quest_id: String) -> PackedStringArray:
	var q: GameState.QuestProgress = state.quests.get(quest_id)
	return q.history.duplicate() if q != null else PackedStringArray()


## Starts a quest at its first stage. Starting a started quest does nothing.
func start_quest(quest_id: String) -> bool:
	var def := ContentDB.quest(quest_id)
	if def == null or def.first_stage() == null:
		Log.error(Log.Category.QUEST, "unknown quest", {"quest": quest_id})
		return false
	if is_quest_started(quest_id):
		return false
	var q := GameState.QuestProgress.new()
	q.stage = def.first_stage().id
	q.history.append(q.stage)
	state.quests[quest_id] = q
	Log.info(Log.Category.QUEST, "quest started", {"quest": quest_id, "stage": q.stage})
	quest_changed.emit(quest_id, q.stage)
	return true


## Moves a quest to `stage`. Only transitions listed in the current stage's `next` are
## allowed; anything else is refused and logged (world triggers may fire out of order).
func advance_quest(quest_id: String, stage: String) -> bool:
	var def := ContentDB.quest(quest_id)
	if def == null:
		Log.error(Log.Category.QUEST, "unknown quest", {"quest": quest_id})
		return false
	if not def.has_stage(stage):
		Log.error(Log.Category.QUEST, "unknown stage", {"quest": quest_id, "stage": stage})
		return false
	var current := quest_stage(quest_id)
	if not def.can_advance(current, stage):
		Log.info(
			Log.Category.QUEST,
			"transition refused",
			{"quest": quest_id, "from": current, "to": stage}
		)
		return false
	var q: GameState.QuestProgress = state.quests[quest_id]
	q.stage = stage
	q.history.append(stage)
	Log.info(Log.Category.QUEST, "quest stage", {"quest": quest_id, "stage": stage})
	quest_changed.emit(quest_id, stage)
	return true


func complete_objective(quest_id: String, objective_id: String) -> bool:
	var def := ContentDB.quest(quest_id)
	if def == null or not is_quest_active(quest_id):
		Log.info(Log.Category.QUEST, "objective ignored", {"quest": quest_id, "obj": objective_id})
		return false
	if not objective_id in def.stage(quest_stage(quest_id)).objectives:
		Log.error(Log.Category.QUEST, "unknown objective", {"quest": quest_id, "obj": objective_id})
		return false
	var q: GameState.QuestProgress = state.quests[quest_id]
	if objective_id in q.objectives_done:
		return false
	q.objectives_done.append(objective_id)
	Log.info(Log.Category.QUEST, "objective done", {"quest": quest_id, "obj": objective_id})
	objective_changed.emit(quest_id, objective_id)
	return true


func is_objective_done(quest_id: String, objective_id: String) -> bool:
	var q: GameState.QuestProgress = state.quests.get(quest_id)
	return q != null and objective_id in q.objectives_done


# --- Relationships ---------------------------------------------------------------------


## "stranger", "cautious", "familiar", "close" or "strained".
func relationship_state(npc_id: String) -> String:
	var r: GameState.Relationship = state.relationships.get(npc_id)
	return GameState.relationship_name(r.state if r != null else 0)


func set_relationship(npc_id: String, state_name: String) -> void:
	var value := GameState.relationship_from_name(state_name)
	if not npc_id in GameState.NPCS or value < 0:
		Log.error(
			Log.Category.WORLD_STATE, "invalid relationship", {"npc": npc_id, "state": state_name}
		)
		return
	var r := _relationship(npc_id)
	if r.state == value:
		return
	r.state = value as GameState.Relationship.State
	Log.info(Log.Category.WORLD_STATE, "relationship", {"npc": npc_id, "state": state_name})
	relationship_changed.emit(npc_id)


func has_memory(npc_id: String, memory_id: String) -> bool:
	var r: GameState.Relationship = state.relationships.get(npc_id)
	return r != null and memory_id in r.memories


func add_memory(npc_id: String, memory_id: String) -> void:
	if not npc_id in GameState.NPCS or not GameState.is_id(memory_id):
		Log.error(Log.Category.WORLD_STATE, "invalid memory", {"npc": npc_id, "memory": memory_id})
		return
	var r := _relationship(npc_id)
	if memory_id in r.memories:
		return
	r.memories.append(memory_id)
	Log.info(Log.Category.WORLD_STATE, "memory", {"npc": npc_id, "memory": memory_id})
	relationship_changed.emit(npc_id)


func _relationship(npc_id: String) -> GameState.Relationship:
	if not state.relationships.has(npc_id):
		state.relationships[npc_id] = GameState.Relationship.new()
	return state.relationships[npc_id]


# --- Facets (slice: flags only) --------------------------------------------------------


func has_facet(facet_id: String) -> bool:
	return state.facets.get(facet_id, false)


func set_facet(facet_id: String) -> void:
	if not facet_id in GameState.FACETS:
		Log.error(Log.Category.WORLD_STATE, "unknown facet", {"facet": facet_id})
		return
	if not has_facet(facet_id):
		state.facets[facet_id] = true
		Log.info(Log.Category.WORLD_STATE, "facet", {"facet": facet_id})


# --- Inventory -------------------------------------------------------------------------


func item_count(item_id: String) -> int:
	return state.inventory.get(item_id, 0)


func has_item(item_id: String, amount := 1) -> bool:
	return item_count(item_id) >= amount


## Adds up to the item's stack limit. Returns how many were actually added.
## `announce` false adds silently (no loot card), e.g. what the hero already carried.
func add_item(item_id: String, amount := 1, announce := true) -> int:
	var def := ContentDB.item(item_id)
	if def == null or amount <= 0:
		Log.error(Log.Category.WORLD_STATE, "invalid item", {"item": item_id, "amount": amount})
		return 0
	var before := item_count(item_id)
	var after := mini(before + amount, def.max_stack)
	if after == before:
		return 0
	state.inventory[item_id] = after
	Log.info(Log.Category.WORLD_STATE, "item added", {"item": item_id, "count": after})
	inventory_changed.emit(item_id, after)
	if announce:
		item_received.emit(item_id, after - before)
	return after - before


func remove_item(item_id: String, amount := 1) -> bool:
	if amount <= 0 or not has_item(item_id, amount):
		Log.info(Log.Category.WORLD_STATE, "remove refused", {"item": item_id, "amount": amount})
		return false
	var after := item_count(item_id) - amount
	if after == 0:
		state.inventory.erase(item_id)
	else:
		state.inventory[item_id] = after
	Log.info(Log.Category.WORLD_STATE, "item removed", {"item": item_id, "count": after})
	inventory_changed.emit(item_id, after)
	return true


## Keeps only the given items (the transition from Elysia leaves stone and seed).
func reduce_inventory_to(keep: PackedStringArray) -> void:
	for item_id: String in state.inventory.keys():
		if not item_id in keep:
			state.inventory.erase(item_id)
			inventory_changed.emit(item_id, 0)
	Log.info(Log.Category.WORLD_STATE, "inventory reduced", {"kept": Array(keep)})


# --- House -----------------------------------------------------------------------------


func is_fire_lit() -> bool:
	return state.house.fire_lit


func set_fire_lit(lit: bool) -> void:
	if state.house.fire_lit == lit:
		return
	state.house.fire_lit = lit
	Log.info(Log.Category.WORLD_STATE, "house fire", {"lit": lit})
	house_changed.emit()


func curiosity_in(slot_id: String) -> String:
	return state.house.curiosity_slots.get(slot_id, "")


## Moves a curiosity from the inventory into a slot (an occupied slot gives its item back).
func place_curiosity(slot_id: String, item_id: String) -> bool:
	var def := ContentDB.item(item_id)
	if not GameState.is_id(slot_id) or def == null or not def.can_be_placed():
		Log.error(Log.Category.WORLD_STATE, "invalid curiosity", {"slot": slot_id, "item": item_id})
		return false
	if not remove_item(item_id):
		return false
	var previous := curiosity_in(slot_id)
	if not previous.is_empty():
		add_item(previous)
	state.house.curiosity_slots[slot_id] = item_id
	Log.info(Log.Category.WORLD_STATE, "curiosity placed", {"slot": slot_id, "item": item_id})
	house_changed.emit()
	return true


func cat_name() -> String:
	return state.house.cat_name


## Names the cat (Game Bible §28). Empty names are refused; the name is trimmed and capped.
func set_cat_name(new_name: String) -> void:
	var clean := new_name.strip_edges().left(GameState.MAX_NAME_LENGTH)
	if clean.is_empty():
		Log.error(Log.Category.WORLD_STATE, "empty cat name refused")
		return
	state.house.cat_name = clean
	Log.info(Log.Category.WORLD_STATE, "cat name", {"name": clean})
	house_changed.emit()


# --- Discovered locations --------------------------------------------------------------


func is_discovered(location_id: String) -> bool:
	return location_id in state.discovered


func discover(location_id: String) -> void:
	if not GameState.is_id(location_id):
		Log.error(Log.Category.WORLD_STATE, "invalid location", {"location": location_id})
		return
	if is_discovered(location_id):
		return
	state.discovered.append(location_id)
	Log.info(Log.Category.WORLD_STATE, "discovered", {"location": location_id})


# --- UI mode and Elysia layer ----------------------------------------------------------


func ui_mode() -> GameState.UiMode:
	return state.ui_mode


func is_real() -> bool:
	return state.ui_mode == GameState.UiMode.REAL


func set_ui_mode(mode: GameState.UiMode) -> void:
	if state.ui_mode == mode:
		return
	state.ui_mode = mode
	Log.info(Log.Category.WORLD_STATE, "ui mode", {"mode": GameState.UiMode.keys()[mode]})
	ui_mode_changed.emit(mode)


## Time of day of the Real world ("" if no scene with daylight has set one yet).
func day_preset() -> String:
	return state.day_preset


func set_day_preset(preset: String) -> void:
	if state.day_preset == preset or not (preset.is_empty() or preset in GameState.DAY_PRESETS):
		return
	state.day_preset = preset
	Log.info(Log.Category.WORLD_STATE, "time of day", {"preset": preset})


func elysia_level() -> int:
	return state.elysia.level()


## Adds cosmetic XP and returns the number of level-ups (for Elysia's popups).
func add_xp(amount: int) -> int:
	if amount <= 0:
		return 0
	var before := state.elysia.level()
	var xp_before := state.elysia.xp
	state.elysia.xp = mini(state.elysia.xp + amount, GameState.MAX_AMOUNT)
	var gained := state.elysia.level() - before
	Log.info(Log.Category.WORLD_STATE, "xp", {"xp": state.elysia.xp, "levels": gained})
	progression_changed.emit(state.elysia.xp - xp_before, 0, gained)
	return gained


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	var gold_before := state.elysia.gold
	state.elysia.gold = mini(state.elysia.gold + amount, GameState.MAX_AMOUNT)
	Log.info(Log.Category.WORLD_STATE, "gold", {"gold": state.elysia.gold})
	progression_changed.emit(0, state.elysia.gold - gold_before, 0)
