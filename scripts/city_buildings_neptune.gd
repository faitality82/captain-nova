class_name CityBuildingsNeptune
extends RefCounted

# Neptune — "Triton Frost" crystalline settlement
# Crystalline ice, deep blues, aurora reflections, elegant frozen architecture.
# Colors: deep blue (0.15, 0.2, 0.45), ice crystal (0.6, 0.8, 0.95), aurora green/pink.


# ── 1. HANGAR — Crystalline ice hangar with frozen bay doors ─────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	# Main ice-block walls
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.12, 0.18, 0.38, 0.9))

	# Ice block texture — translucent blue rectangles with internal lines
	for row_idx in 8:
		for col_idx in 5:
			var bx: float = -w / 2.0 + 4.0 + float(col_idx) * (w - 8.0) / 5.0
			var by: float = -h + 4.0 + float(row_idx) * (h - 8.0) / 8.0
			var bw: float = (w - 8.0) / 5.0 - 3.0
			var bh: float = (h - 8.0) / 8.0 - 3.0
			node.draw_rect(Rect2(bx, by, bw, bh), Color(0.18, 0.28, 0.52, 0.3))
			node.draw_rect(Rect2(bx, by, bw, bh), Color(0.4, 0.6, 0.85, 0.15), false, 1.0)
			# Internal fracture line
			node.draw_line(
				Vector2(bx + 2.0, by + bh * 0.3),
				Vector2(bx + bw - 2.0, by + bh * 0.7),
				Color(0.5, 0.7, 0.9, 0.1), 1.0
			)

	# Internal blue glow
	node.draw_rect(Rect2(-w / 2.0 + 6.0, -h + 6.0, w - 12.0, h - 12.0), Color(0.1, 0.2, 0.5, 0.08))

	# Bay door opening (center bottom) — frozen partially open
	var door_w: float = w * 0.5
	var door_h: float = h * 0.6
	var door_x: float = -door_w / 2.0
	var door_y: float = -door_h
	node.draw_rect(Rect2(door_x, door_y, door_w, door_h), Color(0.06, 0.1, 0.2))

	# Frozen door panels — ice has jammed them partially open
	var jam_h: float = door_h * 0.3
	node.draw_rect(Rect2(door_x, door_y, door_w, jam_h), Color(0.15, 0.22, 0.4, 0.7))
	# Horizontal slat lines on frozen portion
	for i in 6:
		var sy: float = door_y + float(i) * jam_h / 6.0
		node.draw_line(Vector2(door_x, sy), Vector2(door_x + door_w, sy), Color(0.3, 0.45, 0.65, 0.3), 1.0)

	# Ice formations bridging the gap (icicles growing from bottom of frozen door)
	for i in 7:
		var ice_x: float = door_x + 10.0 + float(i) * (door_w - 20.0) / 6.0
		var ice_len: float = 12.0 + fmod(float(i) * 8.3, 18.0)
		var ice_pts: PackedVector2Array = PackedVector2Array([
			Vector2(ice_x - 3.0, door_y + jam_h),
			Vector2(ice_x + 3.0, door_y + jam_h),
			Vector2(ice_x, door_y + jam_h + ice_len),
		])
		node.draw_colored_polygon(ice_pts, Color(0.45, 0.65, 0.85, 0.45))

	# Ice formations growing upward from floor in doorway
	for i in 5:
		var ice_x: float = door_x + 15.0 + float(i) * (door_w - 30.0) / 4.0
		var ice_len: float = 8.0 + fmod(float(i) * 6.7, 14.0)
		var ice_pts: PackedVector2Array = PackedVector2Array([
			Vector2(ice_x - 2.5, 0.0),
			Vector2(ice_x + 2.5, 0.0),
			Vector2(ice_x, -ice_len),
		])
		node.draw_colored_polygon(ice_pts, Color(0.4, 0.6, 0.8, 0.4))

	# Crystal formations growing from walls (left side)
	for i in 4:
		var cy: float = -h * 0.3 - float(i) * h * 0.15
		var cx: float = -w / 2.0
		var crystal_len: float = 18.0 + fmod(float(i) * 11.3, 15.0)
		var crystal_pts: PackedVector2Array = PackedVector2Array([
			Vector2(cx, cy - 4.0),
			Vector2(cx, cy + 4.0),
			Vector2(cx + crystal_len, cy - 1.0),
		])
		node.draw_colored_polygon(crystal_pts, Color(0.5, 0.7, 0.92, 0.4))
		node.draw_polyline(PackedVector2Array([
			Vector2(cx, cy - 4.0), Vector2(cx + crystal_len, cy - 1.0), Vector2(cx, cy + 4.0)
		]), Color(0.6, 0.85, 1.0, 0.3), 1.0)

	# Crystal formations from right wall
	for i in 4:
		var cy: float = -h * 0.25 - float(i) * h * 0.15
		var cx: float = w / 2.0
		var crystal_len: float = 16.0 + fmod(float(i) * 9.7, 14.0)
		var crystal_pts: PackedVector2Array = PackedVector2Array([
			Vector2(cx, cy - 3.5),
			Vector2(cx, cy + 3.5),
			Vector2(cx - crystal_len, cy - 0.5),
		])
		node.draw_colored_polygon(crystal_pts, Color(0.48, 0.68, 0.9, 0.4))

	# Crystal formations from ceiling
	for i in 6:
		var cx: float = -w / 2.0 + 20.0 + float(i) * (w - 40.0) / 5.0
		var crystal_len: float = 14.0 + fmod(float(i) * 7.9, 12.0)
		var crystal_pts: PackedVector2Array = PackedVector2Array([
			Vector2(cx - 3.0, -h),
			Vector2(cx + 3.0, -h),
			Vector2(cx, -h + crystal_len),
		])
		node.draw_colored_polygon(crystal_pts, Color(0.5, 0.72, 0.92, 0.5))

	# Aurora light reflections on surfaces — animated color streaks
	for i in 5:
		var ax: float = -w / 2.0 + 15.0 + float(i) * (w - 30.0) / 4.0
		var ay: float = -h + 20.0 + fmod(float(i) * 19.3, h * 0.4)
		var a_alpha: float = 0.12 + 0.08 * sin(t * 1.5 + float(i) * 1.3)
		# Green streak
		node.draw_line(
			Vector2(ax - 15.0, ay), Vector2(ax + 15.0, ay - 5.0),
			Color(0.2, 0.85, 0.5, a_alpha), 2.0
		)
		# Pink streak offset
		node.draw_line(
			Vector2(ax - 12.0, ay + 6.0), Vector2(ax + 12.0, ay + 1.0),
			Color(0.85, 0.3, 0.65, a_alpha * 0.8), 1.5
		)
		# Purple streak
		node.draw_line(
			Vector2(ax - 10.0, ay + 11.0), Vector2(ax + 10.0, ay + 7.0),
			Color(0.6, 0.25, 0.85, a_alpha * 0.6), 1.5
		)

	# Frost particles in air near entrance
	for i in 12:
		var px: float = door_x + fmod(float(i) * 17.3, door_w)
		var progress: float = fmod(t * 0.4 + float(i) * 0.55, 3.0)
		var py: float = -door_h * 0.5 + progress * 15.0
		var p_alpha: float = 0.35 - progress * 0.1
		if p_alpha > 0.0:
			node.draw_circle(Vector2(px, py), 1.5 + fmod(float(i) * 2.3, 2.0), Color(0.7, 0.85, 1.0, p_alpha))

	# Frozen landing pad lines visible through translucent floor
	for i in 4:
		var lx: float = door_x + 8.0 + float(i) * (door_w - 16.0) / 3.0
		node.draw_line(Vector2(lx, -8.0), Vector2(lx, -2.0), Color(0.3, 0.55, 0.8, 0.15), 2.0)
	node.draw_line(Vector2(door_x + 8.0, -5.0), Vector2(door_x + door_w - 8.0, -5.0), Color(0.3, 0.55, 0.8, 0.12), 2.0)

	# Icicle fringe along roof edge
	for i in 14:
		var ice_x: float = -w / 2.0 + 6.0 + float(i) * (w - 12.0) / 13.0
		var ice_len: float = 8.0 + fmod(float(i) * 5.7, 14.0)
		var ice_pts: PackedVector2Array = PackedVector2Array([
			Vector2(ice_x - 2.5, -h),
			Vector2(ice_x + 2.5, -h),
			Vector2(ice_x, -h + ice_len),
		])
		node.draw_colored_polygon(ice_pts, Color(0.5, 0.72, 0.88, 0.5))

	# Cold mist at floor level
	for i in 8:
		var mx: float = -w / 2.0 + 10.0 + float(i) * (w - 20.0) / 7.0
		var mist_shift: float = sin(t * 0.6 + float(i) * 0.9) * 8.0
		var m_alpha: float = 0.12 + 0.06 * sin(t * 1.0 + float(i) * 1.4)
		node.draw_circle(Vector2(mx + mist_shift, -6.0), 12.0 + fmod(float(i) * 3.7, 8.0), Color(0.4, 0.6, 0.85, m_alpha))

	# Entrance glow
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(door_x - 4.0, -4.0, door_w + 8.0, 6.0), Color(0.2, 0.5, 0.9, glow_pulse))

	# Frost roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.55, 0.72, 0.9, 0.6), 3.0)


