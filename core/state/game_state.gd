class_name GameState
extends RefCounted
## The complete game state as plain typed data. Only the WorldState autoload writes to it;
## everything else reads through WorldState. to_dict() and from_dict() define the
## "world_state" part of a save file (docs/SAVE_FORMAT.md). from_dict() never trusts its
## input: wrong types, out-of-range numbers and unknown IDs are dropped and reported.
## Nothing in a save file is ever executed or loaded as a resource.

enum UiMode { ELYSIA, REAL }

const NPCS: PackedStringArray = ["mira", "tess", "orin", "lio"]
const FACETS: PackedStringArray = [
	"perception", "courage", "connection", "care", "integrity", "boundaries", "trust", "aliveness"
]
const MAX_NAME_LENGTH := 24
const MAX_PRESET := 7
const MAX_ENTRIES := 4096
const MAX_AMOUNT := 1_000_000_000
## Times of day of the Real world, in the order resting passes them (DayLight).
const DAY_PRESETS: PackedStringArray = ["regentag", "abend", "nacht"]

static var _flag_regex := RegEx.create_from_string("^[a-z][a-z0-9_]*(\\.[a-z0-9_]+)+$")
static var _id_regex := RegEx.create_from_string("^[a-z][a-z0-9_]*$")

var flags: Dictionary[String, bool] = {}
var quests: Dictionary[String, QuestProgress] = {}
var relationships: Dictionary[String, Relationship] = {}
var facets: Dictionary[String, bool] = {}
var house := House.new()
var inventory: Dictionary[String, int] = {}
var discovered: PackedStringArray = []
var ui_mode := UiMode.ELYSIA
## Time of day in the Real world ("" until a scene with daylight set it).
var day_preset := ""
var elysia := ElysiaProgression.new()
var player := PlayerInfo.new()
var playtime_seconds := 0.0


## Progress of one started quest. `history` lists visited stages, the current one last.
class QuestProgress:
	extends RefCounted
	var stage := ""
	var history: PackedStringArray = []
	var objectives_done: PackedStringArray = []


## Internal relationship state. Never shown as a number (Game Bible §23).
class Relationship:
	extends RefCounted
	enum State { STRANGER, CAUTIOUS, FAMILIAR, CLOSE, STRAINED }
	var state := State.STRANGER
	var memories: PackedStringArray = []


class House:
	extends RefCounted
	var fire_lit := false
	## Slot ID -> curiosity item ID.
	var curiosity_slots: Dictionary[String, String] = {}
	## The cat's name once the player gave it one (Game Bible §28); "" = unnamed.
	var cat_name := ""


## Elysia's cosmetic reward layer. The level is derived from XP.
class ElysiaProgression:
	extends RefCounted
	var xp := 0
	var gold := 0

	func level() -> int:
		return GameState.level_for_xp(xp)


class PlayerInfo:
	extends RefCounted
	var name := ""
	var preset := 0
	## Scene key (SceneRegistry) and position of the last save point; empty map = unknown.
	var map := ""
	var position := Vector2.ZERO


static func is_flag_id(id: String) -> bool:
	return _flag_regex.search(id) != null


static func is_id(id: String) -> bool:
	return _id_regex.search(id) != null


## 1 + floor(sqrt(xp / 15)): fast early levels, 12500 XP is level 29 (Elysia exaggerates).
static func level_for_xp(xp: int) -> int:
	return 1 + int(sqrt(maxf(xp, 0) / 15.0))


static func relationship_name(state: Relationship.State) -> String:
	return str(Relationship.State.keys()[state]).to_lower()


## Relationship state for a lower-case name, or -1.
static func relationship_from_name(state_name: String) -> int:
	return Relationship.State.keys().find(state_name.to_upper())


