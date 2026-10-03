class_name ContentValidator
extends RefCounted
## Checks typed content and dialogues. Returns readable problems ("<path>: <problem>").
## Runs in the content tests and at boot in debug builds, so broken content never goes
## unnoticed. Rules: docs/CONTENT_GUIDE.md.
##
## Dialogue rules: every spoken line and answer has a static ID ([ID:...], unique across
## all dialogues); no fake choices (answers of one group must not all continue the same
## way); WorldState calls name existing methods and known quests, items, NPCs and facets.

const DIALOGUE_DIR := "res://content/dialogue"
const WORLD_STATE_SCRIPT := "res://core/world_state.gd"
const QUEST_METHODS: PackedStringArray = [
	"quest_stage",
	"is_quest_started",
	"is_quest_active",
	"is_quest_done",
	"quest_outcome",
	"quest_history",
	"start_quest",
	"advance_quest",
	"complete_objective",
	"is_objective_done",
]
const ITEM_METHODS: PackedStringArray = ["item_count", "has_item", "add_item", "remove_item"]
const NPC_METHODS: PackedStringArray = [
	"relationship_state", "set_relationship", "has_memory", "add_memory"
]
const FLAG_METHODS: PackedStringArray = ["has_flag", "set_flag", "clear_flag"]
const FACET_METHODS: PackedStringArray = ["has_facet", "set_facet"]

static var _call_regex := RegEx.create_from_string("WorldState\\.([a-z_]+)\\(([^)]*)\\)")
static var _string_regex := RegEx.create_from_string('"([^"]*)"')


## Default translation check: a key exists if it translates to something else.
static func has_translation(key: String) -> bool:
	return TranslationServer.translate(key) != StringName(key)


static func validate_quest(
	q: QuestDef, path: String, has_key: Callable = has_translation
) -> PackedStringArray:
	var problems: PackedStringArray = []
	var add := func(msg: String) -> void: problems.append("%s: %s" % [path, msg])
	if not GameState.is_id(q.id) or not (q.id.begins_with("main_") or q.id.begins_with("side_")):
		add.call("quest id '%s' must be main_<...> or side_<...>" % q.id)
	if path.get_file().get_basename() != q.id:
		add.call("file name must match id '%s'" % q.id)
	if q.stages.is_empty():
		add.call("quest has no stages")
		return problems
	if not has_key.call(q.title_key()):
		add.call("missing translation %s" % q.title_key())
	var ids := {}
	var objectives := {}
	for s in q.stages:
		if s == null:
			add.call("empty stage entry")
			continue
		if not GameState.is_id(s.id) or ids.has(s.id):
			add.call("invalid or duplicate stage '%s'" % s.id)
		ids[s.id] = true
		if not has_key.call(q.stage_key(s.id)):
			add.call("missing translation %s" % q.stage_key(s.id))
		if s.is_final() == s.outcome.is_empty():
			add.call("stage '%s': final stages need an outcome, others none" % s.id)
		for o in s.objectives:
			if not GameState.is_id(o) or objectives.has(o):
				add.call("invalid or duplicate objective '%s'" % o)
			objectives[o] = true
			if not has_key.call(q.objective_key(o)):
				add.call("missing translation %s" % q.objective_key(o))
	for s in q.stages:
		for n in s.next if s != null else PackedStringArray():
			if not ids.has(n):
				add.call("stage '%s' leads to unknown stage '%s'" % [s.id, n])
	var reachable := _reachable_stages(q)
	for s in q.stages:
		if s != null and not reachable.has(s.id):
			add.call("stage '%s' is unreachable" % s.id)
	if not q.stages.any(func(s: QuestStageDef) -> bool: return s != null and s.is_final()):
		add.call("quest never ends (no final stage)")
	return problems


static func _reachable_stages(q: QuestDef) -> Dictionary:
	var seen := {}
	var open: Array[String] = []
	if q.stages[0] != null:
		open.append(q.stages[0].id)
	while not open.is_empty():
		var id: String = open.pop_back()
		if seen.has(id) or not q.has_stage(id):
			continue
		seen[id] = true
		open.append_array(Array(q.stage(id).next))
	return seen


static func validate_item(
	i: ItemDef, path: String, has_key: Callable = has_translation
) -> PackedStringArray:
	var problems: PackedStringArray = []
	var prefix := "curiosity_" if i.kind == ItemDef.Kind.CURIOSITY else "item_"
	if not GameState.is_id(i.id) or not i.id.begins_with(prefix):
		problems.append("%s: item id '%s' must start with %s" % [path, i.id, prefix])
	if path.get_file().get_basename() != i.id:
		problems.append("%s: file name must match id '%s'" % [path, i.id])
	for key: String in [i.name_key(), i.desc_key()]:
		if not has_key.call(key):
			problems.append("%s: missing translation %s" % [path, key])
	return problems


