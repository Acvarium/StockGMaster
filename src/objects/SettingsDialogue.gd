extends Control
@onready var main_node = get_tree().get_root().get_node("Main")

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _on_profile_name_button_pressed():
	main_node.shoe_profile_selection_dialogue()
