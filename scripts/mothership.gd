extends CharacterBody2D

## Alien Mothership — final boss. Three of these spawn at $100K.
## Larger, tougher, and meaner than regular bosses.

signal destroyed(pos: Vector2)
signal mothership_defeated
signal mothership_hp_changed(current: int, maximum: int)

@export var hp: int = 2000
@export var max_hp: int = 2000
@export var move_speed: float = 60.0
@export var bullet_scene: PackedScene
@export var kill_reward: int = 2000
@export var xp_reward: int = 2000

var _target: Node2D = null
var _attack_timer: float = 0.0
var _attack_cycle: int = 0
var _charge_cooldown: float = 0.0
var _is_charging: bool = false
var _charge_dir: Vector2 = Vector2.ZERO
var _charge_speed: float = 400.0
var _charge_duration: float = 0.0

var _phase: int = 1
var _time: float = 0.0
var _flash_timer: float = 0.0
var _flash_color: Color = Color.WHITE

# Orbit around the sun
var _orbit_center: Vector2 = Vector2.ZERO
var _orbit_radius: float = 14000.0
var _orbit_angle: float = 0.0
var _orbit_speed: float = 0.0002  # very slow orbit
var _chasing: bool = false  # switches to chase when player is nearby

# Pulse wave — visible sonar ping so player can find the mothership
var _pulse_waves: Array = []  # each entry: { "radius": float, "alpha": float }
var _pulse_cooldown: float = 0.0
const PULSE_INTERVAL := 4.0
const PULSE_MAX_RADIUS := 4000.0
const PULSE_SPEED := 600.0

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	add_to_group("mothership")
	mothership_hp_changed.emit(hp, max_hp)

func setup_orbit(center: Vector2, start_angle: float) -> void:
	_orbit_center = center
	_orbit_angle = start_angle
	global_position = _orbit_center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * _orbit_radius

func _process(delta: float) -> void:
	_time += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta

	# Emit pulse waves periodically
	_pulse_cooldown -= delta
	if _pulse_cooldown <= 0:
		_pulse_cooldown = PULSE_INTERVAL
		_pulse_waves.append({"radius": 50.0, "alpha": 0.6})

	# Update existing waves
	var i = _pulse_waves.size() - 1
	while i >= 0:
		_pulse_waves[i]["radius"] += PULSE_SPEED * delta
		_pulse_waves[i]["alpha"] = 0.6 * (1.0 - _pulse_waves[i]["radius"] / PULSE_MAX_RADIUS)
		if _pulse_waves[i]["radius"] >= PULSE_MAX_RADIUS:
			_pulse_waves.remove_at(i)
		i -= 1
	queue_redraw()

func _physics_process(delta: float) -> void:
	_find_target()
	if _target == null:
		_orbit(delta)
		return
	if _target.get("is_dead") == true:
		_orbit(delta)
		return

	var dist_to_player = global_position.distance_to(_target.global_position)

	# Chase if player is within 2000, otherwise orbit
	_chasing = dist_to_player < 2000

	if not _chasing:
		_orbit(delta)
		return

	# Update phase
	var hp_pct = float(hp) / float(max_hp)
	if hp_pct < 0.3:
		_phase = 3
	elif hp_pct < 0.6:
		_phase = 2
	else:
		_phase = 1

	# Handle charging
	if _is_charging:
		_do_charge(delta)
		return

	var dir_to_player = (_target.global_position - global_position).normalized()

	# Movement: orbit player at medium range
	var preferred_dist = 300.0
	if dist_to_player > preferred_dist + 100:
		velocity = dir_to_player * move_speed
	elif dist_to_player < preferred_dist - 100:
		velocity = -dir_to_player * move_speed * 0.4
	else:
		var perp = Vector2(-dir_to_player.y, dir_to_player.x)
		velocity = perp * move_speed * 0.6

	if _phase >= 2:
		velocity += Vector2(sin(Time.get_ticks_msec() * 0.002) * 30, cos(Time.get_ticks_msec() * 0.003) * 30)

	move_and_slide()
	rotation = dir_to_player.angle()

	# Attacks
	var attack_interval = 2.5 / _phase
	_attack_timer -= delta
	_charge_cooldown -= delta

	if _attack_timer <= 0 and dist_to_player < 900:
		_attack_timer = attack_interval
		_attack_cycle = (_attack_cycle + 1) % 4
		match _attack_cycle:
			0:
				_fire_aimed(dir_to_player)
			1:
				_fire_spread(dir_to_player)
			2:
				_fire_ring()
			3:
				if _charge_cooldown <= 0:
					_start_charge(dir_to_player)
				else:
					_fire_spread(dir_to_player)

