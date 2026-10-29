extends CanvasLayer

signal closed

var _tab: String = "log"  # "log" or "trade"

const CATEGORY_COLORS: Dictionary = {
	"story": Color(1.0, 0.9, 0.3),
	"combat": Color(1.0, 0.4, 0.3),
	"death": Color(0.8, 0.2, 0.2),
	"explore": Color(0.3, 0.8, 1.0),
	"upgrade": Color(0.4, 1.0, 0.5),
	"progress": Color(0.7, 0.5, 1.0),
	"event": Color(0.8, 0.7, 0.6),
}

const CATEGORY_LABELS: Dictionary = {
	"story": "STORY",
	"combat": "COMBAT",
	"death": "DEATH",
	"explore": "EXPLORE",
	"upgrade": "UPGRADE",
	"progress": "LEVEL",
	"event": "EVENT",
}

func _ready() -> void:
	layer = 10
	_build_ui()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var panel = Panel.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 80
	panel.offset_top = 40
	panel.offset_right = -80
	panel.offset_bottom = -40
	add_child(panel)

	var outer_vbox = VBoxContainer.new()
	outer_vbox.anchor_left = 0.0
	outer_vbox.anchor_top = 0.0
	outer_vbox.anchor_right = 1.0
	outer_vbox.anchor_bottom = 1.0
	outer_vbox.offset_left = 10
	outer_vbox.offset_top = 10
	outer_vbox.offset_right = -10
	outer_vbox.offset_bottom = -10
	outer_vbox.add_theme_constant_override("separation", 6)
	panel.add_child(outer_vbox)

	# Header
	var header = Label.new()
	header.text = "Captain Nova's Journal"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	outer_vbox.add_child(header)

	# Tab buttons
	var tab_row = HBoxContainer.new()
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_row.add_theme_constant_override("separation", 10)
	outer_vbox.add_child(tab_row)

	var log_tab = Button.new()
	log_tab.text = "CAPTAIN'S LOG"
	log_tab.custom_minimum_size = Vector2(150, 30)
	log_tab.add_theme_font_size_override("font_size", 13)
	log_tab.disabled = _tab == "log"
	log_tab.pressed.connect(func():
		_tab = "log"
		_build_ui()
	)
	tab_row.add_child(log_tab)

	var trade_tab = Button.new()
	trade_tab.text = "TRADE INTEL"
	trade_tab.custom_minimum_size = Vector2(150, 30)
	trade_tab.add_theme_font_size_override("font_size", 13)
	trade_tab.disabled = _tab == "trade"
	trade_tab.pressed.connect(func():
		_tab = "trade"
		_build_ui()
	)
	tab_row.add_child(trade_tab)

	outer_vbox.add_child(HSeparator.new())

	# Scrollable content
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox)

	match _tab:
		"log":
			_build_log_tab(vbox)
		"trade":
			_build_trade_tab(vbox)

	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close Journal"
	close_btn.custom_minimum_size = Vector2(200, 36)
	close_btn.pressed.connect(func(): closed.emit())
	outer_vbox.add_child(close_btn)

func _build_log_tab(vbox: VBoxContainer) -> void:
	if ResourceManager.ship_log.is_empty():
		var empty = Label.new()
		empty.text = "No entries yet. Your story hasn't started."
		empty.add_theme_font_size_override("font_size", 14)
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty)
		return

	var entry_num = ResourceManager.ship_log.size()
	for entry in ResourceManager.ship_log:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		vbox.add_child(row)

		# Entry number
		var num_lbl = Label.new()
		num_lbl.text = "%02d." % entry_num
		num_lbl.custom_minimum_size = Vector2(35, 0)
		num_lbl.add_theme_font_size_override("font_size", 13)
		num_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		row.add_child(num_lbl)

		# Category tag
		var cat = entry.get("category", "event")
		var tag = Label.new()
		tag.text = "[%s]" % CATEGORY_LABELS.get(cat, "EVENT")
		tag.custom_minimum_size = Vector2(75, 0)
		tag.add_theme_font_size_override("font_size", 12)
		tag.add_theme_color_override("font_color", CATEGORY_COLORS.get(cat, Color(0.7, 0.7, 0.7)))
		row.add_child(tag)

		# Log text
		var text_lbl = Label.new()
		text_lbl.text = entry.get("text", "")
		text_lbl.add_theme_font_size_override("font_size", 14)
		text_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text_lbl)

		entry_num -= 1

func _build_trade_tab(vbox: VBoxContainer) -> void:
	# Active price events
	if ResourceManager.price_events.size() > 0:
		var events_header = Label.new()
		events_header.text = "— Active Market Events —"
		events_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		events_header.add_theme_font_size_override("font_size", 16)
		events_header.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
		vbox.add_child(events_header)

		for event in ResourceManager.price_events:
			var elabel = Label.new()
			elabel.autowrap_mode = TextServer.AUTOWRAP_WORD
			var left: int = int(maxf(float(event.get("ends_at", 0.0)) - ResourceManager.game_seconds, 0.0))
			elabel.text = "%s: %s (%d s left)" % [event["type"].to_upper(), event["cause"], left]
			var color = Color(1, 0.6, 0.3) if event["type"] == "shortage" else Color(0.4, 0.8, 1.0)
			elabel.add_theme_color_override("font_color", color)
			vbox.add_child(elabel)

		vbox.add_child(HSeparator.new())

	# Price table per visited planet
	var header2 = Label.new()
	header2.text = "— Last Seen Prices —"
	header2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header2.add_theme_font_size_override("font_size", 16)
	vbox.add_child(header2)

	if ResourceManager.price_memory.is_empty():
		var none_label = Label.new()
		none_label.text = "No planets visited yet. Open a Market to record prices."
		none_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox.add_child(none_label)
	else:
		for planet in ResourceManager.price_memory:
			var planet_header = Label.new()
			planet_header.text = planet
			planet_header.add_theme_font_size_override("font_size", 16)
			planet_header.add_theme_color_override("font_color", Color(1, 0.9, 0.5, 1))
			vbox.add_child(planet_header)

			var prices = ResourceManager.price_memory[planet]
			for resource in prices:
				var p = prices[resource]
				var buy_text = "$%d" % p[0] if p[0] > 0 else "—"
				var sell_text = "$%d" % p[1] if p[1] > 0 else "—"
				var rlabel = Label.new()
				rlabel.text = "  %s  Buy: %s  Sell: %s" % [resource.capitalize(), buy_text, sell_text]
				for event in ResourceManager.price_events:
					if event["planet"] == planet and event["resource"] == resource:
						var color = Color(1, 0.6, 0.3) if event.get("type") == "shortage" else Color(0.4, 0.8, 1.0)
						rlabel.add_theme_color_override("font_color", color)
				vbox.add_child(rlabel)

			vbox.add_child(HSeparator.new())

	# Reputation section
	var rep_header = Label.new()
	rep_header.text = "— Reputation —"
	rep_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rep_header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(rep_header)

	for planet in ResourceManager.reputation:
		var rep = ResourceManager.reputation[planet]
		var rlabel = Label.new()
		rlabel.text = "  %s: %d" % [planet, rep]
		if rep >= 50:
			rlabel.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
		elif rep >= 30:
			rlabel.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		elif rep <= -50:
			rlabel.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		elif rep <= -30:
			rlabel.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		vbox.add_child(rlabel)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		closed.emit()