# ── 2. MARKET — Ice shelf shop with goods frozen in display blocks ───────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	# Main structure — deep blue ice
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.13, 0.19, 0.4, 0.9))

	# Ice archway entrance (pointed arch)
	var arch_w: float = w * 0.28
	var arch_h: float = h * 0.35
	# Arch opening
	node.draw_rect(Rect2(-arch_w / 2.0, -arch_h, arch_w, arch_h), Color(0.06, 0.1, 0.2))
	# Left arch curve
	var arch_pts_l: PackedVector2Array = PackedVector2Array([
		Vector2(-arch_w / 2.0 - 6.0, -arch_h),
		Vector2(-arch_w / 2.0, -arch_h),
		Vector2(-arch_w / 2.0, 0.0),
		Vector2(-arch_w / 2.0 - 6.0, 0.0),
	])
	node.draw_colored_polygon(arch_pts_l, Color(0.18, 0.28, 0.52, 0.8))
	# Right arch curve
	var arch_pts_r: PackedVector2Array = PackedVector2Array([
		Vector2(arch_w / 2.0, -arch_h),
		Vector2(arch_w / 2.0 + 6.0, -arch_h),
		Vector2(arch_w / 2.0 + 6.0, 0.0),
		Vector2(arch_w / 2.0, 0.0),
	])
	node.draw_colored_polygon(arch_pts_r, Color(0.18, 0.28, 0.52, 0.8))
	# Arch peak
	var peak_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-arch_w / 2.0 - 6.0, -arch_h),
		Vector2(0.0, -arch_h - 18.0),
		Vector2(arch_w / 2.0 + 6.0, -arch_h),
	])
	node.draw_colored_polygon(peak_pts, Color(0.18, 0.28, 0.52, 0.8))
	node.draw_polyline(PackedVector2Array([
		Vector2(-arch_w / 2.0 - 6.0, -arch_h),
		Vector2(0.0, -arch_h - 18.0),
		Vector2(arch_w / 2.0 + 6.0, -arch_h),
	]), Color(0.5, 0.7, 0.9, 0.5), 2.0)

	# Icicle curtain entrance — row of hanging triangles
	for i in 9:
		var ix: float = -arch_w / 2.0 + 3.0 + float(i) * (arch_w - 6.0) / 8.0
		var ilen: float = 10.0 + fmod(float(i) * 4.3, 16.0)
		var icicle_pts: PackedVector2Array = PackedVector2Array([
			Vector2(ix - 1.5, -arch_h),
			Vector2(ix + 1.5, -arch_h),
			Vector2(ix, -arch_h + ilen),
		])
		node.draw_colored_polygon(icicle_pts, Color(0.5, 0.7, 0.9, 0.45))

	# Ice shelf display cases — 3 across, 2 rows
	var case_w: float = w * 0.22
	var case_h: float = h * 0.16
	var shelf_start_y: float = -h + h * 0.15
	for row_idx in 2:
		for col_idx in 3:
			var cx: float = -w / 2.0 + 12.0 + float(col_idx) * (w - 24.0) / 3.0
			var cy: float = shelf_start_y + float(row_idx) * (case_h + h * 0.1)

			# Ice block case
			node.draw_rect(Rect2(cx, cy, case_w, case_h), Color(0.2, 0.35, 0.6, 0.35))
			node.draw_rect(Rect2(cx, cy, case_w, case_h), Color(0.45, 0.65, 0.88, 0.3), false, 1.5)

			# Frozen goods inside — colored rectangles visible through ice
			var goods_color_r: float = 0.3 + fmod(float(row_idx * 3 + col_idx) * 0.23, 0.5)
			var goods_color_g: float = 0.2 + fmod(float(row_idx * 3 + col_idx) * 0.37, 0.5)
			var goods_color_b: float = 0.15 + fmod(float(row_idx * 3 + col_idx) * 0.19, 0.4)
			# Item 1
			node.draw_rect(Rect2(cx + 4.0, cy + 4.0, case_w * 0.3, case_h * 0.6),
				Color(goods_color_r, goods_color_g, goods_color_b, 0.4))
			# Item 2
			node.draw_rect(Rect2(cx + case_w * 0.45, cy + 6.0, case_w * 0.25, case_h * 0.5),
				Color(goods_color_g, goods_color_b, goods_color_r, 0.35))
			# Item 3 (small)
			node.draw_circle(Vector2(cx + case_w * 0.82, cy + case_h * 0.5), case_h * 0.2,
				Color(goods_color_b, goods_color_r, goods_color_g, 0.35))

			# Price tag — small rectangle
			node.draw_rect(Rect2(cx + case_w - 14.0, cy - 5.0, 12.0, 5.0), Color(0.8, 0.85, 0.9, 0.3))
			node.draw_line(Vector2(cx + case_w - 12.0, cy - 3.0), Vector2(cx + case_w - 4.0, cy - 3.0),
				Color(0.1, 0.15, 0.3, 0.4), 1.0)

	# Crystal shelf supports
	for col_idx in 4:
		var sx: float = -w / 2.0 + 8.0 + float(col_idx) * (w - 16.0) / 3.0
		node.draw_rect(Rect2(sx - 2.0, shelf_start_y - 4.0, 4.0, h * 0.55), Color(0.25, 0.4, 0.6, 0.4))
		# Crystal facets on supports
		for facet_idx in 3:
			var fy: float = shelf_start_y + float(facet_idx) * h * 0.15
			node.draw_line(Vector2(sx - 2.0, fy), Vector2(sx + 2.0, fy + 6.0), Color(0.5, 0.75, 0.95, 0.2), 1.0)

	# Frozen counter top — translucent blue rectangle at bottom
	var counter_w: float = w * 0.65
	var counter_h: float = h * 0.08
	var counter_y: float = -h * 0.2
	node.draw_rect(Rect2(-counter_w / 2.0, counter_y, counter_w, counter_h), Color(0.22, 0.38, 0.62, 0.5))
	node.draw_rect(Rect2(-counter_w / 2.0, counter_y, counter_w, counter_h), Color(0.5, 0.7, 0.9, 0.3), false, 1.5)
	# Counter top frost lines
	for i in 6:
		var fx: float = -counter_w / 2.0 + 5.0 + float(i) * (counter_w - 10.0) / 5.0
		node.draw_line(Vector2(fx, counter_y + 1.0), Vector2(fx + 8.0, counter_y + counter_h - 1.0),
			Color(0.6, 0.8, 1.0, 0.15), 1.0)

	# Warm lamp in corner — contrast glow
	var lamp_x: float = w / 2.0 - 20.0
	var lamp_y: float = -h + 25.0
	node.draw_circle(Vector2(lamp_x, lamp_y), 5.0, Color(0.9, 0.7, 0.3, 0.6))
	var lamp_glow: float = 0.12 + 0.06 * sin(t * 2.0)
	node.draw_circle(Vector2(lamp_x, lamp_y), 18.0, Color(0.9, 0.65, 0.2, lamp_glow))
	node.draw_circle(Vector2(lamp_x, lamp_y), 30.0, Color(0.8, 0.6, 0.2, lamp_glow * 0.4))

	# Cold mist at floor level
	for i in 10:
		var mx: float = -w / 2.0 + 8.0 + float(i) * (w - 16.0) / 9.0
		var mist_shift: float = sin(t * 0.5 + float(i) * 0.8) * 6.0
		var m_alpha: float = 0.1 + 0.05 * sin(t * 0.9 + float(i) * 1.2)
		node.draw_circle(Vector2(mx + mist_shift, -5.0), 10.0 + fmod(float(i) * 3.1, 6.0),
			Color(0.4, 0.6, 0.85, m_alpha))

	# Ice block wall texture
	for i in 10:
		var bx: float = -w / 2.0 + fmod(float(i) * 41.3, w - 20.0)
		var by: float = -h + fmod(float(i) * 33.7, h * 0.5)
		node.draw_rect(Rect2(bx, by, 18.0, 12.0), Color(0.18, 0.3, 0.5, 0.12))
		node.draw_rect(Rect2(bx, by, 18.0, 12.0), Color(0.4, 0.6, 0.82, 0.1), false, 1.0)

	# Entrance glow
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-arch_w / 2.0 - 4.0, -4.0, arch_w + 8.0, 6.0), Color(0.2, 0.5, 0.9, glow_pulse))

	# Frost roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.55, 0.72, 0.9, 0.6), 3.0)


