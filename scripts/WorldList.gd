extends Control

var MAP_FILES = preload("WorldFiles.gd").new()

onready var list = get_node('Panel/List')
onready var btn_load = get_node('Panel/LoadWorld')
onready var btn_new = get_node('Panel/NewWorld')
onready var popup_new = get_node('NewWorld')

var worlds

func _edit_world(__: int):
	if len(list.get_selected_items()) > 0:
		var i = list.get_selected_items()[0]
		get_tree().change_scene('WorldEdit.tscn')

func _world_selected(__: int):
	btn_load.set_disabled(false)

func _world_unselected():
	list.unselect_all()
	btn_load.set_disabled(true)

func _ready():
	worlds = MAP_FILES.list_worlds()
	for world in worlds:
		var icon = MAP_FILES.get_minimap(world)
		list.add_item(world, icon)
	
	list.connect('item_activated', self, '_edit_world')
	list.connect('item_selected', self, '_world_selected')
	list.connect('nothing_selected', self, '_world_unselected')
	btn_load.connect('pressed', self, '_edit_world', [-1])
	
	btn_new.connect('pressed', popup_new, 'popup')
