extends Node2D

## Phobos Meat Works loading dock. A bounded arena, camera at 2x (pixel-perfect preview of the
## future 640x360 logical resolution), Frank in the middle, four grinders that wake up in phase 3.
## Standalone-runnable. Returns to World.tscn near Mars on win or death.

const ARENA := Rect2(-640, -360, 1280, 720)
const SHIP_SCENE := preload("res://scenes/world/Ship.tscn")
const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const FRANK_SCENE := preload("res://scenes/world/BigFrank.tscn")
# arena_far / arena_mid from OE-0076 are opaque full-frame plates; layering them under an opaque floor is wasted draws. They return as Parallax2D layers in R6 once the art is authored with transparency.
const PLATES := {
	"floor": "res://assets/sprites/frank/arena_floor.png",
}
const GRINDER_POS := [Vector2(-420, -220), Vector2(420, -220), Vector2(-420, 220), Vector2(420, 220)]

var ship: Node2D
var hud: Node
var frank: Node2D
var blood_splatter: CanvasLayer
var _grinders: Array = []
var _grinders_on: bool = false
var _grinder_tick: float = 0.0
var _ending: bool = false
var _frank_reward: int = 0

func _ready() -> void:
	_build_backdrop()
	_build_walls()
	_build_grinders()

	ship = SHIP_SCENE.instantiate()
	ship.global_position = Vector2(-380, 0)
	add_child(ship)
	var cam: Camera2D = ship.get_node("Camera2D")
	cam.zoom = Vector2(2.0, 2.0)
	cam.limit_left = int(ARENA.position.x)
	cam.limit_top = int(ARENA.position.y)
	cam.limit_right = int(ARENA.end.x)
	cam.limit_bottom = int(ARENA.end.y)
	cam.position_smoothing_enabled = true
	cam.make_current()
	ship.hp = ResourceManager.ship_hp if ResourceManager.ship_hp > 0 else ResourceManager.ship_max_hp
	ship.died.connect(_on_ship_died)
	ship.fuel_empty.connect(func():
		ResourceManager.ship_fuel = ResourceManager.ship_max_fuel
		hud.show_interact_hint("DOCK FUEL LINE ENGAGED"))

	hud = HUD_SCENE.instantiate()
	add_child(hud)
	ship.hp_changed.connect(hud.update_hp)
	hud.update_hp(ship.hp, ResourceManager.ship_max_hp)

	blood_splatter = CanvasLayer.new()
	blood_splatter.set_script(load("res://scripts/blood_splatter.gd"))
	add_child(blood_splatter)

	AudioManager.switch_to_boss_music()
	AudioManager.play_sfx("sfx_boss_warning", 0.0)
	hud.show_interact_hint("PHOBOS MEAT WORKS — LOADING DOCK")
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return
	hud.hide_interact_hint()
	_spawn_frank()

func _build_backdrop() -> void:
	var z := -10
	for key in PLATES.keys():
		var path: String = PLATES[key]
		if ResourceLoader.exists(path):
			var s := Sprite2D.new()
			s.texture = load(path)
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.centered = true
			s.region_enabled = true
			s.region_rect = Rect2(0, 0, 640, 360)
			s.scale = Vector2(2.0, 2.0)   # exact 2x: pixel-perfect under NEAREST
			s.z_index = z
			add_child(s)
		z += 5
	if not ResourceLoader.exists(PLATES["floor"]):
		# Fallback: steel floor with conveyor stripes, in the direction-B palette.
		var floor_rect := ColorRect.new()
		floor_rect.position = ARENA.position
		floor_rect.size = ARENA.size
		floor_rect.color = Color(0.09, 0.09, 0.12)
		floor_rect.z_index = -20
		add_child(floor_rect)
		for i in range(6):
			var belt := ColorRect.new()
			belt.position = Vector2(ARENA.position.x, ARENA.position.y + 60 + i * 110)
			belt.size = Vector2(ARENA.size.x, 26)
			belt.color = Color(0.16, 0.16, 0.2)
			belt.z_index = -19
			add_child(belt)
		for i in range(9):
			var splat := ColorRect.new()
			splat.position = Vector2(randf_range(ARENA.position.x, ARENA.end.x - 60), randf_range(ARENA.position.y, ARENA.end.y - 40))
			splat.size = Vector2(randf_range(20, 60), randf_range(12, 40))
			splat.color = Color(0.6, 0.05, 0.05, 0.7)
			splat.z_index = -18
			add_child(splat)

func _build_walls() -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	var t := 40.0
	var rects := [
		Rect2(ARENA.position.x - t, ARENA.position.y - t, ARENA.size.x + 2 * t, t),   # top
		Rect2(ARENA.position.x - t, ARENA.end.y, ARENA.size.x + 2 * t, t),            # bottom
		Rect2(ARENA.position.x - t, ARENA.position.y, t, ARENA.size.y),               # left
		Rect2(ARENA.end.x, ARENA.position.y, t, ARENA.size.y),                        # right
	]
	for r in rects:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = r.size
		cs.shape = shape
		cs.position = r.get_center()
		body.add_child(cs)
	add_child(body)
	# Visible rim
	var rim := Line2D.new()
	rim.width = 4.0
	rim.default_color = Color(0.2, 0.9, 1.0, 0.6)
	rim.points = PackedVector2Array([ARENA.position, Vector2(ARENA.end.x, ARENA.position.y), ARENA.end, Vector2(ARENA.position.x, ARENA.end.y), ARENA.position])
	rim.z_index = -5
	add_child(rim)

