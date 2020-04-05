extends '../HeightTool.gd'

var mean

func _init():
	tool_name = 'Flatten'

func _pre_brush(p: Vector2):
	var rad = opts['radius'][OPT_VAL]
	var sum = 0.0
	mean = 0.0
	for y in range(-rad, rad+1):
		for x in range(-rad, rad+1):
			var d = Vector2(x,y).length()/rad
			if d <= 1:
				mean += (1-d)*terrain.get_height(p.x+x, p.y+y)
				sum += 1-d
	mean /= sum

func _get_brush_value(p_strength: float, old_v: float) -> float:
	return lerp(old_v, mean, p_strength)
