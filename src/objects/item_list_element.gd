extends Panel
var item_tab = null
var item_id = -1
var item_name = ""
var item_description = ""
var item_icon_name = ""
var is_unfolded = false
@onready var main_node = get_tree().get_root().get_node("Main")
@onready var unfold_wait_time = $UnfoldTimer.wait_time

var folded_height = 55.0
var unfolded_height = 250.0
var unfold_control


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
	if "location_id" in new_data.keys() and new_data.location_id != null:
		var location_addr = main_node.get_location_address(new_data.location_id)
		if location_addr:
			$LPanel/LocationAddr.text = location_addr
			$LPanel/LocationAddr.tooltip_text = location_addr
			$ItemName.tooltip_text = location_addr
	$IPanel/ItemIcon.visible = image_loaded
	$IPanel.self_modulate.a = 1.0 if image_loaded else 0.5


func unfold(to_unfold = true):
	if to_unfold == is_unfolded:
		return
	if to_unfold != is_unfolded:
		set_process(true)
		$AnimationPlayer.play("unfold")
		
		$UnfoldTimer.start()
		#if to_unfold:
			#$AnimationPlayer.play("unfold")
		#else:
			#$AnimationPlayer.play_backwards("unfold")
	is_unfolded = to_unfold
	$UnfoldButton.flip_v = is_unfolded


func _process(delta):
	AnimationPlayer
	if !$UnfoldTimer.is_stopped():
		var time_left_normalized = $UnfoldTimer.time_left / unfold_wait_time
		var new_unfolded_height = unfolded_height
		if is_unfolded:
			custom_minimum_size.y = remap(time_left_normalized, 0.0, 1.0, new_unfolded_height, folded_height)
			$AnimationPlayer.seek((1.0 - time_left_normalized), true)
		else:
			custom_minimum_size.y = remap(time_left_normalized, 0.0, 1.0, folded_height, new_unfolded_height)
			$AnimationPlayer.seek(time_left_normalized, true)
			
	else:
		set_process(false)


func toggle_unfold():
	if unfold_control:
		unfold_control.unfold(self, !is_unfolded)


func _ready():
	unfold_control = get_parent()
	set_process(false)


func _on_unfold_button_pressed():
	toggle_unfold()


func _on_change_location_button_pressed():
	main_node.exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Location, item_id)


func _on_edit_button_pressed():
	main_node.edit_item(item_id)

