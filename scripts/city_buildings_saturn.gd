class_name CityBuildingsSaturn
extends RefCounted

# Saturn — "Titan Labs" research station
# Clean whites, sterile blues, holographic displays, robotic precision.
# Colors: clean white (0.9, 0.9, 0.92), lab blue (0.4, 0.6, 0.85), chrome silver.

# ── 1. HANGAR — Clean white docking bay with robotic arms ─────────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	# Main pristine white body
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.88, 0.89, 0.91))

	# Clean geometric panel lines — horizontal
	var hpanel_count: int = int(h / 18.0)
	for i in hpanel_count:
		var py: float = -h + float(i) * 18.0
		node.draw_line(Vector2(-w / 2.0, py), Vector2(w / 2.0, py), Color(0.78, 0.79, 0.82, 0.3), 1.0)

	# Vertical seams — 5 evenly spaced
	for i in 5:
		var sx: float = -w / 2.0 + w * (float(i + 1) / 6.0)
		node.draw_line(Vector2(sx, -h), Vector2(sx, 0.0), Color(0.78, 0.79, 0.82, 0.25), 1.0)

	# Blue LED accent strips along top edge
	var led_pulse: float = 0.5 + 0.3 * sin(t * 3.0)
	node.draw_line(Vector2(-w / 2.0, -h + 2.0), Vector2(w / 2.0, -h + 2.0), Color(0.3, 0.55, 0.95, led_pulse), 2.0)
	# LED strip along bottom edge
	node.draw_line(Vector2(-w / 2.0, -2.0), Vector2(w / 2.0, -2.0), Color(0.3, 0.55, 0.95, led_pulse * 0.7), 1.5)

	# Bay door — smooth clean rectangle
	var door_w: float = w * 0.45
	var door_h: float = h * 0.6
	var door_x: float = -door_w / 2.0
	var door_y: float = -door_h
	node.draw_rect(Rect2(door_x, door_y, door_w, door_h), Color(0.72, 0.74, 0.78))
	# Subtle panel lines on door
	for i in 4:
		var dpy: float = door_y + float(i + 1) * door_h / 5.0
		node.draw_line(Vector2(door_x + 3.0, dpy), Vector2(door_x + door_w - 3.0, dpy), Color(0.65, 0.67, 0.7, 0.4), 1.0)
	# Door center seam
	node.draw_line(Vector2(0.0, door_y + 4.0), Vector2(0.0, -4.0), Color(0.65, 0.67, 0.7, 0.5), 1.0)
	# Door frame
	node.draw_rect(Rect2(door_x, door_y, door_w, door_h), Color(0.82, 0.84, 0.88, 0.6), false, 2.0)

	# Robotic arm 1 — left wall, jointed
	var arm1_base_x: float = -w / 2.0 + 15.0
	var arm1_base_y: float = -h * 0.7
	var arm1_sway: float = sin(t * 0.5) * 8.0
	var arm1_mid_x: float = arm1_base_x + 25.0
	var arm1_mid_y: float = arm1_base_y + 20.0 + arm1_sway * 0.3
	var arm1_end_x: float = arm1_mid_x + 20.0 + arm1_sway
	var arm1_end_y: float = arm1_mid_y + 15.0
	node.draw_line(Vector2(arm1_base_x, arm1_base_y), Vector2(arm1_mid_x, arm1_mid_y), Color(0.82, 0.84, 0.88), 4.0)
	node.draw_line(Vector2(arm1_mid_x, arm1_mid_y), Vector2(arm1_end_x, arm1_end_y), Color(0.82, 0.84, 0.88), 3.0)
	node.draw_circle(Vector2(arm1_base_x, arm1_base_y), 5.0, Color(0.6, 0.62, 0.66))
	node.draw_circle(Vector2(arm1_mid_x, arm1_mid_y), 4.0, Color(0.4, 0.6, 0.85, 0.8))
	# Gripper
	node.draw_line(Vector2(arm1_end_x - 4.0, arm1_end_y), Vector2(arm1_end_x - 6.0, arm1_end_y + 8.0), Color(0.7, 0.72, 0.76), 2.0)
	node.draw_line(Vector2(arm1_end_x + 4.0, arm1_end_y), Vector2(arm1_end_x + 6.0, arm1_end_y + 8.0), Color(0.7, 0.72, 0.76), 2.0)

	# Robotic arm 2 — right wall
	var arm2_base_x: float = w / 2.0 - 15.0
	var arm2_base_y: float = -h * 0.65
	var arm2_sway: float = sin(t * 0.5 + 2.0) * 7.0
	var arm2_mid_x: float = arm2_base_x - 22.0
	var arm2_mid_y: float = arm2_base_y + 18.0 + arm2_sway * 0.3
	var arm2_end_x: float = arm2_mid_x - 18.0 + arm2_sway
	var arm2_end_y: float = arm2_mid_y + 12.0
	node.draw_line(Vector2(arm2_base_x, arm2_base_y), Vector2(arm2_mid_x, arm2_mid_y), Color(0.82, 0.84, 0.88), 4.0)
	node.draw_line(Vector2(arm2_mid_x, arm2_mid_y), Vector2(arm2_end_x, arm2_end_y), Color(0.82, 0.84, 0.88), 3.0)
	node.draw_circle(Vector2(arm2_base_x, arm2_base_y), 5.0, Color(0.6, 0.62, 0.66))
	node.draw_circle(Vector2(arm2_mid_x, arm2_mid_y), 4.0, Color(0.4, 0.6, 0.85, 0.8))
	# Gripper
	node.draw_line(Vector2(arm2_end_x - 4.0, arm2_end_y), Vector2(arm2_end_x - 6.0, arm2_end_y + 8.0), Color(0.7, 0.72, 0.76), 2.0)
	node.draw_line(Vector2(arm2_end_x + 4.0, arm2_end_y), Vector2(arm2_end_x + 6.0, arm2_end_y + 8.0), Color(0.7, 0.72, 0.76), 2.0)

	# Robotic arm 3 — ceiling mount
	var arm3_base_x: float = w * 0.1
	var arm3_base_y: float = -h + 5.0
	var arm3_sway: float = sin(t * 0.7 + 4.0) * 6.0
	var arm3_mid_x: float = arm3_base_x - 10.0 + arm3_sway * 0.5
	var arm3_mid_y: float = arm3_base_y + 25.0
	var arm3_end_x: float = arm3_mid_x + arm3_sway
	var arm3_end_y: float = arm3_mid_y + 20.0
	node.draw_line(Vector2(arm3_base_x, arm3_base_y), Vector2(arm3_mid_x, arm3_mid_y), Color(0.82, 0.84, 0.88), 3.5)
	node.draw_line(Vector2(arm3_mid_x, arm3_mid_y), Vector2(arm3_end_x, arm3_end_y), Color(0.82, 0.84, 0.88), 2.5)
	node.draw_circle(Vector2(arm3_base_x, arm3_base_y), 4.0, Color(0.6, 0.62, 0.66))
	node.draw_circle(Vector2(arm3_mid_x, arm3_mid_y), 3.5, Color(0.4, 0.6, 0.85, 0.8))
	var eff_pulse: float = 0.4 + 0.4 * sin(t * 3.0)
	node.draw_circle(Vector2(arm3_end_x, arm3_end_y), 3.0, Color(0.1, 0.85, 0.3, eff_pulse))

	# Holographic guidance markers — pulsing translucent shapes
	var holo_pulse: float = 0.3 + 0.35 * sin(t * 2.5)
	# Left marker
	var hm_pts1 := PackedVector2Array([
		Vector2(door_x - 15.0, -door_h * 0.5 - 8.0),
		Vector2(door_x - 8.0, -door_h * 0.5),
		Vector2(door_x - 15.0, -door_h * 0.5 + 8.0),
	])
	node.draw_colored_polygon(hm_pts1, Color(0.2, 0.8, 0.4, holo_pulse * 0.5))
	# Right marker
	var hm_pts2 := PackedVector2Array([
		Vector2(door_x + door_w + 15.0, -door_h * 0.5 - 8.0),
		Vector2(door_x + door_w + 8.0, -door_h * 0.5),
		Vector2(door_x + door_w + 15.0, -door_h * 0.5 + 8.0),
	])
	node.draw_colored_polygon(hm_pts2, Color(0.2, 0.8, 0.4, holo_pulse * 0.5))

	# Clean floor with painted guide lines (yellow)
	node.draw_line(Vector2(-door_w / 2.0, -3.0), Vector2(door_w / 2.0, -3.0), Color(0.9, 0.8, 0.2, 0.5), 1.5)
	node.draw_line(Vector2(-door_w / 4.0, -6.0), Vector2(-door_w / 4.0, 0.0), Color(0.9, 0.8, 0.2, 0.4), 1.0)
	node.draw_line(Vector2(door_w / 4.0, -6.0), Vector2(door_w / 4.0, 0.0), Color(0.9, 0.8, 0.2, 0.4), 1.0)
	# Center line
	node.draw_line(Vector2(0.0, -door_h * 0.1), Vector2(0.0, 0.0), Color(0.9, 0.8, 0.2, 0.35), 1.5)

	# Docking clamps on sides — mechanical grip shapes
	for side_idx in 2:
		var side_val: float = -1.0 if side_idx == 0 else 1.0
		var clamp_x: float = side_val * (door_w / 2.0 + 8.0)
		var clamp_y: float = -door_h * 0.4
		node.draw_rect(Rect2(clamp_x - 5.0, clamp_y - 12.0, 10.0, 24.0), Color(0.6, 0.62, 0.66))
		node.draw_rect(Rect2(clamp_x - 3.0, clamp_y - 15.0, 6.0, 6.0), Color(0.5, 0.52, 0.56))
		node.draw_rect(Rect2(clamp_x - 3.0, clamp_y + 9.0, 6.0, 6.0), Color(0.5, 0.52, 0.56))
		var clamp_light: float = 0.4 + 0.4 * sin(t * 2.0 + float(side_idx) * PI)
		node.draw_circle(Vector2(clamp_x, clamp_y), 2.5, Color(0.2, 0.7, 1.0, clamp_light))

	# Status display panel beside bay door
	var stat_x: float = w / 2.0 - 35.0
	var stat_y: float = -h * 0.55
	node.draw_rect(Rect2(stat_x, stat_y, 22.0, 16.0), Color(0.05, 0.08, 0.12))
	# Data readout lines
	for i in 5:
		var data_y: float = stat_y + 2.0 + float(i) * 2.8
		var data_len: float = 8.0 + fmod(t * 2.0 + float(i) * 3.1, 10.0)
		var data_col: Color = Color(0.1, 0.8, 0.4, 0.7) if i % 2 == 0 else Color(0.3, 0.6, 1.0, 0.65)
		node.draw_line(Vector2(stat_x + 2.0, data_y), Vector2(stat_x + data_len, data_y), data_col, 1.0)
	# Status indicators — colored dots
	node.draw_circle(Vector2(stat_x + 4.0, stat_y + 14.0), 1.5, Color(0.1, 0.9, 0.3, 0.8))
	node.draw_circle(Vector2(stat_x + 10.0, stat_y + 14.0), 1.5, Color(0.1, 0.9, 0.3, 0.8))
	node.draw_circle(Vector2(stat_x + 16.0, stat_y + 14.0), 1.5, Color(0.9, 0.8, 0.1, 0.8))
	# Screen frame
	node.draw_rect(Rect2(stat_x, stat_y, 22.0, 16.0), Color(0.5, 0.6, 0.8, 0.4), false, 1.0)

	# Overhead track lighting — evenly spaced dots along ceiling
	for i in 8:
		var lx: float = -w / 2.0 + float(i + 1) * w / 9.0
		var light_bright: float = 0.6 + 0.2 * sin(t * 1.5 + float(i) * 0.8)
		node.draw_circle(Vector2(lx, -h + 8.0), 3.0, Color(0.95, 0.95, 0.98, light_bright))
		# Light cone below
		node.draw_line(Vector2(lx, -h + 11.0), Vector2(lx, -h + 25.0), Color(0.9, 0.92, 0.95, light_bright * 0.15), 6.0)

	# Roof edge — bright clean line
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.85, 0.87, 0.92, 0.7), 2.5)
	# Side edges
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(-w / 2.0, 0.0), Color(0.82, 0.84, 0.88, 0.4), 1.5)
	node.draw_line(Vector2(w / 2.0, -h), Vector2(w / 2.0, 0.0), Color(0.82, 0.84, 0.88, 0.4), 1.5)


