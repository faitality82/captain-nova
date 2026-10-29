class_name CityBuildingsUranus
extends RefCounted

# Uranus — "Miranda's Edge" rough frontier
# Jury-rigged, scrap metal, ice, improvised, dark and dangerous.
# Colors: scrap gray (0.35, 0.33, 0.3), ice teal (0.3, 0.55, 0.6), rust brown.


# ── 1. HANGAR — Jury-rigged cave entrance with scrap overhang ────────────────

static func draw_hangar(node: Node2D, w: float, h: float, t: float) -> void:
	# --- Natural rock cave body (irregular polygon) ---
	var rock_color := Color(0.28, 0.26, 0.24)
	var cave_pts := PackedVector2Array([
		Vector2(-w / 2.0, 0.0),
		Vector2(-w / 2.0 + 8.0, -h * 0.3),
		Vector2(-w / 2.0 + 15.0, -h * 0.55),
		Vector2(-w / 2.0 + 30.0, -h * 0.78),
		Vector2(-w / 2.0 + 60.0, -h * 0.92),
		Vector2(-w * 0.15, -h * 0.98),
		Vector2(0.0, -h),
		Vector2(w * 0.15, -h * 0.97),
		Vector2(w / 2.0 - 55.0, -h * 0.9),
		Vector2(w / 2.0 - 25.0, -h * 0.75),
		Vector2(w / 2.0 - 12.0, -h * 0.5),
		Vector2(w / 2.0 - 5.0, -h * 0.25),
		Vector2(w / 2.0, 0.0),
	])
	node.draw_colored_polygon(cave_pts, rock_color)

	# Rock texture — darker patches
	for i in 20:
		var rx: float = -w / 2.0 + fmod(float(i) * 37.3, w)
		var ry: float = -h + fmod(float(i) * 23.7, h * 0.85)
		var rsz: float = 4.0 + fmod(float(i) * 11.1, 8.0)
		node.draw_circle(Vector2(rx, ry), rsz, Color(0.22, 0.20, 0.18, 0.25))

	# Rock texture — lighter mineral streaks
	for i in 12:
		var sx: float = -w / 2.0 + fmod(float(i) * 43.7, w)
		var sy: float = -h + fmod(float(i) * 31.3, h * 0.7)
		var sx2: float = sx + 12.0 + fmod(float(i) * 7.3, 18.0)
		var sy2: float = sy + 3.0 + fmod(float(i) * 5.1, 6.0)
		node.draw_line(Vector2(sx, sy), Vector2(sx2, sy2), Color(0.38, 0.36, 0.33, 0.2), 1.5)

	# --- Cave opening (dark interior) ---
	var opening_w: float = w * 0.55
	var opening_h: float = h * 0.6
	var open_pts := PackedVector2Array([
		Vector2(-opening_w / 2.0, 0.0),
		Vector2(-opening_w / 2.0 + 10.0, -opening_h * 0.5),
		Vector2(-opening_w / 2.0 + 25.0, -opening_h * 0.8),
		Vector2(-opening_w * 0.1, -opening_h * 0.95),
		Vector2(opening_w * 0.12, -opening_h),
		Vector2(opening_w / 2.0 - 20.0, -opening_h * 0.82),
		Vector2(opening_w / 2.0 - 8.0, -opening_h * 0.45),
		Vector2(opening_w / 2.0, 0.0),
	])
	node.draw_colored_polygon(open_pts, Color(0.06, 0.07, 0.08))

	# Dim warm glow from deep inside (gradient circles)
	var glow_pulse: float = 0.25 + 0.1 * sin(t * 1.5)
	node.draw_circle(Vector2(0.0, -opening_h * 0.35), 40.0, Color(0.6, 0.35, 0.1, glow_pulse * 0.15))
	node.draw_circle(Vector2(0.0, -opening_h * 0.35), 25.0, Color(0.7, 0.4, 0.12, glow_pulse * 0.25))
	node.draw_circle(Vector2(0.0, -opening_h * 0.35), 12.0, Color(0.8, 0.5, 0.15, glow_pulse * 0.4))

	# --- Scrap metal overhang (mismatched plates) ---
	var overhang_y: float = -opening_h * 0.85
	# Plate 1 — large tilted
	var plate1 := PackedVector2Array([
		Vector2(-opening_w / 2.0 - 20.0, overhang_y - 5.0),
		Vector2(-opening_w / 2.0 + 30.0, overhang_y - 18.0),
		Vector2(-opening_w / 2.0 + 35.0, overhang_y - 12.0),
		Vector2(-opening_w / 2.0 - 15.0, overhang_y + 2.0),
	])
	node.draw_colored_polygon(plate1, Color(0.38, 0.35, 0.3))
	node.draw_polyline(plate1, Color(0.45, 0.42, 0.36, 0.6), 1.5)
	# Plate 2 — center
	var plate2 := PackedVector2Array([
		Vector2(-25.0, overhang_y - 20.0),
		Vector2(30.0, overhang_y - 22.0),
		Vector2(32.0, overhang_y - 10.0),
		Vector2(-22.0, overhang_y - 8.0),
	])
	node.draw_colored_polygon(plate2, Color(0.33, 0.30, 0.27))
	node.draw_polyline(plate2, Color(0.42, 0.38, 0.34, 0.6), 1.5)
	# Plate 3 — right side
	var plate3 := PackedVector2Array([
		Vector2(opening_w / 2.0 - 30.0, overhang_y - 16.0),
		Vector2(opening_w / 2.0 + 18.0, overhang_y - 8.0),
		Vector2(opening_w / 2.0 + 15.0, overhang_y + 3.0),
		Vector2(opening_w / 2.0 - 28.0, overhang_y - 4.0),
	])
	node.draw_colored_polygon(plate3, Color(0.4, 0.34, 0.28))
	node.draw_polyline(plate3, Color(0.48, 0.42, 0.36, 0.6), 1.5)

	# Weld marks on plates
	for i in 6:
		var wx: float = -opening_w / 2.0 + 10.0 + float(i) * 22.0
		var wy: float = overhang_y - 14.0 + fmod(float(i) * 3.7, 8.0)
		node.draw_circle(Vector2(wx, wy), 2.0, Color(0.55, 0.45, 0.3, 0.4))

	# --- Bent support beams (improvised, not straight) ---
	# Left beam
	node.draw_line(Vector2(-opening_w / 2.0 - 5.0, 0.0), Vector2(-opening_w / 2.0 + 8.0, -opening_h * 0.4), Color(0.4, 0.37, 0.32), 3.0)
	node.draw_line(Vector2(-opening_w / 2.0 + 8.0, -opening_h * 0.4), Vector2(-opening_w / 2.0 + 3.0, -opening_h * 0.75), Color(0.4, 0.37, 0.32), 3.0)
	# Right beam
	node.draw_line(Vector2(opening_w / 2.0 + 5.0, 0.0), Vector2(opening_w / 2.0 - 10.0, -opening_h * 0.35), Color(0.38, 0.35, 0.3), 3.0)
	node.draw_line(Vector2(opening_w / 2.0 - 10.0, -opening_h * 0.35), Vector2(opening_w / 2.0 - 4.0, -opening_h * 0.72), Color(0.38, 0.35, 0.3), 3.0)
	# Center brace (bent)
	node.draw_line(Vector2(-15.0, -opening_h * 0.7), Vector2(2.0, -opening_h * 0.78), Color(0.36, 0.33, 0.28), 2.5)
	node.draw_line(Vector2(2.0, -opening_h * 0.78), Vector2(20.0, -opening_h * 0.68), Color(0.36, 0.33, 0.28), 2.5)

	# --- Icicles hanging from cave ceiling ---
	for i in 8:
		var ix: float = -opening_w / 2.0 + 15.0 + float(i) * (opening_w - 30.0) / 7.0
		var icicle_len: float = 10.0 + fmod(float(i) * 7.3, 18.0)
		var iy_base: float = -opening_h * 0.85 + fmod(float(i) * 3.1, 8.0)
		var icicle_pts := PackedVector2Array([
			Vector2(ix - 3.0, iy_base),
			Vector2(ix + 3.0, iy_base),
			Vector2(ix + 0.5, iy_base + icicle_len),
		])
		node.draw_colored_polygon(icicle_pts, Color(0.45, 0.65, 0.72, 0.5))
		node.draw_polyline(icicle_pts, Color(0.55, 0.75, 0.8, 0.3), 1.0)

	# --- Junk pile near entrance (left side) ---
	# Barrel
	node.draw_rect(Rect2(-opening_w / 2.0 + 15.0, -18.0, 14.0, 18.0), Color(0.35, 0.28, 0.22))
	node.draw_line(Vector2(-opening_w / 2.0 + 15.0, -9.0), Vector2(-opening_w / 2.0 + 29.0, -9.0), Color(0.42, 0.35, 0.28, 0.5), 1.5)
	# Scrap pieces
	node.draw_rect(Rect2(-opening_w / 2.0 + 32.0, -10.0, 12.0, 10.0), Color(0.32, 0.30, 0.27))
	node.draw_rect(Rect2(-opening_w / 2.0 + 28.0, -22.0, 8.0, 12.0), Color(0.38, 0.33, 0.26))
	# Pipe piece
	node.draw_line(Vector2(-opening_w / 2.0 + 35.0, -15.0), Vector2(-opening_w / 2.0 + 55.0, -8.0), Color(0.4, 0.37, 0.32), 3.0)
	# Wheel/tire shape
	node.draw_arc(Vector2(-opening_w / 2.0 + 50.0, -8.0), 7.0, 0.0, TAU, 16, Color(0.25, 0.23, 0.2, 0.6), 2.0)

	# --- Dripping water (animated drops) ---
	for i in 4:
		var drip_x: float = -opening_w / 4.0 + float(i) * opening_w / 3.0
		var drip_base: float = -opening_h * 0.8 + fmod(float(i) * 5.1, 10.0)
		var drip_prog: float = fmod(t * 0.7 + float(i) * 1.7, 2.5)
		var drip_y: float = drip_base + drip_prog * 25.0
		if drip_prog < 2.2:
			node.draw_circle(Vector2(drip_x, drip_y), 1.5, Color(0.35, 0.6, 0.7, 0.5))
		# Splash at bottom
		if drip_prog > 2.0 and drip_prog < 2.4:
			var splash_y: float = drip_base + 55.0
			node.draw_circle(Vector2(drip_x, splash_y), 3.0, Color(0.35, 0.6, 0.7, 0.2))

	# --- Makeshift light (bare bulb on wire) ---
	var bulb_x: float = 10.0
	var bulb_base_y: float = -opening_h * 0.75
	var wire_sway: float = sin(t * 0.8) * 4.0
	# Wire from ceiling
	node.draw_line(Vector2(bulb_x, -opening_h * 0.9), Vector2(bulb_x + wire_sway, bulb_base_y), Color(0.3, 0.28, 0.25, 0.5), 1.0)
	# Bulb
	var bulb_flicker: float = 0.6 + 0.3 * sin(t * 4.5)
	node.draw_circle(Vector2(bulb_x + wire_sway, bulb_base_y + 3.0), 4.0, Color(0.95, 0.85, 0.5, bulb_flicker))
	node.draw_circle(Vector2(bulb_x + wire_sway, bulb_base_y + 3.0), 12.0, Color(0.95, 0.8, 0.4, bulb_flicker * 0.12))

	# --- Tire tracks/drag marks on ground ---
	for i in 5:
		var track_x: float = -opening_w / 3.0 + float(i) * 18.0
		node.draw_line(Vector2(track_x, -1.0), Vector2(track_x + 20.0, -1.0), Color(0.2, 0.18, 0.15, 0.3), 2.0)
		node.draw_line(Vector2(track_x + 2.0, -4.0), Vector2(track_x + 22.0, -4.0), Color(0.2, 0.18, 0.15, 0.25), 1.5)

	# Jagged rock outline edge
	for i in 10:
		var frac: float = float(i) / 9.0
		var ex: float = -w / 2.0 + frac * w
		var next_frac: float = float(i + 1) / 10.0
		var ex2: float = -w / 2.0 + next_frac * w
		var jag1: float = -h * 0.85 - fmod(float(i) * 17.3, h * 0.15)
		var jag2: float = -h * 0.85 - fmod(float(i + 1) * 17.3, h * 0.15)
		node.draw_line(Vector2(ex, jag1), Vector2(ex2, jag2), Color(0.35, 0.33, 0.3, 0.5), 2.0)


