class_name CityBuildingsJupiter
extends RefCounted

# Jupiter — "Ganymede Docks" industrial port
# Heavy industrial, icy undertones, massive machinery, steam and frost.
# Colors: industrial gray (0.4, 0.42, 0.45), ice blue (0.5, 0.65, 0.8), rust brown.

# ── 1. HANGAR — Massive ice-dock with crane gantries ─────────────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	# Heavy industrial base structure with thick walls
	var base_gray := Color(0.38, 0.40, 0.44)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), base_gray)

	# Thick wall edges (left and right reinforced walls)
	var wall_thick: float = w * 0.06
	node.draw_rect(Rect2(-w / 2.0, -h, wall_thick, h), Color(0.34, 0.36, 0.40))
	node.draw_rect(Rect2(w / 2.0 - wall_thick, -h, wall_thick, h), Color(0.34, 0.36, 0.40))

	# Horizontal panel seams
	for i in 8:
		var py: float = -h + float(i + 1) * h / 9.0
		node.draw_line(Vector2(-w / 2.0, py), Vector2(w / 2.0, py), Color(0.30, 0.32, 0.36, 0.35), 1.0)

	# Ice-crusted wall surfaces (irregular white/blue patches)
	for i in 18:
		var fx: float = -w / 2.0 + fmod(float(i) * 37.3, w)
		var fy: float = -h + fmod(float(i) * 23.7, h * 0.85)
		var fr: float = 2.0 + float(i % 5) * 1.5
		var ice_alpha: float = 0.15 + float(i % 4) * 0.06
		node.draw_circle(Vector2(fx, fy), fr, Color(0.7, 0.82, 0.95, ice_alpha))

	# Overhead crane gantry — vertical supports
	var gantry_left: float = -w / 2.0 + wall_thick + 6.0
	var gantry_right: float = w / 2.0 - wall_thick - 6.0
	var gantry_top: float = -h + h * 0.12
	# Left support
	node.draw_line(Vector2(gantry_left, 0.0), Vector2(gantry_left, gantry_top), Color(0.50, 0.45, 0.38), 4.0)
	# Right support
	node.draw_line(Vector2(gantry_right, 0.0), Vector2(gantry_right, gantry_top), Color(0.50, 0.45, 0.38), 4.0)
	# Horizontal beam across top
	node.draw_line(Vector2(gantry_left, gantry_top), Vector2(gantry_right, gantry_top), Color(0.55, 0.50, 0.42), 5.0)
	# Cross bracing on supports
	for i in 3:
		var brace_y: float = -h * 0.25 - float(i) * h * 0.2
		node.draw_line(Vector2(gantry_left, brace_y), Vector2(gantry_left + 10.0, brace_y - 15.0), Color(0.48, 0.44, 0.38, 0.5), 1.5)
		node.draw_line(Vector2(gantry_right, brace_y), Vector2(gantry_right - 10.0, brace_y - 15.0), Color(0.48, 0.44, 0.38, 0.5), 1.5)

	# Crane trolley (moves along beam, animated)
	var trolley_travel: float = sin(t * 0.3) * (gantry_right - gantry_left) * 0.3
	var trolley_x: float = (gantry_left + gantry_right) / 2.0 + trolley_travel
	node.draw_rect(Rect2(trolley_x - 8.0, gantry_top - 3.0, 16.0, 6.0), Color(0.55, 0.48, 0.35))
	# Hanging chain from trolley
	var chain_len: float = 40.0 + sin(t * 0.5) * 5.0
	for ci in 8:
		var cy: float = gantry_top + 3.0 + float(ci) * chain_len / 8.0
		var link_w: float = 2.0 if ci % 2 == 0 else 1.5
		node.draw_rect(Rect2(trolley_x - link_w / 2.0, cy, link_w, chain_len / 8.0 - 1.0), Color(0.5, 0.48, 0.42, 0.7))
	# Hook at bottom
	var hook_y: float = gantry_top + 3.0 + chain_len
	node.draw_arc(Vector2(trolley_x, hook_y), 5.0, 0.0, PI, 12, Color(0.6, 0.55, 0.4), 2.5)

	# Fuel lines running along left wall (thick pipe shapes with joints)
	var pipe_x: float = -w / 2.0 + wall_thick + 2.0
	node.draw_line(Vector2(pipe_x, -h * 0.15), Vector2(pipe_x, -h * 0.85), Color(0.52, 0.38, 0.25), 4.0)
	node.draw_line(Vector2(pipe_x + 8.0, -h * 0.2), Vector2(pipe_x + 8.0, -h * 0.8), Color(0.48, 0.35, 0.22), 3.0)
	# Pipe joints (rectangular clamps)
	for i in 4:
		var jy: float = -h * 0.2 - float(i) * h * 0.15
		node.draw_rect(Rect2(pipe_x - 3.0, jy - 2.0, 14.0, 4.0), Color(0.42, 0.38, 0.32))
		# Steam venting from joints (animated puff shapes)
		var puff_phase: float = sin(t * 2.0 + float(i) * 1.7)
		if puff_phase > 0.0:
			for pi in 3:
				var px: float = pipe_x + 16.0 + float(pi) * 6.0
				var py: float = jy + sin(t * 1.5 + float(pi) * 0.8) * 3.0
				var pa: float = puff_phase * (0.25 - float(pi) * 0.07)
				node.draw_circle(Vector2(px, py), 3.0 + float(pi) * 1.5, Color(0.8, 0.85, 0.95, pa))

	# Ice formations on edges and corners (jagged triangular shapes)
	for i in 7:
		var ice_x: float = -w / 2.0 + fmod(float(i) * w / 6.5, w)
		var ice_len: float = 6.0 + float(i % 4) * 4.0
		var ice_pts := PackedVector2Array([
			Vector2(ice_x - 2.5, -h),
			Vector2(ice_x + 2.5, -h),
			Vector2(ice_x + 0.5, -h + ice_len),
		])
		node.draw_colored_polygon(ice_pts, Color(0.72, 0.84, 1.0, 0.45))

	# Ice formations at bottom corners
	for side_idx in 2:
		var sx: float = -w / 2.0 + 3.0 if side_idx == 0 else w / 2.0 - 3.0
		for j in 3:
			var ice_y: float = -float(j) * 8.0
			var ice_r: float = 3.0 + float(j) * 1.5
			node.draw_circle(Vector2(sx, ice_y), ice_r, Color(0.7, 0.82, 0.95, 0.3))

	# Industrial dock lighting (hanging light fixtures with glow cones)
	for i in 3:
		var lx: float = -w / 3.0 + float(i) * w / 3.0
		var ly: float = -h * 0.82
		# Fixture bracket
		node.draw_rect(Rect2(lx - 2.0, gantry_top, 4.0, 8.0), Color(0.42, 0.40, 0.38))
		# Light cone (triangular glow)
		var cone_pts := PackedVector2Array([
			Vector2(lx - 1.5, ly),
			Vector2(lx - 15.0, ly + 35.0),
			Vector2(lx + 15.0, ly + 35.0),
			Vector2(lx + 1.5, ly),
		])
		var light_pulse: float = 0.08 + 0.04 * sin(t * 1.2 + float(i) * 2.0)
		node.draw_colored_polygon(cone_pts, Color(0.9, 0.85, 0.6, light_pulse))
		# Light bulb
		node.draw_circle(Vector2(lx, ly), 3.0, Color(0.95, 0.9, 0.7, 0.8))

	# Dock number painted on wall
	var num_x: float = w / 2.0 - wall_thick - 25.0
	var num_y: float = -h * 0.6
	# Background panel
	node.draw_rect(Rect2(num_x - 12.0, num_y - 10.0, 24.0, 20.0), Color(0.3, 0.32, 0.35))
	# "07" block shapes
	node.draw_rect(Rect2(num_x - 8.0, num_y - 6.0, 6.0, 12.0), Color(0.9, 0.85, 0.7, 0.7))
	node.draw_rect(Rect2(num_x + 2.0, num_y - 6.0, 6.0, 12.0), Color(0.9, 0.85, 0.7, 0.7))

	# Loading platform extending from front
	node.draw_rect(Rect2(-w * 0.2, -3.0, w * 0.4, 5.0), Color(0.42, 0.44, 0.46))
	# Platform stripes
	for i in 4:
		var sx: float = -w * 0.2 + float(i) * w * 0.1 + 5.0
		node.draw_rect(Rect2(sx, -3.0, 4.0, 5.0), Color(0.9, 0.7, 0.1, 0.5))

	# Roof edge with frost
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.65, 0.78, 0.92, 0.55), 2.5)

	# Entrance glow
	var glow_pulse: float = 0.35 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-w * 0.2 - 3.0, -5.0, w * 0.4 + 6.0, 7.0), Color(0.4, 0.6, 0.9, glow_pulse))