# ── 2. MARKET — Sterile supply depot with conveyor belts ──────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	# Clean rectangular structure
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.86, 0.87, 0.9))

	# Structural frame lines
	for i in 6:
		var fx: float = -w / 2.0 + w * (float(i + 1) / 7.0)
		node.draw_line(Vector2(fx, -h), Vector2(fx, 0.0), Color(0.76, 0.78, 0.82, 0.25), 1.0)
	for i in int(h / 20.0):
		var fy: float = -h + float(i) * 20.0
		node.draw_line(Vector2(-w / 2.0, fy), Vector2(w / 2.0, fy), Color(0.76, 0.78, 0.82, 0.2), 1.0)

	# Glass front — translucent tinted area at bottom half
	var glass_y: float = -h * 0.55
	var glass_h: float = h * 0.55 - 4.0
	node.draw_rect(Rect2(-w / 2.0 + 8.0, glass_y, w - 16.0, glass_h), Color(0.7, 0.8, 0.95, 0.15))

	# Conveyor belt visible through glass — horizontal belt with moving boxes
	var belt_y: float = -h * 0.18
	var belt_left: float = -w / 2.0 + 20.0
	var belt_right: float = w / 2.0 - 20.0
	# Belt track
	node.draw_line(Vector2(belt_left, belt_y), Vector2(belt_right, belt_y), Color(0.5, 0.52, 0.56), 3.0)
	node.draw_line(Vector2(belt_left, belt_y + 4.0), Vector2(belt_right, belt_y + 4.0), Color(0.5, 0.52, 0.56), 1.5)
	# Belt rollers
	for i in 12:
		var rx: float = belt_left + float(i) * (belt_right - belt_left) / 11.0
		node.draw_line(Vector2(rx, belt_y), Vector2(rx, belt_y + 4.0), Color(0.55, 0.57, 0.6, 0.5), 1.0)
	# Moving boxes on belt
	var belt_len: float = belt_right - belt_left
	for i in 4:
		var box_phase: float = fmod(t * 25.0 + float(i) * belt_len / 4.0, belt_len)
		var box_x: float = belt_left + box_phase
		if box_x < belt_right - 12.0:
			var box_col: Color = Color(0.4, 0.6, 0.85, 0.6) if i % 2 == 0 else Color(0.6, 0.75, 0.4, 0.6)
			node.draw_rect(Rect2(box_x, belt_y - 10.0, 12.0, 10.0), box_col)
			node.draw_rect(Rect2(box_x, belt_y - 10.0, 12.0, 10.0), Color(0.7, 0.72, 0.76, 0.5), false, 1.0)

	# Scanner arch at entrance — glowing arch shape
	var arch_w: float = 30.0
	var arch_h_val: float = h * 0.35
	var scan_pulse: float = 0.4 + 0.4 * sin(t * 4.0)
	# Arch pillars
	node.draw_rect(Rect2(-arch_w / 2.0 - 3.0, -arch_h_val, 5.0, arch_h_val), Color(0.7, 0.72, 0.78))
	node.draw_rect(Rect2(arch_w / 2.0 - 2.0, -arch_h_val, 5.0, arch_h_val), Color(0.7, 0.72, 0.78))
	# Arch top
	node.draw_line(Vector2(-arch_w / 2.0, -arch_h_val), Vector2(arch_w / 2.0, -arch_h_val), Color(0.7, 0.72, 0.78), 5.0)
	# Scanner glow line sweeping
	var scan_y: float = -arch_h_val + fmod(t * 40.0, arch_h_val)
	if scan_y < 0.0:
		node.draw_line(Vector2(-arch_w / 2.0 + 2.0, scan_y), Vector2(arch_w / 2.0 - 2.0, scan_y), Color(0.2, 0.8, 1.0, scan_pulse * 0.6), 2.0)
	# Arch glow
	node.draw_line(Vector2(-arch_w / 2.0, -arch_h_val), Vector2(arch_w / 2.0, -arch_h_val), Color(0.3, 0.6, 1.0, scan_pulse * 0.4), 2.0)

	# Organized shelf units inside — grid of colored blocks
	var shelf_start_x: float = -w / 2.0 + 18.0
	var shelf_start_y: float = -h * 0.85
	for row in 3:
		for col in 5:
			var sx: float = shelf_start_x + float(col) * 22.0
			var sy: float = shelf_start_y + float(row) * 18.0
			# Shelf bracket
			node.draw_rect(Rect2(sx, sy, 18.0, 14.0), Color(0.75, 0.77, 0.82))
			# Items on shelf — colored blocks
			var item_col: Color
			var item_idx: int = row * 5 + col
			if item_idx % 3 == 0:
				item_col = Color(0.3, 0.6, 0.9, 0.5)
			elif item_idx % 3 == 1:
				item_col = Color(0.5, 0.8, 0.4, 0.5)
			else:
				item_col = Color(0.9, 0.6, 0.3, 0.5)
			node.draw_rect(Rect2(sx + 2.0, sy + 2.0, 6.0, 10.0), item_col)
			node.draw_rect(Rect2(sx + 10.0, sy + 4.0, 5.0, 8.0), item_col * 0.8)

	# Automatic door indicators — green/red lights
	var door_active: float = sin(t * 1.0)
	var green_alpha: float = 0.8 if door_active > 0.0 else 0.2
	var red_alpha: float = 0.2 if door_active > 0.0 else 0.8
	node.draw_circle(Vector2(-arch_w / 2.0 - 10.0, -arch_h_val + 8.0), 3.0, Color(0.1, 0.9, 0.2, green_alpha))
	node.draw_circle(Vector2(-arch_w / 2.0 - 10.0, -arch_h_val + 16.0), 3.0, Color(0.9, 0.15, 0.1, red_alpha))

	# Delivery chute on right side — angled tube
	var chute_x: float = w / 2.0 - 10.0
	var chute_top_y: float = -h * 0.7
	var chute_bot_y: float = -h * 0.15
	var chute_bot_x: float = chute_x - 20.0
	node.draw_line(Vector2(chute_x, chute_top_y), Vector2(chute_bot_x, chute_bot_y), Color(0.65, 0.67, 0.72), 6.0)
	node.draw_line(Vector2(chute_x, chute_top_y), Vector2(chute_bot_x, chute_bot_y), Color(0.72, 0.74, 0.78), 3.0)
	# Chute opening
	node.draw_circle(Vector2(chute_x, chute_top_y), 5.0, Color(0.55, 0.57, 0.62))

	# Inventory display screen
	var inv_x: float = -w / 2.0 + 12.0
	var inv_y: float = -h * 0.65
	node.draw_rect(Rect2(inv_x, inv_y, 28.0, 20.0), Color(0.04, 0.07, 0.1))
	# Data lines scrolling
	for i in 6:
		var dy: float = inv_y + 2.5 + float(i) * 2.8
		var dlen: float = 10.0 + fmod(t * 1.8 + float(i) * 4.0, 14.0)
		node.draw_line(Vector2(inv_x + 2.0, dy), Vector2(inv_x + dlen, dy), Color(0.2, 0.7, 1.0, 0.6), 1.0)
	# Screen frame
	node.draw_rect(Rect2(inv_x, inv_y, 28.0, 20.0), Color(0.4, 0.6, 0.85, 0.4), false, 1.0)

	# Zone markings on floor
	node.draw_line(Vector2(-w / 3.0, -3.0), Vector2(w / 3.0, -3.0), Color(0.9, 0.8, 0.2, 0.4), 1.5)
	node.draw_line(Vector2(-w / 3.0, -6.0), Vector2(-w / 3.0, 0.0), Color(0.9, 0.8, 0.2, 0.3), 1.0)
	node.draw_line(Vector2(w / 3.0, -6.0), Vector2(w / 3.0, 0.0), Color(0.9, 0.8, 0.2, 0.3), 1.0)

	# Temperature display — small readout top-right
	var temp_x: float = w / 2.0 - 30.0
	var temp_y: float = -h + 8.0
	node.draw_rect(Rect2(temp_x, temp_y, 20.0, 10.0), Color(0.05, 0.08, 0.05))
	var temp_blink: float = 0.5 + 0.3 * sin(t * 1.5)
	node.draw_rect(Rect2(temp_x + 2.0, temp_y + 2.0, 8.0, 6.0), Color(0.1, 0.85, 0.4, temp_blink))
	node.draw_rect(Rect2(temp_x + 12.0, temp_y + 3.0, 5.0, 4.0), Color(0.1, 0.7, 0.3, temp_blink * 0.7))

	# Barcode scanner near entrance — small mounted device
	node.draw_rect(Rect2(arch_w / 2.0 + 6.0, -arch_h_val + 20.0, 8.0, 12.0), Color(0.6, 0.62, 0.68))
	var scan_active: float = 0.3 + 0.5 * sin(t * 5.0)
	node.draw_line(Vector2(arch_w / 2.0 + 10.0, -arch_h_val + 32.0), Vector2(arch_w / 2.0 + 10.0, -arch_h_val + 40.0), Color(0.9, 0.15, 0.1, scan_active), 2.0)

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.85, 0.87, 0.92, 0.6), 2.5)
	# Side edges
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(-w / 2.0, 0.0), Color(0.82, 0.84, 0.88, 0.35), 1.5)
	node.draw_line(Vector2(w / 2.0, -h), Vector2(w / 2.0, 0.0), Color(0.82, 0.84, 0.88, 0.35), 1.5)


