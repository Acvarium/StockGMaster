extends HFlowContainer
var tag_element_prefab = preload("res://objects/TagElement.tscn")
signal tag_pressed_sig
@export var selectable_tags = true

func _ready():
	pass # Replace with function body.


func clear_tags():
	for t in get_children():
		t.queue_free()


func tag_pressed():
	tag_pressed_sig.emit()


func refrash_tags_list(tag_data, current_selected_tags = []):
	clear_tags()
	for t in tag_data:
		var new_tag = tag_element_prefab.instantiate()
		new_tag.set_text(tag_data[t].name)
		new_tag.get_button().pressed.connect(tag_pressed)
		new_tag.tag_id = t
		new_tag.set_selectable(selectable_tags)
		new_tag.set_pressed(t in current_selected_tags)
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
	
