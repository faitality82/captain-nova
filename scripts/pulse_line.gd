extends Control

## The void's heartbeat. Visible once ResourceManager.npc_powerups["signal_decoder"] is set.
## A slow steady pulse; after the Tithe Overlord (tier 3) falls the rhythm skips a beat.

const PERIOD_STEADY: float = 2.4
const COLOR_LINE := Color(0.25, 0.95, 0.45, 0.9)
const COLOR_DIM := Color(0.25, 0.95, 0.45, 0.25)

var enabled: bool = true   # follows the minimap toggle

func _process(_delta: float) -> void:
	visible = enabled and ResourceManager.npc_powerups.get("signal_decoder", false)
	if visible:
		queue_redraw()

func _draw() -> void:
	if size.x <= 0.0:
		return
	var w := size.x
	var h := size.y
	var mid := h * 0.55
	var t := Time.get_ticks_msec() / 1000.0
	var skipping: bool = 3 in ResourceManager.boss_tiers_cleared
	var period := PERIOD_STEADY
	var phase := fmod(t, period) / period
	# every third beat drops out once the Overlord is dead
	var beat_index := int(t / period)
	var silent: bool = skipping and beat_index % 3 == 2
	draw_line(Vector2(0, mid), Vector2(w, mid), COLOR_DIM, 1.0)
	var pts := PackedVector2Array()
	for i in range(int(w)):
		var x := float(i)
		var u := x / w
		var y := mid
		if not silent:
			var d := absf(u - phase)
			if d < 0.03:
				y = mid - h * 0.42 * (1.0 - d / 0.03)
			elif d < 0.06:
				y = mid + h * 0.18 * (1.0 - (d - 0.03) / 0.03)
		pts.append(Vector2(x, y))
	draw_polyline(pts, COLOR_LINE, 1.5)
	var label := "SIGNAL" if not silent else "SIGNAL  ..."
	draw_string(ThemeDB.fallback_font, Vector2(2, 10), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, COLOR_DIM)
