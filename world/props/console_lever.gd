class_name ConsoleLever
extends Decor
## One lever of the keeper's console (Act V, docs/akt5/REGIONSBRIEFE.md, O4 and O19). It carries a
## number and a form (the picture, never only a colour) and stands up or down. A live lever answers
## the player's use with `pulled(number)`; a lever that is not live is still (the map gives it a
## cloth and a cue to look at). What a pull means is the hall's scene's business: here it is a trial
## (G3), later a load (G4). Params: {"n": <1..12>, "live": <bool>, "sprite_up": "<sprite>",
## "sprite_down": "<sprite>", "radius": <px>}; the other Decor params work as usual (a "cue" makes
## a still lever look-at-able).

signal pulled(number: int)

var number := 0
var live := false
var down := false
var _up: Texture2D
var _down: Texture2D


func apply_params(params: Dictionary) -> void:
	number = int(params.get("n", 0))
	live = bool(params.get("live", false))
	var drawn := params.duplicate()
	drawn["sprite"] = str(params.get("sprite_up", ""))
	super(drawn)
	if sprite == null:
		return
	_up = sprite.texture
	var down_entry := PropCatalog.entry(str(params.get("sprite_down", "")))
	if not down_entry.is_empty():
		_down = PropCatalog.texture_for(down_entry, global_position)
	if live:
		var area := Talk.add_area(self, "INTERACT_PULL", float(params.get("radius", 16.0)))
		area.interacted.connect(func(_actor: Node) -> void: pulled.emit(number))


## Puts the lever down or up (the picture changes); `with_sound` plays the click from the lever.
func set_down(value: bool, with_sound := false) -> void:
	down = value
	if sprite != null and _up != null and _down != null:
		sprite.texture = _down if value else _up
	if with_sound:
		SoundBank.play_at(get_parent(), "lever", global_position, -4.0)
