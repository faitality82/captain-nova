extends CanvasLayer

@onready var hp_bar: ProgressBar = $HPBar
@onready var points_label: Label = $PointsLabel
@onready var cargo_label: Label = $CargoLabel
@onready var interact_hint: Label = $InteractHint
@onready var planet_indicators: Control = $PlanetIndicators
@onready var goal_label: Label = $GoalLabel

var _boss_bar: ProgressBar = null
var _boss_label: Label = null
var _fuel_bar: ProgressBar = null
var _fuel_label: Label = null
var _ability_labels: Dictionary = {}  # ability_name -> Label
var _minimap: Control = null
var _minimap_visible: bool = true
var _xp_bar: ProgressBar = null
var _xp_label: Label = null
var _level_label: Label = null
var _skill_point_label: Label = null
var _level_up_label: Label = null
var _level_up_timer: float = 0.0
var _weapon_label: Label = null
var _pulse_line: Control = null
const MINIMAP_SIZE: float = 150.0
const MINIMAP_RANGE: float = 5000.0

func _ready() -> void:
	add_to_group("hud")
	process_mode = Node.PROCESS_MODE_ALWAYS
	interact_hint.visible = false
	update_hp(ResourceManager.ship_max_hp, ResourceManager.ship_max_hp)
	_create_boss_hp_bar()
	_create_fuel_bar()
	_create_ability_display()
	_create_minimap()
	_create_pulse_line()
	_create_xp_display()
	_create_weapon_display()
	ResourceManager.level_up.connect(_on_level_up)

func _process(delta: float) -> void:
	points_label.text = "$%d  Lives: %d" % [ResourceManager.money, ResourceManager.lives]
	goal_label.text = "Goal: $%d / $%d" % [ResourceManager.money, ResourceManager.WIN_TARGET]
	_update_cargo()
	_update_planet_indicators()
	_update_fuel()
	_update_abilities()
	_update_weapon_display()
	_update_quests()
	_update_xp_display()
	if _level_up_timer > 0.0:
		_level_up_timer -= delta
		_level_up_label.modulate.a = clampf(_level_up_timer / 1.5, 0.0, 1.0)
		if _level_up_timer <= 0.0:
			_level_up_label.visible = false

