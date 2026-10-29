extends CharacterBody2D

signal hp_changed(new_hp: int, max_hp: int)
signal died
signal fuel_empty

@export var bullet_scene: PackedScene
@export var laser_scene: PackedScene
@export var shield_bullet_scene: PackedScene
@export var homing_scene: PackedScene
@export var railgun_scene: PackedScene

var hp: int
var max_hp: int
var speed: float
var is_dead: bool = false
var _shoot_cooldown: float = 0.0
var _medic_timer: float = 0.0

# --- Thrust-based movement ---
var _facing_angle: float = 0.0  # radians, 0 = right
var _thrust_velocity: Vector2 = Vector2.ZERO
const ROTATION_SPEED: float = 3.5  # radians per second
const THRUST_FORCE: float = 400.0  # acceleration
const BRAKE_FORCE: float = 150.0  # reverse/brake acceleration
const MAX_SPEED: float = 600.0
const DRIFT_FRICTION: float = 0.3  # how fast you slow down (0 = no friction, 1 = instant stop)

# --- Ship visual tier ---
var _current_tier: int = -1

# --- Orbiting shield ---
var _shield_bullets: Array = []
var _shield_orbit_radius: float = 50.0
var _shield_orbit_speed: float = 2.5  # radians per second
var _shield_angle: float = 0.0

# --- Abilities ---
var _ability_cooldowns: Dictionary = {}  # ability_name -> remaining cooldown
var _is_dashing: bool = false
var _dash_timer: float = 0.0
const DASH_DURATION: float = 0.2
const DASH_DISTANCE: float = 300.0
var _pre_dash_velocity: Vector2 = Vector2.ZERO
var _shield_bubble_active: bool = false
var _shield_bubble_timer: float = 0.0
const SHIELD_BUBBLE_DURATION: float = 2.0

# --- Skill tree state ---
var _regen_accumulator: float = 0.0
var _emergency_reserves_active: bool = false
var _emergency_reserves_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	hp = ResourceManager.ship_max_hp
	max_hp = ResourceManager.ship_max_hp
	speed = ResourceManager.ship_speed
	# Hide the old PNG sprite - ship is now procedurally drawn
	if has_node("Sprite2D"):
		$Sprite2D.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_movement(delta)
	_handle_shooting(delta)
	_handle_weapon_switch()
	_update_shield(delta)
	_update_ship_anim(delta)
	_handle_abilities(delta)
	_handle_medic_regen(delta)
	_handle_regen_plating(delta)
	_handle_emergency_reserves(delta)

func _handle_weapon_switch() -> void:
	var weapons = ResourceManager.owned_weapons
	if weapons.size() <= 1:
		return
	var keys = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
	for i in range(mini(keys.size(), weapons.size())):
		if Input.is_key_pressed(keys[i]) and ResourceManager.current_weapon != weapons[i]:
			ResourceManager.current_weapon = weapons[i]
			AudioManager.play_sfx("sfx_pickup", -4.0)
			return

