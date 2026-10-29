extends Node2D

# Planet-specific sky particle configurations
const PLANET_PARTICLE_CONFIGS: Dictionary = {
	"Mercury": {"color": Color(1.0, 0.5, 0.1, 0.7), "vel_base": Vector2(0, -20), "vel_spread": Vector2(15, 10), "rate": 0.15, "size": 1.5, "life": 3.0},
	"Venus": {"color": Color(0.7, 0.8, 0.2, 0.5), "vel_base": Vector2(5, 8), "vel_spread": Vector2(8, 3), "rate": 0.1, "size": 2.0, "life": 4.0},
	"Earth": {"color": Color(1.0, 1.0, 1.0, 0.3), "vel_base": Vector2(15, 0), "vel_spread": Vector2(5, 3), "rate": 0.05, "size": 4.0, "life": 6.0},
	"Mars": {"color": Color(0.7, 0.3, 0.1, 0.5), "vel_base": Vector2(25, -2), "vel_spread": Vector2(10, 5), "rate": 0.2, "size": 1.5, "life": 3.0},
	"Jupiter": {"color": Color(0.8, 0.6, 1.0, 0.9), "vel_base": Vector2(0, 5), "vel_spread": Vector2(20, 20), "rate": 0.02, "size": 3.0, "life": 0.3},
	"Saturn": {"color": Color(1.0, 0.85, 0.4, 0.6), "vel_base": Vector2(30, -5), "vel_spread": Vector2(10, 3), "rate": 0.12, "size": 2.5, "life": 2.5},
	"Uranus": {"color": Color(0.3, 0.8, 0.9, 0.6), "vel_base": Vector2(3, 6), "vel_spread": Vector2(5, 2), "rate": 0.15, "size": 2.0, "life": 5.0},
	"Neptune": {"color": Color(0.7, 0.8, 1.0, 0.5), "vel_base": Vector2(2, 5), "vel_spread": Vector2(8, 2), "rate": 0.18, "size": 2.5, "life": 4.0},
	"Pluto": {"color": Color(0.4, 0.35, 0.5, 0.4), "vel_base": Vector2(1, -3), "vel_spread": Vector2(3, 2), "rate": 0.08, "size": 1.5, "life": 6.0},
}

# City names and lore — plausible locations for each planet
const CITY_LORE: Dictionary = {
	"Mercury": {
		"city": "Caloris Forge",
		"location": "Caloris Basin, Mercury",
		"subtitle": "Underground mining hub carved into the crater wall",
	},
	"Venus": {
		"city": "Cloudport Aphrodite",
		"location": "Upper Atmosphere, Venus",
		"subtitle": "Floating city at 50km altitude above the acid clouds",
	},
	"Earth": {
		"city": "New Shanghai",
		"location": "East Coast Megaplex, Earth",
		"subtitle": "The solar system's busiest trade hub",
	},
	"Mars": {
		"city": "Olympus Landing",
		"location": "Base of Olympus Mons, Mars",
		"subtitle": "Frontier settlement in the shadow of the volcano",
	},
	"Jupiter": {
		"city": "Ganymede Docks",
		"location": "Ganymede, Jupiter System",
		"subtitle": "Deep-space refueling port on Jupiter's largest moon",
	},
	"Saturn": {
		"city": "Titan Labs",
		"location": "Titan, Saturn System",
		"subtitle": "Research complex on the methane shores of Kraken Mare",
	},
	"Uranus": {
		"city": "Miranda's Edge",
		"location": "Miranda, Uranus System",
		"subtitle": "Smuggler haven in the fractured ice cliffs",
	},
	"Neptune": {
		"city": "Triton Frost",
		"location": "Triton, Neptune System",
		"subtitle": "Outpost beside cryovolcanic geysers",
	},
	"Pluto": {
		"city": "Erebus Outpost",
		"location": "Charon, Pluto System",
		"subtitle": "The last stop before the void — no laws, no rescue",
	},
}

# Planet-specific configurations
const PLANET_CONFIGS: Dictionary = {
	"Mercury": {"sky": Color(0.15, 0.08, 0.02), "ground": Color(0.4, 0.35, 0.3), "ground_alt": Color(0.35, 0.3, 0.25)},
	"Venus": {"sky": Color(0.5, 0.4, 0.1), "ground": Color(0.45, 0.25, 0.1), "ground_alt": Color(0.5, 0.2, 0.05)},
	"Earth": {"sky": Color(0.2, 0.4, 0.7), "ground": Color(0.2, 0.5, 0.2), "ground_alt": Color(0.25, 0.45, 0.2)},
	"Mars": {"sky": Color(0.4, 0.15, 0.05), "ground": Color(0.6, 0.25, 0.1), "ground_alt": Color(0.55, 0.2, 0.08)},
	"Jupiter": {"sky": Color(0.2, 0.1, 0.3), "ground": Color(0.3, 0.25, 0.35), "ground_alt": Color(0.25, 0.2, 0.3)},
	"Saturn": {"sky": Color(0.5, 0.4, 0.2), "ground": Color(0.4, 0.35, 0.3), "ground_alt": Color(0.35, 0.3, 0.25)},
	"Uranus": {"sky": Color(0.1, 0.3, 0.35), "ground": Color(0.3, 0.5, 0.55), "ground_alt": Color(0.25, 0.45, 0.5)},
	"Neptune": {"sky": Color(0.05, 0.1, 0.3), "ground": Color(0.2, 0.3, 0.5), "ground_alt": Color(0.15, 0.25, 0.45)},
	"Pluto": {"sky": Color(0.02, 0.01, 0.05), "ground": Color(0.15, 0.12, 0.2), "ground_alt": Color(0.12, 0.1, 0.18)},
}

# Building types in order and their draw function names
const BUILDING_ORDER: Array = ["Ship", "Market", "Bar", "Garage", "Unique"]
const BUILDING_DRAW_NAMES: Dictionary = {
	"Ship": "draw_hangar", "Market": "draw_market",
	"Bar": "draw_bar", "Garage": "draw_garage", "Unique": "draw_unique",
}
# Base sizes (scaled by planet via CityConfig)
const BUILDING_SIZES: Dictionary = {
	"Ship": {"w": 200.0, "h": 150.0},
	"Market": {"w": 300.0, "h": 250.0},
	"Bar": {"w": 250.0, "h": 200.0},
	"Garage": {"w": 275.0, "h": 225.0},
	"Unique": {"w": 325.0, "h": 275.0},
}

