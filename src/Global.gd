extends Node
var save_file = "user://StockGMaster.conf.json"
var profile_names = ['In Game Folder', 'Default']
var current_profile_id = 1

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
	Stock
}


func get_current_profile_name():
	return profile_names[current_profile_id]


func load_game():
	var file = FileAccess.open(save_file, FileAccess.READ)
	if is_instance_valid(file):
		var data = JSON.parse_string(file.get_as_text())
		if "profile_names" in data:
			profile_names = data.profile_names
		if "current_profile_id" in data:
			current_profile_id = data.current_profile_id
	else:
		default_values()


func save_config():
	var data = {}
	data.profile_names = profile_names
	data.current_profile_id = current_profile_id
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file = null


func default_values():
	profile_names = ['default']
	current_profile_id = 1
