class_name CityBuildingsMars
extends RefCounted

# Mars — "Dust Haven" frontier settlement
# Sand-blasted surfaces, military gear, canvas and rope, dusty atmosphere.
# Colors: rust orange (0.7, 0.35, 0.15), sand tan (0.75, 0.6, 0.35), dark military green.


# ── 1. HANGAR — Half-buried bunker with blast doors ──────────────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	# --- Ground / sand base that the bunker is buried in ---
	var sand_color: Color = Color(0.72, 0.58, 0.34)
	var sand_dark: Color = Color(0.6, 0.46, 0.26)
	var rust_body: Color = Color(0.42, 0.3, 0.2)
	var rust_light: Color = Color(0.55, 0.38, 0.25)
	var metal_dark: Color = Color(0.3, 0.22, 0.15)

	# Main bunker body (upper half visible, lower half "underground")
	var bunker_h: float = h * 0.55
	var bunker_y: float = -bunker_h
	node.draw_rect(Rect2(-w / 2.0 + 30.0, bunker_y, w - 60.0, bunker_h), rust_body)

	# Horizontal reinforcement bands on bunker
	for i in range(0, int(bunker_h), 18):
		var py: float = bunker_y + float(i)
		node.draw_line(Vector2(-w / 2.0 + 30.0, py), Vector2(w / 2.0 - 30.0, py), Color(0.38, 0.26, 0.16, 0.35), 1.5)

	# Patched panels on bunker surface
	node.draw_rect(Rect2(-w / 2.0 + 40.0, bunker_y + 10.0, 45.0, 30.0), Color(0.5, 0.36, 0.24, 0.3))
	node.draw_rect(Rect2(w / 2.0 - 100.0, bunker_y + 15.0, 40.0, 25.0), Color(0.48, 0.34, 0.22, 0.3))

	# Sand slope on left side (triangle burying the bunker)
	var sand_left: PackedVector2Array = PackedVector2Array([
		Vector2(-w / 2.0, 0.0),
		Vector2(-w / 2.0 + 30.0, 0.0),
		Vector2(-w / 2.0 + 55.0, -bunker_h * 0.4),
		Vector2(-w / 2.0 + 30.0, bunker_y),
		Vector2(-w / 2.0 + 10.0, bunker_y + 15.0),
	])
	node.draw_colored_polygon(sand_left, sand_color)

	# Sand slope on right side
	var sand_right: PackedVector2Array = PackedVector2Array([
		Vector2(w / 2.0, 0.0),
		Vector2(w / 2.0 - 30.0, 0.0),
		Vector2(w / 2.0 - 55.0, -bunker_h * 0.4),
		Vector2(w / 2.0 - 30.0, bunker_y),
		Vector2(w / 2.0 - 10.0, bunker_y + 15.0),
	])
	node.draw_colored_polygon(sand_right, sand_color)

	# Sand drift piled against left wall (irregular triangular shape)
	var drift_l: PackedVector2Array = PackedVector2Array([
		Vector2(-w / 2.0 + 30.0, 0.0),
		Vector2(-w / 2.0 + 30.0, -20.0),
		Vector2(-w / 2.0 + 70.0, -8.0),
		Vector2(-w / 2.0 + 80.0, 0.0),
	])
	node.draw_colored_polygon(drift_l, sand_dark)

	# Sand drift on right wall
	var drift_r: PackedVector2Array = PackedVector2Array([
		Vector2(w / 2.0 - 30.0, 0.0),
		Vector2(w / 2.0 - 30.0, -25.0),
		Vector2(w / 2.0 - 65.0, -10.0),
		Vector2(w / 2.0 - 75.0, 0.0),
	])
	node.draw_colored_polygon(drift_r, sand_dark)

	# --- Heavy blast doors (center, partially open) ---
	var door_w: float = w * 0.35
	var door_h: float = bunker_h * 0.85
	var door_y: float = -door_h
	var door_open: float = 12.0 + 3.0 * sin(t * 0.3)

	# Door opening (dark interior)
	node.draw_rect(Rect2(-door_w / 2.0, door_y, door_w, door_h), Color(0.1, 0.07, 0.04))

	# Left blast door (thick, slightly ajar)
	var ldoor_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-door_w / 2.0 - 8.0, door_y),
		Vector2(-door_w / 2.0 + door_open, door_y + 5.0),
		Vector2(-door_w / 2.0 + door_open, 0.0),
		Vector2(-door_w / 2.0 - 8.0, 0.0),
	])
	node.draw_colored_polygon(ldoor_pts, metal_dark)

	# Right blast door
	var rdoor_pts: PackedVector2Array = PackedVector2Array([
		Vector2(door_w / 2.0 + 8.0, door_y),
		Vector2(door_w / 2.0 - door_open, door_y + 5.0),
		Vector2(door_w / 2.0 - door_open, 0.0),
		Vector2(door_w / 2.0 + 8.0, 0.0),
	])
	node.draw_colored_polygon(rdoor_pts, metal_dark)

	# Rivets on left blast door
	for i in range(0, int(door_h), 20):
		var ry: float = door_y + float(i) + 8.0
		node.draw_circle(Vector2(-door_w / 2.0 - 3.0, ry), 2.5, Color(0.45, 0.33, 0.2, 0.7))
		node.draw_circle(Vector2(-door_w / 2.0 + door_open - 3.0, ry), 2.0, Color(0.45, 0.33, 0.2, 0.5))

	# Rivets on right blast door
	for i in range(0, int(door_h), 20):
		var ry: float = door_y + float(i) + 8.0
		node.draw_circle(Vector2(door_w / 2.0 + 3.0, ry), 2.5, Color(0.45, 0.33, 0.2, 0.7))
		node.draw_circle(Vector2(door_w / 2.0 - door_open + 3.0, ry), 2.0, Color(0.45, 0.33, 0.2, 0.5))

	# Military markings on left blast door (stenciled number)
	node.draw_line(Vector2(-door_w / 2.0 - 5.0, door_y + 15.0), Vector2(-door_w / 2.0 - 5.0, door_y + 30.0), Color(0.8, 0.6, 0.1, 0.5), 2.0)
	node.draw_line(Vector2(-door_w / 2.0 - 5.0, door_y + 15.0), Vector2(-door_w / 2.0 + 3.0, door_y + 15.0), Color(0.8, 0.6, 0.1, 0.5), 2.0)
	node.draw_line(Vector2(-door_w / 2.0 - 5.0, door_y + 22.0), Vector2(-door_w / 2.0 + 3.0, door_y + 22.0), Color(0.8, 0.6, 0.1, 0.5), 2.0)

	# --- Warning lights flanking doors (pulsing red) ---
	var warn_pulse: float = 0.4 + 0.5 * sin(t * 3.0)
	node.draw_circle(Vector2(-door_w / 2.0 - 15.0, bunker_y + 12.0), 5.0, Color(0.9, 0.15, 0.1, warn_pulse))
	node.draw_circle(Vector2(-door_w / 2.0 - 15.0, bunker_y + 12.0), 10.0, Color(0.9, 0.1, 0.05, warn_pulse * 0.2))
	node.draw_circle(Vector2(door_w / 2.0 + 15.0, bunker_y + 12.0), 5.0, Color(0.9, 0.15, 0.1, warn_pulse))
	node.draw_circle(Vector2(door_w / 2.0 + 15.0, bunker_y + 12.0), 10.0, Color(0.9, 0.1, 0.05, warn_pulse * 0.2))

	# --- Antenna on roof ---
	var ant_x: float = w / 2.0 - 60.0
	var ant_base: float = bunker_y
	var ant_top: float = -h + 10.0
	node.draw_line(Vector2(ant_x, ant_base), Vector2(ant_x, ant_top), Color(0.5, 0.38, 0.25), 2.0)
	# Cross bars on antenna
	for i in 4:
		var ay: float = ant_top + float(i) * 15.0
		var bar_w: float = 12.0 - float(i) * 2.0
		node.draw_line(Vector2(ant_x - bar_w, ay), Vector2(ant_x + bar_w, ay), Color(0.5, 0.38, 0.25), 1.5)
	# Blinking light at antenna tip
	var ant_blink: float = 0.3 + 0.7 * sin(t * 4.0)
	if ant_blink > 0.5:
		node.draw_circle(Vector2(ant_x, ant_top - 3.0), 3.0, Color(1.0, 0.3, 0.1, ant_blink))

	# --- Periscope / sensor array poking out of sand on roof ---
	var peri_x: float = -w / 2.0 + 55.0
	node.draw_line(Vector2(peri_x, bunker_y), Vector2(peri_x, bunker_y - 20.0), Color(0.45, 0.35, 0.22), 3.0)
	node.draw_rect(Rect2(peri_x - 6.0, bunker_y - 26.0, 12.0, 8.0), Color(0.4, 0.3, 0.2))
	node.draw_circle(Vector2(peri_x, bunker_y - 22.0), 3.0, Color(0.3, 0.6, 0.4, 0.6))

	# --- Ventilation pipes emerging from ground ---
	var vent_x: float = -w / 2.0 + 100.0
	node.draw_line(Vector2(vent_x, 0.0), Vector2(vent_x, -18.0), Color(0.5, 0.4, 0.28), 4.0)
	node.draw_line(Vector2(vent_x, -18.0), Vector2(vent_x + 8.0, -22.0), Color(0.5, 0.4, 0.28), 4.0)
	# Steam puff
	var steam_a: float = 0.15 + 0.1 * sin(t * 2.0)
	node.draw_circle(Vector2(vent_x + 12.0, -26.0 - 4.0 * sin(t * 1.5)), 5.0, Color(0.8, 0.75, 0.65, steam_a))
	node.draw_circle(Vector2(vent_x + 16.0, -30.0 - 3.0 * sin(t * 1.8)), 4.0, Color(0.8, 0.75, 0.65, steam_a * 0.7))

	# Second vent pipe
	var vent2_x: float = w / 2.0 - 90.0
	node.draw_line(Vector2(vent2_x, 0.0), Vector2(vent2_x, -15.0), Color(0.5, 0.4, 0.28), 3.5)
	node.draw_line(Vector2(vent2_x, -15.0), Vector2(vent2_x - 6.0, -20.0), Color(0.5, 0.4, 0.28), 3.5)

	# --- Sandbag wall along front ---
	for i in 8:
		var sbx: float = -w / 2.0 + 20.0 + float(i) * 28.0
		if sbx > w / 2.0 - 30.0:
			break
		# Skip area near door
		if sbx > -door_w / 2.0 - 20.0 and sbx < door_w / 2.0 + 10.0:
			continue
		var sb_pts: PackedVector2Array = PackedVector2Array([
			Vector2(sbx, 0.0),
			Vector2(sbx + 2.0, -10.0),
			Vector2(sbx + 12.0, -12.0),
			Vector2(sbx + 22.0, -10.0),
			Vector2(sbx + 24.0, 0.0),
		])
		node.draw_colored_polygon(sb_pts, Color(0.55, 0.45, 0.3, 0.7))
		# Sandbag outline
		node.draw_line(Vector2(sbx + 2.0, -10.0), Vector2(sbx + 12.0, -12.0), Color(0.45, 0.35, 0.2, 0.5), 1.0)
		node.draw_line(Vector2(sbx + 12.0, -12.0), Vector2(sbx + 22.0, -10.0), Color(0.45, 0.35, 0.2, 0.5), 1.0)

	# Roof edge of bunker
	node.draw_line(Vector2(-w / 2.0 + 30.0, bunker_y), Vector2(w / 2.0 - 30.0, bunker_y), rust_light, 2.5)

	# Dust specks on sand
	for i in 12:
		var dx: float = -w / 2.0 + fmod(float(i) * 37.3, w)
		var dy: float = -fmod(float(i) * 11.7, bunker_h * 0.3)
		node.draw_circle(Vector2(dx, dy), 1.5 + float(i % 3) * 0.5, Color(0.6, 0.48, 0.3, 0.25))


