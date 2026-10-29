extends Control

var npc_visual: Dictionary = {}
var npc_role: String = ""
var _time: float = 0.0


func setup(visual: Dictionary, role: String = "") -> void:
	npc_visual = visual
	npc_role = role
	custom_minimum_size = Vector2(100, 130)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	# Dark background with border
	draw_rect(Rect2(0, 0, 100, 130), Color(0.08, 0.08, 0.12, 0.9))
	draw_rect(Rect2(0, 0, 100, 130), Color(0.3, 0.3, 0.4, 0.5), false, 1.0)

	_draw_portrait()


func _draw_portrait() -> void:
	var body_color: Color = npc_visual.get("body_color", Color(0.4, 0.5, 0.7))
	var hair_color: Color = npc_visual.get("hair_color", Color(0.3, 0.2, 0.1))
	var skin_color: Color = npc_visual.get("skin_color", Color(0.9, 0.75, 0.6))
	var boot_color: Color = npc_visual.get("boot_color", Color(0.25, 0.2, 0.15))
	var height_mult: float = npc_visual.get("height", 1.0)
	var hair_style: String = npc_visual.get("hair", "short")
	var accessory: String = npc_visual.get("accessory", "")
	var body_shape: String = npc_visual.get("body_shape", "default")
	var is_curvy: bool = body_shape == "curvy"
	var eye_color: Color = npc_visual.get("eye_color", Color(0.25, 0.2, 0.15))
	var facial_hair: String = npc_visual.get("facial_hair", "none")
	var face_marking: String = npc_visual.get("face_marking", "none")
	var clothing_detail: String = npc_visual.get("clothing_detail", "none")

	var s: float = 3.0  # Scale factor
	var h: float = height_mult

	# Center horizontally, feet near bottom
	var cx: float = 50.0
	var foot_base_y: float = 118.0

	# Breathing animation
	var breathe: float = sin(_time * 2.0) * 0.5

	# --- Legs (role-based stance) ---
	var waist_y: float = foot_base_y - 12.0 * s * h
	var foot_y: float = foot_base_y
	var leg_spread: float = 3.0
	if npc_role == "weapon":
		leg_spread = 5.0  # Wide stance
	var hip_width: float = leg_spread
	if is_curvy:
		hip_width = leg_spread + 2.0  # Wider hips

	# Left leg
	draw_line(Vector2(cx - hip_width * s, waist_y), Vector2(cx - (leg_spread + 1) * s, foot_y), body_color.darkened(0.2), 2.0 * s)
	# Right leg
	draw_line(Vector2(cx + hip_width * s, waist_y), Vector2(cx + (leg_spread + 1) * s, foot_y), body_color.darkened(0.2), 2.0 * s)

	# --- Boots with soles ---
	var bw: float = 4.0 * s
	var bh: float = 3.0 * s
	var boot_l_x: float = cx - (leg_spread + 3) * s
	var boot_r_x: float = cx + (leg_spread - 1) * s
	draw_rect(Rect2(boot_l_x, foot_y - bh, bw, bh), boot_color)
	draw_rect(Rect2(boot_r_x, foot_y - bh, bw, bh), boot_color)
	# Sole line
	draw_line(Vector2(boot_l_x, foot_y - 0.5), Vector2(boot_l_x + bw, foot_y - 0.5), boot_color.darkened(0.3), 1.5)
	draw_line(Vector2(boot_r_x, foot_y - 0.5), Vector2(boot_r_x + bw, foot_y - 0.5), boot_color.darkened(0.3), 1.5)
	# Boot top trim
	draw_line(Vector2(boot_l_x, foot_y - bh), Vector2(boot_l_x + bw, foot_y - bh), boot_color.lightened(0.1), 1.0)
	draw_line(Vector2(boot_r_x, foot_y - bh), Vector2(boot_r_x + bw, foot_y - bh), boot_color.lightened(0.1), 1.0)

	# --- Torso (polygon jacket/vest silhouette) ---
	var shoulder_y: float = waist_y - 14.0 * s * h + breathe
	var torso_pts: PackedVector2Array
	if is_curvy:
		# Hourglass: wider shoulders and hips, pinched waist, chest curve
		var mid_y: float = shoulder_y + (waist_y - shoulder_y) * 0.45
		torso_pts = PackedVector2Array([
			Vector2(cx - 6.5 * s, shoulder_y),         # left shoulder
			Vector2(cx - 7.5 * s, shoulder_y + 4 * s), # left chest (wider)
			Vector2(cx - 5 * s, mid_y),                # left waist (pinched)
			Vector2(cx - 7 * s, waist_y),              # left hip (flared)
			Vector2(cx + 7 * s, waist_y),              # right hip (flared)
			Vector2(cx + 5 * s, mid_y),                # right waist (pinched)
			Vector2(cx + 7.5 * s, shoulder_y + 4 * s), # right chest (wider)
			Vector2(cx + 6.5 * s, shoulder_y),         # right shoulder
		])
	else:
		torso_pts = PackedVector2Array([
			Vector2(cx - 7 * s, shoulder_y),           # left shoulder
			Vector2(cx - 6 * s, waist_y),              # left waist (narrower)
			Vector2(cx + 6 * s, waist_y),              # right waist
			Vector2(cx + 7 * s, shoulder_y),           # right shoulder
		])
	draw_colored_polygon(torso_pts, body_color)
	# Jacket lapel lines
	draw_line(Vector2(cx - 2 * s, shoulder_y + 2 * s), Vector2(cx - 1 * s, waist_y - 4 * s), body_color.lightened(0.12), 1.0)
	draw_line(Vector2(cx + 2 * s, shoulder_y + 2 * s), Vector2(cx + 1 * s, waist_y - 4 * s), body_color.lightened(0.12), 1.0)
	# Center seam
	draw_line(Vector2(cx, shoulder_y + 3 * s), Vector2(cx, waist_y - 2 * s), body_color.darkened(0.08), 0.5)

	# Belt with buckle and pouches
	var belt_y: float = waist_y - 2.0 * s
	draw_rect(Rect2(cx - 6 * s, belt_y, 12 * s, 2.0 * s), body_color.darkened(0.25))
	# Belt buckle
	draw_rect(Rect2(cx - 1.5 * s, belt_y + 0.2 * s, 3.0 * s, 1.6 * s), Color(0.6, 0.55, 0.3, 0.8))
	draw_rect(Rect2(cx - 1.5 * s, belt_y + 0.2 * s, 3.0 * s, 1.6 * s), Color(0.7, 0.65, 0.4, 0.5), false, 0.5)
	# Belt pouches
	draw_rect(Rect2(cx - 5.5 * s, belt_y - 3 * s, 3 * s, 3 * s), body_color.darkened(0.15))
	draw_rect(Rect2(cx - 5.5 * s, belt_y - 3 * s, 3 * s, 3 * s), body_color.darkened(0.05), false, 0.5)
	draw_rect(Rect2(cx + 2.5 * s, belt_y - 3 * s, 3 * s, 3 * s), body_color.darkened(0.15))
	draw_rect(Rect2(cx + 2.5 * s, belt_y - 3 * s, 3 * s, 3 * s), body_color.darkened(0.05), false, 0.5)

	# Collar / V-neck
	var collar_pts: PackedVector2Array = PackedVector2Array([
		Vector2(cx - 3 * s, shoulder_y),
		Vector2(cx, shoulder_y + 3 * s),
		Vector2(cx + 3 * s, shoulder_y),
	])
	draw_polyline(collar_pts, body_color.lightened(0.15), 1.5)

	# Shoulder pads (smaller on curvy builds)
	if is_curvy:
		draw_rect(Rect2(cx - 7.5 * s, shoulder_y, 1.5 * s, 3 * s), body_color.lightened(0.05))
		draw_rect(Rect2(cx + 6 * s, shoulder_y, 1.5 * s, 3 * s), body_color.lightened(0.05))
	else:
		draw_rect(Rect2(cx - 8 * s, shoulder_y, 2 * s, 4 * s), body_color.lightened(0.05))
		draw_rect(Rect2(cx + 6 * s, shoulder_y, 2 * s, 4 * s), body_color.lightened(0.05))

	# --- Arms and hands (role-based poses) ---
	_draw_arms(cx, shoulder_y, waist_y, belt_y, body_color, skin_color, s, is_curvy)

	# --- Head ---
	var head_y: float = shoulder_y - 7.0 * s * h + breathe
	var head_radius: float = 5.0 * s * h
	draw_circle(Vector2(cx, head_y), head_radius, skin_color)

	# Neck
	draw_rect(Rect2(cx - 1.5 * s, head_y + head_radius - s, 3 * s, shoulder_y - head_y - head_radius + 2 * s), skin_color.darkened(0.05))

	# --- Face detail ---
	var eye_y: float = head_y - 0.5 * s

	# Eyebrows
	var brow_raise: float = 0.0
	if npc_role == "quest":
		brow_raise = -0.5 * s  # Slightly raised for expressiveness
	draw_line(Vector2(cx - 3 * s, eye_y - 2 * s + brow_raise), Vector2(cx - 1 * s, eye_y - 1.8 * s + brow_raise), hair_color.darkened(0.1), 1.0)
	draw_line(Vector2(cx + 1 * s, eye_y - 1.8 * s + brow_raise), Vector2(cx + 3 * s, eye_y - 2 * s + brow_raise), hair_color.darkened(0.1), 1.0)

	# Eyes (whites + iris + pupil)
	draw_circle(Vector2(cx - 2 * s, eye_y), 1.2 * s, Color(0.95, 0.95, 1.0))
	draw_circle(Vector2(cx + 2 * s, eye_y), 1.2 * s, Color(0.95, 0.95, 1.0))
	# Iris (eye_color)
	draw_circle(Vector2(cx - 2 * s, eye_y), 0.8 * s, eye_color)
	draw_circle(Vector2(cx + 2 * s, eye_y), 0.8 * s, eye_color)
	# Pupil (dark center)
	draw_circle(Vector2(cx - 2 * s, eye_y), 0.35 * s, Color(0.05, 0.05, 0.08))
	draw_circle(Vector2(cx + 2 * s, eye_y), 0.35 * s, Color(0.05, 0.05, 0.08))
	# Eye highlight (tiny white dot for life)
	draw_circle(Vector2(cx - 2.3 * s, eye_y - 0.3 * s), 0.2 * s, Color(1, 1, 1, 0.7))
	draw_circle(Vector2(cx + 1.7 * s, eye_y - 0.3 * s), 0.2 * s, Color(1, 1, 1, 0.7))

	# Nose ridge
	draw_line(Vector2(cx, eye_y + 0.5 * s), Vector2(cx - 0.5 * s, head_y + 1.8 * s), skin_color.darkened(0.12), 1.0)
	draw_line(Vector2(cx - 0.5 * s, head_y + 1.8 * s), Vector2(cx + 0.5 * s, head_y + 2.0 * s), skin_color.darkened(0.12), 1.0)

	# Mouth
	var mouth_y: float = head_y + 3.0 * s
	if npc_role == "lore" or npc_role == "intel":
		# Slight smirk
		draw_line(Vector2(cx - 1.5 * s, mouth_y), Vector2(cx + 1.0 * s, mouth_y), skin_color.darkened(0.2), 1.0)
		draw_line(Vector2(cx + 1.0 * s, mouth_y), Vector2(cx + 1.5 * s, mouth_y - 0.5 * s), skin_color.darkened(0.2), 1.0)
	elif npc_role == "weapon":
		# Firm set mouth
		draw_line(Vector2(cx - 2.0 * s, mouth_y), Vector2(cx + 2.0 * s, mouth_y), skin_color.darkened(0.25), 1.2)
	else:
		# Neutral / slight smile
		draw_line(Vector2(cx - 1.5 * s, mouth_y), Vector2(cx + 1.5 * s, mouth_y - 0.3 * s), skin_color.darkened(0.2), 1.0)

	# --- Facial Hair ---
	var fh_color: Color = hair_color.darkened(0.1)
	match facial_hair:
		"stubble":
			for i in range(12):
				var sx: float = cx + randf_range(-3.5, 3.5) * s
				var sy: float = mouth_y + randf_range(0.5, 3.0) * s
				# Use deterministic positioning based on index
				sx = cx + sin(float(i) * 2.3) * 3.0 * s
				sy = mouth_y + 0.5 * s + (float(i) * 0.3) * s
				draw_circle(Vector2(sx, sy), 0.3 * s, Color(fh_color.r, fh_color.g, fh_color.b, 0.4))
		"beard":
			var beard_pts := PackedVector2Array([
				Vector2(cx - 3.5 * s, mouth_y - 0.5 * s),
				Vector2(cx - 4 * s, mouth_y + 2 * s),
				Vector2(cx - 2 * s, mouth_y + 5 * s),
				Vector2(cx, mouth_y + 6 * s),
				Vector2(cx + 2 * s, mouth_y + 5 * s),
				Vector2(cx + 4 * s, mouth_y + 2 * s),
				Vector2(cx + 3.5 * s, mouth_y - 0.5 * s),
			])
			draw_colored_polygon(beard_pts, fh_color)
		"mustache":
			draw_line(Vector2(cx - 2.5 * s, mouth_y - 0.8 * s), Vector2(cx, mouth_y - 0.3 * s), fh_color, 1.5 * s)
			draw_line(Vector2(cx, mouth_y - 0.3 * s), Vector2(cx + 2.5 * s, mouth_y - 0.8 * s), fh_color, 1.5 * s)
		"goatee":
			draw_line(Vector2(cx - 1.5 * s, mouth_y + 0.5 * s), Vector2(cx, mouth_y + 4 * s), fh_color, 1.5 * s)
			draw_line(Vector2(cx + 1.5 * s, mouth_y + 0.5 * s), Vector2(cx, mouth_y + 4 * s), fh_color, 1.5 * s)
			draw_circle(Vector2(cx, mouth_y + 4 * s), 1.0 * s, fh_color)

	# --- Face Markings ---
	match face_marking:
		"tattoo":
			# Tribal lines on right side of face
			draw_line(Vector2(cx + 2 * s, head_y - 3 * s), Vector2(cx + 4 * s, head_y + 1 * s), Color(0.2, 0.4, 0.6, 0.6), 1.0)
			draw_line(Vector2(cx + 3 * s, head_y - 2 * s), Vector2(cx + 4.5 * s, head_y + 2 * s), Color(0.2, 0.4, 0.6, 0.5), 0.8)
			draw_line(Vector2(cx + 2.5 * s, head_y), Vector2(cx + 4 * s, head_y + 3 * s), Color(0.2, 0.4, 0.6, 0.4), 0.8)
		"freckles":
			var freckle_color := Color(skin_color.r * 0.7, skin_color.g * 0.55, skin_color.b * 0.4, 0.5)
			for i in range(8):
				var fx: float = cx + sin(float(i) * 3.7) * 2.5 * s
				var fy: float = eye_y + 2.0 * s + cos(float(i) * 2.1) * 1.5 * s
				draw_circle(Vector2(fx, fy), 0.4 * s, freckle_color)
		"wrinkles":
			var wrinkle_color := skin_color.darkened(0.12)
			# Forehead lines
			draw_line(Vector2(cx - 2.5 * s, head_y - 3 * s), Vector2(cx + 2.5 * s, head_y - 3 * s), wrinkle_color, 0.5)
			draw_line(Vector2(cx - 2 * s, head_y - 4 * s), Vector2(cx + 2 * s, head_y - 4 * s), wrinkle_color, 0.5)
			# Crow's feet
			draw_line(Vector2(cx - 3.5 * s, eye_y - 0.5 * s), Vector2(cx - 4.5 * s, eye_y - 1.5 * s), wrinkle_color, 0.5)
			draw_line(Vector2(cx + 3.5 * s, eye_y - 0.5 * s), Vector2(cx + 4.5 * s, eye_y - 1.5 * s), wrinkle_color, 0.5)
			# Nasolabial folds
			draw_line(Vector2(cx - 1.5 * s, eye_y + 2 * s), Vector2(cx - 2 * s, mouth_y + 1 * s), wrinkle_color, 0.5)
			draw_line(Vector2(cx + 1.5 * s, eye_y + 2 * s), Vector2(cx + 2 * s, mouth_y + 1 * s), wrinkle_color, 0.5)
		"warpaint":
			# Bold stripe across eyes
			draw_rect(Rect2(cx - 5 * s, eye_y - 1.5 * s, 10 * s, 3 * s), Color(0.1, 0.1, 0.1, 0.5))
		"beauty_mark":
			draw_circle(Vector2(cx + 2.5 * s, mouth_y - 1.5 * s), 0.5 * s, skin_color.darkened(0.35))

	# --- Clothing Details ---
	match clothing_detail:
		"scarf":
			var scarf_color := body_color.lightened(0.2)
			draw_rect(Rect2(cx - 4 * s, shoulder_y - 1 * s, 8 * s, 3 * s), scarf_color)
			# Dangling end
			draw_line(Vector2(cx - 3 * s, shoulder_y + 2 * s), Vector2(cx - 4 * s, shoulder_y + 8 * s), scarf_color, 2.0 * s)
		"bandolier":
			# Diagonal ammo belt
			draw_line(Vector2(cx - 6 * s, shoulder_y + 1 * s), Vector2(cx + 5 * s, waist_y - 2 * s), body_color.darkened(0.3), 2.0 * s)
			for i in range(5):
				var t: float = 0.15 + float(i) * 0.15
				var bx: float = lerpf(cx - 6 * s, cx + 5 * s, t)
				var by: float = lerpf(shoulder_y + 1 * s, waist_y - 2 * s, t)
				draw_circle(Vector2(bx, by), 1.0 * s, Color(0.5, 0.4, 0.2, 0.7))
		"cape":
			# Cape behind shoulders
			var cape_color := body_color.darkened(0.2)
			var cape_pts := PackedVector2Array([
				Vector2(cx - 8 * s, shoulder_y),
				Vector2(cx - 10 * s, waist_y + 8 * s),
				Vector2(cx - 6 * s, waist_y + 10 * s),
				Vector2(cx + 6 * s, waist_y + 10 * s),
				Vector2(cx + 10 * s, waist_y + 8 * s),
				Vector2(cx + 8 * s, shoulder_y),
			])
			draw_colored_polygon(cape_pts, cape_color)
		"collar":
			# High collar / turtleneck
			draw_rect(Rect2(cx - 3 * s, shoulder_y - 2 * s, 6 * s, 4 * s), body_color.lightened(0.08))
			draw_rect(Rect2(cx - 3 * s, shoulder_y - 2 * s, 6 * s, 4 * s), body_color.lightened(0.15), false, 0.5)
		"vest":
			# Open vest over suit
			var vest_color := body_color.darkened(0.15)
			draw_line(Vector2(cx - 5 * s, shoulder_y + 1 * s), Vector2(cx - 4 * s, waist_y - 2 * s), vest_color, 2.5 * s)
			draw_line(Vector2(cx + 5 * s, shoulder_y + 1 * s), Vector2(cx + 4 * s, waist_y - 2 * s), vest_color, 2.5 * s)

	# --- Hair ---
	match hair_style:
		"short":
			draw_arc(Vector2(cx, head_y), head_radius + s, PI * 0.8, PI * 2.2, 16, hair_color, 2.0 * s)
		"ponytail":
			draw_arc(Vector2(cx, head_y), head_radius + s, PI * 0.8, PI * 2.2, 16, hair_color, 2.0 * s)
			draw_line(Vector2(cx, head_y - head_radius), Vector2(cx - 6 * s, head_y + 4 * s), hair_color, 2.0 * s)
			draw_line(Vector2(cx - 6 * s, head_y + 4 * s), Vector2(cx - 5 * s, head_y + 12 * s), hair_color, 1.5 * s)
		"bald":
			draw_arc(Vector2(cx, head_y), head_radius + 0.5, PI * 0.9, PI * 2.1, 16, skin_color.darkened(0.1), 1.0)
		"mohawk":
			for i in range(7):
				var mx: float = cx - 3.0 * s + i * s
				var my: float = head_y - head_radius - s
				draw_line(Vector2(mx, my), Vector2(mx, my - 5 * s), hair_color, 1.5 * s)
		"hood":
			draw_arc(Vector2(cx, head_y), head_radius + 2 * s, PI * 0.6, PI * 2.4, 20, body_color.darkened(0.15), 3.0 * s)
		"long":
			draw_arc(Vector2(cx, head_y), head_radius + s, PI * 0.7, PI * 2.3, 16, hair_color, 2.0 * s)
			draw_line(Vector2(cx - head_radius - s, head_y), Vector2(cx - head_radius, head_y + 12 * s), hair_color, 2.0 * s)
			draw_line(Vector2(cx + head_radius + s, head_y), Vector2(cx + head_radius, head_y + 12 * s), hair_color, 2.0 * s)
		"braids":
			draw_arc(Vector2(cx, head_y), head_radius + s, PI * 0.8, PI * 2.2, 16, hair_color, 2.0 * s)
			# Two braids going down
			for side in [-1.0, 1.0]:
				var braid_x: float = cx + side * (head_radius + 1.5 * s)
				for i in range(6):
					var by: float = head_y + float(i) * 2.5 * s
					var bx: float = braid_x + sin(float(i) * 1.8) * 1.0 * s
					draw_circle(Vector2(bx, by), 1.2 * s, hair_color)
				# Braid tie
				draw_circle(Vector2(braid_x, head_y + 15 * s), 1.5 * s, hair_color.lightened(0.15))
		"afro":
			# Big rounded hair
			draw_circle(Vector2(cx, head_y - 2 * s), head_radius + 3.5 * s, hair_color)
			# Add texture dots
			for i in range(12):
				var angle: float = float(i) * TAU / 12.0
				var dist: float = head_radius + 2.0 * s
				var dot_pos := Vector2(cx + cos(angle) * dist, head_y - 2 * s + sin(angle) * dist)
				draw_circle(dot_pos, 0.8 * s, hair_color.darkened(0.1))
		"undercut":
			# Short on sides, longer on top swept to one side
			draw_arc(Vector2(cx, head_y), head_radius + 0.5, PI * 0.3, PI * 0.8, 8, skin_color.darkened(0.15), 1.5)
			draw_arc(Vector2(cx, head_y), head_radius + 0.5, PI * 1.2, PI * 1.7, 8, skin_color.darkened(0.15), 1.5)
			# Top swept right
			var sweep_pts := PackedVector2Array([
				Vector2(cx - 3 * s, head_y - head_radius),
				Vector2(cx, head_y - head_radius - 3 * s),
				Vector2(cx + 5 * s, head_y - head_radius - 1 * s),
				Vector2(cx + 6 * s, head_y - head_radius + 2 * s),
				Vector2(cx + 3 * s, head_y - head_radius + 1 * s),
			])
			draw_colored_polygon(sweep_pts, hair_color)
		"spiky":
			# Spikes radiating from top of head
			for i in range(9):
				var angle: float = PI * 0.85 + float(i) * PI * 0.3 / 8.0
				var base_pos := Vector2(cx + cos(angle) * head_radius, head_y + sin(angle) * head_radius)
				var tip_pos := Vector2(cx + cos(angle) * (head_radius + 5 * s), head_y + sin(angle) * (head_radius + 5 * s))
				draw_line(base_pos, tip_pos, hair_color, 2.0 * s)

	# --- Accessories ---
	match accessory:
		"goggles":
			draw_rect(Rect2(cx - 4 * s, eye_y - 2 * s, 3 * s, 3 * s), Color(0.2, 0.6, 0.8, 0.8))
			draw_rect(Rect2(cx + 1 * s, eye_y - 2 * s, 3 * s, 3 * s), Color(0.2, 0.6, 0.8, 0.8))
			draw_line(Vector2(cx - 4 * s, eye_y - 0.5 * s), Vector2(cx - head_radius, eye_y - 0.5 * s), Color(0.3, 0.3, 0.3), 1.5)
			draw_line(Vector2(cx + 4 * s, eye_y - 0.5 * s), Vector2(cx + head_radius, eye_y - 0.5 * s), Color(0.3, 0.3, 0.3), 1.5)
			draw_line(Vector2(cx - 3.5 * s, eye_y - 1.5 * s), Vector2(cx - 2.5 * s, eye_y - 1.5 * s), Color(1, 1, 1, 0.3), 1.0)
			draw_line(Vector2(cx + 1.5 * s, eye_y - 1.5 * s), Vector2(cx + 2.5 * s, eye_y - 1.5 * s), Color(1, 1, 1, 0.3), 1.0)
		"visor":
			draw_rect(Rect2(cx - 4 * s, eye_y - 1.5 * s, 8 * s, 3 * s), Color(0.1, 0.8, 0.9, 0.6))
			draw_line(Vector2(cx - 3 * s, eye_y - s), Vector2(cx + 3 * s, eye_y - s), Color(1, 1, 1, 0.2), 1.0)
		"mask":
			draw_rect(Rect2(cx - 4 * s, eye_y + 2 * s, 8 * s, 5 * s), Color(0.3, 0.3, 0.35, 0.8))
			for i in range(3):
				var vy: float = eye_y + 3 * s + i * 1.5 * s
				draw_line(Vector2(cx - 2 * s, vy), Vector2(cx + 2 * s, vy), Color(0.2, 0.2, 0.25, 0.6), 0.5)
		"scar":
			draw_line(Vector2(cx - 3 * s, head_y - 3 * s), Vector2(cx + 2 * s, head_y + 2 * s), Color(0.7, 0.3, 0.3, 0.7), 1.5 * s)
		"eyepatch":
			# Patch over left eye
			draw_rect(Rect2(cx - 3.5 * s, eye_y - 2 * s, 3.5 * s, 4 * s), Color(0.1, 0.1, 0.1, 0.9))
			draw_line(Vector2(cx - 2 * s, eye_y - 2 * s), Vector2(cx + head_radius, head_y - head_radius), Color(0.15, 0.15, 0.15), 1.0)
			draw_line(Vector2(cx - 2 * s, eye_y + 2 * s), Vector2(cx - head_radius, head_y + 2 * s), Color(0.15, 0.15, 0.15), 1.0)
		"earring":
			# Small hoop on left ear
			draw_arc(Vector2(cx - head_radius - 0.5 * s, eye_y + 2 * s), 1.5 * s, PI * 0.3, PI * 1.7, 8, Color(0.8, 0.7, 0.2, 0.9), 1.0)
			draw_circle(Vector2(cx - head_radius - 0.5 * s, eye_y + 3.5 * s), 0.6 * s, Color(0.9, 0.8, 0.3))
		"bandana":
			# Wrapped around forehead
			var bandana_color := Color(0.7, 0.15, 0.15, 0.9)
			draw_rect(Rect2(cx - head_radius - 0.5 * s, head_y - head_radius + 1 * s, head_radius * 2 + s, 2.5 * s), bandana_color)
			# Tail hanging on right side
			draw_line(Vector2(cx + head_radius + 0.5 * s, head_y - head_radius + 2 * s), Vector2(cx + head_radius + 4 * s, head_y), bandana_color, 1.5 * s)
			draw_line(Vector2(cx + head_radius + 4 * s, head_y), Vector2(cx + head_radius + 3 * s, head_y + 4 * s), bandana_color, 1.0 * s)
		"cybernetic_eye":
			# Replace left eye with glowing cybernetic
			draw_circle(Vector2(cx - 2 * s, eye_y), 1.5 * s, Color(0.2, 0.2, 0.25))
			var cyber_pulse := 0.6 + sin(_time * 4.0) * 0.4
			draw_circle(Vector2(cx - 2 * s, eye_y), 1.0 * s, Color(1.0, 0.2, 0.2, cyber_pulse))
			draw_circle(Vector2(cx - 2 * s, eye_y), 0.4 * s, Color(1.0, 0.5, 0.5, cyber_pulse))
			# Circuit lines
			draw_line(Vector2(cx - 3.5 * s, eye_y), Vector2(cx - head_radius, eye_y - 1 * s), Color(1.0, 0.2, 0.2, 0.4), 0.5)
			draw_line(Vector2(cx - 2 * s, eye_y + 1.5 * s), Vector2(cx - 3 * s, eye_y + 3 * s), Color(1.0, 0.2, 0.2, 0.4), 0.5)


