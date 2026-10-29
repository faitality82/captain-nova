extends CharacterBody2D

signal destroyed(pos: Vector2)

@export var hp: int = 80
@export var move_speed: float = 120.0
@export var damage_on_contact: int = 4
@export var kill_reward: int = 100
@export var xp_reward: int = 25

const CHARGE_SPEED: float = 400.0
const CHARGE_TRIGGER_DIST: float = 300.0
const CHARGE_DAMAGE: int = 10
const RECOVERY_TIME: float = 2.0

enum State { APPROACH, CHARGING, RECOVERING }

var _target: Node2D = null
var _state: State = State.APPROACH
var _charge_dir: Vector2 = Vector2.ZERO
var _recovery_timer: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)

func _process(delta: float) -> void:
	_time += delta

func _physics_process(delta: float) -> void:
	_find_target()
	if _target == null or not _target.is_in_group("player"):
		return
	if _target.get("is_dead") == true:
		return

	match _state:
		State.APPROACH:
			_do_approach()
		State.CHARGING:
			_do_charge()
		State.RECOVERING:
			_do_recovery(delta)

	move_and_slide()
	queue_redraw()

func _do_approach() -> void:
	var dir = (_target.global_position - global_position).normalized()
	var dist = global_position.distance_to(_target.global_position)
	velocity = dir * move_speed
	rotation = dir.angle()

	if dist <= CHARGE_TRIGGER_DIST:
		_charge_dir = dir
		_state = State.CHARGING

func _do_charge() -> void:
	velocity = _charge_dir * CHARGE_SPEED
	rotation = _charge_dir.angle()

	var dist = global_position.distance_to(_target.global_position)
	var dot = _charge_dir.dot((_target.global_position - global_position).normalized())
	if dist > CHARGE_TRIGGER_DIST * 1.5 and dot < 0:
		_state = State.RECOVERING
		_recovery_timer = RECOVERY_TIME

func _do_recovery(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)
	_recovery_timer -= delta
	if _recovery_timer <= 0:
		_state = State.APPROACH

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", -4.0)
	ResourceManager.add_money(kill_reward)
	ResourceManager.add_xp(xp_reward)
	# Skill tree on-kill effects
	var tree_fuel := ResourceManager.get_tree_effect("fuel_restore_on_kill")
	if tree_fuel > 0:
		ResourceManager.ship_fuel = min(ResourceManager.ship_fuel + ResourceManager.ship_max_fuel * tree_fuel, ResourceManager.ship_max_fuel)
	var tree_hp := int(ResourceManager.get_tree_effect("hp_on_kill"))
	if tree_hp > 0:
		ResourceManager.ship_hp = min(ResourceManager.ship_hp + tree_hp, ResourceManager.ship_max_hp)
	if randf() < ResourceManager.get_tree_effect("resource_drop_on_kill"):
		var resources = ["ore", "parts", "ice", "crystals"]
		ResourceManager.add_cargo(resources[randi() % resources.size()], 1)
	destroyed.emit(global_position)
	if randf() < 0.15:
		_drop_shield_pickup()
	queue_free()

func _drop_shield_pickup() -> void:
	var pickup_scene = load("res://scenes/world/ShieldPickup.tscn")
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position
		get_parent().call_deferred("add_child", pickup)

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var dmg = CHARGE_DAMAGE if _state == State.CHARGING else damage_on_contact
		body.take_damage(dmg)

func _draw() -> void:
	var hull_color: Color
	match _state:
		State.APPROACH:
			hull_color = Color(0.5, 0.2, 0.7)
		State.CHARGING:
			hull_color = Color(1.0, 0.15, 0.1)
		State.RECOVERING:
			hull_color = Color(0.35, 0.15, 0.5)

	# Outer hull — chunky 6-point wedge with flat ram front
	var hull_outer = PackedVector2Array([
		Vector2(18, -4),
		Vector2(18, 4),
		Vector2(-4, 13),
		Vector2(-14, 10),
		Vector2(-14, -10),
		Vector2(-4, -13),
	])
	draw_colored_polygon(hull_outer, hull_color)

	# Inner armor plating — slightly smaller, darker for depth
	var armor_color = hull_color.darkened(0.35)
	var hull_inner = PackedVector2Array([
		Vector2(15, -3),
		Vector2(15, 3),
		Vector2(-3, 10),
		Vector2(-11, 8),
		Vector2(-11, -8),
		Vector2(-3, -10),
	])
	draw_colored_polygon(hull_inner, armor_color)

	# Ram plate — bright metallic bar across the flat front
	var ram_color = Color(0.85, 0.85, 0.95)
	if _state == State.CHARGING:
		var pulse = (sin(_time * 12.0) + 1.0) * 0.5
		ram_color = ram_color.lerp(Color(1.0, 0.6, 0.3), pulse * 0.5)
	draw_line(Vector2(18, -5), Vector2(18, 5), ram_color, 3.0)

	# Viewport detail — small dark rectangle near front
	var viewport_color = Color(0.15, 0.15, 0.25)
	var vp = PackedVector2Array([
		Vector2(10, -2),
		Vector2(13, -2),
		Vector2(13, 2),
		Vector2(10, 2),
	])
	draw_colored_polygon(vp, viewport_color)

	# Engine thrust
	match _state:
		State.APPROACH:
			draw_circle(Vector2(-15, -5), 3.0, Color(1.0, 0.6, 0.2, 0.8))
			draw_circle(Vector2(-15, 5), 3.0, Color(1.0, 0.6, 0.2, 0.8))
		State.CHARGING:
			# Flame trail — multiple circles getting smaller and more transparent
			var flame_colors: Array[Color] = [
				Color(1.0, 0.2, 0.1, 0.9),
				Color(1.0, 0.45, 0.1, 0.7),
				Color(1.0, 0.65, 0.2, 0.5),
				Color(1.0, 0.85, 0.3, 0.35),
				Color(1.0, 1.0, 0.5, 0.2),
			]
			for i in range(5):
				var offset_x = -15.0 - float(i) * 5.0
				var flicker = sin(_time * 20.0 + float(i) * 1.5) * 1.5
				var r = maxf(4.0 - float(i) * 0.6, 1.0)
				draw_circle(Vector2(offset_x, -4 + flicker), r, flame_colors[i])
				draw_circle(Vector2(offset_x, 4 - flicker), r, flame_colors[i])
			# Impact sparks near front during charge
			for j in range(4):
				var spark_angle = sin(_time * 15.0 + float(j) * 2.3) * 6.0
				var spark_x = 18.0 + cos(_time * 10.0 + float(j) * 3.7) * 4.0
				var spark_alpha = maxf((sin(_time * 18.0 + float(j) * 4.1) + 1.0) * 0.4, 0.0)
				draw_circle(Vector2(spark_x, spark_angle), 1.5, Color(1.0, 1.0, 1.0, spark_alpha))
		State.RECOVERING:
			var dim = 0.4
			draw_circle(Vector2(-15, -5), 2.0, Color(1.0, 0.6, 0.2, dim))
			draw_circle(Vector2(-15, 5), 2.0, Color(1.0, 0.6, 0.2, dim))

	# Recovery ring — double arc glow
	if _state == State.RECOVERING:
		var progress = 1.0 - _recovery_timer / RECOVERY_TIME
		var sweep = TAU * progress
		draw_arc(Vector2.ZERO, 20.0, 0, sweep, 24, Color(1.0, 1.0, 0.0, 0.2), 5.0)
		draw_arc(Vector2.ZERO, 20.0, 0, sweep, 24, Color(1.0, 1.0, 0.0, 0.6), 2.0)