const GROUND_Y: float = 650.0

var _city_width: float = 1200.0
var _nova: CharacterBody2D = null
var _door_areas: Dictionary = {}  # building_name -> Area2D
var _door_positions: Dictionary = {}  # building_name -> float (x position of door center)
var _active_menu: CanvasLayer = null  # currently open building menu
var _events: Node = null  # random events system
var _esc_prev: bool = false  # edge detection for ESC key
var _city_pause_menu: Node = null
var _j_prev: bool = false

# City HUD elements
var _city_hud: CanvasLayer = null
var _hud_money: Label = null
var _hud_planet: Label = null
var _hud_hp: Label = null
var _hud_fuel: Label = null
var _hud_hint: Label = null

# Atmospheric visual effects
var _time: float = 0.0
var _stars: Array = []  # {pos: Vector2, phase: float, brightness: float}
var _sky_particles: Array = []  # {pos: Vector2, vel: Vector2, life: float, max_life: float, color: Color, size: float}
var _windows: Array = []  # {rect: Rect2, color: Color, flicker_phase: float, flicker_speed: float}
var _door_refs: Dictionary = {}  # building_name -> ColorRect reference
var _neon_signs: Array = []  # {pos: Vector2, size: Vector2, color: Color, building: String}
var _ground_cracks: Array = []  # {start: Vector2, end: Vector2, color: Color}
var _particle_spawn_timer: float = 0.0
var _current_planet: String = "Earth"

# Parallax and building systems
var _parallax: Node2D = null
var _planet_buildings_script = null
var _building_nodes: Array = []
var _building_positions_arr: Array = []  # x-positions (center) for each building
var _building_widths: Array = []  # width for each building
var _props_node: Node2D = null
var _prop_data: Array = []  # [{type: String, pos: Vector2}]
var _npcs: Array = []  # CityNpc instances

func _ready() -> void:
	var planet = ResourceManager.current_planet
	if planet == "":
		planet = "Earth"
	_current_planet = planet

	# Get variable city width from CityConfig
	_city_width = CityConfig.get_city_width(planet)

	# Get planet building script reference
	_planet_buildings_script = _get_planet_buildings_script(planet)

	var config = PLANET_CONFIGS.get(planet, PLANET_CONFIGS["Earth"])

	# Create parallax system
	_parallax = preload("res://scripts/city_parallax.gd").new()
	_parallax.name = "Parallax"
	add_child(_parallax)

	# Build sky and ground first (before camera so parallax layers exist)
	_build_sky(config["sky"])
	_build_ground(config["ground"], config["ground_alt"])
	_build_walls()
	_build_buildings()
	_place_street_props()
	_spawn_npcs()
	_spawn_nova()
	_setup_camera()
	_build_city_hud(planet)
	_start_events()
	_generate_stars()
	_generate_ground_cracks(config)

func _get_planet_buildings_script(planet: String):
	match planet:
		"Mercury": return CityBuildingsMercury
		"Venus": return CityBuildingsVenus
		"Earth": return CityBuildingsEarth
		"Mars": return CityBuildingsMars
		"Jupiter": return CityBuildingsJupiter
		"Saturn": return CityBuildingsSaturn
		"Uranus": return CityBuildingsUranus
		"Neptune": return CityBuildingsNeptune
		"Pluto": return CityBuildingsPluto
		_: return CityBuildingsEarth

func _build_sky(color: Color) -> void:
	var sky = ColorRect.new()
	sky.color = color
	sky.position = Vector2(-200, -600)
	sky.size = Vector2(_city_width + 400, GROUND_Y + 600)
	sky.z_index = -10
	add_child(sky)

	# Procedural city skyline background
	var skyline = preload("res://scripts/city_skyline.gd").new()
	skyline.setup(_current_planet, _city_width)
	skyline.position = Vector2(0, GROUND_Y)
	skyline.z_index = -8
	add_child(skyline)

func _build_ground(color: Color, _alt_color: Color) -> void:
	# Visual ground
	var ground_visual = ColorRect.new()
	ground_visual.color = color
	ground_visual.position = Vector2(-200, GROUND_Y)
	ground_visual.size = Vector2(_city_width + 400, 200)
	ground_visual.z_index = -5
	add_child(ground_visual)

	# Ground collision (StaticBody2D)
	var ground_body = StaticBody2D.new()
	ground_body.position = Vector2(_city_width / 2.0 - 200, GROUND_Y)
	var ground_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(_city_width + 400, 40)
	ground_shape.shape = rect
	ground_shape.position = Vector2(0, 20)
	ground_body.add_child(ground_shape)
	add_child(ground_body)

func _build_walls() -> void:
	# Left wall — prevents Nova from walking off the left edge
	var left_wall = StaticBody2D.new()
	left_wall.position = Vector2(-10, 0)
	var left_shape = CollisionShape2D.new()
	var left_rect = RectangleShape2D.new()
	left_rect.size = Vector2(20, 800)
	left_shape.shape = left_rect
	left_wall.add_child(left_shape)
	add_child(left_wall)

	# Right wall — prevents Nova from walking off the right edge
	var right_wall = StaticBody2D.new()
	right_wall.position = Vector2(_city_width + 10, 0)
	var right_shape = CollisionShape2D.new()
	var right_rect = RectangleShape2D.new()
	right_rect.size = Vector2(20, 800)
	right_shape.shape = right_rect
	right_wall.add_child(right_shape)
	add_child(right_wall)

