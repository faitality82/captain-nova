extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 50
@export var move_speed: float = 100.0
@export var damage_on_contact: int = 4
@export var shoot_interval: float = 2.0
@export var bullet_damage: int = 3
@export var kill_reward: int = 75
@export var xp_reward: int = 20
@export var enemy_type: String = "alien"  # "alien" or "spaghetti"
@export var bullet_scene: PackedScene

var _shoot_timer: float = 0.0
var _target: Node2D = null
var _time: float = 0.0
var _flash_timer: float = 0.0
var _stun_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	# Random initial shoot timer so they don't all fire at once
	_shoot_timer = randf() * shoot_interval
	# Contact damage area
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)

func _process(delta: float) -> void:
	_time += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta
	queue_redraw()

func apply_stun(duration: float) -> void:
	_stun_timer = maxf(_stun_timer, duration)

func _physics_process(delta: float) -> void:
	if _stun_timer > 0.0:
		_stun_timer -= delta
		return
	_find_target()
	if _target == null or _target.is_in_group("player") == false:
		return
	# Check if target is dead
	if _target.has_method("take_damage") and _target.get("is_dead") == true:
		return

	var dir_to_player = (_target.global_position - global_position).normalized()
	var dist_to_player = global_position.distance_to(_target.global_position)

	# Movement: approach player but keep some distance
	var preferred_dist = 200.0 if enemy_type == "alien" else 150.0
	if dist_to_player > preferred_dist + 50:
		velocity = dir_to_player * move_speed
	elif dist_to_player < preferred_dist - 50:
		velocity = -dir_to_player * move_speed * 0.5
	else:
		# Orbit around player
		var perp = Vector2(-dir_to_player.y, dir_to_player.x)
		velocity = perp * move_speed * 0.7

	# Spaghetti monsters move more erratically
	if enemy_type == "spaghetti":
		velocity += Vector2(sin(Time.get_ticks_msec() * 0.003) * 60, cos(Time.get_ticks_msec() * 0.004) * 60)

	move_and_slide()
	rotation = dir_to_player.angle()

	# Shooting
	_shoot_timer -= delta
	if _shoot_timer <= 0 and dist_to_player < 600:
		_shoot_timer = shoot_interval
		_fire_at_player(dir_to_player)

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func _fire_at_player(dir: Vector2) -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + dir * 20.0
	bullet.direction = dir
	bullet.damage = bullet_damage
	AudioManager.play_sfx("sfx_enemy_shoot", -10.0)
	if enemy_type == "spaghetti":
		# Spread shot: 3 bullets
		for angle_offset in [-0.2, 0.0, 0.2]:
			var b = bullet_scene.instantiate()
			b.global_position = global_position + dir * 20.0
			b.direction = dir.rotated(angle_offset)
			b.damage = bullet_damage
			get_parent().call_deferred("add_child", b)
		bullet.queue_free()
	else:
		get_parent().call_deferred("add_child", bullet)

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_timer = 0.1
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
	# 15% chance to drop a shield pickup
	if randf() < 0.15:
		_drop_shield_pickup()
	# 5% chance to drop a rare mod
	if randf() < 0.05:
		_try_drop_mod()
	queue_free()

func _try_drop_mod() -> void:
	var rare_mods = ["incendiary", "ricochet", "vampiric"]
	var available = rare_mods.filter(func(m): return m not in ResourceManager.owned_mods)
	if available.is_empty():
		return
	var mod_name = available[randi() % available.size()]
	ResourceManager.owned_mods.append(mod_name)
	# TODO: In a future polish pass, spawn a visual pickup instead of instant grant

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
	var is_flashing = _flash_timer > 0.0
	if enemy_type == "alien":
		_draw_alien(is_flashing)
	else:
		_draw_spaghetti(is_flashing)

