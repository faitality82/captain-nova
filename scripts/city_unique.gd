extends CanvasLayer

signal closed

var _content_vbox: VBoxContainer = null
var _result_label: Label = null
var _money_label: Label = null

func _ready() -> void:
	layer = 10
	_build_ui()

func _build_ui() -> void:
	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250
	panel.offset_top = -200
	panel.offset_right = 250
	panel.offset_bottom = 200
	add_child(panel)

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
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# Header
	var header = Label.new()
	header.text = _get_building_name()
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	vbox.add_child(header)

	# Money
	_money_label = Label.new()
	_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_money_label)

	vbox.add_child(HSeparator.new())

	# Description
	var desc = Label.new()
	desc.text = _get_description()
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)

	vbox.add_child(HSeparator.new())

	# Content area (planet-specific buttons)
	_content_vbox = VBoxContainer.new()
	vbox.add_child(_content_vbox)

	# Result label
	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_result_label)

	vbox.add_child(HSeparator.new())

	# Leave button
	var leave_btn = Button.new()
	leave_btn.text = "Leave"
	leave_btn.custom_minimum_size = Vector2(200, 40)
	leave_btn.pressed.connect(func(): closed.emit())
	vbox.add_child(leave_btn)

	_build_planet_content()
	_refresh_money()

func _refresh_money() -> void:
	_money_label.text = "Money: $%d" % ResourceManager.money

func _get_building_name() -> String:
	match ResourceManager.current_planet:
		"Mercury": return "Caloris Scrapyard"
		"Venus": return "Cloud Market"
		"Earth": return "Sol News Network"
		"Mars": return "Olympus Arena"
		"Jupiter": return "Ganymede Fuel Depot"
		"Saturn": return "Titan Research Lab"
		"Uranus": return "Miranda Smuggler's Den"
		"Neptune": return "Triton Ice Lounge"
		"Pluto": return "The Underworld"
		_: return "Unknown"

func _get_description() -> String:
	match ResourceManager.current_planet:
		"Mercury": return "Salvaged parts pulled from the crater walls of Caloris Basin. Every crate is a gamble — ancient tech or worthless slag?"
		"Venus": return "A shadowy bazaar floating in the clouds of Venus. Better prices, but 50km is a long fall if things go wrong."
		"Earth": return "The Sol News Network broadcasts trade intel from every corner of the solar system. Knowledge is profit."
		"Mars": return "The arena at Olympus Landing draws fighters from across the system. The red dust runs with glory — and credits."
		"Jupiter": return "Ganymede's ice-drilled fuel reserves make this the cheapest fill-up between Mars and Saturn. Bulk discounts available."
		"Saturn": return "Titan Labs pushes the boundaries of ship technology. The methane atmosphere keeps away prying eyes."
		"Uranus": return "In Miranda's shattered ice canyons, nobody asks questions. High risk, high reward — the smuggler's way."
		"Neptune": return "Triton's cryovolcanic vents heat this lounge naturally. Rest, heal, and watch the geysers erupt."
		"Pluto": return "The edge of civilization. In the Underworld, everything has a price — and everything is for sale. No refunds, no complaints, no survivors."
		_: return ""

func _build_planet_content() -> void:
	match ResourceManager.current_planet:
		"Mercury": _build_mercury()
		"Venus": _build_venus()
		"Earth": _build_earth()
		"Mars": _build_mars()
		"Jupiter": _build_jupiter()
		"Saturn": _build_saturn()
		"Uranus": _build_uranus()
		"Neptune": _build_neptune()
		"Pluto": _build_pluto()

# Mercury Scrapyard: Buy mystery crate ($200) → random cargo
func _build_mercury() -> void:
	var btn = Button.new()
	btn.text = "Buy Mystery Crate ($200)"
	btn.custom_minimum_size = Vector2(250, 40)
	btn.pressed.connect(_mercury_buy_crate)
	_content_vbox.add_child(btn)

func _mercury_buy_crate() -> void:
	if not ResourceManager.spend_money(200):
		_result_label.text = "Not enough money!"
		return
	if not ResourceManager.can_carry():
		ResourceManager.add_money(200)  # refund
		_result_label.text = "Cargo full!"
		return
	var items = ResourceManager.cargo.keys()
	var item = items[randi() % items.size()]
	var amount = randi_range(1, 3)
	var added = 0
	for i in range(amount):
		if ResourceManager.add_cargo(item):
			added += 1
	_result_label.text = "Found %d %s in the crate!" % [added, item.capitalize()]
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()