func _orbit(delta: float) -> void:
	_orbit_angle += _orbit_speed * delta
	var target_pos = _orbit_center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * _orbit_radius
	velocity = (target_pos - global_position) * 2.0
	move_and_slide()
	rotation = velocity.angle()

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func _fire_aimed(dir: Vector2) -> void:
	if bullet_scene == null:
		return
	var burst = 3 + _phase
	for i in range(burst):
		var b = bullet_scene.instantiate()
		b.global_position = global_position + dir * 40.0
		b.direction = dir
		b.damage = 8 + _phase * 2
		b.speed = 320.0 + _phase * 40.0
		get_parent().call_deferred("add_child", b)
		dir = dir.rotated(0.04 * (i - burst / 2.0))
	AudioManager.play_sfx("sfx_enemy_shoot", -6.0)

func _fire_spread(dir: Vector2) -> void:
	if bullet_scene == null:
		return
	var count = 7 + _phase * 2
	var arc = 1.5 + _phase * 0.2
	for i in range(count):
		var angle_offset = lerp(-arc / 2.0, arc / 2.0, float(i) / float(count - 1))
		var b = bullet_scene.instantiate()
		b.global_position = global_position + dir * 40.0
		b.direction = dir.rotated(angle_offset)
		b.damage = 6 + _phase * 2
		b.speed = 280.0
		get_parent().call_deferred("add_child", b)
	AudioManager.play_sfx("sfx_enemy_shoot", -4.0)

func _fire_ring() -> void:
	if bullet_scene == null:
		return
	# 360-degree ring of bullets
	var count = 12 + _phase * 4
	for i in range(count):
		var angle = TAU * float(i) / float(count)
		var dir = Vector2(cos(angle), sin(angle))
		var b = bullet_scene.instantiate()
		b.global_position = global_position + dir * 40.0
		b.direction = dir
		b.damage = 6
		b.speed = 250.0
		get_parent().call_deferred("add_child", b)
	AudioManager.play_sfx("sfx_enemy_shoot", -3.0)

func _start_charge(dir: Vector2) -> void:
	_is_charging = true
	_charge_dir = dir
	_charge_duration = 0.8
	_charge_cooldown = 6.0 / _phase
	_flash_timer = 0.2
	_flash_color = Color(0.3, 1.0, 0.3)

func _do_charge(delta: float) -> void:
	velocity = _charge_dir * _charge_speed
	move_and_slide()
	_charge_duration -= delta
	if _charge_duration <= 0:
		_is_charging = false
	if _target and is_instance_valid(_target):
		if global_position.distance_to(_target.global_position) < 50:
			if _target.has_method("take_damage"):
				_target.take_damage(20)

func take_damage(amount: int) -> void:
	hp -= amount
	mothership_hp_changed.emit(hp, max_hp)
	_flash_timer = 0.08
	_flash_color = Color.WHITE
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", 0.0)
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
	mothership_defeated.emit()
	queue_free()