func to_dict() -> Dictionary:
	var quest_data := {}
	for id in quests:
		var q := quests[id]
		quest_data[id] = {
			"stage": q.stage,
			"history": Array(q.history),
			"objectives_done": Array(q.objectives_done),
		}
	var rel_data := {}
	for npc in relationships:
		var r := relationships[npc]
		rel_data[npc] = {"state": relationship_name(r.state), "memories": Array(r.memories)}
	return {
		"flags": flags.duplicate(),
		"quests": quest_data,
		"relationships": rel_data,
		"facets": facets.duplicate(),
		"house":
		{
			"fire_lit": house.fire_lit,
			"curiosity_slots": house.curiosity_slots.duplicate(),
			"cat_name": house.cat_name,
		},
		"inventory": inventory.duplicate(),
		"discovered": Array(discovered),
		"ui_mode": str(UiMode.keys()[ui_mode]),
		"day_preset": day_preset,
		"elysia": {"xp": elysia.xp, "gold": elysia.gold},
		"player":
		{
			"name": player.name,
			"preset": player.preset,
			"map": player.map,
			"x": player.position.x,
			"y": player.position.y,
		},
		"playtime_seconds": playtime_seconds,
	}


## Builds a state from untrusted data. Everything dropped is described in `report`.
static func from_dict(data: Dictionary, report: PackedStringArray) -> GameState:
	var s := GameState.new()
	var r := _Reader.new(report)
	var flag_data := r.dict(data, "flags")
	for id: Variant in flag_data:
		if id is String and is_flag_id(id) and flag_data[id] is bool:
			s.flags[id] = flag_data[id]
		else:
			r.drop("flag", id)
	_read_quests(s, r.dict(data, "quests"), r)
	_read_relationships(s, r.dict(data, "relationships"), r)
	var facet_data := r.dict(data, "facets")
	for id: Variant in facet_data:
		if id is String and id in FACETS and facet_data[id] is bool:
			s.facets[id] = facet_data[id]
		else:
			r.drop("facet", id)
	var house_data := r.dict(data, "house")
	s.house.fire_lit = r.boolean(house_data, "fire_lit", false)
	var slots := r.dict(house_data, "curiosity_slots")
	for slot: Variant in slots:
		var item: Variant = slots[slot]
		if slot is String and is_id(slot) and item is String and ContentDB.has_item(str(item)):
			s.house.curiosity_slots[slot] = item
		else:
			r.drop("curiosity slot", slot)
	s.house.cat_name = r.string(house_data, "cat_name", "").strip_edges().left(MAX_NAME_LENGTH)
	var inv := r.dict(data, "inventory")
	for item: Variant in inv:
		var def := ContentDB.item(str(item)) if item is String else null
		var count := r.integer(inv, item, 0, 1, def.max_stack if def != null else 0)
		if def != null and count > 0:
			s.inventory[def.id] = count
		else:
			r.drop("item", item)
	for place: Variant in r.array(data, "discovered"):
		if place is String and is_id(place) and not place in s.discovered:
			s.discovered.append(place)
		else:
			r.drop("location", place)
	var mode := UiMode.keys().find(r.string(data, "ui_mode", "ELYSIA"))
	if mode < 0:
		r.drop("ui_mode", data.get("ui_mode"))
	s.ui_mode = UiMode.ELYSIA if mode < 0 else mode as UiMode
	s.day_preset = r.string(data, "day_preset", "")
	if not s.day_preset.is_empty() and not s.day_preset in DAY_PRESETS:
		r.drop("day_preset", s.day_preset)
		s.day_preset = ""
	var ely := r.dict(data, "elysia")
	s.elysia.xp = r.integer(ely, "xp", 0, 0, MAX_AMOUNT)
	s.elysia.gold = r.integer(ely, "gold", 0, 0, MAX_AMOUNT)
	var p := r.dict(data, "player")
	s.player.name = r.string(p, "name", "").left(MAX_NAME_LENGTH)
	s.player.preset = r.integer(p, "preset", 0, 0, MAX_PRESET)
	s.player.map = r.string(p, "map", "")
	if not s.player.map.is_empty() and not is_id(s.player.map):
		r.drop("map", s.player.map)
		s.player.map = ""
	s.player.position = Vector2(r.number(p, "x", 0.0), r.number(p, "y", 0.0))
	s.playtime_seconds = r.number(data, "playtime_seconds", 0.0, 0.0)
	return s


