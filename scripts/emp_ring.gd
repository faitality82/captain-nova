extends Node2D

var _radius: float = 10.0
var _max_radius: float = 400.0
var _expand_speed: float = 800.0
var _alpha: float = 1.0

func _process(delta: float) -> void:
	_radius += _expand_speed * delta
	_alpha = 1.0 - (_radius / _max_radius)
	queue_redraw()
	if _radius >= _max_radius:
		queue_free()

func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 64, Color(0.3, 0.5, 1.0, _alpha), 3.0)
	draw_arc(Vector2.ZERO, _radius * 0.8, 0, TAU, 48, Color(0.5, 0.7, 1.0, _alpha * 0.5), 1.5)
