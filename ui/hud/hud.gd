class_name Hud
extends CanvasLayer
## Heads-up display in two worlds (Game Bible §10, §11, §34).
## Elysia: level badge, a shining XP bar, gold that counts up while coins fly into it, a
## quest tracker with a bouncing marker, and loud reward popups (+XP, LEVEL UP with rays,
## sparkles and a flash, loot cards with icon, rarity colour and fanfare). Everything there
## is a little too much, on purpose. The Real world: nothing, except one quiet line with a
## small icon when something is picked up.
## The rift sequence removes the Elysia elements one by one (vanish_next()).
## In both worlds: the name of a place when entering it (Elysia: a golden banner, Real: a
## quiet line) and a small mark in the corner when the game saved.

const COIN := preload("res://assets/generated/ui/coin.png")
const SPARKLE := preload("res://assets/generated/ui/sparkle.png")
const RAYS := preload("res://assets/generated/ui/rays.png")
const QUEST_MARK := preload("res://assets/generated/ui/quest_mark.png")
const FANCY_TEXT := preload("res://ui/hud/fancy_text.gdshader")
const TITLE_FONT := preload("res://assets/fonts/jersey15/Jersey15-Regular.ttf")
const GOLD := Color(1, 0.84, 0.4)
const OUTLINE := Color(0.22, 0.08, 0.16)
const POPUP_GAP := 0.35
const COINS_PER_GAIN := 7
const COUNT_SECONDS := 1.0
## Elysia elements in the order they disappear at the rift.
const VANISH_ORDER: PackedStringArray = ["Quest", "Gold", "Xp", "Level"]

var elysia_root: Control
var real_root: Control
var _elements: Dictionary[String, Control] = {}
var _level_label: Label
var _xp_bar: XpBar
var _gold_label: Label
var _gold_icon: TextureRect
var _gold_shown := 0
var _gold_tween: Tween
var _quest_label: Label
var _quest_mark: TextureRect
var _popups: VBoxContainer
var _fx: Control
var _flash: ColorRect
var _quiet_row: HBoxContainer
var _quiet_icon: TextureRect
var _quiet: Label
var _quiet_tween: Tween
var _queue: Array[Callable] = []
var _busy := false
var _vanished: PackedStringArray = []
var _time := 0.0
var _area: Label
var _area_tween: Tween
var _saved: Label
var _saved_tween: Tween


func _ready() -> void:
	layer = 12
	_build_elysia()
	_build_real()
	_build_common()
	WorldState.progression_changed.connect(_on_progression)
	SaveSystem.saved.connect(func(_slot: String) -> void: _show_saved())
	WorldState.item_received.connect(_on_item)
	WorldState.quest_changed.connect(func(_q: String, _s: String) -> void: _refresh_quest())
	WorldState.ui_mode_changed.connect(func(_m: GameState.UiMode) -> void: refresh())
	WorldState.state_replaced.connect(refresh)
	refresh()


func is_elysia() -> bool:
	return WorldState.ui_mode() == GameState.UiMode.ELYSIA


## Shows the current state at once (scene start, loaded save, mode change).
func refresh() -> void:
	elysia_root.visible = is_elysia()
	real_root.visible = not is_elysia()
	var s := WorldState.state
	_level_label.text = tr("HUD_LEVEL") % s.elysia.level()
	_xp_bar.set_ratio(xp_ratio(s.elysia.xp), 0, true)
	if _gold_tween != null and _gold_tween.is_valid():
		_gold_tween.kill()
	_gold_shown = s.elysia.gold
	_gold_label.text = format_number(_gold_shown)
	_refresh_quest()


## Progress inside the current level, 0..1 (level = 1 + floor(sqrt(xp / 15))).
static func xp_ratio(xp: int) -> float:
	var level := 1 + floori(sqrt(xp / 15.0))
	var floor_xp := 15 * (level - 1) * (level - 1)
	var next_xp := 15 * level * level
	return clampf(float(xp - floor_xp) / float(maxi(next_xp - floor_xp, 1)), 0.0, 1.0)


