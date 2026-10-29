# sun.gd
# Procedural animated sun with gravitational pull and instant-kill contact.
extends Node2D

signal player_burned

# Gravity tuning
const GRAVITY_STRENGTH: float = 800000.0
const GRAVITY_RANGE: float = 2000.0
const KILL_RADIUS: float = 70.0

# Solar flare
var _flare_active: bool = false
const FLARE_KILL_RADIUS: float = 200.0
const FLARE_GRAVITY_RANGE: float = 3000.0

# --- Procedural rendering ---
const CORE_RADIUS: float = 60.0
const RAY_COUNT: int = 14
const RAY_BASE_LENGTH: float = 40.0
const RAY_WIDTH: float = 18.0
const SUNSPOT_COUNT: int = 5
const GLOW_RING_RADIUS: float = 90.0

# Colors
const COLOR_CENTER := Color(1.0, 1.0, 0.85, 1.0)
const COLOR_EDGE := Color(1.0, 0.6, 0.1, 1.0)
const COLOR_RAY := Color(1.0, 0.75, 0.2, 0.6)
const COLOR_SUNSPOT := Color(0.85, 0.4, 0.05, 0.5)
const COLOR_GLOW := Color(1.0, 0.8, 0.3, 0.15)

# Flare colors
const FLARE_COLOR_CENTER := Color(1.0, 0.5, 0.15, 1.0)
const FLARE_COLOR_EDGE := Color(0.9, 0.2, 0.05, 1.0)
const FLARE_COLOR_RAY := Color(1.0, 0.4, 0.1, 0.7)

# Animation state
var _time: float = 0.0
var _ray_rotation: float = 0.0
var _sunspot_offsets: Array = []
var _flare_lerp: float = 0.0
var _flare_angle: float = 0.0

func _ready() -> void:
	add_to_group("sun")
	for i in range(SUNSPOT_COUNT):
		_sunspot_offsets.append(Vector2(
			randf() * TAU,
			randf_range(0.2, 0.7) * CORE_RADIUS
		))
	_flare_angle = randf() * TAU

func _process(delta: float) -> void:
	_time += delta
	_ray_rotation += delta * 0.15

	var target_lerp = 1.0 if _flare_active else 0.0
	_flare_lerp = move_toward(_flare_lerp, target_lerp, delta * 2.0)

	for i in range(_sunspot_offsets.size()):
		_sunspot_offsets[i].x += delta * 0.3

	queue_redraw()
	_apply_gravity(delta)
	_check_kill()

func _draw() -> void:
	_draw_glow_ring()
	_draw_corona_rays()
	_draw_core()
	_draw_sunspots()
	if _flare_lerp > 0.05:
		_draw_flare_tendril()

# --- Drawing layers ---

func _draw_core() -> void:
	var steps := 8
	for i in range(steps):
		var t = float(i) / float(steps - 1)
		var radius = CORE_RADIUS * (1.0 - t * 0.85)
		var normal_color = COLOR_EDGE.lerp(COLOR_CENTER, t)
		var flare_color = FLARE_COLOR_EDGE.lerp(FLARE_COLOR_CENTER, t)
		var color = normal_color.lerp(flare_color, _flare_lerp)
		draw_circle(Vector2.ZERO, radius, color)

