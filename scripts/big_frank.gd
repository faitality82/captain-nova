extends CharacterBody2D

## BIG FRANK — Phobos Meat Works boss. Sprite-based (direction B pixel art).
## Phase 1 "Fresh Off the Line": mustard bolts (aimed), relish burst (spread).
## Phase 2 "Sizzle": bun halves detach as orbiting shields, Glizzy Rush charge, condiment rain.
## Phase 3 "Well Done": on fire, double speed, Lil' Smokies swarm; arena turns on the grinders.
##
## Tuning: the charge telegraphs with a 0.35 s red wind-up, then 0.55 s at 520 px/s for 22 damage.
## Body contact is 6 damage on a 0.8 s cooldown (shared with the charge hit).
## Phase 3 keeps at most MAX_SMOKIES (8) Lil' Smokies alive at once.

signal destroyed(pos: Vector2)
signal boss_defeated
signal boss_hp_changed(current: int, maximum: int)
signal phase_changed(phase: int)

const SPRITES := {
	1: "res://assets/sprites/frank/frank_phase1.png",
	2: "res://assets/sprites/frank/frank_phase2.png",
	3: "res://assets/sprites/frank/frank_phase3.png",
}
const MUSTARD_BOLT := preload("res://scenes/world/MustardBolt.tscn")
const RELISH_FLAKE := preload("res://scenes/world/RelishFlake.tscn")
const SWARM_DRONE := preload("res://scenes/world/SwarmDrone.tscn")
const BUN_HALF_SCRIPT := preload("res://scripts/bun_half.gd")
const MAX_SMOKIES := 8

@export var hp: int = 1800
@export var max_hp: int = 1800
@export var base_speed: float = 70.0
@export var kill_reward: int = 1500
@export var xp_reward: int = 1200

var arena_rect: Rect2 = Rect2(-600, -320, 1200, 640)   # frank_arena.gd overrides

var _target: Node2D = null
var _phase: int = 0
var _attack_timer: float = 1.5
var _attack_cycle: int = 0
var _charge_cooldown: float = 4.0
var _is_charging: bool = false
var _charge_dir: Vector2 = Vector2.ZERO
var _charge_duration: float = 0.0
var _charge_windup: float = 0.0
var _rain_timer: float = 0.0
var _smokie_timer: float = 3.0
var _contact_cooldown: float = 0.0
var _flash_timer: float = 0.0
var _time: float = 0.0
var _fire: CPUParticles2D = null

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$DamageArea.body_entered.connect(_on_damage_area_body_entered)
	_build_fire()
	_set_phase(1)
	boss_hp_changed.emit(hp, max_hp)

func _build_fire() -> void:
	_fire = CPUParticles2D.new()
	_fire.emitting = false
	_fire.amount = 48
	_fire.lifetime = 0.7
	_fire.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_fire.emission_sphere_radius = 34.0
	_fire.direction = Vector2(0, -1)
	_fire.spread = 25.0
	_fire.gravity = Vector2(0, -160)
	_fire.initial_velocity_min = 40.0
	_fire.initial_velocity_max = 90.0
	_fire.scale_amount_min = 3.0
	_fire.scale_amount_max = 6.0
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.85, 0.25))
	grad.set_color(1, Color(1.0, 0.24, 0.65, 0.0))
	_fire.color_ramp = grad
	_fire.z_index = 1
	add_child(_fire)

func _process(delta: float) -> void:
	_time += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _charge_windup <= 0.0:
			_sprite.modulate = Color(2.5, 2.5, 2.5)
	elif _charge_windup <= 0.0:
		_sprite.modulate = Color.WHITE
	# idle bob so a static sprite still feels alive
	_sprite.position.y = sin(_time * 3.0) * 2.0

func _physics_process(delta: float) -> void:
	_find_target()
	if _target == null or _target.get("is_dead") == true:
		return
	_update_phase()
	_contact_cooldown = maxf(_contact_cooldown - delta, 0.0)
	_charge_cooldown = maxf(_charge_cooldown - delta, 0.0)

	if _is_charging:
		_do_charge(delta)
		_clamp_to_arena()
		return

	if _charge_windup > 0.0:
		_charge_windup -= delta
		velocity = Vector2.ZERO
		_sprite.modulate = Color(1.8, 0.55, 0.55)   # red wind-up = the tell
		if _charge_windup <= 0.0:
			_is_charging = true
			_charge_duration = 0.55
			_flash_timer = 0.0
		return

	var to_player: Vector2 = _target.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized()
	var speed := base_speed * (2.0 if _phase == 3 else 1.0)
	var preferred := 210.0
	if dist > preferred + 60.0:
		velocity = dir * speed
	elif dist < preferred - 60.0:
		velocity = -dir * speed * 0.5
	else:
		velocity = Vector2(-dir.y, dir.x) * speed * 0.7
	if _phase >= 2:
		velocity += Vector2(sin(_time * 2.3), cos(_time * 1.7)) * 30.0
	move_and_slide()
	_clamp_to_arena()
	_sprite.flip_h = dir.x < 0.0

	if _contact_cooldown <= 0.0:
		for body in $DamageArea.get_overlapping_bodies():
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(6)
				_contact_cooldown = 0.8
				break

	# Attacks
	_attack_timer -= delta
	if _attack_timer <= 0.0 and dist < 900.0:
		_attack_timer = 2.2 / float(_phase)
		_attack_cycle = (_attack_cycle + 1) % 3
		match _attack_cycle:
			0: _fire_mustard(dir)
			1: _fire_relish(dir)
			2:
				if _phase >= 2 and _charge_cooldown <= 0.0:
					_start_charge(dir)
				else:
					_fire_mustard(dir)

	if _phase >= 2:
		_rain_timer -= delta
		if _rain_timer <= 0.0:
			_rain_timer = 0.6 if _phase == 2 else 0.4
			_condiment_rain()
	if _phase == 3:
		_smokie_timer -= delta
		if _smokie_timer <= 0.0:
			_smokie_timer = 7.0
			_spawn_smokies()

