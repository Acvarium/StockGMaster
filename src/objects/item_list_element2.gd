@tool
extends Panel
@export var title_text = "" :
	set(new_value):
		title_text = new_value
		$TitleControl/Label.text = new_value
		
@export var placeholder_text = "" :
	set(new_value):
		placeholder_text = new_value
		$DataControl/Edit.placeholder_text = new_value

@export var list_item_mode = ListItemModes.Text :
	set(new_value):
		list_item_mode = new_value
		$DataControl/Edit.visible = list_item_mode == ListItemModes.Text
		$DataControl/Button.visible = list_item_mode == ListItemModes.tButton
		$IconControl.visible = list_item_mode == ListItemModes.Icon
		$DataControl/SpinBox.visible = list_item_mode == ListItemModes.Quantity

@onready var unfold_button = get_node("TitleControl/UnfoldButton")
var unfold_control = null
var is_unfolded = false
signal location_button_pressed

enum ListItemModes {
	Text,
	tButton,
	Icon,
	Quantity
}

func _ready():
	if Engine.is_editor_hint():
		return
	#$TitleControl/Label.text = title_text
	#$DataControl/Edit.placeholder_text = placeholder_text


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


func unfold(to_unfold = true):
	if to_unfold == is_unfolded:
		return
	if to_unfold != is_unfolded:
		if to_unfold:
			$AnimationPlayer.play("unfold")
		else:
			$AnimationPlayer.play_backwards("unfold")
	is_unfolded = to_unfold
	unfold_button.flip_v = is_unfolded


func toggle_unfold():
	if unfold_control:
		unfold_control.unfold(self, !is_unfolded)


func _on_location_button_pressed():
	location_button_pressed.emit()
