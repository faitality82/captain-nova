extends Control

var _prestige_shop_open: bool = false
var _shop_layer: CanvasLayer = null

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx("sfx_win")
	AudioManager.play_voice("voice_win")
	# Player won — delete the in-progress save, keep prestige
	ResourceManager.delete_save()
	ResourceManager.save_prestige()

	var scene_path = "res://assets/scenes/scene_win.png"
	if ResourceLoader.exists(scene_path):
		var bg = TextureRect.new()
		bg.texture = load(scene_path)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.anchor_left = 0.0
		bg.anchor_top = 0.0
		bg.anchor_right = 1.0
		bg.anchor_bottom = 1.0
		bg.modulate = Color(1, 1, 1, 0.4)
		add_child(bg)
		move_child(bg, 1)

	$VBoxContainer/VictoryLabel.text = "YOU STRUCK IT RICH!"
	$VBoxContainer/StoryLabel.text = "%s made $%d and hit the big time!" % [
		ResourceManager.PILOT_NAME, ResourceManager.money
	]
	$VBoxContainer/TimeLabel.text = "From nothing to a fortune."
	$VBoxContainer/LivesLabel.text = "Lives remaining: %d" % ResourceManager.lives

	# Show prestige info
	var prestige_info = Label.new()
	prestige_info.text = "Prestige Level: %d | Tokens: %d" % [ResourceManager.prestige_level, ResourceManager.prestige_tokens]
	prestige_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prestige_info.add_theme_font_size_override("font_size", 16)
	prestige_info.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
	$VBoxContainer.add_child(prestige_info)

	# Prestige button
	var prestige_btn = Button.new()
	prestige_btn.text = "PRESTIGE (+1 Token, Restart Harder)"
	prestige_btn.custom_minimum_size = Vector2(300, 45)
	prestige_btn.pressed.connect(_on_prestige)
	$VBoxContainer.add_child(prestige_btn)

	# Prestige shop button
	if ResourceManager.prestige_tokens > 0:
		var shop_btn = Button.new()
		shop_btn.text = "Prestige Shop (%d tokens)" % ResourceManager.prestige_tokens
		shop_btn.custom_minimum_size = Vector2(300, 45)
		shop_btn.pressed.connect(_open_prestige_shop)
		$VBoxContainer.add_child(shop_btn)

	$VBoxContainer/PlayAgainButton.pressed.connect(func():
		AudioManager.stop_voice()
		ResourceManager.reset()
		get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
	)

func _on_prestige() -> void:
	ResourceManager.prestige_level += 1
	ResourceManager.prestige_tokens += 1
	AudioManager.play_sfx("sfx_trade")
	# Refresh the scene
	AudioManager.stop_voice()
	ResourceManager.reset()
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")

func _open_prestige_shop() -> void:
	if _prestige_shop_open:
		return
	_prestige_shop_open = true

	_shop_layer = CanvasLayer.new()
	_shop_layer.layer = 10
	add_child(_shop_layer)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250
	panel.offset_top = -200
	panel.offset_right = 250
	panel.offset_bottom = 200
	_shop_layer.add_child(panel)

	var scroll = ScrollContainer.new()
	scroll.anchor_left = 0.0
	scroll.anchor_top = 0.0
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 10
	scroll.offset_top = 10
	scroll.offset_right = -10
	scroll.offset_bottom = -10
	panel.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.name = "ShopVBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	var header = Label.new()
	header.text = "Prestige Shop"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	vbox.add_child(header)

	var tokens_label = Label.new()
	tokens_label.name = "TokensLabel"
	tokens_label.text = "Tokens: %d" % ResourceManager.prestige_tokens
	tokens_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tokens_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
	vbox.add_child(tokens_label)

	vbox.add_child(HSeparator.new())

	var bonuses = [
		["extra_money", "+$100 Starting Money (current: +$%d)" % (ResourceManager.prestige_bonuses["extra_money"] * 100)],
		["extra_cargo", "+1 Starting Cargo Slot (current: +%d)" % ResourceManager.prestige_bonuses["extra_cargo"]],
		["extra_crew_slots", "+1 Crew Slot (current: +%d, max +2)" % ResourceManager.prestige_bonuses["extra_crew_slots"]],
		["start_dash", "Start with Dash Ability"],
		["extra_fuel", "+10 Starting Max Fuel (current: +%d)" % (ResourceManager.prestige_bonuses["extra_fuel"] * 10)],
	]

	for bonus in bonuses:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 40)
		var bname = bonus[0]
		var bdesc = bonus[1]

		var is_maxed = false
		match bname:
			"extra_crew_slots":
				is_maxed = ResourceManager.prestige_bonuses["extra_crew_slots"] >= 2
			"start_dash":
				is_maxed = ResourceManager.prestige_bonuses["start_dash"]

		if is_maxed:
			btn.text = "%s (MAXED)" % bdesc
			btn.disabled = true
		else:
			btn.text = "%s (1 token)" % bdesc
			btn.disabled = ResourceManager.prestige_tokens <= 0

		var bonus_name = bname
		btn.pressed.connect(func():
			if ResourceManager.purchase_prestige_bonus(bonus_name):
				AudioManager.play_sfx("sfx_trade")
				_shop_layer.queue_free()
				_prestige_shop_open = false
				_open_prestige_shop()
		)
		vbox.add_child(btn)

	vbox.add_child(HSeparator.new())

	var close_btn = Button.new()
	close_btn.text = "Close Shop"
	close_btn.custom_minimum_size = Vector2(200, 40)
	close_btn.pressed.connect(func():
		_shop_layer.queue_free()
		_prestige_shop_open = false
	)
	vbox.add_child(close_btn)
