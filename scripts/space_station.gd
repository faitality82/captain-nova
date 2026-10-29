extends Node2D

signal player_entered_dock(station: Node)
signal player_exited_dock

var station_name: String = "Station"

# Animation state
var _time: float = 0.0
var _panel_angle: float = 0.0
var _blink_phase: float = 0.0

# Visual constants
const HUB_RADIUS := 18.0
const PANEL_LENGTH := 28.0
const PANEL_WIDTH := 8.0
const DOCK_RING_RADIUS := 50.0
const LIGHT_RADIUS := 2.0
const PANEL_ROTATION_SPEED := 0.3
const BLINK_SPEED := 2.5

# Colors
const COLOR_HUB := Color(0.45, 0.52, 0.62, 1.0)
const COLOR_HUB_BORDER := Color(0.6, 0.68, 0.78, 1.0)
const COLOR_HUB_INNER := Color(0.3, 0.38, 0.5, 1.0)
const COLOR_PANEL := Color(0.2, 0.25, 0.45, 1.0)
const COLOR_PANEL_GRID := Color(0.3, 0.4, 0.7, 0.6)
const COLOR_PANEL_FRAME := Color(0.5, 0.55, 0.65, 1.0)
const COLOR_DOCK_RING := Color(0.4, 0.6, 0.9, 0.4)
const COLOR_LIGHT_ON := Color(1.0, 0.3, 0.2, 1.0)
const COLOR_LIGHT_OFF := Color(0.3, 0.1, 0.08, 0.5)
const COLOR_LIGHT_NAV := Color(0.2, 1.0, 0.4, 1.0)
const COLOR_STRUT := Color(0.55, 0.58, 0.65, 1.0)

func _ready() -> void:
	add_to_group("station")

	# Name label
	var label = Label.new()
	label.name = "NameLabel"
	label.text = station_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-40, -50)
	label.size = Vector2(80, 20)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.5, 0.7, 1, 1))
	add_child(label)

	# Landing zone
	var zone = Area2D.new()
	zone.name = "LandingZone"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 80.0
	shape.shape = circle
	zone.add_child(shape)
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)
	add_child(zone)

func _process(delta: float) -> void:
	_time += delta
	_panel_angle += PANEL_ROTATION_SPEED * delta
	_blink_phase = fmod(_time * BLINK_SPEED, TAU)
	queue_redraw()

func _draw() -> void:
	_draw_dock_ring()
	_draw_struts()
	_draw_solar_panels()
	_draw_hub()
	_draw_lights()

func _draw_dock_ring() -> void:
	# Dashed circle for the docking zone
	var segments := 32
	var dash_count := 16
	for i in range(segments):
		var frac := float(i) / float(segments)
		# Skip every other segment to create dashes
		if int(frac * dash_count * 2) % 2 == 1:
			continue
		var a0 := frac * TAU
		var a1 := float(i + 1) / float(segments) * TAU
		var p0 := Vector2(cos(a0), sin(a0)) * DOCK_RING_RADIUS
		var p1 := Vector2(cos(a1), sin(a1)) * DOCK_RING_RADIUS
		# Pulse the dock ring alpha gently
		var pulse_alpha := 0.3 + 0.15 * sin(_time * 1.5)
		var ring_color := Color(COLOR_DOCK_RING.r, COLOR_DOCK_RING.g, COLOR_DOCK_RING.b, pulse_alpha)
		draw_line(p0, p1, ring_color, 1.5)

func _draw_struts() -> void:
	# Draw connecting struts from hub to each solar panel
	for i in range(4):
		var angle := _panel_angle + i * TAU / 4.0
		var dir := Vector2(cos(angle), sin(angle))
		var start := dir * (HUB_RADIUS - 2.0)
		var end := dir * (HUB_RADIUS + PANEL_LENGTH * 0.5)
		draw_line(start, end, COLOR_STRUT, 2.0)

