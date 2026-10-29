extends Node2D

## Procedural cityscape skyline drawn behind foreground buildings.
## Positioned at ground level; structures grow upward (negative y).
## Each planet has a completely unique silhouette and atmosphere.

var _planet: String = "Earth"
var _width: float = 1200.0
var _time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Animated element data (populated per-planet in setup)
var _blink_lights: Array = []   # {pos, color, phase, speed, size}
var _moving_elements: Array = [] # {type, data}  — planet-specific

func setup(planet: String, city_width: float) -> void:
	_planet = planet
	_width = city_width
	_rng.seed = hash(planet) + 42
	_generate_animated_elements()

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	match _planet:
		"Mercury": _draw_mercury()
		"Venus": _draw_venus()
		"Earth": _draw_earth()
		"Mars": _draw_mars()
		"Jupiter": _draw_jupiter()
		"Saturn": _draw_saturn()
		"Uranus": _draw_uranus()
		"Neptune": _draw_neptune()
		"Pluto": _draw_pluto()
		_: _draw_earth()
	_draw_blink_lights()

# ── Animated element generation ─────────────────

func _generate_animated_elements() -> void:
	_blink_lights.clear()
	_moving_elements.clear()
	match _planet:
		"Mercury":
			_add_blink_lights(8, Color(1.0, 0.5, 0.1, 0.7), -20.0, -120.0)
			_moving_elements.append({"type": "heat_shimmer", "y_min": -60.0, "y_max": -10.0})
		"Venus":
			_add_blink_lights(6, Color(0.8, 0.9, 0.2, 0.5), -40.0, -200.0)
			_moving_elements.append({"type": "acid_fog", "y": -80.0})
		"Earth":
			_add_blink_lights(15, Color(1.0, 1.0, 0.8, 0.8), -60.0, -350.0)
			_moving_elements.append({"type": "flying_vehicles", "count": 4})
			_moving_elements.append({"type": "holographic_billboard", "x": _rng.randf_range(_width * 0.3, _width * 0.7)})
		"Mars":
			_add_blink_lights(5, Color(1.0, 0.4, 0.2, 0.5), -15.0, -80.0)
			_moving_elements.append({"type": "dust_devil", "x": _rng.randf_range(100, _width - 100)})
			_moving_elements.append({"type": "radar_sweep", "x": _rng.randf_range(200, _width - 200), "y": -70.0})
		"Jupiter":
			_add_blink_lights(10, Color(0.8, 0.6, 1.0, 0.6), -30.0, -250.0)
			_moving_elements.append({"type": "crane_swing", "x": _rng.randf_range(200, _width - 200)})
			_moving_elements.append({"type": "ice_fog", "y": -15.0})
		"Saturn":
			_add_blink_lights(8, Color(0.4, 0.7, 1.0, 0.6), -50.0, -280.0)
			_moving_elements.append({"type": "dish_rotate", "x": _rng.randf_range(300, _width - 300), "y": -200.0})
		"Uranus":
			_add_blink_lights(12, Color(0.2, 0.9, 0.6, 0.7), -20.0, -180.0)
			_moving_elements.append({"type": "spark_shower", "x": _rng.randf_range(100, _width - 100)})
			_moving_elements.append({"type": "cave_drip", "count": 3})
		"Neptune":
			_add_blink_lights(6, Color(0.5, 0.7, 1.0, 0.6), -40.0, -300.0)
			_moving_elements.append({"type": "aurora_shift"})
			_moving_elements.append({"type": "geyser_burst", "x": _rng.randf_range(200, _width - 200)})
		"Pluto":
			_add_blink_lights(2, Color(0.4, 0.35, 0.5, 0.3), -10.0, -40.0)
			_moving_elements.append({"type": "void_flicker"})

func _add_blink_lights(count: int, base_color: Color, y_min: float, y_max: float) -> void:
	for i in count:
		_blink_lights.append({
			"pos": Vector2(_rng.randf_range(50, _width - 50), _rng.randf_range(y_max, y_min)),
			"color": Color(base_color.r + _rng.randf_range(-0.1, 0.1), base_color.g + _rng.randf_range(-0.1, 0.1), base_color.b, base_color.a),
			"phase": _rng.randf() * TAU,
			"speed": _rng.randf_range(1.5, 4.0),
			"size": _rng.randf_range(1.5, 3.5),
		})

func _draw_blink_lights() -> void:
	for light in _blink_lights:
		var pulse: float = sin(_time * light["speed"] + light["phase"])
		if pulse > 0.3:
			var alpha: float = light["color"].a * (pulse - 0.3) / 0.7
			var c = Color(light["color"].r, light["color"].g, light["color"].b, alpha)
			var sz: float = light["size"]
			var pos: Vector2 = light["pos"]
			# Glow halo
			draw_circle(pos, sz * 2.5, Color(c.r, c.g, c.b, alpha * 0.2))
			# Core
			draw_circle(pos, sz, c)


