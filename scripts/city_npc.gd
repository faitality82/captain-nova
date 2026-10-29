extends Node2D

signal interaction_requested(npc_data: Dictionary)

var npc_data: Dictionary = {}
var _time: float = 0.0
var _player_nearby: bool = false
var _speech_bubble_text: String = ""
var _speech_label: Label
var _name_label: Label

# Wandering behavior
var _spawn_x: float = 0.0
var _wander_range: float = 80.0
var _wander_speed: float = 25.0
var _wander_target: float = 0.0
var _wander_pause: float = 0.0
var _facing_left: bool = false
var _is_walking: bool = false


func setup(data: Dictionary) -> void:
	npc_data = data
	_speech_bubble_text = data.get("greeting", "...")

	# Create proximity detection area
	var area = Area2D.new()
	area.name = "ProximityArea"
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 50.0
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	# Speech label (auto-sized, repositioned each frame by _draw_speech_bubble)
	_speech_label = Label.new()
	_speech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speech_label.add_theme_font_size_override("font_size", 9)
	_speech_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	_speech_label.clip_text = false
	_speech_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_speech_label.visible = false
	_speech_label.text = _speech_bubble_text
	add_child(_speech_label)

	# Name label — auto-sized, repositioned each frame to stay centered
	_name_label = Label.new()
	_name_label.text = data.get("name", "")
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 8)
	_name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	add_child(_name_label)
	# Defer centering until the label knows its text size
	_name_label.resized.connect(_center_name_label)
	_center_name_label.call_deferred()

	# Initialize wandering — each NPC gets a slightly different speed and range
	_wander_speed = randf_range(18.0, 35.0)
	_wander_range = randf_range(50.0, 120.0)
	_wander_pause = randf_range(1.0, 4.0)
	_facing_left = randf() > 0.5


func _center_name_label() -> void:
	if _name_label == null:
		return
	var text_width: float = _name_label.get_minimum_size().x
	_name_label.position = Vector2(-text_width / 2.0, 4.0)
	_name_label.size = Vector2(text_width, 16.0)


func _process(delta: float) -> void:
	_time += delta
	_update_wander(delta)
	queue_redraw()

	if _player_nearby and Input.is_action_just_pressed("interact"):
		interaction_requested.emit(npc_data)


func _update_wander(delta: float) -> void:
	# Remember spawn position on first frame
	if _spawn_x == 0.0:
		_spawn_x = position.x

	# Stop walking when player is nearby (face them instead)
	if _player_nearby:
		_is_walking = false
		return

	# Pause between walks
	if _wander_pause > 0.0:
		_wander_pause -= delta
		_is_walking = false
		if _wander_pause <= 0.0:
			# Pick a new wander target
			_wander_target = _spawn_x + randf_range(-_wander_range, _wander_range)
		return

	# Walk toward target
	var dx: float = _wander_target - position.x
	if abs(dx) < 3.0:
		# Arrived — pause
		_is_walking = false
		_wander_pause = randf_range(2.0, 6.0)
		return

	_is_walking = true
	_facing_left = dx < 0.0
	var move_dir: float = -1.0 if _facing_left else 1.0
	position.x += move_dir * _wander_speed * delta


func _draw() -> void:
	# Flip figure based on facing direction
	if _facing_left:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1, 1))
	_draw_figure()
	if _facing_left:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, 1))
	if _player_nearby:
		_draw_speech_bubble()
		_draw_interact_hint()