func _draw_arms(cx: float, shoulder_y: float, _waist_y: float, belt_y: float, body_color: Color, skin_color: Color, s: float, curvy: bool = false) -> void:
	var arm_sway: float = sin(_time * 1.5) * 1.5 * s
	var arm_thickness: float = 2.0 * s if not curvy else 1.5 * s
	var hand_size: float = 2.0 * s if not curvy else 1.6 * s

	match npc_role:
		"trader":
			# Left arm: relaxed at side
			draw_line(
				Vector2(cx - 7 * s, shoulder_y + 2 * s),
				Vector2(cx - 10 * s, shoulder_y + 12 * s + arm_sway * 0.3),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx - 10 * s, shoulder_y + 12 * s + arm_sway * 0.3), hand_size, skin_color)
			# Right arm: hand on hip
			draw_line(
				Vector2(cx + 7 * s, shoulder_y + 2 * s),
				Vector2(cx + 8 * s, shoulder_y + 8 * s),
				body_color.lightened(0.1), arm_thickness
			)
			draw_line(
				Vector2(cx + 8 * s, shoulder_y + 8 * s),
				Vector2(cx + 6 * s, belt_y),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx + 6 * s, belt_y), hand_size, skin_color)
			# Satchel on left hip
			draw_rect(Rect2(cx - 9 * s, belt_y - 2 * s, 4 * s, 5 * s), Color(0.45, 0.3, 0.15, 0.9))
			draw_rect(Rect2(cx - 9 * s, belt_y - 2 * s, 4 * s, 5 * s), Color(0.55, 0.4, 0.2, 0.5), false, 0.5)
			# Satchel strap
			draw_line(Vector2(cx - 7 * s, belt_y - 2 * s), Vector2(cx - 3 * s, shoulder_y + 2 * s), Color(0.45, 0.3, 0.15, 0.6), 1.0)

		"quest":
			# Left arm: at side
			draw_line(
				Vector2(cx - 7 * s, shoulder_y + 2 * s),
				Vector2(cx - 9 * s, shoulder_y + 12 * s),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx - 9 * s, shoulder_y + 12 * s), hand_size, skin_color)
			# Right arm: gesturing outward/up
			var gesture_sway: float = sin(_time * 2.0) * 1.0 * s
			draw_line(
				Vector2(cx + 7 * s, shoulder_y + 2 * s),
				Vector2(cx + 11 * s, shoulder_y + 4 * s),
				body_color.lightened(0.1), arm_thickness
			)
			draw_line(
				Vector2(cx + 11 * s, shoulder_y + 4 * s),
				Vector2(cx + 13 * s, shoulder_y + 2 * s + gesture_sway),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx + 13 * s, shoulder_y + 2 * s + gesture_sway), hand_size, skin_color)
			# Open palm lines
			draw_line(
				Vector2(cx + 12.5 * s, shoulder_y + 1.0 * s + gesture_sway),
				Vector2(cx + 13.5 * s, shoulder_y + 0.5 * s + gesture_sway),
				skin_color.darkened(0.1), 0.8
			)

		"weapon":
			# Arms crossed over chest
			# Left arm crosses to right
			draw_line(
				Vector2(cx - 7 * s, shoulder_y + 2 * s),
				Vector2(cx - 4 * s, shoulder_y + 6 * s),
				body_color.lightened(0.1), arm_thickness
			)
			draw_line(
				Vector2(cx - 4 * s, shoulder_y + 6 * s),
				Vector2(cx + 4 * s, shoulder_y + 7 * s),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx + 4 * s, shoulder_y + 7 * s), hand_size, skin_color)
			# Right arm crosses to left
			draw_line(
				Vector2(cx + 7 * s, shoulder_y + 2 * s),
				Vector2(cx + 4 * s, shoulder_y + 5 * s),
				body_color.lightened(0.15), arm_thickness
			)
			draw_line(
				Vector2(cx + 4 * s, shoulder_y + 5 * s),
				Vector2(cx - 4 * s, shoulder_y + 6 * s),
				body_color.lightened(0.15), arm_thickness
			)
			draw_circle(Vector2(cx - 4 * s, shoulder_y + 6 * s), hand_size, skin_color)
			# Holstered weapon on right hip
			draw_rect(Rect2(cx + 5 * s, belt_y + 1 * s, 2 * s, 6 * s), Color(0.3, 0.3, 0.35, 0.8))
			draw_rect(Rect2(cx + 4.5 * s, belt_y, 3 * s, 2 * s), Color(0.35, 0.3, 0.25, 0.8))

		"lore", "intel":
			# Left arm: at side, relaxed
			draw_line(
				Vector2(cx - 7 * s, shoulder_y + 2 * s),
				Vector2(cx - 9 * s, shoulder_y + 12 * s + arm_sway * 0.2),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx - 9 * s, shoulder_y + 12 * s + arm_sway * 0.2), hand_size, skin_color)
			# Right arm: hand on chin (contemplative)
			draw_line(
				Vector2(cx + 7 * s, shoulder_y + 2 * s),
				Vector2(cx + 6 * s, shoulder_y + 6 * s),
				body_color.lightened(0.1), arm_thickness
			)
			draw_line(
				Vector2(cx + 6 * s, shoulder_y + 6 * s),
				Vector2(cx + 2 * s, shoulder_y - 3 * s),
				body_color.lightened(0.1), arm_thickness
			)
			# Hand near chin area
			draw_circle(Vector2(cx + 2 * s, shoulder_y - 3 * s), hand_size, skin_color)

		_:
			# Default: gentle idle sway
			draw_line(
				Vector2(cx - 7 * s, shoulder_y + 2 * s),
				Vector2(cx - 10 * s, shoulder_y + 12 * s + arm_sway),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx - 10 * s, shoulder_y + 12 * s + arm_sway), hand_size, skin_color)
			draw_line(
				Vector2(cx + 7 * s, shoulder_y + 2 * s),
				Vector2(cx + 10 * s, shoulder_y + 12 * s - arm_sway),
				body_color.lightened(0.1), arm_thickness
			)
			draw_circle(Vector2(cx + 10 * s, shoulder_y + 12 * s - arm_sway), hand_size, skin_color)
