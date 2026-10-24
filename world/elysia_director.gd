class_name ElysiaDirector
extends Node
## Elysia's slow turn into a loop (Game Bible §35, docs/PRODUKTIONSPLAN.md 4.6): one clock and
## one set of stages for every Elysia scene, so the repetition does not wait for the garden. A
## scene adds it with `ElysiaDirector.attach(self)` and keeps only what is its own: what the
## repetition looks like on its map.
##
## Stages are flags other scenes can read. Dialogue picks its word-for-word variant by
## `elysia.loops` alone (normal, then loop 1); the music stages are not text gates:
##   elysia.loops_1   the music loop is half as long    (the market was entered, or 20 minutes)
##   elysia.loops_2   a quarter as long                 (the stone is taken, or 40 minutes)
##   elysia.loops     the sentences repeat word for word (the toast at the feast, or 60 minutes)
## The first two come from AudioDirectorService.ELYSIA_STAGES, which also picks the music file.
## The toast (`elysia.feast_toast`, hero quest stage "repeat", ADR-062) starts the sentences in
## whatever Elysia scene the hero is in; the times are only for someone who dawdles.
## If nobody follows the child, the rift opens by the clock a good while after the sentences start.

## Emitted when the clock, not the player, opened the rift: the scene with the rift announces it.
signal rift_opened

const LOOPS_FLAG := "elysia.loops"
const FEAST_FLAG := "elysia.feast_toast"
const RIFT_FLAG := "elysia.rift_open"
## Latest start of the sentences, and latest opening of the rift after they started (seconds of
## total play time). Act I runs 30 to 45 minutes and the child's trail comes after the feast: the
## clock only catches someone who does not play on, so it waits an hour and then a quarter hour.
const LOOPS_AFTER := 3600.0
const RIFT_AFTER_LOOPS := 900.0

var _loops_time := -1.0


## The director of `scene` (added as its child), or the one it already has.
static func attach(scene: Node) -> ElysiaDirector:
	for child in scene.get_children():
		if child is ElysiaDirector:
			return child
	var director := ElysiaDirector.new()
	director.name = "ElysiaDirector"
	scene.add_child(director)
	return director


## The stage flag of music stage `index` (1 and 2).
static func stage_flag(index: int) -> String:
	return ["", "elysia.loops_1", "elysia.loops_2"][index]


## The highest stage earned: 0 (none), 1 and 2 (the music shrinks), 3 (the sentences repeat).
static func stage() -> int:
	if WorldState.has_flag(LOOPS_FLAG):
		return 3
	for index in range(AudioDirectorService.ELYSIA_STAGES.size() - 1, 0, -1):
		if WorldState.has_flag(stage_flag(index)):
			return index
	return 0


func _ready() -> void:
	WorldState.flag_changed.connect(_on_flag_changed)
	if WorldState.has_flag(FEAST_FLAG):
		# a save from the feast: the sentences begin if nothing started them yet
		begin_loops()
	if WorldState.has_flag(LOOPS_FLAG):
		# the start of the loops is not saved: after a load the wait starts again
		_loops_time = WorldState.state.playtime_seconds
	_update_stages()


## The sentences start repeating: the hero raised the glass at the feast.
func begin_loops() -> void:
	if not WorldState.has_flag(LOOPS_FLAG):
		WorldState.set_flag(LOOPS_FLAG)
		Beat.mark("irritation")


func _process(_delta: float) -> void:
	var t := WorldState.state.playtime_seconds
	_update_stages()
	if not WorldState.has_flag(LOOPS_FLAG) and t > LOOPS_AFTER:
		begin_loops()
	# never later than the latest possible start of the loops plus the wait
	if (
		_loops_time >= 0.0
		and not WorldState.has_flag(RIFT_FLAG)
		and (t - _loops_time > RIFT_AFTER_LOOPS or t > LOOPS_AFTER + RIFT_AFTER_LOOPS)
	):
		Log.info(Log.Category.WORLD_STATE, "rift opens without the child")
		WorldState.set_flag(RIFT_FLAG)
		rift_opened.emit()


## Sets the music stage flags that are earned by now (by flag or by play time).
func _update_stages() -> void:
	var wanted := AudioDirectorService.elysia_stage_for(
		WorldState.state.playtime_seconds, WorldState.has_flag
	)
	for index in range(1, wanted + 1):
		if not WorldState.has_flag(stage_flag(index)):
			WorldState.set_flag(stage_flag(index))


func _on_flag_changed(id: String, value: bool) -> void:
	if id == FEAST_FLAG and value:
		begin_loops()
	elif id == LOOPS_FLAG and value:
		_loops_time = WorldState.state.playtime_seconds
