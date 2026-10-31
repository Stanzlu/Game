class_name NachtwaldScene
extends LookScene
## Act III, W5: a night in the wood (docs/akt3/REGIONSBRIEFE.md, ADR-070 O10). A small lantern
## stands on the ground of a glade and burns. Whoever walks up to it finds it where it stood;
## whoever sits down beside it hears a hum, once, very quietly and from no direction, and it
## stops. That is the whole picture: no child in it, no word of one, no explanation, no counter,
## no fragment, nothing on a clock (the sitting is the waiting). Whoever looks away or walks on
## loses nothing. Everything on the map lives in props with `if`/`unless`/`sprite_when` and in
## the dialogue; this script only asks once per sitting (cue `wait`), plays the hum when the
## cue has said that it comes, and marks the beats.
##
## The night is this scene's own look (the palette of the prototype `look_wald`, set in the
## `.tscn`): it carries no `day_preset`, because the DayLight would write "nacht" into the stored
## time of day and the forest and the valley after it would stay dark. There is no rain, no wind
## in the leaves, no fog and no music: the hum is the only sound there is, and no light either
## (Plan 7 puts the light off): the glow of the trees, the log and the lantern is baked into
## their pictures and does not flicker (Game Bible §50).

const DIALOGUE := "res://content/dialogue/akt3/nachtwald.dialogue"
## The hum, as quiet as it gets and still heard in a silent wood (dB on the SFX bus).
const HUM_DB := -8.0

var _asked := false


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	player.state_changed.connect(_on_player_state)
	Beat.mark("nachtwald_enter")


## Sitting down beside the lantern opens the cue once per sitting; standing up changes nothing.
func _on_player_state(state: Player.State) -> void:
	if state == Player.State.SIT:
		_ask.call_deferred()


func _ask() -> void:
	if _asked or player.state != Player.State.SIT:
		return
	_asked = true
	await Talk.present(self, DIALOGUE, "wait", player)
	_asked = false


## The cue sets `forest.waited` in the middle of its first run, just before the line that says it
## hums. Later sittings find it set: no change of the flag, so no second hum.
func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "forest.waited":
		AudioDirector.sfx("child_hum", HUM_DB, 1.0)
		Beat.mark("act3_waiting")
