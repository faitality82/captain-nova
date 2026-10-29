# station_menu.gd
# Space station docking menu — Garage + Bounty Board
extends CanvasLayer

signal closed

var _station_name: String = "Station"
var _bounties: Array = []
var _vbox: VBoxContainer = null
var _tab: String = "bounty"  # start on bounty board

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bounties = ResourceManager.generate_bounties()
	_build_ui()

func _build_ui() -> void:
	# Clear old UI
	for child in get_children():
		child.queue_free()

	# Dark backdrop
	var backdrop = ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.7)
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	add_child(backdrop)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -280
	panel.offset_top = -240
	panel.offset_right = 280
	panel.offset_bottom = 240
	add_child(panel)

	_vbox = VBoxContainer.new()
	_vbox.anchor_left = 0.0
	_vbox.anchor_top = 0.0
	_vbox.anchor_right = 1.0
	_vbox.anchor_bottom = 1.0
	_vbox.offset_left = 15
	_vbox.offset_top = 12
	_vbox.offset_right = -15
	_vbox.offset_bottom = -12
	_vbox.add_theme_constant_override("separation", 6)
	panel.add_child(_vbox)

	# Station header
	var header = Label.new()
	header.text = _station_name
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	_vbox.add_child(header)

	# Money / HP / Fuel status
	var status = Label.new()
	status.text = "Money: $%d  |  HP: %d/%d  |  Fuel: %d/%d" % [
		ResourceManager.money,
		ResourceManager.ship_hp, ResourceManager.ship_max_hp,
		int(ResourceManager.ship_fuel), int(ResourceManager.ship_max_fuel),
	]
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 13)
	status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_vbox.add_child(status)

	# Tab buttons
	var tab_row = HBoxContainer.new()
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_row.add_theme_constant_override("separation", 10)
	_vbox.add_child(tab_row)

	var bounty_tab = Button.new()
	bounty_tab.text = "BOUNTY BOARD"
	bounty_tab.custom_minimum_size = Vector2(150, 32)
	bounty_tab.add_theme_font_size_override("font_size", 14)
	if _tab == "bounty":
		bounty_tab.disabled = true
	bounty_tab.pressed.connect(func():
		_tab = "bounty"
		_build_ui()
	)
	tab_row.add_child(bounty_tab)

	var garage_tab = Button.new()
	garage_tab.text = "REPAIRS & FUEL"
	garage_tab.custom_minimum_size = Vector2(150, 32)
	garage_tab.add_theme_font_size_override("font_size", 14)
	if _tab == "garage":
		garage_tab.disabled = true
	garage_tab.pressed.connect(func():
		_tab = "garage"
		_build_ui()
	)
	tab_row.add_child(garage_tab)

	var rumor_tab = Button.new()
	rumor_tab.text = "RUMORS"
	rumor_tab.custom_minimum_size = Vector2(150, 32)
	rumor_tab.add_theme_font_size_override("font_size", 14)
	if _tab == "rumors":
		rumor_tab.disabled = true
	rumor_tab.pressed.connect(func():
		_tab = "rumors"
		_build_ui()
	)
	tab_row.add_child(rumor_tab)

	_vbox.add_child(HSeparator.new())

	# Tab content
	match _tab:
		"bounty":
			_build_bounty_board()
		"garage":
			_build_garage()
		"rumors":
			build_rumor_rows(_vbox)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbox.add_child(spacer)

	# Undock button
	var close_btn = Button.new()
	close_btn.text = "UNDOCK"
	close_btn.custom_minimum_size = Vector2(200, 36)
	close_btn.add_theme_font_size_override("font_size", 14)
	close_btn.pressed.connect(func(): closed.emit())
	_vbox.add_child(close_btn)

