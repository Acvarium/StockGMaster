extends Control
#@export var tree_element : Tree
@export var locations_tab_tree : Tree
@export var category_tab_tree : Tree
@export var tag_tab : Control 
@export var tag_selection_viewer : Control
@export var image_grid : GridContainer
@onready var tab_control : TabContainer = $MainControl/HSplit/MainInfo/TabContainer
@onready var items_tab : Control = $MainControl/HSplit/MainInfo/TabContainer/Items
@onready var item_creation_dialogue : Control = $ItemCreationDialogue
@onready var location_creation_dialogue : Control = $LocationCreationDialogue
@onready var profile_creation_dialogue : Control = $ProfileCreationDialogue
@onready var tag_creation_dialogue : Control = $TagCreationDialogue
@onready var tree_selection_dialogue : Control = $TreeSelectionDialogue
@onready var action_confirm_dialogue : Control = $ActionConfirmDialogue
@onready var location_selection_tree : Tree = $MainControl/HSplit/MainInfo/TabContainer/Locations/LocationStructTree
@onready var search_line_edit : LineEdit = $MainControl/HSplit/MainInfo/SearchLine/SearchLineEdit
@onready var side_info : Control = $MainControl/HSplit/SideInfo
@export var clear_filter_button : TextureButton

var selected_value : int = -1
var tree_selection_index : int = -1
const SIDE_PANEL_OFFSET = 42

@onready var current_what_to_do = Global.WhatToDo.None
@onready var current_action_data_type = Global.ActionDataType.None
#var current_action_id = -1
var grid_image_size = 150
const MIN_SPLIT_SIZE = 150
var filter_tag_ids = []
var h_split_dragged = false

enum ScreenOrientation {
	NONE,
	VERTICAL,
	HORIZONTAL
}
var last_screen_orientation = ScreenOrientation.NONE


func get_search_text():
	return search_line_edit.text


func _ready():
	$CanvasLayer.visible = true
	randomize()
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	if Global.is_on_mobule():
		$FileDialog.root_subfolder = "/storage/emulated/0"
	$MainControl/HSplit/MainInfo/TabContainer.current_tab = 0
	load_images_to_viewer()
	OS.request_permissions()


func load_images_to_viewer(image_to_select = ""):
	var image_paths = $Database.get_image_paths()
	$ImageSelectionDialogue.load_images(image_paths, image_to_select)


func _on_viewport_resize():
	Global.get_scaled_safe_area()
	if Global.is_on_mobule():
		var offset_rect = Global.get_scaled_safe_area()
		offset_left = offset_rect.position.x
		offset_top = offset_rect.position.y
		offset_right = -offset_rect.size.x
		offset_bottom = -offset_rect.size.y
		
	Global.update_ui_scale()
	$Timers/SideInfoPanelTimer.start()
	var side_info_visible = $MainControl/HSplit/SideInfo.visible
	unfold_side_split(side_info_visible)
	image_grid.columns = image_grid.get_parent().size.x / grid_image_size
	

#забрати--------------------------------------
func is_item_passes_filter(item_id):
	if filter_tag_ids and filter_tag_ids.size() > 0:
		var has_selected_tags = false
		var tag_ids_for_item = $Database.get_tag_ids_for_item(item_id)
		for t in tag_ids_for_item:
			if t in filter_tag_ids:
				has_selected_tags = true
				break
		return has_selected_tags
		#for t in $Database.get_tags_for_item(item_id)
	return true


func set_fillter_tag_ids(values):
	filter_tag_ids = values.duplicate(true)


func get_filter_tag_ids():
	return filter_tag_ids


func get_number_of_items_in_location(location_id):
	return $Database.get_number_of_items_in_location(location_id)


func get_number_of_items_with_images(list_of_image_paths):
	return $Database.get_number_of_items_with_images(list_of_image_paths)


func delete_images(list_of_image_paths):
	$Database.delete_images(list_of_image_paths)
	$Database.pull_items_data()
	load_images_to_viewer()


func get_number_of_items_with_category(category_id):
	return $Database.get_number_of_items_with_category(category_id)
	

