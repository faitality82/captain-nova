extends Node2D

@onready var ship = $Ship
@onready var hud = $HUD
@onready var blood_splatter = $BloodSplatter
@onready var fire_death = $FireDeath
@onready var sun = $Sun

# Sun position (orbit center for all planets)
var _sun_position: Vector2 = Vector2(-3000, 0)

# Respawn at Earth (home base) — updated each frame to track Earth's orbit
var _respawn_position: Vector2 = Vector2(0, 100)

# Planet currently nearby (for ENTER to land)
var _visiting_planet: Node = null

# Station currently nearby (for ENTER to dock)
var _visiting_station: Node = null

# Boss system
var _boss_scene: PackedScene = preload("res://scenes/world/Boss.tscn")
var _current_boss: Node = null
var _current_boss_tier: int = 0
var _boss_active: bool = false
# Boss tier tracking now lives in ResourceManager.boss_tiers_defeated
const BOSS_MONEY_THRESHOLDS: Array = [5000, 25000, 60000]  # money milestones that trigger bosses
const MOON_SCRIPT := preload("res://scripts/moon.gd")
const PHOBOS := "Phobos"

# Mothership final boss system
var _motherships_spawned: bool = false
var _motherships_remaining: int = 0

# Golden wormhole (endgame portal)
var _golden_wormhole: Node = null

# Fuel rescue system
var _bounty_enemy_spawned: bool = false
var _pluto_pirates_spawned: bool = false

# Skill tree overlay
var _skill_tree_instance: Node = null

var _fuel_rescue_active: bool = false
var _fuel_rescue_timer: float = 0.0
const FUEL_RESCUE_DELAY: float = 3.0  # seconds after fuel empty before rescue arrives

# Orbital periods — 3x faster than before (divide original values by 3)
const ORBIT_PERIODS: Dictionary = {
	"Mercury": 144.0,    # was 432
	"Venus":   370.0,    # was 1110
	"Earth":   600.0,    # was 1800
	"Mars":    1128.0,   # was 3384
	"Jupiter": 7116.0,   # was 21348
	"Saturn":  17676.0,  # was 53028
	"Uranus":  50400.0,  # was 151200
	"Neptune": 98880.0,  # was 296640
	"Pluto": 148800.0,  # extremely slow orbit, far out
}

func _ready() -> void:
	ship.hp_changed.connect(hud.update_hp)
	ship.died.connect(_on_ship_died)
	ship.fuel_empty.connect(_on_fuel_empty)
	sun.player_burned.connect(_on_sun_burn)

	# First launch log entry
	if ResourceManager.ship_log.is_empty():
		ResourceManager.add_log("Captain Nova's log, entry one. Departing Earth with $200 and a dream.", "story")
	hud.update_hp(ResourceManager.ship_max_hp, ResourceManager.ship_max_hp)

	# Restore ship state from ResourceManager (persisted across city visits)
	ship.hp = ResourceManager.ship_hp
	ship.hp_changed.emit(ship.hp, ResourceManager.ship_max_hp)
	if ResourceManager.ship_position != Vector2.ZERO:
		ship.global_position = ResourceManager.ship_position
		ship._facing_angle = ResourceManager.ship_facing

	# Start the dubstep
	AudioManager.play_music()

	for planet in get_tree().get_nodes_in_group("planet"):
		planet.player_entered_landing_zone.connect(_on_player_enter_planet)
		planet.player_exited_landing_zone.connect(_on_player_exit_planet)
		# Set up orbit if this planet has a known period
		if planet.planet_name in ORBIT_PERIODS:
			planet.setup_orbit(_sun_position, ORBIT_PERIODS[planet.planet_name])

	_spawn_pluto()
	_spawn_phobos()
	_spawn_wormholes()
	_spawn_quest_asteroid_fields()

	# Snap ship to relevant planet after orbits are randomized
	if ResourceManager.current_planet != "":
		# Returning from a city — spawn near the planet we just visited
		var home_planet = _find_planet(ResourceManager.current_planet)
		if home_planet:
			ship.global_position = home_planet.global_position + Vector2(0, 80)
	elif ResourceManager.ship_position == Vector2.ZERO:
		# Fresh game start — spawn near Earth (which is now at a random orbit angle)
		var earth = _find_planet("Earth")
		if earth:
			ship.global_position = earth.global_position + Vector2(0, 80)

	_spawn_stations()

	var space_events = Node.new()
	space_events.set_script(load("res://scripts/space_events.gd"))
	add_child(space_events)

	# Show tutorial on first play
	if not ResourceManager.settings.get("tutorial_seen", false):
		var tutorial = load("res://scripts/tutorial_overlay.gd").new()
		add_child(tutorial)

	ResourceManager.market_event_created.connect(_on_market_event)
	# Landing creates the event here in World (the ENTER handler calls randomize_prices_for_planet),
	# so the signal fires while World is being freed the same frame and the hint never renders.
	# Those events come back unannounced; show the newest one now that World is up again.
	var unseen: Array = ResourceManager.price_events.filter(func(e): return not e.get("announced", false))
	if not unseen.is_empty():
		# Only the newest gets the hint. The rest are already in the log and still carry
		# near_announced, so NEARBY can surface them when the player flies past.
		for i in range(unseen.size() - 1):
			unseen[i]["announced"] = true
		# Deferred: the ship respawns inside the landing zone it just left, and that ENTER
		# prompt would overwrite the hint on frame one. _scan_nearby_events shows it once we are clear.
		_pending_market_replay = unseen.back()

