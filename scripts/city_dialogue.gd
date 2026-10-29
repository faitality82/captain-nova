extends CanvasLayer

signal closed

var _npc_data: Dictionary = {}
var _dialogue_index: int = 0
var _panel: Panel = null
var _portrait_container: Control = null
var _name_label: Label = null
var _role_label: Label = null
var _text_label: Label = null
var _options_vbox: VBoxContainer = null
var _content_container: VBoxContainer = null
var _mode: String = "dialogue"  # "dialogue", "trade", "quest"

const ROLE_COLORS: Dictionary = {
	"trader": Color(0.3, 1.0, 0.3),
	"quest": Color(1.0, 0.8, 0.2),
	"weapon": Color(1.0, 0.4, 0.3),
	"lore": Color(0.5, 0.7, 1.0),
	"intel": Color(0.8, 0.5, 1.0),
}

func _ready() -> void:
	layer = 10
	_build_ui()

func setup(npc_data: Dictionary) -> void:
	_npc_data = npc_data
	_dialogue_index = 0
	_mode = "dialogue"
	_update_npc_info()

	var npc_id: String = npc_data.get("id", "")
	var has_quest: bool = npc_data.has("quest") and not npc_data["quest"].is_empty()
	var quest_id: String = npc_data.get("quest", {}).get("id", npc_id) if has_quest else npc_id

	# If this NPC's quest is already completed, show completion text instead
	if has_quest and ResourceManager.is_npc_quest_complete(quest_id):
		var reward_desc: String = npc_data["quest"].get("reward_desc", "")
		_text_label.text = _get_completed_greeting(npc_data, reward_desc)
		for child in _options_vbox.get_children():
			child.queue_free()
		_show_back_button()
		return

	# If this NPC's quest is currently active, show reminder
	if has_quest:
		for q in ResourceManager.npc_active_quests:
			if q.get("quest_id", q.get("npc_id", "")) == quest_id:
				_text_label.text = _get_active_reminder(npc_data, q)
				for child in _options_vbox.get_children():
					child.queue_free()
				_show_back_button()
				return

	_show_dialogue_node(0)

func _get_completed_greeting(npc_data: Dictionary, reward_desc: String) -> String:
	var role: String = npc_data.get("role", "")
	match role:
		"weapon":
			return "Good work out there, Captain. The %s is yours. Nothing else I need." % reward_desc
		"quest":
			return "You already did what I asked. I won't forget it. Safe travels, Captain."
		_:
			return "We're square, Captain. Pleasure doing business."

func _get_active_reminder(_data: Dictionary, quest: Dictionary) -> String:
	var desc: String = quest.get("desc", "the job")
	var quest_type: String = quest.get("type", "")
	match quest_type:
		"kill":
			var progress: int = quest.get("progress", 0)
			var amount: int = quest.get("amount", 0)
			return "You're still on the job. %s — %d/%d so far. Get it done." % [desc, progress, amount]
		"fetch":
			var target: String = quest.get("target", "items")
			var amount: int = quest.get("amount", 0)
			var have: int = ResourceManager.cargo.get(target, 0)
			return "Still need that %s. You've got %d/%d. Keep at it." % [target, have, amount]
		_:
			return "Job's not done yet, Captain. %s" % desc

func _build_ui() -> void:
	# Full-screen semi-transparent overlay
	var overlay = ColorRect.new()
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	add_child(overlay)

	# Dialogue panel at bottom of screen
	_panel = Panel.new()
	_panel.anchor_left = 0.0
	_panel.anchor_top = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = 40
	_panel.offset_top = -220
	_panel.offset_right = -40
	_panel.offset_bottom = -10
	add_child(_panel)

	# Main HBox: portrait on left, text+options on right
	var hbox = HBoxContainer.new()
	hbox.anchor_left = 0.0
	hbox.anchor_top = 0.0
	hbox.anchor_right = 1.0
	hbox.anchor_bottom = 1.0
	hbox.offset_left = 10
	hbox.offset_top = 10
	hbox.offset_right = -10
	hbox.offset_bottom = -10
	_panel.add_child(hbox)

	# Portrait container (left side)
	_portrait_container = Control.new()
	_portrait_container.custom_minimum_size = Vector2(110, 130)
	hbox.add_child(_portrait_container)

	# Right side: name, role, text, options
	_content_container = VBoxContainer.new()
	_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(_content_container)

	# NPC name
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 18)
	_content_container.add_child(_name_label)

	# NPC role
	_role_label = Label.new()
	_role_label.add_theme_font_size_override("font_size", 12)
	_content_container.add_child(_role_label)

	_content_container.add_child(HSeparator.new())

	# Dialogue text
	_text_label = Label.new()
	_text_label.add_theme_font_size_override("font_size", 14)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_container.add_child(_text_label)

	# Options container
	_options_vbox = VBoxContainer.new()
	_options_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_container.add_child(_options_vbox)

	# Close button (top right corner of panel)
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(30, 30)
	close_btn.anchor_left = 1.0
	close_btn.anchor_top = 0.0
	close_btn.anchor_right = 1.0
	close_btn.anchor_bottom = 0.0
	close_btn.offset_left = -35
	close_btn.offset_top = 5
	close_btn.offset_right = -5
	close_btn.offset_bottom = 35
	close_btn.pressed.connect(func(): closed.emit())
	_panel.add_child(close_btn)

