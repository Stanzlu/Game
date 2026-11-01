class_name StoryLint
extends RefCounted
## Cross-checks between maps, scene scripts, dialogues and quests: what no single file can see
## (docs/PRODUKTIONSPLAN.md, T2). The rules are pure functions over a `Sources` snapshot, so every
## rule has a red fixture in tests/unit/test_story_lint.gd; `validate_project()` fills a snapshot
## from the real files. Problems read "<where>: <problem>".
##
## Rules: door and travel targets name a registered scene and a spawn marker that exists there;
## every cue a map or script starts exists in its dialogue; every quest stage has a trigger
## (something advances to it); every flag that is read is set somewhere and every flag that is
## set is read somewhere (a flag nobody reads is a fake choice in the making); no spawn marker or
## beat appears twice; every facet that is set is read somewhere and the other way round (a facet
## shows itself as answers that were not there before, Game Bible §16); a script that makes its
## own flash or shake reads the matching setting.
## Like the dialogue sources, the files are not shipped: exported builds skip this lint.

const CODE_DIRS: PackedStringArray = [
	"res://core", "res://entities", "res://world", "res://ui", "res://encounters"
]
const MAP_DIR := "res://content/maps"
const DIALOGUE_DIR := "res://content/dialogue"
## Where a prop looks for its cue when the map does not say (Talk and NpcWalker defaults).
const TAL_DIALOGUE := "res://content/dialogue/slice/tal.dialogue"
const SANDBOX_DIALOGUE := "res://content/dialogue/sandbox/sandbox.dialogue"
const PROP_DIALOGUES := {
	"res://entities/npc/npc_walker.tscn": SANDBOX_DIALOGUE,
	"res://world/props/sign.tscn": SANDBOX_DIALOGUE,
}
const TRAVEL_PROPS: PackedStringArray = [
	"res://world/props/door.tscn", "res://world/props/rift.tscn"
]
## Flags that are set and never read, by design. Each needs its reason. The beat flags
## ("beat.<id>") are read by the beat log and the autosave, not by logic.
const WRITE_ONLY_FLAG_PREFIXES: PackedStringArray = ["beat.", "fragment.", "melody."]
const WRITE_ONLY_FLAGS := {
	"house.mira_knocked": "marker that tests and autopilot scripts wait for; no reader in the game",
	"elysia.rift_crossed":
	"marker for tests; the crossing is a reserve for the consequence register",
	"encounter.antreiber_resolved": "reserve: the way's outcome, read by the consequence register",
	"chapter.act1":
	"chapter mark of Act I (ADR-067): the save slots and the return in Act VI will read it",
	"chapter.act2":
	"chapter mark of Act II (ADR-067): the save slots and the return in Act VI will read it",
	"chapter.act3":
	"chapter mark of Act III (ADR-070): the valley's map reads it (ADR-071), Act V will in code",
}

