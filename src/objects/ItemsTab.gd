extends Control
@export var items_holder : VBoxContainer
@export var temp_items_holder : Control
var item_prefab = preload("res://objects/ItemListElement.tscn")
@onready var main_node = get_tree().get_root().get_node("Main")
var elements = {}

const ITEMS_PER_PAGE = [100, 50, 25, 10]

var current_items_per_page = ITEMS_PER_PAGE[3]

var current_items_data = {}
@export var item_page_switcher : Node


func clear_list():
	for c in items_holder.get_children():
		c.queue_free()
	elements = {}


func refrash_item_data_list(items_data):
	if items_data == null:
		current_items_data = null
		item_page_switcher.set_last_page(1)
	else:
		current_items_data = items_data.duplicate(true)
		update_number_of_pages()


func update_number_of_pages():
	if current_items_data.keys().size() == 0:
		item_page_switcher.set_last_page(0)
	else:
		var number_of_items = current_items_data.keys().size()
		var last_page_num = number_of_items / current_items_per_page
		if (number_of_items % current_items_per_page) != 0:
			last_page_num += 1
		if last_page_num == 0:
			last_page_num = 1
		item_page_switcher.set_last_page(last_page_num)  


func refresh_items_list(page_number = 1):
	for item in items_holder.get_children():
		item.queue_free()
	if not current_items_data or current_items_data.keys().size() == 0:
		return
		#item.clear_stocks()
		#if item.item_id < 0 or not item.item_id in items_data.keys():
			#elements.erase(item.item_id)
			#item.queue_free()
			#continue
	var first_item_to_show = (page_number - 1) * current_items_per_page
	if page_number == 0:
		first_item_to_show = 0
	var last_item_to_show = clampi(first_item_to_show + current_items_per_page, 0, current_items_data.keys().size())
	
	for i in range(first_item_to_show, last_item_to_show):
		var current_key = current_items_data.keys()[i]
		var next_item_data = current_items_data[current_key]
		if current_key in elements.keys():
			update_item(next_item_data, elements[current_key])
		else:
			add_item(next_item_data)
	items_holder.refresh_unfold()


func add_item(item_data):
	var item_element = item_prefab.instantiate()
	items_holder.add_child(item_element)
	item_element.item_tab = self
	item_element.set_data(item_data)
	#elements[item_data.id] = item_element


func select_item(item_element):
	for item in items_holder.get_children():
		item.select(item == item_element)


func get_selected_id():
	for item in items_holder.get_children():
		if item.is_selected: 
			return item.get_id()
	return -1


func update_item(item_data, item):
	item.item_tab = self
	item.set_data(item_data)


func refresh_list():
	var search_text = main_node.get_search_text()
	_on_items_search_line_edit_text_changed(search_text)
	

func show_selection(selection_ids):
	for k in elements.keys():
		var in_selection = selection_ids == null or k in selection_ids
		if in_selection:
			elements[k].visible = main_node.is_item_passes_filter(k)
		else:
			elements[k].visible = false


func _on_items_search_line_edit_text_changed(new_text):
	var found_items = main_node.search_items_with_text(new_text)
	show_selection(found_items)


func _on_item_page_switcher_page_changed(new_page: int) -> void:
	refresh_items_list(new_page)


func _on_option_button_item_selected(index: int) -> void:
	current_items_per_page = ITEMS_PER_PAGE[index]
	update_number_of_pages()
	refresh_items_list()