# ═══════════════════════════════════════════════════
# MERCURY — Low industrial horizon, refineries, heat shimmer
# ═══════════════════════════════════════════════════

func _draw_mercury() -> void:
	var base_color := Color(0.12, 0.06, 0.02)
	var highlight := Color(0.25, 0.12, 0.04)

	# Molten horizon glow
	for i in 5:
		var glow_alpha: float = 0.06 - float(i) * 0.01
		var glow_y: float = -float(i) * 15.0
		draw_rect(Rect2(-50, glow_y - 8, _width + 100, 16.0), Color(1.0, 0.4, 0.1, glow_alpha))

	# Solar panel arrays (flat angled rectangles)
	_rng.seed = hash("mercury_panels")
	for i in 8:
		var px: float = _rng.randf_range(50, _width - 50)
		var pw: float = _rng.randf_range(40, 80)
		var ph: float = _rng.randf_range(3, 8)
		var py: float = -_rng.randf_range(15, 35)
		# Support pole
		draw_line(Vector2(px + pw * 0.5, 0), Vector2(px + pw * 0.5, py), Color(0.15, 0.1, 0.05, 0.6), 2.0)
		# Panel (slightly tilted via two rects)
		draw_rect(Rect2(px, py - ph, pw, ph), Color(0.08, 0.05, 0.12, 0.5))
		draw_rect(Rect2(px + 2, py - ph + 1, pw - 4, ph - 2), Color(0.15, 0.1, 0.2, 0.3))

	# Squat refineries and smokestacks
	_rng.seed = hash("mercury_buildings")
	for i in 20:
		var bx: float = _rng.randf_range(-30, _width + 30)
		var bw: float = _rng.randf_range(25, 70)
		var bh: float = _rng.randf_range(30, 100)
		var depth_factor: float = _rng.randf_range(0.5, 1.0)
		var c = Color(base_color.r * depth_factor, base_color.g * depth_factor, base_color.b * depth_factor, 0.7)
		# Main block
		draw_rect(Rect2(bx, -bh, bw, bh), c)
		# Smokestack on some buildings
		if _rng.randf() > 0.5:
			var stack_x: float = bx + _rng.randf_range(5, bw - 8)
			var stack_h: float = bh + _rng.randf_range(15, 40)
			draw_rect(Rect2(stack_x, -stack_h, 6.0, stack_h - bh + 5), Color(highlight.r, highlight.g, highlight.b, 0.6))
			# Smoke/heat at top
			var smoke_pulse: float = sin(_time * 1.5 + float(i) * 0.7) * 0.3 + 0.5
			draw_circle(Vector2(stack_x + 3, -stack_h - 5), 4.0 + smoke_pulse * 3.0, Color(0.3, 0.15, 0.05, 0.15 * smoke_pulse))

	# Heat shimmer effect (animated wavy lines)
	for elem in _moving_elements:
		if elem["type"] == "heat_shimmer":
			for line_i in 6:
				var ly: float = lerpf(elem["y_min"], elem["y_max"], float(line_i) / 5.0)
				var shimmer_offset: float = sin(_time * 2.0 + float(line_i) * 1.3) * 3.0
				var shimmer_alpha: float = 0.04 + 0.02 * sin(_time * 1.0 + float(line_i))
				draw_line(
					Vector2(-50, ly + shimmer_offset),
					Vector2(_width + 50, ly + shimmer_offset + sin(_time * 1.5) * 2.0),
					Color(1.0, 0.6, 0.2, shimmer_alpha), 2.0
				)


# ═══════════════════════════════════════════════════
# VENUS — Domed structures in acid haze
# ═══════════════════════════════════════════════════

