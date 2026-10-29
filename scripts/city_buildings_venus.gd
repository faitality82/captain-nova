class_name CityBuildingsVenus
extends RefCounted

# Venus — "Cloudport Terminus"
# Acid-resistant structures, pressurized domes, yellow-green haze, thick glass.
# Colors: acid yellow-green (0.65, 0.7, 0.2), sealed gray (0.45, 0.45, 0.4), bronze.

# ── 1. HANGAR — Pressurized dome with acid-resistant airlock tubes ─────────────

static func draw_hangar(node: Node2D, w: float, _h: float, t: float) -> void:
	var dome_r: float = w / 2.0
	var dome_cx := 0.0
	var dome_cy := 0.0  # dome base at ground level

	# Dark interior fill under dome (semi-circle polygon approximation)
	var dome_fill := PackedVector2Array()
	var seg_count := 32
	for i in (seg_count + 1):
		var ang: float = PI + float(i) * PI / float(seg_count)
		dome_fill.append(Vector2(dome_cx + cos(ang) * dome_r, dome_cy + sin(ang) * dome_r))
	node.draw_colored_polygon(dome_fill, Color(0.18, 0.2, 0.14))

	# Acid yellow-green tint panels (alternating wedges inside dome)
	for i in 8:
		var ang_start: float = PI + float(i) * PI / 8.0
		var ang_end: float = ang_start + PI / 16.0
		var wedge := PackedVector2Array()
		wedge.append(Vector2(dome_cx, dome_cy))
		for s in 6:
			var a: float = ang_start + float(s) * (ang_end - ang_start) / 5.0
			wedge.append(Vector2(dome_cx + cos(a) * dome_r * 0.95, dome_cy + sin(a) * dome_r * 0.95))
		node.draw_colored_polygon(wedge, Color(0.65, 0.7, 0.2, 0.12))

	# Ribbed dome structure (arc lines radiating from center)
	for i in 9:
		var ang: float = PI + float(i) * PI / 8.0
		var rx: float = dome_cx + cos(ang) * dome_r
		var ry: float = dome_cy + sin(ang) * dome_r
		node.draw_line(Vector2(dome_cx, dome_cy), Vector2(rx, ry), Color(0.55, 0.55, 0.4, 0.5), 2.0)

	# Horizontal rib rings at different radii
	for ring in 3:
		var ring_r: float = dome_r * (0.35 + float(ring) * 0.25)
		node.draw_arc(Vector2(dome_cx, dome_cy), ring_r, PI, TAU, 24, Color(0.5, 0.5, 0.38, 0.4), 1.5)

	# Dome outline
	node.draw_arc(Vector2(dome_cx, dome_cy), dome_r, PI, TAU, 48, Color(0.6, 0.6, 0.45, 0.8), 3.0)

	# Base plate (ground level reinforcement)
	node.draw_rect(Rect2(-w / 2.0, -4.0, w, 4.0), Color(0.45, 0.45, 0.4))
	node.draw_line(Vector2(-w / 2.0, 0.0), Vector2(w / 2.0, 0.0), Color(0.55, 0.55, 0.45, 0.6), 2.0)

	# Airlock tube extending from front (rectangular tube with ring segments)
	var tube_w := w * 0.18
	var tube_len := w * 0.22
	var tube_y_top := -tube_w * 0.6
	var tube_y_bot := tube_w * 0.1
	var tube_x_start: float = w / 2.0 - 10.0
	# Tube body
	node.draw_rect(Rect2(tube_x_start, tube_y_top, tube_len, tube_y_bot - tube_y_top), Color(0.4, 0.42, 0.35))
	# Ring segments on tube
	for i in 4:
		var rx: float = tube_x_start + 8.0 + float(i) * (tube_len - 16.0) / 3.0
		node.draw_line(Vector2(rx, tube_y_top), Vector2(rx, tube_y_bot), Color(0.55, 0.55, 0.42, 0.6), 2.0)
	# Tube outline
	node.draw_rect(Rect2(tube_x_start, tube_y_top, tube_len, tube_y_bot - tube_y_top), Color(0.55, 0.55, 0.42, 0.7), false, 1.5)

	# Warning stripes on airlock (yellow/black diagonal)
	var stripe_x: float = tube_x_start + tube_len - 12.0
	for i in 5:
		var sy: float = tube_y_top + float(i) * 5.0
		node.draw_line(Vector2(stripe_x, sy), Vector2(stripe_x + 10.0, sy + 5.0), Color(0.9, 0.8, 0.1, 0.7), 2.0)
	for i in 5:
		var sy: float = tube_y_top + float(i) * 5.0
		node.draw_line(Vector2(stripe_x + 5.0, sy), Vector2(stripe_x + 10.0, sy + 2.5), Color(0.15, 0.15, 0.1, 0.5), 2.0)

	# Pressurization vents on sides (small circles with animated steam puffs)
	for side_idx in 2:
		var side_val: float = -1.0 + float(side_idx) * 2.0
		var vent_x: float = side_val * (w / 2.0 - 20.0)
		var vent_y := -dome_r * 0.35
		node.draw_circle(Vector2(vent_x, vent_y), 5.0, Color(0.5, 0.5, 0.4))
		node.draw_circle(Vector2(vent_x, vent_y), 3.0, Color(0.3, 0.3, 0.25))
		# Animated steam puffs
		for p in 3:
			var puff_offset: float = fmod(t * 12.0 + float(p) * 8.0, 24.0)
			var puff_alpha: float = 0.4 - puff_offset / 60.0
			if puff_alpha > 0.0:
				var puff_x: float = vent_x + side_val * (8.0 + puff_offset)
				var puff_y: float = vent_y - puff_offset * 0.3
				node.draw_circle(Vector2(puff_x, puff_y), 3.0 + puff_offset * 0.15, Color(0.7, 0.75, 0.5, puff_alpha))

	# Pressure gauge indicators (3 small gauges near base)
	for i in 3:
		var gx: float = -40.0 + float(i) * 40.0
		var gy := -15.0
		node.draw_circle(Vector2(gx, gy), 6.0, Color(0.35, 0.35, 0.3))
		node.draw_arc(Vector2(gx, gy), 6.0, 0.0, TAU, 12, Color(0.55, 0.55, 0.4), 1.5)
		# Gauge fill (different levels)
		var fill_ang: float = PI * (0.3 + float(i) * 0.25)
		node.draw_arc(Vector2(gx, gy), 4.0, PI, PI + fill_ang, 8, Color(0.2, 0.8, 0.3, 0.7), 2.0)
		# Needle
		var needle_a: float = PI + fill_ang + sin(t * 1.5 + float(i)) * 0.1
		node.draw_line(Vector2(gx, gy), Vector2(gx + cos(needle_a) * 4.5, gy + sin(needle_a) * 4.5), Color(0.9, 0.2, 0.2, 0.8), 1.0)

	# Condensation drips on dome (animated droplets)
	for i in 6:
		var drip_ang: float = PI + 0.3 + float(i) * (PI - 0.6) / 5.0
		var drip_progress: float = fmod(t * 8.0 + float(i) * 11.3, dome_r * 0.8)
		var drip_r: float = dome_r - 3.0 - drip_progress * 0.1
		var dx: float = dome_cx + cos(drip_ang) * drip_r
		var base_y: float = dome_cy + sin(drip_ang) * drip_r
		var dy: float = base_y + drip_progress
		var drip_alpha: float = 0.5 - drip_progress / (dome_r * 1.6)
		if drip_alpha > 0.0:
			node.draw_circle(Vector2(dx, dy), 2.0, Color(0.5, 0.7, 0.3, drip_alpha))

	# Dome highlight (glass shine)
	node.draw_arc(Vector2(dome_cx - dome_r * 0.15, dome_cy), dome_r * 0.7, PI + 0.3, PI + 1.2, 16, Color(0.8, 0.85, 0.6, 0.15), 4.0)


