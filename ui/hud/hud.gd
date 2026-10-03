class_name Hud
extends CanvasLayer
## Heads-up display in two worlds (Game Bible §10, §11, §34).
## Elysia: level badge, XP bar, gold, a quest tracker with a bouncing marker, and loud reward
## popups (+XP, level up, loot with rarity as word and colour). The Real world: nothing,
## except a quiet line when something is picked up.
## The rift sequence removes the Elysia elements one by one (vanish_next()).

const COIN := preload("res://assets/generated/ui/coin.png")
const SPARKLE := preload("res://assets/generated/ui/sparkle.png")
const GOLD := Color(1, 0.84, 0.4)
const POPUP_GAP := 0.35
## Elysia elements in the order they disappear at the rift.
const VANISH_ORDER: PackedStringArray = ["Quest", "Gold", "Xp", "Level"]

var elysia_root: Control
var real_root: Control
var _elements: Dictionary[String, Control] = {}
var _level_label: Label
var _xp_bar: ProgressBar
var _gold_label: Label
var _quest_label: Label
var _popups: VBoxContainer
var _quiet: Label
var _queue: Array[Callable] = []
var _busy := false
var _vanished: PackedStringArray = []


func _ready() -> void:
	layer = 12
	_build_elysia()
	_build_real()
	WorldState.progression_changed.connect(_on_progression)
	WorldState.item_received.connect(_on_item)
	WorldState.quest_changed.connect(func(_q: String, _s: String) -> void: refresh())
	WorldState.ui_mode_changed.connect(func(_m: GameState.UiMode) -> void: refresh())
	WorldState.state_replaced.connect(refresh)
	refresh()


func is_elysia() -> bool:
	return WorldState.ui_mode() == GameState.UiMode.ELYSIA


func refresh() -> void:
	elysia_root.visible = is_elysia()
	real_root.visible = not is_elysia()
	var s := WorldState.state
	var level := s.elysia.level()
	_level_label.text = tr("HUD_LEVEL") % level
	var floor_xp := 15 * (level - 1) * (level - 1)
	var next_xp := 15 * level * level
	_xp_bar.max_value = maxi(next_xp - floor_xp, 1)
	_xp_bar.value = clampi(s.elysia.xp - floor_xp, 0, next_xp - floor_xp)
	_gold_label.text = format_number(s.elysia.gold)
	var quest := _active_quest()
	_quest_label.text = (
		"! " + tr(ContentDB.quest(quest).title_key()) if not quest.is_empty() else ""
	)
	_elements["Quest"].visible = not quest.is_empty() and not "Quest" in _vanished


## "4.200" with German thousands separators.
static func format_number(value: int) -> String:
	var digits := str(absi(value))
	var out := ""
	while digits.length() > 3:
		out = "." + digits.right(3) + out
		digits = digits.left(digits.length() - 3)
	return ("-" if value < 0 else "") + digits + out


func _active_quest() -> String:
	var newest := ""
	for quest_id: String in WorldState.state.quests:
		if WorldState.is_quest_active(quest_id) and ContentDB.has_quest(quest_id):
			newest = quest_id
	return newest


# --- Building ---------------------------------------------------------------------------


func _build_elysia() -> void:
	elysia_root = Control.new()
	elysia_root.name = "Elysia"
	elysia_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	elysia_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(elysia_root)
	UiSkin.attach(elysia_root)
	var corner := VBoxContainer.new()
	corner.position = Vector2(6, 5)
	corner.add_theme_constant_override(&"separation", 2)
	elysia_root.add_child(corner)
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override(&"separation", 4)
	corner.add_child(level_row)
	var badge := PanelContainer.new()
	badge.theme_type_variation = &"PromptLabel"
	badge.add_theme_stylebox_override(&"panel", _badge_style())
	level_row.add_child(badge)
	_level_label = Label.new()
	_level_label.add_theme_color_override(&"font_color", GOLD)
	badge.add_child(_level_label)
	_elements["Level"] = badge
	_xp_bar = ProgressBar.new()
	_xp_bar.show_percentage = false
	_xp_bar.custom_minimum_size = Vector2(84, 6)
	_xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_xp_bar.add_theme_stylebox_override(&"background", _bar_style(Color(0.12, 0.08, 0.2, 0.9)))
	_xp_bar.add_theme_stylebox_override(&"fill", _bar_style(Color(1, 0.8, 0.32)))
	level_row.add_child(_xp_bar)
	_elements["Xp"] = _xp_bar
	var gold_row := HBoxContainer.new()
	gold_row.add_theme_constant_override(&"separation", 3)
	corner.add_child(gold_row)
	var coin := TextureRect.new()
	coin.texture = COIN
	coin.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	gold_row.add_child(coin)
	_gold_label = Label.new()
	_gold_label.add_theme_color_override(&"font_color", GOLD)
	gold_row.add_child(_gold_label)
	_elements["Gold"] = gold_row
	_quest_label = Label.new()
	_quest_label.add_theme_color_override(&"font_color", Color(1, 0.95, 0.75))
	_quest_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_quest_label.offset_left = -220
	_quest_label.offset_right = -8
	_quest_label.offset_top = 6
	elysia_root.add_child(_quest_label)
	_elements["Quest"] = _quest_label
	var bounce := create_tween().set_loops()
	bounce.tween_property(_quest_label, ^"offset_top", 3.0, 0.35).set_trans(Tween.TRANS_SINE)
	bounce.tween_property(_quest_label, ^"offset_top", 6.0, 0.35).set_trans(Tween.TRANS_SINE)
	_popups = VBoxContainer.new()
	_popups.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_popups.offset_top = 40
	_popups.offset_left = -120
	_popups.offset_right = 120
	_popups.alignment = BoxContainer.ALIGNMENT_BEGIN
	_popups.add_theme_constant_override(&"separation", 4)
	_popups.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elysia_root.add_child(_popups)