## Checks one dialogue source. `seen_ids` collects static IDs across files (uniqueness).
static func validate_dialogue(
	text: String, path: String, seen_ids: Dictionary
) -> PackedStringArray:
	var problems: PackedStringArray = []
	# The compiler's line numbers are already 1-based; it also knows the IDs of imported files.
	var result := DMCompiler.compile_string(text, path)
	for e: DMError in result.errors:
		problems.append("%s:%d: %s" % [path, e.line_number, DMConstants.get_error_message(e.error)])
	if not result.errors.is_empty():
		return problems
	var lines: Dictionary = result.lines
	for key: String in lines:
		var line: Dictionary = lines[key]
		var kind := str(line.get("type"))
		if kind != "dialogue" and kind != "response":
			continue
		var where := "%s:%d" % [path, int(key) + 1]
		var static_id := str(line.get("static_id", ""))
		if static_id.is_empty():
			problems.append("%s: line has no [ID:...]" % where)
		elif seen_ids.has(static_id):
			problems.append(
				"%s: ID '%s' already used in %s" % [where, static_id, seen_ids[static_id]]
			)
		else:
			seen_ids[static_id] = where
		if kind == "response" and line.has("responses"):
			problems.append_array(_check_choice(lines, line, where))
	problems.append_array(_check_world_state_calls(text, path))
	return problems


## A choice is fake if every answer continues with the same next line and none has its own
## reaction or state change.
static func _check_choice(lines: Dictionary, first: Dictionary, where: String) -> PackedStringArray:
	var targets := {}
	for id: Variant in first["responses"]:
		var response: Dictionary = lines.get(str(id), {})
		targets[str(response.get("next_id", ""))] = true
	if targets.size() < 2:
		return ["%s: fake choice, every answer continues the same way" % where]
	return []


static func _check_world_state_calls(text: String, path: String) -> PackedStringArray:
	var problems: PackedStringArray = []
	var methods := {}
	for m: Dictionary in (load(WORLD_STATE_SCRIPT) as Script).get_script_method_list():
		methods[m["name"]] = true
	for m in _call_regex.search_all(text):
		var method := m.get_string(1)
		var args: PackedStringArray = []
		for s in _string_regex.search_all(m.get_string(2)):
			args.append(s.get_string(1))
		var problem := _check_call(method, args, methods)
		if not problem.is_empty():
			var line_no := text.substr(0, m.get_start()).count("\n") + 1
			problems.append("%s:%d: %s" % [path, line_no, problem])
	return problems


static func _check_call(method: String, args: PackedStringArray, methods: Dictionary) -> String:
	if not methods.has(method) or method.begins_with("_"):
		return "WorldState has no method '%s'" % method
	var first := args[0] if args.size() > 0 else ""
	if method in QUEST_METHODS:
		var q := ContentDB.quest(first)
		if q == null:
			return "unknown quest '%s'" % first
		if method == "advance_quest" and args.size() > 1 and not q.has_stage(args[1]):
			return "quest '%s' has no stage '%s'" % [first, args[1]]
	elif method in ITEM_METHODS and not ContentDB.has_item(first):
		return "unknown item '%s'" % first
	elif method in NPC_METHODS:
		if not first in GameState.NPCS:
			return "unknown character '%s'" % first
		var state_name := args[1] if args.size() > 1 else ""
		if method == "set_relationship" and GameState.relationship_from_name(state_name) < 0:
			return "unknown relationship state '%s'" % state_name
	elif method in FLAG_METHODS and not GameState.is_flag_id(first):
		return "flag '%s' needs a namespace (area.name)" % first
	elif method in FACET_METHODS and not first in GameState.FACETS:
		return "unknown facet '%s'" % first
	return ""


static func dialogue_paths(dir_path := DIALOGUE_DIR) -> PackedStringArray:
	var found: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	for file_name in dir.get_files():
		if file_name.get_extension() == "dialogue":
			found.append(dir_path.path_join(file_name))
	for sub in dir.get_directories():
		found.append_array(dialogue_paths(dir_path.path_join(sub)))
	found.sort()
	return found


## Everything under content/. Dialogue sources are skipped where they are not shipped
## (exported builds contain only the compiled resources).
static func validate_all() -> PackedStringArray:
	var problems: PackedStringArray = []
	for path in ContentDB.resource_paths(ContentDB.QUEST_DIR):
		var q := load(path) as QuestDef
		if q == null:
			problems.append("%s: not a QuestDef" % path)
		else:
			problems.append_array(validate_quest(q, path))
	for path in ContentDB.resource_paths(ContentDB.ITEM_DIR):
		var i := load(path) as ItemDef
		if i == null:
			problems.append("%s: not an ItemDef" % path)
		else:
			problems.append_array(validate_item(i, path))
	var seen := {}
	for path in dialogue_paths():
		problems.append_array(validate_dialogue(FileAccess.get_file_as_string(path), path, seen))
	return problems


## Lists draft content (quests and items still marked as placeholders).
static func drafts() -> PackedStringArray:
	var found: PackedStringArray = []
	for q in ContentDB.quests():
		if q.draft:
			found.append(q.id)
	for i in ContentDB.items():
		if i.draft:
			found.append(i.id)
	return found