# ── 2. MARKET — Sealed trading pod with display screens ────────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	var corner_r := 18.0

	# Outer wall (thick double outline effect — draw filled then slightly smaller)
	# Rounded rectangle approximation: main rect + corner circles
	var outer_col := Color(0.45, 0.45, 0.4)
	node.draw_rect(Rect2(-w / 2.0 + corner_r, -h, w - corner_r * 2.0, h), outer_col)
	node.draw_rect(Rect2(-w / 2.0, -h + corner_r, w, h - corner_r * 2.0), outer_col)
	# Corner fills
	node.draw_circle(Vector2(-w / 2.0 + corner_r, -h + corner_r), corner_r, outer_col)
	node.draw_circle(Vector2(w / 2.0 - corner_r, -h + corner_r), corner_r, outer_col)
	node.draw_circle(Vector2(-w / 2.0 + corner_r, -corner_r), corner_r, outer_col)
	node.draw_circle(Vector2(w / 2.0 - corner_r, -corner_r), corner_r, outer_col)

	# Inner wall (double-wall effect)
	var inset := 8.0
	var inner_col := Color(0.38, 0.38, 0.34)
	node.draw_rect(Rect2(-w / 2.0 + corner_r, -h + inset, w - corner_r * 2.0, h - inset * 2.0), inner_col)
	node.draw_rect(Rect2(-w / 2.0 + inset, -h + corner_r, w - inset * 2.0, h - corner_r * 2.0), inner_col)

	# Outer outline
	node.draw_line(Vector2(-w / 2.0 + corner_r, -h), Vector2(w / 2.0 - corner_r, -h), Color(0.55, 0.55, 0.45, 0.7), 2.0)
	node.draw_line(Vector2(-w / 2.0 + corner_r, 0.0), Vector2(w / 2.0 - corner_r, 0.0), Color(0.55, 0.55, 0.45, 0.7), 2.0)
	node.draw_line(Vector2(-w / 2.0, -h + corner_r), Vector2(-w / 2.0, -corner_r), Color(0.55, 0.55, 0.45, 0.7), 2.0)
	node.draw_line(Vector2(w / 2.0, -h + corner_r), Vector2(w / 2.0, -corner_r), Color(0.55, 0.55, 0.45, 0.7), 2.0)
	# Corner arcs for outline
	node.draw_arc(Vector2(-w / 2.0 + corner_r, -h + corner_r), corner_r, PI, PI * 1.5, 8, Color(0.55, 0.55, 0.45, 0.7), 2.0)
	node.draw_arc(Vector2(w / 2.0 - corner_r, -h + corner_r), corner_r, PI * 1.5, TAU, 8, Color(0.55, 0.55, 0.45, 0.7), 2.0)
	node.draw_arc(Vector2(-w / 2.0 + corner_r, -corner_r), corner_r, PI * 0.5, PI, 8, Color(0.55, 0.55, 0.45, 0.7), 2.0)
	node.draw_arc(Vector2(w / 2.0 - corner_r, -corner_r), corner_r, 0.0, PI * 0.5, 8, Color(0.55, 0.55, 0.45, 0.7), 2.0)

	# Thick viewport windows with display screens (3 windows)
	var win_w := w * 0.2
	var win_h := h * 0.28
	var win_gap: float = (w - 3.0 * win_w) / 4.0
	for i in 3:
		var wx: float = -w / 2.0 + win_gap + float(i) * (win_w + win_gap)
		var wy: float = -h * 0.72
		# Window recess (dark)
		node.draw_rect(Rect2(wx - 3.0, wy - 3.0, win_w + 6.0, win_h + 6.0), Color(0.25, 0.25, 0.22))
		# Thick glass border
		node.draw_rect(Rect2(wx - 3.0, wy - 3.0, win_w + 6.0, win_h + 6.0), Color(0.6, 0.6, 0.5, 0.6), false, 3.0)
		# Glass fill
		node.draw_rect(Rect2(wx, wy, win_w, win_h), Color(0.4, 0.5, 0.45, 0.35))
		# Glass shine (lighter inner rect at top)
		node.draw_rect(Rect2(wx + 3.0, wy + 2.0, win_w - 6.0, win_h * 0.2), Color(0.7, 0.8, 0.7, 0.15))
		# Display screen inside window (flickering colored rect)
		var screen_flicker: float = 0.5 + 0.3 * sin(t * 4.0 + float(i) * 2.1)
		var screen_r: float = 0.3 + 0.4 * sin(t * 1.2 + float(i) * 3.0)
		var screen_g: float = 0.5 + 0.3 * sin(t * 1.8 + float(i) * 1.7)
		var screen_b: float = 0.2 + 0.3 * sin(t * 0.9 + float(i) * 4.2)
		node.draw_rect(Rect2(wx + 6.0, wy + win_h * 0.3, win_w - 12.0, win_h * 0.55), Color(screen_r, screen_g, screen_b, screen_flicker * 0.5))
		# Screen scan line
		var scan_y: float = wy + win_h * 0.3 + fmod(t * 20.0, win_h * 0.55)
		node.draw_line(Vector2(wx + 6.0, scan_y), Vector2(wx + win_w - 6.0, scan_y), Color(1.0, 1.0, 1.0, 0.1), 1.0)

	# Sealed entry hatch with wheel handle (right side)
	var hatch_x := w * 0.05
	var hatch_y := -h * 0.32
	var hatch_r := h * 0.13
	# Hatch recess
	node.draw_circle(Vector2(hatch_x, hatch_y), hatch_r + 4.0, Color(0.3, 0.3, 0.26))
	# Hatch door
	node.draw_circle(Vector2(hatch_x, hatch_y), hatch_r, Color(0.5, 0.5, 0.42))
	# Hatch rim
	node.draw_arc(Vector2(hatch_x, hatch_y), hatch_r, 0.0, TAU, 24, Color(0.6, 0.58, 0.45, 0.8), 2.5)
	# Wheel handle (cross lines rotating slowly)
	var wheel_ang: float = t * 0.3
	for spoke in 4:
		var sa: float = wheel_ang + float(spoke) * PI / 2.0
		var sx: float = hatch_x + cos(sa) * hatch_r * 0.7
		var sy: float = hatch_y + sin(sa) * hatch_r * 0.7
		node.draw_line(Vector2(hatch_x, hatch_y), Vector2(sx, sy), Color(0.65, 0.6, 0.45, 0.7), 2.0)
	# Center bolt
	node.draw_circle(Vector2(hatch_x, hatch_y), 3.0, Color(0.6, 0.55, 0.4))

	# External pipes and conduits along walls
	# Top horizontal pipe
	node.draw_line(Vector2(-w / 2.0 + 15.0, -h + 20.0), Vector2(w / 2.0 - 15.0, -h + 20.0), Color(0.5, 0.5, 0.4, 0.6), 3.0)
	# Vertical pipe segments (joints)
	for i in 3:
		var px: float = -w / 2.0 + 15.0 + float(i) * (w - 30.0) / 2.0
		node.draw_line(Vector2(px, -h + 18.0), Vector2(px, -h + 35.0), Color(0.5, 0.5, 0.4, 0.6), 3.0)
		# Joint circles
		node.draw_circle(Vector2(px, -h + 20.0), 4.0, Color(0.55, 0.55, 0.42, 0.5))
	# Bottom horizontal pipe
	node.draw_line(Vector2(-w / 2.0 + 15.0, -18.0), Vector2(w / 2.0 - 15.0, -18.0), Color(0.5, 0.5, 0.4, 0.5), 2.5)

	# Acid warning markings on exterior (yellow-green triangles)
	for i in 2:
		var ax: float = -w / 2.0 + 20.0 + float(i) * (w - 40.0)
		var ay := -h * 0.5
		var tri := PackedVector2Array([
			Vector2(ax, ay - 8.0),
			Vector2(ax - 7.0, ay + 5.0),
			Vector2(ax + 7.0, ay + 5.0),
		])
		node.draw_colored_polygon(tri, Color(0.9, 0.8, 0.1, 0.6))
		node.draw_circle(Vector2(ax, ay), 3.0, Color(0.15, 0.15, 0.1, 0.7))

	# Small antenna array on roof
	var ant_base_y := -h - 2.0
	for i in 3:
		var ax: float = -15.0 + float(i) * 15.0
		var ant_h: float = 12.0 + float(i % 2) * 8.0
		node.draw_line(Vector2(ax, ant_base_y + corner_r), Vector2(ax, ant_base_y + corner_r - ant_h), Color(0.55, 0.55, 0.45, 0.6), 1.5)
		# Antenna tip
		node.draw_circle(Vector2(ax, ant_base_y + corner_r - ant_h), 2.0, Color(0.65, 0.7, 0.2, 0.7))
	# Cross bar connecting antennas
	node.draw_line(Vector2(-15.0, ant_base_y + corner_r - 12.0), Vector2(15.0, ant_base_y + corner_r - 12.0), Color(0.55, 0.55, 0.45, 0.4), 1.0)

	# Status lights beside hatch (3 colored dots)
	for i in 3:
		var ly: float = hatch_y - hatch_r - 12.0 + float(i) * 10.0
		var lx: float = hatch_x + hatch_r + 10.0
		var light_colors: Array = [Color(0.2, 0.9, 0.2, 0.8), Color(0.9, 0.7, 0.1, 0.6), Color(0.9, 0.2, 0.2, 0.4)]
		var blink_rate: float = 0.6 + 0.4 * sin(t * (2.0 + float(i) * 0.5))
		node.draw_circle(Vector2(lx, ly), 3.0, Color(0.25, 0.25, 0.2))
		node.draw_circle(Vector2(lx, ly), 2.0, Color(light_colors[i].r, light_colors[i].g, light_colors[i].b, blink_rate))


