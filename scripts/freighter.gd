# freighter.gd
# Neutral NPC cargo freighter. Flies between planets.
# Killing one drops loot but tanks reputation at the nearest planet.
extends CharacterBody2D

signal destroyed(pos: Vector2)

var hp: int = 80
var _target_pos: Vector2 = Vector2.ZERO
var _speed: float = 60.0
var _time: float = 0.0
var _flash_timer: float = 0.0
var _cargo_type: String = "ore"
var _cargo_amount: int = 2
var _shortage_planet: String = ""
var _target_planet: Node = null   # tracked each tick: planets orbit, a snapshot position would miss

# Cargo tiers by distance from sun
const INNER_CARGO: Array = ["ore", "fuel", "parts"]              # 0-3000
const MID_CARGO: Array = ["ice", "crystals", "plasma"]            # 3000-7000
const OUTER_CARGO: Array = ["antimatter", "biotech", "nanites"]   # 7000-10000
const DEEP_CARGO: Array = ["dark_matter", "gravitonium", "void_essence"]  # 10000+

func _ready() -> void:
	add_to_group("freighter")
	collision_layer = 32  # same as enemies so bullets can hit
	collision_mask = 0    # doesn't collide with anything

	# Add collision shape
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	add_child(shape)

	# Cargo scales with distance from sun
	var sun_pos = Vector2(-3000, 0)
	var dist = global_position.distance_to(sun_pos)
	var pool: Array
	if dist > 10000:
		pool = DEEP_CARGO
		_cargo_amount = randi_range(1, 2)
		hp = 150
	elif dist > 7000:
		pool = OUTER_CARGO
		_cargo_amount = randi_range(1, 3)
		hp = 120
	elif dist > 3000:
		pool = MID_CARGO
		_cargo_amount = randi_range(2, 4)
		hp = 100
	else:
		pool = INNER_CARGO
		_cargo_amount = randi_range(2, 5)
		hp = 80
	_cargo_type = pool[randi() % pool.size()]

	# Shortage relief: most new freighters head for an active shortage carrying that good.
	var shortages: Array = ResourceManager.active_shortages()
	var target_planet: Node = null
	if not shortages.is_empty() and randf() < 0.6:
		var ev: Dictionary = shortages[randi() % shortages.size()]
		for p in get_tree().get_nodes_in_group("planet"):
			if p.planet_name == ev["planet"]:
				target_planet = p
				break
		if target_planet != null:
			_cargo_type = ev["resource"]
			_cargo_amount = randi_range(3, 5)
			_shortage_planet = ev["planet"]
	if target_planet == null:
		var planets = get_tree().get_nodes_in_group("planet")
		if planets.size() > 0:
			target_planet = planets[randi() % planets.size()]
	if target_planet != null:
		_target_planet = target_planet
		_target_pos = target_planet.global_position
	else:
		_target_pos = global_position + Vector2(randf_range(-2000, 2000), randf_range(-2000, 2000))

func _physics_process(delta: float) -> void:
	if is_instance_valid(_target_planet):
		_target_pos = _target_planet.global_position
	_time += delta
	if _flash_timer > 0:
		_flash_timer -= delta

	var dir = (_target_pos - global_position).normalized()
	velocity = dir * _speed
	move_and_slide()
	rotation = dir.angle()

	# Despawn if reached destination or too far from player
	if global_position.distance_to(_target_pos) < 100:
		if _shortage_planet != "":
			ResourceManager.deliver_stock(_shortage_planet, _cargo_type, 0.3)
			ResourceManager.add_log("A freighter reached %s with %s. Supply is recovering." % [_shortage_planet, _cargo_type], "event")
		queue_free()
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) > 3000:
		queue_free()

	queue_redraw()

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_timer = 0.1
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", -4.0)

	# Drop cargo as pickups
	var pickup_scene = ResourceManager.safe_load("res://scenes/world/ResourcePickup.tscn")
	if pickup_scene:
		for i in range(_cargo_amount):
			var pickup = pickup_scene.instantiate()
			pickup.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			pickup.resource_type = _cargo_type
			get_tree().current_scene.call_deferred("add_child", pickup)

	# Rep penalty at nearest planet
	var nearest_planet = ""
	var nearest_dist = 8000.0
	for planet in get_tree().get_nodes_in_group("planet"):
		var d = global_position.distance_to(planet.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_planet = planet.planet_name
	if nearest_planet != "":
		ResourceManager.adjust_reputation(nearest_planet, -20)
		ResourceManager.add_log("Destroyed a cargo freighter near %s. Reputation damaged." % nearest_planet, "combat")

	if _shortage_planet != "":
		# Any kill counts (player bullets, or an asteroid drifting into the hull); the shortage does not
		# care who did it. Log only if there was still a shortage to extend.
		if ResourceManager.extend_shortage(_shortage_planet, _cargo_type, 300.0):
			ResourceManager.add_log("That freighter was relief for %s. The shortage just got longer." % _shortage_planet, "event")

	# Small money reward (salvage)
	ResourceManager.add_money(50)
	ResourceManager.add_xp(10)

	destroyed.emit(global_position)
	queue_free()

func _draw() -> void:
	var flashing = _flash_timer > 0

	# Hull — boxy freighter shape
	var hull_color = Color(0.4, 0.5, 0.6) if not flashing else Color.WHITE
	var hull = PackedVector2Array([
		Vector2(-20, -10), Vector2(15, -10),
		Vector2(20, -5), Vector2(20, 5),
		Vector2(15, 10), Vector2(-20, 10),
	])
	draw_colored_polygon(hull, hull_color)

	# Cargo bay — center rectangle
	var cargo_color = Color(0.25, 0.35, 0.45) if not flashing else Color.WHITE
	draw_rect(Rect2(-12, -6, 18, 12), cargo_color)

	# Cargo indicator light
	var resource_colors = {
		"ore": Color(1.0, 0.5, 0.0),
		"fuel": Color(0.2, 0.6, 1.0),
		"parts": Color(0.2, 1.0, 0.4),
		"ice": Color(0.7, 0.9, 1.0),
		"crystals": Color(1.0, 0.3, 0.8),
		"plasma": Color(0.6, 0.3, 0.8),
		"antimatter": Color(0.9, 0.1, 0.3),
		"biotech": Color(0.1, 0.9, 0.5),
		"nanites": Color(0.5, 0.5, 0.9),
		"dark_matter": Color(0.2, 0.0, 0.3),
		"gravitonium": Color(0.4, 0.2, 0.6),
		"void_essence": Color(0.1, 0.1, 0.2),
	}
	var light_color = resource_colors.get(_cargo_type, Color.WHITE)
	draw_circle(Vector2(0, 0), 3.0, light_color)

	# Engine glow
	var flicker = 0.5 + sin(_time * 8.0) * 0.3
	var engine_color = Color(0.3, 0.5, 1.0, 0.5 + flicker * 0.3) if not flashing else Color.WHITE
	draw_circle(Vector2(-22, -5), 3.0, engine_color)
	draw_circle(Vector2(-22, 5), 3.0, engine_color)

	# "CARGO" text indicator — green triangle above ship (friendly marker).
	# Relief freighters running a shortage fly an orange marker instead.
	var marker_alpha = 0.6 + sin(_time * 2.0) * 0.2
	var marker_color = Color(1.0, 0.6, 0.1, marker_alpha) if _shortage_planet != "" else Color(0.2, 0.8, 0.3, marker_alpha)
	var tri = PackedVector2Array([
		Vector2(0, -18), Vector2(-4, -13), Vector2(4, -13)
	])
	draw_colored_polygon(tri, marker_color)
