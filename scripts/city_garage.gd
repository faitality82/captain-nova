extends CanvasLayer

signal closed

func _ready() -> void:
	layer = 10
	_build_ui()

func _build_ui() -> void:
	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -220
	panel.offset_top = -180
	panel.offset_right = 220
	panel.offset_bottom = 180
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 15
	vbox.offset_top = 15
	vbox.offset_right = -15
	vbox.offset_bottom = -15
	panel.add_child(vbox)

	# Header
	var header = Label.new()
	header.text = "Garage"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	vbox.add_child(header)

	# Money
	var money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(money_label)

	vbox.add_child(HSeparator.new())

	# HP Display
	var hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hp_label)

	# Repair button
	var repair_btn = Button.new()
	repair_btn.name = "RepairBtn"
	repair_btn.custom_minimum_size = Vector2(250, 40)
	repair_btn.pressed.connect(_on_repair)
	vbox.add_child(repair_btn)

	vbox.add_child(HSeparator.new())

	# Fuel Display
	var fuel_label = Label.new()
	fuel_label.name = "FuelLabel"
	fuel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(fuel_label)

	# Fuel button
	var fuel_btn = Button.new()
	fuel_btn.name = "FuelBtn"
	fuel_btn.custom_minimum_size = Vector2(250, 40)
	fuel_btn.pressed.connect(_on_refuel)
	vbox.add_child(fuel_btn)

	vbox.add_child(HSeparator.new())

	# Insurance section
	var ins_label = Label.new()
	ins_label.name = "InsLabel"
	ins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(ins_label)

	var ins_btn = Button.new()
	ins_btn.name = "InsBtn"
	ins_btn.custom_minimum_size = Vector2(250, 40)
	ins_btn.pressed.connect(_on_buy_insurance)
	vbox.add_child(ins_btn)

	vbox.add_child(HSeparator.new())

	# Fuel tank upgrade section
	var ft_btn = Button.new()
	ft_btn.name = "FuelTankBtn"
	ft_btn.custom_minimum_size = Vector2(250, 40)
	ft_btn.pressed.connect(_on_fuel_tank_upgrade)
	vbox.add_child(ft_btn)

	vbox.add_child(HSeparator.new())

	# Extra life section
	var life_btn = Button.new()
	life_btn.name = "LifeBtn"
	life_btn.custom_minimum_size = Vector2(250, 40)
	life_btn.pressed.connect(_on_buy_life)
	vbox.add_child(life_btn)

	vbox.add_child(HSeparator.new())

	# Paint shop button
	var paint_btn = Button.new()
	paint_btn.text = "Paint Shop"
	paint_btn.custom_minimum_size = Vector2(250, 40)
	paint_btn.pressed.connect(_open_paint_shop)
	vbox.add_child(paint_btn)

	vbox.add_child(HSeparator.new())

	# Leave button
	var leave_btn = Button.new()
	leave_btn.text = "Leave Garage"
	leave_btn.custom_minimum_size = Vector2(200, 40)
	leave_btn.pressed.connect(func(): closed.emit())
	vbox.add_child(leave_btn)

	_refresh_ui()

