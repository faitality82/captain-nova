extends CanvasLayer

signal closed

const SYMBOLS: Array = ["Cherry", "Crystal", "Star", "Rocket", "Jackpot"]
const SYMBOL_EMOJI: Dictionary = {
	"Cherry": "[C]",
	"Crystal": "[X]",
	"Star": "[*]",
	"Rocket": "[R]",
	"Jackpot": "[$]"
}
const WEIGHTS: Array = [30, 25, 22, 15, 8]  # Must match SYMBOLS order
const PAYOUT_3: Dictionary = {
	"Cherry": 3.0,
	"Crystal": 5.0,
	"Star": 5.0,
	"Rocket": 8.0,
	"Jackpot": 20.0
}
const PAYOUT_2: float = 1.5  # any 2 matching

var _tab_container: TabContainer = null
# Slot machine vars
var _current_bet: int = 50
var _spinning: bool = false
var _reel_results: Array = ["", "", ""]
var _spin_timers: Array = [0.0, 0.0, 0.0]
var _reel_labels: Array = []
var _result_label: Label = null
var _money_label: Label = null
var _spin_btn: Button = null
var _bet_buttons: Array = []
var _spin_elapsed: float = 0.0

func _ready() -> void:
	layer = 10
	_build_ui()

func _build_ui() -> void:
	var panel = Panel.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 60
	panel.offset_top = 30
	panel.offset_right = -60
	panel.offset_bottom = -30
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 10
	vbox.offset_top = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10
	panel.add_child(vbox)

	# Header + money
	var header = Label.new()
	header.text = "Space Bar"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	vbox.add_child(header)

	_money_label = Label.new()
	_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_money_label)

	vbox.add_child(HSeparator.new())

	# Tab container
	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_tab_container)

	_build_slot_tab()
	_build_quest_tab()
	_build_bounty_tab()
	_build_rumor_tab()
	_build_crew_tab()
	_build_skills_tab()

	vbox.add_child(HSeparator.new())

	var leave_btn = Button.new()
	leave_btn.text = "Leave Bar"
	leave_btn.custom_minimum_size = Vector2(200, 40)
	leave_btn.pressed.connect(func(): closed.emit())
	vbox.add_child(leave_btn)

	_refresh_money()
	_refresh_skills_tab()

func _build_slot_tab() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Slot Machine"
	_tab_container.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# Reels display
	var reel_container = HBoxContainer.new()
	reel_container.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in range(3):
		var reel_frame = Panel.new()
		reel_frame.custom_minimum_size = Vector2(100, 80)
		reel_container.add_child(reel_frame)

		var reel_label = Label.new()
		reel_label.text = "---"
		reel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		reel_label.anchor_left = 0.0
		reel_label.anchor_top = 0.0
		reel_label.anchor_right = 1.0
		reel_label.anchor_bottom = 1.0
		reel_label.add_theme_font_size_override("font_size", 18)
		reel_frame.add_child(reel_label)
		_reel_labels.append(reel_label)
	vbox.add_child(reel_container)

	# Result label
	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 16)
	_result_label.text = "Place your bet and SPIN!"
	vbox.add_child(_result_label)

	vbox.add_child(HSeparator.new())

	# Bet buttons
	var bet_label = Label.new()
	bet_label.text = "Bet Amount:"
	bet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(bet_label)

	var bet_container = HBoxContainer.new()
	bet_container.alignment = BoxContainer.ALIGNMENT_CENTER
	for amount in [50, 100, 250]:
		var btn = Button.new()
		btn.text = "$%d" % amount
		btn.custom_minimum_size = Vector2(80, 35)
		var bet_amount = amount
		btn.pressed.connect(func(): _set_bet(bet_amount))
		bet_container.add_child(btn)
		_bet_buttons.append(btn)
	vbox.add_child(bet_container)

	# Spin button
	_spin_btn = Button.new()
	_spin_btn.text = "SPIN ($%d)" % _current_bet
	_spin_btn.custom_minimum_size = Vector2(200, 50)
	_spin_btn.pressed.connect(_on_spin)
	vbox.add_child(_spin_btn)

	_refresh_slot_ui()