func _draw_figure() -> void:
	var visual: Dictionary = npc_data.get("visual", {})
	var body_color: Color = visual.get("body_color", Color(0.4, 0.5, 0.7))
	var hair_color: Color = visual.get("hair_color", Color(0.3, 0.2, 0.1))
	var skin_color: Color = visual.get("skin_color", Color(0.9, 0.75, 0.6))
	var boot_color: Color = visual.get("boot_color", Color(0.25, 0.2, 0.15))
	var height_mult: float = visual.get("height", 1.0)
	var hair_style: String = visual.get("hair", "short")
	var accessory: String = visual.get("accessory", "")
	var npc_role: String = npc_data.get("role", "quest")
	var body_shape: String = visual.get("body_shape", "default")
	var is_curvy: bool = body_shape == "curvy"
	var eye_color: Color = visual.get("eye_color", Color(0.25, 0.2, 0.15))
	var facial_hair: String = visual.get("facial_hair", "none")
	var face_marking: String = visual.get("face_marking", "none")
	var clothing_detail: String = visual.get("clothing_detail", "none")

	var h: float = height_mult

	# --- Idle animation values ---
	var breathe: float = sin(_time * 2.0) * 1.5
	var weight_shift: float = sin(_time * 0.7) * 0.8

	# --- Key Y coordinates (origin at feet, y-up = negative) ---
	# Ground/feet = 0, everything else goes negative (up)
	var foot_y: float = 0.0
	var boot_top_y: float = -8.0 * h
	var knee_y: float = -22.0 * h
	var waist_y: float = -34.0 * h
	var belt_y: float = -36.0 * h
	var shoulder_y: float = -58.0 * h + breathe
	var neck_y: float = -61.0 * h + breathe
	var head_center_y: float = -70.0 * h + breathe
	var head_radius: float = 9.0 * h

	# --- Role-specific pose offsets ---
	var torso_lean_x: float = 0.0  # Lean of the whole upper body
	var l_arm_end: Vector2 = Vector2.ZERO  # Left hand position
	var r_arm_end: Vector2 = Vector2.ZERO  # Right hand position
	var l_arm_elbow: Vector2 = Vector2.ZERO
	var r_arm_elbow: Vector2 = Vector2.ZERO
	var l_leg_offset_x: float = 0.0
	var r_leg_offset_x: float = 0.0
	var head_offset_x: float = 0.0

	# Role-specific idle animations
	var trader_fidget: float = sin(_time * 3.5) * 1.5
	var weapon_tap: float = 0.0
	var weapon_tap_abs: float = abs(sin(_time * 4.0))
	weapon_tap = weapon_tap_abs * 2.0
	var lore_look: float = sin(_time * 0.9) * 2.0
	var quest_bob: float = sin(_time * 2.5) * 3.0

	match npc_role:
		"trader":
			# Relaxed lean, weight on left leg, right arm on hip, satchel on left
			torso_lean_x = 3.0 + weight_shift
			l_leg_offset_x = -1.0
			r_leg_offset_x = 4.0
			l_arm_elbow = Vector2(-14.0 * h + torso_lean_x, shoulder_y + 14.0 * h)
			l_arm_end = Vector2(-12.0 * h + torso_lean_x + trader_fidget, shoulder_y + 22.0 * h)
			r_arm_elbow = Vector2(10.0 * h + torso_lean_x, shoulder_y + 10.0 * h)
			r_arm_end = Vector2(8.0 * h + torso_lean_x, waist_y + 2.0)  # Hand on hip
		"quest":
			# Upright, right arm raised gesturing
			torso_lean_x = weight_shift * 0.5
			l_arm_elbow = Vector2(-13.0 * h + torso_lean_x, shoulder_y + 12.0 * h)
			l_arm_end = Vector2(-11.0 * h + torso_lean_x, shoulder_y + 22.0 * h)
			r_arm_elbow = Vector2(12.0 * h + torso_lean_x, shoulder_y + 4.0 * h)
			r_arm_end = Vector2(16.0 * h + torso_lean_x, shoulder_y - 2.0 * h + quest_bob)  # Raised hand
		"weapon":
			# Wide stance, arms crossed
			torso_lean_x = weight_shift * 0.3
			l_leg_offset_x = -3.0
			r_leg_offset_x = 3.0
			# Arms crossed over chest
			l_arm_elbow = Vector2(-12.0 * h + torso_lean_x, shoulder_y + 8.0 * h)
			l_arm_end = Vector2(5.0 * h + torso_lean_x, shoulder_y + 14.0 * h)
			r_arm_elbow = Vector2(12.0 * h + torso_lean_x, shoulder_y + 8.0 * h)
			r_arm_end = Vector2(-5.0 * h + torso_lean_x, shoulder_y + 12.0 * h)
		"lore", "intel":
			# Slight lean, hand on chin, other arm folded
			torso_lean_x = -2.0 + weight_shift
			head_offset_x = lore_look
			l_arm_elbow = Vector2(-12.0 * h + torso_lean_x, shoulder_y + 10.0 * h)
			l_arm_end = Vector2(-6.0 * h + torso_lean_x, shoulder_y + 18.0 * h)
			r_arm_elbow = Vector2(8.0 * h + torso_lean_x, shoulder_y + 6.0 * h)
			r_arm_end = Vector2(3.0 * h + torso_lean_x + head_offset_x, head_center_y + 6.0 * h)  # Hand on chin
		_:
			# Default neutral
			torso_lean_x = weight_shift * 0.5
			l_arm_elbow = Vector2(-13.0 * h + torso_lean_x, shoulder_y + 12.0 * h)
			l_arm_end = Vector2(-11.0 * h + torso_lean_x, shoulder_y + 22.0 * h)
			r_arm_elbow = Vector2(13.0 * h + torso_lean_x, shoulder_y + 12.0 * h)
			r_arm_end = Vector2(11.0 * h + torso_lean_x, shoulder_y + 22.0 * h)

	# =====================
	# --- BOOTS & FEET ---
	# =====================
	# Left boot
	var l_foot_x: float = -5.0 + l_leg_offset_x
	var r_foot_x: float = 5.0 + r_leg_offset_x

	# Left boot shape (polygon for boot silhouette)
	var l_boot: PackedVector2Array = PackedVector2Array([
		Vector2(l_foot_x - 5.0, foot_y),        # Sole front
		Vector2(l_foot_x + 4.0, foot_y),         # Sole back
		Vector2(l_foot_x + 4.0, boot_top_y),     # Top back
		Vector2(l_foot_x - 3.0, boot_top_y),     # Top front
		Vector2(l_foot_x - 5.0, foot_y - 2.0),   # Toe curve
	])
	draw_colored_polygon(l_boot, boot_color)
	# Boot sole line
	draw_line(Vector2(l_foot_x - 5.0, foot_y), Vector2(l_foot_x + 4.0, foot_y), boot_color.darkened(0.3), 2.0)

	# Right boot shape
	var r_boot: PackedVector2Array = PackedVector2Array([
		Vector2(r_foot_x - 4.0, foot_y),
		Vector2(r_foot_x + 5.0, foot_y),
		Vector2(r_foot_x + 5.0, foot_y - 2.0),
		Vector2(r_foot_x + 3.0, boot_top_y),
		Vector2(r_foot_x - 4.0, boot_top_y),
	])
	draw_colored_polygon(r_boot, boot_color)
	draw_line(Vector2(r_foot_x - 4.0, foot_y), Vector2(r_foot_x + 5.0, foot_y), boot_color.darkened(0.3), 2.0)

	# Weapon dealer foot tap animation
	if npc_role == "weapon":
		var tap_offset: float = -weapon_tap
		draw_line(Vector2(r_foot_x - 2.0, foot_y + tap_offset), Vector2(r_foot_x + 3.0, foot_y + tap_offset), boot_color.lightened(0.1), 1.5)

	# ============
	# --- LEGS ---
	# ============
	var leg_color: Color = body_color.darkened(0.15)
	var leg_width: float = 5.0
	var hip_offset: float = 3.0
	if is_curvy:
		leg_width = 4.5  # slightly slimmer legs
		hip_offset = 5.5  # wider hip origin

	# Left leg (thigh from hip, shin from knee)
	draw_line(Vector2(l_foot_x, boot_top_y), Vector2(l_foot_x + 1.0, knee_y), leg_color, leg_width - 0.5)
	draw_line(Vector2(l_foot_x + 1.0, knee_y), Vector2(-hip_offset + torso_lean_x, waist_y), leg_color, leg_width)

	# Right leg
	draw_line(Vector2(r_foot_x, boot_top_y), Vector2(r_foot_x - 1.0, knee_y), leg_color, leg_width - 0.5)
	draw_line(Vector2(r_foot_x - 1.0, knee_y), Vector2(hip_offset + torso_lean_x, waist_y), leg_color, leg_width)

	# Knee caps (small circles)
	draw_circle(Vector2(l_foot_x + 1.0, knee_y), 2.5, leg_color.lightened(0.05))
	draw_circle(Vector2(r_foot_x - 1.0, knee_y), 2.5, leg_color.lightened(0.05))

	# =============
	# --- TORSO ---
	# =============
	# Jacket/vest polygon shape
	var torso_poly: PackedVector2Array
	if is_curvy:
		var mid_y: float = shoulder_y + (waist_y - shoulder_y) * 0.45
		torso_poly = PackedVector2Array([
			Vector2(-9.0 + torso_lean_x, waist_y),            # Left hip (wider)
			Vector2(9.0 + torso_lean_x, waist_y),             # Right hip (wider)
			Vector2(7.0 + torso_lean_x, mid_y),               # Right waist (pinched)
			Vector2(10.0 + torso_lean_x, shoulder_y + 6.0),   # Right chest (wider)
			Vector2(8.0 + torso_lean_x, shoulder_y),           # Right shoulder
			Vector2(-8.0 + torso_lean_x, shoulder_y),          # Left shoulder
			Vector2(-10.0 + torso_lean_x, shoulder_y + 6.0),  # Left chest (wider)
			Vector2(-7.0 + torso_lean_x, mid_y),              # Left waist (pinched)
		])
	else:
		torso_poly = PackedVector2Array([
			Vector2(-8.0 + torso_lean_x, waist_y),           # Waist left
			Vector2(8.0 + torso_lean_x, waist_y),            # Waist right
			Vector2(10.0 + torso_lean_x, shoulder_y + 4.0),  # Right shoulder area
			Vector2(8.0 + torso_lean_x, shoulder_y),          # Right shoulder
			Vector2(-8.0 + torso_lean_x, shoulder_y),         # Left shoulder
			Vector2(-10.0 + torso_lean_x, shoulder_y + 4.0),  # Left shoulder area
		])
	draw_colored_polygon(torso_poly, body_color)

	# Jacket center line detail
	draw_line(Vector2(0.0 + torso_lean_x, shoulder_y + 2.0), Vector2(0.0 + torso_lean_x, waist_y), body_color.lightened(0.08), 1.0)

	# Collar/neckline detail
	draw_line(Vector2(-4.0 + torso_lean_x, shoulder_y), Vector2(0.0 + torso_lean_x, shoulder_y + 5.0), body_color.lightened(0.12), 1.5)
	draw_line(Vector2(4.0 + torso_lean_x, shoulder_y), Vector2(0.0 + torso_lean_x, shoulder_y + 5.0), body_color.lightened(0.12), 1.5)

	# ============
	# --- BELT ---
	# ============
	var belt_color: Color = Color(0.3, 0.25, 0.2)
	draw_line(Vector2(-9.0 + torso_lean_x, belt_y), Vector2(9.0 + torso_lean_x, belt_y), belt_color, 2.5)
	# Belt buckle
	draw_rect(Rect2(-2.0 + torso_lean_x, belt_y - 2.0, 4.0, 4.0), belt_color.lightened(0.3))

	# Belt pouches (small rectangles)
	draw_rect(Rect2(-8.0 + torso_lean_x, belt_y - 1.5, 4.0, 4.0), belt_color.darkened(0.1))
	draw_rect(Rect2(5.0 + torso_lean_x, belt_y - 1.5, 3.5, 3.5), belt_color.darkened(0.1))

	# Holster for weapon dealer
	if npc_role == "weapon":
		var holster_color: Color = Color(0.35, 0.25, 0.15)
		draw_rect(Rect2(9.0 + torso_lean_x, belt_y - 1.0, 4.0, 10.0), holster_color)
		# Weapon handle sticking out
		draw_line(Vector2(10.0 + torso_lean_x, belt_y - 1.0), Vector2(12.0 + torso_lean_x, belt_y - 5.0), Color(0.5, 0.5, 0.55), 2.5)
		draw_circle(Vector2(12.0 + torso_lean_x, belt_y - 5.0), 1.5, Color(0.5, 0.5, 0.55))

	# Satchel for trader
	if npc_role == "trader":
		var satchel_color: Color = Color(0.45, 0.3, 0.15)
		# Strap across torso
		draw_line(Vector2(7.0 + torso_lean_x, shoulder_y + 2.0), Vector2(-10.0 + torso_lean_x, waist_y + 4.0), satchel_color.darkened(0.1), 2.0)
		# Bag body on left hip
		var bag_poly: PackedVector2Array = PackedVector2Array([
			Vector2(-12.0 + torso_lean_x, waist_y),
			Vector2(-6.0 + torso_lean_x, waist_y),
			Vector2(-5.0 + torso_lean_x, waist_y + 10.0),
			Vector2(-13.0 + torso_lean_x, waist_y + 10.0),
		])
		draw_colored_polygon(bag_poly, satchel_color)
		# Bag flap
		draw_line(Vector2(-12.5 + torso_lean_x, waist_y + 3.0), Vector2(-5.5 + torso_lean_x, waist_y + 3.0), satchel_color.darkened(0.2), 1.5)

	# ============
	# --- NECK ---
	# ============
	var neck_width: float = 4.0 if not is_curvy else 3.0
	draw_line(Vector2(0.0 + torso_lean_x, shoulder_y), Vector2(0.0 + torso_lean_x + head_offset_x, neck_y), skin_color.darkened(0.1), neck_width)

	# ============
	# --- ARMS ---
	# ============
	var arm_width: float = 4.0 if not is_curvy else 3.0
	var arm_color: Color = body_color.lightened(0.05)

	# Left arm: shoulder -> elbow -> hand
	var l_shoulder: Vector2 = Vector2(-9.0 + torso_lean_x, shoulder_y + 2.0)
	draw_line(l_shoulder, l_arm_elbow, arm_color, arm_width)
	draw_line(l_arm_elbow, l_arm_end, arm_color, arm_width)
	# Elbow joint
	draw_circle(l_arm_elbow, 2.5, arm_color.lightened(0.05))
	# Left hand
	draw_circle(l_arm_end, 3.0 * h, skin_color)

	# Right arm: shoulder -> elbow -> hand
	var r_shoulder: Vector2 = Vector2(9.0 + torso_lean_x, shoulder_y + 2.0)
	draw_line(r_shoulder, r_arm_elbow, arm_color, arm_width)
	draw_line(r_arm_elbow, r_arm_end, arm_color, arm_width)
	# Elbow joint
	draw_circle(r_arm_elbow, 2.5, arm_color.lightened(0.05))
	# Right hand
	draw_circle(r_arm_end, 3.0 * h, skin_color)

	# ============
	# --- HEAD ---
	# ============
	var head_cx: float = 0.0 + torso_lean_x + head_offset_x
	var head_cy: float = head_center_y

	# Head circle
	draw_circle(Vector2(head_cx, head_cy), head_radius, skin_color)

	# --- Face details ---
	var eye_y: float = head_cy - 1.0
	var eye_spread: float = 3.5 * h

	# Eyebrows
	draw_line(Vector2(head_cx - eye_spread - 1.5, eye_y - 3.5), Vector2(head_cx - eye_spread + 2.5, eye_y - 3.0), Color(0.2, 0.15, 0.1, 0.8), 1.5)
	draw_line(Vector2(head_cx + eye_spread - 2.5, eye_y - 3.0), Vector2(head_cx + eye_spread + 1.5, eye_y - 3.5), Color(0.2, 0.15, 0.1, 0.8), 1.5)

	# Eyes (whites + iris + pupil)
	draw_circle(Vector2(head_cx - eye_spread, eye_y), 1.8, Color(1.0, 1.0, 1.0, 0.9))
	draw_circle(Vector2(head_cx + eye_spread, eye_y), 1.8, Color(1.0, 1.0, 1.0, 0.9))
	# Iris
	draw_circle(Vector2(head_cx - eye_spread + 0.3, eye_y + 0.2), 1.2, eye_color)
	draw_circle(Vector2(head_cx + eye_spread + 0.3, eye_y + 0.2), 1.2, eye_color)
	# Pupils
	draw_circle(Vector2(head_cx - eye_spread + 0.3, eye_y + 0.3), 0.5, Color(0.05, 0.05, 0.08))
	draw_circle(Vector2(head_cx + eye_spread + 0.3, eye_y + 0.3), 0.5, Color(0.05, 0.05, 0.08))
	# Eye highlights
	draw_circle(Vector2(head_cx - eye_spread - 0.2, eye_y - 0.5), 0.4, Color(1, 1, 1, 0.6))
	draw_circle(Vector2(head_cx + eye_spread - 0.2, eye_y - 0.5), 0.4, Color(1, 1, 1, 0.6))

	# Nose ridge
	draw_line(Vector2(head_cx, eye_y + 1.0), Vector2(head_cx + 0.5, eye_y + 4.5), skin_color.darkened(0.15), 1.0)

	# Mouth line
	var mouth_y: float = eye_y + 6.0
	draw_line(Vector2(head_cx - 2.5, mouth_y), Vector2(head_cx + 2.5, mouth_y), skin_color.darkened(0.25), 1.0)

	# --- Facial Hair ---
	var fh_color: Color = hair_color.darkened(0.1)
	match facial_hair:
		"stubble":
			for i in range(10):
				var sx: float = head_cx + sin(float(i) * 2.3) * 4.0
				var sy: float = mouth_y + 1.0 + float(i) * 0.4
				draw_circle(Vector2(sx, sy), 0.5, Color(fh_color.r, fh_color.g, fh_color.b, 0.35))
		"beard":
			var beard_pts := PackedVector2Array([
				Vector2(head_cx - 5.0, mouth_y - 1.0),
				Vector2(head_cx - 6.0, mouth_y + 3.0),
				Vector2(head_cx - 3.0, mouth_y + 8.0),
				Vector2(head_cx, mouth_y + 9.0),
				Vector2(head_cx + 3.0, mouth_y + 8.0),
				Vector2(head_cx + 6.0, mouth_y + 3.0),
				Vector2(head_cx + 5.0, mouth_y - 1.0),
			])
			draw_colored_polygon(beard_pts, fh_color)
		"mustache":
			draw_line(Vector2(head_cx - 4.0, mouth_y - 1.5), Vector2(head_cx, mouth_y - 0.5), fh_color, 2.5)
			draw_line(Vector2(head_cx, mouth_y - 0.5), Vector2(head_cx + 4.0, mouth_y - 1.5), fh_color, 2.5)
		"goatee":
			draw_line(Vector2(head_cx - 2.0, mouth_y + 1.0), Vector2(head_cx, mouth_y + 6.0), fh_color, 2.0)
			draw_line(Vector2(head_cx + 2.0, mouth_y + 1.0), Vector2(head_cx, mouth_y + 6.0), fh_color, 2.0)
			draw_circle(Vector2(head_cx, mouth_y + 6.0), 1.5, fh_color)

	# --- Face Markings ---
	match face_marking:
		"tattoo":
			draw_line(Vector2(head_cx + 3.0, head_cy - 5.0), Vector2(head_cx + 6.0, head_cy + 2.0), Color(0.2, 0.4, 0.6, 0.5), 1.5)
			draw_line(Vector2(head_cx + 4.5, head_cy - 3.0), Vector2(head_cx + 7.0, head_cy + 3.0), Color(0.2, 0.4, 0.6, 0.4), 1.0)
		"freckles":
			var freckle_color := Color(skin_color.r * 0.7, skin_color.g * 0.55, skin_color.b * 0.4, 0.5)
			for i in range(8):
				var fx: float = head_cx + sin(float(i) * 3.7) * 4.0
				var fy: float = eye_y + 3.0 + cos(float(i) * 2.1) * 2.5
				draw_circle(Vector2(fx, fy), 0.6, freckle_color)
		"wrinkles":
			var wrinkle_color := skin_color.darkened(0.12)
			draw_line(Vector2(head_cx - 4.0, head_cy - 6.0), Vector2(head_cx + 4.0, head_cy - 6.0), wrinkle_color, 0.8)
			draw_line(Vector2(head_cx - 3.0, head_cy - 7.5), Vector2(head_cx + 3.0, head_cy - 7.5), wrinkle_color, 0.8)
			draw_line(Vector2(head_cx - eye_spread - 2.0, eye_y - 1.0), Vector2(head_cx - eye_spread - 4.0, eye_y - 3.0), wrinkle_color, 0.7)
			draw_line(Vector2(head_cx + eye_spread + 2.0, eye_y - 1.0), Vector2(head_cx + eye_spread + 4.0, eye_y - 3.0), wrinkle_color, 0.7)
		"warpaint":
			draw_rect(Rect2(head_cx - 7.0, eye_y - 2.5, 14.0, 5.0), Color(0.1, 0.1, 0.1, 0.45))
		"beauty_mark":
			draw_circle(Vector2(head_cx + 4.0, mouth_y - 2.5), 0.8, skin_color.darkened(0.35))

	# --- Clothing Details ---
	match clothing_detail:
		"scarf":
			var scarf_color := body_color.lightened(0.2)
			draw_rect(Rect2(-6.0 + torso_lean_x, shoulder_y - 2.0, 12.0, 5.0), scarf_color)
			draw_line(Vector2(-4.0 + torso_lean_x, shoulder_y + 3.0), Vector2(-6.0 + torso_lean_x, shoulder_y + 14.0), scarf_color, 3.0)
		"bandolier":
			draw_line(Vector2(-8.0 + torso_lean_x, shoulder_y + 2.0), Vector2(7.0 + torso_lean_x, waist_y - 2.0), body_color.darkened(0.25), 3.0)
			for i in range(4):
				var t: float = 0.2 + float(i) * 0.2
				var bx: float = lerpf(-8.0 + torso_lean_x, 7.0 + torso_lean_x, t)
				var by: float = lerpf(shoulder_y + 2.0, waist_y - 2.0, t)
				draw_circle(Vector2(bx, by), 1.5, Color(0.5, 0.4, 0.2, 0.6))
		"cape":
			var cape_color := body_color.darkened(0.2)
			var cape_pts := PackedVector2Array([
				Vector2(-12.0 + torso_lean_x, shoulder_y),
				Vector2(-14.0 + torso_lean_x, waist_y + 12.0),
				Vector2(-8.0 + torso_lean_x, waist_y + 16.0),
				Vector2(8.0 + torso_lean_x, waist_y + 16.0),
				Vector2(14.0 + torso_lean_x, waist_y + 12.0),
				Vector2(12.0 + torso_lean_x, shoulder_y),
			])
			draw_colored_polygon(cape_pts, cape_color)
		"collar":
			draw_rect(Rect2(-4.0 + torso_lean_x, shoulder_y - 3.0, 8.0, 6.0), body_color.lightened(0.08))
			draw_rect(Rect2(-4.0 + torso_lean_x, shoulder_y - 3.0, 8.0, 6.0), body_color.lightened(0.15), false, 0.8)
		"vest":
			var vest_color := body_color.darkened(0.15)
			draw_line(Vector2(-7.0 + torso_lean_x, shoulder_y + 2.0), Vector2(-6.0 + torso_lean_x, waist_y - 2.0), vest_color, 3.5)
			draw_line(Vector2(7.0 + torso_lean_x, shoulder_y + 2.0), Vector2(6.0 + torso_lean_x, waist_y - 2.0), vest_color, 3.5)

	# --- Hair ---
	match hair_style:
		"short":
			draw_arc(Vector2(head_cx, head_cy), head_radius + 2.0, PI * 0.75, PI * 2.25, 16, hair_color, 4.0)
		"ponytail":
			draw_arc(Vector2(head_cx, head_cy), head_radius + 2.0, PI * 0.75, PI * 2.25, 16, hair_color, 4.0)
			# Ponytail hanging down
			draw_line(Vector2(head_cx, head_cy - head_radius), Vector2(head_cx - 12.0, head_cy + 6.0), hair_color, 3.5)
			draw_line(Vector2(head_cx - 12.0, head_cy + 6.0), Vector2(head_cx - 10.0, head_cy + 18.0), hair_color, 3.0)
			# Hair tie
			draw_circle(Vector2(head_cx - 12.0, head_cy + 6.0), 1.5, hair_color.lightened(0.3))
		"bald":
			# Subtle shine
			draw_arc(Vector2(head_cx, head_cy), head_radius + 1.0, PI * 0.85, PI * 2.15, 12, skin_color.lightened(0.15), 1.5)
		"mohawk":
			for i in range(9):
				var mx: float = head_cx - 4.0 + i
				var my: float = head_cy - head_radius - 1.5
				draw_line(Vector2(mx, my), Vector2(mx, my - 10.0), hair_color, 2.5)
		"hood":
			draw_arc(Vector2(head_cx, head_cy), head_radius + 4.0, PI * 0.55, PI * 2.45, 20, body_color.darkened(0.15), 6.0)
			# Hood shadow on face
			draw_arc(Vector2(head_cx, head_cy), head_radius + 1.0, PI * 0.7, PI * 1.3, 8, Color(0, 0, 0, 0.15), 2.0)
		"long":
			draw_arc(Vector2(head_cx, head_cy), head_radius + 2.0, PI * 0.65, PI * 2.35, 16, hair_color, 4.0)
			# Hair flowing down both sides
			draw_line(Vector2(head_cx - head_radius - 2.0, head_cy), Vector2(head_cx - head_radius - 1.0, head_cy + 20.0), hair_color, 3.5)
			draw_line(Vector2(head_cx + head_radius + 2.0, head_cy), Vector2(head_cx + head_radius + 1.0, head_cy + 20.0), hair_color, 3.5)
			# Inner strands
			draw_line(Vector2(head_cx - head_radius, head_cy + 2.0), Vector2(head_cx - head_radius + 1.0, head_cy + 16.0), hair_color.darkened(0.1), 2.0)
			draw_line(Vector2(head_cx + head_radius, head_cy + 2.0), Vector2(head_cx + head_radius - 1.0, head_cy + 16.0), hair_color.darkened(0.1), 2.0)
		"braids":
			draw_arc(Vector2(head_cx, head_cy), head_radius + 2.0, PI * 0.75, PI * 2.25, 16, hair_color, 4.0)
			for side in [-1.0, 1.0]:
				var braid_x: float = head_cx + side * (head_radius + 3.0)
				for i in range(6):
					var by: float = head_cy + float(i) * 4.0
					var bx: float = braid_x + sin(float(i) * 1.8) * 1.5
					draw_circle(Vector2(bx, by), 2.0, hair_color)
				draw_circle(Vector2(braid_x, head_cy + 24.0), 2.5, hair_color.lightened(0.15))
		"afro":
			draw_circle(Vector2(head_cx, head_cy - 3.0), head_radius + 6.0, hair_color)
			for i in range(10):
				var angle: float = float(i) * TAU / 10.0
				var dist: float = head_radius + 3.5
				var dot_pos := Vector2(head_cx + cos(angle) * dist, head_cy - 3.0 + sin(angle) * dist)
				draw_circle(dot_pos, 1.2, hair_color.darkened(0.1))
		"undercut":
			draw_arc(Vector2(head_cx, head_cy), head_radius + 1.0, PI * 0.3, PI * 0.8, 8, skin_color.darkened(0.15), 2.0)
			draw_arc(Vector2(head_cx, head_cy), head_radius + 1.0, PI * 1.2, PI * 1.7, 8, skin_color.darkened(0.15), 2.0)
			var sweep_pts := PackedVector2Array([
				Vector2(head_cx - 4.0, head_cy - head_radius),
				Vector2(head_cx, head_cy - head_radius - 5.0),
				Vector2(head_cx + 8.0, head_cy - head_radius - 2.0),
				Vector2(head_cx + 10.0, head_cy - head_radius + 3.0),
				Vector2(head_cx + 5.0, head_cy - head_radius + 2.0),
			])
			draw_colored_polygon(sweep_pts, hair_color)
		"spiky":
			for i in range(9):
				var angle: float = PI * 0.85 + float(i) * PI * 0.3 / 8.0
				var base_pos := Vector2(head_cx + cos(angle) * head_radius, head_cy + sin(angle) * head_radius)
				var tip_pos := Vector2(head_cx + cos(angle) * (head_radius + 8.0), head_cy + sin(angle) * (head_radius + 8.0))
				draw_line(base_pos, tip_pos, hair_color, 3.0)

	# --- Accessories ---
	match accessory:
		"goggles":
			# Goggle lenses
			draw_rect(Rect2(head_cx - eye_spread - 3.0, eye_y - 4.0, 6.0, 6.0), Color(0.2, 0.6, 0.8, 0.8))
			draw_rect(Rect2(head_cx + eye_spread - 3.0, eye_y - 4.0, 6.0, 6.0), Color(0.2, 0.6, 0.8, 0.8))
			# Lens frames
			draw_rect(Rect2(head_cx - eye_spread - 3.0, eye_y - 4.0, 6.0, 6.0), Color(0.4, 0.4, 0.4), false, 1.0)
			draw_rect(Rect2(head_cx + eye_spread - 3.0, eye_y - 4.0, 6.0, 6.0), Color(0.4, 0.4, 0.4), false, 1.0)
			# Strap
			draw_line(Vector2(head_cx - eye_spread - 3.0, eye_y - 1.0), Vector2(head_cx - head_radius, eye_y - 1.0), Color(0.35, 0.35, 0.35), 2.0)
			draw_line(Vector2(head_cx + eye_spread + 3.0, eye_y - 1.0), Vector2(head_cx + head_radius, eye_y - 1.0), Color(0.35, 0.35, 0.35), 2.0)
		"visor":
			draw_rect(Rect2(head_cx - 7.0, eye_y - 3.0, 14.0, 6.0), Color(0.1, 0.8, 0.9, 0.6))
			draw_rect(Rect2(head_cx - 7.0, eye_y - 3.0, 14.0, 6.0), Color(0.2, 0.9, 1.0, 0.3), false, 1.0)
		"mask":
			# Lower-face mask
			var mask_poly: PackedVector2Array = PackedVector2Array([
				Vector2(head_cx - 6.0, eye_y + 2.0),
				Vector2(head_cx + 6.0, eye_y + 2.0),
				Vector2(head_cx + 5.0, head_cy + head_radius - 1.0),
				Vector2(head_cx - 5.0, head_cy + head_radius - 1.0),
			])
			draw_colored_polygon(mask_poly, Color(0.3, 0.3, 0.35, 0.85))
			# Mask lines
			draw_line(Vector2(head_cx - 5.0, eye_y + 5.0), Vector2(head_cx + 5.0, eye_y + 5.0), Color(0.4, 0.4, 0.45, 0.5), 0.8)
			draw_line(Vector2(head_cx - 4.0, eye_y + 8.0), Vector2(head_cx + 4.0, eye_y + 8.0), Color(0.4, 0.4, 0.45, 0.5), 0.8)
		"scar":
			draw_line(Vector2(head_cx - 5.0, head_cy - 5.0), Vector2(head_cx + 4.0, head_cy + 5.0), Color(0.7, 0.3, 0.3, 0.7), 2.0)
		"eyepatch":
			draw_rect(Rect2(head_cx - eye_spread - 3.0, eye_y - 3.0, 6.0, 6.0), Color(0.1, 0.1, 0.1, 0.9))
			draw_line(Vector2(head_cx - eye_spread, eye_y - 3.0), Vector2(head_cx + head_radius, head_cy - head_radius), Color(0.15, 0.15, 0.15), 1.5)
			draw_line(Vector2(head_cx - eye_spread, eye_y + 3.0), Vector2(head_cx - head_radius, head_cy + 3.0), Color(0.15, 0.15, 0.15), 1.5)
		"earring":
			draw_arc(Vector2(head_cx - head_radius - 1.0, eye_y + 3.0), 2.5, PI * 0.3, PI * 1.7, 8, Color(0.8, 0.7, 0.2, 0.9), 1.5)
			draw_circle(Vector2(head_cx - head_radius - 1.0, eye_y + 5.5), 1.0, Color(0.9, 0.8, 0.3))
		"bandana":
			var bandana_color := Color(0.7, 0.15, 0.15, 0.9)
			draw_rect(Rect2(head_cx - head_radius - 1.0, head_cy - head_radius + 1.0, head_radius * 2 + 2.0, 4.0), bandana_color)
			draw_line(Vector2(head_cx + head_radius + 1.0, head_cy - head_radius + 3.0), Vector2(head_cx + head_radius + 6.0, head_cy), bandana_color, 2.5)
			draw_line(Vector2(head_cx + head_radius + 6.0, head_cy), Vector2(head_cx + head_radius + 5.0, head_cy + 6.0), bandana_color, 1.5)
		"cybernetic_eye":
			draw_circle(Vector2(head_cx - eye_spread, eye_y), 2.5, Color(0.2, 0.2, 0.25))
			var cyber_pulse := 0.6 + sin(_time * 4.0) * 0.4
			draw_circle(Vector2(head_cx - eye_spread, eye_y), 1.5, Color(1.0, 0.2, 0.2, cyber_pulse))
			draw_circle(Vector2(head_cx - eye_spread, eye_y), 0.6, Color(1.0, 0.5, 0.5, cyber_pulse))
			draw_line(Vector2(head_cx - eye_spread - 2.5, eye_y), Vector2(head_cx - head_radius, eye_y - 2.0), Color(1.0, 0.2, 0.2, 0.4), 0.8)
			draw_line(Vector2(head_cx - eye_spread, eye_y + 2.5), Vector2(head_cx - eye_spread - 2.0, eye_y + 5.0), Color(1.0, 0.2, 0.2, 0.4), 0.8)


