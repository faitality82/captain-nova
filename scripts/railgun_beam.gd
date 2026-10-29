extends Area2D

var direction: Vector2 = Vector2.RIGHT
var damage: int = 100
var speed: float = 1500.0
var lifetime: float = 1.0
var _hit_enemies: Array = []  # track who we already hit to avoid double damage

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body in _hit_enemies:
		return  # already hit this one
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_hit_enemies.append(body)
	# Do NOT queue_free — railgun pierces through