func _draw_venus() -> void:
	var dome_color := Color(0.25, 0.2, 0.08, 0.6)
	var walkway_color := Color(0.2, 0.18, 0.07, 0.5)

	# Thick haze layers
	for i in 8:
		var hy: float = -float(i) * 30.0 - 20.0
		var haze_alpha: float = 0.08 - float(i) * 0.008
		var haze_shift: float = sin(_time * 0.3 + float(i) * 0.5) * 10.0
		draw_rect(Rect2(-50 + haze_shift, hy, _width + 100, 35.0), Color(0.5, 0.45, 0.1, haze_alpha))

	# Domed structures
	_rng.seed = hash("venus_domes")
	var dome_positions: Array = []
	for i in 18:
		var dx: float = _rng.randf_range(-20, _width + 20)
		var dome_r: float = _rng.randf_range(20, 55)
		var dome_h: float = _rng.randf_range(40, 130)
		var depth: float = _rng.randf_range(0.4, 1.0)
		var c = Color(dome_color.r * depth, dome_color.g * depth, dome_color.b * depth, dome_color.a * depth)

		# Base structure (rectangle)
		var base_h: float = dome_h * 0.6
		draw_rect(Rect2(dx - dome_r, -base_h, dome_r * 2, base_h), c)

		# Dome top (semicircle approximated with arc + fill)
		var dome_center = Vector2(dx, -base_h)
		var dome_pts := PackedVector2Array()
		for seg in 13:
			var angle: float = PI + (float(seg) / 12.0) * PI
			dome_pts.append(dome_center + Vector2(cos(angle) * dome_r, sin(angle) * dome_r * 0.6))
		if dome_pts.size() >= 3:
			draw_colored_polygon(dome_pts, c)

		# Inner glow (yellowish)
		draw_circle(dome_center, dome_r * 0.3, Color(0.6, 0.5, 0.1, 0.08 * depth))

		dome_positions.append({"x": dx, "y": -base_h, "r": dome_r})

	# Enclosed walkways connecting nearby domes
	for i in dome_positions.size() - 1:
		var d1 = dome_positions[i]
		var d2 = dome_positions[i + 1]
		var dist: float = abs(d1["x"] - d2["x"])
		if dist < 200 and dist > 30:
			var walk_y: float = maxf(d1["y"], d2["y"]) + 10.0
			draw_rect(Rect2(minf(d1["x"], d2["x"]), walk_y, dist, 8.0), walkway_color)

	# Acid fog animation
	for elem in _moving_elements:
		if elem["type"] == "acid_fog":
			for fi in 4:
				var fog_x: float = fmod(_time * 15.0 + float(fi) * _width * 0.25, _width + 200) - 100
				var fog_y: float = elem["y"] + sin(_time * 0.5 + float(fi)) * 10.0
				draw_circle(Vector2(fog_x, fog_y), 30 + sin(_time + float(fi)) * 10.0, Color(0.5, 0.5, 0.1, 0.06))


# ═══════════════════════════════════════════════════
# EARTH — Dense megacity skyline
# ═══════════════════════════════════════════════════

func _draw_earth() -> void:
	var silhouette := Color(0.08, 0.1, 0.18)

	# Atmospheric haze at base
	for i in 4:
		var hy: float = -float(i) * 20.0 - 5.0
		draw_rect(Rect2(-50, hy, _width + 100, 25.0), Color(0.15, 0.2, 0.35, 0.06 - float(i) * 0.01))

	# Dense skyscrapers — back layer (darker, shorter variation)
	_rng.seed = hash("earth_back")
	for i in 15:
		var bx: float = _rng.randf_range(-40, _width + 40)
		var bw: float = _rng.randf_range(20, 50)
		var bh: float = _rng.randf_range(80, 200)
		var depth: float = _rng.randf_range(0.3, 0.6)
		var c = Color(silhouette.r * depth, silhouette.g * depth, silhouette.b * depth, 0.6)
		draw_rect(Rect2(bx, -bh, bw, bh), c)

	# Main layer — tall varied skyscrapers
	_rng.seed = hash("earth_main")
	for i in 25:
		var bx: float = _rng.randf_range(-30, _width + 30)
		var bw: float = _rng.randf_range(25, 65)
		var bh: float = _rng.randf_range(100, 350)
		var depth: float = _rng.randf_range(0.5, 1.0)
		var c = Color(silhouette.r * depth, silhouette.g * depth, silhouette.b * depth, 0.75)

		# Main building body
		draw_rect(Rect2(bx, -bh, bw, bh), c)

		# Rooftop antenna on tall buildings
		if bh > 200 and _rng.randf() > 0.4:
			var ant_x: float = bx + bw * 0.5
			draw_line(Vector2(ant_x, -bh), Vector2(ant_x, -bh - _rng.randf_range(15, 40)), Color(0.15, 0.15, 0.2, 0.6), 1.5)

		# Window grid (small dots)
		var cols: int = maxi(int(bw / 10.0), 2)
		var rows: int = maxi(int(bh / 12.0), 2)
		for wy in range(0, mini(rows, 8)):
			for wx in range(0, mini(cols, 5)):
				if _rng.randf() > 0.3:
					var win_x: float = bx + 4.0 + float(wx) * (bw - 8.0) / float(cols)
					var win_y: float = -bh + 8.0 + float(wy) * (bh - 16.0) / float(rows)
					var win_bright: float = _rng.randf_range(0.1, 0.4) * depth
					draw_rect(Rect2(win_x, win_y, 4, 4), Color(1.0, 0.9, 0.6, win_bright))

	# Holographic billboard effect
	for elem in _moving_elements:
		if elem["type"] == "holographic_billboard":
			var hx: float = elem["x"]
			var holo_phase: float = fmod(_time * 0.8, TAU)
			var holo_color := Color(
				0.3 + 0.3 * sin(holo_phase),
				0.2 + 0.3 * sin(holo_phase + TAU / 3.0),
				0.5 + 0.3 * sin(holo_phase + 2.0 * TAU / 3.0),
				0.12 + 0.04 * sin(_time * 3.0)
			)
			draw_rect(Rect2(hx - 25, -180, 50, 30), holo_color)
			# Scan line
			var scan_y: float = -180.0 + fmod(_time * 20.0, 30.0)
			draw_line(Vector2(hx - 25, scan_y), Vector2(hx + 25, scan_y), Color(1, 1, 1, 0.1), 1.0)

	# Flying vehicle lights
	for elem in _moving_elements:
		if elem["type"] == "flying_vehicles":
			for vi in elem["count"]:
				var vx: float = fmod(_time * (30.0 + float(vi) * 15.0) + float(vi) * _width * 0.25, _width + 200) - 100
				var vy: float = -200.0 - float(vi) * 40.0 + sin(_time * 0.5 + float(vi) * 2.0) * 10.0
				# Red/white running lights
				var v_color: Color = Color(1.0, 0.3, 0.2, 0.6) if vi % 2 == 0 else Color(1.0, 1.0, 1.0, 0.5)
				draw_circle(Vector2(vx, vy), 2.0, v_color)
				# Trail
				draw_line(Vector2(vx - 8, vy), Vector2(vx, vy), Color(v_color.r, v_color.g, v_color.b, 0.2), 1.0)


