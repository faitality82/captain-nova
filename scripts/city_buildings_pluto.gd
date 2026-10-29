class_name CityBuildingsPluto
extends RefCounted

# Pluto — "Erebus Outpost" desperate frontier
# Scrap-metal, barely standing, desperate, dark, cold, improvised from wreckage.
# Colors: dark scrap (0.25, 0.22, 0.2), rust (0.5, 0.3, 0.15), dim yellow light.


# ── 1. HANGAR — Lean-to made of welded ship hulls ─────────────────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	var left_edge: float = -w / 2.0
	var right_edge: float = w / 2.0

	# --- Main asymmetric structure (leaning right) ---
	# The hull leans ~12 degrees to the right — left wall is taller
	var lean_offset: float = w * 0.12
	var hull_pts: PackedVector2Array = PackedVector2Array([
		Vector2(left_edge, 0.0),
		Vector2(left_edge, -h),
		Vector2(right_edge + lean_offset, -h * 0.72),
		Vector2(right_edge, 0.0),
	])
	node.draw_colored_polygon(hull_pts, Color(0.2, 0.18, 0.16))

	# --- Ship hull curved plates (3 large sections) ---
	# Left hull piece (curved plate shape)
	var plate1_pts: PackedVector2Array = PackedVector2Array([
		Vector2(left_edge, -h * 0.95),
		Vector2(left_edge + w * 0.38, -h * 0.98),
		Vector2(left_edge + w * 0.4, -h * 0.55),
		Vector2(left_edge + w * 0.02, -h * 0.5),
	])
	node.draw_colored_polygon(plate1_pts, Color(0.24, 0.21, 0.18))
	node.draw_polyline(plate1_pts, Color(0.35, 0.3, 0.25, 0.5), 1.5)

	# Center hull piece
	var plate2_pts: PackedVector2Array = PackedVector2Array([
		Vector2(left_edge + w * 0.35, -h * 0.92),
		Vector2(right_edge - w * 0.15 + lean_offset * 0.6, -h * 0.78),
		Vector2(right_edge - w * 0.1, -h * 0.35),
		Vector2(left_edge + w * 0.32, -h * 0.45),
	])
	node.draw_colored_polygon(plate2_pts, Color(0.22, 0.19, 0.17))
	node.draw_polyline(plate2_pts, Color(0.33, 0.28, 0.23, 0.5), 1.5)

	# Right hull piece (shorter due to lean)
	var plate3_pts: PackedVector2Array = PackedVector2Array([
		Vector2(right_edge - w * 0.2 + lean_offset * 0.5, -h * 0.73),
		Vector2(right_edge + lean_offset, -h * 0.72),
		Vector2(right_edge, -h * 0.1),
		Vector2(right_edge - w * 0.25, -h * 0.15),
	])
	node.draw_colored_polygon(plate3_pts, Color(0.26, 0.22, 0.19))
	node.draw_polyline(plate3_pts, Color(0.34, 0.29, 0.24, 0.5), 1.5)

	# --- Rivet lines on hull plates ---
	for i in 12:
		var rv_x: float = left_edge + w * 0.05 + fmod(float(i) * 31.7, w * 0.85)
		var rv_y: float = -h * 0.3 - fmod(float(i) * 23.1, h * 0.6)
		for j in 6:
			var dot_x: float = rv_x + float(j) * 7.0
			if dot_x < right_edge + lean_offset * 0.5:
				node.draw_circle(Vector2(dot_x, rv_y), 1.5, Color(0.35, 0.3, 0.25, 0.5))

	# --- Weld seams (dotted bright lines between plates) ---
	# Seam between plate1 and plate2
	for i in 14:
		var seg_t: float = float(i) / 13.0
		var sx: float = left_edge + w * 0.35 + seg_t * 2.0
		var sy: float = -h * 0.95 + seg_t * h * 0.48
		node.draw_circle(Vector2(sx, sy), 1.2, Color(0.55, 0.45, 0.3, 0.55))
	# Seam between plate2 and plate3
	for i in 10:
		var seg_t: float = float(i) / 9.0
		var sx: float = right_edge - w * 0.18 + lean_offset * 0.5 - seg_t * 3.0
		var sy: float = -h * 0.76 + seg_t * h * 0.48
		node.draw_circle(Vector2(sx, sy), 1.2, Color(0.55, 0.45, 0.3, 0.55))

	# --- Rust streaks on hull pieces ---
	for i in 8:
		var rx: float = left_edge + fmod(float(i) * 43.7, w)
		var ry_start: float = -h * 0.8 + fmod(float(i) * 29.3, h * 0.4)
		var streak_len: float = 25.0 + fmod(float(i) * 11.1, 30.0)
		node.draw_line(
			Vector2(rx, ry_start),
			Vector2(rx + 2.0, ry_start + streak_len),
			Color(0.5, 0.3, 0.15, 0.3), 2.5
		)

	# --- Support struts at desperate angles ---
	# Left external strut (angled brace)
	node.draw_line(Vector2(left_edge - 20.0, 0.0), Vector2(left_edge + w * 0.08, -h * 0.6), Color(0.3, 0.26, 0.22), 4.0)
	node.draw_line(Vector2(left_edge - 22.0, 0.0), Vector2(left_edge + w * 0.08, -h * 0.6), Color(0.25, 0.22, 0.18, 0.5), 2.0)
	# Right external strut (preventing lean collapse)
	node.draw_line(Vector2(right_edge + 30.0, 0.0), Vector2(right_edge + lean_offset * 0.5, -h * 0.5), Color(0.3, 0.26, 0.22), 4.0)
	node.draw_line(Vector2(right_edge + 32.0, 0.0), Vector2(right_edge + lean_offset * 0.5, -h * 0.5), Color(0.25, 0.22, 0.18, 0.5), 2.0)
	# Internal cross brace visible
	node.draw_line(Vector2(left_edge + w * 0.15, 0.0), Vector2(left_edge + w * 0.55, -h * 0.7), Color(0.28, 0.24, 0.2, 0.4), 3.0)

	# --- Gaps in walls with tarp/fabric patches ---
	# Gap 1 (left side)
	var gap1_x: float = left_edge + w * 0.08
	var gap1_y: float = -h * 0.65
	node.draw_rect(Rect2(gap1_x, gap1_y, 28.0, 22.0), Color(0.05, 0.04, 0.04))
	# Tarp patch (different color — faded blue)
	node.draw_rect(Rect2(gap1_x + 2.0, gap1_y + 2.0, 24.0, 18.0), Color(0.15, 0.2, 0.3, 0.7))
	# Tarp wrinkles
	node.draw_line(Vector2(gap1_x + 5.0, gap1_y + 4.0), Vector2(gap1_x + 20.0, gap1_y + 10.0), Color(0.12, 0.16, 0.25, 0.4), 1.0)
	node.draw_line(Vector2(gap1_x + 3.0, gap1_y + 14.0), Vector2(gap1_x + 22.0, gap1_y + 8.0), Color(0.12, 0.16, 0.25, 0.4), 1.0)

	# Gap 2 (right side, higher)
	var gap2_x: float = right_edge - w * 0.35
	var gap2_y: float = -h * 0.48
	node.draw_rect(Rect2(gap2_x, gap2_y, 22.0, 18.0), Color(0.05, 0.04, 0.04))
	# Tarp patch (faded green)
	node.draw_rect(Rect2(gap2_x + 1.0, gap2_y + 1.0, 20.0, 16.0), Color(0.15, 0.25, 0.15, 0.6))

	# --- Makeshift door (bent plate) ---
	var door_x: float = -w * 0.12
	var door_w: float = w * 0.24
	var door_h_val: float = h * 0.4
	# Door opening (dark)
	node.draw_rect(Rect2(door_x, -door_h_val, door_w, door_h_val), Color(0.06, 0.05, 0.05))
	# Bent plate door (slightly ajar, offset)
	var door_pts: PackedVector2Array = PackedVector2Array([
		Vector2(door_x + 3.0, -door_h_val + 2.0),
		Vector2(door_x + door_w - 5.0, -door_h_val - 4.0),
		Vector2(door_x + door_w - 2.0, -6.0),
		Vector2(door_x + 1.0, -2.0),
	])
	node.draw_colored_polygon(door_pts, Color(0.22, 0.19, 0.16))
	node.draw_polyline(door_pts, Color(0.3, 0.26, 0.22, 0.6), 2.0)
	# Dent on door
	node.draw_arc(Vector2(door_x + door_w * 0.4, -door_h_val * 0.5), 8.0, 0.3, PI + 0.3, 10, Color(0.28, 0.24, 0.2, 0.4), 1.5)

	# --- Dim work light inside (warm glow) ---
	var light_flicker: float = 0.5 + 0.2 * sin(t * 3.5)
	if sin(t * 11.0) < -0.7:
		light_flicker = 0.1
	var light_x: float = door_x + door_w * 0.5
	var light_y: float = -door_h_val * 0.7
	node.draw_circle(Vector2(light_x, light_y), 5.0, Color(0.9, 0.75, 0.4, light_flicker))
	node.draw_circle(Vector2(light_x, light_y), 18.0, Color(0.9, 0.75, 0.4, light_flicker * 0.15))
	node.draw_circle(Vector2(light_x, light_y), 35.0, Color(0.9, 0.7, 0.3, light_flicker * 0.06))

	# --- Dripping condensation (animated drops) ---
	for i in 4:
		var drip_x: float = left_edge + w * 0.2 + float(i) * w * 0.2
		var drip_cycle: float = fmod(t * 0.8 + float(i) * 1.7, 3.0)
		var drip_y: float = -h * 0.5 + drip_cycle * 30.0
		if drip_cycle < 2.5:
			node.draw_circle(Vector2(drip_x, drip_y), 1.5, Color(0.4, 0.5, 0.6, 0.5 - drip_cycle * 0.18))
		# Drip source
		node.draw_circle(Vector2(drip_x, -h * 0.5), 2.0, Color(0.35, 0.45, 0.55, 0.3))

	# --- Warning sign: "STRUCTURAL INTEGRITY: LOW" ---
	var sign_x: float = left_edge + w * 0.55
	var sign_y: float = -h * 0.28
	node.draw_rect(Rect2(sign_x, sign_y, 60.0, 16.0), Color(0.5, 0.4, 0.1, 0.4))
	node.draw_rect(Rect2(sign_x, sign_y, 60.0, 16.0), Color(0.6, 0.5, 0.15, 0.5), false, 1.0)
	# Scratched text lines
	for i in 3:
		var tx: float = sign_x + 4.0
		var ty: float = sign_y + 4.0 + float(i) * 4.0
		node.draw_line(Vector2(tx, ty), Vector2(tx + 52.0 - float(i) * 8.0, ty), Color(0.2, 0.15, 0.1, 0.5), 1.5)

	# --- Roof edge (jagged, uneven) ---
	for i in 10:
		var seg_frac: float = float(i) / 9.0
		var rx1: float = left_edge + seg_frac * w
		var ry1: float = -h + fmod(float(i) * 3.7, 6.0) - lean_offset * seg_frac
		var rx2: float = left_edge + (seg_frac + 0.111) * w
		var ry2: float = -h + fmod(float(i + 1) * 3.7, 6.0) - lean_offset * (seg_frac + 0.111)
		node.draw_line(Vector2(rx1, ry1), Vector2(rx2, ry2), Color(0.3, 0.26, 0.22, 0.6), 2.5)

	# --- Ground debris ---
	for i in 6:
		var dx: float = left_edge + fmod(float(i) * 47.3, w + 40.0) - 20.0
		var dsz: float = 3.0 + fmod(float(i) * 7.1, 5.0)
		node.draw_rect(Rect2(dx, -dsz, dsz * 1.5, dsz), Color(0.22, 0.19, 0.15, 0.4))


