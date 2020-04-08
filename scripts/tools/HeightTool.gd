extends '../Tool.gd'

# Identifies tool in the HUD interface
var tool_name = 'Height Tool'

"""
Executes just before the loop that changes the value of each brushed pixel.
This is where meta-values that affect every pixel (e.g. averages) should be
computed.
"""
func _pre_brush(p: Vector2):
	pass

"""
Returns the new pixel value given a pixel strength and the old pixel value
"""
func _get_brush_value(p_strength: float, old_v: float) -> float:
	return old_v

func _update(p: Vector2):
	var rad = opts['radius'][OPT_VAL]
	terrain.update_height(Rect2(p-Vector2(rad,rad), Vector2(rad*2,rad*2)))

func _stroke(p: Vector2):
	var rad = opts['radius'][OPT_VAL]
	var strength = opts['strength'][OPT_VAL]
	_pre_brush(p)
	for y in range(-rad, rad+1):
		for x in range(-rad, rad+1):
			var pos = Vector2(x, y)
			var d = pos.length()/rad
			if d <= 1:
				var p_strength = (1-d) * strength
				var old_v = terrain.get_height(p.x+x, p.y+y)
				terrain.alter_height(p+pos, _get_brush_value(p_strength, old_v))
	_update(p)