func _build_buildings() -> void:
	var positions = CityConfig.get_building_positions(_current_planet)
	# Scale building sizes based on city width ratio
	var width_ratio: float = _city_width / 4000.0  # Earth (4000) = 1.0 scale
	var scale_factor: float = clampf(width_ratio * 1.2, 0.7, 1.5)

	for i in range(BUILDING_ORDER.size()):
		var bname: String = BUILDING_ORDER[i]
		var base_size: Dictionary = BUILDING_SIZES[bname]
		var bwidth: float = base_size["w"] * scale_factor
		var bheight: float = base_size["h"] * scale_factor
		var x_pos: float = positions[i]
		var draw_name: String = BUILDING_DRAW_NAMES[bname]

		_building_positions_arr.append(x_pos)
		_building_widths.append(bwidth)

		# Create building Node2D — positioned at ground level (bottom-center)
		var building_node := Node2D.new()
		building_node.name = "Building_" + bname
		building_node.position = Vector2(x_pos, GROUND_Y)
		building_node.z_index = -2
		# Store as local vars for the closure
		var bw := bwidth
		var bh := bheight
		var script_ref = _planet_buildings_script
		var draw_fn := Callable(script_ref, draw_name)
		building_node.draw.connect(func(): draw_fn.call(building_node, bw, bh, _time))
		add_child(building_node)
		_building_nodes.append(building_node)

		# Building name label
		var label = Label.new()
		label.text = _get_building_display_name(bname)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(x_pos - bwidth / 2.0, GROUND_Y - bheight - 35)
		label.size = Vector2(bwidth, 35)
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
		add_child(label)

		# Door area highlight (subtle glow at building entrance — buildings draw their own doors)
		var door = ColorRect.new()
		door.color = Color(0.8, 0.7, 0.2, 0.0)  # Invisible — entrance drawn by building script
		door.position = Vector2(x_pos - 20, GROUND_Y - 56)
		door.size = Vector2(40, 56)
		door.z_index = -1
		add_child(door)
		_door_refs[bname] = door

		# Neon sign glow above door (generated relative to building position)
		var neon_pos = Vector2(x_pos - 32, GROUND_Y - 65)
		var neon_size = Vector2(64, 12)
		var neon_hue := float(i) / float(BUILDING_ORDER.size())
		var neon_color := Color.from_hsv(neon_hue, 0.8, 1.0)
		_neon_signs.append({"pos": neon_pos, "size": neon_size, "color": neon_color, "building": bname})

		# Window lights on building face
		var window_count = randi_range(2, 4)
		for wi in window_count:
			var wx = x_pos - bwidth / 2.0 + randi_range(6, int(bwidth) - 16)
			var wy = GROUND_Y - bheight + randi_range(8, int(bheight) - 40)
			var ww = randf_range(6.0, 10.0)
			var wh = randf_range(6.0, 8.0)
			var wcolor = Color(1.0, 0.9, 0.5, randf_range(0.3, 0.7))
			_windows.append({
				"rect": Rect2(wx, wy, ww, wh),
				"color": wcolor,
				"flicker_phase": randf() * TAU,
				"flicker_speed": randf_range(1.5, 5.0),
			})

		# Door Area2D for interaction
		var door_area = Area2D.new()
		door_area.monitoring = true
		door_area.monitorable = true
		door_area.position = Vector2(x_pos, GROUND_Y - 28)
		var door_collision = CollisionShape2D.new()
		var door_rect = RectangleShape2D.new()
		door_rect.size = Vector2(40, 40)
		door_collision.shape = door_rect
		door_area.add_child(door_collision)
		add_child(door_area)
		_door_areas[bname] = door_area
		_door_positions[bname] = x_pos

		# "Press E" hint label (hidden by default)
		var hint = Label.new()
		hint.name = bname + "Hint"
		hint.text = "Press E"
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.position = Vector2(x_pos - 40, GROUND_Y - 75)
		hint.size = Vector2(80, 24)
		hint.add_theme_font_size_override("font_size", 14)
		hint.add_theme_color_override("font_color", Color(1, 1, 0.5, 1))
		hint.visible = false
		add_child(hint)

func _place_street_props() -> void:
	var props_list = CityConfig.get_props(_current_planet)
	if props_list.is_empty():
		return
	# Place props in gaps between buildings
	for i in range(_building_positions_arr.size() - 1):
		var gap_start = _building_positions_arr[i] + _building_widths[i] / 2.0 + 10.0
		var gap_end = _building_positions_arr[i + 1] - _building_widths[i + 1] / 2.0 - 10.0
		var gap_width = gap_end - gap_start
		if gap_width < 20.0:
			continue
		# Place 1-3 props in gap
		var prop_count = mini(randi_range(1, 3), int(gap_width / 25.0))
		for p in prop_count:
			var px = gap_start + (gap_width / float(prop_count + 1)) * float(p + 1)
			var prop_type = props_list[randi() % props_list.size()]
			_prop_data.append({"type": prop_type, "pos": Vector2(px, GROUND_Y)})

	# Create a single Node2D that draws all props
	_props_node = Node2D.new()
	_props_node.name = "StreetProps"
	_props_node.z_index = -1
	_props_node.draw.connect(_draw_props)
	add_child(_props_node)

func _draw_props() -> void:
	for prop in _prop_data:
		CityProps.draw_prop(_props_node, prop["type"], prop["pos"], _time)

func _spawn_npcs() -> void:
	var roster = CityNpcRoster.get_npcs_for_planet(_current_planet)
	if roster.is_empty():
		return
	# Place NPCs in gaps between buildings, spread evenly
	var npc_positions: Array = []
	for i in range(_building_positions_arr.size() - 1):
		var gap_center = (_building_positions_arr[i] + _building_widths[i] / 2.0 + _building_positions_arr[i + 1] - _building_widths[i + 1] / 2.0) / 2.0
		npc_positions.append(gap_center)
	# Also add a position after the last building
	if _building_positions_arr.size() > 0:
		var last_idx = _building_positions_arr.size() - 1
		var after_last = _building_positions_arr[last_idx] + _building_widths[last_idx] / 2.0 + 60.0
		if after_last < _city_width - 50.0:
			npc_positions.append(after_last)
	# Assign NPCs to positions — spread evenly across the city, no stacking
	var npc_count: int = roster.size()
	var spread_positions: Array = []
	if npc_positions.size() > 0:
		for i in npc_count:
			# Distribute across all gap positions with offset to avoid stacking
			var base_idx: int = i % npc_positions.size()
			@warning_ignore("integer_division")
			var pass_num: int = i / npc_positions.size()
			var offset: float = float(pass_num) * 60.0 - float(pass_num) * 20.0
			spread_positions.append(npc_positions[base_idx] + offset)
	else:
		for i in npc_count:
			spread_positions.append(100.0 + float(i) * 120.0)

	for i in roster.size():
		var npc_data = roster[i]
		var npc_node = preload("res://scripts/city_npc.gd").new()
		var x_pos: float = spread_positions[i]
		npc_node.position = Vector2(x_pos, GROUND_Y)
		npc_node.z_index = 0
		npc_node.setup(npc_data)
		npc_node.interaction_requested.connect(_on_npc_interaction)
		add_child(npc_node)
		_npcs.append(npc_node)

