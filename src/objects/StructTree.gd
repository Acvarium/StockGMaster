extends Tree

@export var parent_id_key = "parent_id"
@export var name_key = "name"
@onready var main_node = get_tree().get_root().get_node("Main")
var item_selection_action_type = Global.ActionDataType.None
@export var tree_selection_dialogue : Control
@export var has_edit_buttons = false
var a_texture: Texture = preload("res://textures/edit_button_sm.png")
var item_dict = {}

func get_active_id():
	var active = get_selected()
	if active:
		return active.get_metadata(0)
	return -1


func build_tree(tree_data : Dictionary, item_id = -1, extra_line_data = {}):
	clear()
	var root = create_item()
	root.set_metadata(0, 0)
	#hide_root = true
	item_dict.clear()
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
				var item_text = tree_data[current_key][name_key]
				if (current_key in extra_line_data.keys()):
					item_text += " [" + extra_line_data[current_key] + "]"
				item_dict[current_key].set_text(0, item_text)
				item_dict[current_key].set_metadata(0, current_key)
				if current_key == item_id:
					item_dict[current_key].visible = false
				if has_edit_buttons:
					item_dict[current_key].add_button(0, a_texture, current_key)
		index_list.remove_at(0)


func show_selection(selection_ids):
	var search_count = 0
	if selection_ids == null:
		for key in item_dict:
			item_dict[key].visible = true
		return 0
	
	var items_to_show = []
	for key in item_dict:
		item_dict[key].visible = false
		if selection_ids.has(key):
			search_count += 1
			items_to_show.append(item_dict[key])
			var current_item : TreeItem = item_dict[key]
			while current_item != null:
				current_item = current_item.get_parent()
				if current_item and not items_to_show.has(current_item):
					items_to_show.append(current_item)
			
	for item in items_to_show:
		item.visible = true
	return search_count


func tree_value_selected(value):
	if tree_selection_dialogue:
		tree_selection_dialogue.tree_value_selected(value, item_selection_action_type)
	else:
		main_node.tree_value_selected(value, item_selection_action_type)


func _on_item_selected():
	tree_value_selected(get_selected().get_metadata(0))
	
