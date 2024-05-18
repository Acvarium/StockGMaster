extends Panel
@onready var main_node = get_tree().get_root().get_node("Main")
var current_stock_data
var current_unit_name = ""

func set_data(stock_data, unit_name):#location_path, quantity, amount, unit_name):
	if !main_node:
		main_node = get_tree().get_root().get_node("Main")
	current_stock_data = stock_data
	current_unit_name = unit_name
	var location_path = main_node.get_location_address(stock_data.location_id)
	var quantity = 0 if stock_data.quantity == null else stock_data.quantity
	var amount = 0.0 if stock_data.amount == null else stock_data.amount
	$AddressLine.text = location_path
	$AddressLine.set_tooltip_text(location_path)
	if amount != 0:
		$QuantityLine.text = str(snapped(amount, 0.01)) + " " + unit_name
	else:
		$QuantityLine.text = str(quantity)


func _ready():
	pass # Replace with function body.


func _on_edit_button_pressed():
	main_node.edit_stock(current_stock_data)
