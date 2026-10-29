extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -350.0
const GRAVITY: float = 980.0

var _anim_state: String = "idle"
var _facing_left: bool = false
var _time: float = 0.0
var _was_on_floor: bool = true
var _walk_cycle: float = 0.0  # Continuous walk phase
var _land_particles: Array = []
var _walk_dust: Array = []
var _boot_sparks: Array = []
var _jump_trail: Array = []

# Colors — Nova's signature palette (matches NPC roster design)
var _cyan: Color = Color(0.15, 0.6, 0.25)           # Vivid green (her eyes + accent color)
var _dark_suit: Color = Color(0.18, 0.15, 0.2)       # Near-black with purple undertone
var _suit_mid: Color = Color(0.22, 0.19, 0.25)       # Slightly lighter jacket mid-tone
var _suit_light: Color = Color(0.28, 0.24, 0.32)     # Jacket highlight
var _skin_tone: Color = Color(0.78, 0.62, 0.48)      # Warm sun-kissed skin
var _hair_color: Color = Color(0.55, 0.18, 0.08)     # Deep copper-auburn
var _boot_color: Color = Color(0.15, 0.12, 0.1)      # Scuffed black combat boots
var _cape_color: Color = Color(0.15, 0.12, 0.18)     # Dark vest/cape backing
var _cape_lining: Color = Color(0.25, 0.12, 0.15)    # Dark burgundy lining


func _ready() -> void:
	add_to_group("nova")


func _process(delta: float) -> void:
	_time += delta
	if _anim_state == "walk":
		var spd: float = abs(velocity.x)
		_walk_cycle += delta * spd * 0.04
	_update_particles(delta)
	queue_redraw()

	# Detect landing
	if is_on_floor() and not _was_on_floor:
		_spawn_landing_dust()
	_was_on_floor = is_on_floor()

	# Walk dust
	if is_on_floor() and abs(velocity.x) > 50:
		if randf() < 0.3:
			_spawn_walk_dust()

	# Boot sparks while walking
	if is_on_floor() and abs(velocity.x) > 100:
		if randf() < 0.15:
			_spawn_boot_spark()

	# Jump trail
	if not is_on_floor() and abs(velocity.y) > 50:
		if randf() < 0.4:
			_spawn_jump_trail()


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction = 0.0
	if Input.is_action_pressed("move_left"):
		direction -= 1.0
	if Input.is_action_pressed("move_right"):
		direction += 1.0

	velocity.x = direction * SPEED

	# Track facing direction
	if direction != 0:
		_facing_left = direction < 0

	move_and_slide()

	# Animation state
	_update_animation_state()


func _update_animation_state() -> void:
	var new_state = "idle"
	if not is_on_floor():
		new_state = "jump"
	elif abs(velocity.x) > 10:
		new_state = "walk"
	_anim_state = new_state


# ================================================================
#  PARTICLES
# ================================================================

func _spawn_landing_dust() -> void:
	for i in range(8):
		var spread: float = randf_range(-1.0, 1.0)
		_land_particles.append({
			"pos": Vector2(spread * 15.0, 36.0),
			"vel": Vector2(spread * 75.0, randf_range(-45.0, -12.0)),
			"life": randf_range(0.3, 0.7),
			"color": Color(0.7, 0.65, 0.5, 0.8)
		})

func _spawn_walk_dust() -> void:
	var dir: float = -1.0 if velocity.x > 0 else 1.0
	_walk_dust.append({
		"pos": Vector2(dir * 7.5, 35.0),
		"vel": Vector2(dir * randf_range(15.0, 45.0), randf_range(-12.0, -3.0)),
		"life": randf_range(0.2, 0.4),
		"color": Color(0.6, 0.55, 0.4, 0.5)
	})

func _spawn_boot_spark() -> void:
	var fx: float = -1.0 if _facing_left else 1.0
	var foot_x: float = fx * randf_range(-4.5, 4.5)
	_boot_sparks.append({
		"pos": Vector2(foot_x, 35.0),
		"vel": Vector2(randf_range(-22.5, 22.5), randf_range(-37.5, -15.0)),
		"life": randf_range(0.1, 0.25),
		"color": Color(0.0, 0.9, 1.0, 0.9)
	})