## "4.200" with German thousands separators.
static func format_number(value: int) -> String:
	var digits := str(absi(value))
	var out := ""
	while digits.length() > 3:
		out = "." + digits.right(3) + out
		digits = digits.left(digits.length() - 3)
	return ("-" if value < 0 else "") + digits + out


func _refresh_quest() -> void:
	var quest := _active_quest()
	_quest_label.text = tr(ContentDB.quest(quest).title_key()) if not quest.is_empty() else ""
	_elements["Quest"].visible = not quest.is_empty() and not "Quest" in _vanished


func _active_quest() -> String:
	var newest := ""
	for quest_id: String in WorldState.state.quests:
		if WorldState.is_quest_active(quest_id) and ContentDB.has_quest(quest_id):
			newest = quest_id
	return newest


func _process(delta: float) -> void:
	_time += delta
	if _quest_mark != null and _quest_mark.is_visible_in_tree():
		# the marker hops by one pixel, a little faster than a heartbeat
		_quest_mark.position.y = 1.0 - float(int(_time * 3.0) % 2)


# --- Building ---------------------------------------------------------------------------


func _build_elysia() -> void:
	elysia_root = _full_rect("Elysia")
	add_child(elysia_root)
	UiSkin.attach(elysia_root)
	var corner := VBoxContainer.new()
	corner.position = Vector2(6, 5)
	corner.add_theme_constant_override(&"separation", 1)
	elysia_root.add_child(corner)
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override(&"separation", 3)
	corner.add_child(level_row)
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override(&"panel", _badge_style())
	level_row.add_child(badge)
	_level_label = _outlined_label(GOLD)
	badge.add_child(_level_label)
	_elements["Level"] = badge
	_xp_bar = XpBar.new()
	_xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_row.add_child(_xp_bar)
	_elements["Xp"] = _xp_bar
	var gold_row := HBoxContainer.new()
	gold_row.add_theme_constant_override(&"separation", 3)
	corner.add_child(gold_row)
	_gold_icon = TextureRect.new()
	_gold_icon.texture = COIN
	_gold_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_gold_icon.custom_minimum_size = Vector2(9, 9)
	_gold_icon.pivot_offset = Vector2(4.5, 4.5)
	gold_row.add_child(_gold_icon)
	_gold_label = _outlined_label(GOLD)
	gold_row.add_child(_gold_label)
	_elements["Gold"] = gold_row
	var quest_row := HBoxContainer.new()
	quest_row.add_theme_constant_override(&"separation", 5)
	quest_row.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	quest_row.alignment = BoxContainer.ALIGNMENT_END
	quest_row.offset_left = -260
	quest_row.offset_right = -8
	quest_row.offset_top = 5
	elysia_root.add_child(quest_row)
	var mark_holder := Control.new()
	mark_holder.custom_minimum_size = Vector2(6, 14)
	quest_row.add_child(mark_holder)
	_quest_mark = TextureRect.new()
	_quest_mark.texture = QUEST_MARK
	mark_holder.add_child(_quest_mark)
	_quest_label = _outlined_label(Color(1, 0.96, 0.82))
	quest_row.add_child(_quest_label)
	_elements["Quest"] = quest_row
	_popups = VBoxContainer.new()
	_popups.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_popups.offset_top = 40
	_popups.offset_left = -150
	_popups.offset_right = 150
	_popups.alignment = BoxContainer.ALIGNMENT_BEGIN
	_popups.add_theme_constant_override(&"separation", 2)
	_popups.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elysia_root.add_child(_popups)
	_fx = _full_rect("Fx")
	elysia_root.add_child(_fx)
	_flash = ColorRect.new()
	_flash.color = Color(1, 0.98, 0.9, 0.0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elysia_root.add_child(_flash)


func _build_real() -> void:
	real_root = _full_rect("Real")
	add_child(real_root)
	UiSkin.attach(real_root)
	_quiet_row = HBoxContainer.new()
	_quiet_row.add_theme_constant_override(&"separation", 4)
	_quiet_row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_quiet_row.offset_left = 10
	_quiet_row.offset_top = -26
	_quiet_row.offset_bottom = -8
	_quiet_row.modulate.a = 0.0
	real_root.add_child(_quiet_row)
	_quiet_icon = TextureRect.new()
	_quiet_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_quiet_icon.modulate = Color(0.8, 0.8, 0.8, 0.85)
	_quiet_row.add_child(_quiet_icon)
	_quiet = Label.new()
	_quiet.theme_type_variation = &"MutedLabel"
	_quiet_row.add_child(_quiet)


func _build_common() -> void:
	var common := _full_rect("Common")
	add_child(common)
	_area = Label.new()
	_area.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_area.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_area.offset_left = -200
	_area.offset_right = 200
	_area.offset_top = 52
	_area.modulate.a = 0.0
	common.add_child(_area)
	_saved = Label.new()
	_saved.theme_type_variation = &"HintLabel"
	_saved.text = tr("HUD_SAVED")
	_saved.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_saved.offset_left = -90
	_saved.offset_right = -8
	_saved.offset_top = -16
	_saved.offset_bottom = -6
	_saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_saved.modulate.a = 0.0
	common.add_child(_saved)


## Name of the place, when a scene starts: Elysia announces it in gold with a little
## sparkle; the Real world just says it, quietly, and lets it go.
func show_area(name_key: String) -> void:
	if _area_tween != null and _area_tween.is_valid():
		_area_tween.kill()
	_area.text = tr(name_key)
	_area.material = null
	for item: StringName in [&"font_color", &"font_outline_color"]:
		_area.remove_theme_color_override(item)
	_area.remove_theme_font_override(&"font")
	_area.remove_theme_font_size_override(&"font_size")
	_area_tween = _area.create_tween()
	if is_elysia():
		_area.theme_type_variation = &""
		_make_fancy(_area, 27)
		_area.offset_top = 40
		_area_tween.tween_property(_area, ^"modulate:a", 1.0, 0.25).set_delay(0.6)
		_area_tween.parallel().tween_property(_area, ^"offset_top", 52.0, 0.4).set_delay(0.6)
		_area_tween.tween_callback(
			func() -> void: _sparkle_burst(_area.get_global_rect().get_center(), 12)
		)
		_area_tween.tween_interval(2.2)
		_area_tween.tween_property(_area, ^"modulate:a", 0.0, 0.5)
	else:
		_area.theme_type_variation = &"MutedLabel"
		_area.add_theme_color_override(&"font_color", Color(0.86, 0.86, 0.84))
		_area.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.6))
		_area.add_theme_constant_override(&"outline_size", 2)
		# lower third, like a quiet film caption
		_area.offset_top = 292
		_area_tween.tween_property(_area, ^"modulate:a", 0.9, 1.4).set_delay(1.6)
		_area_tween.tween_interval(2.4)
		_area_tween.tween_property(_area, ^"modulate:a", 0.0, 2.0)


