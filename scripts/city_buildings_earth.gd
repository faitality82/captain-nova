class_name CityBuildingsEarth
extends RefCounted

# Earth — "New Shanghai" megacity
# Clean, sleek, holographic ads, well-maintained paint, rooftop gardens.
# Colors: steel grays (0.3-0.42), glass blues (0.4-0.8 alpha), bright neon accents.

# ── 1. HANGAR — Modern multi-level parking garage ─────────────────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	var left: float = -w / 2.0
	var right: float = w / 2.0
	var floor_count: int = 3
	var floor_h: float = h / float(floor_count)

	# Main structure body — clean concrete gray
	node.draw_rect(Rect2(left, -h, w, h), Color(0.38, 0.40, 0.44))

	# Subtle horizontal panel lines across entire facade
	for i in range(0, int(h), 8):
		var py: float = -h + float(i)
		node.draw_line(Vector2(left, py), Vector2(right, py), Color(0.32, 0.34, 0.38, 0.2), 1.0)

	# Floor separator lines — thick concrete dividers
	for i in range(1, floor_count):
		var fy: float = -float(i) * floor_h
		node.draw_rect(Rect2(left, fy - 3.0, w, 6.0), Color(0.34, 0.36, 0.40))
		# LED strip along each floor edge (bright cyan)
		var led_pulse: float = 0.6 + 0.3 * sin(t * 2.0 + float(i) * 1.2)
		node.draw_line(Vector2(left + 5.0, fy), Vector2(right - 40.0, fy), Color(0.1, 0.8, 1.0, led_pulse), 2.0)

	# LED strip along roof edge
	var led_roof_pulse: float = 0.6 + 0.3 * sin(t * 2.0)
	node.draw_line(Vector2(left + 5.0, -h + 3.0), Vector2(right - 40.0, -h + 3.0), Color(0.1, 0.8, 1.0, led_roof_pulse), 2.0)

	# LED strip along ground floor
	var led_ground_pulse: float = 0.6 + 0.3 * sin(t * 2.0 + 2.4)
	node.draw_line(Vector2(left + 5.0, -3.0), Vector2(right - 40.0, -3.0), Color(0.1, 0.8, 1.0, led_ground_pulse), 2.0)

	# Ramp connecting floors — diagonal line between levels
	var ramp_x_start: float = left + w * 0.15
	var ramp_x_end: float = left + w * 0.45
	for i in range(0, floor_count - 1):
		var ramp_y_bottom: float = -float(i) * floor_h - 6.0
		var ramp_y_top: float = -float(i + 1) * floor_h + 6.0
		node.draw_line(Vector2(ramp_x_start, ramp_y_bottom), Vector2(ramp_x_end, ramp_y_top), Color(0.50, 0.52, 0.56, 0.6), 2.0)
		# Ramp railing
		node.draw_line(Vector2(ramp_x_start, ramp_y_bottom - 4.0), Vector2(ramp_x_end, ramp_y_top - 4.0), Color(0.45, 0.47, 0.50, 0.4), 1.0)

	# Glass elevator shaft on right side — translucent blue
	var elev_w: float = 35.0
	var elev_x: float = right - elev_w - 3.0
	node.draw_rect(Rect2(elev_x, -h, elev_w, h), Color(0.3, 0.5, 0.8, 0.25))
	# Elevator shaft frame
	node.draw_rect(Rect2(elev_x, -h, elev_w, h), Color(0.4, 0.45, 0.55, 0.6), false, 2.0)
	# Elevator vertical guide rails
	node.draw_line(Vector2(elev_x + 4.0, -h), Vector2(elev_x + 4.0, 0.0), Color(0.35, 0.38, 0.45, 0.4), 1.0)
	node.draw_line(Vector2(elev_x + elev_w - 4.0, -h), Vector2(elev_x + elev_w - 4.0, 0.0), Color(0.35, 0.38, 0.45, 0.4), 1.0)

	# Moving elevator car (animated)
	var elev_travel: float = h - 20.0
	var elev_pos: float = (sin(t * 0.8) * 0.5 + 0.5) * elev_travel
	var elev_car_y: float = -10.0 - elev_pos
	node.draw_rect(Rect2(elev_x + 3.0, elev_car_y - 16.0, elev_w - 6.0, 16.0), Color(0.5, 0.7, 0.9, 0.5))
	# Light inside elevator
	var elev_light_pulse: float = 0.6 + 0.2 * sin(t * 4.0)
	node.draw_rect(Rect2(elev_x + 8.0, elev_car_y - 14.0, elev_w - 16.0, 4.0), Color(1.0, 0.95, 0.8, elev_light_pulse))

	# Vehicle/ship silhouettes on each level
	for i in range(0, floor_count):
		var park_y: float = -float(i) * floor_h
		# 2-3 vehicles per level
		for j in range(0, 3):
			var vx: float = left + 20.0 + float(j) * (w * 0.22)
			var vy: float = park_y - 8.0
			# Ship body (small rounded rectangle)
			node.draw_rect(Rect2(vx, vy - 8.0, 28.0, 8.0), Color(0.45 + float(j) * 0.08, 0.48, 0.55, 0.5))
			# Ship cockpit (small triangle on front)
			var cockpit_pts: PackedVector2Array = PackedVector2Array([
				Vector2(vx + 28.0, vy - 6.0),
				Vector2(vx + 34.0, vy - 4.0),
				Vector2(vx + 28.0, vy - 2.0),
			])
			node.draw_colored_polygon(cockpit_pts, Color(0.4, 0.6, 0.8, 0.4))
			# Landing gear dots
			node.draw_circle(Vector2(vx + 5.0, vy), 2.0, Color(0.30, 0.30, 0.32, 0.5))
			node.draw_circle(Vector2(vx + 23.0, vy), 2.0, Color(0.30, 0.30, 0.32, 0.5))

	# Ground level entrance — wide opening
	var entrance_w: float = w * 0.3
	var entrance_h: float = floor_h * 0.7
	node.draw_rect(Rect2(-entrance_w / 2.0, -entrance_h, entrance_w, entrance_h), Color(0.18, 0.20, 0.24))

	# Barrier gate arm (animated — swings up and down slowly)
	var gate_angle: float = sin(t * 0.6) * 0.3 + 0.15
	var gate_x: float = -entrance_w / 2.0 + 8.0
	var gate_y: float = -entrance_h * 0.6
	var gate_end_x: float = gate_x + entrance_w * 0.7 * cos(gate_angle)
	var gate_end_y: float = gate_y - entrance_w * 0.7 * sin(gate_angle)
	node.draw_line(Vector2(gate_x, gate_y), Vector2(gate_end_x, gate_end_y), Color(0.9, 0.2, 0.2), 3.0)
	# Gate pivot post
	node.draw_rect(Rect2(gate_x - 3.0, gate_y, 6.0, -gate_y), Color(0.50, 0.50, 0.52))

	# Security booth beside entrance
	var booth_x: float = -entrance_w / 2.0 - 30.0
	var booth_w: float = 24.0
	var booth_h: float = 36.0
	node.draw_rect(Rect2(booth_x, -booth_h, booth_w, booth_h), Color(0.36, 0.38, 0.42))
	# Booth window
	node.draw_rect(Rect2(booth_x + 3.0, -booth_h + 5.0, booth_w - 6.0, 14.0), Color(0.4, 0.6, 0.8, 0.5))
	# Booth light
	var booth_light: float = 0.5 + 0.3 * sin(t * 1.5)
	node.draw_rect(Rect2(booth_x + 6.0, -booth_h + 8.0, booth_w - 12.0, 4.0), Color(1.0, 0.9, 0.6, booth_light))

	# Rooftop antenna array
	var ant_base_x: float = left + 20.0
	for i in range(0, 4):
		var ax: float = ant_base_x + float(i) * 18.0
		var ant_h: float = 14.0 + float(i) * 5.0
		node.draw_line(Vector2(ax, -h), Vector2(ax, -h - ant_h), Color(0.50, 0.50, 0.55), 2.0)
		# Blinking light at tip
		var blink_rate: float = 2.5 + float(i) * 0.7
		var blink_val: float = 0.5 + 0.5 * sin(t * blink_rate)
		node.draw_circle(Vector2(ax, -h - ant_h - 2.0), 2.5, Color(1.0, 0.1, 0.1, blink_val))

	# Cross-bar between antennas
	node.draw_line(Vector2(ant_base_x, -h - 12.0), Vector2(ant_base_x + 54.0, -h - 12.0), Color(0.45, 0.45, 0.50, 0.5), 1.5)

	# Entrance glow (blue, pulsing)
	var glow_pulse: float = 0.4 + 0.25 * sin(t * 2.0)
	node.draw_rect(Rect2(-entrance_w / 2.0 - 4.0, -4.0, entrance_w + 8.0, 6.0), Color(0.2, 0.5, 1.0, glow_pulse))

	# Roof edge highlight
	node.draw_line(Vector2(left, -h), Vector2(right, -h), Color(0.50, 0.52, 0.58, 0.6), 2.0)

	# Building corner accents
	node.draw_line(Vector2(left, -h), Vector2(left, 0.0), Color(0.42, 0.44, 0.50, 0.4), 2.0)
	node.draw_line(Vector2(right, -h), Vector2(right, 0.0), Color(0.42, 0.44, 0.50, 0.4), 2.0)