func _spawn_jump_trail() -> void:
	var fx: float = -1.0 if _facing_left else 1.0
	for boot_x in [-6.0 * fx, 6.0 * fx]:
		_jump_trail.append({
			"pos": Vector2(boot_x, 33.0),
			"vel": Vector2(randf_range(-7.5, 7.5), randf_range(12.0, 30.0)),
			"life": randf_range(0.15, 0.35),
			"color": Color(0.0, 0.7, 1.0, 0.6)
		})

func _update_particles(delta: float) -> void:
	for p in _land_particles:
		p["pos"] += p["vel"] * delta
		p["vel"].y += 60.0 * delta
		p["life"] -= delta
	_land_particles = _land_particles.filter(func(p): return p["life"] > 0)

	for p in _walk_dust:
		p["pos"] += p["vel"] * delta
		p["life"] -= delta
	_walk_dust = _walk_dust.filter(func(p): return p["life"] > 0)

	for p in _boot_sparks:
		p["pos"] += p["vel"] * delta
		p["vel"].y += 40.0 * delta
		p["life"] -= delta
	_boot_sparks = _boot_sparks.filter(func(p): return p["life"] > 0)

	for p in _jump_trail:
		p["pos"] += p["vel"] * delta
		p["life"] -= delta
	_jump_trail = _jump_trail.filter(func(p): return p["life"] > 0)


# ================================================================
#  DRAW
# ================================================================

func _draw() -> void:
	var fx: float = -1.0 if _facing_left else 1.0

	# --- Animation parameters ---
	var breathe: float = sin(_time * 2.5) * 1.5
	var energy_pulse: float = 0.5 + 0.5 * sin(_time * 3.5)
	var walk_phase: float = _walk_cycle
	var walk_sin: float = sin(walk_phase * TAU)
	var walk_bounce: float = 0.0
	var l_leg_angle: float = 0.0
	var r_leg_angle: float = 0.0
	var l_arm_swing: float = 0.0
	var r_arm_swing: float = 0.0

	if _anim_state == "walk":
		walk_bounce = abs(walk_sin) * 3.0
		l_leg_angle = walk_sin * 0.5
		r_leg_angle = -walk_sin * 0.5
		l_arm_swing = -walk_sin * 12.0
		r_arm_swing = walk_sin * 12.0

	# --- Key positions (origin = center of collision, feet at +36, head at -43) ---
	var foot_y: float = 36.0
	var boot_top_y: float = 24.0
	var knee_y: float = 15.0
	var waist_y: float = 3.0
	var belt_y: float = 0.0
	var chest_y: float = -12.0 - walk_bounce + breathe
	var shoulder_y: float = -18.0 - walk_bounce + breathe
	var neck_y: float = -23.0 - walk_bounce + breathe
	var head_center_y: float = -33.0 - walk_bounce + breathe

	# =====================
	# HALF-CAPE (behind body)
	# =====================
	_draw_cape(fx, shoulder_y, waist_y, foot_y, walk_sin)

	# =====================
	# JUMP TRAIL PARTICLES (behind body)
	# =====================
	for p in _jump_trail:
		var alpha: float = p["life"] * p["color"].a * 2.0
		var c = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
		draw_circle(p["pos"], 3.0 * p["life"] + 0.75, c)

	# =====================
	# BOOT THRUSTER GLOW (behind boots when jumping)
	# =====================
	if not is_on_floor():
		_draw_thruster_glow(fx, foot_y)

	# =====================
	# LEGS
	# =====================
	_draw_legs(fx, foot_y, boot_top_y, knee_y, waist_y, l_leg_angle, r_leg_angle)

	# =====================
	# TORSO / BODYSUIT
	# =====================
	_draw_torso(fx, waist_y, belt_y, chest_y, shoulder_y, energy_pulse)

	# =====================
	# ARMS
	# =====================
	_draw_arms(fx, shoulder_y, waist_y, l_arm_swing, r_arm_swing, breathe)

	# =====================
	# UTILITY BELT & POUCHES
	# =====================
	_draw_belt(fx, belt_y, waist_y)

	# =====================
	# NECK & HEAD
	# =====================
	_draw_head(fx, neck_y, head_center_y, energy_pulse, breathe)

	# =====================
	# ENERGY LINES (over everything)
	# =====================
	_draw_energy_lines(fx, shoulder_y, waist_y, boot_top_y, energy_pulse, breathe)

	# =====================
	# VISOR GLOW (over everything)
	# =====================
	_draw_visor_glow(fx, head_center_y, energy_pulse)

	# =====================
	# PARTICLES (over everything)
	# =====================
	_draw_particles()

	# =====================
	# IDLE SPARKLE
	# =====================
	if _anim_state == "idle":
		_draw_idle_sparkle(fx, chest_y)


