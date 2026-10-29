# skill_tree_data.gd
# Pure data class — all 31 upgrade web node definitions, adjacency graph,
# unlock validation, and effect lookups. No state, no UI.
class_name SkillTreeData
extends RefCounted

# ---------------------------------------------------------------------------
# Node definitions
# Each entry: id (key), name, cluster, effect_desc, cost_points,
#             cost_resources (Dictionary resource_id -> amount),
#             requires (Array of prerequisite node IDs)
# ---------------------------------------------------------------------------
const NODES: Dictionary = {
	# -----------------------------------------------------------------------
	# CENTER
	# -----------------------------------------------------------------------
	"spacer": {
		"name": "Spacer",
		"cluster": "center",
		"effect_desc": "+10 max HP, +5% damage",
		"cost_points": 0,
		"cost_resources": {},
		"requires": [],
	},

	# -----------------------------------------------------------------------
	# COMBAT CLUSTER
	# -----------------------------------------------------------------------
	"sharp_shooter": {
		"name": "Sharpshooter",
		"cluster": "combat",
		"effect_desc": "+15% weapon damage",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["spacer"],
	},
	"quick_draw": {
		"name": "Quick Draw",
		"cluster": "combat",
		"effect_desc": "-10% weapon cooldown",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["sharp_shooter"],
	},
	"critical_systems": {
		"name": "Critical Systems",
		"cluster": "combat",
		"effect_desc": "8% crit chance (2x damage)",
		"cost_points": 1,
		"cost_resources": {"crystals": 5},
		"requires": ["sharp_shooter"],
	},
	"blaster_mastery": {
		"name": "Blaster Mastery",
		"cluster": "combat",
		"effect_desc": "Blaster shots pierce 1 enemy",
		"cost_points": 1,
		"cost_resources": {"parts": 3},
		"requires": ["quick_draw"],
	},
	"laser_mastery": {
		"name": "Laser Mastery",
		"cluster": "combat",
		"effect_desc": "Laser beam widens into cone",
		"cost_points": 2,
		"cost_resources": {"plasma": 3, "crystals": 2},
		"requires": ["quick_draw"],
	},
	"spread_mastery": {
		"name": "Spread Mastery",
		"cluster": "combat",
		"effect_desc": "Spread fires 7 shots in tighter cone",
		"cost_points": 1,
		"cost_resources": {"ore": 3},
		"requires": ["quick_draw"],
	},
	"homing_mastery": {
		"name": "Homing Mastery",
		"cluster": "combat",
		"effect_desc": "Homing missiles split into 2 on impact",
		"cost_points": 2,
		"cost_resources": {"nanites": 5},
		"requires": ["critical_systems"],
	},
	"railgun_mastery": {
		"name": "Railgun Mastery",
		"cluster": "combat",
		"effect_desc": "Railgun stuns target for 1 second",
		"cost_points": 2,
		"cost_resources": {"plasma": 3, "dark_matter": 2},
		"requires": ["critical_systems"],
	},

	# -----------------------------------------------------------------------
	# SURVIVAL CLUSTER
	# -----------------------------------------------------------------------
	"thick_hull": {
		"name": "Thick Hull",
		"cluster": "survival",
		"effect_desc": "+25 max HP",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["spacer"],
	},
	"fuel_saver": {
		"name": "Fuel Saver",
		"cluster": "survival",
		"effect_desc": "-15% fuel burn rate",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["thick_hull"],
	},
	"shield_wall": {
		"name": "Shield Wall",
		"cluster": "survival",
		"effect_desc": "Shield bullets absorb 2 hits",
		"cost_points": 1,
		"cost_resources": {"ore": 5},
		"requires": ["thick_hull"],
	},
	"regen_plating": {
		"name": "Regen Plating",
		"cluster": "survival",
		"effect_desc": "+1 HP per 4 seconds",
		"cost_points": 1,
		"cost_resources": {"biotech": 3},
		"requires": ["shield_wall"],
	},
	"emergency_reserves": {
		"name": "Emergency Reserves",
		"cluster": "survival",
		"effect_desc": "Below 20% HP: +30% speed for 5s (60s cooldown)",
		"cost_points": 2,
		"cost_resources": {"antimatter": 3},
		"requires": ["regen_plating"],
	},
	"fuel_recycler": {
		"name": "Fuel Recycler",
		"cluster": "survival",
		"effect_desc": "Enemy kills restore 2% fuel",
		"cost_points": 1,
		"cost_resources": {"parts": 3},
		"requires": ["fuel_saver"],
	},
	"last_stand": {
		"name": "Last Stand",
		"cluster": "survival",
		"effect_desc": "Survive one killing blow with 1 HP (once per life)",
		"cost_points": 2,
		"cost_resources": {"biotech": 5, "void_essence": 2},
		"requires": ["emergency_reserves"],
	},

	# -----------------------------------------------------------------------
	# TRADE CLUSTER
	# -----------------------------------------------------------------------
	"bartenders_charm": {
		"name": "Bartender's Charm",
		"cluster": "trade",
		"effect_desc": "+8% sell prices",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["spacer"],
	},
	"haggler": {
		"name": "Haggler",
		"cluster": "trade",
		"effect_desc": "-10% buy prices",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["bartenders_charm"],
	},
	"deep_pockets": {
		"name": "Deep Pockets",
		"cluster": "trade",
		"effect_desc": "+3 cargo capacity",
		"cost_points": 1,
		"cost_resources": {"parts": 5},
		"requires": ["bartenders_charm"],
	},
	"market_sense": {
		"name": "Market Sense",
		"cluster": "trade",
		"effect_desc": "Price events last 2 extra visits",
		"cost_points": 1,
		"cost_resources": {"crystals": 3},
		"requires": ["haggler"],
	},
	"bulk_trader": {
		"name": "Bulk Trader",
		"cluster": "trade",
		"effect_desc": "Sell 5+ of same resource for +15% bonus",
		"cost_points": 2,
		"cost_resources": {"nanites": 3},
		"requires": ["deep_pockets"],
	},
	"insider_trading": {
		"name": "Insider Trading",
		"cluster": "trade",
		"effect_desc": "See adjacent planet prices on HUD",
		"cost_points": 1,
		"cost_resources": {"crystals": 3},
		"requires": ["market_sense"],
	},

	# -----------------------------------------------------------------------
	# PILOTING CLUSTER
	# -----------------------------------------------------------------------
	"afterburner": {
		"name": "Afterburner",
		"cluster": "piloting",
		"effect_desc": "+12% ship speed",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["spacer"],
	},
	"tight_turn": {
		"name": "Tight Turn",
		"cluster": "piloting",
		"effect_desc": "+20% turn rate",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["afterburner"],
	},
	"dash_boost": {
		"name": "Dash Boost",
		"cluster": "piloting",
		"effect_desc": "Dash 30% farther, -1s cooldown",
		"cost_points": 1,
		"cost_resources": {"plasma": 3},
		"requires": ["afterburner"],
	},
	"radar_sweep": {
		"name": "Radar Sweep",
		"cluster": "piloting",
		"effect_desc": "+40% minimap range",
		"cost_points": 1,
		"cost_resources": {},
		"requires": ["tight_turn"],
	},
	"ability_surge": {
		"name": "Ability Surge",
		"cluster": "piloting",
		"effect_desc": "-20% all ability cooldowns",
		"cost_points": 1,
		"cost_resources": {"crystals": 5, "antimatter": 2},
		"requires": ["dash_boost"],
	},
	"evasion_protocol": {
		"name": "Evasion Protocol",
		"cluster": "piloting",
		"effect_desc": "6% dodge chance",
		"cost_points": 2,
		"cost_resources": {"nanites": 5, "gravitonium": 2},
		"requires": ["ability_surge"],
	},

	# -----------------------------------------------------------------------
	# BRIDGE NODES  (require ANY ONE prerequisite — see BRIDGE_NODES)
	# -----------------------------------------------------------------------
	"scavenger": {
		"name": "Scavenger",
		"cluster": "bridge",
		"effect_desc": "10% chance enemy kills drop resources",
		"cost_points": 1,
		"cost_resources": {"parts": 3},
		"requires": ["sharp_shooter", "bartenders_charm"],
	},
	"combat_medic": {
		"name": "Combat Medic",
		"cluster": "bridge",
		"effect_desc": "Kills restore 3 HP",
		"cost_points": 1,
		"cost_resources": {"biotech": 3},
		"requires": ["sharp_shooter", "thick_hull"],
	},
	"smugglers_reflexes": {
		"name": "Smuggler's Reflexes",
		"cluster": "bridge",
		"effect_desc": "+5% speed when cargo >75% full",
		"cost_points": 1,
		"cost_resources": {"ice": 3},
		"requires": ["deep_pockets", "afterburner"],
	},
}

