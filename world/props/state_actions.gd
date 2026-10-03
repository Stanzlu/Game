class_name StateActions
extends RefCounted
## World-state changes that map data may trigger (levers, trigger zones). Only these keys
## exist; nothing in map data is executed:
##   {"flag": "area.name"}  {"quest": "<id>", "stage": "<stage>", "start": true}
##   {"item": "<id>", "count": 1}  {"discover": "<location>"}  {"xp": 250}  {"gold": 100}
## "start" starts the quest first if needed, then tries to move it to "stage".

const KEYS: PackedStringArray = ["flag", "quest", "item", "discover", "xp", "gold"]


static func run(actions: Array, source: String) -> void:
	for problem in validate(actions):
		Log.error(
			Log.Category.CONTENT, "invalid world action", {"source": source, "problem": problem}
		)
		return
	for action: Dictionary in actions:
		if action.has("flag"):
			WorldState.set_flag(str(action["flag"]))
		elif action.has("quest"):
			var quest_id := str(action["quest"])
			if bool(action.get("start", false)):
				WorldState.start_quest(quest_id)
			if action.has("stage"):
				WorldState.advance_quest(quest_id, str(action["stage"]))
		elif action.has("item"):
			WorldState.add_item(str(action["item"]), int(action.get("count", 1)))
		elif action.has("discover"):
			WorldState.discover(str(action["discover"]))
		elif action.has("xp"):
			WorldState.add_xp(int(action["xp"]))
		elif action.has("gold"):
			WorldState.add_gold(int(action["gold"]))


## Problems with an action list (empty if fine). Used at runtime and by the content tests.
static func validate(actions: Variant) -> PackedStringArray:
	var problems: PackedStringArray = []
	if not actions is Array:
		return ["actions must be a list"]
	for action: Variant in actions:
		if not action is Dictionary:
			problems.append("action must be an object")
			continue
		var data: Dictionary = action
		var kind := ""
		for key in KEYS:
			if data.has(key):
				kind = key
		match kind:
			"flag":
				if not GameState.is_flag_id(str(data["flag"])):
					problems.append("flag '%s' needs a namespace" % data["flag"])
			"quest":
				var q := ContentDB.quest(str(data["quest"]))
				if q == null:
					problems.append("unknown quest '%s'" % data["quest"])
				elif data.has("stage") and not q.has_stage(str(data["stage"])):
					problems.append("quest '%s' has no stage '%s'" % [data["quest"], data["stage"]])
			"item":
				if not ContentDB.has_item(str(data["item"])):
					problems.append("unknown item '%s'" % data["item"])
			"discover":
				if not GameState.is_id(str(data["discover"])):
					problems.append("invalid location '%s'" % data["discover"])
			"xp", "gold":
				var amount: Variant = data[kind]
				if not (amount is int or amount is float) or float(amount) <= 0.0:
					problems.append("%s needs a positive amount" % kind)
			_:
				problems.append("unknown action %s" % JSON.stringify(data))
	return problems