# ── 2. MARKET — Open-air souk with canvas stalls ────────────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	var sand_ground: Color = Color(0.68, 0.55, 0.32)
	var pole_color: Color = Color(0.45, 0.32, 0.18)
	var rope_color: Color = Color(0.55, 0.42, 0.25, 0.6)

	# Canvas top colors for 4 stalls
	var canvas_colors: Array = [
		Color(0.7, 0.35, 0.15, 0.85),
		Color(0.75, 0.6, 0.25, 0.85),
		Color(0.55, 0.35, 0.2, 0.85),
		Color(0.65, 0.5, 0.3, 0.85),
	]

	# Dusty ground slab
	node.draw_rect(Rect2(-w / 2.0, -6.0, w, 6.0), sand_ground)

	# Dust particles at base
	for i in 20:
		var dx: float = -w / 2.0 + fmod(float(i) * 19.7, w)
		var dy: float = -2.0 + fmod(float(i) * 7.3, 5.0)
		var dust_a: float = 0.15 + 0.1 * sin(t * 1.5 + float(i) * 0.8)
		node.draw_circle(Vector2(dx, dy), 1.5 + float(i % 3), Color(0.65, 0.52, 0.32, dust_a))

	# --- 4 market stalls ---
	var stall_count: int = 4
	var stall_w: float = w * 0.2
	var gap: float = (w - stall_w * float(stall_count)) / float(stall_count + 1)

	for s_idx in stall_count:
		var sx: float = -w / 2.0 + gap + float(s_idx) * (stall_w + gap)
		var pole_h: float = h * 0.65 + float(s_idx % 2) * 15.0
		var canvas_y: float = -pole_h

		# Support poles (2 per stall, front)
		node.draw_line(Vector2(sx + 4.0, 0.0), Vector2(sx + 4.0, canvas_y), pole_color, 3.0)
		node.draw_line(Vector2(sx + stall_w - 4.0, 0.0), Vector2(sx + stall_w - 4.0, canvas_y), pole_color, 3.0)

		# Canvas top (irregular trapezoid with wind animation)
		var wind_off: float = 4.0 * sin(t * 1.2 + float(s_idx) * 1.5)
		var canvas_pts: PackedVector2Array = PackedVector2Array([
			Vector2(sx - 6.0 + wind_off, canvas_y - 3.0),
			Vector2(sx + stall_w + 6.0 + wind_off * 0.5, canvas_y),
			Vector2(sx + stall_w + 10.0, canvas_y + 18.0),
			Vector2(sx - 10.0, canvas_y + 15.0),
		])
		node.draw_colored_polygon(canvas_pts, canvas_colors[s_idx])

		# Canvas edge highlight
		node.draw_line(
			Vector2(sx - 6.0 + wind_off, canvas_y - 3.0),
			Vector2(sx + stall_w + 6.0 + wind_off * 0.5, canvas_y),
			Color(1.0, 1.0, 0.9, 0.25), 1.5
		)

		# Ropes / guy-wires from canvas edges to ground
		node.draw_line(Vector2(sx - 8.0, canvas_y + 10.0), Vector2(sx - 14.0, 0.0), rope_color, 1.0)
		node.draw_line(Vector2(sx + stall_w + 8.0, canvas_y + 10.0), Vector2(sx + stall_w + 14.0, 0.0), rope_color, 1.0)

		# Merchant counter (horizontal plank)
		var counter_y: float = -h * 0.2
		node.draw_rect(Rect2(sx, counter_y, stall_w, 5.0), Color(0.5, 0.36, 0.2))
		node.draw_rect(Rect2(sx, counter_y, stall_w, 5.0), Color(0.4, 0.28, 0.15), false, 1.0)

		# Hanging wares from ropes (small shapes dangling)
		for hw in 3:
			var hang_x: float = sx + 8.0 + float(hw) * (stall_w - 16.0) / 2.0
			var hang_y: float = canvas_y + 20.0 + float(hw % 2) * 6.0
			var swing: float = 2.0 * sin(t * 1.0 + float(hw) * 2.0 + float(s_idx))
			# Rope
			node.draw_line(Vector2(hang_x, canvas_y + 15.0), Vector2(hang_x + swing, hang_y), rope_color, 1.0)
			# Ware shape (alternate between circles and rectangles)
			if (hw + s_idx) % 2 == 0:
				node.draw_circle(Vector2(hang_x + swing, hang_y + 3.0), 3.5, Color(0.7, 0.5, 0.2, 0.7))
			else:
				node.draw_rect(Rect2(hang_x + swing - 3.0, hang_y, 6.0, 8.0), Color(0.6, 0.4, 0.25, 0.7))

	# --- Ropes between stalls (connecting at top) ---
	for s_idx in range(0, stall_count - 1):
		var sx1: float = -w / 2.0 + gap + float(s_idx) * (stall_w + gap) + stall_w - 4.0
		var sx2: float = -w / 2.0 + gap + float(s_idx + 1) * (stall_w + gap) + 4.0
		var rope_y: float = -h * 0.55
		var sag: float = 8.0 + 2.0 * sin(t * 0.7 + float(s_idx))
		node.draw_line(Vector2(sx1, rope_y), Vector2((sx1 + sx2) / 2.0, rope_y + sag), rope_color, 1.5)
		node.draw_line(Vector2((sx1 + sx2) / 2.0, rope_y + sag), Vector2(sx2, rope_y), rope_color, 1.5)

	# --- Large haggling board (tall rectangle) ---
	var board_x: float = w / 2.0 - 35.0
	var board_y: float = -h * 0.75
	node.draw_rect(Rect2(board_x, board_y, 28.0, h * 0.55), Color(0.25, 0.18, 0.1))
	node.draw_rect(Rect2(board_x, board_y, 28.0, h * 0.55), Color(0.4, 0.3, 0.18), false, 1.5)
	# Scratched price lines
	for i in 8:
		var ly: float = board_y + 6.0 + float(i) * 12.0
		var line_w: float = 18.0 - float(i % 3) * 4.0
		node.draw_line(Vector2(board_x + 5.0, ly), Vector2(board_x + 5.0 + line_w, ly), Color(0.75, 0.6, 0.3, 0.4), 1.0)

	# Board support post
	node.draw_line(Vector2(board_x + 14.0, board_y + h * 0.55), Vector2(board_x + 14.0, 0.0), pole_color, 3.0)

	# --- Barrel and crate clusters between stalls ---
	# Barrel near stall 1
	var brl_x: float = -w / 2.0 + gap + stall_w + gap * 0.3
	node.draw_rect(Rect2(brl_x, -20.0, 14.0, 20.0), Color(0.45, 0.3, 0.15))
	node.draw_line(Vector2(brl_x, -7.0), Vector2(brl_x + 14.0, -7.0), Color(0.55, 0.4, 0.2), 1.5)
	node.draw_line(Vector2(brl_x, -14.0), Vector2(brl_x + 14.0, -14.0), Color(0.55, 0.4, 0.2), 1.5)
	# Barrel top (arc)
	node.draw_arc(Vector2(brl_x + 7.0, -20.0), 7.0, PI, TAU, 8, Color(0.5, 0.35, 0.2), 1.5)

	# Crate stack near stall 3
	var crt_x: float = -w / 2.0 + gap + 2.0 * (stall_w + gap) + stall_w + gap * 0.2
	node.draw_rect(Rect2(crt_x, -12.0, 16.0, 12.0), Color(0.5, 0.38, 0.22))
	node.draw_rect(Rect2(crt_x + 2.0, -22.0, 12.0, 10.0), Color(0.48, 0.36, 0.2))
	node.draw_rect(Rect2(crt_x, -12.0, 16.0, 12.0), Color(0.4, 0.28, 0.15), false, 1.0)
	node.draw_rect(Rect2(crt_x + 2.0, -22.0, 12.0, 10.0), Color(0.4, 0.28, 0.15), false, 1.0)