# ── 2. MARKET — Multi-story mall with holographic displays ────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	var left: float = -w / 2.0
	var right: float = w / 2.0
	var stories: int = 3
	var story_h: float = h / float(stories)

	# Main structure — steel gray body
	node.draw_rect(Rect2(left, -h, w, h), Color(0.35, 0.38, 0.44))

	# Large glass front wall (translucent blue fill over entire front)
	node.draw_rect(Rect2(left + 6.0, -h + 6.0, w - 12.0, h - 20.0), Color(0.35, 0.55, 0.80, 0.30))

	# Floor separator lines
	for i in range(1, stories):
		var fy: float = -float(i) * story_h
		node.draw_rect(Rect2(left, fy - 2.0, w, 4.0), Color(0.40, 0.42, 0.48))

	# Decorative columns between window sections (5 columns)
	for i in range(0, 6):
		var cx: float = left + float(i) * w / 5.0
		node.draw_rect(Rect2(cx - 3.0, -h, 6.0, h), Color(0.40, 0.42, 0.48, 0.6))
		# Column capital detail at top
		node.draw_rect(Rect2(cx - 5.0, -h, 10.0, 6.0), Color(0.42, 0.44, 0.50, 0.5))

	# Holographic window displays — pulsing colored shapes per story
	for story_idx in range(0, stories):
		var sy_base: float = -float(story_idx + 1) * story_h + 10.0
		var win_section_w: float = w / 5.0 - 12.0
		for col_idx in range(0, 5):
			var wx: float = left + float(col_idx) * w / 5.0 + 9.0
			var wy: float = sy_base
			var ww: float = win_section_w
			var wh: float = story_h - 20.0

			# Window glass
			node.draw_rect(Rect2(wx, wy, ww, wh), Color(0.40, 0.60, 0.85, 0.35))

			# Holographic display inside — colored shapes that pulse
			var holo_phase: float = t * 1.8 + float(col_idx) * 1.4 + float(story_idx) * 2.1
			var holo_alpha: float = 0.3 + 0.25 * sin(holo_phase)
			var holo_r: float = 0.5 + 0.5 * sin(holo_phase * 0.7)
			var holo_g: float = 0.5 + 0.5 * sin(holo_phase * 0.5 + 1.0)
			var holo_b: float = 0.8
			node.draw_rect(Rect2(wx + 4.0, wy + 4.0, ww - 8.0, wh * 0.4), Color(holo_r, holo_g, holo_b, holo_alpha))

			# Shopper silhouettes (tiny figures)
			if story_idx < 2:
				var fig_x: float = wx + 8.0 + sin(t * 0.3 + float(col_idx)) * 4.0
				var fig_y: float = wy + wh - 6.0
				# Head
				node.draw_circle(Vector2(fig_x, fig_y - 8.0), 2.0, Color(0.25, 0.25, 0.30, 0.5))
				# Body
				node.draw_line(Vector2(fig_x, fig_y - 6.0), Vector2(fig_x, fig_y), Color(0.25, 0.25, 0.30, 0.5), 1.5)

			# Window frame
			node.draw_rect(Rect2(wx, wy, ww, wh), Color(0.45, 0.48, 0.55, 0.5), false, 1.0)

	# Escalator visible through glass (diagonal with moving dots) — between floors 1-2
	var esc_x1: float = left + w * 0.65
	var esc_x2: float = left + w * 0.80
	var esc_y1: float = -story_h + 4.0
	var esc_y2: float = -2.0 * story_h + 10.0
	node.draw_line(Vector2(esc_x1, esc_y1), Vector2(esc_x2, esc_y2), Color(0.50, 0.55, 0.60, 0.5), 2.0)
	# Handrails
	node.draw_line(Vector2(esc_x1 - 4.0, esc_y1), Vector2(esc_x2 - 4.0, esc_y2), Color(0.45, 0.48, 0.55, 0.35), 1.0)
	node.draw_line(Vector2(esc_x1 + 4.0, esc_y1), Vector2(esc_x2 + 4.0, esc_y2), Color(0.45, 0.48, 0.55, 0.35), 1.0)
	# Moving dots on escalator
	for i in range(0, 5):
		var esc_t: float = fmod(t * 0.8 + float(i) * 0.2, 1.0)
		var dot_x: float = esc_x1 + (esc_x2 - esc_x1) * esc_t
		var dot_y: float = esc_y1 + (esc_y2 - esc_y1) * esc_t
		node.draw_circle(Vector2(dot_x, dot_y), 2.5, Color(0.55, 0.60, 0.70, 0.6))

	# Second escalator between floors 2-3
	var esc2_y1: float = -2.0 * story_h + 4.0
	var esc2_y2: float = -3.0 * story_h + 10.0
	node.draw_line(Vector2(esc_x1, esc2_y1), Vector2(esc_x2, esc2_y2), Color(0.50, 0.55, 0.60, 0.5), 2.0)
	for i in range(0, 5):
		var esc2_t: float = fmod(t * 0.8 + float(i) * 0.2 + 0.5, 1.0)
		var dot2_x: float = esc_x1 + (esc_x2 - esc_x1) * esc2_t
		var dot2_y: float = esc2_y1 + (esc2_y2 - esc2_y1) * esc2_t
		node.draw_circle(Vector2(dot2_x, dot2_y), 2.5, Color(0.55, 0.60, 0.70, 0.6))

	# Rooftop garden — green irregular shapes on top
	var garden_colors: Array = [Color(0.2, 0.6, 0.25, 0.7), Color(0.15, 0.55, 0.2, 0.65), Color(0.25, 0.65, 0.3, 0.6)]
	for i in range(0, 8):
		var gx: float = left + 15.0 + float(i) * (w - 30.0) / 7.0
		var gy: float = -h - 2.0
		var g_rad: float = 8.0 + sin(float(i) * 2.3) * 3.0
		var gc_idx: int = i % 3
		node.draw_circle(Vector2(gx, gy - g_rad * 0.5), g_rad, garden_colors[gc_idx])
	# Garden planters (brown rectangles)
	for i in range(0, 4):
		var px: float = left + 30.0 + float(i) * (w - 60.0) / 3.0
		node.draw_rect(Rect2(px - 12.0, -h - 3.0, 24.0, 5.0), Color(0.45, 0.30, 0.18, 0.7))

	# Large neon sign across top — "NOVA MALL"
	var sign_w: float = w * 0.6
	var sign_h: float = 16.0
	var sign_x: float = -sign_w / 2.0
	var sign_y: float = -h + 8.0
	# Dark backing
	node.draw_rect(Rect2(sign_x - 4.0, sign_y - 2.0, sign_w + 8.0, sign_h + 4.0), Color(0.06, 0.06, 0.08))
	# Neon glow
	var neon_pulse: float = 0.5 + 0.4 * sin(t * 2.2)
	node.draw_rect(Rect2(sign_x - 6.0, sign_y - 4.0, sign_w + 12.0, sign_h + 8.0), Color(0.0, 0.9, 0.4, neon_pulse * 0.15))
	# Letter blocks
	for i in range(0, 8):
		var lx: float = sign_x + 4.0 + float(i) * (sign_w - 8.0) / 8.0
		var letter_pulse: float = 0.5 + 0.4 * sin(t * 2.5 + float(i) * 0.5)
		node.draw_rect(Rect2(lx, sign_y + 2.0, (sign_w - 8.0) / 8.0 - 3.0, sign_h - 4.0), Color(0.0, 1.0, 0.4, letter_pulse))

	# Revolving door entrance (circle shape)
	var door_cx: float = 0.0
	var door_cy: float = -story_h * 0.35
	var door_rad: float = 16.0
	node.draw_circle(Vector2(door_cx, door_cy), door_rad, Color(0.30, 0.35, 0.42))
	node.draw_arc(Vector2(door_cx, door_cy), door_rad, 0.0, TAU, 24, Color(0.50, 0.55, 0.60, 0.7), 2.0)
	# Revolving door blades (animated rotation)
	var door_rot: float = t * 1.5
	for i in range(0, 4):
		var blade_angle: float = door_rot + float(i) * PI / 2.0
		var bx: float = door_cx + cos(blade_angle) * door_rad * 0.9
		var by: float = door_cy + sin(blade_angle) * door_rad * 0.9
		node.draw_line(Vector2(door_cx, door_cy), Vector2(bx, by), Color(0.55, 0.60, 0.65, 0.6), 1.5)

	# Awnings over ground floor windows
	for i in range(0, 5):
		var awn_cx: float = left + float(i) * w / 5.0 + w / 10.0
		var awn_y: float = -story_h + 6.0
		var awn_pts: PackedVector2Array = PackedVector2Array([
			Vector2(awn_cx - 16.0, awn_y),
			Vector2(awn_cx + 16.0, awn_y),
			Vector2(awn_cx + 20.0, awn_y + 8.0),
			Vector2(awn_cx - 20.0, awn_y + 8.0),
		])
		node.draw_colored_polygon(awn_pts, Color(0.15, 0.50, 0.20, 0.7))

	# Green entrance glow
	var glow_pulse: float = 0.35 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-22.0, -4.0, 44.0, 6.0), Color(0.2, 1.0, 0.3, glow_pulse))

	# Roof edge
	node.draw_line(Vector2(left, -h), Vector2(right, -h), Color(0.50, 0.52, 0.56, 0.5), 2.0)

	# Building corner accents
	node.draw_line(Vector2(left, -h), Vector2(left, 0.0), Color(0.42, 0.44, 0.50, 0.4), 2.0)
	node.draw_line(Vector2(right, -h), Vector2(right, 0.0), Color(0.42, 0.44, 0.50, 0.4), 2.0)


