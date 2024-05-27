extends Control
@export var tag_viewer : Control


func _ready():
	pass # Replace with function body.


func refrash_items_list(tag_data):
	tag_viewer.refrash_items_list(tag_data)
		


func _on_create_tag_button_pressed():
	pass # Replace with function body.
