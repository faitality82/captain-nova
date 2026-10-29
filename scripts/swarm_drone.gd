extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 15
@export var move_speed: float = 160.0
@export var damage_on_contact: int = 2
@export var kill_reward: int = 20
@export var xp_reward: int = 15
@export var body_color: Color = Color(0.2, 0.9, 0.3)

var _target: Node2D = null
var _time: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _physics_process(_delta: float) -> void:
	_find_target()
	if _target == null or not _target.is_in_group("player"):
		return
	if _target.get("is_dead") == true:
		return

	var dir = (_target.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()
	rotation = dir.angle()

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func take_damage(amount: int) -> void:
	hp -= amount
	queue_redraw()
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", -4.0)
	ResourceManager.add_money(kill_reward)
	ResourceManager.add_xp(xp_reward)
	# Skill tree on-kill effects
	var tree_fuel := ResourceManager.get_tree_effect("fuel_restore_on_kill")
	if tree_fuel > 0:
		ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + ResourceManager.ship_max_fuel * tree_fuel, ResourceManager.ship_max_fuel)
	var tree_hp := int(ResourceManager.get_tree_effect("hp_on_kill"))
	if tree_hp > 0:
		ResourceManager.ship_hp = min(ResourceManager.ship_hp + tree_hp, ResourceManager.ship_max_hp)
	if randf() < ResourceManager.get_tree_effect("resource_drop_on_kill"):
		var resources = ["ore", "parts", "ice", "crystals"]
		ResourceManager.add_cargo(resources[randi() % resources.size()], 1)
	destroyed.emit(global_position)
	if randf() < 0.15:
		_drop_shield_pickup()
	queue_free()

func _drop_shield_pickup() -> void:
	var pickup_scene = load("res://scenes/world/ShieldPickup.tscn")
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position
		get_parent().call_deferred("add_child", pickup)

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage_on_contact)

func _draw() -> void:
	var buzz_x = sin(_time * 35.0) * 0.5
	var buzz_y = cos(_time * 28.0) * 0.4
	var buzz = Vector2(buzz_x, buzz_y)

	var base_color = body_color
	var damaged = hp < 15
	if damaged:
		base_color = base_color.lightened(0.3)

	# Engine trail - small fading circles behind
	var trail_alpha1 = maxf(0.1, 0.25 + sin(_time * 12.0) * 0.1)
	var trail_alpha2 = maxf(0.05, 0.12 + sin(_time * 10.0) * 0.05)
	draw_circle(Vector2(-10, 0) + buzz, 2.0, Color(0.2, 0.8, 0.3, trail_alpha2))
	draw_circle(Vector2(-7, 0) + buzz, 2.5, Color(0.2, 0.85, 0.3, trail_alpha1))

	# Insect body - elongated hexagon
	var body_points = PackedVector2Array([
		Vector2(7, 0) + buzz,
		Vector2(3, -3.5) + buzz,
		Vector2(-4, -3) + buzz,
		Vector2(-6, 0) + buzz,
		Vector2(-4, 3) + buzz,
		Vector2(3, 3.5) + buzz,
	])
	draw_colored_polygon(body_points, base_color)
	# Body outline
	for i in range(body_points.size()):
		var next_i = (i + 1) % body_points.size()
		draw_line(body_points[i], body_points[next_i], base_color.darkened(0.3), 0.5)

	# Wings - 2 tiny translucent triangles on each side, flickering rapidly
	var wing_alpha_l = maxf(0.1, 0.4 + sin(_time * 50.0) * 0.3)
	var wing_alpha_r = maxf(0.1, 0.4 + cos(_time * 50.0) * 0.3)
	var wing_color_l = Color(0.5, 1.0, 0.6, wing_alpha_l)
	var wing_color_r = Color(0.5, 1.0, 0.6, wing_alpha_r)

	# Top wings
	var wing_top_1 = PackedVector2Array([
		Vector2(2, -3) + buzz,
		Vector2(-1, -7) + buzz,
		Vector2(-3, -3) + buzz,
	])
	var wing_top_2 = PackedVector2Array([
		Vector2(-1, -3) + buzz,
		Vector2(-4, -6) + buzz,
		Vector2(-5, -2.5) + buzz,
	])
	draw_colored_polygon(wing_top_1, wing_color_l)
	draw_colored_polygon(wing_top_2, wing_color_l)

	# Bottom wings
	var wing_bot_1 = PackedVector2Array([
		Vector2(2, 3) + buzz,
		Vector2(-1, 7) + buzz,
		Vector2(-3, 3) + buzz,
	])
	var wing_bot_2 = PackedVector2Array([
		Vector2(-1, 3) + buzz,
		Vector2(-4, 6) + buzz,
		Vector2(-5, 2.5) + buzz,
	])
	draw_colored_polygon(wing_bot_1, wing_color_r)
	draw_colored_polygon(wing_bot_2, wing_color_r)

	# Eye - tiny bright circle at front, pulsing
	var eye_pulse = maxf(0.6, 0.8 + sin(_time * 8.0) * 0.2)
	var eye_color = Color(1.0, 1.0, 0.7, eye_pulse)
	draw_circle(Vector2(5, 0) + buzz, 1.5, eye_color)
	draw_circle(Vector2(5, 0) + buzz, 0.8, Color(1.0, 1.0, 1.0, eye_pulse))