func _handle_movement(delta: float) -> void:
	# Rotate with left/right
	var rotate_input = 0.0
	if Input.is_action_pressed("move_left"):
		rotate_input -= 1.0
	if Input.is_action_pressed("move_right"):
		rotate_input += 1.0
	# Skill tree: turn rate bonus (tight_turn)
	var turn_speed: float = ROTATION_SPEED * (1.0 + ResourceManager.get_tree_effect("turn_rate_mult"))
	_facing_angle += rotate_input * turn_speed * delta

	# Thrust forward/backward (only if we have fuel)
	var thrust_input = 0.0
	if Input.is_action_pressed("move_up"):
		thrust_input += 1.0
	if Input.is_action_pressed("move_down"):
		thrust_input -= 0.5  # reverse is weaker

	# Skill tree: speed bonus (afterburner)
	var tree_speed_mult: float = 1.0 + ResourceManager.get_tree_effect("speed_mult")
	# Skill tree: smuggler's reflexes - extra speed when cargo > 75% full
	if ResourceManager.has_tree_effect("cargo_speed_mult"):
		var fill_pct: float = float(ResourceManager.total_cargo()) / max(float(ResourceManager.cargo_capacity), 1.0)
		if fill_pct >= ResourceManager.get_tree_effect("cargo_speed_threshold"):
			tree_speed_mult += ResourceManager.get_tree_effect("cargo_speed_mult")
	# Skill tree: emergency reserves - speed boost when low HP
	if _emergency_reserves_active:
		tree_speed_mult += ResourceManager.get_tree_effect("low_hp_speed_mult")

	var has_fuel = ResourceManager.ship_fuel > 0

	if thrust_input != 0.0 and has_fuel:
		var facing_dir = Vector2(cos(_facing_angle), sin(_facing_angle))
		var thrust = facing_dir * thrust_input * THRUST_FORCE * (ResourceManager.ship_speed / 200.0) * tree_speed_mult
		_thrust_velocity += thrust * delta

		# Burn fuel
		var burn_rate = ResourceManager.FUEL_BURN_RATE
		if ResourceManager.has_crew("mechanic"):
			burn_rate *= 0.80
		if ResourceManager.has_crew("ferryman"):
			burn_rate *= 0.70
		# Skill tree: fuel burn reduction (fuel_saver)
		var burn_mult: float = 1.0 + ResourceManager.get_tree_effect("fuel_burn_mult")
		burn_rate *= burn_mult
		ResourceManager.ship_fuel -= burn_rate * abs(thrust_input) * delta
		if ResourceManager.ship_fuel <= 0:
			ResourceManager.ship_fuel = 0
			fuel_empty.emit()
	elif thrust_input != 0.0 and not has_fuel:
		# No fuel - can't thrust, just drift
		pass

	# Apply drift friction (space has a little drag for gameplay)
	# Don't apply friction during dash — let the full burst happen
	if not _is_dashing:
		_thrust_velocity *= (1.0 - DRIFT_FRICTION * delta)

	# Clamp to max speed (skip during dash so the burst isn't crushed)
	if not _is_dashing:
		var current_max = MAX_SPEED * (ResourceManager.ship_speed / 200.0) * tree_speed_mult
		if _thrust_velocity.length() > current_max:
			_thrust_velocity = _thrust_velocity.normalized() * current_max

	# Move
	velocity = _thrust_velocity
	move_and_slide()

	# Redraw procedural ship each frame
	queue_redraw()

func _handle_shooting(delta: float) -> void:
	_shoot_cooldown -= delta
	var wd = ResourceManager.get_weapon_data()
	if Input.is_action_pressed("shoot") and _shoot_cooldown <= 0.0:
		var cooldown = wd["cooldown"]
		if ResourceManager.has_crew("gunner"):
			cooldown *= 0.85
		if ResourceManager.equipped_mod == "rapid_fire":
			cooldown *= 0.80
		# Skill tree: weapon cooldown reduction (quick_draw)
		var cd_mult: float = 1.0 + ResourceManager.get_tree_effect("cooldown_mult")
		cooldown *= cd_mult
		_shoot_cooldown = cooldown
		_fire_weapon(wd)