func _refresh_ui() -> void:
	for child in _find_all_children(self):
		if child is Label and child.name == "MoneyLabel":
			child.text = "Money: $%d" % ResourceManager.money
		elif child is Label and child.name == "HPLabel":
			child.text = "Ship HP: %d / %d" % [ResourceManager.ship_hp, ResourceManager.ship_max_hp]
		elif child is Label and child.name == "FuelLabel":
			var pct = int((ResourceManager.ship_fuel / ResourceManager.ship_max_fuel) * 100)
			child.text = "Fuel: %d%% (%d / %d)" % [pct, int(ResourceManager.ship_fuel), int(ResourceManager.ship_max_fuel)]
		elif child is Button and child.name == "RepairBtn":
			var missing = ResourceManager.ship_max_hp - ResourceManager.ship_hp
			if missing <= 0:
				child.text = "Repair: Full HP"
				child.disabled = true
			else:
				var cost = missing * ResourceManager.REPAIR_COST_PER_HP
				var h_mult: float = 1.0 + ResourceManager.get_tree_effect("buy_price_mult")
				cost = int(float(cost) * h_mult)
				child.text = "Repair %d HP ($%d)" % [missing, cost]
				child.disabled = ResourceManager.money < maxi(1, int(float(ResourceManager.REPAIR_COST_PER_HP) * h_mult))
		elif child is Button and child.name == "FuelBtn":
			if ResourceManager.ship_fuel >= ResourceManager.ship_max_fuel:
				child.text = "Fuel: Tank Full"
				child.disabled = true
			else:
				var fuel_cost = ResourceManager.FUEL_REFILL_COST
				var h_mult: float = 1.0 + ResourceManager.get_tree_effect("buy_price_mult")
				fuel_cost = int(float(fuel_cost) * h_mult)
				var pct = int((ResourceManager.ship_fuel / ResourceManager.ship_max_fuel) * 100)
				child.text = "Refuel +25 ($%d) [%d%%]" % [fuel_cost, pct]
				child.disabled = ResourceManager.money < fuel_cost
		elif child is Label and child.name == "InsLabel":
			if ResourceManager.cargo_insurance:
				child.text = "Cargo Insurance: ACTIVE"
			else:
				child.text = "Cargo Insurance: None"
		elif child is Button and child.name == "InsBtn":
			if ResourceManager.cargo_insurance:
				child.text = "Insurance: Active"
				child.disabled = true
			else:
				child.text = "Buy Cargo Insurance ($%d)" % ResourceManager.CARGO_INSURANCE_COST
				child.disabled = ResourceManager.money < ResourceManager.CARGO_INSURANCE_COST
		elif child is Button and child.name == "LifeBtn":
			if ResourceManager.lives >= 7:
				child.text = "Extra Life: MAX (7)"
				child.disabled = true
			else:
				var life_cost: int = 4000
				var h_mult: float = 1.0 + ResourceManager.get_tree_effect("buy_price_mult")
				life_cost = int(float(life_cost) * h_mult)
				child.text = "Buy Extra Life ($%d) [Lives: %d]" % [life_cost, ResourceManager.lives]
				child.disabled = ResourceManager.money < life_cost
		elif child is Button and child.name == "FuelTankBtn":
			var level = ResourceManager.upgrade_levels["fuel_tank"]
			var cost = ResourceManager.get_upgrade_cost("fuel_tank")
			if level >= 3:
				child.text = "Fuel Tank: MAX"
				child.disabled = true
			else:
				child.text = "Fuel Tank Lv%d -> Lv%d ($%d)" % [level, level + 1, cost]
				child.disabled = ResourceManager.money < cost

func _find_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_find_all_children(child))
	return result

func _on_repair() -> void:
	var missing = ResourceManager.ship_max_hp - ResourceManager.ship_hp
	if missing <= 0:
		return
	var cost = missing * ResourceManager.REPAIR_COST_PER_HP
	# Haggler discount
	var haggler_mult: float = 1.0 + ResourceManager.get_tree_effect("buy_price_mult")
	cost = int(float(cost) * haggler_mult)
	if ResourceManager.money < cost:
		# Repair as much as we can afford
		var per_hp_cost: int = maxi(1, int(float(ResourceManager.REPAIR_COST_PER_HP) * haggler_mult))
		@warning_ignore("integer_division")
		missing = ResourceManager.money / per_hp_cost
		if missing <= 0:
			return
		cost = missing * per_hp_cost
	ResourceManager.money -= cost
	ResourceManager.ship_hp = min(ResourceManager.ship_hp + missing, ResourceManager.ship_max_hp)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _on_refuel() -> void:
	# Apply Haggler discount to fuel cost
	var haggler_mult: float = 1.0 + ResourceManager.get_tree_effect("buy_price_mult")
	var fuel_cost: int = maxi(1, int(float(ResourceManager.FUEL_REFILL_COST) * haggler_mult))
	if ResourceManager.ship_fuel >= ResourceManager.ship_max_fuel:
		_refresh_ui()
		return
	if ResourceManager.money < fuel_cost:
		_refresh_ui()
		return
	ResourceManager.money -= fuel_cost
	ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + 25.0, ResourceManager.ship_max_fuel)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _on_buy_insurance() -> void:
	if ResourceManager.cargo_insurance:
		return
	if ResourceManager.spend_money(ResourceManager.CARGO_INSURANCE_COST):
		ResourceManager.cargo_insurance = true
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _on_fuel_tank_upgrade() -> void:
	if ResourceManager.purchase_upgrade("fuel_tank"):
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _on_buy_life() -> void:
	if ResourceManager.lives >= 7:
		return
	var life_cost: int = 4000
	var h_mult: float = 1.0 + ResourceManager.get_tree_effect("buy_price_mult")
	life_cost = int(float(life_cost) * h_mult)
	if ResourceManager.spend_money(life_cost):
		ResourceManager.lives += 1
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