func _on_npc_interaction(npc_data: Dictionary) -> void:
	if _active_menu != null:
		return
	var dialogue = load("res://scripts/city_dialogue.gd").new()
	dialogue.closed.connect(func(): _close_menu())
	_active_menu = dialogue
	add_child(dialogue)
	dialogue.setup(npc_data)

func _get_building_display_name(bname: String) -> String:
	if bname == "Unique":
		return _get_unique_building_name()
	if bname == "Ship":
		return "Your Ship"
	return bname

func _get_unique_building_name() -> String:
	match ResourceManager.current_planet:
		"Mercury": return "Scrapyard"
		"Venus": return "Black Market"
		"Earth": return "News Station"
		"Mars": return "Arena"
		"Jupiter": return "Fuel Depot"
		"Saturn": return "Upgrade Lab"
		"Uranus": return "Smuggler's Den"
		"Neptune": return "Ice Lounge"
		"Pluto": return "The Underworld"
		_: return "??? Building"

func _spawn_nova() -> void:
	var nova_scene = ResourceManager.safe_load("res://scenes/city/Nova.tscn")
	if nova_scene == null:
		push_error("Nova scene missing — cannot spawn player character")
		return
	_nova = nova_scene.instantiate()
	_nova.position = Vector2(90, GROUND_Y)  # Near the ship (CharacterBody2D origin at feet)
	add_child(_nova)

func _setup_camera() -> void:
	var camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	# Limit camera to city bounds (variable width)
	camera.limit_left = -100
	camera.limit_right = int(_city_width) + 100
	camera.limit_top = -200
	camera.limit_bottom = int(GROUND_Y) + 200
	_nova.add_child(camera)
	camera.make_current()

	# Set up parallax now that camera exists
	_parallax.setup(camera)

func _on_nova_entered_door(building_name: String) -> void:
	var planet = ResourceManager.current_planet
	if ResourceManager.is_building_locked(planet, building_name):
		_show_locked_message(building_name)
		return
	match building_name:
		"Ship":
			_return_to_space()
		"Market":
			_open_market()
		"Bar":
			_open_bar()
		"Garage":
			_open_garage()
		"Unique":
			_open_unique()

func _show_locked_message(building_name: String) -> void:
	var rep = ResourceManager.get_reputation(ResourceManager.current_planet)
	if _hud_hint:
		_hud_hint.text = "%s is locked! (Reputation: %d)" % [building_name, rep]
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree():
		return
	if _hud_hint:
		_hud_hint.text = "Press E at doors to enter  |  Walk to ship to leave"

func _return_to_space() -> void:
	ResourceManager.save_game()  # Auto-save on leaving city
	get_tree().change_scene_to_file("res://scenes/world/World.tscn")

func _open_market() -> void:
	var market = load("res://scripts/city_market.gd").new()
	market.closed.connect(func(): _close_menu())
	_active_menu = market
	add_child(market)

func _open_bar() -> void:
	var bar = load("res://scripts/city_bar.gd").new()
	bar.closed.connect(func(): _close_menu())
	_active_menu = bar
	add_child(bar)

func _open_garage() -> void:
	var garage = load("res://scripts/city_garage.gd").new()
	garage.closed.connect(func(): _close_menu())
	_active_menu = garage
	add_child(garage)

func _open_unique() -> void:
	var unique = load("res://scripts/city_unique.gd").new()
	unique.closed.connect(func(): _close_menu())
	_active_menu = unique
	add_child(unique)

func _open_journal() -> void:
	var journal = load("res://scripts/journal.gd").new()
	journal.closed.connect(func(): _close_menu())
	_active_menu = journal
	add_child(journal)

func _close_menu() -> void:
	if _active_menu:
		_active_menu.queue_free()
		_active_menu = null

func _open_city_pause_menu() -> void:
	if _city_pause_menu != null:
		return
	get_tree().paused = true
	_city_pause_menu = load("res://scripts/pause_menu.gd").new()
	_city_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_city_pause_menu.closed.connect(func():
		_city_pause_menu = null
	)
	add_child(_city_pause_menu)

func _process(delta: float) -> void:
	_time += delta
	_update_city_hud()
	_check_door_proximity()
	_update_sky_particles(delta)
	_update_door_glow(delta)
	queue_redraw()

	# Redraw building nodes every frame (they use _time for animation)
	for bn in _building_nodes:
		bn.queue_redraw()

	# Redraw props node every frame (animated props)
	if _props_node:
		_props_node.queue_redraw()

	# ESC to close menu or open pause menu (with edge detection)
	var esc_now = Input.is_physical_key_pressed(KEY_ESCAPE)
	if esc_now and not _esc_prev:
		if _active_menu:
			_close_menu()
		elif _city_pause_menu == null:
			_open_city_pause_menu()
	_esc_prev = esc_now

	# J to open journal
	var j_now = Input.is_physical_key_pressed(KEY_J)
	if j_now and not _j_prev and _active_menu == null:
		_open_journal()
	_j_prev = j_now

# ── Door proximity + interaction (all in one place) ─────
const DOOR_INTERACT_RANGE: float = 40.0
var _prev_nearby_door: String = ""
var _e_prev: bool = false

func _check_door_proximity() -> void:
	if _nova == null:
		return

	# Guard: clear stale menu references (freed nodes that weren't nulled)
	if _active_menu != null and not is_instance_valid(_active_menu):
		_active_menu = null

	# Find nearest door by X distance
	var nova_x: float = _nova.position.x
	var nearest_door: String = ""
	var nearest_dist: float = DOOR_INTERACT_RANGE
	for bname in _door_positions:
		var door_x: float = _door_positions[bname]
		var dx: float = abs(nova_x - door_x)
		if dx < nearest_dist:
			nearest_dist = dx
			nearest_door = bname

	# Update hint visibility on change
	if nearest_door != _prev_nearby_door:
		if _prev_nearby_door != "":
			var old_hint = get_node_or_null(_prev_nearby_door + "Hint")
			if old_hint:
				old_hint.visible = false
		if nearest_door != "":
			var hint = get_node_or_null(nearest_door + "Hint")
			if hint:
				hint.visible = true
		_prev_nearby_door = nearest_door

	# Check E key and enter door — all in the same frame, no signals needed
	var e_now: bool = Input.is_physical_key_pressed(KEY_E)
	if e_now and not _e_prev and nearest_door != "" and _active_menu == null:
		_on_nova_entered_door(nearest_door)
		_e_prev = true
	elif not e_now:
		_e_prev = false