static var _const_regex := RegEx.create_from_string(
	'(?m)^const\\s+([A-Z][A-Z0-9_]*)\\s*(?::=|=|:\\s*\\w+\\s*=)\\s*(?:preload\\()?"([^"]*)"'
)
static var _flag_call_regex := RegEx.create_from_string(
	"\\b(set_flag|clear_flag|has_flag)\\(([^()\\n]*)\\)"
)
static var _flag_param_regex := RegEx.create_from_string(
	'"(?:flag|start_flag)"\\s*:\\s*("[^"]*"|[A-Za-z_][A-Za-z0-9_]*)'
)
static var _facet_regex := RegEx.create_from_string('\\b(set_facet|has_facet)\\(\\s*"([a-z_]+)"')
static var _token_regex := RegEx.create_from_string('"[^"]*"|[A-Za-z_][A-Za-z0-9_]*')
static var _mark_regex := RegEx.create_from_string(
	'\\b(Beat|Chapter)\\.(mark|reached)\\(\\s*("[^"]*"|[A-Za-z_][A-Za-z0-9_]*)(?=\\s*[,)])'
)
static var _flags_dict_regex := RegEx.create_from_string('flags(?:\\.get\\(|\\[)\\s*"([^"]+)"')
static var _literal_flag_regex := RegEx.create_from_string('"([a-z0-9_]+\\.[a-z0-9_]+)"')
static var _advance_regex := (
	RegEx
	. create_from_string(
		'\\badvance_quest\\(\\s*("[^"]*"|[A-Za-z_][A-Za-z0-9_]*)\\s*,\\s*("[^"]*"|[A-Za-z_][A-Za-z0-9_]*)'
	)
)
static var _start_regex := RegEx.create_from_string(
	'\\bstart_quest\\(\\s*("[^"]*"|[A-Za-z_][A-Za-z0-9_]*)'
)
static var _cue_call_regex := RegEx.create_from_string(
	(
		"\\b(?:Talk\\.present|cut\\.say)\\(\\s*(?:self\\s*,\\s*)?"
		+ '([A-Za-z_][A-Za-z0-9_]*(?:\\.resource_path)?|"[^"]*")\\s*,\\s*("[^"]*")'
	)
)
static var _travel_call_regex := RegEx.create_from_string(
	'\\bSceneTravel\\.go\\(\\s*\\w+\\s*,\\s*"([^"]*)"\\s*,\\s*"([^"]*)"'
)
static var _flash_def_regex := RegEx.create_from_string(
	"(?m)^(?:static\\s+)?(?:func|var)\\s+_?\\w*(?:flash|flicker|strobe|lightning)\\w*"
)
static var _shake_def_regex := RegEx.create_from_string(
	"(?m)^(?:static\\s+)?(?:func|var)\\s+_?\\w*shake\\w*"
)


## Everything the rules look at. Fixtures fill the dictionaries by hand.
class Sources:
	extends RefCounted
	## path -> source text of scripts (tests excluded) and dialogues
	var code: Dictionary = {}
	var dialogues: Dictionary = {}
	## path -> MapData
	var maps: Dictionary = {}
	## dialogue path -> PackedStringArray of its cues
	var cues: Dictionary = {}
	## scene key -> map path (from the scene's `map_path`)
	var scene_maps: Dictionary = {}
	var quests: Array[QuestDef] = []


## Reads the real project.
static func load_project() -> Sources:
	var src := Sources.new()
	for dir_path in CODE_DIRS:
		for path in _files(dir_path, ["gd"]):
			src.code[path] = FileAccess.get_file_as_string(path)
	for path in ContentValidator.dialogue_paths(DIALOGUE_DIR):
		src.dialogues[path] = FileAccess.get_file_as_string(path)
		var resource := load(path) as DialogueResource
		src.cues[path] = PackedStringArray(resource.cues.keys()) if resource != null else []
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	for path in _files(MAP_DIR, ["txt"]):
		src.maps[path] = MapData.parse(FileAccess.get_file_as_string(path), legend, path)
	var map_regex := RegEx.create_from_string('(?m)^map_path\\s*=\\s*"([^"]+)"')
	for key: String in SceneRegistry.SCENES:
		var found := map_regex.search(FileAccess.get_file_as_string(SceneRegistry.path(key)))
		if found != null:
			src.scene_maps[key] = found.get_string(1)
	src.quests = ContentDB.quests()
	return src


## All rules over the real project.
static func validate_project() -> PackedStringArray:
	var src := load_project()
	var problems: PackedStringArray = []
	problems.append_array(door_problems(src))
	problems.append_array(cue_problems(src))
	problems.append_array(quest_problems(src))
	problems.append_array(flag_problems(src))
	problems.append_array(facet_problems(src))
	problems.append_array(duplicate_problems(src))
	problems.append_array(effect_problems(src))
	return problems


# --- Doors and travel ---------------------------------------------------------------------


## Doors, rifts and `SceneTravel.go(...)` calls: the target is a registered scene (or an alias
## of one) and, if a spawn is named, the target's map has the marker "spawn_<name>".
static func door_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	for map_path: String in src.maps:
		var data: MapData = src.maps[map_path]
		for p: Dictionary in data.placements:
			if not str(p["prop"]) in TRAVEL_PROPS:
				continue
			var params: Dictionary = p["params"]
			var where := "%s:%s" % [map_path, _cell_text(p["cell"])]
			problems.append_array(
				_travel_problems(
					src, where, str(params.get("target", "")), str(params.get("spawn", ""))
				)
			)
	for code_path: String in src.code:
		for m in _travel_call_regex.search_all(src.code[code_path]):
			var where := "%s:%d" % [code_path, _line_of(src.code[code_path], m.get_start())]
			problems.append_array(_travel_problems(src, where, m.get_string(1), m.get_string(2)))
	return problems