var _event_scan: float = 1.0   # first scan waits a beat so landing zones have registered
var _pending_market_replay: Dictionary = {}

## Show a hint for `seconds`, then clear it only if nothing else has replaced it since.
func _flash_hint(text: String, seconds: float) -> void:
	hud.show_interact_hint(text)
	await get_tree().create_timer(seconds).timeout
	if is_inside_tree() and hud.interact_hint.text == text:
		hud.hide_interact_hint()

func _on_market_event(event: Dictionary) -> void:
	if event.get("announced", false):
		return
	var text: String = "MARKET: " + str(event["cause"])
	hud.show_interact_hint(text)
	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree():
		return   # World was freed (landing); _ready()'s replay announces it next time
	# Flagged only if the hint survived its full run; if something overwrote it, try again
	# once the scan finds the player clear of prompts.
	if hud.interact_hint.text == text:
		event["announced"] = true
		hud.hide_interact_hint()
	else:
		_pending_market_replay = event

func _scan_nearby_events(delta: float) -> void:
	_event_scan -= delta
	if _event_scan > 0.0:
		return
	_event_scan = 2.0
	# The world clock is what advances events, so expire them here rather than only on landing.
	ResourceManager.tick_events()
	if _visiting_planet != null:
		return   # standing in a landing zone; the ENTER prompt owns the hint
	if not _pending_market_replay.is_empty():
		var replay: Dictionary = _pending_market_replay
		_pending_market_replay = {}
		if replay in ResourceManager.price_events:   # it may have expired while stuck behind other prompts
			_on_market_event(replay)
		return
	for event in ResourceManager.price_events:
		if event.get("near_announced", false):
			continue
		var planet = _find_planet(event["planet"])
		if planet and ship.global_position.distance_to(planet.global_position) < 1500.0:
			event["near_announced"] = true
			_flash_hint("NEARBY: " + event["cause"], 3.0)

func _process(delta: float) -> void:
	ResourceManager.game_seconds += delta
	_scan_nearby_events(delta)
	# Warp cooldown
	if _warp_cooldown > 0.0:
		_warp_cooldown -= delta

	# Track Earth's position for respawning
	var earth = _find_planet("Earth")
	if earth:
		_respawn_position = earth.global_position + Vector2(0, 100)

	# Win condition — spawn motherships at $100K, victory when all 3 defeated
	if ResourceManager.game_active and ResourceManager.money >= ResourceManager.WIN_TARGET and not _motherships_spawned:
		_spawn_motherships()
		return

	# Boss spawning check
	if ResourceManager.game_active:
		_check_boss_spawn()

	# Bounty spawn check
	_check_bounty_spawn()

	# Pluto pirate ambush check
	if not _pluto_pirates_spawned:
		var pluto = _find_planet("Pluto")
		if pluto and ship.global_position.distance_to(pluto.global_position) < 2000:
			_spawn_pluto_pirates(pluto)
			_pluto_pirates_spawned = true

	# Fuel rescue check
	if _fuel_rescue_active:
		_fuel_rescue_timer -= delta
		if _fuel_rescue_timer <= 0:
			_fuel_rescue_active = false
			_do_fuel_rescue()

func _check_boss_spawn() -> void:
	# Boss spawns at money milestones: $5K, $25K, $60K
	for tier in [1, 2, 3]:
		var threshold = BOSS_MONEY_THRESHOLDS[tier - 1]
		if ResourceManager.money >= threshold and tier not in ResourceManager.boss_tiers_defeated and not _boss_active:
			_spawn_boss(tier)
			break