func _find_target() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

func _update_phase() -> void:
	var pct := float(hp) / float(max_hp)
	var want := 1
	if pct < 0.3:
		want = 3
	elif pct < 0.6:
		want = 2
	while _phase < want:
		_set_phase(_phase + 1)

func _set_phase(p: int) -> void:
	_phase = p
	if ResourceLoader.exists(SPRITES[p]):
		_sprite.texture = load(SPRITES[p])
	match p:
		2:
			_detach_buns()
			AudioManager.play_sfx("sfx_boss_warning", -4.0)
			ResourceManager.add_log("Big Frank shed his bun. The bun is fighting too.", "combat")
		3:
			_fire.emitting = true
			AudioManager.play_sfx("sfx_boss_warning", 0.0)
			ResourceManager.add_log("Big Frank is on fire and does not seem to mind.", "combat")
	phase_changed.emit(p)

func _clamp_to_arena() -> void:
	global_position.x = clampf(global_position.x, arena_rect.position.x + 50.0, arena_rect.end.x - 50.0)
	global_position.y = clampf(global_position.y, arena_rect.position.y + 60.0, arena_rect.end.y - 60.0)

# --- Attacks ---

func _fire_mustard(dir: Vector2) -> void:
	var burst := 2 + _phase
	for i in range(burst):
		var b = MUSTARD_BOLT.instantiate()
		b.global_position = global_position + dir * 48.0
		b.direction = dir.rotated(0.07 * (i - (burst - 1) / 2.0))
		get_parent().call_deferred("add_child", b)
	AudioManager.play_sfx("sfx_enemy_shoot", -6.0)

func _fire_relish(dir: Vector2) -> void:
	var count := 6 + _phase * 2
	var arc := 1.1 + _phase * 0.35
	for i in range(count):
		var off: float = lerp(-arc / 2.0, arc / 2.0, float(i) / float(count - 1))
		var f = RELISH_FLAKE.instantiate()
		f.global_position = global_position + dir * 48.0
		f.direction = dir.rotated(off)
		get_parent().call_deferred("add_child", f)
	AudioManager.play_sfx("sfx_spread", -4.0)

func _start_charge(dir: Vector2) -> void:
	_charge_dir = dir
	_charge_windup = 0.35
	_charge_cooldown = 9.0 / float(_phase)

func _do_charge(delta: float) -> void:
	velocity = _charge_dir * 520.0
	move_and_slide()
	_charge_duration -= delta
	if _charge_duration <= 0.0:
		_is_charging = false
	if _target and is_instance_valid(_target) and _contact_cooldown <= 0.0:
		if global_position.distance_to(_target.global_position) < 64.0 and _target.has_method("take_damage"):
			_target.take_damage(22)
			_contact_cooldown = 0.8

func _condiment_rain() -> void:
	var b = MUSTARD_BOLT.instantiate()
	b.global_position = Vector2(randf_range(arena_rect.position.x + 20.0, arena_rect.end.x - 20.0), arena_rect.position.y + 10.0)
	b.direction = Vector2.DOWN
	get_parent().call_deferred("add_child", b)

func _detach_buns() -> void:
	for i in range(2):
		var bun = CharacterBody2D.new()
		bun.set_script(BUN_HALF_SCRIPT)
		bun.host = self
		bun.orbit_angle = PI * i
		get_parent().call_deferred("add_child", bun)

func _spawn_smokies() -> void:
	var world := get_parent()
	var live := get_tree().get_nodes_in_group("smokie").size()
	if live >= MAX_SMOKIES:
		return
	for i in range(mini(4, MAX_SMOKIES - live)):
		var s = SWARM_DRONE.instantiate()
		s.body_color = Color(0.75, 0.22, 0.18)   # Lil' Smokie: cocktail-sausage red
		s.hp = 25
		s.move_speed = 190.0
		s.damage_on_contact = 3
		s.kill_reward = 30
		s.global_position = global_position + Vector2(cos(i * PI / 2.0), sin(i * PI / 2.0)) * 70.0
		s.add_to_group("smokie")
		world.call_deferred("add_child", s)
	AudioManager.play_sfx("sfx_enemy_shoot", -8.0)

# --- Damage / death ---

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage") and _contact_cooldown <= 0.0:
		body.take_damage(6)
		_contact_cooldown = 0.8

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	if _target != null and is_instance_valid(_target) and _target.get("is_dead") == true:
		return   # bullets in flight after the player dies must not finish him (mutual-kill exploit)
	hp -= amount
	boss_hp_changed.emit(hp, max_hp)
	_flash_timer = 0.08
	if hp <= 0:
		_die()

func _die() -> void:
	AudioManager.play_sfx("sfx_explosion", 0.0)
	ResourceManager.add_money(kill_reward)
	ResourceManager.add_xp(xp_reward)
	ResourceManager.apply_kill_effects()
	if 4 not in ResourceManager.boss_tiers_cleared:
		ResourceManager.boss_tiers_cleared.append(4)
	ResourceManager.npc_powerups["franks_mustard"] = true
	ResourceManager.add_log("Big Frank is down. Phobos Meat Works is quiet. Frank's Mustard unlocked at any paint shop.", "combat")
	destroyed.emit(global_position)
	boss_defeated.emit()
	queue_free()
