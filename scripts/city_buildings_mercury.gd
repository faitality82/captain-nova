class_name CityBuildingsMercury
extends RefCounted

# Mercury — "Helios Outpost"
# Scorched metals, solar reflectors, heat shimmers, exposed pipes.
# Colors: burnt orange (0.7, 0.45, 0.2), copper (0.72, 0.45, 0.2), dark steel.


# ── 1. HANGAR — Open-air landing pad with heat shields and solar reflectors ──

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	var half_w: float = w / 2.0

	# --- Platform base (thick slab) ---
	var platform_h: float = h * 0.12
	node.draw_rect(Rect2(-half_w, -platform_h, w, platform_h), Color(0.4, 0.32, 0.22))
	# Platform edge highlight
	node.draw_line(Vector2(-half_w, -platform_h), Vector2(half_w, -platform_h), Color(0.55, 0.4, 0.25), 2.0)
	# Platform underside shadow
	node.draw_rect(Rect2(-half_w + 4.0, -4.0, w - 8.0, 4.0), Color(0.25, 0.18, 0.1, 0.6))

	# --- Landing stripes on platform ---
	var stripe_color := Color(0.9, 0.7, 0.2, 0.5)
	for i in 8:
		var sx: float = -half_w + 20.0 + float(i) * (w - 40.0) / 7.0
		node.draw_rect(Rect2(sx - 2.0, -platform_h + 2.0, 4.0, platform_h - 4.0), stripe_color)

	# --- Chevron marks at center ---
	var chev_color := Color(0.9, 0.5, 0.1, 0.4)
	for i in 3:
		var cy: float = -platform_h * 0.5
		var cx: float = float(i - 1) * 20.0
		node.draw_line(Vector2(cx - 6.0, cy - 4.0), Vector2(cx, cy + 4.0), chev_color, 2.0)
		node.draw_line(Vector2(cx + 6.0, cy - 4.0), Vector2(cx, cy + 4.0), chev_color, 2.0)

	# --- Angled heat shield panels on sides ---
	var shield_color := Color(0.55, 0.35, 0.18, 0.85)
	var shield_h: float = h * 0.55
	# Left heat shield (triangle leaning outward)
	var left_shield := PackedVector2Array([
		Vector2(-half_w, -platform_h),
		Vector2(-half_w - 25.0, -platform_h - shield_h * 0.3),
		Vector2(-half_w, -platform_h - shield_h),
	])
	node.draw_colored_polygon(left_shield, shield_color)
	node.draw_polyline(left_shield, Color(0.7, 0.45, 0.2, 0.7), 2.0)
	# Right heat shield
	var right_shield := PackedVector2Array([
		Vector2(half_w, -platform_h),
		Vector2(half_w + 25.0, -platform_h - shield_h * 0.3),
		Vector2(half_w, -platform_h - shield_h),
	])
	node.draw_colored_polygon(right_shield, shield_color)
	node.draw_polyline(right_shield, Color(0.7, 0.45, 0.2, 0.7), 2.0)

	# Shield panel lines (rivets)
	for i in 5:
		var frac: float = float(i + 1) / 6.0
		var ly: float = -platform_h - shield_h * frac
		node.draw_line(Vector2(-half_w, ly), Vector2(-half_w - 25.0 * (1.0 - frac), ly), Color(0.4, 0.28, 0.15, 0.4), 1.0)
		node.draw_line(Vector2(half_w, ly), Vector2(half_w + 25.0 * (1.0 - frac), ly), Color(0.4, 0.28, 0.15, 0.4), 1.0)

	# --- Solar reflector dishes on poles ---
	for i in 3:
		var pole_x: float = -half_w * 0.6 + float(i) * half_w * 0.6
		var pole_top: float = -platform_h - h * 0.5 - float(i % 2) * 30.0
		# Pole
		node.draw_line(Vector2(pole_x, -platform_h), Vector2(pole_x, pole_top), Color(0.5, 0.4, 0.3), 3.0)
		# Rotating dish (ellipse via arc)
		var dish_angle: float = t * (1.2 + float(i) * 0.3)
		var dish_w: float = 18.0
		var dish_stretch: float = cos(dish_angle) * dish_w
		var dish_abs: float = dish_stretch
		if dish_abs < 0.0:
			dish_abs = -dish_abs
		if dish_abs < 3.0:
			dish_abs = 3.0
		# Draw dish as thick line representing the ellipse edge-on
		node.draw_line(
			Vector2(pole_x - dish_abs, pole_top - 3.0),
			Vector2(pole_x + dish_abs, pole_top - 3.0),
			Color(0.8, 0.75, 0.65), 3.0
		)
		# Dish rim highlight
		node.draw_line(
			Vector2(pole_x - dish_abs, pole_top - 5.0),
			Vector2(pole_x + dish_abs, pole_top - 5.0),
			Color(1.0, 0.9, 0.7, 0.4), 1.5
		)
		# Dish stem
		node.draw_line(Vector2(pole_x, pole_top), Vector2(pole_x, pole_top - 3.0), Color(0.5, 0.4, 0.3), 2.0)
		# Sun reflection glint
		var glint_alpha: float = 0.3 + 0.3 * sin(t * 3.0 + float(i) * 2.0)
		node.draw_circle(Vector2(pole_x, pole_top - 4.0), 4.0, Color(1.0, 0.95, 0.7, glint_alpha))

	# --- Heat shimmer above pad (wavy animated lines) ---
	var shimmer_color := Color(1.0, 0.7, 0.3, 0.08)
	for i in 6:
		var sy: float = -platform_h - 15.0 - float(i) * 12.0
		var wave_pts := PackedVector2Array()
		for j in 12:
			var fx: float = -half_w + 20.0 + float(j) * (w - 40.0) / 11.0
			var fy: float = sy + sin(t * 2.0 + float(j) * 0.8 + float(i) * 1.5) * 3.0
			wave_pts.append(Vector2(fx, fy))
		if wave_pts.size() >= 2:
			node.draw_polyline(wave_pts, shimmer_color, 1.5)

	# --- Landing lights along edges ---
	for i in 6:
		var lx: float = -half_w + 15.0 + float(i) * (w - 30.0) / 5.0
		var pulse_val: float = 0.3 + 0.4 * sin(t * 3.0 + float(i) * 1.0)
		node.draw_circle(Vector2(lx, -platform_h + 2.0), 3.0, Color(1.0, 0.8, 0.2, pulse_val))
		node.draw_circle(Vector2(lx, -platform_h + 2.0), 6.0, Color(1.0, 0.7, 0.1, pulse_val * 0.25))

	# --- Ship silhouette parked on pad ---
	var ship_color := Color(0.45, 0.4, 0.35, 0.7)
	var ship_body := PackedVector2Array([
		Vector2(-30.0, -platform_h),
		Vector2(-20.0, -platform_h - 18.0),
		Vector2(0.0, -platform_h - 28.0),
		Vector2(20.0, -platform_h - 18.0),
		Vector2(30.0, -platform_h),
	])
	node.draw_colored_polygon(ship_body, ship_color)
	# Cockpit window
	node.draw_circle(Vector2(0.0, -platform_h - 20.0), 4.0, Color(0.3, 0.7, 0.9, 0.5))
	# Engine glow
	var eng_alpha: float = 0.15 + 0.1 * sin(t * 1.5)
	node.draw_circle(Vector2(-18.0, -platform_h - 2.0), 5.0, Color(0.2, 0.6, 1.0, eng_alpha))
	node.draw_circle(Vector2(18.0, -platform_h - 2.0), 5.0, Color(0.2, 0.6, 1.0, eng_alpha))

	# --- Control tower on right side ---
	var tower_x: float = half_w - 30.0
	var tower_w: float = 24.0
	var tower_h: float = h * 0.35
	node.draw_rect(Rect2(tower_x, -platform_h - tower_h, tower_w, tower_h), Color(0.38, 0.3, 0.22))
	# Tower windows
	for i in 2:
		var wy: float = -platform_h - tower_h + 8.0 + float(i) * 18.0
		node.draw_rect(Rect2(tower_x + 4.0, wy, tower_w - 8.0, 8.0), Color(0.3, 0.7, 0.8, 0.4))
	# Antenna on tower
	node.draw_line(
		Vector2(tower_x + tower_w * 0.5, -platform_h - tower_h),
		Vector2(tower_x + tower_w * 0.5, -platform_h - tower_h - 25.0),
		Color(0.6, 0.5, 0.4), 2.0
	)
	# Antenna blink
	var blink_val: float = 0.2 + 0.8 * sin(t * 4.0)
	if blink_val < 0.0:
		blink_val = 0.0
	node.draw_circle(Vector2(tower_x + tower_w * 0.5, -platform_h - tower_h - 25.0), 2.5, Color(1.0, 0.3, 0.1, blink_val))

	# --- Ground glow ---
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_circle(Vector2(0.0, -3.0), 10.0, Color(1.0, 0.5, 0.1, glow_pulse))


