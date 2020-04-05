"""
This object is a single terrain 'tile'.
It is created from a section of a terrain image file.
The tile size is defined in the parent 'Terrain' object.
This class also handles LOD based on distance from player.
"""

extends StaticBody

var terrain
var x
var y
var rect
var SCALE

var col_shape
var mesh_inst
var water

var res = null

var TERRAIN_MATERIAL

func init(terrain, x, y, rect, TERRAIN_MATERIAL, SCALE):
	self.terrain = terrain
	self.x = x
	self.y = y
	self.rect = rect
	self.TERRAIN_MATERIAL = TERRAIN_MATERIAL
	self.SCALE = SCALE
	
	col_shape = get_node("CollisionShape")
	mesh_inst = get_node("MeshInstance")
	water = get_node("Water")
	
	water.set_translation(Vector3(rect.size.x/2*SCALE, terrain.WATER_LEVEL, rect.size.y/2*SCALE))
	
	call_deferred("set_translation", Vector3(rect.position.x*SCALE, 0, rect.position.y*SCALE))

func set_res(res, force_refresh=false):
	if res == self.res and not force_refresh:
		return
	self.res = res
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	
	for y in range(0, rect.size.y-res+1, res):
		for x in range(0, rect.size.x-res+1, res):
			add_vertex(st, x, y)
			add_vertex(st, x+res, y)
			add_vertex(st, x, y+res)
			add_vertex(st, x+res, y+res)
			add_vertex(st, x, y+res)
			add_vertex(st, x+res, y)
	
	st.set_material(TERRAIN_MATERIAL)
	st.generate_normals()
	st.index()
	
	call_deferred("load_st", st)  # Changing mesh is not thread safe, needs deferred function

func load_st(st):
	var mesh = st.commit()
	mesh_inst.set_mesh(mesh)
	col_shape.set_shape(mesh.create_trimesh_shape())

func add_vertex(st, x, y):
	var g_x = x+rect.position.x  # 'g' for global
	var g_y = y+rect.position.y
	var v = terrain.get_height(g_x, g_y)
	st.add_uv(Vector2(g_x,g_y))
	st.add_vertex(Vector3(float(x)*SCALE, v*64-32, float(y)*SCALE))