func _build_real() -> void:
	real_root = Control.new()
	real_root.name = "Real"
	real_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	real_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(real_root)
	UiSkin.attach(real_root)
	_quiet = Label.new()
	_quiet.theme_type_variation = &"MutedLabel"
	_quiet.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_quiet.offset_left = 10
	_quiet.offset_top = -18
	_quiet.offset_bottom = -8
	_quiet.modulate.a = 0.0
	real_root.add_child(_quiet)


func _badge_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.2, 0.12, 0.32, 0.95)
	box.set_border_width_all(1)
	box.border_color = GOLD
	box.set_content_margin_all(2)
	box.content_margin_left = 4
	box.content_margin_right = 4
	return box


func _bar_style(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = Color(0.3, 0.16, 0.06)
	box.set_border_width_all(1)
	return box


# --- Rewards ----------------------------------------------------------------------------


func _on_progression(xp: int, gold: int, levels: int) -> void:
	refresh()
	if not is_elysia():
		return
	if xp > 0:
		_enqueue(func() -> void: _float_text("+%s XP" % format_number(xp), GOLD, 1.25))
	if gold > 0:
		_enqueue(func() -> void: _float_text("+%s" % format_number(gold), GOLD, 1.0, COIN))
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
		_quiet_line(tr(def.name_key()))


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
	await get_tree().create_timer(POPUP_GAP).timeout
	_next_popup()


func _float_text(text: String, color: Color, scale_from: float, icon: Texture2D = null) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	if icon != null:
		var rect := TextureRect.new()
		rect.texture = icon
		rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		row.add_child(rect)
	var label := Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", Color(0.25, 0.1, 0.05))
	label.add_theme_constant_override(&"outline_size", 2)
	row.add_child(label)
	_show_popup(row, 1.4, scale_from)


func _level_up(level: int) -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var title := Label.new()
	title.theme_type_variation = &"SubtitleLabel"
	title.text = tr("HUD_LEVEL_UP")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := Label.new()
	sub.text = tr("HUD_LEVEL") % level
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override(&"font_color", GOLD)
	box.add_child(sub)
	_show_popup(box, 2.2, 1.6)
	_sparkles(box)


func _loot_card(def: ItemDef, amount: int) -> void:
	var card := PanelContainer.new()
	card.theme_type_variation = &"DialoguePanel"
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override(&"separation", 1)
	card.add_child(rows)
	var found := Label.new()
	found.theme_type_variation = &"MutedLabel"
	found.text = tr("HUD_LOOT")
	found.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(found)
	var item_name := Label.new()
	item_name.text = tr(def.name_key()) + ("  ×%d" % amount if amount > 1 else "")
	item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_name.add_theme_color_override(&"font_color", def.rarity_color())
	rows.add_child(item_name)
	var rarity := Label.new()
	rarity.text = tr("HUD_RARITY") % tr(def.rarity_key())
	rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity.add_theme_color_override(&"font_color", def.rarity_color())
	rows.add_child(rarity)
	_show_popup(card, 2.6, 1.3)
	if def.rarity >= ItemDef.Rarity.EPIC:
		_sparkles(card)


func _show_popup(node: Control, seconds: float, scale_from: float) -> void:
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popups.add_child(node)
	node.pivot_offset = node.get_combined_minimum_size() * 0.5
	node.scale = Vector2.ONE * scale_from
	node.modulate.a = 0.0
	var tween := node.create_tween()
	tween.tween_property(node, ^"modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(node, ^"scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(seconds)
	tween.tween_property(node, ^"modulate:a", 0.0, 0.4)
	tween.tween_callback(node.queue_free)


func _sparkles(around: Control) -> void:
	for i in 6:
		var star := TextureRect.new()
		star.texture = SPARKLE
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star.top_level = true
		around.add_child(star)
		var center := around.global_position + around.get_combined_minimum_size() * 0.5
		var angle := TAU * i / 6.0
		star.global_position = center
		var tween := star.create_tween()
		(
			tween
			. tween_property(
				star, ^"global_position", center + Vector2.from_angle(angle) * 46.0, 0.7
			)
			. set_ease(Tween.EASE_OUT)
		)
		tween.parallel().tween_property(star, ^"modulate:a", 0.0, 0.7)
		tween.tween_callback(star.queue_free)


func _quiet_line(text: String) -> void:
	_quiet.text = text
	var tween := _quiet.create_tween()
	tween.tween_property(_quiet, ^"modulate:a", 1.0, 0.6)
	tween.tween_interval(2.0)
	tween.tween_property(_quiet, ^"modulate:a", 0.0, 1.2)


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
			for i in 4:
				tween.tween_property(node, ^"modulate:a", 0.15, 0.05)
				tween.tween_property(node, ^"modulate:a", 1.0, 0.05)
			tween.tween_property(node, ^"modulate:a", 0.0, 0.12)
		tween.tween_callback(node.hide)
		Log.info(Log.Category.UI, "hud element gone", {"element": element_name})
		return true
	return false


func vanished() -> PackedStringArray:
	return _vanished.duplicate()
