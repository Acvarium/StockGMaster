extends Control
var data_recever_dialogue = null
@onready var main_node = get_tree().get_root().get_node("Main")


func tree_value_selected(value, item_selection_action_type):
	if data_recever_dialogue:
		data_recever_dialogue.tree_value_selected(value, item_selection_action_type)
	else:
		main_node.tree_value_selected(value, item_selection_action_type)
	hide()
