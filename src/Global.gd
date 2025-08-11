extends Node
var save_file = "user://StockGMaster.conf.json"
var current_profile_id : int = 1
var ui_scale_factor = 1.0
var last_orientation_is_portrait: bool = false
const base_window_size = Vector2(600, 1000)
var profiles = []

signal profiles_loaded
signal warning_message(title : String, message : String)
signal action_dialogue(recever, conf_what_to_do, warning_message)
signal open_file_popup(filepath, event_pos)
signal edit_attachments_for_item(recever, item_id)


var max_image_size = 200

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
	Profile,
}

enum ProfileValidationStatus {
	Ok,
	NameExists,
	PathExists,
	EmptyName,
	EmptyPath
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


func restart():
	get_tree().reload_current_scene()
	_ready()

func load_config():
	var file = FileAccess.open(save_file, FileAccess.READ)
	if is_instance_valid(file):
		var data = JSON.parse_string(file.get_as_text())
		if "current_profile_id" in data:
			current_profile_id = int(data.current_profile_id)
		if "ui_scale_factor" in data:
			set_ui_scale(data.ui_scale_factor)
		if "max_image_size" in data:
			max_image_size = data.max_image_size
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


func get_image_folder_path():
	return get_data_path() + "images/"


func get_attachments_folder_path():
	return get_data_path() + "attachments/"


func open_file_at(file_path):
	var absolute_path = ProjectSettings.globalize_path(file_path)
	if DirAccess.dir_exists_absolute(absolute_path):
		OS.shell_open(absolute_path)
	elif FileAccess.file_exists(absolute_path):
		OS.shell_open(absolute_path)
	else:
		push_error("File Not Found")



func save_config():
	var data = {}
	data.current_profile_id = current_profile_id
	data.ui_scale_factor = ui_scale_factor
	data.profiles = profiles
	data.max_image_size = max_image_size
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file = null


func add_profile(profile_name, profile_path):
	var _profile = {}
	_profile.name = profile_name
	_profile.editable = true
	_profile.path = profile_path
	profiles.append(_profile)
	save_config()
	profiles_loaded.emit()


func delete_profile(profile_id : int):
	if profile_id < 0 and profile_id >= profiles.size():
		return false
	delete_directory_recursive(profiles[profile_id].path)
	profiles.remove_at(profile_id)
	if profile_id == current_profile_id:
		current_profile_id = 1
		save_config()
		restart()
	else:
		if current_profile_id > profile_id:
			current_profile_id -= 1
		save_config()
		profiles_loaded.emit()


func delete_directory_recursive(path: String) -> bool:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Не вдалося відкрити директорію: %s" % path)
		return false

	# Проходимось по вмісту директорії
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var file_path := path.path_join(file_name)
		if dir.current_is_dir():
			# Рекурсивно видаляємо піддиректорію
			if not delete_directory_recursive(file_path):
				return false
		else:
			# Видаляємо файл
			if dir.remove(file_name) != OK:
				push_error("Не вдалося видалити файл: %s" % file_path)
				return false

		file_name = dir.get_next()
	dir.list_dir_end()


	# Видаляємо саму порожню директорію
	var parent := DirAccess.open(path.get_base_dir())
	if parent == null:
		push_error("Не вдалося відкрити батьківську директорію: %s" % path.get_base_dir())
		return false

	if parent.remove(path.get_file()) != OK:
		push_error("Не вдалося видалити директорію: %s" % path)
		return false

	return true
	


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


func validate_profile(_profile_data) -> ProfileValidationStatus:
	for i in range(profiles.size()):
		if i == _profile_data.id:
			continue
		if _profile_data.name == profiles[i].name:
			return ProfileValidationStatus.NameExists
		if _profile_data.path == profiles[i].path:
			return ProfileValidationStatus.PathExists
	return ProfileValidationStatus.Ok


func default_values():
	gen_default_profiles()
	current_profile_id = 0
	ui_scale_factor = 1.0