# ================================================================
#  DRAW SUB-FUNCTIONS
# ================================================================

func _draw_cape(fx: float, shoulder_y: float, waist_y: float, foot_y: float, walk_sin: float) -> void:
	# Half-cape on the left side (right side when facing left) — asymmetric detail
	var cape_sway: float = sin(_time * 1.8) * 4.5
	var walk_sway: float = 0.0
	if _anim_state == "walk":
		walk_sway = walk_sin * 6.0
	if _anim_state == "jump":
		cape_sway += 7.5  # Cape billows up in jump

	var cape_x: float = -9.0 * fx  # Cape hangs on the left shoulder
	var cape_poly: PackedVector2Array = PackedVector2Array([
		Vector2(cape_x, shoulder_y),
		Vector2(cape_x - 6.0 * fx, shoulder_y + 3.0),
		Vector2(cape_x - 9.0 * fx + cape_sway + walk_sway, waist_y + 24.0),
		Vector2(cape_x - 4.5 * fx + cape_sway * 0.7 + walk_sway * 0.5, foot_y - 9.0),
		Vector2(cape_x + 3.0 * fx + cape_sway * 0.3, foot_y - 6.0),
		Vector2(cape_x + 4.5 * fx, waist_y + 15.0),
		Vector2(cape_x + 3.0 * fx, shoulder_y + 6.0),
	])
	draw_colored_polygon(cape_poly, _cape_color)

	# Cape lining edge
	var lining_alpha: float = 0.3 + 0.1 * sin(_time * 2.0)
	var lining_color = Color(_cape_lining.r, _cape_lining.g, _cape_lining.b, lining_alpha)
	draw_line(
		Vector2(cape_x - 6.0 * fx, shoulder_y + 3.0),
		Vector2(cape_x - 9.0 * fx + cape_sway + walk_sway, waist_y + 24.0),
		lining_color, 2.0
	)
	draw_line(
		Vector2(cape_x - 9.0 * fx + cape_sway + walk_sway, waist_y + 24.0),
		Vector2(cape_x - 4.5 * fx + cape_sway * 0.7, foot_y - 9.0),
		lining_color, 2.0
	)


func _draw_thruster_glow(fx: float, foot_y: float) -> void:
	var thrust_pulse: float = 0.5 + 0.5 * sin(_time * 14.0)
	var thrust_color = Color(0.0, 0.8, 1.0, thrust_pulse * 0.5)
	var thrust_hot = Color(0.5, 0.9, 1.0, thrust_pulse * 0.7)

	# Under left boot
	draw_circle(Vector2(-6.0 * fx, foot_y + 3.0), 6.0 + thrust_pulse * 3.0, thrust_color)
	draw_circle(Vector2(-6.0 * fx, foot_y + 1.5), 3.0 + thrust_pulse * 1.5, thrust_hot)
	# Under right boot
	draw_circle(Vector2(6.0 * fx, foot_y + 3.0), 6.0 + thrust_pulse * 3.0, thrust_color)
	draw_circle(Vector2(6.0 * fx, foot_y + 1.5), 3.0 + thrust_pulse * 1.5, thrust_hot)
	# Flame trail
	var trail_len: float = 9.0 + thrust_pulse * 12.0
	for i in range(3):
		var t: float = float(i) / 3.0
		var trail_y: float = foot_y + 4.5 + trail_len * t
		var trail_r: float = (4.5 - t * 3.75) * (1.0 + thrust_pulse * 0.5)
		var trail_a: float = (1.0 - t) * thrust_pulse * 0.3
		draw_circle(Vector2(-6.0 * fx, trail_y), trail_r, Color(0.0, 0.6, 1.0, trail_a))
		draw_circle(Vector2(6.0 * fx, trail_y), trail_r, Color(0.0, 0.6, 1.0, trail_a))


