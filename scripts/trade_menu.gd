extends CanvasLayer

signal closed

var _current_planet: Node = null
var _resource_rows: Dictionary = {}
var _weapon_rows: Dictionary = {}
var _repair_btn: Button = null
var _fuel_btn: Button = null

@onready var panel: Panel = $Panel
@onready var planet_name_label: Label = $Panel/VBoxContainer/PlanetNameLabel
@onready var points_label: Label = $Panel/VBoxContainer/PointsLabel
@onready var cargo_label: Label = $Panel/VBoxContainer/CargoLabel
@onready var resource_container: VBoxContainer = $Panel/VBoxContainer/ResourceContainer
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

# Upgrade buttons
@onready var upgrade_container: VBoxContainer = $Panel/VBoxContainer/UpgradeContainer
# Weapon shop
@onready var weapon_container: VBoxContainer = $Panel/VBoxContainer/WeaponContainer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_on_close)

	# Dynamically create sell rows from ResourceManager cargo keys
	for resource in ResourceManager.cargo.keys():
		var row = HBoxContainer.new()
		row.name = resource.capitalize() + "Row"

		var label = Label.new()
		label.custom_minimum_size = Vector2(80, 0)
		label.text = resource.capitalize()
		row.add_child(label)

		var stock_label = Label.new()
		stock_label.name = "Stock"
		stock_label.custom_minimum_size = Vector2(50, 0)
		stock_label.text = "x0"
		row.add_child(stock_label)

		var sell_btn = Button.new()
		sell_btn.name = "Sell"
		sell_btn.custom_minimum_size = Vector2(140, 0)
		sell_btn.text = "Sell"
		sell_btn.pressed.connect(func(): _sell(resource))
		row.add_child(sell_btn)

		resource_container.add_child(row)
		_resource_rows[resource] = row

	# Add Repair button to upgrade container
	_repair_btn = Button.new()
	_repair_btn.name = "RepairBtn"
	_repair_btn.custom_minimum_size = Vector2(250, 0)
	_repair_btn.pressed.connect(_on_repair)
	upgrade_container.add_child(_repair_btn)

	# Add Fuel Refill button to upgrade container
	_fuel_btn = Button.new()
	_fuel_btn.name = "FuelBtn"
	_fuel_btn.custom_minimum_size = Vector2(250, 0)
	_fuel_btn.pressed.connect(_on_refuel)
	upgrade_container.add_child(_fuel_btn)

	# Wire upgrade buttons
	for child in upgrade_container.get_children():
		if child is Button and child != _repair_btn and child != _fuel_btn:
			var upgrade_name = child.get_meta("upgrade_type", "")
			if upgrade_name != "":
				child.pressed.connect(func(): _upgrade(upgrade_name))

	# Dynamically create weapon rows
	for weapon_name in ResourceManager.WEAPON_DATA.keys():
		var row = HBoxContainer.new()
		row.name = weapon_name.capitalize() + "Row"

		var label = Label.new()
		label.custom_minimum_size = Vector2(80, 0)
		label.text = weapon_name.capitalize()
		row.add_child(label)

		var btn = Button.new()
		btn.name = "ActionBtn"
		btn.custom_minimum_size = Vector2(200, 0)
		btn.pressed.connect(func(): _weapon_action(weapon_name))
		row.add_child(btn)

		weapon_container.add_child(row)
		_weapon_rows[weapon_name] = row

func open(planet: Node) -> void:
	_current_planet = planet
	planet_name_label.text = planet.planet_name + " — Trading Post"
	_refresh_ui()
	visible = true
	# Game is already paused from mining scene

func _on_close() -> void:
	get_tree().paused = false
	visible = false
	_current_planet = null
	closed.emit()

func _refresh_ui() -> void:
	points_label.text = "Money: $%d" % ResourceManager.money
	var c = ResourceManager.cargo
	var cap = ResourceManager.cargo_capacity
	cargo_label.text = "Cargo [%d/%d]" % [ResourceManager.total_cargo(), cap]

	if _current_planet == null:
		return
	var pt = _current_planet.get_price_table()
	for resource in _resource_rows:
		_update_row(_resource_rows[resource], resource, pt)
	_update_upgrades()
	_refresh_weapons()
	_refresh_repair()
	_refresh_fuel()