func delete_location(location_id):
	var location_parent_id = 0
	if location_id in $Database.locations_data.keys():
		if "parent_id" in $Database.locations_data[location_id]:
			location_parent_id = $Database.locations_data[location_id]["parent_id"]
		$Database.move_all_stocks_from_loc_to(location_id, location_parent_id)
		$Database.move_all_locations_from_parent_up(location_id)
		$Database.delete_location(location_id)
		$Database.pull_items_data()
		$Database.pull_locations_data()


func search_items_with_text(search_text):
	var filtered_data = get_filtered_item_data()
	if search_text.is_empty():
		return null
	var found_item_ids = {}
	var search_text_split = search_text.to_lower().split(" ")
	for i in filtered_data:
		var current_item_data = filtered_data[i]
		var item_name = current_item_data.name
		var item_descr = "" 
		if "description" in current_item_data and current_item_data.description:
			item_descr = current_item_data.description
		var current_text = (item_name + item_descr).to_lower()
		if does_text_contain_words(search_text_split, current_text):
			found_item_ids[i] = filtered_data[i]
	return found_item_ids


func search_tree_data_with_text(search_text : String, tree_data : Dictionary):
	if search_text.is_empty():
		return null
	var found_ids = []
	var search_text_split = search_text.to_lower().split(" ")
	for i in tree_data:
		var current_data = tree_data[i]
		var data_name = current_data.name
		var data_descr = ""
		if "description" in current_data and current_data.description:
			data_descr = current_data.description
		var current_text = (data_name + data_descr).to_lower()
		if does_text_contain_words(search_text_split, current_text):
			found_ids.append(i)
	return found_ids


func does_text_contain_words(words, text):
	for word in words:
		if word.is_empty():
			continue
		if not word in text:
			return false
	return true
	
	
func delete_category(category_id):
	var cat_parent_id = 0
	if category_id in $Database.categories_data.keys():
		if "parent_id" in $Database.categories_data[category_id]:
			cat_parent_id = $Database.categories_data[category_id]["parent_id"]
		$Database.move_all_items_from_cat_to(category_id, cat_parent_id)
		$Database.move_all_categories_from_parent_up(category_id)
		$Database.delete_category(category_id)
		$Database.pull_items_data()
		$Database.pull_categories_data()


func tag_exists(tag_name):
	tag_name = tag_name.to_lower()
	for t in $Database.tags_data:
		if "name" in $Database.tags_data[t] and $Database.tags_data[t].name == tag_name:
			return true
	return false


func get_number_of_items_with_tags(tag_ids):
	return $Database.get_number_of_items_with_tags(tag_ids)


func warning_dialogue(warning_message, title : String = ""):
	action_confirm_dialogue.warning_dialogue(warning_message, title)
	

func get_image_by_path(image_path):
	
	if image_path != "":
		var full_path = get_image_folder_path(image_path)
		if FileAccess.file_exists(full_path):
			return Image.load_from_file(full_path)

	return load("res://textures/NoImage.jpg")


func get_image_folder_path(path):
	if path != "":
		return $Database.get_image_folder_path() + path
	else:
		#if OS.get_name() == "Android":
			#return "res://textures/NoImage.jpg"
		return ""
	
	
func hide_tree_selector():
	tree_selection_dialogue.visible = false


func get_location_address(location_id):
	return $Database.build_location_address(location_id)


func get_category_address(category_id):
	return $Database.build_category_address(category_id)


func get_location_name_by_id(location_id):
	return $Database.get_location_name_by_id(location_id)


func get_unit_name_by_id(_id):
	if _id == null:
		return ""
	return $Database.get_unit_name_by_id(_id)