# ── 2. MARKET — Solar bazaar with retractable shade sails ────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	var half_w: float = w / 2.0

	# --- Ground / floor area ---
	node.draw_rect(Rect2(-half_w, -6.0, w, 6.0), Color(0.35, 0.27, 0.18))
	# Ground texture lines
	for i in 10:
		var gx: float = -half_w + float(i) * w / 9.0
		node.draw_line(Vector2(gx, 0.0), Vector2(gx, -6.0), Color(0.3, 0.22, 0.14, 0.3), 1.0)

	# --- Market stalls (4 stalls) ---
	var stall_count: int = 4
	var stall_w: float = w * 0.2
	var stall_gap: float = (w - float(stall_count) * stall_w) / float(stall_count + 1)
	var stall_colors: Array = [
		Color(0.4, 0.3, 0.2),
		Color(0.35, 0.28, 0.18),
		Color(0.42, 0.32, 0.2),
		Color(0.38, 0.26, 0.17),
	]

	for i in stall_count:
		var sx: float = -half_w + stall_gap + float(i) * (stall_w + stall_gap)
		var stall_h: float = h * 0.22
		var sy: float = -stall_h - 6.0

		# Stall body (counter/table)
		node.draw_rect(Rect2(sx, sy, stall_w, stall_h), stall_colors[i])
		node.draw_rect(Rect2(sx, sy, stall_w, stall_h), Color(0.55, 0.4, 0.25, 0.5), false, 1.5)

		# Counter top highlight
		node.draw_line(Vector2(sx, sy), Vector2(sx + stall_w, sy), Color(0.6, 0.45, 0.3, 0.6), 2.0)

		# Display goods (tiny colored rectangles)
		var goods_colors: Array = [
			Color(0.8, 0.3, 0.1, 0.7),
			Color(0.2, 0.6, 0.8, 0.7),
			Color(0.7, 0.7, 0.2, 0.7),
			Color(0.5, 0.2, 0.7, 0.7),
			Color(0.3, 0.7, 0.3, 0.7),
		]
		for g in 5:
			var gx: float = sx + 3.0 + float(g) * (stall_w - 10.0) / 4.0
			var gy: float = sy + 4.0
			node.draw_rect(Rect2(gx, gy, 5.0, 6.0), goods_colors[g])

		# Price board on 2nd stall
		if i == 1:
			node.draw_rect(Rect2(sx + 2.0, sy - 18.0, stall_w - 4.0, 16.0), Color(0.25, 0.2, 0.12))
			node.draw_rect(Rect2(sx + 2.0, sy - 18.0, stall_w - 4.0, 16.0), Color(0.5, 0.4, 0.25, 0.6), false, 1.0)
			for ln in 4:
				var ly: float = sy - 15.0 + float(ln) * 4.0
				node.draw_line(
					Vector2(sx + 5.0, ly),
					Vector2(sx + stall_w - 7.0, ly),
					Color(0.7, 0.6, 0.3, 0.5), 1.0
				)

	# --- Shade sail poles ---
	var pole_positions: Array = []
	for i in 5:
		var px: float = -half_w + 15.0 + float(i) * (w - 30.0) / 4.0
		var pole_h: float = h * 0.7 + float(i % 2) * h * 0.15
		pole_positions.append(Vector2(px, -pole_h - 6.0))
		# Draw pole
		node.draw_line(Vector2(px, -6.0), Vector2(px, -pole_h - 6.0), Color(0.5, 0.38, 0.25), 3.0)
		# Pole cap
		node.draw_circle(Vector2(px, -pole_h - 6.0), 3.0, Color(0.6, 0.45, 0.3))

	# --- Triangular shade sails between poles ---
	var sail_colors: Array = [
		Color(0.72, 0.45, 0.2, 0.55),
		Color(0.6, 0.38, 0.18, 0.5),
		Color(0.75, 0.55, 0.25, 0.5),
		Color(0.65, 0.4, 0.15, 0.55),
	]
	for i in 4:
		var p1: Vector2 = pole_positions[i]
		var p2: Vector2 = pole_positions[i + 1]
		var mid_x: float = (p1.x + p2.x) / 2.0
		var sag: float = 12.0 + sin(t * 0.8 + float(i)) * 3.0
		var mid_y: float = minf(p1.y, p2.y) + sag
		var sail := PackedVector2Array([p1, Vector2(mid_x, mid_y), p2])
		node.draw_colored_polygon(sail, sail_colors[i])
		node.draw_polyline(PackedVector2Array([p1, Vector2(mid_x, mid_y), p2]), Color(0.5, 0.35, 0.2, 0.6), 1.5)

	# --- Hanging lanterns between poles ---
	for i in 4:
		var p1: Vector2 = pole_positions[i]
		var p2: Vector2 = pole_positions[i + 1]
		for j in 3:
			var frac: float = float(j + 1) / 4.0
			var lx: float = p1.x + (p2.x - p1.x) * frac
			var ly: float = p1.y + (p2.y - p1.y) * frac + 15.0
			# Lantern string
			node.draw_line(Vector2(lx, ly - 8.0), Vector2(lx, ly), Color(0.4, 0.3, 0.2, 0.4), 1.0)
			# Lantern glow
			var lantern_pulse: float = 0.4 + 0.3 * sin(t * 2.5 + float(i) * 1.5 + float(j) * 2.0)
			node.draw_circle(Vector2(lx, ly), 4.0, Color(1.0, 0.7, 0.2, lantern_pulse))
			node.draw_circle(Vector2(lx, ly), 8.0, Color(1.0, 0.6, 0.15, lantern_pulse * 0.2))

	# --- Heat shimmer between stalls ---
	var shimmer_col := Color(1.0, 0.7, 0.3, 0.06)
	for i in 4:
		var sy: float = -20.0 - float(i) * 8.0
		var wave_pts := PackedVector2Array()
		for j in 10:
			var fx: float = -half_w + 15.0 + float(j) * (w - 30.0) / 9.0
			var fy: float = sy + sin(t * 1.8 + float(j) * 0.9 + float(i) * 1.2) * 2.5
			wave_pts.append(Vector2(fx, fy))
		if wave_pts.size() >= 2:
			node.draw_polyline(wave_pts, shimmer_col, 1.0)

	# --- Crate stacks near edges ---
	var crate_color := Color(0.45, 0.35, 0.22)
	var crate_outline := Color(0.55, 0.42, 0.28, 0.6)
	# Left crates
	node.draw_rect(Rect2(-half_w + 5.0, -20.0, 14.0, 14.0), crate_color)
	node.draw_rect(Rect2(-half_w + 5.0, -20.0, 14.0, 14.0), crate_outline, false, 1.0)
	node.draw_rect(Rect2(-half_w + 8.0, -32.0, 10.0, 12.0), Color(0.42, 0.32, 0.2))
	node.draw_rect(Rect2(-half_w + 8.0, -32.0, 10.0, 12.0), crate_outline, false, 1.0)
	# Right crates
	node.draw_rect(Rect2(half_w - 22.0, -18.0, 16.0, 12.0), crate_color)
	node.draw_rect(Rect2(half_w - 22.0, -18.0, 16.0, 12.0), crate_outline, false, 1.0)
	node.draw_rect(Rect2(half_w - 18.0, -30.0, 12.0, 12.0), Color(0.42, 0.32, 0.2))
	node.draw_rect(Rect2(half_w - 18.0, -30.0, 12.0, 12.0), crate_outline, false, 1.0)
	node.draw_rect(Rect2(half_w - 15.0, -40.0, 9.0, 10.0), Color(0.4, 0.3, 0.18))
	node.draw_rect(Rect2(half_w - 15.0, -40.0, 9.0, 10.0), crate_outline, false, 1.0)

	# --- Ground entrance glow ---
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_circle(Vector2(0.0, -3.0), 10.0, Color(1.0, 0.5, 0.1, glow_pulse))


