extends Node2D

var destination: Node = null  # target planet node
var hp: int = 50
var speed: float = 60.0
var _arrived: bool = false
var _time: float = 0.0

func _ready() -> void:
	add_to_group("convoy")

	# Make it damageable
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	area.add_child(shape)
	add_child(area)

func _process(delta: float) -> void:
	_time += delta
	if destination == null or not is_instance_valid(destination):
		queue_free()
		return
	var dir = (destination.global_position - global_position).normalized()
	global_position += dir * speed * delta
	rotation = dir.angle()
	if global_position.distance_to(destination.global_position) < 100:
		_arrive()
	queue_redraw()

func _draw() -> void:
	# --- Engine glow at the rear (drawn first so hull overlaps it) ---
	var flicker = 0.8 + 0.2 * sin(_time * 12.0)
	var glow_color = Color(1.0, 0.65, 0.1, flicker)
	draw_circle(Vector2(-8, 0), 3.5, glow_color)
	# Dimmer outer glow
	draw_circle(Vector2(-9, 0), 5.0, Color(1.0, 0.5, 0.0, flicker * 0.3))

	# --- Wedge / arrow-shaped hull (green-gray) ---
	var hull_color = Color(0.45, 0.62, 0.42, 1.0)
	var hull_points = PackedVector2Array([
		Vector2(8, 0),    # nose
		Vector2(-7, -5),  # rear top
		Vector2(-5, 0),   # rear center notch
		Vector2(-7, 5),   # rear bottom
	])
	draw_colored_polygon(hull_points, hull_color)

	# Hull outline for definition
	var outline_color = Color(0.3, 0.45, 0.3, 0.8)
	for i in range(hull_points.size()):
		var a = hull_points[i]
		var b = hull_points[(i + 1) % hull_points.size()]
		draw_line(a, b, outline_color, 1.0)

	# --- Cargo bay markings: 3 small colored rectangles on the body ---
	var cargo_colors = [
		Color(0.85, 0.7, 0.2, 0.9),   # gold
		Color(0.3, 0.55, 0.8, 0.9),   # blue
		Color(0.75, 0.35, 0.2, 0.9),  # rust-orange
	]
	draw_rect(Rect2(-4, -2.5, 3, 2), cargo_colors[0])
	draw_rect(Rect2(-4, 0.5, 3, 2), cargo_colors[1])
	draw_rect(Rect2(0, -1, 3, 2), cargo_colors[2])

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		# Player or enemy killed the convoy ship
		_drop_cargo()
		var nearest_planet = _find_nearest_planet()
		if nearest_planet != "":
			ResourceManager.adjust_reputation(nearest_planet, -20)
		queue_free()

func _arrive() -> void:
	if _arrived:
		return
	_arrived = true
	# Reward player if all convoy ships made it
	ResourceManager.add_money(125)  # $500 split across ~4 ships
	if destination.get("planet_name"):
		ResourceManager.adjust_reputation(destination.planet_name, 3)
	queue_free()

func _drop_cargo() -> void:
	var pickup_scene = load("res://scenes/world/ResourcePickup.tscn")
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position
		get_parent().call_deferred("add_child", pickup)

func _find_nearest_planet() -> String:
	var nearest = ""
	var nearest_dist = 99999.0
	for planet in get_tree().get_nodes_in_group("planet"):
		var d = global_position.distance_to(planet.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = planet.planet_name
	return nearest
