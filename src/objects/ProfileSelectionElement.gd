extends Panel
var profile_id = 0

var profile_selection_dialogue

func set_profile_id(_id):
	profile_id = _id
	var profile_name = Global.profile_names[profile_id]
	$TitleControl/Label.text = profile_name

func set_selected(is_selected = false):
	$Button.disabled = is_selected

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _on_button_pressed():
	if profile_selection_dialogue:
		profile_selection_dialogue.select_profile(profile_id)
