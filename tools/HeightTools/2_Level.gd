extends '../HeightTool.gd'

func _init():
	tool_name = 'Level'
	opts['height'] = [0, 1, 0.5, 0.01]

func _pre_brush(p: Vector2):
	pass

func _get_brush_value(p_strength: float, old_v: float) -> float:
	return lerp(old_v, opts['height'][OPT_VAL], p_strength)
