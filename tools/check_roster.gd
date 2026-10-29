extends SceneTree

## Headless sanity check: prints the Mars roster size and last id.
## Run: godot --headless --path <project> -s res://tools/check_roster.gd
##
## In -s script mode autoloads are not instantiated, and
## city_npc_roster.gd references ResourceManager, so a stand-in is
## registered as an Engine singleton before the roster is loaded.

func _initialize() -> void:
	var rm: Node = load("res://scripts/resource_manager.gd").new()
	Engine.register_singleton("ResourceManager", rm)
	var r = load("res://scripts/city_npc_roster.gd")
	var mars = r.get_npcs_for_planet("Mars")
	print("Mars NPCs: ", mars.size(), " last id: ", mars[-1]["id"])
	var vance = mars[-1]
	print("Quest target: ", vance.get("quest", {}).get("target", "none"), " type: ", vance.get("quest", {}).get("type", "none"))
	Engine.unregister_singleton("ResourceManager")
	rm.free()
	quit()
