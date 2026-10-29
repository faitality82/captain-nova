extends Node2D

@export var alien_scene: PackedScene
@export var spaghetti_scene: PackedScene
@export var swarm_drone_scene: PackedScene
@export var mine_layer_scene: PackedScene
@export var rammer_scene: PackedScene
@export var cloaker_scene: PackedScene
@export var max_enemies: int = 15
@export var spawn_interval: float = 4.0

var _spawn_timer: float = 0.0
var _sun_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	var sun = get_tree().get_first_node_in_group("sun")
	if sun:
		_sun_pos = sun.global_position

func _process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_timer = spawn_interval
		_try_spawn()

func _try_spawn() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship == null or ship.get("is_dead") == true:
		return

	var current_enemies = get_tree().get_nodes_in_group("enemy").size()
	if current_enemies >= max_enemies:
		return

	var dist_from_sun = ship.global_position.distance_to(_sun_pos)

	if dist_from_sun < 500:
		return

	var difficulty = clampf(dist_from_sun / 10000.0, 0.0, 1.0)

	if randf() > 0.3 + difficulty * 0.5:
		return

	# Build available types based on distance bands
	var available: Array[Dictionary] = []

	# Alien — always available past safe zone
	if alien_scene:
		available.append({"scene": alien_scene, "weight": 3.0})

	# Swarm Drone — everywhere (500+), spawns in groups
	if swarm_drone_scene and dist_from_sun > 500:
		available.append({"scene": swarm_drone_scene, "weight": 2.0, "swarm": true})

	# Mine Layer — Mars+ (2000+)
	if mine_layer_scene and dist_from_sun > 2000:
		available.append({"scene": mine_layer_scene, "weight": 1.5})

	# Spaghetti — Saturn+ (6000+)
	if spaghetti_scene and dist_from_sun > 6000:
		available.append({"scene": spaghetti_scene, "weight": 2.0})

	# Rammer — Jupiter+ (3500+)
	if rammer_scene and dist_from_sun > 3500:
		available.append({"scene": rammer_scene, "weight": 1.5})

	# Cloaker — Saturn+ (6000+)
	if cloaker_scene and dist_from_sun > 6000:
		available.append({"scene": cloaker_scene, "weight": 1.0})

	if available.is_empty():
		return

	# Weighted random selection
	var total_weight = 0.0
	for entry in available:
		total_weight += entry["weight"]
	var roll = randf() * total_weight
	var chosen: Dictionary = available[0]
	var cumulative = 0.0
	for entry in available:
		cumulative += entry["weight"]
		if roll <= cumulative:
			chosen = entry
			break

	# Swarm drones spawn in packs
	var spawn_count = 1
	if chosen.get("swarm", false):
		spawn_count = randi_range(3, 5)
		# Don't exceed max enemies
		spawn_count = mini(spawn_count, max_enemies - current_enemies)

	for i in range(spawn_count):
		_spawn_enemy(ship, chosen["scene"], difficulty, i > 0)

	# Occasionally spawn a neutral freighter (15% chance per spawn cycle)
	if randf() < 0.15 and get_tree().get_nodes_in_group("freighter").size() < 3:
		_spawn_freighter(ship)

func _spawn_enemy(ship: Node2D, scene: PackedScene, difficulty: float, offset: bool) -> void:
	var enemy = ResourceManager.safe_instantiate(scene)
	if enemy == null:
		return

	var spawn_angle = randf() * TAU
	var spawn_dist = 600 + randf() * 200
	if offset:
		# Swarm members spawn in a cluster
		spawn_dist += randf() * 80 - 40
		spawn_angle += randf() * 0.5 - 0.25
	enemy.global_position = ship.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_dist

	# Scale stats with difficulty
	var stat_mult = 1.0 + difficulty * 1.5
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * stat_mult)
	if enemy.get("move_speed") != null:
		enemy.move_speed *= (1.0 + difficulty * 0.5)
	if enemy.get("bullet_damage") != null:
		enemy.bullet_damage = int(enemy.bullet_damage * stat_mult)
	if enemy.get("kill_reward") != null:
		enemy.kill_reward = int(enemy.kill_reward * stat_mult)
	if enemy.get("xp_reward") != null:
		enemy.xp_reward = int(enemy.xp_reward * stat_mult)
	if enemy.get("damage_on_contact") != null:
		enemy.damage_on_contact = int(enemy.damage_on_contact * stat_mult)

	# Prestige scaling
	var prestige_mult = 1.0 + ResourceManager.prestige_level * 0.10
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * prestige_mult)
	if enemy.get("bullet_damage") != null:
		enemy.bullet_damage = int(enemy.bullet_damage * prestige_mult)
	if enemy.get("damage_on_contact") != null:
		enemy.damage_on_contact = int(enemy.damage_on_contact * prestige_mult)

	get_parent().call_deferred("add_child", enemy)
	if enemy.has_signal("destroyed"):
		var world = get_parent()
		if world.has_method("_on_enemy_destroyed"):
			enemy.destroyed.connect(world._on_enemy_destroyed)

func _spawn_freighter(ship: Node2D) -> void:
	var freighter_script = load("res://scripts/freighter.gd")
	if freighter_script == null:
		return
	var freighter = CharacterBody2D.new()
	freighter.set_script(freighter_script)
	var spawn_angle = randf() * TAU
	freighter.global_position = ship.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * 800
	get_parent().call_deferred("add_child", freighter)
