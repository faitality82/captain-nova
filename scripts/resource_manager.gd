# resource_manager.gd
# Global singleton - persists for the entire game session.
# All scenes access shared state through ResourceManager.
extends Node

signal level_up(new_level: int)
signal xp_gained(amount: int)
signal market_event_created(event: Dictionary)

func _ready() -> void:
	load_prestige()
	load_settings()

# --- Safe asset loading ---
# Use instead of load() when the asset might be missing.
# Returns null gracefully instead of crashing.
func safe_load(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		push_warning("Asset not found: %s" % path)
		return null
	var res = load(path)
	if res == null:
		push_warning("Failed to load asset: %s" % path)
	return res

# Safe instantiate — guards against null PackedScene
func safe_instantiate(scene: PackedScene) -> Node:
	if scene == null:
		push_warning("Attempted to instantiate null PackedScene")
		return null
	return scene.instantiate()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# --- Cargo ---
var cargo: Dictionary = {
	"ore": 0,
	"fuel": 0,
	"parts": 0,
	"ice": 0,
	"crystals": 0,
	"plasma": 0,
	"antimatter": 0,
	"biotech": 0,
	"nanites": 0,
	"dark_matter": 0,
	"artifacts": 0,
	"gravitonium": 0,
	"void_essence": 0,
	"starcore": 0,
}
var cargo_capacity: int = 10  # total slots (sum of all cargo values)

# --- Money ---
var money: int = 200
const WIN_TARGET: int = 100000

# --- Game State ---
var game_active: bool = false

# --- Lives ---
var lives: int = 3

# --- Story ---
const PILOT_NAME: String = "Captain Nova"

# --- Ship Stats (affected by upgrades) ---
var ship_speed: float = 100.0
var ship_max_hp: int = 100
var ship_hp: int = 100  # current HP, synced between scenes
var weapon_damage: int = 25

# --- Fuel System ---
var ship_fuel: float = 100.0
var ship_max_fuel: float = 100.0
const FUEL_BURN_RATE: float = 2.0  # fuel per second while thrusting
const FUEL_REFILL_COST: int = 50  # cost per 25 fuel at a shop
const EMERGENCY_FUEL_COST: int = 1000  # tow truck price
const EMERGENCY_FUEL_COST_BROKE: int = 100  # "pay it forward" price
var fuel_rescue_used: bool = false  # only one freebie per game

# --- City/Planet Context ---
var current_planet: String = ""
var current_planet_prices: Dictionary = {}
var ship_position: Vector2 = Vector2.ZERO
var ship_facing: float = 0.0
var planet_orbit_angles: Dictionary = {}  # planet_name -> angle, persists across city visits

# --- Boss Tracking ---
var boss_tiers_defeated: Array = []  # e.g. [1, 2, 3]
var boss_tiers_cleared: Array = []  # tiers whose boss was actually destroyed (1-3 money bosses, 4 = Big Frank)

# --- Ship Paint ---
var ship_hull_color: Color = Color(0.55, 0.6, 0.65)      # default steel grey
var ship_accent_color: Color = Color(0.2, 0.5, 0.8)       # default blue trim
var ship_engine_color: Color = Color(0.3, 0.7, 1.0)       # default cyan glow

# --- Abilities ---
var owned_abilities: Array = []  # e.g. ["dash", "shield_bubble", "emp_blast"]

# --- XP / Leveling ---
var xp: int = 0
var level: int = 1
var skill_points: int = 0
var unlocked_nodes: Array = []

const MAX_LEVEL: int = 50
const SKILL_POINT_INTERVAL: int = 5

# Passive damage bonus from leveling (separate from weapon_damage flat value)
var weapon_damage_bonus_pct: float = 0.0

# Last Stand state (resets per life, not per game)
var last_stand_used: bool = false
# Emergency Reserves state
var emergency_reserves_cooldown: float = 0.0

# --- Fuel Tank Upgrade ---
# (fuel_tank added to UPGRADE_COSTS and upgrade_levels below)

# --- Cargo Insurance ---
var cargo_insurance: bool = false
const CARGO_INSURANCE_COST: int = 500

# --- Reputation ---
var reputation: Dictionary = {
	"Mercury": 0, "Venus": 0, "Earth": 0, "Mars": 0,
	"Jupiter": 0, "Saturn": 0, "Uranus": 0, "Neptune": 0,
	"Pluto": 0,
}

# --- Dynamic Prices ---
var dynamic_price_modifiers: Dictionary = {}  # planet -> resource -> float (landing noise)
var price_events: Array = []  # [{type: "shortage"|"glut", planet, resource, cause, ends_at, announced, near_announced}]
var _planet_visit_count: int = 0

# --- Game clock (seconds of flight; advanced by world.gd, saved) ---
var game_seconds: float = 0.0

# --- Elastic stock: 1.0 normal, 0.0 empty, 2.0 glutted; missing = 1.0 ---
const STOCK_K: float = 0.6            # elasticity (Will: standard)
const STOCK_STEP: float = 0.05        # per unit bought (-) or sold (+)
const STOCK_TAU: float = 480.0        # recovery time constant in game-seconds
const STOCK_FLOOR: float = 0.4        # price factor limits
const STOCK_CEIL: float = 2.0         # unreachable at K=0.6 (max 1.6); guards future K bumps
const SHORTAGE_STOCK: float = 0.2
const GLUT_STOCK: float = 1.8
const SHORTAGE_RESOLVES_AT: float = 0.8
const GLUT_RESOLVES_AT: float = 1.2
var market_stock: Dictionary = {}      # planet -> resource -> float
var market_stock_time: Dictionary = {} # planet -> game_seconds of last settle

# --- Rumors (Task 3 fills the model in; declared here so events can spawn them) ---
var rumors: Array = []

# --- Price Memory ---
var price_memory: Dictionary = {}  # planet -> resource -> [buy, sell]

# --- Crew ---
var crew_members: Array = []  # ["mechanic", "gunner", ...]
var crew_slots: int = 3

const CREW_DATA: Dictionary = {
	"navigator": {"cost": 800, "desc": "Shows last-seen prices on planet indicators"},
	"mechanic": {"cost": 600, "desc": "-20% fuel burn rate"},
	"gunner": {"cost": 1000, "desc": "-15% weapon cooldown"},
	"medic": {"cost": 900, "desc": "+1 HP per 5 seconds in space"},
	"trader": {"cost": 1200, "desc": "+10% sell prices"},
	"smuggler": {"cost": 1000, "desc": "+25% contraband price, no rep penalty"},
	"engineer": {"cost": 800, "desc": "Shield bullets take 2 hits"},
	"scout": {"cost": 700, "desc": "+30% minimap range"},
	"ferryman": {"cost": 3000, "desc": "-30% fuel burn rate (legendary)"},
}

# --- Quests ---
var active_quests: Array = []  # max 3, each is a Dictionary
var completed_quests: Array = []  # quest IDs of completed chain quests
var available_quests: Array = []  # generated on planet visit

# --- Bounties ---
var active_bounty: Dictionary = {}  # empty = none active

const BOUNTY_NAMES: Array = ["Captain Zyx", "Red Widow", "The Void", "Iron Maw", "Phantom", "Scourge"]

# --- Weapon Mods ---
var owned_mods: Array = []
var equipped_mod: String = ""

const MOD_DATA: Dictionary = {
	"rapid_fire": {"cost": 800, "rare": false, "desc": "-20% weapon cooldown"},
	"heavy_rounds": {"cost": 1000, "rare": false, "desc": "+25% damage, -10% bullet speed"},
	"extended_range": {"cost": 900, "rare": false, "desc": "+40% bullet lifetime"},
	"lucky_shot": {"cost": 1200, "rare": false, "desc": "10% chance for free shot"},
	"incendiary": {"cost": 0, "rare": true, "desc": "5 burn damage/sec for 3s"},
	"ricochet": {"cost": 0, "rare": true, "desc": "Bullets bounce once toward nearest enemy"},
	"vampiric": {"cost": 0, "rare": true, "desc": "Kills restore 5 HP"},
}

# --- Prestige / NG+ (survives reset) ---
var prestige_level: int = 0
var prestige_tokens: int = 0
var prestige_bonuses: Dictionary = {
	"extra_money": 0,       # each point = +$100 starting money
	"extra_cargo": 0,       # each point = +1 starting cargo slot
	"extra_crew_slots": 0,  # max 2
	"start_dash": false,    # start with dash ability
	"extra_fuel": 0,        # each point = +10 starting max fuel
}

# --- NPC Quests (separate from bar quests) ---
var npc_active_quests: Array = []  # [{npc_id, type, desc, target, progress, reward_type, reward_data}]
var npc_completed_quests: Array = []  # quest ids (quest "id", else the giver's npc_id) of completed quests
var npc_completed_trades: Dictionary = {}  # npc_id -> number of times traded

# --- NPC Powerups (permanent upgrades from NPC traders) ---
var npc_powerups: Dictionary = {}  # powerup_name -> true (set dynamically by NPC trades)

# --- Story Flags (saved) ---
const STORY_FLAG_DEFAULTS: Dictionary = {
	"margaux_recognized": false,   # Margaux realized Nova is the Low Orbit bartender
	"signal_step": 0,              # 0 none, 1 Yuki's recordings delivered, 2 Chakraborty powered, 3 ARIA decoded
	"first_sale_logged": false,
	"tithe_named": false,          # first Tithe boss hail shown
	"first_market_event": false,   # the guaranteed opening shortage/glut has fired
}
var story_flags: Dictionary = STORY_FLAG_DEFAULTS.duplicate()

func set_story_flags(changes: Dictionary) -> void:
	for key in changes:
		var v = changes[key]
		if STORY_FLAG_DEFAULTS.get(key) is int and v is float:
			v = int(v)   # quest set_flags round-trip through JSON saves as floats
		story_flags[key] = v

func story_flag(key: String) -> Variant:
	return story_flags.get(key, STORY_FLAG_DEFAULTS.get(key))

# --- Captain's Log ---
var ship_log: Array = []  # [{text, category}] — newest first
const MAX_LOG_ENTRIES: int = 50

func add_log(text: String, category: String = "event") -> void:
	ship_log.insert(0, {"text": text, "category": category})
	if ship_log.size() > MAX_LOG_ENTRIES:
		ship_log.resize(MAX_LOG_ENTRIES)

const ABILITY_DATA: Dictionary = {
	"dash": {"cost": 400, "cooldown": 3.0, "key": "ability_dash"},
	"shield_bubble": {"cost": 0, "cooldown": 8.0, "key": "ability_shield"},
	"emp_blast": {"cost": 0, "cooldown": 15.0, "key": "ability_emp"},
}

# --- Weapons ---
var current_weapon: String = "blaster"
var owned_weapons: Array = ["blaster"]

const WEAPON_DATA: Dictionary = {
	"blaster": {"cost": 0, "cooldown": 0.25, "damage_mult": 1.0, "bullets": 1, "spread": 0.0, "speed": 600.0, "lifetime": 2.0, "type": "bullet"},
	"laser":   {"cost": 500, "cooldown": 0.08, "damage_mult": 0.4, "bullets": 1, "spread": 0.0, "speed": 900.0, "lifetime": 1.5, "type": "laser"},
	"spread":  {"cost": 750, "cooldown": 0.4, "damage_mult": 0.7, "bullets": 4, "spread": 0.5, "speed": 500.0, "lifetime": 1.5, "type": "bullet"},
	"homing":  {"cost": 600, "cooldown": 0.8, "damage_mult": 1.5, "bullets": 2, "spread": 0.3, "speed": 350.0, "lifetime": 3.0, "type": "homing"},
	"railgun": {"cost": 0, "cooldown": 1.5, "damage_mult": 4.0, "bullets": 1, "spread": 0.0, "speed": 1500.0, "lifetime": 1.0, "type": "railgun"},
}

# --- Upgrade costs ---
const UPGRADE_COSTS: Dictionary = {
	"engine": 300,
	"shield": 400,
	"cargo": 350,
	"weapon": 250,
	"fuel_tank": 300,
}

# --- Repair cost ---
const REPAIR_COST_PER_HP: int = 5  # $5 per HP restored

# --- Upgrade levels (max 3 each) ---
var upgrade_levels: Dictionary = {
	"engine": 0,
	"shield": 0,
	"cargo": 0,
	"weapon": 0,
	"fuel_tank": 0,
}

func total_cargo() -> int:
	var total = 0
	for key in cargo:
		total += cargo[key]
	return total

func can_carry(amount: int = 1) -> bool:
	return total_cargo() + amount <= cargo_capacity

func add_cargo(type: String, amount: int = 1) -> bool:
	if not can_carry(amount):
		return false
	cargo[type] += amount
	return true

func remove_cargo(type: String, amount: int = 1) -> bool:
	if cargo[type] < amount:
		return false
	cargo[type] -= amount
	return true

func add_money(amount: int) -> void:
	money += amount

func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	return true

func get_upgrade_cost(upgrade: String) -> int:
	var base = UPGRADE_COSTS[upgrade]
	var lvl = upgrade_levels[upgrade]
	# Each tier costs 2x more: base, base*2, base*4
	return base * int(pow(2, lvl))

func purchase_upgrade(upgrade: String) -> bool:
	var cost = get_upgrade_cost(upgrade)
	var upgrade_lvl = upgrade_levels[upgrade]
	if upgrade_lvl >= 3 or money < cost:
		return false
	money -= cost
	upgrade_levels[upgrade] += 1
	_apply_upgrade(upgrade)
	return true

func _apply_upgrade(upgrade: String) -> void:
	match upgrade:
		"engine":
			ship_speed += 50.0
		"shield":
			ship_max_hp += 25
		"cargo":
			cargo_capacity += 5
		"weapon":
			weapon_damage += 15
		"fuel_tank":
			ship_max_fuel += 25.0

func purchase_weapon(weapon_name: String) -> bool:
	if weapon_name not in WEAPON_DATA:
		return false
	if weapon_name in owned_weapons:
		return false
	var cost = WEAPON_DATA[weapon_name]["cost"]
	if money < cost:
		return false
	money -= cost
	owned_weapons.append(weapon_name)
	current_weapon = weapon_name
	add_log("Acquired new weapon: %s." % weapon_name.capitalize(), "upgrade")
	return true

func equip_weapon(weapon_name: String) -> bool:
	if weapon_name in owned_weapons:
		current_weapon = weapon_name
		return true
	return false

func purchase_ability(ability_name: String) -> bool:
	if ability_name not in ABILITY_DATA:
		return false
	if ability_name in owned_abilities:
		return false
	var cost = ABILITY_DATA[ability_name]["cost"]
	if cost > 0 and money < cost:
		return false
	if cost > 0:
		money -= cost
	owned_abilities.append(ability_name)
	return true

func grant_ability(ability_name: String) -> void:
	if ability_name not in owned_abilities:
		owned_abilities.append(ability_name)

func grant_weapon(weapon_name: String) -> void:
	if weapon_name not in owned_weapons:
		owned_weapons.append(weapon_name)
		current_weapon = weapon_name

func get_weapon_data() -> Dictionary:
	return WEAPON_DATA[current_weapon]

func purchase_repair(ship_node: Node) -> int:
	# Returns the number of HP repaired, 0 if can't afford or already full
	if not ship_node or not ship_node.has_method("get_hp"):
		return 0
	var current_hp = ship_node.get_hp()
	var missing_hp = ship_max_hp - current_hp
	if missing_hp <= 0:
		return 0
	var cost = missing_hp * REPAIR_COST_PER_HP
	if money < cost:
		# Repair as much as we can afford
		@warning_ignore("integer_division")
		missing_hp = money / REPAIR_COST_PER_HP
		if missing_hp <= 0:
			return 0
		cost = missing_hp * REPAIR_COST_PER_HP
	money -= cost
	return missing_hp

func purchase_fuel(amount: float = 25.0) -> bool:
	if ship_fuel >= ship_max_fuel:
		return false
	if money < FUEL_REFILL_COST:
		return false
	money -= FUEL_REFILL_COST
	ship_fuel = min(ship_fuel + amount, ship_max_fuel)
	return true

func emergency_refuel() -> int:
	# Returns cost charged. Handles the "pay it forward" logic.
	var cost = EMERGENCY_FUEL_COST
	if money < EMERGENCY_FUEL_COST:
		cost = EMERGENCY_FUEL_COST_BROKE
	if money < cost:
		cost = money  # take whatever they have
	money -= cost
	ship_fuel = ship_max_fuel
	fuel_rescue_used = true
	return cost

# --- Reputation ---
func adjust_reputation(planet: String, amount: int) -> void:
	if planet in reputation:
		reputation[planet] = clampi(reputation[planet] + amount, -100, 100)

func get_reputation(planet: String) -> int:
	return reputation.get(planet, 0)

func is_building_locked(planet: String, building: String) -> bool:
	var rep = get_reputation(planet)
	match building:
		"Bar":
			return rep < -50
		"Unique":
			return rep < -30
	return false

func get_price_discount(planet: String) -> float:
	var rep = get_reputation(planet)
	if rep >= 50:
		return 0.20
	elif rep >= 30:
		return 0.10
	return 0.0

# --- Dynamic Prices ---
const ALL_PLANETS: Array = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
const ALL_RESOURCES: Array = ["ore", "fuel", "parts", "ice", "crystals", "plasma"]

const PREMIUM_RESOURCES_T2: Array = ["antimatter", "biotech", "nanites"]
const PREMIUM_RESOURCES_T3: Array = ["dark_matter", "artifacts", "gravitonium"]
const PREMIUM_RESOURCES_T4: Array = ["void_essence", "starcore"]
const PREMIUM_REP_REQUIRED: Dictionary = {
	"antimatter": 25, "biotech": 25, "nanites": 25,
	"dark_matter": 50, "artifacts": 50, "gravitonium": 50,
	"void_essence": 75, "starcore": 75,
}
const T4_PLANET_LOCKS: Dictionary = {
	"void_essence": ["Pluto", "Neptune"],
	"starcore": ["Mercury", "Venus"],
}

const PLANET_PREMIUM_PRICES: Dictionary = {
	"Mercury": {"nanites": [80, 0], "gravitonium": [200, 0], "starcore": [350, 0], "antimatter": [0, 200], "biotech": [0, 180], "dark_matter": [0, 450], "artifacts": [0, 400], "void_essence": [0, 700]},
	"Venus": {"biotech": [90, 0], "artifacts": [180, 0], "starcore": [400, 0], "antimatter": [0, 180], "nanites": [0, 170], "dark_matter": [0, 400], "gravitonium": [0, 450], "void_essence": [0, 650]},
	"Earth": {"nanites": [100, 0], "antimatter": [0, 200], "biotech": [0, 160], "dark_matter": [0, 380], "artifacts": [0, 350], "gravitonium": [0, 400], "void_essence": [0, 600], "starcore": [0, 750]},
	"Mars": {"antimatter": [85, 0], "gravitonium": [220, 0], "biotech": [0, 190], "nanites": [0, 160], "dark_matter": [0, 420], "artifacts": [0, 380], "void_essence": [0, 680], "starcore": [0, 800]},
	"Jupiter": {"antimatter": [75, 0], "artifacts": [190, 0], "biotech": [0, 200], "nanites": [0, 180], "dark_matter": [0, 400], "gravitonium": [0, 480], "void_essence": [0, 720], "starcore": [0, 850]},
	"Saturn": {"biotech": [80, 0], "dark_matter": [200, 0], "antimatter": [0, 170], "nanites": [0, 150], "artifacts": [0, 420], "gravitonium": [0, 500], "void_essence": [0, 750], "starcore": [0, 900]},
	"Uranus": {"antimatter": [70, 0], "dark_matter": [180, 0], "biotech": [0, 210], "nanites": [0, 190], "artifacts": [0, 450], "gravitonium": [0, 470], "void_essence": [0, 700], "starcore": [0, 800]},
	"Neptune": {"biotech": [85, 0], "gravitonium": [210, 0], "void_essence": [380, 0], "antimatter": [0, 220], "nanites": [0, 200], "dark_matter": [0, 380], "artifacts": [0, 430], "starcore": [0, 850]},
	"Pluto": {"nanites": [90, 0], "artifacts": [170, 0], "void_essence": [300, 0], "antimatter": [0, 250], "biotech": [0, 230], "dark_matter": [0, 500], "gravitonium": [0, 480], "starcore": [0, 900]},
}

func get_available_premium_resources(planet: String) -> Array:
	var result: Array = []
	var rep = get_reputation(planet)
	var premium = PLANET_PREMIUM_PRICES.get(planet, {})
	for res in PREMIUM_RESOURCES_T2 + PREMIUM_RESOURCES_T3 + PREMIUM_RESOURCES_T4:
		if res not in premium:
			continue
		# Check T4 planet lock
		if res in T4_PLANET_LOCKS:
			if planet not in T4_PLANET_LOCKS[res]:
				continue
		var req_rep = PREMIUM_REP_REQUIRED.get(res, 0)
		if rep >= req_rep:
			result.append(res)
	return result

func randomize_prices_for_planet(planet: String) -> void:
	if planet not in dynamic_price_modifiers:
		dynamic_price_modifiers[planet] = {}
	for resource in ALL_RESOURCES:
		dynamic_price_modifiers[planet][resource] = randf_range(-0.10, 0.10)
	_planet_visit_count += 1
	_tick_price_events()
	_maybe_create_price_event()

const EVENT_PLANETS: Array = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
const EVENT_DURATION: float = 900.0
const EVENT_CHANCE: float = 0.20
const CAUSES: Dictionary = {
	"Mercury/ore": {"shortage": "Caloris Forge lost a smelter. What ore is left costs a fortune.", "glut": "Three ore haulers arrived at Mercury the same day. Nobody is paying for rock this week."},
	"Mercury/crystals": {"shortage": "Reyes cornered the pink crystal trade on Mercury for a project she will not explain. What is left prices like a favor.", "glut": "A crystal vein cracked open under Caloris. Mercury is drowning in the stuff."},
	"Venus/ore": {"shortage": "Cloudport Aphrodite is patching its shell after a pressure event. Venus is buying ore at any price.", "glut": "An ore hauler dumped its load over Venus rather than pay the docking tithe. Nobody there needs rock."},
	"Venus/fuel": {"shortage": "Lysandra's people are hoarding fuel. Venus pumps are dry to outsiders.", "glut": "A fuel barge broke up over Venus. Salvagers are dumping it cheap."},
	"Earth/parts": {"shortage": "Earth Defense grounded half its patrol for repairs. Parts are gold on Earth.", "glut": "A shipyard on Luna overproduced. Earth is flooded with parts."},
	"Earth/plasma": {"shortage": "New Shanghai's grid is running hot. Earth will pay for plasma.", "glut": "Earth reactors came back online early. Plasma is a drug on the market."},
	"Mars/parts": {"shortage": "A Tithe raid hit the Olympus Landing parts depot. Mars is desperate.", "glut": "Callahan's salvage yard cleared out its backlog. Parts are cheap on Mars."},
	"Mars/fuel": {"shortage": "Dust storms grounded the Mars tanker fleet. Fuel is short at Olympus.", "glut": "The Mars refinery finished its expansion. Fuel is plentiful there."},
	"Jupiter/ore": {"shortage": "Ganymede Docks ran out of hull plating stock. Jupiter wants ore.", "glut": "Jupiter's belt miners had a record month. Ore is piled on the docks."},
	"Jupiter/crystals": {"shortage": "A cutting rig failed on Ganymede and took the crystal stock with it. Jupiter is paying.", "glut": "Jupiter's cutters worked through the belt backlog. Ganymede has more crystals than it can move."},
	"Saturn/plasma": {"shortage": "Titan Labs is running an experiment that eats plasma. Saturn pays.", "glut": "Titan Labs shut a wing for review. Plasma is surplus on Saturn."},
	"Saturn/ice": {"shortage": "Titan Labs burned through its ice reserve on a cooling run. Saturn is paying for every block.", "glut": "An Enceladus hauler shed its load over Titan. Saturn has ice to spare."},
	"Uranus/fuel": {"shortage": "Miranda's Edge tankers went missing past the belt. Uranus is out of fuel.", "glut": "The Queenpin seized a smuggler's fuel stock. Uranus is selling it cheap."},
	"Uranus/plasma": {"shortage": "The Tithe has quietly taken every plasma cell on Uranus, for reasons nobody says aloud. What reaches the open market costs triple.", "glut": "A plasma convoy got turned away at Neptune and dumped on Uranus."},
	"Neptune/fuel": {"shortage": "Triton's geyser field iced over. Neptune is out of fuel.", "glut": "Neptune Defense released its fuel reserve. Cheap fuel on Triton."},
	"Neptune/crystals": {"shortage": "Ruiz's geyser probes need crystals. Neptune pays a premium.", "glut": "A crystal shipment meant for Pluto never left Neptune. Prices collapsed."},
	"Pluto/fuel": {"shortage": "Erebus Outpost has gone quiet and the fuel line with it. Pluto pays anything.", "glut": "Candle is giving fuel away on Pluto. Nobody knows why. Nobody asks."},
	"Pluto/ice": {"shortage": "Something on Pluto is melting the ice stores. Pluto wants ice.", "glut": "Pluto has more ice than it knows what to do with. It always did."},
}

func _generic_cause(kind: String, planet: String, resource: String) -> String:
	if kind == "shortage":
		return "%s is short on %s. Somebody will pay for it." % [planet, resource.capitalize()]
	return "%s has a glut of %s. Nobody there is buying." % [planet, resource.capitalize()]

## Drives event expiry from the world clock, so events end in flight and not only on landing.
func tick_events() -> void:
	_tick_price_events()

func _tick_price_events() -> void:
	var still_active: Array = []
	for event in price_events:
		if float(event.get("ends_at", 0.0)) > game_seconds:
			still_active.append(event)
		else:
			settle_stock(event["planet"])   # other goods relax to now while this one is still pinned
			_end_event(event)
	price_events = still_active

func _end_event(event: Dictionary) -> void:
	# stock is left where it is; normal recovery resumes on the next settle
	var f: Array = rumors.filter(func(r): return r.get("event_planet") == event["planet"] and r.get("event_resource") == event["resource"])
	for r in f:
		rumors.erase(r)

const RUMOR_TEMPLATES: Dictionary = {
	"shortage": ["They say %s is paying through the nose for %s.", "Heard %s ran dry on %s. Sellers' market.", "Word is %s will take all the %s you can carry."],
	"glut": ["They say %s is giving %s away.", "Heard %s is buried in %s. Don't bother selling it there.", "Word is %s cut its %s price to nothing."],
}

func _rumor_text(kind: String, planet: String, resource: String) -> String:
	var t: Array = RUMOR_TEMPLATES[kind]
	return t[randi() % t.size()] % [planet, resource.capitalize()]

## Each event seeds one true rumor and one lie of the same shape.
func _spawn_rumors_for(event: Dictionary) -> void:
	var kind: String = event["type"]
	rumors.append({"text": _rumor_text(kind, event["planet"], event["resource"]), "planet": event["planet"], "resource": event["resource"],
		"kind": kind, "is_true": true, "event_planet": event["planet"], "event_resource": event["resource"], "ends_at": event["ends_at"], "revealed": false})
	# One lie with the same shape about a different authored planet/good pair, so the lie is
	# still about a trade that exists somewhere — it just isn't happening.
	var pairs: Array = CAUSES.keys()
	var fp: String = event["planet"]
	var fr: String = event["resource"]
	var guard := 0
	while (fp == event["planet"] or fr == event["resource"]) and guard < 20:   # the lie differs on BOTH axes
		var kp: PackedStringArray = String(pairs[randi() % pairs.size()]).split("/")
		fp = kp[0]
		fr = kp[1]
		guard += 1
	rumors.append({"text": _rumor_text(kind, fp, fr), "planet": fp, "resource": fr, "kind": kind, "is_true": false,
		"event_planet": event["planet"], "event_resource": event["resource"], "ends_at": event["ends_at"], "revealed": false})
	# Cap at two events' worth (four lines). Evict the OLDEST PAIR together so a lie never
	# outlives the truth it was spawned with.
	while rumors.size() > 4:
		var oldest: Dictionary = rumors[0]
		for r in rumors:
			if float(r["ends_at"]) < float(oldest["ends_at"]):
				oldest = r
		var oldest_p: String = oldest["event_planet"]
		var oldest_r: String = oldest["event_resource"]
		rumors = rumors.filter(func(r): return not (r["event_planet"] == oldest_p and r["event_resource"] == oldest_r))
	# Shuffle so the true/false pairs are not visually adjacent on the board.
	rumors.shuffle()

func reveal_rumors() -> void:
	for r in rumors:
		r["revealed"] = true

func current_rumors() -> Array:
	return rumors.filter(func(r): return float(r.get("ends_at", 0.0)) > game_seconds)

func _maybe_create_price_event() -> void:
	var force_first: bool = price_events.is_empty() and not story_flag("first_market_event")
	if force_first or randf() < EVENT_CHANCE:
		if force_first:
			set_story_flags({"first_market_event": true})
		create_market_event()

func create_market_event(force_planet: String = "", force_resource: String = "", force_kind: String = "") -> Dictionary:
	# Unforced events draw from CAUSES, whose keys are the authored planet/good pairs. Every one
	# of them is tradeable at that planet; a random planet x resource roll is not. A half-forced
	# call still picks its other half from the pairs that match, so the good stays tradeable there.
	var planet: String = force_planet
	var resource: String = force_resource
	if planet == "" or resource == "":
		var candidates: Array = []
		for key in CAUSES:
			var kp: PackedStringArray = String(key).split("/")
			if (planet == "" or kp[0] == planet) and (resource == "" or kp[1] == resource):
				candidates.append(kp)
		if candidates.is_empty():
			return {}
		var pick: PackedStringArray = candidates[randi() % candidates.size()]
		planet = pick[0]
		resource = pick[1]
	if not _event_for(planet, resource).is_empty():
		return {}
	var kind: String = force_kind if force_kind != "" else ("shortage" if randf() < 0.5 else "glut")
	var key := "%s/%s" % [planet, resource]
	var cause: String = CAUSES.get(key, {}).get(kind, _generic_cause(kind, planet, resource))
	var extra: float = 300.0 * get_tree_effect("price_event_extra_visits")
	var event := {
		"type": kind, "planet": planet, "resource": resource, "cause": cause,
		"ends_at": game_seconds + EVENT_DURATION + extra, "announced": false, "near_announced": false,
	}
	settle_stock(planet)
	_set_stock(planet, resource, SHORTAGE_STOCK if kind == "shortage" else GLUT_STOCK)
	price_events.append(event)
	_spawn_rumors_for(event)
	add_log(cause, "event")
	market_event_created.emit(event)
	return event

## Freighter arrivals and other supply pushes.
func deliver_stock(planet: String, resource: String, amount: float) -> void:
	settle_stock(planet)
	_set_stock(planet, resource, get_stock(planet, resource) + amount)
	_check_event_resolution(planet, resource)

## Returns true if there was an active shortage to extend.
func extend_shortage(planet: String, resource: String, seconds: float) -> bool:
	var e := _event_for(planet, resource)
	if not e.is_empty() and e["type"] == "shortage":
		e["ends_at"] = float(e["ends_at"]) + seconds
		return true
	return false

func active_shortages() -> Array:
	return price_events.filter(func(e): return e["type"] == "shortage")

const TITHE_PLANETS: Array = ["Uranus", "Pluto"]
const TITHE_WANTS: Dictionary = {"plasma": 1.25, "void_essence": 1.25, "dark_matter": 1.25}
const TITHE_SHUNS: Dictionary = {"biotech": 0.8, "parts": 0.8}

func faction_factor(planet: String, resource: String, is_sell: bool) -> float:
	if not is_sell or planet not in TITHE_PLANETS:
		return 1.0
	if resource in TITHE_WANTS:
		return TITHE_WANTS[resource]
	if resource in TITHE_SHUNS:
		return TITHE_SHUNS[resource]
	return 1.0

func get_effective_price(planet: String, resource: String, base_price: int, is_sell: bool = false) -> int:
	if base_price <= 0:
		return 0
	var modifier: float = 0.0
	if planet in dynamic_price_modifiers and resource in dynamic_price_modifiers[planet]:
		modifier += dynamic_price_modifiers[planet][resource]
	var price := float(base_price) * (1.0 + modifier)
	price *= stock_factor(planet, resource)
	price *= faction_factor(planet, resource, is_sell)
	return max(1, int(price))

func update_price_memory(planet: String, prices: Dictionary) -> void:
	price_memory[planet] = {}
	for resource in prices:
		var base_buy = prices[resource][0]
		var base_sell = prices[resource][1]
		price_memory[planet][resource] = [
			get_effective_price(planet, resource, base_buy),
			get_effective_price(planet, resource, base_sell, true),
		]

# --- Elastic stock ---
func get_stock(planet: String, resource: String) -> float:
	return market_stock.get(planet, {}).get(resource, 1.0)

func _set_stock(planet: String, resource: String, value: float) -> void:
	if planet not in market_stock:
		market_stock[planet] = {}
	market_stock[planet][resource] = clampf(value, 0.0, 2.0)

func _event_for(planet: String, resource: String) -> Dictionary:
	for e in price_events:
		if e["planet"] == planet and e["resource"] == resource:
			return e
	return {}

## Lazily relax every good at a planet toward 1.0 by the time elapsed since its last settle.
## Goods under an active shortage/glut are pinned until the event ends.
func settle_stock(planet: String) -> void:
	var last: float = market_stock_time.get(planet, game_seconds)
	var dt: float = maxf(game_seconds - last, 0.0)
	market_stock_time[planet] = game_seconds
	if dt <= 0.0 or planet not in market_stock:
		return
	var relax: float = 1.0 - exp(-dt / STOCK_TAU)
	for resource in market_stock[planet].keys():
		if not _event_for(planet, resource).is_empty():
			continue
		var s: float = market_stock[planet][resource]
		market_stock[planet][resource] = s + (1.0 - s) * relax

func stock_factor(planet: String, resource: String) -> float:
	return clampf(1.0 + STOCK_K * (1.0 - get_stock(planet, resource)), STOCK_FLOOR, STOCK_CEIL)

## Called by the market after each unit traded. units > 0 bought from the planet, < 0 sold to it.
func record_trade(planet: String, resource: String, units: int) -> void:
	settle_stock(planet)
	_set_stock(planet, resource, get_stock(planet, resource) - STOCK_STEP * units)
	_check_event_resolution(planet, resource)

## Shortage/glut events resolve once stock crosses back over the resolve threshold.
func _check_event_resolution(planet: String, resource: String) -> void:
	var e := _event_for(planet, resource)
	if e.is_empty():
		return
	var s := get_stock(planet, resource)
	if (e["type"] == "shortage" and s >= SHORTAGE_RESOLVES_AT) or (e["type"] == "glut" and s <= GLUT_RESOLVES_AT):
		price_events.erase(e)
		_end_event(e)
		add_log("%s: the %s %s is over." % [planet, resource.capitalize(), e["type"]], "event")

## Thresholds mirror the event constants: SCARCE covers the SHORTAGE_STOCK (0.2) pin,
## LOW runs up to SHORTAGE_RESOLVES_AT (0.8), PLENTY starts past GLUT_RESOLVES_AT (1.2),
## and GLUT covers the GLUT_STOCK (1.8) pin.
func supply_word(planet: String, resource: String) -> String:
	var s := get_stock(planet, resource)
	if s < 0.5: return "SCARCE"
	if s < 0.8: return "LOW"
	if s > 1.7: return "GLUT"
	if s > 1.3: return "PLENTY"
	return ""

func has_crew(crew_type: String) -> bool:
	return crew_type in crew_members

# --- Weapon Mod Functions ---
func purchase_mod(mod_name: String) -> bool:
	if mod_name not in MOD_DATA:
		return false
	if mod_name in owned_mods:
		return false
	var data = MOD_DATA[mod_name]
	if data["rare"]:
		return false  # can't buy rare mods
	if money < data["cost"]:
		return false
	money -= data["cost"]
	owned_mods.append(mod_name)
	return true

func equip_mod(mod_name: String) -> bool:
	if mod_name in owned_mods:
		equipped_mod = mod_name
		return true
	return false

func unequip_mod() -> void:
	equipped_mod = ""

# --- Quest System ---
const CHAIN_QUESTS: Dictionary = {
	"Mercury": {"desc": "Salvage black box near Mercury, deliver to Earth", "steps": [{"type": "visit", "planet": "Mercury"}, {"type": "deliver_to", "planet": "Earth"}], "reward": 2000},
	"Venus": {"desc": "Smuggle data chip from Venus to Uranus", "steps": [{"type": "visit", "planet": "Venus"}, {"type": "deliver_to", "planet": "Uranus"}], "reward": 2500},
	"Earth": {"desc": "Deliver medical supplies to Neptune", "steps": [{"type": "visit", "planet": "Earth"}, {"type": "deliver_to", "planet": "Neptune"}], "reward": 1800},
	"Mars": {"desc": "Retrieve trophy from Mars, deliver to Jupiter", "steps": [{"type": "visit", "planet": "Mars"}, {"type": "deliver_to", "planet": "Jupiter"}], "reward": 2000},
	"Jupiter": {"desc": "Transport volatile fuel to Saturn", "steps": [{"type": "visit", "planet": "Jupiter"}, {"type": "deliver_to", "planet": "Saturn"}], "reward": 2200},
	"Saturn": {"desc": "Deliver experimental tech to Mercury", "steps": [{"type": "visit", "planet": "Saturn"}, {"type": "deliver_to", "planet": "Mercury"}], "reward": 2000},
	"Uranus": {"desc": "Move contraband to Venus", "steps": [{"type": "visit", "planet": "Uranus"}, {"type": "deliver_to", "planet": "Venus"}], "reward": 2500},
	"Neptune": {"desc": "Carry ice samples to Earth", "steps": [{"type": "visit", "planet": "Neptune"}, {"type": "deliver_to", "planet": "Earth"}], "reward": 1800},
}

func generate_quests_for_planet(planet: String) -> void:
	available_quests = []
	var count = randi_range(2, 3)
	for i in range(count):
		if randf() < 0.5:
			available_quests.append(_generate_deliver_quest(planet))
		else:
			available_quests.append(_generate_kill_quest(planet))
	if planet in CHAIN_QUESTS and planet not in completed_quests:
		var chain = CHAIN_QUESTS[planet].duplicate(true)
		chain["id"] = "chain_" + planet
		chain["type"] = "chain"
		chain["origin"] = planet
		chain["step"] = 0
		available_quests.append(chain)

func _generate_deliver_quest(origin: String) -> Dictionary:
	# Only target outer planets for longer, more rewarding runs
	var outer_planets: Array = ["Jupiter", "Saturn", "Uranus", "Neptune"]
	var inner_planets: Array = ["Mercury", "Venus", "Earth", "Mars"]
	# If origin is inner, target outer. If origin is outer, target inner. Keeps routes interesting.
	var pool: Array
	if origin in outer_planets:
		pool = inner_planets.filter(func(p): return p != origin)
	else:
		pool = outer_planets.filter(func(p): return p != origin)
	if pool.is_empty():
		pool = ALL_PLANETS.filter(func(p): return p != origin)
	var target = pool[randi() % pool.size()]
	var resource = ALL_RESOURCES[randi() % ALL_RESOURCES.size()]
	var amount = randi_range(2, 5)
	var reward = 400 + amount * 150 + randi_range(0, 300)
	return {
		"id": "deliver_%d" % randi(),
		"type": "deliver",
		"desc": "Haul %d %s to %s" % [amount, resource.capitalize(), target],
		"resource": resource,
		"amount": amount,
		"target_planet": target,
		"reward": reward,
		"origin": origin,
	}

func _generate_kill_quest(origin: String) -> Dictionary:
	var targets = ALL_PLANETS.filter(func(p): return p != origin)
	var target = targets[randi() % targets.size()]
	var count = randi_range(3, 7)
	var reward = 600 + count * 120 + randi_range(0, 400)
	return {
		"id": "kill_%d" % randi(),
		"type": "kill",
		"desc": "Destroy %d enemies near %s" % [count, target],
		"target_planet": target,
		"kill_target": count,
		"kills": 0,
		"reward": reward,
		"origin": origin,
	}

func accept_quest(quest: Dictionary) -> bool:
	if active_quests.size() >= 3:
		return false
	active_quests.append(quest)
	return true

func check_quest_completion(planet: String) -> Array:
	var completed: Array = []
	for quest in active_quests:
		match quest["type"]:
			"deliver":
				if quest["target_planet"] == planet:
					if cargo.get(quest["resource"], 0) >= quest["amount"]:
						remove_cargo(quest["resource"], quest["amount"])
						completed.append(quest)
			"chain":
				var step = quest.get("step", 0)
				var steps = quest.get("steps", [])
				if step < steps.size() and steps[step].get("type") == "deliver_to" and steps[step].get("planet") == planet:
					quest["step"] += 1
					if quest["step"] >= steps.size():
						completed.append(quest)
			"kill":
				pass  # Kill quests auto-complete in record_kill_near_planet()
	for quest in completed:
		active_quests.erase(quest)
		add_money(quest["reward"])
		add_xp(quest.get("xp_reward", 200))
		var target = quest.get("target_planet", planet)
		adjust_reputation(target, 10)
		if quest["type"] == "chain":
			completed_quests.append(quest["origin"])
	# Also check NPC quest completion
	var npc_completed: Array = []
	for npc_quest in npc_active_quests:
		match npc_quest.get("type", ""):
			"fetch":
				if cargo.get(npc_quest.get("target", ""), 0) >= npc_quest.get("amount", 0):
					remove_cargo(npc_quest["target"], npc_quest["amount"])
					npc_completed.append(npc_quest)
			"kill":
				if npc_quest.get("progress", 0) >= npc_quest.get("amount", 0):
					npc_completed.append(npc_quest)
			"deliver":
				if npc_quest.get("target", "") == planet:
					npc_completed.append(npc_quest)
	for npc_quest in npc_completed:
		var qid: String = npc_quest.get("quest_id", npc_quest["npc_id"])
		complete_npc_quest(qid, npc_quest.get("reward_money", 0), npc_quest.get("xp_reward", 300))
		if npc_quest.get("reward_powerup", "") != "":
			npc_powerups[npc_quest["reward_powerup"]] = true
		if npc_quest.has("set_flags"):
			set_story_flags(npc_quest["set_flags"])
		if npc_quest.get("log", "") != "":
			add_log(npc_quest["log"], "story")
		completed.append({"reward": npc_quest.get("reward_money", 0), "type": "npc", "desc": npc_quest.get("reward_desc", "")})
	return completed

func record_kill_near_planet(planet_name: String) -> void:
	var completed_kills: Array = []
	for quest in active_quests:
		if quest["type"] == "kill" and quest["target_planet"] == planet_name:
			quest["kills"] += 1
			if quest["kills"] >= quest["kill_target"]:
				completed_kills.append(quest)
	for quest in completed_kills:
		active_quests.erase(quest)
		add_money(quest["reward"])
		add_xp(quest.get("xp_reward", 200))
		adjust_reputation(quest.get("target_planet", planet_name), 10)
	# Also track NPC kill quests (any kill counts, not planet-specific)
	var npc_completed_kills: Array = []
	for npc_quest in npc_active_quests:
		if npc_quest.get("type", "") == "kill":
			npc_quest["progress"] = npc_quest.get("progress", 0) + 1
			if npc_quest["progress"] >= npc_quest.get("amount", 0):
				npc_completed_kills.append(npc_quest)
	for npc_quest in npc_completed_kills:
		npc_active_quests.erase(npc_quest)
		add_money(npc_quest.get("reward", 500))
		add_xp(npc_quest.get("xp_reward", 300))

# --- Bounty System ---
func generate_bounties() -> Array:
	var bounties = []
	var used_names: Array = []
	for i in range(3):
		# Pick a unique name for each bounty
		var name_pick = BOUNTY_NAMES[randi() % BOUNTY_NAMES.size()]
		var attempts = 0
		while name_pick in used_names and attempts < 10:
			name_pick = BOUNTY_NAMES[randi() % BOUNTY_NAMES.size()]
			attempts += 1
		used_names.append(name_pick)
		var planet = ALL_PLANETS[randi() % ALL_PLANETS.size()]
		var reward = randi_range(1500, 4000)
		bounties.append({"name": name_pick, "planet": planet, "reward": reward})
	return bounties

func accept_bounty(bounty: Dictionary) -> bool:
	if active_bounty.size() > 0:
		return false
	active_bounty = bounty
	return true

func complete_bounty() -> int:
	if active_bounty.size() == 0:
		return 0
	var reward = active_bounty["reward"]
	var bounty_name = active_bounty.get("name", "Unknown")
	var planet = active_bounty.get("planet", "")
	add_money(reward)
	adjust_reputation(planet, 15)
	add_log("Bounty collected: %s near %s. +$%d." % [bounty_name, planet, reward], "combat")
	active_bounty = {}
	return reward

# --- Crew Hire ---
func hire_crew(crew_type: String) -> bool:
	if crew_type not in CREW_DATA:
		return false
	if crew_members.size() >= crew_slots:
		return false
	if crew_type in crew_members:
		return false
	var cost = CREW_DATA[crew_type]["cost"]
	if money < cost:
		return false
	money -= cost
	crew_members.append(crew_type)
	add_log("Hired crew: %s." % crew_type.capitalize(), "upgrade")
	return true

func get_available_crew() -> Array:
	var pool = CREW_DATA.keys().filter(func(c): return c not in crew_members)
	pool.shuffle()
	return pool.slice(0, min(2, pool.size()))

func lose_life() -> bool:
	lives -= 1
	return lives > 0

# --- XP / Leveling ---
func xp_for_level(lvl: int) -> int:
	if lvl <= 0 or lvl >= MAX_LEVEL:
		return 999999
	if lvl <= 10:
		return 100 + (lvl - 1) * 33
	elif lvl <= 20:
		return 500 + (lvl - 11) * 78
	elif lvl <= 30:
		return 1500 + (lvl - 21) * 222
	elif lvl <= 40:
		return 4000 + (lvl - 31) * 444
	else:
		return 9000 + (lvl - 41) * 667

func add_xp(amount: int) -> void:
	if level >= MAX_LEVEL:
		return
	xp += amount
	xp_gained.emit(amount)
	while xp >= xp_for_level(level) and level < MAX_LEVEL:
		xp -= xp_for_level(level)
		level += 1
		_on_level_up()

## Skill-tree on-kill effects shared by every enemy death (fuel, hp, resource drop).
func apply_kill_effects() -> void:
	var tree_fuel := get_tree_effect("fuel_restore_on_kill")
	if tree_fuel > 0:
		ship_fuel = min(ship_fuel + ship_max_fuel * tree_fuel, ship_max_fuel)
	var tree_hp := int(get_tree_effect("hp_on_kill"))
	if tree_hp > 0:
		ship_hp = min(ship_hp + tree_hp, ship_max_hp)
	if randf() < get_tree_effect("resource_drop_on_kill"):
		var resources := ["ore", "parts", "ice", "crystals"]
		add_cargo(resources[randi() % resources.size()], 1)

func _on_level_up() -> void:
	if level <= 10:
		ship_max_hp += 2
		weapon_damage_bonus_pct += 0.01
	elif level <= 20:
		ship_max_hp += 3
		weapon_damage_bonus_pct += 0.01
	elif level <= 30:
		ship_max_hp += 4
		weapon_damage_bonus_pct += 0.02
	elif level <= 40:
		ship_max_hp += 5
		weapon_damage_bonus_pct += 0.02
	else:
		ship_max_hp += 5
		weapon_damage_bonus_pct += 0.03
	if level % SKILL_POINT_INTERVAL == 0:
		skill_points += 1
	add_log("Reached Level %d." % level, "progress")
	level_up.emit(level)

# --- Skill Tree ---
func unlock_node(node_id: String) -> bool:
	if not SkillTreeData.can_unlock(node_id, unlocked_nodes, skill_points, cargo):
		return false
	var node: Dictionary = SkillTreeData.NODES[node_id]
	skill_points -= node["cost_points"]
	for resource in node["cost_resources"]:
		cargo[resource] -= node["cost_resources"][resource]
	unlocked_nodes.append(node_id)
	_apply_node_effects(node_id)
	return true

func _apply_node_effects(node_id: String) -> void:
	var effects: Dictionary = SkillTreeData.get_node_effect_value(node_id)
	if effects.has("max_hp_flat"):
		ship_max_hp += effects["max_hp_flat"]
		ship_hp = min(ship_hp + effects["max_hp_flat"], ship_max_hp)
	if effects.has("cargo_capacity_flat"):
		cargo_capacity += effects["cargo_capacity_flat"]

func get_tree_effect(key: String) -> float:
	var total: float = 0.0
	for node_id in unlocked_nodes:
		var effects: Dictionary = SkillTreeData.get_node_effect_value(node_id)
		if effects.has(key):
			var val = effects[key]
			if val is float or val is int:
				total += val
	return total

func has_tree_effect(key: String) -> bool:
	for node_id in unlocked_nodes:
		var effects: Dictionary = SkillTreeData.get_node_effect_value(node_id)
		if effects.has(key) and effects[key]:
			return true
	return false

# --- NPC Quest/Trade Helpers ---

func is_npc_quest_complete(quest_id: String) -> bool:
	return quest_id in npc_completed_quests

func complete_npc_quest(quest_id: String, reward_money: int, xp_reward: int = 300) -> void:
	if quest_id not in npc_completed_quests:
		npc_completed_quests.append(quest_id)
	npc_active_quests = npc_active_quests.filter(func(q): return q.get("quest_id", q.get("npc_id", "")) != quest_id)
	add_money(reward_money)
	add_xp(xp_reward)

func accept_npc_quest(quest: Dictionary) -> bool:
	npc_active_quests.append(quest)
	return true

func npc_trade(npc_id: String, resource: String, amount: int, powerup: String) -> bool:
	if cargo.get(resource, 0) < amount:
		return false
	remove_cargo(resource, amount)
	# Special powerup: extra_life grants +1 life (repeatable, max 7)
	if powerup == "extra_life":
		if lives < 7:
			lives += 1
	else:
		npc_powerups[powerup] = true
	if npc_id not in npc_completed_trades:
		npc_completed_trades[npc_id] = 0
	npc_completed_trades[npc_id] += 1
	return true

func reset() -> void:
	cargo = {"ore": 0, "fuel": 0, "parts": 0, "ice": 0, "crystals": 0, "plasma": 0, "antimatter": 0, "biotech": 0, "nanites": 0, "dark_matter": 0, "artifacts": 0, "gravitonium": 0, "void_essence": 0, "starcore": 0}
	cargo_capacity = 10
	money = 200
	lives = 3
	ship_speed = 100.0
	ship_max_hp = 100
	ship_hp = 100
	weapon_damage = 25
	ship_fuel = 100.0
	ship_max_fuel = 100.0
	fuel_rescue_used = false
	current_planet = ""
	current_planet_prices = {}
	ship_position = Vector2.ZERO
	ship_facing = 0.0
	planet_orbit_angles = {}
	upgrade_levels = {"engine": 0, "shield": 0, "cargo": 0, "weapon": 0, "fuel_tank": 0}
	current_weapon = "blaster"
	owned_weapons = ["blaster"]
	owned_abilities = []
	boss_tiers_defeated = []
	boss_tiers_cleared = []
	ship_hull_color = Color(0.55, 0.6, 0.65)
	ship_accent_color = Color(0.2, 0.5, 0.8)
	ship_engine_color = Color(0.3, 0.7, 1.0)
	game_active = false
	# New state resets
	cargo_insurance = false
	reputation = {
		"Mercury": 0, "Venus": 0, "Earth": 0, "Mars": 0,
		"Jupiter": 0, "Saturn": 0, "Uranus": 0, "Neptune": 0,
		"Pluto": 0,
	}
	dynamic_price_modifiers = {}
	price_events = []
	_planet_visit_count = 0
	price_memory = {}
	game_seconds = 0.0
	market_stock = {}
	market_stock_time = {}
	rumors = []
	crew_members = []
	crew_slots = 3
	active_quests = []
	completed_quests = []
	available_quests = []
	active_bounty = {}
	owned_mods = []
	equipped_mod = ""
	npc_active_quests = []
	npc_completed_quests = []
	npc_completed_trades = {}
	npc_powerups = {}
	story_flags = STORY_FLAG_DEFAULTS.duplicate()
	ship_log = []
	# XP / Leveling
	xp = 0
	level = 1
	skill_points = 0
	unlocked_nodes = []
	weapon_damage_bonus_pct = 0.0
	last_stand_used = false
	emergency_reserves_cooldown = 0.0
	# Apply prestige bonuses
	_apply_prestige_bonuses()

func _apply_prestige_bonuses() -> void:
	money += prestige_bonuses["extra_money"] * 100
	cargo_capacity += prestige_bonuses["extra_cargo"]
	crew_slots += prestige_bonuses["extra_crew_slots"]
	ship_max_fuel += prestige_bonuses["extra_fuel"] * 10.0
	ship_fuel = ship_max_fuel
	if prestige_bonuses["start_dash"]:
		owned_abilities.append("dash")

func purchase_prestige_bonus(bonus_name: String) -> bool:
	if prestige_tokens <= 0:
		return false
	match bonus_name:
		"extra_money", "extra_cargo", "extra_fuel":
			prestige_tokens -= 1
			prestige_bonuses[bonus_name] += 1
			return true
		"extra_crew_slots":
			if prestige_bonuses["extra_crew_slots"] >= 2:
				return false
			prestige_tokens -= 1
			prestige_bonuses["extra_crew_slots"] += 1
			return true
		"start_dash":
			if prestige_bonuses["start_dash"]:
				return false
			prestige_tokens -= 1
			prestige_bonuses["start_dash"] = true
			return true
	return false

# ============================================================
# SAVE / LOAD SYSTEM
# ============================================================
const SAVE_PATH: String = "user://savegame.json"
const PRESTIGE_PATH: String = "user://prestige.json"
const SETTINGS_PATH: String = "user://settings.json"

# --- Settings (persist independently) ---
var settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"tutorial_seen": false,
}

