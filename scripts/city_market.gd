extends CanvasLayer

signal closed

var _buy_rows: Dictionary = {}
var _sell_rows: Dictionary = {}
var _weapon_rows: Dictionary = {}

# ── Inner class: procedural resource icon ──────────────────────────────
class ResourceIcon extends Control:
	var resource_name: String = ""

	func _init(res: String = "") -> void:
		resource_name = res
		custom_minimum_size = Vector2(24, 24)

	func _draw() -> void:
		var cx: float = 12.0
		var cy: float = 12.0
		match resource_name:
			"ore":
				# Brown/orange rocky chunks
				var pts = PackedVector2Array([
					Vector2(4, 18), Vector2(2, 12), Vector2(6, 6),
					Vector2(12, 3), Vector2(18, 5), Vector2(21, 10),
					Vector2(20, 16), Vector2(14, 20), Vector2(8, 19)
				])
				draw_colored_polygon(pts, Color(0.65, 0.42, 0.18))
				draw_polyline(pts, Color(0.45, 0.3, 0.1), 1.0)
				# crack line
				draw_line(Vector2(8, 8), Vector2(14, 14), Color(0.45, 0.3, 0.1), 1.0)
			"fuel":
				# Red fuel canister
				draw_rect(Rect2(6, 6, 12, 14), Color(0.85, 0.15, 0.1))
				draw_rect(Rect2(6, 6, 12, 14), Color(0.6, 0.1, 0.08), false, 1.0)
				# nozzle
				draw_rect(Rect2(9, 2, 6, 5), Color(0.7, 0.7, 0.7))
				# highlight
				draw_rect(Rect2(8, 8, 3, 8), Color(1.0, 0.4, 0.35))
			"parts":
				# Gray gear/cog shape
				var gear_color = Color(0.6, 0.62, 0.65)
				var teeth: int = 6
				var outer_r: float = 10.0
				var inner_r: float = 6.0
				var gear_pts = PackedVector2Array()
				for i in range(teeth * 2):
					var angle: float = float(i) * PI / float(teeth)
					var r: float = outer_r if i % 2 == 0 else inner_r
					gear_pts.append(Vector2(cx + cos(angle) * r, cy + sin(angle) * r))
				draw_colored_polygon(gear_pts, gear_color)
				draw_circle(Vector2(cx, cy), 3.0, Color(0.3, 0.3, 0.35))
			"ice":
				# Light blue crystal/diamond
				var pts = PackedVector2Array([
					Vector2(12, 2), Vector2(20, 10), Vector2(12, 22), Vector2(4, 10)
				])
				draw_colored_polygon(pts, Color(0.6, 0.85, 1.0))
				draw_polyline(pts, Color(0.4, 0.7, 0.9), 1.0)
				draw_line(Vector2(12, 2), Vector2(12, 22), Color(0.8, 0.95, 1.0, 0.5), 1.0)
			"crystals":
				# Purple/pink faceted gem
				var pts = PackedVector2Array([
					Vector2(12, 1), Vector2(19, 7), Vector2(22, 14),
					Vector2(16, 22), Vector2(8, 22), Vector2(2, 14), Vector2(5, 7)
				])
				draw_colored_polygon(pts, Color(0.7, 0.25, 0.75))
				draw_polyline(pts, Color(0.9, 0.5, 0.95), 1.0)
				draw_line(Vector2(12, 1), Vector2(12, 22), Color(0.9, 0.6, 1.0, 0.4), 1.0)
			"plasma":
				# Bright green glowing orb
				draw_circle(Vector2(cx, cy), 9.0, Color(0.1, 0.8, 0.2, 0.3))
				draw_circle(Vector2(cx, cy), 7.0, Color(0.2, 0.9, 0.3, 0.5))
				draw_circle(Vector2(cx, cy), 5.0, Color(0.4, 1.0, 0.4))
				draw_circle(Vector2(cx, cy), 2.0, Color(0.8, 1.0, 0.8))
			"antimatter":
				# Swirling dark purple sphere with inner glow
				draw_circle(Vector2(cx, cy), 9.0, Color(0.15, 0.0, 0.25))
				draw_circle(Vector2(cx, cy), 6.0, Color(0.35, 0.05, 0.55, 0.7))
				draw_circle(Vector2(cx, cy), 3.0, Color(0.6, 0.2, 0.9, 0.8))
				draw_arc(Vector2(cx, cy), 7.0, 0.0, 4.0, 12, Color(0.7, 0.3, 1.0, 0.5), 1.0)
			"biotech":
				# Green organic cell/blob
				draw_circle(Vector2(cx, cy), 8.0, Color(0.15, 0.6, 0.2))
				draw_circle(Vector2(cx - 2, cy - 2), 3.0, Color(0.25, 0.75, 0.3, 0.7))
				draw_circle(Vector2(cx + 3, cy + 2), 2.5, Color(0.2, 0.7, 0.25, 0.6))
				draw_circle(Vector2(cx, cy), 1.5, Color(0.4, 0.85, 0.4))
			"nanites":
				# Tiny silver dots in cluster
				var nanite_color = Color(0.75, 0.78, 0.82)
				var offsets = [
					Vector2(-3, -3), Vector2(0, -4), Vector2(3, -2),
					Vector2(-4, 1), Vector2(-1, 0), Vector2(2, 1), Vector2(5, 0),
					Vector2(-3, 3), Vector2(0, 4), Vector2(3, 3),
				]
				for off in offsets:
					draw_circle(Vector2(cx + off.x, cy + off.y), 1.5, nanite_color)
			"dark_matter":
				# Black circle with faint purple halo
				draw_circle(Vector2(cx, cy), 10.0, Color(0.2, 0.05, 0.3, 0.4))
				draw_circle(Vector2(cx, cy), 7.0, Color(0.08, 0.0, 0.12))
				draw_circle(Vector2(cx, cy), 4.0, Color(0.0, 0.0, 0.0))
				draw_arc(Vector2(cx, cy), 9.0, 0.0, TAU, 24, Color(0.4, 0.1, 0.6, 0.5), 1.5)
			"artifacts":
				# Gold ornate star/medallion
				var star_pts = PackedVector2Array()
				var points_count: int = 5
				for i in range(points_count * 2):
					var angle: float = float(i) * PI / float(points_count) - PI / 2.0
					var r: float = 10.0 if i % 2 == 0 else 4.5
					star_pts.append(Vector2(cx + cos(angle) * r, cy + sin(angle) * r))
				draw_colored_polygon(star_pts, Color(1.0, 0.82, 0.2))
				draw_circle(Vector2(cx, cy), 3.0, Color(1.0, 0.9, 0.5))
			"gravitonium":
				# Blue-gray swirl/vortex
				draw_circle(Vector2(cx, cy), 9.0, Color(0.3, 0.35, 0.5, 0.5))
				draw_arc(Vector2(cx, cy), 7.0, 0.0, 5.0, 16, Color(0.4, 0.5, 0.7), 2.0)
				draw_arc(Vector2(cx, cy), 4.0, 1.0, 6.0, 12, Color(0.5, 0.6, 0.8), 1.5)
				draw_circle(Vector2(cx, cy), 2.0, Color(0.6, 0.7, 0.9))
			"void_essence":
				# Deep indigo with faint white sparkle
				draw_circle(Vector2(cx, cy), 9.0, Color(0.08, 0.02, 0.2))
				draw_circle(Vector2(cx, cy), 6.0, Color(0.12, 0.04, 0.3))
				draw_circle(Vector2(cx - 2, cy - 2), 1.0, Color(1.0, 1.0, 1.0, 0.7))
				draw_circle(Vector2(cx + 3, cy + 1), 0.8, Color(1.0, 1.0, 1.0, 0.5))
				draw_circle(Vector2(cx + 1, cy + 3), 0.6, Color(1.0, 1.0, 1.0, 0.4))
			"starcore":
				# Bright yellow/white star shape
				var star_pts = PackedVector2Array()
				var sc: int = 4
				for i in range(sc * 2):
					var angle: float = float(i) * PI / float(sc) - PI / 2.0
					var r: float = 10.0 if i % 2 == 0 else 3.0
					star_pts.append(Vector2(cx + cos(angle) * r, cy + sin(angle) * r))
				draw_colored_polygon(star_pts, Color(1.0, 0.95, 0.5))
				draw_circle(Vector2(cx, cy), 4.0, Color(1.0, 1.0, 0.9))
			"contraband":
				# Red/black crate with X mark
				draw_rect(Rect2(3, 3, 18, 18), Color(0.2, 0.05, 0.05))
				draw_rect(Rect2(3, 3, 18, 18), Color(0.7, 0.1, 0.1), false, 1.5)
				draw_line(Vector2(6, 6), Vector2(18, 18), Color(0.9, 0.15, 0.1), 2.0)
				draw_line(Vector2(18, 6), Vector2(6, 18), Color(0.9, 0.15, 0.1), 2.0)
			# Weapon icons
			"blaster":
				draw_rect(Rect2(4, 10, 16, 5), Color(0.5, 0.55, 0.6))
				draw_rect(Rect2(16, 8, 5, 9), Color(0.6, 0.62, 0.65))
				draw_circle(Vector2(6, 12), 2.0, Color(1.0, 0.8, 0.2))
			"laser":
				draw_rect(Rect2(3, 11, 18, 3), Color(0.7, 0.15, 0.15))
				draw_line(Vector2(2, 12), Vector2(22, 12), Color(1.0, 0.3, 0.3), 1.5)
				draw_circle(Vector2(4, 12), 2.0, Color(1.0, 0.5, 0.5))
			"spread":
				var fan_color = Color(0.9, 0.65, 0.1)
				draw_line(Vector2(4, 12), Vector2(20, 6), fan_color, 1.5)
				draw_line(Vector2(4, 12), Vector2(20, 9), fan_color, 1.5)
				draw_line(Vector2(4, 12), Vector2(20, 12), fan_color, 1.5)
				draw_line(Vector2(4, 12), Vector2(20, 15), fan_color, 1.5)
				draw_line(Vector2(4, 12), Vector2(20, 18), fan_color, 1.5)
			"homing":
				draw_rect(Rect2(6, 8, 12, 8), Color(0.3, 0.5, 0.3))
				# fins
				var fin_col = Color(0.4, 0.6, 0.4)
				draw_line(Vector2(6, 8), Vector2(3, 4), fin_col, 1.5)
				draw_line(Vector2(6, 16), Vector2(3, 20), fin_col, 1.5)
				# tip
				var tip_pts = PackedVector2Array([Vector2(18, 8), Vector2(22, 12), Vector2(18, 16)])
				draw_colored_polygon(tip_pts, Color(0.8, 0.2, 0.1))
			"railgun":
				draw_rect(Rect2(2, 10, 20, 4), Color(0.35, 0.4, 0.55))
				draw_line(Vector2(2, 12), Vector2(22, 12), Color(0.5, 0.7, 1.0), 1.0)
				draw_rect(Rect2(2, 9, 4, 6), Color(0.45, 0.5, 0.6))
				draw_rect(Rect2(18, 9, 4, 6), Color(0.45, 0.5, 0.6))
			# Upgrade icons
			"engine":
				var flame = PackedVector2Array([Vector2(8, 20), Vector2(12, 4), Vector2(16, 20)])
				draw_colored_polygon(flame, Color(1.0, 0.5, 0.1))
				draw_colored_polygon(PackedVector2Array([Vector2(10, 20), Vector2(12, 10), Vector2(14, 20)]), Color(1.0, 0.85, 0.3))
			"shield":
				var shield_pts = PackedVector2Array([
					Vector2(12, 2), Vector2(20, 6), Vector2(20, 14),
					Vector2(12, 22), Vector2(4, 14), Vector2(4, 6)
				])
				draw_colored_polygon(shield_pts, Color(0.2, 0.5, 0.9, 0.7))
				draw_polyline(shield_pts, Color(0.4, 0.7, 1.0), 1.5)
			"cargo":
				draw_rect(Rect2(4, 6, 16, 14), Color(0.5, 0.4, 0.25))
				draw_rect(Rect2(4, 6, 16, 14), Color(0.65, 0.55, 0.35), false, 1.0)
				draw_rect(Rect2(9, 6, 6, 4), Color(0.65, 0.55, 0.35))
			"weapon":
				draw_rect(Rect2(4, 10, 16, 4), Color(0.6, 0.25, 0.25))
				draw_circle(Vector2(6, 12), 2.0, Color(0.9, 0.4, 0.1))
			"fuel_tank":
				draw_rect(Rect2(6, 4, 12, 16), Color(0.2, 0.5, 0.7))
				draw_rect(Rect2(6, 4, 12, 16), Color(0.3, 0.65, 0.85), false, 1.0)
				draw_rect(Rect2(9, 1, 6, 4), Color(0.4, 0.6, 0.7))
			# Ability icons
			"dash":
				var arrow_col = Color(0.3, 0.8, 1.0)
				draw_line(Vector2(4, 12), Vector2(18, 12), arrow_col, 2.0)
				draw_line(Vector2(14, 7), Vector2(20, 12), arrow_col, 2.0)
				draw_line(Vector2(14, 17), Vector2(20, 12), arrow_col, 2.0)
			"shield_bubble":
				draw_arc(Vector2(cx, cy), 9.0, 0.0, TAU, 24, Color(0.3, 0.7, 1.0, 0.6), 2.0)
				draw_arc(Vector2(cx, cy), 6.0, 0.0, TAU, 18, Color(0.4, 0.8, 1.0, 0.3), 1.0)
			"emp_blast":
				draw_arc(Vector2(cx, cy), 9.0, 0.0, TAU, 24, Color(1.0, 1.0, 0.3, 0.4), 2.0)
				draw_arc(Vector2(cx, cy), 5.0, 0.0, TAU, 16, Color(1.0, 1.0, 0.5, 0.6), 1.5)
				draw_circle(Vector2(cx, cy), 2.0, Color(1.0, 1.0, 0.7))
			_:
				# Fallback: simple colored square
				draw_rect(Rect2(4, 4, 16, 16), Color(0.4, 0.4, 0.4))

