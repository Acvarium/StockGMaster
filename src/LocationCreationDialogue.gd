extends Control
@export var title_label : Label
@export var name_list_item : Panel
@export var description_list_item : Panel
@export var parent_list_item : Panel
@onready var main_node = get_tree().get_root().get_node("Main")
@export var delete_button : Button


var current_location_data
var location_index = -1
var current_mode = Global.WhatToDo.None
var current_action_data_type = Global.ActionDataType.None


func _ready():
	pass # Replace with function body.


func set_location_data(location_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_location_data = location_data
	location_index = -1 
	if "id" in location_data.keys():
		title_label.text = "Edit Location"
		location_index = location_data.id
		delete_button.visible = true
	else:
		title_label.text = "Create Location"
		delete_button.visible = false
	name_list_item.set_edit_text("")
	if "name" in location_data.keys() and location_data.name:
		name_list_item.set_edit_text(location_data.name)
	description_list_item.set_edit_text("")
	if "description" in location_data.keys() and location_data.description:
		description_list_item.set_edit_text(location_data.description)


func _show(what_to_do, action_data_type):
	current_mode = what_to_do
	current_action_data_type = action_data_type
	if action_data_type == Global.ActionDataType.Location:
		if what_to_do == Global.WhatToDo.Create:
			pass
		else:
			pass
	show()


func _on_cancel_button_pressed():
	hide()


func _on_delete_button_pressed():
	pass # Replace with function body.


func _on_save_item_button_pressed():
	pass # Replace with function body.
