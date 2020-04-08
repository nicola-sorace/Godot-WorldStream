extends Control

onready var root = get_node('/root/root')
var cam # root.cam

const TOOL = preload('Tool.gd')
var tools = [[]] # List of tools in each mode
var active_tool : Tool

onready var mode_buts = get_node("Modes").get_children()
onready var action_buts = get_node("Actions").get_children()
onready var submodes = get_node("Submodes")
onready var toolopts = get_node("ToolOptions/VBoxContainer")

# Mode ENUMs:
const MODE_HEIGHT = 0
const MODE_TEXTURE = 1
const MODE_OBJECT = 2
const MODE_SPAWNS = 3

var mode = MODE_HEIGHT

func _get_files_in(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if not file.begins_with("."):
			files.append(file)
		file = dir.get_next()
	return files

func _set_mode(i: int):
	mode = i
	for j in range(len(mode_buts)):
		mode_buts[j].set_pressed( j == i )
	
	submodes.clear()
	for t in tools[i]:
		submodes.add_item(t.tool_name)
	_set_submode(0)

func _set_submode(i: int):
	submodes.select(i)
	_disconnect_tool()
	active_tool = tools[mode][i]
	_connect_tool()
	_update_tool_options()

func _update_tool_options():
	for c in toolopts.get_children():
		toolopts.remove_child(c)
		c.queue_free()
	
	for opt_name in active_tool.opts:
		var o = active_tool.opts[opt_name]
		
		var label = Label.new()
		label.set_text(opt_name)
		toolopts.add_child(label)
		
		var slider = HSlider.new()
		slider.set_min(o[TOOL.OPT_MIN])
		slider.set_max(o[TOOL.OPT_MAX])
		slider.set_step(o[TOOL.OPT_STEP])
		slider.set_value(o[TOOL.OPT_VAL])
		slider.set_ticks(5)
		slider.connect("value_changed", self, "_set_tool_value", [opt_name])
		toolopts.add_child(slider)

func _set_tool_value(value: float, opt_name: String):
	active_tool.opts[opt_name][TOOL.OPT_VAL] = value

func _disconnect_tool():
	cam.disconnect("drag_start", active_tool, "tool_start")
	cam.disconnect("drag_move", active_tool, "tool_move")
	cam.disconnect("drag_stop", active_tool, "tool_stop")

func _connect_tool():
	active_tool.set_terrain(root.terrain)
	cam.connect("drag_start", active_tool, "tool_start")
	cam.connect("drag_move", active_tool, "tool_move")
	cam.connect("drag_stop", active_tool, "tool_stop")

func _scroll(dir: int):
	var rad = active_tool.opts['radius']
	var new_val = rad[TOOL.OPT_VAL] - dir*rad[TOOL.OPT_STEP]
	if new_val >= rad[TOOL.OPT_MIN] and new_val <= rad[TOOL.OPT_MAX]:
		rad[TOOL.OPT_VAL] = new_val
	root.terrain.TOOL_SHADER.set_shader_param("rad", rad[TOOL.OPT_VAL])

func _set_cam():
	cam = root.cam
	cam.connect('scroll', self, '_scroll')

func _ready():
	for i in range(len(mode_buts)):
		mode_buts[i].connect("pressed", self, "_set_mode", [i])
	for i in range(len(action_buts)):
		action_buts[i].connect("pressed", self, "_action", [i])
	submodes.connect("item_selected", self, "_set_submode")
	
	tools = []
	for m in range(4): # For each available mode
		tools.append([])
	# Height
	for tool_name in _get_files_in('scripts/tools/HeightTools'):
		tools[MODE_HEIGHT].append(load('scripts/tools/HeightTools/'+tool_name).new())
	# Texture
	tools[MODE_TEXTURE].append(load('scripts/tools/TextureTool.gd').new('Grass', 0.0))
	tools[MODE_TEXTURE].append(load('scripts/tools/TextureTool.gd').new('Dirt', 1.0))
	
	call_deferred("_set_cam")
	call_deferred("_set_mode", MODE_HEIGHT)
