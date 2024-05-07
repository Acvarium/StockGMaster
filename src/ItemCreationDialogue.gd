extends Control
@export var name_edit : TextEdit
@export var description_edit : TextEdit
@export var location_button : Button
@export var title_label : Label
@onready var main_node = get_tree().get_root().get_node("Main")
var item_index = -1


func set_data(item_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	item_index = -1 
	if "id" in item_data.keys():
		title_label.text = "Edit Item"
		item_index = item_data.id
	else:
		title_label.text = "Create Item"
	name_edit.text = ""
	if "name" in item_data.keys() and item_data.name:
		name_edit.text = item_data.name
	description_edit.text = ""
	if "description" in item_data.keys() and item_data.description:
		description_edit.text = item_data.description
	if "location_id" in item_data.keys() and item_data.location_id:
		update_location_text(main_node.get_location_address(item_data.location_id))


func update_location_text(new_location_text):
	location_button.get_node("LocationEdit").text = new_location_text


func _ready():
	pass # Replace with function body.


func _on_cancel_button_pressed():
	hide()


#func update_location()

func _on_save_item_button_pressed():
	var new_item_data = {}
	new_item_data.id = item_index
	new_item_data.name = name_edit.text
	new_item_data.description = description_edit.text
	main_node.save_item(new_item_data)
	hide()


func _on_location_selection_button_pressed():
	main_node.exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Location, item_index)
