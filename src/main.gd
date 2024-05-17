extends Control
@export var tree_element : Tree
@export var locations_tab_tree : Tree
@onready var items_tab : Control = $MainControl/TabContainer/Items
@onready var item_creation_dialogue : Control = $ItemCreationDialogue
@onready var location_creation_dialogue : Control = $LocationCreationDialogue
@onready var tree_selection_dialogue : Control = $TreeSelectionDialogue
@onready var action_confirm_dialogue : Control = $ActionConfirmDialogue

var selected_value : int = -1
var tree_selection_index : int = -1

@onready var current_what_to_do = Global.WhatToDo.None
@onready var current_action_data_type = Global.ActionDataType.None
var current_action_id = -1


func _ready():
	pass


func confirme_action(recever, conf_what_to_do):
	action_confirm_dialogue.confirme_action(recever, conf_what_to_do)
	

func get_image_by_id(image_id):
	var image = $Database.get_image_by_id(image_id)
	return image


func hide_tree_selector():
	tree_selection_dialogue.visible = false


func get_location_address(location_id):
	return $Database.build_location_address(location_id)


func get_unit_name_by_id(_id):
	if _id == null:
		return ""
	return $Database.get_unit_name_by_id(_id)

#what_to_do can be global.WhatToDo.Change, Delete or create 
#action_data_type can be global.ActionDataType.Location, Category, Tag
func exec_action_popup(what_to_do, action_data_type, for_id, for_dialogue = null):
	current_what_to_do = what_to_do
	current_action_data_type = action_data_type
	current_action_id = for_id
	if current_action_data_type == Global.ActionDataType.Location or \
			current_action_data_type == Global.ActionDataType.ParentLocation:
		tree_element.build_tree($Database.locations_data)
		tree_selection_dialogue.data_recever_dialogue = for_dialogue
		tree_selection_dialogue.visible = true
		

func edit_item(item_id):
	if item_id in $Database.items_data.keys() and item_id > 0:
		item_creation_dialogue.set_item_data($Database.items_data[item_id])
	else:
		item_creation_dialogue.set_item_data({})
	item_creation_dialogue._show()


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


func save_item(item_data, to_pull = true):
	$Database.save_item(item_data)
	if to_pull:
		$Database.pull_items_data()
	return $Database.get_new_item_id()
	


func save_stock(stock_data, to_pull = true):
	$Database.save_stock(stock_data)
	if to_pull:
		$Database.pull_items_data()
	

func _on_parent_selection_button_pressed():
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentLocation, -1)
	#show_tree_selector_dialogue(Global.TreeSelection.ParentLocation)


func refrash_items_list():
	if !items_tab:
		items_tab = $MainControl/TabContainer/Items
	items_tab.refrash_items_list($Database.items_data)


func _on_database_item_data_loaded():
	refrash_items_list()
	print("item data loaded")


func _on_create_item_button_pressed():
	edit_item(-1)


func _on_database_locations_data_loaded():
	locations_tab_tree.build_tree($Database.locations_data)


func select_location_popup(item_index, for_dialogue):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Location, item_index, for_dialogue)