func _draw_alien(is_flashing: bool) -> void:
	var base_color = Color(1.0, 1.0, 1.0) if is_flashing else Color(0.2, 0.8, 0.6)
	var dark_color = Color(0.9, 0.9, 0.9) if is_flashing else Color(0.1, 0.5, 0.35)
	var highlight_color = Color(1.0, 1.0, 1.0) if is_flashing else Color(0.4, 0.95, 0.75)
	var cockpit_color = Color(0.8, 0.8, 0.8) if is_flashing else Color(0.05, 0.15, 0.1)
	var engine_color: Color
	if is_flashing:
		engine_color = Color(1.0, 1.0, 1.0)
	else:
		var pulse = (sin(_time * 8.0) + 1.0) * 0.5
		engine_color = Color(1.0, 0.6 + pulse * 0.3, 0.1, 0.7 + pulse * 0.3)

	# Main wedge hull (pointed nose on the right since rotation=0 means facing right)
	var hull_points = PackedVector2Array([
		Vector2(18, 0),     # nose
		Vector2(-8, -12),   # top wing tip
		Vector2(-5, -4),    # top tail fin
		Vector2(-5, 4),     # bottom tail fin
		Vector2(-8, 12),    # bottom wing tip
	])
	draw_colored_polygon(hull_points, base_color)

	# Hull outline for definition
	draw_polyline(hull_points, dark_color, 1.0)
	draw_line(hull_points[4], hull_points[0], dark_color, 1.0)

	# Center highlight stripe
	var stripe_points = PackedVector2Array([
		Vector2(16, 0),
		Vector2(-4, -2),
		Vector2(-4, 2),
	])
	draw_colored_polygon(stripe_points, highlight_color)

	# Cockpit window
	draw_circle(Vector2(8, 0), 2.5, cockpit_color)

	# Engine glow (two small circles behind hull)
	draw_circle(Vector2(-7, -5), 2.0, engine_color)
	draw_circle(Vector2(-7, 5), 2.0, engine_color)

func _draw_spaghetti(is_flashing: bool) -> void:
	var base_color = Color(1.0, 1.0, 1.0) if is_flashing else Color(0.7, 0.2, 0.8)
	var tentacle_color = Color(0.9, 0.9, 0.9) if is_flashing else Color(0.6, 0.15, 0.7)
	var eye_color = Color(1.0, 1.0, 1.0) if is_flashing else Color(1.0, 0.9, 0.2)
	var aura_color: Color
	if is_flashing:
		aura_color = Color(1.0, 1.0, 1.0, 0.8)
	else:
		aura_color = Color(0.8, 0.3, 0.9, 0.4)

	# Pulsing body radius
	var body_pulse = sin(_time * 3.0) * 2.0
	var body_radius = 10.0 + body_pulse

	# 6 tentacles with sine-wave animation
	for i in range(6):
		var base_angle = (float(i) / 6.0) * TAU
		var segments = 8
		var prev_point = Vector2.ZERO
		for seg in range(1, segments + 1):
			var t = float(seg) / float(segments)
			var extend_dist = body_radius + t * 18.0
			var wave = sin(_time * 4.0 + t * 6.0 + float(i) * 1.2) * 4.0 * t
			var seg_angle = base_angle + wave * 0.05
			var point = Vector2(cos(seg_angle), sin(seg_angle)) * extend_dist
			point += Vector2(cos(base_angle + PI * 0.5), sin(base_angle + PI * 0.5)) * wave
			var thickness = maxf(2.5 * (1.0 - t), 0.5)
			draw_line(prev_point if seg > 1 else Vector2(cos(base_angle), sin(base_angle)) * body_radius, point, tentacle_color, thickness)
			prev_point = point

	# Central blob body
	draw_circle(Vector2.ZERO, body_radius, base_color)

	# Glowing eye in center (pulses)
	var eye_pulse = (sin(_time * 5.0) + 1.0) * 0.5
	var eye_radius = 3.0 + eye_pulse * 1.5
	draw_circle(Vector2.ZERO, eye_radius, eye_color)

	# 4 orbiting particle dots
	for i in range(4):
		var orbit_angle = _time * 2.0 + float(i) * TAU / 4.0
		var orbit_dist = body_radius + 6.0 + sin(_time * 3.0 + float(i)) * 3.0
		var dot_pos = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_dist
		draw_circle(dot_pos, 1.5, aura_color)