# Venus Black Market: Same as Market but 30% better sell prices, 15% chance of robbery
func _build_venus() -> void:
	var prices = ResourceManager.current_planet_prices
	for resource in ResourceManager.cargo.keys():
		var sell_price = prices[resource][1] if resource in prices else 0
		if sell_price <= 0:
			continue
		var boosted_price = int(sell_price * 1.3)
		var row = HBoxContainer.new()
		var label = Label.new()
		label.text = "%s (x%d)" % [resource.capitalize(), ResourceManager.cargo[resource]]
		label.custom_minimum_size = Vector2(120, 0)
		row.add_child(label)
		var btn = Button.new()
		btn.text = "Sell +$%d" % boosted_price
		var res_name = resource
		var bp = boosted_price
		btn.pressed.connect(func(): _venus_sell(res_name, bp))
		btn.disabled = ResourceManager.cargo[resource] == 0
		row.add_child(btn)
		_content_vbox.add_child(row)

func _venus_sell(resource: String, price: int) -> void:
	if ResourceManager.cargo[resource] == 0:
		return
	ResourceManager.remove_cargo(resource)
	# 15% chance of robbery
	if randf() < 0.15:
		var stolen = min(500, ResourceManager.money)
		ResourceManager.money -= stolen
		_result_label.text = "ROBBED! Lost $%d! (Sold %s for $%d)" % [stolen, resource.capitalize(), price]
	else:
		ResourceManager.add_money(price)
		_result_label.text = "Sold %s for $%d on the black market!" % [resource.capitalize(), price]
	AudioManager.play_sfx("sfx_trade")
	if not ResourceManager.has_crew("smuggler"):
		ResourceManager.adjust_reputation("Venus", -5)
	_refresh_money()
	# Rebuild to update stock counts
	for child in _content_vbox.get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_venus()

# Earth News Station: Shows best prices for each resource
func _build_earth() -> void:
	var info_label = Label.new()
	info_label.text = "=== TRADE INTEL ==="
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content_vbox.add_child(info_label)

	# Sol News runs the same rumor board the stations and bars carry.
	load("res://scripts/station_menu.gd").build_rumor_rows(_content_vbox)

	_content_vbox.add_child(HSeparator.new())

	# What the ship's own logs last saw, instead of a hardcoded table that lied.
	var seen_header = Label.new()
	seen_header.text = "=== LAST SEEN PRICES ==="
	seen_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content_vbox.add_child(seen_header)

	var seen_lines: int = 0
	for planet in ResourceManager.price_memory:
		if seen_lines >= 12:
			break
		for resource in ResourceManager.price_memory[planet]:
			if seen_lines >= 12:
				break
			var p: Array = ResourceManager.price_memory[planet][resource]
			if p.size() > 1 and int(p[1]) > 0:
				var seen_label = Label.new()
				seen_label.text = "%s: %s sells for $%d" % [planet, resource.capitalize(), p[1]]
				_content_vbox.add_child(seen_label)
				seen_lines += 1
	if seen_lines == 0:
		var no_seen = Label.new()
		no_seen.text = "No market logs yet. Go land somewhere."
		no_seen.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_content_vbox.add_child(no_seen)

	_content_vbox.add_child(HSeparator.new())

	var prem_header = Label.new()
	prem_header.text = "=== PREMIUM GOODS INTEL ==="
	prem_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prem_header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_content_vbox.add_child(prem_header)

	var tier_label = Label.new()
	tier_label.text = "T2 (Rep 25+): Antimatter, Biotech, Nanites"
	_content_vbox.add_child(tier_label)

	var tier3_label = Label.new()
	tier3_label.text = "T3 (Rep 50+): Dark Matter, Artifacts, Gravitonium"
	_content_vbox.add_child(tier3_label)

	var tier4_label = Label.new()
	tier4_label.text = "T4 (Rep 75+): Void Essence (Pluto/Neptune), Starcore (Mercury/Venus)"
	_content_vbox.add_child(tier4_label)

	var tip_label = Label.new()
	tip_label.text = "Buy where produced, sell where scarce. Huge margins!"
	tip_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	_content_vbox.add_child(tip_label)

