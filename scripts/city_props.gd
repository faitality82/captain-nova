extends RefCounted
class_name CityProps

# Draw a prop at the given position. Origin is bottom-center of prop.
# Returns the width of the prop (for spacing calculations).

static func draw_prop(node: Node2D, prop_type: String, pos: Vector2, t: float) -> float:
	match prop_type:
		"lamp_post":
			_draw_lamp_post(node, pos, t)
			return 10.0
		"bench":
			_draw_bench(node, pos, t)
			return 20.0
		"hover_car":
			_draw_hover_car(node, pos, t)
			return 40.0
		"crate":
			_draw_crate(node, pos, t)
			return 16.0
		"pipe":
			_draw_pipe(node, pos, t)
			return 12.0
		"heat_vent":
			_draw_heat_vent(node, pos, t)
			return 14.0
		"sandbag":
			_draw_sandbag(node, pos, t)
			return 18.0
		"antenna":
			_draw_antenna(node, pos, t)
			return 8.0
		"fuel_tank":
			_draw_fuel_tank(node, pos, t)
			return 24.0
		"ice_chunk":
			_draw_ice_chunk(node, pos, t)
			return 16.0
		"scrap_pile":
			_draw_scrap_pile(node, pos, t)
			return 30.0
		"barrel":
			_draw_barrel(node, pos, t)
			return 12.0
		"geyser_vent":
			_draw_geyser_vent(node, pos, t)
			return 14.0
		"trash_can":
			_draw_trash_can(node, pos, t)
			return 10.0
		"sign":
			_draw_sign(node, pos, t)
			return 8.0
		"planter":
			_draw_planter(node, pos, t)
			return 16.0
		"tarp":
			_draw_tarp(node, pos, t)
			return 22.0
		"acid_pipe":
			_draw_acid_pipe(node, pos, t)
			return 12.0
		"platform_strut":
			_draw_platform_strut(node, pos, t)
			return 10.0
		"crane_arm":
			_draw_crane_arm(node, pos, t)
			return 20.0
		"data_terminal":
			_draw_data_terminal(node, pos, t)
			return 14.0
		"cable_conduit":
			_draw_cable_conduit(node, pos, t)
			return 10.0
		"lab_crate":
			_draw_lab_crate(node, pos, t)
			return 16.0
		"wire_spool":
			_draw_wire_spool(node, pos, t)
			return 14.0
	return 10.0

static func _draw_lamp_post(node: Node2D, pos: Vector2, t: float) -> void:
	# Tall pole with glowing light at top
	node.draw_line(pos, pos + Vector2(0, -40), Color(0.4, 0.4, 0.4), 2.0)
	node.draw_line(pos + Vector2(0, -40), pos + Vector2(8, -38), Color(0.4, 0.4, 0.4), 1.5)
	var glow_a := 0.4 + 0.1 * sin(t * 1.5)
	node.draw_circle(pos + Vector2(8, -38), 5.0, Color(1.0, 0.9, 0.6, glow_a))
	node.draw_circle(pos + Vector2(8, -38), 12.0, Color(1.0, 0.9, 0.6, glow_a * 0.15))

static func _draw_bench(node: Node2D, pos: Vector2, _t: float) -> void:
	# Simple bench
	node.draw_rect(Rect2(pos.x - 10, pos.y - 8, 20, 3), Color(0.4, 0.3, 0.2))
	node.draw_line(pos + Vector2(-8, -8), pos + Vector2(-8, 0), Color(0.35, 0.25, 0.15), 2.0)
	node.draw_line(pos + Vector2(8, -8), pos + Vector2(8, 0), Color(0.35, 0.25, 0.15), 2.0)

static func _draw_hover_car(node: Node2D, pos: Vector2, t: float) -> void:
	# Parked hover car — floating slightly
	var hover := sin(t * 1.2) * 1.5
	var y := pos.y - 6 + hover
	node.draw_rect(Rect2(pos.x - 18, y - 8, 36, 8), Color(0.3, 0.35, 0.5))
	node.draw_rect(Rect2(pos.x - 12, y - 14, 24, 6), Color(0.35, 0.4, 0.55))
	# Windows
	node.draw_rect(Rect2(pos.x - 10, y - 13, 8, 4), Color(0.5, 0.7, 0.9, 0.4))
	node.draw_rect(Rect2(pos.x + 2, y - 13, 8, 4), Color(0.5, 0.7, 0.9, 0.4))
	# Hover glow
	node.draw_circle(Vector2(pos.x - 8, pos.y - 1), 2.0, Color(0.3, 0.6, 1.0, 0.3))
	node.draw_circle(Vector2(pos.x + 8, pos.y - 1), 2.0, Color(0.3, 0.6, 1.0, 0.3))

