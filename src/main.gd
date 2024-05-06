extends Control
@export var tree_selector_dialogue : Control
@export var location_creation_dialogue : Control
@export var tree_element : Tree
@export var items_tab : Control

var selected_value : int = -1
var tree_selection_index : int = -1


func _ready():
	pass


func get_image_by_id(image_id):
	var image = $Database.get_image_by_id(image_id)
	return image


func hide_tree_selector():
	tree_selector_dialogue.visible = false


func show_tree_selector_dialogue(tree_index):
	tree_selection_index = tree_index
	if tree_index == Global.TreeSelection.ParentLocation:
		tree_element.build_tree($Database.location_data)
	tree_selector_dialogue.visible = true


func value_selected(value):
	hide_tree_selector()
	selected_value = value
	if tree_selection_index == Global.TreeSelection.ParentLocation:
		var parent_name = $Database.get_location_name_by_id(selected_value)
		location_creation_dialogue.set_parent_name(parent_name)
	
	
func _on_parent_selection_button_pressed():
	show_tree_selector_dialogue(Global.TreeSelection.ParentLocation)


func _on_cancel_tree_selection_pressed():
	hide_tree_selector()


func refrash_items_list():
	items_tab.refrash_items_list($Database.items_data)


func _on_database_item_data_loaded():
	refrash_items_list()
	print("item data loaded")
