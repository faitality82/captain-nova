extends CanvasLayer

## Full-screen blood splatter effect — shown when dying during a boss fight.
## Creates random red splotches that fade out over ~2.5 seconds.

var _active: bool = false
var _fade_timer: float = 0.0
var _initial_alphas: Array = []  # store each splotch's starting alpha
const FADE_DURATION: float = 2.5
const NUM_SPLOTCHES: int = 12

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100  # On top of everything
	visible = false

func trigger() -> void:
	# Clear old splotches
	for child in get_children():
		child.queue_free()
	_initial_alphas.clear()

	visible = true
	_active = true
	_fade_timer = FADE_DURATION

	var viewport_size = get_viewport().get_visible_rect().size

	# Big dripping overlay tint
	var overlay = ColorRect.new()
	overlay.position = Vector2.ZERO
	overlay.size = viewport_size
	overlay.color = Color(0.6, 0.0, 0.0, 0.35)
	add_child(overlay)
	_initial_alphas.append(0.35)

	# Random blood splotches
	for i in range(NUM_SPLOTCHES):
		var splotch = ColorRect.new()
		var sx = randf_range(20, viewport_size.x - 80)
		var sy = randf_range(20, viewport_size.y - 80)
		var sw = randf_range(30, 120)
		var sh = randf_range(20, 80)
		splotch.position = Vector2(sx, sy)
		splotch.size = Vector2(sw, sh)
		var r = randf_range(0.5, 0.85)
		var g = randf_range(0.0, 0.08)
		var b = randf_range(0.0, 0.05)
		var a = randf_range(0.5, 0.9)
		splotch.color = Color(r, g, b, a)
		add_child(splotch)
		_initial_alphas.append(a)

	# Drip streaks
	for i in range(6):
		var drip = ColorRect.new()
		drip.position = Vector2(randf_range(50, viewport_size.x - 50), randf_range(0, viewport_size.y * 0.3))
		drip.size = Vector2(randf_range(4, 12), randf_range(80, 250))
		var a = randf_range(0.4, 0.7)
		drip.color = Color(0.55, 0.0, 0.0, a)
		add_child(drip)
		_initial_alphas.append(a)

func _process(delta: float) -> void:
	if not _active:
		return
	_fade_timer -= delta
	if _fade_timer <= 0:
		_active = false
		visible = false
		for child in get_children():
			child.queue_free()
		_initial_alphas.clear()
		return

	# Linear fade using stored initial alphas
	var progress = _fade_timer / FADE_DURATION
	var children = get_children()
	for i in range(min(children.size(), _initial_alphas.size())):
		var child = children[i]
		if child is ColorRect:
			var c = child.color
			child.color = Color(c.r, c.g, c.b, _initial_alphas[i] * progress)