# ---------------------------------------------------------------------------
# Bridge node IDs — unlock requires ANY ONE prerequisite (not all)
# ---------------------------------------------------------------------------
const BRIDGE_NODES: Array = [
	"scavenger",
	"combat_medic",
	"smugglers_reflexes",
]

# ---------------------------------------------------------------------------
# Cluster colors for UI
# ---------------------------------------------------------------------------
const CLUSTER_COLORS: Dictionary = {
	"center":   Color(0.9, 0.9, 0.9),   # near-white
	"combat":   Color(0.9, 0.2, 0.2),   # red
	"survival": Color(0.2, 0.8, 0.3),   # green
	"trade":    Color(0.9, 0.75, 0.1),  # gold
	"piloting": Color(0.2, 0.6, 0.95),  # blue
	"bridge":   Color(0.7, 0.3, 0.9),   # purple
}

# ---------------------------------------------------------------------------
# Node positions for web layout  (Vector2, spacer at origin)
# Combat: negative Y (up), Survival: positive X (right),
# Trade: positive Y (down), Piloting: negative X (left)
# Scale: roughly -5 to +5 per axis.
# ---------------------------------------------------------------------------
const NODE_POSITIONS: Dictionary = {
	# Center
	"spacer":              Vector2( 0.0,  0.0),

	# Combat (upward, negative Y)
	"sharp_shooter":       Vector2( 0.0, -1.8),
	"quick_draw":          Vector2(-1.2, -3.0),
	"critical_systems":    Vector2( 1.2, -3.0),
	"blaster_mastery":     Vector2(-2.5, -4.2),
	"laser_mastery":       Vector2(-1.0, -4.5),
	"spread_mastery":      Vector2( 0.5, -4.2),
	"homing_mastery":      Vector2( 0.8, -4.8),
	"railgun_mastery":     Vector2( 2.2, -4.2),

	# Survival (rightward, positive X)
	"thick_hull":          Vector2( 1.8,  0.0),
	"fuel_saver":          Vector2( 3.0, -1.2),
	"shield_wall":         Vector2( 3.0,  1.2),
	"regen_plating":       Vector2( 4.2,  1.8),
	"emergency_reserves":  Vector2( 4.8,  0.5),
	"fuel_recycler":       Vector2( 4.2, -1.8),
	"last_stand":          Vector2( 5.0,  2.5),

	# Trade (downward, positive Y)
	"bartenders_charm":    Vector2( 0.0,  1.8),
	"haggler":             Vector2(-1.2,  3.0),
	"deep_pockets":        Vector2( 1.2,  3.0),
	"market_sense":        Vector2(-2.0,  4.2),
	"bulk_trader":         Vector2( 2.0,  4.2),
	"insider_trading":     Vector2(-2.8,  5.0),

	# Piloting (leftward, negative X)
	"afterburner":         Vector2(-1.8,  0.0),
	"tight_turn":          Vector2(-3.0, -1.2),
	"dash_boost":          Vector2(-3.0,  1.2),
	"radar_sweep":         Vector2(-4.2, -1.8),
	"ability_surge":       Vector2(-4.2,  1.8),
	"evasion_protocol":    Vector2(-5.0,  2.5),

	# Bridges (between clusters)
	"scavenger":           Vector2( 0.8, -2.2),   # combat <-> trade
	"combat_medic":        Vector2( 1.5, -1.2),   # combat <-> survival
	"smugglers_reflexes":  Vector2(-1.5,  2.2),   # trade  <-> piloting
}