func _update_npc_info() -> void:
	if _npc_data.is_empty():
		return

	# Set name with role color
	var role: String = _npc_data.get("role", "lore")
	var role_color: Color = ROLE_COLORS.get(role, Color(1, 1, 1))
	_name_label.text = _npc_data.get("name", "Unknown")
	_name_label.add_theme_color_override("font_color", role_color)

	# Set role text
	_role_label.text = role.capitalize()
	_role_label.add_theme_color_override("font_color", role_color.darkened(0.3))

	# Set up portrait
	_setup_portrait()

func _setup_portrait() -> void:
	# Clear old portrait
	for child in _portrait_container.get_children():
		child.queue_free()

	var visual: Dictionary = _npc_data.get("visual", {})
	if visual.is_empty():
		return

	var role: String = _npc_data.get("role", "")
	var portrait = preload("res://scripts/npc_portrait.gd").new()
	portrait.setup(visual, role)
	_portrait_container.add_child(portrait)

func _show_dialogue_node(index: int) -> void:
	_dialogue_index = index
	var dialogue: Array = _npc_data.get("dialogue", [])
	if index < 0 or index >= dialogue.size():
		closed.emit()
		return

	var node: Dictionary = dialogue[index]
	_text_label.text = node.get("text", "...")

	# Clear old options
	for child in _options_vbox.get_children():
		child.queue_free()

	# Create option buttons
	var options: Array = node.get("options", [])
	for option in options:
		var btn = Button.new()
		btn.text = option.get("text", "...")
		btn.custom_minimum_size = Vector2(200, 32)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		var opt = option
		btn.pressed.connect(func(): _on_option_selected(opt))
		_options_vbox.add_child(btn)

func _on_option_selected(option: Dictionary) -> void:
	if option.has("set_flags"):
		ResourceManager.set_story_flags(option["set_flags"])
	# Check for action first
	if option.has("action"):
		match option["action"]:
			"open_trade":
				_show_trade_panel()
				return
			"accept_quest":
				_accept_quest()
				return
			"reveal_rumors":
				_reveal_rumors()
				return

	# Otherwise advance dialogue
	var next: int = option.get("next", -1)
	if next == -1:
		closed.emit()
	else:
		_show_dialogue_node(next)

func _reveal_rumors() -> void:
	var cost := 400
	if ResourceManager.get_reputation("Uranus") >= 30:
		cost = 200
	for child in _options_vbox.get_children():
		child.queue_free()
	if ResourceManager.current_rumors().is_empty():
		_text_label.text = "...nothing worth selling this week. Come back when the board is loud."
	elif ResourceManager.money < cost:
		_text_label.text = "...%d credits. You don't have it. Come back when you do." % cost
	else:
		ResourceManager.spend_money(cost)
		ResourceManager.reveal_rumors()
		AudioManager.play_sfx("sfx_trade")
		_text_label.text = "...done. Check the board. The lie is marked. Don't tell anyone where you heard it."
	_show_back_button()

