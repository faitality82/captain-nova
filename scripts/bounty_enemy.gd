extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 150
@export var move_speed: float = 130.0
@export var damage_on_contact: int = 6
@export var shoot_interval: float = 1.5
@export var bullet_damage: int = 5
@export var kill_reward: int = 0
@export var xp_reward: int = 300
@export var bullet_scene: PackedScene

var bounty_name: String = ""
var _shoot_timer: float = 0.0
var _target: Node2D = null
var _time: float = 0.0
var _flash_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("bounty")
	_shoot_timer = randf() * shoot_interval
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)

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
	var dir = (_target.global_position - global_position).normalized()
	var dist = global_position.distance_to(_target.global_position)
	if dist > 250:
		velocity = dir * move_speed
	elif dist < 150:
		velocity = -dir * move_speed * 0.5
	else:
		velocity = Vector2(-dir.y, dir.x) * move_speed * 0.8
	move_and_slide()
	rotation = dir.angle()
	_shoot_timer -= delta
	if _shoot_timer <= 0 and dist < 600:
		_shoot_timer = shoot_interval
		_fire(dir)

func _draw() -> void:
	var flashing := _flash_timer > 0.0
	var gold := Color(1.0, 0.85, 0.2) if not flashing else Color(1.0, 1.0, 1.0)
	var dark_gold := Color(0.7, 0.6, 0.1) if not flashing else Color(1.0, 1.0, 1.0)
	var bright_gold := Color(1.0, 0.95, 0.5) if not flashing else Color(1.0, 1.0, 1.0)
	var orange := Color(1.0, 0.5, 0.0) if not flashing else Color(1.0, 1.0, 1.0)
	var red := Color(1.0, 0.15, 0.1) if not flashing else Color(1.0, 1.0, 1.0)
	var shield_color := Color(1.0, 0.95, 0.7, 0.3) if not flashing else Color(1.0, 1.0, 1.0, 0.5)

	# Hull polygon: angular hunter ship (7 points)
	# Sharp nose, swept wings, twin tail fins
	var hull_points := PackedVector2Array([
		Vector2(18, 0),       # sharp nose
		Vector2(-6, -12),     # right wing leading edge
		Vector2(-14, -10),    # right wing tip
		Vector2(-10, -3),     # right tail fin inner
		Vector2(-10, 3),      # left tail fin inner
		Vector2(-14, 10),     # left wing tip
		Vector2(-6, 12),      # left wing leading edge
	])

	# Outline: draw hull slightly larger and darker behind
	var outline_points := PackedVector2Array()
	for p in hull_points:
		outline_points.append(p * 1.12)
	draw_colored_polygon(outline_points, dark_gold)

	# Main hull
	draw_colored_polygon(hull_points, gold)

	# Twin tail fins (small triangles at rear)
	var fin_r := PackedVector2Array([
		Vector2(-10, -3),
		Vector2(-16, -7),
		Vector2(-12, -2),
	])
	draw_colored_polygon(fin_r, dark_gold)

	var fin_l := PackedVector2Array([
		Vector2(-10, 3),
		Vector2(-16, 7),
		Vector2(-12, 2),
	])
	draw_colored_polygon(fin_l, dark_gold)

	# Twin engine glow: 2 pulsing orange circles at rear
	var engine_pulse := 0.6 + 0.4 * sin(_time * 8.0)
	var engine_color := Color(orange.r, orange.g, orange.b, engine_pulse)
	draw_circle(Vector2(-12, -5), 3.0, engine_color)
	draw_circle(Vector2(-12, 5), 3.0, engine_color)

	# Crown / bounty mark: small V-shape on top of the ship in bright gold
	draw_line(Vector2(6, -4), Vector2(9, -1), bright_gold, 1.5)
	draw_line(Vector2(9, -1), Vector2(12, -4), bright_gold, 1.5)

	# Energy shield shimmer: thin arc around ship, slowly rotating, golden-white
	var shield_angle := fmod(_time * 1.2, TAU)
	var arc_segments := 16
	var arc_span := PI * 0.6
	var shield_radius := 20.0
	var prev_pt := Vector2.ZERO
	for i in range(arc_segments + 1):
		var t := float(i) / float(arc_segments)
		var a := shield_angle - arc_span * 0.5 + arc_span * t
		var pt := Vector2(cos(a), sin(a)) * shield_radius
		if i > 0:
			draw_line(prev_pt, pt, shield_color, 1.0)
		prev_pt = pt

	# Orbiting threat indicators: 2 small red dots orbiting the ship
	var orbit_radius := 24.0
	var orbit_a1 := fmod(_time * 2.5, TAU)
	var orbit_a2 := orbit_a1 + PI
	var orb1 := Vector2(cos(orbit_a1), sin(orbit_a1)) * orbit_radius
	var orb2 := Vector2(cos(orbit_a2), sin(orbit_a2)) * orbit_radius
	draw_circle(orb1, 2.0, red)
	draw_circle(orb2, 2.0, red)

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func _fire(dir: Vector2) -> void:
	if bullet_scene == null:
		return
	for offset in [-0.15, 0.15]:
		var b = bullet_scene.instantiate()
		b.global_position = global_position + dir * 20.0
		b.direction = dir.rotated(offset)
		b.damage = bullet_damage
		get_parent().call_deferred("add_child", b)
	AudioManager.play_sfx("sfx_enemy_shoot", -8.0)

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_timer = 0.1
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", -2.0)
	ResourceManager.complete_bounty()
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
	if randf() < 0.20:
		_drop_mod()
	queue_free()

func _drop_mod() -> void:
	var rare_mods = ["incendiary", "ricochet", "vampiric"]
	var mod_name = rare_mods[randi() % rare_mods.size()]
	if mod_name in ResourceManager.owned_mods:
		return
	ResourceManager.owned_mods.append(mod_name)

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage_on_contact)
