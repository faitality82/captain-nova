extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 60
@export var move_speed: float = 70.0
@export var damage_on_contact: int = 4
@export var kill_reward: int = 150
@export var xp_reward: int = 40
@export var bullet_damage: int = 5
@export var bullet_scene: PackedScene

const CLOAK_ALPHA: float = 0.05
const UNCLOAK_ALPHA: float = 1.0
const AMBUSH_RANGE: float = 200.0
const AMBUSH_DURATION: float = 3.0
const BURST_COUNT: int = 3
const BURST_DELAY: float = 0.3

enum State { STALKING, AMBUSHING, RECLOAKING }

var _target: Node2D = null
var _state: State = State.STALKING
var _ambush_timer: float = 0.0
var _burst_remaining: int = 0
var _burst_timer: float = 0.0
var _alpha: float = CLOAK_ALPHA
var _time: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	modulate.a = CLOAK_ALPHA
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)

func _process(delta: float) -> void:
	_time += delta

func _physics_process(delta: float) -> void:
	_find_target()
	if _target == null or not _target.is_in_group("player"):
		return
	if _target.get("is_dead") == true:
		return

	var dir_to_player = (_target.global_position - global_position).normalized()
	var dist = global_position.distance_to(_target.global_position)

	match _state:
		State.STALKING:
			velocity = dir_to_player * move_speed
			if dist <= AMBUSH_RANGE:
				_start_ambush()
		State.AMBUSHING:
			velocity = dir_to_player * move_speed * 0.2
			_ambush_timer -= delta
			_burst_timer -= delta
			if _burst_remaining > 0 and _burst_timer <= 0:
				_fire_at_player(dir_to_player)
				_burst_remaining -= 1
				_burst_timer = BURST_DELAY
			if _ambush_timer <= 0:
				_state = State.RECLOAKING
		State.RECLOAKING:
			_alpha = move_toward(_alpha, CLOAK_ALPHA, delta * 2.0)
			modulate.a = _alpha
			velocity = -dir_to_player * move_speed * 1.5
			if _alpha <= CLOAK_ALPHA + 0.01:
				_alpha = CLOAK_ALPHA
				modulate.a = CLOAK_ALPHA
				_state = State.STALKING

	move_and_slide()
	rotation = dir_to_player.angle()
	queue_redraw()

func _start_ambush() -> void:
	_state = State.AMBUSHING
	_ambush_timer = AMBUSH_DURATION
	_alpha = UNCLOAK_ALPHA
	modulate.a = UNCLOAK_ALPHA
	_burst_remaining = BURST_COUNT
	_burst_timer = 0.3

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
	get_parent().call_deferred("add_child", bullet)

func force_reveal(_duration: float) -> void:
	_alpha = UNCLOAK_ALPHA
	modulate.a = UNCLOAK_ALPHA

