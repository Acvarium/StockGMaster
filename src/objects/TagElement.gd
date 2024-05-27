extends PanelContainer
var tag_id = -1

func _ready():
	pass

func get_button():
	return $Button

func set_text(text):
	$HB/Label.text = text


func get_pressed():
	return $Button.button_pressed


func set_pressed(value):
	$Button.button_pressed = value
