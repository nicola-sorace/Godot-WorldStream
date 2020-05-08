"""
This object represents the world map. It handles the loading of terrain tiles.
Terrain data is stored as an image, with the red chanel as height data and green
channel as terrain texture index.

TODO:
	- Hide seams between tiles of different res
	  -> Easiest method is probably to extrude edges downwards to cover gaps.
	- Fix whatever is causing occasional freeze (deadlock?)
"""

extends Spatial

export(NodePath) var player_path = null
onready var player = get_node(player_path)

var MAP_FILES = preload("WorldFiles.gd").new()

var MAP_NAME = 'Test'
const SCALE = 1 # Map scale (meters per pixel)
var TERRAIN_MATERIAL = preload("../materials/Terrain.tres")
var WATER_LEVEL = -1.0

var img
var obj_dict = {}

var tiles = [] # Holds the currently visible terrain tiles

const TS = 64 # Tile size in pixels

# The size of the visible map is set via the 'set_block_dist(D)' function
var D  # Distance from center tile to edge of visible map (perpendicularly): D = int((N-1)/2)
var N  # Edge length (in tiles) of 'tiles' array. MUST BE ODD! N = D*2+1

# Last known tile position of player:
var last_x = 0
var last_y = 0

# Terrain loading is threaded to avoid lag
var thread = Thread.new()
var abort_thread = false  # Set to 'true' to make threaded process quit as soon as possible (used when tile being loaded is out of date)
var urgent_update = true  # Set to 'true' to force a non-threaded terrain update (used when player is about to fall off the loaded map)

var TILE = preload("../TerrainTile.tscn")

func create_tile(x,y, res=0):
	var tile = TILE.instance()
	tile.init(self, x, y, Rect2(x*TS, y*TS, TS, TS), TERRAIN_MATERIAL, SCALE)
	if res!=0:
		tile.set_res(res)
	call_deferred("add_child", tile)
	return tile

func delete_tile(i):
	var t = tiles[i]
	if t != null:
		call_deferred("remove_child", t)
		t.queue_free()
		tiles[i] = null

func set_block_dist(D):
	self.D = D
	N = D*2+1
	# Throw away all tiles and start over
	for i in range(len(tiles)):
		delete_tile(i)
	tiles = []
	for y in N:
		for x in N:
			tiles.append(null)

# Returns desired resolution based on *squared* distance to tile
func get_res(d):
	if d <= 4: return 1
	elif d <= 9: return 4
	else: return 16

func get_height(x, y):
	return img.get_pixel(x,y).r
func get_texture(x, y):
	return img.get_pixel(x,y).g

"""
This function updates the terrain:
 - Create array of required tile resolutions
 - Iterate over tiles array:
   - If tile is in required, update res & remove from required array
   - Else, delete tile (element becomes null)
 - Iterate over remaining required tiles:
   - Find next tile in tiles that is null
   - Create the required tile here & delete from required array
"""
func update(args):
	var x = args[0]
	var y = args[1]
	
	var desired_ress = {} # Stores desired tile resolutions. Index is 'x,y' string
	for y_r in range(y-D, y+D+1):
		for x_r in range(x-D, x+D+1):
			if x_r>0 and y_r>0 and x_r<img.get_width()/TS-1 and y_r<img.get_height()/TS-1:
				var d = pow(x_r-x, 2) + pow(y_r-y, 2) # Avoid squareroot for efficiency
				if d <= pow(D, 2): # Circular mask around player
					desired_ress[ [x_r,y_r] ] = get_res(d)
	
	for i in range(len(tiles)):
		if abort_thread:
			return
		var tile = tiles[i]
		if tile != null:
			var j = [tile.x, tile.y]
			if not( j in desired_ress ):
				delete_tile(i)
			else:
				tile.set_res(desired_ress[j])
				desired_ress.erase(j)
	
	for j in desired_ress:
		if abort_thread:
			return
		if not urgent_update and desired_ress[j] <= 1: # Nearby tile missing! Force urgent map update
			urgent_update = true
			return
		for i in range(len(tiles)):
			if tiles[i] == null:
				tiles[i] = create_tile(j[0], j[1], desired_ress[j])
				break

func check_update():
	var pos = player.translation
	var x = int(pos.x/TS/SCALE)
	var y = int(pos.z/TS/SCALE)
	
	if urgent_update:
		print("Urgent terrain update")
		update([x,y])
		urgent_update = false
	elif x != last_x or y != last_y:
		if thread.is_active():  # Falling behind; let thread catch up before continuing:
				abort_thread = true
				thread.wait_to_finish()
				abort_thread = false
		thread.start(self, "update", [x,y], Thread.PRIORITY_LOW)
		
		last_x = x
		last_y = y

func _ready():
	img = load("worlds/"+MAP_NAME+"/terrain.png").get_data()
	img.decompress()
	img.lock()
	set_block_dist(6)
	
	var d = {[5, 3]: [ ['Sphere', Vector3(12.12,3,4), Vector3(0,0,0)], ['Sphere', Vector3(20,3,20), Vector3(0,0,0)] ]}
	MAP_FILES.write_objects(MAP_NAME, d)
	obj_dict = MAP_FILES.read_objects(MAP_NAME)

func _physics_process(delta):
	check_update()