# ── 3. BAR — Minimalist wine bar ─────────────────────────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	# Clean elegant structure — warm white
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.85, 0.84, 0.82))

	# Large panoramic windows — glass front
	var win_y: float = -h * 0.75
	var win_h_val: float = h * 0.55
	node.draw_rect(Rect2(-w / 2.0 + 10.0, win_y, w - 20.0, win_h_val), Color(0.6, 0.65, 0.75, 0.2))
	# Window frame dividers — 4 tall panes
	for i in 5:
		var wx: float = -w / 2.0 + 10.0 + float(i) * (w - 20.0) / 4.0
		node.draw_line(Vector2(wx, win_y), Vector2(wx, win_y + win_h_val), Color(0.78, 0.78, 0.8, 0.5), 2.0)
	# Window top/bottom frames
	node.draw_line(Vector2(-w / 2.0 + 10.0, win_y), Vector2(w / 2.0 - 10.0, win_y), Color(0.78, 0.78, 0.8, 0.6), 2.0)
	node.draw_line(Vector2(-w / 2.0 + 10.0, win_y + win_h_val), Vector2(w / 2.0 - 10.0, win_y + win_h_val), Color(0.78, 0.78, 0.8, 0.6), 2.0)

	# Soft warm recessed lighting from window edges
	var warm_glow: float = 0.3 + 0.15 * sin(t * 1.2)
	node.draw_rect(Rect2(-w / 2.0 + 12.0, win_y + 1.0, w - 24.0, 4.0), Color(0.95, 0.85, 0.65, warm_glow * 0.3))
	node.draw_rect(Rect2(-w / 2.0 + 12.0, win_y + win_h_val - 5.0, w - 24.0, 4.0), Color(0.95, 0.85, 0.65, warm_glow * 0.25))

	# Minimalist interior visible: clean counter line
	var counter_y: float = -h * 0.3
	node.draw_line(Vector2(-w / 3.0, counter_y), Vector2(w / 3.0, counter_y), Color(0.55, 0.5, 0.48), 4.0)
	# Counter top highlight
	node.draw_line(Vector2(-w / 3.0, counter_y - 1.0), Vector2(w / 3.0, counter_y - 1.0), Color(0.75, 0.72, 0.68, 0.5), 1.0)

	# Backlit bottle shelves — colored rectangles behind counter
	var shelf_base_y: float = -h * 0.55
	for row in 3:
		for col in 6:
			var bx: float = -w / 4.0 + float(col) * 14.0
			var by: float = shelf_base_y + float(row) * 16.0
			# Shelf line
			if row < 2:
				node.draw_line(Vector2(-w / 4.0, by + 14.0), Vector2(-w / 4.0 + 80.0, by + 14.0), Color(0.6, 0.58, 0.55, 0.3), 1.0)
			# Bottle shape — thin tall rectangle
			var bottle_col: Color
			if col % 3 == 0:
				bottle_col = Color(0.6, 0.2, 0.25, 0.55)
			elif col % 3 == 1:
				bottle_col = Color(0.8, 0.7, 0.3, 0.5)
			else:
				bottle_col = Color(0.3, 0.5, 0.3, 0.5)
			node.draw_rect(Rect2(bx, by, 4.0, 12.0), bottle_col)
			# Backlight glow
			node.draw_rect(Rect2(bx - 1.0, by - 1.0, 6.0, 14.0), Color(0.9, 0.85, 0.7, 0.08))

	# Floating holographic menu above entrance — translucent rectangle, animated gentle bob
	var menu_bob: float = sin(t * 1.5) * 3.0
	var menu_x: float = -w * 0.2
	var menu_y: float = -h * 0.88 + menu_bob
	var menu_w: float = w * 0.4
	var menu_h_val: float = 14.0
	var menu_pulse: float = 0.35 + 0.2 * sin(t * 2.0)
	# Holographic glow
	node.draw_rect(Rect2(menu_x - 3.0, menu_y - 2.0, menu_w + 6.0, menu_h_val + 4.0), Color(0.3, 0.6, 1.0, menu_pulse * 0.15))
	# Menu body
	node.draw_rect(Rect2(menu_x, menu_y, menu_w, menu_h_val), Color(0.3, 0.6, 1.0, menu_pulse * 0.4))
	# Text-like lines on menu
	for i in 3:
		var tl_y: float = menu_y + 3.0 + float(i) * 4.0
		var tl_len: float = menu_w * 0.3 + float(i) * menu_w * 0.15
		node.draw_line(Vector2(menu_x + 4.0, tl_y), Vector2(menu_x + tl_len, tl_y), Color(0.7, 0.85, 1.0, menu_pulse * 0.6), 1.0)

	# Single elegant plant by entrance — slim vertical shape with leaves
	var plant_x: float = w / 2.0 - 25.0
	var plant_base_y: float = -4.0
	# Pot
	node.draw_rect(Rect2(plant_x - 6.0, plant_base_y - 12.0, 12.0, 12.0), Color(0.55, 0.45, 0.35))
	# Stem
	node.draw_line(Vector2(plant_x, plant_base_y - 12.0), Vector2(plant_x, plant_base_y - 35.0), Color(0.3, 0.5, 0.25), 2.0)
	# Leaves
	var leaf_pts1 := PackedVector2Array([
		Vector2(plant_x, plant_base_y - 28.0),
		Vector2(plant_x + 10.0, plant_base_y - 34.0),
		Vector2(plant_x + 3.0, plant_base_y - 30.0),
	])
	node.draw_colored_polygon(leaf_pts1, Color(0.35, 0.6, 0.3, 0.7))
	var leaf_pts2 := PackedVector2Array([
		Vector2(plant_x, plant_base_y - 24.0),
		Vector2(plant_x - 9.0, plant_base_y - 30.0),
		Vector2(plant_x - 2.0, plant_base_y - 25.0),
	])
	node.draw_colored_polygon(leaf_pts2, Color(0.3, 0.55, 0.28, 0.7))
	var leaf_pts3 := PackedVector2Array([
		Vector2(plant_x, plant_base_y - 32.0),
		Vector2(plant_x + 7.0, plant_base_y - 40.0),
		Vector2(plant_x + 2.0, plant_base_y - 35.0),
	])
	node.draw_colored_polygon(leaf_pts3, Color(0.32, 0.58, 0.28, 0.65))

	# Sleek modern signage — thin clean marks
	var sign_y: float = -h + 12.0
	var sign_w: float = w * 0.35
	var sign_x: float = -sign_w / 2.0
	node.draw_rect(Rect2(sign_x - 2.0, sign_y - 2.0, sign_w + 4.0, 12.0), Color(0.15, 0.13, 0.12))
	# Letter blocks — "WINE BAR" approximation
	for i in 5:
		var lx: float = sign_x + 4.0 + float(i) * (sign_w / 5.0)
		var letter_pulse: float = 0.5 + 0.3 * sin(t * 2.0 + float(i) * 0.8)
		node.draw_rect(Rect2(lx, sign_y, sign_w / 7.0, 8.0), Color(0.9, 0.8, 0.6, letter_pulse))

	# Polished floor visible through glass — reflective line
	node.draw_line(Vector2(-w / 2.0 + 15.0, -8.0), Vector2(w / 2.0 - 15.0, -8.0), Color(0.8, 0.78, 0.75, 0.2), 1.0)

	# Subtle ambient warm glow
	node.draw_rect(Rect2(-w / 2.0, -h * 0.2, w, h * 0.2), Color(0.95, 0.85, 0.6, 0.04))

	# Geometric art piece on wall — abstract shape
	var art_x: float = -w / 2.0 + 25.0
	var art_y: float = -h * 0.6
	var art_pts := PackedVector2Array([
		Vector2(art_x, art_y),
		Vector2(art_x + 15.0, art_y - 10.0),
		Vector2(art_x + 20.0, art_y + 5.0),
		Vector2(art_x + 8.0, art_y + 12.0),
	])
	node.draw_colored_polygon(art_pts, Color(0.7, 0.5, 0.3, 0.35))
	node.draw_polyline(art_pts, Color(0.8, 0.6, 0.4, 0.5), 1.5)

	# Glass of wine icon on sign area
	var wine_x: float = sign_x + sign_w + 8.0
	var wine_y: float = sign_y + 2.0
	# Wine glass stem
	node.draw_line(Vector2(wine_x, wine_y + 2.0), Vector2(wine_x, wine_y + 7.0), Color(0.9, 0.85, 0.75, 0.7), 1.0)
	# Wine glass bowl (triangle)
	var wine_pts := PackedVector2Array([
		Vector2(wine_x - 4.0, wine_y),
		Vector2(wine_x + 4.0, wine_y),
		Vector2(wine_x, wine_y + 3.0),
	])
	node.draw_colored_polygon(wine_pts, Color(0.7, 0.15, 0.2, 0.6))
	# Wine glass base
	node.draw_line(Vector2(wine_x - 3.0, wine_y + 7.0), Vector2(wine_x + 3.0, wine_y + 7.0), Color(0.9, 0.85, 0.75, 0.7), 1.0)

	# Entrance — elegant double doors
	node.draw_rect(Rect2(-14.0, -h * 0.16, 13.0, h * 0.16), Color(0.6, 0.55, 0.52))
	node.draw_rect(Rect2(1.0, -h * 0.16, 13.0, h * 0.16), Color(0.6, 0.55, 0.52))
	# Handles — thin elegant
	node.draw_line(Vector2(-5.0, -h * 0.11), Vector2(-5.0, -h * 0.06), Color(0.85, 0.78, 0.6), 1.5)
	node.draw_line(Vector2(5.0, -h * 0.11), Vector2(5.0, -h * 0.06), Color(0.85, 0.78, 0.6), 1.5)

	# Soft warm entrance glow
	var ent_glow: float = 0.25 + 0.15 * sin(t * 1.8)
	node.draw_rect(Rect2(-18.0, -4.0, 36.0, 6.0), Color(0.95, 0.85, 0.6, ent_glow))

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.82, 0.8, 0.78, 0.6), 2.5)