func _build_bounty_board() -> void:
	var title = Label.new()
	title.text = "WANTED — DEAD OR DEADER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
	_vbox.add_child(title)

	# Active bounty display
	if ResourceManager.active_bounty.size() > 0:
		var active = ResourceManager.active_bounty
		var active_row = HBoxContainer.new()
		active_row.add_theme_constant_override("separation", 10)
		_vbox.add_child(active_row)

		var active_lbl = Label.new()
		active_lbl.text = "ACTIVE: %s — near %s — $%d" % [
			active.get("name", "???"),
			active.get("planet", "???"),
			active.get("reward", 0),
		]
		active_lbl.add_theme_font_size_override("font_size", 14)
		active_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		active_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		active_row.add_child(active_lbl)

		var abandon_btn = Button.new()
		abandon_btn.text = "Abandon"
		abandon_btn.custom_minimum_size = Vector2(80, 28)
		abandon_btn.add_theme_font_size_override("font_size", 12)
		abandon_btn.pressed.connect(func():
			var bounty_planet = ResourceManager.active_bounty.get("planet", "")
			var bounty_name = ResourceManager.active_bounty.get("name", "Unknown")
			ResourceManager.active_bounty = {}
			if bounty_planet != "":
				ResourceManager.adjust_reputation(bounty_planet, -10)
				ResourceManager.add_log("Abandoned bounty on %s. Reputation with %s damaged." % [bounty_name, bounty_planet], "event")
			_build_ui()
		)
		active_row.add_child(abandon_btn)

		var note = Label.new()
		note.text = "Complete your current bounty before taking another."
		note.add_theme_font_size_override("font_size", 12)
		note.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vbox.add_child(note)
		return

	# Available bounties
	if _bounties.is_empty():
		var empty = Label.new()
		empty.text = "No bounties available. Check back later."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 14)
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_vbox.add_child(empty)
		return

	for bounty in _bounties:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_vbox.add_child(row)

		# Skull icon
		var skull = Label.new()
		skull.text = "X"
		skull.custom_minimum_size = Vector2(20, 0)
		skull.add_theme_font_size_override("font_size", 16)
		skull.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
		skull.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(skull)

		# Name
		var name_lbl = Label.new()
		name_lbl.text = bounty["name"]
		name_lbl.custom_minimum_size = Vector2(120, 0)
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.8))
		row.add_child(name_lbl)

		# Location
		var loc_lbl = Label.new()
		loc_lbl.text = "near %s" % bounty["planet"]
		loc_lbl.custom_minimum_size = Vector2(120, 0)
		loc_lbl.add_theme_font_size_override("font_size", 14)
		loc_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
		row.add_child(loc_lbl)

		# Reward
		var reward_lbl = Label.new()
		reward_lbl.text = "$%d" % bounty["reward"]
		reward_lbl.custom_minimum_size = Vector2(60, 0)
		reward_lbl.add_theme_font_size_override("font_size", 15)
		reward_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		row.add_child(reward_lbl)

		# Accept button
		var accept_btn = Button.new()
		accept_btn.text = "HUNT"
		accept_btn.custom_minimum_size = Vector2(70, 28)
		accept_btn.add_theme_font_size_override("font_size", 13)
		var b = bounty  # capture for lambda
		accept_btn.pressed.connect(func():
			if ResourceManager.accept_bounty(b):
				AudioManager.play_sfx("sfx_trade")
				_build_ui()
		)
		row.add_child(accept_btn)

## Shared by the station rumor tab, the bar's Rumors tab and Sol News on Earth.
## Called from other scripts as load("res://scripts/station_menu.gd").build_rumor_rows(vbox).
static func build_rumor_rows(vbox: VBoxContainer) -> void:
	var title = Label.new()
	title.text = "RUMORS — SOME OF THESE ARE LIES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.9, 0.6, 1.0))
	vbox.add_child(title)
	var list: Array = ResourceManager.current_rumors()
	if list.is_empty():
		var none = Label.new()
		none.text = "Quiet week. Nobody's talking."
		none.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox.add_child(none)
		return
	for r in list:
		var row = Label.new()
		row.autowrap_mode = TextServer.AUTOWRAP_WORD
		row.add_theme_font_size_override("font_size", 13)
		if r.get("revealed", false) and not r.get("is_true", true):
			row.text = "[LIE] " + r["text"]
			row.add_theme_color_override("font_color", Color(0.6, 0.35, 0.35))
		elif r.get("revealed", false):
			row.text = "[OK] " + r["text"]
			row.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
		else:
			row.text = "- " + r["text"]
		vbox.add_child(row)
	var tip = Label.new()
	tip.text = "Whisper on Uranus knows which ones are lies."
	tip.add_theme_font_size_override("font_size", 11)
	tip.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	vbox.add_child(tip)

