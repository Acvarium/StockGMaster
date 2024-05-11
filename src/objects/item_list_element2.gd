extends Panel
@export var title_text = ""
@export var placeholder_text = ""

@onready var unfold_button = get_node("TitleControl/UnfoldButton")
var unfold_control = null
var is_unfolded = false
signal location_button_pressed

enum ListItemModes {
	Text,
	tButton,
	Icon
}
@export var list_item_mode = ListItemModes.Text

func _ready():
	$TitleControl/Label.text = title_text
	$DataControl/Edit.placeholder_text = placeholder_text
	$DataControl/Edit.visible = list_item_mode == ListItemModes.Text
	$DataControl/Button.visible = list_item_mode == ListItemModes.tButton
	$IconControl.visible = list_item_mode == ListItemModes.Icon


func unfold(to_unfold = true):
	if to_unfold == is_unfolded:
		return
	if to_unfold:
		pass
	else:
		pass
	if to_unfold != is_unfolded:
		if to_unfold:
			$AnimationPlayer.play("unfold")
		else:
			$AnimationPlayer.play_backwards("unfold")
	is_unfolded = to_unfold
	unfold_button.flip_v = is_unfolded


func set_unfold_control(value):
	unfold_control = value
	print(name + "  " + str(unfold_control != null))
	unfold_button.visible = unfold_control != null


func set_location_button_text(_text):
	$DataControl/Button/Label.text = _text


func set_edit_text(_text):
	$DataControl/Edit.text = _text


func get_edit_text():
	return $DataControl/Edit.text


func toggle_unfold():
	if unfold_control:
		unfold_control.unfold(self, !is_unfolded)


func _on_location_button_pressed():
	location_button_pressed.emit()