func _draw_speech_bubble() -> void:
	var visual: Dictionary = npc_data.get("visual", {})
	var height_mult: float = visual.get("height", 1.0)
	var head_top_y: float = -70.0 * height_mult - 9.0 * height_mult  # head_center - head_radius

	# Measure label's actual text size, with padding
	var text_size: Vector2 = Vector2(80.0, 16.0)
	if _speech_label:
		var min_size: Vector2 = _speech_label.get_minimum_size()
		if min_size.x > 0:
			text_size = min_size
	var bubble_w: float = text_size.x + 12.0  # 6px padding each side
	var bubble_h: float = text_size.y + 6.0
	var bubble_x: float = -bubble_w / 2.0
	var bubble_y: float = head_top_y - bubble_h - 8.0

	# Background
	draw_rect(Rect2(bubble_x, bubble_y, bubble_w, bubble_h), Color(0.1, 0.1, 0.15, 0.85))
	# Border
	draw_rect(Rect2(bubble_x, bubble_y, bubble_w, bubble_h), Color(0.5, 0.5, 0.6, 0.5), false, 1.0)
	# Triangle pointer
	var tri_points = PackedVector2Array([
		Vector2(-3, bubble_y + bubble_h),
		Vector2(3, bubble_y + bubble_h),
		Vector2(0, bubble_y + bubble_h + 5)
	])
	draw_colored_polygon(tri_points, Color(0.1, 0.1, 0.15, 0.85))

	# Update label position to center in bubble
	if _speech_label:
		_speech_label.position = Vector2(bubble_x + 6.0, bubble_y + 3.0)
		_speech_label.size = Vector2(text_size.x, text_size.y)


