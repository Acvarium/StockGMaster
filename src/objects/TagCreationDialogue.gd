extends Control
@onready var main_node = get_tree().get_root().get_node("Main")
@export var name_list_item : Panel
var current_data

func _ready():
	reset_and_hide


func set_data(_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_data = _data.duplicate()
	name_list_item.set_edit_text("")
	if "name" in _data.keys() and _data.name:
		name_list_item.set_edit_text(_data.name)


func _show():
	show()
	
	
func reset_and_hide():
	_reset()
	hide()


func _reset():
	name_list_item.set_edit_text("")
	current_data = {}


func _on_cancel_button_pressed():
	reset_and_hide()


func _on_save_item_button_pressed():
	if !current_data:
		current_data = {}
	current_data.name = name_list_item.get_edit_text()

	if main_node.tag_exists(current_data.name):
		main_node.warning_dialogue("A tag with this name already exists", "Tag exists!")
	else:
		main_node.save_tag(current_data)
		reset_and_hide()
		