# ── City HUD ──────────────────────────────────

func _build_city_hud(planet_name: String) -> void:
	_city_hud = CanvasLayer.new()
	_city_hud.layer = 5
	add_child(_city_hud)

	var lore = CITY_LORE.get(planet_name, {"city": planet_name, "location": "", "subtitle": ""})

	# City name (top center, large)
	_hud_planet = Label.new()
	_hud_planet.text = lore["city"]
	_hud_planet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_planet.anchors_preset = Control.PRESET_CENTER_TOP
	_hud_planet.anchor_left = 0.5
	_hud_planet.anchor_right = 0.5
	_hud_planet.offset_left = -200
	_hud_planet.offset_right = 200
	_hud_planet.offset_top = 6
	_hud_planet.offset_bottom = 28
	_hud_planet.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hud_planet.add_theme_font_size_override("font_size", 20)
	_hud_planet.add_theme_color_override("font_color", Color(1, 0.9, 0.5, 1))
	_city_hud.add_child(_hud_planet)

	# Location subtitle (below city name)
	var _hud_location = Label.new()
	_hud_location.text = lore["location"]
	_hud_location.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_location.anchors_preset = Control.PRESET_CENTER_TOP
	_hud_location.anchor_left = 0.5
	_hud_location.anchor_right = 0.5
	_hud_location.offset_left = -200
	_hud_location.offset_right = 200
	_hud_location.offset_top = 28
	_hud_location.offset_bottom = 44
	_hud_location.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hud_location.add_theme_font_size_override("font_size", 12)
	_hud_location.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.7))
	_city_hud.add_child(_hud_location)

	# Money (top left)
	_hud_money = Label.new()
	_hud_money.anchors_preset = Control.PRESET_TOP_LEFT
	_hud_money.offset_left = 10
	_hud_money.offset_top = 8
	_hud_money.offset_right = 200
	_hud_money.offset_bottom = 28
	_hud_money.add_theme_font_size_override("font_size", 16)
	_hud_money.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
	_city_hud.add_child(_hud_money)

	# HP (below money)
	_hud_hp = Label.new()
	_hud_hp.anchors_preset = Control.PRESET_TOP_LEFT
	_hud_hp.offset_left = 10
	_hud_hp.offset_top = 32
	_hud_hp.offset_right = 200
	_hud_hp.offset_bottom = 50
	_hud_hp.add_theme_font_size_override("font_size", 13)
	_city_hud.add_child(_hud_hp)

	# Fuel (below HP)
	_hud_fuel = Label.new()
	_hud_fuel.anchors_preset = Control.PRESET_TOP_LEFT
	_hud_fuel.offset_left = 10
	_hud_fuel.offset_top = 52
	_hud_fuel.offset_right = 200
	_hud_fuel.offset_bottom = 70
	_hud_fuel.add_theme_font_size_override("font_size", 13)
	_city_hud.add_child(_hud_fuel)

	# Hint (bottom center)
	_hud_hint = Label.new()
	_hud_hint.text = "Press E at doors to enter  |  Walk to ship to leave"
	_hud_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_hint.anchors_preset = Control.PRESET_CENTER_BOTTOM
	_hud_hint.anchor_left = 0.5
	_hud_hint.anchor_right = 0.5
	_hud_hint.anchor_top = 1.0
	_hud_hint.anchor_bottom = 1.0
	_hud_hint.offset_left = -250
	_hud_hint.offset_right = 250
	_hud_hint.offset_top = -30
	_hud_hint.offset_bottom = -8
	_hud_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hud_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hud_hint.add_theme_font_size_override("font_size", 12)
	_hud_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	_city_hud.add_child(_hud_hint)

func _update_city_hud() -> void:
	if _hud_money:
		_hud_money.text = "$%d" % ResourceManager.money

	if _hud_hp:
		_hud_hp.text = "HP: %d/%d" % [ResourceManager.ship_hp, ResourceManager.ship_max_hp]

	if _hud_fuel:
		var pct = int((ResourceManager.ship_fuel / ResourceManager.ship_max_fuel) * 100)
		_hud_fuel.text = "Fuel: %d%%" % pct
		if pct < 20:
			_hud_fuel.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))
		elif pct < 50:
			_hud_fuel.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
		else:
			_hud_fuel.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4, 1))

# ── Random Events ─────────────────────────────

func _start_events() -> void:
	_events = Node.new()
	_events.set_script(load("res://scripts/city_events.gd"))
	add_child(_events)
	_events.try_trigger_event()

# ── Atmospheric Visual Effects ─────────────────

func _generate_stars() -> void:
	var star_count = randi_range(30, 50)
	for i in star_count:
		_stars.append({
			"pos": Vector2(randf_range(-200, _city_width + 200), randf_range(-600, GROUND_Y - 20)),
			"phase": randf() * TAU,
			"brightness": randf_range(0.3, 1.0),
		})