# ── 2. MARKET — Fuel exchange with tank racks ────────────────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	# Back wall / structure
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.36, 0.38, 0.42))

	# Safety barrier around perimeter (striped line at ground level)
	for i in 16:
		var bx: float = -w / 2.0 + float(i) * w / 16.0
		var stripe_col := Color(0.9, 0.7, 0.05, 0.6) if i % 2 == 0 else Color(0.15, 0.15, 0.15, 0.6)
		node.draw_rect(Rect2(bx, -6.0, w / 16.0, 6.0), stripe_col)

	# Rows of cylindrical fuel tanks — 4 tanks of different sizes
	var tank_positions: Array = [
		{"cx": -w * 0.34, "tw": w * 0.18, "th": h * 0.65},
		{"cx": -w * 0.12, "tw": w * 0.20, "th": h * 0.75},
		{"cx": w * 0.12, "tw": w * 0.16, "th": h * 0.55},
		{"cx": w * 0.34, "tw": w * 0.18, "th": h * 0.70},
	]
	for ti in tank_positions.size():
		var tank_data: Dictionary = tank_positions[ti]
		var cx: float = tank_data["cx"]
		var tw: float = tank_data["tw"]
		var th: float = tank_data["th"]
		var tank_top: float = -th - 6.0
		# Tank body
		node.draw_rect(Rect2(cx - tw / 2.0, tank_top, tw, th), Color(0.48, 0.52, 0.56))
		# Tank dome top (rounded cap)
		var dome_pts := PackedVector2Array([
			Vector2(cx - tw / 2.0, tank_top),
			Vector2(cx - tw / 3.0, tank_top - 8.0),
			Vector2(cx + tw / 3.0, tank_top - 8.0),
			Vector2(cx + tw / 2.0, tank_top),
		])
		node.draw_colored_polygon(dome_pts, Color(0.50, 0.54, 0.58))
		# Tank bottom rounded
		node.draw_rect(Rect2(cx - tw / 2.0, -8.0, tw, 2.0), Color(0.42, 0.44, 0.48))
		# Horizontal bands on tank
		for bi in 5:
			var by: float = tank_top + float(bi + 1) * th / 6.0
			node.draw_line(Vector2(cx - tw / 2.0, by), Vector2(cx + tw / 2.0, by), Color(0.40, 0.42, 0.46, 0.4), 1.5)
		# Pressure gauge on each tank (small circle)
		var gauge_y: float = tank_top + th * 0.3
		node.draw_circle(Vector2(cx, gauge_y), 5.0, Color(0.12, 0.12, 0.15))
		var needle_ang: float = -PI / 4.0 + sin(t * 0.7 + float(ti) * 1.3) * PI / 5.0
		var needle_dx: float = cos(needle_ang) * 3.5
		var needle_dy: float = sin(needle_ang) * 3.5
		node.draw_line(Vector2(cx, gauge_y), Vector2(cx + needle_dx, gauge_y + needle_dy), Color(0.9, 0.2, 0.1, 0.8), 1.5)
		node.draw_arc(Vector2(cx, gauge_y), 5.0, 0.0, TAU, 12, Color(0.55, 0.55, 0.58, 0.6), 1.0)
		# Fill level indicator
		var fill_frac: float = 0.35 + 0.2 * sin(t * 0.25 + float(ti) * 2.0)
		var fill_h: float = th * fill_frac
		node.draw_rect(Rect2(cx - tw / 2.0 + 2.0, -8.0 - fill_h, tw - 4.0, fill_h), Color(0.2, 0.45, 0.8, 0.12))
		# Steam/frost effects around cold tanks (animated wisps)
		for si in 3:
			var steam_x: float = cx + sin(t * 1.3 + float(si) * 1.5 + float(ti) * 0.7) * tw * 0.3
			var steam_y: float = tank_top - 12.0 - float(si) * 8.0
			var steam_a: float = 0.18 - float(si) * 0.05
			node.draw_circle(Vector2(steam_x, steam_y), 4.0 + float(si) * 2.0, Color(0.75, 0.82, 0.95, steam_a))

	# Pipeline connections between tanks (horizontal pipes with valve wheels)
	var pipe_y: float = -h * 0.35
	node.draw_line(Vector2(-w * 0.34, pipe_y), Vector2(w * 0.34, pipe_y), Color(0.50, 0.44, 0.34), 3.5)
	# Vertical drops from pipe to each tank
	for ti in tank_positions.size():
		var tank_data: Dictionary = tank_positions[ti]
		var cx: float = tank_data["cx"]
		node.draw_line(Vector2(cx, pipe_y), Vector2(cx, pipe_y + 15.0), Color(0.50, 0.44, 0.34), 2.5)
		# Valve wheel
		node.draw_arc(Vector2(cx, pipe_y), 4.0, 0.0, TAU, 10, Color(0.65, 0.15, 0.1, 0.7), 2.0)
		# Valve spokes
		node.draw_line(Vector2(cx - 3.0, pipe_y), Vector2(cx + 3.0, pipe_y), Color(0.6, 0.15, 0.1, 0.5), 1.0)
		node.draw_line(Vector2(cx, pipe_y - 3.0), Vector2(cx, pipe_y + 3.0), Color(0.6, 0.15, 0.1, 0.5), 1.0)

	# Price ticker board (upper area)
	var ticker_x: float = -w * 0.38
	var ticker_y: float = -h * 0.88
	var ticker_w: float = w * 0.76
	var ticker_h: float = h * 0.1
	node.draw_rect(Rect2(ticker_x, ticker_y, ticker_w, ticker_h), Color(0.08, 0.08, 0.1))
	node.draw_rect(Rect2(ticker_x, ticker_y, ticker_w, ticker_h), Color(0.4, 0.42, 0.45, 0.5), false, 1.5)
	# Scrolling number-like marks (animated)
	var scroll_off: float = fmod(t * 30.0, 20.0)
	for i in 12:
		var tx: float = ticker_x + 6.0 + float(i) * ticker_w / 12.0 - scroll_off
		if tx > ticker_x and tx < ticker_x + ticker_w - 6.0:
			var digit_h: float = ticker_h * 0.6
			var digit_col := Color(0.1, 0.9, 0.3, 0.7) if i % 3 != 2 else Color(0.9, 0.2, 0.1, 0.7)
			node.draw_rect(Rect2(tx, ticker_y + ticker_h * 0.2, 8.0, digit_h), digit_col)

	# "FUEL EXCHANGE" sign panel (above ticker)
	var sign_w: float = w * 0.5
	var sign_x: float = -sign_w / 2.0
	var sign_y: float = -h * 0.97
	node.draw_rect(Rect2(sign_x - 3.0, sign_y - 2.0, sign_w + 6.0, 14.0), Color(0.12, 0.12, 0.15))
	# Letter blocks for "FUEL EXCHANGE"
	for i in 8:
		var lx: float = sign_x + 4.0 + float(i) * (sign_w - 8.0) / 8.0
		var lp: float = 0.55 + 0.3 * sin(t * 2.0 + float(i) * 0.5)
		node.draw_rect(Rect2(lx, sign_y + 1.0, 5.0, 8.0), Color(0.5, 0.65, 0.9, lp))

	# Weight scale platform (lower right)
	var scale_x: float = w * 0.2
	var scale_y: float = -12.0
	node.draw_rect(Rect2(scale_x, scale_y, w * 0.22, 4.0), Color(0.42, 0.44, 0.48))
	# Scale legs
	node.draw_line(Vector2(scale_x + 5.0, scale_y + 4.0), Vector2(scale_x + 5.0, 0.0), Color(0.38, 0.40, 0.44), 2.0)
	node.draw_line(Vector2(scale_x + w * 0.22 - 5.0, scale_y + 4.0), Vector2(scale_x + w * 0.22 - 5.0, 0.0), Color(0.38, 0.40, 0.44), 2.0)
	# Measurement marks
	for i in 5:
		var mx: float = scale_x + 4.0 + float(i) * w * 0.22 / 5.0
		node.draw_line(Vector2(mx, scale_y), Vector2(mx, scale_y - 3.0), Color(0.9, 0.85, 0.7, 0.5), 1.0)

	# Office booth (small glass-fronted rectangle on left)
	var booth_x: float = -w / 2.0 + 8.0
	var booth_y: float = -h * 0.35
	var booth_w: float = w * 0.14
	var booth_h: float = h * 0.28
	node.draw_rect(Rect2(booth_x, booth_y, booth_w, booth_h), Color(0.32, 0.34, 0.38))
	# Glass front
	var glass_pulse: float = 0.3 + 0.15 * sin(t * 1.5)
	node.draw_rect(Rect2(booth_x + 2.0, booth_y + 4.0, booth_w - 4.0, booth_h * 0.5), Color(0.5, 0.7, 0.9, glass_pulse))
	# Booth roof
	node.draw_line(Vector2(booth_x, booth_y), Vector2(booth_x + booth_w, booth_y), Color(0.45, 0.47, 0.50), 2.0)

	# Roof edge with frost
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.65, 0.78, 0.92, 0.55), 2.0)

	# Entrance glow
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-18.0, -5.0, 36.0, 7.0), Color(0.4, 0.6, 0.9, glow_pulse))


