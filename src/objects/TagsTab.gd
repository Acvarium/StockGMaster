extends Control
@export var tag_viewer : Control
@onready var main_node = get_tree().get_root().get_node("Main")
@export var edit_button : Button
@export var delete_button : Button

func _ready():
	_on_tag_viewer_tag_pressed_sig()


func refrash_tags_list(tag_data):
	tag_viewer.refrash_tags_list(tag_data)
	await get_tree().process_frame
	_on_tag_viewer_tag_pressed_sig()


func _on_create_tag_button_pressed():
	main_node.edit_tag(-1)


func _on_test_selected_tags_button_pressed():
	tag_viewer.select_all()
	#print(tag_viewer.get_selected_id())


func confirme_action(what_to_do):
	if what_to_do == Global.WhatToDo.Delete:
		var selected_tags = tag_viewer.get_selected_ids()
		if selected_tags.size() != 0:
			main_node.delete_tags(selected_tags)
	await get_tree().process_frame
	_on_tag_viewer_tag_pressed_sig()
	

func _on_delete_selected_tags_button_pressed():
	var number_of_items = \
		main_node.get_number_of_items_with_tags(tag_viewer.get_selected_ids())
	var mess = ""
	if number_of_items > 0:
		mess = str(number_of_items) +  " items use tags that will be removed"
	main_node.confirme_action_dialogue(self, Global.WhatToDo.Delete, mess)


func _on_edit_tags_button_pressed():
	var selecred_ids = tag_viewer.get_selected_ids()
	if selecred_ids.size() == 1:
		main_node.edit_tag(selecred_ids[0])


func _on_tag_viewer_tag_pressed_sig():
	var selected_ids = tag_viewer.get_selected_ids().size()
	edit_button.disabled = selected_ids != 1
	delete_button.disabled = selected_ids == 0
