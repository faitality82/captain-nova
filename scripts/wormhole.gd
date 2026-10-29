extends Node2D

signal player_entered_wormhole(wormhole: Node)
signal player_exited_wormhole

var wormhole_name: String = "Wormhole"
var destination_label: String = "Unknown"
var linked_wormhole: Node2D = null

var is_endgame: bool = false  # golden wormhole — end-of-beta portal

var _time: float = 0.0

# Visual constants
const OUTER_RADIUS := 40.0
const INNER_RADIUS := 8.0
const SPIRAL_ARMS := 4
const SPIRAL_POINTS := 20
const ROTATION_SPEED := 1.2
const PULSE_SPEED := 2.0
const TENDRIL_COUNT := 6

# Colors (defaults = purple, overridden for golden wormhole)
const COLOR_RING_OUTER := Color(0.6, 0.3, 1.0, 0.8)
const COLOR_RING_INNER := Color(0.4, 0.2, 0.9, 1.0)
const COLOR_SPIRAL := Color(0.5, 0.25, 0.85, 0.6)
const COLOR_CORE := Color(0.8, 0.6, 1.0, 1.0)
const COLOR_TENDRIL := Color(0.55, 0.3, 0.9, 0.4)

# Override colors (set before _ready to customize)
var color_ring_outer: Color = COLOR_RING_OUTER
var color_ring_inner: Color = COLOR_RING_INNER
var color_spiral: Color = COLOR_SPIRAL
var color_core: Color = COLOR_CORE
var color_tendril: Color = COLOR_TENDRIL
var color_label: Color = Color(0.7, 0.4, 1.0, 1)

var _tendrils: Array = []

func _ready() -> void:
	add_to_group("wormhole")

	var label = Label.new()
	label.name = "NameLabel"
	label.text = wormhole_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -55)
	label.size = Vector2(100, 20)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", color_label)
	add_child(label)

	var zone = Area2D.new()
	zone.name = "WarpZone"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 60.0
	shape.shape = circle
	zone.add_child(shape)
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)
	add_child(zone)

	# Initialize tendrils
	for i in TENDRIL_COUNT:
		_tendrils.append({
			"angle": randf() * TAU,
			"speed": randf_range(0.3, 0.8),
			"length": randf_range(30.0, 55.0),
			"phase": randf() * TAU,
		})

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	_draw_outer_ring()
	_draw_spiral_arms()
	_draw_tendrils()
	_draw_core()

func _draw_outer_ring() -> void:
	var pulse = 1.0 + sin(_time * PULSE_SPEED) * 0.1
	var radius = OUTER_RADIUS * pulse
	# Golden wormhole is bigger and more dramatic
	var scale_mult: float = 1.8 if is_endgame else 1.0
	radius *= scale_mult
	# Outer glow ring
	draw_arc(Vector2.ZERO, radius + 4.0, 0, TAU, 48, Color(color_ring_outer.r, color_ring_outer.g, color_ring_outer.b, 0.2), 6.0 * scale_mult)
	# Main ring
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, color_ring_outer, 2.5 * scale_mult)
	# Inner ring
	draw_arc(Vector2.ZERO, radius * 0.7, 0, TAU, 36, Color(color_ring_inner.r, color_ring_inner.g, color_ring_inner.b, 0.4), 1.5 * scale_mult)
	# Extra glow layer for golden wormhole
	if is_endgame:
		draw_arc(Vector2.ZERO, radius + 12.0, 0, TAU, 48, Color(color_ring_outer.r, color_ring_outer.g, color_ring_outer.b, 0.08), 12.0)

func _draw_spiral_arms() -> void:
	var spin = _time * ROTATION_SPEED
	var scale_mult: float = 1.8 if is_endgame else 1.0
	for arm in SPIRAL_ARMS:
		var arm_offset = (TAU / SPIRAL_ARMS) * arm
		var prev_pos = Vector2.ZERO
		for i in range(SPIRAL_POINTS):
			var t = float(i) / float(SPIRAL_POINTS - 1)
			var r = lerp(INNER_RADIUS, OUTER_RADIUS * 0.9, t) * scale_mult
			var angle = arm_offset + spin + t * TAU * 0.75
			var pos = Vector2(cos(angle), sin(angle)) * r
			if i > 0:
				var alpha = (1.0 - t) * 0.6
				var width = lerp(2.5, 0.5, t) * scale_mult
				draw_line(prev_pos, pos, Color(color_spiral.r, color_spiral.g, color_spiral.b, alpha), width)
			prev_pos = pos

func _draw_tendrils() -> void:
	var scale_mult: float = 1.8 if is_endgame else 1.0
	for t in _tendrils:
		var angle = t["angle"] + _time * t["speed"]
		var length = (t["length"] + sin(_time * 1.5 + t["phase"]) * 8.0) * scale_mult
		var start = Vector2(cos(angle), sin(angle)) * OUTER_RADIUS * scale_mult
		var end = Vector2(cos(angle), sin(angle)) * (OUTER_RADIUS * scale_mult + length)
		var alpha = 0.15 + sin(_time * 2.0 + t["phase"]) * 0.1
		draw_line(start, end, Color(color_tendril.r, color_tendril.g, color_tendril.b, alpha), 1.5 * scale_mult)

func _draw_core() -> void:
	var scale_mult: float = 1.8 if is_endgame else 1.0
	# Bright center
	var core_pulse = 1.0 + sin(_time * 3.0) * 0.2
	draw_circle(Vector2.ZERO, INNER_RADIUS * core_pulse * scale_mult, color_core)
	# Core glow
	draw_circle(Vector2.ZERO, INNER_RADIUS * core_pulse * 1.5 * scale_mult, Color(color_core.r, color_core.g, color_core.b, 0.2))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_entered_wormhole.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_exited_wormhole.emit()
