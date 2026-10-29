extends CharacterBody2D

## Boss enemy — spawns every 7 minutes with escalating difficulty.
## Three attack patterns: aimed shots, spread bursts, and charge attacks.

signal destroyed(pos: Vector2)
signal boss_defeated
signal boss_hp_changed(current: int, maximum: int)

@export var hp: int = 500
@export var max_hp: int = 500
@export var move_speed: float = 80.0
@export var bullet_scene: PackedScene
@export var kill_reward: int = 500
@export var xp_reward: int = 500
@export var boss_tier: int = 1  # 1, 2, or 3

var _target: Node2D = null
var _attack_timer: float = 0.0
var _attack_cycle: int = 0  # cycles through attack patterns
var _charge_cooldown: float = 0.0
var _is_charging: bool = false
var _charge_dir: Vector2 = Vector2.ZERO
var _charge_speed: float = 500.0
var _charge_duration: float = 0.0

# Phase system: boss gets more aggressive at lower HP
var _phase: int = 1  # 1 = full HP, 2 = <60%, 3 = <30%

# Procedural draw state
var _time: float = 0.0
var _flash_timer: float = 0.0
var _flash_color: Color = Color.WHITE

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	boss_hp_changed.emit(hp, max_hp)
	match boss_tier:
		2: xp_reward = 1000
		3: xp_reward = 2000

func _process(delta: float) -> void:
	_time += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta
	queue_redraw()

func _physics_process(delta: float) -> void:
	_find_target()
	if _target == null:
		return
	if _target.get("is_dead") == true:
		return

	# Update phase
	var hp_pct = float(hp) / float(max_hp)
	if hp_pct < 0.3:
		_phase = 3
	elif hp_pct < 0.6:
		_phase = 2
	else:
		_phase = 1

	# Handle charging attack
	if _is_charging:
		_do_charge(delta)
		return

	var dir_to_player = (_target.global_position - global_position).normalized()
	var dist_to_player = global_position.distance_to(_target.global_position)

	# Movement: orbit the player at medium range
	var preferred_dist = 250.0
	if dist_to_player > preferred_dist + 80:
		velocity = dir_to_player * move_speed
	elif dist_to_player < preferred_dist - 80:
		velocity = -dir_to_player * move_speed * 0.4
	else:
		var perp = Vector2(-dir_to_player.y, dir_to_player.x)
		velocity = perp * move_speed * 0.6

	# Erratic movement in later phases
	if _phase >= 2:
		velocity += Vector2(sin(Time.get_ticks_msec() * 0.002) * 40, cos(Time.get_ticks_msec() * 0.003) * 40)

	move_and_slide()
	rotation = dir_to_player.angle()

	# Attack timing — faster in later phases
	var attack_interval = 2.0 / _phase
	_attack_timer -= delta
	_charge_cooldown -= delta

	if _attack_timer <= 0 and dist_to_player < 800:
		_attack_timer = attack_interval
		_attack_cycle = (_attack_cycle + 1) % 3
		match _attack_cycle:
			0:
				_fire_aimed(dir_to_player)
			1:
				_fire_spread(dir_to_player)
			2:
				if _charge_cooldown <= 0:
					_start_charge(dir_to_player)
				else:
					_fire_aimed(dir_to_player)

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func _fire_aimed(dir: Vector2) -> void:
	if bullet_scene == null:
		return
	# Fire a burst of 3 aimed shots
	var burst = 2 + _phase
	for i in range(burst):
		var b = bullet_scene.instantiate()
		b.global_position = global_position + dir * 30.0
		b.direction = dir
		b.damage = 3 + boss_tier * 1
		b.speed = 350.0 + _phase * 50.0
		get_parent().call_deferred("add_child", b)
		# Slight delay between shots via offset position
		dir = dir.rotated(0.05 * (i - burst / 2.0))
	AudioManager.play_sfx("sfx_enemy_shoot", -6.0)