# ═══════════════════════════════════════════════════
# MARS — Rugged frontier outpost
# ═══════════════════════════════════════════════════

func _draw_mars() -> void:
	var base := Color(0.18, 0.06, 0.02)

	# Dust haze at ground level
	for i in 3:
		var hy: float = -float(i) * 12.0 - 3.0
		var dust_shift: float = sin(_time * 0.4 + float(i)) * 8.0
		draw_rect(Rect2(-50 + dust_shift, hy, _width + 100, 15.0), Color(0.5, 0.2, 0.08, 0.07 - float(i) * 0.015))

	# Low angular military buildings
	_rng.seed = hash("mars_buildings")
	for i in 22:
		var bx: float = _rng.randf_range(-20, _width + 20)
		var bw: float = _rng.randf_range(30, 80)
		var bh: float = _rng.randf_range(20, 85)
		var depth: float = _rng.randf_range(0.5, 1.0)
		var c = Color(base.r * depth, base.g * depth, base.b * depth, 0.7)

		# Angular roof (trapezoidal)
		var pts := PackedVector2Array([
			Vector2(bx, 0),
			Vector2(bx, -bh * 0.7),
			Vector2(bx + bw * 0.15, -bh),
			Vector2(bx + bw * 0.85, -bh),
			Vector2(bx + bw, -bh * 0.7),
			Vector2(bx + bw, 0),
		])
		draw_colored_polygon(pts, c)

		# Occasional slit windows
		if _rng.randf() > 0.5:
			var slit_x: float = bx + _rng.randf_range(5, bw - 8)
			draw_rect(Rect2(slit_x, -bh * 0.5, 3.0, 10.0), Color(0.8, 0.3, 0.1, 0.2 * depth))

	# Radar dishes
	_rng.seed = hash("mars_radar")
	for i in 4:
		var rx: float = _rng.randf_range(100, _width - 100)
		var ry: float = -_rng.randf_range(50, 90)
		# Pole
		draw_line(Vector2(rx, 0), Vector2(rx, ry), Color(0.15, 0.08, 0.03, 0.6), 2.0)
		# Dish (arc)
		draw_arc(Vector2(rx, ry), 12.0, PI * 0.8, PI * 1.2, 10, Color(0.2, 0.1, 0.05, 0.5), 2.5)

	# Radar sweep animation
	for elem in _moving_elements:
		if elem["type"] == "radar_sweep":
			var sweep_angle: float = fmod(_time * 1.5, TAU)
			var center = Vector2(elem["x"], elem["y"])
			var sweep_end = center + Vector2(cos(sweep_angle), sin(sweep_angle)) * 15.0
			draw_line(center, sweep_end, Color(0.2, 1.0, 0.2, 0.3), 1.5)

	# Dust devil
	for elem in _moving_elements:
		if elem["type"] == "dust_devil":
			var dx: float = elem["x"] + sin(_time * 0.3) * 50.0
			for di in 8:
				var dy: float = -float(di) * 8.0
				var swirl_r: float = 3.0 + float(di) * 1.5
				var swirl_x: float = dx + cos(_time * 3.0 + float(di) * 0.8) * swirl_r
				var dust_alpha: float = 0.12 - float(di) * 0.012
				draw_circle(Vector2(swirl_x, dy), 3.0, Color(0.6, 0.25, 0.1, dust_alpha))


