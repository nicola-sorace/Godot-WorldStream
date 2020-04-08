extends Node
class_name Tool

var terrain # Assigned via 'set_terrain' function

# Tool options enums and array
const OPT_MIN = 0
const OPT_MAX = 1
const OPT_VAL = 2
const OPT_STEP = 3
var opts = {
	'radius': [1, 100, 10, 1],
	'spacing': [1, 100, 2, 1],
	'strength': [0, 1, 0.5, 0.01],
}

var last_pos = Vector2(0,0)
var distance = 0 # Total distance moved since last stroke
var painting = false

func set_terrain(terrain: Node):
	self.terrain = terrain

func _update(p: Vector2):
	pass

func _stroke(p: Vector2):
	print('stroke')

func tool_start(p: Vector2):
	last_pos = p
	distance = 0
	painting = true
	_stroke(p)

func tool_stop(p: Vector2):
	last_pos = p
	distance = 0
	painting = false

func tool_move(p: Vector2):
	if painting:
		distance += (p - last_pos).length()
		last_pos = p
		if distance >= opts['spacing'][OPT_VAL]:
			distance = 0
			_stroke(p)