func update_hp(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func _update_cargo() -> void:
	var c = ResourceManager.cargo
	var cap = ResourceManager.cargo_capacity
	var used = ResourceManager.total_cargo()
	var items = ""
	for key in c:
		if c[key] > 0:
			items += " %s:%d" % [key.capitalize(), c[key]]
	if items == "":
		items = " Empty"
	cargo_label.text = "Cargo [%d/%d]%s" % [used, cap, items]

func _update_fuel() -> void:
	if _fuel_bar:
		_fuel_bar.max_value = ResourceManager.ship_max_fuel
		_fuel_bar.value = ResourceManager.ship_fuel
		# Color shift: green → yellow → red
		var pct = ResourceManager.ship_fuel / ResourceManager.ship_max_fuel
		if pct < 0.2:
			_fuel_bar.modulate = Color(1, 0.2, 0.2, 1)
		elif pct < 0.5:
			_fuel_bar.modulate = Color(1, 0.8, 0.2, 1)
		else:
			_fuel_bar.modulate = Color(0.3, 0.9, 0.4, 1)
	if _fuel_label:
		_fuel_label.text = "FUEL: %d%%" % int((ResourceManager.ship_fuel / ResourceManager.ship_max_fuel) * 100)

func show_interact_hint(text: String) -> void:
	interact_hint.text = text
	interact_hint.visible = true

func hide_interact_hint() -> void:
	interact_hint.visible = false

func _update_planet_indicators() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null:
		return

	var planets = get_tree().get_nodes_in_group("planet")
	# Ensure we have the right number of indicator labels
	while planet_indicators.get_child_count() < planets.size():
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 14)
		planet_indicators.add_child(label)
	while planet_indicators.get_child_count() > planets.size():
		planet_indicators.get_child(planet_indicators.get_child_count() - 1).queue_free()

	for i in range(planets.size()):
		var planet = planets[i]
		var label: Label = planet_indicators.get_child(i)
		var dir = planet.global_position - ship.global_position
		var dist = dir.length()

		# Arrow character based on direction
		var angle = dir.angle()
		var arrow = _angle_to_arrow(angle)

		# Check if this planet is a quest target
		var is_quest_target: bool = _is_quest_planet(planet.planet_name)
		var quest_marker: String = " [!]" if is_quest_target else ""
		label.text = "%s %s %dm%s" % [arrow, planet.planet_name, int(dist / 10), quest_marker]

		# Navigator crew perk: show the best sell price we last saw at this planet
		if ResourceManager.has_crew("navigator") and planet.planet_name in ResourceManager.price_memory:
			var best_res: String = ""
			var best_price: int = 0
			for res in ResourceManager.price_memory[planet.planet_name]:
				var sell_price: int = int(ResourceManager.price_memory[planet.planet_name][res][1])
				if sell_price > best_price:
					best_price = sell_price
					best_res = res
			if best_price > 0:
				label.text += "  best: %s $%d" % [best_res.capitalize(), best_price]

		label.position = Vector2(10, 110 + i * 22)

		# Dim the indicator when close (already at the planet)
		if dist < 100:
			label.modulate = Color(0.5, 0.5, 0.5, 0.5)
		elif is_quest_target:
			label.modulate = Color(1.0, 0.85, 0.3, 1.0)
		else:
			label.modulate = Color(1, 1, 1, 0.8)

	# Golden wormhole indicator (if it exists)
	var golden_wormholes = get_tree().get_nodes_in_group("wormhole").filter(func(w): return w.is_endgame)
	if golden_wormholes.size() > 0:
		var gw = golden_wormholes[0]
		var gw_dir = gw.global_position - ship.global_position
		var gw_dist = gw_dir.length()
		var gw_arrow = _angle_to_arrow(gw_dir.angle())
		# Use one more label slot after planets
		var idx = planets.size()
		while planet_indicators.get_child_count() <= idx:
			var extra = Label.new()
			extra.add_theme_font_size_override("font_size", 14)
			planet_indicators.add_child(extra)
		var gw_label: Label = planet_indicators.get_child(idx)
		var pulse_a = 0.7 + sin(Time.get_ticks_msec() * 0.004) * 0.3
		gw_label.text = "%s THE GOLDEN RIFT %dm" % [gw_arrow, int(gw_dist / 10)]
		gw_label.position = Vector2(10, 110 + idx * 22)
		gw_label.modulate = Color(1.0, 0.9, 0.3, pulse_a)

func _is_quest_planet(planet_name: String) -> bool:
	for quest in ResourceManager.active_quests:
		if quest.get("target_planet", "") == planet_name:
			return true
	for npc_quest in ResourceManager.npc_active_quests:
		if npc_quest.get("target_planet", "") == planet_name:
			return true
	return false

# ── Fuel bar (created dynamically) ────────────

func _create_fuel_bar() -> void:
	_fuel_label = Label.new()
	_fuel_label.add_theme_font_size_override("font_size", 12)
	_fuel_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4, 1))
	_fuel_label.anchors_preset = Control.PRESET_TOP_LEFT
	_fuel_label.offset_left = 10.0
	_fuel_label.offset_top = 48.0
	_fuel_label.offset_right = 160.0
	_fuel_label.offset_bottom = 62.0
	add_child(_fuel_label)

	_fuel_bar = ProgressBar.new()
	_fuel_bar.anchors_preset = Control.PRESET_TOP_LEFT
	_fuel_bar.offset_left = 10.0
	_fuel_bar.offset_top = 62.0
	_fuel_bar.offset_right = 160.0
	_fuel_bar.offset_bottom = 74.0
	_fuel_bar.show_percentage = false
	_fuel_bar.modulate = Color(0.3, 0.9, 0.4, 1)
	add_child(_fuel_bar)

# ── XP display (created dynamically) ─────────────

