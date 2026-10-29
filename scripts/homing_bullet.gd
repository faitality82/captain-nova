extends Area2D

var direction: Vector2 = Vector2.RIGHT
var damage: int = 25
var speed: float = 350.0
var lifetime: float = 3.0
var _turn_rate: float = 3.0  # radians per second

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Find nearest enemy to home toward
	var target = _find_nearest_enemy()
	if target:
		var desired_dir = (target.global_position - global_position).normalized()
		var angle_diff = direction.angle_to(desired_dir)
		var max_turn = _turn_rate * delta
		angle_diff = clampf(angle_diff, -max_turn, max_turn)
		direction = direction.rotated(angle_diff)

	position += direction * speed * delta
	rotation = direction.angle()
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _find_nearest_enemy() -> Node:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest: Node = null
	var nearest_dist: float = 600.0  # max tracking range
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
