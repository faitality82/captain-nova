extends Node2D

@export var asteroid_scene: PackedScene
@export var field_size: Vector2 = Vector2(800, 600)
@export var max_asteroids: int = 15
@export var spawn_interval: float = 3.0
@export var resource_type: String = ""  # override asteroid drops ("" = use asteroid default)

var _asteroids: Array = []

func _ready() -> void:
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.timeout.connect(_spawn_asteroid)
	@warning_ignore("integer_division")
	for i in range(max_asteroids / 2):
		_spawn_asteroid()

func _spawn_asteroid() -> void:
	_asteroids = _asteroids.filter(func(a): return is_instance_valid(a))
	if _asteroids.size() >= max_asteroids:
		return
	if asteroid_scene == null:
		return
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(
		randf_range(-field_size.x / 2, field_size.x / 2),
		randf_range(-field_size.y / 2, field_size.y / 2)
	)
	if resource_type != "":
		asteroid.resource_drop = resource_type
	add_child(asteroid)
	_asteroids.append(asteroid)
