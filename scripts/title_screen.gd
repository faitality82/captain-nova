extends Control

var _story_lines: Array = [
	"[CAPTAIN'S LOG. ENTRY ZERO.]",
	"Closing time at The Low Orbit. Five years behind that bar. I can recite every regular's order and not one thing I've done that scared me.",
	"Tuesday, I woke up and decided that was unacceptable.",
	"Cashed out. Bought the cheapest ship on the docks. The listing said 'flight-capable (mostly).' The 'mostly' was accurate.",
	"Margaux was in her usual seat when I left. Twelve crew, one captain came back, she told me a hundred times. I never once told her to stop. I think that's why I'm doing this.",
	"Mom called. Asked if I was eating. I said yes. I was holding a ration bar, so technically.",
	"Two hundred credits. Nine planets. A hundred thousand is the number. Not because I need it. Because I need to know I can.",
	"Buy low. Sell high. Do not fly into the sun. Dex on the radio says the green light past Pluto is real. Dex says a lot of things.",
	"Undocking. Backwards, as it turns out.",
	"[END ENTRY ZERO]",
]

var _story_index: int = -1
var _in_story: bool = false
var _scene_image: TextureRect = null

# Intro slideshow — timed to music_intro
var _slideshow_active: bool = false
var _slideshow_timer: float = 0.0
var _slideshow_index: int = -1
var _slide_image: TextureRect = null

# Slide timings in seconds — when each slide should appear
# Adjust these to match your actual song timing
const SLIDE_TIMINGS: Array = [
	0.0,   # slide 01 — title card
	5.0,   # slide 02 — cockpit
	10.0,  # slide 03 — spaghetti monster chase
	15.0,  # slide 04 — trading life
	20.0,  # slide 05 — making bank
	25.0,  # slide 06 — SPACE TRADER hero shot
	30.0,  # slide 07 — Gus the fuel guy
	35.0,  # slide 08 — wormhole jump
	40.0,  # slide 09 — the motherships
	45.0,  # slide 10 — railgun ready
	50.0,  # slide 11 — chaos montage
	55.0,  # slide 12 — the outro / oops
]

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var story_panel: Panel = $StoryPanel
@onready var story_label: Label = $StoryPanel/StoryLabel
@onready var continue_label: Label = $StoryPanel/ContinueLabel
@onready var pilot_label: Label = $StoryPanel/PilotLabel

var _continue_button: Button = null
var _settings_button: Button = null

func _ready() -> void:
	ResourceManager.reset()
	story_panel.visible = false
	start_button.pressed.connect(_on_start)
	AudioManager.play_music("music_intro")
	_start_slideshow()

	# Add Continue Game button if save exists
	if ResourceManager.has_save():
		_continue_button = Button.new()
		_continue_button.text = "Continue Game"
		_continue_button.custom_minimum_size = Vector2(200, 50)
		_continue_button.pressed.connect(_on_continue)
		# Insert after Start button
		$VBoxContainer.add_child(_continue_button)
		$VBoxContainer.move_child(_continue_button, start_button.get_index() + 1)

	# Add Settings button
	_settings_button = Button.new()
	_settings_button.text = "Settings"
	_settings_button.custom_minimum_size = Vector2(200, 40)
	_settings_button.pressed.connect(_on_title_settings)
	$VBoxContainer.add_child(_settings_button)

func _on_continue() -> void:
	# Stop slideshow
	_slideshow_active = false
	if _slide_image:
		_slide_image.visible = false
	# Load saved game
	ResourceManager.load_game()
	ResourceManager.game_active = true
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_title_settings() -> void:
	var menu = load("res://scripts/pause_menu.gd").new()
	# Only show the settings panel, hide game-specific buttons
	add_child(menu)

func _start_slideshow() -> void:
	# Create the slide image display (behind UI, in front of background)
	_slide_image = TextureRect.new()
	_slide_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_slide_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_slide_image.anchor_left = 0.0
	_slide_image.anchor_top = 0.0
	_slide_image.anchor_right = 1.0
	_slide_image.anchor_bottom = 1.0
	_slide_image.visible = false
	add_child(_slide_image)
	move_child(_slide_image, 1)  # after ColorRect, before VBoxContainer

	_slideshow_active = true
	_slideshow_timer = 0.0
	_slideshow_index = -1

func _process(delta: float) -> void:
	if not _slideshow_active:
		return

	_slideshow_timer += delta

	# Check if it's time for the next slide
	var next_index = _slideshow_index + 1
	if next_index < SLIDE_TIMINGS.size() and _slideshow_timer >= SLIDE_TIMINGS[next_index]:
		_slideshow_index = next_index
		_show_slide(_slideshow_index)

func _show_slide(index: int) -> void:
	var slide_path = "res://assets/scenes/slide_intro_%02d.png" % (index + 1)
	if not ResourceLoader.exists(slide_path):
		return

	var tex = load(slide_path)
	if tex == null:
		return

	_slide_image.texture = tex
	_slide_image.visible = true

	# Crossfade effect
	_slide_image.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(_slide_image, "modulate:a", 1.0, 0.5)

func _on_start() -> void:
	# Stop slideshow
	_slideshow_active = false
	if _slide_image:
		_slide_image.visible = false

	title_label.visible = false
	subtitle_label.visible = false
	start_button.visible = false
	$VBoxContainer/Spacer.visible = false

	# Show scene image as background
	var scene_path = "res://assets/scenes/scene_intro.png"
	if ResourceLoader.exists(scene_path):
		_scene_image = TextureRect.new()
		_scene_image.texture = load(scene_path)
		_scene_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_scene_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_scene_image.anchor_left = 0.0
		_scene_image.anchor_top = 0.0
		_scene_image.anchor_right = 1.0
		_scene_image.anchor_bottom = 1.0
		add_child(_scene_image)
		move_child(_scene_image, 1)

	story_panel.visible = true
	_in_story = true
	_story_index = -1
	_advance_story()

func _advance_story() -> void:
	_story_index += 1
	if _story_index >= _story_lines.size():
		# Story done — stop voice if still playing, start the game
		AudioManager.stop_voice()
		ResourceManager.game_active = true
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return
	story_label.text = _story_lines[_story_index]
	# Show pilot name on dialog lines (not transmission markers)
	if _story_lines[_story_index].begins_with("["):
		pilot_label.text = ""
	else:
		pilot_label.text = ResourceManager.PILOT_NAME

func _input(event: InputEvent) -> void:
	if not _in_story:
		return
	if event is InputEventKey and event.pressed:
		_advance_story()
	elif event is InputEventMouseButton and event.pressed:
		_advance_story()