# ── 2. MARKET — Plank-across-barrels scrap counter ────────────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	var left_edge: float = -w / 2.0
	var right_edge: float = w / 2.0

	# --- Two barrels (left and right supports for counter) ---
	var barrel_y: float = -h * 0.3
	var barrel_r: float = 18.0
	var _barrel_h_val: float = barrel_y  # from ground (0) to barrel_y
	# Left barrel
	var lb_x: float = left_edge + w * 0.25
	node.draw_rect(Rect2(lb_x - barrel_r, barrel_y, barrel_r * 2.0, -barrel_y), Color(0.3, 0.22, 0.15))
	node.draw_arc(Vector2(lb_x, barrel_y), barrel_r, PI, TAU, 14, Color(0.4, 0.3, 0.18, 0.6), 2.0)
	# Barrel bands
	node.draw_line(Vector2(lb_x - barrel_r, barrel_y + 8.0), Vector2(lb_x + barrel_r, barrel_y + 8.0), Color(0.35, 0.28, 0.18, 0.5), 2.0)
	node.draw_line(Vector2(lb_x - barrel_r, -8.0), Vector2(lb_x + barrel_r, -8.0), Color(0.35, 0.28, 0.18, 0.5), 2.0)
	# Barrel rust
	node.draw_circle(Vector2(lb_x + 5.0, barrel_y + 20.0), 6.0, Color(0.45, 0.28, 0.12, 0.3))

	# Right barrel
	var rb_x: float = right_edge - w * 0.25
	node.draw_rect(Rect2(rb_x - barrel_r, barrel_y, barrel_r * 2.0, -barrel_y), Color(0.28, 0.21, 0.14))
	node.draw_arc(Vector2(rb_x, barrel_y), barrel_r, PI, TAU, 14, Color(0.38, 0.28, 0.16, 0.6), 2.0)
	node.draw_line(Vector2(rb_x - barrel_r, barrel_y + 8.0), Vector2(rb_x + barrel_r, barrel_y + 8.0), Color(0.35, 0.28, 0.18, 0.5), 2.0)
	node.draw_line(Vector2(rb_x - barrel_r, -8.0), Vector2(rb_x + barrel_r, -8.0), Color(0.35, 0.28, 0.18, 0.5), 2.0)

	# --- Plank counter across barrels ---
	var plank_y: float = barrel_y - 4.0
	node.draw_rect(Rect2(lb_x - barrel_r - 8.0, plank_y, (rb_x - lb_x) + barrel_r * 2.0 + 16.0, 6.0), Color(0.35, 0.25, 0.14))
	# Plank wood grain
	for i in 5:
		var gy: float = plank_y + 1.0 + float(i) * 1.2
		node.draw_line(
			Vector2(lb_x - barrel_r - 6.0, gy),
			Vector2(rb_x + barrel_r + 6.0, gy),
			Color(0.3, 0.2, 0.1, 0.25), 0.8
		)

	# --- Scale/balance on counter ---
	var scale_x: float = lb_x + (rb_x - lb_x) * 0.6
	var scale_y: float = plank_y
	node.draw_line(Vector2(scale_x, scale_y), Vector2(scale_x, scale_y - 14.0), Color(0.4, 0.35, 0.28), 2.0)
	var sway_angle: float = sin(t * 1.2) * 0.1
	# Balance beam
	var beam_half: float = 12.0
	node.draw_line(
		Vector2(scale_x - beam_half * cos(sway_angle), scale_y - 14.0 - beam_half * sin(sway_angle)),
		Vector2(scale_x + beam_half * cos(sway_angle), scale_y - 14.0 + beam_half * sin(sway_angle)),
		Color(0.45, 0.38, 0.3), 2.0
	)
	# Pans
	node.draw_arc(Vector2(scale_x - beam_half * cos(sway_angle), scale_y - 12.0 - beam_half * sin(sway_angle)), 5.0, 0.0, PI, 8, Color(0.4, 0.35, 0.28), 1.5)
	node.draw_arc(Vector2(scale_x + beam_half * cos(sway_angle), scale_y - 12.0 + beam_half * sin(sway_angle)), 5.0, 0.0, PI, 8, Color(0.4, 0.35, 0.28), 1.5)

	# --- Massive junk pile behind counter ---
	var pile_base_y: float = plank_y
	var pile_cx: float = 0.0
	# Main mound shape
	var pile_pts: PackedVector2Array = PackedVector2Array([
		Vector2(left_edge + 10.0, pile_base_y),
		Vector2(left_edge + 25.0, -h * 0.7),
		Vector2(left_edge + w * 0.3, -h * 0.88),
		Vector2(pile_cx, -h * 0.95),
		Vector2(right_edge - w * 0.3, -h * 0.85),
		Vector2(right_edge - 20.0, -h * 0.65),
		Vector2(right_edge - 10.0, pile_base_y),
	])
	node.draw_colored_polygon(pile_pts, Color(0.2, 0.17, 0.14))

	# Assorted junk shapes in pile — circles (wheels/gears)
	for i in 6:
		var jx: float = left_edge + w * 0.15 + fmod(float(i) * 53.7, w * 0.7)
		var jy: float = -h * 0.5 - fmod(float(i) * 37.3, h * 0.35)
		var jr: float = 6.0 + fmod(float(i) * 5.1, 8.0)
		node.draw_arc(Vector2(jx, jy), jr, 0.0, TAU, 10, Color(0.3, 0.25, 0.2, 0.5), 1.5)
	# Rectangles (panels/parts)
	for i in 8:
		var jx: float = left_edge + w * 0.12 + fmod(float(i) * 41.3, w * 0.75)
		var jy: float = -h * 0.45 - fmod(float(i) * 31.7, h * 0.4)
		var jw: float = 8.0 + fmod(float(i) * 7.3, 12.0)
		var jh: float = 5.0 + fmod(float(i) * 5.7, 8.0)
		var shade: float = 0.22 + fmod(float(i) * 0.04, 0.1)
		node.draw_rect(Rect2(jx, jy, jw, jh), Color(shade, shade - 0.03, shade - 0.05, 0.6))
	# Triangles (pointed scraps)
	for i in 4:
		var jx: float = left_edge + w * 0.2 + fmod(float(i) * 67.1, w * 0.6)
		var jy: float = -h * 0.55 - fmod(float(i) * 43.9, h * 0.3)
		var tri_pts: PackedVector2Array = PackedVector2Array([
			Vector2(jx, jy),
			Vector2(jx + 10.0, jy + 8.0),
			Vector2(jx - 4.0, jy + 10.0),
		])
		node.draw_colored_polygon(tri_pts, Color(0.25, 0.2, 0.16, 0.5))

	# --- Occasional glint in scrap pile (animated sparkle) ---
	for i in 3:
		var glint_cycle: float = fmod(t * 0.5 + float(i) * 2.1, 4.0)
		if glint_cycle < 0.3:
			var gx: float = left_edge + w * 0.2 + fmod(float(i) * 71.3, w * 0.6)
			var gy: float = -h * 0.6 - fmod(float(i) * 47.7, h * 0.25)
			var glint_alpha: float = 1.0 - glint_cycle / 0.3
			node.draw_circle(Vector2(gx, gy), 2.5, Color(1.0, 0.95, 0.8, glint_alpha * 0.8))
			# Sparkle rays
			for j in 4:
				var ray_a: float = float(j) * PI / 2.0 + t * 2.0
				node.draw_line(
					Vector2(gx, gy),
					Vector2(gx + cos(ray_a) * 6.0, gy + sin(ray_a) * 6.0),
					Color(1.0, 0.9, 0.7, glint_alpha * 0.5), 1.0
				)

	# --- Tarp overhead (sagging fabric on sticks) ---
	var tarp_left: float = left_edge + 5.0
	var tarp_right: float = right_edge - 5.0
	var pole_left_y: float = -h * 0.85
	var pole_right_y: float = -h * 0.78
	# Left pole
	node.draw_line(Vector2(tarp_left + 8.0, pile_base_y), Vector2(tarp_left + 8.0, pole_left_y), Color(0.3, 0.25, 0.2), 3.0)
	# Right pole
	node.draw_line(Vector2(tarp_right - 8.0, pile_base_y), Vector2(tarp_right - 8.0, pole_right_y), Color(0.3, 0.25, 0.2), 3.0)
	# Tarp fabric (sagging)
	var tarp_sag: float = 15.0 + sin(t * 0.4) * 3.0
	var tarp_pts: PackedVector2Array = PackedVector2Array([
		Vector2(tarp_left, pole_left_y - 3.0),
		Vector2(tarp_left + (tarp_right - tarp_left) * 0.3, pole_left_y + tarp_sag),
		Vector2(tarp_left + (tarp_right - tarp_left) * 0.5, pole_left_y + tarp_sag + 5.0),
		Vector2(tarp_left + (tarp_right - tarp_left) * 0.7, pole_right_y + tarp_sag - 2.0),
		Vector2(tarp_right, pole_right_y - 3.0),
		Vector2(tarp_right + 5.0, pole_right_y + 2.0),
		Vector2(tarp_left - 5.0, pole_left_y + 2.0),
	])
	node.draw_colored_polygon(tarp_pts, Color(0.25, 0.2, 0.15, 0.6))
	# Tarp edge line
	node.draw_line(Vector2(tarp_left, pole_left_y - 3.0), Vector2(tarp_left + (tarp_right - tarp_left) * 0.5, pole_left_y + tarp_sag + 5.0), Color(0.35, 0.3, 0.22, 0.4), 1.5)
	node.draw_line(Vector2(tarp_left + (tarp_right - tarp_left) * 0.5, pole_left_y + tarp_sag + 5.0), Vector2(tarp_right, pole_right_y - 3.0), Color(0.35, 0.3, 0.22, 0.4), 1.5)

	# --- Single hanging lamp above counter ---
	var lamp_x: float = lb_x + (rb_x - lb_x) * 0.35
	var lamp_wire_top: float = pole_left_y + tarp_sag * 0.5
	var lamp_sway: float = sin(t * 1.1) * 4.0
	var lamp_y: float = plank_y - 35.0
	# Wire
	node.draw_line(Vector2(lamp_x, lamp_wire_top), Vector2(lamp_x + lamp_sway, lamp_y), Color(0.3, 0.28, 0.22, 0.5), 1.0)
	# Bulb
	var bulb_flicker: float = 0.55 + 0.25 * sin(t * 4.0)
	if sin(t * 13.0) < -0.8:
		bulb_flicker = 0.1
	node.draw_circle(Vector2(lamp_x + lamp_sway, lamp_y), 4.0, Color(0.9, 0.8, 0.4, bulb_flicker))
	node.draw_circle(Vector2(lamp_x + lamp_sway, lamp_y), 14.0, Color(0.9, 0.75, 0.35, bulb_flicker * 0.15))
	node.draw_circle(Vector2(lamp_x + lamp_sway, lamp_y), 30.0, Color(0.9, 0.7, 0.3, bulb_flicker * 0.05))

	# --- Hand-painted price signs ---
	for i in 3:
		var ps_x: float = lb_x - 5.0 + float(i) * (rb_x - lb_x) * 0.35
		var ps_y: float = plank_y - 6.0 - fmod(float(i) * 3.7, 4.0)
		var ps_rot: float = sin(float(i) * 2.3) * 0.15
		node.draw_rect(Rect2(ps_x, ps_y, 18.0, 10.0), Color(0.45, 0.38, 0.2, 0.6))
		# Scratch marks (price text)
		node.draw_line(Vector2(ps_x + 3.0, ps_y + 3.0), Vector2(ps_x + 14.0, ps_y + 3.0 + ps_rot * 5.0), Color(0.2, 0.15, 0.1, 0.5), 1.0)
		node.draw_line(Vector2(ps_x + 3.0, ps_y + 7.0), Vector2(ps_x + 11.0, ps_y + 7.0), Color(0.2, 0.15, 0.1, 0.4), 1.0)

	# --- Customer stool ---
	var stool_x: float = lb_x
	node.draw_rect(Rect2(stool_x - 6.0, -16.0, 12.0, 4.0), Color(0.3, 0.25, 0.18))
	node.draw_line(Vector2(stool_x - 4.0, -12.0), Vector2(stool_x - 5.0, 0.0), Color(0.28, 0.23, 0.16), 2.0)
	node.draw_line(Vector2(stool_x + 4.0, -12.0), Vector2(stool_x + 5.0, 0.0), Color(0.28, 0.23, 0.16), 2.0)

	# --- "FAIR PRICES" sign (crooked) ---
	var fair_x: float = pile_cx - 30.0
	var fair_y: float = -h * 0.75
	# Sign board (rotated by being drawn as polygon)
	var fp_pts: PackedVector2Array = PackedVector2Array([
		Vector2(fair_x, fair_y),
		Vector2(fair_x + 58.0, fair_y - 6.0),
		Vector2(fair_x + 60.0, fair_y + 12.0),
		Vector2(fair_x + 2.0, fair_y + 18.0),
	])
	node.draw_colored_polygon(fp_pts, Color(0.4, 0.35, 0.15, 0.6))
	node.draw_polyline(fp_pts, Color(0.5, 0.42, 0.2, 0.5), 1.5)
	# Text scratches
	for i in 2:
		var ty: float = fair_y + 4.0 + float(i) * 6.0
		node.draw_line(Vector2(fair_x + 6.0, ty), Vector2(fair_x + 52.0, ty - 3.0 + float(i) * 2.0), Color(0.2, 0.15, 0.08, 0.5), 1.5)

	# --- Rat-like creature silhouette near pile ---
	var rat_x: float = right_edge - 35.0
	var rat_y: float = -4.0
	var rat_bob: float = sin(t * 3.0) * 1.0
	# Body
	node.draw_rect(Rect2(rat_x, rat_y + rat_bob - 4.0, 10.0, 4.0), Color(0.15, 0.12, 0.1, 0.6))
	# Head
	node.draw_circle(Vector2(rat_x + 12.0, rat_y + rat_bob - 3.0), 3.0, Color(0.15, 0.12, 0.1, 0.6))
	# Tail
	node.draw_line(Vector2(rat_x, rat_y + rat_bob - 2.0), Vector2(rat_x - 8.0, rat_y + rat_bob - 5.0), Color(0.15, 0.12, 0.1, 0.5), 1.0)
	# Eye
	node.draw_circle(Vector2(rat_x + 13.0, rat_y + rat_bob - 4.0), 1.0, Color(0.6, 0.1, 0.1, 0.5))

	# --- Ground stains ---
	node.draw_rect(Rect2(lb_x - 10.0, -3.0, 25.0, 4.0), Color(0.12, 0.1, 0.08, 0.3))
	node.draw_rect(Rect2(rb_x - 15.0, -2.0, 30.0, 3.0), Color(0.12, 0.1, 0.08, 0.25))