# ── 3. BAR — Rooftop cantina with parasols ──────────────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	var half_w: float = w / 2.0
	var story_h: float = h * 0.45

	# --- Ground floor (two-story base) ---
	node.draw_rect(Rect2(-half_w, -h, w, h), Color(0.38, 0.28, 0.18))

	# Floor divider line (between stories)
	node.draw_line(
		Vector2(-half_w, -story_h),
		Vector2(half_w, -story_h),
		Color(0.5, 0.38, 0.25, 0.7), 2.0
	)

	# Wall texture — horizontal mortar lines
	for i in range(0, int(h), 12):
		var ly: float = -h + float(i)
		node.draw_line(Vector2(-half_w, ly), Vector2(half_w, ly), Color(0.45, 0.33, 0.2, 0.2), 1.0)
	# Vertical brick accents
	for i in range(0, int(h), 12):
		var ly: float = -h + float(i)
		var brick_shift: float = 0.0
		@warning_ignore("integer_division")
		if (i / 12) % 2 == 1:
			brick_shift = 15.0
		for j in range(0, int(w), 30):
			var bx: float = -half_w + float(j) + brick_shift
			if bx < half_w:
				node.draw_line(Vector2(bx, ly), Vector2(bx, ly + 12.0), Color(0.45, 0.33, 0.2, 0.15), 1.0)

	# --- Ground floor windows (warm glow) ---
	for i in 3:
		var wx: float = -half_w + 20.0 + float(i) * (w - 40.0) / 2.0
		var wy: float = -story_h + 12.0
		node.draw_rect(Rect2(wx - 10.0, wy, 20.0, story_h - 24.0), Color(0.2, 0.15, 0.1))
		var win_glow: float = 0.3 + 0.15 * sin(t * 1.5 + float(i) * 1.2)
		node.draw_rect(Rect2(wx - 8.0, wy + 2.0, 16.0, story_h - 28.0), Color(1.0, 0.6, 0.2, win_glow))

	# --- Entrance at ground level with awning ---
	var door_w: float = 28.0
	var door_h: float = story_h * 0.7
	node.draw_rect(Rect2(-door_w / 2.0, -door_h, door_w, door_h), Color(0.3, 0.22, 0.14))
	# Awning triangle
	var awning := PackedVector2Array([
		Vector2(-door_w * 0.8, -door_h),
		Vector2(0.0, -door_h - 15.0),
		Vector2(door_w * 0.8, -door_h),
	])
	node.draw_colored_polygon(awning, Color(0.65, 0.4, 0.18, 0.8))
	node.draw_polyline(PackedVector2Array([
		Vector2(-door_w * 0.8, -door_h),
		Vector2(0.0, -door_h - 15.0),
		Vector2(door_w * 0.8, -door_h),
	]), Color(0.5, 0.35, 0.2, 0.6), 1.5)
	# Door handle
	node.draw_circle(Vector2(door_w / 2.0 - 5.0, -door_h * 0.5), 2.0, Color(0.7, 0.55, 0.3))

	# --- Stairs on left side going up ---
	var stair_count: int = 8
	var stair_w: float = 18.0
	var stair_total_h: float = h - story_h
	for i in stair_count:
		var frac: float = float(i) / float(stair_count)
		var sx: float = -half_w - stair_w + 2.0
		var sy: float = -story_h - frac * stair_total_h
		var step_h: float = stair_total_h / float(stair_count)
		node.draw_rect(Rect2(sx, sy, stair_w, step_h), Color(0.42, 0.32, 0.2))
		node.draw_line(Vector2(sx, sy), Vector2(sx + stair_w, sy), Color(0.55, 0.4, 0.25, 0.5), 1.0)
	# Stair railing
	node.draw_line(
		Vector2(-half_w - stair_w + 2.0, -story_h),
		Vector2(-half_w - stair_w + 2.0, -h),
		Color(0.5, 0.38, 0.25), 2.0
	)

	# --- Rooftop terrace railing ---
	var rail_y: float = -h
	# Horizontal top rail
	node.draw_line(Vector2(-half_w, rail_y), Vector2(half_w, rail_y), Color(0.55, 0.42, 0.28), 2.5)
	# Horizontal bottom rail
	node.draw_line(Vector2(-half_w, rail_y + 10.0), Vector2(half_w, rail_y + 10.0), Color(0.5, 0.38, 0.25), 1.5)
	# Vertical rail bars
	for i in range(0, int(w), 15):
		var rx: float = -half_w + float(i)
		node.draw_line(Vector2(rx, rail_y), Vector2(rx, rail_y + 10.0), Color(0.5, 0.38, 0.25, 0.6), 1.5)

	# --- Upper level windows (warm glow) ---
	for i in 4:
		var wx: float = -half_w + 15.0 + float(i) * (w - 30.0) / 3.0
		var wy: float = -h + 15.0
		node.draw_rect(Rect2(wx - 8.0, wy, 16.0, 18.0), Color(0.2, 0.15, 0.1))
		var win_glow: float = 0.35 + 0.2 * sin(t * 1.8 + float(i) * 0.9)
		node.draw_rect(Rect2(wx - 6.0, wy + 2.0, 12.0, 14.0), Color(1.0, 0.65, 0.2, win_glow))

	# --- Parasols on rooftop ---
	var parasol_data: Array = [
		[(-half_w * 0.5), -h - 35.0, 22.0, Color(0.75, 0.45, 0.15, 0.75)],
		[0.0, -h - 45.0, 26.0, Color(0.65, 0.35, 0.12, 0.7)],
		[(half_w * 0.45), -h - 30.0, 20.0, Color(0.7, 0.5, 0.2, 0.75)],
	]
	for p_idx in parasol_data.size():
		var pd: Array = parasol_data[p_idx]
		var px: float = pd[0]
		var py: float = pd[1]
		var pr: float = pd[2]
		var pc: Color = pd[3]
		# Pole
		node.draw_line(Vector2(px, -h), Vector2(px, py), Color(0.5, 0.38, 0.25), 2.5)
		# Parasol canopy (wide triangle)
		var canopy := PackedVector2Array([
			Vector2(px - pr, py + 4.0),
			Vector2(px, py - 6.0),
			Vector2(px + pr, py + 4.0),
		])
		node.draw_colored_polygon(canopy, pc)
		node.draw_polyline(PackedVector2Array([
			Vector2(px - pr, py + 4.0),
			Vector2(px, py - 6.0),
			Vector2(px + pr, py + 4.0),
		]), Color(0.5, 0.35, 0.2, 0.5), 1.5)
		# Rib lines
		for r_idx in 3:
			var frac: float = float(r_idx) / 3.0 - 0.5
			node.draw_line(
				Vector2(px, py - 6.0),
				Vector2(px + pr * frac * 2.0, py + 4.0),
				Color(0.5, 0.35, 0.2, 0.3), 1.0
			)

	# --- String lights connecting parasols ---
	for i in 2:
		var pd1: Array = parasol_data[i]
		var pd2: Array = parasol_data[i + 1]
		var x1: float = pd1[0]
		var y1: float = pd1[1]
		var x2: float = pd2[0]
		var y2: float = pd2[1]
		# Draw string with light dots
		for j in 6:
			var frac: float = float(j + 1) / 7.0
			var lx: float = x1 + (x2 - x1) * frac
			var sag: float = sin(frac * PI) * 8.0
			var ly: float = y1 + (y2 - y1) * frac + sag
			var twinkle: float = 0.3 + 0.5 * sin(t * 4.0 + float(j) * 1.7 + float(i) * 2.5)
			node.draw_circle(Vector2(lx, ly), 2.0, Color(1.0, 0.85, 0.4, twinkle))
		# String line
		var string_pts := PackedVector2Array()
		for j in 10:
			var frac: float = float(j) / 9.0
			var lx: float = x1 + (x2 - x1) * frac
			var sag: float = sin(frac * PI) * 8.0
			var ly: float = y1 + (y2 - y1) * frac + sag
			string_pts.append(Vector2(lx, ly))
		if string_pts.size() >= 2:
			node.draw_polyline(string_pts, Color(0.5, 0.4, 0.3, 0.3), 1.0)

	# --- Bar counter on roof ---
	var bar_x: float = half_w * 0.1
	var bar_w: float = half_w * 0.7
	var bar_y: float = -h + 12.0
	node.draw_rect(Rect2(bar_x, bar_y, bar_w, 10.0), Color(0.45, 0.3, 0.18))
	node.draw_line(Vector2(bar_x, bar_y), Vector2(bar_x + bar_w, bar_y), Color(0.55, 0.4, 0.25), 2.0)
	# Bottles behind bar
	for i in 5:
		var bx: float = bar_x + 6.0 + float(i) * (bar_w - 12.0) / 4.0
		var bottle_h: float = 10.0 + float(i % 3) * 3.0
		node.draw_rect(Rect2(bx - 2.0, bar_y - bottle_h, 4.0, bottle_h), Color(0.5, 0.35 + float(i) * 0.04, 0.2, 0.6))
		# Bottle cap
		node.draw_rect(Rect2(bx - 1.0, bar_y - bottle_h - 2.0, 2.0, 2.0), Color(0.6, 0.5, 0.35, 0.5))

	# --- Entrance glow ---
	var glow_pulse: float = 0.35 + 0.25 * sin(t * 2.0)
	node.draw_circle(Vector2(0.0, -3.0), 10.0, Color(1.0, 0.5, 0.1, glow_pulse))