#what_to_do can be global.WhatToDo.Change, Delete or create 
#action_data_type can be global.ActionDataType.Location, Category, Tag
func exec_action_popup(what_to_do, action_data_type, for_dialogue = null, item_id = -1):
	if action_data_type == Global.ActionDataType.Location or \
			action_data_type == Global.ActionDataType.ParentLocation:
		tree_selection_dialogue.set_tree_element_item_selection_action_type(action_data_type)
		
		tree_selection_dialogue.build_tree($Database.locations_data, item_id)
		tree_selection_dialogue.data_recever_dialogue = for_dialogue
		tree_selection_dialogue.item_id = item_id
		tree_selection_dialogue._show()
	if action_data_type == Global.ActionDataType.Category or \
			action_data_type == Global.ActionDataType.ParentCategory:
		tree_selection_dialogue.set_tree_element_item_selection_action_type(action_data_type)
		tree_selection_dialogue.build_tree($Database.categories_data, item_id)
		tree_selection_dialogue.data_recever_dialogue = for_dialogue
		tree_selection_dialogue.item_id = item_id
		tree_selection_dialogue._show()
	if action_data_type == Global.ActionDataType.Image:
		load_images_to_viewer()
		$ImageSelectionDialogue.set_receiver_dialogue(for_dialogue)
		$ImageSelectionDialogue._show()


func save_item_tags(item_index, current_tag_ids):
	$Database.save_item_tags(item_index, current_tag_ids)


func save_item_image_path(item_index, item_image_path):
	$Database.save_item_image_path(item_index, item_image_path)
	refresh_items_list()
	

func get_tags_data_by_ids(tag_ids):
	var current_tags_data = {}
	for t in tag_ids:
		if t in $Database.tags_data:
			current_tags_data[t] = $Database.tags_data[t]
	return current_tags_data


func get_all_tags_data():
	return $Database.tags_data


func select_tags_with_dialogue(recever, selected_tags = []):
	$TagSelectionDialogue.select_tags_with_dialogue(recever, selected_tags)
	$TagSelectionDialogue.show()


#func image_selected(selected_image_path, selected_item_id, selected_action_type):
	#pass


func edit_item(item_id):
	remove_ui_focus()
	if item_id in $Database.items_data.keys() and item_id > 0:
		item_creation_dialogue.set_item_data($Database.items_data[item_id])
		item_creation_dialogue._reset(true, false)
		item_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Item)
	else:
		item_creation_dialogue.set_item_data({})
		item_creation_dialogue._reset()
		item_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Item)


func edit_stock(stock_data):
	item_creation_dialogue.set_stock_data($Database.items_data[stock_data.item_id], stock_data)
	item_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Stock)


func create_stock(item_id):
	item_creation_dialogue.set_item_data($Database.items_data[item_id])
	item_creation_dialogue._reset(true, false)
	item_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Stock)


#func tree_value_selected(value, action_data_type):
	#if action_data_type == Global.ActionDataType.ParentLocation:
		#hide_tree_selector()
		#selected_value = value
		#if current_what_to_do == Global.WhatToDo.Change:
			#if current_action_data_type == Global.ActionDataType.Location:
				#$Database.update_value(Global.ActionDataType.Location, current_action_id, value)
				#$Database.pull_items_data()
				#if item_creation_dialogue.visible:
					#item_creation_dialogue.update_location_text(get_location_address(selected_value))
			#elif current_action_data_type == Global.ActionDataType.ParentLocation:
				#var parent_name = $Database.get_location_name_by_id(selected_value)
				#location_creation_dialogue.set_parent_name(parent_name)


func delete_item(item_index):
	if item_index in $Database.items_data.keys():
		$Database.delete_item(item_index)
		$Database.pull_items_data()


func delete_stock(stock_id):
	$Database.delete_stock(stock_id)
	$Database.pull_items_data()


func delete_tags(tag_ids):
	$Database.delete_tags(tag_ids)
	$Database.pull_tags_data()


func save_item(item_data, to_pull = true):
	$Database.save_item(item_data)
	if to_pull:
		$Database.pull_items_data()
	return $Database.get_new_item_id()


func save_tag(tag_data, to_pull = true):
	$Database.save_tag(tag_data)
	if to_pull:
		$Database.pull_tags_data()
	return $Database.get_new_tag_id()


func save_stock(stock_data, to_pull = true):
	$Database.save_stock(stock_data)
	if to_pull:
		$Database.pull_items_data()
	

func save_location(location_data):
	$Database.save_location(location_data)
	$Database.pull_locations_data()


func save_category(category_data):
	$Database.save_category(category_data)
	$Database.pull_categories_data()


func _on_parent_selection_button_pressed():
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentLocation, -1)
	#show_tree_selector_dialogue(Global.TreeSelection.ParentLocation)


