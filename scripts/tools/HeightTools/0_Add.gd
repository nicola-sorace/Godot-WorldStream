extends '../HeightTool.gd'

func _init():
	tool_name = 'Add'

func _pre_brush(p: Vector2):
	pass

func _get_brush_value(p_strength: float, old_v: float) -> float:
	return old_v + p_strength * 0.1