func _draw_legs(fx: float, foot_y: float, boot_top_y: float, knee_y: float, waist_y: float,
		l_leg_angle: float, r_leg_angle: float) -> void:
	# --- LEFT LEG (wider hip origin for feminine proportions) ---
	var l_hip = Vector2(-7.0 * fx, waist_y)
	var l_knee = Vector2(-6.0 * fx + sin(l_leg_angle) * 9.0 * fx, knee_y)
	var l_ankle = Vector2(-6.0 * fx + sin(l_leg_angle) * 15.0 * fx, boot_top_y)
	var l_foot_tip = Vector2(-6.0 * fx + sin(l_leg_angle) * 18.0 * fx, foot_y)

	# Jump: tuck legs
	if _anim_state == "jump":
		l_knee = Vector2(-7.5 * fx, knee_y - 9.0)
		l_ankle = Vector2(-9.0 * fx, boot_top_y - 6.0)
		l_foot_tip = Vector2(-7.5 * fx, foot_y - 9.0)

	# Thigh (slightly tapered — wider at hip, narrower at knee)
	draw_line(l_hip, l_knee, _dark_suit, 7.0)
	# Shin
	draw_line(l_knee, l_ankle, _dark_suit, 6.0)
	# Knee joint
	draw_circle(l_knee, 3.5, _suit_mid)
	# Boot
	_draw_boot(l_ankle, l_foot_tip, fx, false)

	# --- RIGHT LEG ---
	var r_hip = Vector2(7.0 * fx, waist_y)
	var r_knee = Vector2(6.0 * fx + sin(r_leg_angle) * 9.0 * fx, knee_y)
	var r_ankle = Vector2(6.0 * fx + sin(r_leg_angle) * 15.0 * fx, boot_top_y)
	var r_foot_tip = Vector2(6.0 * fx + sin(r_leg_angle) * 18.0 * fx, foot_y)

	if _anim_state == "jump":
		r_knee = Vector2(7.5 * fx, knee_y - 6.0)
		r_ankle = Vector2(6.0 * fx, boot_top_y - 3.0)
		r_foot_tip = Vector2(7.5 * fx, foot_y - 6.0)

	draw_line(r_hip, r_knee, _dark_suit, 7.0)
	draw_line(r_knee, r_ankle, _dark_suit, 6.0)
	draw_circle(r_knee, 3.5, _suit_mid)
	_draw_boot(r_ankle, r_foot_tip, fx, true)


func _draw_boot(ankle: Vector2, foot_tip: Vector2, fx: float, _is_right: bool) -> void:
	# Armored boot — simple rect-based shape that works regardless of facing
	var boot_w: float = 10.0
	var boot_h: float = foot_tip.y - ankle.y + 3.0
	var boot_x: float = ankle.x - boot_w * 0.5
	draw_rect(Rect2(boot_x, ankle.y, boot_w, boot_h), _boot_color)
	# Toe extension
	var toe_dir: float = fx
	draw_rect(Rect2(boot_x + (boot_w if toe_dir > 0 else -4.0), foot_tip.y - 3.0, 4.0, 3.0), _boot_color)
	# Boot sole (cyan accent)
	var toe_ext: float = 4.0 * fx
	draw_line(
		Vector2(foot_tip.x - 3.0 * fx, foot_tip.y),
		Vector2(foot_tip.x + toe_ext, foot_tip.y),
		Color(_cyan.r, _cyan.g, _cyan.b, 0.4), 2.0
	)
	# Boot buckle
	draw_line(
		Vector2(ankle.x - 4.5 * fx, ankle.y + 3.0),
		Vector2(ankle.x + 4.5 * fx, ankle.y + 3.0),
		_suit_light, 1.5
	)


