extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 30
@export var move_speed: float = 140.0
@export var damage_on_contact: int = 3
@export var kill_reward: int = 50
@export var xp_reward: int = 35
@export var mine_scene: PackedScene

const PREFERRED_DIST: float = 450.0
const MINE_INTERVAL: float = 4.0
const MAX_MINES: int = 5

var _target: Node2D = null
var _mine_timer: float = 2.0
var _mines: Array = []
var _time: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _physics_process(delta: float) -> void:
	_find_target()
	if _target == null or not _target.is_in_group("player"):
		return
	if _target.get("is_dead") == true:
		return

	var dir_to_player = (_target.global_position - global_position).normalized()
	var dist = global_position.distance_to(_target.global_position)

	if dist < PREFERRED_DIST - 50:
		velocity = -dir_to_player * move_speed
	elif dist > PREFERRED_DIST + 50:
		velocity = dir_to_player * move_speed * 0.6
	else:
		var perp = Vector2(-dir_to_player.y, dir_to_player.x)
		velocity = perp * move_speed * 0.5

	move_and_slide()
	rotation = dir_to_player.angle() + PI

	_mine_timer -= delta
	_mines = _mines.filter(func(m): return is_instance_valid(m))
	if _mine_timer <= 0 and _mines.size() < MAX_MINES:
		_mine_timer = MINE_INTERVAL
		_drop_mine()

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func _drop_mine() -> void:
	if mine_scene == null:
		return
	var mine = mine_scene.instantiate()
	mine.global_position = global_position
	_mines.append(mine)
	get_parent().call_deferred("add_child", mine)

func take_damage(amount: int) -> void:
	hp -= amount
	queue_redraw()
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", -4.0)
	ResourceManager.add_money(kill_reward)
	ResourceManager.add_xp(xp_reward)
	# Skill tree on-kill effects
	var tree_fuel := ResourceManager.get_tree_effect("fuel_restore_on_kill")
	if tree_fuel > 0:
		ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + ResourceManager.ship_max_fuel * tree_fuel, ResourceManager.ship_max_fuel)
	var tree_hp := int(ResourceManager.get_tree_effect("hp_on_kill"))
	if tree_hp > 0:
		ResourceManager.ship_hp = min(ResourceManager.ship_hp + tree_hp, ResourceManager.ship_max_hp)
	if randf() < ResourceManager.get_tree_effect("resource_drop_on_kill"):
		var resources = ["ore", "parts", "ice", "crystals"]
		ResourceManager.add_cargo(resources[randi() % resources.size()], 1)
	destroyed.emit(global_position)
	if randf() < 0.15:
		_drop_shield_pickup()
	queue_free()

func _drop_shield_pickup() -> void:
	var pickup_scene = load("res://scenes/world/ShieldPickup.tscn")
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position
		get_parent().call_deferred("add_child", pickup)

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage_on_contact)

func _draw() -> void:
	var base_color := Color(0.7, 0.75, 0.15)
	var dark_plate := Color(0.5, 0.55, 0.1)
	var bay_color := Color(0.25, 0.2, 0.1)
	var stripe_color := Color(0.4, 0.42, 0.08)
	var engine_color := Color(0.6, 0.8, 1.0)
	var sensor_color := Color(0.3, 1.0, 0.5)
	var mine_dot_color := Color(1.0, 0.2, 0.2)

	# Industrial hull - boxy hexagonal shape, wider than tall
	var hull := PackedVector2Array([
		Vector2(14, 0),
		Vector2(8, -10),
		Vector2(-10, -10),
		Vector2(-16, 0),
		Vector2(-10, 10),
		Vector2(8, 10),
	])
	draw_colored_polygon(hull, base_color)

	# Hull plating - inner polygon for armored look
	var plate := PackedVector2Array([
		Vector2(10, 0),
		Vector2(6, -7),
		Vector2(-7, -7),
		Vector2(-12, 0),
		Vector2(-7, 7),
		Vector2(6, 7),
	])
	draw_colored_polygon(plate, dark_plate)

	# Mine bay - rectangular opening at the rear
	var bay_glow := 0.0
	if _mine_timer < 1.0:
		bay_glow = (1.0 - _mine_timer) * 0.6
	var bay_c := Color(
		bay_color.r + bay_glow * 0.8,
		bay_color.g + bay_glow * 0.5,
		bay_color.b + bay_glow * 0.1
	)
	var bay_rect := PackedVector2Array([
		Vector2(-10, -5),
		Vector2(-16, -5),
		Vector2(-16, 5),
		Vector2(-10, 5),
	])
	draw_colored_polygon(bay_rect, bay_c)

	# Bay border lines
	draw_line(Vector2(-10, -5), Vector2(-16, -5), Color(0.6, 0.6, 0.1), 1.0)
	draw_line(Vector2(-10, 5), Vector2(-16, 5), Color(0.6, 0.6, 0.1), 1.0)

	# Warning stripes - hazard markings on hull
	draw_line(Vector2(0, -6), Vector2(3, -3), stripe_color, 1.5)
	draw_line(Vector2(-3, -6), Vector2(0, -3), stripe_color, 1.5)
	draw_line(Vector2(-6, -6), Vector2(-3, -3), stripe_color, 1.5)

	# Engine exhaust - blue-white at rear sides
	var exhaust_flicker := 0.7 + 0.3 * sin(_time * 12.0)
	var eng_alpha := exhaust_flicker
	var eng_c := Color(engine_color.r, engine_color.g, engine_color.b, eng_alpha)
	draw_circle(Vector2(-16, -6), 2.5, eng_c)
	draw_circle(Vector2(-16, 6), 2.5, eng_c)
	var eng_outer := Color(0.3, 0.5, 1.0, eng_alpha * 0.4)
	draw_circle(Vector2(-17, -6), 3.5, eng_outer)
	draw_circle(Vector2(-17, 6), 3.5, eng_outer)

	# Sensor dish at front - slowly rotating arc
	var sensor_angle := _time * 1.5
	var dish_center := Vector2(12, 0)
	var arc_points := PackedVector2Array()
	var arc_segments := 8
	var arc_radius := 4.0
	var arc_start := sensor_angle
	var arc_sweep := PI * 0.6
	for i in range(arc_segments + 1):
		var t := arc_start + arc_sweep * (float(i) / float(arc_segments))
		arc_points.append(dish_center + Vector2(cos(t), sin(t)) * arc_radius)
	for i in range(arc_segments):
		draw_line(arc_points[i], arc_points[i + 1], sensor_color, 1.5)
	draw_circle(dish_center, 1.5, sensor_color)

	# Mine count indicator - small mine icons along the top
	_mines = _mines.filter(func(m): return is_instance_valid(m))
	var active_count := _mines.size()
	for i in range(active_count):
		var mx := -6.0 + float(i) * 5.0
		var my := -13.0
		var mine_pos := Vector2(mx, my)
		draw_circle(mine_pos, 2.0, mine_dot_color)
		# Blinking halo around each mine icon
		var halo_alpha := 0.3 + 0.3 * sin(_time * 4.0 + float(i) * 1.2)
		var halo_c := Color(1.0, 0.4, 0.2, maxf(halo_alpha, 0.0))
		draw_arc(mine_pos, 3.5, 0, TAU, 12, halo_c, 1.0)

	# Hull outline
	for i in range(hull.size()):
		var a := hull[i]
		var b := hull[(i + 1) % hull.size()]
		draw_line(a, b, Color(0.85, 0.9, 0.2, 0.6), 1.0)