func _fire_spread(dir: Vector2) -> void:
	if bullet_scene == null:
		return
	# Fan of bullets
	var count = 5 + _phase * 2
	var arc = 1.2 + _phase * 0.3
	for i in range(count):
		var angle_offset = lerp(-arc / 2.0, arc / 2.0, float(i) / float(count - 1))
		var b = bullet_scene.instantiate()
		b.global_position = global_position + dir * 30.0
		b.direction = dir.rotated(angle_offset)
		b.damage = 2 + boss_tier * 1
		b.speed = 300.0
		get_parent().call_deferred("add_child", b)
	AudioManager.play_sfx("sfx_enemy_shoot", -4.0)

func _start_charge(dir: Vector2) -> void:
	_is_charging = true
	_charge_dir = dir
	_charge_duration = 0.6
	_charge_cooldown = 8.0 / _phase
	# Flash warning
	_flash_timer = 0.15
	_flash_color = Color(1, 0.3, 0.3)

func _do_charge(delta: float) -> void:
	velocity = _charge_dir * _charge_speed * (1.0 + boss_tier * 0.3)
	move_and_slide()
	_charge_duration -= delta
	if _charge_duration <= 0:
		_is_charging = false

	# Contact damage during charge
	if _target and is_instance_valid(_target):
		if global_position.distance_to(_target.global_position) < 40:
			if _target.has_method("take_damage"):
				_target.take_damage(12 + boss_tier * 5)

func take_damage(amount: int) -> void:
	hp -= amount
	boss_hp_changed.emit(hp, max_hp)
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
	boss_defeated.emit()
	queue_free()