func _generate_ground_cracks(config: Dictionary) -> void:
	var ground_color: Color = config["ground"]
	match _current_planet:
		"Mercury":
			# Metal grate lines — regular horizontal + vertical grid pattern
			for gx in range(-100, int(_city_width) + 100, 30):
				var shade = randf_range(-0.06, 0.02)
				var c = Color(clampf(ground_color.r + shade, 0.0, 1.0), clampf(ground_color.g + shade, 0.0, 1.0), clampf(ground_color.b + shade, 0.0, 1.0), 0.5)
				_ground_cracks.append({"start": Vector2(float(gx), GROUND_Y), "end": Vector2(float(gx), GROUND_Y + 8.0), "color": c})
			for gy_i in 4:
				var gy = GROUND_Y + float(gy_i) * 2.0
				var shade = randf_range(-0.06, 0.02)
				var c = Color(clampf(ground_color.r + shade, 0.0, 1.0), clampf(ground_color.g + shade, 0.0, 1.0), clampf(ground_color.b + shade, 0.0, 1.0), 0.4)
				_ground_cracks.append({"start": Vector2(-100.0, gy), "end": Vector2(_city_width + 100.0, gy), "color": c})
		"Venus":
			# Flowing acid channels — curved lines in yellow-green
			for i in 15:
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 6.0)
				var curve_len = randf_range(40.0, 120.0)
				var segments = randi_range(3, 6)
				for seg in segments:
					var t0 = float(seg) / float(segments)
					var t1 = float(seg + 1) / float(segments)
					var x0 = sx + curve_len * t0
					var y0 = sy + sin(t0 * 4.0) * 3.0
					var x1 = sx + curve_len * t1
					var y1 = sy + sin(t1 * 4.0) * 3.0
					_ground_cracks.append({"start": Vector2(x0, y0), "end": Vector2(x1, y1), "color": Color(0.5, 0.6, 0.1, 0.4)})
		"Earth":
			# Pavement with crosswalk stripes at intervals
			for gx in range(0, int(_city_width), 200):
				for stripe in 5:
					var sy = GROUND_Y + 1.0
					var stripe_x = float(gx) + float(stripe) * 8.0
					_ground_cracks.append({"start": Vector2(stripe_x, sy), "end": Vector2(stripe_x + 5.0, sy), "color": Color(0.9, 0.9, 0.8, 0.35)})
					_ground_cracks.append({"start": Vector2(stripe_x, sy + 3.0), "end": Vector2(stripe_x + 5.0, sy + 3.0), "color": Color(0.9, 0.9, 0.8, 0.3)})
			# Pavement lines
			for i in 10:
				var lx = randf_range(0, _city_width)
				_ground_cracks.append({"start": Vector2(lx, GROUND_Y + 0.5), "end": Vector2(lx + randf_range(30.0, 80.0), GROUND_Y + 0.5), "color": Color(0.7, 0.7, 0.6, 0.25)})
		"Mars":
			# Cracked red rock with scattered pebble dots
			for i in 25:
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 5.0)
				var ex = sx + randf_range(10.0, 70.0)
				var ey = sy + randf_range(-3.0, 4.0)
				_ground_cracks.append({"start": Vector2(sx, sy), "end": Vector2(ex, ey), "color": Color(0.4, 0.1, 0.05, 0.5)})
			# Pebble dots
			for i in 40:
				var px = randf_range(-50, _city_width + 50)
				var py = randf_range(GROUND_Y + 1.0, GROUND_Y + 6.0)
				_ground_cracks.append({"start": Vector2(px, py), "end": Vector2(px + 1.0, py + 1.0), "color": Color(0.5, 0.2, 0.1, 0.4)})
		"Jupiter":
			# Ice fractures in blue-white (Ganymede surface)
			for i in 30:
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 5.0)
				var ex = sx + randf_range(15.0, 80.0)
				var ey = sy + randf_range(-2.0, 2.0)
				var blue_shift = randf_range(0.0, 0.15)
				_ground_cracks.append({"start": Vector2(sx, sy), "end": Vector2(ex, ey), "color": Color(0.6 + blue_shift, 0.7 + blue_shift, 0.9, 0.4)})
		"Saturn":
			# Methane rivulet channels in orange-brown (Titan surface)
			for i in 18:
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 4.0)
				var curve_len = randf_range(30.0, 100.0)
				var segments = randi_range(4, 7)
				for seg in segments:
					var t0 = float(seg) / float(segments)
					var t1 = float(seg + 1) / float(segments)
					var x0 = sx + curve_len * t0
					var y0 = sy + sin(t0 * 3.0 + float(i)) * 2.0
					var x1 = sx + curve_len * t1
					var y1 = sy + sin(t1 * 3.0 + float(i)) * 2.0
					_ground_cracks.append({"start": Vector2(x0, y0), "end": Vector2(x1, y1), "color": Color(0.55, 0.35, 0.15, 0.45)})
		"Uranus":
			# Deep dark crevasse lines (Miranda's fractured ice)
			for i in 20:
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 3.0)
				var ex = sx + randf_range(20.0, 90.0)
				var ey = sy + randf_range(-1.0, 1.0)
				_ground_cracks.append({"start": Vector2(sx, sy), "end": Vector2(ex, ey), "color": Color(0.08, 0.15, 0.18, 0.6)})
				# Secondary fracture branching off
				if randf() > 0.5:
					var bx = (sx + ex) * 0.5
					var by = (sy + ey) * 0.5
					_ground_cracks.append({"start": Vector2(bx, by), "end": Vector2(bx + randf_range(-20.0, 20.0), by + randf_range(2.0, 5.0)), "color": Color(0.06, 0.12, 0.15, 0.5)})
		"Pluto":
			# Nitrogen ice fractures — sharp angular cracks with faint blue-purple tint
			for i in 25:
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 4.0)
				var ex = sx + randf_range(15.0, 60.0)
				var ey = sy + randf_range(-2.0, 2.0)
				_ground_cracks.append({"start": Vector2(sx, sy), "end": Vector2(ex, ey), "color": Color(0.25, 0.2, 0.35, 0.5)})
				# Branch fracture
				if randf() > 0.6:
					var mx = (sx + ex) * 0.5
					var my = (sy + ey) * 0.5
					_ground_cracks.append({"start": Vector2(mx, my), "end": Vector2(mx + randf_range(-15.0, 15.0), my + randf_range(1.0, 4.0)), "color": Color(0.2, 0.15, 0.3, 0.4)})
			# Scattered ice crystals (small dots)
			for i in 20:
				var cx = randf_range(-50, _city_width + 50)
				var cy = randf_range(GROUND_Y + 0.5, GROUND_Y + 5.0)
				_ground_cracks.append({"start": Vector2(cx, cy), "end": Vector2(cx + 1.0, cy + 1.0), "color": Color(0.4, 0.35, 0.5, 0.3)})
		"Neptune":
			# Frozen geyser vents — small circles approximated with short lines + upward lines
			for i in 12:
				var vx = randf_range(50, _city_width - 50)
				var vy = randf_range(GROUND_Y + 1.0, GROUND_Y + 4.0)
				# Vent circle (4 short segments forming a diamond)
				var r = randf_range(2.0, 4.0)
				_ground_cracks.append({"start": Vector2(vx - r, vy), "end": Vector2(vx, vy - r), "color": Color(0.5, 0.6, 0.8, 0.45)})
				_ground_cracks.append({"start": Vector2(vx, vy - r), "end": Vector2(vx + r, vy), "color": Color(0.5, 0.6, 0.8, 0.45)})
				_ground_cracks.append({"start": Vector2(vx + r, vy), "end": Vector2(vx, vy + r), "color": Color(0.5, 0.6, 0.8, 0.45)})
				_ground_cracks.append({"start": Vector2(vx, vy + r), "end": Vector2(vx - r, vy), "color": Color(0.5, 0.6, 0.8, 0.45)})
				# Upward geyser line
				_ground_cracks.append({"start": Vector2(vx, vy - r), "end": Vector2(vx + randf_range(-3.0, 3.0), vy - r - randf_range(5.0, 15.0)), "color": Color(0.6, 0.7, 0.9, 0.3)})
		_:
			# Generic fallback cracks
			for i in randi_range(20, 30):
				var sx = randf_range(-100, _city_width + 100)
				var sy = randf_range(GROUND_Y, GROUND_Y + 5.0)
				var shade = randf_range(-0.08, 0.04)
				var c = Color(clampf(ground_color.r + shade, 0.0, 1.0), clampf(ground_color.g + shade, 0.0, 1.0), clampf(ground_color.b + shade, 0.0, 1.0), 0.5)
				_ground_cracks.append({"start": Vector2(sx, sy), "end": Vector2(sx + randf_range(10.0, 60.0), sy + randf_range(-2.0, 3.0)), "color": c})

