extends Control
@export var tree_selector_dialogue : Control
@export var location_creation_dialogue : Control
@export var tree_element : Tree
@export var items_tab : Control
@export var item_creation_dialogue : Control

var selected_value : int = -1
var tree_selection_index : int = -1

@onready var current_what_to_do = Global.WhatToDo.None
@onready var current_action_data_type = Global.ActionDataType.None
var current_action_id = -1

func _ready():
	pass


func get_image_by_id(image_id):
	var image = $Database.get_image_by_id(image_id)
	return image


func hide_tree_selector():
	tree_selector_dialogue.visible = false


func get_location_address(location_id):
	return $Database.build_location_address(location_id)


#func show_tree_selector_dialogue(tree_index):
	#tree_selection_index = tree_index
	#if tree_index == Global.TreeSelection.ParentLocation:
		#tree_element.build_tree($Database.location_data)
	#tree_selector_dialogue.visible = true


#what_to_do can be global.WhatToDo.Change, Delete or create 
#action_data_type can be global.ActionDataType.Location, Category, Tag
func exec_action_popup(what_to_do, action_data_type, for_id):
	current_what_to_do = what_to_do
	current_action_data_type = action_data_type
	current_action_id = for_id
	if current_action_data_type == Global.ActionDataType.Location or \
			current_action_data_type == Global.ActionDataType.ParentLocation:
		tree_element.build_tree($Database.location_data)
		tree_selector_dialogue.visible = true


func edit_item(item_id):
	if item_id in $Database.items_data.keys() and item_id > 0:
		item_creation_dialogue.set_data($Database.items_data[item_id])
		item_creation_dialogue.show()
	else:
		item_creation_dialogue.set_data({})
		item_creation_dialogue.show()


func tree_value_selected(value, action_data_type):
	if action_data_type == Global.ActionDataType.ParentLocation:
		hide_tree_selector()
		selected_value = value
		if current_what_to_do == Global.WhatToDo.Change:
			if current_action_data_type == Global.ActionDataType.Location:
				$Database.update_value(Global.ActionDataType.Location, current_action_id, value)
				$Database.pull_items_data()
				if item_creation_dialogue.visible:
					item_creation_dialogue.update_location_text(get_location_address(selected_value))
			elif current_action_data_type == Global.ActionDataType.ParentLocation:
				var parent_name = $Database.get_location_name_by_id(selected_value)
				location_creation_dialogue.set_parent_name(parent_name)


func delete_item(item_index):
	if item_index in $Database.items_data.keys():
		$Database.delete_item(item_index)
		$Database.pull_items_data()


func save_item(item_data):
	$Database.save_item(item_data)
	$Database.pull_items_data()


func _on_parent_selection_button_pressed():
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentLocation, -1)
	#show_tree_selector_dialogue(Global.TreeSelection.ParentLocation)


func _on_cancel_tree_selection_pressed():
	hide_tree_selector()


func refrash_items_list():
	items_tab.refrash_items_list($Database.items_data)


func _on_database_item_data_loaded():
	refrash_items_list()
	print("item data loaded")


func _on_create_item_button_pressed():
	edit_item(-1)
