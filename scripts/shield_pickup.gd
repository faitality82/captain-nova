extends Area2D

## Pickup that grants the player a 5-bullet orbiting shield.
## Procedural cyan shield icon with pulsing glow and orbiting sparkles.

var _spin_speed: float = 2.0
var _time: float = 0.0

# Drawing constants
const SHIELD_RADIUS: float = 8.0
const CROSS_HALF: float = 5.0
const CROSS_THICK: float = 2.0
const GLOW_RADIUS: float = 12.0
const SPARKLE_ORBIT: float = 14.0
const SPARKLE_COUNT: int = 4
const SPARKLE_SIZE: float = 1.5

func _ready() -> void:
	add_to_group("shield_pickup")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var rotation_angle := _time * _spin_speed
	var pulse := 0.7 + sin(_time * 3.0) * 0.3

	# --- Pulsing glow ring ---
	var glow_color := Color(0.0, 0.9, 1.0, 0.25 * pulse)
	var glow_r := GLOW_RADIUS + sin(_time * 4.0) * 1.5
	draw_arc(Vector2.ZERO, glow_r, 0.0, TAU, 48, glow_color, 2.0)
	# Second softer outer ring
	var outer_glow := Color(0.0, 0.8, 1.0, 0.12 * pulse)
	draw_arc(Vector2.ZERO, glow_r + 2.5, 0.0, TAU, 48, outer_glow, 1.5)

	# --- Shield circle (rotated) ---
	var shield_color := Color(0.2, 0.85, 1.0, 0.9)
	# Draw the circle outline
	draw_arc(Vector2.ZERO, SHIELD_RADIUS, 0.0, TAU, 32, shield_color, 1.8)
	# Filled inner circle (darker)
	var fill_color := Color(0.05, 0.3, 0.5, 0.4)
	draw_circle(Vector2.ZERO, SHIELD_RADIUS - 1.0, fill_color)

	# --- Plus/cross inside (rotated) ---
	var cross_color := Color(0.4, 1.0, 1.0, 0.95)
	# Vertical bar of cross
	var v_top := Vector2(0, -CROSS_HALF).rotated(rotation_angle)
	var v_bot := Vector2(0, CROSS_HALF).rotated(rotation_angle)
	draw_line(v_top, v_bot, cross_color, CROSS_THICK)
	# Horizontal bar of cross
	var h_left := Vector2(-CROSS_HALF, 0).rotated(rotation_angle)
	var h_right := Vector2(CROSS_HALF, 0).rotated(rotation_angle)
	draw_line(h_left, h_right, cross_color, CROSS_THICK)

	# --- Orbiting sparkles ---
	var sparkle_color := Color(0.6, 1.0, 1.0, pulse)
	for i in SPARKLE_COUNT:
		var angle := rotation_angle * 1.5 + (TAU / SPARKLE_COUNT) * i
		var pos := Vector2(cos(angle), sin(angle)) * SPARKLE_ORBIT
		draw_circle(pos, SPARKLE_SIZE * (0.7 + pulse * 0.3), sparkle_color)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("add_shield"):
		body.add_shield(5)
		AudioManager.play_sfx("sfx_pickup", -2.0)
		queue_free()
