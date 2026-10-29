extends Node

# Random event system for city visits
# 20% chance per city visit, triggered on _ready()

signal event_started
signal event_ended

var _event_active: bool = false

# Quick events (80% of triggered events)
const QUICK_EVENTS: Array = [
	{"text": "You found $150 on the ground!", "money": 150},
	{"text": "Pickpocketed! Lost $100!", "money": -100},
	{"text": "A kind stranger gives you a free fuel cell! +15 fuel", "fuel": 15.0},
	{"text": "You found a small cache of parts!", "cargo": "parts"},
	{"text": "You slipped on something and broke a gadget. -$75 repairs.", "money": -75},
	{"text": "A merchant tips you $200 for helping load cargo!", "money": 200},
	{"text": "You found some ice crystals in an alley!", "cargo": "ice"},
	{"text": "Space pickpocket! Lost $150!", "money": -150},
	{"text": "Won a street lottery! +$250!", "money": 250},
	{"text": "Found a fuel leak repair kit! +10 fuel", "fuel": 10.0},
]

# Story events (20% of triggered events) — require player choice
const STORY_EVENTS: Array = [
	{
		"text": "A shady dealer approaches you.\n\"I've got a mystery crate. Could be worth thousands... or nothing. $500, take it or leave it.\"",
		"accept_text": "Buy crate ($500)",
		"decline_text": "Walk away",
		"accept_cost": 500,
		"accept_outcomes": [
			{"text": "The crate contained rare crystals worth a fortune!", "cargo": "crystals", "amount": 3},
			{"text": "The crate was full of junk. What a waste!", "cargo": "", "amount": 0},
			{"text": "You found some decent ore inside.", "cargo": "ore", "amount": 2},
		]
	},
	{
		"text": "A stranger runs up to you.\n\"Please! My ship is broken down. I need $200 for parts. I'll remember this kindness!\"",
		"accept_text": "Help ($200)",
		"decline_text": "Ignore",
		"accept_cost": 200,
		"accept_outcomes": [
			{"text": "The stranger was grateful and gave you a tip about cheap fuel on Jupiter!", "money": 0},
			{"text": "The stranger paid you back double! +$400!", "money": 400},
			{"text": "The stranger disappeared... You feel good about helping, at least.", "money": 0},
		]
	},
	{
		"text": "A bar fight breaks out near you!\n\"Hey spacer, whose side are you on?!\"",
		"accept_text": "Jump in! (Risk it)",
		"decline_text": "Run away",
		"accept_cost": 0,
		"accept_outcomes": [
			{"text": "You won the fight! The crowd cheers and throws money! +$300!", "money": 300},
			{"text": "You got knocked around. Lost $100 on medical bills.", "money": -100},
			{"text": "It was a draw. No harm, no foul.", "money": 0},
		]
	},
]

func try_trigger_event() -> void:
	if randf() > 0.20:
		return  # 80% chance nothing happens

	# Wait a moment before triggering (let player walk around first)
	await get_tree().create_timer(randf_range(2.0, 5.0)).timeout

	_event_active = true
	event_started.emit()

	# 80% quick event, 20% story event
	if randf() < 0.80:
		_trigger_quick_event()
	else:
		_trigger_story_event()

func _trigger_quick_event() -> void:
	var event = QUICK_EVENTS[randi() % QUICK_EVENTS.size()]

	# Apply effects
	if event.has("money"):
		ResourceManager.money = max(0, ResourceManager.money + event["money"])
	if event.has("fuel"):
		ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + event["fuel"], ResourceManager.ship_max_fuel)
	if event.has("cargo"):
		ResourceManager.add_cargo(event["cargo"])

	# Show dialog
	_show_event_dialog(event["text"], true)

func _trigger_story_event() -> void:
	var event = STORY_EVENTS[randi() % STORY_EVENTS.size()]
	_show_story_dialog(event)

func _show_event_dialog(text: String, auto_close: bool = false) -> void:
	var overlay = CanvasLayer.new()
	overlay.name = "EventOverlay"
	overlay.layer = 15

	# Dim background
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	overlay.add_child(dim)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -80
	panel.offset_right = 200
	panel.offset_bottom = 80
	overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 15
	vbox.offset_top = 15
	vbox.offset_right = -15
	vbox.offset_bottom = -15
	panel.add_child(vbox)

	var header = Label.new()
	header.text = "! Random Event !"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))
	vbox.add_child(header)

	var msg = Label.new()
	msg.text = text
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(msg)

	var ok_btn = Button.new()
	ok_btn.text = "OK"
	ok_btn.custom_minimum_size = Vector2(100, 35)
	ok_btn.pressed.connect(func():
		overlay.queue_free()
		_event_active = false
		event_ended.emit()
	)
	vbox.add_child(ok_btn)

	get_tree().root.add_child(overlay)

	if auto_close:
		AudioManager.play_sfx("sfx_trade")

func _show_story_dialog(event: Dictionary) -> void:
	var overlay = CanvasLayer.new()
	overlay.name = "EventOverlay"
	overlay.layer = 15

	# Dim background
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	overlay.add_child(dim)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -220
	panel.offset_top = -120
	panel.offset_right = 220
	panel.offset_bottom = 120
	overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 15
	vbox.offset_top = 15
	vbox.offset_right = -15
	vbox.offset_bottom = -15
	panel.add_child(vbox)

	var header = Label.new()
	header.text = "! Story Event !"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(1, 0.6, 0, 1))
	vbox.add_child(header)

	var msg = Label.new()
	msg.text = event["text"]
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(msg)

	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var accept_btn = Button.new()
	accept_btn.text = event["accept_text"]
	accept_btn.custom_minimum_size = Vector2(150, 35)
	accept_btn.pressed.connect(func():
		overlay.queue_free()
		_resolve_story_accept(event)
	)
	# Disable if can't afford
	if event["accept_cost"] > 0 and ResourceManager.money < event["accept_cost"]:
		accept_btn.disabled = true
		accept_btn.text += " (can't afford)"
	btn_container.add_child(accept_btn)

	var decline_btn = Button.new()
	decline_btn.text = event["decline_text"]
	decline_btn.custom_minimum_size = Vector2(150, 35)
	decline_btn.pressed.connect(func():
		overlay.queue_free()
		_event_active = false
		event_ended.emit()
	)
	btn_container.add_child(decline_btn)

	vbox.add_child(btn_container)
	get_tree().root.add_child(overlay)

func _resolve_story_accept(event: Dictionary) -> void:
	# Pay cost
	if event["accept_cost"] > 0:
		ResourceManager.spend_money(event["accept_cost"])

	# Random outcome
	var outcomes = event["accept_outcomes"]
	var outcome = outcomes[randi() % outcomes.size()]

	# Apply outcome
	if outcome.has("money") and outcome["money"] != 0:
		ResourceManager.money = max(0, ResourceManager.money + outcome["money"])
	if outcome.has("cargo") and outcome["cargo"] != "":
		var amount = outcome.get("amount", 1)
		for i in range(amount):
			ResourceManager.add_cargo(outcome["cargo"])

	# Show result
	_show_event_dialog(outcome["text"], true)
