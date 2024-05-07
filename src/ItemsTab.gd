extends Control
@export var items_holder : VBoxContainer
@export var temp_items_holder : Control
var item_prefab = preload("res://objects/item_list_element.tscn")

func _ready():
	pass
	#clear_list()


func fold_all_but_one(the_one):
	for c in items_holder.get_children():
		if c != the_one:
			c.unfold(false)


func clear_list():
	for c in items_holder.get_children():
		c.queue_free()


func refrash_items_list(items_data):
	#clear_list()
	var temp_items = {}
	for item in items_holder.get_children():
		if item.item_id < 0:
			item.queue_free()
			continue
		temp_items[item.item_id] = item
		temp_items_holder.add_child(item)
	
	for i in range(items_data.keys().size()):
		var current_key = items_data.keys()[i]
		var next_item_data = items_data[current_key]
		if current_key in temp_items.keys():
			items_holder.add_child(temp_items[current_key])
			update_item(next_item_data, temp_items[current_key])
		else:
			add_item(next_item_data)
		

func update_item(item_data, item):
	item.item_tab = self
	item.set_data(item_data)


func add_item(item_data):
	var item_element = item_prefab.instantiate()
	items_holder.add_child(item_element)
	item_element.item_tab = self
	item_element.set_data(item_data)
