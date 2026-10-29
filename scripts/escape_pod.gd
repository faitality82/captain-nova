extends Node2D

signal pod_finished

var target_position: Vector2 = Vector2.ZERO
var speed: float = 50.0
var _elapsed: float = 0.0
var _duration: float = 2.5

var _wobble_angle: float = 0.0
var _blink_time: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var dir = (target_position - global_position).normalized()
	global_position += dir * speed * delta

	# Orient toward travel direction
	rotation = dir.angle()

	# Wobble animation for tumbling effect
	_wobble_angle += delta * 8.0
	_blink_time += delta

	_elapsed += delta
	queue_redraw()
	if _elapsed >= _duration:
		pod_finished.emit()
		queue_free()

func _draw() -> void:
	var wobble = sin(_wobble_angle) * 0.15

	# --- Thruster trail (drawn behind the pod, in local -X direction) ---
	var trail_colors: Array[Color] = [
		Color(1.0, 0.6, 0.1, 0.15),
		Color(1.0, 0.5, 0.0, 0.25),
		Color(1.0, 0.4, 0.0, 0.4),
	]
	var trail_radii: Array[float] = [2.0, 2.5, 3.0]
	var trail_offsets: Array[float] = [-14.0, -11.0, -8.5]
	for i in range(3):
		var offset_y = sin(_wobble_angle + float(i) * 1.2) * 1.0
		draw_circle(Vector2(trail_offsets[i], offset_y), trail_radii[i], trail_colors[i])

	# --- Capsule body (orange-yellow oval) ---
	var body_color = Color(1.0, 0.78, 0.2, 1.0)
	var highlight_color = Color(1.0, 0.9, 0.5, 0.6)

	# Draw oval body using ellipse approximation with segments
	_draw_ellipse(Vector2.ZERO, 8.0, 5.0, wobble, body_color)
	# Lighter highlight on top half
	_draw_ellipse(Vector2(1.0, -1.0), 5.0, 3.0, wobble, highlight_color)

	# --- Blinking emergency light (red dot that pulses) ---
	var blink_intensity = (sin(_blink_time * 6.0) + 1.0) * 0.5  # 0..1 pulsing
	var red_alpha = 0.3 + blink_intensity * 0.7
	var light_color = Color(1.0, 0.1, 0.0, red_alpha)
	var glow_color = Color(1.0, 0.2, 0.1, red_alpha * 0.3)

	var light_pos = Vector2(4.0, -3.0)
	draw_circle(light_pos, 2.5, glow_color)
	draw_circle(light_pos, 1.2, light_color)

func _draw_ellipse(center: Vector2, rx: float, ry: float, wobble: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var segments: int = 16
	for i in range(segments + 1):
		var angle = (float(i) / float(segments)) * TAU + wobble
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	var colors: PackedColorArray = PackedColorArray()
	for i in range(points.size()):
		colors.append(color)
	if points.size() >= 3:
		draw_polygon(points, colors)
