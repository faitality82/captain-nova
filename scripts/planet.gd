extends Node2D

signal player_entered_landing_zone(planet: Node)
signal player_exited_landing_zone

@export var planet_name: String = "Unknown Planet"
@export var price_table: Dictionary = {
	"ore":      [0, 0],
	"fuel":     [0, 0],
	"parts":    [0, 0],
	"ice":      [0, 0],
	"crystals": [0, 0],
	"plasma":   [0, 0],
}

var premium_prices: Dictionary = {}

# Orbit parameters — set by world.gd at runtime
var orbit_center: Vector2 = Vector2.ZERO
var orbit_radius: float = 0.0
var orbit_period: float = 0.0  # seconds for full orbit, 0 = no orbit
var _orbit_angle: float = 0.0

var _player_in_range: bool = false

# Planet rotation animation (optional — loads frames if they exist)
var _anim_frames: Array = []
var _anim_timer: float = 0.0
var _anim_frame: int = 0
const PLANET_ANIM_FPS: float = 12.0

func _ready() -> void:
	$NameLabel.text = planet_name
	$LandingZone.body_entered.connect(_on_body_entered)
	$LandingZone.body_exited.connect(_on_body_exited)
	_load_anim_frames()

func setup_orbit(center: Vector2, period: float) -> void:
	orbit_center = center
	orbit_radius = (global_position - center).length()
	orbit_period = period
	# Restore saved angle or randomize on first visit
	if planet_name in ResourceManager.planet_orbit_angles:
		_orbit_angle = ResourceManager.planet_orbit_angles[planet_name]
	else:
		_orbit_angle = randf() * TAU
		ResourceManager.planet_orbit_angles[planet_name] = _orbit_angle
	global_position = orbit_center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * orbit_radius

func _process(delta: float) -> void:
	if orbit_period > 0 and orbit_radius > 0:
		_orbit_angle += (TAU / orbit_period) * delta
		global_position = orbit_center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * orbit_radius
		ResourceManager.planet_orbit_angles[planet_name] = _orbit_angle
	_animate(delta)

func _load_anim_frames() -> void:
	var name_lower = planet_name.to_lower()
	var i = 0
	while true:
		var path = "res://assets/sprites/%s_frame_%d.png" % [name_lower, i]
		if ResourceLoader.exists(path):
			_anim_frames.append(load(path))
			i += 1
		else:
			break
	if _anim_frames.size() > 1:
		print("Planet %s: loaded %d animation frames" % [planet_name, _anim_frames.size()])

func _animate(delta: float) -> void:
	if _anim_frames.size() < 2:
		return
	_anim_timer += delta
	if _anim_timer >= 1.0 / PLANET_ANIM_FPS:
		_anim_timer -= 1.0 / PLANET_ANIM_FPS
		_anim_frame = (_anim_frame + 1) % _anim_frames.size()
		$Sprite2D.texture = _anim_frames[_anim_frame]

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		player_entered_landing_zone.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		player_exited_landing_zone.emit()

func get_price_table() -> Dictionary:
	return price_table
