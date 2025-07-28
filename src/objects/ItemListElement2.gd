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
		$CheckControl/CheckBox.text = new_value
@export var list_item_mode = ListItemModes.Text :
	set(new_value):
		list_item_mode = new_value
		$DataControl/Edit.visible = list_item_mode == ListItemModes.Text
		$DataControl/Button.visible = list_item_mode == ListItemModes.tButton
		$IconControl.visible = list_item_mode == ListItemModes.Icon
		$DataControl/SpinBox.visible = list_item_mode == ListItemModes.Quantity
		$DataControl/Tags.visible = list_item_mode == ListItemModes.Tags
		$TitleControl/EditTagsButton.visible = list_item_mode == ListItemModes.Tags
		$TitleControl/ClearTagsButton.visible = list_item_mode == ListItemModes.Tags and show_clear_button


@export var show_clear_button = false

@export var edit_regex_line = ""

@export var quantity_range : Vector2i 

@onready var unfold_button = get_node("TitleControl/UnfoldButton")
var unfold_control = null
var is_unfolded = false
signal location_button_pressed
signal edit_tags_button_pressed
signal image_selection_button_pressed
signal clear_tags_button_pressed
signal edit_text_changed
signal quantity_changed(new_value)

enum ListItemModes {
	Text,
	tButton,
	Icon,
	Quantity,
	Tags
}

@onready var regex = RegEx.new()

func set_editable(value):
	$DataControl/Edit.editable = value


func _ready():
	if quantity_range.x != quantity_range.y:
		$DataControl/SpinBox.min_value = quantity_range.x
		$DataControl/SpinBox.max_value = quantity_range.y
		$DataControl/SpinBox.allow_greater = false
	
	if edit_regex_line != "":
		regex.compile(edit_regex_line)
	if Engine.is_editor_hint():
		return
	list_item_mode = list_item_mode
	#$TitleControl/Label.text = title_text
	#$DataControl/Edit.placeholder_text = placeholder_text


func set_unfold_control(value):
	unfold_control = value
	unfold_button.visible = unfold_control != null
	if  list_item_mode == ListItemModes.Tags:
		unfold_button.visible = false


func set_tags(tags_data):
	$TitleControl/ClearTagsButton.disabled = tags_data.size() == 0
	$DataControl/Tags/TagViewer.refrash_tags_list(tags_data)


func set_location_button_text(_text):
	$DataControl/Button/Label.text = _text


func set_edit_text(_text):
	$DataControl/Edit.text = _text


func get_edit_text():
	return $DataControl/Edit.text


func get_unfolded():
	return is_unfolded
	

func unfold(to_unfold = true, to_force = false, immediate = false):
	if to_unfold == is_unfolded and !to_force:
		return
	if to_unfold != is_unfolded or to_force:
		if to_unfold:
			$AnimationPlayer.play("unfold")
		else:
			$AnimationPlayer.play_backwards("unfold")
	is_unfolded = to_unfold
	unfold_button.flip_v = is_unfolded


func set_quantity(quantity):
	$DataControl/SpinBox.value = quantity


func get_quantiry():
	return $DataControl/SpinBox.value


func toggle_unfold():
	if unfold_control:
		unfold_control.unfold(self, !is_unfolded)


func _on_location_button_pressed():
	location_button_pressed.emit()


func update_image(image):
	var texture = ImageTexture.create_from_image(image)
	$IconControl/P/ItemIcon.texture = texture


func _on_edit_tags_button_pressed():
	edit_tags_button_pressed.emit()


func _on_icon_button_pressed():
	image_selection_button_pressed.emit()


func _on_clear_tags_button_pressed() -> void:
	clear_tags_button_pressed.emit()



func focus_name_input():
	$DataControl/Edit.grab_focus()


func _on_edit_text_changed() -> void:
	if edit_regex_line == "":
		edit_text_changed.emit()
		return
		
	var final_text = ""

	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9 ]")

	var regex_match = regex.search_all($DataControl/Edit.text)
	if regex_match:
		for i in range(0,regex_match.size()):
			final_text += regex_match[i].get_string()
	$DataControl/Edit.text = final_text
	
	var last_line = $DataControl/Edit.get_line_count() - 1
	var last_column = $DataControl/Edit.get_line(last_line).length()
	$DataControl/Edit.set_caret_line(last_line)
	$DataControl/Edit.set_caret_column(last_column)
	edit_text_changed.emit()


func _on_spin_box_value_changed(value: float) -> void:
	quantity_changed.emit(int(value))
