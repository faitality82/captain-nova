extends Area2D

var resource_type: String = "ore"
var amount: int = 1
var _time: float = 0.0

const RESOURCE_COLORS: Dictionary = {
	"ore": Color(1.0, 0.5, 0.0),
	"fuel": Color(0.2, 0.6, 1.0),
	"parts": Color(0.2, 1.0, 0.4),
	"ice": Color(0.7, 0.9, 1.0),
	"crystals": Color(1.0, 0.3, 0.8),
	"plasma": Color(0.6, 0.3, 0.8),
	"antimatter": Color(0.9, 0.1, 0.3),
	"biotech": Color(0.1, 0.9, 0.5),
	"nanites": Color(0.5, 0.5, 0.9),
	"dark_matter": Color(0.2, 0.0, 0.3),
	"artifacts": Color(0.9, 0.7, 0.1),
	"gravitonium": Color(0.4, 0.2, 0.6),
	"void_essence": Color(0.1, 0.1, 0.2),
	"starcore": Color(1.0, 0.9, 0.3),
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var color = RESOURCE_COLORS.get(resource_type, Color.WHITE)

	# Pulsing size
	var pulse = 1.0 + sin(_time * 3.0) * 0.15
	var size = 6.0 * pulse

	# Outer glow
	var glow_alpha = 0.15 + sin(_time * 2.0) * 0.08
	draw_circle(Vector2.ZERO, size + 4.0, Color(color.r, color.g, color.b, glow_alpha))

	# Diamond gem shape
	var top = Vector2(0, -size)
	var right = Vector2(size * 0.7, 0)
	var bottom = Vector2(0, size)
	var left = Vector2(-size * 0.7, 0)
	var points = PackedVector2Array([top, right, bottom, left])
	var colors = PackedColorArray([
		Color(color.r + 0.2, color.g + 0.2, color.b + 0.2, 0.95),
		color,
		Color(color.r * 0.7, color.g * 0.7, color.b * 0.7, 0.95),
		color,
	])
	draw_polygon(points, colors)

	# Inner highlight facet
	var hl_top = Vector2(0, -size * 0.5)
	var hl_right = Vector2(size * 0.3, 0)
	var hl_left = Vector2(-size * 0.3, 0)
	var hl_color = Color(1.0, 1.0, 1.0, 0.25)
	draw_polygon(PackedVector2Array([hl_top, hl_right, hl_left]), PackedColorArray([hl_color, hl_color, hl_color]))

	# Sparkle particles orbiting
	for i in range(3):
		var angle = _time * 2.0 + i * (TAU / 3.0)
		var orbit_r = size + 6.0
		var spark_pos = Vector2(cos(angle), sin(angle)) * orbit_r
		var spark_alpha = 0.4 + sin(_time * 5.0 + i * 2.0) * 0.4
		draw_circle(spark_pos, 1.5, Color(1.0, 1.0, 1.0, maxf(spark_alpha, 0.0)))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if ResourceManager.add_cargo(resource_type, amount):
			AudioManager.play_sfx("sfx_pickup", -4.0)
			queue_free()
		else:
			# Cargo full — show warning via HUD
			var hud_nodes = get_tree().get_nodes_in_group("hud")
			if hud_nodes.size() > 0 and hud_nodes[0].has_method("show_interact_hint"):
				hud_nodes[0].show_interact_hint("CARGO FULL! (%d/%d)" % [ResourceManager.total_cargo(), ResourceManager.cargo_capacity])