# ── 3. BAR — Dockworker's pub with barrel tables ────────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	# Squat, sturdy structure (wider than tall, thick walls)
	var wall_col := Color(0.28, 0.30, 0.35)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), wall_col)

	# Thick wall shading on edges
	node.draw_rect(Rect2(-w / 2.0, -h, w * 0.04, h), Color(0.24, 0.26, 0.30))
	node.draw_rect(Rect2(w / 2.0 - w * 0.04, -h, w * 0.04, h), Color(0.24, 0.26, 0.30))

	# Sloped roof (slight peak)
	var roof_pts := PackedVector2Array([
		Vector2(-w / 2.0 - 6.0, -h),
		Vector2(0.0, -h - 15.0),
		Vector2(w / 2.0 + 6.0, -h),
	])
	node.draw_colored_polygon(roof_pts, Color(0.32, 0.34, 0.38))
	node.draw_polyline(roof_pts, Color(0.40, 0.42, 0.46, 0.6), 2.0)

	# Icicles hanging from eaves (triangular shapes along roof edge)
	for i in 12:
		var ix: float = -w / 2.0 + 6.0 + float(i) * (w - 12.0) / 11.0
		var il: float = 5.0 + float(i % 4) * 4.0
		var icicle_pts := PackedVector2Array([
			Vector2(ix - 2.0, -h),
			Vector2(ix + 2.0, -h),
			Vector2(ix + 0.3, -h + il),
		])
		node.draw_colored_polygon(icicle_pts, Color(0.72, 0.84, 1.0, 0.5))

	# Chimney with animated smoke puffs
	var chimney_x: float = w * 0.25
	var chimney_base: float = -h - 8.0
	node.draw_rect(Rect2(chimney_x - 5.0, chimney_base - 20.0, 10.0, 28.0), Color(0.35, 0.30, 0.28))
	node.draw_rect(Rect2(chimney_x - 7.0, chimney_base - 22.0, 14.0, 4.0), Color(0.38, 0.33, 0.30))
	# Smoke puffs
	for i in 6:
		var smoke_x: float = chimney_x + sin(t * 0.8 + float(i) * 1.2) * (4.0 + float(i) * 2.0)
		var smoke_y: float = chimney_base - 26.0 - float(i) * 10.0
		var smoke_r: float = 4.0 + float(i) * 2.5
		var smoke_a: float = 0.25 - float(i) * 0.035
		node.draw_circle(Vector2(smoke_x, smoke_y), smoke_r, Color(0.6, 0.62, 0.65, smoke_a))

	# Steam pipes running through ceiling visible through open front
	for i in 3:
		var pipe_y: float = -h + 8.0 + float(i) * 10.0
		node.draw_line(Vector2(-w * 0.35, pipe_y), Vector2(w * 0.35, pipe_y), Color(0.5, 0.42, 0.32, 0.5), 3.0)
		# Pipe joints
		for j in 4:
			var jx: float = -w * 0.3 + float(j) * w * 0.2
			node.draw_rect(Rect2(jx - 3.0, pipe_y - 2.5, 6.0, 5.0), Color(0.45, 0.40, 0.33, 0.5))

	# Windows with warm interior glow and frost on panes
	for i in 3:
		var wx: float = -w * 0.32 + float(i) * w * 0.28
		var wy: float = -h * 0.62
		var ww: float = w * 0.16
		var wh: float = h * 0.2
		# Warm interior glow
		var warm_pulse: float = 0.4 + 0.2 * sin(t * 1.6 + float(i) * 0.9)
		node.draw_rect(Rect2(wx, wy, ww, wh), Color(0.9, 0.6, 0.2, warm_pulse))
		# Frost on window panes
		node.draw_rect(Rect2(wx, wy, ww, wh), Color(0.7, 0.82, 0.95, 0.3))
		# Frost crystals on corners
		node.draw_circle(Vector2(wx + 2.0, wy + 2.0), 3.0, Color(0.8, 0.88, 1.0, 0.4))
		node.draw_circle(Vector2(wx + ww - 2.0, wy + 2.0), 2.5, Color(0.8, 0.88, 1.0, 0.35))
		node.draw_circle(Vector2(wx + ww - 2.0, wy + wh - 2.0), 2.0, Color(0.8, 0.88, 1.0, 0.3))
		# Window frame
		node.draw_rect(Rect2(wx, wy, ww, wh), Color(0.42, 0.44, 0.48, 0.6), false, 1.5)
		# Cross bar
		node.draw_line(Vector2(wx, wy + wh / 2.0), Vector2(wx + ww, wy + wh / 2.0), Color(0.42, 0.44, 0.48, 0.5), 1.0)
		node.draw_line(Vector2(wx + ww / 2.0, wy), Vector2(wx + ww / 2.0, wy + wh), Color(0.42, 0.44, 0.48, 0.5), 1.0)

	# Heavy wooden/metal door (thick rectangle with handle)
	var door_w: float = w * 0.15
	var door_h: float = h * 0.38
	node.draw_rect(Rect2(-door_w / 2.0, -door_h, door_w, door_h), Color(0.22, 0.18, 0.14))
	# Door frame
	node.draw_rect(Rect2(-door_w / 2.0 - 3.0, -door_h - 3.0, door_w + 6.0, door_h + 3.0), Color(0.35, 0.30, 0.25), false, 2.0)
	# Door handle
	node.draw_circle(Vector2(door_w / 2.0 - 6.0, -door_h * 0.45), 2.5, Color(0.65, 0.55, 0.3))
	# Door planks
	for i in 3:
		var plank_x: float = -door_w / 2.0 + float(i + 1) * door_w / 4.0
		node.draw_line(Vector2(plank_x, -door_h), Vector2(plank_x, 0.0), Color(0.18, 0.15, 0.12, 0.4), 1.0)
	# Door hinges
	node.draw_rect(Rect2(-door_w / 2.0 - 2.0, -door_h * 0.8, 4.0, 6.0), Color(0.4, 0.38, 0.32))
	node.draw_rect(Rect2(-door_w / 2.0 - 2.0, -door_h * 0.3, 4.0, 6.0), Color(0.4, 0.38, 0.32))

	# Barrel-shaped tables out front (3 circles with flat tops, stools)
	for i in 3:
		var bx: float = -w * 0.28 + float(i) * w * 0.25
		var by: float = -h * 0.12
		# Barrel body
		node.draw_circle(Vector2(bx, by), 8.0, Color(0.45, 0.32, 0.18))
		# Barrel bands
		node.draw_arc(Vector2(bx, by), 6.0, 0.0, TAU, 12, Color(0.5, 0.42, 0.25, 0.6), 1.0)
		node.draw_arc(Vector2(bx, by), 8.0, 0.0, TAU, 12, Color(0.5, 0.42, 0.25, 0.5), 1.0)
		# Flat top (line across)
		node.draw_line(Vector2(bx - 9.0, by - 4.0), Vector2(bx + 9.0, by - 4.0), Color(0.48, 0.35, 0.2), 2.0)
		# Stools (small rectangles on each side)
		node.draw_rect(Rect2(bx - 14.0, by - 2.0, 4.0, 6.0), Color(0.38, 0.35, 0.30))
		node.draw_rect(Rect2(bx + 10.0, by - 2.0, 4.0, 6.0), Color(0.38, 0.35, 0.30))

	# "PUB" sign in rough lettering
	var sign_y: float = -h * 0.42
	var sign_w: float = w * 0.25
	var sign_x: float = -sign_w / 2.0
	node.draw_rect(Rect2(sign_x - 4.0, sign_y - 3.0, sign_w + 8.0, 16.0), Color(0.15, 0.12, 0.10))
	# Neon letter blocks
	for i in 3:
		var lx: float = sign_x + 4.0 + float(i) * sign_w / 3.0
		var lp: float = 0.6 + 0.35 * sin(t * 2.5 + float(i) * 1.0)
		node.draw_rect(Rect2(lx, sign_y, 8.0, 10.0), Color(0.9, 0.55, 0.15, lp))
	# Sign glow
	var sign_glow: float = 0.1 + 0.06 * sin(t * 2.5)
	node.draw_rect(Rect2(sign_x - 8.0, sign_y - 6.0, sign_w + 16.0, 22.0), Color(0.9, 0.55, 0.15, sign_glow))

	# Boot scraper and mat by entrance
	node.draw_rect(Rect2(-door_w / 2.0 - 12.0, -3.0, 8.0, 3.0), Color(0.35, 0.32, 0.28))
	node.draw_rect(Rect2(-door_w / 2.0 - 10.0, -5.0, 4.0, 5.0), Color(0.4, 0.38, 0.32))
	# Door mat
	node.draw_rect(Rect2(-door_w / 2.0, -2.0, door_w, 2.0), Color(0.35, 0.28, 0.20))

	# Warm amber entrance glow
	var glow_pulse: float = 0.35 + 0.25 * sin(t * 2.0)
	node.draw_rect(Rect2(-door_w / 2.0 - 5.0, -4.0, door_w + 10.0, 6.0), Color(0.9, 0.55, 0.15, glow_pulse))


