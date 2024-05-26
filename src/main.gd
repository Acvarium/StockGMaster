extends Control
@export var tree_element : Tree
@export var locations_tab_tree : Tree
@export var category_tab_tree : Tree
@export  var tag_tab : Control 
@onready var items_tab : Control = $MainControl/TabContainer/Items
@onready var item_creation_dialogue : Control = $ItemCreationDialogue
@onready var location_creation_dialogue : Control = $LocationCreationDialogue
@onready var tree_selection_dialogue : Control = $TreeSelectionDialogue
@onready var action_confirm_dialogue : Control = $ActionConfirmDialogue
var selected_value : int = -1
var tree_selection_index : int = -1

@onready var current_what_to_do = Global.WhatToDo.None
@onready var current_action_data_type = Global.ActionDataType.None
#var current_action_id = -1


func _ready():
	if OS.get_name() == "Android":
		$MainControl/AnimationPlayer.play("mobile_offset")
	pass


func get_number_of_items_in_location(location_id):
	return $Database.get_number_of_items_in_location(location_id)


func delete_location(location_id):
	var location_parent_id = 0
	if location_id in $Database.locations_data.keys():
		if "parent_id" in $Database.locations_data[location_id]:
			location_parent_id = $Database.locations_data[location_id]["parent_id"]
		$Database.move_all_stocks_from_to(location_id, location_parent_id)
		$Database.move_all_locations_from_parent_up(location_id)
		$Database.delete_location(location_id)
		$Database.pull_items_data()
		$Database.pull_locations_data()


func confirme_action_dialogue(recever, conf_what_to_do, message = ""):
	action_confirm_dialogue.confirme_action_dialogue(recever, conf_what_to_do, message)
	

func get_image_by_id(image_id):
	var image = $Database.get_image_by_id(image_id)
	return image


func hide_tree_selector():
	tree_selection_dialogue.visible = false


func get_location_address(location_id):
	return $Database.build_location_address(location_id)


func get_category_address(category_id):
	return $Database.build_category_address(category_id)


func get_location_name_by_id(location_id):
	return $Database.get_location_name_by_id(location_id)


func get_unit_name_by_id(_id):
	if _id == null:
		return ""
	return $Database.get_unit_name_by_id(_id)

#what_to_do can be global.WhatToDo.Change, Delete or create 
#action_data_type can be global.ActionDataType.Location, Category, Tag
func exec_action_popup(what_to_do, action_data_type, for_dialogue = null, item_id = -1):
	if action_data_type == Global.ActionDataType.Location or \
			action_data_type == Global.ActionDataType.ParentLocation:
		tree_element.item_selection_action_type = action_data_type
		tree_element.build_tree($Database.locations_data, item_id)
		tree_selection_dialogue.data_recever_dialogue = for_dialogue
		tree_selection_dialogue.item_id = item_id
		tree_selection_dialogue.visible = true
	if action_data_type == Global.ActionDataType.Category or \
			action_data_type == Global.ActionDataType.ParentCategory:
		tree_element.item_selection_action_type = action_data_type
		tree_element.build_tree($Database.categories_data, item_id)
		tree_selection_dialogue.data_recever_dialogue = for_dialogue
		tree_selection_dialogue.item_id = item_id
		tree_selection_dialogue.visible = true
		

func edit_item(item_id):
	if item_id in $Database.items_data.keys() and item_id > 0:
		item_creation_dialogue.set_item_data($Database.items_data[item_id])
		item_creation_dialogue._reset(true, false)
		item_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Item)
	else:
		item_creation_dialogue.set_item_data({})
		item_creation_dialogue._reset()
		item_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Item)


func edit_stock(stock_data):
	item_creation_dialogue.set_stock_data($Database.items_data[stock_data.item_id], stock_data)
	item_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Stock)


func create_stock(item_id):
	item_creation_dialogue.set_item_data($Database.items_data[item_id])
	item_creation_dialogue._reset(true, false)
	item_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Stock)


#func tree_value_selected(value, action_data_type):
	#if action_data_type == Global.ActionDataType.ParentLocation:
		#hide_tree_selector()
		#selected_value = value
		#if current_what_to_do == Global.WhatToDo.Change:
			#if current_action_data_type == Global.ActionDataType.Location:
				#$Database.update_value(Global.ActionDataType.Location, current_action_id, value)
				#$Database.pull_items_data()
				#if item_creation_dialogue.visible:
					#item_creation_dialogue.update_location_text(get_location_address(selected_value))
			#elif current_action_data_type == Global.ActionDataType.ParentLocation:
				#var parent_name = $Database.get_location_name_by_id(selected_value)
				#location_creation_dialogue.set_parent_name(parent_name)


func delete_item(item_index):
	if item_index in $Database.items_data.keys():
		$Database.delete_item(item_index)
		$Database.pull_items_data()


func delete_stock(stock_id):
	$Database.delete_stock(stock_id)
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
	

func save_location(location_data):
	$Database.save_location(location_data)
	$Database.pull_locations_data()

func save_category(category_data):
	$Database.save_category(category_data)
	$Database.pull_categories_data()

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


func _on_database_categories_data_loaded():
	category_tab_tree.build_tree($Database.categories_data)


func select_location_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Location, for_dialogue, item_id)


func select_category_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Category, for_dialogue, item_id)


func select_parent_location_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentLocation, for_dialogue, item_id)


func select_parent_category_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentCategory, for_dialogue, item_id)



func edit_location(location_id):
	if location_id in $Database.locations_data.keys() and location_id > 0:
		#editing
		location_creation_dialogue.set_data($Database.locations_data[location_id])
		location_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Location)
	else:
		#creating
		location_creation_dialogue.set_data({})
		location_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Location)


func edit_category(category_id):
	if category_id in $Database.categories_data.keys() and category_id > 0:
		#editing
		location_creation_dialogue.set_data($Database.categories_data[category_id])
		location_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Category)
	else:
		#creating
		location_creation_dialogue.set_data({})
		location_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Category)


func _on_create_location_button_pressed():
	edit_location(-1)


func _on_location_struct_tree_button_clicked(item, column, id, mouse_button_index):
	edit_location(id)


func _on_create_category_button_pressed():
	edit_category(-1)


func _on_category_struct_tree_button_clicked(item, column, id, mouse_button_index):
	edit_category(id)


func _on_database_tags_data_loaded():
	tag_tab.refrash_items_list($Database.tags_data)
