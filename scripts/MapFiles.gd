extends Node

const START_TILE = 0
const START_OBJECT = 1
const END_FILE = 2

const maps_dir = "maps/"

func write_objects(map_name: String, d: Dictionary):
	var file = File.new()
	file.open(maps_dir+map_name+'/objects.dat', File.WRITE)
	
	# File header ('WOBJ')
	file.store_buffer([87,79,66,74, 0])
	
	for key in d:
		# Signal start of a tile
		file.store_8(START_TILE)
		# Store tile coordinates
		file.store_16(key[0])
		file.store_16(key[1])
		for obj in d[key]:
			# Signal start of an object
			file.store_8(START_OBJECT)
			# Store object name
			file.store_string(obj[0])
			file.store_buffer([0]) # Null terminate
			# Store relative translation
			file.store_float(obj[1].x)
			file.store_float(obj[1].y)
			file.store_float(obj[1].z)
			# Store relative rotation
			file.store_float(obj[2].x)
			file.store_float(obj[2].y)
			file.store_float(obj[2].z)
	# Signal end of file
	file.store_8(END_FILE)
	file.close()

func read_objects(map_name: String) -> Dictionary:
	var d = {}
	var file = File.new()
	file.open(maps_dir+map_name+"/objects.dat", File.READ)
	assert( file.get_line() == 'WOBJ' )
	var b = file.get_8()
	while b == START_TILE:
		var key = [file.get_16(), file.get_16()]
		d[key] = []
		b = file.get_8()
		while b == START_OBJECT:
			var obj_name = file.get_line()
			var obj_pos = Vector3(file.get_float(), file.get_float(), file.get_float())
			var obj_rot = Vector3(file.get_float(), file.get_float(), file.get_float())
			d[key].append([obj_name, obj_pos, obj_rot])
			b = file.get_8()
	return d