func get_filtered_item_data():
	var _items = $Database.items_data
	var to_filter = false
	if filter_tag_ids and filter_tag_ids.size() > 0:
		to_filter = true
	clear_filter_button.visible = to_filter
	if to_filter:
		_items = $Database.get_filtered_items(filter_tag_ids)
	
	return _items


func refresh_items_list():
	var is_filter_on = false
	if filter_tag_ids and filter_tag_ids.size() > 0:
		is_filter_on = true
	clear_filter_button.visible = is_filter_on
		
	if !items_tab:
		items_tab = $MainControl/HSplit/MainInfo/TabContainer/Items
	items_tab.refrash_item_data_list(get_filtered_item_data())
	#items_tab.refresh_items_list(get_filtered_item_data())


func _on_database_item_data_loaded():
	refresh_items_list()
	print("item data loaded")


func _on_create_item_button_pressed():
	edit_item(-1)


func _on_database_locations_data_loaded():
	var current_location_data = $Database.locations_data
	var location_extra_data = {}
	for key in current_location_data.keys():
		var items_in_location = get_number_of_items_in_location(key)
		if items_in_location > 0:
			location_extra_data[key] = str(items_in_location)
	locations_tab_tree.build_tree(current_location_data, -1, location_extra_data)


func _on_database_categories_data_loaded():
	var current_cat_data = $Database.categories_data
	var current_extra_data = {}
	for key in current_cat_data.keys():
		var items_in_cat = get_number_of_items_with_category(key)
		if items_in_cat > 0:
			current_extra_data[key] = str(items_in_cat)
	category_tab_tree.build_tree(current_cat_data, -1, current_extra_data)


func select_location_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Location, for_dialogue, item_id)


func select_category_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Category, for_dialogue, item_id)


func select_parent_location_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentLocation, for_dialogue, item_id)


func select_parent_category_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.ParentCategory, for_dialogue, item_id)


func select_image_popup(for_dialogue, item_id = -1):
	exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Image, for_dialogue, item_id)


func edit_location(location_id):
	remove_ui_focus()
	if location_id in $Database.locations_data.keys() and location_id > 0:
		#editing
		location_creation_dialogue.set_data($Database.locations_data[location_id])
		location_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Location)
	else:
		#creating
		location_creation_dialogue.set_data({})
		location_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Location)


func create_location_from_selected():
	remove_ui_focus()
	var active_id = location_selection_tree.get_active_id()
	if active_id >= 0:
		create_location_from(active_id)
	else:
		edit_location(-1)


func edit_profile(profile_id):
	remove_ui_focus()
	if profile_id >= 0 and profile_id < Global.profiles.size():
		#editing
		var profile_data = {}
		profile_data.id = profile_id
		profile_data.name = Global.profiles[profile_id].name
		profile_data.path = Global.profiles[profile_id].path
		profile_creation_dialogue.set_data(profile_data)
		profile_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Profile)
	else:
		#creating
		profile_creation_dialogue.set_data({})
		profile_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Profile)


func create_profile():
	edit_profile(-1)
	

func create_item_from(selected_item_id):
	remove_ui_focus()
	if selected_item_id in $Database.items_data.keys() and selected_item_id >= 0:
		var _data = $Database.items_data[selected_item_id]
		_data.erase("id")
		item_creation_dialogue.set_item_data(_data)
		item_creation_dialogue.set_item_tags(get_tags_for_item(selected_item_id))
		item_creation_dialogue._reset_quantity()
		item_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Item)


func create_location_from(selected_location_id):
	remove_ui_focus()
	if selected_location_id in $Database.locations_data.keys() and selected_location_id >= 0:
		var _data = $Database.locations_data[selected_location_id]
		_data.erase("id")
		location_creation_dialogue.set_data(_data)
		
		location_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Location)


func create_location_with_parent(parent_location_id):
	remove_ui_focus()
	if parent_location_id in $Database.locations_data.keys() and parent_location_id >= 0:
		var _data = {}
		_data.parent_id = parent_location_id
		location_creation_dialogue.set_data(_data)
		location_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Location)
	else:
		edit_location(-1)