# ── 3. BAR — Neon cocktail lounge with floor-to-ceiling windows ───────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	var left: float = -w / 2.0
	var right: float = w / 2.0

	# Main body — dark moody base
	node.draw_rect(Rect2(left, -h, w, h), Color(0.18, 0.14, 0.22))

	# Second floor balcony structure (upper third)
	var balcony_h: float = h * 0.35
	var balcony_y: float = -h
	node.draw_rect(Rect2(left, balcony_y, w, balcony_h), Color(0.20, 0.16, 0.24))

	# Balcony railing
	var rail_y: float = -h + balcony_h
	node.draw_line(Vector2(left + 8.0, rail_y), Vector2(right - 8.0, rail_y), Color(0.60, 0.55, 0.40, 0.6), 2.0)
	# Railing posts
	for i in range(0, 8):
		var rx: float = left + 8.0 + float(i) * (w - 16.0) / 7.0
		node.draw_line(Vector2(rx, rail_y), Vector2(rx, rail_y - 12.0), Color(0.60, 0.55, 0.40, 0.5), 1.5)
	# Balcony floor line
	node.draw_line(Vector2(left + 4.0, rail_y + 2.0), Vector2(right - 4.0, rail_y + 2.0), Color(0.30, 0.25, 0.35, 0.5), 2.0)

	# Wide glass front wall — floor-to-ceiling windows (ground floor)
	var glass_y: float = rail_y + 4.0
	var glass_h: float = -glass_y - 6.0
	node.draw_rect(Rect2(left + 6.0, glass_y, w - 12.0, glass_h), Color(0.30, 0.25, 0.40, 0.25))

	# Mood lighting through windows — warm glow
	var mood_pulse: float = 0.15 + 0.1 * sin(t * 0.8)
	node.draw_rect(Rect2(left + 8.0, glass_y + 2.0, w - 16.0, glass_h - 4.0), Color(1.0, 0.6, 0.2, mood_pulse))

	# Interior: Long bar counter
	var bar_y: float = glass_y + glass_h * 0.6
	var bar_x1: float = left + 25.0
	var bar_x2: float = right - 60.0
	node.draw_rect(Rect2(bar_x1, bar_y, bar_x2 - bar_x1, 6.0), Color(0.35, 0.20, 0.15, 0.6))
	# Bar top surface highlight
	node.draw_line(Vector2(bar_x1, bar_y), Vector2(bar_x2, bar_y), Color(0.55, 0.40, 0.25, 0.5), 1.0)

	# Bottle shelves behind bar (back wall area)
	var shelf_x: float = left + 20.0
	var shelf_w: float = w * 0.45
	for i in range(0, 3):
		var sy: float = glass_y + 10.0 + float(i) * 14.0
		node.draw_line(Vector2(shelf_x, sy), Vector2(shelf_x + shelf_w, sy), Color(0.35, 0.25, 0.20, 0.5), 1.5)
		# Bottles on shelf
		for j in range(0, 8):
			var bx: float = shelf_x + 5.0 + float(j) * (shelf_w - 10.0) / 8.0
			var bottle_h: float = 8.0 + sin(float(j) * 1.7) * 2.0
			var bottle_color: Color = Color(0.4 + float(j) * 0.06, 0.25, 0.15 + float(i) * 0.1, 0.5)
			node.draw_rect(Rect2(bx, sy - bottle_h, 3.0, bottle_h), bottle_color)

	# Bar stool shapes
	for i in range(0, 5):
		var stool_x: float = bar_x1 + 10.0 + float(i) * (bar_x2 - bar_x1 - 20.0) / 4.0
		var stool_y: float = bar_y + 6.0
		# Stool post
		node.draw_line(Vector2(stool_x, stool_y), Vector2(stool_x, stool_y + 12.0), Color(0.50, 0.50, 0.55, 0.4), 1.5)
		# Stool seat
		node.draw_line(Vector2(stool_x - 4.0, stool_y), Vector2(stool_x + 4.0, stool_y), Color(0.50, 0.50, 0.55, 0.5), 2.0)

	# Patrons at bar (tiny silhouettes)
	for i in range(0, 3):
		var patron_x: float = bar_x1 + 15.0 + float(i) * 30.0
		var patron_y: float = bar_y - 2.0
		# Head
		node.draw_circle(Vector2(patron_x, patron_y - 14.0), 3.0, Color(0.25, 0.20, 0.28, 0.5))
		# Torso
		node.draw_line(Vector2(patron_x, patron_y - 11.0), Vector2(patron_x, patron_y), Color(0.25, 0.20, 0.28, 0.5), 2.0)

	# Tables with patrons (right side)
	for i in range(0, 2):
		var table_x: float = right - 50.0 + float(i) * 25.0
		var table_y: float = glass_y + glass_h * 0.5 + float(i) * 15.0
		# Table
		node.draw_rect(Rect2(table_x - 8.0, table_y, 16.0, 3.0), Color(0.35, 0.25, 0.20, 0.5))
		# Table leg
		node.draw_line(Vector2(table_x, table_y + 3.0), Vector2(table_x, table_y + 10.0), Color(0.30, 0.22, 0.18, 0.4), 1.5)
		# Patron at table
		node.draw_circle(Vector2(table_x - 3.0, table_y - 10.0), 2.5, Color(0.25, 0.20, 0.28, 0.4))
		node.draw_line(Vector2(table_x - 3.0, table_y - 7.5), Vector2(table_x - 3.0, table_y), Color(0.25, 0.20, 0.28, 0.4), 1.5)

	# Small stage area (right side, ground floor)
	var stage_x: float = right - 35.0
	var stage_y: float = glass_y + glass_h - 8.0
	var stage_w: float = 28.0
	node.draw_rect(Rect2(stage_x - stage_w / 2.0, stage_y, stage_w, 8.0), Color(0.30, 0.22, 0.28, 0.5))
	# Spotlight cone (animated)
	var spot_sway: float = sin(t * 1.2) * 8.0
	var spot_pts: PackedVector2Array = PackedVector2Array([
		Vector2(stage_x + spot_sway, glass_y + 6.0),
		Vector2(stage_x - 12.0, stage_y),
		Vector2(stage_x + 12.0, stage_y),
	])
	var spot_pulse: float = 0.15 + 0.1 * sin(t * 2.5)
	node.draw_colored_polygon(spot_pts, Color(1.0, 0.9, 0.5, spot_pulse))

	# Neon signs on facade — multiple colors, different pulse rates
	# Sign 1: Purple neon (top left)
	var neon1_x: float = left + 15.0
	var neon1_y: float = balcony_y + 10.0
	var neon1_pulse: float = 0.5 + 0.45 * sin(t * 3.0)
	node.draw_rect(Rect2(neon1_x, neon1_y, 40.0, 10.0), Color(0.05, 0.03, 0.06))
	node.draw_rect(Rect2(neon1_x + 3.0, neon1_y + 2.0, 34.0, 6.0), Color(0.8, 0.2, 1.0, neon1_pulse))
	# Glow
	node.draw_rect(Rect2(neon1_x - 2.0, neon1_y - 2.0, 44.0, 14.0), Color(0.8, 0.2, 1.0, neon1_pulse * 0.15))

	# Sign 2: Cyan neon (top right)
	var neon2_x: float = right - 65.0
	var neon2_y: float = balcony_y + 10.0
	var neon2_pulse: float = 0.5 + 0.45 * sin(t * 2.3 + 1.0)
	node.draw_rect(Rect2(neon2_x, neon2_y, 50.0, 10.0), Color(0.05, 0.05, 0.06))
	node.draw_rect(Rect2(neon2_x + 3.0, neon2_y + 2.0, 44.0, 6.0), Color(0.1, 0.9, 1.0, neon2_pulse))
	node.draw_rect(Rect2(neon2_x - 2.0, neon2_y - 2.0, 54.0, 14.0), Color(0.1, 0.9, 1.0, neon2_pulse * 0.15))

	# Sign 3: Pink neon (above entrance)
	var neon3_y: float = rail_y + 8.0
	var neon3_pulse: float = 0.5 + 0.45 * sin(t * 2.8 + 2.0)
	node.draw_rect(Rect2(-30.0, neon3_y, 60.0, 12.0), Color(0.06, 0.04, 0.05))
	node.draw_rect(Rect2(-27.0, neon3_y + 2.0, 54.0, 8.0), Color(1.0, 0.3, 0.5, neon3_pulse))
	node.draw_rect(Rect2(-32.0, neon3_y - 2.0, 64.0, 16.0), Color(1.0, 0.3, 0.5, neon3_pulse * 0.15))

	# Large illuminated sign on roof — "LOUNGE"
	var roof_sign_w: float = w * 0.5
	var roof_sign_h: float = 18.0
	var roof_sign_x: float = -roof_sign_w / 2.0
	var roof_sign_y: float = -h - roof_sign_h - 4.0
	node.draw_rect(Rect2(roof_sign_x - 3.0, roof_sign_y - 2.0, roof_sign_w + 6.0, roof_sign_h + 4.0), Color(0.08, 0.06, 0.10))
	# Sign support posts
	node.draw_line(Vector2(roof_sign_x, -h), Vector2(roof_sign_x, roof_sign_y + roof_sign_h), Color(0.40, 0.40, 0.45), 2.0)
	node.draw_line(Vector2(roof_sign_x + roof_sign_w, -h), Vector2(roof_sign_x + roof_sign_w, roof_sign_y + roof_sign_h), Color(0.40, 0.40, 0.45), 2.0)
	# Letter blocks
	for i in range(0, 6):
		var lx: float = roof_sign_x + 5.0 + float(i) * (roof_sign_w - 10.0) / 6.0
		var lpulse: float = 0.5 + 0.4 * sin(t * 2.5 + float(i) * 0.8)
		node.draw_rect(Rect2(lx, roof_sign_y + 3.0, (roof_sign_w - 10.0) / 6.0 - 4.0, roof_sign_h - 6.0), Color(1.0, 0.2, 0.4, lpulse))

	# Velvet rope entrance
	var rope_y: float = -8.0
	var rope_x1: float = -28.0
	var rope_x2: float = -14.0
	var rope_x3: float = 14.0
	var rope_x4: float = 28.0
	# Posts
	node.draw_line(Vector2(rope_x1, rope_y - 16.0), Vector2(rope_x1, rope_y), Color(0.70, 0.55, 0.20), 2.0)
	node.draw_circle(Vector2(rope_x1, rope_y - 16.0), 3.0, Color(0.80, 0.65, 0.25))
	node.draw_line(Vector2(rope_x2, rope_y - 16.0), Vector2(rope_x2, rope_y), Color(0.70, 0.55, 0.20), 2.0)
	node.draw_circle(Vector2(rope_x2, rope_y - 16.0), 3.0, Color(0.80, 0.65, 0.25))
	node.draw_line(Vector2(rope_x3, rope_y - 16.0), Vector2(rope_x3, rope_y), Color(0.70, 0.55, 0.20), 2.0)
	node.draw_circle(Vector2(rope_x3, rope_y - 16.0), 3.0, Color(0.80, 0.65, 0.25))
	node.draw_line(Vector2(rope_x4, rope_y - 16.0), Vector2(rope_x4, rope_y), Color(0.70, 0.55, 0.20), 2.0)
	node.draw_circle(Vector2(rope_x4, rope_y - 16.0), 3.0, Color(0.80, 0.65, 0.25))
	# Ropes (sagging curves approximated as lines)
	node.draw_line(Vector2(rope_x1, rope_y - 13.0), Vector2(rope_x2, rope_y - 13.0), Color(0.70, 0.15, 0.15, 0.7), 2.0)
	node.draw_line(Vector2(rope_x3, rope_y - 13.0), Vector2(rope_x4, rope_y - 13.0), Color(0.70, 0.15, 0.15, 0.7), 2.0)

	# Entrance doors
	node.draw_rect(Rect2(-12.0, -h * 0.25, 10.0, h * 0.25 - 6.0), Color(0.15, 0.12, 0.18))
	node.draw_rect(Rect2(2.0, -h * 0.25, 10.0, h * 0.25 - 6.0), Color(0.15, 0.12, 0.18))
	# Door handles
	node.draw_circle(Vector2(-5.0, -h * 0.13), 2.0, Color(0.80, 0.65, 0.25))
	node.draw_circle(Vector2(5.0, -h * 0.13), 2.0, Color(0.80, 0.65, 0.25))

	# Red entrance glow
	var glow_pulse: float = 0.35 + 0.25 * sin(t * 2.0)
	node.draw_rect(Rect2(-16.0, -4.0, 32.0, 6.0), Color(1.0, 0.2, 0.3, glow_pulse))

	# Window divider lines (vertical mullions on glass)
	for i in range(0, 6):
		var mx: float = left + 6.0 + float(i) * (w - 12.0) / 5.0
		node.draw_line(Vector2(mx, glass_y), Vector2(mx, glass_y + glass_h), Color(0.25, 0.20, 0.30, 0.4), 1.0)

	# Roof edge
	node.draw_line(Vector2(left, -h), Vector2(right, -h), Color(0.40, 0.35, 0.50, 0.5), 2.0)