func _spawn_boss(tier: int) -> void:
	ResourceManager.boss_tiers_defeated.append(tier)
	_boss_active = true
	ResourceManager.add_log("Boss Tier %d appeared. $%d milestone reached." % [tier, BOSS_MONEY_THRESHOLDS[tier - 1]], "combat")

	# Warning
	AudioManager.play_sfx("sfx_boss_warning", -2.0)
	var hails := {
		1: "TITHE DESTROYER: \"The light named you, bartender. We collect what it names.\"",
		2: "TITHE DREADNOUGHT: \"You keep refusing the gift. We stop asking.\"",
		3: "TITHE OVERLORD: \"Nobody says no to the void. Nobody has lived long enough.\"",
	}
	hud.show_interact_hint(hails.get(tier, "WARNING: Boss incoming!"))
	if not ResourceManager.story_flag("tithe_named"):
		ResourceManager.set_story_flags({"tithe_named": true})
		ResourceManager.add_log("The pirates have a name for themselves. The Tithe. They talk about the green light like it's a landlord.", "story")
	await get_tree().create_timer(2.0).timeout
	hud.hide_interact_hint()

	# Switch to industrial boss music
	AudioManager.switch_to_boss_music()

	# Spawn boss near the player
	var boss = ResourceManager.safe_instantiate(_boss_scene)
	if boss == null:
		return
	var spawn_angle = randf() * TAU
	boss.global_position = ship.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * 500

	# Scale boss with tier (3x HP for meaningful fights)
	boss.boss_tier = tier
	_current_boss_tier = tier
	boss.hp = 800 + tier * 600  # T1: 1400, T2: 2000, T3: 2600
	boss.max_hp = boss.hp
	boss.kill_reward = 1000 + tier * 750  # T1: $1750, T2: $2500, T3: $3250
	boss.move_speed = 80 + tier * 20

	# Connect signals
	boss.boss_defeated.connect(_on_boss_defeated)
	boss.boss_hp_changed.connect(hud.update_boss_hp)
	boss.destroyed.connect(_on_enemy_destroyed)

	_current_boss = boss
	add_child(boss)

	# Show boss HP bar
	hud.show_boss_hp(boss.hp, boss.max_hp, tier)

func _log_has_prefix(prefix: String) -> bool:
	for entry in ResourceManager.ship_log:
		if entry.get("text", "").begins_with(prefix):
			return true
	return false

func _on_boss_defeated() -> void:
	if _current_boss_tier not in ResourceManager.boss_tiers_cleared:
		ResourceManager.boss_tiers_cleared.append(_current_boss_tier)
	_boss_active = false
	_current_boss = null
	hud.hide_boss_hp()

	# Grant tier-specific reward
	match _current_boss_tier:
		1:
			ResourceManager.grant_ability("shield_bubble")
			hud.show_interact_hint("NEW ABILITY: Shield Bubble! [Q]")
			if not _log_has_prefix("Someone built a warship"):
				ResourceManager.add_log("Someone built a warship to stop a bartender. I'm flattered.", "story")
		2:
			ResourceManager.grant_ability("emp_blast")
			hud.show_interact_hint("NEW ABILITY: EMP Blast! [F]")
			if not _log_has_prefix("The Dreadnought had a symbol"):
				ResourceManager.add_log("The Dreadnought had a symbol painted on the hull. Green circle, three lines. Dex says it's a cult. Dex says a lot of things.", "story")
		3:
			ResourceManager.grant_weapon("railgun")
			hud.show_interact_hint("NEW WEAPON: Railgun!")

	# Drop a shield pickup as before
	var pickup_scene = load("res://scenes/world/ShieldPickup.tscn")
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		pickup.global_position = ship.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		call_deferred("add_child", pickup)

	AudioManager.switch_to_normal_music()

	await get_tree().create_timer(3.0).timeout
	hud.hide_interact_hint()

func _find_planet(pname: String) -> Node:
	for planet in get_tree().get_nodes_in_group("planet"):
		if planet.planet_name == pname:
			return planet
	for moon in get_tree().get_nodes_in_group("moon"):
		if moon.planet_name == pname:
			return moon
	return null

func _spawn_pluto() -> void:
	var planet_scene = ResourceManager.safe_load("res://scenes/world/Planet.tscn")
	if planet_scene == null:
		return
	var pluto = planet_scene.instantiate()
	pluto.planet_name = "Pluto"
	pluto.price_table = {
		"ore": [0, 180],
		"fuel": [40, 200],
		"parts": [0, 160],
		"ice": [0, 250],
		"crystals": [0, 280],
		"plasma": [0, 130],
	}
	pluto.global_position = _sun_position + Vector2(13000, 0)
	add_child(pluto)
	pluto.player_entered_landing_zone.connect(_on_player_enter_planet)
	pluto.player_exited_landing_zone.connect(_on_player_exit_planet)

	# Asteroid field near Pluto — drops void_essence for endgame quest
	var pluto_field_scene = ResourceManager.safe_load("res://scenes/world/AsteroidField.tscn")
	if pluto_field_scene == null:
		return
	var pluto_field = pluto_field_scene.instantiate()
	pluto_field.global_position = pluto.global_position + Vector2(500, -300)
	pluto_field.field_size = Vector2(1200, 800)
	pluto_field.max_asteroids = 20
	pluto_field.resource_type = "void_essence"
	add_child(pluto_field)
	pluto.setup_orbit(_sun_position, ORBIT_PERIODS["Pluto"])

func _spawn_phobos() -> void:
	var mars = _find_planet("Mars")
	if mars == null:
		return
	var phobos = Node2D.new()
	phobos.name = PHOBOS
	phobos.set_script(MOON_SCRIPT)
	phobos.planet_name = PHOBOS
	mars.add_child(phobos)
	phobos.player_entered_landing_zone.connect(_on_player_enter_planet)
	phobos.player_exited_landing_zone.connect(_on_player_exit_planet)

