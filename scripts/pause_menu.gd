# pause_menu.gd
# ESC-toggled pause overlay. Works in both World and CityScene.
# Provides Resume, Settings, Save Game, and Quit to Title.
extends CanvasLayer

signal closed

var _settings_open: bool = false
var _settings_panel: Control = null

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Semi-transparent background
	var bg = ColorRect.new()
	bg.name = "PauseBG"
	bg.color = Color(0, 0, 0, 0.7)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	# Center container
	var vbox = VBoxContainer.new()
	vbox.name = "PauseVBox"
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -160
	vbox.offset_top = -160
	vbox.offset_right = 160
	vbox.offset_bottom = 160
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# Resume
	var resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.custom_minimum_size = Vector2(260, 45)
	resume_btn.pressed.connect(_on_resume)
	vbox.add_child(resume_btn)

	# Settings
	var settings_btn = Button.new()
	settings_btn.text = "Settings"
	settings_btn.custom_minimum_size = Vector2(260, 45)
	settings_btn.pressed.connect(_on_settings)
	vbox.add_child(settings_btn)

	# Save Game
	var save_btn = Button.new()
	save_btn.text = "Save Game"
	save_btn.custom_minimum_size = Vector2(260, 45)
	save_btn.pressed.connect(_on_save)
	vbox.add_child(save_btn)

	# Quit to Title
	var quit_btn = Button.new()
	quit_btn.text = "Quit to Title"
	quit_btn.custom_minimum_size = Vector2(260, 45)
	quit_btn.pressed.connect(_on_quit)
	vbox.add_child(quit_btn)

	# Save feedback label (hidden)
	var feedback = Label.new()
	feedback.name = "SaveFeedback"
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.add_theme_font_size_override("font_size", 14)
	feedback.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4, 1.0))
	feedback.text = ""
	vbox.add_child(feedback)

	# Controls hint at bottom
	var controls = Label.new()
	controls.text = "WASD/Arrows: Move  |  Space: Shoot  |  E: Interact\nQ: Shield  |  F: EMP  |  Shift: Dash  |  K: Skill Tree"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 11)
	controls.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	vbox.add_child(controls)

func _on_resume() -> void:
	_close()

func _on_settings() -> void:
	if _settings_open:
		return
	_settings_open = true
	_settings_panel = _create_settings_panel()
	add_child(_settings_panel)

func _on_save() -> void:
	# Sync ship state before saving
	var ship = _find_ship()
	if ship:
		ResourceManager.ship_hp = ship.hp
		ResourceManager.ship_position = ship.global_position
		ResourceManager.ship_facing = ship._facing_angle

	if ResourceManager.save_game():
		var feedback = _find_node_by_name("SaveFeedback")
		if feedback:
			feedback.text = "Game saved!"
			var tween = create_tween()
			tween.tween_property(feedback, "modulate:a", 0.0, 2.0).set_delay(1.0)
	else:
		var feedback = _find_node_by_name("SaveFeedback")
		if feedback:
			feedback.text = "Save failed!"

func _on_quit() -> void:
	ResourceManager.save_game()
	get_tree().paused = false
	ResourceManager.game_active = false
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")

func _close() -> void:
	get_tree().paused = false
	closed.emit()
	queue_free()

func _input(event: InputEvent) -> void:
	if _settings_open:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_close()

func _find_ship() -> Node:
	var ships = get_tree().get_nodes_in_group("player")
	if ships.size() > 0:
		return ships[0]
	# Fallback: look for Ship node
	var world = get_tree().current_scene
	if world and world.has_node("Ship"):
		return world.get_node("Ship")
	return null

func _find_node_by_name(n: String) -> Node:
	for child in get_children():
		var found = child.find_child(n, true, false)
		if found:
			return found
	return null

# --- Settings Panel ---
func _create_settings_panel() -> Control:
	var panel = Panel.new()
	panel.name = "SettingsPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -180
	panel.offset_right = 200
	panel.offset_bottom = 180

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 15
	vbox.offset_top = 15
	vbox.offset_right = -15
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var header = Label.new()
	header.text = "SETTINGS"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	vbox.add_child(header)

	# Master Volume
	_add_slider(vbox, "Master Volume", "master_volume")
	# Music Volume
	_add_slider(vbox, "Music Volume", "music_volume")
	# SFX Volume
	_add_slider(vbox, "SFX Volume", "sfx_volume")

	vbox.add_child(HSeparator.new())

	# Fullscreen toggle
	var fs_box = HBoxContainer.new()
	var fs_label = Label.new()
	fs_label.text = "Fullscreen"
	fs_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs_box.add_child(fs_label)
	var fs_check = CheckButton.new()
	fs_check.button_pressed = ResourceManager.settings["fullscreen"]
	fs_check.toggled.connect(func(on: bool):
		ResourceManager.settings["fullscreen"] = on
		ResourceManager._apply_settings()
		ResourceManager.save_settings()
	)
	fs_box.add_child(fs_check)
	vbox.add_child(fs_box)

	vbox.add_child(HSeparator.new())

	# Close button
	var close_btn = Button.new()
	close_btn.text = "Back"
	close_btn.custom_minimum_size = Vector2(120, 40)
	close_btn.pressed.connect(func():
		ResourceManager.save_settings()
		panel.queue_free()
		_settings_open = false
	)
	vbox.add_child(close_btn)

	return panel

func _add_slider(parent: Control, label_text: String, setting_key: String) -> void:
	var hbox = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(120, 0)
	hbox.add_child(label)

	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = ResourceManager.settings[setting_key]
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(150, 0)
	slider.value_changed.connect(func(val: float):
		ResourceManager.settings[setting_key] = val
		_apply_volume_setting(setting_key, val)
	)
	hbox.add_child(slider)

	var val_label = Label.new()
	val_label.text = "%d%%" % int(ResourceManager.settings[setting_key] * 100)
	val_label.custom_minimum_size = Vector2(45, 0)
	slider.value_changed.connect(func(val: float):
		val_label.text = "%d%%" % int(val * 100)
	)
	hbox.add_child(val_label)

	parent.add_child(hbox)

func _apply_volume_setting(key: String, val: float) -> void:
	match key:
		"master_volume":
			AudioServer.set_bus_volume_db(0, linear_to_db(val))
		"music_volume":
			# Apply to AudioManager's music player directly
			if AudioManager._music_player:
				AudioManager._music_player.volume_db = linear_to_db(val) - 6.0
		"sfx_volume":
			# Apply to all SFX players
			for player in AudioManager._sfx_players:
				player.volume_db = linear_to_db(val)
