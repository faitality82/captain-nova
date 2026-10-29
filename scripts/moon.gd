extends Node2D

## A moon: orbits its PARENT node in local space (so it follows Mars around the sun)
## and exposes the same landing signals and `planet_name` as planet.gd.
## Deliberately in the "moon" group, NOT "planet", so nearest-planet attribution
## (kill quests, reputation penalties, HUD rows, minimap) stays on Mars.
## world.gd's _find_planet scans the moon group too. No market, no city.

signal player_entered_landing_zone(planet: Node)
signal player_exited_landing_zone

@export var planet_name: String = "Phobos"
@export var orbit_radius: float = 180.0
@export var orbit_period: float = 90.0   # seconds per revolution around the parent
@export var landing_radius: float = 60.0

var _orbit_angle: float = 0.0
var _anim_frames: Array = []
var _anim_timer: float = 0.0
var _anim_frame: int = 0
var _sprite: Sprite2D
const ANIM_FPS: float = 12.0

func _ready() -> void:
	add_to_group("moon")
	# Restore saved angle or randomize on first visit
	if planet_name in ResourceManager.planet_orbit_angles:
		_orbit_angle = ResourceManager.planet_orbit_angles[planet_name]
	else:
		_orbit_angle = randf() * TAU
		ResourceManager.planet_orbit_angles[planet_name] = _orbit_angle
	position = Vector2(cos(_orbit_angle), sin(_orbit_angle)) * orbit_radius

	_sprite = Sprite2D.new()
	_sprite.name = "Sprite2D"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)
	_load_anim_frames()

	var label := Label.new()
	label.name = "NameLabel"
	label.text = planet_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -36)
	label.size = Vector2(100, 20)
	label.add_theme_font_size_override("font_size", 11)
	add_child(label)

	var zone := Area2D.new()
	zone.name = "LandingZone"
	zone.collision_layer = 16
	zone.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = landing_radius
	shape.shape = circle
	zone.add_child(shape)
	add_child(zone)
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)

	queue_redraw()

func _process(delta: float) -> void:
	if orbit_period > 0.0:
		_orbit_angle += (TAU / orbit_period) * delta
		position = Vector2(cos(_orbit_angle), sin(_orbit_angle)) * orbit_radius
		ResourceManager.planet_orbit_angles[planet_name] = _orbit_angle
	if _anim_frames.size() > 1:
		_anim_timer += delta
		if _anim_timer >= 1.0 / ANIM_FPS:
			_anim_timer -= 1.0 / ANIM_FPS
			_anim_frame = (_anim_frame + 1) % _anim_frames.size()
			_sprite.texture = _anim_frames[_anim_frame]

func _load_anim_frames() -> void:
	var i := 0
	while true:
		var path := "res://assets/sprites/%s_frame_%d.png" % [planet_name.to_lower(), i]
		if ResourceLoader.exists(path):
			_anim_frames.append(load(path))
			i += 1
		else:
			break
	if _anim_frames.size() > 0:
		_sprite.texture = _anim_frames[0]

func _draw() -> void:
	# Fallback if no frames exist: a dusty gray disc.
	if _anim_frames.is_empty():
		draw_circle(Vector2.ZERO, 12.0, Color(0.38, 0.35, 0.32))
		draw_circle(Vector2(-4, -3), 3.0, Color(0.22, 0.2, 0.19))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_entered_landing_zone.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_exited_landing_zone.emit()

func get_price_table() -> Dictionary:
	return {}
