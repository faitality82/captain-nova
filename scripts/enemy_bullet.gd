extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 3
var _lifetime: float = 3.0
var _time: float = 0.0

func _ready() -> void:
	add_to_group("enemy_bullet")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_time += delta
	global_position += direction * speed * delta
	rotation = direction.angle()
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var pulse: float = 1.0 + 0.15 * sin(_time * 12.0)
	var core_color: Color = Color(1.0, 0.2, 0.15)
	var trail_color: Color = Color(1.0, 0.35, 0.1)

	# Outer glow around core
	var glow_color: Color = Color(1.0, 0.15, 0.1, 0.15)
	draw_circle(Vector2.ZERO, 10.0 * pulse, glow_color)

	# Trail circles behind the core (drawn first so core overlaps)
	var trail_offsets: Array[float] = [-12.0, -9.0, -6.0, -3.5]
	var trail_sizes: Array[float] = [1.5, 2.0, 2.8, 3.5]
	var trail_alphas: Array[float] = [0.08, 0.15, 0.25, 0.4]
	for i in range(trail_offsets.size()):
		var t_color: Color = Color(trail_color.r, trail_color.g, trail_color.b, trail_alphas[i])
		draw_circle(Vector2(trail_offsets[i], 0.0), trail_sizes[i], t_color)

	# Core body: overlapping circles to form elongated bolt shape
	var core_size: float = maxf(3.0 * pulse, 1.0)
	draw_circle(Vector2(-2.0, 0.0), core_size * 0.85, core_color)
	draw_circle(Vector2(0.0, 0.0), core_size, core_color)
	draw_circle(Vector2(2.0, 0.0), core_size * 0.9, core_color)

	# Brighter inner highlight
	var highlight_color: Color = Color(1.0, 0.5, 0.3, 0.7)
	draw_circle(Vector2(1.0, 0.0), core_size * 0.55, highlight_color)

	# Hot white-yellow dot at the very front
	var hot_color: Color = Color(1.0, 0.95, 0.7, 0.9)
	draw_circle(Vector2(3.5, 0.0), maxf(1.2 * pulse, 0.8), hot_color)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
