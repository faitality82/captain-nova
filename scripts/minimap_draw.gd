extends Control

const MAP_RANGE: float = 5000.0
const MAP_SIZE: float = 150.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_SIZE, MAP_SIZE)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_SIZE, MAP_SIZE)), Color(0.3, 0.3, 0.3, 0.5), false, 1.0)

	var ship = get_tree().get_first_node_in_group("player")
	if ship == null:
		return

	var ship_pos = ship.global_position
	var range_mult = MAP_SIZE / (MAP_RANGE * 2.0)
	var center = Vector2(MAP_SIZE / 2.0, MAP_SIZE / 2.0)

	# Scout crew bonus
	var actual_range = MAP_RANGE
	if ResourceManager.has_crew("scout"):
		actual_range *= 1.3
	# Skill tree: Radar Sweep — minimap range bonus
	actual_range *= (1.0 + ResourceManager.get_tree_effect("minimap_range_mult"))
	range_mult = MAP_SIZE / (actual_range * 2.0)

	# Sun
	var sun = get_tree().get_first_node_in_group("sun") if true else null
	for node in get_tree().get_nodes_in_group("sun"):
		sun = node
		break
	if sun == null:
		# Try finding by name
		var world = get_tree().current_scene
		if world and world.has_node("Sun"):
			sun = world.get_node("Sun")
	if sun:
		var sun_offset = (sun.global_position - ship_pos) * range_mult + center
		if _in_bounds(sun_offset):
			draw_circle(sun_offset, 5.0, Color(1, 0.9, 0.2, 1))

	# Planets
	var planet_colors = {
		"Mercury": Color(0.7, 0.5, 0.3),
		"Venus": Color(0.9, 0.7, 0.2),
		"Earth": Color(0.2, 0.5, 1.0),
		"Mars": Color(0.8, 0.3, 0.1),
		"Jupiter": Color(0.8, 0.6, 0.3),
		"Saturn": Color(0.9, 0.8, 0.4),
		"Uranus": Color(0.4, 0.7, 0.8),
		"Neptune": Color(0.2, 0.3, 0.9),
	}
	for planet in get_tree().get_nodes_in_group("planet"):
		var offset = (planet.global_position - ship_pos) * range_mult + center
		if _in_bounds(offset):
			var color = planet_colors.get(planet.planet_name, Color(0.5, 0.5, 0.5))
			draw_circle(offset, 3.0, color)

	# Space stations
	for station in get_tree().get_nodes_in_group("station"):
		var offset = (station.global_position - ship_pos) * range_mult + center
		if _in_bounds(offset):
			draw_rect(Rect2(offset - Vector2(3, 3), Vector2(6, 6)), Color(0.3, 0.5, 1.0, 1))

	# Wormholes
	var wormhole_idx := 0
	var wormhole_colors := [Color(0.7, 0.4, 1.0, 1), Color(0.5, 0.3, 0.9, 1)]
	for wormhole in get_tree().get_nodes_in_group("wormhole"):
		var w_offset = (wormhole.global_position - ship_pos) * range_mult + center
		if _in_bounds(w_offset):
			var color: Color
			var s := 3.5
			if wormhole.is_endgame:
				# Golden wormhole — pulsing gold star, larger
				s = 5.0
				var pulse = 0.7 + sin(Time.get_ticks_msec() * 0.005) * 0.3
				color = Color(1.0, 0.9, 0.3, pulse)
				draw_arc(w_offset, s + 3.0, 0, TAU, 16, Color(1.0, 0.85, 0.2, pulse * 0.4), 1.5)
			else:
				@warning_ignore("integer_division")
				color = wormhole_colors[mini(wormhole_idx / 2, 1)]
			# Diamond shape
			var diamond := PackedVector2Array([
				w_offset + Vector2(0, -s),
				w_offset + Vector2(s, 0),
				w_offset + Vector2(0, s),
				w_offset + Vector2(-s, 0),
			])
			draw_polygon(diamond, PackedColorArray([color, color, color, color]))
		wormhole_idx += 1

	# Freighters (neutral — green dots)
	for freighter in get_tree().get_nodes_in_group("freighter"):
		var f_offset = (freighter.global_position - ship_pos) * range_mult + center
		if _in_bounds(f_offset):
			draw_circle(f_offset, 2.0, Color(0.2, 0.8, 0.3, 0.7))

	# Enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var offset = (enemy.global_position - ship_pos) * range_mult + center
		if _in_bounds(offset):
			if enemy.is_in_group("mothership"):
				var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.4
				draw_circle(offset, 5.0 * pulse, Color(0.2, 1.0, 0.3, 1))
			elif enemy.is_in_group("boss"):
				var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.3
				draw_circle(offset, 4.0 * pulse, Color(1, 0.1, 0.1, 1))
			elif enemy.is_in_group("bounty"):
				draw_circle(offset, 3.0, Color(1, 0.8, 0.1, 1))
			else:
				draw_circle(offset, 2.0, Color(1, 0.2, 0.2, 0.8))

	# Quest target planets — pulsing gold ring around target planet
	# Skip fetch quests (asteroid fields get their own marker instead)
	var fetch_planets: Array = []
	for npc_quest in ResourceManager.npc_active_quests:
		if npc_quest.get("type", "") == "fetch":
			var fp: String = npc_quest.get("target_planet", "")
			if fp != "":
				fetch_planets.append(fp)
	var quest_planets: Array = []
	for quest in ResourceManager.active_quests:
		var tp: String = quest.get("target_planet", "")
		if tp != "" and tp not in quest_planets:
			quest_planets.append(tp)
	for npc_quest in ResourceManager.npc_active_quests:
		var tp: String = npc_quest.get("target_planet", "")
		if tp != "" and tp not in quest_planets and tp not in fetch_planets:
			quest_planets.append(tp)
	if quest_planets.size() > 0:
		var pulse: float = 0.6 + sin(Time.get_ticks_msec() * 0.004) * 0.4
		var quest_ring_radius: float = 5000.0 * range_mult  # 5000 world px scaled to minimap
		for planet in get_tree().get_nodes_in_group("planet"):
			if planet.planet_name in quest_planets:
				var offset = (planet.global_position - ship_pos) * range_mult + center
				draw_arc(offset, quest_ring_radius, 0, TAU, 32, Color(1.0, 0.85, 0.3, pulse), 1.5)

	# Quest asteroid fields — pulsing orange pickaxe marker
	for field in get_tree().get_nodes_in_group("quest_field"):
		var f_offset = (field.global_position - ship_pos) * range_mult + center
		if _in_bounds(f_offset):
			var pulse = 0.6 + sin(Time.get_ticks_msec() * 0.005) * 0.4
			var col = Color(1.0, 0.6, 0.15, pulse)
			# Draw 3 small dots in a cluster
			draw_circle(f_offset + Vector2(-3, -2), 1.5, col)
			draw_circle(f_offset + Vector2(3, -1), 1.5, col)
			draw_circle(f_offset + Vector2(0, 3), 1.5, col)
			# Outer ring to make it visible
			draw_arc(f_offset, 6.0, 0, TAU, 12, Color(1.0, 0.6, 0.15, pulse * 0.6), 1.0)

	# Ship (center)
	draw_circle(center, 3.0, Color(1, 1, 1, 1))

	# Border label
	draw_string(ThemeDB.fallback_font, Vector2(2, MAP_SIZE - 4), "MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.5, 0.5, 0.5, 0.5))

func _in_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x <= MAP_SIZE and pos.y >= 0 and pos.y <= MAP_SIZE
