extends Control
@onready var main_node = get_tree().get_root().get_node("Main")
var current_item_tags_data = {}
@export var tags_element : Panel
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_cancel_button_pressed():
	hide()


func _on_save_item_button_pressed():
	var selected_tag_ids = []
	for tag_key in current_item_tags_data:
		selected_tag_ids.append(tag_key)

	main_node.set_fillter_tag_ids(selected_tag_ids)
	main_node.apply_filter()
	hide()


func clear_selection():
	update_tags([])
	

func update_tags(tag_ids):
	current_item_tags_data = main_node.get_tags_data_by_ids(tag_ids)
	tags_element.set_tags(current_item_tags_data)
	

func _on_tags_edit_tags_button_pressed():
	var selected_tags = []
	for t in current_item_tags_data:
		selected_tags.append(current_item_tags_data[t].id)
	main_node.select_tags_with_dialogue(self, selected_tags)


func _on_tags_clear_tags_button_pressed() -> void:
	clear_selection()