# ── 4. GARAGE — Heavy industrial bay with overhead crane ─────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	# Tall open-front structure (high ceiling for crane clearance)
	var body_col := Color(0.36, 0.40, 0.46)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), body_col)

	# Side walls (thicker, reinforced)
	var wall_w: float = w * 0.07
	node.draw_rect(Rect2(-w / 2.0, -h, wall_w, h), Color(0.32, 0.36, 0.42))
	node.draw_rect(Rect2(w / 2.0 - wall_w, -h, wall_w, h), Color(0.32, 0.36, 0.42))

	# Horizontal panel seams
	for i in 10:
		var py: float = -h + float(i + 1) * h / 11.0
		node.draw_line(Vector2(-w / 2.0, py), Vector2(w / 2.0, py), Color(0.28, 0.32, 0.38, 0.3), 1.0)

	# Open bay front (dark interior visible)
	var bay_w: float = w * 0.65
	var bay_h: float = h * 0.72
	var bay_x: float = -bay_w / 2.0
	var bay_y: float = -bay_h
	node.draw_rect(Rect2(bay_x, bay_y, bay_w, bay_h), Color(0.15, 0.17, 0.20))

	# Overhead crane rail near top (horizontal beam)
	var rail_y: float = -h * 0.88
	node.draw_line(Vector2(-w / 2.0 + wall_w, rail_y), Vector2(w / 2.0 - wall_w, rail_y), Color(0.52, 0.48, 0.40), 5.0)
	# Rail supports (brackets from ceiling)
	for i in 4:
		var bx: float = -w / 2.0 + wall_w + float(i + 1) * (w - 2.0 * wall_w) / 5.0
		node.draw_line(Vector2(bx, -h), Vector2(bx, rail_y), Color(0.48, 0.44, 0.38, 0.5), 2.0)
		node.draw_rect(Rect2(bx - 4.0, rail_y - 2.0, 8.0, 4.0), Color(0.50, 0.46, 0.40))

	# Crane trolley with hanging chain (animated gentle sway)
	var trolley_sway: float = sin(t * 0.35) * (w * 0.2)
	var trolley_x: float = trolley_sway
	node.draw_rect(Rect2(trolley_x - 12.0, rail_y, 24.0, 8.0), Color(0.58, 0.50, 0.38))
	# Trolley wheels
	node.draw_circle(Vector2(trolley_x - 8.0, rail_y), 3.0, Color(0.45, 0.42, 0.38))
	node.draw_circle(Vector2(trolley_x + 8.0, rail_y), 3.0, Color(0.45, 0.42, 0.38))
	# Chain (gentle sway offset)
	var chain_sway: float = sin(t * 0.5 + 0.5) * 4.0
	var chain_bottom: float = rail_y + 8.0 + h * 0.35
	for ci in 10:
		var cy: float = rail_y + 8.0 + float(ci) * h * 0.035
		var cx_off: float = chain_sway * float(ci) / 10.0
		var link_half: float = 1.5 if ci % 2 == 0 else 1.0
		node.draw_rect(Rect2(trolley_x + cx_off - link_half, cy, link_half * 2.0, h * 0.035 - 1.0), Color(0.5, 0.48, 0.42, 0.7))
	# Hook
	var hook_x: float = trolley_x + chain_sway
	node.draw_arc(Vector2(hook_x, chain_bottom), 6.0, 0.0, PI, 12, Color(0.6, 0.55, 0.42), 3.0)

	# Welding sparks in one corner (bright animated dots)
	var spark_x: float = w / 2.0 - wall_w - 20.0
	var spark_y: float = -h * 0.25
	var spark_active: float = sin(t * 3.0)
	if spark_active > 0.0:
		# Bright flash
		node.draw_circle(Vector2(spark_x, spark_y), 4.0, Color(0.9, 0.9, 1.0, spark_active * 0.6))
		# Flying sparks
		for i in 8:
			var sp_ang: float = float(i) * TAU / 8.0 + t * 5.0
			var sp_dist: float = 5.0 + sin(t * 8.0 + float(i) * 1.3) * 8.0
			var sp_x: float = spark_x + cos(sp_ang) * sp_dist
			var sp_y: float = spark_y + sin(sp_ang) * sp_dist
			var sp_a: float = spark_active * 0.7
			node.draw_circle(Vector2(sp_x, sp_y), 1.5, Color(1.0, 0.8, 0.2, sp_a))

	# Heavy tool racks along left wall (organized shapes)
	var rack_x: float = -w / 2.0 + wall_w + 3.0
	for i in 5:
		var ry: float = -h * 0.3 - float(i) * h * 0.1
		# Rack shelf
		node.draw_line(Vector2(rack_x, ry), Vector2(rack_x + 18.0, ry), Color(0.45, 0.42, 0.38), 2.0)
		# Tools on shelf (small shapes)
		for j in 3:
			var tool_x: float = rack_x + 3.0 + float(j) * 5.0
			node.draw_rect(Rect2(tool_x, ry - 5.0, 3.0, 5.0), Color(0.52, 0.48, 0.42, 0.6))

	# Oil drums on floor (cylinder shapes)
	for i in 3:
		var drum_x: float = -w * 0.25 + float(i) * 20.0
		node.draw_rect(Rect2(drum_x - 5.0, -18.0, 10.0, 18.0), Color(0.25, 0.28, 0.32))
		# Drum bands
		node.draw_line(Vector2(drum_x - 5.0, -14.0), Vector2(drum_x + 5.0, -14.0), Color(0.35, 0.38, 0.42), 1.5)
		node.draw_line(Vector2(drum_x - 5.0, -6.0), Vector2(drum_x + 5.0, -6.0), Color(0.35, 0.38, 0.42), 1.5)
		# Drum lid
		node.draw_line(Vector2(drum_x - 5.0, -18.0), Vector2(drum_x + 5.0, -18.0), Color(0.30, 0.33, 0.38), 2.0)

	# Parts and equipment scattered (small shapes)
	node.draw_rect(Rect2(w * 0.1, -8.0, 12.0, 8.0), Color(0.4, 0.38, 0.35))
	node.draw_rect(Rect2(w * 0.15, -12.0, 6.0, 6.0), Color(0.45, 0.42, 0.38))
	node.draw_circle(Vector2(w * 0.05, -5.0), 3.0, Color(0.38, 0.36, 0.32))

	# Industrial ventilation ducts on ceiling
	for i in 2:
		var duct_x: float = -w * 0.2 + float(i) * w * 0.35
		var duct_y: float = -h + 5.0
		node.draw_rect(Rect2(duct_x, duct_y, w * 0.15, 8.0), Color(0.42, 0.44, 0.48, 0.6))
		# Duct grille lines
		for j in 4:
			var gx: float = duct_x + float(j + 1) * w * 0.15 / 5.0
			node.draw_line(Vector2(gx, duct_y), Vector2(gx, duct_y + 8.0), Color(0.35, 0.37, 0.40, 0.4), 1.0)

	# Work platform/scaffolding on right side
	var scaffold_x: float = w / 2.0 - wall_w - 25.0
	for level in 3:
		var plat_y: float = -h * 0.2 - float(level) * h * 0.2
		# Platform
		node.draw_line(Vector2(scaffold_x, plat_y), Vector2(scaffold_x + 22.0, plat_y), Color(0.52, 0.48, 0.40), 2.0)
		# Vertical supports
		node.draw_line(Vector2(scaffold_x, plat_y), Vector2(scaffold_x, plat_y + h * 0.2), Color(0.48, 0.44, 0.38), 1.5)
		node.draw_line(Vector2(scaffold_x + 22.0, plat_y), Vector2(scaffold_x + 22.0, plat_y + h * 0.2), Color(0.48, 0.44, 0.38), 1.5)
		# Cross brace
		node.draw_line(Vector2(scaffold_x, plat_y), Vector2(scaffold_x + 22.0, plat_y + h * 0.2), Color(0.46, 0.42, 0.36, 0.4), 1.0)

	# Bright overhead work lights
	for i in 3:
		var light_x: float = bay_x + float(i + 1) * bay_w / 4.0
		var light_y: float = -h * 0.92
		node.draw_rect(Rect2(light_x - 6.0, light_y, 12.0, 4.0), Color(0.55, 0.52, 0.48))
		# Light glow cone
		var cone_pts := PackedVector2Array([
			Vector2(light_x - 3.0, light_y + 4.0),
			Vector2(light_x - 18.0, light_y + 40.0),
			Vector2(light_x + 18.0, light_y + 40.0),
			Vector2(light_x + 3.0, light_y + 4.0),
		])
		var light_pulse: float = 0.06 + 0.03 * sin(t * 1.0 + float(i) * 1.5)
		node.draw_colored_polygon(cone_pts, Color(0.95, 0.9, 0.7, light_pulse))
		node.draw_circle(Vector2(light_x, light_y + 4.0), 3.0, Color(0.95, 0.9, 0.7, 0.8))

	# Warning stripes on bay edges
	var stripe_sz: float = 6.0
	var stripe_cnt: int = int(bay_h / stripe_sz)
	for i in stripe_cnt:
		if i % 2 == 0:
			var sy: float = bay_y + float(i) * stripe_sz
			node.draw_rect(Rect2(bay_x, sy, 5.0, stripe_sz), Color(0.9, 0.7, 0.1, 0.55))
			node.draw_rect(Rect2(bay_x + bay_w - 5.0, sy, 5.0, stripe_sz), Color(0.9, 0.7, 0.1, 0.55))

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.6, 0.72, 0.88, 0.5), 2.0)

	# Entrance glow
	var glow_pulse: float = 0.35 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(bay_x - 3.0, -5.0, bay_w + 6.0, 7.0), Color(0.4, 0.6, 1.0, glow_pulse))