# ── 4. GARAGE — High-tech auto shop with diagnostic holograms ─────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	var left: float = -w / 2.0
	var right: float = w / 2.0

	# Main body — clean modern white/gray
	node.draw_rect(Rect2(left, -h, w, h), Color(0.42, 0.44, 0.48))

	# Subtle panel lines
	for i in range(0, int(h), 12):
		var py: float = -h + float(i)
		node.draw_line(Vector2(left, py), Vector2(right, py), Color(0.38, 0.40, 0.44, 0.2), 1.0)

	# Wide bay opening (center-left area)
	var bay_w: float = w * 0.50
	var bay_h: float = h * 0.70
	var bay_x: float = left + 15.0
	var bay_y: float = -bay_h
	node.draw_rect(Rect2(bay_x, bay_y, bay_w, bay_h), Color(0.15, 0.16, 0.20))

	# Bay frame — clean blue accent
	node.draw_rect(Rect2(bay_x, bay_y, bay_w, bay_h), Color(0.2, 0.5, 0.9, 0.4), false, 3.0)

	# Vehicle lift platform (raised)
	var lift_x: float = bay_x + 15.0
	var lift_w: float = bay_w - 30.0
	var lift_y: float = bay_y + bay_h * 0.55
	# Lift columns
	node.draw_rect(Rect2(lift_x - 4.0, bay_y + bay_h * 0.3, 6.0, bay_h * 0.7), Color(0.35, 0.37, 0.42, 0.6))
	node.draw_rect(Rect2(lift_x + lift_w - 2.0, bay_y + bay_h * 0.3, 6.0, bay_h * 0.7), Color(0.35, 0.37, 0.42, 0.6))
	# Lift platform
	node.draw_rect(Rect2(lift_x, lift_y, lift_w, 4.0), Color(0.50, 0.52, 0.58))

	# Ship silhouette on lift
	var ship_cx: float = lift_x + lift_w / 2.0
	var ship_y: float = lift_y - 4.0
	# Ship body
	var ship_pts: PackedVector2Array = PackedVector2Array([
		Vector2(ship_cx - 30.0, ship_y),
		Vector2(ship_cx - 35.0, ship_y - 10.0),
		Vector2(ship_cx - 20.0, ship_y - 16.0),
		Vector2(ship_cx + 20.0, ship_y - 16.0),
		Vector2(ship_cx + 35.0, ship_y - 10.0),
		Vector2(ship_cx + 30.0, ship_y),
	])
	node.draw_colored_polygon(ship_pts, Color(0.45, 0.48, 0.55, 0.6))
	# Ship cockpit
	node.draw_rect(Rect2(ship_cx - 8.0, ship_y - 14.0, 16.0, 6.0), Color(0.35, 0.55, 0.75, 0.5))
	# Ship engine glow (faint)
	node.draw_circle(Vector2(ship_cx - 20.0, ship_y - 2.0), 4.0, Color(0.2, 0.5, 1.0, 0.25))
	node.draw_circle(Vector2(ship_cx + 20.0, ship_y - 2.0), 4.0, Color(0.2, 0.5, 1.0, 0.25))

	# Diagnostic hologram display — wireframe shape floating above workbench
	var holo_cx: float = bay_x + bay_w * 0.75
	var holo_cy: float = bay_y + bay_h * 0.3
	var holo_spin: float = t * 1.2
	var holo_alpha: float = 0.4 + 0.2 * sin(t * 2.0)
	var holo_color: Color = Color(0.1, 0.8, 1.0, holo_alpha)
	# Rotating wireframe cube
	var cube_sz: float = 14.0
	for i in range(0, 4):
		var angle_a: float = holo_spin + float(i) * PI / 2.0
		var angle_b: float = holo_spin + float(i + 1) * PI / 2.0
		var ax: float = holo_cx + cos(angle_a) * cube_sz
		var ay: float = holo_cy + sin(angle_a) * cube_sz * 0.5
		var bx: float = holo_cx + cos(angle_b) * cube_sz
		var by: float = holo_cy + sin(angle_b) * cube_sz * 0.5
		node.draw_line(Vector2(ax, ay), Vector2(bx, by), holo_color, 1.5)
		# Vertical lines to offset layer
		var ax2: float = holo_cx + cos(angle_a) * cube_sz * 0.7
		var ay2: float = holo_cy - 10.0 + sin(angle_a) * cube_sz * 0.35
		node.draw_line(Vector2(ax, ay), Vector2(ax2, ay2), holo_color, 1.0)
	# Upper ring
	for i in range(0, 4):
		var angle_a: float = holo_spin + float(i) * PI / 2.0
		var angle_b: float = holo_spin + float(i + 1) * PI / 2.0
		var ax: float = holo_cx + cos(angle_a) * cube_sz * 0.7
		var ay: float = holo_cy - 10.0 + sin(angle_a) * cube_sz * 0.35
		var bx: float = holo_cx + cos(angle_b) * cube_sz * 0.7
		var by: float = holo_cy - 10.0 + sin(angle_b) * cube_sz * 0.35
		node.draw_line(Vector2(ax, ay), Vector2(bx, by), holo_color, 1.0)
	# Hologram base glow
	node.draw_circle(Vector2(holo_cx, holo_cy + cube_sz * 0.5 + 4.0), 10.0, Color(0.1, 0.7, 1.0, 0.1))
	# Scanlines through hologram
	for i in range(0, 3):
		var sly: float = holo_cy - 10.0 + float(i) * 10.0
		var sl_alpha: float = 0.15 + 0.1 * sin(t * 3.0 + float(i))
		node.draw_line(Vector2(holo_cx - 16.0, sly), Vector2(holo_cx + 16.0, sly), Color(0.1, 0.8, 1.0, sl_alpha), 1.0)

	# Tool cabinets along back wall (right side of bay, grid of small rectangles)
	var cab_x: float = bay_x + bay_w - 40.0
	var cab_y: float = bay_y + 10.0
	for row in range(0, 4):
		for col in range(0, 3):
			var cx: float = cab_x + float(col) * 12.0
			var cy: float = cab_y + float(row) * 14.0
			node.draw_rect(Rect2(cx, cy, 10.0, 12.0), Color(0.35, 0.37, 0.42, 0.6))
			node.draw_rect(Rect2(cx, cy, 10.0, 12.0), Color(0.45, 0.48, 0.55, 0.4), false, 1.0)
			# Drawer handle
			node.draw_line(Vector2(cx + 3.0, cy + 6.0), Vector2(cx + 7.0, cy + 6.0), Color(0.55, 0.58, 0.62, 0.5), 1.0)

	# LED floor guide strips (thin lines on ground inside bay)
	for i in range(0, 4):
		var guide_x: float = bay_x + 20.0 + float(i) * (bay_w - 40.0) / 3.0
		var guide_pulse: float = 0.4 + 0.3 * sin(t * 1.5 + float(i) * 0.8)
		node.draw_line(Vector2(guide_x, bay_y + bay_h - 2.0), Vector2(guide_x, -2.0), Color(0.2, 0.6, 1.0, guide_pulse), 1.5)

	# Digital readout panel near entrance (right side of building)
	var panel_x: float = right - 55.0
	var panel_y: float = -h * 0.55
	var panel_w: float = 40.0
	var panel_h: float = 50.0
	node.draw_rect(Rect2(panel_x, panel_y, panel_w, panel_h), Color(0.08, 0.10, 0.14))
	node.draw_rect(Rect2(panel_x, panel_y, panel_w, panel_h), Color(0.2, 0.5, 0.9, 0.4), false, 1.5)
	# Scrolling data lines
	for i in range(0, 6):
		var data_y: float = panel_y + 5.0 + float(i) * 7.0
		var data_scroll: float = fmod(t * 20.0 + float(i) * 15.0, panel_w - 8.0)
		var data_w: float = 12.0 + sin(float(i) * 2.3) * 6.0
		if data_scroll + data_w < panel_w - 4.0:
			node.draw_line(Vector2(panel_x + 4.0 + data_scroll, data_y), Vector2(panel_x + 4.0 + data_scroll + data_w, data_y), Color(0.1, 0.9, 0.3, 0.6), 1.5)
	# Panel header line
	node.draw_line(Vector2(panel_x + 3.0, panel_y + 3.0), Vector2(panel_x + panel_w - 3.0, panel_y + 3.0), Color(0.1, 0.8, 1.0, 0.5), 1.0)

	# Overhead track lighting
	var track_y: float = bay_y + 5.0
	node.draw_line(Vector2(bay_x + 5.0, track_y), Vector2(bay_x + bay_w - 5.0, track_y), Color(0.50, 0.52, 0.56, 0.5), 2.0)
	# Light fixtures along track
	for i in range(0, 5):
		var lx: float = bay_x + 15.0 + float(i) * (bay_w - 30.0) / 4.0
		node.draw_rect(Rect2(lx - 4.0, track_y, 8.0, 6.0), Color(0.55, 0.57, 0.62, 0.5))
		# Light cone below fixture
		var light_alpha: float = 0.08 + 0.04 * sin(t * 1.0 + float(i) * 0.5)
		var cone_pts: PackedVector2Array = PackedVector2Array([
			Vector2(lx - 3.0, track_y + 6.0),
			Vector2(lx + 3.0, track_y + 6.0),
			Vector2(lx + 18.0, track_y + 50.0),
			Vector2(lx - 18.0, track_y + 50.0),
		])
		node.draw_colored_polygon(cone_pts, Color(1.0, 0.95, 0.85, light_alpha))

	# "CERTIFIED" badge on wall (right of bay)
	var badge_x: float = right - 50.0
	var badge_y: float = -h * 0.82
	var badge_rad: float = 16.0
	node.draw_circle(Vector2(badge_x, badge_y), badge_rad, Color(0.1, 0.3, 0.7, 0.5))
	node.draw_arc(Vector2(badge_x, badge_y), badge_rad, 0.0, TAU, 20, Color(0.2, 0.5, 0.9, 0.7), 2.0)
	# Inner circle
	node.draw_arc(Vector2(badge_x, badge_y), badge_rad * 0.7, 0.0, TAU, 16, Color(0.2, 0.5, 0.9, 0.5), 1.0)
	# Star in center (simplified as small lines)
	for i in range(0, 5):
		var star_angle: float = float(i) * TAU / 5.0 - PI / 2.0
		var sx: float = badge_x + cos(star_angle) * 7.0
		var sy: float = badge_y + sin(star_angle) * 7.0
		node.draw_line(Vector2(badge_x, badge_y), Vector2(sx, sy), Color(0.3, 0.6, 1.0, 0.6), 1.5)

	# Blue entrance glow
	var glow_pulse: float = 0.35 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(bay_x - 3.0, -4.0, bay_w + 6.0, 6.0), Color(0.2, 0.5, 1.0, glow_pulse))

	# Roof edge
	node.draw_line(Vector2(left, -h), Vector2(right, -h), Color(0.48, 0.50, 0.55, 0.5), 2.0)

	# Building edge accents
	node.draw_line(Vector2(left, -h), Vector2(left, 0.0), Color(0.40, 0.42, 0.48, 0.4), 2.0)
	node.draw_line(Vector2(right, -h), Vector2(right, 0.0), Color(0.40, 0.42, 0.48, 0.4), 2.0)