func _build_grinders() -> void:
	for p in GRINDER_POS:
		var g := Area2D.new()
		g.collision_layer = 0
		g.collision_mask = 1
		g.position = p
		var cs := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 38.0
		cs.shape = circle
		g.add_child(cs)
		g.monitoring = false
		g.z_index = -10
		add_child(g)
		_grinders.append(g)

func _spawn_frank() -> void:
	frank = FRANK_SCENE.instantiate()
	_frank_reward = frank.kill_reward
	frank.arena_rect = ARENA
	frank.global_position = Vector2(300, 0)
	frank.boss_hp_changed.connect(hud.update_boss_hp)
	frank.boss_defeated.connect(_on_frank_defeated)
	frank.phase_changed.connect(_on_frank_phase)
	add_child(frank)
	hud.show_boss_hp(frank.hp, frank.max_hp, 4)
	# Encounter line lives here, not in Frank's _ready, so replays and retries do not stack it.
	var seen := false
	for entry in ResourceManager.ship_log:
		if entry.get("text", "").begins_with("Phobos Meat Works. The mascot"):
			seen = true
			break
	if not seen:
		ResourceManager.add_log("Phobos Meat Works. The mascot is awake. It is forty feet tall.", "combat")

func _on_frank_phase(p: int) -> void:
	if p == 3:
		_grinders_on = true
		for g in _grinders:
			g.monitoring = true
		hud.show_interact_hint("THE GRINDERS ARE ON")
		await get_tree().create_timer(2.0).timeout
		if is_inside_tree() and not _ending:
			hud.hide_interact_hint()

func _physics_process(delta: float) -> void:
	if _grinders_on:
		_grinder_tick -= delta
		if _grinder_tick <= 0.0:
			_grinder_tick = 0.5
			for g in _grinders:
				for body in g.get_overlapping_bodies():
					if body.is_in_group("player") and body.has_method("take_damage"):
						body.take_damage(4)
	queue_redraw()

func _draw() -> void:
	# Grinders: dark disc with rotating blades; cyan when armed.
	var t := Time.get_ticks_msec() / 1000.0
	for g in _grinders:
		var c: Vector2 = g.position
		draw_circle(c, 40.0, Color(0.12, 0.12, 0.15))
		var blade := Color(0.2, 0.9, 1.0) if _grinders_on else Color(0.35, 0.35, 0.4)
		var spin := t * 6.0 if _grinders_on else 0.0
		for i in range(4):
			var a := spin + i * PI / 2.0
			draw_line(c, c + Vector2(cos(a), sin(a)) * 34.0, blade, 3.0)
		draw_circle(c, 6.0, Color(0.55, 0.05, 0.05))

func _on_frank_defeated() -> void:
	if _ending:
		return
	_ending = true
	hud.hide_boss_hp()
	blood_splatter.trigger()   # ketchup. It was always ketchup.
	hud.show_interact_hint("BIG FRANK DEFEATED  +$%d" % _frank_reward)
	for g in _grinders:
		g.monitoring = false
	_grinders_on = false
	# Lil' Smokies and stray bun halves do not outlive their boss.
	for e in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(e):
			e.queue_free()
	for b in get_tree().get_nodes_in_group("enemy_bullet"):
		if is_instance_valid(b):
			b.queue_free()
	for c in get_children():
		if c is Area2D and c.get_script() != null and c.get_script().resource_path.ends_with("mustard_puddle.gd"):
			c.queue_free()
	await get_tree().create_timer(3.5).timeout
	if not is_inside_tree():
		return
	_exit_to_world()

func _on_ship_died() -> void:
	# Arena death is deliberately gentler than world death: no cargo drop, no reputation hit, full tank on ejection. Phobos is a boss room, not open space.
	if _ending:
		return
	_ending = true
	if is_instance_valid(frank):
		frank.set_physics_process(false)
		frank.get_node("DamageArea").set_deferred("monitoring", false)
	hud.hide_boss_hp()
	ResourceManager.add_log("Ground up at Phobos Meat Works. Ejected toward Mars.", "death")
	var alive := ResourceManager.lose_life()
	hud.show_interact_hint("EJECTED" if alive else "NO LIVES LEFT")
	await get_tree().create_timer(2.5).timeout
	if not is_inside_tree():
		return
	if alive:
		ResourceManager.ship_hp = ResourceManager.ship_max_hp
		ResourceManager.ship_fuel = ResourceManager.ship_max_fuel
		ResourceManager.last_stand_used = false
		_exit_to_world()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func _exit_to_world() -> void:
	# Stop spawners before the scene is torn down so deferred add_child calls do not orphan bullets.
	if is_instance_valid(frank):
		frank.set_physics_process(false)
	for e in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(e):
			e.set_physics_process(false)
	if is_instance_valid(ship) and not ship.is_dead:
		ResourceManager.ship_hp = ship.hp
	ResourceManager.current_planet = "Mars"
	ResourceManager.save_game()
	AudioManager.switch_to_normal_music()
	get_tree().change_scene_to_file("res://scenes/world/World.tscn")
