extends Control
@export var tree_selector_dialogue : Control
@export var location_creation_dialogue : Control
@export var tree_element : Tree
@export var items_tab : Control

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


func value_selected(value):
	hide_tree_selector()
	selected_value = value
	if current_what_to_do == Global.WhatToDo.Change:
		if current_action_data_type == Global.ActionDataType.Location:
			$Database.update_value(Global.ActionDataType.Location, current_action_id, value)
			$Database.pull_items_data()
			
		elif current_action_data_type == Global.ActionDataType.ParentLocation:
			var parent_name = $Database.get_location_name_by_id(selected_value)
			location_creation_dialogue.set_parent_name(parent_name)


func item_saved(item_data):
	if item_data.id in $Database.items_data.keys():
		pass


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