func _fire_weapon(wd: Dictionary) -> void:
	var dir = Vector2(cos(_facing_angle), sin(_facing_angle))
	var scene: PackedScene
	match wd["type"]:
		"laser": scene = laser_scene
		"homing": scene = homing_scene
		"railgun": scene = railgun_scene
		_: scene = bullet_scene
	if scene == null:
		return

	var bullet_count = wd["bullets"]
	var spread_angle = wd["spread"]
	# Skill tree: Spread Mastery - more bullets, tighter cone
	if ResourceManager.current_weapon == "spread" and ResourceManager.has_tree_effect("spread_tighter_cone"):
		bullet_count = int(ResourceManager.get_tree_effect("spread_shot_count"))
		spread_angle *= 0.7  # tighter cone
	var base_damage = int(ResourceManager.weapon_damage * wd["damage_mult"])
	var bullet_speed = wd["speed"]
	var bullet_lifetime = wd["lifetime"]

	# Skill tree: weapon damage bonus (damage_mult from tree + level bonuses)
	var tree_damage_mult: float = 1.0 + ResourceManager.get_tree_effect("damage_mult") + ResourceManager.weapon_damage_bonus_pct
	base_damage = int(float(base_damage) * tree_damage_mult)

	# Skill tree: crit chance (critical_systems)
	var crit_chance: float = ResourceManager.get_tree_effect("crit_chance")
	if crit_chance > 0 and randf() < crit_chance:
		base_damage *= int(ResourceManager.get_tree_effect("crit_damage_mult"))

	# Apply mod effects
	var mod = ResourceManager.equipped_mod
	if mod == "heavy_rounds":
		base_damage = int(base_damage * 1.25)
		bullet_speed *= 0.90
	if mod == "extended_range":
		bullet_lifetime *= 1.40
	if mod == "lucky_shot" and randf() < 0.10:
		_shoot_cooldown = 0.0  # free shot

	# Play weapon SFX
	match ResourceManager.current_weapon:
		"laser": AudioManager.play_sfx("sfx_laser", -8.0)
		"spread": AudioManager.play_sfx("sfx_spread", -4.0)
		"homing": AudioManager.play_sfx("sfx_shoot", -4.0)
		"railgun": AudioManager.play_sfx("sfx_laser", -2.0)
		_: AudioManager.play_sfx("sfx_shoot", -6.0)

	# TODO: Implement blaster_pierce - needs bullet.gd changes
	# TODO: Implement homing_split_on_impact - needs homing_bullet.gd changes
	# TODO: Implement laser_cone - needs railgun_beam.gd or laser changes

	for i in range(bullet_count):
		var bullet = ResourceManager.safe_instantiate(scene)
		if bullet == null:
			return
		var angle_offset = 0.0
		if bullet_count > 1:
			angle_offset = lerp(-spread_angle / 2.0, spread_angle / 2.0, float(i) / float(bullet_count - 1))
		var bullet_dir = dir.rotated(angle_offset)
		bullet.global_position = global_position + dir * 30.0
		bullet.direction = bullet_dir
		bullet.damage = base_damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime
		# Tag bullet with mod info
		if bullet.has_method("set_meta"):
			bullet.set_meta("mod", mod)
		get_parent().add_child(bullet)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	if _is_dashing:
		return  # invincible during dash
	if _shield_bubble_active:
		return  # shield absorbs all damage
	# Skill tree: dodge chance (evasion_protocol)
	if randf() < ResourceManager.get_tree_effect("dodge_chance"):
		return  # dodged!
	hp = max(0, hp - amount)
	AudioManager.play_sfx("sfx_hit", -4.0)
	hp_changed.emit(hp, ResourceManager.ship_max_hp)
	if hp == 0:
		# Skill tree: last stand - survive one killing blow per life
		if ResourceManager.has_tree_effect("survive_killing_blow") and not ResourceManager.last_stand_used:
			hp = 1
			ResourceManager.last_stand_used = true
			hp_changed.emit(hp, ResourceManager.ship_max_hp)
		else:
			_die()
	else:
		# Skill tree: emergency reserves - activate speed boost when HP drops below threshold
		if ResourceManager.has_tree_effect("low_hp_speed_mult") and ResourceManager.emergency_reserves_cooldown <= 0.0:
			if float(hp) / float(max_hp) < ResourceManager.get_tree_effect("low_hp_threshold"):
				_emergency_reserves_active = true
				_emergency_reserves_timer = ResourceManager.get_tree_effect("low_hp_duration")
				ResourceManager.emergency_reserves_cooldown = ResourceManager.get_tree_effect("low_hp_cooldown")

func _die() -> void:
	is_dead = true
	_clear_shield()
	_thrust_velocity = Vector2.ZERO
	AudioManager.play_sfx("sfx_death")
	died.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	visible = false