func edit_category(category_id):
	remove_ui_focus()
	if category_id in $Database.categories_data.keys() and category_id > 0:
		#editing
		location_creation_dialogue.set_data($Database.categories_data[category_id])
		location_creation_dialogue._show(Global.WhatToDo.Change, Global.ActionDataType.Category)
	else:
		#creating
		location_creation_dialogue.set_data({})
		location_creation_dialogue._show(Global.WhatToDo.Create, Global.ActionDataType.Category)


func edit_tag(tag_id):
	remove_ui_focus()
	if tag_id in $Database.tags_data.keys() and tag_id > 0:
		#edit
		tag_creation_dialogue.set_data($Database.tags_data[tag_id])
		tag_creation_dialogue._show()
	else:
		#createe
		tag_creation_dialogue.set_data({})
		tag_creation_dialogue._show()


func show_item_filtering_dialogue():
	remove_ui_focus()
	if not filter_tag_ids or filter_tag_ids.size() == 0:
		$ItemFilteringDialogue.clear_selection()
	$ItemFilteringDialogue.show()


func get_tags_for_item(id):
	return $Database.get_tags_for_item(id)
	

func _on_create_location_button_pressed():
	remove_ui_focus()
	var selected_id = location_selection_tree.get_active_id()
	if selected_id > 0:
		create_location_with_parent(selected_id)
	else:
		edit_location(-1)


func _on_location_struct_tree_button_clicked(item, column, id, mouse_button_index):
	edit_location(id)


func _on_create_category_button_pressed():
	edit_category(-1)


func _on_category_struct_tree_button_clicked(item, column, id, mouse_button_index):
	edit_category(id)


func _on_database_tags_data_loaded():
	tag_tab.refresh_items_list($Database.tags_data)


func _on_filter_items_button_pressed():
	show_item_filtering_dialogue()




func shoe_profile_selection_dialogue(to_show = true):
	$ProfileSelectionDialogue.visible = to_show


func _on_search_line_edit_text_changed(new_text):
	var current_tab = tab_control.current_tab
	_on_tab_container_tab_changed(current_tab)


func _on_tab_container_tab_changed(tab):
	if search_line_edit == null:
		return
	var new_text = search_line_edit.text
	if tab == 0:
		if new_text == "":
			refresh_items_list()
		else:
			var found_items = search_items_with_text(new_text)
			items_tab.refrash_item_data_list(found_items)
		
	elif tab == 1:
		var found_locations = search_tree_data_with_text(new_text, $Database.locations_data)
		locations_tab_tree.show_selection(found_locations)
	elif tab == 2:
		var found_categories = search_tree_data_with_text(new_text, $Database.categories_data)
		category_tab_tree.show_selection(found_categories)


func select_item(item_element):
	items_tab.select_item(item_element)


func update_side_info_panel():
	var side_size = side_info.size
	side_info.get_node("Panel").visible = side_size.x > MIN_SPLIT_SIZE
	#if side_size.x < MIN_SPLIT_SIZE:
		#unfold_side_split(false)


func _on_h_split_dragged(offset):
	update_side_info_panel()
	h_split_dragged = true


func _on_side_info_panel_timer_timeout():
	update_side_info_panel()


func _on_add_image_button_pressed():
	$FileDialog.popup()


func _on_file_dialog_file_selected(path):
	print(path)


func _on_file_dialog_files_selected(paths):
	var image_name_to_select = ""
	for path : String in paths:
		var file_name = path.get_file()
		var full_new_path = $Database.get_image_folder_path() + file_name
		var resized_image_path = resize_and_save_image(path)
		if resized_image_path != null and !resized_image_path.is_empty():
			image_name_to_select = resized_image_path.get_file()
	load_images_to_viewer(image_name_to_select)