# ── Section header colors ──────────────────────────────────────────────
const SECTION_COLORS: Dictionary = {
	"buy": Color(0.2, 0.8, 0.3),
	"premium": Color(1.0, 0.82, 0.2),
	"sell": Color(0.95, 0.6, 0.15),
	"upgrades": Color(0.3, 0.55, 1.0),
	"weapons": Color(0.9, 0.25, 0.2),
	"abilities": Color(0.7, 0.3, 0.9),
}

func _ready() -> void:
	layer = 10
	_build_ui()
	ResourceManager.update_price_memory(ResourceManager.current_planet, ResourceManager.current_planet_prices)

# ── Helper: create a styled section header ─────────────────────────────
func _make_section_header(text: String, section_key: String) -> VBoxContainer:
	var wrapper = VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", 2)

	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	var col: Color = SECTION_COLORS.get(section_key, Color.WHITE)
	lbl.add_theme_color_override("font_color", col)
	wrapper.add_child(lbl)

	# Colored underline
	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(0, 2)
	line.color = Color(col.r, col.g, col.b, 0.5)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_child(line)

	return wrapper

# ── Helper: create a resource row (buy or sell) ────────────────────────
func _make_resource_row(icon_name: String, display_name: String, price_label_name: String, btn_name: String, btn_min_w: float, callback: Callable, premium: bool = false) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var icon = ResourceIcon.new(icon_name)
	row.add_child(icon)

	var name_lbl = Label.new()
	name_lbl.text = display_name
	name_lbl.custom_minimum_size = Vector2(105, 0)
	name_lbl.add_theme_font_size_override("font_size", 13)
	if premium:
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	row.add_child(name_lbl)

	var supply_lbl = Label.new()
	supply_lbl.name = "Supply"
	supply_lbl.custom_minimum_size = Vector2(62, 0)
	supply_lbl.add_theme_font_size_override("font_size", 11)
	row.add_child(supply_lbl)

	if price_label_name != "":
		var plbl = Label.new()
		plbl.name = price_label_name
		plbl.custom_minimum_size = Vector2(55, 0)
		plbl.add_theme_font_size_override("font_size", 13)
		row.add_child(plbl)

	var btn = Button.new()
	btn.name = btn_name
	btn.custom_minimum_size = Vector2(btn_min_w, 26)
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(callback)
	row.add_child(btn)

	return row

