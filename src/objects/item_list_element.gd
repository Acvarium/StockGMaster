extends Panel
var item_tab = null
var item_id = -1
var item_name = ""
var item_description = ""
var item_icon_name = ""
var is_unfolded = false
@onready var main_node = get_tree().get_root().get_node("Main")
@onready var unfold_wait_time = $UnfoldTimer.wait_time
var stock_line_prefab = preload("res://objects/stock_info_line.tscn")
var folded_height = 55.0
var unfolded_height = 250.0
var unfold_offset_for_stocks = 0.0
var unfold_control
const BASE_STOCK_OFFSET = 45

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
	if "stocks" in new_data.keys():
		unfold_offset_for_stocks = (new_data.stocks.size()) * BASE_STOCK_OFFSET
		for s in new_data.stocks:
			var current_stock_line = stock_line_prefab.instantiate()
			var unit_name = main_node.get_unit_name_by_id(new_data.unit_name_id)
			$StocksHolder.add_child(current_stock_line)
			current_stock_line.set_data(s, unit_name)
		self_modulate = Color.LIGHT_GRAY
	else:
		self_modulate = Color.MISTY_ROSE


func clear_stocks():
	for s in $StocksHolder.get_children():
		s.queue_free()


func unfold(to_unfold = true, to_force = false):
	if to_unfold == is_unfolded and !to_force:
		return
	if to_unfold != is_unfolded or to_force:
		set_process(true)
		$AnimationPlayer.play("unfold")
		$UnfoldTimer.start()
	is_unfolded = to_unfold
	$UnfoldButton.flip_v = is_unfolded


func _process(delta):
	var new_unfolded_height = unfolded_height + unfold_offset_for_stocks
	if !$UnfoldTimer.is_stopped():
		var time_left_normalized = $UnfoldTimer.time_left / unfold_wait_time
		if is_unfolded:
			custom_minimum_size.y = remap(time_left_normalized, 0.0, 1.0, new_unfolded_height, folded_height)
			$AnimationPlayer.seek((1.0 - time_left_normalized), true)
		else:
			custom_minimum_size.y = remap(time_left_normalized, 0.0, 1.0, folded_height, new_unfolded_height)
			$AnimationPlayer.seek(time_left_normalized, true)
	else:
		if is_unfolded:
			custom_minimum_size.y = new_unfolded_height
		else:
			custom_minimum_size.y = folded_height
		set_process(false)


func get_unfolded():
	return is_unfolded
	

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


func _on_add_stock_button_pressed():
	main_node.create_stock(item_id)