func _show_saved() -> void:
	if _saved_tween != null and _saved_tween.is_valid():
		_saved_tween.kill()
	_saved.add_theme_color_override(&"font_color", GOLD if is_elysia() else Color(0.7, 0.72, 0.72))
	_saved_tween = _saved.create_tween()
	_saved_tween.tween_property(_saved, ^"modulate:a", 1.0, 0.25)
	_saved_tween.tween_interval(1.2)
	_saved_tween.tween_property(_saved, ^"modulate:a", 0.0, 0.6)


func _full_rect(node_name: String) -> Control:
	var root := Control.new()
	root.name = node_name
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return root


func _outlined_label(color: Color, outline := 2) -> Label:
	var label := Label.new()
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", OUTLINE)
	label.add_theme_constant_override(&"outline_size", outline)
	return label


func _badge_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.3, 0.14, 0.42, 0.96)
	box.set_border_width_all(1)
	box.border_color = GOLD
	box.set_corner_radius_all(2)
	box.anti_aliasing = false
	box.content_margin_left = 4
	box.content_margin_right = 4
	box.content_margin_top = 0
	box.content_margin_bottom = 1
	return box


# --- Rewards ----------------------------------------------------------------------------


func _on_progression(xp: int, gold: int, levels: int) -> void:
	var s := WorldState.state
	_level_label.text = tr("HUD_LEVEL") % s.elysia.level()
	if not is_elysia():
		refresh()
		return
	_xp_bar.set_ratio(xp_ratio(s.elysia.xp), levels)
	if gold > 0:
		_count_gold_to(s.elysia.gold)
	if xp > 0:
		_enqueue(func() -> void: _float_text("+%s XP" % format_number(xp), "xp"))
	if gold > 0:
		_enqueue(
			func() -> void:
				_float_text("+%s" % format_number(gold), "", COIN)
				_fly_coins(mini(COINS_PER_GAIN, 3 + int(gold / 500.0)))
		)
	if levels > 0:
		var level := WorldState.elysia_level()
		_enqueue(func() -> void: _level_up(level))