func _build_ui() -> void:
	# Rebuildable: a second call replaces the panel instead of stacking another one on top.
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_buy_rows.clear()
	_sell_rows.clear()
	_weapon_rows.clear()

	# ── Main panel with dark background ────────────────────────────────
	var panel = Panel.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 40
	panel.offset_top = 20
	panel.offset_right = -40
	panel.offset_bottom = -20

	var panel_bg = StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	panel_bg.border_width_left = 1
	panel_bg.border_width_right = 1
	panel_bg.border_width_top = 1
	panel_bg.border_width_bottom = 1
	panel_bg.border_color = Color(0.25, 0.25, 0.35, 0.7)
	panel_bg.corner_radius_top_left = 4
	panel_bg.corner_radius_top_right = 4
	panel_bg.corner_radius_bottom_left = 4
	panel_bg.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_bg)
	add_child(panel)

	# ── Scroll container ───────────────────────────────────────────────
	var scroll = ScrollContainer.new()
	scroll.anchor_left = 0.0
	scroll.anchor_top = 0.0
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 8
	scroll.offset_top = 8
	scroll.offset_right = -8
	scroll.offset_bottom = -8
	panel.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox)

	# ── Title header ───────────────────────────────────────────────────
	var header = Label.new()
	header.text = ResourceManager.current_planet + " Market"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", Color(0.9, 0.92, 1.0))
	vbox.add_child(header)

	# ── Info status bar ────────────────────────────────────────────────
	var info_bar = PanelContainer.new()
	var info_bg = StyleBoxFlat.new()
	info_bg.bg_color = Color(0.1, 0.12, 0.18, 0.9)
	info_bg.border_width_bottom = 1
	info_bg.border_color = Color(0.3, 0.35, 0.5, 0.5)
	info_bg.corner_radius_top_left = 3
	info_bg.corner_radius_top_right = 3
	info_bg.corner_radius_bottom_left = 3
	info_bg.corner_radius_bottom_right = 3
	info_bg.content_margin_left = 10
	info_bg.content_margin_right = 10
	info_bg.content_margin_top = 4
	info_bg.content_margin_bottom = 4
	info_bar.add_theme_stylebox_override("panel", info_bg)

	var info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 14)
	info_label.add_theme_color_override("font_color", Color(0.75, 0.9, 1.0))
	info_bar.add_child(info_label)
	vbox.add_child(info_bar)

	# ── Spacer ─────────────────────────────────────────────────────────
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer_top)

	var prices = ResourceManager.current_planet_prices
	var base_resources = ResourceManager.ALL_RESOURCES
	var planet_name = ResourceManager.current_planet
	var rep = ResourceManager.get_reputation(planet_name)

	# ═══════════════════════════════════════════════════════════════════
	# BUY CARGO SECTION
	# ═══════════════════════════════════════════════════════════════════
	var has_buy_items = false
	for resource in base_resources:
		var buy_price = prices[resource][0] if resource in prices else 0
		if buy_price > 0:
			has_buy_items = true
			break

	if has_buy_items:
		vbox.add_child(_make_section_header("Buy Cargo", "buy"))

		# Why the prices look strange today. Filled in _refresh_ui, hidden when nothing is running.
		var news_lbl = Label.new()
		news_lbl.name = "MarketNews"
		news_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		news_lbl.add_theme_font_size_override("font_size", 12)
		news_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.35))
		news_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		news_lbl.visible = false
		vbox.add_child(news_lbl)

		for resource in base_resources:
			var buy_price = prices[resource][0] if resource in prices else 0
			if buy_price <= 0:
				continue
			var res_name = resource
			var row = _make_resource_row(resource, resource.capitalize(), "BuyPrice", "BuyBtn", 110.0, func(): _buy(res_name))
			vbox.add_child(row)
			_buy_rows[resource] = row

		var sp1 = Control.new()
		sp1.custom_minimum_size = Vector2(0, 6)
		vbox.add_child(sp1)

	# ═══════════════════════════════════════════════════════════════════
	# PREMIUM GOODS SECTION
	# ═══════════════════════════════════════════════════════════════════
	var all_premium = ResourceManager.PREMIUM_RESOURCES_T2 + ResourceManager.PREMIUM_RESOURCES_T3 + ResourceManager.PREMIUM_RESOURCES_T4
	var any_premium = false
	for res in all_premium:
		if res in prices and prices[res][0] > 0:
			if res in ResourceManager.T4_PLANET_LOCKS:
				if planet_name not in ResourceManager.T4_PLANET_LOCKS[res]:
					continue
			any_premium = true
			break

	if any_premium:
		vbox.add_child(_make_section_header("Premium Goods", "premium"))

		for res in all_premium:
			if res not in prices:
				continue
			var buy_price = prices[res][0]
			if buy_price <= 0:
				continue
			if res in ResourceManager.T4_PLANET_LOCKS:
				if planet_name not in ResourceManager.T4_PLANET_LOCKS[res]:
					continue
			var req_rep = ResourceManager.PREMIUM_REP_REQUIRED.get(res, 0)
			if rep < req_rep:
				# Locked row
				var locked_row = HBoxContainer.new()
				locked_row.add_theme_constant_override("separation", 6)
				var icon = ResourceIcon.new(res)
				locked_row.add_child(icon)
				var locked_label = Label.new()
				locked_label.text = "%s (Rep %d needed, you: %d)" % [res.capitalize().replace("_", " "), req_rep, rep]
				locked_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
				locked_label.add_theme_font_size_override("font_size", 12)
				locked_row.add_child(locked_label)
				vbox.add_child(locked_row)
			else:
				var res_name = res
				var row = _make_resource_row(res, res.capitalize().replace("_", " "), "BuyPrice", "BuyBtn", 110.0, func(): _buy(res_name), true)
				vbox.add_child(row)
				_buy_rows[res] = row

		var sp2 = Control.new()
		sp2.custom_minimum_size = Vector2(0, 6)
		vbox.add_child(sp2)

	# ═══════════════════════════════════════════════════════════════════
	# SELL CARGO SECTION
	# ═══════════════════════════════════════════════════════════════════
	vbox.add_child(_make_section_header("Sell Cargo", "sell"))

	# The Tithe pays a premium for its sacraments — worth saying out loud where it holds.
	var tithe_lbl = Label.new()
	tithe_lbl.name = "TitheNote"
	tithe_lbl.text = "The Tithe pays extra here for plasma, void essence, and dark matter."
	tithe_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tithe_lbl.add_theme_font_size_override("font_size", 12)
	tithe_lbl.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0))
	tithe_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tithe_lbl.visible = planet_name in ResourceManager.TITHE_PLANETS
	vbox.add_child(tithe_lbl)

	for resource in base_resources:
		var res_name = resource
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var icon = ResourceIcon.new(resource)
		row.add_child(icon)

		var name_lbl = Label.new()
		name_lbl.text = resource.capitalize()
		name_lbl.custom_minimum_size = Vector2(105, 0)
		name_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(name_lbl)

		var supply_lbl = Label.new()
		supply_lbl.name = "Supply"
		supply_lbl.custom_minimum_size = Vector2(62, 0)
		supply_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(supply_lbl)

		var stock_lbl = Label.new()
		stock_lbl.name = "Stock"
		stock_lbl.custom_minimum_size = Vector2(40, 0)
		stock_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(stock_lbl)

		var sell_btn = Button.new()
		sell_btn.name = "SellBtn"
		sell_btn.custom_minimum_size = Vector2(120, 26)
		sell_btn.add_theme_font_size_override("font_size", 12)
		sell_btn.pressed.connect(func(): _sell(res_name))
		row.add_child(sell_btn)

		vbox.add_child(row)
		_sell_rows[resource] = row

	# Premium sell rows
	for res in all_premium:
		var has_stock = ResourceManager.cargo.get(res, 0) > 0
		var has_sell_price = res in prices and prices[res][1] > 0
		if not has_stock and not has_sell_price:
			continue
		var res_name = res
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var icon = ResourceIcon.new(res)
		row.add_child(icon)

		var name_lbl = Label.new()
		name_lbl.text = res.capitalize().replace("_", " ")
		name_lbl.custom_minimum_size = Vector2(105, 0)
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		row.add_child(name_lbl)

		var supply_lbl = Label.new()
		supply_lbl.name = "Supply"
		supply_lbl.custom_minimum_size = Vector2(62, 0)
		supply_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(supply_lbl)

		var stock_lbl = Label.new()
		stock_lbl.name = "Stock"
		stock_lbl.custom_minimum_size = Vector2(40, 0)
		stock_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(stock_lbl)

		var sell_btn = Button.new()
		sell_btn.name = "SellBtn"
		sell_btn.custom_minimum_size = Vector2(120, 26)
		sell_btn.add_theme_font_size_override("font_size", 12)
		sell_btn.pressed.connect(func(): _sell(res_name))
		row.add_child(sell_btn)

		vbox.add_child(row)
		_sell_rows[res] = row

	# Contraband sell row
	if ResourceManager.cargo.has("contraband") and ResourceManager.cargo["contraband"] > 0:
		var c_row = HBoxContainer.new()
		c_row.add_theme_constant_override("separation", 6)

		var c_icon = ResourceIcon.new("contraband")
		c_row.add_child(c_icon)

		var c_label = Label.new()
		c_label.text = "Contraband"
		c_label.custom_minimum_size = Vector2(105, 0)
		c_label.add_theme_font_size_override("font_size", 13)
		c_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
		c_row.add_child(c_label)

		var c_stock = Label.new()
		c_stock.name = "Stock"
		c_stock.custom_minimum_size = Vector2(40, 0)
		c_stock.add_theme_font_size_override("font_size", 13)
		c_row.add_child(c_stock)

		var c_btn = Button.new()
		c_btn.name = "SellBtn"
		c_btn.custom_minimum_size = Vector2(120, 26)
		c_btn.add_theme_font_size_override("font_size", 12)
		c_btn.pressed.connect(func(): _sell_contraband())
		c_row.add_child(c_btn)

		vbox.add_child(c_row)
		_sell_rows["contraband"] = c_row

	var sp3 = Control.new()
	sp3.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(sp3)

	# ═══════════════════════════════════════════════════════════════════
	# UPGRADES SECTION
	# ═══════════════════════════════════════════════════════════════════
	vbox.add_child(_make_section_header("Upgrades", "upgrades"))

	for upgrade_name in ResourceManager.UPGRADE_COSTS.keys():
		var up_name = upgrade_name
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var icon = ResourceIcon.new(upgrade_name)
		row.add_child(icon)

		var btn = Button.new()
		btn.name = upgrade_name.capitalize() + "Btn"
		btn.custom_minimum_size = Vector2(220, 28)
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(func(): _upgrade(up_name))
		row.add_child(btn)

		vbox.add_child(row)

	var sp4 = Control.new()
	sp4.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(sp4)

	# ═══════════════════════════════════════════════════════════════════
	# WEAPONS SECTION
	# ═══════════════════════════════════════════════════════════════════
	vbox.add_child(_make_section_header("Weapons", "weapons"))

	for weapon_name in ResourceManager.WEAPON_DATA.keys():
		var wd = ResourceManager.WEAPON_DATA[weapon_name]
		if wd["cost"] <= 0 and weapon_name not in ResourceManager.owned_weapons:
			continue
		var wname = weapon_name
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var icon = ResourceIcon.new(weapon_name)
		row.add_child(icon)

		var label = Label.new()
		label.text = weapon_name.capitalize()
		label.custom_minimum_size = Vector2(80, 0)
		label.add_theme_font_size_override("font_size", 13)
		row.add_child(label)

		var btn = Button.new()
		btn.name = "ActionBtn"
		btn.custom_minimum_size = Vector2(140, 28)
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(func(): _weapon_action(wname))
		row.add_child(btn)

		vbox.add_child(row)
		_weapon_rows[weapon_name] = row

	var sp5 = Control.new()
	sp5.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(sp5)

	# ═══════════════════════════════════════════════════════════════════
	# ABILITIES SECTION
	# ═══════════════════════════════════════════════════════════════════
	vbox.add_child(_make_section_header("Abilities", "abilities"))

	for ability_name in ResourceManager.ABILITY_DATA.keys():
		var ad = ResourceManager.ABILITY_DATA[ability_name]
		if ad["cost"] <= 0:
			continue
		var aname = ability_name
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var icon = ResourceIcon.new(ability_name)
		row.add_child(icon)

		var btn = Button.new()
		btn.name = ability_name + "AbilityBtn"
		btn.custom_minimum_size = Vector2(220, 28)
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(func(): _buy_ability(aname))
		row.add_child(btn)

		vbox.add_child(row)

	var sp6 = Control.new()
	sp6.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(sp6)

	# ═══════════════════════════════════════════════════════════════════
	# LEAVE BUTTON
	# ═══════════════════════════════════════════════════════════════════
	var leave_btn = Button.new()
	leave_btn.text = "Leave Market"
	leave_btn.custom_minimum_size = Vector2(180, 34)
	leave_btn.add_theme_font_size_override("font_size", 14)
	leave_btn.pressed.connect(func(): closed.emit())
	vbox.add_child(leave_btn)

	_refresh_ui()