func resize_and_save_image(path):
	var file_name = path.get_file()
	var full_new_path = $Database.get_image_folder_path() + file_name

	while FileAccess.file_exists(full_new_path):
		full_new_path = $Database.get_image_folder_path() + \
			file_name.get_basename() + str(randi()) + "." + file_name.get_extension()

	var original_image = Image.new()
	var err = original_image.load(path)
	if err != OK:
		push_error("Не вдалося завантажити зображення: ", path, " Помилка: ", err)
		return null

	var original_width = original_image.get_width()
	var original_height = original_image.get_height()

	var crop_side = min(original_width, original_height)
	var x_offset = (original_width - crop_side) / 2
	var y_offset = (original_height - crop_side) / 2

	var cropped_image = Image.create_empty(crop_side, crop_side, false, original_image.get_format())
	cropped_image.blit_rect(original_image, Rect2(x_offset, y_offset, crop_side, crop_side), Vector2(0, 0))
	cropped_image.resize(Global.max_image_size, Global.max_image_size, Image.INTERPOLATE_CUBIC)
	
	var save_err = ERR_FILE_CANT_OPEN
	var file_extension = file_name.get_extension().to_lower()
	if file_extension == "png":
		save_err = cropped_image.save_png(full_new_path)
	elif file_extension == "jpg" or file_extension == "jpeg":
		save_err = cropped_image.save_jpg(full_new_path)
	elif file_extension == "webp":
		save_err = cropped_image.save_webp(full_new_path)
	else:
		push_error("Непідтримуваний формат файлу для збереження: ", file_extension)
		full_new_path += ".png"
		save_err = cropped_image.save_png(full_new_path) 
	if save_err != OK:
		push_error("Не вдалося зберегти змінене зображення до: ", full_new_path, " Помилка: ", save_err)
		return null
	return full_new_path

func remove_ui_focus():
	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		focused.release_focus()


func unfold_side_split(to_unfold = true):
	var window_size = DisplayServer.window_get_size()
	var h_split : HSplitContainer = $MainControl/HSplit
	var to_offset_left = true
	$MainControl/SidePanel/SideSplitButton.flip_h = to_unfold
	
	if not Global.is_window_vertical():
		#$MainControl/SidePanelLeft.visible = false
		#$MainControl/SidePanel.visible = true
		$MainControl/HSplit/MainInfo.visible = true
		$MainControl/HSplit/SideInfo.visible = to_unfold
		var h_split_size = $MainControl/HSplit.size
		if (h_split_size.x - $MainControl/HSplit.split_offset) < MIN_SPLIT_SIZE:
			$MainControl/HSplit.split_offset = h_split_size.x - MIN_SPLIT_SIZE * 2
	else:
		#$MainControl/SidePanelLeft.visible = to_unfold
		#$MainControl/SidePanel.visible = not to_unfold
		$MainControl/HSplit/MainInfo.visible = not to_unfold
		$MainControl/HSplit/SideInfo.visible = to_unfold
		if to_unfold:
			to_offset_left = false
			
	#if to_offset_left:
		#h_split.offset_right = -SIDE_PANEL_OFFSET
		#h_split.offset_left = 0
	#else:
		#h_split.offset_right = 0
		#h_split.offset_left = SIDE_PANEL_OFFSET
			
	$Timers/SideInfoPanelTimer.start()


func _on_side_split_button_pressed():
	var side_info_visible = $MainControl/HSplit/SideInfo.visible
	unfold_side_split(!side_info_visible)


func _input(event):
	if h_split_dragged and event is InputEventMouseButton and event.is_released() \
			and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		h_split_dragged = false
		if not $MainControl/HSplit/SideInfo/Panel.visible:
			$Timers/SideInfoPanelTimer2.start()


func _on_side_info_panel_timer_2_timeout():
	unfold_side_split(false)


func _on_create_from_item_button_pressed():
	remove_ui_focus()
	var selected_item_id = items_tab.get_selected_id()
	if selected_item_id == -1:
		edit_item(-1)
	else:
		create_item_from(selected_item_id)


func apply_filter():
	if search_line_edit.text != "":
		_on_search_line_edit_text_changed(search_line_edit.text)
	else:
		refresh_items_list()


func clear_filter():
	filter_tag_ids = []
	if search_line_edit.text != "":
		_on_search_line_edit_text_changed(search_line_edit.text)
	else:
		refresh_items_list()


func _on_clear_filter_pressed() -> void:
	clear_filter()


func _on_items_in_selected_locations_pressed() -> void:
	tab_control.current_tab = 0