# ── 3. BAR — Ice lounge with carved furniture ────────────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	# Main ice structure
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.1, 0.15, 0.35, 0.9))

	# Crystalline floor patterns — geometric ice lines
	for i in 8:
		var fx: float = -w / 2.0 + 10.0 + float(i) * (w - 20.0) / 7.0
		node.draw_line(Vector2(fx, -2.0), Vector2(fx + 12.0, -12.0), Color(0.4, 0.6, 0.85, 0.15), 1.0)
		node.draw_line(Vector2(fx + 12.0, -12.0), Vector2(fx + 24.0, -2.0), Color(0.4, 0.6, 0.85, 0.12), 1.0)

	# Ice bar counter (left-center area)
	var bar_x: float = -w / 2.0 + w * 0.12
	var bar_w: float = w * 0.5
	var bar_y: float = -h * 0.3
	var bar_h: float = h * 0.08
	# Counter top
	node.draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.22, 0.38, 0.6, 0.55))
	node.draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.5, 0.72, 0.92, 0.35), false, 2.0)
	# Counter front panel
	node.draw_rect(Rect2(bar_x, bar_y + bar_h, bar_w, h * 0.12), Color(0.18, 0.3, 0.5, 0.5))
	# Counter ice texture lines
	for i in 6:
		var lx: float = bar_x + 5.0 + float(i) * (bar_w - 10.0) / 5.0
		node.draw_line(Vector2(lx, bar_y + 1.0), Vector2(lx + 4.0, bar_y + bar_h - 1.0),
			Color(0.55, 0.75, 0.95, 0.2), 1.0)

	# Ice bar stools — 4 stools in front of counter
	for i in 4:
		var stool_x: float = bar_x + 15.0 + float(i) * (bar_w - 30.0) / 3.0
		var stool_y: float = bar_y + bar_h + h * 0.12 + 2.0
		# Stool seat (small ice rectangle)
		node.draw_rect(Rect2(stool_x - 6.0, stool_y, 12.0, 3.0), Color(0.25, 0.42, 0.62, 0.45))
		# Stool leg
		node.draw_line(Vector2(stool_x, stool_y + 3.0), Vector2(stool_x, stool_y + 14.0),
			Color(0.25, 0.42, 0.62, 0.4), 2.0)
		# Stool base
		node.draw_line(Vector2(stool_x - 5.0, stool_y + 14.0), Vector2(stool_x + 5.0, stool_y + 14.0),
			Color(0.25, 0.42, 0.62, 0.35), 2.0)

	# Warm drinks with steam above bar
	for i in 3:
		var drink_x: float = bar_x + 20.0 + float(i) * (bar_w - 40.0) / 2.0
		# Glass shape
		node.draw_rect(Rect2(drink_x - 3.0, bar_y - 8.0, 6.0, 8.0), Color(0.8, 0.5, 0.2, 0.4))
		# Steam wisps rising
		for wisp_idx in 3:
			var wisp_progress: float = fmod(t * 0.7 + float(i) * 0.5 + float(wisp_idx) * 0.9, 2.5)
			var wisp_y: float = bar_y - 10.0 - wisp_progress * 12.0
			var wisp_x_drift: float = sin(t * 1.5 + float(i) * 2.0 + float(wisp_idx) * 1.3) * 4.0
			var wisp_alpha: float = 0.3 - wisp_progress * 0.1
			if wisp_alpha > 0.0:
				node.draw_circle(Vector2(drink_x + wisp_x_drift, wisp_y), 2.0,
					Color(0.8, 0.85, 0.95, wisp_alpha))

	# Ice tables (right side, 2 tables)
	for tbl_idx in 2:
		var tbl_x: float = w / 2.0 - w * 0.3 + float(tbl_idx) * w * 0.15
		var tbl_y: float = -h * 0.35 + float(tbl_idx) * h * 0.12
		# Table top
		node.draw_rect(Rect2(tbl_x - 12.0, tbl_y, 24.0, 3.0), Color(0.25, 0.42, 0.6, 0.4))
		# Table legs
		node.draw_line(Vector2(tbl_x - 8.0, tbl_y + 3.0), Vector2(tbl_x - 8.0, tbl_y + 16.0),
			Color(0.25, 0.42, 0.6, 0.35), 2.0)
		node.draw_line(Vector2(tbl_x + 8.0, tbl_y + 3.0), Vector2(tbl_x + 8.0, tbl_y + 16.0),
			Color(0.25, 0.42, 0.6, 0.35), 2.0)

	# Aurora lights overhead — animated color waves
	for i in 7:
		var ax: float = -w / 2.0 + 15.0 + float(i) * (w - 30.0) / 6.0
		var ay: float = -h + 12.0
		var wave_shift: float = sin(t * 1.2 + float(i) * 0.8) * 10.0
		# Green aurora band
		var a_green: float = 0.15 + 0.1 * sin(t * 0.9 + float(i) * 1.1)
		node.draw_line(Vector2(ax - 12.0, ay), Vector2(ax + 12.0 + wave_shift, ay + 4.0),
			Color(0.15, 0.85, 0.45, a_green), 3.0)
		# Pink aurora band
		var a_pink: float = 0.12 + 0.08 * sin(t * 1.1 + float(i) * 1.5)
		node.draw_line(Vector2(ax - 8.0, ay + 6.0), Vector2(ax + 8.0 + wave_shift * 0.7, ay + 10.0),
			Color(0.9, 0.3, 0.6, a_pink), 2.5)
		# Purple aurora band
		var a_purp: float = 0.1 + 0.07 * sin(t * 1.3 + float(i) * 0.9)
		node.draw_line(Vector2(ax - 10.0, ay + 13.0), Vector2(ax + 10.0 + wave_shift * 0.5, ay + 16.0),
			Color(0.55, 0.2, 0.85, a_purp), 2.0)

	# Ice chandelier — center ceiling
	var ch_x: float = 0.0
	var ch_y: float = -h + 22.0
	# Chain from ceiling
	node.draw_line(Vector2(ch_x, -h), Vector2(ch_x, ch_y), Color(0.5, 0.68, 0.85, 0.5), 2.0)
	# Radiating lines downward with drops
	for i in 8:
		var angle: float = float(i) * TAU / 8.0
		var ray_x: float = ch_x + cos(angle) * 16.0
		var ray_y: float = ch_y + sin(angle) * 8.0
		node.draw_line(Vector2(ch_x, ch_y), Vector2(ray_x, ray_y), Color(0.5, 0.72, 0.92, 0.4), 1.5)
		# Drop at end of each ray
		var drop_len: float = 6.0 + fmod(float(i) * 3.7, 8.0)
		node.draw_line(Vector2(ray_x, ray_y), Vector2(ray_x, ray_y + drop_len),
			Color(0.55, 0.78, 0.95, 0.45), 1.0)
		node.draw_circle(Vector2(ray_x, ray_y + drop_len), 1.5, Color(0.65, 0.85, 1.0, 0.5))
	# Central sparkle
	var ch_sparkle: float = 0.4 + 0.4 * sin(t * 3.0)
	node.draw_circle(Vector2(ch_x, ch_y), 4.0, Color(0.85, 0.92, 1.0, ch_sparkle))

	# Frosted windows — partially transparent with frost patterns
	var win_y: float = -h * 0.65
	for i in 3:
		var wx: float = -w / 2.0 + w * (float(i + 1) / 4.0)
		# Window frame
		node.draw_rect(Rect2(wx - 14.0, win_y - 12.0, 28.0, 24.0), Color(0.25, 0.4, 0.6, 0.3))
		node.draw_rect(Rect2(wx - 14.0, win_y - 12.0, 28.0, 24.0), Color(0.5, 0.7, 0.9, 0.3), false, 1.5)
		# Frost pattern lines on glass
		for frost_idx in 4:
			var f_angle: float = float(frost_idx) * PI / 2.0 + 0.3
			var f_len: float = 8.0
			node.draw_line(
				Vector2(wx, win_y),
				Vector2(wx + cos(f_angle) * f_len, win_y + sin(f_angle) * f_len),
				Color(0.7, 0.85, 0.95, 0.25), 1.0
			)

	# Elegant ice archway entrance
	var earch_w: float = 24.0
	node.draw_rect(Rect2(-earch_w / 2.0, -h * 0.16, earch_w, h * 0.16), Color(0.08, 0.12, 0.25))
	node.draw_arc(Vector2(0.0, -h * 0.16), earch_w / 2.0, PI, TAU, 16, Color(0.45, 0.65, 0.88, 0.5), 2.5)

	# Soft warm amber interior glow (contrast)
	var amber_glow: float = 0.06 + 0.03 * sin(t * 1.5)
	node.draw_rect(Rect2(-w / 2.0 + 8.0, -h * 0.5, w - 16.0, h * 0.25), Color(0.8, 0.55, 0.2, amber_glow))

	# Ice sculpture decorations — abstract shapes on sides
	# Left sculpture — hexagonal
	var sc_x: float = -w / 2.0 + 25.0
	var sc_y: float = -h * 0.5
	var hex_pts: PackedVector2Array = PackedVector2Array()
	for i in 6:
		var angle: float = float(i) * TAU / 6.0 - PI / 6.0
		hex_pts.append(Vector2(sc_x + cos(angle) * 10.0, sc_y + sin(angle) * 10.0))
	node.draw_colored_polygon(hex_pts, Color(0.3, 0.5, 0.72, 0.3))
	node.draw_polyline(hex_pts, Color(0.55, 0.78, 0.95, 0.35), 1.0)

	# Right sculpture — star shape
	var sc2_x: float = w / 2.0 - 25.0
	var sc2_y: float = -h * 0.55
	for i in 5:
		var angle: float = float(i) * TAU / 5.0 - PI / 2.0
		var outer_x: float = sc2_x + cos(angle) * 10.0
		var outer_y: float = sc2_y + sin(angle) * 10.0
		node.draw_line(Vector2(sc2_x, sc2_y), Vector2(outer_x, outer_y), Color(0.5, 0.72, 0.92, 0.35), 1.5)

	# Entrance glow
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-earch_w / 2.0 - 4.0, -4.0, earch_w + 8.0, 6.0), Color(0.2, 0.5, 0.9, glow_pulse))

	# Frost roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.55, 0.72, 0.9, 0.6), 3.0)