var _quest_fields: Array = []  # track quest asteroid fields so we don't duplicate

func _spawn_quest_asteroid_fields() -> void:
	# Spawn asteroid fields near planets that have active fetch quests
	var field_scene = ResourceManager.safe_load("res://scenes/world/AsteroidField.tscn")
	if field_scene == null:
		return

	# Collect target planets from active NPC fetch quests
	var needed: Dictionary = {}  # planet_name -> resource_type
	for quest in ResourceManager.npc_active_quests:
		if quest.get("type", "") == "fetch":
			var planet = quest.get("target_planet", "")
			var resource = quest.get("target", "")
			if planet != "" and resource != "" and planet != "Pluto":  # Pluto already has one
				needed[planet] = resource

	for planet_name in needed:
		var planet_node = _find_planet(planet_name)
		if planet_node == null:
			continue

		# Don't spawn a duplicate if one already exists for this planet
		if planet_name in _quest_fields:
			continue

		var field = field_scene.instantiate()
		# Offset from planet center so it's nearby but not overlapping
		var offset = Vector2(600, -400).rotated(randf() * TAU)
		field.position = offset  # local offset from planet
		field.field_size = Vector2(1000, 700)
		field.max_asteroids = 15
		field.resource_type = needed[planet_name]
		field.add_to_group("quest_field")
		# Add as child of the planet — inherits orbital movement automatically
		planet_node.add_child(field)
		_quest_fields.append(planet_name)

func _spawn_pluto_pirates(pluto: Node) -> void:
	hud.show_interact_hint("WARNING: Uncharted space! Pirates detected!")
	var enemy_scene = ResourceManager.safe_load("res://scenes/world/AlienShip.tscn")
	if enemy_scene == null:
		return
	for i in 3:
		var enemy = enemy_scene.instantiate()
		var angle = randf() * TAU
		enemy.global_position = pluto.global_position + Vector2(cos(angle), sin(angle)) * randf_range(300, 800)
		add_child(enemy)
	await get_tree().create_timer(3.0).timeout
	hud.hide_interact_hint()

func _check_bounty_spawn() -> void:
	if ResourceManager.active_bounty.size() == 0:
		_bounty_enemy_spawned = false
		return
	if _bounty_enemy_spawned:
		return
	var target_planet_name = ResourceManager.active_bounty.get("planet", "")
	var target_planet = _find_planet(target_planet_name)
	if target_planet == null:
		return
	if ship.global_position.distance_to(target_planet.global_position) < 3000:
		_spawn_bounty_enemy(target_planet)
		_bounty_enemy_spawned = true

func _spawn_bounty_enemy(near_planet: Node) -> void:
	var enemy_scene = ResourceManager.safe_load("res://scenes/world/AlienShip.tscn")
	if enemy_scene == null:
		return
	var enemy = enemy_scene.instantiate()
	enemy.set_script(load("res://scripts/bounty_enemy.gd"))
	var angle = randf() * TAU
	enemy.global_position = near_planet.global_position + Vector2(cos(angle), sin(angle)) * 500
	enemy.bounty_name = ResourceManager.active_bounty.get("name", "Bounty")
	add_child(enemy)

func _on_player_enter_planet(planet: Node) -> void:
	_visiting_planet = planet
	if planet.planet_name == PHOBOS:
		if 4 in ResourceManager.boss_tiers_cleared:
			hud.show_interact_hint("Phobos Meat Works: cleared. Press ENTER to revisit the dock")
		elif 2 in ResourceManager.boss_tiers_cleared:
			hud.show_interact_hint("Press ENTER to dock at Phobos Meat Works")
		else:
			hud.show_interact_hint("Phobos Meat Works is sealed. Something is moving inside.")
		return
	hud.show_interact_hint("Press ENTER to land on " + planet.planet_name)

func _on_player_exit_planet() -> void:
	_visiting_planet = null
	hud.hide_interact_hint()

func _enter_phobos() -> void:
	if 2 not in ResourceManager.boss_tiers_cleared:
		hud.show_interact_hint("Sealed. The Dreadnought's escort codes would open it.")
		return
	ResourceManager.ship_hp = ship.hp
	ResourceManager.ship_position = ship.global_position
	ResourceManager.ship_facing = ship._facing_angle
	# Mars, not Phobos: current_planet also drives CityScene market headers, and Phobos has no city
	ResourceManager.current_planet = "Mars"   # world.gd respawns us near Mars on return
	var completed = ResourceManager.check_quest_completion(PHOBOS)
	for q in completed:
		ResourceManager.add_log("Quest complete at Phobos Meat Works. +$%d" % q["reward"], "event")
	ResourceManager.save_game()
	get_tree().change_scene_to_file("res://scenes/world/FrankArena.tscn")

# --- Pause Menu ---
var _pause_menu: Node = null