# ── 3. BAR — Dusty saloon with swinging doors ───────────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	var wood_main: Color = Color(0.42, 0.28, 0.15)
	var wood_light: Color = Color(0.52, 0.38, 0.22)
	var wood_dark: Color = Color(0.3, 0.2, 0.1)
	var plank_line: Color = Color(0.35, 0.24, 0.12, 0.4)

	# --- Main facade (wooden building) ---
	# First floor
	var floor1_h: float = h * 0.55
	node.draw_rect(Rect2(-w / 2.0, -floor1_h, w, floor1_h), wood_main)

	# Second floor (slightly narrower)
	var floor2_w: float = w * 0.9
	var floor2_h: float = h - floor1_h
	node.draw_rect(Rect2(-floor2_w / 2.0, -h, floor2_w, floor2_h), Color(0.4, 0.27, 0.14))

	# --- Horizontal plank lines across facade ---
	var plank_spacing: float = 12.0
	for i in range(0, int(h), int(plank_spacing)):
		var py: float = -float(i)
		var pw: float = w if py > -floor1_h else floor2_w
		var jitter: float = float(i % 5) * 0.5
		node.draw_line(Vector2(-pw / 2.0, py - jitter), Vector2(pw / 2.0, py - jitter), plank_line, 1.0)

	# Vertical plank divisions
	for i in range(0, 7):
		var px: float = -w / 2.0 + float(i) * w / 6.0
		node.draw_line(Vector2(px, 0.0), Vector2(px, -floor1_h), Color(0.35, 0.24, 0.12, 0.2), 1.0)

	# --- Second floor balcony ---
	var balc_y: float = -floor1_h
	# Balcony floor (extends out)
	node.draw_rect(Rect2(-w / 2.0 - 8.0, balc_y, w + 16.0, 6.0), wood_dark)
	# Railing posts
	for i in range(0, 8):
		var rx: float = -w / 2.0 + float(i) * w / 7.0
		node.draw_line(Vector2(rx, balc_y), Vector2(rx, balc_y - 24.0), wood_light, 2.0)
	# Horizontal railing bars
	node.draw_line(Vector2(-w / 2.0, balc_y - 24.0), Vector2(w / 2.0, balc_y - 24.0), wood_light, 2.5)
	node.draw_line(Vector2(-w / 2.0, balc_y - 12.0), Vector2(w / 2.0, balc_y - 12.0), wood_light, 1.5)

	# --- Shuttered windows on second floor ---
	for i in 3:
		var wx: float = -floor2_w / 2.0 + 20.0 + float(i) * (floor2_w - 40.0) / 2.0
		var wy: float = -h + 15.0
		var ww: float = 28.0
		var wh: float = 30.0
		# Window opening
		node.draw_rect(Rect2(wx, wy, ww, wh), Color(0.2, 0.14, 0.08))
		# Shutters (two sides)
		node.draw_rect(Rect2(wx, wy, ww / 2.0 - 1.0, wh), Color(0.45, 0.32, 0.18))
		node.draw_rect(Rect2(wx + ww / 2.0 + 1.0, wy, ww / 2.0 - 1.0, wh), Color(0.45, 0.32, 0.18))
		# Shutter slats
		for sl in 4:
			var sly: float = wy + 4.0 + float(sl) * 7.0
			node.draw_line(Vector2(wx + 2.0, sly), Vector2(wx + ww / 2.0 - 3.0, sly), plank_line, 1.0)
			node.draw_line(Vector2(wx + ww / 2.0 + 3.0, sly), Vector2(wx + ww - 2.0, sly), plank_line, 1.0)
		# Window frame
		node.draw_rect(Rect2(wx, wy, ww, wh), wood_dark, false, 1.5)

	# --- "SALOON" sign above entrance ---
	var sign_w: float = 80.0
	var sign_h: float = 18.0
	var sign_y: float = -floor1_h - 10.0
	node.draw_rect(Rect2(-sign_w / 2.0, sign_y, sign_w, sign_h), Color(0.55, 0.2, 0.1))
	node.draw_rect(Rect2(-sign_w / 2.0, sign_y, sign_w, sign_h), Color(0.7, 0.35, 0.15), false, 1.5)
	# "SALOON" text approximated as horizontal dashes
	var letter_x: float = -sign_w / 2.0 + 8.0
	for i in 6:
		var lx: float = letter_x + float(i) * 11.0
		node.draw_line(Vector2(lx, sign_y + 5.0), Vector2(lx + 7.0, sign_y + 5.0), Color(0.9, 0.8, 0.5, 0.8), 2.0)
		node.draw_line(Vector2(lx, sign_y + 9.0), Vector2(lx + 7.0, sign_y + 9.0), Color(0.9, 0.8, 0.5, 0.6), 1.5)
		node.draw_line(Vector2(lx, sign_y + 13.0), Vector2(lx + 7.0, sign_y + 13.0), Color(0.9, 0.8, 0.5, 0.8), 2.0)

	# --- Entrance with swinging half-doors ---
	var ent_w: float = 40.0
	var ent_h: float = floor1_h * 0.65
	var ent_y: float = -ent_h
	# Dark interior
	node.draw_rect(Rect2(-ent_w / 2.0, ent_y, ent_w, ent_h), Color(0.15, 0.1, 0.06))

	# Swinging doors (half-height, angled with animation)
	var swing_angle: float = 0.08 * sin(t * 1.5)
	var half_door_h: float = ent_h * 0.45
	var half_door_w: float = ent_w / 2.0 - 2.0
	# Left swinging door
	var ld_x: float = -ent_w / 2.0
	var ld_pts: PackedVector2Array = PackedVector2Array([
		Vector2(ld_x, ent_y + ent_h - half_door_h),
		Vector2(ld_x + half_door_w + swing_angle * 30.0, ent_y + ent_h - half_door_h + 2.0),
		Vector2(ld_x + half_door_w + swing_angle * 30.0, ent_y + ent_h),
		Vector2(ld_x, ent_y + ent_h),
	])
	node.draw_colored_polygon(ld_pts, wood_light)
	# Right swinging door
	var rd_x: float = ent_w / 2.0
	var rd_pts: PackedVector2Array = PackedVector2Array([
		Vector2(rd_x, ent_y + ent_h - half_door_h),
		Vector2(rd_x - half_door_w - swing_angle * 30.0, ent_y + ent_h - half_door_h + 2.0),
		Vector2(rd_x - half_door_w - swing_angle * 30.0, ent_y + ent_h),
		Vector2(rd_x, ent_y + ent_h),
	])
	node.draw_colored_polygon(rd_pts, wood_light)
	# Door hinges
	node.draw_circle(Vector2(ld_x, ent_y + ent_h - half_door_h + 5.0), 2.5, Color(0.5, 0.4, 0.2))
	node.draw_circle(Vector2(rd_x, ent_y + ent_h - half_door_h + 5.0), 2.5, Color(0.5, 0.4, 0.2))

	# --- Trophy shapes visible through window (skull/antler) ---
	# Large first-floor window to the right of entrance
	var tw_x: float = ent_w / 2.0 + 15.0
	var tw_y: float = -floor1_h * 0.7
	var tw_w: float = 35.0
	var tw_h: float = 30.0
	node.draw_rect(Rect2(tw_x, tw_y, tw_w, tw_h), Color(0.25, 0.18, 0.1, 0.6))
	node.draw_rect(Rect2(tw_x, tw_y, tw_w, tw_h), wood_dark, false, 1.5)
	# Skull shape (circle + jaw)
	var skull_x: float = tw_x + tw_w / 2.0
	var skull_y: float = tw_y + tw_h / 2.0
	node.draw_circle(Vector2(skull_x, skull_y - 3.0), 7.0, Color(0.75, 0.7, 0.6, 0.5))
	node.draw_rect(Rect2(skull_x - 4.0, skull_y + 2.0, 8.0, 5.0), Color(0.75, 0.7, 0.6, 0.4))
	# Antler lines
	node.draw_line(Vector2(skull_x - 7.0, skull_y - 6.0), Vector2(skull_x - 16.0, skull_y - 14.0), Color(0.7, 0.6, 0.5, 0.4), 1.5)
	node.draw_line(Vector2(skull_x - 16.0, skull_y - 14.0), Vector2(skull_x - 20.0, skull_y - 10.0), Color(0.7, 0.6, 0.5, 0.4), 1.5)
	node.draw_line(Vector2(skull_x + 7.0, skull_y - 6.0), Vector2(skull_x + 16.0, skull_y - 14.0), Color(0.7, 0.6, 0.5, 0.4), 1.5)
	node.draw_line(Vector2(skull_x + 16.0, skull_y - 14.0), Vector2(skull_x + 20.0, skull_y - 10.0), Color(0.7, 0.6, 0.5, 0.4), 1.5)

	# --- Hitching post out front ---
	var pole_color: Color = Color(0.45, 0.32, 0.18)
	var hitch_y: float = -16.0
	node.draw_line(Vector2(-w / 2.0 + 20.0, 0.0), Vector2(-w / 2.0 + 20.0, hitch_y), pole_color, 2.5)
	node.draw_line(Vector2(-w / 2.0 + 60.0, 0.0), Vector2(-w / 2.0 + 60.0, hitch_y), pole_color, 2.5)
	node.draw_line(Vector2(-w / 2.0 + 18.0, hitch_y), Vector2(-w / 2.0 + 62.0, hitch_y), pole_color, 3.0)

	# --- Lantern hanging beside door ---
	var lantern_x: float = -ent_w / 2.0 - 12.0
	var lantern_y: float = -floor1_h * 0.4
	node.draw_line(Vector2(lantern_x, lantern_y - 15.0), Vector2(lantern_x, lantern_y), Color(0.4, 0.3, 0.18), 1.5)
	var flicker: float = 0.5 + 0.4 * sin(t * 5.0) + 0.1 * sin(t * 13.0)
	node.draw_circle(Vector2(lantern_x, lantern_y + 4.0), 5.0, Color(1.0, 0.75, 0.25, flicker))
	node.draw_circle(Vector2(lantern_x, lantern_y + 4.0), 12.0, Color(1.0, 0.6, 0.15, flicker * 0.15))
	# Lantern body
	node.draw_rect(Rect2(lantern_x - 3.0, lantern_y - 1.0, 6.0, 10.0), Color(0.5, 0.4, 0.2, 0.4))

	# Second lantern on other side
	var lantern2_x: float = ent_w / 2.0 + 12.0
	node.draw_line(Vector2(lantern2_x, lantern_y - 15.0), Vector2(lantern2_x, lantern_y), Color(0.4, 0.3, 0.18), 1.5)
	var flicker2: float = 0.5 + 0.4 * sin(t * 5.0 + 1.5) + 0.1 * sin(t * 11.0)
	node.draw_circle(Vector2(lantern2_x, lantern_y + 4.0), 5.0, Color(1.0, 0.75, 0.25, flicker2))
	node.draw_circle(Vector2(lantern2_x, lantern_y + 4.0), 12.0, Color(1.0, 0.6, 0.15, flicker2 * 0.15))

	# --- Barrel beside entrance ---
	var barrel_x: float = ent_w / 2.0 + 55.0
	node.draw_rect(Rect2(barrel_x, -22.0, 16.0, 22.0), Color(0.45, 0.3, 0.15))
	node.draw_line(Vector2(barrel_x, -8.0), Vector2(barrel_x + 16.0, -8.0), Color(0.55, 0.4, 0.2), 1.5)
	node.draw_line(Vector2(barrel_x, -16.0), Vector2(barrel_x + 16.0, -16.0), Color(0.55, 0.4, 0.2), 1.5)
	node.draw_arc(Vector2(barrel_x + 8.0, -22.0), 8.0, PI, TAU, 8, Color(0.5, 0.35, 0.2), 1.5)

	# --- Dust cloud near ground (animated) ---
	for i in 8:
		var cloud_x: float = -w / 2.0 + 10.0 + fmod(float(i) * 41.0 + t * 8.0, w + 20.0)
		var cloud_a: float = 0.1 + 0.08 * sin(t * 2.0 + float(i) * 1.3)
		node.draw_circle(Vector2(cloud_x, -2.0 - float(i % 3) * 2.0), 4.0 + float(i % 4) * 2.0, Color(0.65, 0.52, 0.34, cloud_a))

	# Roof peak
	var peak: PackedVector2Array = PackedVector2Array([
		Vector2(-floor2_w / 2.0, -h),
		Vector2(0.0, -h - 15.0),
		Vector2(floor2_w / 2.0, -h),
	])
	node.draw_colored_polygon(peak, Color(0.38, 0.25, 0.13))
	node.draw_line(Vector2(-floor2_w / 2.0, -h), Vector2(0.0, -h - 15.0), wood_dark, 2.0)
	node.draw_line(Vector2(0.0, -h - 15.0), Vector2(floor2_w / 2.0, -h), wood_dark, 2.0)


