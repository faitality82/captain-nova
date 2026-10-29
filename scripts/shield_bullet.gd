extends Area2D

## Each shield bullet orbits the player ship and blocks one hit.
## Engineer crew bonus: survives 2 hits instead of 1.

var damage: int = 20
var orbit_index: int = 0
var orbit_total: int = 5
var _hits_remaining: int = 1
var _time: float = 0.0

func _ready() -> void:
	add_to_group("shield_bullet")
	if ResourceManager.has_crew("engineer"):
		_hits_remaining = 2
	# Skill tree: Shield Wall — shields absorb multiple hits
	if ResourceManager.has_tree_effect("shield_bullet_absorb"):
		_hits_remaining = maxi(_hits_remaining, int(ResourceManager.get_tree_effect("shield_bullet_absorb")))
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	# --- Core orb glow (cyan-blue, ~5px radius) ---
	var core_color := Color(0.3, 0.85, 1.0, 0.9)
	var glow_color := Color(0.2, 0.7, 1.0, 0.25)

	# Soft glow halo behind the orb
	draw_circle(Vector2.ZERO, 8.0, glow_color)
	# Solid core
	draw_circle(Vector2.ZERO, 5.0, core_color)
	# Bright center highlight
	draw_circle(Vector2.ZERO, 2.0, Color(0.8, 0.95, 1.0, 1.0))

	# --- Outer ring that pulses ---
	var pulse := 0.5 + 0.5 * sin(_time * 4.0)
	var ring_alpha := 0.4 + 0.3 * pulse
	var ring_radius := 7.0 + 1.0 * pulse
	var ring_color := Color(0.3, 0.8, 1.0, ring_alpha)
	_draw_ring(Vector2.ZERO, ring_radius, ring_color, 1.2)

	# --- Extra durability ring (engineer or Shield Wall) ---
	if _hits_remaining >= 2:
		var outer_pulse := 0.5 + 0.5 * sin(_time * 2.5 + 1.0)
		var outer_alpha := 0.2 + 0.15 * outer_pulse
		var outer_radius := 10.0 + 1.5 * outer_pulse
		var outer_color := Color(0.5, 0.6, 1.0, outer_alpha)
		_draw_ring(Vector2.ZERO, outer_radius, outer_color, 0.8)

	# --- Small sparkle / twinkle effect ---
	var sparkle_angle := _time * 3.0
	var sparkle_alpha := 0.3 + 0.7 * maxf(0.0, sin(_time * 6.0))
	var sparkle_offset := Vector2(cos(sparkle_angle), sin(sparkle_angle)) * 4.0
	var sparkle_size := 1.0 + 0.5 * sin(_time * 8.0)
	var sparkle_color := Color(1.0, 1.0, 1.0, sparkle_alpha)
	draw_circle(sparkle_offset, sparkle_size, sparkle_color)

	# Second sparkle opposite side, offset timing
	var sparkle2_angle := _time * 3.0 + PI
	var sparkle2_alpha := 0.3 + 0.7 * maxf(0.0, sin(_time * 6.0 + PI))
	var sparkle2_offset := Vector2(cos(sparkle2_angle), sin(sparkle2_angle)) * 3.5
	var sparkle2_size := 0.8 + 0.4 * sin(_time * 7.0 + 1.5)
	var sparkle2_color := Color(0.7, 0.9, 1.0, sparkle2_alpha)
	draw_circle(sparkle2_offset, sparkle2_size, sparkle2_color)

func _draw_ring(center: Vector2, radius: float, color: Color, width: float) -> void:
	var segments := 32
	var prev := center + Vector2(radius, 0.0)
	for i in range(1, segments + 1):
		var angle := TAU * i / segments
		var next := center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(prev, next, color, width)
		prev = next

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	AudioManager.play_sfx("sfx_hit", -6.0)
	_take_hit()

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
		AudioManager.play_sfx("sfx_hit", -6.0)
		_take_hit()

func _take_hit() -> void:
	_hits_remaining -= 1
	if _hits_remaining <= 0:
		_remove_self()
	else:
		# Visual feedback — flash
		modulate = Color(0.5, 0.5, 1, 0.7)
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(self):
			modulate = Color(1, 1, 1, 1)

func _remove_self() -> void:
	var ship = get_tree().get_first_node_in_group("player")
	if ship and ship.has_method("_on_shield_bullet_destroyed"):
		ship._on_shield_bullet_destroyed(self)
	queue_free()
