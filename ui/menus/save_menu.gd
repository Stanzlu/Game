class_name SaveMenu
extends MenuLayer
## Save and load slots. Saving over an existing slot asks first. A broken slot offers its
## backup; nothing is ever deleted from here.

enum Mode { SAVE, LOAD }

var mode := Mode.LOAD
var _confirm := ""
var _message := ""


func _ready() -> void:
	panel_width = 300
	layer = 50
	super()


func open_mode(new_mode: Mode) -> void:
	mode = new_mode
	_confirm = ""
	_message = ""
	title.text = "SAVE_TITLE" if mode == Mode.SAVE else "LOAD_TITLE"
	open()


func _build() -> void:
	if not _confirm.is_empty():
		_build_confirm()
		return
	for slot in SaveService.SLOTS:
		if mode == Mode.SAVE and slot == SaveService.AUTOSAVE:
			continue
		var info := SaveSystem.summary(slot)
		var enabled: bool = mode == Mode.SAVE or info["status"] != "empty"
		list.add_action("", func() -> void: _choose(slot, info), enabled, describe(slot, info))
	list.add_action("MENU_BACK", close)
	hint.text = _message


func _build_confirm() -> void:
	var slot := _confirm
	var question := "SAVE_CONFIRM_OVERWRITE" if mode == Mode.SAVE else "LOAD_CONFIRM_BACKUP"
	list.add_info(tr(question) % slot_name(slot))
	var yes := func() -> void:
		_confirm = ""
		if mode == Mode.SAVE:
			_save(slot)
		else:
			_load(slot, true)
	list.add_action("OPTION_YES", yes)
	list.add_action("OPTION_NO", func() -> void: _ask("", ""))
	hint.text = ""


func _choose(slot: String, info: Dictionary) -> void:
	if mode == Mode.SAVE:
		if info["status"] == "empty":
			_save(slot)
		else:
			_ask(slot, "")
	elif info["status"] == "ok":
		_load(slot, false)
	elif bool(info["backup"]):
		_ask(slot, "")
	else:
		_ask("", tr("LOAD_BROKEN_NO_BACKUP"))


func _ask(slot: String, message: String) -> void:
	_confirm = slot
	_message = message
	rebuild()


func _save(slot: String) -> void:
	var err := SaveSystem.save_slot(slot)
	_ask("", tr("SAVE_DONE") if err == OK else tr("SAVE_FAILED"))


func _load(slot: String, backup: bool) -> void:
	if SaveSystem.load_slot(slot, backup) != OK:
		_ask("", tr("LOAD_FAILED"))


static func slot_name(slot: String) -> String:
	if slot == SaveService.AUTOSAVE:
		return TranslationServer.translate("SLOT_AUTOSAVE")
	return TranslationServer.translate("SLOT_N") % slot.trim_prefix("slot_")


## "Slot 1 · Tal · 12 min · 03.10.2026 14:05", "Slot 2 · leer", "Slot 3 · beschädigt".
static func describe(slot: String, info: Dictionary) -> String:
	var parts: PackedStringArray = [slot_name(slot)]
	match str(info["status"]):
		"empty":
			parts.append(TranslationServer.translate("SLOT_EMPTY"))
		"broken":
			parts.append(TranslationServer.translate("SLOT_BROKEN"))
		_:
			parts.append(TranslationServer.translate(SceneRegistry.title_key(str(info["map"]))))
			parts.append(format_playtime(float(info["playtime"])))
			parts.append(format_date(str(info["saved_at"])))
	return " · ".join(parts)


static func format_playtime(seconds: float) -> String:
	var minutes := int(seconds / 60.0)
	if minutes < 60:
		return TranslationServer.translate("TIME_MINUTES") % minutes
	return TranslationServer.translate("TIME_HOURS") % [minutes / 60, minutes % 60]


## UTC ISO time to local "DD.MM.YYYY HH:MM".
static func format_date(iso: String) -> String:
	if iso.is_empty():
		return "?"
	var unix := Time.get_unix_time_from_datetime_string(iso.trim_suffix("Z"))
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	var d := Time.get_datetime_dict_from_unix_time(unix + bias * 60)
	return "%02d.%02d.%d %02d:%02d" % [d["day"], d["month"], d["year"], d["hour"], d["minute"]]