# ── 4. GARAGE — Robotic upgrade lab ──────────────────────────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	# Main structure — light gray
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.84, 0.86, 0.9))

	# Glass-fronted clean room — blue-tinted transparent front wall
	var glass_y: float = -h * 0.8
	var glass_h: float = h * 0.65
	node.draw_rect(Rect2(-w / 2.0 + 6.0, glass_y, w - 12.0, glass_h), Color(0.5, 0.65, 0.9, 0.12))
	# Glass frame
	node.draw_rect(Rect2(-w / 2.0 + 6.0, glass_y, w - 12.0, glass_h), Color(0.6, 0.7, 0.85, 0.35), false, 2.0)

	# Clean room glass partition walls inside — translucent vertical lines
	for i in 3:
		var px: float = -w / 4.0 + float(i) * w / 4.0
		node.draw_line(Vector2(px, glass_y + 4.0), Vector2(px, glass_y + glass_h - 4.0), Color(0.6, 0.7, 0.9, 0.2), 2.0)

	# Ventilation system on top — clean rectangular vents
	for i in 4:
		var vx: float = -w / 2.0 + 15.0 + float(i) * (w - 30.0) / 3.0
		node.draw_rect(Rect2(vx, -h + 3.0, 20.0, 8.0), Color(0.7, 0.72, 0.76))
		# Vent slats
		for j in 3:
			var sly: float = -h + 4.5 + float(j) * 2.5
			node.draw_line(Vector2(vx + 2.0, sly), Vector2(vx + 18.0, sly), Color(0.55, 0.57, 0.62, 0.5), 1.0)

	# Conveyor belt with item shapes moving through
	var belt_y: float = -h * 0.25
	var belt_left: float = -w / 2.0 + 15.0
	var belt_right: float = w / 2.0 - 15.0
	node.draw_line(Vector2(belt_left, belt_y), Vector2(belt_right, belt_y), Color(0.5, 0.52, 0.58), 3.5)
	node.draw_line(Vector2(belt_left, belt_y + 5.0), Vector2(belt_right, belt_y + 5.0), Color(0.5, 0.52, 0.58), 1.5)
	# Belt items moving
	var blen: float = belt_right - belt_left
	for i in 3:
		var item_phase: float = fmod(t * 20.0 + float(i) * blen / 3.0, blen)
		var item_x: float = belt_left + item_phase
		if item_x < belt_right - 15.0:
			# Item body
			node.draw_rect(Rect2(item_x, belt_y - 12.0, 14.0, 12.0), Color(0.6, 0.65, 0.72))
			# Item detail
			node.draw_rect(Rect2(item_x + 3.0, belt_y - 10.0, 8.0, 4.0), Color(0.4, 0.6, 0.85, 0.5))

	# Laser arms — thin bright lines, animated sweeping motion
	var laser1_angle: float = sin(t * 1.2) * 0.5
	var laser1_base_x: float = -w / 4.0
	var laser1_base_y: float = -h * 0.65
	var laser1_end_x: float = laser1_base_x + cos(laser1_angle) * 40.0
	var laser1_end_y: float = laser1_base_y + sin(laser1_angle + 0.8) * 30.0
	node.draw_line(Vector2(laser1_base_x, laser1_base_y), Vector2(laser1_end_x, laser1_end_y), Color(0.75, 0.78, 0.85), 3.0)
	var laser1_pulse: float = 0.5 + 0.4 * sin(t * 6.0)
	node.draw_line(Vector2(laser1_end_x, laser1_end_y), Vector2(laser1_end_x + cos(laser1_angle) * 15.0, laser1_end_y + 15.0), Color(1.0, 0.2, 0.1, laser1_pulse), 1.5)
	node.draw_circle(Vector2(laser1_base_x, laser1_base_y), 4.0, Color(0.6, 0.62, 0.68))

	var laser2_angle: float = sin(t * 1.2 + PI) * 0.4
	var laser2_base_x: float = w / 4.0
	var laser2_base_y: float = -h * 0.6
	var laser2_end_x: float = laser2_base_x + cos(laser2_angle + PI) * 35.0
	var laser2_end_y: float = laser2_base_y + sin(laser2_angle + 0.6) * 25.0
	node.draw_line(Vector2(laser2_base_x, laser2_base_y), Vector2(laser2_end_x, laser2_end_y), Color(0.75, 0.78, 0.85), 3.0)
	var laser2_pulse: float = 0.5 + 0.4 * sin(t * 6.0 + 1.5)
	node.draw_line(Vector2(laser2_end_x, laser2_end_y), Vector2(laser2_end_x + cos(laser2_angle) * 12.0, laser2_end_y + 12.0), Color(1.0, 0.2, 0.1, laser2_pulse), 1.5)
	node.draw_circle(Vector2(laser2_base_x, laser2_base_y), 4.0, Color(0.6, 0.62, 0.68))

	# Robotic tool arms in various positions
	var tool1_base_x: float = -w / 2.0 + 20.0
	var tool1_base_y: float = -h * 0.5
	var tool1_sway: float = sin(t * 0.8) * 6.0
	var tool1_mid_x: float = tool1_base_x + 18.0
	var tool1_mid_y: float = tool1_base_y + 15.0 + tool1_sway * 0.4
	var tool1_end_x: float = tool1_mid_x + 12.0 + tool1_sway
	var tool1_end_y: float = tool1_mid_y + 10.0
	node.draw_line(Vector2(tool1_base_x, tool1_base_y), Vector2(tool1_mid_x, tool1_mid_y), Color(0.8, 0.82, 0.88), 3.5)
	node.draw_line(Vector2(tool1_mid_x, tool1_mid_y), Vector2(tool1_end_x, tool1_end_y), Color(0.8, 0.82, 0.88), 2.5)
	node.draw_circle(Vector2(tool1_mid_x, tool1_mid_y), 3.0, Color(0.4, 0.6, 0.85, 0.7))
	var tool1_pulse: float = 0.4 + 0.4 * sin(t * 3.5)
	node.draw_circle(Vector2(tool1_end_x, tool1_end_y), 2.5, Color(0.1, 0.85, 0.3, tool1_pulse))

	var tool2_base_x: float = w / 2.0 - 22.0
	var tool2_base_y: float = -h * 0.55
	var tool2_sway: float = sin(t * 0.8 + 2.5) * 5.0
	var tool2_mid_x: float = tool2_base_x - 16.0
	var tool2_mid_y: float = tool2_base_y + 12.0 + tool2_sway * 0.3
	var tool2_end_x: float = tool2_mid_x - 10.0 + tool2_sway
	var tool2_end_y: float = tool2_mid_y + 10.0
	node.draw_line(Vector2(tool2_base_x, tool2_base_y), Vector2(tool2_mid_x, tool2_mid_y), Color(0.8, 0.82, 0.88), 3.5)
	node.draw_line(Vector2(tool2_mid_x, tool2_mid_y), Vector2(tool2_end_x, tool2_end_y), Color(0.8, 0.82, 0.88), 2.5)
	node.draw_circle(Vector2(tool2_mid_x, tool2_mid_y), 3.0, Color(0.4, 0.6, 0.85, 0.7))
	var tool2_pulse: float = 0.4 + 0.4 * sin(t * 3.5 + 1.5)
	node.draw_circle(Vector2(tool2_end_x, tool2_end_y), 2.5, Color(0.1, 0.85, 0.3, tool2_pulse))

	# Digital readout displays — small rectangles with number-like marks
	for i in 3:
		var rd_x: float = -w / 3.0 + float(i) * w / 3.0 - 10.0
		var rd_y: float = -h * 0.42
		node.draw_rect(Rect2(rd_x, rd_y, 18.0, 12.0), Color(0.04, 0.06, 0.1))
		# Number-like marks
		for j in 4:
			var nx: float = rd_x + 2.0 + float(j) * 4.0
			var nval: float = fmod(t * 2.0 + float(i * 4 + j) * 1.7, 1.0)
			var nh: float = 3.0 + nval * 5.0
			node.draw_rect(Rect2(nx, rd_y + 8.0 - nh, 2.5, nh), Color(0.2, 0.8, 1.0, 0.65))
		node.draw_rect(Rect2(rd_x, rd_y, 18.0, 12.0), Color(0.4, 0.6, 0.8, 0.3), false, 1.0)

	# "AUTHORIZED PERSONNEL" warning sign
	var warn_x: float = -w * 0.22
	var warn_y: float = -h * 0.12
	node.draw_rect(Rect2(warn_x, warn_y, w * 0.44, 10.0), Color(0.9, 0.7, 0.1, 0.7))
	# Warning stripes
	for i in 8:
		var stripe_x: float = warn_x + float(i) * w * 0.055
		node.draw_line(Vector2(stripe_x, warn_y), Vector2(stripe_x + 5.0, warn_y + 10.0), Color(0.1, 0.1, 0.1, 0.4), 2.0)
	# Text approximation
	for i in 6:
		var tx: float = warn_x + 8.0 + float(i) * w * 0.06
		node.draw_rect(Rect2(tx, warn_y + 3.0, w * 0.04, 4.0), Color(0.1, 0.1, 0.1, 0.6))

	# Status lights — row of colored dots along top
	for i in 6:
		var sl_x: float = -w / 3.0 + float(i) * w / 5.0
		var sl_col: Color
		if i < 3:
			sl_col = Color(0.1, 0.9, 0.3, 0.6 + 0.3 * sin(t * 2.0 + float(i)))
		elif i < 5:
			sl_col = Color(0.9, 0.8, 0.1, 0.6 + 0.3 * sin(t * 2.0 + float(i)))
		else:
			sl_col = Color(0.9, 0.2, 0.1, 0.5 + 0.4 * sin(t * 3.0))
		node.draw_circle(Vector2(sl_x, -h + 16.0), 3.0, sl_col)

	# Precision equipment on work surfaces
	var bench_y: float = -h * 0.18
	# Left bench
	node.draw_rect(Rect2(-w / 2.0 + 12.0, bench_y, 35.0, 5.0), Color(0.65, 0.67, 0.72))
	node.draw_rect(Rect2(-w / 2.0 + 16.0, bench_y - 8.0, 8.0, 8.0), Color(0.55, 0.6, 0.68))
	node.draw_rect(Rect2(-w / 2.0 + 28.0, bench_y - 5.0, 6.0, 5.0), Color(0.5, 0.55, 0.65))
	# Right bench
	node.draw_rect(Rect2(w / 2.0 - 47.0, bench_y, 35.0, 5.0), Color(0.65, 0.67, 0.72))
	node.draw_rect(Rect2(w / 2.0 - 40.0, bench_y - 10.0, 10.0, 10.0), Color(0.55, 0.6, 0.68))
	node.draw_rect(Rect2(w / 2.0 - 25.0, bench_y - 6.0, 7.0, 6.0), Color(0.5, 0.55, 0.65))

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.85, 0.87, 0.92, 0.6), 2.5)
	# Side edges
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(-w / 2.0, 0.0), Color(0.82, 0.84, 0.88, 0.35), 1.5)
	node.draw_line(Vector2(w / 2.0, -h), Vector2(w / 2.0, 0.0), Color(0.82, 0.84, 0.88, 0.35), 1.5)