func _draw_corona_rays() -> void:
	var ray_color = COLOR_RAY.lerp(FLARE_COLOR_RAY, _flare_lerp)
	var flare_length_mult = 1.0 + _flare_lerp * 1.0

	for i in range(RAY_COUNT):
		var base_angle = (TAU / RAY_COUNT) * i + _ray_rotation
		var pulse = sin(_time * 1.5 + i * 0.7) * 0.3 + 0.7
		var ray_len = RAY_BASE_LENGTH * pulse * flare_length_mult

		var dir = Vector2(cos(base_angle), sin(base_angle))
		var perp = Vector2(-dir.y, dir.x)

		var tip = dir * (CORE_RADIUS + ray_len)
		var base_left = dir * CORE_RADIUS + perp * (RAY_WIDTH * 0.5)
		var base_right = dir * CORE_RADIUS - perp * (RAY_WIDTH * 0.5)

		var points = PackedVector2Array([base_left, tip, base_right])
		var colors = PackedColorArray([
			Color(ray_color.r, ray_color.g, ray_color.b, ray_color.a * 0.3),
			Color(ray_color.r, ray_color.g, ray_color.b, ray_color.a * 0.8),
			Color(ray_color.r, ray_color.g, ray_color.b, ray_color.a * 0.3),
		])
		draw_polygon(points, colors)

func _draw_sunspots() -> void:
	for offset in _sunspot_offsets:
		var angle = offset.x
		var dist = offset.y
		var pos = Vector2(cos(angle), sin(angle)) * dist
		var spot_radius = 5.0 + sin(_time * 0.5 + angle * 3.0) * 2.5
		var alpha = 0.3 + sin(_time * 2.0 + angle) * 0.15
		var color = Color(COLOR_SUNSPOT.r, COLOR_SUNSPOT.g, COLOR_SUNSPOT.b, alpha)
		draw_circle(pos, spot_radius, color)

func _draw_glow_ring() -> void:
	var pulse = sin(_time * 0.8) * 0.05 + 0.12
	var alpha = pulse + _flare_lerp * 0.1
	var glow_color = Color(COLOR_GLOW.r, COLOR_GLOW.g, COLOR_GLOW.b, alpha)
	var radius = GLOW_RING_RADIUS + sin(_time * 1.2) * 5.0 + _flare_lerp * 30.0
	for i in range(4):
		var r = radius + i * 12.0
		var a = alpha * (1.0 - float(i) * 0.25)
		var c = Color(glow_color.r, glow_color.g, glow_color.b, maxf(a, 0.0))
		draw_arc(Vector2.ZERO, r, 0, TAU, 64, c, 3.0)

func _draw_flare_tendril() -> void:
	var dir = Vector2(cos(_flare_angle), sin(_flare_angle))
	var perp = Vector2(-dir.y, dir.x)

	var start = dir * CORE_RADIUS
	var end_dist = CORE_RADIUS + (FLARE_KILL_RADIUS - CORE_RADIUS) * _flare_lerp
	var end_point = dir * end_dist
	var control = dir * (end_dist * 0.6) + perp * 60.0

	var segments := 16
	var prev = start
	for i in range(1, segments + 1):
		var t = float(i) / float(segments)
		var point = (1.0 - t) * (1.0 - t) * start + 2.0 * (1.0 - t) * t * control + t * t * end_point
		var alpha = (1.0 - t) * _flare_lerp * 0.8
		var width = (1.0 - t) * 8.0 + 2.0
		var color = Color(1.0, 0.5, 0.1, alpha)
		draw_line(prev, point, color, width)
		prev = point

# --- Gravity & Kill (unchanged) ---

func _apply_gravity(delta: float) -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null or ship.is_dead:
		return

	var to_sun = global_position - ship.global_position
	var dist = to_sun.length()

	var effective_range = FLARE_GRAVITY_RANGE if _flare_active else GRAVITY_RANGE
	if dist < effective_range and dist > 1.0:
		var force = GRAVITY_STRENGTH / (dist * dist)
		force = minf(force, 600.0)
		ship.apply_force(to_sun.normalized() * force * delta)

func _check_kill() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null or ship.is_dead:
		return

	var dist = global_position.distance_to(ship.global_position)
	var effective_kill = FLARE_KILL_RADIUS if _flare_active else KILL_RADIUS
	if dist < effective_kill:
		player_burned.emit()

func start_flare() -> void:
	_flare_active = true
	_flare_angle = randf() * TAU

func end_flare() -> void:
	_flare_active = false
