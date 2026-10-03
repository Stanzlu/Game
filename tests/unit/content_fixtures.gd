extends RefCounted
## Small, fixed content for state, save and validator tests (independent of real content).


static func stage(id: String, next: PackedStringArray = [], outcome := "") -> QuestStageDef:
	var s := QuestStageDef.new()
	s.id = id
	s.next = next
	s.outcome = outcome
	return s


## side_test: start -> (middle with objectives a, b) -> done | missed
static func quest() -> QuestDef:
	var q := QuestDef.new()
	q.id = "side_test"
	var middle := stage("middle", ["done", "missed"])
	middle.objectives = ["obj_a", "obj_b"]
	q.stages = [stage("start", ["middle"]), middle, stage("done", [], "done")]
	q.stages.append(stage("missed", [], "missed"))
	return q


static func item(id: String, kind := ItemDef.Kind.ITEM, max_stack := 9) -> ItemDef:
	var i := ItemDef.new()
	i.id = id
	i.kind = kind
	i.max_stack = max_stack
	return i


static func use() -> void:
	ContentDB.use_definitions(
		[quest()],
		[
			item("item_stone"),
			item("item_seed", ItemDef.Kind.ITEM, 3),
			item("curiosity_spoon", ItemDef.Kind.CURIOSITY, 1)
		]
	)