func _open_pause_menu() -> void:
	if _pause_menu != null:
		return
	get_tree().paused = true
	_pause_menu = load("res://scripts/pause_menu.gd").new()
	_pause_menu.closed.connect(func():
		_pause_menu = null
	)
	add_child(_pause_menu)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _pause_menu == null and not ship.is_dead:
			_open_pause_menu()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		if _skill_tree_instance == null and not ship.is_dead:
			_open_skill_tree()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if _visiting_station != null and not ship.is_dead:
			_open_station_menu()
		elif _visiting_planet != null and not ship.is_dead:
			if _visiting_planet.planet_name == PHOBOS:
				_enter_phobos()
				return
			var planet_name = _visiting_planet.planet_name
			ResourceManager.current_planet = planet_name
			ResourceManager.current_planet_prices = _visiting_planet.get_price_table().duplicate(true)
			# Merge premium prices into current_planet_prices
			var premium = ResourceManager.PLANET_PREMIUM_PRICES.get(planet_name, {})
			for res in premium:
				ResourceManager.current_planet_prices[res] = premium[res]
			ResourceManager.ship_hp = ship.hp
			ResourceManager.ship_position = ship.global_position
			ResourceManager.ship_facing = ship._facing_angle
			# Log first visit to each planet
			var visited_before = false
			for entry in ResourceManager.ship_log:
				if entry.get("text", "").begins_with("Landed on " + planet_name):
					visited_before = true
					break
			if not visited_before:
				ResourceManager.add_log("Landed on %s for the first time." % planet_name, "explore")
			ResourceManager.randomize_prices_for_planet(planet_name)
			ResourceManager.settle_stock(planet_name)
			# Auto-save on planet landing — after the price roll and settle so the save
			# holds the market the city scene is about to show.
			ResourceManager.save_game()
			ResourceManager.generate_quests_for_planet(planet_name)
			# +1 rep for landing on a planet
			ResourceManager.adjust_reputation(planet_name, 1)
			var completed = ResourceManager.check_quest_completion(planet_name)
			for q in completed:
				hud.show_interact_hint("Quest complete! +$%d" % q["reward"])
			get_tree().change_scene_to_file("res://scenes/city/CityScene.tscn")

func _open_skill_tree() -> void:
	_skill_tree_instance = preload("res://scripts/skill_tree_ui.gd").new()
	_skill_tree_instance.closed.connect(func():
		_skill_tree_instance.queue_free()
		_skill_tree_instance = null
	)
	add_child(_skill_tree_instance)

func _spawn_stations() -> void:
	var station_script = load("res://scripts/space_station.gd")
	# Station Alpha — between Mars and Jupiter
	var alpha = Node2D.new()
	alpha.set_script(station_script)
	alpha.station_name = "Station Alpha"
	alpha.global_position = _sun_position + Vector2(2800, 0)
	alpha.player_entered_dock.connect(_on_player_enter_station)
	alpha.player_exited_dock.connect(_on_player_exit_station)
	add_child(alpha)

	# Station Beta — between Saturn and Uranus
	var beta = Node2D.new()
	beta.set_script(station_script)
	beta.station_name = "Station Beta"
	beta.global_position = _sun_position + Vector2(-7500, 0)
	beta.player_entered_dock.connect(_on_player_enter_station)
	beta.player_exited_dock.connect(_on_player_exit_station)
	add_child(beta)

func _on_player_enter_station(station: Node) -> void:
	_visiting_station = station
	hud.show_interact_hint("Press ENTER to dock at " + station.station_name)

func _on_player_exit_station() -> void:
	_visiting_station = null
	hud.hide_interact_hint()

func _open_station_menu() -> void:
	var menu = CanvasLayer.new()
	menu.set_script(load("res://scripts/station_menu.gd"))
	menu._station_name = _visiting_station.station_name if _visiting_station else "Station"
	get_tree().paused = true
	menu.closed.connect(func():
		get_tree().paused = false
		menu.queue_free()
	)
	add_child(menu)