func _draw_solar_panels() -> void:
	# 4 rectangular solar panels extending from the hub
	for i in range(4):
		var angle := _panel_angle + i * TAU / 4.0
		var dir := Vector2(cos(angle), sin(angle))
		var perp := Vector2(-dir.y, dir.x)
		var center := dir * (HUB_RADIUS + PANEL_LENGTH * 0.5 + 2.0)

		# Panel rectangle corners
		var half_len := PANEL_LENGTH * 0.5
		var half_wid := PANEL_WIDTH * 0.5
		var corners: Array[Vector2] = [
			center + dir * half_len + perp * half_wid,
			center + dir * half_len - perp * half_wid,
			center - dir * half_len - perp * half_wid,
			center - dir * half_len + perp * half_wid,
		]

		# Fill
		var packed := PackedVector2Array(corners)
		var colors := PackedColorArray([COLOR_PANEL, COLOR_PANEL, COLOR_PANEL, COLOR_PANEL])
		draw_polygon(packed, colors)

		# Frame outline
		for j in range(4):
			draw_line(corners[j], corners[(j + 1) % 4], COLOR_PANEL_FRAME, 1.0)

		# Grid lines across the panel (solar cell detail)
		var grid_lines := 3
		for g in range(1, grid_lines + 1):
			var t := float(g) / float(grid_lines + 1)
			var p0 := corners[3].lerp(corners[0], t)
			var p1 := corners[2].lerp(corners[1], t)
			draw_line(p0, p1, COLOR_PANEL_GRID, 0.8)
		# Cross line
		var mid0 := (corners[0] + corners[3]) * 0.5
		var mid1 := (corners[1] + corners[2]) * 0.5
		draw_line(mid0, mid1, COLOR_PANEL_GRID, 0.8)

func _draw_hub() -> void:
	# Octagonal central hub
	var points: Array[Vector2] = []
	var inner_points: Array[Vector2] = []
	for i in range(8):
		var angle := i * TAU / 8.0 - TAU / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * HUB_RADIUS)
		inner_points.append(Vector2(cos(angle), sin(angle)) * (HUB_RADIUS * 0.55))

	# Outer hull fill
	var packed := PackedVector2Array(points)
	var outer_colors: Array[Color] = []
	for i in range(8):
		outer_colors.append(COLOR_HUB)
	draw_polygon(packed, PackedColorArray(outer_colors))

	# Outer hull border
	for i in range(8):
		draw_line(points[i], points[(i + 1) % 8], COLOR_HUB_BORDER, 1.5)

	# Inner ring detail
	var inner_packed := PackedVector2Array(inner_points)
	var inner_colors: Array[Color] = []
	for i in range(8):
		inner_colors.append(COLOR_HUB_INNER)
	draw_polygon(inner_packed, PackedColorArray(inner_colors))

	# Center viewport window
	draw_circle(Vector2.ZERO, 5.0, Color(0.15, 0.25, 0.5, 1.0))
	draw_arc(Vector2.ZERO, 5.0, 0, TAU, 16, Color(0.5, 0.6, 0.8, 0.8), 1.0)

func _draw_lights() -> void:
	# Blinking warning lights at the tips of each hub edge
	var blink_on := sin(_blink_phase) > 0.0
	var alt_blink_on := sin(_blink_phase + PI) > 0.0

	for i in range(8):
		var angle := i * TAU / 8.0 - TAU / 16.0
		var pos := Vector2(cos(angle), sin(angle)) * (HUB_RADIUS + 1.0)
		var on := blink_on if i % 2 == 0 else alt_blink_on
		var color := COLOR_LIGHT_ON if on else COLOR_LIGHT_OFF
		draw_circle(pos, LIGHT_RADIUS, color)

	# Navigation lights at solar panel tips
	for i in range(4):
		var angle := _panel_angle + i * TAU / 4.0
		var dir := Vector2(cos(angle), sin(angle))
		var tip := dir * (HUB_RADIUS + PANEL_LENGTH + 4.0)
		var nav_on := sin(_blink_phase + i * PI * 0.5) > 0.2
		var alpha := 1.0 if nav_on else 0.2
		var nav_color := Color(COLOR_LIGHT_NAV.r, COLOR_LIGHT_NAV.g, COLOR_LIGHT_NAV.b, alpha)
		draw_circle(tip, LIGHT_RADIUS * 0.8, nav_color)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_entered_dock.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_exited_dock.emit()
