extends Area2D

## Left behind by a mustard bolt. Drags the player while overlapping. Fades after LIFETIME.

const LIFETIME: float = 6.0
const DRAG: float = 0.10   # fraction of velocity removed per physics tick while inside
var _life: float = LIFETIME
var _radius: float = 22.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = _radius
	shape.shape = circle
	add_child(shape)
	z_index = -1

func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("apply_force"):
			body.apply_force(-body.velocity * DRAG)
	queue_redraw()

func _draw() -> void:
	var a := clampf(_life / LIFETIME, 0.0, 1.0) * 0.85
	draw_circle(Vector2.ZERO, _radius, Color(1.0, 0.82, 0.25, a))
	draw_circle(Vector2(6, -4), _radius * 0.45, Color(1.0, 0.92, 0.45, a))
