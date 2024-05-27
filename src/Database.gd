extends Node

signal item_data_loaded
signal locations_data_loaded
signal categories_data_loaded
signal tags_data_loaded

var db : SQLite = null
@export var name_text : TextEdit
@export var score_text : TextEdit

const verbosity_level : int = SQLite.VERBOSE
var database_path = "res://data/data.db"
#var database_path = "user://data.db"


var locations_data = {}
var items_data = {}
var categories_data = {}
var tags_data = {}

func move_all_stocks_from_to(from_location_id, to_location_id):
	db.update_rows("item_stocks", "location_id = '" + str(from_location_id) + "'", {"location_id" : to_location_id})


func move_all_locations_from_parent_up(from_location):
	var parent_id = 0
	if from_location in locations_data.keys() and "parent_id" in locations_data[from_location] and \
			locations_data[from_location]["parent_id"] != null:
		parent_id = locations_data[from_location]["parent_id"]
	db.update_rows("locations", "parent_id = '" + str(from_location) + "'", {"parent_id" : parent_id})


func delete_location(location_id):
	db.delete_rows("locations", "id = '" + str(location_id) + "'")


func delete_item(item_index):
	db.delete_rows("items", "id = '" + str(item_index) + "'")
	db.delete_rows("item_stocks", "item_id = '" + str(item_index) + "'")


func delete_stock(stock_id):
	db.delete_rows("item_stocks", "id = '" + str(stock_id) + "'")


func delete_tags(tag_ids):
	for i in tag_ids:
		db.delete_rows("item_tags", "tag_id = '" + str(i) + "'")
		db.delete_rows("tags", "id = '" + str(i) + "'")


func get_unit_name_by_id(_id):
	var unit_name_data = db.select_rows("unit_names", "id = " + str(_id), ["name"])
	if unit_name_data.size() > 0 and "name" in unit_name_data[0].keys():
		return unit_name_data[0].name
	return ""


func get_image_by_id(image_id):
	db.select_rows("images", "id = '" + str(image_id) + "'", ["*"])
	for res in db.query_result:
		var image = Image.new()
		image.load_jpg_from_buffer(res.image)
		return image


func get_location_name_by_id(location_id):
	if location_id in locations_data.keys():
		return locations_data[location_id].name
	return ""


func get_locations_data_by_id(location_id):
	if location_id in locations_data.keys():
		return locations_data[location_id]
	return null


func get_category_data_by_id(category_id):
	if category_id in categories_data.keys():
		return categories_data[category_id]
	return null


func pull_locations_data():
	locations_data.clear()
	var localion_db_data = db.select_rows("locations", "", ["*"])
	for i in range(localion_db_data.size()):
		locations_data[localion_db_data[i].id] = localion_db_data[i]
	locations_data_loaded.emit()


func pull_categories_data():
	categories_data.clear()
	var categories_db_data = db.select_rows("categories", "", ["*"])
	for i in range(categories_db_data.size()):
		categories_data[categories_db_data[i].id] = categories_db_data[i]
	categories_data_loaded.emit()


func pull_tags_data():
	tags_data.clear()
	var tags_db_data = db.select_rows("tags", "", ["*"])
	for i in range(tags_db_data.size()):
		tags_data[tags_db_data[i].id] = tags_db_data[i]
	tags_data_loaded.emit()


func get_new_item_id():
	db.query("SELECT * FROM 'items' ORDER BY id DESC LIMIT 1;")
	print(db.query_result)
	return db.query_result[0].id


func get_new_tag_id():
	db.query("SELECT * FROM 'tags' ORDER BY id DESC LIMIT 1;")
	print(db.query_result)
	return db.query_result[0].id



func pull_items_data():
	items_data.clear()
	var stock_db_data = db.select_rows("item_stocks", "", ["*"])
	var items_db_data = db.select_rows("items", "", ["*"])
	for i in range(items_db_data.size()):
		items_data[items_db_data[i].id] = items_db_data[i]
	for i in range(stock_db_data.size()):
		var current_stock = stock_db_data[i]
		if "item_id" in current_stock.keys() and current_stock["item_id"] in items_data.keys():
			if not "stocks" in items_data[current_stock["item_id"]].keys():
				items_data[current_stock["item_id"]].stocks = [current_stock]
			else:
				items_data[current_stock["item_id"]].stocks.append(current_stock)
	item_data_loaded.emit()
	

func _ready():
	if OS.get_name() == "Android":
		database_path = "user://data.db"
	db = SQLite.new()
	db.path = database_path
	db.open_db()
	create_tables()
	pull_locations_data()
	pull_items_data()
	pull_categories_data()
	pull_tags_data()
	

func get_tables():
	db.query("SELECT name FROM sqlite_schema WHERE type = 'table' AND name NOT LIKE 'sqlite_%';")
	var tables = []
	for res in db.query_result:
		for k in res.keys():
			tables.append(res[k])
	return tables