# ── 2. MARKET — Black market den ─────────────────────────────────────────────

static func draw_market(node: Node2D, w: float, h: float, t: float) -> void:
	# --- Low wide oppressive structure ---
	var base_color := Color(0.18, 0.17, 0.16)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), base_color)

	# Darker overlay for oppressive feel
	node.draw_rect(Rect2(-w / 2.0, -h, w, h * 0.3), Color(0.1, 0.09, 0.08, 0.5))

	# Grimy wall texture
	for i in 18:
		var gx: float = -w / 2.0 + fmod(float(i) * 41.3, w)
		var gy: float = -h + fmod(float(i) * 27.7, h)
		var gsz: float = 3.0 + fmod(float(i) * 9.3, 6.0)
		node.draw_circle(Vector2(gx, gy), gsz, Color(0.14, 0.13, 0.12, 0.3))

	# Rust stains dripping down walls
	for i in 6:
		var rust_x: float = -w / 2.0 + 20.0 + float(i) * (w - 40.0) / 5.0
		var rust_y: float = -h + fmod(float(i) * 19.7, h * 0.3)
		var rust_len: float = 20.0 + fmod(float(i) * 13.1, 30.0)
		node.draw_line(Vector2(rust_x, rust_y), Vector2(rust_x + 2.0, rust_y + rust_len), Color(0.4, 0.25, 0.15, 0.25), 2.0)

	# --- Caged goods sections (3 bays) ---
	var bay_count: int = 3
	var bay_w: float = (w - 60.0) / float(bay_count)
	var bay_h: float = h * 0.55
	var bay_start_y: float = -bay_h - 10.0
	for bay_idx in bay_count:
		var bx: float = -w / 2.0 + 20.0 + float(bay_idx) * (bay_w + 10.0)
		# Bay background
		node.draw_rect(Rect2(bx, bay_start_y, bay_w, bay_h), Color(0.1, 0.1, 0.1, 0.7))
		# Vertical bars
		var bar_count: int = int(bay_w / 12.0)
		for bar_idx in bar_count:
			var bar_x: float = bx + float(bar_idx) * 12.0 + 6.0
			node.draw_line(Vector2(bar_x, bay_start_y), Vector2(bar_x, bay_start_y + bay_h), Color(0.4, 0.38, 0.35, 0.6), 1.5)
		# Horizontal bars
		node.draw_line(Vector2(bx, bay_start_y), Vector2(bx + bay_w, bay_start_y), Color(0.4, 0.38, 0.35, 0.7), 2.0)
		node.draw_line(Vector2(bx, bay_start_y + bay_h), Vector2(bx + bay_w, bay_start_y + bay_h), Color(0.4, 0.38, 0.35, 0.7), 2.0)
		node.draw_line(Vector2(bx, bay_start_y + bay_h * 0.5), Vector2(bx + bay_w, bay_start_y + bay_h * 0.5), Color(0.4, 0.38, 0.35, 0.5), 1.0)
		# Contraband crate shapes visible through bars
		for crate_idx in 3:
			var cx: float = bx + 8.0 + float(crate_idx) * (bay_w - 20.0) / 3.0
			var cy: float = bay_start_y + bay_h - 18.0 - float(crate_idx % 2) * 12.0
			var cw: float = 14.0 + float(crate_idx % 2) * 6.0
			var ch: float = 12.0 + float(crate_idx % 3) * 4.0
			node.draw_rect(Rect2(cx, cy, cw, ch), Color(0.3, 0.24, 0.17, 0.5))
			# X marking on crate
			node.draw_line(Vector2(cx, cy), Vector2(cx + cw, cy + ch), Color(0.5, 0.2, 0.15, 0.3), 1.0)
			node.draw_line(Vector2(cx + cw, cy), Vector2(cx, cy + ch), Color(0.5, 0.2, 0.15, 0.3), 1.0)

	# --- Single flickering light source (center ceiling) ---
	var light_flicker: float = 0.5 + 0.4 * sin(t * 6.0) * sin(t * 3.7)
	var light_on: float = 1.0 if sin(t * 8.5) > -0.8 else 0.15
	var combined_light: float = light_flicker * light_on
	node.draw_circle(Vector2(0.0, -h + 10.0), 5.0, Color(0.9, 0.75, 0.4, combined_light))
	node.draw_circle(Vector2(0.0, -h + 10.0), 20.0, Color(0.9, 0.7, 0.35, combined_light * 0.1))
	# Light cone
	var cone_pts := PackedVector2Array([
		Vector2(-3.0, -h + 12.0),
		Vector2(-40.0, -h * 0.3),
		Vector2(40.0, -h * 0.3),
		Vector2(3.0, -h + 12.0),
	])
	node.draw_colored_polygon(cone_pts, Color(0.9, 0.8, 0.5, combined_light * 0.04))
	# Wire to light
	node.draw_line(Vector2(0.0, -h), Vector2(0.0, -h + 8.0), Color(0.3, 0.28, 0.25, 0.5), 1.5)

	# --- Heavy curtain entrance (wavy fabric) ---
	var curtain_w: float = w * 0.22
	var curtain_h: float = h * 0.45
	var curtain_x: float = -curtain_w / 2.0
	var curtain_y: float = -curtain_h
	# Curtain rod
	node.draw_line(Vector2(curtain_x - 5.0, curtain_y), Vector2(curtain_x + curtain_w + 5.0, curtain_y), Color(0.35, 0.3, 0.25), 3.0)
	# Fabric folds (wavy vertical strips)
	var fold_count: int = 8
	for fold_idx in fold_count:
		var fx: float = curtain_x + float(fold_idx) * curtain_w / float(fold_count)
		var wave: float = sin(float(fold_idx) * 1.3 + t * 0.5) * 3.0
		var shade: float = 0.22 + 0.06 * sin(float(fold_idx) * 2.1)
		node.draw_line(Vector2(fx + wave, curtain_y), Vector2(fx + wave * 0.5, 0.0), Color(shade, shade * 0.8, shade * 0.6, 0.8), 4.0)

	# --- Barred windows (left and right walls) ---
	for side_val in 2:
		var win_x: float = -w / 2.0 + 8.0 if side_val == 0 else w / 2.0 - 30.0
		var win_y: float = -h * 0.7
		var win_w: float = 22.0
		var win_h: float = 18.0
		node.draw_rect(Rect2(win_x, win_y, win_w, win_h), Color(0.08, 0.08, 0.1, 0.7))
		# Bars
		for b_idx in 4:
			var bx2: float = win_x + float(b_idx + 1) * win_w / 5.0
			node.draw_line(Vector2(bx2, win_y), Vector2(bx2, win_y + win_h), Color(0.4, 0.37, 0.33, 0.7), 1.5)
		# Cross bar
		node.draw_line(Vector2(win_x, win_y + win_h * 0.5), Vector2(win_x + win_w, win_y + win_h * 0.5), Color(0.4, 0.37, 0.33, 0.7), 1.5)

	# --- Lookout perch on roof ---
	var perch_x: float = w / 2.0 - 50.0
	var perch_y: float = -h - 8.0
	# Platform
	node.draw_rect(Rect2(perch_x, perch_y, 35.0, 5.0), Color(0.3, 0.28, 0.25))
	# Railing
	node.draw_line(Vector2(perch_x, perch_y), Vector2(perch_x, perch_y - 16.0), Color(0.35, 0.32, 0.28), 2.0)
	node.draw_line(Vector2(perch_x + 35.0, perch_y), Vector2(perch_x + 35.0, perch_y - 16.0), Color(0.35, 0.32, 0.28), 2.0)
	node.draw_line(Vector2(perch_x, perch_y - 16.0), Vector2(perch_x + 35.0, perch_y - 16.0), Color(0.35, 0.32, 0.28), 1.5)
	# Figure silhouette
	node.draw_circle(Vector2(perch_x + 18.0, perch_y - 22.0), 4.0, Color(0.1, 0.1, 0.1, 0.6))
	node.draw_line(Vector2(perch_x + 18.0, perch_y - 18.0), Vector2(perch_x + 18.0, perch_y - 8.0), Color(0.1, 0.1, 0.1, 0.6), 3.0)

	# --- "NO QUESTIONS" scratched sign ---
	var sign_x: float = -w / 2.0 + 35.0
	var sign_y: float = -h * 0.88
	node.draw_rect(Rect2(sign_x, sign_y, 70.0, 16.0), Color(0.25, 0.23, 0.2, 0.5))
	# Scratched text (rough lines)
	for letter_idx in 7:
		var lx: float = sign_x + 5.0 + float(letter_idx) * 9.0
		var ly: float = sign_y + 3.0
		node.draw_line(Vector2(lx, ly), Vector2(lx + 4.0, ly + 10.0), Color(0.6, 0.55, 0.5, 0.5), 1.5)
		node.draw_line(Vector2(lx + 4.0, ly), Vector2(lx, ly + 10.0), Color(0.6, 0.55, 0.5, 0.4), 1.0)

	# --- Hidden camera (tiny detail, upper right corner) ---
	node.draw_rect(Rect2(w / 2.0 - 12.0, -h + 5.0, 6.0, 5.0), Color(0.15, 0.15, 0.15))
	var cam_blink: float = 0.0
	if fmod(t, 2.5) < 0.2:
		cam_blink = 0.9
	node.draw_circle(Vector2(w / 2.0 - 9.0, -h + 6.0), 1.5, Color(0.9, 0.1, 0.1, cam_blink))

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.3, 0.28, 0.25, 0.7), 3.0)

	# Ground grime
	for i in 8:
		var grime_x: float = -w / 2.0 + fmod(float(i) * 47.3, w)
		node.draw_circle(Vector2(grime_x, -2.0), 4.0 + float(i % 3) * 2.0, Color(0.12, 0.11, 0.1, 0.3))