static func _travel_problems(
	src: Sources, where: String, target: String, spawn: String
) -> PackedStringArray:
	var key := SceneRegistry.resolve(target)
	if not SceneRegistry.has(key):
		return ["%s: travel target '%s' is not a registered scene" % [where, target]]
	if spawn.is_empty():
		return []
	if not src.scene_maps.has(key):
		return ["%s: scene '%s' has no map to hold the spawn '%s'" % [where, key, spawn]]
	var map_path: String = src.scene_maps[key]
	var data: MapData = src.maps.get(map_path)
	if data == null:
		return ["%s: map %s of scene '%s' is unknown" % [where, map_path, key]]
	if data.find_marker("spawn_" + spawn).is_empty():
		return ["%s: %s has no marker spawn_%s" % [where, map_path, spawn]]
	return []


# --- Cues ---------------------------------------------------------------------------------


## Map props with a "cue" and script calls `Talk.present(...)` / `cut.say(...)` name a cue that
## their dialogue file has.
static func cue_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	for map_path: String in src.maps:
		var data: MapData = src.maps[map_path]
		for p: Dictionary in data.placements:
			var params: Dictionary = p["params"]
			if not params.has("cue"):
				continue
			var fallback: String = PROP_DIALOGUES.get(str(p["prop"]), TAL_DIALOGUE)
			var where := "%s:%s" % [map_path, _cell_text(p["cell"])]
			problems.append_array(
				_cue_problems(src, where, str(params.get("dialogue", fallback)), str(params["cue"]))
			)
	for code_path: String in src.code:
		var text: String = src.code[code_path]
		var consts := _consts(text)
		for m in _cue_call_regex.search_all(text):
			var path := _value(m.get_string(1).trim_suffix(".resource_path"), consts)
			var cue := _value(m.get_string(2), consts)
			if path.is_empty() or cue.is_empty():
				continue
			var where := "%s:%d" % [code_path, _line_of(text, m.get_start())]
			problems.append_array(_cue_problems(src, where, path, cue))
	return problems


static func _cue_problems(
	src: Sources, where: String, dialogue_path: String, cue: String
) -> PackedStringArray:
	if not src.cues.has(dialogue_path):
		return ["%s: dialogue %s is unknown" % [where, dialogue_path]]
	if not cue in (src.cues[dialogue_path] as PackedStringArray):
		return ["%s: cue '%s' is missing in %s" % [where, cue, dialogue_path]]
	return []


# --- Quests -------------------------------------------------------------------------------


## Every quest is started by something and every stage after the first has a trigger: a
## literal `advance_quest("quest", "stage")` in a script or dialogue, or a world action in a
## map. A stage nothing advances to is a quest that can never get there.
static func quest_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	var started := {}
	var advanced := {}
	var texts: Array[Dictionary] = [src.code, src.dialogues]
	for texts_of_kind in texts:
		for path: String in texts_of_kind:
			var text: String = texts_of_kind[path]
			var consts := _consts(text)
			for m in _start_regex.search_all(text):
				started[_value(m.get_string(1), consts)] = true
			for m in _advance_regex.search_all(text):
				advanced["%s/%s" % [_value(m.get_string(1), consts), _value(m.get_string(2), consts)]] = true
	for map_path: String in src.maps:
		for p: Dictionary in (src.maps[map_path] as MapData).placements:
			for action: Variant in (p["params"] as Dictionary).get("actions", []):
				if not action is Dictionary or not (action as Dictionary).has("quest"):
					continue
				var data: Dictionary = action
				if bool(data.get("start", false)):
					started[str(data["quest"])] = true
				if data.has("stage"):
					advanced["%s/%s" % [data["quest"], data["stage"]]] = true
	for q in src.quests:
		if not started.has(q.id):
			problems.append("%s: nothing starts the quest" % q.id)
		for s in q.stages:
			if s != null and s != q.first_stage() and not advanced.has("%s/%s" % [q.id, s.id]):
				problems.append("%s: stage '%s' has no trigger" % [q.id, s.id])
	return problems


