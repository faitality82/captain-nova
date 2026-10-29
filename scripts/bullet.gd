extends Area2D

var direction: Vector2 = Vector2.RIGHT
var damage: int = 25
var speed: float = 600.0
var lifetime: float = 2.0
var _has_bounced: bool = false
var _time: float = 0.0

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	_time += delta
	queue_redraw()
	if lifetime <= 0:
		queue_free()

func _draw() -> void:
	var base_color: Color = Color(1.0, 0.95, 0.3)  # yellow default
	var mod = get_meta("mod") if has_meta("mod") else ""
	if mod == "incendiary":
		base_color = Color(1.0, 0.35, 0.1)  # orange-red
	elif mod == "vampiric":
		base_color = Color(0.7, 0.2, 1.0)  # purple
	elif mod == "ricochet":
		base_color = Color(0.2, 0.9, 1.0)  # cyan

	# Glowing trail: 3 fading circles behind the bullet
	var trail_color := base_color
	trail_color.a = 0.15
	draw_circle(Vector2(-7, 0), 1.5, trail_color)
	trail_color.a = 0.3
	draw_circle(Vector2(-5, 0), 2.0, trail_color)
	trail_color.a = 0.5
	draw_circle(Vector2(-3, 0), 2.5, trail_color)

	# Main bolt body: elongated rect ~8px long, 3px wide
	var bolt_rect := Rect2(-4, -1.5, 8, 3)
	draw_rect(bolt_rect, base_color)

	# Bright white-hot core for glow effect
	var core_color := Color(1.0, 1.0, 1.0, 0.9)
	var core_rect := Rect2(-3, -0.75, 6, 1.5)
	draw_rect(core_rect, core_color)

func _on_body_entered(body: Node) -> void:
	var mod = get_meta("mod") if has_meta("mod") else ""
	if body.has_method("take_damage"):
		body.take_damage(damage)
		# Incendiary: apply burn
		if mod == "incendiary" and body.is_in_group("enemy"):
			_apply_burn(body)
		# Vampiric: heal on kill
		if mod == "vampiric" and body.is_in_group("enemy"):
			if body.get("hp") != null and body.hp <= 0:
				var ship = get_tree().get_first_node_in_group("player")
				if ship and ship.has_method("heal"):
					ship.heal(5)
	# Ricochet: bounce once
	if mod == "ricochet" and not _has_bounced and body.is_in_group("enemy"):
		_has_bounced = true
		var nearest = _find_nearest_enemy(body)
		if nearest:
			direction = (nearest.global_position - global_position).normalized()
			rotation = direction.angle()
			return  # don't free, bounce continues
	queue_free()

func _apply_burn(target: Node) -> void:
	# 5 damage per second for 3 seconds
	for i in range(3):
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(5)

func _find_nearest_enemy(exclude: Node) -> Node:
	var nearest: Node = null
	var nearest_dist: float = 500.0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy == exclude:
			continue
		var d = global_position.distance_to(enemy.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = enemy
	return nearest
