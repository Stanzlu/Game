class_name DebugPanel
extends MenuLayer
## Developer panel (F4, debug builds only): shows the world state and offers shortcuts to
## test saving, loading, quests, relationships, items and the UI mode without playing there.
## Never part of release builds' behaviour: it frees itself outside debug builds.

const QUICK_SLOT := SaveService.DEBUG_SLOT

var _state: Label
var _was_paused := false


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	title_key = "DEBUG_TITLE"
	panel_width = 200
	layer = 60
	super()
	_state = Label.new()
	_state.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_state.custom_minimum_size = Vector2(250, 0)
	body.add_child(_state)


func _build() -> void:
	list.add_action("DEBUG_QUICKSAVE", _quicksave)
	list.add_action("DEBUG_QUICKLOAD", _quickload)
	list.add_action("DEBUG_ADVANCE_QUESTS", _advance_quests)
	list.add_action("DEBUG_MIRA_NEXT", _next_mira_state)
	list.add_action("DEBUG_UI_MODE", _toggle_ui_mode)
	list.add_action("DEBUG_DAY_LIGHT", _next_day_light)
	list.add_action("DEBUG_MUSIC", _next_music)
	list.add_action("DEBUG_ADD_STONE", func() -> void: _after(WorldState.add_item("item_stone")))
	list.add_action("DEBUG_ADD_XP", func() -> void: _after(WorldState.add_xp(100)))
	list.add_action("DEBUG_VALIDATE", _validate)
	list.add_action("DEBUG_NEW_GAME", _new_game)
	list.add_action("MENU_BACK", close)
	_state.text = describe_state()


func open() -> void:
	_was_paused = get_tree().paused
	super()
	get_tree().paused = true


## Restores the pause state from before (the panel may open over the pause menu).
func close() -> void:
	if not visible:
		return
	super()
	get_tree().paused = _was_paused


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_panel"):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			open()
		return
	super(event)


func _after(_result: Variant = null) -> void:
	_state.text = describe_state()


func _new_game() -> void:
	WorldState.new_game()
	_after()


func _quicksave() -> void:
	# The panel pauses the game, which does not block saving.
	var err := SaveSystem.save_slot(QUICK_SLOT)
	hint.text = tr("SAVE_DONE") if err == OK else "%s (%s)" % [tr("SAVE_FAILED"), error_string(err)]
	_after()


func _quickload() -> void:
	close()
	if SaveSystem.load_slot(QUICK_SLOT) != OK:
		open()
		hint.text = tr("LOAD_FAILED")


func _advance_quests() -> void:
	for quest_id: String in WorldState.state.quests.keys():
		var stage := ContentDB.quest(quest_id).stage(WorldState.quest_stage(quest_id))
		if stage != null and not stage.is_final():
			WorldState.advance_quest(quest_id, stage.next[0])
	_after()


func _next_mira_state() -> void:
	var states := GameState.Relationship.State.keys()
	var index := GameState.relationship_from_name(WorldState.relationship_state("mira"))
	WorldState.set_relationship("mira", str(states[(index + 1) % states.size()]).to_lower())
	_after()


func _toggle_ui_mode() -> void:
	WorldState.set_ui_mode(
		GameState.UiMode.ELYSIA if WorldState.is_real() else GameState.UiMode.REAL
	)
	_after()


func _next_day_light() -> void:
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as LookScene
	if scene == null or scene.day_light == null:
		hint.text = tr("DEBUG_NO_DAY_LIGHT")
		return
	hint.text = tr("DEBUG_DAY_LIGHT_NOW") % scene.day_light.next_preset(3.0)


func _next_music() -> void:
	var tracks: Array = [""] + Array(AudioDirectorService.TRACKS)
	var next: String = tracks[(tracks.find(AudioDirector.current) + 1) % tracks.size()]
	AudioDirector.play_music(next if not next.is_empty() else "silence", 1.5)
	hint.text = tr("DEBUG_MUSIC_NOW") % (next if not next.is_empty() else "—")


func _validate() -> void:
	var problems := ContentValidator.validate_all()
	for problem in problems:
		Log.warn(Log.Category.CONTENT, problem)
	hint.text = tr("DEBUG_VALIDATE_RESULT") % problems.size()


## Compact text dump of the world state (IDs, not display names).
static func describe_state() -> String:
	var s := WorldState.state
	var lines: PackedStringArray = []
	lines.append(
		(
			"ui %s · lvl %d · xp %d · gold %d"
			% [GameState.UiMode.keys()[s.ui_mode], s.elysia.level(), s.elysia.xp, s.elysia.gold]
		)
	)
	lines.append(
		(
			"map %s (%d, %d) · %d s"
			% [s.player.map, s.player.position.x, s.player.position.y, s.playtime_seconds]
		)
	)
	lines.append("flags: " + ", ".join(PackedStringArray(s.flags.keys())))
	for quest_id: String in s.quests:
		lines.append("quest %s: %s" % [quest_id, s.quests[quest_id].stage])
	for npc: String in s.relationships:
		var r: GameState.Relationship = s.relationships[npc]
		lines.append(
			"%s: %s [%s]" % [npc, GameState.relationship_name(r.state), ", ".join(r.memories)]
		)
	var items: PackedStringArray = []
	for item: String in s.inventory:
		items.append("%s×%d" % [item, s.inventory[item]])
	lines.append("items: " + ", ".join(items))
	lines.append("save: %s" % ("ok" if SaveSystem.can_save() else ", ".join(SaveSystem.blockers())))
	return "\n".join(lines)