# ═══════════════════════════════════════════════════
# JUPITER — Massive industrial dockyard (Ganymede)
# ═══════════════════════════════════════════════════

func _draw_jupiter() -> void:
	var steel := Color(0.1, 0.08, 0.15)
	var accent := Color(0.15, 0.1, 0.2)

	# Ice fog at base
	for elem in _moving_elements:
		if elem["type"] == "ice_fog":
			for fi in 6:
				var fog_x: float = fmod(_time * 8.0 + float(fi) * _width / 6.0, _width + 200) - 100
				var fog_y: float = elem["y"] + sin(_time * 0.7 + float(fi)) * 5.0
				draw_circle(Vector2(fog_x, fog_y), 35 + sin(_time * 0.4 + float(fi)) * 10.0, Color(0.5, 0.5, 0.7, 0.05))

	# Container stacks and fuel tanks
	_rng.seed = hash("jupiter_containers")
	for i in 12:
		var cx: float = _rng.randf_range(0, _width)
		var stack_count: int = _rng.randi_range(2, 5)
		var cw: float = _rng.randf_range(20, 40)
		var ch: float = _rng.randf_range(12, 20)
		for si in stack_count:
			var sy: float = -float(si) * ch
			var shade: float = _rng.randf_range(0.5, 1.0)
			draw_rect(Rect2(cx, sy - ch, cw, ch), Color(steel.r * shade, steel.g * shade, steel.b * shade, 0.6))

	# Fuel tank farms (cylinders = rounded rects)
	_rng.seed = hash("jupiter_tanks")
	for i in 6:
		var tx: float = _rng.randf_range(50, _width - 50)
		var tw: float = _rng.randf_range(30, 60)
		var th: float = _rng.randf_range(50, 120)
		var depth: float = _rng.randf_range(0.5, 1.0)
		draw_rect(Rect2(tx, -th, tw, th), Color(accent.r * depth, accent.g * depth, accent.b * depth, 0.65))
		# Rounded top
		draw_circle(Vector2(tx + tw * 0.5, -th), tw * 0.5, Color(accent.r * depth, accent.g * depth, accent.b * depth, 0.65))

	# Huge cranes
	_rng.seed = hash("jupiter_cranes")
	for i in 5:
		var crane_x: float = _rng.randf_range(80, _width - 80)
		var crane_h: float = _rng.randf_range(150, 280)
		var boom_len: float = _rng.randf_range(60, 120)
		var c = Color(0.12, 0.1, 0.18, 0.7)
		# Vertical mast
		draw_line(Vector2(crane_x, 0), Vector2(crane_x, -crane_h), c, 3.0)
		# Horizontal boom
		draw_line(Vector2(crane_x, -crane_h), Vector2(crane_x + boom_len, -crane_h + 20), c, 2.5)
		# Cable
		draw_line(Vector2(crane_x + boom_len, -crane_h + 20), Vector2(crane_x + boom_len, -crane_h + 80), Color(0.15, 0.12, 0.2, 0.4), 1.0)
		# Cross braces
		for bi in 4:
			var by: float = -float(bi + 1) * crane_h * 0.2
			draw_line(Vector2(crane_x - 6, by), Vector2(crane_x + 6, by - crane_h * 0.2), Color(0.1, 0.08, 0.15, 0.4), 1.0)

	# Cargo ship silhouettes in background
	_rng.seed = hash("jupiter_ships")
	for i in 3:
		var sx: float = _rng.randf_range(100, _width - 100)
		var sy: float = -_rng.randf_range(180, 250)
		var sw: float = _rng.randf_range(40, 80)
		var sh: float = sw * 0.3
		var ship_pts := PackedVector2Array([
			Vector2(sx, sy),
			Vector2(sx + sw * 0.2, sy - sh),
			Vector2(sx + sw * 0.8, sy - sh),
			Vector2(sx + sw, sy),
			Vector2(sx + sw * 0.9, sy + sh * 0.3),
			Vector2(sx + sw * 0.1, sy + sh * 0.3),
		])
		draw_colored_polygon(ship_pts, Color(0.08, 0.06, 0.12, 0.4))
		# Engine glow
		draw_circle(Vector2(sx + sw * 0.05, sy), 3.0, Color(0.3, 0.4, 1.0, 0.15))

	# Crane swing animation
	for elem in _moving_elements:
		if elem["type"] == "crane_swing":
			var swing_angle: float = sin(_time * 0.8) * 0.15
			var cable_top = Vector2(elem["x"], -200)
			var cable_bot = cable_top + Vector2(sin(swing_angle) * 40, 40)
			draw_line(cable_top, cable_bot, Color(0.2, 0.15, 0.25, 0.5), 1.5)
			draw_rect(Rect2(cable_bot.x - 8, cable_bot.y, 16, 10), Color(0.15, 0.12, 0.2, 0.5))