# ── 4. GARAGE — Cryo-forge ──────────────────────────────────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	# Main structure
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.12, 0.16, 0.34, 0.9))

	# Forge area (center-left) — blue/white flames
	var forge_x: float = -w * 0.2
	var forge_y: float = -h * 0.35
	var forge_w: float = w * 0.3
	var forge_h: float = h * 0.2
	# Forge base
	node.draw_rect(Rect2(forge_x, forge_y, forge_w, forge_h), Color(0.08, 0.12, 0.22))
	node.draw_rect(Rect2(forge_x, forge_y, forge_w, forge_h), Color(0.3, 0.45, 0.65, 0.3), false, 2.0)

	# Animated blue/white flames
	for i in 6:
		var flame_x: float = forge_x + 8.0 + float(i) * (forge_w - 16.0) / 5.0
		var flame_h_val: float = 12.0 + 6.0 * sin(t * 3.0 + float(i) * 1.2)
		var flame_pts: PackedVector2Array = PackedVector2Array([
			Vector2(flame_x - 4.0, forge_y),
			Vector2(flame_x + 4.0, forge_y),
			Vector2(flame_x + 1.0 + sin(t * 4.0 + float(i)) * 2.0, forge_y - flame_h_val),
		])
		# Blue core
		node.draw_colored_polygon(flame_pts, Color(0.3, 0.5, 0.95, 0.5))
		# White tip
		var tip_pts: PackedVector2Array = PackedVector2Array([
			Vector2(flame_x - 2.0, forge_y - flame_h_val * 0.4),
			Vector2(flame_x + 2.0, forge_y - flame_h_val * 0.4),
			Vector2(flame_x + sin(t * 4.0 + float(i)) * 1.5, forge_y - flame_h_val),
		])
		node.draw_colored_polygon(tip_pts, Color(0.7, 0.85, 1.0, 0.45))

	# Forge glow
	var forge_glow: float = 0.1 + 0.06 * sin(t * 2.5)
	node.draw_circle(Vector2(forge_x + forge_w / 2.0, forge_y - 5.0), 30.0,
		Color(0.3, 0.5, 0.95, forge_glow))

	# Anvil with frost coating
	var anvil_x: float = forge_x + forge_w + 15.0
	var anvil_y: float = -h * 0.22
	# Anvil body (dark)
	var anvil_pts: PackedVector2Array = PackedVector2Array([
		Vector2(anvil_x - 12.0, anvil_y),
		Vector2(anvil_x + 12.0, anvil_y),
		Vector2(anvil_x + 16.0, anvil_y + 6.0),
		Vector2(anvil_x + 8.0, anvil_y + 18.0),
		Vector2(anvil_x - 8.0, anvil_y + 18.0),
		Vector2(anvil_x - 16.0, anvil_y + 6.0),
	])
	node.draw_colored_polygon(anvil_pts, Color(0.15, 0.18, 0.25))
	# Frost overlay on anvil
	node.draw_colored_polygon(anvil_pts, Color(0.4, 0.6, 0.85, 0.15))
	# Anvil frost edge
	node.draw_polyline(PackedVector2Array([
		Vector2(anvil_x - 12.0, anvil_y), Vector2(anvil_x + 12.0, anvil_y),
		Vector2(anvil_x + 16.0, anvil_y + 6.0)
	]), Color(0.55, 0.75, 0.92, 0.3), 1.5)

	# Tools encased in ice along left wall
	for i in 5:
		var tool_y: float = -h + 20.0 + float(i) * (h * 0.6) / 5.0
		var tool_x: float = -w / 2.0 + 8.0
		# Ice block containing tool
		node.draw_rect(Rect2(tool_x, tool_y, 22.0, 14.0), Color(0.2, 0.35, 0.55, 0.35))
		node.draw_rect(Rect2(tool_x, tool_y, 22.0, 14.0), Color(0.45, 0.65, 0.85, 0.25), false, 1.0)
		# Tool shape inside (line)
		node.draw_line(Vector2(tool_x + 3.0, tool_y + 7.0), Vector2(tool_x + 19.0, tool_y + 7.0),
			Color(0.35, 0.38, 0.45, 0.5), 2.0)
		# Tool head
		node.draw_rect(Rect2(tool_x + 15.0, tool_y + 3.0, 5.0, 8.0), Color(0.3, 0.33, 0.4, 0.45))

	# Cryo-welding sparks — blue-white animated dots
	for i in 10:
		var spark_progress: float = fmod(t * 2.0 + float(i) * 0.7, 2.0)
		var spark_x: float = forge_x + forge_w / 2.0 + sin(float(i) * 2.3 + t * 3.0) * 20.0
		var spark_y: float = forge_y - 5.0 - spark_progress * 15.0
		var spark_alpha: float = 0.6 - spark_progress * 0.25
		if spark_alpha > 0.0:
			node.draw_circle(Vector2(spark_x, spark_y), 1.5,
				Color(0.7, 0.85, 1.0, spark_alpha))

	# Steam venting from work area
	for i in 5:
		var steam_x: float = forge_x + 10.0 + float(i) * (forge_w - 20.0) / 4.0
		var steam_progress: float = fmod(t * 0.5 + float(i) * 0.6, 3.0)
		var steam_y: float = forge_y - 20.0 - steam_progress * 20.0
		var steam_drift: float = sin(t * 1.2 + float(i) * 1.5) * 6.0
		var steam_alpha: float = 0.2 - steam_progress * 0.06
		if steam_alpha > 0.0:
			node.draw_circle(Vector2(steam_x + steam_drift, steam_y), 5.0 + steam_progress * 3.0,
				Color(0.5, 0.65, 0.85, steam_alpha))

	# Ice stalactites from ceiling
	for i in 10:
		var stx: float = -w / 2.0 + 12.0 + float(i) * (w - 24.0) / 9.0
		var st_len: float = 10.0 + fmod(float(i) * 7.3, 16.0)
		var st_pts: PackedVector2Array = PackedVector2Array([
			Vector2(stx - 3.0, -h),
			Vector2(stx + 3.0, -h),
			Vector2(stx, -h + st_len),
		])
		node.draw_colored_polygon(st_pts, Color(0.48, 0.68, 0.9, 0.45))

	# Work bench with frozen equipment (right side)
	var bench_x: float = w / 2.0 - w * 0.3
	var bench_y: float = -h * 0.3
	node.draw_rect(Rect2(bench_x, bench_y, w * 0.22, h * 0.06), Color(0.2, 0.32, 0.5, 0.5))
	# Equipment on bench
	node.draw_rect(Rect2(bench_x + 5.0, bench_y - 8.0, 10.0, 8.0), Color(0.18, 0.25, 0.4, 0.45))
	node.draw_rect(Rect2(bench_x + 20.0, bench_y - 12.0, 8.0, 12.0), Color(0.2, 0.28, 0.42, 0.45))
	# Frost on equipment
	node.draw_rect(Rect2(bench_x + 5.0, bench_y - 8.0, 10.0, 3.0), Color(0.45, 0.65, 0.85, 0.2))
	node.draw_rect(Rect2(bench_x + 20.0, bench_y - 12.0, 8.0, 3.0), Color(0.45, 0.65, 0.85, 0.2))

	# Temperature display (cold numbers)
	var temp_x: float = w / 2.0 - 35.0
	var temp_y: float = -h + 18.0
	node.draw_rect(Rect2(temp_x, temp_y, 28.0, 14.0), Color(0.05, 0.08, 0.15))
	var temp_pulse: float = 0.5 + 0.3 * sin(t * 1.8)
	node.draw_rect(Rect2(temp_x + 2.0, temp_y + 2.0, 24.0, 10.0), Color(0.2, 0.5, 0.9, temp_pulse * 0.4))
	# "Temperature" lines
	node.draw_line(Vector2(temp_x + 4.0, temp_y + 5.0), Vector2(temp_x + 12.0, temp_y + 5.0),
		Color(0.3, 0.65, 1.0, temp_pulse), 1.0)
	node.draw_line(Vector2(temp_x + 4.0, temp_y + 9.0), Vector2(temp_x + 18.0, temp_y + 9.0),
		Color(0.3, 0.65, 1.0, temp_pulse * 0.7), 1.0)

	# Cryo-fuel containers — labeled cylinders
	for i in 3:
		var cyl_x: float = -w / 2.0 + w * 0.65 + float(i) * 22.0
		var cyl_y: float = -h * 0.15
		# Cylinder body
		node.draw_rect(Rect2(cyl_x, cyl_y, 14.0, 22.0), Color(0.2, 0.3, 0.5, 0.5))
		# Cylinder cap
		node.draw_rect(Rect2(cyl_x + 1.0, cyl_y - 3.0, 12.0, 3.0), Color(0.25, 0.38, 0.55, 0.5))
		# Label stripe
		node.draw_rect(Rect2(cyl_x + 2.0, cyl_y + 8.0, 10.0, 4.0), Color(0.3, 0.55, 0.85, 0.35))

	# Frozen tool rack on right wall
	var rack_x: float = w / 2.0 - 12.0
	for i in 4:
		var ry: float = -h * 0.55 + float(i) * h * 0.1
		node.draw_line(Vector2(rack_x, ry), Vector2(rack_x - 18.0, ry), Color(0.35, 0.5, 0.7, 0.35), 2.0)
		# Tool hanging
		node.draw_line(Vector2(rack_x - 12.0, ry), Vector2(rack_x - 12.0, ry + 10.0),
			Color(0.3, 0.35, 0.45, 0.4), 2.0)

	# Bay door entrance
	var bay_w: float = w * 0.45
	node.draw_rect(Rect2(-bay_w / 2.0, -h * 0.55, bay_w, h * 0.55), Color(0.07, 0.1, 0.2))

	# Entrance glow
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-bay_w / 2.0 - 4.0, -4.0, bay_w + 8.0, 6.0), Color(0.2, 0.5, 0.9, glow_pulse))

	# Frost roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.55, 0.72, 0.9, 0.6), 3.0)


