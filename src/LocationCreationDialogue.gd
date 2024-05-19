extends Control
@export var title_label : Label
@export var name_list_item : Panel
@export var description_list_item : Panel
@export var parent_list_item : Panel
@onready var main_node = get_tree().get_root().get_node("Main")
@export var delete_button : Button


var current_location_data
#var location_index = -1
var current_mode = Global.WhatToDo.None
var current_action_data_type = Global.ActionDataType.None


func _ready():
	hide()


func set_location_data(location_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_location_data = location_data
	if "id" in location_data.keys():
		title_label.text = "Edit Location"
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
	if !current_location_data:
		current_location_data = {}
	current_location_data.name = name_list_item.get_edit_text()
	if current_location_data.name.is_empty():
		hide()
		return
	current_location_data.description = description_list_item.get_edit_text()
	main_node.save_location(current_location_data)
	hide()


func update_parent_location_text(new_location_text):
	parent_list_item.set_location_button_text(new_location_text)


func tree_value_selected(value, item_selection_action_type):
	#if item_selection_action_type == Global.ActionDataType.Location:
		#current_stock_data.item_id = item_index
	if item_selection_action_type == Global.ActionDataType.ParentLocation:
		if !current_location_data:
			current_location_data = {}
		
		current_location_data.parent_id = value
		update_parent_location_text(main_node.get_location_address(current_location_data.parent_id))


func _on_parent_selection_button_pressed():
	main_node.select_location_popup(self)
