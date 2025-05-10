extends Control
@export var items_holder : VBoxContainer
@export var temp_items_holder : Control
var item_prefab = preload("res://objects/ItemListElement.tscn")
@onready var main_node = get_tree().get_root().get_node("Main")
var elements = {}


func _ready():
	pass
	#clear_list()


func clear_list():
	for c in items_holder.get_children():
		c.queue_free()
	elements = {}
	

func refresh_items_list(items_data):
	#clear_list()
	for item in items_holder.get_children():
		item.clear_stocks()
		if item.item_id < 0 or not item.item_id in items_data.keys():
			elements.erase(item.item_id)
			item.queue_free()
			continue
	
	for i in range(items_data.keys().size()):
		if i > 50:
			break
		var current_key = items_data.keys()[i]
		var next_item_data = items_data[current_key]
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
	elements[item_data.id] = item_element


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