func take_damage(amount: int) -> void:
	hp -= amount
	modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", _alpha, 0.15)
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
	# --- Hull shape: elongated angular kite (6 points) ---
	var hull_points = PackedVector2Array([
		Vector2(16, 0),
		Vector2(4, -6),
		Vector2(-6, -9),
		Vector2(-14, 0),
		Vector2(-6, 9),
		Vector2(4, 6),
	])

	# --- Determine colors by state ---
	var hull_color: Color
	var edge_color: Color
	var sensor_color: Color
	var engine_brightness: float

	match _state:
		State.STALKING:
			hull_color = Color(0.15, 0.2, 0.35, 1.0)
			edge_color = Color(0.25, 0.3, 0.5, 0.4)
			sensor_color = Color(0.4, 0.15, 0.15, 0.6)
			engine_brightness = 0.3
		State.AMBUSHING:
			hull_color = Color(0.2, 0.3, 0.6, 1.0)
			edge_color = Color(0.3, 0.5, 1.0, 0.9)
			sensor_color = Color(1.0, 0.2, 0.1, 1.0)
			engine_brightness = 1.0
		State.RECLOAKING:
			var t = (_alpha - CLOAK_ALPHA) / maxf(UNCLOAK_ALPHA - CLOAK_ALPHA, 0.001)
			hull_color = Color(0.15, 0.2, 0.35, 1.0).lerp(Color(0.2, 0.3, 0.6, 1.0), t)
			edge_color = Color(0.25, 0.3, 0.5, 0.4).lerp(Color(0.3, 0.5, 1.0, 0.9), t)
			sensor_color = Color(0.4, 0.15, 0.15, 0.6).lerp(Color(1.0, 0.2, 0.1, 1.0), t)
			engine_brightness = lerpf(0.3, 1.0, t)

	# --- Draw hull ---
	draw_colored_polygon(hull_points, hull_color)

	# --- Inner hull panel lines ---
	var panel_color = Color(edge_color.r, edge_color.g, edge_color.b, edge_color.a * 0.5)
	draw_line(Vector2(16, 0), Vector2(-6, -9), panel_color, 1.0)
	draw_line(Vector2(16, 0), Vector2(-6, 9), panel_color, 1.0)
	draw_line(Vector2(-2, 0), Vector2(-14, 0), panel_color, 1.0)

	# --- Hull outline ---
	for i in range(hull_points.size()):
		var a = hull_points[i]
		var b = hull_points[(i + 1) % hull_points.size()]
		draw_line(a, b, edge_color, 1.2)

	# --- Stealth shimmer (STALKING): sweeping arc ripple ---
	if _state == State.STALKING:
		var sweep_angle = fmod(_time * 2.5, TAU)
		var shimmer_color = Color(0.4, 0.5, 0.8, 0.15 + 0.1 * sin(_time * 4.0))
		var arc_radius = 14.0
		var arc_segments = 8
		var arc_span = PI * 0.4
		var start_angle = sweep_angle - arc_span * 0.5
		for j in range(arc_segments):
			var a1 = start_angle + (arc_span / arc_segments) * j
			var a2 = start_angle + (arc_span / arc_segments) * (j + 1)
			var p1 = Vector2(cos(a1), sin(a1)) * arc_radius
			var p2 = Vector2(cos(a2), sin(a2)) * arc_radius
			draw_line(p1, p2, shimmer_color, 1.0)

	# --- Phase cloak dashed outline (STALKING) ---
	if _state == State.STALKING:
		var dash_color = Color(0.3, 0.4, 0.7, 0.12 + 0.06 * sin(_time * 3.0))
		var outline_radius = 16.0
		var total_dashes = 12
		var dash_arc = PI * 2.0 / total_dashes * 0.5
		for d in range(total_dashes):
			var base_angle = (PI * 2.0 / total_dashes) * d + _time * 0.8
			var segs = 4
			for s in range(segs):
				var a1 = base_angle + (dash_arc / segs) * s
				var a2 = base_angle + (dash_arc / segs) * (s + 1)
				var p1 = Vector2(cos(a1), sin(a1)) * outline_radius
				var p2 = Vector2(cos(a2), sin(a2)) * outline_radius
				draw_line(p1, p2, dash_color, 0.8)

	# --- Ambush flare: electric energy jagged lines ---
	if _state == State.AMBUSHING:
		var flare_color = Color(0.4, 0.6, 1.0, 0.7 + 0.3 * sin(_time * 12.0))
		var line_count = 6
		for i in range(line_count):
			var base_angle = (TAU / line_count) * i + _time * 3.0
			var start_r = 10.0
			var p_start = Vector2(cos(base_angle), sin(base_angle)) * start_r
			var mid_angle = base_angle + sin(_time * 8.0 + i * 1.5) * 0.4
			var mid_r = start_r + 6.0
			var p_mid = Vector2(cos(mid_angle), sin(mid_angle)) * mid_r
			var end_angle = base_angle + sin(_time * 10.0 + i * 2.0) * 0.3
			var end_r = mid_r + 5.0 + 2.0 * sin(_time * 6.0 + i)
			var p_end = Vector2(cos(end_angle), sin(end_angle)) * end_r
			draw_line(p_start, p_mid, flare_color, 1.2)
			draw_line(p_mid, p_end, flare_color, 0.8)

	# --- Sensor eye at front ---
	var sensor_pos = Vector2(13, 0)
	var sensor_radius = 2.0 if _state == State.AMBUSHING else 1.5
	draw_circle(sensor_pos, sensor_radius, sensor_color)
	if _state == State.AMBUSHING:
		var glow_color = Color(sensor_color.r, sensor_color.g, sensor_color.b, 0.25)
		draw_circle(sensor_pos, sensor_radius + 1.5, glow_color)

	# --- Engine exhaust at rear ---
	var exhaust_color = Color(0.3, 0.4, 0.8, engine_brightness * 0.7)
	var exhaust_width = 3.0 + 1.0 * sin(_time * 8.0)
	var exhaust_len = 4.0 + 3.0 * engine_brightness + 1.5 * sin(_time * 6.0)
	var exhaust_points = PackedVector2Array([
		Vector2(-14, -exhaust_width),
		Vector2(-14 - exhaust_len, 0),
		Vector2(-14, exhaust_width),
	])
	var exhaust_fill = Color(0.2, 0.3, 0.7, engine_brightness * 0.5)
	draw_colored_polygon(exhaust_points, exhaust_fill)
	draw_line(Vector2(-14, -exhaust_width), Vector2(-14 - exhaust_len, 0), exhaust_color, 1.0)
	draw_line(Vector2(-14, exhaust_width), Vector2(-14 - exhaust_len, 0), exhaust_color, 1.0)
	if engine_brightness > 0.6:
		var core_color = Color(0.5, 0.7, 1.0, engine_brightness * 0.6)
		var core_len = exhaust_len * 0.5
		draw_line(Vector2(-14, 0), Vector2(-14 - core_len, 0), core_color, 1.5)