# ── 5. UNIQUE — Research Spire with satellite arrays ─────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	# Reinforced base section — wider, heavier looking
	var base_w: float = w * 0.85
	var base_h: float = h * 0.2
	node.draw_rect(Rect2(-base_w / 2.0, -base_h, base_w, base_h), Color(0.7, 0.72, 0.76))
	# Base reinforcement lines
	for i in 3:
		var by: float = -base_h + float(i + 1) * base_h / 4.0
		node.draw_line(Vector2(-base_w / 2.0, by), Vector2(base_w / 2.0, by), Color(0.6, 0.62, 0.66, 0.4), 1.5)
	# Base bolts
	for i in 6:
		var bx: float = -base_w / 2.0 + 10.0 + float(i) * (base_w - 20.0) / 5.0
		node.draw_circle(Vector2(bx, -base_h * 0.5), 2.5, Color(0.55, 0.57, 0.62))

	# Main tower body — tall narrow
	var tower_w: float = w * 0.4
	var tower_h: float = h - base_h
	var tower_y: float = -base_h - tower_h
	node.draw_rect(Rect2(-tower_w / 2.0, tower_y, tower_w, tower_h), Color(0.86, 0.88, 0.92))

	# Tower taper — subtle narrowing towards top using side panels
	var taper_pts_left := PackedVector2Array([
		Vector2(-tower_w / 2.0, tower_y),
		Vector2(-tower_w / 2.0 + 8.0, tower_y),
		Vector2(-tower_w / 2.0, -base_h),
	])
	node.draw_colored_polygon(taper_pts_left, Color(0.8, 0.82, 0.86))
	var taper_pts_right := PackedVector2Array([
		Vector2(tower_w / 2.0, tower_y),
		Vector2(tower_w / 2.0 - 8.0, tower_y),
		Vector2(tower_w / 2.0, -base_h),
	])
	node.draw_colored_polygon(taper_pts_right, Color(0.8, 0.82, 0.86))

	# Observation windows in spiral pattern going up tower
	for i in 12:
		var frac: float = float(i) / 12.0
		var win_y: float = tower_y + tower_h * 0.05 + frac * tower_h * 0.85
		var spiral_x: float = sin(frac * TAU * 2.0) * tower_w * 0.25
		var win_glow: float = 0.4 + 0.2 * sin(t * 1.5 + float(i) * 0.6)
		# Window rectangle
		node.draw_rect(Rect2(spiral_x - 5.0, win_y, 10.0, 7.0), Color(0.3, 0.5, 0.85, win_glow))
		# Window frame
		node.draw_rect(Rect2(spiral_x - 5.0, win_y, 10.0, 7.0), Color(0.75, 0.77, 0.82, 0.5), false, 1.0)

	# Lab windows with blue interior glow — larger windows at specific floors
	for i in 4:
		var lab_y: float = tower_y + tower_h * (0.15 + float(i) * 0.2)
		var lab_glow: float = 0.35 + 0.25 * sin(t * 2.0 + float(i) * 1.2)
		# Left lab window
		node.draw_rect(Rect2(-tower_w / 2.0 + 4.0, lab_y, 14.0, 10.0), Color(0.25, 0.45, 0.8, lab_glow))
		node.draw_rect(Rect2(-tower_w / 2.0 + 4.0, lab_y, 14.0, 10.0), Color(0.7, 0.75, 0.82, 0.4), false, 1.0)
		# Right lab window
		node.draw_rect(Rect2(tower_w / 2.0 - 18.0, lab_y, 14.0, 10.0), Color(0.25, 0.45, 0.8, lab_glow))
		node.draw_rect(Rect2(tower_w / 2.0 - 18.0, lab_y, 14.0, 10.0), Color(0.7, 0.75, 0.82, 0.4), false, 1.0)

	# Data cable bundles running up sides — bundled lines
	for side_idx in 2:
		var cable_side: float = -1.0 if side_idx == 0 else 1.0
		var cable_x: float = cable_side * (tower_w / 2.0 - 2.0)
		for j in 3:
			var cx: float = cable_x + float(j) * cable_side * 2.0
			node.draw_line(Vector2(cx, -base_h), Vector2(cx, tower_y + 10.0), Color(0.45, 0.5, 0.58, 0.4), 1.5)
		# Cable clips every so often
		for j in 5:
			var clip_y: float = tower_y + tower_h * (0.1 + float(j) * 0.18)
			node.draw_rect(Rect2(cable_x - 2.0, clip_y, cable_side * 8.0, 3.0), Color(0.6, 0.62, 0.66, 0.5))

	# "TITAN RESEARCH" signage on tower
	var sign_y: float = tower_y + tower_h * 0.35
	var sign_w: float = tower_w * 0.7
	var sign_x: float = -sign_w / 2.0
	node.draw_rect(Rect2(sign_x - 2.0, sign_y - 2.0, sign_w + 4.0, 14.0), Color(0.12, 0.14, 0.18))
	for i in 6:
		var lx: float = sign_x + 3.0 + float(i) * (sign_w / 6.0)
		var letter_pulse: float = 0.5 + 0.3 * sin(t * 2.5 + float(i) * 0.7)
		node.draw_rect(Rect2(lx, sign_y, sign_w / 8.0, 10.0), Color(0.4, 0.6, 0.85, letter_pulse))

	# Satellite dishes at top — 3 different sizes/angles
	var dish_base_y: float = tower_y + 5.0

	# Dish 1 — large, right-facing, slight animated tracking
	var dish1_track: float = sin(t * 0.3) * 0.15
	var dish1_cx: float = tower_w / 2.0 + 5.0
	var dish1_cy: float = dish_base_y + 10.0
	var dish1_pts := PackedVector2Array([
		Vector2(dish1_cx, dish1_cy - 15.0),
		Vector2(dish1_cx + 25.0 + dish1_track * 10.0, dish1_cy),
		Vector2(dish1_cx, dish1_cy + 15.0),
	])
	node.draw_colored_polygon(dish1_pts, Color(0.75, 0.77, 0.82))
	# Dish arm
	node.draw_line(Vector2(0.0, dish1_cy), Vector2(dish1_cx, dish1_cy), Color(0.65, 0.67, 0.72), 2.5)
	# Dish feed
	node.draw_circle(Vector2(dish1_cx + 8.0, dish1_cy), 2.5, Color(0.5, 0.55, 0.62))
	# Active light on dish
	var dish1_active: float = 0.4 + 0.4 * sin(t * 2.0)
	node.draw_circle(Vector2(dish1_cx + 8.0, dish1_cy), 1.5, Color(0.2, 0.8, 1.0, dish1_active))

	# Dish 2 — medium, left-facing
	var dish2_track: float = sin(t * 0.3 + 1.5) * 0.12
	var dish2_cx: float = -tower_w / 2.0 - 3.0
	var dish2_cy: float = dish_base_y + 20.0
	var dish2_pts := PackedVector2Array([
		Vector2(dish2_cx, dish2_cy - 10.0),
		Vector2(dish2_cx - 18.0 + dish2_track * 8.0, dish2_cy),
		Vector2(dish2_cx, dish2_cy + 10.0),
	])
	node.draw_colored_polygon(dish2_pts, Color(0.72, 0.74, 0.8))
	# Dish arm
	node.draw_line(Vector2(0.0, dish2_cy), Vector2(dish2_cx, dish2_cy), Color(0.65, 0.67, 0.72), 2.0)
	# Dish feed
	node.draw_circle(Vector2(dish2_cx - 6.0, dish2_cy), 2.0, Color(0.5, 0.55, 0.62))
	var dish2_active: float = 0.4 + 0.4 * sin(t * 2.0 + 1.0)
	node.draw_circle(Vector2(dish2_cx - 6.0, dish2_cy), 1.2, Color(0.2, 0.8, 1.0, dish2_active))

	# Dish 3 — small, upward-facing
	var dish3_track: float = sin(t * 0.4 + 3.0) * 0.1
	var dish3_cy: float = dish_base_y + 2.0
	var dish3_pts := PackedVector2Array([
		Vector2(-8.0, dish3_cy),
		Vector2(0.0, dish3_cy - 14.0 + dish3_track * 5.0),
		Vector2(8.0, dish3_cy),
	])
	node.draw_colored_polygon(dish3_pts, Color(0.7, 0.72, 0.78))
	# Dish stem
	node.draw_line(Vector2(0.0, dish3_cy), Vector2(0.0, dish3_cy + 8.0), Color(0.65, 0.67, 0.72), 2.0)
	var dish3_active: float = 0.4 + 0.4 * sin(t * 2.5 + 2.0)
	node.draw_circle(Vector2(0.0, dish3_cy - 5.0), 1.5, Color(0.2, 0.8, 1.0, dish3_active))

	# Lightning rod at peak
	var rod_base_y: float = tower_y
	var rod_top_y: float = tower_y - 20.0
	node.draw_line(Vector2(0.0, rod_base_y), Vector2(0.0, rod_top_y), Color(0.7, 0.72, 0.76), 2.0)
	# Cross bar
	node.draw_line(Vector2(-5.0, rod_top_y + 5.0), Vector2(5.0, rod_top_y + 5.0), Color(0.65, 0.67, 0.72), 1.5)

	# Blinking antenna light at very top — red dot
	var blink_val: float = sin(t * 4.0)
	var blink_alpha: float = 0.9 if blink_val > 0.0 else 0.15
	node.draw_circle(Vector2(0.0, rod_top_y - 2.0), 3.5, Color(1.0, 0.1, 0.05, blink_alpha))
	# Glow around when bright
	if blink_val > 0.0:
		node.draw_circle(Vector2(0.0, rod_top_y - 2.0), 7.0, Color(1.0, 0.15, 0.1, blink_alpha * 0.2))

	# Atmospheric data sensors — small protruding shapes on sides
	for i in 3:
		var sensor_y: float = tower_y + tower_h * (0.1 + float(i) * 0.3)
		# Left sensor
		node.draw_rect(Rect2(-tower_w / 2.0 - 10.0, sensor_y, 10.0, 4.0), Color(0.65, 0.67, 0.72))
		node.draw_circle(Vector2(-tower_w / 2.0 - 12.0, sensor_y + 2.0), 2.0, Color(0.5, 0.55, 0.62))
		# Right sensor
		node.draw_rect(Rect2(tower_w / 2.0, sensor_y + 6.0, 10.0, 4.0), Color(0.65, 0.67, 0.72))
		node.draw_circle(Vector2(tower_w / 2.0 + 12.0, sensor_y + 8.0), 2.0, Color(0.5, 0.55, 0.62))

	# Tower panel lines — horizontal
	for i in int(tower_h / 20.0):
		var py: float = tower_y + float(i) * 20.0
		node.draw_line(Vector2(-tower_w / 2.0, py), Vector2(tower_w / 2.0, py), Color(0.78, 0.8, 0.84, 0.2), 1.0)

	# Entrance at base
	node.draw_rect(Rect2(-12.0, -base_h * 0.7, 24.0, base_h * 0.7), Color(0.62, 0.64, 0.7))
	# Door frame
	node.draw_rect(Rect2(-12.0, -base_h * 0.7, 24.0, base_h * 0.7), Color(0.72, 0.74, 0.78, 0.5), false, 1.5)

	# Blue entrance glow
	var ent_glow: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-16.0, -4.0, 32.0, 6.0), Color(0.3, 0.55, 0.95, ent_glow))

	# Tower edge lines
	node.draw_line(Vector2(-tower_w / 2.0, tower_y), Vector2(-tower_w / 2.0, -base_h), Color(0.8, 0.82, 0.86, 0.5), 1.5)
	node.draw_line(Vector2(tower_w / 2.0, tower_y), Vector2(tower_w / 2.0, -base_h), Color(0.8, 0.82, 0.86, 0.5), 1.5)
	# Base edges
	node.draw_line(Vector2(-base_w / 2.0, -base_h), Vector2(base_w / 2.0, -base_h), Color(0.65, 0.67, 0.72, 0.5), 2.0)
