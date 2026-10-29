extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 50
@export var damage_on_contact: int = 3
@export var resource_drop: String = "ore"
@export var min_speed: float = 20.0
@export var max_speed: float = 80.0
@export var resource_pickup_scene: PackedScene

var _rot_speed: float = 0.0

func _ready() -> void:
	var angle = randf() * TAU
	var spd = randf_range(min_speed, max_speed)
	velocity = Vector2(cos(angle), sin(angle)) * spd
	_rot_speed = randf_range(-1.0, 1.0)
	$DamageArea.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	move_and_slide()
	$Sprite2D.rotation += _rot_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_on_contact)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_destroy()

@export var kill_reward: int = 25

func _destroy() -> void:
	AudioManager.play_sfx("sfx_explosion", -6.0)
	destroyed.emit(global_position)
	ResourceManager.add_money(kill_reward)
	_spawn_resource_pickup()
	queue_free()

func _spawn_resource_pickup() -> void:
	if resource_pickup_scene == null:
		# Fallback: add cargo directly if pickup scene is missing
		if ResourceManager.add_cargo(resource_drop, 1):
			AudioManager.play_sfx("sfx_pickup", -4.0)
		return
	var pickup = resource_pickup_scene.instantiate()
	pickup.global_position = global_position
	pickup.resource_type = resource_drop
	# Add to the world root so pickups don't orbit with planet fields
	var world = get_tree().current_scene
	if world:
		world.call_deferred("add_child", pickup)
	else:
		get_parent().call_deferred("add_child", pickup)
