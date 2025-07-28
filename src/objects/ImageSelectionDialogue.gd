extends Control
var image_holder_prefab = preload("res://objects/ImagePreviewHolder.tscn")
@onready var image_grid : GridContainer = $ItemsPanel/ScrollContainer/ImageGridContainer
@onready var delete_button : Button = $SDCButtons/HBoxContainer/DeleteButton
@onready var main_node = get_tree().get_root().get_node("Main")
var current_reciver_dialogue = null


func clear_images():
	for image_prev in image_grid.get_children():
		image_prev.queue_free()
	deselect_all()
	update_none_image_active_mark()
	update_delete_button()
	

func load_images(image_paths, image_to_select = ""):
	clear_images()
	var image_holder_to_select
	for im in [""] + image_paths:
		var new_image_holder = image_holder_prefab.instantiate()
		image_grid.add_child(new_image_holder)
		new_image_holder.set_image_path(im)
		new_image_holder.load_image(main_node.get_image_by_path(im))
		if im == "":
			new_image_holder.is_none_image = true
			new_image_holder.activate(true)
		new_image_holder.image_selection_dialogue = self
		if image_to_select == im:
			image_holder_to_select = new_image_holder
	update_delete_button()
	if image_holder_to_select != null:
		select_image(image_holder_to_select)


func delete_selected_images():
	var message = ""
	var selected_images = get_list_of_selected()
	var number_of_items_with_image = main_node.get_number_of_items_with_images(selected_images)
	if number_of_items_with_image == 1:
		message = str(number_of_items_with_image) + " item uses this image."
	elif number_of_items_with_image > 1:
		message = str(number_of_items_with_image) + " items use this image."
	Global.action_dialogue.emit(self, Global.WhatToDo.Delete, message)


func update_delete_button():
	delete_button.disabled = get_list_of_selected().size() == 0


func confirme_action(what_to_do = Global.WhatToDo.Delete):
	main_node.delete_images(get_list_of_selected())
	update_none_image_active_mark()
	update_delete_button()


func _show():
	visible = true
	deselect_all()
	update_delete_button()
	if current_reciver_dialogue != null and \
			current_reciver_dialogue.has_method("get_current_item_image_path"):
		var image_path_to_select : String = current_reciver_dialogue.get_current_item_image_path()
		if !image_path_to_select.is_empty():
			select_image_by_path(image_path_to_select)
			

func select_image_by_path(image_path):
	await get_tree().create_timer(0.02).timeout

	for image_prev in image_grid.get_children():
		var current_image_path = image_prev.current_image_path
		if image_path == current_image_path:
			select_image(image_prev)
			return


func deselect_all():
	for image_prev in image_grid.get_children():
		image_prev.select(false)
	update_none_image_active_mark()


func set_receiver_dialogue(reciver):
	current_reciver_dialogue = reciver


func select_image(image_item_to_select, multi_select = false):
	for image_prev in image_grid.get_children():
		if multi_select:
			if image_item_to_select == image_prev:
				image_prev.select(!image_prev.is_selected)
		else:
			if image_item_to_select == image_prev:
				image_prev.select(!image_prev.is_selected)
			else:
				image_prev.select(image_item_to_select == image_prev)
		image_prev.activate(image_item_to_select == image_prev)
		if not image_prev.is_selected:
			image_prev.activate(false)
	update_none_image_active_mark()
	update_delete_button()


func update_none_image_active_mark():
	var has_active = false
	for image_prev in image_grid.get_children():
		if not image_prev.is_none_image and image_prev.is_active:
			has_active = true
			break
	image_grid.get_child(0).activate(not has_active)


func get_active_image_path():
	for image_prev in image_grid.get_children():
		if image_prev.is_active:
			return image_prev.current_image_path
	return ""


func get_list_of_selected():
	var selected_items = []
	for image_prev in image_grid.get_children():
		if image_prev.is_selected and not image_prev.is_none_image:
			selected_items.append(image_prev.current_image_path)
	return selected_items
	

func _ready() -> void:
	pass


func _on_save_button_pressed():
	var current_image_path = get_active_image_path()
	if current_reciver_dialogue == null:
		_on_cancel_button_pressed()
	else:
		current_reciver_dialogue.set_image_path(current_image_path)
		_on_cancel_button_pressed()
	current_reciver_dialogue = null
	

func _on_cancel_button_pressed():
	current_reciver_dialogue = null
	visible = false


func _on_delete_button_pressed():
	delete_selected_images()