func _update_row(row: HBoxContainer, resource: String, pt: Dictionary) -> void:
	var sell_price = pt[resource][1]
	var stock = ResourceManager.cargo[resource]
	for child in row.get_children():
		if child is Label and child.name == "Stock":
			child.text = "x%d" % stock
		if child is Button and child.name == "Sell":
			child.text = "Sell (+$%d)" % sell_price if sell_price > 0 else "Can't sell here"
			child.disabled = sell_price == 0 or stock == 0

func _update_upgrades() -> void:
	for child in upgrade_container.get_children():
		if child is Button and child != _repair_btn and child != _fuel_btn:
			var up_type = child.get_meta("upgrade_type", "")
			if up_type != "":
				var level = ResourceManager.upgrade_levels.get(up_type, 0)
				var cost = ResourceManager.UPGRADE_COSTS.get(up_type, 0)
				if level >= 3:
					child.text = "%s: MAX" % up_type.capitalize()
					child.disabled = true
				else:
					child.text = "%s Lv%d ($%d)" % [up_type.capitalize(), level + 1, cost]
					child.disabled = ResourceManager.money < cost

func _refresh_repair() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship and ship.has_method("get_hp"):
		var missing = ResourceManager.ship_max_hp - ship.get_hp()
		if missing <= 0:
			_repair_btn.text = "Repair: Full HP"
			_repair_btn.disabled = true
		else:
			var cost = missing * ResourceManager.REPAIR_COST_PER_HP
			_repair_btn.text = "Repair %d HP ($%d)" % [missing, cost]
			_repair_btn.disabled = ResourceManager.money < ResourceManager.REPAIR_COST_PER_HP
	else:
		_repair_btn.text = "Repair: N/A"
		_repair_btn.disabled = true

func _refresh_fuel() -> void:
	if ResourceManager.ship_fuel >= ResourceManager.ship_max_fuel:
		_fuel_btn.text = "Fuel: Tank Full"
		_fuel_btn.disabled = true
	else:
		var pct = int((ResourceManager.ship_fuel / ResourceManager.ship_max_fuel) * 100)
		_fuel_btn.text = "Refuel +25 ($%d) [%d%%]" % [ResourceManager.FUEL_REFILL_COST, pct]
		_fuel_btn.disabled = ResourceManager.money < ResourceManager.FUEL_REFILL_COST

func _sell(resource: String) -> void:
	var pt = _current_planet.get_price_table()
	var sell_price = pt[resource][1]
	if sell_price == 0 or ResourceManager.cargo[resource] == 0:
		return
	ResourceManager.remove_cargo(resource)
	ResourceManager.add_money(sell_price)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _upgrade(upgrade_type: String) -> void:
	if ResourceManager.purchase_upgrade(upgrade_type):
		AudioManager.play_sfx("sfx_trade")
		var ship = get_tree().get_first_node_in_group("player")
		if ship and ship.has_method("refresh_stats"):
			ship.refresh_stats()
	_refresh_ui()

func _on_repair() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	var healed = ResourceManager.purchase_repair(ship)
	if healed > 0 and ship and ship.has_method("heal"):
		ship.heal(healed)
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _on_refuel() -> void:
	if ResourceManager.purchase_fuel():
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _refresh_weapons() -> void:
	for weapon_name in _weapon_rows:
		var row = _weapon_rows[weapon_name]
		var btn = row.get_node("ActionBtn")
		var wd = ResourceManager.WEAPON_DATA[weapon_name]
		if weapon_name == ResourceManager.current_weapon:
			btn.text = "Equipped"
			btn.disabled = true
		elif weapon_name in ResourceManager.owned_weapons:
			btn.text = "Equip"
			btn.disabled = false
		else:
			btn.text = "Buy ($%d)" % wd["cost"]
			btn.disabled = ResourceManager.money < wd["cost"]

func _weapon_action(weapon_name: String) -> void:
	if weapon_name in ResourceManager.owned_weapons:
		ResourceManager.equip_weapon(weapon_name)
	else:
		ResourceManager.purchase_weapon(weapon_name)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()
