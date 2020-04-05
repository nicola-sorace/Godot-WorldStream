extends '../Tool.gd'

# Identifies tool in the HUD interface
var tool_name = 'Texture Tool'

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
	return 1.0

func _update(p: Vector2):
	terrain.update_texture()

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
				var old_v = terrain.get_texture(p.x+x, p.y+y)
				terrain.alter_texture(p+pos, _get_brush_value(p_strength, old_v))
	_update(p)
