extends Node
var save_file = "user://StockGMaster.conf.json"
var profile_names = ['In Game Folder', 'Default']
var current_profile_id = 1
var ui_scale_factor = 1.0

enum WhatToDo {
	None,
	Change,
	Create,
	Delete
}

enum ActionDataType {
	None,
	Location,
	ParentLocation,
	Category,
	ParentCategory,
	Tag,
	Item,
	Stock,
	Image,
}


func set_ui_scale(ui_scale_value):
	ui_scale_factor = ui_scale_value
	var base_wi_height = 1000
	get_viewport().set_content_scale_factor(ui_scale_factor)
	#get_viewport().content_scale_size = Vector2(600, base_wi_height * ui_scale_factor) 
	save_config()
	

func isWindowVertical():
	var disp_size = get_viewport().get_visible_rect().size
	return disp_size.x < disp_size.y


func get_current_profile_name():
	return profile_names[current_profile_id]


func _ready() -> void:
	load_config()
	

func load_config():
	var file = FileAccess.open(save_file, FileAccess.READ)
	if is_instance_valid(file):
		var data = JSON.parse_string(file.get_as_text())
		if "profile_names" in data:
			profile_names = data.profile_names
		if "current_profile_id" in data:
			current_profile_id = data.current_profile_id
		if "ui_scale_factor" in data:
			set_ui_scale(data.ui_scale_factor)
	else:
		default_values()


func save_config():
	var data = {}
	data.profile_names = profile_names
	data.current_profile_id = current_profile_id
	data.ui_scale_factor = ui_scale_factor
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file = null


func default_values():
	profile_names = ['default']
	current_profile_id = 1
	ui_scale_factor = 1.0