func _draw_torso(fx: float, waist_y: float, _belt_y: float, chest_y: float,
		shoulder_y: float, energy_pulse: float) -> void:
	# Hourglass torso — narrower waist, wider hips and chest
	var mid_y: float = shoulder_y + (waist_y - shoulder_y) * 0.45  # waist pinch point
	var torso_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-12.0 * fx, waist_y),          # Left hip (wider)
		Vector2(12.0 * fx, waist_y),           # Right hip (wider)
		Vector2(8.0 * fx, mid_y),              # Right waist (pinched)
		Vector2(13.5 * fx, chest_y),           # Right chest (full)
		Vector2(11.0 * fx, shoulder_y),        # Right shoulder
		Vector2(-11.0 * fx, shoulder_y),       # Left shoulder
		Vector2(-13.5 * fx, chest_y),          # Left chest (full)
		Vector2(-8.0 * fx, mid_y),             # Left waist (pinched)
	])
	draw_colored_polygon(torso_poly, _dark_suit)

	# Jacket center seam
	draw_line(Vector2(0.0, shoulder_y + 4.0), Vector2(0.0, waist_y), _suit_mid, 1.0)

	# Jacket panels — lighter inner panels following the curve
	var panel_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-3.0 * fx, waist_y - 1.5),
		Vector2(3.0 * fx, waist_y - 1.5),
		Vector2(4.0 * fx, chest_y + 1.5),
		Vector2(-4.0 * fx, chest_y + 1.5),
	])
	draw_colored_polygon(panel_poly, _suit_mid)

	# Collar / neckline — V-shape
	var collar_color = Color(_suit_light.r, _suit_light.g, _suit_light.b, 0.8)
	draw_line(Vector2(-8.0 * fx, shoulder_y), Vector2(0.0, shoulder_y + 6.0), collar_color, 2.0)
	draw_line(Vector2(8.0 * fx, shoulder_y), Vector2(0.0, shoulder_y + 6.0), collar_color, 2.0)

	# Vest detail — open front, darker edges
	draw_line(Vector2(-6.0 * fx, shoulder_y + 3.0), Vector2(-5.0 * fx, waist_y - 2.0), _suit_light, 2.0)
	draw_line(Vector2(6.0 * fx, shoulder_y + 3.0), Vector2(5.0 * fx, waist_y - 2.0), _suit_light, 2.0)

	# Shoulder pads — sleek, not bulky
	draw_circle(Vector2(11.0 * fx, shoulder_y), 4.0, _suit_mid)
	draw_circle(Vector2(-11.0 * fx, shoulder_y), 4.0, _suit_mid)

	# Green accent trim on collar
	draw_line(
		Vector2(-8.0 * fx, shoulder_y),
		Vector2(8.0 * fx, shoulder_y),
		Color(_cyan.r, _cyan.g, _cyan.b, energy_pulse * 0.4), 1.0
	)


func _draw_arms(fx: float, shoulder_y: float, waist_y: float,
		l_arm_swing: float, r_arm_swing: float, breathe: float) -> void:
	var arm_width: float = 3.5

	# --- LEFT ARM ---
	var l_shoulder = Vector2(-11.0 * fx, shoulder_y)
	var l_elbow = Vector2(-16.5 * fx + l_arm_swing * fx * 0.3, shoulder_y + 15.0)
	var l_hand = Vector2(-15.0 * fx + l_arm_swing * fx * 0.5, waist_y + 3.0 + breathe)

	if _anim_state == "jump":
		# Arms spread outward
		l_elbow = Vector2(-21.0 * fx, shoulder_y + 6.0)
		l_hand = Vector2(-24.0 * fx, shoulder_y + 12.0)

	# Upper arm
	draw_line(l_shoulder, l_elbow, _dark_suit, arm_width)
	# Forearm
	draw_line(l_elbow, l_hand, _dark_suit, arm_width - 0.75)
	# Elbow joint
	draw_circle(l_elbow, 2.7, _suit_mid)
	# Glove
	draw_circle(l_hand, 3.0, _suit_light)

	# --- RIGHT ARM ---
	var r_shoulder = Vector2(11.0 * fx, shoulder_y)
	var r_elbow = Vector2(16.5 * fx + r_arm_swing * fx * 0.3, shoulder_y + 15.0)
	var r_hand = Vector2(15.0 * fx + r_arm_swing * fx * 0.5, waist_y + 3.0 + breathe)

	if _anim_state == "jump":
		r_elbow = Vector2(21.0 * fx, shoulder_y + 6.0)
		r_hand = Vector2(24.0 * fx, shoulder_y + 12.0)

	draw_line(r_shoulder, r_elbow, _dark_suit, arm_width)
	draw_line(r_elbow, r_hand, _dark_suit, arm_width - 0.75)
	draw_circle(r_elbow, 2.7, _suit_mid)
	# Right glove has a cyan accent (data gauntlet)
	draw_circle(r_hand, 3.3, _suit_light)
	var gauntlet_pulse: float = 0.3 + 0.3 * sin(_time * 4.0)
	draw_circle(r_hand, 2.25, Color(_cyan.r, _cyan.g, _cyan.b, gauntlet_pulse))