func _create_xp_display() -> void:
	# Level label (left side, below fuel bar)
	_level_label = Label.new()
	_level_label.add_theme_font_size_override("font_size", 14)
	_level_label.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0, 1.0))
	_level_label.anchors_preset = Control.PRESET_TOP_LEFT
	_level_label.offset_left = 10.0
	_level_label.offset_top = 78.0
	_level_label.offset_right = 75.0
	_level_label.offset_bottom = 94.0
	add_child(_level_label)

	# XP progress bar (right of level label)
	_xp_bar = ProgressBar.new()
	_xp_bar.anchors_preset = Control.PRESET_TOP_LEFT
	_xp_bar.offset_left = 80.0
	_xp_bar.offset_top = 80.0
	_xp_bar.offset_right = 200.0
	_xp_bar.offset_bottom = 90.0
	_xp_bar.show_percentage = false
	_xp_bar.modulate = Color(0.7, 0.5, 1.0, 1.0)
	add_child(_xp_bar)

	# XP text label (below XP bar)
	_xp_label = Label.new()
	_xp_label.add_theme_font_size_override("font_size", 10)
	_xp_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.9, 0.8))
	_xp_label.anchors_preset = Control.PRESET_TOP_LEFT
	_xp_label.offset_left = 80.0
	_xp_label.offset_top = 91.0
	_xp_label.offset_right = 200.0
	_xp_label.offset_bottom = 104.0
	add_child(_xp_label)

	# Skill point notification (right of XP area)
	_skill_point_label = Label.new()
	_skill_point_label.add_theme_font_size_override("font_size", 12)
	_skill_point_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	_skill_point_label.anchors_preset = Control.PRESET_TOP_LEFT
	_skill_point_label.offset_left = 205.0
	_skill_point_label.offset_top = 80.0
	_skill_point_label.offset_right = 290.0
	_skill_point_label.offset_bottom = 96.0
	_skill_point_label.visible = false
	add_child(_skill_point_label)

	# Level-up flash label (center-top of screen)
	_level_up_label = Label.new()
	_level_up_label.add_theme_font_size_override("font_size", 32)
	_level_up_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_up_label.anchors_preset = Control.PRESET_CENTER_TOP
	_level_up_label.anchor_left = 0.5
	_level_up_label.anchor_right = 0.5
	_level_up_label.offset_left = -250.0
	_level_up_label.offset_right = 250.0
	_level_up_label.offset_top = 120.0
	_level_up_label.offset_bottom = 160.0
	_level_up_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_level_up_label.visible = false
	add_child(_level_up_label)

func _update_xp_display() -> void:
	if _level_label:
		_level_label.text = "Lv %d" % ResourceManager.level
	if _xp_bar:
		var needed: int = ResourceManager.xp_for_level(ResourceManager.level)
		_xp_bar.max_value = needed
		_xp_bar.value = ResourceManager.xp
	if _xp_label:
		var needed: int = ResourceManager.xp_for_level(ResourceManager.level)
		_xp_label.text = "%d / %d XP" % [ResourceManager.xp, needed]
	if _skill_point_label:
		if ResourceManager.skill_points > 0:
			_skill_point_label.text = "SP: %d" % ResourceManager.skill_points
			_skill_point_label.visible = true
		else:
			_skill_point_label.visible = false

func _on_level_up(new_level: int) -> void:
	AudioManager.play_sfx("sfx_pickup", 2.0)
	_level_up_label.visible = true
	if new_level % ResourceManager.SKILL_POINT_INTERVAL == 0:
		_level_up_label.text = "LEVEL %d — SKILL POINT!" % new_level
		_level_up_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		_level_up_label.text = "LEVEL %d" % new_level
		_level_up_label.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0))
	_level_up_timer = 2.0
	_level_up_label.modulate.a = 1.0

# ── Ability display (created dynamically) ───────

func _create_weapon_display() -> void:
	_weapon_label = Label.new()
	_weapon_label.add_theme_font_size_override("font_size", 13)
	_weapon_label.anchor_left = 0.0
	_weapon_label.anchor_right = 0.0
	_weapon_label.anchor_top = 1.0
	_weapon_label.anchor_bottom = 1.0
	_weapon_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_weapon_label.offset_left = 10.0
	_weapon_label.offset_right = 300.0
	_weapon_label.offset_top = -28.0
	_weapon_label.offset_bottom = -8.0
	add_child(_weapon_label)

func _update_weapon_display() -> void:
	var weapons = ResourceManager.owned_weapons
	if weapons.size() <= 1:
		_weapon_label.text = ""
		return
	var parts: Array = []
	for i in range(weapons.size()):
		var w = weapons[i].capitalize()
		if weapons[i] == ResourceManager.current_weapon:
			parts.append("[%d] >%s<" % [i + 1, w])
		else:
			parts.append("[%d] %s" % [i + 1, w])
	_weapon_label.text = "  ".join(parts)
	_weapon_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.6))