# ── 4. GARAGE — Military motor pool with camo netting ────────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	var concrete_color: Color = Color(0.6, 0.5, 0.35)
	var concrete_dark: Color = Color(0.5, 0.4, 0.28)
	var metal_frame: Color = Color(0.4, 0.32, 0.2)

	# --- Sand-colored concrete structure ---
	var struct_h: float = h * 0.7
	var struct_y: float = -struct_h
	node.draw_rect(Rect2(-w / 2.0, struct_y, w, struct_h), concrete_color)

	# Concrete texture (subtle horizontal lines)
	for i in range(0, int(struct_h), 10):
		var py: float = struct_y + float(i)
		node.draw_line(Vector2(-w / 2.0, py), Vector2(w / 2.0, py), Color(0.52, 0.42, 0.3, 0.2), 1.0)

	# --- 3 vehicle bays (open sides) ---
	var bay_count: int = 3
	var bay_margin: float = 12.0
	var total_margin: float = bay_margin * float(bay_count + 1)
	var bay_w: float = (w - total_margin) / float(bay_count)
	var bay_h: float = struct_h * 0.8
	var bay_y: float = -bay_h

	for b_idx in bay_count:
		var bx: float = -w / 2.0 + bay_margin + float(b_idx) * (bay_w + bay_margin)

		# Bay interior (dark)
		node.draw_rect(Rect2(bx, bay_y, bay_w, bay_h), Color(0.15, 0.12, 0.08))

		# Bay divider pillar on left side
		node.draw_rect(Rect2(bx - 4.0, struct_y, 5.0, struct_h), concrete_dark)

		# Vehicle silhouette inside bay (simple rectangles)
		var veh_w: float = bay_w * 0.7
		var veh_h: float = bay_h * 0.35
		var veh_x: float = bx + (bay_w - veh_w) / 2.0
		var veh_y: float = -veh_h - 4.0
		node.draw_rect(Rect2(veh_x, veh_y, veh_w, veh_h), Color(0.22, 0.2, 0.14, 0.6))
		# Wheels
		node.draw_circle(Vector2(veh_x + 8.0, -4.0), 5.0, Color(0.18, 0.15, 0.1, 0.6))
		node.draw_circle(Vector2(veh_x + veh_w - 8.0, -4.0), 5.0, Color(0.18, 0.15, 0.1, 0.6))

	# Right-side pillar
	var last_bx: float = -w / 2.0 + bay_margin + 2.0 * (bay_w + bay_margin) + bay_w
	node.draw_rect(Rect2(last_bx - 1.0, struct_y, 5.0, struct_h), concrete_dark)

	# --- Tire/track marks on ground ---
	for i in 6:
		var tx: float = -w / 2.0 + 30.0 + float(i) * 40.0
		node.draw_line(Vector2(tx, 0.0), Vector2(tx + 25.0, 0.0), Color(0.3, 0.25, 0.15, 0.3), 2.0)
		node.draw_line(Vector2(tx + 3.0, -2.0), Vector2(tx + 22.0, -2.0), Color(0.3, 0.25, 0.15, 0.2), 1.5)

	# --- Ammo crate stacks (left of first bay) ---
	var crate_x: float = -w / 2.0 + 8.0
	for row in 3:
		for col in range(0, 3 - row):
			var cx: float = crate_x + float(col) * 14.0 + float(row) * 7.0
			var cy: float = -float(row) * 12.0 - 12.0
			node.draw_rect(Rect2(cx, cy, 12.0, 10.0), Color(0.28, 0.3, 0.2))
			node.draw_rect(Rect2(cx, cy, 12.0, 10.0), Color(0.22, 0.24, 0.16), false, 1.0)
			# Marking on crate
			node.draw_line(Vector2(cx + 3.0, cy + 3.0), Vector2(cx + 9.0, cy + 3.0), Color(0.6, 0.5, 0.1, 0.4), 1.0)

	# --- Weapons rack on back wall (visible inside bay 2) ---
	var rack_x: float = -w / 2.0 + bay_margin + (bay_w + bay_margin) + bay_w * 0.15
	var rack_y: float = struct_y + 8.0
	# Vertical posts
	node.draw_line(Vector2(rack_x, rack_y), Vector2(rack_x, rack_y + 50.0), Color(0.4, 0.35, 0.2, 0.5), 2.0)
	node.draw_line(Vector2(rack_x + 35.0, rack_y), Vector2(rack_x + 35.0, rack_y + 50.0), Color(0.4, 0.35, 0.2, 0.5), 2.0)
	# Horizontal weapon shapes
	for i in 4:
		var wy: float = rack_y + 6.0 + float(i) * 12.0
		node.draw_line(Vector2(rack_x + 2.0, wy), Vector2(rack_x + 33.0, wy), Color(0.35, 0.3, 0.2, 0.5), 2.5)
		# Weapon detail (handle/stock)
		node.draw_line(Vector2(rack_x + 28.0, wy), Vector2(rack_x + 33.0, wy + 4.0), Color(0.35, 0.3, 0.2, 0.4), 2.0)

	# --- Generator unit on right side ---
	var gen_x: float = w / 2.0 - 40.0
	var gen_y: float = -30.0
	node.draw_rect(Rect2(gen_x, gen_y, 28.0, 30.0), Color(0.35, 0.32, 0.25))
	node.draw_rect(Rect2(gen_x, gen_y, 28.0, 30.0), Color(0.3, 0.27, 0.2), false, 1.5)
	# Exhaust pipe
	node.draw_line(Vector2(gen_x + 20.0, gen_y), Vector2(gen_x + 20.0, gen_y - 20.0), Color(0.4, 0.35, 0.25), 3.0)
	# Exhaust smoke
	var smoke_a: float = 0.12 + 0.08 * sin(t * 1.8)
	node.draw_circle(Vector2(gen_x + 20.0, gen_y - 24.0 - 3.0 * sin(t * 1.2)), 5.0, Color(0.6, 0.55, 0.45, smoke_a))
	node.draw_circle(Vector2(gen_x + 22.0, gen_y - 30.0 - 2.0 * sin(t * 1.5)), 4.0, Color(0.6, 0.55, 0.45, smoke_a * 0.6))
	# Generator vibration indicator
	var vib: float = 1.0 + 0.5 * sin(t * 8.0)
	node.draw_circle(Vector2(gen_x + 8.0, gen_y + 10.0), 3.0, Color(0.2, 0.7, 0.2, 0.4 * vib))

	# --- Military insignia on wall (star shape using lines) ---
	var ins_x: float = -w / 2.0 + bay_margin + 2.0 * (bay_w + bay_margin) + bay_w * 0.5
	var ins_y: float = struct_y + 15.0
	var star_r: float = 10.0
	for i in 5:
		var angle1: float = -PI / 2.0 + float(i) * TAU / 5.0
		var angle2: float = -PI / 2.0 + float(i + 2) * TAU / 5.0
		node.draw_line(
			Vector2(ins_x + cos(angle1) * star_r, ins_y + sin(angle1) * star_r),
			Vector2(ins_x + cos(angle2) * star_r, ins_y + sin(angle2) * star_r),
			Color(0.6, 0.5, 0.15, 0.5), 1.5
		)

	# --- Work bench with tools (inside bay 1) ---
	var bench_x: float = -w / 2.0 + bay_margin + bay_w * 0.1
	var bench_y: float = -bay_h * 0.45
	node.draw_rect(Rect2(bench_x, bench_y, bay_w * 0.4, 5.0), Color(0.4, 0.32, 0.2, 0.5))
	# Tool shapes on bench
	node.draw_line(Vector2(bench_x + 5.0, bench_y - 2.0), Vector2(bench_x + 5.0, bench_y - 12.0), Color(0.5, 0.45, 0.35, 0.4), 2.0)
	node.draw_line(Vector2(bench_x + 15.0, bench_y - 1.0), Vector2(bench_x + 22.0, bench_y - 8.0), Color(0.5, 0.45, 0.35, 0.4), 2.0)
	node.draw_circle(Vector2(bench_x + 30.0, bench_y - 3.0), 3.0, Color(0.5, 0.45, 0.35, 0.4))

	# --- Camo netting draped over the top ---
	# Multiple irregular polygon patches in green/brown/tan
	var net_y_base: float = struct_y - 5.0
	var camo_patches: Array = [
		# [x_offset, width, height, color]
		[-w / 2.0 - 5.0, w * 0.28, 22.0, Color(0.25, 0.35, 0.18, 0.7)],
		[-w * 0.25, w * 0.22, 18.0, Color(0.45, 0.35, 0.2, 0.65)],
		[-w * 0.05, w * 0.3, 24.0, Color(0.3, 0.38, 0.2, 0.7)],
		[w * 0.2, w * 0.25, 20.0, Color(0.5, 0.4, 0.25, 0.65)],
		[w * 0.4, w * 0.18, 16.0, Color(0.28, 0.32, 0.18, 0.7)],
	]

	for patch in camo_patches:
		var px: float = patch[0]
		var pw: float = patch[1]
		var ph: float = patch[2]
		var pc: Color = patch[3]
		var drape: float = 4.0 * sin(t * 0.3 + px * 0.02)
		var net_pts: PackedVector2Array = PackedVector2Array([
			Vector2(px, net_y_base + 3.0 + drape),
			Vector2(px + pw * 0.3, net_y_base - ph * 0.6),
			Vector2(px + pw * 0.6, net_y_base - ph + drape * 0.5),
			Vector2(px + pw, net_y_base - ph * 0.4),
			Vector2(px + pw + 5.0, net_y_base + 5.0),
		])
		node.draw_colored_polygon(net_pts, pc)

	# Netting rope lines across top
	for i in 8:
		var nx: float = -w / 2.0 + float(i) * w / 7.0
		var sag_n: float = 3.0 + 2.0 * sin(t * 0.5 + float(i))
		node.draw_line(
			Vector2(nx, net_y_base),
			Vector2(nx + w / 7.0, net_y_base - sag_n),
			Color(0.35, 0.3, 0.2, 0.4), 1.0
		)

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, struct_y), Vector2(w / 2.0, struct_y), metal_frame, 2.5)


