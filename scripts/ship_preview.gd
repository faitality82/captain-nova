extends Node2D

# Draws a static preview of the procedural ship for the paint shop

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var hull_c: Color = ResourceManager.ship_hull_color
	var accent_c: Color = ResourceManager.ship_accent_color
	var engine_c: Color = ResourceManager.ship_engine_color
	var weapon: String = ResourceManager.current_weapon
	var t: float = Time.get_ticks_msec() * 0.001

	# Ship faces right (angle = 0)
	var fwd: Vector2 = Vector2.RIGHT
	var right: Vector2 = Vector2.DOWN
	var scale_f: float = 2.0  # bigger preview

	var hull_dark: Color = hull_c.darkened(0.2)

	# Engine glow (always show in preview)
	var engine_lvl: int = ResourceManager.upgrade_levels.get("engine", 0)
	var exhaust_len: float = (12.0 + engine_lvl * 4.0) * scale_f
	var flicker: float = sin(t * 15.0) * 2.0 * scale_f
	exhaust_len += flicker
	var base_l: Vector2 = fwd * -14.0 * scale_f + right * -5.0 * scale_f
	var base_r: Vector2 = fwd * -14.0 * scale_f + right * 5.0 * scale_f
	var tip: Vector2 = fwd * -(14.0 * scale_f + exhaust_len)
	draw_colored_polygon(PackedVector2Array([base_l, tip, base_r]), Color(engine_c, 0.9))
	var core_l: Vector2 = fwd * -14.0 * scale_f + right * -2.5 * scale_f
	var core_r: Vector2 = fwd * -14.0 * scale_f + right * 2.5 * scale_f
	var core_tip: Vector2 = fwd * -(14.0 * scale_f + exhaust_len * 0.6)
	draw_colored_polygon(PackedVector2Array([core_l, core_tip, core_r]), Color(1, 1, 1, 0.7))

	# Hull
	var s: float = scale_f
	var nose: Vector2 = fwd * 22.0 * s
	var wing_l: Vector2 = fwd * -10.0 * s + right * -16.0 * s
	var wing_r: Vector2 = fwd * -10.0 * s + right * 16.0 * s
	var shoulder_l: Vector2 = fwd * 6.0 * s + right * -10.0 * s
	var shoulder_r: Vector2 = fwd * 6.0 * s + right * 10.0 * s
	var rear_l: Vector2 = fwd * -14.0 * s + right * -8.0 * s
	var rear_r: Vector2 = fwd * -14.0 * s + right * 8.0 * s
	draw_colored_polygon(PackedVector2Array([nose, shoulder_r, wing_r, rear_r, rear_l, wing_l, shoulder_l]), hull_c)

	# Accent stripe
	var sw: float = 2.5 * s
	draw_colored_polygon(PackedVector2Array([
		fwd * 18.0 * s + right * -sw, fwd * 18.0 * s + right * sw,
		fwd * -12.0 * s + right * sw, fwd * -12.0 * s + right * -sw,
	]), accent_c)

	# Wing fins
	var fin_ext: float = (4.0 + engine_lvl * 2.0) * s
	draw_colored_polygon(PackedVector2Array([wing_l, fwd * -6.0 * s + right * -(16.0 * s + fin_ext), fwd * -16.0 * s + right * -(10.0 * s + fin_ext * 0.5), rear_l]), hull_dark)
	draw_colored_polygon(PackedVector2Array([wing_r, fwd * -6.0 * s + right * (16.0 * s + fin_ext), fwd * -16.0 * s + right * (10.0 * s + fin_ext * 0.5), rear_r]), hull_dark)

	# Cockpit canopy
	draw_colored_polygon(PackedVector2Array([fwd * 14.0 * s, fwd * 6.0 * s + right * -4.0 * s, fwd * 2.0 * s, fwd * 6.0 * s + right * 4.0 * s]), Color(0.3, 0.6, 0.9, 0.6))

	# Weapon tip glow
	var w_glow: Color
	match weapon:
		"blaster": w_glow = Color(1.0, 0.8, 0.2)
		"laser": w_glow = Color(1.0, 0.2, 0.2)
		"spread": w_glow = Color(0.2, 1.0, 0.3)
		"homing": w_glow = Color(0.8, 0.3, 1.0)
		"railgun": w_glow = Color(0.3, 0.8, 1.0)
		_: w_glow = Color(1.0, 0.8, 0.2)
	var weapon_lvl: int = ResourceManager.upgrade_levels.get("weapon", 0)
	var barrel_len: float = (6.0 + weapon_lvl * 2.0) * s
	draw_circle(nose + fwd * barrel_len, (2.0 + weapon_lvl * 0.5) * s, Color(w_glow, 0.7))