func _create_ability_display() -> void:
	var abilities = ["dash", "shield_bubble", "emp_blast"]
	var keys = {"dash": "Shift", "shield_bubble": "Q", "emp_blast": "F"}
	var names = {"dash": "DASH", "shield_bubble": "SHIELD", "emp_blast": "EMP"}
	for i in range(abilities.size()):
		var ability = abilities[i]
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 12)
		label.anchors_preset = Control.PRESET_BOTTOM_RIGHT
		label.anchor_left = 1.0
		label.anchor_right = 1.0
		label.anchor_top = 1.0
		label.anchor_bottom = 1.0
		label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		label.grow_vertical = Control.GROW_DIRECTION_BEGIN
		label.offset_left = -120.0
		label.offset_right = -10.0
		label.offset_top = -30.0 - i * 22.0
		label.offset_bottom = -10.0 - i * 22.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.text = "[%s] %s" % [keys[ability], names[ability]]
		label.visible = false
		add_child(label)
		_ability_labels[ability] = label

func _update_abilities() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null:
		return
	var cooldowns = ship.get_ability_cooldowns() if ship.has_method("get_ability_cooldowns") else {}
	var keys = {"dash": "Shift", "shield_bubble": "Q", "emp_blast": "F"}
	var names = {"dash": "DASH", "shield_bubble": "SHIELD", "emp_blast": "EMP"}
	for ability in _ability_labels:
		var label = _ability_labels[ability]
		if ability in ResourceManager.owned_abilities:
			label.visible = true
			var cd = cooldowns.get(ability, 0.0)
			if cd > 0:
				label.text = "[%s] %s (%.1fs)" % [keys[ability], names[ability], cd]
				label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.7))
			else:
				label.text = "[%s] %s READY" % [keys[ability], names[ability]]
				label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
		else:
			label.visible = false

# ── Boss HP bar (created dynamically) ──────────

func _create_boss_hp_bar() -> void:
	# Boss name label — centered at top
	_boss_label = Label.new()
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_label.add_theme_font_size_override("font_size", 18)
	_boss_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	_boss_label.anchors_preset = Control.PRESET_CENTER_TOP
	_boss_label.anchor_left = 0.5
	_boss_label.anchor_right = 0.5
	_boss_label.offset_left = -150.0
	_boss_label.offset_right = 150.0
	_boss_label.offset_top = 55.0
	_boss_label.offset_bottom = 75.0
	_boss_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_boss_label.visible = false
	add_child(_boss_label)

	# Boss HP progress bar
	_boss_bar = ProgressBar.new()
	_boss_bar.anchors_preset = Control.PRESET_CENTER_TOP
	_boss_bar.anchor_left = 0.5
	_boss_bar.anchor_right = 0.5
	_boss_bar.offset_left = -150.0
	_boss_bar.offset_right = 150.0
	_boss_bar.offset_top = 78.0
	_boss_bar.offset_bottom = 92.0
	_boss_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_boss_bar.show_percentage = false
	# Red tint via modulate
	_boss_bar.modulate = Color(1, 0.3, 0.3, 1)
	_boss_bar.visible = false
	add_child(_boss_bar)

func show_boss_hp(current: int, maximum: int, tier: int) -> void:
	var boss_names = {0: "ALIEN MOTHERSHIPS", 1: "TITHE DESTROYER", 2: "TITHE DREADNOUGHT", 3: "TITHE OVERLORD", 4: "BIG FRANK"}
	_boss_label.text = ">> %s <<" % boss_names.get(tier, "BOSS")
	_boss_label.visible = true
	_boss_bar.max_value = maximum
	_boss_bar.value = current
	_boss_bar.visible = true

func update_boss_hp(current: int, maximum: int) -> void:
	if _boss_bar:
		_boss_bar.max_value = maximum
		_boss_bar.value = current

func hide_boss_hp() -> void:
	if _boss_bar:
		_boss_bar.visible = false
	if _boss_label:
		_boss_label.visible = false

# ── Minimap ───────────────────────────────────