# --- Flags --------------------------------------------------------------------------------


## Flags read by content are set somewhere, and flags set by content are read somewhere.
## Setting counts literal calls, map params ("flag", "start_flag", world actions) and the
## marks `Beat.mark` and `Chapter.mark`; reading counts `has_flag`, `Beat.reached`,
## `Chapter.reached`, map conditions ("if", "unless", "sprite_when"), the "flag" param of
## one-shot props and any other literal use in a script.
static func flag_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	var sets := {}
	var reads := {}
	# literal uses of a flag in scripts, and how many of them are plain set or read calls
	var mentions := {}
	var set_mentions := {}
	var read_mentions := {}
	var texts: Array[Dictionary] = [src.code, src.dialogues]
	for texts_of_kind in texts:
		for path: String in texts_of_kind:
			var text: String = texts_of_kind[path]
			var consts := _consts(text)
			for m in _flag_call_regex.search_all(text):
				# every flag named in the arguments: a literal, a constant, both sides of an `if`
				for token in _token_regex.search_all(m.get_string(2)):
					var flag := _value(token.get_string(), consts)
					if not GameState.is_flag_id(flag):
						continue
					var literal := token.get_string().begins_with('"')
					if m.get_string(1) == "has_flag":
						reads[flag] = path
						if literal:
							_count(read_mentions, flag)
					else:
						sets[flag] = path
						if literal:
							_count(set_mentions, flag)
			# a prop made in code takes the flag as a param: it sets it and guards itself with it
			for m in _flag_param_regex.search_all(text):
				var param := _value(m.get_string(1), consts)
				if GameState.is_flag_id(param):
					sets[param] = path
					reads[param] = path
			for m in _mark_regex.search_all(text):
				var mark := _value(m.get_string(3), consts)
				if not mark.is_empty():
					(sets if m.get_string(2) == "mark" else reads)[_mark_flag(m.get_string(1), mark)] = path
			for m in _flags_dict_regex.search_all(text):
				reads[m.get_string(1)] = path
				_count(read_mentions, m.get_string(1))
			if texts_of_kind == src.code:
				for line in text.split("\n"):
					if line.begins_with("const "):
						continue
					for m in _literal_flag_regex.search_all(line):
						_count(mentions, m.get_string(1))
	for map_path: String in src.maps:
		for p: Dictionary in (src.maps[map_path] as MapData).placements:
			var params: Dictionary = p["params"]
			for key: String in ["if", "unless"]:
				var value: Variant = params.get(key, [])
				for flag: Variant in [value] if value is String else value:
					reads[str(flag)] = map_path
			for flag: Variant in params.get("sprite_when", {}):
				reads[str(flag)] = map_path
			if params.has("flag"):
				sets[str(params["flag"])] = map_path
				reads[str(params["flag"])] = map_path
			if params.has("start_flag"):
				sets[str(params["start_flag"])] = map_path
			for action: Variant in params.get("actions", []):
				if action is Dictionary and (action as Dictionary).has("flag"):
					sets[str((action as Dictionary)["flag"])] = map_path
	for flag: String in reads:
		# another literal in a script may set it through a variable (data-driven setters)
		if not sets.has(flag) and int(mentions.get(flag, 0)) <= int(read_mentions.get(flag, 0)):
			problems.append("%s: reads flag '%s', nothing sets it" % [reads[flag], flag])
	for flag: String in sets:
		if reads.has(flag) or WRITE_ONLY_FLAGS.has(flag) or _write_only_prefix(flag):
			continue
		if int(mentions.get(flag, 0)) > int(set_mentions.get(flag, 0)):
			continue
		problems.append("%s: sets flag '%s', nothing reads it" % [sets[flag], flag])
	return problems


