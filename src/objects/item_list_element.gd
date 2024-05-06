extends Panel
var item_tab = null
var item_id = -1
var item_name = ""
var item_description = ""
var item_icon_name = ""
var is_unfolded = false


@onready var main_node = get_tree().get_root().get_node("Main")


func set_data(new_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	if "id" in new_data.keys():
		item_id = new_data.id
	if "name" in new_data.keys():
		item_name = new_data.name
		$ItemName.text = item_name
	if "description" in new_data.keys() and new_data.description != null:
		item_description = new_data.description
		$DPanel/ItemDescription.text = item_description
	else:
		$DPanel/ItemDescription.text = ""
		
	var image_loaded = false
	if "image_id" in new_data.keys() and new_data.image_id != null:
		var image = main_node.get_image_by_id(new_data.image_id)
		$IPanel/ItemIcon.texture = ImageTexture.create_from_image(image)
		image_loaded = true
		
	$IPanel/ItemIcon.visible = image_loaded
	$IPanel.self_modulate.a = 1.0 if image_loaded else 0.5
		

func unfold(to_unfold = true):
	if is_unfolded == to_unfold:
		return
	is_unfolded = to_unfold
	if to_unfold:
		if item_tab:
			item_tab.fold_all_but_one(self)
		$AnimationPlayer.play("unfold")
	else:
		$AnimationPlayer.play_backwards("unfold")


func toggle_unfold():
	unfold(!is_unfolded)


func _ready():
	pass # Replace with function body.


func _on_unfold_button_pressed():
	toggle_unfold()