func _refresh_slot_ui() -> void:
	_spin_btn.text = "SPIN ($%d)" % _current_bet
	_spin_btn.disabled = _spinning or ResourceManager.money < _current_bet

	# Highlight selected bet
	var bets = [50, 100, 250]
	for i in range(_bet_buttons.size()):
		if bets[i] == _current_bet:
			_bet_buttons[i].modulate = Color(1, 1, 0.5, 1)
		else:
			_bet_buttons[i].modulate = Color(1, 1, 1, 1)
		_bet_buttons[i].disabled = _spinning

func _set_bet(amount: int) -> void:
	if _spinning:
		return
	_current_bet = amount
	_refresh_slot_ui()
	_refresh_money()

func _on_spin() -> void:
	if _spinning or ResourceManager.money < _current_bet:
		return

	ResourceManager.money -= _current_bet
	_spinning = true
	_result_label.text = "Spinning..."
	_refresh_slot_ui()
	_refresh_money()

	# Determine results
	for i in range(3):
		_reel_results[i] = _weighted_pick()

	# Animate reels
	_spin_timers = [0.6, 1.2, 1.8]  # Each reel stops at different times
	set_process(true)

func _process(delta: float) -> void:
	if not _spinning:
		set_process(false)
		return

	_spin_elapsed += delta

	# Animate spinning reels
	for i in range(3):
		if _spin_elapsed < _spin_timers[i]:
			# Still spinning - show random symbol
			_reel_labels[i].text = SYMBOL_EMOJI[SYMBOLS[randi() % SYMBOLS.size()]]
		else:
			# Stopped - show result
			_reel_labels[i].text = SYMBOL_EMOJI[_reel_results[i]]

	# All reels stopped?
	if _spin_elapsed >= _spin_timers[2] + 0.3:
		_spinning = false
		_spin_elapsed = 0.0
		set_process(false)
		_evaluate_result()

func _evaluate_result() -> void:
	var r0 = _reel_results[0]
	var r1 = _reel_results[1]
	var r2 = _reel_results[2]

	var payout = 0.0

	if r0 == r1 and r1 == r2:
		# 3 of a kind
		payout = PAYOUT_3[r0]
		_result_label.text = "3x %s! WIN $%d!" % [r0, int(_current_bet * payout)]
		_result_label.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))
	elif r0 == r1 or r1 == r2 or r0 == r2:
		# 2 of a kind
		payout = PAYOUT_2
		_result_label.text = "2 Match! WIN $%d!" % int(_current_bet * payout)
		_result_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))
	else:
		_result_label.text = "No match. Better luck next time!"
		_result_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4, 1))

	if payout > 0:
		var winnings = int(_current_bet * payout)
		ResourceManager.money += winnings
		AudioManager.play_sfx("sfx_trade")

	_refresh_slot_ui()
	_refresh_money()

func _weighted_pick() -> String:
	var total_weight = 0
	for w in WEIGHTS:
		total_weight += w
	var roll = randi() % total_weight
	var cumulative = 0
	for i in range(SYMBOLS.size()):
		cumulative += WEIGHTS[i]
		if roll < cumulative:
			return SYMBOLS[i]
	return SYMBOLS[0]

func _build_quest_tab() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Job Board"
	_tab_container.add_child(scroll)
	var vbox = VBoxContainer.new()
	vbox.name = "QuestVBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	_refresh_quest_tab()

