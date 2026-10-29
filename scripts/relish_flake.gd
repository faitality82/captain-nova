extends "res://scripts/enemy_bullet.gd"

## Big Frank's spread shot. Green shard, tumbles.

func _init() -> void:
	speed = 300.0
	damage = 3
	_lifetime = 2.0

func _draw() -> void:
	var spin := _time * 9.0
	var pts := PackedVector2Array([
		Vector2(5, 0).rotated(spin), Vector2(-3, 3).rotated(spin), Vector2(-4, -2).rotated(spin)
	])
	draw_colored_polygon(pts, Color(0.55, 0.95, 0.25))
	draw_circle(Vector2.ZERO, 6.0, Color(0.55, 0.95, 0.25, 0.15))