func _draw() -> void:
	var flashing := _flash_timer > 0.0
	var hp_pct := float(hp) / float(max_hp)

	# Phase-dependent hull color
	var hull_color: Color
	match _phase:
		1:
			hull_color = Color(0.6, 0.1, 0.1)
		2:
			hull_color = Color(0.8, 0.3, 0.1)
		3:
			hull_color = Color(1.0, 0.2, 0.2)
		_:
			hull_color = Color(0.6, 0.1, 0.1)

	# Phase-dependent pulse speed
	var pulse_speed := 3.0
	if _phase == 2:
		pulse_speed = 5.0
	elif _phase == 3:
		pulse_speed = 8.0

	var pulse := 0.5 + 0.5 * sin(_time * pulse_speed)

	# Override colors during flash
	if flashing:
		hull_color = _flash_color

	# --- Charge afterburner trail ---
	if _is_charging:
		var trail_dir := -_charge_dir.normalized()
		for i in range(5):
			var offset := trail_dir * (15.0 + float(i) * 12.0)
			var trail_radius := maxf(8.0 - float(i) * 1.5, 2.0)
			var trail_alpha := maxf(0.7 - float(i) * 0.14, 0.1)
			var trail_color: Color
			if flashing:
				trail_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, trail_alpha)
			else:
				trail_color = Color(1.0, 0.3 + float(i) * 0.05, 0.0, trail_alpha)
			draw_circle(offset, trail_radius, trail_color)

	# --- Shield ring (alpha based on HP) ---
	var shield_alpha := hp_pct * 0.35
	if shield_alpha > 0.01:
		var shield_color: Color
		if flashing:
			shield_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, shield_alpha)
		else:
			shield_color = Color(0.3, 0.5, 1.0, shield_alpha)
		draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 48, shield_color, 1.5)

	# --- Outer hexagonal hull ---
	var hex_radius := 25.0
	var hex_points := PackedVector2Array()
	for i in range(6):
		var angle := float(i) * TAU / 6.0 - PI / 6.0
		hex_points.append(Vector2(cos(angle), sin(angle)) * hex_radius)
	var hex_colors := PackedColorArray()
	for i in range(6):
		hex_colors.append(hull_color)
	draw_polygon(hex_points, hex_colors)

	# --- Inner armored plating hexagon ---
	var inner_radius := 18.0
	var inner_points := PackedVector2Array()
	for i in range(6):
		var angle := float(i) * TAU / 6.0 - PI / 6.0
		inner_points.append(Vector2(cos(angle), sin(angle)) * inner_radius)
	var inner_color: Color
	if flashing:
		inner_color = Color(_flash_color.r * 0.7, _flash_color.g * 0.7, _flash_color.b * 0.7)
	else:
		inner_color = Color(hull_color.r * 0.5, hull_color.g * 0.5, hull_color.b * 0.5)
	var inner_colors := PackedColorArray()
	for i in range(6):
		inner_colors.append(inner_color)
	draw_polygon(inner_points, inner_colors)

	# --- Central eye/core (pulsing) ---
	var core_radius := 5.0 + pulse * 2.0
	var core_color: Color
	if flashing:
		core_color = _flash_color
	else:
		match _phase:
			1:
				core_color = Color(1.0, 0.4, 0.1, 0.8 + pulse * 0.2)
			2:
				core_color = Color(1.0, 0.6, 0.0, 0.8 + pulse * 0.2)
			3:
				core_color = Color(1.0, 0.1, 0.1, 0.8 + pulse * 0.2)
			_:
				core_color = Color(1.0, 0.4, 0.1, 0.8 + pulse * 0.2)
	draw_circle(Vector2.ZERO, core_radius, core_color)

	# Core glow ring
	var glow_alpha := 0.3 + pulse * 0.3
	var glow_color: Color
	if flashing:
		glow_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, glow_alpha)
	else:
		glow_color = Color(core_color.r, core_color.g, core_color.b, glow_alpha)
	draw_arc(Vector2.ZERO, core_radius + 3.0, 0.0, TAU, 24, glow_color, 1.0)

	# --- 4 engine exhausts at the rear ---
	var exhaust_positions := [
		Vector2(-20.0, -10.0),
		Vector2(-20.0, 10.0),
		Vector2(-22.0, -5.0),
		Vector2(-22.0, 5.0),
	]
	for idx in range(exhaust_positions.size()):
		var epos: Vector2 = exhaust_positions[idx]
		var flicker := 0.5 + 0.5 * sin(_time * 12.0 + float(idx) * 1.5)
		var flame_radius := 3.0 + flicker * 2.0
		var flame_color: Color
		if flashing:
			flame_color = _flash_color
		else:
			flame_color = Color(1.0, 0.5 + flicker * 0.3, 0.0, 0.7 + flicker * 0.3)
		draw_circle(epos, flame_radius, flame_color)
		# Outer exhaust glow
		var exhaust_glow := Color(flame_color.r, flame_color.g, flame_color.b, 0.2 + flicker * 0.15)
		draw_circle(epos + Vector2(-3.0, 0.0), flame_radius * 0.6, exhaust_glow)

	# --- Weapon ports: 2 small triangles at the front ---
	var weapon_offsets := [Vector2(22.0, -8.0), Vector2(22.0, 8.0)]
	var weapon_dirs := [Vector2(0.0, -1.0), Vector2(0.0, 1.0)]
	for idx in range(weapon_offsets.size()):
		var wpos: Vector2 = weapon_offsets[idx]
		var wdir: Vector2 = weapon_dirs[idx]
		var tri := PackedVector2Array()
		tri.append(wpos + Vector2(5.0, 0.0))
		tri.append(wpos + wdir * 4.0)
		tri.append(wpos - Vector2(3.0, 0.0))
		var tri_color: Color
		if flashing:
			tri_color = _flash_color
		else:
			tri_color = Color(0.9, 0.9, 0.9, 0.9)
		var tri_colors := PackedColorArray()
		for i in range(3):
			tri_colors.append(tri_color)
		draw_polygon(tri, tri_colors)

	# --- Hex edge outlines for definition ---
	for i in range(6):
		var a_pt: Vector2 = hex_points[i]
		var b_pt: Vector2 = hex_points[(i + 1) % 6]
		var edge_color: Color
		if flashing:
			edge_color = Color(_flash_color.r, _flash_color.g, _flash_color.b, 0.6)
		else:
			edge_color = Color(minf(hull_color.r + 0.3, 1.0), minf(hull_color.g + 0.2, 1.0), minf(hull_color.b + 0.1, 1.0), 0.6)
		draw_line(a_pt, b_pt, edge_color, 1.0)