func _draw() -> void:
	# Pulse waves — large expanding rings visible from far away
	for wave in _pulse_waves:
		var wave_color = Color(0.2, 1.0, 0.4, wave["alpha"])
		draw_arc(Vector2.ZERO, wave["radius"], 0, TAU, 64, wave_color, 2.0)

	var flashing := _flash_timer > 0.0
	var hp_pct := float(hp) / float(max_hp)

	var hull_color: Color
	match _phase:
		1: hull_color = Color(0.1, 0.4, 0.15)
		2: hull_color = Color(0.15, 0.6, 0.1)
		3: hull_color = Color(0.2, 0.8, 0.1)
		_: hull_color = Color(0.1, 0.4, 0.15)

	var pulse_speed := 3.0
	if _phase == 2: pulse_speed = 5.0
	elif _phase == 3: pulse_speed = 8.0
	var pulse := 0.5 + 0.5 * sin(_time * pulse_speed)

	if flashing:
		hull_color = _flash_color

	# Charge trail
	if _is_charging:
		var trail_dir := -_charge_dir.normalized()
		for i in range(6):
			var offset := trail_dir * (20.0 + float(i) * 14.0)
			var trail_radius := maxf(10.0 - float(i) * 1.5, 2.0)
			var trail_alpha := maxf(0.7 - float(i) * 0.12, 0.1)
			var trail_color: Color
			if flashing:
				trail_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, trail_alpha)
			else:
				trail_color = Color(0.2, 1.0, 0.3, trail_alpha)
			draw_circle(offset, trail_radius, trail_color)

	# Shield ring
	var shield_alpha := hp_pct * 0.4
	if shield_alpha > 0.01:
		var shield_color: Color
		if flashing:
			shield_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, shield_alpha)
		else:
			shield_color = Color(0.2, 1.0, 0.4, shield_alpha)
		draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 48, shield_color, 2.0)

	# Outer octagonal hull (larger than boss)
	var oct_radius := 35.0
	var oct_points := PackedVector2Array()
	for i in range(8):
		var angle := float(i) * TAU / 8.0 - PI / 8.0
		oct_points.append(Vector2(cos(angle), sin(angle)) * oct_radius)
	var oct_colors := PackedColorArray()
	for i in range(8):
		oct_colors.append(hull_color)
	draw_polygon(oct_points, oct_colors)

	# Inner hull
	var inner_radius := 24.0
	var inner_points := PackedVector2Array()
	for i in range(8):
		var angle := float(i) * TAU / 8.0 - PI / 8.0
		inner_points.append(Vector2(cos(angle), sin(angle)) * inner_radius)
	var inner_color: Color
	if flashing:
		inner_color = Color(_flash_color.r * 0.7, _flash_color.g * 0.7, _flash_color.b * 0.7)
	else:
		inner_color = Color(hull_color.r * 0.4, hull_color.g * 0.6, hull_color.b * 0.4)
	var inner_colors := PackedColorArray()
	for i in range(8):
		inner_colors.append(inner_color)
	draw_polygon(inner_points, inner_colors)

	# Pulsing core — green alien eye
	var core_radius := 7.0 + pulse * 3.0
	var core_color: Color
	if flashing:
		core_color = _flash_color
	else:
		match _phase:
			1: core_color = Color(0.3, 1.0, 0.4, 0.8 + pulse * 0.2)
			2: core_color = Color(0.5, 1.0, 0.2, 0.8 + pulse * 0.2)
			3: core_color = Color(0.8, 1.0, 0.1, 0.8 + pulse * 0.2)
			_: core_color = Color(0.3, 1.0, 0.4, 0.8 + pulse * 0.2)
	draw_circle(Vector2.ZERO, core_radius, core_color)

	# Core glow
	var glow_alpha := 0.3 + pulse * 0.3
	var glow_color: Color
	if flashing:
		glow_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, glow_alpha)
	else:
		glow_color = Color(core_color.r, core_color.g, core_color.b, glow_alpha)
	draw_arc(Vector2.ZERO, core_radius + 4.0, 0.0, TAU, 24, glow_color, 1.5)

	# 6 engine exhausts
	for idx in range(6):
		var exhaust_angle = PI + (float(idx) - 2.5) * 0.3
		var epos = Vector2(cos(exhaust_angle), sin(exhaust_angle)) * 28.0
		var flicker := 0.5 + 0.5 * sin(_time * 10.0 + float(idx) * 1.2)
		var flame_radius := 4.0 + flicker * 2.5
		var flame_color: Color
		if flashing:
			flame_color = _flash_color
		else:
			flame_color = Color(0.2, 1.0, 0.5 + flicker * 0.3, 0.7 + flicker * 0.3)
		draw_circle(epos, flame_radius, flame_color)

	# 3 weapon prongs at the front
	for idx in range(3):
		var prong_angle = (float(idx) - 1.0) * 0.4
		var prong_base = Vector2(cos(prong_angle), sin(prong_angle)) * 30.0
		var prong_tip = Vector2(cos(prong_angle), sin(prong_angle)) * 42.0
		var prong_color: Color
		if flashing:
			prong_color = _flash_color
		else:
			prong_color = Color(0.7, 0.9, 0.7, 0.9)
		draw_line(prong_base, prong_tip, prong_color, 3.0)
		draw_circle(prong_tip, 2.5, prong_color)

	# Hull edge outlines
	for i in range(8):
		var a_pt: Vector2 = oct_points[i]
		var b_pt: Vector2 = oct_points[(i + 1) % 8]
		var edge_color: Color
		if flashing:
			edge_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, 0.6)
		else:
			edge_color = Color(minf(hull_color.r + 0.2, 1.0), minf(hull_color.g + 0.3, 1.0), minf(hull_color.b + 0.1, 1.0), 0.6)
		draw_line(a_pt, b_pt, edge_color, 1.0)
