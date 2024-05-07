extends Control
@export var name_edit : TextEdit
@export var description_edit : TextEdit
@export var location_button : Button

@onready var main_node = get_tree().get_root().get_node("Main")
var item_index = -1


func set_data(item_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	item_index = -1 
	if "id" in item_data.keys():
		item_index = item_data.id
	name_edit.text = ""
	if "name" in item_data.keys():
		name_edit.text = item_data.name
	

func _ready():
	pass # Replace with function body.


func _on_cancel_button_pressed():
	pass # Replace with function body.


func _on_save_item_button_pressed():
	pass # Replace with function body.