# ═══════════════════════════════════════════════════
# SATURN — Clean research campus (Titan)
# ═══════════════════════════════════════════════════

func _draw_saturn() -> void:
	var campus := Color(0.15, 0.13, 0.1)
	var accent_blue := Color(0.2, 0.35, 0.6, 0.3)

	# Soft blue accent glow at base
	draw_rect(Rect2(-50, -8, _width + 100, 12.0), Color(0.2, 0.3, 0.6, 0.04))

	# Elegant spires and orderly structures
	_rng.seed = hash("saturn_campus")
	var building_count: int = 20
	var spacing: float = _width / float(building_count + 1)
	for i in building_count:
		var bx: float = spacing * float(i + 1) + _rng.randf_range(-spacing * 0.2, spacing * 0.2)
		var bw: float = _rng.randf_range(18, 45)
		var bh: float = _rng.randf_range(60, 250)
		var depth: float = _rng.randf_range(0.5, 1.0)
		var c = Color(campus.r * depth, campus.g * depth, campus.b * depth, 0.7)

		# Symmetric building body
		draw_rect(Rect2(bx - bw * 0.5, -bh, bw, bh), c)

		# Spire top on some
		if _rng.randf() > 0.4:
			var spire_h: float = _rng.randf_range(20, 60)
			var pts := PackedVector2Array([
				Vector2(bx - bw * 0.2, -bh),
				Vector2(bx, -bh - spire_h),
				Vector2(bx + bw * 0.2, -bh),
			])
			draw_colored_polygon(pts, Color(c.r * 0.9, c.g * 0.9, c.b * 0.9, c.a))
			# Blue tip light
			draw_circle(Vector2(bx, -bh - spire_h), 2.0, accent_blue)

		# Glass dome on others
		if _rng.randf() > 0.6:
			draw_arc(Vector2(bx, -bh), bw * 0.4, PI, TAU, 12, Color(0.3, 0.4, 0.6, 0.15 * depth), 2.0)

	# Dish arrays
	_rng.seed = hash("saturn_dishes")
	for i in 6:
		var dx: float = _rng.randf_range(80, _width - 80)
		var dy: float = -_rng.randf_range(80, 180)
		# Support pole
		draw_line(Vector2(dx, 0), Vector2(dx, dy), Color(0.12, 0.1, 0.08, 0.5), 1.5)
		# Dish face
		draw_arc(Vector2(dx, dy), 15.0, PI * 0.65, PI * 1.35, 12, Color(0.2, 0.25, 0.35, 0.4), 2.0)
		# Feed horn
		draw_line(Vector2(dx, dy), Vector2(dx, dy - 10), Color(0.15, 0.15, 0.2, 0.3), 1.0)

	# Dish rotation animation
	for elem in _moving_elements:
		if elem["type"] == "dish_rotate":
			var rot_angle: float = sin(_time * 0.3) * 0.4
			var center = Vector2(elem["x"], elem["y"])
			draw_arc(center, 18.0, PI * 0.7 + rot_angle, PI * 1.3 + rot_angle, 12, Color(0.3, 0.5, 0.8, 0.35), 2.5)
			# Signal pulse
			var pulse_r: float = fmod(_time * 30.0, 60.0)
			if pulse_r < 40:
				draw_arc(center, pulse_r, PI * 0.85 + rot_angle, PI * 1.15 + rot_angle, 8, Color(0.3, 0.5, 0.8, 0.08 * (1.0 - pulse_r / 40.0)), 1.0)


# ═══════════════════════════════════════════════════
# URANUS — Chaotic scrapyard (Miranda)
# ═══════════════════════════════════════════════════