# ── 3. BAR — Fight pit bar with central cage ─────────────────────────────────

static func draw_bar(node: Node2D, w: float, h: float, t: float) -> void:
	# --- Main structure ---
	var base_color := Color(0.16, 0.14, 0.13)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), base_color)

	# Grimy walls
	for i in 15:
		var gx: float = -w / 2.0 + fmod(float(i) * 37.7, w)
		var gy: float = -h + fmod(float(i) * 23.1, h)
		node.draw_circle(Vector2(gx, gy), 4.0 + float(i % 3) * 2.0, Color(0.12, 0.11, 0.1, 0.25))

	# --- Central cage (hexagonal) ---
	var cage_cx: float = 0.0
	var cage_cy: float = -h * 0.4
	var cage_r: float = w * 0.2
	var cage_pts := PackedVector2Array()
	for i in 7:
		var angle: float = float(i) * TAU / 6.0 - PI / 6.0
		cage_pts.append(Vector2(cage_cx + cos(angle) * cage_r, cage_cy + sin(angle) * cage_r * 0.7))
	# Cage floor
	node.draw_colored_polygon(cage_pts, Color(0.12, 0.1, 0.09))
	# Cage outline
	node.draw_polyline(cage_pts, Color(0.5, 0.47, 0.42, 0.8), 2.5)
	# Wire cross-hatching inside cage
	for i in 8:
		var hatch_x: float = cage_cx - cage_r + float(i) * cage_r * 2.0 / 7.0
		node.draw_line(
			Vector2(hatch_x, cage_cy - cage_r * 0.6),
			Vector2(hatch_x + 8.0, cage_cy + cage_r * 0.6),
			Color(0.45, 0.42, 0.38, 0.2), 1.0
		)
	for i in 5:
		var hatch_y: float = cage_cy - cage_r * 0.5 + float(i) * cage_r * 0.25
		node.draw_line(
			Vector2(cage_cx - cage_r * 0.8, hatch_y),
			Vector2(cage_cx + cage_r * 0.8, hatch_y + 5.0),
			Color(0.45, 0.42, 0.38, 0.2), 1.0
		)
	# Scorch/blood marks on cage floor
	for i in 5:
		var mark_x: float = cage_cx - cage_r * 0.5 + fmod(float(i) * 23.7, cage_r)
		var mark_y: float = cage_cy - cage_r * 0.3 + fmod(float(i) * 17.3, cage_r * 0.5)
		node.draw_circle(Vector2(mark_x, mark_y), 3.0 + float(i % 3) * 2.0, Color(0.25, 0.08, 0.05, 0.3))

	# --- Tiered seating (left side) ---
	for tier_idx in 3:
		var tier_x: float = -w / 2.0 + 10.0
		var tier_y: float = -h * 0.2 - float(tier_idx) * 20.0
		var tier_w: float = w * 0.2 - float(tier_idx) * 10.0
		node.draw_rect(Rect2(tier_x, tier_y, tier_w, 8.0), Color(0.25, 0.22, 0.2))
		node.draw_line(Vector2(tier_x, tier_y), Vector2(tier_x + tier_w, tier_y), Color(0.35, 0.32, 0.28, 0.5), 1.5)

	# --- Tiered seating (right side) ---
	for tier_idx in 3:
		var tier_w2: float = w * 0.2 - float(tier_idx) * 10.0
		var tier_x2: float = w / 2.0 - 10.0 - tier_w2
		var tier_y2: float = -h * 0.2 - float(tier_idx) * 20.0
		node.draw_rect(Rect2(tier_x2, tier_y2, tier_w2, 8.0), Color(0.25, 0.22, 0.2))
		node.draw_line(Vector2(tier_x2, tier_y2), Vector2(tier_x2 + tier_w2, tier_y2), Color(0.35, 0.32, 0.28, 0.5), 1.5)

	# --- Harsh overhead spotlights ---
	for i in 3:
		var spot_x: float = -w * 0.25 + float(i) * w * 0.25
		var spot_y_top: float = -h + 8.0
		# Light housing
		node.draw_rect(Rect2(spot_x - 6.0, spot_y_top - 4.0, 12.0, 8.0), Color(0.3, 0.28, 0.25))
		# Flicker
		var spot_flicker: float = 0.6 + 0.35 * sin(t * 5.0 + float(i) * 2.3)
		var spot_blink: float = 1.0 if sin(t * 7.0 + float(i) * 3.1) > -0.9 else 0.2
		var spot_bright: float = spot_flicker * spot_blink
		# Bulb
		node.draw_circle(Vector2(spot_x, spot_y_top + 6.0), 4.0, Color(1.0, 0.95, 0.85, spot_bright))
		# Light cone down
		var cone_pts := PackedVector2Array([
			Vector2(spot_x - 4.0, spot_y_top + 8.0),
			Vector2(spot_x - 30.0, cage_cy + cage_r * 0.7),
			Vector2(spot_x + 30.0, cage_cy + cage_r * 0.7),
			Vector2(spot_x + 4.0, spot_y_top + 8.0),
		])
		node.draw_colored_polygon(cone_pts, Color(1.0, 0.95, 0.8, spot_bright * 0.04))

	# --- Beer keg stacks along walls ---
	for side_val in 2:
		var keg_base_x: float = -w / 2.0 + 12.0 if side_val == 0 else w / 2.0 - 32.0
		for row_idx in 2:
			for col_idx in 2:
				var kx: float = keg_base_x + float(col_idx) * 14.0
				var ky: float = -12.0 - float(row_idx) * 16.0
				# Keg body (cylinder-ish rectangle)
				node.draw_rect(Rect2(kx, ky, 12.0, 14.0), Color(0.35, 0.28, 0.22))
				# Keg band
				node.draw_line(Vector2(kx, ky + 4.0), Vector2(kx + 12.0, ky + 4.0), Color(0.45, 0.4, 0.33, 0.5), 1.0)
				node.draw_line(Vector2(kx, ky + 10.0), Vector2(kx + 12.0, ky + 10.0), Color(0.45, 0.4, 0.33, 0.5), 1.0)

	# --- Rowdy atmosphere (flickering colored lights along ceiling) ---
	for i in 6:
		var rl_x: float = -w / 2.0 + 25.0 + float(i) * (w - 50.0) / 5.0
		var rl_hue: float = fmod(float(i) * 0.37, 1.0)
		var rl_bright: float = 0.4 + 0.5 * sin(t * 3.5 + float(i) * 1.9)
		var rl_color := Color.from_hsv(rl_hue, 0.6, 0.8, rl_bright * 0.5)
		node.draw_circle(Vector2(rl_x, -h + 3.0), 3.0, rl_color)
		node.draw_circle(Vector2(rl_x, -h + 3.0), 8.0, Color(rl_color.r, rl_color.g, rl_color.b, rl_bright * 0.08))

	# --- Betting counter (right side, lower) ---
	var bet_x: float = w / 2.0 - 65.0
	var bet_y: float = -h * 0.18
	node.draw_rect(Rect2(bet_x, bet_y, 50.0, 12.0), Color(0.3, 0.25, 0.2))
	node.draw_line(Vector2(bet_x, bet_y), Vector2(bet_x + 50.0, bet_y), Color(0.4, 0.35, 0.28, 0.6), 2.0)
	# Cash on counter
	for i in 3:
		var cash_x: float = bet_x + 8.0 + float(i) * 14.0
		node.draw_rect(Rect2(cash_x, bet_y - 3.0, 8.0, 3.0), Color(0.3, 0.5, 0.25, 0.4))

	# --- "ENTER AT OWN RISK" scratched above entrance ---
	var ent_x: float = -35.0
	var ent_y: float = -h * 0.52
	node.draw_rect(Rect2(ent_x, ent_y, 70.0, 12.0), Color(0.2, 0.18, 0.16, 0.4))
	for letter_idx in 9:
		var lx: float = ent_x + 3.0 + float(letter_idx) * 7.0
		node.draw_line(Vector2(lx, ent_y + 2.0), Vector2(lx + 3.0, ent_y + 10.0), Color(0.55, 0.45, 0.35, 0.5), 1.0)

	# --- Entrance ---
	node.draw_rect(Rect2(-18.0, -h * 0.48, 36.0, h * 0.48), Color(0.08, 0.07, 0.06))

	# --- Broken furniture pieces ---
	# Broken chair
	node.draw_line(Vector2(-w * 0.32, -5.0), Vector2(-w * 0.32 + 8.0, -14.0), Color(0.3, 0.25, 0.2, 0.5), 2.0)
	node.draw_line(Vector2(-w * 0.32 + 8.0, -14.0), Vector2(-w * 0.32 + 16.0, -5.0), Color(0.3, 0.25, 0.2, 0.5), 2.0)
	# Broken table leg
	node.draw_line(Vector2(w * 0.3, -3.0), Vector2(w * 0.3 + 5.0, -20.0), Color(0.3, 0.25, 0.2, 0.4), 2.5)

	# --- Announcer booth (elevated small platform, upper left) ---
	var booth_x: float = -w / 2.0 + 15.0
	var booth_y: float = -h * 0.72
	node.draw_rect(Rect2(booth_x, booth_y, 30.0, 18.0), Color(0.22, 0.2, 0.18))
	node.draw_line(Vector2(booth_x, booth_y), Vector2(booth_x + 30.0, booth_y), Color(0.35, 0.32, 0.28, 0.6), 2.0)
	# Microphone
	node.draw_line(Vector2(booth_x + 15.0, booth_y - 2.0), Vector2(booth_x + 15.0, booth_y - 10.0), Color(0.3, 0.28, 0.25, 0.5), 1.5)
	node.draw_circle(Vector2(booth_x + 15.0, booth_y - 11.0), 3.0, Color(0.35, 0.32, 0.28, 0.5))

	# Roof edge
	node.draw_line(Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h), Color(0.25, 0.23, 0.2, 0.7), 3.0)