# ── 3. BAR — Underground speakeasy (stairs down, neon from below) ──────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	# Ground level reference: y=0 is ground. The bar is underground.
	# Split height: visible surface structure + underground speakeasy
	var entrance_h := h * 0.4  # surface structure above ground
	var underground_h := h * 0.6

	# Ground surface line
	node.draw_line(Vector2(-w / 2.0, 0.0), Vector2(w / 2.0, 0.0), Color(0.45, 0.42, 0.35, 0.6), 2.0)

	# Surface entrance structure (small roof over opening)
	var ent_w := w * 0.5
	var ent_h := entrance_h
	# Entrance walls
	node.draw_rect(Rect2(-ent_w / 2.0, -ent_h, ent_w, ent_h), Color(0.4, 0.4, 0.35))
	# Entrance roof (slightly wider, angled)
	var roof_pts := PackedVector2Array([
		Vector2(-ent_w / 2.0 - 12.0, -ent_h),
		Vector2(0.0, -ent_h - 15.0),
		Vector2(ent_w / 2.0 + 12.0, -ent_h),
	])
	node.draw_colored_polygon(roof_pts, Color(0.5, 0.48, 0.38))
	node.draw_polyline(roof_pts, Color(0.6, 0.58, 0.45, 0.7), 2.0)

	# Acid rain gutter/drip system above entrance
	node.draw_line(Vector2(-ent_w / 2.0 - 12.0, -ent_h), Vector2(-ent_w / 2.0 - 18.0, -ent_h + 8.0), Color(0.5, 0.5, 0.4, 0.6), 2.5)
	node.draw_line(Vector2(ent_w / 2.0 + 12.0, -ent_h), Vector2(ent_w / 2.0 + 18.0, -ent_h + 8.0), Color(0.5, 0.5, 0.4, 0.6), 2.5)
	# Animated acid drips from gutter
	for i in 3:
		var gutter_side: float = -1.0 + float(i % 2) * 2.0
		var gutter_x: float = gutter_side * (ent_w / 2.0 + 18.0)
		var drip_progress: float = fmod(t * 15.0 + float(i) * 9.0, 30.0)
		var drip_alpha: float = 0.6 - drip_progress / 50.0
		if drip_alpha > 0.0:
			node.draw_circle(Vector2(gutter_x, -ent_h + 8.0 + drip_progress), 2.0, Color(0.6, 0.75, 0.25, drip_alpha))

	# Small neon sign above entrance
	var sign_w := ent_w * 0.6
	var sign_h := 12.0
	var sign_x := -sign_w / 2.0
	var sign_y := -ent_h + 5.0
	var neon_pulse: float = 0.6 + 0.3 * sin(t * 2.5)
	# Sign glow halo
	node.draw_rect(Rect2(sign_x - 4.0, sign_y - 3.0, sign_w + 8.0, sign_h + 6.0), Color(0.8, 0.2, 0.5, neon_pulse * 0.15))
	# Sign background
	node.draw_rect(Rect2(sign_x, sign_y, sign_w, sign_h), Color(0.15, 0.12, 0.1))
	# Neon text (just colored lines representing text)
	node.draw_line(Vector2(sign_x + 5.0, sign_y + 6.0), Vector2(sign_x + sign_w - 5.0, sign_y + 6.0), Color(0.9, 0.2, 0.5, neon_pulse), 2.0)
	node.draw_line(Vector2(sign_x + 8.0, sign_y + 3.0), Vector2(sign_x + sign_w * 0.5, sign_y + 3.0), Color(0.9, 0.2, 0.5, neon_pulse * 0.7), 1.0)
	# Sign border
	node.draw_rect(Rect2(sign_x, sign_y, sign_w, sign_h), Color(0.7, 0.15, 0.4, neon_pulse * 0.5), false, 1.5)

	# Staircase opening in ground
	var stair_w := ent_w - 8.0
	var stair_depth := underground_h * 0.7

	# Underground cavity (dark rectangle below ground)
	node.draw_rect(Rect2(-stair_w / 2.0 - 10.0, 0.0, stair_w + 20.0, underground_h), Color(0.12, 0.11, 0.08))

	# Staircase descending down (visible steps getting darker)
	var step_count := 12
	var step_h: float = stair_depth / float(step_count)
	var step_indent := 3.0  # each step indents slightly
	for i in step_count:
		var sy: float = float(i) * step_h
		var brightness: float = 0.35 - float(i) * 0.02
		var sx: float = -stair_w / 2.0 + float(i) * step_indent
		var sw: float = stair_w - float(i) * step_indent * 2.0
		# Step top surface
		node.draw_rect(Rect2(sx, sy, sw, step_h * 0.4), Color(brightness + 0.05, brightness + 0.03, brightness, 0.9))
		# Step front face
		node.draw_rect(Rect2(sx, sy + step_h * 0.4, sw, step_h * 0.6), Color(brightness - 0.05, brightness - 0.05, brightness - 0.03, 0.9))
		# Step edge highlight
		node.draw_line(Vector2(sx, sy), Vector2(sx + sw, sy), Color(0.5, 0.5, 0.4, 0.3), 1.0)

	# Railing along stairs (metal bars on both sides)
	for side_idx in 2:
		var rail_side: float = -1.0 + float(side_idx) * 2.0
		var rail_x_top: float = rail_side * (stair_w / 2.0 + 2.0)
		var rail_x_bot: float = rail_side * (stair_w / 2.0 + 2.0 - float(step_count) * step_indent)
		# Top rail
		node.draw_line(Vector2(rail_x_top, -2.0), Vector2(rail_x_bot, stair_depth - step_h), Color(0.5, 0.48, 0.38, 0.7), 2.0)
		# Vertical posts
		for i in 5:
			var frac: float = float(i) / 4.0
			var post_x: float = rail_x_top + (rail_x_bot - rail_x_top) * frac
			var post_y: float = frac * (stair_depth - step_h)
			node.draw_line(Vector2(post_x, post_y), Vector2(post_x, post_y - 15.0), Color(0.5, 0.48, 0.38, 0.5), 1.5)

	# Neon glow emanating from below (colored light wash, animated pulse)
	var below_pulse: float = 0.4 + 0.3 * sin(t * 1.8)
	# Main glow
	node.draw_rect(Rect2(-stair_w / 2.0 - 5.0, stair_depth - 20.0, stair_w + 10.0, 40.0), Color(0.8, 0.2, 0.5, below_pulse * 0.2))
	# Secondary glow (wider, softer)
	node.draw_rect(Rect2(-stair_w / 2.0 - 15.0, stair_depth - 10.0, stair_w + 30.0, 30.0), Color(0.6, 0.1, 0.7, below_pulse * 0.1))
	# Glow spilling up onto steps
	for i in 4:
		var glow_y: float = stair_depth - float(i) * step_h * 2.0
		var glow_alpha: float = below_pulse * 0.15 * (1.0 - float(i) * 0.25)
		node.draw_rect(Rect2(-stair_w / 2.0, glow_y - step_h, stair_w, step_h), Color(0.8, 0.2, 0.5, glow_alpha))

	# Bouncer silhouette near entrance (simple dark figure)
	var bouncer_x: float = ent_w / 2.0 - 5.0
	var bouncer_y := -3.0
	# Body
	node.draw_rect(Rect2(bouncer_x - 6.0, bouncer_y - 30.0, 12.0, 25.0), Color(0.12, 0.12, 0.1, 0.8))
	# Head
	node.draw_circle(Vector2(bouncer_x, bouncer_y - 35.0), 6.0, Color(0.12, 0.12, 0.1, 0.8))
	# Legs
	node.draw_rect(Rect2(bouncer_x - 5.0, bouncer_y - 5.0, 4.0, 8.0), Color(0.12, 0.12, 0.1, 0.8))
	node.draw_rect(Rect2(bouncer_x + 1.0, bouncer_y - 5.0, 4.0, 8.0), Color(0.12, 0.12, 0.1, 0.8))
	# Bouncer's glowing eyes
	var eye_glow: float = 0.5 + 0.3 * sin(t * 1.0)
	node.draw_circle(Vector2(bouncer_x - 2.0, bouncer_y - 36.0), 1.0, Color(0.9, 0.3, 0.3, eye_glow))
	node.draw_circle(Vector2(bouncer_x + 2.0, bouncer_y - 36.0), 1.0, Color(0.9, 0.3, 0.3, eye_glow))

	# Ground debris / acid-stained area around entrance
	for i in 5:
		var debris_x: float = -w / 2.0 + 15.0 + float(i) * (w - 30.0) / 4.0
		node.draw_circle(Vector2(debris_x, -1.0), 3.0 + float(i % 3) * 1.5, Color(0.5, 0.6, 0.2, 0.15))

	# Side walls of underground (visible edges)
	node.draw_line(Vector2(-stair_w / 2.0 - 10.0, 0.0), Vector2(-stair_w / 2.0 - 10.0, underground_h), Color(0.3, 0.28, 0.22, 0.6), 2.0)
	node.draw_line(Vector2(stair_w / 2.0 + 10.0, 0.0), Vector2(stair_w / 2.0 + 10.0, underground_h), Color(0.3, 0.28, 0.22, 0.6), 2.0)