func _on_item(item_id: String, amount: int) -> void:
	var def := ContentDB.item(item_id)
	if def == null:
		return
	if is_elysia():
		_enqueue(func() -> void: _loot_card(def, amount))
	else:
		_quiet_line(def)


## Popups appear one after another, not on top of each other.
func _enqueue(popup: Callable) -> void:
	_queue.append(popup)
	if not _busy:
		_next_popup()


func _next_popup() -> void:
	if _queue.is_empty():
		_busy = false
		return
	_busy = true
	(_queue.pop_front() as Callable).call()
	await NodeTimer.after(self, POPUP_GAP)
	_next_popup()


func _count_gold_to(target: int) -> void:
	if _gold_tween != null and _gold_tween.is_valid():
		_gold_tween.kill()
	_gold_tween = create_tween()
	_gold_tween.tween_interval(0.35)
	_gold_tween.tween_method(
		func(v: float) -> void:
			_gold_shown = roundi(v)
			_gold_label.text = format_number(_gold_shown),
		float(_gold_shown),
		float(target),
		COUNT_SECONDS
	)


func _float_text(text: String, sound: String, icon: Texture2D = null) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 3)
	if icon != null:
		var rect := TextureRect.new()
		rect.texture = icon
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size = icon.get_size() * 2.0
		rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(rect)
	var label := _fancy_label(text, 27)
	row.add_child(label)
	_show_popup(row, 1.3, 1.35)
	if not sound.is_empty():
		AudioDirector.sfx(sound, -2.0)


func _level_up(level: int) -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override(&"separation", -4)
	var title := _fancy_label(tr("HUD_LEVEL_UP"), 54)
	title.add_theme_constant_override(&"outline_size", 4)
	box.add_child(title)
	var sub := _outlined_label(GOLD)
	sub.text = tr("HUD_LEVEL") % level
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	_show_popup(box, 2.2, 1.7)
	_after_layout(
		box,
		func(center: Vector2) -> void:
			_rays_at(center, GOLD, 1.6, 2.6)
			_sparkle_burst(center, 28)
	)
	_screen_flash()
	AudioDirector.sfx("level_up")


