extends "res://scripts/enemy_bullet.gd"

## Big Frank's aimed shot. Yellow, slower, leaves a MustardPuddle where it lands.

const PUDDLE_SCRIPT := preload("res://scripts/mustard_puddle.gd")
var _puddled: bool = false

func _init() -> void:
	speed = 260.0
	damage = 5
	_lifetime = 2.2

func _physics_process(delta: float) -> void:
	_time += delta
	global_position += direction * speed * delta
	rotation = direction.angle()
	_lifetime -= delta
	if _lifetime <= 0.0:
		_spawn_puddle()
		queue_free()
	queue_redraw()

func _draw() -> void:
	var pulse: float = 1.0 + 0.15 * sin(_time * 12.0)
	draw_circle(Vector2.ZERO, 9.0 * pulse, Color(1.0, 0.82, 0.25, 0.18))
	draw_circle(Vector2(-6, 0), 2.2, Color(1.0, 0.75, 0.2, 0.5))
	draw_circle(Vector2(-3, 0), 3.0, Color(1.0, 0.82, 0.25))
	draw_circle(Vector2.ZERO, 3.4 * pulse, Color(1.0, 0.86, 0.3))
	draw_circle(Vector2(2.5, 0), 1.6, Color(1.0, 0.98, 0.8))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		_spawn_puddle()
		queue_free()

func _spawn_puddle() -> void:
	if _puddled:
		return
	_puddled = true
	var puddle := Area2D.new()
	puddle.set_script(PUDDLE_SCRIPT)
	puddle.position = position
	get_parent().call_deferred("add_child", puddle)
