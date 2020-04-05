extends "Terrain.gd"

const TOOL_SHADER = preload("materials/TerrainToolShader.tres")

onready var map_view = get_node("../ViewportContainer/MapViewport")
onready var map_cam = map_view.get_node("MapCamera")

func _ready():
	._ready()
	TERRAIN_MATERIAL.set_next_pass(TOOL_SHADER)
	
	map_cam.set_size(TS*SCALE)

func gen_map():
	var map = Image.new()
	map.create(img.get_width()*SCALE, img.get_height()*SCALE, true, Image.FORMAT_RGB8)
	
	set_block_dist(0)
	TOOL_SHADER.set_shader_param("active", false)
	set_physics_process(false)
	
	for y in range(0, int(map.get_height()/TS)):
		for x in range(0, int(map.get_width()/TS)):
			map_cam.set_translation(Vector3((x+0.5)*TS*SCALE, 100, (y+0.5)*TS*SCALE))
			urgent_update = true
			update([x, y])
			yield(get_tree(), "idle_frame")  # Lets camera position update
			var shot = map_view.get_texture().get_data()
			shot.flip_x()
			shot.convert(map.get_format())
			map.blit_rect(shot, Rect2(Vector2(0,0), shot.get_size()), Vector2(x*TS*SCALE, y*TS*SCALE))
	map.save_png("res://maps/"+MAP_NAME+"/map.png")
	
	set_block_dist(4)
	TOOL_SHADER.set_shader_param("active", true)
	set_physics_process(true)

func alter_height(p, v):
	var old = img.get_pixelv(p)
	img.set_pixelv(p, Color(v, old.g, old.b))
func alter_texture(p, v):
	var old = img.get_pixelv(p)
	img.set_pixelv(p, Color(old.r, v, old.b))

func update_height(rect):
	var coords = []
	for y in range( int(rect.position.y/TS), int(rect.end.y/TS)+1 ):
		for x in range( int(rect.position.x/TS), int(rect.end.x/TS)+1 ):
			coords.append([x,y])
	var i=0
	for t in tiles:
		if t != null:
			for i in range(len(coords)):
				var c = coords[i]
				if t.x == c[0] and t.y == c[1]:
					t.set_res(t.res, true)
					coords.remove(i)
					break
		i+=1

func update_texture():
	var map = ImageTexture.new()
	map.create_from_image(img)
	TERRAIN_MATERIAL.set_shader_param('map', map)

# Store current image data in history queue
func save_img_hist():
	pass