# ── 4. GARAGE — Sealed repair bay with mechanical arms ─────────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	# Reinforced rectangular structure
	var wall_col := Color(0.42, 0.42, 0.36)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), wall_col)

	# Heavy visible rivets along edges
	var rivet_col := Color(0.55, 0.55, 0.45, 0.7)
	var rivet_spacing := 18.0
	# Top edge rivets
	var rivet_count_top := int(w / rivet_spacing)
	for i in rivet_count_top:
		var rx: float = -w / 2.0 + 8.0 + float(i) * rivet_spacing
		node.draw_circle(Vector2(rx, -h + 6.0), 2.5, rivet_col)
		node.draw_circle(Vector2(rx, -6.0), 2.5, rivet_col)
	# Side edge rivets
	var rivet_count_side := int(h / rivet_spacing)
	for i in rivet_count_side:
		var ry: float = -h + 8.0 + float(i) * rivet_spacing
		node.draw_circle(Vector2(-w / 2.0 + 6.0, ry), 2.5, rivet_col)
		node.draw_circle(Vector2(w / 2.0 - 6.0, ry), 2.5, rivet_col)

	# Wall panel lines (horizontal)
	for i in 4:
		var py: float = -h + float(i + 1) * h / 5.0
		node.draw_line(Vector2(-w / 2.0 + 10.0, py), Vector2(w / 2.0 - 10.0, py), Color(0.35, 0.35, 0.3, 0.3), 1.0)

	# Large sealed bay door (center, horizontal segments)
	var door_w: float = w * 0.55
	var door_h: float = h * 0.6
	var door_x: float = -door_w / 2.0
	var door_y: float = -door_h
	node.draw_rect(Rect2(door_x, door_y, door_w, door_h), Color(0.32, 0.32, 0.28))
	# Horizontal segment lines
	var door_segs := 6
	for i in door_segs:
		var seg_y: float = door_y + float(i + 1) * door_h / float(door_segs + 1)
		node.draw_line(Vector2(door_x + 4.0, seg_y), Vector2(door_x + door_w - 4.0, seg_y), Color(0.22, 0.22, 0.2, 0.6), 1.5)
	# Door frame
	node.draw_rect(Rect2(door_x, door_y, door_w, door_h), Color(0.55, 0.52, 0.42, 0.7), false, 3.0)

	# Hazmat symbol on door (triangle with circle)
	var hazmat_cx := 0.0
	var hazmat_cy: float = door_y + door_h * 0.35
	var haz_tri := PackedVector2Array([
		Vector2(hazmat_cx, hazmat_cy - 18.0),
		Vector2(hazmat_cx - 16.0, hazmat_cy + 10.0),
		Vector2(hazmat_cx + 16.0, hazmat_cy + 10.0),
	])
	node.draw_colored_polygon(haz_tri, Color(0.9, 0.75, 0.1, 0.6))
	node.draw_polyline(PackedVector2Array([
		Vector2(hazmat_cx, hazmat_cy - 18.0),
		Vector2(hazmat_cx - 16.0, hazmat_cy + 10.0),
		Vector2(hazmat_cx + 16.0, hazmat_cy + 10.0),
		Vector2(hazmat_cx, hazmat_cy - 18.0),
	]), Color(0.1, 0.1, 0.05, 0.8), 2.0)
	node.draw_circle(Vector2(hazmat_cx, hazmat_cy - 2.0), 6.0, Color(0.1, 0.1, 0.05, 0.7))
	node.draw_arc(Vector2(hazmat_cx, hazmat_cy - 2.0), 6.0, 0.0, TAU, 12, Color(0.9, 0.75, 0.1, 0.8), 1.5)

	# Mechanical arms extending from walls (jointed arm shapes, animated)
	for side_idx in 2:
		var arm_side: float = -1.0 + float(side_idx) * 2.0
		var arm_base_x: float = arm_side * (w / 2.0 - 15.0)
		var arm_base_y: float = -h * 0.55
		# Shoulder joint
		node.draw_circle(Vector2(arm_base_x, arm_base_y), 6.0, Color(0.5, 0.5, 0.4))
		node.draw_arc(Vector2(arm_base_x, arm_base_y), 6.0, 0.0, TAU, 12, Color(0.6, 0.6, 0.48, 0.7), 1.5)
		# Upper arm — animated swing
		var arm_ang: float = sin(t * 0.8 + float(side_idx) * PI) * 0.4
		var upper_len := 35.0
		var elbow_x: float = arm_base_x + cos(arm_ang - arm_side * 0.5) * upper_len * (-arm_side)
		var elbow_y: float = arm_base_y + sin(arm_ang - 0.3) * upper_len
		node.draw_line(Vector2(arm_base_x, arm_base_y), Vector2(elbow_x, elbow_y), Color(0.5, 0.48, 0.38), 4.0)
		# Elbow joint
		node.draw_circle(Vector2(elbow_x, elbow_y), 4.5, Color(0.5, 0.5, 0.4))
		# Lower arm (forearm)
		var forearm_ang: float = arm_ang * 0.7 + sin(t * 1.2 + float(side_idx) * PI) * 0.3
		var forearm_len := 30.0
		var hand_x: float = elbow_x + cos(forearm_ang) * forearm_len * (-arm_side)
		var hand_y: float = elbow_y + sin(forearm_ang + 0.5) * forearm_len * 0.5
		node.draw_line(Vector2(elbow_x, elbow_y), Vector2(hand_x, hand_y), Color(0.48, 0.46, 0.36), 3.0)
		# Claw/tool at end
		node.draw_circle(Vector2(hand_x, hand_y), 5.0, Color(0.6, 0.55, 0.35))
		# Claw prongs
		for prong in 3:
			var pa: float = forearm_ang + float(prong - 1) * 0.5
			var px: float = hand_x + cos(pa) * 8.0 * (-arm_side)
			var py: float = hand_y + sin(pa) * 8.0
			node.draw_line(Vector2(hand_x, hand_y), Vector2(px, py), Color(0.55, 0.5, 0.35, 0.7), 2.0)

	# Acid-proof coating stripe along base (yellow-green band)
	node.draw_rect(Rect2(-w / 2.0, -14.0, w, 14.0), Color(0.65, 0.7, 0.2, 0.4))
	node.draw_line(Vector2(-w / 2.0, -14.0), Vector2(w / 2.0, -14.0), Color(0.65, 0.7, 0.2, 0.6), 1.5)

	# Exhaust vents on roof (rectangular protrusions with steam)
	for i in 2:
		var vx: float = -w * 0.25 + float(i) * w * 0.5
		var vent_w := 20.0
		var vent_h := 12.0
		# Vent housing
		node.draw_rect(Rect2(vx - vent_w / 2.0, -h - vent_h, vent_w, vent_h), Color(0.4, 0.4, 0.35))
		node.draw_rect(Rect2(vx - vent_w / 2.0, -h - vent_h, vent_w, vent_h), Color(0.52, 0.52, 0.42, 0.6), false, 1.5)
		# Steam animation
		for s in 4:
			var steam_y: float = -h - vent_h - fmod(t * 10.0 + float(s) * 6.0 + float(i) * 3.0, 25.0)
			var steam_alpha: float = 0.35 - fmod(t * 10.0 + float(s) * 6.0 + float(i) * 3.0, 25.0) / 70.0
			if steam_alpha > 0.0:
				var drift: float = sin(t * 2.0 + float(s)) * 4.0
				node.draw_circle(Vector2(vx + drift, steam_y), 4.0 + float(s) * 1.5, Color(0.6, 0.65, 0.5, steam_alpha))

	# Tool shapes visible through small reinforced window (right of door)
	var tool_win_x: float = door_x + door_w + 12.0
	var tool_win_y: float = -h * 0.5
	var tool_win_w := 25.0
	var tool_win_h := 20.0
	node.draw_rect(Rect2(tool_win_x, tool_win_y, tool_win_w, tool_win_h), Color(0.2, 0.22, 0.18))
	node.draw_rect(Rect2(tool_win_x, tool_win_y, tool_win_w, tool_win_h), Color(0.55, 0.55, 0.42, 0.6), false, 2.5)
	# Tool silhouettes inside
	node.draw_line(Vector2(tool_win_x + 5.0, tool_win_y + 5.0), Vector2(tool_win_x + 5.0, tool_win_y + 15.0), Color(0.3, 0.3, 0.25, 0.5), 2.0)
	node.draw_line(Vector2(tool_win_x + 10.0, tool_win_y + 3.0), Vector2(tool_win_x + 10.0, tool_win_y + 17.0), Color(0.3, 0.3, 0.25, 0.5), 1.5)
	node.draw_line(Vector2(tool_win_x + 15.0, tool_win_y + 7.0), Vector2(tool_win_x + 20.0, tool_win_y + 7.0), Color(0.3, 0.3, 0.25, 0.5), 2.0)

	# External power conduit running to building
	node.draw_line(Vector2(-w / 2.0 - 20.0, -h * 0.4), Vector2(-w / 2.0, -h * 0.4), Color(0.5, 0.5, 0.38, 0.5), 3.0)
	node.draw_line(Vector2(-w / 2.0 - 20.0, -h * 0.4), Vector2(-w / 2.0 - 20.0, 0.0), Color(0.5, 0.5, 0.38, 0.5), 3.0)
	# Conduit junction box
	node.draw_rect(Rect2(-w / 2.0 - 8.0, -h * 0.4 - 5.0, 10.0, 10.0), Color(0.48, 0.48, 0.38))
	# Spark animation at junction
	var spark_alpha: float = 0.0
	var spark_phase: float = fmod(t * 3.0, 4.0)
	if spark_phase < 0.3:
		spark_alpha = 0.8
	node.draw_circle(Vector2(-w / 2.0 - 3.0, -h * 0.4), 3.0, Color(0.9, 0.85, 0.3, spark_alpha))

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.55, 0.52, 0.4, 0.6), 2.5)


