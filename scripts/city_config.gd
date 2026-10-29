# city_config.gd
# Central config for all planet-specific city parameters.
# Provides variable-width cities so each planet feels distinct —
# Pluto is a cramped outpost, Earth is a sprawling megacity.
class_name CityConfig
extends RefCounted

const PLANET_CITY_DATA: Dictionary = {
	"Mercury": {
		"width": 1600.0,
		"npc_count": 2,
		"props": ["pipe", "heat_vent", "crate"],
	},
	"Venus": {
		"width": 2400.0,
		"npc_count": 3,
		"props": ["acid_pipe", "platform_strut", "crate"],
	},
	"Earth": {
		"width": 4000.0,
		"npc_count": 6,
		"props": ["lamp_post", "bench", "hover_car", "trash_can", "sign", "planter"],
	},
	"Mars": {
		"width": 2800.0,
		"npc_count": 4,
		"props": ["sandbag", "crate", "antenna", "tarp"],
	},
	"Jupiter": {
		"width": 3200.0,
		"npc_count": 5,
		"props": ["fuel_tank", "crane_arm", "crate", "pipe"],
	},
	"Saturn": {
		"width": 2800.0,
		"npc_count": 4,
		"props": ["data_terminal", "cable_conduit", "lab_crate"],
	},
	"Uranus": {
		"width": 2000.0,
		"npc_count": 3,
		"props": ["ice_chunk", "tarp", "crate"],
	},
	"Neptune": {
		"width": 2200.0,
		"npc_count": 3,
		"props": ["ice_chunk", "geyser_vent", "pipe"],
	},
	"Pluto": {
		"width": 1400.0,
		"npc_count": 2,
		"props": ["scrap_pile", "barrel", "wire_spool"],
	},
}

const _FALLBACK_PLANET := "Earth"


static func get_city_width(planet: String) -> float:
	if PLANET_CITY_DATA.has(planet):
		return PLANET_CITY_DATA[planet]["width"]
	return PLANET_CITY_DATA[_FALLBACK_PLANET]["width"]


static func get_npc_count(planet: String) -> int:
	if PLANET_CITY_DATA.has(planet):
		return PLANET_CITY_DATA[planet]["npc_count"]
	return PLANET_CITY_DATA[_FALLBACK_PLANET]["npc_count"]


static func get_props(planet: String) -> Array:
	if PLANET_CITY_DATA.has(planet):
		return PLANET_CITY_DATA[planet]["props"].duplicate()
	return PLANET_CITY_DATA[_FALLBACK_PLANET]["props"].duplicate()


static func get_building_positions(planet: String) -> Array:
	var width := get_city_width(planet)
	var padding := width * 0.05
	var usable := width - 2.0 * padding
	var positions: Array = []
	for i in range(5):
		positions.append(padding + usable * (float(i) / 4.0))
	return positions
