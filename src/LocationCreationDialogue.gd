extends Control
@export var parent_button : Button
@export var title_label : Label

func _ready():
	pass # Replace with function body.


func set_parent_name(parent_name):
	parent_button.text = parent_name