static func _read_quests(s: GameState, quest_data: Dictionary, r: _Reader) -> void:
	for id: Variant in quest_data:
		var def := ContentDB.quest(str(id)) if id is String else null
		if def == null or not quest_data[id] is Dictionary:
			r.drop("quest", id)
			continue
		var entry: Dictionary = quest_data[id]
		var q := QuestProgress.new()
		q.stage = r.string(entry, "stage", "")
		if not def.has_stage(q.stage):
			r.drop("quest stage", "%s:%s" % [id, q.stage])
			continue
		for st: Variant in r.array(entry, "history"):
			if st is String and def.has_stage(st):
				q.history.append(st)
		if q.history.is_empty() or q.history[-1] != q.stage:
			q.history.append(q.stage)
		var known := {}
		for st in def.stages:
			for o in st.objectives:
				known[o] = true
		for o: Variant in r.array(entry, "objectives_done"):
			if o is String and known.has(o) and not o in q.objectives_done:
				q.objectives_done.append(o)
		s.quests[def.id] = q


static func _read_relationships(s: GameState, rel_data: Dictionary, r: _Reader) -> void:
	for npc: Variant in rel_data:
		if not (npc is String and npc in NPCS and rel_data[npc] is Dictionary):
			r.drop("relationship", npc)
			continue
		var entry: Dictionary = rel_data[npc]
		var rel := Relationship.new()
		var state := relationship_from_name(r.string(entry, "state", "stranger"))
		if state < 0:
			r.drop("relationship state", npc)
			state = Relationship.State.STRANGER
		rel.state = state as Relationship.State
		for m: Variant in r.array(entry, "memories"):
			if m is String and is_id(m) and not m in rel.memories:
				rel.memories.append(m)
		s.relationships[str(npc)] = rel


## Typed, defensive access to JSON data. Numbers in JSON are floats; integers are checked
## to be whole and in range. Every fallback is reported.
class _Reader:
	extends RefCounted
	var report: PackedStringArray

	func _init(target: PackedStringArray) -> void:
		report = target

	func drop(kind: String, value: Variant) -> void:
		report.append("dropped %s %s" % [kind, str(value).left(64)])

	func dict(data: Dictionary, key: String) -> Dictionary:
		var value: Variant = data.get(key)
		if value is Dictionary and (value as Dictionary).size() <= MAX_ENTRIES:
			return value
		if value != null:
			drop(key, "(not an object or too large)")
		return {}

	func array(data: Dictionary, key: String) -> Array:
		var value: Variant = data.get(key)
		if value is Array and (value as Array).size() <= MAX_ENTRIES:
			return value
		if value != null:
			drop(key, "(not a list or too large)")
		return []

	func string(data: Dictionary, key: String, fallback: String) -> String:
		var value: Variant = data.get(key)
		if value is String:
			return value
		if value != null:
			drop(key, value)
		return fallback

	func boolean(data: Dictionary, key: String, fallback: bool) -> bool:
		var value: Variant = data.get(key)
		if value is bool:
			return value
		if value != null:
			drop(key, value)
		return fallback

	func number(data: Dictionary, key: String, fallback: float, low := -1.0e9) -> float:
		var value: Variant = data.get(key)
		if value is float or value is int:
			var f := float(value)
			if is_finite(f) and f >= low and f <= 1.0e9:
				return f
		if value != null:
			drop(key, value)
		return fallback

	func integer(data: Dictionary, key: Variant, fallback: int, low: int, high: int) -> int:
		var value: Variant = data.get(key)
		if value is float or value is int:
			var f := float(value)
			if is_finite(f) and f == floorf(f) and f >= low and f <= high:
				return int(f)
		if value != null:
			drop(str(key), value)
		return fallback
