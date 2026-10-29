extends CanvasLayer

signal mining_done

var _current_planet: Node = null
var _miner_pos: Vector2 = Vector2(300, 350)
var _mine_speed: float = 200.0
var _mining_target: Dictionary = {}
var _mining_progress: float = 0.0
var _is_mining: bool = false
const MINE_TIME: float = 1.0  # seconds to mine one unit

var _resource_nodes: Array = []

@onready var panel: Panel = $Panel
@onready var miner_sprite: Sprite2D = $Panel/MinerSprite
@onready var info_label: Label = $Panel/InfoLabel
@onready var cargo_label: Label = $Panel/CargoLabel
@onready var leave_btn: Button = $Panel/LeaveButton
@onready var mine_area: Control = $Panel/MineArea

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	leave_btn.pressed.connect(_on_leave)

func open(planet: Node) -> void:
	_current_planet = planet
	_miner_pos = Vector2(300, 350)
	_is_mining = false
	_mining_progress = 0.0

	# Clear old nodes
	for node in _resource_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_resource_nodes.clear()

	# Determine which resources this planet has (resources with buy price > 0 means planet produces it)
	var pt = planet.get_price_table()
	var available: Array = []
	for resource in pt:
		if pt[resource][0] > 0:  # has a buy price = planet produces this
			available.append(resource)

	# If planet doesn't produce anything minable, add its sell specialties as minable
	if available.is_empty():
		for resource in pt:
			if pt[resource][1] > 0:
				available.append(resource)

	# Spawn 6-10 resource deposits at random positions
	var rng = RandomNumberGenerator.new()
	rng.seed = planet.planet_name.hash()
	var num_nodes = rng.randi_range(6, 10)
	for i in range(num_nodes):
		var res_type = available[i % available.size()]
		var node_ctrl = _create_mine_node(res_type, rng)
		mine_area.add_child(node_ctrl)
		_resource_nodes.append(node_ctrl)

	# Set planet surface color on panel
	info_label.text = planet.planet_name + " Surface — Walk to deposits and press SPACE to mine"
	_update_cargo_label()
	visible = true
	get_tree().paused = true

func _create_mine_node(res_type: String, rng: RandomNumberGenerator) -> Control:
	var node = Control.new()
	node.custom_minimum_size = Vector2(20, 20)
	node.size = Vector2(20, 20)
	node.position = Vector2(rng.randf_range(40, 540), rng.randf_range(40, 300))

	var rect = ColorRect.new()
	rect.size = Vector2(16, 16)
	rect.position = Vector2(2, 2)

	# Color by resource type
	var colors = {
		"ore": Color(1.0, 0.5, 0.0),
		"fuel": Color(0.2, 0.6, 1.0),
		"parts": Color(0.2, 1.0, 0.4),
		"ice": Color(0.7, 0.9, 1.0),
		"crystals": Color(1.0, 0.3, 0.8),
		"plasma": Color(0.6, 0.3, 0.8),
		"antimatter": Color(0.9, 0.1, 0.3),
		"biotech": Color(0.1, 0.9, 0.5),
		"nanites": Color(0.5, 0.5, 0.9),
		"dark_matter": Color(0.2, 0.0, 0.3),
		"artifacts": Color(0.9, 0.7, 0.1),
		"gravitonium": Color(0.4, 0.2, 0.6),
		"void_essence": Color(0.1, 0.1, 0.2),
		"starcore": Color(1.0, 0.9, 0.3),
	}
	rect.color = colors.get(res_type, Color.WHITE)
	node.add_child(rect)

	var label = Label.new()
	label.text = res_type.substr(0, 3).to_upper()
	label.add_theme_font_size_override("font_size", 10)
	label.position = Vector2(0, -14)
	node.add_child(label)

	node.set_meta("resource_type", res_type)
	node.set_meta("mined", false)
	return node

func _process(delta: float) -> void:
	if not visible:
		return

	# Miner movement (WASD)
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if _is_mining:
		# Mining in progress — hold still
		_mining_progress += delta
		info_label.text = "Mining %s... %.0f%%" % [_mining_target.get("type", ""), (_mining_progress / MINE_TIME) * 100]
		if _mining_progress >= MINE_TIME:
			_finish_mining()
		# Cancel mining if player moves
		if input_dir.length() > 0.1:
			_is_mining = false
			_mining_progress = 0.0
			info_label.text = "Mining cancelled — walk to a deposit and press SPACE"
	else:
		_miner_pos += input_dir * _mine_speed * delta
		_miner_pos.x = clampf(_miner_pos.x, 20, 580)
		_miner_pos.y = clampf(_miner_pos.y, 20, 370)

		# Check for mine action
		if Input.is_action_just_pressed("shoot"):  # Space bar
			_try_mine()

	miner_sprite.position = _miner_pos

func _try_mine() -> void:
	for node in _resource_nodes:
		if not is_instance_valid(node) or node.get_meta("mined", false):
			continue
		var node_center = node.position + Vector2(10, 10)
		if _miner_pos.distance_to(node_center) < 40:
			if not ResourceManager.can_carry():
				info_label.text = "Cargo full! Return to ship to sell."
				return
			_mining_target = {"node": node, "type": node.get_meta("resource_type")}
			_is_mining = true
			_mining_progress = 0.0
			return
	info_label.text = "No deposit nearby — walk closer to a colored deposit"

func _finish_mining() -> void:
	_is_mining = false
	_mining_progress = 0.0
	var res_type = _mining_target.get("type", "ore")
	if ResourceManager.add_cargo(res_type):
		AudioManager.play_sfx("sfx_mine")
		info_label.text = "Mined 1 %s!" % res_type.capitalize()
		var node = _mining_target.get("node")
		if is_instance_valid(node):
			node.set_meta("mined", true)
			node.modulate = Color(0.3, 0.3, 0.3, 0.5)
	else:
		info_label.text = "Cargo full!"
	_update_cargo_label()

func _update_cargo_label() -> void:
	var c = ResourceManager.cargo
	var used = ResourceManager.total_cargo()
	var cap = ResourceManager.cargo_capacity
	var items = ""
	for key in c:
		if c[key] > 0:
			items += " %s:%d" % [key.capitalize(), c[key]]
	if items == "":
		items = " Empty"
	cargo_label.text = "Cargo [%d/%d]%s" % [used, cap, items]

func _on_leave() -> void:
	visible = false
	# Don't unpause — trade menu will open next
	mining_done.emit()