# ── 3. BAR — Shipping container with hole cut in it ───────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	var left_edge: float = -w / 2.0
	var right_edge: float = w / 2.0

	# --- Main shipping container body ---
	var container_bottom: float = 0.0
	var container_top: float = -h * 0.75
	var container_h: float = -container_top
	node.draw_rect(Rect2(left_edge, container_top, w, container_h), Color(0.22, 0.18, 0.15))

	# --- Corrugated sides (vertical line pattern) ---
	var ridge_count: int = int(w / 8.0)
	for i in ridge_count:
		var rx: float = left_edge + float(i) * 8.0
		var shade_mod: float = 0.03 * sin(float(i) * 0.8)
		node.draw_line(
			Vector2(rx, container_top),
			Vector2(rx, container_bottom),
			Color(0.25 + shade_mod, 0.21 + shade_mod, 0.17 + shade_mod, 0.4), 1.0
		)

	# --- Dents and damage marks ---
	for i in 5:
		var dx: float = left_edge + w * 0.1 + fmod(float(i) * 59.3, w * 0.8)
		var dy: float = container_top + fmod(float(i) * 37.7, container_h * 0.7)
		var dent_r: float = 8.0 + fmod(float(i) * 4.3, 6.0)
		node.draw_arc(Vector2(dx, dy), dent_r, 0.5, PI + 0.5, 8, Color(0.18, 0.15, 0.12, 0.4), 1.5)

	# --- Rough-cut doorway (jagged irregular opening) ---
	var door_cx: float = -w * 0.08
	var door_w: float = w * 0.28
	var door_h_val: float = container_h * 0.7
	var door_top: float = -door_h_val
	# Jagged opening shape
	var cut_pts: PackedVector2Array = PackedVector2Array([
		Vector2(door_cx - door_w * 0.5 - 3.0, 0.0),
		Vector2(door_cx - door_w * 0.5, -door_h_val * 0.2),
		Vector2(door_cx - door_w * 0.48 - 5.0, -door_h_val * 0.5),
		Vector2(door_cx - door_w * 0.45, -door_h_val * 0.75),
		Vector2(door_cx - door_w * 0.4 + 3.0, -door_h_val * 0.92),
		Vector2(door_cx - door_w * 0.2, -door_h_val),
		Vector2(door_cx + door_w * 0.15, -door_h_val - 4.0),
		Vector2(door_cx + door_w * 0.35, -door_h_val * 0.88),
		Vector2(door_cx + door_w * 0.45 + 4.0, -door_h_val * 0.7),
		Vector2(door_cx + door_w * 0.48, -door_h_val * 0.4),
		Vector2(door_cx + door_w * 0.5 + 2.0, -door_h_val * 0.15),
		Vector2(door_cx + door_w * 0.5, 0.0),
	])
	node.draw_colored_polygon(cut_pts, Color(0.06, 0.05, 0.05))
	# Jagged edge highlight (torch-cut metal glow)
	for i in range(0, cut_pts.size() - 1):
		node.draw_line(cut_pts[i], cut_pts[i + 1], Color(0.4, 0.3, 0.2, 0.5), 2.0)

	# --- "BAR" scratched into metal above door ---
	var bar_sign_y: float = door_top - 12.0
	# B
	node.draw_line(Vector2(door_cx - 18.0, bar_sign_y), Vector2(door_cx - 18.0, bar_sign_y + 10.0), Color(0.5, 0.42, 0.3, 0.6), 2.0)
	node.draw_arc(Vector2(door_cx - 18.0, bar_sign_y + 2.5), 3.0, -PI / 2.0, PI / 2.0, 6, Color(0.5, 0.42, 0.3, 0.6), 2.0)
	node.draw_arc(Vector2(door_cx - 18.0, bar_sign_y + 7.5), 3.0, -PI / 2.0, PI / 2.0, 6, Color(0.5, 0.42, 0.3, 0.6), 2.0)
	# A
	node.draw_line(Vector2(door_cx - 4.0, bar_sign_y + 10.0), Vector2(door_cx, bar_sign_y), Color(0.5, 0.42, 0.3, 0.6), 2.0)
	node.draw_line(Vector2(door_cx, bar_sign_y), Vector2(door_cx + 4.0, bar_sign_y + 10.0), Color(0.5, 0.42, 0.3, 0.6), 2.0)
	node.draw_line(Vector2(door_cx - 2.0, bar_sign_y + 6.0), Vector2(door_cx + 2.0, bar_sign_y + 6.0), Color(0.5, 0.42, 0.3, 0.6), 1.5)
	# R
	node.draw_line(Vector2(door_cx + 12.0, bar_sign_y), Vector2(door_cx + 12.0, bar_sign_y + 10.0), Color(0.5, 0.42, 0.3, 0.6), 2.0)
	node.draw_arc(Vector2(door_cx + 12.0, bar_sign_y + 3.0), 3.5, -PI / 2.0, PI / 2.0, 6, Color(0.5, 0.42, 0.3, 0.6), 2.0)
	node.draw_line(Vector2(door_cx + 14.0, bar_sign_y + 5.5), Vector2(door_cx + 17.0, bar_sign_y + 10.0), Color(0.5, 0.42, 0.3, 0.6), 2.0)

	# --- Single light bulb on wire above door ---
	var bulb_x: float = door_cx + sin(t * 0.9) * 5.0
	var bulb_y: float = door_top + 8.0
	# Wire
	node.draw_line(Vector2(door_cx, container_top + 5.0), Vector2(bulb_x, bulb_y), Color(0.3, 0.25, 0.2, 0.5), 1.0)
	# Bulb flicker
	var bulb_on: float = 0.5 + 0.3 * sin(t * 3.2)
	if sin(t * 9.5) < -0.6:
		bulb_on = 0.08
	node.draw_circle(Vector2(bulb_x, bulb_y), 4.0, Color(0.95, 0.85, 0.5, bulb_on))
	node.draw_circle(Vector2(bulb_x, bulb_y), 16.0, Color(0.95, 0.8, 0.4, bulb_on * 0.12))

	# --- Graffiti marks on container sides ---
	# Left side scribbles
	for i in 4:
		var gx: float = left_edge + 12.0 + fmod(float(i) * 31.0, w * 0.3)
		var gy: float = container_top + 15.0 + fmod(float(i) * 19.0, container_h * 0.5)
		# Squiggle line
		var pts: PackedVector2Array = PackedVector2Array()
		for j in 6:
			pts.append(Vector2(gx + float(j) * 5.0, gy + sin(float(j) * 2.0 + float(i)) * 4.0))
		node.draw_polyline(pts, Color(0.4, 0.15, 0.15, 0.3), 1.5)
	# Right side scribbles
	for i in 3:
		var gx: float = right_edge - w * 0.35 + fmod(float(i) * 27.0, w * 0.25)
		var gy: float = container_top + 20.0 + fmod(float(i) * 23.0, container_h * 0.4)
		node.draw_line(Vector2(gx, gy), Vector2(gx + 15.0, gy + 8.0), Color(0.15, 0.3, 0.15, 0.3), 2.0)
		node.draw_line(Vector2(gx + 3.0, gy + 10.0), Vector2(gx + 18.0, gy + 3.0), Color(0.15, 0.3, 0.15, 0.25), 1.5)

	# --- Bent chimney pipe on top with animated smoke ---
	var chimney_x: float = right_edge - w * 0.2
	node.draw_line(Vector2(chimney_x, container_top), Vector2(chimney_x, container_top - 18.0), Color(0.3, 0.28, 0.24), 4.0)
	node.draw_line(Vector2(chimney_x, container_top - 18.0), Vector2(chimney_x + 8.0, container_top - 25.0), Color(0.3, 0.28, 0.24), 4.0)
	# Cap
	node.draw_rect(Rect2(chimney_x + 4.0, container_top - 28.0, 10.0, 3.0), Color(0.28, 0.25, 0.22))
	# Smoke puffs
	for i in 4:
		var smoke_t: float = fmod(t * 0.6 + float(i) * 1.2, 5.0)
		var smoke_y: float = container_top - 30.0 - smoke_t * 12.0
		var smoke_x: float = chimney_x + 9.0 + sin(smoke_t * 1.5 + float(i)) * 6.0
		var smoke_r: float = 4.0 + smoke_t * 2.5
		var smoke_alpha: float = 0.3 - smoke_t * 0.055
		if smoke_alpha > 0.0:
			node.draw_circle(Vector2(smoke_x, smoke_y), smoke_r, Color(0.4, 0.38, 0.36, smoke_alpha))

	# --- Stools outside (3) ---
	for i in 3:
		var stool_x: float = door_cx - door_w * 0.6 + float(i) * 28.0
		# Seat
		node.draw_rect(Rect2(stool_x - 6.0, -14.0, 12.0, 3.0), Color(0.28, 0.22, 0.16))
		# Legs
		node.draw_line(Vector2(stool_x - 4.0, -11.0), Vector2(stool_x - 5.0, 0.0), Color(0.25, 0.2, 0.15), 2.0)
		node.draw_line(Vector2(stool_x + 4.0, -11.0), Vector2(stool_x + 5.0, 0.0), Color(0.25, 0.2, 0.15), 2.0)

	# --- Crate serving as table ---
	var crate_x: float = door_cx + door_w * 0.7
	node.draw_rect(Rect2(crate_x, -22.0, 20.0, 22.0), Color(0.28, 0.22, 0.14))
	node.draw_rect(Rect2(crate_x, -22.0, 20.0, 22.0), Color(0.35, 0.28, 0.18, 0.4), false, 1.5)
	# Cross slats
	node.draw_line(Vector2(crate_x, -22.0), Vector2(crate_x + 20.0, 0.0), Color(0.32, 0.25, 0.16, 0.3), 1.5)
	node.draw_line(Vector2(crate_x + 20.0, -22.0), Vector2(crate_x, 0.0), Color(0.32, 0.25, 0.16, 0.3), 1.5)

	# --- Puddle on ground near entrance ---
	var puddle_pts: PackedVector2Array = PackedVector2Array([
		Vector2(door_cx - 15.0, -1.0),
		Vector2(door_cx - 8.0, -3.0),
		Vector2(door_cx + 5.0, -2.0),
		Vector2(door_cx + 12.0, -1.0),
		Vector2(door_cx + 8.0, 1.0),
		Vector2(door_cx - 10.0, 1.0),
	])
	node.draw_colored_polygon(puddle_pts, Color(0.1, 0.12, 0.15, 0.4))
	# Puddle highlight
	node.draw_arc(Vector2(door_cx - 2.0, -1.0), 5.0, 0.2, 1.5, 6, Color(0.3, 0.35, 0.4, 0.2), 1.0)

	# --- Container frame edges ---
	node.draw_rect(Rect2(left_edge, container_top, w, container_h), Color(0.28, 0.24, 0.2, 0.5), false, 3.0)
	# Corner reinforcements
	var corner_sz: float = 12.0
	node.draw_line(Vector2(left_edge, container_top), Vector2(left_edge + corner_sz, container_top), Color(0.35, 0.3, 0.25), 3.0)
	node.draw_line(Vector2(left_edge, container_top), Vector2(left_edge, container_top + corner_sz), Color(0.35, 0.3, 0.25), 3.0)
	node.draw_line(Vector2(right_edge, container_top), Vector2(right_edge - corner_sz, container_top), Color(0.35, 0.3, 0.25), 3.0)
	node.draw_line(Vector2(right_edge, container_top), Vector2(right_edge, container_top + corner_sz), Color(0.35, 0.3, 0.25), 3.0)

	# --- Container bottom rail ---
	node.draw_rect(Rect2(left_edge, -4.0, w, 4.0), Color(0.25, 0.22, 0.18))