func _loot_card(def: ItemDef, amount: int) -> void:
	var card := PanelContainer.new()
	card.theme_type_variation = &"DialoguePanel"
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	card.add_child(row)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(34, 34)
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(holder)
	var color := def.rarity_color()
	if def.rarity >= ItemDef.Rarity.RARE:
		var glow := Sprite2D.new()
		glow.texture = RAYS
		glow.modulate = Color(color, 0.85)
		glow.scale = Vector2.ONE * (56.0 / 96.0)
		glow.position = Vector2(17, 17)
		holder.add_child(glow)
		var spin := glow.create_tween().set_loops()
		spin.tween_property(glow, ^"rotation", TAU, 6.0).from(0.0)
	var icon := TextureRect.new()
	icon.texture = def.icon()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.size = Vector2(32, 32)
	icon.position = Vector2(1, 1)
	holder.add_child(icon)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override(&"separation", -3)
	rows.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rows)
	var found := Label.new()
	found.theme_type_variation = &"MutedLabel"
	found.text = tr("HUD_LOOT")
	rows.add_child(found)
	var item_name := _outlined_label(color, 1)
	item_name.text = tr(def.name_key()) + ("  ×%d" % amount if amount > 1 else "")
	rows.add_child(item_name)
	var rarity := _outlined_label(color, 1)
	rarity.text = tr("HUD_RARITY") % tr(def.rarity_key())
	rows.add_child(rarity)
	if def.rarity == ItemDef.Rarity.LEGENDARY:
		var shimmer := ShaderMaterial.new()
		shimmer.shader = FANCY_TEXT
		shimmer.set_shader_parameter(&"rainbow", 0.65)
		shimmer.set_shader_parameter(&"top_color", Color(1, 0.9, 0.6))
		shimmer.set_shader_parameter(&"bottom_color", color)
		shimmer.set_shader_parameter(&"height", 20.0)
		rarity.material = shimmer
	_show_popup(card, 2.6, 1.3)
	if def.rarity >= ItemDef.Rarity.EPIC:
		_after_layout(card, func(center: Vector2) -> void: _sparkle_burst(center, 20))
	AudioDirector.sfx(def.loot_sound())


## A Label in Jersey 15 with the gold gradient shader and a dark outline.
func _fancy_label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_make_fancy(label, size)
	return label


func _make_fancy(label: Label, size: int) -> void:
	label.add_theme_font_override(&"font", TITLE_FONT)
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", Color(1, 0.9, 0.5))
	label.add_theme_color_override(&"font_outline_color", OUTLINE)
	label.add_theme_constant_override(&"outline_size", 3)
	var material := ShaderMaterial.new()
	material.shader = FANCY_TEXT
	material.set_shader_parameter(&"keep_color", OUTLINE)
	material.set_shader_parameter(&"height", float(size))
	label.material = material


func _show_popup(node: Control, seconds: float, scale_from: float) -> void:
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_popups.add_child(node)
	node.modulate.a = 0.0
	node.scale = Vector2.ONE * scale_from
	# The pivot needs the laid-out size: one frame later (the popup is invisible until then).
	_after_layout(node, func(_center: Vector2) -> void: node.pivot_offset = node.size * 0.5)
	var tween := node.create_tween()
	tween.tween_interval(0.02)
	tween.tween_property(node, ^"modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(node, ^"scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(seconds)
	tween.tween_property(node, ^"modulate:a", 0.0, 0.35)
	tween.tween_callback(node.queue_free)


## Calls `then(global centre)` once the container has laid `node` out.
func _after_layout(node: Control, then: Callable) -> void:
	await NodeTimer.after(self, 0.0)
	if is_instance_valid(node):
		then.call(node.get_global_rect().get_center())


func _rays_at(center: Vector2, color: Color, size_scale: float, seconds: float) -> void:
	var rays := Sprite2D.new()
	rays.texture = RAYS
	rays.scale = Vector2.ONE * size_scale
	rays.position = center.round()
	rays.modulate = Color(color, 0.0)
	_fx.add_child(rays)
	_fx.move_child(rays, 0)
	var tween := rays.create_tween().set_parallel()
	tween.tween_property(rays, ^"modulate:a", 0.8, 0.2)
	tween.tween_property(rays, ^"rotation", 0.9, seconds)
	tween.tween_property(rays, ^"modulate:a", 0.0, 0.5).set_delay(seconds - 0.5)
	tween.chain().tween_callback(rays.queue_free)


func _sparkle_burst(center: Vector2, amount: int) -> void:
	var burst := CPUParticles2D.new()
	burst.texture = SPARKLE
	burst.one_shot = true
	burst.explosiveness = 0.9
	burst.amount = amount
	burst.lifetime = 0.9
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.initial_velocity_min = 50.0
	burst.initial_velocity_max = 110.0
	burst.gravity = Vector2(0, 90)
	burst.damping_min = 30.0
	burst.damping_max = 60.0
	burst.scale_amount_min = 0.6
	burst.scale_amount_max = 1.2
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 0.9, 0.5, 0))
	burst.color_ramp = fade
	burst.position = center
	_fx.add_child(burst)
	burst.emitting = true
	burst.finished.connect(burst.queue_free)


