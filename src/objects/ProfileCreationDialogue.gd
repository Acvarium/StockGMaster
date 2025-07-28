extends Control

@export var title_label : Label
@export var name_list_item : Panel
@export var dir_name_list_item : Panel
@onready var main_node = get_tree().get_root().get_node("Main")
@export var delete_button : Button


var current_data
#var location_index = -1
var current_mode = Global.WhatToDo.None
var current_action_data_type = Global.ActionDataType.None
var dir_text_edited = false


func _notification(what):
	dir_text_edited = false


func _ready():
	hide()


func set_data(_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_data = _data
	name_list_item.set_edit_text("")
	if "name" in _data.keys() and _data.name:
		name_list_item.set_edit_text(_data.name)
	dir_name_list_item.set_edit_text("")
	if "path" in _data.keys() and _data.path:
		dir_name_list_item.set_edit_text(get_dir_name_from_paht(_data.path))


func get_dir_name_from_paht(_path):
	var _dir_name = _path.replace("user://", "").replace("/", "")
	return _dir_name
	


func _show(what_to_do, action_data_type):
	current_mode = what_to_do
	current_action_data_type = action_data_type
	if action_data_type == Global.ActionDataType.Profile:
		#update_parent_text("/")
		if what_to_do == Global.WhatToDo.Create:
			title_label.text = "Create Profile"
			delete_button.visible = false
		else:
			title_label.text = "Edit Profile"
			delete_button.visible = true
	show()


func _on_cancel_button_pressed() -> void:
	hide()


func _on_save_item_button_pressed() -> void:
	if name_list_item.get_edit_text().is_empty():
		Global.warning_message.emit("Empty Name!", "Name cannot be empty.")
		return
	if dir_name_list_item.get_edit_text().is_empty():
		Global.warning_message.emit("Empty Path!", "Path cannot be empty.")
		return
	var new_profile_data = {}
	new_profile_data.name = name_list_item.get_edit_text()
	new_profile_data.path = "user://" + dir_name_list_item.get_edit_text() + "/"
	
	if current_mode == Global.WhatToDo.Create:
		new_profile_data.id = -1
		var validation_status = Global.validate_profile(new_profile_data)
		if validation_status == Global.ProfileValidationStatus.Ok:
			Global.add_profile(new_profile_data.name, new_profile_data.path)
			hide()
		elif validation_status == Global.ProfileValidationStatus.NameExists:
			Global.warning_message.emit("The Name Exists!", "A profile with that name already exists.")
		elif validation_status == Global.ProfileValidationStatus.PathExists:
			Global.warning_message.emit("Path Exists!", "A profile with this path already exists.")
			

func delete_profile():
	Global.delete_profile(current_data.id)
	hide()


func confirme_action(conf_what_to_do):
	if conf_what_to_do == Global.WhatToDo.Delete:
		delete_profile()


func _on_delete_button_pressed() -> void:
	var action_message = "Are you sure you want to delete the profile \'" + \
		current_data.name + "\' with all its data?"
		
	Global.action_dialogue.emit(self, Global.WhatToDo.Delete, action_message)


func _on_name_edit_text_changed() -> void:
	if !dir_text_edited:
		dir_name_list_item.set_edit_text(name_list_item.get_edit_text())


func _on_dir_name_edit_text_changed() -> void:
	if dir_name_list_item.get_edit_text() != name_list_item.get_edit_text():
		dir_text_edited = true