func _refresh_quest_tab() -> void:
	var vbox = _tab_container.get_node("Job Board/QuestVBox")
	if vbox == null:
		return
	for child in vbox.get_children():
		child.queue_free()

	var header = Label.new()
	header.text = "Available Jobs"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(header)

	if ResourceManager.available_quests.is_empty():
		var none_label = Label.new()
		none_label.text = "No jobs available right now."
		none_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox.add_child(none_label)
	else:
		for quest in ResourceManager.available_quests:
			var hbox = HBoxContainer.new()
			var desc = Label.new()
			desc.text = "%s ($%d)" % [quest["desc"], quest["reward"]]
			desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(desc)

			var accept_btn = Button.new()
			accept_btn.text = "Accept"
			accept_btn.custom_minimum_size = Vector2(80, 30)
			var q = quest
			accept_btn.pressed.connect(func():
				if ResourceManager.accept_quest(q):
					AudioManager.play_sfx("sfx_trade")
					ResourceManager.available_quests.erase(q)
					_refresh_quest_tab()
			)
			if ResourceManager.active_quests.size() >= 3:
				accept_btn.disabled = true
			hbox.add_child(accept_btn)
			vbox.add_child(hbox)

	vbox.add_child(HSeparator.new())

	# Active quests
	var active_header = Label.new()
	active_header.text = "Active Jobs (%d/3)" % ResourceManager.active_quests.size()
	active_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	active_header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(active_header)

	for quest in ResourceManager.active_quests:
		var qlabel = Label.new()
		match quest["type"]:
			"deliver":
				var have = ResourceManager.cargo.get(quest.get("resource", ""), 0)
				qlabel.text = "  %s (%d/%d)" % [quest["desc"], have, quest.get("amount", 0)]
			"kill":
				qlabel.text = "  %s (%d/%d)" % [quest["desc"], quest.get("kills", 0), quest.get("kill_target", 0)]
			"chain":
				qlabel.text = "  %s (step %d)" % [quest["desc"], quest.get("step", 0) + 1]
		qlabel.add_theme_color_override("font_color", Color(0.8, 0.8, 1, 1))
		vbox.add_child(qlabel)

func _build_rumor_tab() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Rumors"
	_tab_container.add_child(scroll)
	var vbox = VBoxContainer.new()
	vbox.name = "RumorVBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	load("res://scripts/station_menu.gd").build_rumor_rows(vbox)

func _build_bounty_tab() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Bounties"
	_tab_container.add_child(scroll)
	var vbox = VBoxContainer.new()
	vbox.name = "BountyVBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	_refresh_bounty_tab()

func _refresh_bounty_tab() -> void:
	var vbox = _tab_container.get_node("Bounties/BountyVBox")
	if vbox == null:
		return
	for child in vbox.get_children():
		child.queue_free()

	# Active bounty
	if ResourceManager.active_bounty.size() > 0:
		var active_label = Label.new()
		active_label.text = "Active Bounty: %s near %s ($%d)" % [
			ResourceManager.active_bounty.get("name", "?"),
			ResourceManager.active_bounty.get("planet", "?"),
			ResourceManager.active_bounty.get("reward", 0),
		]
		active_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
		vbox.add_child(active_label)
		vbox.add_child(HSeparator.new())

	var header = Label.new()
	header.text = "Available Bounties"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(header)

	# Generate bounties if none
	if not has_meta("_bounties"):
		set_meta("_bounties", ResourceManager.generate_bounties() if ResourceManager.has_method("generate_bounties") else [])

	var bounties = get_meta("_bounties", [])
	if bounties.is_empty():
		var none_label = Label.new()
		none_label.text = "No bounties posted. Check back later."
		none_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox.add_child(none_label)
	else:
		for bounty in bounties:
			var hbox = HBoxContainer.new()
			var desc = Label.new()
			desc.text = "%s near %s ($%d)" % [bounty.get("name", "?"), bounty.get("planet", "?"), bounty.get("reward", 0)]
			desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(desc)

			var accept_btn = Button.new()
			accept_btn.text = "Accept"
			accept_btn.custom_minimum_size = Vector2(80, 30)
			var b = bounty
			accept_btn.pressed.connect(func():
				if ResourceManager.accept_bounty(b):
					AudioManager.play_sfx("sfx_trade")
					_refresh_bounty_tab()
			)
			if ResourceManager.active_bounty.size() > 0:
				accept_btn.disabled = true
			hbox.add_child(accept_btn)
			vbox.add_child(hbox)

func _build_crew_tab() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Crew"
	_tab_container.add_child(scroll)
	var vbox = VBoxContainer.new()
	vbox.name = "CrewVBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	_refresh_crew_tab()

