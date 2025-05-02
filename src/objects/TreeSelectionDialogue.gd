extends Control
var data_recever_dialogue = null
var item_id = -1
@onready var main_node = get_tree().get_root().get_node("Main")
@onready var search_line_edit : LineEdit = $TSL/AspectRatioContainer/Control/SearchLine2/SearchLineEdit
@onready var tree_element : Tree = $TSL/AspectRatioContainer/Control/StructTree
var current_tree_data : Dictionary

func tree_value_selected(value, item_selection_action_type):
	if data_recever_dialogue:
		data_recever_dialogue.tree_value_selected(value, item_selection_action_type)
	else:
		main_node.tree_value_selected(value, item_selection_action_type)
	hide()


func set_tree_element_item_selection_action_type(action_data_type):
	tree_element.item_selection_action_type = action_data_type


func build_tree(tree_data : Dictionary, item_id = -1):
	current_tree_data = tree_data
	tree_element.build_tree(tree_data, item_id)
	

func _on_cancel_tree_selection_pressed():
	hide()


func _show():
	search_line_edit.text = ""
	visible = true
	search_line_edit.grab_focus()


func _on_search_line_edit_text_changed(new_text):
	if current_tree_data:
		var found_items = main_node.search_tree_data_with_text(new_text, current_tree_data)
		tree_element.show_selection(found_items)
