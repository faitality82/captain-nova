extends CanvasLayer

signal closed

const GRID_SCALE: float = 70.0
const SCREEN_CENTER: Vector2 = Vector2(640, 380)
const NODE_RADIUS: float = 28.0

var _selected_node: String = ""
var _node_buttons: Dictionary = {}  # node_id -> Button
var _lines_control: Control = null
var _info_panel: Panel = null
var _info_name: Label = null
var _info_desc: Label = null
var _info_cost: Label = null
var _info_resources: Label = null
var _info_status: Label = null
var _unlock_btn: Button = null
var _level_label: Label = null
var _sp_label: Label = null

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	get_tree().paused = true

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------
func _build_ui() -> void:
	# Dark overlay
	var overlay := ColorRect.new()
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0.02, 0.02, 0.06, 0.95)
	add_child(overlay)

	# Header
	var header := Label.new()
	header.text = "UPGRADE WEB"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.anchor_left = 0.0
	header.anchor_right = 1.0
	header.anchor_top = 0.0
	header.anchor_bottom = 0.0
	header.offset_top = 12
	header.offset_bottom = 42
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0))
	add_child(header)

	# Level + SP display (top-left)
	_level_label = Label.new()
	_level_label.anchor_left = 0.0
	_level_label.anchor_top = 0.0
	_level_label.offset_left = 16
	_level_label.offset_top = 14
	_level_label.add_theme_font_size_override("font_size", 14)
	_level_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	add_child(_level_label)

	_sp_label = Label.new()
	_sp_label.anchor_left = 0.0
	_sp_label.anchor_top = 0.0
	_sp_label.offset_left = 16
	_sp_label.offset_top = 34
	_sp_label.add_theme_font_size_override("font_size", 14)
	_sp_label.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0))
	add_child(_sp_label)

	# Connection lines layer
	_lines_control = Control.new()
	_lines_control.set_script(preload("res://scripts/skill_tree_lines.gd"))
	_lines_control.anchor_left = 0.0
	_lines_control.anchor_top = 0.0
	_lines_control.anchor_right = 1.0
	_lines_control.anchor_bottom = 1.0
	add_child(_lines_control)

	# Node buttons
	for node_id in SkillTreeData.NODES:
		var btn := Button.new()
		var pos: Vector2 = _node_screen_pos(node_id)
		btn.position = pos - Vector2(NODE_RADIUS, NODE_RADIUS)
		btn.custom_minimum_size = Vector2(NODE_RADIUS * 2, NODE_RADIUS * 2)
		btn.size = Vector2(NODE_RADIUS * 2, NODE_RADIUS * 2)
		btn.text = _abbreviate(SkillTreeData.NODES[node_id]["name"])
		btn.add_theme_font_size_override("font_size", 10)
		btn.clip_text = true
		var nid: String = node_id
		btn.pressed.connect(func(): _on_node_clicked(nid))
		add_child(btn)
		_node_buttons[node_id] = btn

	# Info panel (right side ~22% of screen)
	_info_panel = Panel.new()
	_info_panel.anchor_left = 0.0
	_info_panel.anchor_top = 0.0
	_info_panel.anchor_right = 0.0
	_info_panel.anchor_bottom = 0.0
	_info_panel.offset_left = 1280 * 0.78
	_info_panel.offset_top = 60
	_info_panel.offset_right = 1280 - 10
	_info_panel.offset_bottom = 620
	_info_panel.visible = false
	add_child(_info_panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 10
	vbox.offset_top = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10
	_info_panel.add_child(vbox)

	_info_name = Label.new()
	_info_name.add_theme_font_size_override("font_size", 18)
	_info_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_info_name)

	vbox.add_child(HSeparator.new())

	_info_desc = Label.new()
	_info_desc.add_theme_font_size_override("font_size", 13)
	_info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_info_desc)

	_info_cost = Label.new()
	_info_cost.add_theme_font_size_override("font_size", 13)
	_info_cost.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0))
	vbox.add_child(_info_cost)

	_info_resources = Label.new()
	_info_resources.add_theme_font_size_override("font_size", 12)
	_info_resources.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_info_resources)

	_info_status = Label.new()
	_info_status.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_info_status)

	_unlock_btn = Button.new()
	_unlock_btn.text = "UNLOCK"
	_unlock_btn.custom_minimum_size = Vector2(100, 36)
	_unlock_btn.pressed.connect(_on_unlock_pressed)
	vbox.add_child(_unlock_btn)

	# Close button (bottom-right)
	var close_btn := Button.new()
	close_btn.text = "Close [ESC]"
	close_btn.custom_minimum_size = Vector2(110, 36)
	close_btn.anchor_left = 1.0
	close_btn.anchor_top = 1.0
	close_btn.anchor_right = 1.0
	close_btn.anchor_bottom = 1.0
	close_btn.offset_left = -130
	close_btn.offset_top = -50
	close_btn.offset_right = -10
	close_btn.offset_bottom = -10
	close_btn.pressed.connect(func(): _close())
	add_child(close_btn)

	_refresh_all()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _node_screen_pos(node_id: String) -> Vector2:
	var grid_pos: Vector2 = SkillTreeData.NODE_POSITIONS.get(node_id, Vector2.ZERO)
	return SCREEN_CENTER + grid_pos * GRID_SCALE