# ── Price helpers: one place each, so labels, buttons and trades always agree ──────────
func _buy_price_for(resource: String) -> int:
	var prices = ResourceManager.current_planet_prices
	var base_buy = prices[resource][0] if resource in prices else 0
	var p := ResourceManager.get_effective_price(ResourceManager.current_planet, resource, base_buy)
	if p <= 0:
		return 0
	var discount = ResourceManager.get_price_discount(ResourceManager.current_planet)
	var haggler: float = ResourceManager.get_tree_effect("buy_price_mult")  # Haggler skill, negative = cheaper
	return max(1, int(p * (1.0 - discount) * (1.0 + haggler)))

func _sell_price_for(resource: String) -> int:
	var prices = ResourceManager.current_planet_prices
	var base_sell = prices[resource][1] if resource in prices else 0
	var p := ResourceManager.get_effective_price(ResourceManager.current_planet, resource, base_sell, true)
	if p <= 0:
		return 0
	if ResourceManager.has_crew("trader"):
		p = int(p * 1.10)
	# Bartender's Charm — sell price bonus
	var sell_mult: float = 1.0 + ResourceManager.get_tree_effect("sell_price_mult")
	# Bulk Trader bonus
	var bulk_threshold: int = int(ResourceManager.get_tree_effect("bulk_sell_threshold"))
	if bulk_threshold > 0 and ResourceManager.cargo.get(resource, 0) >= bulk_threshold:
		sell_mult += ResourceManager.get_tree_effect("bulk_sell_bonus_mult")
	return int(float(p) * sell_mult)

