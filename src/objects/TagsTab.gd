extends Control
@export var tag_viewer : Control
@onready var main_node = get_tree().get_root().get_node("Main")
@export var edit_button : Button

func _ready():
	pass # Replace with function body.


func refrash_items_list(tag_data):
	tag_viewer.refrash_items_list(tag_data)


func _on_create_tag_button_pressed():
	main_node.edit_tag(-1)


func _on_test_selected_tags_button_pressed():
	tag_viewer.select_all()
	#print(tag_viewer.get_selected_id())


func _on_delete_selected_tags_button_pressed():
	var selected_tags = tag_viewer.get_selected_ids()
	if selected_tags.size() != 0:
		#TODO warning message with number of items with tags to delete
		main_node.delete_tags(selected_tags)


func _on_edit_tags_button_pressed():
	var selecred_ids = tag_viewer.get_selected_ids()
	if selecred_ids.size() == 1:
		main_node.edit_tag(selecred_ids[0])


func _on_tag_viewer_tag_pressed_sig():
	edit_button.disabled = tag_viewer.get_selected_ids().size() != 1