func _draw_uranus() -> void:
	var scrap := Color(0.08, 0.15, 0.18)

	# Cave ceiling overhead (dark mass at top)
	draw_rect(Rect2(-50, -400, _width + 100, 200), Color(0.03, 0.06, 0.08, 0.7))
	# Stalactite-like shapes from ceiling
	_rng.seed = hash("uranus_ceiling")
	for i in 15:
		var sx: float = _rng.randf_range(-30, _width + 30)
		var stl_h: float = _rng.randf_range(20, 80)
		var stl_w: float = _rng.randf_range(8, 25)
		var pts := PackedVector2Array([
			Vector2(sx - stl_w * 0.5, -200),
			Vector2(sx, -200 + stl_h),
			Vector2(sx + stl_w * 0.5, -200),
		])
		draw_colored_polygon(pts, Color(0.04, 0.08, 0.1, 0.6))

	# Jagged irregular scrapyard towers
	_rng.seed = hash("uranus_scrap")
	for i in 25:
		var bx: float = _rng.randf_range(-20, _width + 20)
		var bw: float = _rng.randf_range(15, 55)
		var bh: float = _rng.randf_range(25, 160)
		var depth: float = _rng.randf_range(0.4, 1.0)
		var c = Color(scrap.r * depth, scrap.g * depth, scrap.b * depth, 0.7)

		# Irregular shape — build left edge going up, then right edge going down
		var pts := PackedVector2Array()
		# Bottom-left
		pts.append(Vector2(bx, 0))
		# Left side going up (jitter inward)
		var left_steps: int = _rng.randi_range(1, 3)
		for si in left_steps:
			var t: float = float(si + 1) / float(left_steps + 1)
			var jx: float = bx + _rng.randf_range(0, bw * 0.2)
			var jy: float = -bh * t + _rng.randf_range(-8, 8)
			pts.append(Vector2(jx, jy))
		# Peak
		pts.append(Vector2(bx + bw * 0.5 + _rng.randf_range(-bw * 0.15, bw * 0.15), -bh))
		# Right side going down (jitter inward)
		var right_steps: int = _rng.randi_range(1, 3)
		for si in right_steps:
			var t: float = float(right_steps - si) / float(right_steps + 1)
			var jx: float = bx + bw + _rng.randf_range(-bw * 0.2, 0)
			var jy: float = -bh * t + _rng.randf_range(-8, 8)
			pts.append(Vector2(jx, jy))
		# Bottom-right
		pts.append(Vector2(bx + bw, 0))
		if pts.size() >= 3:
			draw_colored_polygon(pts, c)

		# Random lights on scrap
		if _rng.randf() > 0.6:
			var lx: float = bx + _rng.randf_range(0, bw)
			var ly: float = -_rng.randf_range(5, bh * 0.8)
			var light_color = Color(_rng.randf_range(0.2, 1.0), _rng.randf_range(0.2, 1.0), _rng.randf_range(0.2, 0.8), 0.3)
			draw_circle(Vector2(lx, ly), 2.0, light_color)

	# Sparking wires animation
	for elem in _moving_elements:
		if elem["type"] == "spark_shower":
			var spark_phase: float = fmod(_time * 2.0, 3.0)
			if spark_phase < 0.5:
				var sx: float = elem["x"]
				for si in 5:
					var spark_x: float = sx + _rng.randf_range(-15, 15)
					var spark_y: float = -80 + float(si) * 10.0 + sin(_time * 10.0 + float(si)) * 5.0
					draw_circle(Vector2(spark_x, spark_y), 1.5, Color(1.0, 0.8, 0.2, 0.6 - float(si) * 0.1))

	# Cave ceiling drips
	for elem in _moving_elements:
		if elem["type"] == "cave_drip":
			for di in elem["count"]:
				var drip_x: float = 200.0 + float(di) * _width * 0.25
				var drip_y: float = fmod(_time * 30.0 + float(di) * 40.0, 250.0) - 200.0
				if drip_y < 0:
					draw_circle(Vector2(drip_x, drip_y), 1.5, Color(0.3, 0.6, 0.7, 0.3 * (1.0 - (drip_y + 200.0) / 200.0)))


# ═══════════════════════════════════════════════════
# NEPTUNE — Crystalline ice city (Triton)
# ═══════════════════════════════════════════════════