# ── 5. UNIQUE — Collector's Vault ────────────────────────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	# Main ornate structure body
	var body_col := Color(0.30, 0.32, 0.36)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), body_col)

	# Decorative border molding around edges (thick ornate frame)
	var mold: float = 6.0
	# Outer molding highlight
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.55, 0.45, 0.28, 0.5), false, 3.0)
	# Inner molding
	node.draw_rect(Rect2(-w / 2.0 + mold, -h + mold, w - mold * 2.0, h - mold * 2.0), Color(0.50, 0.42, 0.25, 0.35), false, 2.0)
	# Corner decorative squares
	for cx_idx in 2:
		for cy_idx in 2:
			var corner_x: float = -w / 2.0 + float(cx_idx) * (w - mold) - 1.0
			var corner_y: float = -h + float(cy_idx) * (h - mold) - 1.0
			node.draw_rect(Rect2(corner_x, corner_y, mold + 2.0, mold + 2.0), Color(0.6, 0.50, 0.30, 0.4))

	# Gold/bronze trim line along top and bottom
	node.draw_line(Vector2(-w / 2.0, -h + 3.0), Vector2(w / 2.0, -h + 3.0), Color(0.7, 0.58, 0.3, 0.6), 2.0)
	node.draw_line(Vector2(-w / 2.0, -3.0), Vector2(w / 2.0, -3.0), Color(0.7, 0.58, 0.3, 0.6), 2.0)

	# Ornate columns flanking entrance (2 on each side)
	for side_idx in 2:
		var col_x: float = -w * 0.18 if side_idx == 0 else w * 0.18
		var col_hw: float = 6.0
		# Column shaft
		node.draw_rect(Rect2(col_x - col_hw, -h * 0.75, col_hw * 2.0, h * 0.75), Color(0.42, 0.38, 0.32))
		# Column capital (top wider piece)
		node.draw_rect(Rect2(col_x - col_hw - 3.0, -h * 0.75 - 5.0, col_hw * 2.0 + 6.0, 8.0), Color(0.55, 0.48, 0.32))
		# Column base (bottom wider piece)
		node.draw_rect(Rect2(col_x - col_hw - 2.0, -4.0, col_hw * 2.0 + 4.0, 6.0), Color(0.50, 0.44, 0.30))
		# Column fluting lines
		for fi in 3:
			var fx: float = col_x - col_hw + 3.0 + float(fi) * col_hw * 0.6
			node.draw_line(Vector2(fx, -h * 0.74), Vector2(fx, -2.0), Color(0.38, 0.34, 0.28, 0.3), 1.0)

	# Heavy vault door (large circle with spoke pattern/handle wheel)
	var vault_cx: float = 0.0
	var vault_cy: float = -h * 0.38
	var vault_r: float = h * 0.22
	# Door circle body
	node.draw_circle(Vector2(vault_cx, vault_cy), vault_r, Color(0.35, 0.38, 0.42))
	# Outer ring
	node.draw_arc(Vector2(vault_cx, vault_cy), vault_r, 0.0, TAU, 32, Color(0.55, 0.48, 0.30), 3.0)
	# Inner ring
	node.draw_arc(Vector2(vault_cx, vault_cy), vault_r * 0.7, 0.0, TAU, 24, Color(0.50, 0.44, 0.28, 0.6), 2.0)
	# Spoke pattern (handle wheel)
	for i in 8:
		var spoke_ang: float = float(i) * TAU / 8.0
		var spoke_dx: float = cos(spoke_ang) * vault_r * 0.65
		var spoke_dy: float = sin(spoke_ang) * vault_r * 0.65
		node.draw_line(Vector2(vault_cx, vault_cy), Vector2(vault_cx + spoke_dx, vault_cy + spoke_dy), Color(0.52, 0.46, 0.32, 0.5), 1.5)
	# Center hub
	node.draw_circle(Vector2(vault_cx, vault_cy), vault_r * 0.15, Color(0.6, 0.52, 0.35))
	# Locking bolts around perimeter
	for i in 12:
		var bolt_ang: float = float(i) * TAU / 12.0
		var bolt_x: float = vault_cx + cos(bolt_ang) * vault_r * 0.88
		var bolt_y: float = vault_cy + sin(bolt_ang) * vault_r * 0.88
		node.draw_circle(Vector2(bolt_x, bolt_y), 2.5, Color(0.48, 0.44, 0.35))

	# Spotlight on vault door (animated)
	var spot_pulse: float = 0.08 + 0.04 * sin(t * 1.5)
	var spot_pts := PackedVector2Array([
		Vector2(vault_cx, -h * 0.82),
		Vector2(vault_cx - vault_r * 1.1, vault_cy + vault_r),
		Vector2(vault_cx + vault_r * 1.1, vault_cy + vault_r),
	])
	node.draw_colored_polygon(spot_pts, Color(0.95, 0.9, 0.7, spot_pulse))
	# Spotlight fixture
	node.draw_rect(Rect2(vault_cx - 4.0, -h * 0.84, 8.0, 5.0), Color(0.45, 0.42, 0.38))

	# Display cases visible through barred windows (left and right of vault)
	for side_idx in 2:
		var win_cx: float = -w * 0.35 if side_idx == 0 else w * 0.35
		var win_w: float = w * 0.16
		var win_h: float = h * 0.22
		var win_x: float = win_cx - win_w / 2.0
		var win_y: float = -h * 0.65
		# Window recess
		node.draw_rect(Rect2(win_x, win_y, win_w, win_h), Color(0.12, 0.12, 0.15))
		# Display items inside (small glowing shapes)
		for di in 3:
			var item_x: float = win_x + 5.0 + float(di) * (win_w - 10.0) / 2.0
			var item_y: float = win_y + win_h * 0.5
			var item_pulse: float = 0.4 + 0.3 * sin(t * 1.8 + float(di) * 1.2 + float(side_idx) * PI)
			# Item glow
			node.draw_circle(Vector2(item_x, item_y), 4.0, Color(0.8, 0.7, 0.3, item_pulse * 0.3))
			# Item shape
			node.draw_circle(Vector2(item_x, item_y), 2.5, Color(0.9, 0.8, 0.4, item_pulse))
		# Window bars (vertical)
		for bi in 4:
			var bar_x: float = win_x + float(bi + 1) * win_w / 5.0
			node.draw_line(Vector2(bar_x, win_y), Vector2(bar_x, win_y + win_h), Color(0.45, 0.42, 0.38, 0.7), 1.5)
		# Window frame
		node.draw_rect(Rect2(win_x, win_y, win_w, win_h), Color(0.48, 0.42, 0.30, 0.6), false, 2.0)
		# Laser security grid across windows (thin red lines)
		for li in 3:
			var laser_y: float = win_y + float(li + 1) * win_h / 4.0
			var laser_pulse: float = 0.3 + 0.2 * sin(t * 3.0 + float(li) * 0.7)
			node.draw_line(Vector2(win_x + 1.0, laser_y), Vector2(win_x + win_w - 1.0, laser_y), Color(1.0, 0.1, 0.05, laser_pulse), 1.0)

	# Security cameras on upper corners (small box with lens dot)
	for side_idx in 2:
		var cam_x: float = -w / 2.0 + 12.0 if side_idx == 0 else w / 2.0 - 12.0
		var cam_y: float = -h * 0.88
		# Camera bracket
		var bracket_dir: float = 1.0 if side_idx == 0 else -1.0
		node.draw_line(Vector2(cam_x - bracket_dir * 8.0, cam_y), Vector2(cam_x, cam_y), Color(0.42, 0.40, 0.38), 2.0)
		# Camera body
		node.draw_rect(Rect2(cam_x - 4.0, cam_y - 3.0, 8.0, 6.0), Color(0.25, 0.25, 0.28))
		# Lens dot
		var lens_x: float = cam_x + bracket_dir * 2.0
		node.draw_circle(Vector2(lens_x, cam_y), 2.0, Color(0.9, 0.15, 0.1, 0.5 + 0.3 * sin(t * 2.0 + float(side_idx) * PI)))

	# "PRIVATE COLLECTION" plaque (above vault door)
	var plaque_w: float = w * 0.45
	var plaque_x: float = -plaque_w / 2.0
	var plaque_y: float = -h * 0.82
	# Plaque background (bronze)
	node.draw_rect(Rect2(plaque_x, plaque_y, plaque_w, 12.0), Color(0.5, 0.40, 0.22))
	node.draw_rect(Rect2(plaque_x, plaque_y, plaque_w, 12.0), Color(0.6, 0.50, 0.30, 0.5), false, 1.5)
	# Text blocks
	for i in 10:
		var tx: float = plaque_x + 5.0 + float(i) * (plaque_w - 10.0) / 10.0
		node.draw_rect(Rect2(tx, plaque_y + 3.0, 4.0, 6.0), Color(0.25, 0.20, 0.12, 0.7))

	# Atmospheric fog at base (animated translucent shapes)
	for i in 10:
		var fog_x: float = -w / 2.0 + fmod(float(i) * w / 9.3 + t * 8.0, w)
		var fog_y: float = -4.0 + sin(t * 0.6 + float(i) * 0.8) * 3.0
		var fog_r: float = 8.0 + float(i % 4) * 5.0
		var fog_a: float = 0.08 + 0.04 * sin(t * 0.9 + float(i) * 1.1)
		node.draw_circle(Vector2(fog_x, fog_y), fog_r, Color(0.6, 0.65, 0.72, fog_a))

	# Roof edge with gold accent
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.6, 0.50, 0.30, 0.6), 2.5)

	# Entrance glow (warm gold)
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 1.8)
	node.draw_rect(Rect2(-w * 0.15, -5.0, w * 0.3, 7.0), Color(0.8, 0.65, 0.3, glow_pulse))