# ── 4. GARAGE — Tarp over engine block with scattered tools ───────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	var left_edge: float = -w / 2.0
	var right_edge: float = w / 2.0

	# --- Oil stain spreading on ground ---
	var oil_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-30.0, -1.0),
		Vector2(-15.0, -3.0),
		Vector2(10.0, -2.0),
		Vector2(25.0, -1.0),
		Vector2(35.0, 1.0),
		Vector2(15.0, 2.0),
		Vector2(-20.0, 2.0),
		Vector2(-35.0, 1.0),
	])
	node.draw_colored_polygon(oil_pts, Color(0.08, 0.07, 0.06, 0.5))
	# Oil sheen
	var sheen_cycle: float = fmod(t * 0.3, TAU)
	node.draw_arc(Vector2(0.0, 0.0), 15.0, sheen_cycle, sheen_cycle + 1.0, 8, Color(0.15, 0.12, 0.2, 0.2), 1.5)

	# --- Two poles for tarp support ---
	var pole_left_x: float = left_edge + w * 0.15
	var pole_right_x: float = right_edge - w * 0.15
	var pole_left_top: float = -h * 0.85
	var pole_right_top: float = -h * 0.8
	# Left pole
	node.draw_line(Vector2(pole_left_x, 0.0), Vector2(pole_left_x, pole_left_top), Color(0.3, 0.26, 0.22), 4.0)
	# Right pole
	node.draw_line(Vector2(pole_right_x, 0.0), Vector2(pole_right_x, pole_right_top), Color(0.3, 0.26, 0.22), 4.0)
	# Cross support bar
	node.draw_line(Vector2(pole_left_x, pole_left_top), Vector2(pole_right_x, pole_right_top), Color(0.28, 0.24, 0.2), 3.0)

	# --- Tarp stretched over poles (sagging in middle) ---
	var tarp_sag: float = h * 0.18 + sin(t * 0.3) * 4.0
	var tarp_mid_y: float = (pole_left_top + pole_right_top) / 2.0 + tarp_sag
	var tarp_pts: PackedVector2Array = PackedVector2Array([
		Vector2(pole_left_x - 20.0, pole_left_top + 8.0),
		Vector2(pole_left_x, pole_left_top - 3.0),
		Vector2((pole_left_x + pole_right_x) * 0.35, tarp_mid_y - 5.0),
		Vector2((pole_left_x + pole_right_x) * 0.5, tarp_mid_y),
		Vector2((pole_left_x + pole_right_x) * 0.65, tarp_mid_y - 3.0),
		Vector2(pole_right_x, pole_right_top - 3.0),
		Vector2(pole_right_x + 20.0, pole_right_top + 8.0),
		Vector2(pole_right_x + 15.0, pole_right_top + 25.0),
		Vector2(pole_left_x - 15.0, pole_left_top + 25.0),
	])
	node.draw_colored_polygon(tarp_pts, Color(0.22, 0.28, 0.2, 0.65))
	# Tarp edge line
	for i in range(0, 7):
		node.draw_line(tarp_pts[i], tarp_pts[i + 1], Color(0.3, 0.35, 0.25, 0.4), 1.5)
	# Tarp patches (different colored rectangles)
	node.draw_rect(Rect2(pole_left_x + 15.0, tarp_mid_y - 10.0, 20.0, 14.0), Color(0.3, 0.2, 0.15, 0.4))
	node.draw_rect(Rect2(pole_right_x - 40.0, tarp_mid_y - 8.0, 16.0, 12.0), Color(0.15, 0.2, 0.3, 0.35))

	# --- Large engine block underneath tarp ---
	var eng_x: float = -w * 0.18
	var eng_w: float = w * 0.4
	var eng_h: float = h * 0.35
	var eng_y: float = -eng_h
	# Main block
	node.draw_rect(Rect2(eng_x, eng_y, eng_w, eng_h), Color(0.18, 0.17, 0.16))
	node.draw_rect(Rect2(eng_x, eng_y, eng_w, eng_h), Color(0.25, 0.22, 0.2, 0.5), false, 2.0)
	# Cylinder heads (bumps on top)
	for i in 4:
		var cyl_x: float = eng_x + 10.0 + float(i) * eng_w / 4.5
		node.draw_rect(Rect2(cyl_x, eng_y - 10.0, eng_w / 6.0, 10.0), Color(0.2, 0.19, 0.17))
		node.draw_rect(Rect2(cyl_x, eng_y - 10.0, eng_w / 6.0, 10.0), Color(0.28, 0.25, 0.22, 0.4), false, 1.0)
	# Exhaust manifold (pipes on side)
	for i in 3:
		var pipe_y: float = eng_y + 8.0 + float(i) * eng_h / 4.0
		node.draw_line(Vector2(eng_x + eng_w, pipe_y), Vector2(eng_x + eng_w + 18.0, pipe_y + 3.0), Color(0.25, 0.22, 0.18), 3.0)
	# Belt/chain visible
	node.draw_arc(Vector2(eng_x + eng_w * 0.3, eng_y + eng_h * 0.5), 12.0, 0.0, TAU, 12, Color(0.15, 0.14, 0.13, 0.6), 2.0)
	node.draw_arc(Vector2(eng_x + eng_w * 0.7, eng_y + eng_h * 0.4), 8.0, 0.0, TAU, 10, Color(0.15, 0.14, 0.13, 0.6), 2.0)
	# Oil pan at bottom
	node.draw_rect(Rect2(eng_x + 5.0, -4.0, eng_w - 10.0, 5.0), Color(0.14, 0.13, 0.12))

	# --- Jack stands (triangular supports) ---
	var jack1_x: float = eng_x - 10.0
	var jack_pts1: PackedVector2Array = PackedVector2Array([
		Vector2(jack1_x, 0.0),
		Vector2(jack1_x + 12.0, 0.0),
		Vector2(jack1_x + 6.0, -18.0),
	])
	node.draw_colored_polygon(jack_pts1, Color(0.5, 0.15, 0.1))
	node.draw_polyline(jack_pts1, Color(0.6, 0.2, 0.12, 0.5), 1.5)
	var jack2_x: float = eng_x + eng_w + 5.0
	var jack_pts2: PackedVector2Array = PackedVector2Array([
		Vector2(jack2_x, 0.0),
		Vector2(jack2_x + 12.0, 0.0),
		Vector2(jack2_x + 6.0, -18.0),
	])
	node.draw_colored_polygon(jack_pts2, Color(0.5, 0.15, 0.1))
	node.draw_polyline(jack_pts2, Color(0.6, 0.2, 0.12, 0.5), 1.5)

	# --- Tools scattered on ground ---
	# Wrench (left side)
	var wr_x: float = left_edge + 20.0
	node.draw_line(Vector2(wr_x, -2.0), Vector2(wr_x + 22.0, -5.0), Color(0.4, 0.38, 0.35), 2.5)
	node.draw_arc(Vector2(wr_x + 22.0, -5.0), 4.0, -0.5, PI + 0.5, 6, Color(0.4, 0.38, 0.35), 2.0)
	# Hammer (right side)
	var hm_x: float = right_edge - 45.0
	node.draw_line(Vector2(hm_x, -3.0), Vector2(hm_x + 18.0, -6.0), Color(0.35, 0.25, 0.15), 2.0)
	node.draw_rect(Rect2(hm_x + 16.0, -10.0, 10.0, 7.0), Color(0.4, 0.38, 0.35))
	# Socket (near engine)
	node.draw_circle(Vector2(eng_x + eng_w + 25.0, -3.0), 4.0, Color(0.38, 0.36, 0.33))
	node.draw_circle(Vector2(eng_x + eng_w + 25.0, -3.0), 2.0, Color(0.25, 0.23, 0.2))
	# Screwdriver
	var sd_x: float = eng_x - 25.0
	node.draw_line(Vector2(sd_x, -1.0), Vector2(sd_x + 14.0, -4.0), Color(0.35, 0.3, 0.25), 2.0)
	node.draw_line(Vector2(sd_x + 14.0, -4.0), Vector2(sd_x + 20.0, -5.0), Color(0.6, 0.2, 0.15), 3.0)

	# --- Bucket of loose parts ---
	var bucket_x: float = right_edge - 30.0
	var bucket_pts: PackedVector2Array = PackedVector2Array([
		Vector2(bucket_x - 10.0, 0.0),
		Vector2(bucket_x - 8.0, -20.0),
		Vector2(bucket_x + 8.0, -20.0),
		Vector2(bucket_x + 10.0, 0.0),
	])
	node.draw_colored_polygon(bucket_pts, Color(0.28, 0.25, 0.22))
	node.draw_polyline(bucket_pts, Color(0.35, 0.3, 0.25, 0.5), 1.5)
	# Handle
	node.draw_arc(Vector2(bucket_x, -22.0), 8.0, PI, TAU, 8, Color(0.35, 0.3, 0.25, 0.5), 1.5)
	# Parts sticking out
	for i in 5:
		var px: float = bucket_x - 5.0 + fmod(float(i) * 3.7, 10.0)
		var py: float = -20.0 - fmod(float(i) * 4.3, 8.0)
		node.draw_rect(Rect2(px, py, 3.0, 5.0 + fmod(float(i) * 2.1, 4.0)), Color(0.35, 0.3, 0.25, 0.6))

	# --- Toolbox (open lid) ---
	var tb_x: float = left_edge + 40.0
	node.draw_rect(Rect2(tb_x, -12.0, 24.0, 12.0), Color(0.5, 0.15, 0.1))
	node.draw_rect(Rect2(tb_x, -12.0, 24.0, 12.0), Color(0.6, 0.2, 0.12, 0.4), false, 1.5)
	# Open lid (angled)
	var lid_pts: PackedVector2Array = PackedVector2Array([
		Vector2(tb_x, -12.0),
		Vector2(tb_x + 24.0, -12.0),
		Vector2(tb_x + 22.0, -22.0),
		Vector2(tb_x - 2.0, -22.0),
	])
	node.draw_colored_polygon(lid_pts, Color(0.5, 0.15, 0.1, 0.8))
	node.draw_polyline(lid_pts, Color(0.6, 0.2, 0.12, 0.4), 1.0)
	# Latch
	node.draw_rect(Rect2(tb_x + 10.0, -13.0, 4.0, 3.0), Color(0.4, 0.38, 0.35))

	# --- Extension cord (wavy line) ---
	var cord_pts: PackedVector2Array = PackedVector2Array()
	for i in 12:
		var ct: float = float(i) / 11.0
		var cx: float = left_edge - 10.0 + ct * (w + 20.0)
		var cy: float = -2.0 + sin(ct * 8.0 + 1.5) * 3.0
		cord_pts.append(Vector2(cx, cy))
	node.draw_polyline(cord_pts, Color(0.6, 0.4, 0.1, 0.4), 2.0)

	# --- Flickering work light on bent stick ---
	var wl_x: float = eng_x + eng_w * 0.5
	var wl_stick_top: float = pole_left_top + tarp_sag * 0.3
	# Bent stick
	node.draw_line(Vector2(wl_x + 15.0, 0.0), Vector2(wl_x + 10.0, wl_stick_top + 20.0), Color(0.3, 0.25, 0.18), 2.5)
	node.draw_line(Vector2(wl_x + 10.0, wl_stick_top + 20.0), Vector2(wl_x + 5.0, wl_stick_top), Color(0.3, 0.25, 0.18), 2.5)
	# Light
	var wl_flicker: float = 0.6 + 0.3 * sin(t * 5.0)
	if sin(t * 14.0) < -0.5:
		wl_flicker = 0.15
	node.draw_circle(Vector2(wl_x + 5.0, wl_stick_top), 5.0, Color(0.95, 0.85, 0.5, wl_flicker))
	node.draw_circle(Vector2(wl_x + 5.0, wl_stick_top), 20.0, Color(0.95, 0.8, 0.4, wl_flicker * 0.12))
	node.draw_circle(Vector2(wl_x + 5.0, wl_stick_top), 45.0, Color(0.9, 0.75, 0.35, wl_flicker * 0.04))

	# --- "WILL FIX ANYTHING" sign ---
	var sign_x: float = pole_right_x + 5.0
	var sign_y: float = -h * 0.45
	# Board
	node.draw_rect(Rect2(sign_x, sign_y, 55.0, 22.0), Color(0.35, 0.28, 0.15))
	node.draw_rect(Rect2(sign_x, sign_y, 55.0, 22.0), Color(0.42, 0.34, 0.18, 0.4), false, 1.5)
	# Nail holes
	node.draw_circle(Vector2(sign_x + 4.0, sign_y + 4.0), 1.5, Color(0.25, 0.2, 0.12))
	node.draw_circle(Vector2(sign_x + 51.0, sign_y + 18.0), 1.5, Color(0.25, 0.2, 0.12))
	# Text scratches (3 lines for "WILL FIX ANYTHING")
	for i in 3:
		var ty: float = sign_y + 5.0 + float(i) * 6.0
		var line_len: float = 45.0 - float(i) * 8.0
		node.draw_line(Vector2(sign_x + 5.0, ty), Vector2(sign_x + 5.0 + line_len, ty + 1.0), Color(0.18, 0.14, 0.08, 0.6), 1.5)
	# Post holding sign
	node.draw_line(Vector2(sign_x + 27.0, sign_y + 22.0), Vector2(sign_x + 27.0, 0.0), Color(0.3, 0.25, 0.18), 3.0)


