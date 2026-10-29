# tutorial_overlay.gd
# First-play controls tutorial. Shows once, then never again.
# Pauses the game, displays controls, dismisses on any key/click.
extends CanvasLayer

signal dismissed

func _ready() -> void:
	layer = 99
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	# Dark overlay
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.05, 0.85)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	# Title
	var title = Label.new()
	title.text = "CONTROLS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left = 0.0
	title.anchor_top = 0.05
	title.anchor_right = 1.0
	title.anchor_bottom = 0.12
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	add_child(title)

	# Controls grid - left column: space controls, right column: city controls
	var grid = _build_controls_display()
	add_child(grid)

	# Dismiss hint
	var dismiss = Label.new()
	dismiss.text = "Press any key to begin..."
	dismiss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dismiss.anchor_left = 0.0
	dismiss.anchor_top = 0.88
	dismiss.anchor_right = 1.0
	dismiss.anchor_bottom = 0.95
	dismiss.add_theme_font_size_override("font_size", 18)
	dismiss.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(dismiss)

	# Pulse the dismiss label
	var tween = create_tween().set_loops()
	tween.tween_property(dismiss, "modulate:a", 0.3, 1.0)
	tween.tween_property(dismiss, "modulate:a", 1.0, 1.0)

func _build_controls_display() -> Control:
	var container = Control.new()
	container.anchor_left = 0.05
	container.anchor_top = 0.14
	container.anchor_right = 0.95
	container.anchor_bottom = 0.86

	# Two columns
	var hbox = HBoxContainer.new()
	hbox.anchor_left = 0.0
	hbox.anchor_top = 0.0
	hbox.anchor_right = 1.0
	hbox.anchor_bottom = 1.0
	hbox.add_theme_constant_override("separation", 60)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(hbox)

	# Left column — Space
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	hbox.add_child(left)

	_add_section(left, "SPACE FLIGHT", Color(0.3, 0.7, 1.0))
	_add_control_row(left, "W / Up", "Thrust forward")
	_add_control_row(left, "S / Down", "Brake / Reverse")
	_add_control_row(left, "A / Left", "Rotate left")
	_add_control_row(left, "D / Right", "Rotate right")
	_add_control_row(left, "Space", "Shoot")
	_add_control_row(left, "1-5", "Switch weapon")
	_add_control_row(left, "E / Enter", "Land on planet / Dock")
	_add_control_row(left, "K", "Skill Tree")
	_add_spacer(left)
	_add_section(left, "ABILITIES", Color(0.8, 0.4, 1.0))
	_add_control_row(left, "Shift", "Dash (if owned)")
	_add_control_row(left, "Q", "Shield Bubble (if owned)")
	_add_control_row(left, "F", "EMP Blast (if owned)")

	# Right column — City & General
	var right = VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	hbox.add_child(right)

	_add_section(right, "ON PLANETS", Color(0.3, 1.0, 0.5))
	_add_control_row(right, "A / D", "Walk left / right")
	_add_control_row(right, "W / Space", "Jump")
	_add_control_row(right, "E", "Enter building")
	_add_control_row(right, "J", "Journal")
	_add_spacer(right)
	_add_section(right, "GENERAL", Color(1.0, 0.9, 0.3))
	_add_control_row(right, "ESC", "Pause menu")
	_add_control_row(right, "F11", "Toggle fullscreen")
	_add_spacer(right)
	_add_section(right, "TIPS", Color(1.0, 0.5, 0.3))
	_add_tip(right, "Buy resources cheap, sell them at planets where they're expensive.")
	_add_tip(right, "Watch your fuel! You burn fuel while thrusting.")
	_add_tip(right, "Outer planets are more dangerous but more profitable.")
	_add_tip(right, "Reach $100,000 to trigger the endgame.")

	return container

func _add_section(parent: VBoxContainer, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	parent.add_child(HSeparator.new())

func _add_control_row(parent: VBoxContainer, key: String, action: String) -> void:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)

	var key_label = Label.new()
	key_label.text = "[%s]" % key
	key_label.custom_minimum_size = Vector2(130, 0)
	key_label.add_theme_font_size_override("font_size", 15)
	key_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	hbox.add_child(key_label)

	var action_label = Label.new()
	action_label.text = action
	action_label.add_theme_font_size_override("font_size", 15)
	action_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	hbox.add_child(action_label)

	parent.add_child(hbox)

func _add_tip(parent: VBoxContainer, text: String) -> void:
	var label = Label.new()
	label.text = "  " + text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.75, 0.7, 0.65))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(label)

func _add_spacer(parent: VBoxContainer) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	parent.add_child(spacer)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_dismiss()
	elif event is InputEventMouseButton and event.pressed:
		_dismiss()

func _dismiss() -> void:
	ResourceManager.settings["tutorial_seen"] = true
	ResourceManager.save_settings()
	get_tree().paused = false
	dismissed.emit()
	queue_free()