func _on_ship_died() -> void:
	ResourceManager.add_log("Ship destroyed. Escape pod deployed. Lives remaining: %d." % max(ResourceManager.lives - 1, 0), "death")
	# Rep penalty at nearest planet — you died in their space
	var nearest_planet = ""
	var nearest_dist = 5000.0
	for planet in get_tree().get_nodes_in_group("planet"):
		var d = ship.global_position.distance_to(planet.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_planet = planet.planet_name
	if nearest_planet != "":
		ResourceManager.adjust_reputation(nearest_planet, -5)
	# Drop cargo on death — insurance reduces loss
	var loss_fraction = 4 if ResourceManager.cargo_insurance else 2
	for key in ResourceManager.cargo:
		@warning_ignore("integer_division")
		var lost = ResourceManager.cargo[key] / loss_fraction
		ResourceManager.cargo[key] -= lost
	if ResourceManager.cargo_insurance:
		ResourceManager.cargo_insurance = false

	if _boss_active:
		blood_splatter.trigger()

	# Spawn escape pod
	var pod = Node2D.new()
	pod.set_script(load("res://scripts/escape_pod.gd"))
	pod.global_position = ship.global_position
	pod.target_position = _respawn_position
	add_child(pod)

	# Camera follows pod
	var cam = Camera2D.new()
	cam.enabled = true
	cam.position_smoothing_enabled = true
	pod.add_child(cam)
	cam.make_current()

	hud.show_interact_hint("ESCAPE POD DEPLOYED")

	if ResourceManager.lose_life():
		pod.pod_finished.connect(func():
			hud.show_interact_hint("Ship destroyed! Cargo lost! Lives: %d" % ResourceManager.lives)
			await get_tree().create_timer(1.0).timeout
			ship.respawn(_respawn_position)
			ResourceManager.ship_fuel = ResourceManager.ship_max_fuel
			ResourceManager.ship_hp = ship.hp
			ResourceManager.last_stand_used = false
			hud.hide_interact_hint()
		)
	else:
		hud.show_interact_hint("NO RESCUE INCOMING...")
		pod.pod_finished.connect(func():
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
		)

func _on_fuel_empty() -> void:
	if _fuel_rescue_active:
		return  # already waiting for rescue
	_fuel_rescue_active = true
	_fuel_rescue_timer = FUEL_RESCUE_DELAY
	hud.show_interact_hint("OUT OF FUEL! Drifting... Rescue incoming...")

func _do_fuel_rescue() -> void:
	# The fuel rescue guy arrives
	ResourceManager.add_log("Ran out of fuel. Gus arrived with a tow rig and a story.", "event")
	var cost = ResourceManager.emergency_refuel()

	AudioManager.play_sfx("sfx_trade")
	AudioManager.play_voice("voice_fuel")

	# Show the story from the fuel guy
	var story_lines: Array = []
	if cost >= ResourceManager.EMERGENCY_FUEL_COST:
		story_lines = [
			"[INCOMING TRANSMISSION]",
			"Hey there, Captain! Name's Gus. Saw you floating dead out here.",
			"I filled your tank. That'll be $%d. Space towing ain't cheap!" % cost,
			"But hey — someone helped ME once when I was stranded near Jupiter.",
			"Told me to pay it forward someday. So here's the deal...",
			"If you're ever broke and out of fuel, I'll cut you a break.",
			"Stay safe out there, Captain. The void doesn't forgive.",
			"[TRANSMISSION ENDED]",
		]
	else:
		story_lines = [
			"[INCOMING TRANSMISSION]",
			"Gus again! Looks like you're running on fumes AND empty pockets.",
			"Tell you what — I once ran out of fuel near Saturn's rings.",
			"A stranger towed me to safety. Only charged me $100.",
			"Said 'Pay it forward.' So that's what I'm doing.",
			"Tank's full. Only $%d this time. Consider it a gift from the cosmos." % cost,
			"Now get out there and make your fortune!",
			"[TRANSMISSION ENDED]",
		]

	# Display the story line by line (audio plays via voice_fuel above)
	for line in story_lines:
		hud.show_interact_hint(line)
		await get_tree().create_timer(2.5).timeout

	hud.hide_interact_hint()

func _on_enemy_destroyed(pos: Vector2) -> void:
	# Find nearest planet to the kill location
	var nearest_planet = ""
	var nearest_dist = 5000.0  # quest tracking range
	for planet in get_tree().get_nodes_in_group("planet"):
		var d = pos.distance_to(planet.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_planet = planet.planet_name
	if nearest_planet != "":
		ResourceManager.record_kill_near_planet(nearest_planet)

func _spawn_motherships() -> void:
	_motherships_spawned = true
	_motherships_remaining = 3
	ResourceManager.add_log("$100,000 reached. Three alien motherships detected on the outer rim.", "story")

	# Warning sequence
	AudioManager.play_sfx("sfx_boss_warning", -2.0)
	AudioManager.switch_to_mothership_music()
	hud.show_interact_hint("ALERT: 3 ALIEN MOTHERSHIPS DETECTED ON THE OUTER RIM!")

	var mothership_script = ResourceManager.safe_load("res://scripts/mothership.gd")
	var bullet_scene = ResourceManager.safe_load("res://scenes/world/EnemyBullet.tscn")
	if mothership_script == null or bullet_scene == null:
		push_error("Mothership assets missing — cannot spawn endgame")
		return
	var total_hp := 0

	# Spawn 3 motherships equally spaced (120 degrees apart) on outer orbit
	for i in range(3):
		var ms = CharacterBody2D.new()
		ms.set_script(mothership_script)
		ms.bullet_scene = bullet_scene
		# Collision setup — must match Boss.tscn layers so bullets can hit
		ms.collision_layer = 32   # layer 6 (same as Boss)
		ms.collision_mask = 3     # layers 1+2 (player + player bullets)
		# Add collision shape — mothership octagon is ~35px radius
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 35.0
		shape.shape = circle
		ms.add_child(shape)
		ms.mothership_defeated.connect(_on_mothership_defeated)
		ms.mothership_hp_changed.connect(_on_mothership_hp_changed)
		ms.destroyed.connect(_on_enemy_destroyed)
		add_child(ms)

		var angle = (TAU / 3.0) * float(i)
		ms.setup_orbit(_sun_position, angle)
		total_hp += ms.hp

	# Show combined boss HP bar
	hud.show_boss_hp(total_hp, total_hp, 0)

	await get_tree().create_timer(4.0).timeout
	hud.show_interact_hint("DESTROY ALL 3 MOTHERSHIPS TO WIN!")
	await get_tree().create_timer(3.0).timeout
	hud.hide_interact_hint()

func _on_mothership_defeated() -> void:
	_motherships_remaining -= 1
	ResourceManager.add_log("Mothership destroyed. %d remaining." % _motherships_remaining, "combat")

	if _motherships_remaining <= 0:
		# All motherships destroyed — spawn golden wormhole
		ResourceManager.add_log("All motherships destroyed. A golden rift is opening.", "story")
		hud.hide_boss_hp()
		AudioManager.switch_to_normal_music()
		hud.show_interact_hint("ALL MOTHERSHIPS DESTROYED!")
		await get_tree().create_timer(3.0).timeout
		hud.show_interact_hint("A GOLDEN RIFT IS TEARING OPEN...")
		await get_tree().create_timer(2.0).timeout
		_spawn_golden_wormhole()
		hud.show_interact_hint("FLY INTO THE RIFT, CAPTAIN.")
		await get_tree().create_timer(4.0).timeout
		hud.hide_interact_hint()
	else:
		hud.show_interact_hint("MOTHERSHIP DOWN! %d REMAINING!" % _motherships_remaining)
		# Update HP bar with remaining motherships' combined HP
		_update_mothership_hp_bar()
		await get_tree().create_timer(2.0).timeout
		hud.hide_interact_hint()

func _on_mothership_hp_changed(_current: int, _maximum: int) -> void:
	_update_mothership_hp_bar()

func _update_mothership_hp_bar() -> void:
	var total_hp := 0
	var total_max := 0
	for ms in get_tree().get_nodes_in_group("mothership"):
		total_hp += ms.hp
		total_max += ms.max_hp
	if total_max > 0:
		hud.update_boss_hp(total_hp, total_max)

func _spawn_wormholes() -> void:
	var wormhole_script = load("res://scripts/wormhole.gd")

	# Pair 1: Inner <-> Mid
	var alpha = Node2D.new()
	alpha.set_script(wormhole_script)
	alpha.wormhole_name = "Wormhole Alpha"
	alpha.destination_label = "Saturn Region"
	alpha.global_position = _sun_position + Vector2(2200, 400)
	alpha.player_entered_wormhole.connect(_on_player_enter_wormhole)
	alpha.player_exited_wormhole.connect(_on_player_exit_wormhole)
	add_child(alpha)

	var beta = Node2D.new()
	beta.set_script(wormhole_script)
	beta.wormhole_name = "Wormhole Beta"
	beta.destination_label = "Mars Region"
	beta.global_position = _sun_position + Vector2(-5500, -400)
	beta.player_entered_wormhole.connect(_on_player_enter_wormhole)
	beta.player_exited_wormhole.connect(_on_player_exit_wormhole)
	add_child(beta)

	alpha.linked_wormhole = beta
	beta.linked_wormhole = alpha

	# Pair 2: Mid <-> Outer
	var gamma = Node2D.new()
	gamma.set_script(wormhole_script)
	gamma.wormhole_name = "Wormhole Gamma"
	gamma.destination_label = "Pluto Region"
	gamma.global_position = _sun_position + Vector2(8000, 500)
	gamma.player_entered_wormhole.connect(_on_player_enter_wormhole)
	gamma.player_exited_wormhole.connect(_on_player_exit_wormhole)
	add_child(gamma)

	var delta = Node2D.new()
	delta.set_script(wormhole_script)
	delta.wormhole_name = "Wormhole Delta"
	delta.destination_label = "Uranus Region"
	delta.global_position = _sun_position + Vector2(-12000, -500)
	delta.player_entered_wormhole.connect(_on_player_enter_wormhole)
	delta.player_exited_wormhole.connect(_on_player_exit_wormhole)
	add_child(delta)

	gamma.linked_wormhole = delta
	delta.linked_wormhole = gamma

var _warp_cooldown: float = 0.0

func _on_player_enter_wormhole(wormhole: Node) -> void:
	# Golden wormhole = endgame portal
	if wormhole.is_endgame:
		_enter_golden_wormhole()
		return
	if wormhole.linked_wormhole == null:
		return
	if _warp_cooldown > 0.0:
		return
	# Teleport ship instantly
	var dest = wormhole.linked_wormhole.global_position + Vector2(0, 80)
	ship.global_position = dest
	# Cooldown prevents destination wormhole from immediately warping back
	_warp_cooldown = 2.0
	# Brief visual feedback - purple flash
	_flash_screen()
	hud.show_interact_hint("WARPED to " + wormhole.destination_label)
	await get_tree().create_timer(2.0).timeout
	hud.hide_interact_hint()

func _on_player_exit_wormhole() -> void:
	pass  # No action needed - teleport is instant on enter

func _flash_screen() -> void:
	var flash = ColorRect.new()
	flash.color = Color(0.7, 0.5, 1.0, 0.6)
	flash.anchor_left = 0.0
	flash.anchor_top = 0.0
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	var layer = CanvasLayer.new()
	layer.layer = 10
	layer.add_child(flash)
	add_child(layer)
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.4)
	tween.tween_callback(layer.queue_free)

func _spawn_golden_wormhole() -> void:
	var wormhole_script = load("res://scripts/wormhole.gd")
	_golden_wormhole = Node2D.new()
	_golden_wormhole.set_script(wormhole_script)

	# Golden color palette
	_golden_wormhole.color_ring_outer = Color(1.0, 0.85, 0.2, 0.9)
	_golden_wormhole.color_ring_inner = Color(1.0, 0.7, 0.1, 1.0)
	_golden_wormhole.color_spiral = Color(1.0, 0.9, 0.3, 0.6)
	_golden_wormhole.color_core = Color(1.0, 1.0, 0.8, 1.0)
	_golden_wormhole.color_tendril = Color(1.0, 0.8, 0.15, 0.4)
	_golden_wormhole.color_label = Color(1.0, 0.9, 0.3, 1.0)
	_golden_wormhole.is_endgame = true

	_golden_wormhole.wormhole_name = "THE GOLDEN RIFT"
	_golden_wormhole.destination_label = "Beyond..."

	# Spawn ahead of the ship so the player sees it appear
	_golden_wormhole.global_position = ship.global_position + Vector2(300, 0)
	_golden_wormhole.player_entered_wormhole.connect(_on_player_enter_wormhole)
	_golden_wormhole.player_exited_wormhole.connect(_on_player_exit_wormhole)
	add_child(_golden_wormhole)

	# Gold flash when it appears
	_flash_screen_gold()

func _flash_screen_gold() -> void:
	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.9, 0.3, 0.7)
	flash.anchor_left = 0.0
	flash.anchor_top = 0.0
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	var layer = CanvasLayer.new()
	layer.layer = 10
	layer.add_child(flash)
	add_child(layer)
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.8)
	tween.tween_callback(layer.queue_free)