func respawn(pos: Vector2) -> void:
	global_position = pos
	hp = ResourceManager.ship_max_hp
	max_hp = ResourceManager.ship_max_hp
	is_dead = false
	visible = true
	_thrust_velocity = Vector2.ZERO
	_emergency_reserves_active = false
	_emergency_reserves_timer = 0.0
	_regen_accumulator = 0.0
	$CollisionShape2D.set_deferred("disabled", false)
	hp_changed.emit(hp, max_hp)

func apply_force(force: Vector2) -> void:
	_thrust_velocity += force

func get_hp() -> int:
	return hp

func heal(amount: int) -> void:
	hp = min(hp + amount, ResourceManager.ship_max_hp)
	hp_changed.emit(hp, ResourceManager.ship_max_hp)

func refresh_stats() -> void:
	max_hp = ResourceManager.ship_max_hp
	speed = ResourceManager.ship_speed
	hp = min(hp, max_hp)
	hp_changed.emit(hp, max_hp)
	# Check if visual tier changed
	var new_tier = _get_ship_tier()
	if new_tier != _current_tier:
		_current_tier = new_tier

func _handle_medic_regen(delta: float) -> void:
	if not ResourceManager.has_crew("medic"):
		return
	_medic_timer += delta
	if _medic_timer >= 5.0:
		_medic_timer -= 5.0
		if hp < ResourceManager.ship_max_hp:
			heal(1)

# --- Skill tree: Regen Plating (hp_regen_per_sec) ---
func _handle_regen_plating(delta: float) -> void:
	var regen: float = ResourceManager.get_tree_effect("hp_regen_per_sec")
	if regen > 0 and hp < max_hp:
		_regen_accumulator += regen * delta
		if _regen_accumulator >= 1.0:
			hp = min(hp + 1, max_hp)
			_regen_accumulator -= 1.0
			hp_changed.emit(hp, max_hp)

# --- Skill tree: Emergency Reserves timer ---
func _handle_emergency_reserves(delta: float) -> void:
	# Tick global cooldown
	if ResourceManager.emergency_reserves_cooldown > 0.0:
		ResourceManager.emergency_reserves_cooldown -= delta
	# Tick active duration
	if _emergency_reserves_active:
		_emergency_reserves_timer -= delta
		if _emergency_reserves_timer <= 0.0:
			_emergency_reserves_active = false

# ── Ship animation ─────────────────────────────

func _get_ship_tier() -> int:
	var total = 0
	for key in ResourceManager.upgrade_levels:
		total += ResourceManager.upgrade_levels[key]
	# 0 upgrades = tier 0, 1-3 = tier 1, 4-6 = tier 2, 7+ = tier 3
	if total >= 7:
		return 3
	elif total >= 4:
		return 2
	elif total >= 1:
		return 1
	return 0

func _update_ship_anim(_delta: float) -> void:
	# Check if tier changed (for any systems still referencing tier)
	var new_tier = _get_ship_tier()
	if new_tier != _current_tier:
		_current_tier = new_tier

# ── Shield system ──────────────────────────────

func add_shield(count: int) -> void:
	if shield_bullet_scene == null:
		return
	for i in range(count):
		var sb = shield_bullet_scene.instantiate()
		sb.orbit_index = _shield_bullets.size()
		sb.orbit_total = _shield_bullets.size() + (count - i)
		_shield_bullets.append(sb)
		get_parent().call_deferred("add_child", sb)
	# Reassign indices so spacing is even
	_reindex_shield()

func _update_shield(delta: float) -> void:
	# Clean up any freed bullets
	_shield_bullets = _shield_bullets.filter(func(b): return is_instance_valid(b))
	if _shield_bullets.is_empty():
		return
	_shield_angle += _shield_orbit_speed * delta
	var count = _shield_bullets.size()
	for i in range(count):
		var angle = _shield_angle + (TAU / count) * i
		_shield_bullets[i].global_position = global_position + Vector2(cos(angle), sin(angle)) * _shield_orbit_radius