func get_number_of_items_in_location(location_id):
	if location_id in locations_data.keys():
		db.select_rows("item_stocks", "location_id = '" + str(location_id) + "'", ["*"])
		return db.query_result.size()
	return 0


func create_tables():
	var tables = get_tables()
	if not "items" in tables:
		var items_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
			"description" : {"data_type" : "TEXT"},
			"category_id" : {"data_type" : "int"},
			"image_id" : {"data_type" : "int"},
			"mark" : {"data_type" : "int"},
			"variant_of_id" : {"data_type" : "int"},
			"unit_name_id" : {"data_type" : "int"},
		}
		db.create_table("items", items_table)
		
		var item_stocks_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"item_id" : {"data_type" : "int"},
			"location_id" : {"data_type" : "int"},
			"quantity" : {"data_type" : "int"},
			"amount" : {"data_type" : "REAL"},
			"mark" : {"data_type" : "int"},
		}
		db.create_table("item_stocks", item_stocks_table)
		
		var units_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
		}
		db.create_table("unit_names", units_table)
		
		var locations_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
			"parent_id" : {"data_type" : "int"},
			"description" : {"data_type" : "TEXT"},
			"mark" : {"data_type" : "int"},
			"is_virtual" : {"data_type" : "int"},
		}
		db.create_table("locations", locations_table)
		
		var images_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"image" : {"data_type" : "BLOB"},
			"image_path" : {"data_type" : "TEXT"},
		}
		db.create_table("images", images_table)
		
		var category_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
			"description" : {"data_type" : "TEXT"},
			"parent_id" : {"data_type" : "int"}
		}
		db.create_table("categories", category_table)
		
		var tags_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
		}
		db.create_table("tags", tags_table)
		
		var item_tags_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"item_id" : {"data_type" : "int"},
			"tag_id" : {"data_type" : "int"},
		}
		db.create_table("item_tags", item_tags_table)
		
		var projects_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
			"description" : {"data_type" : "TEXT"},
			"final_item_id" : {"data_type" : "int"},
		}
		db.create_table("projects", projects_table)
		
		var project_items_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"project_id" : {"data_type" : "int"},
			"item_id" : {"data_type" : "int"},
			"quantiry" : {"data_type" : "int"},
			"amount" : {"data_type" : "REAL"},
		}
		db.create_table("project_items", project_items_table)
		
		var project_build_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"project_id" : {"data_type" : "int"},
			"quantiry" : {"data_type" : "int"},
			"location_id" : {"data_type" : "int"},
		}
		db.create_table("projeect_build", project_build_table)
		
		var meta_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
			"data" : {"data_type" : "TEXT"},
		}
		db.create_table("stock_g_master_meta", meta_table)
		
		
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


func save_tag(new_tag_data):
	if "name" in new_tag_data:
		new_tag_data.name = new_tag_data.name.to_lower()
	if "id" in new_tag_data and new_tag_data.id in items_data.keys():
		db.update_rows("tags", "id = '" + str(new_tag_data.id) + "'", new_tag_data)
	else:
		new_tag_data.erase('id')
		db.insert_row("tags", new_tag_data)



func save_location(new_location_data):
	if "id" in new_location_data:
		db.update_rows("locations", "id = '" + str(new_location_data.id) + "'", new_location_data)
	else:
		new_location_data.erase('id')
		db.insert_row("locations", new_location_data)


func save_category(new_category_data):
	if "id" in new_category_data:
		db.update_rows("categories", "id = '" + str(new_category_data.id) + "'", new_category_data)
	else:
		new_category_data.erase('id')
		db.insert_row("categories", new_category_data)


func save_stock(new_stock_data):
	if "id" in new_stock_data:
		db.update_rows("item_stocks", "id = '" + str(new_stock_data.id) + "'", new_stock_data)
	else:
		db.insert_row("item_stocks", new_stock_data)
	

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
	var current_locations_data = get_locations_data_by_id(location_id)
	while current_locations_data != null:
		addr = current_locations_data.name + "/" + addr
		if "parent_id" in current_locations_data.keys() and current_locations_data.parent_id:
			current_locations_data = get_locations_data_by_id(current_locations_data.parent_id)
		else:
			current_locations_data = null
	addr = "/" + addr.left(addr.length() - 1)
	return addr


func build_category_address(category_id):
	var addr = "/"
	var current_category_data = get_category_data_by_id(category_id)
	while current_category_data != null:
		addr = current_category_data.name + "/" + addr
		if "parent_id" in current_category_data.keys() and current_category_data.parent_id:
			current_category_data = get_category_data_by_id(current_category_data.parent_id)
		else:
			current_category_data = null
	addr = "/" + addr.left(addr.length() - 1)
	return addr


func load_image_example():
	db.select_rows("images", "id = '1'", ["*"])
	for res in db.query_result:
		var image = Image.new()
		image.load_jpg_from_buffer(res.image)
		var texture = ImageTexture.create_from_image(image)
		
