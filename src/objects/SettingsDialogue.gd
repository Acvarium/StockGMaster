extends Control
@onready var main_node = get_tree().get_root().get_node("Main")
@export var x0_5_button : Button
@export var x1_0_button : Button
@export var x1_5_button : Button
@export var x2_0_button : Button

func _ready():
	update_ui_scale_buttons()


func _on_profile_name_button_pressed():
	main_node.shoe_profile_selection_dialogue()


func update_ui_scale_buttons():
	pass
	#x0_5_button.disabled = Global.ui_scale_factor < 1
	#x1_0_button.disabled = Global.ui_scale_factor > 0.5 and Global.ui_scale_factor < 1.5
	#x1_5_button.disabled = Global.ui_scale_factor > 1.0 and Global.ui_scale_factor < 2 
	#x2_0_button.disabled = Global.ui_scale_factor > 1.5
	

func _on_uix_0_5_button_pressed() -> void:
	Global.set_ui_scale(0.75)
	update_ui_scale_buttons()

func _on_uix_1_button_pressed() -> void:
	Global.set_ui_scale(1.0)
	update_ui_scale_buttons()

func _on_uix_1_5_button_pressed() -> void:
	Global.set_ui_scale(1.2)
	update_ui_scale_buttons()

func _on_uix_2_button_pressed() -> void:
	Global.set_ui_scale(2.0)
	update_ui_scale_buttons()