func save_game() -> bool:
	var data: Dictionary = {
		"version": 1,
		# Core
		"cargo": cargo.duplicate(),
		"cargo_capacity": cargo_capacity,
		"money": money,
		"lives": lives,
		# Ship
		"ship_speed": ship_speed,
		"ship_max_hp": ship_max_hp,
		"ship_hp": ship_hp,
		"weapon_damage": weapon_damage,
		"ship_fuel": ship_fuel,
		"ship_max_fuel": ship_max_fuel,
		"fuel_rescue_used": fuel_rescue_used,
		"ship_position": [ship_position.x, ship_position.y],
		"ship_facing": ship_facing,
		# Paint
		"ship_hull_color": _color_to_array(ship_hull_color),
		"ship_accent_color": _color_to_array(ship_accent_color),
		"ship_engine_color": _color_to_array(ship_engine_color),
		# Upgrades & Weapons
		"upgrade_levels": upgrade_levels.duplicate(),
		"current_weapon": current_weapon,
		"owned_weapons": owned_weapons.duplicate(),
		"owned_abilities": owned_abilities.duplicate(),
		"owned_mods": owned_mods.duplicate(),
		"equipped_mod": equipped_mod,
		# Progression
		"boss_tiers_defeated": boss_tiers_defeated.duplicate(),
		"boss_tiers_cleared": boss_tiers_cleared.duplicate(),
		"xp": xp,
		"level": level,
		"skill_points": skill_points,
		"unlocked_nodes": unlocked_nodes.duplicate(),
		"weapon_damage_bonus_pct": weapon_damage_bonus_pct,
		# Reputation & Economy
		"reputation": reputation.duplicate(),
		"dynamic_price_modifiers": dynamic_price_modifiers.duplicate(true),
		"price_events": price_events.duplicate(true),
		"price_memory": price_memory.duplicate(true),
		"game_seconds": game_seconds,
		"market_stock": market_stock.duplicate(true),
		"market_stock_time": market_stock_time.duplicate(true),
		"rumors": rumors.duplicate(true),
		# Crew
		"crew_members": crew_members.duplicate(),
		"crew_slots": crew_slots,
		# Quests
		"active_quests": active_quests.duplicate(true),
		"completed_quests": completed_quests.duplicate(),
		"active_bounty": active_bounty.duplicate(),
		# NPC
		"npc_active_quests": npc_active_quests.duplicate(true),
		"npc_completed_quests": npc_completed_quests.duplicate(),
		"npc_completed_trades": npc_completed_trades.duplicate(),
		"npc_powerups": npc_powerups.duplicate(),
		"story_flags": story_flags.duplicate(),
		# Planet context
		"current_planet": current_planet,
		"planet_orbit_angles": planet_orbit_angles.duplicate(),
		# Insurance
		"cargo_insurance": cargo_insurance,
		# Captain's Log
		"ship_log": ship_log.duplicate(true),
		# State
		"game_active": game_active,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save game: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	save_prestige()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK:
		push_error("Failed to parse save file")
		return false
	var data: Dictionary = json.data
	if not data is Dictionary:
		return false
	# Core
	cargo = _dict_with_defaults(data.get("cargo", {}), cargo)
	cargo_capacity = int(data.get("cargo_capacity", 10))
	money = int(data.get("money", 200))
	lives = int(data.get("lives", 3))
	# Ship
	ship_speed = float(data.get("ship_speed", 100.0))
	ship_max_hp = int(data.get("ship_max_hp", 100))
	ship_hp = int(data.get("ship_hp", 100))
	weapon_damage = int(data.get("weapon_damage", 25))
	ship_fuel = float(data.get("ship_fuel", 100.0))
	ship_max_fuel = float(data.get("ship_max_fuel", 100.0))
	fuel_rescue_used = data.get("fuel_rescue_used", false)
	var pos = data.get("ship_position", [0, 0])
	ship_position = Vector2(pos[0], pos[1]) if pos is Array else Vector2.ZERO
	ship_facing = float(data.get("ship_facing", 0.0))
	# Paint
	ship_hull_color = _array_to_color(data.get("ship_hull_color", [0.55, 0.6, 0.65]))
	ship_accent_color = _array_to_color(data.get("ship_accent_color", [0.2, 0.5, 0.8]))
	ship_engine_color = _array_to_color(data.get("ship_engine_color", [0.3, 0.7, 1.0]))
	# Upgrades & Weapons
	upgrade_levels = _dict_with_defaults(data.get("upgrade_levels", {}), {"engine": 0, "shield": 0, "cargo": 0, "weapon": 0, "fuel_tank": 0})
	current_weapon = data.get("current_weapon", "blaster")
	owned_weapons = _ensure_array(data.get("owned_weapons", ["blaster"]))
	owned_abilities = _ensure_array(data.get("owned_abilities", []))
	owned_mods = _ensure_array(data.get("owned_mods", []))
	equipped_mod = data.get("equipped_mod", "")
	# Progression
	# JSON restores numbers as floats, and `2 in [2.0]` is false in GDScript, so both
	# tier lists must come back as ints: otherwise money bosses respawn every load and
	# the Phobos gate reseals.
	boss_tiers_defeated = _ensure_int_array(data.get("boss_tiers_defeated", []))
	boss_tiers_cleared = _ensure_int_array(data.get("boss_tiers_cleared", []))
	if not data.has("boss_tiers_cleared"):
		boss_tiers_cleared = boss_tiers_defeated.duplicate()   # pre-pilot saves only knew "spawned"; treat as cleared so Phobos can open
	xp = int(data.get("xp", 0))
	level = int(data.get("level", 1))
	skill_points = int(data.get("skill_points", 0))
	unlocked_nodes = _ensure_array(data.get("unlocked_nodes", []))
	weapon_damage_bonus_pct = float(data.get("weapon_damage_bonus_pct", 0.0))
	# Reputation & Economy
	reputation = _dict_with_defaults(data.get("reputation", {}), {"Mercury": 0, "Venus": 0, "Earth": 0, "Mars": 0, "Jupiter": 0, "Saturn": 0, "Uranus": 0, "Neptune": 0, "Pluto": 0})
	dynamic_price_modifiers = _ensure_dict(data.get("dynamic_price_modifiers", {}))
	price_memory = _ensure_dict(data.get("price_memory", {}))
	# game_seconds must land before the price_events conversion below: old saves get an
	# ends_at relative to the restored clock.
	game_seconds = float(data.get("game_seconds", 0.0))
	market_stock = _ensure_dict(data.get("market_stock", {}))
	market_stock_time = _ensure_dict(data.get("market_stock_time", {}))
	price_events = _ensure_array(data.get("price_events", []))
	var converted: Array = []
	for e in price_events:
		# A corrupt or hand-edited save can hold non-dictionaries here; drop them rather than
		# crash on .has()/[] below.
		if e is Dictionary and e.has("visits_remaining"):   # pre-elastic save
			var kind := "shortage" if e.get("type", "") == "boom" else "glut"
			converted.append({"type": kind, "planet": e["planet"], "resource": e["resource"],
				"cause": _generic_cause(kind, e["planet"], e["resource"]),
				"ends_at": game_seconds + 600.0, "announced": true, "near_announced": true})
		elif e is Dictionary:
			e["ends_at"] = float(e.get("ends_at", 0.0))
			converted.append(e)
	price_events = converted
	rumors = _ensure_array(data.get("rumors", []))
	# Crew
	crew_members = _ensure_array(data.get("crew_members", []))
	crew_slots = int(data.get("crew_slots", 1))
	# Quests
	active_quests = _ensure_array(data.get("active_quests", []))
	completed_quests = _ensure_array(data.get("completed_quests", []))
	active_bounty = data.get("active_bounty", {})
	# NPC
	npc_active_quests = _ensure_array(data.get("npc_active_quests", []))
	npc_completed_quests = _ensure_array(data.get("npc_completed_quests", []))
	npc_completed_trades = data.get("npc_completed_trades", {})
	npc_powerups = data.get("npc_powerups", {})
	story_flags = _dict_with_defaults(data.get("story_flags", {}), STORY_FLAG_DEFAULTS)
	story_flags["signal_step"] = int(story_flags.get("signal_step", 0))   # JSON restores numbers as floats
	# Planet context
	current_planet = data.get("current_planet", "")
	planet_orbit_angles = data.get("planet_orbit_angles", {})
	# Insurance
	cargo_insurance = data.get("cargo_insurance", false)
	# Captain's Log
	ship_log = _ensure_array(data.get("ship_log", []))
	# State
	game_active = data.get("game_active", false)
	# Reset transient state
	last_stand_used = false
	emergency_reserves_cooldown = 0.0
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func save_prestige() -> void:
	var data: Dictionary = {
		"prestige_level": prestige_level,
		"prestige_tokens": prestige_tokens,
		"prestige_bonuses": prestige_bonuses.duplicate(),
	}
	var file = FileAccess.open(PRESTIGE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_prestige() -> void:
	if not FileAccess.file_exists(PRESTIGE_PATH):
		return
	var file = FileAccess.open(PRESTIGE_PATH, FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()
	var data = json.data
	if not data is Dictionary:
		return
	prestige_level = int(data.get("prestige_level", 0))
	prestige_tokens = int(data.get("prestige_tokens", 0))
	var bonuses = data.get("prestige_bonuses", {})
	for key in prestige_bonuses:
		if key in bonuses:
			prestige_bonuses[key] = bonuses[key]

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()
	var data = json.data
	if not data is Dictionary:
		return
	for key in settings:
		if key in data:
			settings[key] = data[key]
	_apply_settings()

func _apply_settings() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(settings["master_volume"]))
	# Music and SFX buses (create if needed, or use Master for now)
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# --- Serialization helpers ---
func _color_to_array(c: Color) -> Array:
	return [c.r, c.g, c.b, c.a]

func _array_to_color(a) -> Color:
	if a is Array and a.size() >= 3:
		return Color(a[0], a[1], a[2], a[3] if a.size() > 3 else 1.0)
	return Color.WHITE

func _dict_with_defaults(loaded: Dictionary, defaults: Dictionary) -> Dictionary:
	var result = defaults.duplicate()
	for key in loaded:
		if key in result:
			result[key] = loaded[key]
	return result

func _ensure_array(val) -> Array:
	if val is Array:
		return val
	return []

func _ensure_dict(val) -> Dictionary:
	return val if val is Dictionary else {}

func _ensure_int_array(val) -> Array:
	var out: Array = []
	if val is Array:
		for v in val:
			if v is int:
				out.append(v)
			elif v is float:
				out.append(int(v))
			elif v is String and v.is_valid_int():
				out.append(v.to_int())
	return out