# ── 5. UNIQUE — Temple of Frost (cathedral) ─────────────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	# Main cathedral body
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.12, 0.17, 0.4, 0.92))

	# Pointed arch roof shape
	var roof_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-w / 2.0, -h),
		Vector2(0.0, -h - h * 0.15),
		Vector2(w / 2.0, -h),
	])
	node.draw_colored_polygon(roof_pts, Color(0.14, 0.2, 0.42, 0.9))
	node.draw_polyline(PackedVector2Array([
		Vector2(-w / 2.0, -h), Vector2(0.0, -h - h * 0.15), Vector2(w / 2.0, -h)
	]), Color(0.5, 0.7, 0.9, 0.5), 2.0)

	# Ice spires — 5 tall pointed shapes, tallest in center
	var spire_heights: Array = [h * 0.25, h * 0.35, h * 0.48, h * 0.35, h * 0.25]
	var spire_widths: Array = [8.0, 10.0, 14.0, 10.0, 8.0]
	for i in 5:
		var sp_x: float = -w * 0.32 + float(i) * w * 0.16
		var sp_h: float = spire_heights[i]
		var sp_w: float = spire_widths[i]
		var sp_base_y: float = -h - h * 0.1
		# Spire body
		var spire_pts: PackedVector2Array = PackedVector2Array([
			Vector2(sp_x - sp_w / 2.0, sp_base_y),
			Vector2(sp_x + sp_w / 2.0, sp_base_y),
			Vector2(sp_x + sp_w * 0.15, sp_base_y - sp_h),
			Vector2(sp_x - sp_w * 0.15, sp_base_y - sp_h),
		])
		node.draw_colored_polygon(spire_pts, Color(0.16, 0.25, 0.5, 0.85))
		# Spire highlight edge
		node.draw_line(Vector2(sp_x - sp_w * 0.15, sp_base_y - sp_h),
			Vector2(sp_x - sp_w / 2.0, sp_base_y), Color(0.5, 0.72, 0.95, 0.35), 1.5)
		node.draw_line(Vector2(sp_x + sp_w * 0.15, sp_base_y - sp_h),
			Vector2(sp_x + sp_w / 2.0, sp_base_y), Color(0.45, 0.65, 0.88, 0.25), 1.0)
		# Crystal facets on spire
		for facet_idx in 3:
			var fy: float = sp_base_y - sp_h * (float(facet_idx + 1) / 4.0)
			node.draw_line(Vector2(sp_x - sp_w * 0.3, fy), Vector2(sp_x + sp_w * 0.3, fy),
				Color(0.5, 0.72, 0.92, 0.2), 1.0)

	# Bell/chime at top of central spire
	var bell_y: float = -h - h * 0.1 - h * 0.48 - 6.0
	node.draw_circle(Vector2(0.0, bell_y), 5.0, Color(0.6, 0.75, 0.9, 0.5))
	var bell_ring: float = 0.3 + 0.2 * sin(t * 1.5)
	node.draw_arc(Vector2(0.0, bell_y), 8.0, 0.0, TAU, 16, Color(0.7, 0.85, 1.0, bell_ring), 1.0)

	# Buttress supports along sides (4 per side)
	for i in 4:
		var by: float = -h + h * 0.1 + float(i) * h * 0.2
		# Left buttress
		var bl_pts: PackedVector2Array = PackedVector2Array([
			Vector2(-w / 2.0, by),
			Vector2(-w / 2.0, by + h * 0.12),
			Vector2(-w / 2.0 - 14.0, by + h * 0.12),
		])
		node.draw_colored_polygon(bl_pts, Color(0.15, 0.22, 0.45, 0.7))
		node.draw_polyline(PackedVector2Array([
			Vector2(-w / 2.0, by), Vector2(-w / 2.0 - 14.0, by + h * 0.12), Vector2(-w / 2.0, by + h * 0.12)
		]), Color(0.45, 0.62, 0.85, 0.3), 1.0)
		# Right buttress
		var br_pts: PackedVector2Array = PackedVector2Array([
			Vector2(w / 2.0, by),
			Vector2(w / 2.0, by + h * 0.12),
			Vector2(w / 2.0 + 14.0, by + h * 0.12),
		])
		node.draw_colored_polygon(br_pts, Color(0.15, 0.22, 0.45, 0.7))
		node.draw_polyline(PackedVector2Array([
			Vector2(w / 2.0, by), Vector2(w / 2.0 + 14.0, by + h * 0.12), Vector2(w / 2.0, by + h * 0.12)
		]), Color(0.45, 0.62, 0.85, 0.3), 1.0)

	# Stained-glass aurora windows — colored translucent panels
	var win_row_y: float = -h * 0.7
	for i in 5:
		var wx: float = -w / 2.0 + w * (float(i + 1) / 6.0)
		var ww: float = w * 0.1
		var wh: float = h * 0.2
		# Window frame
		node.draw_rect(Rect2(wx - ww / 2.0, win_row_y - wh / 2.0, ww, wh), Color(0.08, 0.12, 0.25))
		# Pointed top
		var wtop_pts: PackedVector2Array = PackedVector2Array([
			Vector2(wx - ww / 2.0, win_row_y - wh / 2.0),
			Vector2(wx, win_row_y - wh / 2.0 - 10.0),
			Vector2(wx + ww / 2.0, win_row_y - wh / 2.0),
		])
		node.draw_colored_polygon(wtop_pts, Color(0.08, 0.12, 0.25))

		# Color fill — animated shifting between green, pink, purple
		var color_shift: float = sin(t * 0.8 + float(i) * 1.2)
		var win_color: Color
		if color_shift > 0.3:
			win_color = Color(0.15, 0.8, 0.45, 0.25 + 0.1 * sin(t * 1.2 + float(i)))
		elif color_shift < -0.3:
			win_color = Color(0.85, 0.25, 0.6, 0.25 + 0.1 * sin(t * 1.2 + float(i)))
		else:
			win_color = Color(0.55, 0.2, 0.82, 0.25 + 0.1 * sin(t * 1.2 + float(i)))
		node.draw_rect(Rect2(wx - ww / 2.0 + 2.0, win_row_y - wh / 2.0 + 2.0, ww - 4.0, wh - 4.0), win_color)
		node.draw_colored_polygon(PackedVector2Array([
			Vector2(wx - ww / 2.0 + 2.0, win_row_y - wh / 2.0),
			Vector2(wx, win_row_y - wh / 2.0 - 8.0),
			Vector2(wx + ww / 2.0 - 2.0, win_row_y - wh / 2.0),
		]), win_color)

		# Interior glow through window
		var int_glow: float = 0.08 + 0.05 * sin(t * 1.5 + float(i) * 0.9)
		node.draw_rect(Rect2(wx - ww / 2.0 + 4.0, win_row_y - wh / 2.0 + 4.0, ww - 8.0, wh - 8.0),
			Color(0.8, 0.85, 1.0, int_glow))

	# Rose window above entrance
	var rose_x: float = 0.0
	var rose_y: float = -h * 0.38
	var rose_r: float = 18.0
	# Outer circle
	node.draw_arc(Vector2(rose_x, rose_y), rose_r, 0.0, TAU, 24, Color(0.5, 0.7, 0.9, 0.5), 2.0)
	# Inner fill
	node.draw_circle(Vector2(rose_x, rose_y), rose_r - 2.0, Color(0.15, 0.25, 0.5, 0.3))
	# Radial pattern — 8 spokes
	for i in 8:
		var angle: float = float(i) * TAU / 8.0
		node.draw_line(
			Vector2(rose_x, rose_y),
			Vector2(rose_x + cos(angle) * (rose_r - 2.0), rose_y + sin(angle) * (rose_r - 2.0)),
			Color(0.5, 0.7, 0.92, 0.4), 1.0
		)
	# Inner ring
	node.draw_arc(Vector2(rose_x, rose_y), rose_r * 0.5, 0.0, TAU, 16, Color(0.55, 0.75, 0.95, 0.35), 1.5)
	# Colored segments between spokes
	for i in 8:
		var angle: float = float(i) * TAU / 8.0 + TAU / 16.0
		var seg_x: float = rose_x + cos(angle) * rose_r * 0.7
		var seg_y: float = rose_y + sin(angle) * rose_r * 0.7
		var seg_color: Color
		if i % 3 == 0:
			seg_color = Color(0.2, 0.8, 0.5, 0.2)
		elif i % 3 == 1:
			seg_color = Color(0.85, 0.3, 0.6, 0.2)
		else:
			seg_color = Color(0.5, 0.2, 0.8, 0.2)
		node.draw_circle(Vector2(seg_x, seg_y), 4.0, seg_color)

	# Grand arched entrance — pointed arch
	var ent_w: float = w * 0.22
	var ent_h: float = h * 0.28
	# Opening
	node.draw_rect(Rect2(-ent_w / 2.0, -ent_h, ent_w, ent_h), Color(0.06, 0.09, 0.18))
	# Pointed arch top
	var arch_peak_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-ent_w / 2.0, -ent_h),
		Vector2(0.0, -ent_h - 16.0),
		Vector2(ent_w / 2.0, -ent_h),
	])
	node.draw_colored_polygon(arch_peak_pts, Color(0.06, 0.09, 0.18))
	# Arch frame
	node.draw_polyline(PackedVector2Array([
		Vector2(-ent_w / 2.0 - 4.0, 0.0),
		Vector2(-ent_w / 2.0 - 4.0, -ent_h),
		Vector2(0.0, -ent_h - 20.0),
		Vector2(ent_w / 2.0 + 4.0, -ent_h),
		Vector2(ent_w / 2.0 + 4.0, 0.0),
	]), Color(0.45, 0.62, 0.85, 0.5), 2.5)

	# Steps leading up to entrance (5 steps)
	for i in 5:
		var step_w: float = ent_w + 10.0 + float(i) * 6.0
		var step_y: float = -2.0 + float(i) * 3.0
		if step_y < 0.0:
			node.draw_rect(Rect2(-step_w / 2.0, step_y, step_w, 3.0), Color(0.18, 0.28, 0.48, 0.6))
		else:
			node.draw_line(Vector2(-step_w / 2.0, 0.0), Vector2(step_w / 2.0, 0.0),
				Color(0.18, 0.28, 0.48, 0.5), 2.0)

	# Frost crystallization patterns on walls
	for i in 15:
		var fx: float = -w / 2.0 + fmod(float(i) * 37.3, w)
		var fy: float = -h + fmod(float(i) * 29.7, h * 0.8)
		# Branching frost
		for branch_idx in 3:
			var b_angle: float = float(branch_idx) * TAU / 3.0 + float(i) * 0.5
			var b_len: float = 6.0 + fmod(float(i) * 3.1, 8.0)
			node.draw_line(
				Vector2(fx, fy),
				Vector2(fx + cos(b_angle) * b_len, fy + sin(b_angle) * b_len),
				Color(0.55, 0.75, 0.92, 0.12), 1.0
			)
			# Sub-branch
			var sub_angle: float = b_angle + 0.5
			node.draw_line(
				Vector2(fx + cos(b_angle) * b_len, fy + sin(b_angle) * b_len),
				Vector2(fx + cos(b_angle) * b_len + cos(sub_angle) * 4.0,
					fy + sin(b_angle) * b_len + sin(sub_angle) * 4.0),
				Color(0.55, 0.75, 0.92, 0.08), 1.0
			)

	# Wall panel lines — ice block seams
	for i in 12:
		var py: float = -h + float(i) * h / 11.0
		node.draw_line(Vector2(-w / 2.0, py), Vector2(w / 2.0, py), Color(0.35, 0.5, 0.72, 0.1), 1.0)
	for i in 8:
		var px: float = -w / 2.0 + float(i) * w / 7.0
		node.draw_line(Vector2(px, -h), Vector2(px, 0.0), Color(0.35, 0.5, 0.72, 0.08), 1.0)

	# Interior glow — warm amber through entrance
	var int_warm: float = 0.08 + 0.04 * sin(t * 1.2)
	node.draw_rect(Rect2(-ent_w / 2.0 + 4.0, -ent_h + 4.0, ent_w - 8.0, ent_h - 8.0),
		Color(0.7, 0.55, 0.3, int_warm))

	# Entrance glow
	var glow_pulse: float = 0.3 + 0.2 * sin(t * 2.0)
	node.draw_rect(Rect2(-ent_w / 2.0 - 6.0, -4.0, ent_w + 12.0, 6.0), Color(0.2, 0.5, 0.9, glow_pulse))

	# Frost edge along roof peaks
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(0.0, -h - h * 0.15), Color(0.6, 0.78, 0.95, 0.5), 2.0)
	node.draw_line(Vector2(0.0, -h - h * 0.15), Vector2(w / 2.0, -h), Color(0.6, 0.78, 0.95, 0.5), 2.0)