# ---------------------------------------------------------------------------
# can_unlock()
# Returns true if the given node can be unlocked given the current state.
#
# Parameters:
#   node_id         — string ID of the node to attempt
#   unlocked_nodes  — Array of already-unlocked node IDs
#   skill_points    — int, available skill points
#   cargo           — Dictionary  resource_id -> int  (current cargo counts)
# ---------------------------------------------------------------------------
static func can_unlock(
		node_id: String,
		unlocked_nodes: Array,
		skill_points: int,
		cargo: Dictionary) -> bool:

	# Node must exist
	if not NODES.has(node_id):
		return false

	# Already unlocked?
	if unlocked_nodes.has(node_id):
		return false

	var node: Dictionary = NODES[node_id]

	# Enough skill points?
	if skill_points < node["cost_points"]:
		return false

	# Enough resources in cargo?
	var cost_res: Dictionary = node["cost_resources"]
	for resource_id in cost_res:
		var needed: int = cost_res[resource_id]
		var have: int = cargo.get(resource_id, 0)
		if have < needed:
			return false

	# Prerequisite check
	var requires: Array = node["requires"]
	if requires.is_empty():
		return true  # spacer (or any no-prereq node) — only gate is cost

	if BRIDGE_NODES.has(node_id):
		# Bridge: ANY ONE prerequisite must be unlocked
		for prereq in requires:
			if unlocked_nodes.has(prereq):
				return true
		return false
	else:
		# Regular: ALL prerequisites must be unlocked
		for prereq in requires:
			if not unlocked_nodes.has(prereq):
				return false
		return true


