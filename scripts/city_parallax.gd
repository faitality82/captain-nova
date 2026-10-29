extends Node2D
## Manages multiple parallax layers that scroll at different speeds relative to the camera.
## Each layer is a Node2D child with a scroll multiplier.
##
## Scroll factors:
##   0.0 = static (sky, doesn't move with camera)
##   0.1 = slow parallax (far background)
##   0.3 = medium parallax (near background)
##   1.0 = normal (street level, moves with camera)
##   1.2 = foreground (moves faster than camera)

var _camera: Camera2D
var _layers: Array[Dictionary] = []


func setup(camera: Camera2D) -> void:
	_camera = camera


func add_layer(layer_name: String, z: int, scroll_factor: float) -> Node2D:
	var layer := Node2D.new()
	layer.name = layer_name
	layer.z_index = z
	add_child(layer)
	_layers.append({"node": layer, "factor": scroll_factor})
	return layer


func _process(_delta: float) -> void:
	if not is_instance_valid(_camera):
		return

	var cam_offset: Vector2 = _camera.get_screen_center_position()

	for entry in _layers:
		var layer: Node2D = entry["node"]
		var factor: float = entry["factor"]
		layer.position.x = -cam_offset.x * (1.0 - factor)
