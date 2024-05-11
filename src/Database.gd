extends Node

signal item_data_loaded

var db : SQLite = null
@export var name_text : TextEdit
@export var score_text : TextEdit

const verbosity_level : int = SQLite.VERBOSE
var database_path = "user://data.db"

var location_data = {
}

var items_data = {
	
}


func delete_item(item_index):
	db.delete_rows("items", "id = '" + str(item_index) + "'")
	


func get_image_by_id(image_id):
	db.select_rows("images", "id = '" + str(image_id) + "'", ["*"])
	for res in db.query_result:
		var image = Image.new()
		image.load_jpg_from_buffer(res.image)
		return image


func get_location_name_by_id(location_id):
	if location_id in location_data.keys():
		return location_data[location_id].name
	return ""


func get_location_data_by_id(location_id):
	if location_id in location_data.keys():
		return location_data[location_id]
	return null


func pull_locations_data():
	location_data.clear()
	var localion_db_data = db.select_rows("locations", "", ["*"])
	for i in range(localion_db_data.size()):
		location_data[localion_db_data[i].id] = localion_db_data[i]


func pull_items_data():
	items_data.clear()
	var items_db_data = db.select_rows("items", "", ["*"])
	for i in range(items_db_data.size()):
		items_data[items_db_data[i].id] = items_db_data[i]
		#print(items_db_data[i])
	item_data_loaded.emit()
	

func _ready():
	db = SQLite.new()
	db.path = database_path
	db.open_db()
	create_tables()
	pull_locations_data()
	pull_items_data()


func get_tables():
	db.query("SELECT name FROM sqlite_schema WHERE type = 'table' AND name NOT LIKE 'sqlite_%';")
	var tables = []
	for res in db.query_result:
		for k in res.keys():
			tables.append(res[k])
	return tables


func create_tables():
	var tables = get_tables()
	if not "items" in tables:
		var items_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "text"},
			"description" : {"data_type" : "text"},
			"category_id" : {"data_type" : "int"},
			"location_id" : {"data_type" : "int"},
			"values_id" : {"data_type" : "int"},
			"image_id" : {"data_type" : "int",
			"tags_id" : {"data_type" : "int"}
			}
		}
		db.create_table("items", items_table)
		var locations_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "text"},
			"parent_id" : {"data_type" : "id",
			"description" : {"data_type" : "text"}
			}
		}
		db.create_table("locations", locations_table)
		var category_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "text"},
			"description" : {"data_type" : "text"},
			"parent_id" : {"data_type" : "id"}
		}
		db.create_table("categories", category_table)
		var images_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"image" : {"data_type" : "blob"},
		}
		db.create_table("images", images_table)


func update_value(action_data_type, for_id, with_value):
	if action_data_type == Global.ActionDataType.Location:
		db.update_rows("items", "id = '" + str(for_id) + "'", {"location_id" : with_value})


func save_item(new_item_data):
	if new_item_data.id in items_data.keys():
		db.update_rows("items", "id = '" + str(new_item_data.id) + "'", new_item_data)
#TODO add the rest of the data
	else:
		new_item_data.erase('id')
		db.insert_row("items", new_item_data)
	

func _on_create_table_pressed():
	var table = {
		"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
		"name" : {"data_type" : "text"},
		"score" : {"data_type" : "int"}
	}
	db.create_table("players", table)


func _on_insert_data_2_pressed():
	var data = {
		"name" : name_text.text,
		"score" : int(score_text.text)}
	db.insert_row("players", data)


func _on_select_data_pressed():
	print(db.select_rows("players", "score > 0", ["name, score"]))


func _on_update_data_pressed():
	db.update_rows("players", "name = '" + name_text.text + "'", {"score" : int(score_text.text)})


func _on_delete_data_pressed():
	db.delete_rows("players", "name = '" + name_text.text + "'")


func _on_custom_select_pressed():
	db.query("SELECT * FROM players JOIN player_info ON player_info.id = players.player_info_id")
	print(db.query_result)


func store_image_example():
	pass
	#var pba = image.get_image().save_jpg_to_buffer()
	#var data = {"image" : pba}
	#db.insert_row("images", data)


func build_location_address(location_id):
	var addr = "/"
	var current_location_data = get_location_data_by_id(location_id)
	while current_location_data != null:
		addr = current_location_data.name + "/" + addr
		if "parent_id" in current_location_data.keys() and current_location_data.parent_id:
			current_location_data = get_location_data_by_id(current_location_data.parent_id)
		else:
			current_location_data = null
	addr = "/" + addr.left(addr.length() - 1)
	return addr


func load_image_example():
	db.select_rows("images", "id = '1'", ["*"])
	for res in db.query_result:
		var image = Image.new()
		image.load_jpg_from_buffer(res.image)
		var texture = ImageTexture.create_from_image(image)
		
