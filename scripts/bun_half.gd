extends CharacterBody2D

## One half of Frank's bun, detached in phase 2. Orbits the host and soaks player bullets.
## Built in code by big_frank.gd. Uses bun_half.png from OE-0076 if present, else draws itself.

signal destroyed(pos: Vector2)

const SPRITE_PATH := "res://assets/sprites/frank/bun_half.png"
const FLASH_COLOR := Color(2, 2, 2)

var hp: int = 60
var host: Node2D = null
var orbit_radius: float = 78.0
var orbit_speed: float = 2.2          # radians per second
var orbit_angle: float = 0.0
var _flash: float = 0.0
var _sprite: Sprite2D = null

func _ready() -> void:
	add_to_group("enemy")
	collision_layer = 32
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 20.0
	capsule.height = 60.0
	shape.shape = capsule
	shape.rotation = PI / 2.0
	add_child(shape)
	var tex := load(SPRITE_PATH) as Texture2D if ResourceLoader.exists(SPRITE_PATH) else null
	if tex != null:
		_sprite = Sprite2D.new()
		_sprite.texture = tex
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(_sprite)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(host):
		queue_free()
		return
	orbit_angle += orbit_speed * delta
	global_position = host.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	rotation = orbit_angle + PI / 2.0
	if _flash > 0.0:
		_flash -= delta
	if _sprite != null:
		_sprite.modulate = FLASH_COLOR if _flash > 0.0 else Color.WHITE
	else:
		queue_redraw()

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp -= amount
	_flash = 0.08
	if hp <= 0:
		AudioManager.play_sfx("sfx_explosion", -6.0)
		ResourceManager.add_xp(40)
		destroyed.emit(global_position)
		queue_free()

func _draw() -> void:
	# Fallback: toasted bun half (a thick arc), charred spots, cyan rim light.
	var col := Color(0.72, 0.5, 0.28) if _flash <= 0.0 else Color.WHITE
	draw_arc(Vector2.ZERO, 18.0, PI * 0.15, PI * 0.85, 12, col, 12.0)
	draw_arc(Vector2.ZERO, 24.0, PI * 0.2, PI * 0.8, 12, Color(0.2, 0.9, 1.0, 0.7), 1.5)
	draw_circle(Vector2(-6, 14), 2.0, Color(0.25, 0.15, 0.1))
	draw_circle(Vector2(5, 15), 1.6, Color(0.25, 0.15, 0.1))