# ── 4. GARAGE — Open workshop under solar-powered canopy ─────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	var half_w: float = w / 2.0

	# --- Work pit below ground level ---
	var pit_w: float = w * 0.4
	var pit_depth: float = 20.0
	node.draw_rect(Rect2(-pit_w / 2.0, 0.0, pit_w, pit_depth), Color(0.15, 0.1, 0.07))
	# Pit edges
	node.draw_line(Vector2(-pit_w / 2.0, 0.0), Vector2(-pit_w / 2.0, pit_depth), Color(0.35, 0.25, 0.18), 2.0)
	node.draw_line(Vector2(pit_w / 2.0, 0.0), Vector2(pit_w / 2.0, pit_depth), Color(0.35, 0.25, 0.18), 2.0)
	# Pit ladder
	node.draw_line(Vector2(-pit_w / 2.0 + 4.0, 0.0), Vector2(-pit_w / 2.0 + 4.0, pit_depth - 2.0), Color(0.5, 0.4, 0.3, 0.5), 1.5)
	node.draw_line(Vector2(-pit_w / 2.0 + 10.0, 0.0), Vector2(-pit_w / 2.0 + 10.0, pit_depth - 2.0), Color(0.5, 0.4, 0.3, 0.5), 1.5)
	for i in 4:
		var ry: float = 3.0 + float(i) * 4.0
		node.draw_line(
			Vector2(-pit_w / 2.0 + 4.0, ry),
			Vector2(-pit_w / 2.0 + 10.0, ry),
			Color(0.5, 0.4, 0.3, 0.5), 1.5
		)

	# --- Ground surface ---
	node.draw_rect(Rect2(-half_w, -4.0, w, 4.0), Color(0.35, 0.27, 0.18))

	# --- 4 support poles ---
	var pole_inset: float = 25.0
	var canopy_h: float = h * 0.8
	# Draw poles
	node.draw_line(Vector2(-half_w + pole_inset, 0.0), Vector2(-half_w + pole_inset, -canopy_h), Color(0.5, 0.4, 0.3), 4.0)
	node.draw_line(Vector2(half_w - pole_inset, 0.0), Vector2(half_w - pole_inset, -canopy_h), Color(0.5, 0.4, 0.3), 4.0)
	# Middle poles
	node.draw_line(Vector2(-half_w + pole_inset + 30.0, 0.0), Vector2(-half_w + pole_inset + 30.0, -canopy_h), Color(0.45, 0.35, 0.25), 3.0)
	node.draw_line(Vector2(half_w - pole_inset - 30.0, 0.0), Vector2(half_w - pole_inset - 30.0, -canopy_h), Color(0.45, 0.35, 0.25), 3.0)

	# --- Angled canopy roof ---
	var roof_left_y: float = -canopy_h
	var roof_right_y: float = -canopy_h + 15.0
	var canopy_poly := PackedVector2Array([
		Vector2(-half_w + pole_inset - 10.0, roof_left_y - 8.0),
		Vector2(half_w - pole_inset + 10.0, roof_right_y - 8.0),
		Vector2(half_w - pole_inset + 10.0, roof_right_y),
		Vector2(-half_w + pole_inset - 10.0, roof_left_y),
	])
	node.draw_colored_polygon(canopy_poly, Color(0.4, 0.32, 0.22))

	# --- Solar panels on canopy (grid) ---
	var panel_color := Color(0.2, 0.3, 0.5, 0.7)
	var panel_highlight := Color(0.3, 0.5, 0.7, 0.4)
	var panel_rows: int = 2
	var panel_cols: int = 6
	var panel_area_w: float = w - 2.0 * pole_inset
	var panel_w: float = panel_area_w / float(panel_cols) - 4.0
	var panel_h_size: float = 6.0
	for row in panel_rows:
		for col in panel_cols:
			var px: float = -half_w + pole_inset + 2.0 + float(col) * (panel_w + 4.0)
			var slope_frac: float = (px + half_w - pole_inset) / panel_area_w
			var py: float = roof_left_y + (roof_right_y - roof_left_y) * slope_frac - 6.0 - float(row) * (panel_h_size + 2.0)
			node.draw_rect(Rect2(px, py, panel_w, panel_h_size), panel_color)
			node.draw_rect(Rect2(px, py, panel_w, panel_h_size), panel_highlight, false, 1.0)
			# Cell divider
			node.draw_line(
				Vector2(px + panel_w * 0.5, py),
				Vector2(px + panel_w * 0.5, py + panel_h_size),
				Color(0.15, 0.25, 0.4, 0.5), 1.0
			)

	# --- Power cables from solar panels (curved lines) ---
	for side_val in [0, 1]:
		var cable_x: float = -half_w + pole_inset + 5.0 + float(side_val) * (panel_area_w - 10.0)
		var cable_pts := PackedVector2Array()
		for j in 8:
			var frac: float = float(j) / 7.0
			var cx: float = cable_x + sin(frac * PI) * 8.0
			var cy: float = roof_left_y + frac * canopy_h
			cable_pts.append(Vector2(cx, cy))
		if cable_pts.size() >= 2:
			node.draw_polyline(cable_pts, Color(0.3, 0.3, 0.3, 0.5), 2.0)
		# Cable glow
		var cable_glow: float = 0.2 + 0.15 * sin(t * 2.0 + float(side_val) * PI)
		node.draw_circle(Vector2(cable_x, roof_left_y + canopy_h * 0.5), 3.0, Color(0.2, 0.6, 1.0, cable_glow))

	# --- Back wall (tool rack) ---
	var wall_x: float = -half_w + pole_inset + 2.0
	var wall_w: float = 40.0
	var wall_h: float = canopy_h * 0.6
	node.draw_rect(Rect2(wall_x, -wall_h, wall_w, wall_h), Color(0.32, 0.25, 0.17))
	node.draw_rect(Rect2(wall_x, -wall_h, wall_w, wall_h), Color(0.45, 0.35, 0.22, 0.5), false, 1.5)

	# Tools on wall
	# Wrench
	var tool_y: float = -wall_h + 12.0
	node.draw_line(Vector2(wall_x + 8.0, tool_y), Vector2(wall_x + 8.0, tool_y + 20.0), Color(0.55, 0.45, 0.35), 2.0)
	node.draw_arc(Vector2(wall_x + 8.0, tool_y), 4.0, -PI * 0.8, PI * 0.8, 8, Color(0.55, 0.45, 0.35), 2.0)
	# Hammer
	node.draw_line(Vector2(wall_x + 20.0, tool_y + 2.0), Vector2(wall_x + 20.0, tool_y + 22.0), Color(0.5, 0.4, 0.3), 2.0)
	node.draw_rect(Rect2(wall_x + 16.0, tool_y, 8.0, 6.0), Color(0.5, 0.4, 0.3))
	# Pliers
	node.draw_line(Vector2(wall_x + 32.0, tool_y), Vector2(wall_x + 30.0, tool_y + 12.0), Color(0.55, 0.45, 0.35), 2.0)
	node.draw_line(Vector2(wall_x + 32.0, tool_y), Vector2(wall_x + 34.0, tool_y + 12.0), Color(0.55, 0.45, 0.35), 2.0)
	# Tool pegs
	for i in 3:
		var peg_x: float = wall_x + 8.0 + float(i) * 12.0
		node.draw_circle(Vector2(peg_x, tool_y - 3.0), 2.0, Color(0.6, 0.5, 0.35, 0.5))

	# --- Vehicle lift with ship shape ---
	var lift_x: float = half_w * 0.15
	var lift_w: float = w * 0.35
	var lift_y: float = -canopy_h * 0.35
	# Lift platform
	node.draw_rect(Rect2(lift_x, lift_y, lift_w, 4.0), Color(0.5, 0.4, 0.3))
	# Lift hydraulics
	node.draw_line(Vector2(lift_x + 10.0, lift_y + 4.0), Vector2(lift_x + 10.0, 0.0), Color(0.45, 0.38, 0.28), 3.0)
	node.draw_line(Vector2(lift_x + lift_w - 10.0, lift_y + 4.0), Vector2(lift_x + lift_w - 10.0, 0.0), Color(0.45, 0.38, 0.28), 3.0)
	# Ship on lift
	var ship_poly := PackedVector2Array([
		Vector2(lift_x + 8.0, lift_y),
		Vector2(lift_x + lift_w * 0.3, lift_y - 16.0),
		Vector2(lift_x + lift_w * 0.5, lift_y - 22.0),
		Vector2(lift_x + lift_w * 0.7, lift_y - 16.0),
		Vector2(lift_x + lift_w - 8.0, lift_y),
	])
	node.draw_colored_polygon(ship_poly, Color(0.4, 0.35, 0.3, 0.65))
	node.draw_polyline(ship_poly, Color(0.5, 0.42, 0.32, 0.5), 1.5)

	# --- Welding sparks (animated bright dots) ---
	for i in 8:
		var spark_x: float = lift_x + 15.0 + fmod(float(i) * 17.3, lift_w - 30.0)
		var spark_y: float = lift_y - 5.0 - fmod(float(i) * 11.7, 15.0)
		var spark_life: float = sin(t * 10.0 + float(i) * 3.7)
		if spark_life > 0.5:
			var spark_alpha: float = (spark_life - 0.5) * 2.0
			node.draw_circle(Vector2(spark_x, spark_y), 1.5, Color(1.0, 0.95, 0.5, spark_alpha))
			# Spark trail
			var trail_dx: float = sin(float(i) * 2.3) * 4.0
			var trail_dy: float = cos(float(i) * 1.7) * 4.0
			node.draw_line(
				Vector2(spark_x, spark_y),
				Vector2(spark_x + trail_dx, spark_y + trail_dy),
				Color(1.0, 0.8, 0.3, spark_alpha * 0.5), 1.0
			)

	# --- Oil stains on ground ---
	for i in 4:
		var ox: float = -half_w + 40.0 + float(i) * 50.0
		node.draw_circle(Vector2(ox, -2.0), 6.0 + float(i % 2) * 3.0, Color(0.2, 0.18, 0.12, 0.3))

	# --- Entrance glow ---
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_circle(Vector2(0.0, -3.0), 10.0, Color(1.0, 0.5, 0.1, glow_pulse))


