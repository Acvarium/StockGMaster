extends Control
@export var tag_viewer : Control
var data_recever_dialogue = null
@onready var main_node = get_tree().get_root().get_node("Main")
var action_recever

func _ready():
	pass # Replace with function body.


func select_tags_with_dialogue(recover, selected_tags = []):
	var all_tags_data = main_node.get_all_tags_data()
	action_recever = recover
	tag_viewer.refrash_tags_list(all_tags_data, selected_tags)


func _on_tag_viewer_tag_pressed_sig():
	pass # Replace with function body.


func _on_confirm_button_pressed():
	var tags_selected = tag_viewer.get_selected_ids()
	if action_recever:
		action_recever.update_tags(tags_selected)
	hide()


func _on_cancel_button_pressed():
	hide()