func _draw_belt(fx: float, belt_y: float, waist_y: float) -> void:
	# Belt band
	var belt_color = Color(0.18, 0.16, 0.12)
	draw_line(Vector2(-10.5 * fx, belt_y), Vector2(10.5 * fx, belt_y), belt_color, 3.75)

	# Belt buckle (centered, glowing)
	var buckle_pulse: float = 0.4 + 0.2 * sin(_time * 2.5)
	draw_rect(Rect2(Vector2(-3.0, belt_y - 2.25), Vector2(6.0, 4.5)), Color(0.15, 0.15, 0.1))
	draw_rect(Rect2(Vector2(-2.25, belt_y - 1.5), Vector2(4.5, 3.0)), Color(_cyan.r, _cyan.g, _cyan.b, buckle_pulse))

	# Utility pouch on right hip
	var pouch_x: float = 9.0 * fx
	var pouch_poly: PackedVector2Array = PackedVector2Array([
		Vector2(pouch_x, belt_y),
		Vector2(pouch_x + 6.0 * fx, belt_y + 1.5),
		Vector2(pouch_x + 6.0 * fx, waist_y + 6.0),
		Vector2(pouch_x, waist_y + 4.5),
	])
	draw_colored_polygon(pouch_poly, Color(0.14, 0.12, 0.1))
	draw_line(
		Vector2(pouch_x, belt_y + 2.25),
		Vector2(pouch_x + 5.25 * fx, belt_y + 2.25),
		Color(0.25, 0.22, 0.18), 1.2
	)

	# Small pouch on left hip
	var sm_pouch_x: float = -7.5 * fx
	draw_rect(
		Rect2(Vector2(minf(sm_pouch_x, sm_pouch_x + 4.5 * fx), belt_y),
			Vector2(abs(4.5 * fx), 6.0)),
		Color(0.12, 0.11, 0.1)
	)