func _update_sky_particles(delta: float) -> void:
	var pconfig = PLANET_PARTICLE_CONFIGS.get(_current_planet, null)
	if pconfig == null:
		return

	# Spawn new particles
	_particle_spawn_timer += delta
	var rate: float = pconfig["rate"]
	if rate > 0.0 and _particle_spawn_timer >= rate:
		_particle_spawn_timer -= rate
		var vel_base: Vector2 = pconfig["vel_base"]
		var vel_spread: Vector2 = pconfig["vel_spread"]
		var particle = {
			"pos": Vector2(randf_range(-200, _city_width + 200), randf_range(-500, GROUND_Y - 50)),
			"vel": Vector2(vel_base.x + randf_range(-vel_spread.x, vel_spread.x), vel_base.y + randf_range(-vel_spread.y, vel_spread.y)),
			"life": pconfig["life"],
			"max_life": pconfig["life"],
			"color": pconfig["color"],
			"size": pconfig["size"],
		}
		_sky_particles.append(particle)

	# Update existing particles
	var i = _sky_particles.size() - 1
	while i >= 0:
		_sky_particles[i]["life"] -= delta
		if _sky_particles[i]["life"] <= 0.0:
			_sky_particles.remove_at(i)
		else:
			_sky_particles[i]["pos"] += _sky_particles[i]["vel"] * delta
		i -= 1

func _update_door_glow(_delta: float) -> void:
	if _nova == null:
		return
	var nova_x: float = _nova.position.x
	for bname in _door_refs:
		var door_ref: ColorRect = _door_refs[bname]
		if not is_instance_valid(door_ref):
			continue
		var door_x: float = _door_positions.get(bname, 0.0)
		var dist: float = abs(nova_x - door_x)
		if dist < DOOR_INTERACT_RANGE:
			# Subtle pulsing glow when near — buildings draw their own doors
			var pulse = 0.5 + 0.5 * sin(_time * 4.0)
			var glow_alpha: float = lerpf(0.15, 0.35, pulse)
			door_ref.color = Color(1.0, 0.95, 0.4, glow_alpha)
		else:
			door_ref.color = Color(0.8, 0.7, 0.2, 0.0)  # Invisible when not near

func _draw() -> void:
	_draw_planet_feature()
	_draw_stars()
	_draw_sky_particles()
	_draw_ground_cracks()
	_draw_neon_signs()
	_draw_windows()