var _paint_panel: Panel = null

func _open_paint_shop() -> void:
	if _paint_panel:
		_paint_panel.queue_free()
		_paint_panel = null
		return

	_paint_panel = Panel.new()
	_paint_panel.anchor_left = 0.5
	_paint_panel.anchor_top = 0.5
	_paint_panel.anchor_right = 0.5
	_paint_panel.anchor_bottom = 0.5
	_paint_panel.offset_left = 240
	_paint_panel.offset_top = -180
	_paint_panel.offset_right = 580
	_paint_panel.offset_bottom = 180
	add_child(_paint_panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 10
	vbox.offset_top = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10
	_paint_panel.add_child(vbox)

	var title = Label.new()
	title.text = "PAINT SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# Ship preview
	var preview = Node2D.new()
	preview.name = "ShipPreview"
	preview.set_script(load("res://scripts/ship_preview.gd"))
	var preview_container = SubViewportContainer.new()
	preview_container.custom_minimum_size = Vector2(300, 120)
	var sub_vp = SubViewport.new()
	sub_vp.size = Vector2i(300, 120)
	sub_vp.transparent_bg = true
	sub_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	preview.position = Vector2(150, 60)
	sub_vp.add_child(preview)
	preview_container.add_child(sub_vp)
	vbox.add_child(preview_container)

	vbox.add_child(HSeparator.new())

	# Color pickers
	_add_color_row(vbox, "Hull", ResourceManager.ship_hull_color, func(c: Color):
		ResourceManager.ship_hull_color = c)
	_add_color_row(vbox, "Accent", ResourceManager.ship_accent_color, func(c: Color):
		ResourceManager.ship_accent_color = c)
	_add_color_row(vbox, "Engine", ResourceManager.ship_engine_color, func(c: Color):
		ResourceManager.ship_engine_color = c)

	if ResourceManager.npc_powerups.get("franks_mustard", false):
		var frank_btn = Button.new()
		frank_btn.text = "Preset: Frank's Mustard"
		frank_btn.tooltip_text = "Hull mustard, accent ketchup, engines relish. Trophy paint from Phobos Meat Works."
		frank_btn.pressed.connect(func():
			ResourceManager.ship_hull_color = Color(0.93, 0.76, 0.2)
			ResourceManager.ship_accent_color = Color(0.72, 0.08, 0.08)
			ResourceManager.ship_engine_color = Color(0.5, 0.95, 0.3)
			_paint_panel.queue_free()
			_paint_panel = null
			_open_paint_shop())
		vbox.add_child(frank_btn)

	vbox.add_child(HSeparator.new())

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func():
		_paint_panel.queue_free()
		_paint_panel = null)
	vbox.add_child(close_btn)

func _add_color_row(parent: VBoxContainer, label_text: String, current: Color, on_change: Callable) -> void:
	var hbox = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text + ":"
	label.custom_minimum_size = Vector2(60, 0)
	hbox.add_child(label)

	var picker = ColorPickerButton.new()
	picker.color = current
	picker.custom_minimum_size = Vector2(180, 30)
	picker.edit_alpha = false
	picker.color_changed.connect(on_change)
	hbox.add_child(picker)

	parent.add_child(hbox)
