extends Control
@export var title_label : Label
@export var name_list_item : Panel
@export var description_list_item : Panel
@export var parent_list_item : Panel
@onready var main_node = get_tree().get_root().get_node("Main")
@export var delete_button : Button


var current_data
#var location_index = -1
var current_mode = Global.WhatToDo.None
var current_action_data_type = Global.ActionDataType.None


func _ready():
	hide()


func set_data(_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_data = _data
	name_list_item.set_edit_text("")
	if "name" in _data.keys() and _data.name:
		name_list_item.set_edit_text(_data.name)
	description_list_item.set_edit_text("")
	if "description" in _data.keys() and _data.description:
		description_list_item.set_edit_text(_data.description)


func _show(what_to_do, action_data_type):
	current_mode = what_to_do
	current_action_data_type = action_data_type
	if action_data_type == Global.ActionDataType.Location:
		update_parent_text("/")
		if what_to_do == Global.WhatToDo.Create:
			title_label.text = "Create Location"
			delete_button.visible = false
		else:
			if "parent_id" in current_data.keys() and current_data.parent_id:
				update_parent_text(main_node.get_location_address(current_data.parent_id))
			title_label.text = "Edit Location"
			delete_button.visible = true
	elif action_data_type == Global.ActionDataType.Category:
		update_parent_text("/")
		if what_to_do == Global.WhatToDo.Create:
			title_label.text = "Create Category"
			delete_button.visible = false
		else:
			if "parent_id" in current_data.keys() and current_data.parent_id:
				update_parent_text(main_node.get_category_address(current_data.parent_id))
			title_label.text = "Edit Category"
			delete_button.visible = true
	show()


func update_parent_text(new_parent_text):
	parent_list_item.set_location_button_text(new_parent_text)


func _on_cancel_button_pressed():
	hide()


func _on_delete_button_pressed():
	var number_of_items_in_location = main_node.get_number_of_items_in_location(current_data.id)
	var message = ""
	if number_of_items_in_location == 1:
		message = str(number_of_items_in_location) + " item stock will be moved to the ROOT location."
	elif number_of_items_in_location > 1:
		message = str(number_of_items_in_location) + " item stocks will be moved to the ROOT location."
	main_node.confirme_action_dialogue(self, Global.WhatToDo.Delete, message)


func confirme_action(conf_what_to_do):
	if conf_what_to_do == Global.WhatToDo.Delete:
		if current_action_data_type == Global.ActionDataType.Location:
			main_node.delete_location(current_data.id)
		hide()


func _on_save_item_button_pressed():
	if !current_data:
		current_data = {}
	current_data.name = name_list_item.get_edit_text()
	if current_data.name.is_empty():
		hide()
		return
	current_data.description = description_list_item.get_edit_text()
	if current_action_data_type == Global.ActionDataType.Location:
		main_node.save_location(current_data)
	elif current_action_data_type == Global.ActionDataType.Category:
		main_node.save_category(current_data)
	hide()

#
#func update_parent_location_text(new_location_text):
	#parent_list_item.set_location_button_text(new_location_text)


func tree_value_selected(value, item_selection_action_type):
	#if item_selection_action_type == Global.ActionDataType.Location:
		#current_stock_data.item_id = item_index
	if item_selection_action_type == Global.ActionDataType.ParentLocation:
		if !current_data:
			current_data = {}
		current_data.parent_id = value
		update_parent_text(main_node.get_location_address(current_data.parent_id))
	if item_selection_action_type == Global.ActionDataType.ParentCategory:
		if !current_data:
			current_data = {}
		current_data.parent_id = value
		update_parent_text(main_node.get_category_address(current_data.parent_id))


func _on_parent_selection_button_pressed():
	var current_id = -1
	if current_action_data_type == Global.ActionDataType.Location:
		if current_data and "id" in current_data.keys() and current_data.id:
			current_id = current_data.id
		main_node.select_parent_location_popup(self, current_id)
	elif current_action_data_type == Global.ActionDataType.Category:
		if current_data and "id" in current_data.keys() and current_data.id:
			current_id = current_data.id
		main_node.select_parent_category_popup(self, current_id)
