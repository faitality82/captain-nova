extends Node2D

var target_position: Vector2 = Vector2.ZERO
var speed: float = 400.0
var hp: int = 40
var _lifetime: float = 8.0
var _time: float = 0.0
var _tail_direction: Vector2 = Vector2.LEFT
var _debris_offsets: Array[Vector2] = []
var _debris_sizes: Array[float] = []

func _ready() -> void:
	# Pre-generate random debris particles around the core
	for i in range(8):
		var angle = randf() * TAU
		var dist = randf_range(6.0, 18.0)
		_debris_offsets.append(Vector2(cos(angle), sin(angle)) * dist)
		_debris_sizes.append(randf_range(1.0, 2.5))

	# Collision
	var area = Area2D.new()
	area.name = "HitArea"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 15.0
	shape.shape = circle
	area.add_child(shape)
	area.body_entered.connect(_on_hit_body)
	add_child(area)

	var direction = (target_position - global_position).normalized()
	rotation = direction.angle()
	_tail_direction = -direction

func _process(delta: float) -> void:
	var dir = (target_position - global_position).normalized()
	global_position += dir * speed * delta
	_tail_direction = -dir
	_lifetime -= delta
	_time += delta
	queue_redraw()
	if _lifetime <= 0 or global_position.distance_to(target_position) < 50:
		queue_free()

func _draw() -> void:
	# Everything is drawn in local space; the tail extends opposite to travel direction.
	# We need to undo the node rotation so the tail points correctly in local coords.
	var tail_local = _tail_direction.rotated(-rotation)

	# --- Tail: series of fading, expanding circles trailing behind ---
	var tail_segments = 18
	for i in range(tail_segments, 0, -1):
		var t = float(i) / float(tail_segments)
		var offset = tail_local * (i * 8.0)
		# Slight wave for drama
		var perp = Vector2(-tail_local.y, tail_local.x)
		var wave = sin(_time * 4.0 + i * 0.5) * 3.0 * t
		offset += perp * wave
		var radius = lerpf(4.0, 14.0, t)
		var alpha = lerpf(0.35, 0.02, t)
		# Color shifts from icy blue near core to deep blue/purple at tip
		var color = Color(0.6 + 0.4 * (1.0 - t), 0.7 + 0.3 * (1.0 - t), 1.0, alpha)
		draw_circle(offset, radius, color)

	# --- Outer coma (fuzzy glow) ---
	var coma_pulse = 1.0 + sin(_time * 3.0) * 0.1
	draw_circle(Vector2.ZERO, 20.0 * coma_pulse, Color(0.6, 0.8, 1.0, 0.08))
	draw_circle(Vector2.ZERO, 15.0 * coma_pulse, Color(0.7, 0.85, 1.0, 0.15))
	draw_circle(Vector2.ZERO, 11.0 * coma_pulse, Color(0.8, 0.9, 1.0, 0.25))

	# --- Inner core: bright icy-white/blue ---
	var core_pulse = 1.0 + sin(_time * 5.0) * 0.08
	draw_circle(Vector2.ZERO, 10.0 * core_pulse, Color(0.85, 0.92, 1.0, 0.9))
	draw_circle(Vector2.ZERO, 7.0 * core_pulse, Color(0.95, 0.97, 1.0, 0.95))
	draw_circle(Vector2.ZERO, 4.0 * core_pulse, Color(1.0, 1.0, 1.0, 1.0))

	# --- Debris particles scattered near the core ---
	for i in range(_debris_offsets.size()):
		var base_offset = _debris_offsets[i]
		# Animate debris: slow orbit + slight jitter
		var orbit_angle = _time * (1.0 + i * 0.3)
		var animated_offset = base_offset.rotated(orbit_angle * 0.4)
		# Flicker alpha
		var flicker = 0.5 + 0.5 * sin(_time * 6.0 + i * 1.7)
		var debris_color = Color(0.8, 0.9, 1.0, 0.4 * flicker)
		draw_circle(animated_offset, _debris_sizes[i], debris_color)

	# --- Bright streaks near the core for extra drama ---
	for i in range(3):
		var streak_angle = _time * 2.0 + i * TAU / 3.0
		var streak_dir = Vector2(cos(streak_angle), sin(streak_angle))
		var streak_start = streak_dir * 5.0
		var streak_end = streak_dir * (12.0 + sin(_time * 4.0 + i) * 3.0)
		var streak_alpha = 0.3 + 0.2 * sin(_time * 5.0 + i * 2.0)
		draw_line(streak_start, streak_end, Color(0.9, 0.95, 1.0, streak_alpha), 1.5)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_drop_cargo()
		queue_free()

func _drop_cargo() -> void:
	var _resources = ResourceManager.ALL_RESOURCES
	var drops = randi_range(1, 2)
	for i in range(drops):
		var pickup_scene = load("res://scenes/world/ResourcePickup.tscn")
		if pickup_scene:
			var pickup = pickup_scene.instantiate()
			pickup.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			get_parent().call_deferred("add_child", pickup)

func _on_hit_body(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(30)
		queue_free()
