extends Control
@onready var main_node = get_tree().get_root().get_node("Main")
@export var x0_75_button : Button
@export var x1_0_button : Button
@export var x1_25_button : Button
@export var image_size_spinebox : SpinBox


func _notification(what):
	if image_size_spinebox:
		image_size_spinebox.value = Global.max_image_size


func _ready():
	Global.profiles_loaded.connect(profiles_loaded)
	update_ui_scale_buttons()


func profiles_loaded():
	var _profile_name = Global.profiles[Global.current_profile_id].name
	$SettingsPanel/ScrollContainer/VBoxContainer/ProfileName.set_location_button_text(_profile_name)


func _on_profile_name_button_pressed():
	main_node.shoe_profile_selection_dialogue()


func update_ui_scale_buttons():
	x0_75_button.disabled = Global.ui_scale_factor < 1
	x1_0_button.disabled = Global.ui_scale_factor > 0.75 and Global.ui_scale_factor < 1.2
	x1_25_button.disabled = Global.ui_scale_factor > 1.0 and Global.ui_scale_factor < 2 


func _on_uix_0_75_button_pressed() -> void:
	Global.set_ui_scale(0.75)
	update_ui_scale_buttons()

func _on_uix_1_0_button_pressed() -> void:
	Global.set_ui_scale(1.0)
	update_ui_scale_buttons()

func _on_uix_1_25_button_pressed() -> void:
	Global.set_ui_scale(1.2)
	update_ui_scale_buttons()


func _on_apply_button_pressed() -> void:
	Global.max_image_size = int(image_size_spinebox.value)
	Global.save_config()