# ── 5. UNIQUE — The Underworld (descending staircase into darkness) ───────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	var left_edge: float = -w / 2.0
	var right_edge: float = w / 2.0

	# --- Ground level (minimal above-ground) ---
	# Rocky ground surface
	var ground_pts: PackedVector2Array = PackedVector2Array([
		Vector2(left_edge, 0.0),
		Vector2(left_edge + 10.0, -5.0),
		Vector2(left_edge + 30.0, -3.0),
		Vector2(left_edge + w * 0.3, -7.0),
		Vector2(0.0, -4.0),
		Vector2(right_edge - w * 0.3, -8.0),
		Vector2(right_edge - 30.0, -3.0),
		Vector2(right_edge - 10.0, -6.0),
		Vector2(right_edge, 0.0),
	])
	node.draw_colored_polygon(ground_pts, Color(0.15, 0.13, 0.11))

	# --- Low entrance frame/arch ---
	var arch_w: float = w * 0.4
	var arch_h: float = h * 0.25
	var arch_left: float = -arch_w / 2.0
	var arch_right: float = arch_w / 2.0
	var arch_top: float = -arch_h - 5.0

	# Left pillar
	node.draw_rect(Rect2(arch_left - 12.0, arch_top - 10.0, 14.0, arch_h + 15.0), Color(0.2, 0.18, 0.16))
	node.draw_rect(Rect2(arch_left - 12.0, arch_top - 10.0, 14.0, arch_h + 15.0), Color(0.28, 0.24, 0.2, 0.4), false, 2.0)
	# Right pillar
	node.draw_rect(Rect2(arch_right - 2.0, arch_top - 10.0, 14.0, arch_h + 15.0), Color(0.2, 0.18, 0.16))
	node.draw_rect(Rect2(arch_right - 2.0, arch_top - 10.0, 14.0, arch_h + 15.0), Color(0.28, 0.24, 0.2, 0.4), false, 2.0)
	# Lintel (top beam)
	node.draw_rect(Rect2(arch_left - 15.0, arch_top - 18.0, arch_w + 30.0, 12.0), Color(0.22, 0.19, 0.17))
	node.draw_rect(Rect2(arch_left - 15.0, arch_top - 18.0, arch_w + 30.0, 12.0), Color(0.3, 0.26, 0.22, 0.4), false, 2.0)

	# --- Carved symbols/runes on entrance frame ---
	# Left pillar runes
	for i in 4:
		var ry: float = arch_top - 5.0 + float(i) * 14.0
		var rx: float = arch_left - 8.0
		# Simple rune shapes (X, circle, triangle, line)
		if i == 0:
			node.draw_line(Vector2(rx, ry), Vector2(rx + 6.0, ry + 8.0), Color(0.45, 0.15, 0.1, 0.5), 1.5)
			node.draw_line(Vector2(rx + 6.0, ry), Vector2(rx, ry + 8.0), Color(0.45, 0.15, 0.1, 0.5), 1.5)
		elif i == 1:
			node.draw_arc(Vector2(rx + 3.0, ry + 4.0), 4.0, 0.0, TAU, 8, Color(0.45, 0.15, 0.1, 0.5), 1.5)
		elif i == 2:
			var tri: PackedVector2Array = PackedVector2Array([Vector2(rx + 3.0, ry), Vector2(rx + 6.0, ry + 8.0), Vector2(rx, ry + 8.0)])
			node.draw_polyline(tri, Color(0.45, 0.15, 0.1, 0.5), 1.5)
		else:
			node.draw_line(Vector2(rx + 1.0, ry), Vector2(rx + 5.0, ry + 8.0), Color(0.45, 0.15, 0.1, 0.5), 1.5)
			node.draw_line(Vector2(rx + 3.0, ry + 2.0), Vector2(rx + 7.0, ry + 4.0), Color(0.45, 0.15, 0.1, 0.4), 1.5)
	# Right pillar runes
	for i in 4:
		var ry: float = arch_top - 5.0 + float(i) * 14.0
		var rx: float = arch_right + 2.0
		if i == 0:
			node.draw_arc(Vector2(rx + 3.0, ry + 4.0), 4.0, 0.0, TAU, 8, Color(0.45, 0.15, 0.1, 0.5), 1.5)
		elif i == 1:
			node.draw_line(Vector2(rx, ry), Vector2(rx + 6.0, ry + 8.0), Color(0.45, 0.15, 0.1, 0.5), 1.5)
			node.draw_line(Vector2(rx + 6.0, ry), Vector2(rx, ry + 8.0), Color(0.45, 0.15, 0.1, 0.5), 1.5)
		elif i == 2:
			node.draw_line(Vector2(rx + 1.0, ry), Vector2(rx + 5.0, ry + 8.0), Color(0.45, 0.15, 0.1, 0.5), 1.5)
			node.draw_line(Vector2(rx + 3.0, ry + 2.0), Vector2(rx + 7.0, ry + 4.0), Color(0.45, 0.15, 0.1, 0.4), 1.5)
		else:
			var tri: PackedVector2Array = PackedVector2Array([Vector2(rx + 3.0, ry), Vector2(rx + 6.0, ry + 8.0), Vector2(rx, ry + 8.0)])
			node.draw_polyline(tri, Color(0.45, 0.15, 0.1, 0.5), 1.5)

	# --- Skull motif above entrance ---
	var skull_x: float = 0.0
	var skull_y: float = arch_top - 28.0
	# Skull head (circle)
	node.draw_circle(Vector2(skull_x, skull_y), 14.0, Color(0.4, 0.36, 0.32, 0.7))
	node.draw_arc(Vector2(skull_x, skull_y), 14.0, 0.0, TAU, 16, Color(0.5, 0.44, 0.38, 0.5), 2.0)
	# Eye sockets
	node.draw_circle(Vector2(skull_x - 5.0, skull_y - 2.0), 4.0, Color(0.08, 0.06, 0.05))
	node.draw_circle(Vector2(skull_x + 5.0, skull_y - 2.0), 4.0, Color(0.08, 0.06, 0.05))
	# Eye glow (animated)
	var eye_pulse: float = 0.3 + 0.25 * sin(t * 2.0)
	node.draw_circle(Vector2(skull_x - 5.0, skull_y - 2.0), 2.5, Color(0.6, 0.08, 0.05, eye_pulse))
	node.draw_circle(Vector2(skull_x + 5.0, skull_y - 2.0), 2.5, Color(0.6, 0.08, 0.05, eye_pulse))
	# Nose hole
	node.draw_circle(Vector2(skull_x, skull_y + 3.0), 2.0, Color(0.08, 0.06, 0.05, 0.7))
	# Jaw
	var jaw_pts: PackedVector2Array = PackedVector2Array([
		Vector2(skull_x - 10.0, skull_y + 8.0),
		Vector2(skull_x - 8.0, skull_y + 15.0),
		Vector2(skull_x + 8.0, skull_y + 15.0),
		Vector2(skull_x + 10.0, skull_y + 8.0),
	])
	node.draw_colored_polygon(jaw_pts, Color(0.38, 0.34, 0.3, 0.6))
	node.draw_polyline(jaw_pts, Color(0.48, 0.42, 0.36, 0.4), 1.5)
	# Teeth
	for i in 5:
		var tooth_x: float = skull_x - 7.0 + float(i) * 3.5
		node.draw_line(Vector2(tooth_x, skull_y + 8.0), Vector2(tooth_x, skull_y + 11.0), Color(0.45, 0.4, 0.35, 0.6), 1.5)
		node.draw_line(Vector2(tooth_x, skull_y + 12.0), Vector2(tooth_x, skull_y + 15.0), Color(0.45, 0.4, 0.35, 0.5), 1.5)

	# --- Chains hanging near entrance ---
	for i in 2:
		var ch_side: float = -1.0 + float(i) * 2.0
		var ch_x: float = ch_side * (arch_w / 2.0 + 20.0)
		var ch_top_y: float = arch_top - 12.0
		var ch_sway: float = sin(t * 0.7 + float(i) * 2.0) * 3.0
		# Chain links (vertical)
		for j in 8:
			var link_y: float = ch_top_y + float(j) * 8.0
			var link_x: float = ch_x + ch_sway * (1.0 - float(j) / 12.0)
			# Alternating orientation of links
			if j % 2 == 0:
				node.draw_rect(Rect2(link_x - 2.0, link_y, 4.0, 7.0), Color(0.0, 0.0, 0.0, 0.0))
				node.draw_arc(Vector2(link_x, link_y + 3.5), 3.0, 0.0, TAU, 8, Color(0.35, 0.3, 0.25, 0.5), 2.0)
			else:
				node.draw_arc(Vector2(link_x, link_y + 3.5), 2.0, 0.0, TAU, 8, Color(0.35, 0.3, 0.25, 0.5), 2.0)

	# --- Staircase descending into darkness ---
	var stair_count: int = 12
	var stair_w: float = arch_w - 8.0
	var stair_start_y: float = -4.0
	var stair_step_h: float = h * 0.055
	var stair_step_depth: float = 4.0  # visual narrowing per step

	# Background darkness behind stairs (deep pit)
	var pit_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-stair_w / 2.0, stair_start_y),
		Vector2(stair_w / 2.0, stair_start_y),
		Vector2(stair_w / 2.0 - stair_step_depth * float(stair_count), stair_start_y + stair_step_h * float(stair_count)),
		Vector2(-stair_w / 2.0 + stair_step_depth * float(stair_count), stair_start_y + stair_step_h * float(stair_count)),
	])
	node.draw_colored_polygon(pit_pts, Color(0.03, 0.02, 0.02))

	# Steps (getting progressively darker)
	for i in stair_count:
		var fi: float = float(i)
		var frac: float = fi / float(stair_count)
		var step_y: float = stair_start_y + fi * stair_step_h
		var step_left: float = -stair_w / 2.0 + fi * stair_step_depth
		var step_right: float = stair_w / 2.0 - fi * stair_step_depth
		var step_shade: float = 0.2 - frac * 0.17
		# Step surface
		node.draw_rect(
			Rect2(step_left, step_y, step_right - step_left, stair_step_h * 0.7),
			Color(step_shade, step_shade - 0.02, step_shade - 0.03)
		)
		# Step edge highlight
		node.draw_line(
			Vector2(step_left, step_y),
			Vector2(step_right, step_y),
			Color(step_shade + 0.08, step_shade + 0.05, step_shade + 0.03, 0.6), 1.5
		)

	# --- Guard rail along stairs (bent, damaged) ---
	# Left rail
	var rail_pts_l: PackedVector2Array = PackedVector2Array()
	for i in 7:
		var fi: float = float(i)
		var frac: float = fi / 6.0
		var ry: float = stair_start_y + frac * stair_step_h * float(stair_count) * 0.8
		var rx: float = -stair_w / 2.0 + frac * stair_step_depth * float(stair_count) * 0.8 - 3.0
		# Add bends/damage
		var bend: float = sin(fi * 1.8) * 4.0
		rail_pts_l.append(Vector2(rx + bend, ry - 12.0 + fi * 1.5))
	node.draw_polyline(rail_pts_l, Color(0.3, 0.26, 0.22, 0.6), 2.0)
	# Rail posts
	for i in 4:
		var fi: float = float(i) * 2.0
		var frac: float = fi / 6.0
		var post_x: float = -stair_w / 2.0 + frac * stair_step_depth * float(stair_count) * 0.8 - 3.0
		var post_y: float = stair_start_y + frac * stair_step_h * float(stair_count) * 0.8
		node.draw_line(Vector2(post_x, post_y), Vector2(post_x, post_y - 14.0 + float(i) * 1.5), Color(0.28, 0.24, 0.2, 0.5), 2.0)

	# Right rail (more damaged)
	var rail_pts_r: PackedVector2Array = PackedVector2Array()
	for i in 5:
		var fi: float = float(i)
		var frac: float = fi / 4.0
		var ry: float = stair_start_y + frac * stair_step_h * float(stair_count) * 0.6
		var rx: float = stair_w / 2.0 - frac * stair_step_depth * float(stair_count) * 0.6 + 3.0
		var bend: float = sin(fi * 2.3) * 5.0
		rail_pts_r.append(Vector2(rx + bend, ry - 12.0 + fi * 2.0))
	node.draw_polyline(rail_pts_r, Color(0.3, 0.26, 0.22, 0.5), 2.0)
	# Broken rail section (gap)
	node.draw_line(
		Vector2(stair_w / 2.0 - 5.0, stair_start_y - 8.0),
		Vector2(stair_w / 2.0 - 2.0, stair_start_y + 8.0),
		Color(0.3, 0.26, 0.22, 0.4), 2.0
	)

	# --- Eerie glow from below (deep red/purple animated pulse) ---
	var glow_pulse: float = 0.2 + 0.15 * sin(t * 1.2)
	var glow_pulse2: float = 0.15 + 0.1 * sin(t * 1.8 + 1.0)
	var deep_y: float = stair_start_y + stair_step_h * float(stair_count)
	var deep_left: float = -stair_w / 2.0 + stair_step_depth * float(stair_count)
	var deep_right: float = stair_w / 2.0 - stair_step_depth * float(stair_count)
	# Deep red glow
	var glow_pts: PackedVector2Array = PackedVector2Array([
		Vector2(deep_left - 10.0, deep_y),
		Vector2(deep_right + 10.0, deep_y),
		Vector2(deep_right + 5.0, deep_y - stair_step_h * 4.0),
		Vector2(deep_left - 5.0, deep_y - stair_step_h * 4.0),
	])
	node.draw_colored_polygon(glow_pts, Color(0.5, 0.05, 0.08, glow_pulse))
	# Purple secondary glow
	var glow_pts2: PackedVector2Array = PackedVector2Array([
		Vector2(deep_left, deep_y),
		Vector2(deep_right, deep_y),
		Vector2(deep_right + 15.0, deep_y - stair_step_h * 7.0),
		Vector2(deep_left - 15.0, deep_y - stair_step_h * 7.0),
	])
	node.draw_colored_polygon(glow_pts2, Color(0.3, 0.05, 0.25, glow_pulse2))
	# Glow cast on stair edges
	for i in range(stair_count - 4, stair_count):
		var fi: float = float(i)
		var frac: float = fi / float(stair_count)
		var step_y: float = stair_start_y + fi * stair_step_h
		var step_left: float = -stair_w / 2.0 + fi * stair_step_depth
		var step_right: float = stair_w / 2.0 - fi * stair_step_depth
		var glow_i: float = glow_pulse * (frac - 0.5) * 2.0
		node.draw_line(
			Vector2(step_left, step_y),
			Vector2(step_right, step_y),
			Color(0.5, 0.08, 0.12, glow_i), 1.0
		)

	# --- Mysterious fog seeping up from below ---
	for i in 6:
		var fog_cycle: float = fmod(t * 0.25 + float(i) * 1.5, 5.0)
		var fog_y: float = deep_y - fog_cycle * 15.0
		var fog_x: float = deep_left + fmod(float(i) * 17.3, deep_right - deep_left)
		var fog_r: float = 8.0 + fog_cycle * 4.0
		var fog_alpha: float = 0.2 - fog_cycle * 0.035
		if fog_alpha > 0.0:
			node.draw_circle(Vector2(fog_x, fog_y), fog_r, Color(0.3, 0.15, 0.25, fog_alpha))
	# Fog near entrance level
	for i in 4:
		var fog_x: float = -stair_w / 2.0 + float(i) * stair_w / 3.0
		var fog_drift: float = sin(t * 0.4 + float(i) * 2.1) * 8.0
		var fog_y: float = stair_start_y - 2.0
		node.draw_circle(Vector2(fog_x + fog_drift, fog_y), 10.0 + sin(t * 0.6 + float(i)) * 3.0, Color(0.25, 0.15, 0.22, 0.12))

	# --- Warning signs scratched into walls beside stairs ---
	# Left wall warning
	var warn_x: float = arch_left - 45.0
	var warn_y: float = -arch_h * 0.5
	node.draw_rect(Rect2(warn_x, warn_y, 30.0, 14.0), Color(0.18, 0.16, 0.14))
	# Scratched lines
	node.draw_line(Vector2(warn_x + 3.0, warn_y + 4.0), Vector2(warn_x + 26.0, warn_y + 5.0), Color(0.5, 0.15, 0.1, 0.5), 1.5)
	node.draw_line(Vector2(warn_x + 5.0, warn_y + 9.0), Vector2(warn_x + 22.0, warn_y + 10.0), Color(0.5, 0.15, 0.1, 0.4), 1.0)
	# Right wall warning (skull crude drawing)
	var warn2_x: float = arch_right + 18.0
	var warn2_y: float = -arch_h * 0.4
	node.draw_circle(Vector2(warn2_x + 6.0, warn2_y), 5.0, Color(0.5, 0.15, 0.1, 0.35))
	node.draw_circle(Vector2(warn2_x + 4.0, warn2_y - 1.0), 1.5, Color(0.5, 0.15, 0.1, 0.35))
	node.draw_circle(Vector2(warn2_x + 8.0, warn2_y - 1.0), 1.5, Color(0.5, 0.15, 0.1, 0.35))

	# --- Rubble/rocks near entrance ---
	for i in 8:
		var rock_x: float = left_edge + fmod(float(i) * 41.7, w)
		var rock_r: float = 3.0 + fmod(float(i) * 5.3, 6.0)
		var rock_y: float = -rock_r * 0.5 - fmod(float(i) * 3.1, 3.0)
		node.draw_circle(Vector2(rock_x, rock_y), rock_r, Color(0.18, 0.15, 0.13, 0.5))
		node.draw_arc(Vector2(rock_x, rock_y), rock_r, 0.3, PI, 6, Color(0.22, 0.19, 0.16, 0.3), 1.0)

	# --- Ambient darkness effect (vignette at edges) ---
	# Dark overlay strips at far left and right
	node.draw_rect(Rect2(left_edge, -h, w * 0.08, h), Color(0.0, 0.0, 0.0, 0.15))
	node.draw_rect(Rect2(right_edge - w * 0.08, -h, w * 0.08, h), Color(0.0, 0.0, 0.0, 0.15))

	# --- Lintel cracks ---
	node.draw_line(Vector2(arch_left - 5.0, arch_top - 14.0), Vector2(arch_left + 10.0, arch_top - 9.0), Color(0.12, 0.1, 0.08, 0.4), 1.5)
	node.draw_line(Vector2(arch_right - 8.0, arch_top - 16.0), Vector2(arch_right + 3.0, arch_top - 10.0), Color(0.12, 0.1, 0.08, 0.4), 1.5)

	# --- Dust particles floating near entrance ---
	for i in 5:
		var dust_cycle: float = fmod(t * 0.4 + float(i) * 1.8, 4.0)
		var dust_x: float = -arch_w / 2.0 + fmod(float(i) * 23.7, arch_w)
		var dust_y: float = -arch_h * 0.3 + sin(dust_cycle * 1.5) * 8.0
		var dust_alpha: float = 0.3 * sin(dust_cycle * PI / 4.0)
		if dust_alpha > 0.0:
			node.draw_circle(Vector2(dust_x, dust_y), 1.0, Color(0.5, 0.45, 0.4, dust_alpha))