func _on_shield_bullet_destroyed(bullet: Node) -> void:
	_shield_bullets.erase(bullet)
	_reindex_shield()

func _reindex_shield() -> void:
	_shield_bullets = _shield_bullets.filter(func(b): return is_instance_valid(b))
	for i in range(_shield_bullets.size()):
		_shield_bullets[i].orbit_index = i
		_shield_bullets[i].orbit_total = _shield_bullets.size()

func _clear_shield() -> void:
	for b in _shield_bullets:
		if is_instance_valid(b):
			b.queue_free()
	_shield_bullets.clear()

# ── Abilities ──────────────────────────────────

func _handle_abilities(delta: float) -> void:
	# Tick cooldowns
	for ability in _ability_cooldowns.keys():
		_ability_cooldowns[ability] = max(0.0, _ability_cooldowns[ability] - delta)

	# Dash tick
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0:
			_is_dashing = false
			# Restore pre-dash velocity so ship doesn't fly off at 1500 u/s
			_thrust_velocity = _pre_dash_velocity

	# Shield bubble tick
	if _shield_bubble_active:
		_shield_bubble_timer -= delta
		queue_redraw()
		if _shield_bubble_timer <= 0:
			_shield_bubble_active = false
			queue_redraw()

	# Check ability inputs
	if "dash" in ResourceManager.owned_abilities:
		if Input.is_action_just_pressed("ability_dash") and _get_cooldown("dash") <= 0:
			_activate_dash()

	if "shield_bubble" in ResourceManager.owned_abilities:
		if Input.is_action_just_pressed("ability_shield") and _get_cooldown("shield_bubble") <= 0:
			_activate_shield_bubble()

	if "emp_blast" in ResourceManager.owned_abilities:
		if Input.is_action_just_pressed("ability_emp") and _get_cooldown("emp_blast") <= 0:
			_activate_emp()

func _get_cooldown(ability: String) -> float:
	return _ability_cooldowns.get(ability, 0.0)

func get_ability_cooldowns() -> Dictionary:
	return _ability_cooldowns

func _activate_dash() -> void:
	_is_dashing = true
	_dash_timer = DASH_DURATION
	# Skill tree: ability cooldown reduction (ability_surge) + dash-specific (dash_boost)
	var base_cd: float = ResourceManager.ABILITY_DATA["dash"]["cooldown"]
	var ability_cd_mult: float = 1.0 + ResourceManager.get_tree_effect("ability_cooldown_mult")
	base_cd *= ability_cd_mult
	base_cd += ResourceManager.get_tree_effect("dash_cooldown_flat")
	_ability_cooldowns["dash"] = max(0.5, base_cd)
	_pre_dash_velocity = _thrust_velocity
	# Skill tree: dash distance bonus (dash_boost)
	var dash_dist: float = DASH_DISTANCE * (1.0 + ResourceManager.get_tree_effect("dash_distance_mult"))
	var dash_dir = Vector2(cos(_facing_angle), sin(_facing_angle))
	_thrust_velocity = dash_dir * (dash_dist / DASH_DURATION)
	AudioManager.play_sfx("sfx_pickup", -4.0)

func _activate_shield_bubble() -> void:
	_shield_bubble_active = true
	_shield_bubble_timer = SHIELD_BUBBLE_DURATION
	# Skill tree: ability cooldown reduction (ability_surge)
	var base_cd: float = ResourceManager.ABILITY_DATA["shield_bubble"]["cooldown"]
	var ability_cd_mult: float = 1.0 + ResourceManager.get_tree_effect("ability_cooldown_mult")
	_ability_cooldowns["shield_bubble"] = max(1.0, base_cd * ability_cd_mult)
	AudioManager.play_sfx("sfx_pickup", -2.0)

