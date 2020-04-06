extends '../Tool.gd'

var tool_name = 'Texture Tool'
var texture_val = 1.0

func _init(tool_name: String, texture_val: float):
	self.tool_name = tool_name
	self.texture_val = texture_val

"""
Returns the new pixel value given a pixel strength and the old pixel value
"""
func _get_brush_value(p_strength: float, old_v: float) -> float:
	return texture_val

func _update(p: Vector2):
	terrain.update_texture()

func _stroke(p: Vector2):
	var rad = opts['radius'][OPT_VAL]
	var strength = opts['strength'][OPT_VAL]
	for y in range(-rad, rad+1):
		for x in range(-rad, rad+1):
			var pos = Vector2(x, y)
			var d = pos.length()/rad
			if d <= 1:
				var p_strength = (1-d) * strength
				var old_v = terrain.get_texture(p.x+x, p.y+y)
				terrain.alter_texture(p+pos, _get_brush_value(p_strength, old_v))
	_update(p)