func _draw_head(fx: float, neck_y: float, head_center_y: float,
		energy_pulse: float, _breathe: float) -> void:
	# Neck
	draw_line(Vector2(0.0, neck_y + 4.5), Vector2(0.0, neck_y), _skin_tone, 4.5)

	# Jacket collar (high, fitted)
	var collar_color = Color(_dark_suit.r + 0.05, _dark_suit.g + 0.05, _dark_suit.b + 0.08, 0.9)
	var collar_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-6.0 * fx, neck_y + 4.5),
		Vector2(6.0 * fx, neck_y + 4.5),
		Vector2(5.0 * fx, neck_y - 1.5),
		Vector2(3.0 * fx, neck_y - 3.0),
		Vector2(-3.0 * fx, neck_y - 3.0),
		Vector2(-5.0 * fx, neck_y - 1.5),
	])
	draw_colored_polygon(collar_poly, collar_color)

	# Head shape
	var head_r: float = 10.0
	draw_circle(Vector2(0.0, head_center_y), head_r, _skin_tone)

	# Hair — copper-auburn, swept back into ponytail
	var hair_base: PackedVector2Array = PackedVector2Array([
		Vector2(-9.0 * fx, head_center_y + 1.5),
		Vector2(-10.5 * fx, head_center_y - 3.0),
		Vector2(-9.75 * fx, head_center_y - 10.5),
		Vector2(-4.5 * fx, head_center_y - 13.5),
		Vector2(3.0 * fx, head_center_y - 14.25),
		Vector2(7.5 * fx, head_center_y - 12.0),
		Vector2(10.5 * fx, head_center_y - 7.5),
		Vector2(10.5 * fx, head_center_y - 1.5),
		Vector2(9.0 * fx, head_center_y + 1.5),
		Vector2(4.5 * fx, head_center_y - 4.5),
		Vector2(0.0, head_center_y - 3.0),
		Vector2(-4.5 * fx, head_center_y - 1.5),
	])
	draw_colored_polygon(hair_base, _hair_color)

	# Ponytail — hanging behind, swaying slightly
	var sway: float = sin(_time * 1.5) * 2.0
	draw_line(Vector2(-8.0 * fx, head_center_y - 2.0), Vector2(-14.0 * fx + sway, head_center_y + 8.0), _hair_color, 4.0)
	draw_line(Vector2(-14.0 * fx + sway, head_center_y + 8.0), Vector2(-12.0 * fx + sway * 0.5, head_center_y + 22.0), _hair_color, 3.0)
	draw_line(Vector2(-12.0 * fx + sway * 0.5, head_center_y + 22.0), Vector2(-10.0 * fx + sway * 0.3, head_center_y + 30.0), _hair_color.darkened(0.1), 2.5)
	# Hair tie
	draw_circle(Vector2(-14.0 * fx + sway, head_center_y + 8.0), 1.5, _hair_color.lightened(0.3))
	# Hair highlight strand
	draw_line(Vector2(-6.0 * fx, head_center_y - 9.0), Vector2(-2.0 * fx, head_center_y - 12.0), _hair_color.lightened(0.2), 1.5)

	# --- EYES — both visible, vivid green ---
	var eye_y: float = head_center_y - 1.5
	var l_eye_x: float = -4.5 * fx
	var r_eye_x: float = 4.5 * fx

	# Eyebrows
	draw_line(Vector2(l_eye_x - 2.5 * fx, eye_y - 3.5), Vector2(l_eye_x + 2.5 * fx, eye_y - 3.0),
		Color(_hair_color.r, _hair_color.g, _hair_color.b, 0.6), 1.2)
	draw_line(Vector2(r_eye_x - 2.5 * fx, eye_y - 3.0), Vector2(r_eye_x + 2.5 * fx, eye_y - 3.5),
		Color(_hair_color.r, _hair_color.g, _hair_color.b, 0.6), 1.2)

	# Eye whites
	draw_circle(Vector2(l_eye_x, eye_y), 2.0, Color(0.95, 0.95, 0.98))
	draw_circle(Vector2(r_eye_x, eye_y), 2.0, Color(0.95, 0.95, 0.98))

	# Irises — vivid green
	var eye_glow: float = 0.8 + 0.2 * energy_pulse
	var iris_color := Color(_cyan.r, _cyan.g, _cyan.b, eye_glow)
	draw_circle(Vector2(l_eye_x + 0.3 * fx, eye_y + 0.2), 1.3, iris_color)
	draw_circle(Vector2(r_eye_x + 0.3 * fx, eye_y + 0.2), 1.3, iris_color)

	# Pupils
	draw_circle(Vector2(l_eye_x + 0.3 * fx, eye_y + 0.3), 0.6, Color(0.05, 0.05, 0.08))
	draw_circle(Vector2(r_eye_x + 0.3 * fx, eye_y + 0.3), 0.6, Color(0.05, 0.05, 0.08))

	# Eye highlights
	draw_circle(Vector2(l_eye_x - 0.3 * fx, eye_y - 0.5), 0.45, Color(1, 1, 1, 0.6))
	draw_circle(Vector2(r_eye_x - 0.3 * fx, eye_y - 0.5), 0.45, Color(1, 1, 1, 0.6))

	# Nose
	draw_line(Vector2(0.0, eye_y + 1.0), Vector2(0.5 * fx, eye_y + 4.0), _skin_tone.darkened(0.12), 1.0)

	# Freckles — scattered across nose and cheeks
	var freckle_color := Color(_skin_tone.r * 0.65, _skin_tone.g * 0.5, _skin_tone.b * 0.35, 0.45)
	for i in range(8):
		var frx: float = sin(float(i) * 3.7) * 5.0
		var fry: float = eye_y + 2.5 + cos(float(i) * 2.1) * 2.5
		draw_circle(Vector2(frx, fry), 0.7, freckle_color)

	# Mouth — slight confident smirk
	draw_line(
		Vector2(-2.5 * fx, head_center_y + 5.0),
		Vector2(1.5 * fx, head_center_y + 5.0),
		_skin_tone.darkened(0.2), 1.0
	)
	draw_line(
		Vector2(1.5 * fx, head_center_y + 5.0),
		Vector2(2.5 * fx, head_center_y + 4.5),
		_skin_tone.darkened(0.2), 1.0
	)