func _activate_emp() -> void:
	# Skill tree: ability cooldown reduction (ability_surge)
	var base_cd: float = ResourceManager.ABILITY_DATA["emp_blast"]["cooldown"]
	var ability_cd_mult: float = 1.0 + ResourceManager.get_tree_effect("ability_cooldown_mult")
	_ability_cooldowns["emp_blast"] = max(2.0, base_cd * ability_cd_mult)
	AudioManager.play_sfx("sfx_explosion", -6.0)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.is_in_group("boss"):
			continue
		if global_position.distance_to(enemy.global_position) <= 400.0:
			_stun_enemy(enemy)
			if enemy.has_method("force_reveal"):
				enemy.force_reveal(3.0)
	_create_emp_visual()

func _stun_enemy(enemy: Node) -> void:
	if enemy.has_method("set_physics_process"):
		enemy.set_physics_process(false)
		get_tree().create_timer(3.0).timeout.connect(func():
			if is_instance_valid(enemy):
				enemy.set_physics_process(true)
		)
		if enemy.has_node("Sprite2D"):
			enemy.get_node("Sprite2D").modulate = Color(0.3, 0.3, 1.0, 1)
			get_tree().create_timer(3.0).timeout.connect(func():
				if is_instance_valid(enemy) and enemy.has_node("Sprite2D"):
					enemy.get_node("Sprite2D").modulate = Color(1, 1, 1, 1)
			)

func _create_emp_visual() -> void:
	var ring = Node2D.new()
	ring.global_position = global_position
	ring.set_script(load("res://scripts/emp_ring.gd"))
	get_parent().add_child(ring)

func _draw() -> void:
	_draw_procedural_ship()
	if _shield_bubble_active:
		var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.15
		draw_arc(Vector2.ZERO, 45.0 * pulse, 0, TAU, 32, Color(0, 0.8, 1, 0.4), 3.0)