## The cause line for whatever is running here, or "" when this planet's board is quiet.
func _current_market_news() -> String:
	var prices = ResourceManager.current_planet_prices
	for resource in prices:
		if int(prices[resource][0]) <= 0 and int(prices[resource][1]) <= 0:
			continue
		var ev := ResourceManager._event_for(ResourceManager.current_planet, resource)
		if not ev.is_empty():
			return String(ev.get("cause", ""))
	return ""

func _update_supply_label(row: Node, resource: String) -> void:
	for child in row.get_children():
		if child is Label and child.name == "Supply":
			var word := ResourceManager.supply_word(ResourceManager.current_planet, resource)
			child.text = word
			child.add_theme_color_override("font_color", Color(1.0, 0.35, 0.7) if word in ["SCARCE", "LOW"] else Color(0.3, 0.9, 1.0))

func _refresh_ui() -> void:
	# Update info label
	for child in _find_all_children(self):
		if child is Label and child.name == "InfoLabel":
			var rep_val = ResourceManager.get_reputation(ResourceManager.current_planet)
			var rep_rank = "Stranger"
			if rep_val >= 75:
				rep_rank = "Legend"
			elif rep_val >= 50:
				rep_rank = "Trusted"
			elif rep_val >= 25:
				rep_rank = "Known"
			elif rep_val >= 10:
				rep_rank = "Familiar"
			child.text = "Money: $%d  |  Cargo: %d/%d  |  Rep: %d (%s)" % [ResourceManager.money, ResourceManager.total_cargo(), ResourceManager.cargo_capacity, rep_val, rep_rank]
			break

	var prices = ResourceManager.current_planet_prices

	# Market news + Tithe note
	var news_text := _current_market_news()
	for child in _find_all_children(self):
		if child is Label and child.name == "MarketNews":
			child.text = ("MARKET NEWS: " + news_text) if news_text != "" else ""
			child.visible = news_text != ""
		elif child is Label and child.name == "TitheNote":
			child.visible = ResourceManager.current_planet in ResourceManager.TITHE_PLANETS

	# Refresh buy rows
	for resource in _buy_rows:
		var row = _buy_rows[resource]
		var buy_price = _buy_price_for(resource)
		_update_supply_label(row, resource)
		for child in row.get_children():
			if child is Label and child.name == "BuyPrice":
				child.text = "$%d ea" % buy_price
			if child is Button and child.name == "BuyBtn":
				child.text = "Buy (-$%d)" % buy_price
				child.disabled = ResourceManager.money < buy_price or not ResourceManager.can_carry()

	# Refresh sell rows
	for resource in _sell_rows:
		var row = _sell_rows[resource]
		# Contraband has its own pricing
		if resource == "contraband":
			var c_price = _get_contraband_price()
			var c_stock = ResourceManager.cargo.get("contraband", 0)
			for child in row.get_children():
				if child is Label and child.name == "Stock":
					child.text = "x%d" % c_stock
				if child is Button and child.name == "SellBtn":
					if c_price > 0 and c_stock > 0:
						child.text = "Sell (+$%d)" % c_price
						child.disabled = false
						child.modulate = Color(1, 1, 1, 1.0)
					elif c_price > 0:
						child.text = "Sell (+$%d)" % c_price
						child.disabled = true
						child.modulate = Color(1, 1, 1, 0.4)
					else:
						child.text = "Can't sell here"
						child.disabled = true
						child.modulate = Color(1, 1, 1, 0.4)
			continue
		var sell_price = _sell_price_for(resource)
		var stock = ResourceManager.cargo[resource]
		_update_supply_label(row, resource)
		for child in row.get_children():
			if child is Label and child.name == "Stock":
				child.text = "x%d" % stock
			if child is Button and child.name == "SellBtn":
				if sell_price > 0 and stock > 0:
					child.text = "Sell (+$%d)" % sell_price
					child.disabled = false
					child.modulate = Color(1, 1, 1, 1.0)
				elif sell_price > 0 and stock == 0:
					child.text = "Sell (+$%d)" % sell_price
					child.disabled = true
					child.modulate = Color(1, 1, 1, 0.4)
				else:
					child.text = "Can't sell here"
					child.disabled = true
					child.modulate = Color(1, 1, 1, 0.4)

	# Refresh upgrades
	for child in _find_all_children(self):
		if child is Button:
			for upgrade_name in ResourceManager.UPGRADE_COSTS.keys():
				if child.name == upgrade_name.capitalize() + "Btn":
					var level = ResourceManager.upgrade_levels[upgrade_name]
					var cost = ResourceManager.get_upgrade_cost(upgrade_name)
					if level >= 3:
						child.text = "%s: MAX" % upgrade_name.capitalize()
						child.disabled = true
					else:
						child.text = "%s Lv%d → Lv%d ($%d)" % [upgrade_name.capitalize(), level, level + 1, cost]
						child.disabled = ResourceManager.money < cost

	# Refresh weapons
	for weapon_name in _weapon_rows:
		var row = _weapon_rows[weapon_name]
		for child in row.get_children():
			if child is Button and child.name == "ActionBtn":
				var wd = ResourceManager.WEAPON_DATA[weapon_name]
				if weapon_name == ResourceManager.current_weapon:
					child.text = "Equipped"
					child.disabled = true
				elif weapon_name in ResourceManager.owned_weapons:
					child.text = "Equip"
					child.disabled = false
				else:
					child.text = "Buy ($%d)" % wd["cost"]
					child.disabled = ResourceManager.money < wd["cost"]

	# Refresh abilities
	for ability_name in ResourceManager.ABILITY_DATA.keys():
		var ad = ResourceManager.ABILITY_DATA[ability_name]
		if ad["cost"] <= 0:
			continue
		for child in _find_all_children(self):
			if child is Button and child.name == ability_name + "AbilityBtn":
				if ability_name in ResourceManager.owned_abilities:
					child.text = "%s: OWNED" % ability_name.capitalize().replace("_", " ")
					child.disabled = true
				else:
					child.text = "%s ($%d)" % [ability_name.capitalize().replace("_", " "), ad["cost"]]
					child.disabled = ResourceManager.money < ad["cost"]

