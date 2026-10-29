extends Control

# Draws connection lines between skill tree nodes.
# Attach to a Control that sits behind the node buttons.

const GRID_SCALE: float = 70.0
const SCREEN_CENTER: Vector2 = Vector2(640, 380)

func refresh() -> void:
	queue_redraw()

func _draw() -> void:
	var unlocked: Array = ResourceManager.unlocked_nodes
	for node_id in SkillTreeData.NODES:
		var node: Dictionary = SkillTreeData.NODES[node_id]
		var requires: Array = node.get("requires", [])
		if requires.is_empty():
			continue
		var to_pos: Vector2 = _node_screen_pos(node_id)
		var to_owned: bool = unlocked.has(node_id)
		for prereq_id in requires:
			var from_pos: Vector2 = _node_screen_pos(prereq_id)
			var from_owned: bool = unlocked.has(prereq_id)
			var line_color: Color
			if to_owned and from_owned:
				line_color = Color(0.7, 0.4, 1.0, 0.9)
			elif to_owned or from_owned:
				line_color = Color(0.5, 0.3, 0.7, 0.6)
			else:
				line_color = Color(0.3, 0.3, 0.3, 0.35)
			draw_line(from_pos, to_pos, line_color, 2.0, true)

func _node_screen_pos(node_id: String) -> Vector2:
	var grid_pos: Vector2 = SkillTreeData.NODE_POSITIONS.get(node_id, Vector2.ZERO)
	return SCREEN_CENTER + grid_pos * GRID_SCALE
