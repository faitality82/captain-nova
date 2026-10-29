extends Area2D

@export var damage: int = 8
@export var arm_time: float = 1.0
@export var lifetime: float = 12.0

var _armed: bool = false
var _timer: float = 0.0
var _pulse_timer: float = 0.0

func _ready() -> void:
	collision_layer = 32
	collision_mask = 1
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_timer += delta
	if not _armed and _timer >= arm_time:
		_armed = true
	if _timer >= lifetime:
		_explode()
		return
	_pulse_timer += delta
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if not _armed:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		_explode()

func _explode() -> void:
	AudioManager.play_sfx("sfx_explosion", -6.0)
	queue_free()

func _draw() -> void:
	if _armed:
		var pulse = 0.5 + sin(_pulse_timer * 6.0) * 0.3
		draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.1, 0.1, pulse))
		draw_arc(Vector2.ZERO, 8.0, 0, TAU, 16, Color(1.0, 0.3, 0.3, pulse * 0.5), 1.0)
	else:
		draw_circle(Vector2.ZERO, 4.0, Color(0.5, 0.5, 0.5, 0.5))