func _draw_neptune() -> void:
	var ice := Color(0.06, 0.1, 0.22)
	var crystal := Color(0.2, 0.35, 0.6, 0.4)

	# Aurora reflections at top
	for elem in _moving_elements:
		if elem["type"] == "aurora_shift":
			for ai in 5:
				var ax: float = float(ai) * _width * 0.2 + sin(_time * 0.2 + float(ai)) * 50.0
				var ay: float = -280.0 - float(ai) * 20.0
				var aurora_hue: float = fmod(0.45 + _time * 0.02 + float(ai) * 0.08, 1.0)
				var aurora_c := Color.from_hsv(aurora_hue, 0.6, 0.8, 0.06)
				draw_rect(Rect2(ax - 60, ay, 120, 30), aurora_c)

	# Ice spires
	_rng.seed = hash("neptune_spires")
	for i in 20:
		var sx: float = _rng.randf_range(-20, _width + 20)
		var sw: float = _rng.randf_range(10, 35)
		var sh: float = _rng.randf_range(60, 280)
		var depth: float = _rng.randf_range(0.4, 1.0)
		var c = Color(ice.r * depth, ice.g * depth, ice.b * depth, 0.65)

		# Crystalline spire (triangle)
		var pts := PackedVector2Array([
			Vector2(sx - sw * 0.5, 0),
			Vector2(sx - sw * 0.15, -sh * 0.7),
			Vector2(sx, -sh),
			Vector2(sx + sw * 0.15, -sh * 0.7),
			Vector2(sx + sw * 0.5, 0),
		])
		draw_colored_polygon(pts, c)

		# Inner glow (translucent)
		var glow_pts := PackedVector2Array([
			Vector2(sx - sw * 0.2, -sh * 0.2),
			Vector2(sx, -sh * 0.85),
			Vector2(sx + sw * 0.2, -sh * 0.2),
		])
		if glow_pts.size() >= 3:
			draw_colored_polygon(glow_pts, Color(0.3, 0.5, 0.8, 0.06 * depth))

		# Facet reflections (bright lines on edges)
		draw_line(Vector2(sx - sw * 0.15, -sh * 0.7), Vector2(sx, -sh), Color(crystal.r, crystal.g, crystal.b, 0.15 * depth), 1.0)
		draw_line(Vector2(sx + sw * 0.15, -sh * 0.7), Vector2(sx, -sh), Color(crystal.r, crystal.g, crystal.b, 0.12 * depth), 1.0)

	# Frozen waterfalls (vertical streaks)
	_rng.seed = hash("neptune_falls")
	for i in 5:
		var fx: float = _rng.randf_range(100, _width - 100)
		var fh: float = _rng.randf_range(60, 150)
		var fy: float = -_rng.randf_range(80, 200)
		for streak in 3:
			var streak_x: float = fx + float(streak) * 4.0
			draw_line(Vector2(streak_x, fy), Vector2(streak_x + _rng.randf_range(-2, 2), fy + fh), Color(0.5, 0.6, 0.8, 0.12), 2.0)

	# Geyser burst animation
	for elem in _moving_elements:
		if elem["type"] == "geyser_burst":
			var burst_phase: float = fmod(_time * 0.5, 4.0)
			if burst_phase < 2.0:
				var burst_h: float = burst_phase * 40.0
				var gx: float = elem["x"]
				for gi in 4:
					var gy: float = -burst_h + float(gi) * 10.0
					var ga: float = 0.15 * (1.0 - burst_phase / 2.0)
					draw_circle(Vector2(gx + sin(_time * 3.0 + float(gi)) * 5.0, gy), 4.0 - float(gi) * 0.5, Color(0.5, 0.6, 0.9, ga))


# ═══════════════════════════════════════════════════
# PLUTO — Almost nothing. Vast darkness. The loneliest skyline.
# ═══════════════════════════════════════════════════

func _draw_pluto() -> void:
	# A few barely-visible structures in the void
	_rng.seed = hash("pluto_void")

	# Sparse, dim structures — only 5
	for i in 5:
		var bx: float = _rng.randf_range(_width * 0.2, _width * 0.8)
		var bw: float = _rng.randf_range(12, 30)
		var bh: float = _rng.randf_range(10, 35)
		var c = Color(0.06, 0.04, 0.1, 0.35)
		draw_rect(Rect2(bx, -bh, bw, bh), c)

	# A single dim communication tower
	var tower_x: float = _width * 0.5
	draw_line(Vector2(tower_x, 0), Vector2(tower_x, -50), Color(0.08, 0.06, 0.12, 0.4), 1.5)
	draw_line(Vector2(tower_x - 8, -30), Vector2(tower_x + 8, -30), Color(0.08, 0.06, 0.12, 0.3), 1.0)

	# Vast empty darkness — a very faint gradient to emphasize the void
	for i in 3:
		var vy: float = -100.0 - float(i) * 80.0
		draw_rect(Rect2(-50, vy, _width + 100, 80.0), Color(0.01, 0.005, 0.025, 0.02))

	# Void flicker — occasional subtle static-like shimmer suggesting EM interference
	for elem in _moving_elements:
		if elem["type"] == "void_flicker":
			# Very rare, brief flicker of a distant light
			var flicker_val: float = sin(_time * 0.7) * sin(_time * 3.1) * sin(_time * 7.3)
			if flicker_val > 0.8:
				var fx: float = _width * (0.3 + 0.4 * sin(_time * 0.13))
				var fy: float = -120.0 + 40.0 * sin(_time * 0.17)
				draw_circle(Vector2(fx, fy), 1.5, Color(0.4, 0.35, 0.5, 0.25))
