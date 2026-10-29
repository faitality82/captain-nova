extends Control

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx("sfx_gameover")
	AudioManager.play_voice("voice_death")
	# Game over — delete in-progress save, keep prestige
	ResourceManager.delete_save()
	ResourceManager.save_prestige()

	# Replace opaque ColorRect with scene background image
	var scene_path = "res://assets/scenes/scene_death.png"
	if ResourceLoader.exists(scene_path):
		$ColorRect.color = Color(0, 0, 0, 1)  # black base
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
		move_child(bg, 1)  # after ColorRect, before VBoxContainer

	$VBoxContainer/GameOverLabel.text = "SHIP DESTROYED"
	$VBoxContainer/StoryLabel.text = "%s's ship was destroyed beyond repair.\nThe dream of striking it rich dies here..." % [
		ResourceManager.PILOT_NAME
	]
	$VBoxContainer/ScoreLabel.text = "Fortune collected: $%d / $%d" % [ResourceManager.money, ResourceManager.WIN_TARGET]

	# Play death music after voice line finishes
	_wait_for_voice_then_play_music()

	$VBoxContainer/RetryButton.pressed.connect(func():
		AudioManager.stop_voice()
		AudioManager.stop_music()
		ResourceManager.reset()
		get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
	)

func _wait_for_voice_then_play_music() -> void:
	while AudioManager.is_voice_playing():
		await get_tree().create_timer(0.2).timeout
	AudioManager.play_music("music_death")