## Coins fly from the popup into the counter; each arrival clinks and bumps the coin.
func _fly_coins(count: int) -> void:
	var start := _popups.get_global_rect().position + Vector2(_popups.size.x * 0.5, 14)
	var goal := _gold_icon.get_global_rect().get_center()
	for i in count:
		var coin := TextureRect.new()
		coin.texture = COIN
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fx.add_child(coin)
		coin.position = start
		var bend := Vector2(randf_range(-60, 60), randf_range(30, 80))
		var tween := coin.create_tween()
		tween.tween_interval(0.25 + i * 0.07)
		tween.tween_method(
			func(t: float) -> void:
				var a := start.lerp(start + bend, t)
				var b := (start + bend).lerp(goal, t)
				coin.position = (a.lerp(b, t) - Vector2(3, 3)).round(),
			0.0,
			1.0,
			0.55
		)
		tween.tween_callback(_coin_arrived)
		tween.tween_callback(coin.queue_free)


func _coin_arrived() -> void:
	AudioDirector.sfx("coin", -6.0)
	_gold_icon.scale = Vector2(1.6, 1.6)
	var tween := _gold_icon.create_tween()
	tween.tween_property(_gold_icon, ^"scale", Vector2.ONE, 0.15)


func _screen_flash() -> void:
	if Settings.get_bool("display.reduce_flashing"):
		return
	_flash.color.a = 0.35
	var tween := _flash.create_tween()
	tween.tween_property(_flash, ^"color:a", 0.0, 0.3)


func _quiet_line(def: ItemDef) -> void:
	_quiet.text = tr(def.name_key())
	_quiet_icon.texture = def.icon()
	_quiet_icon.visible = _quiet_icon.texture != null
	if _quiet_tween != null and _quiet_tween.is_valid():
		_quiet_tween.kill()
	_quiet_tween = _quiet_row.create_tween()
	_quiet_tween.tween_property(_quiet_row, ^"modulate:a", 1.0, 0.6)
	_quiet_tween.tween_interval(2.0)
	_quiet_tween.tween_property(_quiet_row, ^"modulate:a", 0.0, 1.2)
	AudioDirector.sfx("pickup_real", -4.0, 1.05)


# --- Rift -------------------------------------------------------------------------------


## Removes the next Elysia element (glitch, then gone). Returns false when none is left.
func vanish_next(calm := false) -> bool:
	for element_name in VANISH_ORDER:
		if element_name in _vanished:
			continue
		_vanished.append(element_name)
		var node: Control = _elements[element_name]
		if not node.visible:
			continue
		var tween := node.create_tween()
		if calm:
			tween.tween_property(node, ^"modulate:a", 0.0, 0.5)
		else:
			var home := node.position
			for i in 4:
				var jump := Vector2(randi_range(-3, 3), randi_range(-1, 1))
				tween.tween_property(node, ^"modulate:a", 0.15, 0.05)
				tween.parallel().tween_property(node, ^"position", home + jump, 0.0)
				tween.tween_property(node, ^"modulate:a", 1.0, 0.05)
			tween.tween_property(node, ^"position", home, 0.0)
			tween.tween_property(node, ^"modulate:a", 0.0, 0.12)
		tween.tween_callback(node.hide)
		AudioDirector.sfx("glitch", -4.0)
		Log.info(Log.Category.UI, "hud element gone", {"element": element_name})
		return true
	return false


func vanished() -> PackedStringArray:
	return _vanished.duplicate()