# Mars Arena: Bet on NPC fight (50/50, 2x payout)
func _build_mars() -> void:
	var fighters = ["Iron Fist", "Crimson Blade", "Shadow Walker", "Thunder Bear"]
	var f1 = fighters[randi() % fighters.size()]
	var f2 = fighters[randi() % fighters.size()]
	while f2 == f1:
		f2 = fighters[randi() % fighters.size()]

	var label = Label.new()
	label.text = "Tonight's match: %s vs %s" % [f1, f2]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content_vbox.add_child(label)

	for bet_amount in [100, 250, 500]:
		var row = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var btn1 = Button.new()
		btn1.text = "%s ($%d)" % [f1, bet_amount]
		btn1.custom_minimum_size = Vector2(150, 35)
		var fighter1 = f1
		var ba = bet_amount
		btn1.pressed.connect(func(): _mars_bet(fighter1, ba))
		row.add_child(btn1)

		var btn2 = Button.new()
		btn2.text = "%s ($%d)" % [f2, bet_amount]
		btn2.custom_minimum_size = Vector2(150, 35)
		var fighter2 = f2
		btn2.pressed.connect(func(): _mars_bet(fighter2, ba))
		row.add_child(btn2)

		_content_vbox.add_child(row)

func _mars_bet(fighter: String, amount: int) -> void:
	if not ResourceManager.spend_money(amount):
		_result_label.text = "Not enough money!"
		return
	# 50/50 odds
	if randf() < 0.5:
		var winnings = amount * 2
		ResourceManager.add_money(winnings)
		_result_label.text = "%s wins! You earned $%d!" % [fighter, winnings]
	else:
		_result_label.text = "%s lost the fight! You lose $%d!" % [fighter, amount]
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()

# Jupiter Fuel Depot: Fuel at 50% cost
func _build_jupiter() -> void:
	var btn = Button.new()
	btn.name = "CheapFuelBtn"
	btn.custom_minimum_size = Vector2(250, 40)
	btn.pressed.connect(_jupiter_refuel)
	_content_vbox.add_child(btn)
	_refresh_jupiter_fuel()

func _refresh_jupiter_fuel() -> void:
	for child in _find_all_children(_content_vbox):
		if child is Button and child.name == "CheapFuelBtn":
			if ResourceManager.ship_fuel >= ResourceManager.ship_max_fuel:
				child.text = "Fuel: Tank Full"
				child.disabled = true
			else:
				@warning_ignore("integer_division")
				var half_cost = ResourceManager.FUEL_REFILL_COST / 2
				var pct = int((ResourceManager.ship_fuel / ResourceManager.ship_max_fuel) * 100)
				child.text = "Refuel +25 ($%d) [%d%%] — HALF PRICE!" % [half_cost, pct]
				child.disabled = ResourceManager.money < half_cost

func _jupiter_refuel() -> void:
	@warning_ignore("integer_division")
	var half_cost = ResourceManager.FUEL_REFILL_COST / 2
	if ResourceManager.ship_fuel >= ResourceManager.ship_max_fuel:
		return
	if ResourceManager.money < half_cost:
		_result_label.text = "Not enough money!"
		return
	ResourceManager.money -= half_cost
	ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + 25.0, ResourceManager.ship_max_fuel)
	_result_label.text = "Fueled up! Half price, baby!"
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()
	_refresh_jupiter_fuel()