# ── 5. UNIQUE — Acid Gardens bio-dome ──────────────────────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	var dome_r: float = w / 2.0
	var dome_cy := 0.0  # dome base at ground

	# Entry vestibule at base (small rectangular airlock, drawn first so dome overlaps)
	var vest_w := w * 0.18
	var vest_h := h * 0.12
	node.draw_rect(Rect2(-vest_w / 2.0, -vest_h, vest_w, vest_h), Color(0.42, 0.42, 0.36))
	node.draw_rect(Rect2(-vest_w / 2.0, -vest_h, vest_w, vest_h), Color(0.55, 0.55, 0.42, 0.6), false, 2.0)
	# Airlock door lines
	node.draw_line(Vector2(0.0, -vest_h), Vector2(0.0, 0.0), Color(0.35, 0.35, 0.28, 0.5), 1.5)
	# Airlock wheel
	node.draw_circle(Vector2(0.0, -vest_h * 0.5), 4.0, Color(0.5, 0.5, 0.4))
	node.draw_arc(Vector2(0.0, -vest_h * 0.5), 4.0, 0.0, TAU, 8, Color(0.6, 0.6, 0.48, 0.6), 1.0)

	# Glass dome (semi-circle, translucent fill)
	var dome_fill := PackedVector2Array()
	var dome_segs := 40
	for i in (dome_segs + 1):
		var ang: float = PI + float(i) * PI / float(dome_segs)
		dome_fill.append(Vector2(cos(ang) * dome_r, dome_cy + sin(ang) * dome_r))
	# Bioluminescent glow base inside (soft animated color)
	var bio_pulse: float = 0.3 + 0.15 * sin(t * 1.2)
	node.draw_colored_polygon(dome_fill, Color(0.15, 0.25, 0.12, 0.7))
	# Inner glow layer
	var inner_fill := PackedVector2Array()
	var inner_r: float = dome_r * 0.85
	for i in (dome_segs + 1):
		var ang: float = PI + float(i) * PI / float(dome_segs)
		inner_fill.append(Vector2(cos(ang) * inner_r, dome_cy + sin(ang) * inner_r))
	node.draw_colored_polygon(inner_fill, Color(0.1 + bio_pulse * 0.15, 0.35 + bio_pulse * 0.1, 0.15, 0.3))

	# Alien plants pressing against glass (organic blob shapes, green/purple)
	# Plant 1 — tall central fern-like
	var plant1_base_x := 0.0
	var plant1_base_y := -5.0
	for frond in 5:
		var frond_ang: float = PI * 0.5 + (float(frond) - 2.0) * 0.3
		var frond_sway: float = sin(t * 0.7 + float(frond) * 1.3) * 0.08
		var frond_len: float = dome_r * 0.6 + float(frond % 2) * dome_r * 0.15
		var tip_x: float = plant1_base_x + cos(frond_ang + frond_sway) * frond_len * 0.3
		var tip_y: float = plant1_base_y + sin(frond_ang + frond_sway) * (-frond_len)
		node.draw_line(Vector2(plant1_base_x, plant1_base_y), Vector2(tip_x, tip_y), Color(0.2, 0.55, 0.15, 0.6), 3.0)
		# Leaf blobs along frond
		for leaf in 3:
			var lfrac: float = 0.3 + float(leaf) * 0.25
			var lx: float = plant1_base_x + (tip_x - plant1_base_x) * lfrac
			var ly: float = plant1_base_y + (tip_y - plant1_base_y) * lfrac
			node.draw_circle(Vector2(lx, ly), 5.0 + float(leaf) * 2.0, Color(0.25, 0.6, 0.2, 0.35))

	# Plant 2 — purple bulbous thing on the left
	var p2x: float = -dome_r * 0.4
	var p2y: float = -dome_r * 0.3
	node.draw_circle(Vector2(p2x, p2y), 18.0, Color(0.4, 0.15, 0.5, 0.4))
	node.draw_circle(Vector2(p2x - 8.0, p2y - 12.0), 12.0, Color(0.45, 0.18, 0.55, 0.35))
	node.draw_circle(Vector2(p2x + 10.0, p2y - 6.0), 10.0, Color(0.35, 0.12, 0.45, 0.35))
	# Bioluminescent spots on purple plant
	for spot in 4:
		var spot_ang: float = float(spot) * TAU / 4.0 + t * 0.3
		var spot_r: float = 12.0
		var spot_x: float = p2x + cos(spot_ang) * spot_r
		var spot_y: float = p2y + sin(spot_ang) * spot_r * 0.6
		var spot_glow: float = 0.4 + 0.3 * sin(t * 2.0 + float(spot) * 1.5)
		node.draw_circle(Vector2(spot_x, spot_y), 3.0, Color(0.7, 0.3, 0.9, spot_glow))

	# Plant 3 — green vine mass on the right
	var p3x: float = dome_r * 0.35
	var p3y := -10.0
	for vine in 4:
		var vine_sway: float = sin(t * 0.5 + float(vine) * 2.0) * 5.0
		var vine_end_x: float = p3x + float(vine - 2) * 10.0 + vine_sway
		var vine_end_y: float = p3y - dome_r * 0.5 - float(vine) * 15.0
		node.draw_line(Vector2(p3x, p3y), Vector2(vine_end_x, vine_end_y), Color(0.15, 0.5, 0.1, 0.5), 2.5)
		# Vine blob endpoints
		node.draw_circle(Vector2(vine_end_x, vine_end_y), 7.0, Color(0.2, 0.55, 0.15, 0.3))

	# Structural support ribs (lines from base to top of dome)
	for i in 7:
		var rib_ang: float = PI + float(i) * PI / 6.0
		var rx: float = cos(rib_ang) * dome_r
		var ry: float = dome_cy + sin(rib_ang) * dome_r
		node.draw_line(Vector2(cos(rib_ang) * dome_r * 0.05, dome_cy), Vector2(rx, ry), Color(0.5, 0.5, 0.42, 0.35), 2.5)

	# Horizontal support ring at mid-height
	node.draw_arc(Vector2(0.0, dome_cy), dome_r * 0.7, PI, TAU, 24, Color(0.5, 0.5, 0.42, 0.3), 2.0)

	# Glass dome outline (translucent)
	node.draw_arc(Vector2(0.0, dome_cy), dome_r, PI, TAU, 48, Color(0.6, 0.7, 0.55, 0.6), 3.5)
	# Secondary glass highlight
	node.draw_arc(Vector2(-dome_r * 0.1, dome_cy), dome_r * 0.75, PI + 0.2, PI + 1.3, 16, Color(0.8, 0.9, 0.7, 0.12), 5.0)

	# Dripping condensation on dome exterior (animated drops rolling down curve)
	for i in 8:
		var drip_ang: float = PI + 0.2 + float(i) * (PI - 0.4) / 7.0
		var drip_time: float = fmod(t * 6.0 + float(i) * 7.7, dome_r)
		var drip_frac: float = drip_time / dome_r
		# Drop slides down the dome curve
		var drop_ang: float = drip_ang + (PI * 0.5 - drip_ang) * drip_frac * 0.3
		var drop_r: float = dome_r + 2.0
		var drop_x: float = cos(drop_ang) * drop_r
		var base_drop_y: float = dome_cy + sin(drop_ang) * drop_r
		var drop_y: float = base_drop_y + drip_time * 0.5
		var drip_alpha: float = 0.5 - drip_frac * 0.5
		if drip_alpha > 0.05:
			node.draw_circle(Vector2(drop_x, drop_y), 2.0, Color(0.5, 0.7, 0.3, drip_alpha))
			# Small trail
			node.draw_circle(Vector2(drop_x, drop_y - 3.0), 1.0, Color(0.5, 0.7, 0.3, drip_alpha * 0.5))

	# Misting system at top (small particle dots)
	for i in 10:
		var mist_ang: float = PI + 0.5 + float(i) * (PI - 1.0) / 9.0
		var mist_r: float = dome_r * (0.6 + fmod(t * 3.0 + float(i) * 4.7, 10.0) / 25.0)
		var mist_x: float = cos(mist_ang) * mist_r
		var mist_base_y: float = dome_cy + sin(mist_ang) * mist_r
		var mist_drift: float = fmod(t * 5.0 + float(i) * 3.3, 15.0)
		var mist_alpha: float = 0.3 - mist_drift / 50.0
		if mist_alpha > 0.0:
			node.draw_circle(Vector2(mist_x, mist_base_y - mist_drift * 0.2), 2.0, Color(0.6, 0.8, 0.5, mist_alpha))

	# Alien plant tendrils creeping out of seams (small curved lines at dome base edges)
	for i in 5:
		var tendril_x: float = -dome_r + 15.0 + float(i) * (dome_r * 2.0 - 30.0) / 4.0
		var tendril_sway: float = sin(t * 0.6 + float(i) * 1.8) * 4.0
		# Tendril curving outward from base
		var tendril_end_x: float = tendril_x + 8.0 * (1.0 if i > 2 else -1.0) + tendril_sway
		var tendril_end_y: float = 6.0 + float(i % 3) * 3.0
		node.draw_line(Vector2(tendril_x, 0.0), Vector2(tendril_end_x, tendril_end_y), Color(0.2, 0.55, 0.15, 0.45), 2.0)
		# Tiny leaf at tip
		node.draw_circle(Vector2(tendril_end_x, tendril_end_y), 2.5, Color(0.25, 0.6, 0.2, 0.4))

	# Warning sign near entrance
	var warn_x: float = vest_w / 2.0 + 18.0
	var warn_y: float = -vest_h * 0.6
	# Sign post
	node.draw_line(Vector2(warn_x, 0.0), Vector2(warn_x, warn_y - 10.0), Color(0.5, 0.5, 0.4, 0.5), 2.0)
	# Triangle warning
	var warn_tri := PackedVector2Array([
		Vector2(warn_x, warn_y - 22.0),
		Vector2(warn_x - 10.0, warn_y - 5.0),
		Vector2(warn_x + 10.0, warn_y - 5.0),
	])
	node.draw_colored_polygon(warn_tri, Color(0.9, 0.8, 0.1, 0.7))
	node.draw_polyline(PackedVector2Array([
		Vector2(warn_x, warn_y - 22.0),
		Vector2(warn_x - 10.0, warn_y - 5.0),
		Vector2(warn_x + 10.0, warn_y - 5.0),
		Vector2(warn_x, warn_y - 22.0),
	]), Color(0.1, 0.1, 0.05, 0.8), 1.5)
	# Exclamation mark
	node.draw_line(Vector2(warn_x, warn_y - 18.0), Vector2(warn_x, warn_y - 11.0), Color(0.1, 0.1, 0.05, 0.8), 2.0)
	node.draw_circle(Vector2(warn_x, warn_y - 8.0), 1.5, Color(0.1, 0.1, 0.05, 0.8))

	# Base plate
	node.draw_line(Vector2(-w / 2.0, 0.0), Vector2(w / 2.0, 0.0), Color(0.5, 0.5, 0.42, 0.6), 2.5)
	# Base bolts
	for i in 8:
		var bx: float = -w / 2.0 + 12.0 + float(i) * (w - 24.0) / 7.0
		node.draw_circle(Vector2(bx, -2.0), 2.0, Color(0.55, 0.55, 0.42, 0.5))