# ---------------------------------------------------------------------------
# get_node_effect_value()
# Returns a machine-readable Dictionary of gameplay effect keys and values.
# Consumers should check which keys exist and apply accordingly.
# ---------------------------------------------------------------------------
static func get_node_effect_value(node_id: String) -> Dictionary:
	match node_id:
		# Center
		"spacer":
			return {"max_hp_flat": 10, "damage_mult": 0.05}

		# Combat
		"sharp_shooter":
			return {"damage_mult": 0.15}
		"quick_draw":
			return {"cooldown_mult": -0.10}
		"critical_systems":
			return {"crit_chance": 0.08, "crit_damage_mult": 2.0}
		"blaster_mastery":
			return {"blaster_pierce": 1}
		"laser_mastery":
			return {"laser_cone": true}
		"spread_mastery":
			return {"spread_shot_count": 7, "spread_tighter_cone": true}
		"homing_mastery":
			return {"homing_split_on_impact": 2}
		"railgun_mastery":
			return {"railgun_stun_duration": 1.0}

		# Survival
		"thick_hull":
			return {"max_hp_flat": 25}
		"fuel_saver":
			return {"fuel_burn_mult": -0.15}
		"shield_wall":
			return {"shield_bullet_absorb": 2}
		"regen_plating":
			return {"hp_regen_per_sec": 0.25}   # 1 HP per 4 sec
		"emergency_reserves":
			return {"low_hp_speed_mult": 0.30, "low_hp_threshold": 0.20,
					"low_hp_duration": 5.0, "low_hp_cooldown": 60.0}
		"fuel_recycler":
			return {"fuel_restore_on_kill": 0.02}
		"last_stand":
			return {"survive_killing_blow": true}

		# Trade
		"bartenders_charm":
			return {"sell_price_mult": 0.08}
		"haggler":
			return {"buy_price_mult": -0.10}
		"deep_pockets":
			return {"cargo_capacity_flat": 3}
		"market_sense":
			return {"price_event_extra_visits": 2}
		"bulk_trader":
			return {"bulk_sell_threshold": 5, "bulk_sell_bonus_mult": 0.15}
		"insider_trading":
			return {"show_adjacent_prices": true}

		# Piloting
		"afterburner":
			return {"speed_mult": 0.12}
		"tight_turn":
			return {"turn_rate_mult": 0.20}
		"dash_boost":
			return {"dash_distance_mult": 0.30, "dash_cooldown_flat": -1.0}
		"radar_sweep":
			return {"minimap_range_mult": 0.40}
		"ability_surge":
			return {"ability_cooldown_mult": -0.20}
		"evasion_protocol":
			return {"dodge_chance": 0.06}

		# Bridges
		"scavenger":
			return {"resource_drop_on_kill": 0.10}
		"combat_medic":
			return {"hp_on_kill": 3}
		"smugglers_reflexes":
			return {"cargo_speed_mult": 0.05, "cargo_speed_threshold": 0.75}

	# Unknown node — return empty dict (consumers should handle gracefully)
	return {}