# Saturn Upgrade Lab: 4th upgrade level
func _build_saturn() -> void:
	for upgrade_name in ResourceManager.UPGRADE_COSTS.keys():
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 40)
		var level = ResourceManager.upgrade_levels[upgrade_name]
		var cost = ResourceManager.get_upgrade_cost(upgrade_name) * 2  # double cost for tier 4
		if level >= 4:
			btn.text = "%s: ULTIMATE MAX" % upgrade_name.capitalize()
			btn.disabled = true
		elif level < 3:
			btn.text = "%s: Need Lv3 first (currently Lv%d)" % [upgrade_name.capitalize(), level]
			btn.disabled = true
		else:
			btn.text = "%s Lv3 → Lv4 ($%d)" % [upgrade_name.capitalize(), cost]
			btn.disabled = ResourceManager.money < cost
		var up_name = upgrade_name
		var up_cost = cost
		btn.pressed.connect(func(): _saturn_upgrade(up_name, up_cost))
		_content_vbox.add_child(btn)

	# Weapon Mods section
	var mod_sep = HSeparator.new()
	_content_vbox.add_child(mod_sep)

	var mod_header = Label.new()
	mod_header.text = "— Weapon Mods —"
	mod_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mod_header.add_theme_font_size_override("font_size", 14)
	_content_vbox.add_child(mod_header)

	for mod_name in ResourceManager.MOD_DATA:
		var data = ResourceManager.MOD_DATA[mod_name]
		if data["rare"]:
			continue  # rare mods aren't sold
		var btn2 = Button.new()
		btn2.custom_minimum_size = Vector2(300, 35)
		if mod_name in ResourceManager.owned_mods:
			if mod_name == ResourceManager.equipped_mod:
				btn2.text = "%s — EQUIPPED" % mod_name.capitalize().replace("_", " ")
				btn2.disabled = true
			else:
				btn2.text = "%s — Equip" % mod_name.capitalize().replace("_", " ")
				var mn = mod_name
				btn2.pressed.connect(func():
					ResourceManager.equip_mod(mn)
					AudioManager.play_sfx("sfx_trade")
					# Rebuild
					for child in _content_vbox.get_children():
						child.queue_free()
					await get_tree().process_frame
					_build_saturn()
				)
		else:
			btn2.text = "%s ($%d) — %s" % [mod_name.capitalize().replace("_", " "), data["cost"], data["desc"]]
			btn2.disabled = ResourceManager.money < data["cost"]
			var mn = mod_name
			btn2.pressed.connect(func():
				if ResourceManager.purchase_mod(mn):
					AudioManager.play_sfx("sfx_trade")
					_refresh_money()
					for child in _content_vbox.get_children():
						child.queue_free()
					await get_tree().process_frame
					_build_saturn()
			)
		_content_vbox.add_child(btn2)

	# Crew slot purchase (if not at max)
	if ResourceManager.crew_slots < 3:
		var crew_btn = Button.new()
		crew_btn.text = "Extra Crew Slot ($2000)"
		crew_btn.custom_minimum_size = Vector2(300, 35)
		crew_btn.disabled = ResourceManager.money < 2000
		crew_btn.pressed.connect(func():
			if ResourceManager.spend_money(2000):
				ResourceManager.crew_slots += 1
				AudioManager.play_sfx("sfx_trade")
				_refresh_money()
		)
		_content_vbox.add_child(crew_btn)

func _saturn_upgrade(upgrade_name: String, cost: int) -> void:
	var level = ResourceManager.upgrade_levels[upgrade_name]
	if level != 3 or ResourceManager.money < cost:
		return
	ResourceManager.money -= cost
	ResourceManager.upgrade_levels[upgrade_name] = 4
	# Apply the extra upgrade bonus
	match upgrade_name:
		"engine": ResourceManager.ship_speed += 75.0
		"shield": ResourceManager.ship_max_hp += 50
		"cargo": ResourceManager.cargo_capacity += 8
		"weapon": ResourceManager.weapon_damage += 25
	_result_label.text = "%s upgraded to Lv4! Maximum power!" % upgrade_name.capitalize()
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()
	# Rebuild
	for child in _content_vbox.get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_saturn()

# Uranus Smuggler's Den: Buy contraband ($300, sells for $800-1500)
func _build_uranus() -> void:
	var btn = Button.new()
	btn.text = "Buy Contraband ($300)"
	btn.custom_minimum_size = Vector2(250, 40)
	btn.pressed.connect(_uranus_buy_contraband)
	btn.disabled = ResourceManager.money < 300 or not ResourceManager.can_carry()
	_content_vbox.add_child(btn)

	# Show contraband count if any
	var contraband_count = ResourceManager.cargo.get("contraband", 0)
	if contraband_count > 0:
		var info = Label.new()
		info.text = "Contraband in cargo: %d" % contraband_count
		_content_vbox.add_child(info)

func _uranus_buy_contraband() -> void:
	if not ResourceManager.spend_money(300):
		_result_label.text = "Not enough money!"
		return
	# Add contraband to cargo
	if not ResourceManager.cargo.has("contraband"):
		ResourceManager.cargo["contraband"] = 0
	if not ResourceManager.can_carry():
		ResourceManager.add_money(300)
		_result_label.text = "Cargo full!"
		return
	ResourceManager.cargo["contraband"] += 1
	_result_label.text = "Contraband acquired. Sell it at other planets for big profit!"
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()

# Neptune Ice Lounge: Full HP heal for $200 flat fee (cheaper than garage per-HP repair)
const ICE_LOUNGE_HEAL_COST: int = 200