func _draw_planet_feature() -> void:
	match _current_planet:
		"Jupiter":
			# Draw giant Jupiter in the sky (visible from Ganymede)
			var jupiter_center = Vector2(_city_width * 0.75, -200)
			var jupiter_radius = 180.0
			# Jupiter main body (banded)
			draw_circle(jupiter_center, jupiter_radius, Color(0.6, 0.4, 0.25, 0.25))
			draw_circle(jupiter_center, jupiter_radius * 0.95, Color(0.7, 0.5, 0.3, 0.2))
			# Horizontal bands
			for band_i in 7:
				var band_y = jupiter_center.y - jupiter_radius * 0.7 + band_i * jupiter_radius * 0.2
				var band_width = jupiter_radius * (0.6 + 0.4 * sin(float(band_i) * 1.3))
				var band_alpha = 0.08 + 0.04 * sin(_time * 0.3 + float(band_i))
				var band_color = Color(0.8, 0.55, 0.3, band_alpha) if band_i % 2 == 0 else Color(0.5, 0.35, 0.25, band_alpha)
				draw_line(Vector2(jupiter_center.x - band_width, band_y), Vector2(jupiter_center.x + band_width, band_y), band_color, 8.0)
			# Great Red Spot
			draw_circle(Vector2(jupiter_center.x + 40, jupiter_center.y + 30), 25.0, Color(0.8, 0.3, 0.15, 0.15))

		"Saturn":
			# Draw Saturn with rings visible from Titan
			var saturn_center = Vector2(_city_width * 0.8, -150)
			draw_circle(saturn_center, 80.0, Color(0.8, 0.7, 0.4, 0.2))
			# Rings (arcs)
			for ring_i in 4:
				var ring_radius = 100.0 + ring_i * 15.0
				var ring_alpha = 0.12 - ring_i * 0.02
				draw_arc(saturn_center, ring_radius, -0.3, PI + 0.3, 40, Color(0.9, 0.8, 0.5, ring_alpha), 3.0)

		"Earth":
			# Draw a crescent moon in the sky
			draw_circle(Vector2(_city_width * 0.85, -400), 25.0, Color(0.85, 0.85, 0.8, 0.5))
			draw_circle(Vector2(_city_width * 0.85 + 10, -403), 22.0, Color(0.2, 0.4, 0.7, 0.5))  # shadow creates crescent

		"Mercury":
			# Massive sun close and bright
			var sun_center = Vector2(_city_width * 0.5, -500)
			var sun_pulse = 1.0 + 0.05 * sin(_time * 2.0)
			draw_circle(sun_center, 120.0 * sun_pulse, Color(1.0, 0.95, 0.6, 0.08))
			draw_circle(sun_center, 80.0 * sun_pulse, Color(1.0, 0.9, 0.5, 0.12))
			draw_circle(sun_center, 40.0 * sun_pulse, Color(1.0, 0.85, 0.4, 0.2))

		"Venus":
			# Thick atmospheric haze layers
			for layer_i in 5:
				var ly = -400 + layer_i * 150
				var layer_alpha = 0.04 + 0.02 * sin(_time * 0.5 + float(layer_i))
				draw_rect(Rect2(-200, ly, _city_width + 400, 40), Color(0.6, 0.5, 0.15, layer_alpha))

		"Mars":
			# Olympus Mons silhouette in background
			var mons_pts = PackedVector2Array([
				Vector2(-100, GROUND_Y - 20),
				Vector2(200, -300),
				Vector2(350, -350),
				Vector2(500, -280),
				Vector2(_city_width + 100, GROUND_Y - 20),
			])
			draw_colored_polygon(mons_pts, Color(0.35, 0.12, 0.05, 0.15))

		"Uranus":
			# Uranus as a dim teal disc
			draw_circle(Vector2(_city_width * 0.3, -300), 60.0, Color(0.3, 0.7, 0.75, 0.12))
			draw_arc(Vector2(_city_width * 0.3, -300), 70.0, 0.5, PI + 0.5, 30, Color(0.4, 0.8, 0.85, 0.08), 2.0)

		"Neptune":
			# Neptune visible as a blue disc with one dark spot
			var nep_center = Vector2(_city_width * 0.7, -250)
			draw_circle(nep_center, 55.0, Color(0.15, 0.25, 0.7, 0.18))
			draw_circle(nep_center, 50.0, Color(0.2, 0.35, 0.8, 0.15))
			# Great Dark Spot
			draw_circle(Vector2(nep_center.x - 10, nep_center.y + 5), 12.0, Color(0.08, 0.12, 0.4, 0.1))

		"Pluto":
			# Pluto visible from Charon — small icy heart-shaped feature
			var pluto_center = Vector2(_city_width * 0.6, -350)
			draw_circle(pluto_center, 45.0, Color(0.35, 0.3, 0.25, 0.2))
			draw_circle(pluto_center, 42.0, Color(0.4, 0.35, 0.3, 0.15))
			# Heart shape (Tombaugh Regio) — two overlapping circles
			draw_circle(Vector2(pluto_center.x - 8, pluto_center.y - 5), 12.0, Color(0.7, 0.65, 0.6, 0.12))
			draw_circle(Vector2(pluto_center.x + 8, pluto_center.y - 5), 12.0, Color(0.7, 0.65, 0.6, 0.12))
			# Distant sun — tiny bright dot
			draw_circle(Vector2(200, -550), 3.0, Color(1.0, 0.95, 0.8, 0.6))
			draw_circle(Vector2(200, -550), 8.0, Color(1.0, 0.95, 0.8, 0.15))

func _draw_stars() -> void:
	for star in _stars:
		var pulse = sin(_time * 1.5 + star["phase"]) * 0.5 + 0.5
		var alpha = star["brightness"] * lerpf(0.2, 1.0, pulse)
		var star_color = Color(1.0, 1.0, 1.0, alpha)
		var pos: Vector2 = star["pos"]
		draw_rect(Rect2(pos.x - 1, pos.y - 1, 2, 2), star_color)

func _draw_sky_particles() -> void:
	for p in _sky_particles:
		var life_ratio: float = p["life"] / p["max_life"]
		# Fade in at start and out at end
		var fade: float = minf(life_ratio * 3.0, 1.0) * minf((1.0 - life_ratio) * 3.0, 1.0)
		var base_color: Color = p["color"]
		var c = Color(base_color.r, base_color.g, base_color.b, base_color.a * fade)
		var sz: float = p["size"]
		var pos: Vector2 = p["pos"]
		draw_rect(Rect2(pos.x - sz * 0.5, pos.y - sz * 0.5, sz, sz), c)

func _draw_ground_cracks() -> void:
	for crack in _ground_cracks:
		draw_line(crack["start"], crack["end"], crack["color"], 1.0)

func _draw_neon_signs() -> void:
	for neon in _neon_signs:
		var pulse = sin(_time * 2.5 + hash(neon["building"]) * 0.1) * 0.5 + 0.5
		var alpha = lerpf(0.3, 0.8, pulse)
		var base_color: Color = neon["color"]
		var c = Color(base_color.r, base_color.g, base_color.b, alpha)
		var pos: Vector2 = neon["pos"]
		var sz: Vector2 = neon["size"]
		# Draw outer glow (larger, more transparent)
		var glow_expand = 3.0
		var glow_color = Color(base_color.r, base_color.g, base_color.b, alpha * 0.3)
		draw_rect(Rect2(pos.x - glow_expand, pos.y - glow_expand, sz.x + glow_expand * 2, sz.y + glow_expand * 2), glow_color)
		# Draw neon sign
		draw_rect(Rect2(pos.x, pos.y, sz.x, sz.y), c)

func _draw_windows() -> void:
	for w in _windows:
		var flicker = sin(_time * w["flicker_speed"] + w["flicker_phase"])
		# Most windows stay lit; some flicker off briefly
		var base_alpha: float = w["color"].a
		var alpha: float
		if flicker < -0.7:
			# Brief flicker off
			alpha = base_alpha * 0.15
		else:
			alpha = base_alpha * lerpf(0.7, 1.0, (flicker + 1.0) * 0.5)
		var c = Color(w["color"].r, w["color"].g, w["color"].b, alpha)
		var r: Rect2 = w["rect"]
		draw_rect(r, c)