func _build_garage() -> void:
	# Repair
	var repair_cost = (ResourceManager.ship_max_hp - ResourceManager.ship_hp) * ResourceManager.REPAIR_COST_PER_HP
	var repair_btn = Button.new()
	if ResourceManager.ship_hp >= ResourceManager.ship_max_hp:
		repair_btn.text = "Hull Integrity: 100%"
		repair_btn.disabled = true
	else:
		repair_btn.text = "Repair Hull — $%d (HP: %d/%d)" % [repair_cost, ResourceManager.ship_hp, ResourceManager.ship_max_hp]
		repair_btn.disabled = ResourceManager.money < repair_cost
	repair_btn.custom_minimum_size = Vector2(0, 36)
	repair_btn.add_theme_font_size_override("font_size", 14)
	repair_btn.pressed.connect(func():
		if ResourceManager.spend_money(repair_cost):
			ResourceManager.ship_hp = ResourceManager.ship_max_hp
			var ship = get_tree().get_first_node_in_group("player")
			if ship:
				ship.hp = ResourceManager.ship_max_hp
				ship.hp_changed.emit(ship.hp, ResourceManager.ship_max_hp)
			AudioManager.play_sfx("sfx_trade")
			_build_ui()
	)
	_vbox.add_child(repair_btn)

	# Fuel refill
	var fuel_needed = ResourceManager.ship_max_fuel - ResourceManager.ship_fuel
	var fuel_cost = int(ceil(fuel_needed / 25.0)) * ResourceManager.FUEL_REFILL_COST
	var fuel_btn = Button.new()
	if fuel_needed < 1.0:
		fuel_btn.text = "Fuel Tank: FULL"
		fuel_btn.disabled = true
	else:
		fuel_btn.text = "Refuel — $%d (Fuel: %d/%d)" % [fuel_cost, int(ResourceManager.ship_fuel), int(ResourceManager.ship_max_fuel)]
		fuel_btn.disabled = ResourceManager.money < ResourceManager.FUEL_REFILL_COST
	fuel_btn.custom_minimum_size = Vector2(0, 36)
	fuel_btn.add_theme_font_size_override("font_size", 14)
	fuel_btn.pressed.connect(func():
		# Buy in 25-unit increments
		while ResourceManager.ship_fuel < ResourceManager.ship_max_fuel and ResourceManager.spend_money(ResourceManager.FUEL_REFILL_COST):
			ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + 25.0, ResourceManager.ship_max_fuel)
		AudioManager.play_sfx("sfx_trade")
		_build_ui()
	)
	_vbox.add_child(fuel_btn)

	# Cargo insurance
	if not ResourceManager.cargo_insurance:
		var ins_btn = Button.new()
		ins_btn.text = "Cargo Insurance — $%d (keep cargo on death)" % ResourceManager.CARGO_INSURANCE_COST
		ins_btn.custom_minimum_size = Vector2(0, 36)
		ins_btn.add_theme_font_size_override("font_size", 14)
		ins_btn.disabled = ResourceManager.money < ResourceManager.CARGO_INSURANCE_COST
		ins_btn.pressed.connect(func():
			if ResourceManager.spend_money(ResourceManager.CARGO_INSURANCE_COST):
				ResourceManager.cargo_insurance = true
				AudioManager.play_sfx("sfx_trade")
				_build_ui()
		)
		_vbox.add_child(ins_btn)
	else:
		var ins_lbl = Label.new()
		ins_lbl.text = "Cargo Insurance: ACTIVE"
		ins_lbl.add_theme_font_size_override("font_size", 14)
		ins_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		ins_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vbox.add_child(ins_lbl)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		closed.emit()
