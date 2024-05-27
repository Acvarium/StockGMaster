@tool
extends Panel
@export var separator_text : String :
	set(new_value):
		separator_text = new_value
		$Panel/TitleControl/Label.text = new_value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

