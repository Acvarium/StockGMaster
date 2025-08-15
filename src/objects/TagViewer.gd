extends HFlowContainer
var tag_element_prefab = preload("res://objects/TagElement.tscn")
var att_element_prefab = preload("res://objects/AttachmentElement.tscn")

signal tag_pressed_sig
@export var selectable_tags = true


func clear_tags():
	for t in get_children():
		t.queue_free()


func tag_pressed():
	tag_pressed_sig.emit()


func refrash_tags_list(_data, current_selected_tags = [], tag_colors = {}):
	clear_tags()
	if _data == null:
		return
	if _data is Array:
		for a in _data:
			var new_att = att_element_prefab.instantiate()
			new_att.set_file_path(a.path)
			add_child(new_att)
			new_att.set_selectable(selectable_tags)
			new_att.tag_id = a.id
			if a.id < 0:
				new_att.set_color(Color.DARK_SEA_GREEN)
			if "delete" in a.keys() and a.delete == true:
				new_att.set_color(Color(0.4, 0.352, 0.352))
			if a.id in tag_colors.keys():
				new_att.set_color(tag_colors[a.id])
			new_att.get_button().pressed.connect(tag_pressed)
	else:
		for t in _data:
			var new_tag = tag_element_prefab.instantiate()
			new_tag.set_text(_data[t].name)
			new_tag.get_button().pressed.connect(tag_pressed)
			new_tag.tag_id = t
			new_tag.set_selectable(selectable_tags)
			new_tag.set_pressed(t in current_selected_tags)
			if t in tag_colors.keys():
				new_tag.set_color(tag_colors[t])
			add_child(new_tag)


func get_selected_ids():
	var selected_ids = []
	for t in get_children():
		if t.has_method("get_pressed") and t.get_pressed():
			selected_ids.append(t.tag_id)
	return(selected_ids)


func select_all(to_select = true):
	for t in get_children():
		if t.has_method("set_pressed"):
			t.set_pressed(to_select)
	tag_pressed_sig.emit()
	