# ── 5. UNIQUE — Arena / Colosseum ────────────────────────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	var wall_color: Color = Color(0.55, 0.4, 0.25)
	var wall_dark: Color = Color(0.4, 0.28, 0.18)
	var _wall_light: Color = Color(0.65, 0.5, 0.32)
	var sand_floor: Color = Color(0.7, 0.58, 0.35)
	var banner_colors: Array = [
		Color(0.8, 0.2, 0.15),
		Color(0.2, 0.3, 0.7),
		Color(0.7, 0.6, 0.1),
		Color(0.15, 0.5, 0.2),
	]

	# --- Oval/curved wall structure (approximated with segments) ---
	var seg_count: int = 16
	var arena_rx: float = w / 2.0
	var arena_ry_top: float = h * 0.15
	var wall_height: float = h * 0.75

	# Draw the curved wall as filled segments
	for i in seg_count:
		var angle1: float = PI + float(i) * PI / float(seg_count)
		var angle2: float = PI + float(i + 1) * PI / float(seg_count)
		var x1: float = cos(angle1) * arena_rx
		var x2: float = cos(angle2) * arena_rx
		var y_curve1: float = sin(angle1) * arena_ry_top
		var y_curve2: float = sin(angle2) * arena_ry_top

		# Wall segment polygon
		var seg_pts: PackedVector2Array = PackedVector2Array([
			Vector2(x1, -wall_height + y_curve1),
			Vector2(x2, -wall_height + y_curve2),
			Vector2(x2, 0.0),
			Vector2(x1, 0.0),
		])
		# Alternating shade for depth
		var shade: float = 0.03 * float(i % 2)
		node.draw_colored_polygon(seg_pts, Color(wall_color.r + shade, wall_color.g + shade, wall_color.b + shade, 1.0))

	# Wall top edge (curved line)
	for i in seg_count:
		var angle1: float = PI + float(i) * PI / float(seg_count)
		var angle2: float = PI + float(i + 1) * PI / float(seg_count)
		node.draw_line(
			Vector2(cos(angle1) * arena_rx, -wall_height + sin(angle1) * arena_ry_top),
			Vector2(cos(angle2) * arena_rx, -wall_height + sin(angle2) * arena_ry_top),
			wall_dark, 3.0
		)

	# --- Arched openings (4 arches showing interior) ---
	var arch_count: int = 4
	var arch_spacing: float = w / float(arch_count + 1)
	for a_idx in arch_count:
		var ax: float = -w / 2.0 + arch_spacing * float(a_idx + 1)
		var arch_w: float = 30.0
		var arch_h: float = wall_height * 0.5
		var arch_y: float = -arch_h

		# Dark interior through arch
		node.draw_rect(Rect2(ax - arch_w / 2.0, arch_y, arch_w, arch_h), Color(0.12, 0.08, 0.05))

		# Arch top (semicircle approximated with polygon)
		var arch_pts: PackedVector2Array = PackedVector2Array()
		var arch_segs: int = 8
		for seg in range(arch_segs + 1):
			var aangle: float = PI + float(seg) * PI / float(arch_segs)
			arch_pts.append(Vector2(ax + cos(aangle) * arch_w / 2.0, arch_y + sin(aangle) * arch_w / 2.0))
		arch_pts.append(Vector2(ax + arch_w / 2.0, arch_y))
		arch_pts.append(Vector2(ax - arch_w / 2.0, arch_y))
		node.draw_colored_polygon(arch_pts, wall_color)

		# Arch outline
		for seg in arch_segs:
			var aangle1: float = PI + float(seg) * PI / float(arch_segs)
			var aangle2: float = PI + float(seg + 1) * PI / float(arch_segs)
			node.draw_line(
				Vector2(ax + cos(aangle1) * arch_w / 2.0, arch_y + sin(aangle1) * arch_w / 2.0),
				Vector2(ax + cos(aangle2) * arch_w / 2.0, arch_y + sin(aangle2) * arch_w / 2.0),
				wall_dark, 2.0
			)

		# Tiered seating visible through arch (rows of small lines)
		for row in 4:
			var seat_y: float = arch_y + 8.0 + float(row) * 10.0
			var seat_w_inner: float = arch_w - 8.0 - float(row) * 3.0
			node.draw_line(
				Vector2(ax - seat_w_inner / 2.0, seat_y),
				Vector2(ax + seat_w_inner / 2.0, seat_y),
				Color(0.5, 0.38, 0.25, 0.4), 2.0
			)
			# Tiny crowd figures on seats
			for fig in range(0, int(seat_w_inner / 6.0)):
				var fx: float = ax - seat_w_inner / 2.0 + 3.0 + float(fig) * 6.0
				node.draw_circle(Vector2(fx, seat_y - 3.0), 1.5, Color(0.6, 0.5, 0.35, 0.35))

		# Dust inside arena (animated, visible through arch)
		var dust_a: float = 0.1 + 0.08 * sin(t * 1.5 + float(a_idx) * 2.0)
		node.draw_circle(Vector2(ax - 5.0, -15.0), 8.0, Color(0.7, 0.6, 0.4, dust_a))
		node.draw_circle(Vector2(ax + 7.0, -10.0), 6.0, Color(0.7, 0.6, 0.4, dust_a * 0.7))

	# --- Large arched entrance gate (center) ---
	var gate_w: float = 50.0
	var gate_h: float = wall_height * 0.7
	var gate_y: float = -gate_h
	# Gate opening (deep dark)
	node.draw_rect(Rect2(-gate_w / 2.0, gate_y, gate_w, gate_h), Color(0.08, 0.05, 0.03))

	# Gate arch top
	var gate_arch: PackedVector2Array = PackedVector2Array()
	var gate_segs: int = 10
	for seg in range(gate_segs + 1):
		var gaangle: float = PI + float(seg) * PI / float(gate_segs)
		gate_arch.append(Vector2(cos(gaangle) * gate_w / 2.0, gate_y + sin(gaangle) * gate_w / 2.0))
	gate_arch.append(Vector2(gate_w / 2.0, gate_y))
	gate_arch.append(Vector2(-gate_w / 2.0, gate_y))
	node.draw_colored_polygon(gate_arch, wall_color)

	# Gate arch outline
	for seg in gate_segs:
		var ga1: float = PI + float(seg) * PI / float(gate_segs)
		var ga2: float = PI + float(seg + 1) * PI / float(gate_segs)
		node.draw_line(
			Vector2(cos(ga1) * gate_w / 2.0, gate_y + sin(ga1) * gate_w / 2.0),
			Vector2(cos(ga2) * gate_w / 2.0, gate_y + sin(ga2) * gate_w / 2.0),
			wall_dark, 2.5
		)

	# Gate frame pillars
	node.draw_rect(Rect2(-gate_w / 2.0 - 6.0, gate_y, 8.0, gate_h), wall_dark)
	node.draw_rect(Rect2(gate_w / 2.0 - 2.0, gate_y, 8.0, gate_h), wall_dark)

	# --- Torch-style lights on pillars flanking entrance ---
	for side_val in [1.0, -1.0]:
		var torch_x: float = side_val * (gate_w / 2.0 + 2.0)
		var torch_y: float = gate_y + 10.0
		# Torch post
		node.draw_line(Vector2(torch_x, gate_y + gate_h * 0.3), Vector2(torch_x, torch_y), Color(0.5, 0.35, 0.2), 3.0)
		# Flame (animated)
		var flame_h: float = 10.0 + 3.0 * sin(t * 4.0 + side_val * 2.0)
		var flame_w_val: float = 5.0 + 2.0 * sin(t * 6.0 + side_val)
		var flame_pts: PackedVector2Array = PackedVector2Array([
			Vector2(torch_x - flame_w_val, torch_y),
			Vector2(torch_x, torch_y - flame_h),
			Vector2(torch_x + flame_w_val, torch_y),
		])
		node.draw_colored_polygon(flame_pts, Color(1.0, 0.6, 0.15, 0.8))
		# Inner flame
		var inner_pts: PackedVector2Array = PackedVector2Array([
			Vector2(torch_x - flame_w_val * 0.5, torch_y),
			Vector2(torch_x, torch_y - flame_h * 0.7),
			Vector2(torch_x + flame_w_val * 0.5, torch_y),
		])
		node.draw_colored_polygon(inner_pts, Color(1.0, 0.9, 0.4, 0.7))
		# Glow
		node.draw_circle(Vector2(torch_x, torch_y - 3.0), 14.0, Color(1.0, 0.5, 0.1, 0.12))

	# --- Championship trophy silhouette above gate ---
	var trophy_x: float = 0.0
	var trophy_y: float = -wall_height - 10.0
	# Cup body
	node.draw_rect(Rect2(trophy_x - 8.0, trophy_y, 16.0, 18.0), Color(0.8, 0.65, 0.2, 0.7))
	# Cup stem
	node.draw_rect(Rect2(trophy_x - 3.0, trophy_y + 18.0, 6.0, 8.0), Color(0.75, 0.6, 0.18, 0.6))
	# Cup base
	node.draw_rect(Rect2(trophy_x - 10.0, trophy_y + 26.0, 20.0, 4.0), Color(0.75, 0.6, 0.18, 0.6))
	# Cup handles
	node.draw_arc(Vector2(trophy_x - 8.0, trophy_y + 8.0), 6.0, PI * 0.5, PI * 1.5, 6, Color(0.8, 0.65, 0.2, 0.6), 2.0)
	node.draw_arc(Vector2(trophy_x + 8.0, trophy_y + 8.0), 6.0, -PI * 0.5, PI * 0.5, 6, Color(0.8, 0.65, 0.2, 0.6), 2.0)
	# Shine
	node.draw_line(Vector2(trophy_x - 4.0, trophy_y + 3.0), Vector2(trophy_x - 2.0, trophy_y + 12.0), Color(1.0, 0.95, 0.6, 0.4), 1.5)

	# --- Banners hanging from top (flutter with sin(t)) ---
	for b_idx in 4:
		var bx: float = -w / 2.0 + 30.0 + float(b_idx) * (w - 60.0) / 3.0
		var by: float = -wall_height + 5.0
		var b_flutter: float = 5.0 * sin(t * 2.0 + float(b_idx) * 1.8)
		var b_h: float = 35.0
		var b_w: float = 14.0
		var b_pts: PackedVector2Array = PackedVector2Array([
			Vector2(bx, by),
			Vector2(bx + b_w, by),
			Vector2(bx + b_w + b_flutter * 0.3, by + b_h),
			Vector2(bx + b_flutter * 0.3, by + b_h),
		])
		node.draw_colored_polygon(b_pts, banner_colors[b_idx])
		# Banner pole attachment
		node.draw_line(Vector2(bx, by), Vector2(bx + b_w, by), wall_dark, 2.0)

	# --- Ticket booth beside entrance ---
	var booth_x: float = gate_w / 2.0 + 25.0
	var booth_y: float = -40.0
	# Booth body
	node.draw_rect(Rect2(booth_x, booth_y, 25.0, 40.0), Color(0.5, 0.38, 0.22))
	node.draw_rect(Rect2(booth_x, booth_y, 25.0, 40.0), wall_dark, false, 1.5)
	# Window in booth
	node.draw_rect(Rect2(booth_x + 4.0, booth_y + 8.0, 17.0, 12.0), Color(0.3, 0.4, 0.5, 0.4))
	node.draw_rect(Rect2(booth_x + 4.0, booth_y + 8.0, 17.0, 12.0), wall_dark, false, 1.0)
	# Counter shelf
	node.draw_rect(Rect2(booth_x - 3.0, booth_y + 20.0, 28.0, 3.0), wall_dark)
	# Roof
	var booth_roof: PackedVector2Array = PackedVector2Array([
		Vector2(booth_x - 4.0, booth_y),
		Vector2(booth_x + 12.5, booth_y - 8.0),
		Vector2(booth_x + 29.0, booth_y),
	])
	node.draw_colored_polygon(booth_roof, Color(0.6, 0.3, 0.15))

	# --- Horizontal bands on arena wall ---
	for i in 3:
		var band_y: float = -wall_height * 0.25 * float(i + 1)
		node.draw_line(Vector2(-w / 2.0, band_y), Vector2(w / 2.0, band_y), Color(0.48, 0.35, 0.22, 0.4), 2.0)

	# --- Sand floor at base ---
	node.draw_rect(Rect2(-w / 2.0, -4.0, w, 4.0), sand_floor)

	# Dust particles on ground
	for i in 10:
		var dx: float = -w / 2.0 + fmod(float(i) * 29.3 + t * 5.0, w)
		var dy: float = -2.0 + fmod(float(i) * 3.7, 3.0)
		var d_a: float = 0.12 + 0.08 * sin(t * 1.8 + float(i))
		node.draw_circle(Vector2(dx, dy), 2.0 + float(i % 3), Color(0.65, 0.55, 0.35, d_a))