func _abbreviate(full_name: String) -> String:
	var words: PackedStringArray = full_name.split(" ", false)
	if words.size() <= 1:
		return full_name.substr(0, 5)
	var abbr := ""
	for w in words:
		if w.length() > 0:
			abbr += w[0]
	return abbr.to_upper()

# ---------------------------------------------------------------------------
# State refresh
# ---------------------------------------------------------------------------
func _refresh_all() -> void:
	_level_label.text = "Level %d" % ResourceManager.level
	_sp_label.text = "SP: %d" % ResourceManager.skill_points

	var unlocked: Array = ResourceManager.unlocked_nodes
	for node_id in _node_buttons:
		var btn: Button = _node_buttons[node_id]
		var node: Dictionary = SkillTreeData.NODES[node_id]
		var cluster: String = node["cluster"]
		var cluster_color: Color = SkillTreeData.CLUSTER_COLORS.get(cluster, Color.WHITE)

		if unlocked.has(node_id):
			# Owned — bright cluster color
			_style_button(btn, cluster_color)
		elif SkillTreeData.can_unlock(node_id, unlocked, ResourceManager.skill_points, ResourceManager.cargo):
			# Unlockable — lighter/highlighted
			_style_button(btn, cluster_color.lightened(0.35))
		else:
			# Locked — dim gray
			_style_button(btn, Color(0.3, 0.3, 0.3, 0.6))

	_lines_control.refresh()

	if _selected_node != "":
		_update_info_panel(_selected_node)

func _style_button(btn: Button, color: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", sb)

	var hover_sb := StyleBoxFlat.new()
	hover_sb.bg_color = color.lightened(0.2)
	hover_sb.corner_radius_top_left = 6
	hover_sb.corner_radius_top_right = 6
	hover_sb.corner_radius_bottom_left = 6
	hover_sb.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("hover", hover_sb)

	var pressed_sb := StyleBoxFlat.new()
	pressed_sb.bg_color = color.darkened(0.15)
	pressed_sb.corner_radius_top_left = 6
	pressed_sb.corner_radius_top_right = 6
	pressed_sb.corner_radius_bottom_left = 6
	pressed_sb.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("pressed", pressed_sb)

	# Text color — dark text on bright bg, light text on dark bg
	var luma: float = color.r * 0.299 + color.g * 0.587 + color.b * 0.114
	var text_color := Color(0.0, 0.0, 0.0) if luma > 0.45 else Color(1.0, 1.0, 1.0)
	btn.add_theme_color_override("font_color", text_color)

# ---------------------------------------------------------------------------
# Info panel
# ---------------------------------------------------------------------------
func _on_node_clicked(node_id: String) -> void:
	_selected_node = node_id
	_info_panel.visible = true
	_update_info_panel(node_id)

func _update_info_panel(node_id: String) -> void:
	var node: Dictionary = SkillTreeData.NODES[node_id]
	var cluster: String = node["cluster"]
	var cluster_color: Color = SkillTreeData.CLUSTER_COLORS.get(cluster, Color.WHITE)
	var unlocked: Array = ResourceManager.unlocked_nodes

	_info_name.text = node["name"]
	_info_name.add_theme_color_override("font_color", cluster_color)

	_info_desc.text = node["effect_desc"]
	_info_desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))

	_info_cost.text = "Cost: %d SP" % node["cost_points"]

	# Resource costs
	var cost_res: Dictionary = node["cost_resources"]
	if cost_res.is_empty():
		_info_resources.text = ""
	else:
		var lines: PackedStringArray = PackedStringArray()
		for res_id in cost_res:
			var need: int = cost_res[res_id]
			var have: int = ResourceManager.cargo.get(res_id, 0)
			lines.append("%s: %d / %d" % [res_id.capitalize(), have, need])
		_info_resources.text = "\n".join(lines)
		var enough_all := true
		for res_id in cost_res:
			if ResourceManager.cargo.get(res_id, 0) < cost_res[res_id]:
				enough_all = false
				break
		_info_resources.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3) if enough_all else Color(1.0, 0.4, 0.3))

	# Status / unlock button
	if unlocked.has(node_id):
		_info_status.text = "UNLOCKED"
		_info_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		_unlock_btn.visible = false
	else:
		_info_status.text = ""
		_unlock_btn.visible = true
		var can: bool = SkillTreeData.can_unlock(node_id, unlocked, ResourceManager.skill_points, ResourceManager.cargo)
		_unlock_btn.disabled = not can

# ---------------------------------------------------------------------------
# Unlock
# ---------------------------------------------------------------------------
func _on_unlock_pressed() -> void:
	if _selected_node == "":
		return
	if ResourceManager.unlock_node(_selected_node):
		AudioManager.play_sfx("sfx_trade")
		_refresh_all()

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
func _close() -> void:
	get_tree().paused = false
	closed.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_K:
			_close()
			get_viewport().set_input_as_handled()