func _create_minimap() -> void:
	_minimap = Control.new()
	_minimap.name = "Minimap"
	_minimap.anchor_left = 1.0
	_minimap.anchor_top = 0.0
	_minimap.anchor_right = 1.0
	_minimap.anchor_bottom = 0.0
	_minimap.offset_left = -(MINIMAP_SIZE + 10)
	_minimap.offset_top = 10
	_minimap.offset_right = -10
	_minimap.offset_bottom = MINIMAP_SIZE + 10
	_minimap.set_script(load("res://scripts/minimap_draw.gd"))
	add_child(_minimap)

# ── Signal Decoder pulse line ──────────────────

func _create_pulse_line() -> void:
	_pulse_line = Control.new()
	_pulse_line.name = "PulseLine"
	_pulse_line.anchor_left = 1.0
	_pulse_line.anchor_right = 1.0
	_pulse_line.anchor_top = 0.0
	_pulse_line.anchor_bottom = 0.0
	_pulse_line.offset_left = -(MINIMAP_SIZE + 10)
	_pulse_line.offset_top = MINIMAP_SIZE + 14
	_pulse_line.offset_right = -10
	_pulse_line.offset_bottom = MINIMAP_SIZE + 44
	_pulse_line.set_script(load("res://scripts/pulse_line.gd"))
	add_child(_pulse_line)

func _input_minimap(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		_minimap_visible = not _minimap_visible
		if _minimap:
			_minimap.visible = _minimap_visible
		if _pulse_line:
			_pulse_line.enabled = _minimap_visible

func _unhandled_input(event: InputEvent) -> void:
	_input_minimap(event)

func _update_quests() -> void:
	var quest_text = ""
	for quest in ResourceManager.active_quests:
		match quest["type"]:
			"deliver":
				var have = ResourceManager.cargo.get(quest["resource"], 0)
				quest_text += "%s (%d/%d) $%d\n" % [quest["desc"], have, quest["amount"], quest["reward"]]
			"kill":
				quest_text += "%s (%d/%d) $%d\n" % [quest["desc"], quest["kills"], quest["kill_target"], quest["reward"]]
			"chain":
				var step = quest.get("step", 0)
				quest_text += "%s (step %d) $%d\n" % [quest["desc"], step + 1, quest["reward"]]
	# NPC quests
	for npc_quest in ResourceManager.npc_active_quests:
		var npc_type = npc_quest.get("type", "")
		match npc_type:
			"fetch":
				var have = ResourceManager.cargo.get(npc_quest.get("target", ""), 0)
				quest_text += "[NPC] %s (%d/%d)\n" % [npc_quest.get("desc", ""), have, npc_quest.get("amount", 0)]
			"kill":
				quest_text += "[NPC] %s (%d/%d)\n" % [npc_quest.get("desc", ""), npc_quest.get("progress", 0), npc_quest.get("amount", 0)]
			"deliver":
				quest_text += "[NPC] %s\n" % npc_quest.get("desc", "")
	if quest_text != "":
		if not has_node("QuestLabel"):
			var ql = Label.new()
			ql.name = "QuestLabel"
			ql.add_theme_font_size_override("font_size", 11)
			ql.add_theme_color_override("font_color", Color(0.8, 0.8, 1, 0.8))
			ql.anchors_preset = Control.PRESET_BOTTOM_LEFT
			ql.anchor_top = 1.0
			ql.anchor_bottom = 1.0
			ql.offset_left = 10
			ql.offset_top = -80
			ql.offset_right = 350
			ql.offset_bottom = -10
			ql.grow_vertical = Control.GROW_DIRECTION_BEGIN
			add_child(ql)
		get_node("QuestLabel").text = quest_text
	elif has_node("QuestLabel"):
		get_node("QuestLabel").text = ""

func _angle_to_arrow(angle: float) -> String:
	# 8-directional arrow from angle in radians
	var deg = fmod(rad_to_deg(angle) + 360.0, 360.0)
	if deg < 22.5 or deg >= 337.5:
		return ">"
	elif deg < 67.5:
		return "v>"
	elif deg < 112.5:
		return "v"
	elif deg < 157.5:
		return "<v"
	elif deg < 202.5:
		return "<"
	elif deg < 247.5:
		return "<^"
	elif deg < 292.5:
		return "^"
	else:
		return "^>"