func _draw_interact_hint() -> void:
	var visual: Dictionary = npc_data.get("visual", {})
	var height_mult: float = visual.get("height", 1.0)
	var head_top_y: float = -70.0 * height_mult - 9.0 * height_mult
	var hint_y: float = head_top_y - 42.0

	var pulse: float = 0.6 + 0.4 * sin(_time * 3.0)
	var hint_color: Color = Color(1, 1, 0.7, pulse)

	# Draw key background
	draw_rect(Rect2(-8, hint_y - 6, 16, 14), Color(0.2, 0.2, 0.25, pulse * 0.7))
	draw_rect(Rect2(-8, hint_y - 6, 16, 14), hint_color, false, 1.0)

	# Draw "E" as simple lines
	var ex: float = -4.0
	var ey: float = hint_y - 3.0
	draw_line(Vector2(ex, ey), Vector2(ex, ey + 8), hint_color, 1.5)
	draw_line(Vector2(ex, ey), Vector2(ex + 6, ey), hint_color, 1.5)
	draw_line(Vector2(ex, ey + 4), Vector2(ex + 5, ey + 4), hint_color, 1.5)
	draw_line(Vector2(ex, ey + 8), Vector2(ex + 6, ey + 8), hint_color, 1.5)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("nova"):
		_player_nearby = true
		if _speech_label:
			_speech_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("nova"):
		_player_nearby = false
		if _speech_label:
			_speech_label.visible = false