func _show_trade_panel() -> void:
	_mode = "trade"
	var trades: Array = _npc_data.get("trades", [])
	if trades.is_empty():
		_text_label.text = "Nothing to trade right now."
		_show_back_button()
		return

	_text_label.text = "Available trades:"

	# Clear options
	for child in _options_vbox.get_children():
		child.queue_free()

	for trade in trades:
		var resource: String = trade.get("resource", "")
		var amount: int = trade.get("amount", 0)
		var powerup: String = trade.get("powerup", "")
		var desc: String = trade.get("desc", "")

		var hbox = HBoxContainer.new()

		var info_label = Label.new()
		info_label.text = "%d %s -> %s" % [amount, resource.capitalize(), desc]
		info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_label.add_theme_font_size_override("font_size", 13)
		hbox.add_child(info_label)

		var trade_btn = Button.new()
		trade_btn.custom_minimum_size = Vector2(80, 30)
		var t = trade
		var npc_id = _npc_data.get("id", "")

		# Check if already owned
		if powerup == "extra_life" and ResourceManager.lives >= 7:
			trade_btn.text = "Max Lives"
			trade_btn.disabled = true
		elif powerup in ResourceManager.npc_powerups and ResourceManager.npc_powerups[powerup]:
			trade_btn.text = "Owned"
			trade_btn.disabled = true
		elif ResourceManager.cargo.get(resource, 0) < amount:
			trade_btn.text = "Trade"
			trade_btn.disabled = true
		else:
			trade_btn.text = "Trade"
			trade_btn.pressed.connect(func(): _execute_trade(npc_id, t))

		hbox.add_child(trade_btn)
		_options_vbox.add_child(hbox)

	_show_back_button()

func _execute_trade(npc_id: String, trade: Dictionary) -> void:
	var resource: String = trade.get("resource", "")
	var amount: int = trade.get("amount", 0)
	var powerup: String = trade.get("powerup", "")

	if ResourceManager.npc_trade(npc_id, resource, amount, powerup):
		AudioManager.play_sfx("sfx_trade")
	# Refresh trade panel
	_show_trade_panel()

func _accept_quest() -> void:
	var quest: Dictionary = _npc_data.get("quest", {})
	if quest.is_empty():
		closed.emit()
		return

	var npc_id: String = _npc_data.get("id", "")
	var quest_id: String = quest.get("id", npc_id)

	# Check if quest already completed
	if ResourceManager.is_npc_quest_complete(quest_id):
		_text_label.text = "Quest complete! Thanks, pilot."
		for child in _options_vbox.get_children():
			child.queue_free()
		_show_back_button()
		return

	# Check if quest already active
	for q in ResourceManager.npc_active_quests:
		if q.get("quest_id", q.get("npc_id", "")) == quest_id:
			_text_label.text = "You're already on this job. Get it done."
			for child in _options_vbox.get_children():
				child.queue_free()
			_show_back_button()
			return

	# Show quest details
	_mode = "quest"
	_text_label.text = quest.get("desc", "")

	for child in _options_vbox.get_children():
		child.queue_free()

	# Quest info
	var reward_text = ""
	var reward_money: int = quest.get("reward_money", 0)
	var reward_desc: String = quest.get("reward_desc", "")
	if reward_money > 0:
		reward_text += "$%d" % reward_money
	if reward_desc != "":
		if reward_text != "":
			reward_text += " + "
		reward_text += reward_desc

	var info_label = Label.new()
	info_label.text = "Reward: %s" % reward_text
	info_label.add_theme_font_size_override("font_size", 13)
	info_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_options_vbox.add_child(info_label)

	var accept_btn = Button.new()
	accept_btn.text = "Accept Quest"
	accept_btn.custom_minimum_size = Vector2(150, 35)
	accept_btn.pressed.connect(func():
		var quest_entry = quest.duplicate()
		quest_entry["npc_id"] = npc_id
		quest_entry["quest_id"] = quest_id
		quest_entry["progress"] = 0
		ResourceManager.accept_npc_quest(quest_entry)
		AudioManager.play_sfx("sfx_trade")
		_text_label.text = "Quest accepted. Good luck out there."
		for child in _options_vbox.get_children():
			child.queue_free()
		_show_back_button()
	)
	_options_vbox.add_child(accept_btn)

	_show_back_button()

func _show_back_button() -> void:
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.custom_minimum_size = Vector2(80, 30)
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back_btn.pressed.connect(func():
		_mode = "dialogue"
		_show_dialogue_node(0)
	)
	_options_vbox.add_child(back_btn)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		closed.emit()
		get_viewport().set_input_as_handled()