func _refresh_crew_tab() -> void:
	var vbox = _tab_container.get_node("Crew/CrewVBox")
	if vbox == null:
		return
	for child in vbox.get_children():
		child.queue_free()

	# Current crew
	var crew_header = Label.new()
	crew_header.text = "Your Crew (%d/%d)" % [ResourceManager.crew_members.size(), ResourceManager.crew_slots]
	crew_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crew_header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(crew_header)

	if ResourceManager.crew_members.is_empty():
		var none_label = Label.new()
		none_label.text = "No crew hired yet."
		none_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox.add_child(none_label)
	else:
		for member in ResourceManager.crew_members:
			var mlabel = Label.new()
			var desc = ResourceManager.CREW_DATA[member]["desc"] if member in ResourceManager.CREW_DATA else ""
			mlabel.text = "  %s — %s" % [member.capitalize(), desc]
			mlabel.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))
			vbox.add_child(mlabel)

	vbox.add_child(HSeparator.new())

	# Available for hire
	var hire_header = Label.new()
	hire_header.text = "For Hire"
	hire_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hire_header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(hire_header)

	if not has_meta("_available_crew"):
		set_meta("_available_crew", ResourceManager.get_available_crew() if ResourceManager.has_method("get_available_crew") else [])

	var available = get_meta("_available_crew", [])
	for crew_type in available:
		if crew_type not in ResourceManager.CREW_DATA:
			continue
		var data = ResourceManager.CREW_DATA[crew_type]
		var hbox = HBoxContainer.new()
		var desc = Label.new()
		desc.text = "%s — %s ($%d)" % [crew_type.capitalize(), data["desc"], data["cost"]]
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(desc)

		var hire_btn = Button.new()
		hire_btn.text = "Hire"
		hire_btn.custom_minimum_size = Vector2(80, 30)
		var ct = crew_type
		hire_btn.pressed.connect(func():
			if ResourceManager.hire_crew(ct):
				AudioManager.play_sfx("sfx_trade")
				_refresh_crew_tab()
				_refresh_money()
		)
		hire_btn.disabled = ResourceManager.money < data["cost"] or ResourceManager.crew_members.size() >= ResourceManager.crew_slots or crew_type in ResourceManager.crew_members
		hbox.add_child(hire_btn)
		vbox.add_child(hbox)

func _refresh_money() -> void:
	if _money_label:
		_money_label.text = "Money: $%d" % ResourceManager.money

func _find_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_find_all_children(child))
	return result

func _build_skills_tab() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Skills"
	_tab_container.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	var level_label = Label.new()
	level_label.name = "SkillsLevelLabel"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(level_label)

	var xp_label = Label.new()
	xp_label.name = "SkillsXPLabel"
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(xp_label)

	var sp_label = Label.new()
	sp_label.name = "SkillsSPLabel"
	sp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(sp_label)

	vbox.add_child(HSeparator.new())

	var hint_label = Label.new()
	hint_label.text = "Press [K] in space to open Upgrade Web"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.8))
	vbox.add_child(hint_label)

	var summary_label = Label.new()
	summary_label.name = "SkillsSummaryLabel"
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(summary_label)

func _refresh_skills_tab() -> void:
	for child in _find_all_children(self):
		if child is Label and child.name == "SkillsLevelLabel":
			child.text = "Level %d" % ResourceManager.level
		elif child is Label and child.name == "SkillsXPLabel":
			var needed := ResourceManager.xp_for_level(ResourceManager.level)
			child.text = "XP: %d / %d" % [ResourceManager.xp, needed]
		elif child is Label and child.name == "SkillsSPLabel":
			if ResourceManager.skill_points > 0:
				child.text = "Skill Points: %d (spend in Upgrade Web!)" % ResourceManager.skill_points
			else:
				child.text = "Skill Points: 0"
		elif child is Label and child.name == "SkillsSummaryLabel":
			var count: int = ResourceManager.unlocked_nodes.size()
			var total: int = SkillTreeData.NODES.size()
			var names: String = ""
			for nid in ResourceManager.unlocked_nodes:
				names += SkillTreeData.NODES[nid]["name"] + ", "
			if names != "":
				names = names.substr(0, names.length() - 2)
			child.text = "Unlocked: %d/%d\n%s" % [count, total, names]