# ── 5. UNIQUE — Solar Observatory tower with rotating dish ───────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	var half_w: float = w / 2.0

	# --- Equipment boxes at base ---
	var box_colors: Array = [
		Color(0.38, 0.3, 0.2),
		Color(0.35, 0.28, 0.18),
		Color(0.4, 0.32, 0.22),
	]
	# Left cluster
	node.draw_rect(Rect2(-half_w + 5.0, -18.0, 20.0, 18.0), box_colors[0])
	node.draw_rect(Rect2(-half_w + 5.0, -18.0, 20.0, 18.0), Color(0.5, 0.4, 0.28, 0.5), false, 1.0)
	node.draw_rect(Rect2(-half_w + 10.0, -32.0, 14.0, 14.0), box_colors[1])
	node.draw_rect(Rect2(-half_w + 10.0, -32.0, 14.0, 14.0), Color(0.5, 0.4, 0.28, 0.5), false, 1.0)
	# Right cluster
	node.draw_rect(Rect2(half_w - 30.0, -22.0, 24.0, 22.0), box_colors[2])
	node.draw_rect(Rect2(half_w - 30.0, -22.0, 24.0, 22.0), Color(0.5, 0.4, 0.28, 0.5), false, 1.0)
	node.draw_rect(Rect2(half_w - 24.0, -38.0, 16.0, 16.0), box_colors[0])
	node.draw_rect(Rect2(half_w - 24.0, -38.0, 16.0, 16.0), Color(0.5, 0.4, 0.28, 0.5), false, 1.0)
	# Warning stripes on boxes
	for i in 3:
		var stripe_x: float = -half_w + 7.0 + float(i) * 6.0
		node.draw_line(
			Vector2(stripe_x, -16.0),
			Vector2(stripe_x, -2.0),
			Color(0.8, 0.6, 0.1, 0.3), 1.0
		)

	# --- Heat ripple effect around base ---
	var ripple_col := Color(1.0, 0.65, 0.3, 0.06)
	for i in 5:
		var ry: float = -8.0 - float(i) * 6.0
		var rw: float = half_w * 0.8 - float(i) * 8.0
		var wave_pts := PackedVector2Array()
		for j in 10:
			var fx: float = -rw + float(j) * rw * 2.0 / 9.0
			var fy: float = ry + sin(t * 1.5 + float(j) * 0.7 + float(i) * 1.3) * 2.0
			wave_pts.append(Vector2(fx, fy))
		if wave_pts.size() >= 2:
			node.draw_polyline(wave_pts, ripple_col, 1.0)

	# --- Tower body (slightly tapered) ---
	var tower_base_w: float = w * 0.3
	var tower_top_w: float = w * 0.22
	var tower_h: float = h * 0.72
	var tower_bottom: float = -10.0
	var tower_top: float = tower_bottom - tower_h

	var tower_poly := PackedVector2Array([
		Vector2(-tower_base_w / 2.0, tower_bottom),
		Vector2(-tower_top_w / 2.0, tower_top),
		Vector2(tower_top_w / 2.0, tower_top),
		Vector2(tower_base_w / 2.0, tower_bottom),
	])
	node.draw_colored_polygon(tower_poly, Color(0.4, 0.3, 0.2))

	# Tower outline
	node.draw_polyline(PackedVector2Array([
		Vector2(-tower_base_w / 2.0, tower_bottom),
		Vector2(-tower_top_w / 2.0, tower_top),
		Vector2(tower_top_w / 2.0, tower_top),
		Vector2(tower_base_w / 2.0, tower_bottom),
		Vector2(-tower_base_w / 2.0, tower_bottom),
	]), Color(0.55, 0.4, 0.25, 0.6), 2.0)

	# Horizontal stone/metal texture lines on tower
	for i in range(0, int(tower_h), 10):
		var frac: float = float(i) / tower_h
		var line_y: float = tower_bottom - float(i)
		var line_half_w: float = tower_base_w / 2.0 - (tower_base_w - tower_top_w) / 2.0 * frac
		node.draw_line(
			Vector2(-line_half_w, line_y),
			Vector2(line_half_w, line_y),
			Color(0.5, 0.38, 0.25, 0.2), 1.0
		)

	# --- Window slits along tower ---
	for i in 6:
		var frac: float = float(i + 1) / 7.0
		var win_y: float = tower_bottom - tower_h * frac
		var win_half: float = tower_base_w / 2.0 - (tower_base_w - tower_top_w) / 2.0 * frac
		var slit_w: float = 6.0
		var slit_h: float = 12.0
		# Alternate sides
		var win_x: float = 0.0
		if i % 2 == 0:
			win_x = win_half * 0.3
		else:
			win_x = -win_half * 0.3
		node.draw_rect(Rect2(win_x - slit_w / 2.0, win_y - slit_h / 2.0, slit_w, slit_h), Color(0.2, 0.15, 0.1))
		# Window glow
		var wglow: float = 0.2 + 0.15 * sin(t * 1.2 + float(i) * 1.8)
		node.draw_rect(Rect2(win_x - slit_w / 2.0 + 1.0, win_y - slit_h / 2.0 + 1.0, slit_w - 2.0, slit_h - 2.0), Color(1.0, 0.6, 0.2, wglow))

	# --- Observation deck near top (wider platform) ---
	var deck_y: float = tower_top + tower_h * 0.12
	var deck_w: float = tower_base_w * 1.3
	var deck_thickness: float = 8.0
	node.draw_rect(Rect2(-deck_w / 2.0, deck_y - deck_thickness, deck_w, deck_thickness), Color(0.42, 0.33, 0.22))
	node.draw_line(
		Vector2(-deck_w / 2.0, deck_y - deck_thickness),
		Vector2(deck_w / 2.0, deck_y - deck_thickness),
		Color(0.55, 0.4, 0.25, 0.7), 2.0
	)
	node.draw_line(
		Vector2(-deck_w / 2.0, deck_y),
		Vector2(deck_w / 2.0, deck_y),
		Color(0.55, 0.4, 0.25, 0.5), 1.5
	)
	# Deck railing
	for i in range(0, int(deck_w), 10):
		var rx: float = -deck_w / 2.0 + float(i)
		node.draw_line(
			Vector2(rx, deck_y - deck_thickness),
			Vector2(rx, deck_y - deck_thickness - 8.0),
			Color(0.5, 0.38, 0.25, 0.4), 1.0
		)
	node.draw_line(
		Vector2(-deck_w / 2.0, deck_y - deck_thickness - 8.0),
		Vector2(deck_w / 2.0, deck_y - deck_thickness - 8.0),
		Color(0.5, 0.38, 0.25, 0.5), 1.5
	)
	# Deck instruments (small boxes)
	node.draw_rect(Rect2(-deck_w / 2.0 + 3.0, deck_y - deck_thickness - 6.0, 8.0, 6.0), Color(0.35, 0.28, 0.18))
	node.draw_rect(Rect2(deck_w / 2.0 - 11.0, deck_y - deck_thickness - 5.0, 8.0, 5.0), Color(0.35, 0.28, 0.18))

	# --- Large rotating dish on top ---
	var dish_center_y: float = tower_top - 10.0
	var dish_radius: float = w * 0.22
	var dish_tilt: float = cos(t * 0.6)
	var dish_apparent_w: float = dish_radius * 2.0
	var dish_apparent_h: float = dish_radius * 0.5
	var dish_tilt_abs: float = dish_tilt
	if dish_tilt_abs < 0.0:
		dish_tilt_abs = -dish_tilt_abs
	var eff_h: float = dish_apparent_h * (0.3 + 0.7 * dish_tilt_abs)

	# Dish support column
	node.draw_line(Vector2(0.0, tower_top), Vector2(0.0, dish_center_y), Color(0.5, 0.4, 0.3), 4.0)

	# Draw dish as ellipse approximation (polygon)
	var dish_pts := PackedVector2Array()
	for i in 20:
		var angle: float = float(i) / 20.0 * TAU
		var dx: float = cos(angle) * dish_apparent_w / 2.0
		var dy: float = sin(angle) * eff_h
		dish_pts.append(Vector2(dx, dish_center_y + dy))
	node.draw_colored_polygon(dish_pts, Color(0.55, 0.45, 0.35, 0.8))
	node.draw_polyline(dish_pts, Color(0.7, 0.55, 0.4, 0.6), 2.0)

	# Dish cross-hairs / structure lines
	node.draw_line(
		Vector2(-dish_apparent_w / 2.0, dish_center_y),
		Vector2(dish_apparent_w / 2.0, dish_center_y),
		Color(0.6, 0.48, 0.35, 0.4), 1.5
	)
	node.draw_line(
		Vector2(0.0, dish_center_y - eff_h),
		Vector2(0.0, dish_center_y + eff_h),
		Color(0.6, 0.48, 0.35, 0.4), 1.5
	)

	# Dish reflective glint
	var dish_glint: float = 0.3 + 0.3 * sin(t * 2.0)
	node.draw_circle(Vector2(dish_apparent_w * 0.15, dish_center_y - eff_h * 0.3), 5.0, Color(1.0, 0.95, 0.8, dish_glint))

	# --- Light beam sweeping from dish ---
	var beam_angle: float = t * 1.2
	var beam_len: float = h * 0.5
	var beam_dx: float = cos(beam_angle) * beam_len
	var beam_dy: float = sin(beam_angle) * beam_len * 0.3 - beam_len * 0.5
	var beam_alpha: float = 0.08 + 0.05 * sin(t * 3.0)
	node.draw_line(
		Vector2(0.0, dish_center_y),
		Vector2(beam_dx, dish_center_y + beam_dy),
		Color(1.0, 0.9, 0.5, beam_alpha), 3.0
	)
	# Beam tip glow
	node.draw_circle(
		Vector2(beam_dx, dish_center_y + beam_dy),
		6.0, Color(1.0, 0.9, 0.5, beam_alpha * 1.5)
	)

	# --- Antenna at very top with blinking light ---
	var antenna_base_y: float = dish_center_y - eff_h - 2.0
	var antenna_top_y: float = antenna_base_y - 30.0
	node.draw_line(Vector2(0.0, antenna_base_y), Vector2(0.0, antenna_top_y), Color(0.5, 0.4, 0.3), 2.0)
	# Cross bars on antenna
	node.draw_line(Vector2(-6.0, antenna_top_y + 8.0), Vector2(6.0, antenna_top_y + 8.0), Color(0.5, 0.4, 0.3), 1.5)
	node.draw_line(Vector2(-4.0, antenna_top_y + 16.0), Vector2(4.0, antenna_top_y + 16.0), Color(0.5, 0.4, 0.3), 1.5)
	# Blinking light at tip
	var blink_phase: float = sin(t * 5.0)
	var blink_alpha: float = 0.0
	if blink_phase > 0.3:
		blink_alpha = 1.0
	node.draw_circle(Vector2(0.0, antenna_top_y), 3.0, Color(1.0, 0.2, 0.1, blink_alpha))
	node.draw_circle(Vector2(0.0, antenna_top_y), 7.0, Color(1.0, 0.2, 0.1, blink_alpha * 0.25))

	# --- Pipes/conduits running down tower exterior ---
	for side_val in [0, 1]:
		var pipe_sign: float = -1.0 + float(side_val) * 2.0
		var pipe_x_top: float = pipe_sign * tower_top_w / 2.0 + pipe_sign * 3.0
		var pipe_x_bot: float = pipe_sign * tower_base_w / 2.0 + pipe_sign * 3.0
		var pipe_pts := PackedVector2Array()
		for j in 8:
			var frac: float = float(j) / 7.0
			var px: float = pipe_x_top + (pipe_x_bot - pipe_x_top) * frac
			var py: float = tower_top + tower_h * frac
			pipe_pts.append(Vector2(px, py))
		if pipe_pts.size() >= 2:
			node.draw_polyline(pipe_pts, Color(0.4, 0.35, 0.3), 2.5)
		# Pipe joint markers
		for j in 4:
			var frac: float = float(j) / 3.0
			var jx: float = pipe_x_top + (pipe_x_bot - pipe_x_top) * frac
			var jy: float = tower_top + tower_h * frac
			node.draw_circle(Vector2(jx, jy), 2.5, Color(0.5, 0.4, 0.3, 0.5))

	# --- Base door ---
	node.draw_rect(Rect2(-12.0, -30.0, 24.0, 20.0), Color(0.25, 0.18, 0.12))
	node.draw_rect(Rect2(-12.0, -30.0, 24.0, 20.0), Color(0.5, 0.38, 0.25, 0.5), false, 1.5)

	# --- Ground entrance glow ---
	var glow_pulse: float = 0.35 + 0.25 * sin(t * 2.0)
	node.draw_circle(Vector2(0.0, -3.0), 10.0, Color(1.0, 0.5, 0.1, glow_pulse))