func _draw_energy_lines(fx: float, shoulder_y: float, waist_y: float, boot_top_y: float,
		energy_pulse: float, breathe: float) -> void:
	var alpha: float = 0.2 + 0.25 * energy_pulse
	var line_color = Color(_cyan.r, _cyan.g, _cyan.b, alpha)
	var bright_color = Color(_cyan.r, _cyan.g, _cyan.b, alpha * 1.5)

	# Central chest line
	draw_line(Vector2(0.0, shoulder_y + 6.0 + breathe), Vector2(0.0, waist_y - 1.5), bright_color, 1.8)

	# Left torso energy line
	draw_line(
		Vector2(-7.5 * fx, shoulder_y + 3.0 + breathe),
		Vector2(-6.0 * fx, waist_y),
		line_color, 1.5
	)

	# Right torso energy line
	draw_line(
		Vector2(7.5 * fx, shoulder_y + 3.0 + breathe),
		Vector2(6.0 * fx, waist_y),
		line_color, 1.5
	)

	# Shoulder-to-arm line on right side (armor side)
	draw_line(
		Vector2(12.0 * fx, shoulder_y + breathe),
		Vector2(15.0 * fx, shoulder_y + 9.0 + breathe),
		line_color, 1.2
	)

	# Leg energy lines (down outer thigh)
	draw_line(
		Vector2(-9.0 * fx, waist_y + 1.5),
		Vector2(-7.5 * fx, boot_top_y),
		Color(_cyan.r, _cyan.g, _cyan.b, alpha * 0.6), 1.2
	)
	draw_line(
		Vector2(9.0 * fx, waist_y + 1.5),
		Vector2(7.5 * fx, boot_top_y),
		Color(_cyan.r, _cyan.g, _cyan.b, alpha * 0.6), 1.2
	)

	# Traveling energy dot that moves along the chest line
	var dot_t: float = fmod(_time * 1.5, 1.0)
	var dot_y: float = lerpf(shoulder_y + 6.0 + breathe, waist_y - 1.5, dot_t)
	var dot_alpha: float = sin(dot_t * PI) * 0.8
	draw_circle(Vector2(0.0, dot_y), 1.8, Color(_cyan.r, _cyan.g, _cyan.b, dot_alpha))


func _draw_visor_glow(fx: float, head_center_y: float, energy_pulse: float) -> void:
	# Subtle green eye glow — Nova's eyes catch the light
	var glow_alpha: float = energy_pulse * 0.12
	var eye_y: float = head_center_y - 1.5
	draw_circle(Vector2(-4.5 * fx, eye_y), 6.0, Color(_cyan.r, _cyan.g, _cyan.b, glow_alpha))
	draw_circle(Vector2(4.5 * fx, eye_y), 6.0, Color(_cyan.r, _cyan.g, _cyan.b, glow_alpha))


func _draw_particles() -> void:
	# Landing dust
	for p in _land_particles:
		var alpha: float = p["life"] * p["color"].a
		var c = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
		draw_circle(p["pos"], 3.0 * p["life"] + 0.75, c)

	# Walk dust
	for p in _walk_dust:
		var alpha: float = p["life"] * p["color"].a * 2.0
		var c = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
		draw_circle(p["pos"], 1.8, c)

	# Boot sparks
	for p in _boot_sparks:
		var alpha: float = p["life"] * p["color"].a * 3.0
		var c = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
		draw_circle(p["pos"], 1.2, c)

	# Jump trail
	# (already drawn behind body in main _draw)


func _draw_idle_sparkle(_fx: float, chest_y: float) -> void:
	# Orbiting energy sparkle
	var sparkle_t: float = fmod(_time * 2.0, TAU)
	var sx: float = sin(sparkle_t) * 12.0
	var sy: float = cos(sparkle_t * 0.7) * 6.0 + chest_y
	var sparkle_alpha: float = sin(sparkle_t * 3.0)
	if sparkle_alpha > 0.0:
		sparkle_alpha = sparkle_alpha * 0.5
		draw_circle(Vector2(sx, sy), 1.5, Color(_cyan.r, _cyan.g, _cyan.b, sparkle_alpha))
		# Tiny secondary sparkle trailing behind
		var sx2: float = sin(sparkle_t - 0.5) * 12.0
		var sy2: float = cos((sparkle_t - 0.5) * 0.7) * 6.0 + chest_y
		draw_circle(Vector2(sx2, sy2), 0.9, Color(_cyan.r, _cyan.g, _cyan.b, sparkle_alpha * 0.4))

	# Breathing aura — very subtle ring around torso
	var aura_alpha: float = 0.04 + 0.03 * sin(_time * 2.0)
	draw_circle(Vector2(0.0, chest_y + 12.0), 21.0, Color(_cyan.r, _cyan.g, _cyan.b, aura_alpha))
