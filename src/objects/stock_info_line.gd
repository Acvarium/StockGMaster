extends Panel


func set_data(location_path, quantity, amount, unit_name):
	$AddressLine.text = location_path
	$AddressLine.set_tooltip_text(location_path)
	if amount != 0:
		$QuantityLine.text = str(snapped(amount, 0.01)) + " " + unit_name
	else:
		$QuantityLine.text = str(quantity)
		
func _ready():
	pass # Replace with function body.