# ── 4. GARAGE — Chop shop ────────────────────────────────────────────────────

static func draw_garage(node: Node2D, w: float, h: float, t: float) -> void:
	# --- Open messy structure with gaps ---
	var wall_color := Color(0.25, 0.23, 0.2)

	# Back wall (not full — has gaps)
	node.draw_rect(Rect2(-w / 2.0, -h, w, h), Color(0.15, 0.14, 0.13))

	# Left wall section (partial)
	node.draw_rect(Rect2(-w / 2.0, -h, 20.0, h * 0.6), wall_color)
	node.draw_rect(Rect2(-w / 2.0, -h * 0.25, 20.0, h * 0.25), wall_color)
	# Gap in left wall (exposed framing)
	node.draw_line(Vector2(-w / 2.0 + 10.0, -h * 0.4), Vector2(-w / 2.0 + 10.0, -h * 0.25), Color(0.35, 0.32, 0.28, 0.5), 2.0)
	node.draw_line(Vector2(-w / 2.0 + 3.0, -h * 0.35), Vector2(-w / 2.0 + 17.0, -h * 0.35), Color(0.35, 0.32, 0.28, 0.5), 2.0)

	# Right wall section (partial)
	node.draw_rect(Rect2(w / 2.0 - 20.0, -h, 20.0, h * 0.45), wall_color)
	node.draw_rect(Rect2(w / 2.0 - 20.0, -h * 0.35, 20.0, h * 0.35), wall_color)
	# Gap in right wall (exposed framing)
	node.draw_line(Vector2(w / 2.0 - 10.0, -h * 0.55), Vector2(w / 2.0 - 10.0, -h * 0.35), Color(0.35, 0.32, 0.28, 0.5), 2.0)
	node.draw_line(Vector2(w / 2.0 - 18.0, -h * 0.45), Vector2(w / 2.0 - 3.0, -h * 0.45), Color(0.35, 0.32, 0.28, 0.5), 2.0)

	# Roof (partial, with gaps showing sky)
	node.draw_rect(Rect2(-w / 2.0, -h, w * 0.35, 10.0), Color(0.3, 0.27, 0.23))
	node.draw_rect(Rect2(w * 0.05, -h, w * 0.45, 10.0), Color(0.28, 0.25, 0.22))
	# Corrugated texture on roof
	for i in 12:
		var corr_x: float = -w / 2.0 + float(i) * w / 11.0
		node.draw_line(Vector2(corr_x, -h), Vector2(corr_x, -h + 10.0), Color(0.35, 0.32, 0.28, 0.2), 1.0)

	# --- Parts hanging from hooks on ceiling ---
	for i in 6:
		var hook_x: float = -w / 2.0 + 40.0 + float(i) * (w - 80.0) / 5.0
		var hook_y: float = -h + 12.0
		var chain_len: float = 15.0 + fmod(float(i) * 11.3, 20.0)
		var chain_sway: float = sin(t * 0.6 + float(i) * 1.4) * 3.0
		# Hook
		node.draw_circle(Vector2(hook_x, hook_y), 2.0, Color(0.4, 0.37, 0.32))
		# Chain
		node.draw_line(Vector2(hook_x, hook_y), Vector2(hook_x + chain_sway, hook_y + chain_len), Color(0.4, 0.38, 0.33, 0.6), 1.5)
		# Hanging part (different shapes)
		var part_y: float = hook_y + chain_len
		if i % 3 == 0:
			# Engine block
			node.draw_rect(Rect2(hook_x + chain_sway - 8.0, part_y, 16.0, 12.0), Color(0.32, 0.3, 0.27))
		elif i % 3 == 1:
			# Exhaust pipe
			node.draw_line(Vector2(hook_x + chain_sway - 10.0, part_y + 4.0), Vector2(hook_x + chain_sway + 10.0, part_y + 4.0), Color(0.38, 0.35, 0.3), 4.0)
		else:
			# Panel
			node.draw_rect(Rect2(hook_x + chain_sway - 6.0, part_y, 12.0, 8.0), Color(0.35, 0.28, 0.22))

	# --- Grease stains on ground ---
	for i in 8:
		var stain_x: float = -w / 3.0 + fmod(float(i) * 31.7, w * 0.65)
		var stain_y: float = -2.0 - fmod(float(i) * 3.7, 4.0)
		var stain_r: float = 6.0 + fmod(float(i) * 7.3, 10.0)
		node.draw_circle(Vector2(stain_x, stain_y), stain_r, Color(0.08, 0.07, 0.06, 0.35))

	# --- Stolen vehicle parts in piles ---
	# Left pile
	node.draw_rect(Rect2(-w / 2.0 + 30.0, -25.0, 22.0, 25.0), Color(0.3, 0.27, 0.23))
	node.draw_rect(Rect2(-w / 2.0 + 35.0, -40.0, 16.0, 15.0), Color(0.33, 0.3, 0.25))
	node.draw_rect(Rect2(-w / 2.0 + 25.0, -18.0, 12.0, 18.0), Color(0.28, 0.25, 0.2))
	# Wheel on pile
	node.draw_arc(Vector2(-w / 2.0 + 48.0, -30.0), 8.0, 0.0, TAU, 16, Color(0.22, 0.2, 0.18, 0.7), 2.5)
	node.draw_arc(Vector2(-w / 2.0 + 48.0, -30.0), 3.0, 0.0, TAU, 12, Color(0.22, 0.2, 0.18, 0.5), 1.5)

	# Right pile
	node.draw_rect(Rect2(w / 2.0 - 60.0, -20.0, 18.0, 20.0), Color(0.32, 0.28, 0.22))
	node.draw_rect(Rect2(w / 2.0 - 50.0, -32.0, 20.0, 32.0), Color(0.28, 0.25, 0.2))
	# Bumper on pile
	node.draw_line(Vector2(w / 2.0 - 58.0, -22.0), Vector2(w / 2.0 - 35.0, -25.0), Color(0.4, 0.38, 0.35), 3.0)

	# --- Work bench with scattered tools ---
	var bench_x: float = -30.0
	var bench_y: float = -h * 0.32
	var bench_w: float = 80.0
	# Bench surface
	node.draw_rect(Rect2(bench_x, bench_y, bench_w, 6.0), Color(0.35, 0.3, 0.25))
	# Bench legs
	node.draw_line(Vector2(bench_x + 5.0, bench_y + 6.0), Vector2(bench_x + 5.0, bench_y + 30.0), Color(0.3, 0.27, 0.23), 3.0)
	node.draw_line(Vector2(bench_x + bench_w - 5.0, bench_y + 6.0), Vector2(bench_x + bench_w - 5.0, bench_y + 30.0), Color(0.3, 0.27, 0.23), 3.0)
	# Tools on bench
	# Wrench
	node.draw_line(Vector2(bench_x + 10.0, bench_y - 1.0), Vector2(bench_x + 25.0, bench_y - 2.0), Color(0.45, 0.42, 0.38), 2.0)
	# Screwdriver
	node.draw_line(Vector2(bench_x + 35.0, bench_y - 1.0), Vector2(bench_x + 48.0, bench_y - 1.0), Color(0.5, 0.3, 0.2), 1.5)
	# Hammer
	node.draw_line(Vector2(bench_x + 55.0, bench_y - 1.0), Vector2(bench_x + 65.0, bench_y - 3.0), Color(0.38, 0.35, 0.3), 2.0)
	node.draw_rect(Rect2(bench_x + 65.0, bench_y - 5.0, 6.0, 5.0), Color(0.4, 0.38, 0.33))
	# Bolts/small parts
	for i in 4:
		var bolt_x: float = bench_x + 15.0 + float(i) * 16.0
		node.draw_circle(Vector2(bolt_x, bench_y - 1.0), 1.5, Color(0.45, 0.42, 0.38, 0.5))

	# --- Sparking exposed wire (animated) ---
	var spark_x: float = w / 4.0
	var spark_y: float = -h * 0.6
	# Dangling wire
	node.draw_line(Vector2(spark_x, -h + 5.0), Vector2(spark_x - 5.0, -h * 0.65), Color(0.85, 0.4, 0.1, 0.6), 1.5)
	node.draw_line(Vector2(spark_x - 5.0, -h * 0.65), Vector2(spark_x + 3.0, spark_y), Color(0.85, 0.4, 0.1, 0.6), 1.5)
	# Sparks (blinking)
	var spark_on: bool = sin(t * 8.0) > 0.3
	if spark_on:
		for i in 5:
			var sp_angle: float = t * 6.0 + float(i) * 1.3
			var sp_dist: float = 3.0 + float(i) * 2.5
			var sp_dx: float = cos(sp_angle) * sp_dist
			var sp_dy: float = sin(sp_angle) * sp_dist
			node.draw_circle(Vector2(spark_x + 3.0 + sp_dx, spark_y + sp_dy), 1.0, Color(1.0, 0.8, 0.2, 0.8))
		node.draw_circle(Vector2(spark_x + 3.0, spark_y), 6.0, Color(1.0, 0.7, 0.15, 0.25))

	# --- Oil drum fire ---
	var drum_x: float = -w / 2.0 + 65.0
	var drum_y: float = -28.0
	# Drum body
	node.draw_rect(Rect2(drum_x, drum_y, 18.0, 28.0), Color(0.3, 0.22, 0.15))
	node.draw_line(Vector2(drum_x, drum_y + 8.0), Vector2(drum_x + 18.0, drum_y + 8.0), Color(0.38, 0.3, 0.22, 0.5), 1.0)
	node.draw_line(Vector2(drum_x, drum_y + 20.0), Vector2(drum_x + 18.0, drum_y + 20.0), Color(0.38, 0.3, 0.22, 0.5), 1.0)
	# Fire (animated)
	var fire_flicker: float = sin(t * 5.0) * 3.0
	var fire_flicker2: float = sin(t * 7.3) * 2.0
	# Outer flame
	var flame_pts := PackedVector2Array([
		Vector2(drum_x + 2.0, drum_y),
		Vector2(drum_x + 5.0, drum_y - 16.0 + fire_flicker),
		Vector2(drum_x + 9.0, drum_y - 22.0 + fire_flicker2),
		Vector2(drum_x + 13.0, drum_y - 15.0 + fire_flicker),
		Vector2(drum_x + 16.0, drum_y),
	])
	node.draw_colored_polygon(flame_pts, Color(0.9, 0.4, 0.1, 0.7))
	# Inner flame
	var inner_pts := PackedVector2Array([
		Vector2(drum_x + 5.0, drum_y),
		Vector2(drum_x + 7.0, drum_y - 12.0 + fire_flicker2),
		Vector2(drum_x + 9.0, drum_y - 16.0 + fire_flicker),
		Vector2(drum_x + 11.0, drum_y - 10.0 + fire_flicker2),
		Vector2(drum_x + 13.0, drum_y),
	])
	node.draw_colored_polygon(inner_pts, Color(1.0, 0.7, 0.2, 0.7))
	# Fire glow
	node.draw_circle(Vector2(drum_x + 9.0, drum_y - 8.0), 18.0, Color(0.9, 0.4, 0.1, 0.06))

	# --- "CASH ONLY" sign ---
	var csign_x: float = w / 2.0 - 75.0
	var csign_y: float = -h * 0.75
	node.draw_rect(Rect2(csign_x, csign_y, 55.0, 14.0), Color(0.35, 0.3, 0.22))
	for letter_idx in 6:
		var clx: float = csign_x + 4.0 + float(letter_idx) * 8.0
		node.draw_line(Vector2(clx, csign_y + 2.0), Vector2(clx + 4.0, csign_y + 12.0), Color(0.7, 0.6, 0.4, 0.6), 1.5)

	# --- Guard dog bowl (small detail near entrance) ---
	node.draw_arc(Vector2(25.0, -3.0), 5.0, PI, TAU, 12, Color(0.4, 0.35, 0.28, 0.5), 2.0)
	node.draw_line(Vector2(20.0, -3.0), Vector2(30.0, -3.0), Color(0.4, 0.35, 0.28, 0.5), 2.0)

	# Grimy floor
	for i in 6:
		var gx: float = -w / 3.0 + float(i) * w / 5.0
		node.draw_line(Vector2(gx, -1.0), Vector2(gx + 12.0, -1.0), Color(0.1, 0.09, 0.08, 0.3), 2.0)


