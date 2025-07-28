extends Panel
var profile_id = 0
var profile_selection_dialogue
var is_editable = true
var profile = {}
@onready var main_node = get_tree().get_root().get_node("Main")


func set_editable(value = true):
	is_editable = value
	$TitleControl/EditButton.disabled = !is_editable


func select_profile_element(to_select : bool):
	$Button.disabled = to_select


func set_profile(_id, _profile):
	profile_id = _id
	profile = _profile
	set_editable(profile.editable)
	var mark = ""
	if profile_id == Global.current_profile_id:
		mark = "* "
	$TitleControl/Label.text = mark + profile.name


func set_selected(is_selected = false):
	$Button.disabled = is_selected


func _ready():
	pass # Replace with function body.


func _on_button_pressed():
	if profile_selection_dialogue:
		profile_selection_dialogue.select_profile(profile_id)


func _on_edit_button_pressed() -> void:
	main_node.edit_profile(profile_id)
