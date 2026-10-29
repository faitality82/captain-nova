# fire_death.gd
# Full-screen fire effect — shown when the player flies into the sun.
# Creates rising flames, embers, and a heat overlay that fades out.
extends CanvasLayer

var _active: bool = false
var _fade_timer: float = 0.0
var _flame_data: Array = []  # stores {node, rise_speed, flicker_speed, initial_alpha}
const FADE_DURATION: float = 3.5
const NUM_FLAMES: int = 20
const NUM_EMBERS: int = 15

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	visible = false

func trigger() -> void:
	# Clear old effects
	for child in get_children():
		child.queue_free()
	_flame_data.clear()

	visible = true
	_active = true
	_fade_timer = FADE_DURATION

	var viewport_size = get_viewport().get_visible_rect().size

	# Phase 1: Bright flash overlay (white-hot center fading to orange)
	var flash = ColorRect.new()
	flash.position = Vector2.ZERO
	flash.size = viewport_size
	flash.color = Color(1.0, 0.9, 0.3, 0.7)
	add_child(flash)
	_flame_data.append({"node": flash, "rise_speed": 0.0, "flicker_speed": 0.0, "initial_alpha": 0.7})

	# Phase 2: Deep orange/red overlay
	var overlay = ColorRect.new()
	overlay.position = Vector2.ZERO
	overlay.size = viewport_size
	overlay.color = Color(0.8, 0.2, 0.0, 0.5)
	add_child(overlay)
	_flame_data.append({"node": overlay, "rise_speed": 0.0, "flicker_speed": 0.0, "initial_alpha": 0.5})

	# Phase 3: Rising flame tongues from bottom
	for i in range(NUM_FLAMES):
		var flame = ColorRect.new()
		var fx = randf_range(0, viewport_size.x)
		var fw = randf_range(20, 80)
		var fh = randf_range(60, 200)
		flame.position = Vector2(fx, viewport_size.y - fh * randf_range(0.2, 1.0))
		flame.size = Vector2(fw, fh)
		# Flame color varies: deep red to bright orange to yellow
		var temp = randf()  # 0 = red, 1 = yellow
		var fr = lerp(0.7, 1.0, temp)
		var fg = lerp(0.05, 0.7, temp)
		var fb = lerp(0.0, 0.1, temp)
		var fa = randf_range(0.6, 0.95)
		flame.color = Color(fr, fg, fb, fa)
		add_child(flame)

		var rise = randf_range(40, 120)
		var flicker = randf_range(3.0, 8.0)
		_flame_data.append({"node": flame, "rise_speed": rise, "flicker_speed": flicker, "initial_alpha": fa})

	# Phase 4: Embers / sparks scattered across screen
	for i in range(NUM_EMBERS):
		var ember = ColorRect.new()
		ember.position = Vector2(randf_range(0, viewport_size.x), randf_range(0, viewport_size.y))
		ember.size = Vector2(randf_range(3, 8), randf_range(3, 8))
		var ea = randf_range(0.5, 1.0)
		ember.color = Color(1.0, randf_range(0.5, 0.9), 0.0, ea)
		add_child(ember)

		var rise = randf_range(60, 150)
		var flicker = randf_range(5.0, 12.0)
		_flame_data.append({"node": ember, "rise_speed": rise, "flicker_speed": flicker, "initial_alpha": ea})

func _process(delta: float) -> void:
	if not _active:
		return

	_fade_timer -= delta
	if _fade_timer <= 0:
		_active = false
		visible = false
		for child in get_children():
			child.queue_free()
		_flame_data.clear()
		return

	var progress = _fade_timer / FADE_DURATION
	var time = FADE_DURATION - _fade_timer

	for data in _flame_data:
		var node = data["node"]
		if not is_instance_valid(node):
			continue

		# Rise upward
		if data["rise_speed"] > 0:
			node.position.y -= data["rise_speed"] * delta

		# Flicker alpha
		var flicker = 1.0
		if data["flicker_speed"] > 0:
			flicker = 0.7 + 0.3 * sin(time * data["flicker_speed"])

		var c = node.color
		node.color = Color(c.r, c.g, c.b, data["initial_alpha"] * progress * flicker)
