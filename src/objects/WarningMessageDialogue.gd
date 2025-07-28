extends Control
@export var title_label : Label
@export var message_label : Label


func _ready() -> void:
	hide()
	Global.warning_message.connect(warning_message)


func warning_message(title, message):
	title_label.text = title
	message_label.text = message
	show()


func _on_bg_button_pressed() -> void:
	hide()


func _on_confirm_button_pressed() -> void:
	hide()
 
