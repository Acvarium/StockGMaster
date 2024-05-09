extends Tree

@export var parent_id_key = "parent_id"
@export var name_key = "name"
@onready var main_node = get_tree().get_root().get_node("Main")
@export var item_selection_action_type = Global.ActionDataType.None

func build_tree(tree_data : Dictionary):
	clear()
	var root = create_item()
	root.set_metadata(0, 0)
	#hide_root = true
	var item_dict = {}
	var index_list = [0]
	while item_dict.keys().size() != tree_data.keys().size() and index_list.size() > 0:
		for i in range(tree_data.keys().size()):
			var current_key = tree_data.keys()[i]
			if current_key in item_dict.keys():
				continue
			if tree_data[current_key][parent_id_key] == index_list[0] or \
					index_list[0] == 0 and tree_data[current_key][parent_id_key] == null:
				var current_parent_item = root
				if index_list[0] != 0:
					current_parent_item = item_dict[index_list[0]]
				item_dict[current_key] = create_item(current_parent_item)
				index_list.append(current_key)
				item_dict[current_key].set_text(0, tree_data[current_key][name_key])
				item_dict[current_key].set_metadata(0, current_key)
		index_list.remove_at(0)


func tree_value_selected(value):
	main_node.tree_value_selected(value, item_selection_action_type)


func _on_item_selected():
	tree_value_selected(get_selected().get_metadata(0))
	