func _draw_procedural_ship() -> void:
	var t = Time.get_ticks_msec() * 0.001
	var hull_c: Color = ResourceManager.ship_hull_color
	var accent_c: Color = ResourceManager.ship_accent_color
	var engine_c: Color = ResourceManager.ship_engine_color
	var weapon: String = ResourceManager.current_weapon

	# All points drawn relative to facing_angle (0 = right)
	var fa: float = _facing_angle
	var fwd: Vector2 = Vector2(cos(fa), sin(fa))
	var right: Vector2 = Vector2(cos(fa + PI / 2), sin(fa + PI / 2))

	# ── Engine exhaust (drawn first, behind hull) ──
	var engine_lvl: int = ResourceManager.upgrade_levels.get("engine", 0)
	var thrusting: bool = Input.is_action_pressed("move_up") and ResourceManager.ship_fuel > 0
	if thrusting or _is_dashing:
		var exhaust_len: float = 12.0 + engine_lvl * 4.0
		var flicker: float = sin(t * 25.0) * 3.0 + cos(t * 37.0) * 2.0
		exhaust_len += flicker
		if _is_dashing:
			exhaust_len *= 2.5
		var base_l: Vector2 = fwd * -14.0 + right * -5.0
		var base_r: Vector2 = fwd * -14.0 + right * 5.0
		var tip: Vector2 = fwd * -(14.0 + exhaust_len)
		var glow_c: Color = engine_c
		glow_c.a = 0.9
		draw_colored_polygon(PackedVector2Array([base_l, tip, base_r]), glow_c)
		# Inner bright core
		var core_l: Vector2 = fwd * -14.0 + right * -2.5
		var core_r: Vector2 = fwd * -14.0 + right * 2.5
		var core_tip: Vector2 = fwd * -(14.0 + exhaust_len * 0.6)
		draw_colored_polygon(PackedVector2Array([core_l, core_tip, core_r]), Color(1, 1, 1, 0.7))
		# Second engine for engine lvl 2+
		if engine_lvl >= 2:
			var off_l: Vector2 = right * -8.0
			var off_r: Vector2 = right * 8.0
			var sm_len: float = exhaust_len * 0.6
			for off in [off_l, off_r]:
				var sb_l: Vector2 = fwd * -12.0 + off + right * -2.5
				var sb_r: Vector2 = fwd * -12.0 + off + right * 2.5
				var sb_tip: Vector2 = fwd * -(12.0 + sm_len) + off
				draw_colored_polygon(PackedVector2Array([sb_l, sb_tip, sb_r]), Color(engine_c, 0.6))

	# ── Main hull ──
	var hull_dark: Color = hull_c.darkened(0.2)
	# Nose
	var nose: Vector2 = fwd * 22.0
	# Body points
	var wing_l: Vector2 = fwd * -10.0 + right * -16.0
	var wing_r: Vector2 = fwd * -10.0 + right * 16.0
	var shoulder_l: Vector2 = fwd * 6.0 + right * -10.0
	var shoulder_r: Vector2 = fwd * 6.0 + right * 10.0
	var rear_l: Vector2 = fwd * -14.0 + right * -8.0
	var rear_r: Vector2 = fwd * -14.0 + right * 8.0
	# Main body polygon
	var hull_pts: PackedVector2Array = PackedVector2Array([
		nose, shoulder_r, wing_r, rear_r, rear_l, wing_l, shoulder_l
	])
	draw_colored_polygon(hull_pts, hull_c)

	# ── Accent stripe down center ──
	var stripe_w: float = 2.5
	var stripe_pts: PackedVector2Array = PackedVector2Array([
		fwd * 18.0 + right * -stripe_w,
		fwd * 18.0 + right * stripe_w,
		fwd * -12.0 + right * stripe_w,
		fwd * -12.0 + right * -stripe_w,
	])
	draw_colored_polygon(stripe_pts, accent_c)

	# ── Wing fins (get bigger with engine upgrades) ──
	var fin_ext: float = 4.0 + engine_lvl * 2.0
	var fin_l_pts: PackedVector2Array = PackedVector2Array([
		wing_l,
		fwd * -6.0 + right * -(16.0 + fin_ext),
		fwd * -16.0 + right * -(10.0 + fin_ext * 0.5),
		rear_l,
	])
	var fin_r_pts: PackedVector2Array = PackedVector2Array([
		wing_r,
		fwd * -6.0 + right * (16.0 + fin_ext),
		fwd * -16.0 + right * (10.0 + fin_ext * 0.5),
		rear_r,
	])
	draw_colored_polygon(fin_l_pts, hull_dark)
	draw_colored_polygon(fin_r_pts, hull_dark)

	# ── Shield hardware (visible with shield upgrades) ──
	var shield_lvl: int = ResourceManager.upgrade_levels.get("shield", 0)
	if shield_lvl >= 1:
		var shield_c: Color = accent_c.lightened(0.3)
		shield_c.a = 0.5 + sin(t * 2.0) * 0.15
		var arc_radius: float = 18.0 + shield_lvl * 2.0
		draw_arc(Vector2.ZERO, arc_radius, fa - 0.8, fa + 0.8, 12, shield_c, 1.5 + shield_lvl * 0.5)
		if shield_lvl >= 2:
			draw_arc(Vector2.ZERO, arc_radius, fa + PI - 0.5, fa + PI + 0.5, 8, shield_c, 1.5)

	# ── Cargo pods (visible with cargo upgrades) ──
	var cargo_lvl: int = ResourceManager.upgrade_levels.get("cargo", 0)
	if cargo_lvl >= 1:
		var pod_c: Color = hull_dark.darkened(0.15)
		for side in [-1.0, 1.0]:
			var pod_center: Vector2 = fwd * -4.0 + right * side * (12.0 + cargo_lvl * 1.5)
			var pod_fwd: Vector2 = fwd * (3.0 + cargo_lvl * 1.0)
			var pod_side: Vector2 = right * side * 2.5
			var pod_pts: PackedVector2Array = PackedVector2Array([
				pod_center + pod_fwd + pod_side * 0.5,
				pod_center + pod_fwd * -1.0 + pod_side * 0.5,
				pod_center + pod_fwd * -1.0 - pod_side * 0.5,
				pod_center + pod_fwd - pod_side * 0.5,
			])
			draw_colored_polygon(pod_pts, pod_c)

	# ── Fuel tank (visible with fuel tank upgrades) ──
	var fuel_lvl: int = ResourceManager.upgrade_levels.get("fuel_tank", 0)
	if fuel_lvl >= 1:
		var tank_c: Color = Color(0.6, 0.5, 0.3)
		var tank_center: Vector2 = fwd * -10.0
		var tank_r: float = 2.5 + fuel_lvl * 0.8
		draw_circle(tank_center, tank_r, tank_c)
		draw_arc(tank_center, tank_r, 0, TAU, 12, tank_c.darkened(0.3), 1.0)

	# ── Weapon emitter (changes with equipped weapon) ──
	var w_glow: Color
	match weapon:
		"blaster":
			w_glow = Color(1.0, 0.8, 0.2)  # yellow
		"laser":
			w_glow = Color(1.0, 0.2, 0.2)  # red
		"spread":
			w_glow = Color(0.2, 1.0, 0.3)  # green
		"homing":
			w_glow = Color(0.8, 0.3, 1.0)  # purple
		"railgun":
			w_glow = Color(0.3, 0.8, 1.0)  # cyan
		_:
			w_glow = Color(1.0, 0.8, 0.2)

	# Weapon barrel
	var weapon_lvl: int = ResourceManager.upgrade_levels.get("weapon", 0)
	var barrel_len: float = 6.0 + weapon_lvl * 2.0
	var barrel_w: float = 1.5 + weapon_lvl * 0.5
	var barrel_pts: PackedVector2Array = PackedVector2Array([
		nose + fwd * 0.0 + right * -barrel_w,
		nose + fwd * barrel_len + right * -barrel_w * 0.5,
		nose + fwd * barrel_len + right * barrel_w * 0.5,
		nose + fwd * 0.0 + right * barrel_w,
	])
	draw_colored_polygon(barrel_pts, hull_dark)
	# Weapon tip glow
	var glow_pulse: float = 0.6 + sin(t * 4.0) * 0.2
	var tip_pos: Vector2 = nose + fwd * barrel_len
	draw_circle(tip_pos, 2.0 + weapon_lvl * 0.5, Color(w_glow, glow_pulse))

	# Spread weapon: side barrels
	if weapon == "spread":
		for side in [-1.0, 1.0]:
			var sb_start: Vector2 = fwd * 12.0 + right * side * 8.0
			var sb_end: Vector2 = sb_start + fwd * 5.0
			draw_line(sb_start, sb_end, hull_dark, 2.0)
			draw_circle(sb_end, 1.5, Color(w_glow, glow_pulse))

	# Homing weapon: antenna dishes
	if weapon == "homing":
		for side in [-1.0, 1.0]:
			var dish_pos: Vector2 = fwd * 2.0 + right * side * 13.0
			draw_arc(dish_pos, 3.0, fa + side * 0.5 - 0.8, fa + side * 0.5 + 0.8, 6, w_glow, 1.5)

	# Railgun: long barrel with charge rings
	if weapon == "railgun":
		for i in range(3):
			var ring_pos: Vector2 = nose + fwd * (2.0 + i * 3.0)
			draw_arc(ring_pos, 3.0, 0, TAU, 8, Color(w_glow, 0.4 + sin(t * 6.0 + i) * 0.2), 1.0)

	# ── Cockpit canopy ──
	var canopy_c: Color = Color(0.3, 0.6, 0.9, 0.6)
	var canopy_pts: PackedVector2Array = PackedVector2Array([
		fwd * 14.0,
		fwd * 6.0 + right * -4.0,
		fwd * 2.0,
		fwd * 6.0 + right * 4.0,
	])
	draw_colored_polygon(canopy_pts, canopy_c)