func _find_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_find_all_children(child))
	return result

func _buy(resource: String) -> void:
	var buy_price = _buy_price_for(resource)
	if buy_price <= 0 or ResourceManager.money < buy_price:
		return
	if not ResourceManager.can_carry():
		return
	ResourceManager.spend_money(buy_price)
	ResourceManager.add_cargo(resource)
	ResourceManager.record_trade(ResourceManager.current_planet, resource, 1)
	# Buying out a shortage is hoarding, and the locals remember who did it.
	var ev := ResourceManager._event_for(ResourceManager.current_planet, resource)
	if not ev.is_empty() and ev["type"] == "shortage" and ResourceManager.get_stock(ResourceManager.current_planet, resource) < 0.1:
		ResourceManager.adjust_reputation(ResourceManager.current_planet, -3)
		ResourceManager.add_log("%s noticed you cornering the %s market during a shortage." % [ResourceManager.current_planet, resource], "event")
	else:
		ResourceManager.adjust_reputation(ResourceManager.current_planet, 2)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _sell(resource: String) -> void:
	var sell_price = _sell_price_for(resource)
	if sell_price == 0 or ResourceManager.cargo[resource] == 0:
		return
	ResourceManager.remove_cargo(resource)
	ResourceManager.add_money(sell_price)
	ResourceManager.record_trade(ResourceManager.current_planet, resource, -1)
	if not ResourceManager.story_flag("first_sale_logged"):
		ResourceManager.set_story_flags({"first_sale_logged": true})
		ResourceManager.add_log("Sold %s on %s. Money went up. I understand capitalism now." % [resource.capitalize(), ResourceManager.current_planet], "story")
	# Small XP for profitable trades
	@warning_ignore("integer_division")
	var trade_xp: int = clampi(sell_price / 20, 10, 30)
	ResourceManager.add_xp(trade_xp)
	# Selling into a shortage is relief, not gouging — the locals wanted the goods. Task 4 puts
	# the penalty where it belongs, on buying up a shortage.
	ResourceManager.adjust_reputation(ResourceManager.current_planet, 2)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _upgrade(upgrade_name: String) -> void:
	if ResourceManager.purchase_upgrade(upgrade_name):
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _buy_ability(ability_name: String) -> void:
	if ResourceManager.purchase_ability(ability_name):
		AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

