extends Node2D

@export var debris_scene: PackedScene
@export var ring_radius: float = 200.0
@export var debris_count: int = 20
@export var orbit_speed: float = 0.5
@export var respawn_time: float = 5.0

var _angle_offset: float = 0.0
var _debris: Array = []  # track debris pieces by slot index
var _respawn_timers: Array = []  # countdown per slot (-1 = alive)

func _ready() -> void:
	if debris_scene == null:
		return
	for i in range(debris_count):
		var debris = _create_debris()
		_debris.append(debris)
		_respawn_timers.append(-1.0)

func _create_debris() -> CharacterBody2D:
	var debris = debris_scene.instantiate()
	debris.min_speed = 0.0
	debris.max_speed = 0.0
	add_child(debris)
	return debris

func _process(delta: float) -> void:
	_angle_offset += orbit_speed * delta

	for i in range(_debris.size()):
		# Check if debris was destroyed — respawn after timer
		if not is_instance_valid(_debris[i]):
			if _respawn_timers[i] < 0:
				_respawn_timers[i] = respawn_time
			_respawn_timers[i] -= delta
			if _respawn_timers[i] <= 0:
				_debris[i] = _create_debris()
				_respawn_timers[i] = -1.0

		# Position living debris in the ring
		if is_instance_valid(_debris[i]):
			var base_angle = (TAU / debris_count) * i
			var current_angle = base_angle + _angle_offset
			_debris[i].position = Vector2(cos(current_angle), sin(current_angle)) * ring_radius