# ── 5. UNIQUE — Smuggler's Den (hidden entrance) ─────────────────────────────

static func draw_unique(node: Node2D, w: float, h: float, t: float) -> void:
	# --- Natural rock face (main body — the whole building IS the rock) ---
	# Large irregular polygon, rock colored
	var rock_base := Color(0.3, 0.28, 0.25)
	var rock_pts := PackedVector2Array([
		Vector2(-w / 2.0, 0.0),
		Vector2(-w / 2.0 + 5.0, -h * 0.2),
		Vector2(-w / 2.0 + 12.0, -h * 0.45),
		Vector2(-w / 2.0 + 20.0, -h * 0.65),
		Vector2(-w / 2.0 + 40.0, -h * 0.82),
		Vector2(-w / 2.0 + 70.0, -h * 0.94),
		Vector2(-w * 0.12, -h * 0.98),
		Vector2(w * 0.05, -h),
		Vector2(w * 0.2, -h * 0.97),
		Vector2(w / 2.0 - 60.0, -h * 0.92),
		Vector2(w / 2.0 - 30.0, -h * 0.8),
		Vector2(w / 2.0 - 15.0, -h * 0.6),
		Vector2(w / 2.0 - 8.0, -h * 0.35),
		Vector2(w / 2.0, -h * 0.1),
		Vector2(w / 2.0, 0.0),
	])
	node.draw_colored_polygon(rock_pts, rock_base)

	# Rock texture layers — darker strata
	for i in 25:
		var rx: float = -w / 2.0 + fmod(float(i) * 31.7, w)
		var ry: float = -h + fmod(float(i) * 23.3, h)
		var rsz: float = 5.0 + fmod(float(i) * 13.7, 12.0)
		node.draw_circle(Vector2(rx, ry), rsz, Color(0.25, 0.23, 0.2, 0.2))

	# Rock texture — lighter mineral patches
	for i in 15:
		var mx: float = -w / 2.0 + fmod(float(i) * 43.1, w)
		var my: float = -h + fmod(float(i) * 29.7, h * 0.8)
		var msz: float = 3.0 + fmod(float(i) * 7.1, 6.0)
		node.draw_circle(Vector2(mx, my), msz, Color(0.38, 0.35, 0.32, 0.15))

	# Natural crack lines in rock (NOT the entrance — these are decoration)
	for i in 10:
		var cx: float = -w / 2.0 + fmod(float(i) * 47.3, w)
		var cy: float = -h + fmod(float(i) * 33.7, h)
		var cx2: float = cx + 8.0 + fmod(float(i) * 11.1, 20.0)
		var cy2: float = cy + 5.0 + fmod(float(i) * 7.3, 12.0)
		node.draw_line(Vector2(cx, cy), Vector2(cx2, cy2), Color(0.22, 0.2, 0.18, 0.25), 1.0)

	# Horizontal strata lines
	for i in 6:
		var strata_y: float = -h * 0.15 - float(i) * h * 0.13
		var strata_x1: float = -w / 2.0 + 15.0 + fmod(float(i) * 19.3, 30.0)
		var strata_x2: float = w / 2.0 - 20.0 - fmod(float(i) * 23.7, 40.0)
		node.draw_line(Vector2(strata_x1, strata_y), Vector2(strata_x2, strata_y), Color(0.26, 0.24, 0.21, 0.15), 1.5)

	# --- The barely visible vertical crack/fissure (THE ENTRANCE) ---
	var crack_x: float = w * 0.08
	var crack_top: float = -h * 0.72
	var crack_bot: float = -h * 0.03
	var crack_mid_x: float = crack_x + 1.5

	# Fissure — very subtle dark line
	var fissure_alpha: float = 0.18 + 0.05 * sin(t * 0.8)
	node.draw_line(Vector2(crack_x, crack_top), Vector2(crack_x - 1.0, crack_top + (crack_bot - crack_top) * 0.3), Color(0.1, 0.09, 0.08, fissure_alpha), 2.0)
	node.draw_line(Vector2(crack_x - 1.0, crack_top + (crack_bot - crack_top) * 0.3), Vector2(crack_mid_x, crack_top + (crack_bot - crack_top) * 0.6), Color(0.1, 0.09, 0.08, fissure_alpha), 2.5)
	node.draw_line(Vector2(crack_mid_x, crack_top + (crack_bot - crack_top) * 0.6), Vector2(crack_x, crack_bot), Color(0.1, 0.09, 0.08, fissure_alpha), 2.0)

	# Secondary hairline cracks branching off
	node.draw_line(Vector2(crack_x - 1.0, crack_top + 20.0), Vector2(crack_x - 8.0, crack_top + 28.0), Color(0.15, 0.14, 0.12, 0.12), 1.0)
	node.draw_line(Vector2(crack_mid_x, crack_top + 50.0), Vector2(crack_mid_x + 6.0, crack_top + 55.0), Color(0.15, 0.14, 0.12, 0.12), 1.0)
	node.draw_line(Vector2(crack_x, crack_bot - 30.0), Vector2(crack_x - 5.0, crack_bot - 22.0), Color(0.15, 0.14, 0.12, 0.1), 1.0)

	# --- Subtle glow from within the crack (animated pulse) ---
	var glow_intensity: float = 0.08 + 0.04 * sin(t * 1.2)
	var glow_center_y: float = (crack_top + crack_bot) * 0.5
	node.draw_circle(Vector2(crack_x, glow_center_y), 8.0, Color(0.3, 0.55, 0.6, glow_intensity))
	node.draw_circle(Vector2(crack_x, glow_center_y - 20.0), 5.0, Color(0.3, 0.55, 0.6, glow_intensity * 0.6))
	node.draw_circle(Vector2(crack_x, glow_center_y + 20.0), 5.0, Color(0.3, 0.55, 0.6, glow_intensity * 0.6))
	# Wider faint glow
	node.draw_circle(Vector2(crack_x, glow_center_y), 20.0, Color(0.3, 0.55, 0.6, glow_intensity * 0.25))

	# --- Small scratched symbol beside crack (smuggler mark) ---
	var sym_x: float = crack_x + 12.0
	var sym_y: float = glow_center_y - 5.0
	# Triangle scratch mark
	node.draw_line(Vector2(sym_x, sym_y - 5.0), Vector2(sym_x + 4.0, sym_y + 3.0), Color(0.4, 0.37, 0.33, 0.15), 1.0)
	node.draw_line(Vector2(sym_x + 4.0, sym_y + 3.0), Vector2(sym_x - 4.0, sym_y + 3.0), Color(0.4, 0.37, 0.33, 0.15), 1.0)
	node.draw_line(Vector2(sym_x - 4.0, sym_y + 3.0), Vector2(sym_x, sym_y - 5.0), Color(0.4, 0.37, 0.33, 0.15), 1.0)
	# Dot in center
	node.draw_circle(Vector2(sym_x, sym_y + 0.5), 1.0, Color(0.4, 0.37, 0.33, 0.15))

	# --- Security camera hidden in rock formation ---
	var cam_x: float = crack_x - 30.0
	var cam_y: float = crack_top + 15.0
	# Rock bump hiding camera
	node.draw_circle(Vector2(cam_x, cam_y), 8.0, Color(0.32, 0.3, 0.27, 0.6))
	node.draw_circle(Vector2(cam_x + 3.0, cam_y - 2.0), 5.0, Color(0.34, 0.31, 0.28, 0.5))
	# Tiny lens (barely visible)
	node.draw_circle(Vector2(cam_x + 5.0, cam_y), 1.5, Color(0.15, 0.15, 0.18, 0.3))
	# Tiny red indicator (blinks very rarely)
	var cam_blink: float = 0.0
	if fmod(t, 5.0) < 0.15:
		cam_blink = 0.5
	node.draw_circle(Vector2(cam_x + 5.0, cam_y + 2.0), 0.8, Color(0.8, 0.1, 0.1, cam_blink))

	# --- Crates partially concealed by rock debris ---
	var crate_base_x: float = crack_x + 25.0
	var crate_base_y: float = -18.0
	# Crate 1 (partially visible)
	node.draw_rect(Rect2(crate_base_x, crate_base_y, 16.0, 18.0), Color(0.32, 0.26, 0.19, 0.4))
	node.draw_line(Vector2(crate_base_x, crate_base_y), Vector2(crate_base_x + 16.0, crate_base_y + 18.0), Color(0.4, 0.3, 0.2, 0.25), 1.0)
	# Crate 2 (stacked, more hidden)
	node.draw_rect(Rect2(crate_base_x + 4.0, crate_base_y - 14.0, 12.0, 14.0), Color(0.3, 0.24, 0.17, 0.3))
	# Rock debris partially covering crates
	var debris_pts := PackedVector2Array([
		Vector2(crate_base_x + 18.0, 0.0),
		Vector2(crate_base_x + 22.0, -8.0),
		Vector2(crate_base_x + 28.0, -15.0),
		Vector2(crate_base_x + 35.0, -10.0),
		Vector2(crate_base_x + 38.0, 0.0),
	])
	node.draw_colored_polygon(debris_pts, Color(0.3, 0.28, 0.25))
	# More debris on left of crates
	var debris2_pts := PackedVector2Array([
		Vector2(crate_base_x - 8.0, 0.0),
		Vector2(crate_base_x - 5.0, -12.0),
		Vector2(crate_base_x + 2.0, -8.0),
		Vector2(crate_base_x + 5.0, 0.0),
	])
	node.draw_colored_polygon(debris2_pts, Color(0.29, 0.27, 0.24))

	# --- Footprints leading to crack ---
	for i in 6:
		var fp_x: float = crack_x + 50.0 - float(i) * 9.0
		var fp_y: float = -3.0 + fmod(float(i) * 1.7, 3.0)
		# Left foot / right foot alternating
		var fp_off: float = -2.0 if i % 2 == 0 else 2.0
		node.draw_circle(Vector2(fp_x, fp_y + fp_off), 1.8, Color(0.22, 0.2, 0.18, 0.12))
		node.draw_circle(Vector2(fp_x + 2.0, fp_y + fp_off + 1.0), 1.0, Color(0.22, 0.2, 0.18, 0.1))

	# --- Ice formation partially hiding entrance ---
	var ice_x: float = crack_x - 10.0
	var ice_y: float = crack_top - 5.0
	# Ice mass over top of crack
	var ice_pts := PackedVector2Array([
		Vector2(ice_x - 12.0, ice_y + 15.0),
		Vector2(ice_x - 8.0, ice_y),
		Vector2(ice_x, ice_y - 8.0),
		Vector2(ice_x + 15.0, ice_y - 5.0),
		Vector2(ice_x + 20.0, ice_y + 10.0),
		Vector2(ice_x + 18.0, ice_y + 20.0),
	])
	node.draw_colored_polygon(ice_pts, Color(0.4, 0.6, 0.65, 0.35))
	node.draw_polyline(ice_pts, Color(0.5, 0.7, 0.75, 0.2), 1.0)
	# Icicles hanging from ice formation
	for i in 3:
		var icicle_x: float = ice_x - 5.0 + float(i) * 10.0
		var icicle_len: float = 8.0 + float(i) * 4.0
		var icicle_pts := PackedVector2Array([
			Vector2(icicle_x - 2.0, ice_y + 18.0),
			Vector2(icicle_x + 2.0, ice_y + 18.0),
			Vector2(icicle_x, ice_y + 18.0 + icicle_len),
		])
		node.draw_colored_polygon(icicle_pts, Color(0.45, 0.65, 0.7, 0.3))

	# Bottom ice formation near ground level
	var ice_bot_pts := PackedVector2Array([
		Vector2(crack_x - 15.0, 0.0),
		Vector2(crack_x - 12.0, -10.0),
		Vector2(crack_x - 5.0, -14.0),
		Vector2(crack_x + 3.0, -12.0),
		Vector2(crack_x + 8.0, -6.0),
		Vector2(crack_x + 10.0, 0.0),
	])
	node.draw_colored_polygon(ice_bot_pts, Color(0.4, 0.6, 0.65, 0.3))

	# --- "Look closer" subtle details ---
	# Tiny scratch tally marks on rock (someone counting days?)
	var tally_x: float = -w / 2.0 + 50.0
	var tally_y: float = -h * 0.35
	for i in 5:
		var tx: float = tally_x + float(i) * 3.5
		node.draw_line(Vector2(tx, tally_y), Vector2(tx, tally_y + 6.0), Color(0.38, 0.35, 0.32, 0.1), 1.0)
	# Cross mark on 5th tally
	node.draw_line(Vector2(tally_x, tally_y + 2.0), Vector2(tally_x + 14.0, tally_y + 4.0), Color(0.38, 0.35, 0.32, 0.1), 1.0)

	# Barely visible boot scuff near crack base
	node.draw_line(Vector2(crack_x - 3.0, -1.0), Vector2(crack_x + 5.0, -2.0), Color(0.2, 0.18, 0.16, 0.12), 2.0)

	# Tiny discarded cigarette butt
	node.draw_line(Vector2(crack_x + 18.0, -1.5), Vector2(crack_x + 22.0, -1.0), Color(0.6, 0.58, 0.52, 0.1), 1.5)
	node.draw_circle(Vector2(crack_x + 22.0, -1.0), 1.0, Color(0.5, 0.4, 0.3, 0.1))

	# Moss/lichen on rock face (organic detail)
	for i in 5:
		var lichen_x: float = -w / 2.0 + 30.0 + fmod(float(i) * 67.3, w - 60.0)
		var lichen_y: float = -h * 0.4 + fmod(float(i) * 41.7, h * 0.3)
		node.draw_circle(Vector2(lichen_x, lichen_y), 3.0 + float(i % 3) * 2.0, Color(0.2, 0.3, 0.18, 0.1))

	# Ground rubble and small rocks
	for i in 8:
		var rub_x: float = -w / 2.0 + fmod(float(i) * 53.7, w)
		var rub_sz: float = 2.0 + fmod(float(i) * 7.3, 4.0)
		node.draw_circle(Vector2(rub_x, -rub_sz), rub_sz, Color(0.28, 0.26, 0.23, 0.3))

	# Subtle rock face edge outline
	node.draw_polyline(rock_pts, Color(0.35, 0.33, 0.3, 0.3), 2.0)
