extends Node
var save_file = "user://StockGMaster.conf.json"
var current_profile_id : int = 1
var ui_scale_factor = 1.0
var last_orientation_is_portrait: bool = false
const base_window_size = Vector2(600, 1000)
var profiles = []
signal profiles_loaded

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


func get_scaled_safe_area():
	var safe_area := DisplayServer.get_display_safe_area()
	var window_size = DisplayServer.window_get_size()
	var viewport_size = get_viewport().get_visible_rect().size
	var ratio = viewport_size.x / window_size.x
	var vec_1 = Vector2i(Vector2(safe_area.position) * ratio)
	var vec_2 = Vector2i(Vector2(window_size - safe_area.end) * ratio)
	return Rect2i(vec_1, vec_2)



func set_ui_scale(ui_scale_value):
	ui_scale_factor = ui_scale_value
	if is_on_mobule():
		if is_window_vertical():
			get_viewport().set_content_scale_factor(ui_scale_factor)
		else:
			get_viewport().set_content_scale_factor(ui_scale_factor * 2)
	else:
		get_viewport().set_content_scale_factor(ui_scale_factor)
	save_config()


func update_ui_scale():
	set_ui_scale(ui_scale_factor)


func is_on_mobule():
	return OS.get_name() == "Android" or OS.get_name() == "iOS"


func is_window_vertical():
	var disp_size = get_viewport().get_visible_rect().size
	return disp_size.x < disp_size.y


func get_current_profile_name():
	return profiles[current_profile_id].name


func _ready() -> void:
	get_scaled_safe_area()
	load_config()
	

func load_config():
	var file = FileAccess.open(save_file, FileAccess.READ)
	if is_instance_valid(file):
		var data = JSON.parse_string(file.get_as_text())
		if "current_profile_id" in data:
			current_profile_id = int(data.current_profile_id)
		if "ui_scale_factor" in data:
			set_ui_scale(data.ui_scale_factor)
		if "profiles" in data and data.profiles.size() > 1:
			profiles.clear()
			profiles = data.profiles
		else:
			gen_default_profiles()
	else:
		default_values()
	await get_tree().create_timer(0.1).timeout
	profiles_loaded.emit()
	

func get_data_path():
	return profiles[current_profile_id].path


func save_config():
	var data = {}
	data.current_profile_id = current_profile_id
	data.ui_scale_factor = ui_scale_factor
	data.profiles = profiles
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file = null


func gen_default_profiles():
	profiles.clear()
	var ingame_profile = {}
	ingame_profile.name = 'Ingame(dev)'
	ingame_profile.editable = false
	ingame_profile.path = "res://profile_data/"
	
	var default_profile = {}
	default_profile.name = 'Default'
	default_profile.editable = false
	default_profile.path = "user://default/"
	
	profiles.append(ingame_profile)
	profiles.append(default_profile)
	current_profile_id = 1

func default_values():
	gen_default_profiles()
	current_profile_id = 0
	ui_scale_factor = 1.0