func _enter_golden_wormhole() -> void:
	# Disable player input
	ship.is_dead = true
	ship.visible = false

	# Big gold flash
	var layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.95, 0.5, 0.0)
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	layer.add_child(flash)

	# Fade to gold
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 1.0, 1.5)
	await tween.finished

	# Hold gold screen, then fade to black
	await get_tree().create_timer(1.0).timeout
	tween = create_tween()
	tween.tween_property(flash, "color", Color(0.0, 0.0, 0.0, 1.0), 1.0)
	await tween.finished

	# Show end-of-beta text
	var title_label = Label.new()
	title_label.text = "END OF BETA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.anchor_left = 0.0
	title_label.anchor_top = 0.3
	title_label.anchor_right = 1.0
	title_label.anchor_bottom = 0.5
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 0.0))
	layer.add_child(title_label)

	var thanks_label = Label.new()
	thanks_label.text = "Thanks for playing, Captain."
	thanks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thanks_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	thanks_label.anchor_left = 0.0
	thanks_label.anchor_top = 0.5
	thanks_label.anchor_right = 1.0
	thanks_label.anchor_bottom = 0.6
	thanks_label.add_theme_font_size_override("font_size", 22)
	thanks_label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6, 0.0))
	layer.add_child(thanks_label)

	var tease_label = Label.new()
	tease_label.text = "The rift leads somewhere. A new solar system awaits.\nBut that's a story for another update."
	tease_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tease_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tease_label.anchor_left = 0.1
	tease_label.anchor_top = 0.62
	tease_label.anchor_right = 0.9
	tease_label.anchor_bottom = 0.75
	tease_label.add_theme_font_size_override("font_size", 16)
	tease_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.35, 0.0))
	tease_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	layer.add_child(tease_label)

	# Fade in text sequentially
	tween = create_tween()
	tween.tween_property(title_label, "theme_override_colors/font_color:a", 1.0, 1.5)
	await tween.finished
	await get_tree().create_timer(1.0).timeout

	tween = create_tween()
	tween.tween_property(thanks_label, "theme_override_colors/font_color:a", 1.0, 1.5)
	await tween.finished
	await get_tree().create_timer(1.0).timeout

	tween = create_tween()
	tween.tween_property(tease_label, "theme_override_colors/font_color:a", 1.0, 2.0)
	await tween.finished

	# Wait, then transition to victory/prestige screen
	await get_tree().create_timer(5.0).timeout
	ResourceManager.game_active = false
	get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")

func _on_sun_burn() -> void:
	if ship.is_dead:
		return
	# Instant kill — the sun doesn't care about your HP
	fire_death.trigger()
	hud.show_interact_hint("INCINERATED BY THE SUN!")
	ship._die()
