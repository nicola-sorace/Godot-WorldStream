"""
Handles camera movement and emits signals for 3d-view mouse events.
"""
extends Camera

onready var root = get_node('/root/root')

var dist = 10  # Camera distance
var dir = deg2rad(180)  # y-rotation
var ang = 0  # Altitude angle

var rotating = false
var last_mouse = Vector2(0,0) # Screen coordinates
var map_mouse = Vector2(0,0) # Map coordinates

signal drag_start
signal drag_move
signal drag_stop
signal scroll # Scroll with 'shift' modifier (i.e. not zoom)

func _update_pos():
	set_translation(Vector3(0, 2, 0))
	set_rotation(Vector3(ang, dir, 0))
	translate_object_local(Vector3(0, 0, dist))

func _update_map_mouse():
	var mouse = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * 300
	var mouse_hit = get_world().get_direct_space_state().intersect_ray(from, to, [root.player], 1)
	if not mouse_hit.empty():
		var m_p = mouse_hit.position
		map_mouse = Vector2(m_p.x/root.terrain.SCALE, m_p.z/root.terrain.SCALE)
		root.terrain.TOOL_SHADER.set_shader_param("pos", map_mouse)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		last_mouse = get_viewport().get_mouse_position()
		if event.button_index == BUTTON_RIGHT:
			if event.pressed:
				rotating = true
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			else:
				rotating = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == BUTTON_LEFT:
			if event.pressed:
				emit_signal("drag_start", map_mouse)
			else:
				emit_signal("drag_stop", map_mouse)
		
		var scroll = float(event.button_index == BUTTON_WHEEL_DOWN)-float(event.button_index == BUTTON_WHEEL_UP)
		if scroll != 0:
			if Input.is_key_pressed(KEY_SHIFT):
				emit_signal("scroll", sign(scroll))
			else:
				dist += scroll
				_update_pos()
	
	elif event is InputEventMouseMotion:
		var mouse = get_viewport().get_mouse_position()
		if rotating:
			var diff = mouse - last_mouse
			dir -= diff.x/100
			ang -= diff.y/100
			last_mouse = mouse
			_update_pos()
		else:
			_update_map_mouse()
			emit_signal("drag_move", map_mouse)