func _weapon_action(weapon_name: String) -> void:
	if weapon_name in ResourceManager.owned_weapons:
		ResourceManager.equip_weapon(weapon_name)
	else:
		ResourceManager.purchase_weapon(weapon_name)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()

# --- Contraband ---
const CONTRABAND_PRICES: Dictionary = {
	"Mercury": 800,
	"Venus": 900,
	"Earth": 1500,
	"Mars": 1200,
	"Jupiter": 1000,
	"Saturn": 1100,
	"Uranus": 0,  # can't sell where you buy
	"Neptune": 850,
	"Pluto": 2000,  # highest contraband price in the system
}

func _get_contraband_price() -> int:
	return CONTRABAND_PRICES.get(ResourceManager.current_planet, 0)

func _sell_contraband() -> void:
	var price = _get_contraband_price()
	if price == 0 or ResourceManager.cargo.get("contraband", 0) == 0:
		return
	ResourceManager.cargo["contraband"] -= 1
	if ResourceManager.cargo["contraband"] <= 0:
		ResourceManager.cargo.erase("contraband")
	# Smuggler crew bonus
	if ResourceManager.has_crew("smuggler"):
		price = int(price * 1.25)
	ResourceManager.add_money(price)
	# Rep penalty — chance of getting caught (smuggler crew negates)
	if not ResourceManager.has_crew("smuggler"):
		ResourceManager.adjust_reputation(ResourceManager.current_planet, -15)
		# 30% chance of getting caught — heavy rep hit + fine
		if randf() < 0.3:
			var fine = int(price * 0.5)
			ResourceManager.spend_money(fine)
			ResourceManager.adjust_reputation(ResourceManager.current_planet, -25)
			ResourceManager.add_log("Caught selling contraband on %s. Fined $%d." % [ResourceManager.current_planet, fine], "event")
			# Show warning via HUD hint
			var hud_nodes = get_tree().get_nodes_in_group("hud")
			if hud_nodes.size() > 0 and hud_nodes[0].has_method("show_interact_hint"):
				hud_nodes[0].show_interact_hint("BUSTED! Contraband detected — fined $%d!" % fine)
	AudioManager.play_sfx("sfx_trade")
	_refresh_ui()
