extends Node

var _event_timer: float = 30.0
var _event_active: bool = false
var _flare_active: bool = false
var _flare_timer: float = 0.0
var _convoy_ships: Array = []

func _process(delta: float) -> void:
	_event_timer -= delta
	if _event_timer <= 0 and not _event_active:
		_event_timer = randf_range(25.0, 40.0)
		if randf() < 0.05:
			_trigger_random_event()

	if _flare_active:
		_flare_timer -= delta
		if _flare_timer <= 0:
			_end_solar_flare()

func _trigger_random_event() -> void:
	var roll = randf()
	if roll < 0.33:
		_spawn_comet()
	elif roll < 0.66:
		_start_solar_flare()
	else:
		_spawn_convoy()

func _spawn_comet() -> void:
	_event_active = true
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null:
		_event_active = false
		return
	var comet = Node2D.new()
	comet.set_script(load("res://scripts/comet.gd"))
	var angle = randf() * TAU
	comet.global_position = ship.global_position + Vector2(cos(angle), sin(angle)) * 800
	comet.target_position = ship.global_position + Vector2(cos(angle + PI), sin(angle + PI)) * 1200
	get_parent().add_child(comet)
	comet.tree_exited.connect(func(): _event_active = false)

func _start_solar_flare() -> void:
	_event_active = true
	_flare_active = true
	_flare_timer = 10.0
	var sun = get_tree().get_first_node_in_group("sun")
	if sun and sun.has_method("start_flare"):
		sun.start_flare()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_interact_hint"):
		hud.show_interact_hint("SOLAR FLARE — STAY CLEAR!")

func _end_solar_flare() -> void:
	_flare_active = false
	_event_active = false
	var sun = get_tree().get_first_node_in_group("sun")
	if sun and sun.has_method("end_flare"):
		sun.end_flare()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("hide_interact_hint"):
		hud.hide_interact_hint()

func _spawn_convoy() -> void:
	_event_active = true
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null:
		_event_active = false
		return
	var planets = get_tree().get_nodes_in_group("planet")
	if planets.is_empty():
		_event_active = false
		return
	var dest_planet = planets[randi() % planets.size()]
	var spawn_offset = Vector2(randf_range(-500, 500), randf_range(-500, 500))
	_convoy_ships.clear()
	for i in range(randi_range(3, 4)):
		var convoy_ship = Node2D.new()
		convoy_ship.set_script(load("res://scripts/trade_convoy.gd"))
		convoy_ship.global_position = ship.global_position + spawn_offset + Vector2(i * 60, 0)
		convoy_ship.destination = dest_planet
		convoy_ship.tree_exited.connect(func(): _on_convoy_ship_gone())
		get_parent().add_child(convoy_ship)
		_convoy_ships.append(convoy_ship)

func _on_convoy_ship_gone() -> void:
	_convoy_ships = _convoy_ships.filter(func(s): return is_instance_valid(s))
	if _convoy_ships.is_empty():
		_event_active = false