## Facets named by literal calls: one that is set needs a reader and one that is read needs a
## setter. A facet nobody reads changes nothing the player can see; one nobody sets is dead code.
static func facet_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	var sets := {}
	var reads := {}
	var texts: Array[Dictionary] = [src.code, src.dialogues]
	for texts_of_kind in texts:
		for path: String in texts_of_kind:
			for m in _facet_regex.search_all(texts_of_kind[path]):
				(sets if m.get_string(1) == "set_facet" else reads)[m.get_string(2)] = path
	for facet: String in reads:
		if not sets.has(facet):
			problems.append("%s: reads facet '%s', nothing sets it" % [reads[facet], facet])
	for facet: String in sets:
		if not reads.has(facet):
			problems.append("%s: sets facet '%s', nothing reads it" % [sets[facet], facet])
	return problems


## The flag a `Beat` or `Chapter` mark stands for.
static func _mark_flag(kind: String, id: String) -> String:
	return (Chapter.PREFIX if kind == "Chapter" else "beat.") + id


static func _write_only_prefix(flag: String) -> bool:
	for prefix in WRITE_ONLY_FLAG_PREFIXES:
		if flag.begins_with(prefix):
			return true
	return false


# --- Duplicates ---------------------------------------------------------------------------


## A spawn marker twice in one map (the player arrives at the first) and a beat or chapter
## marked at two places (the log would show whichever comes first).
static func duplicate_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	for map_path: String in src.maps:
		var seen := {}
		for p: Dictionary in (src.maps[map_path] as MapData).placements:
			var marker := str(p["marker"])
			if not marker.begins_with("spawn_") and marker != "player_spawn":
				continue
			if seen.has(marker):
				problems.append(
					(
						"%s:%s: marker '%s' twice, first at %s"
						% [map_path, _cell_text(p["cell"]), marker, seen[marker]]
					)
				)
			else:
				seen[marker] = _cell_text(p["cell"])
	var beats := {}
	for code_path: String in src.code:
		var text: String = src.code[code_path]
		var consts := _consts(text)
		for m in _mark_regex.search_all(text):
			if m.get_string(2) != "mark":
				continue
			var flag := _mark_flag(m.get_string(1), _value(m.get_string(3), consts))
			var where := "%s:%d" % [code_path, _line_of(text, m.get_start())]
			if beats.has(flag):
				problems.append("%s: '%s' is also marked at %s" % [where, flag, beats[flag]])
			else:
				beats[flag] = where
	return problems


# --- Effects ------------------------------------------------------------------------------


## A script that defines a flash (a function or variable named flash, flicker, strobe or
## lightning) reads "display.reduce_flashing"; one that defines its own shake reads
## "display.screen_shake". Calls into such a script are fine, the check lives where the effect is.
static func effect_problems(src: Sources) -> PackedStringArray:
	var problems: PackedStringArray = []
	for path: String in src.code:
		var text: String = src.code[path]
		if _flash_def_regex.search(text) != null and not text.contains("display.reduce_flashing"):
			problems.append("%s: makes a flash without reading display.reduce_flashing" % path)
		if _shake_def_regex.search(text) != null and not text.contains("display.screen_shake"):
			problems.append("%s: makes a shake without reading display.screen_shake" % path)
	return problems


# --- Helpers ------------------------------------------------------------------------------


static func _files(dir_path: String, extensions: PackedStringArray) -> PackedStringArray:
	var found: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	for file_name in dir.get_files():
		if file_name.get_extension() in extensions:
			found.append(dir_path.path_join(file_name))
	for sub in dir.get_directories():
		found.append_array(_files(dir_path.path_join(sub), extensions))
	found.sort()
	return found


## `const NAME := "text"` (or preload("path")) at the start of a line: name -> text.
static func _consts(text: String) -> Dictionary:
	var consts := {}
	for m in _const_regex.search_all(text):
		consts[m.get_string(1)] = m.get_string(2)
	return consts


## A call argument as text: a string literal, or a constant of the same file ("" if it is a
## variable the lint cannot see).
static func _value(arg: String, consts: Dictionary) -> String:
	if arg.begins_with('"'):
		return arg.trim_prefix('"').trim_suffix('"')
	return str(consts.get(arg, ""))


static func _count(counts: Dictionary, key: String) -> void:
	counts[key] = int(counts.get(key, 0)) + 1


static func _line_of(text: String, offset: int) -> int:
	return text.substr(0, offset).count("\n") + 1


static func _cell_text(cell: Variant) -> String:
	var c: Vector2i = cell
	return "%d,%d" % [c.x, c.y]