static func _draw_crate(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_rect(Rect2(pos.x - 7, pos.y - 12, 14, 12), Color(0.45, 0.35, 0.2))
	node.draw_line(pos + Vector2(-7, -6), pos + Vector2(7, -6), Color(0.35, 0.25, 0.15, 0.5), 1.0)
	node.draw_line(pos + Vector2(0, -12), pos + Vector2(0, 0), Color(0.35, 0.25, 0.15, 0.5), 1.0)

static func _draw_pipe(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_line(pos + Vector2(-5, -3), pos + Vector2(5, -3), Color(0.4, 0.4, 0.35), 4.0)
	node.draw_line(pos + Vector2(-5, -3), pos + Vector2(-5, -15), Color(0.4, 0.4, 0.35), 4.0)

static func _draw_heat_vent(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_rect(Rect2(pos.x - 6, pos.y - 5, 12, 5), Color(0.4, 0.3, 0.25))
	# Heat shimmer
	var shimmer_a := 0.15 + 0.1 * sin(t * 3.0)
	node.draw_circle(pos + Vector2(0, -8), 4.0, Color(1.0, 0.5, 0.2, shimmer_a))

static func _draw_sandbag(node: Node2D, pos: Vector2, _t: float) -> void:
	# Stack of two sandbags
	node.draw_rect(Rect2(pos.x - 8, pos.y - 6, 16, 6), Color(0.5, 0.4, 0.25))
	node.draw_rect(Rect2(pos.x - 6, pos.y - 11, 12, 5), Color(0.45, 0.35, 0.2))

static func _draw_antenna(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_line(pos, pos + Vector2(0, -30), Color(0.5, 0.5, 0.5), 1.5)
	node.draw_line(pos + Vector2(0, -30), pos + Vector2(-5, -25), Color(0.5, 0.5, 0.5), 1.0)
	node.draw_line(pos + Vector2(0, -30), pos + Vector2(5, -25), Color(0.5, 0.5, 0.5), 1.0)
	var blink := 0.5 + 0.5 * sin(t * 4.0)
	node.draw_circle(pos + Vector2(0, -30), 1.5, Color(1.0, 0.2, 0.2, blink))

static func _draw_fuel_tank(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_rect(Rect2(pos.x - 10, pos.y - 20, 20, 20), Color(0.35, 0.4, 0.35))
	node.draw_arc(Vector2(pos.x, pos.y - 20), 10, PI, TAU, 8, Color(0.35, 0.4, 0.35), 10.0)
	# Warning label
	node.draw_rect(Rect2(pos.x - 5, pos.y - 12, 10, 6), Color(1.0, 0.6, 0.0, 0.4))

static func _draw_ice_chunk(node: Node2D, pos: Vector2, t: float) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-7, 0),
		pos + Vector2(-5, -10),
		pos + Vector2(2, -12),
		pos + Vector2(7, -4),
		pos + Vector2(5, 0),
	])
	node.draw_colored_polygon(pts, Color(0.5, 0.7, 0.8, 0.6))
	var glint := 0.2 + 0.15 * sin(t * 2.0)
	node.draw_circle(pos + Vector2(0, -6), 2.0, Color(0.8, 0.9, 1.0, glint))

static func _draw_scrap_pile(node: Node2D, pos: Vector2, _t: float) -> void:
	# Messy pile of junk
	node.draw_rect(Rect2(pos.x - 12, pos.y - 8, 8, 8), Color(0.3, 0.28, 0.25))
	node.draw_rect(Rect2(pos.x - 5, pos.y - 12, 10, 12), Color(0.35, 0.3, 0.27))
	node.draw_rect(Rect2(pos.x + 3, pos.y - 6, 9, 6), Color(0.28, 0.25, 0.22))
	# Protruding pipe
	node.draw_line(pos + Vector2(-8, -8), pos + Vector2(-12, -15), Color(0.4, 0.35, 0.3), 2.0)

static func _draw_barrel(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_rect(Rect2(pos.x - 5, pos.y - 14, 10, 14), Color(0.35, 0.3, 0.25))
	node.draw_line(pos + Vector2(-5, -4), pos + Vector2(5, -4), Color(0.3, 0.25, 0.2), 1.5)
	node.draw_line(pos + Vector2(-5, -10), pos + Vector2(5, -10), Color(0.3, 0.25, 0.2), 1.5)

static func _draw_geyser_vent(node: Node2D, pos: Vector2, t: float) -> void:
	# Ground vent with occasional burst
	node.draw_rect(Rect2(pos.x - 6, pos.y - 3, 12, 3), Color(0.4, 0.45, 0.5))
	var burst := maxf(0.0, sin(t * 0.8)) * 0.6
	if burst > 0.1:
		for i in 3:
			var by := pos.y - 5.0 - float(i) * 8.0
			var ba := burst * (1.0 - float(i) * 0.3)
			node.draw_circle(Vector2(pos.x + sin(t * 3.0 + float(i)) * 2.0, by), 3.0 - float(i) * 0.5, Color(0.6, 0.7, 0.9, ba))

static func _draw_trash_can(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_rect(Rect2(pos.x - 4, pos.y - 12, 8, 12), Color(0.35, 0.35, 0.35))
	node.draw_rect(Rect2(pos.x - 5, pos.y - 13, 10, 2), Color(0.4, 0.4, 0.4))

static func _draw_sign(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_line(pos, pos + Vector2(0, -25), Color(0.4, 0.4, 0.4), 1.5)
	node.draw_rect(Rect2(pos.x - 8, pos.y - 30, 16, 8), Color(0.2, 0.2, 0.25))
	var glow := 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(pos.x - 6, pos.y - 28, 12, 4), Color(0.3, 0.8, 1.0, glow))

static func _draw_planter(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_rect(Rect2(pos.x - 7, pos.y - 8, 14, 8), Color(0.4, 0.3, 0.2))
	# Plants
	node.draw_circle(pos + Vector2(-3, -10), 4.0, Color(0.2, 0.5, 0.2, 0.7))
	node.draw_circle(pos + Vector2(3, -11), 3.5, Color(0.15, 0.45, 0.15, 0.7))

static func _draw_tarp(node: Node2D, pos: Vector2, _t: float) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-10, 0),
		pos + Vector2(-8, -8),
		pos + Vector2(0, -6),
		pos + Vector2(8, -9),
		pos + Vector2(10, 0),
	])
	node.draw_colored_polygon(pts, Color(0.4, 0.35, 0.25, 0.7))

static func _draw_acid_pipe(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_line(pos + Vector2(-5, -3), pos + Vector2(5, -3), Color(0.4, 0.5, 0.2), 4.0)
	# Drip
	var drip_y := fmod(t * 8.0, 10.0)
	node.draw_circle(pos + Vector2(2, -3 + drip_y), 1.5, Color(0.5, 0.6, 0.1, 0.5))

static func _draw_platform_strut(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_line(pos, pos + Vector2(0, -35), Color(0.5, 0.45, 0.3), 3.0)
	node.draw_line(pos + Vector2(-4, 0), pos + Vector2(0, -15), Color(0.45, 0.4, 0.28), 1.5)
	node.draw_line(pos + Vector2(4, 0), pos + Vector2(0, -15), Color(0.45, 0.4, 0.28), 1.5)

static func _draw_crane_arm(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_line(pos, pos + Vector2(0, -30), Color(0.5, 0.45, 0.3), 3.0)
	var swing := sin(t * 0.3) * 10.0
	node.draw_line(pos + Vector2(0, -30), pos + Vector2(swing, -30), Color(0.5, 0.45, 0.3), 2.0)
	# Hanging cable
	node.draw_line(pos + Vector2(swing, -30), pos + Vector2(swing, -20), Color(0.4, 0.4, 0.4), 1.0)
	node.draw_rect(Rect2(pos.x + swing - 3, pos.y - 20, 6, 4), Color(0.45, 0.4, 0.3))

static func _draw_data_terminal(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_rect(Rect2(pos.x - 6, pos.y - 18, 12, 18), Color(0.3, 0.3, 0.35))
	# Screen
	var screen_a := 0.4 + 0.15 * sin(t * 2.0)
	node.draw_rect(Rect2(pos.x - 4, pos.y - 16, 8, 6), Color(0.2, 0.8, 0.4, screen_a))

static func _draw_cable_conduit(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_rect(Rect2(pos.x - 4, pos.y - 6, 8, 6), Color(0.35, 0.35, 0.4))
	# Cables running up
	node.draw_line(pos + Vector2(-2, -6), pos + Vector2(-2, -20), Color(0.2, 0.2, 0.25), 1.5)
	node.draw_line(pos + Vector2(2, -6), pos + Vector2(2, -20), Color(0.2, 0.2, 0.25), 1.5)

static func _draw_lab_crate(node: Node2D, pos: Vector2, t: float) -> void:
	node.draw_rect(Rect2(pos.x - 7, pos.y - 12, 14, 12), Color(0.4, 0.42, 0.45))
	# Biohazard symbol (simple)
	var glow := 0.3 + 0.2 * sin(t * 1.5)
	node.draw_circle(pos + Vector2(0, -6), 3.0, Color(0.0, 0.8, 0.2, glow))

static func _draw_wire_spool(node: Node2D, pos: Vector2, _t: float) -> void:
	node.draw_circle(pos + Vector2(0, -6), 6.0, Color(0.3, 0.3, 0.28))
	node.draw_circle(pos + Vector2(0, -6), 3.0, Color(0.25, 0.25, 0.22))
	# Wire trailing
	node.draw_line(pos + Vector2(6, -6), pos + Vector2(10, -2), Color(0.4, 0.3, 0.2), 1.0)
