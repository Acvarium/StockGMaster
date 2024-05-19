extends Control
@export var name_list_item : Panel
@export var description_list_item : Panel
@export var title_label : Label
@export var location_list_stock : Panel
@export var quantity_list_stock : Panel

@onready var main_node = get_tree().get_root().get_node("Main")

@export var item_data_components : Array[Control]
@export var stock_data_components : Array[Control]
@export var delete_button : Button

var item_index = -1
var current_item_data
var current_mode = Global.WhatToDo.None
var current_action_data_type = Global.ActionDataType.None
var current_stock_data = {}

func show_item_data_components(to_show = true):
	for i in item_data_components:
		i.visible = to_show


func show_stock_data_components(to_show = true):
	for s in stock_data_components:
		s.visible = to_show


func _show(what_to_do, action_data_type):
	#_reset()
	current_mode = what_to_do
	current_action_data_type = action_data_type
	if action_data_type == Global.ActionDataType.Item:
		name_list_item.set_editable(true)
		if what_to_do == Global.WhatToDo.Create:
			title_label.text = "create item"
			delete_button.visible = false 
		else:
			title_label.text = "edit item"
			delete_button.visible = true 
		show_item_data_components(true)
		show_stock_data_components(current_mode == Global.WhatToDo.Create)
	elif action_data_type == Global.ActionDataType.Stock:
		name_list_item.set_editable(false)
		if what_to_do == Global.WhatToDo.Create:
			pass
		else:
			pass
		show_item_data_components(false)
		show_stock_data_components(true)
	show()


#TODO implement the mode for editing the stock data
func set_stock_data(item_data, stock_data):
	current_item_data = item_data
	current_stock_data = stock_data
	if "name" in item_data.keys() and item_data.name:
		name_list_item.set_edit_text(item_data.name)
	if "location_id" in stock_data.keys():
		update_location_text(main_node.get_location_address(stock_data.location_id))
	if "quantity" in stock_data.keys():
		quantity_list_stock.set_quantity(stock_data.quantity)


func set_item_data(item_data):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_item_data = item_data
	item_index = -1 
	if "id" in item_data.keys():
		title_label.text = "Edit Item"
		item_index = item_data.id
	else:
		title_label.text = "Create Item"
	name_list_item.set_edit_text("")
	if "name" in item_data.keys() and item_data.name:
		name_list_item.set_edit_text(item_data.name)
	description_list_item.set_edit_text("")
	if "description" in item_data.keys() and item_data.description:
		description_list_item.set_edit_text(item_data.description)
	

func update_location_text(new_location_text):
	location_list_stock.set_location_button_text(new_location_text)


func _ready():
	reset_and_hide()


func _on_cancel_button_pressed():
	reset_and_hide()


func _reset(reset_stock_data = true, reset_item_data = true):
	if reset_stock_data:
		quantity_list_stock.set_quantity(0)
		current_stock_data = null
		update_location_text("/")
	if reset_item_data:
		current_item_data = null
	

func reset_and_hide():
	_reset()
	hide()


func _on_save_item_button_pressed():
	var quantity = quantity_list_stock.get_quantiry()
	if current_action_data_type == Global.ActionDataType.Item:
		var new_item_data = {}
		new_item_data.id = item_index
		new_item_data.name = name_list_item.get_edit_text()
		new_item_data.description = description_list_item.get_edit_text()
		item_index = main_node.save_item(new_item_data, quantity == 0)
	var to_save_stock = quantity != 0
	if current_action_data_type == Global.ActionDataType.Item and \
			current_mode != Global.WhatToDo.Create:
		to_save_stock = false
	if to_save_stock:
		if !current_stock_data:
			current_stock_data = {}
		if not "location_id" in current_stock_data:
			current_stock_data.location_id = 0
		if not "item_id" in current_stock_data:
			current_stock_data.item_id = item_index
		current_stock_data.quantity = quantity
		main_node.save_stock(current_stock_data)
	reset_and_hide()


func tree_value_selected(value, item_selection_action_type):
	#if item_selection_action_type == Global.ActionDataType.Location:
		#current_stock_data.item_id = item_index
	if !current_stock_data:
		current_stock_data = {}
	current_stock_data.location_id = value
	update_location_text(main_node.get_location_address(current_stock_data.location_id))


func _on_location_selection_button_pressed():
	main_node.select_location_popup(self)
	#main_node.exec_action_popup(Global.WhatToDo.Change, Global.ActionDataType.Location, item_index)


func _on_delete_button_pressed():
	main_node.confirme_action_dialogue(self, Global.WhatToDo.Delete, "Do you want to delete this item?")
	
	
func confirme_action(conf_what_to_do):
	if conf_what_to_do == Global.WhatToDo.Delete:
		if current_action_data_type == Global.ActionDataType.Item:
			main_node.delete_item(item_index)
		elif current_action_data_type == Global.ActionDataType.Stock:
			main_node.delete_stock(current_stock_data.id)
		reset_and_hide()