# ── 5. UNIQUE — Nova Corps HQ (government building) ──────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	var left: float = -w / 2.0
	var right: float = w / 2.0

	# Grand steps leading up to entrance (5 steps)
	var step_count: int = 5
	var step_total_h: float = h * 0.15
	var step_each_h: float = step_total_h / float(step_count)
	var step_total_depth: float = w * 0.15
	for i in range(0, step_count):
		var sx_inset: float = float(step_count - i) * step_total_depth / float(step_count)
		var sy: float = -float(i) * step_each_h
		var sw: float = w - sx_inset * 2.0
		node.draw_rect(Rect2(-sw / 2.0, sy - step_each_h, sw, step_each_h), Color(0.52, 0.54, 0.58))
		# Step edge highlight
		node.draw_line(Vector2(-sw / 2.0, sy - step_each_h), Vector2(sw / 2.0, sy - step_each_h), Color(0.58, 0.60, 0.65, 0.6), 1.0)

	# Main structure body (above steps)
	var base_y: float = -step_total_h
	var main_h: float = h - step_total_h
	node.draw_rect(Rect2(left, -h, w, main_h), Color(0.40, 0.42, 0.48))

	# Pediment (triangular roof section)
	var pediment_h: float = h * 0.12
	var ped_pts: PackedVector2Array = PackedVector2Array([
		Vector2(left, -h),
		Vector2(0.0, -h - pediment_h),
		Vector2(right, -h),
	])
	node.draw_colored_polygon(ped_pts, Color(0.44, 0.46, 0.52))
	# Pediment edge lines
	node.draw_line(Vector2(left, -h), Vector2(0.0, -h - pediment_h), Color(0.50, 0.52, 0.58, 0.7), 2.0)
	node.draw_line(Vector2(0.0, -h - pediment_h), Vector2(right, -h), Color(0.50, 0.52, 0.58, 0.7), 2.0)
	node.draw_line(Vector2(left, -h), Vector2(right, -h), Color(0.50, 0.52, 0.58, 0.5), 2.0)

	# Columns across front (6 columns)
	var col_count: int = 6
	var col_w: float = 12.0
	var col_margin: float = 25.0
	var col_spacing: float = (w - col_margin * 2.0 - col_w) / float(col_count - 1)
	for i in range(0, col_count):
		var cx: float = left + col_margin + float(i) * col_spacing
		var col_top: float = -h + 6.0
		var col_bottom: float = base_y
		# Column shaft
		node.draw_rect(Rect2(cx, col_top, col_w, col_bottom - col_top), Color(0.50, 0.52, 0.58))
		# Column capital (top decoration)
		node.draw_rect(Rect2(cx - 3.0, col_top - 4.0, col_w + 6.0, 8.0), Color(0.52, 0.54, 0.60))
		# Column base
		node.draw_rect(Rect2(cx - 2.0, col_bottom - 6.0, col_w + 4.0, 6.0), Color(0.50, 0.52, 0.58))
		# Vertical fluting lines on column
		for j in range(0, 3):
			var flute_x: float = cx + 2.0 + float(j) * (col_w - 4.0) / 2.0
			node.draw_line(Vector2(flute_x, col_top + 4.0), Vector2(flute_x, col_bottom - 6.0), Color(0.46, 0.48, 0.54, 0.3), 1.0)

		# Spotlight illuminating column from below
		var spot_cone_pts: PackedVector2Array = PackedVector2Array([
			Vector2(cx + col_w / 2.0 - 3.0, col_bottom),
			Vector2(cx + col_w / 2.0 + 3.0, col_bottom),
			Vector2(cx + col_w / 2.0 + 14.0, col_top + main_h * 0.3),
			Vector2(cx + col_w / 2.0 - 14.0, col_top + main_h * 0.3),
		])
		var spot_alpha: float = 0.06 + 0.03 * sin(t * 1.0 + float(i) * 0.5)
		node.draw_colored_polygon(spot_cone_pts, Color(1.0, 0.95, 0.80, spot_alpha))

	# Wall behind columns (darker inset)
	var wall_x: float = left + col_margin - 2.0
	var wall_w: float = w - (col_margin - 2.0) * 2.0
	node.draw_rect(Rect2(wall_x, -h + 6.0, wall_w, main_h - 6.0), Color(0.35, 0.37, 0.42))

	# Large double doors (center)
	var door_w: float = 22.0
	var door_h_val: float = main_h * 0.55
	var door_y: float = base_y - door_h_val
	# Left door
	node.draw_rect(Rect2(-door_w - 2.0, door_y, door_w, door_h_val), Color(0.22, 0.20, 0.26))
	# Right door
	node.draw_rect(Rect2(2.0, door_y, door_w, door_h_val), Color(0.22, 0.20, 0.26))
	# Door frames
	node.draw_rect(Rect2(-door_w - 2.0, door_y, door_w, door_h_val), Color(0.45, 0.42, 0.35, 0.5), false, 1.5)
	node.draw_rect(Rect2(2.0, door_y, door_w, door_h_val), Color(0.45, 0.42, 0.35, 0.5), false, 1.5)
	# Door handles
	node.draw_circle(Vector2(-6.0, door_y + door_h_val * 0.5), 2.5, Color(0.80, 0.70, 0.30))
	node.draw_circle(Vector2(6.0, door_y + door_h_val * 0.5), 2.5, Color(0.80, 0.70, 0.30))
	# Door panel details (horizontal line)
	node.draw_line(Vector2(-door_w - 1.0, door_y + door_h_val * 0.35), Vector2(-3.0, door_y + door_h_val * 0.35), Color(0.35, 0.32, 0.30, 0.3), 1.0)
	node.draw_line(Vector2(3.0, door_y + door_h_val * 0.35), Vector2(door_w + 1.0, door_y + door_h_val * 0.35), Color(0.35, 0.32, 0.30, 0.3), 1.0)

	# Clock/emblem circle above entrance
	var emblem_y: float = door_y - 20.0
	var emblem_rad: float = 16.0
	node.draw_circle(Vector2(0.0, emblem_y), emblem_rad, Color(0.30, 0.32, 0.38))
	node.draw_arc(Vector2(0.0, emblem_y), emblem_rad, 0.0, TAU, 24, Color(0.55, 0.50, 0.35, 0.7), 2.0)
	# Inner circle
	node.draw_arc(Vector2(0.0, emblem_y), emblem_rad * 0.7, 0.0, TAU, 20, Color(0.50, 0.48, 0.35, 0.5), 1.0)
	# Clock hands (animated)
	var hour_angle: float = t * 0.1
	var minute_angle: float = t * 0.8
	node.draw_line(Vector2(0.0, emblem_y), Vector2(cos(hour_angle) * 8.0, emblem_y + sin(hour_angle) * 8.0), Color(0.70, 0.65, 0.40, 0.7), 2.0)
	node.draw_line(Vector2(0.0, emblem_y), Vector2(cos(minute_angle) * 11.0, emblem_y + sin(minute_angle) * 11.0), Color(0.70, 0.65, 0.40, 0.6), 1.5)
	# Center dot
	node.draw_circle(Vector2(0.0, emblem_y), 2.0, Color(0.75, 0.70, 0.40))

	# Name plaque above doors — "NOVA CORPS HQ"
	var plaque_w: float = 100.0
	var plaque_h: float = 14.0
	var plaque_y: float = door_y - 6.0
	node.draw_rect(Rect2(-plaque_w / 2.0, plaque_y, plaque_w, plaque_h), Color(0.25, 0.22, 0.28))
	node.draw_rect(Rect2(-plaque_w / 2.0, plaque_y, plaque_w, plaque_h), Color(0.55, 0.50, 0.35, 0.5), false, 1.0)
	# Text blocks (approximated as small rectangles)
	for i in range(0, 10):
		var tx: float = -plaque_w / 2.0 + 8.0 + float(i) * 9.0
		node.draw_rect(Rect2(tx, plaque_y + 3.0, 6.0, plaque_h - 6.0), Color(0.80, 0.75, 0.45, 0.6))

	# Windows on either side of doors (symmetrical)
	var win_w_val: float = 30.0
	var win_h_val: float = main_h * 0.35
	for side_idx in range(0, 2):
		var side_val: float = -1.0 + float(side_idx) * 2.0
		var win_x: float = side_val * (door_w + 20.0) + (win_w_val / 2.0 * side_val) - win_w_val / 2.0
		var win_y: float = door_y + 5.0
		node.draw_rect(Rect2(win_x, win_y, win_w_val, win_h_val), Color(0.35, 0.50, 0.70, 0.35))
		node.draw_rect(Rect2(win_x, win_y, win_w_val, win_h_val), Color(0.45, 0.48, 0.55, 0.5), false, 1.0)
		# Window cross
		node.draw_line(Vector2(win_x + win_w_val / 2.0, win_y), Vector2(win_x + win_w_val / 2.0, win_y + win_h_val), Color(0.45, 0.48, 0.55, 0.35), 1.0)
		node.draw_line(Vector2(win_x, win_y + win_h_val / 2.0), Vector2(win_x + win_w_val, win_y + win_h_val / 2.0), Color(0.45, 0.48, 0.55, 0.35), 1.0)

	# Flag on roof pole (animated wave)
	var flag_x: float = right - 30.0
	var flag_pole_h: float = 35.0
	# Pole
	node.draw_line(Vector2(flag_x, -h - pediment_h * 0.3), Vector2(flag_x, -h - pediment_h * 0.3 - flag_pole_h), Color(0.55, 0.55, 0.58), 2.0)
	# Flag (waving via sine)
	var flag_w_val: float = 24.0
	var flag_h_val: float = 14.0
	var flag_top: float = -h - pediment_h * 0.3 - flag_pole_h
	var flag_segments: int = 6
	for i in range(0, flag_segments):
		var seg_x: float = flag_x + float(i) * flag_w_val / float(flag_segments)
		var seg_x2: float = flag_x + float(i + 1) * flag_w_val / float(flag_segments)
		var wave1: float = sin(t * 3.0 + float(i) * 0.8) * 2.0
		var wave2: float = sin(t * 3.0 + float(i + 1) * 0.8) * 2.0
		var flag_seg_pts: PackedVector2Array = PackedVector2Array([
			Vector2(seg_x, flag_top + wave1),
			Vector2(seg_x2, flag_top + wave2),
			Vector2(seg_x2, flag_top + flag_h_val + wave2),
			Vector2(seg_x, flag_top + flag_h_val + wave1),
		])
		node.draw_colored_polygon(flag_seg_pts, Color(0.15, 0.25, 0.65, 0.8))
	# Flag stripe
	for i in range(0, flag_segments):
		var seg_x: float = flag_x + float(i) * flag_w_val / float(flag_segments)
		var seg_x2: float = flag_x + float(i + 1) * flag_w_val / float(flag_segments)
		var wave1: float = sin(t * 3.0 + float(i) * 0.8) * 2.0
		var wave2: float = sin(t * 3.0 + float(i + 1) * 0.8) * 2.0
		var stripe_y: float = flag_top + flag_h_val * 0.4
		node.draw_line(Vector2(seg_x, stripe_y + wave1), Vector2(seg_x2, stripe_y + wave2), Color(0.80, 0.75, 0.30, 0.7), 2.0)

	# Surveillance cameras on corners
	for side_idx in range(0, 2):
		var side_val: float = -1.0 + float(side_idx) * 2.0
		var cam_x: float = side_val * (w / 2.0 - 8.0)
		var cam_y: float = -h + 12.0
		# Camera mount
		node.draw_rect(Rect2(cam_x - 3.0, cam_y - 2.0, 6.0, 4.0), Color(0.30, 0.30, 0.35))
		# Camera body
		node.draw_rect(Rect2(cam_x - 2.0 + side_val * 4.0, cam_y - 3.0, 8.0, 6.0), Color(0.25, 0.25, 0.30))
		# Camera lens (red blinking)
		var cam_blink: float = 0.5 + 0.5 * sin(t * 2.5 + float(side_idx) * PI)
		node.draw_circle(Vector2(cam_x + side_val * 10.0, cam_y), 2.0, Color(1.0, 0.1, 0.1, cam_blink))

	# Manicured hedges beside steps (green rectangles)
	for side_idx in range(0, 2):
		var side_val: float = -1.0 + float(side_idx) * 2.0
		var hedge_x: float = side_val * (w / 2.0 - 20.0) - 14.0
		# Large hedge
		node.draw_rect(Rect2(hedge_x, -step_total_h - 8.0, 28.0, step_total_h + 8.0), Color(0.15, 0.50, 0.20, 0.7))
		# Hedge top rounded (circle)
		node.draw_circle(Vector2(hedge_x + 14.0, -step_total_h - 8.0), 14.0, Color(0.18, 0.55, 0.22, 0.65))
		# Small accent hedge
		node.draw_rect(Rect2(hedge_x + 4.0, -4.0, 20.0, 4.0), Color(0.12, 0.45, 0.18, 0.5))

	# Symmetrical decorative lines on wall (between windows and columns)
	for side_idx in range(0, 2):
		var side_val: float = -1.0 + float(side_idx) * 2.0
		var dec_x: float = side_val * (w * 0.38)
		node.draw_line(Vector2(dec_x, -h + 20.0), Vector2(dec_x, base_y - 10.0), Color(0.50, 0.48, 0.40, 0.25), 1.0)

	# Entrance glow (warm gold)
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 1.8)
	node.draw_rect(Rect2(-door_w - 6.0, base_y - 3.0, door_w * 2.0 + 12.0, 5.0), Color(0.90, 0.75, 0.30, glow_pulse))

	# Building corner accents
	node.draw_line(Vector2(left, -h), Vector2(left, 0.0), Color(0.46, 0.48, 0.54, 0.4), 2.0)
	node.draw_line(Vector2(right, -h), Vector2(right, 0.0), Color(0.46, 0.48, 0.54, 0.4), 2.0)