func _build_neptune() -> void:
	var btn = Button.new()
	btn.text = "Rest & Heal (Full HP — $%d)" % ICE_LOUNGE_HEAL_COST
	btn.custom_minimum_size = Vector2(300, 40)
	btn.pressed.connect(_neptune_heal)
	_content_vbox.add_child(btn)

	var hp_info = Label.new()
	hp_info.text = "HP: %d / %d" % [ResourceManager.ship_hp, ResourceManager.ship_max_hp]
	_content_vbox.add_child(hp_info)

func _neptune_heal() -> void:
	if ResourceManager.ship_hp >= ResourceManager.ship_max_hp:
		_result_label.text = "Already at full health!"
		return
	if ResourceManager.money < ICE_LOUNGE_HEAL_COST:
		_result_label.text = "Not enough money! Need $%d." % ICE_LOUNGE_HEAL_COST
		return
	ResourceManager.spend_money(ICE_LOUNGE_HEAL_COST)
	ResourceManager.ship_hp = ResourceManager.ship_max_hp
	_result_label.text = "Fully healed for $%d!" % ICE_LOUNGE_HEAL_COST
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()
	# Rebuild to update HP display
	for child in _content_vbox.get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_neptune()

func _build_pluto() -> void:
	# --- Black Market (2x sell prices, 25% robbery) ---
	var bm_header = Label.new()
	bm_header.text = "— Black Market (2x Prices, 25% Robbery Risk) —"
	bm_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bm_header.add_theme_font_size_override("font_size", 14)
	_content_vbox.add_child(bm_header)

	var prices = ResourceManager.current_planet_prices
	for resource in ResourceManager.cargo.keys():
		var sell_price = prices[resource][1] if resource in prices else 0
		if sell_price <= 0:
			continue
		var boosted = sell_price * 2
		var row = HBoxContainer.new()
		var label = Label.new()
		label.text = "%s (x%d)" % [resource.capitalize(), ResourceManager.cargo[resource]]
		label.custom_minimum_size = Vector2(120, 0)
		row.add_child(label)
		var btn = Button.new()
		btn.text = "Sell +$%d" % boosted
		btn.disabled = ResourceManager.cargo[resource] == 0
		var res_name = resource
		var bp = boosted
		btn.pressed.connect(func(): _pluto_sell(res_name, bp))
		row.add_child(btn)
		_content_vbox.add_child(row)

	_content_vbox.add_child(HSeparator.new())

	# --- Hire Charon (unique crew member) ---
	var crew_header = Label.new()
	crew_header.text = "— Legendary Crew —"
	crew_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crew_header.add_theme_font_size_override("font_size", 14)
	_content_vbox.add_child(crew_header)

	var charon_btn = Button.new()
	charon_btn.custom_minimum_size = Vector2(300, 40)
	if ResourceManager.has_crew("ferryman"):
		charon_btn.text = "Charon the Ferryman — HIRED"
		charon_btn.disabled = true
	else:
		charon_btn.text = "Hire Charon the Ferryman ($3000) — -30% Fuel Costs"
		charon_btn.disabled = ResourceManager.money < 3000
		charon_btn.pressed.connect(func(): _hire_charon())
	_content_vbox.add_child(charon_btn)

func _pluto_sell(resource: String, price: int) -> void:
	if ResourceManager.cargo[resource] == 0:
		return
	ResourceManager.remove_cargo(resource)
	# 25% robbery chance
	if randf() < 0.25:
		var stolen = min(800, ResourceManager.money)
		ResourceManager.money -= stolen
		_result_label.text = "AMBUSHED! Lost $%d! (Sold %s for $%d)" % [stolen, resource.capitalize(), price]
	else:
		ResourceManager.add_money(price)
		_result_label.text = "Sold %s for $%d in the Underworld!" % [resource.capitalize(), price]
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()
	# Rebuild
	for child in _content_vbox.get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_pluto()

func _hire_charon() -> void:
	if ResourceManager.money < 3000:
		_result_label.text = "Not enough money!"
		return
	if ResourceManager.crew_members.size() >= ResourceManager.crew_slots:
		_result_label.text = "No crew slots available!"
		return
	ResourceManager.spend_money(3000)
	ResourceManager.crew_members.append("ferryman")
	_result_label.text = "Charon joins your crew. The void between stars grows shorter."
	AudioManager.play_sfx("sfx_trade")
	_refresh_money()
	# Rebuild
	for child in _content_vbox.get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_pluto()

func _find_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_find_all_children(child))
	return result
