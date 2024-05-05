extends Node

var db : SQLite = null
@export var name_text : TextEdit
@export var score_text : TextEdit

const verbosity_level : int = SQLite.VERBOSE
var database_path = "user://data.db"

var location_data = {
	1 : ["a1", 0],
		2 : ["b1", 1],
		3 : ["b2", 1],
	4 : ["c1", 0],
		5 : ["d1", 4],
			6 : ["e1", 5],
			7 : ["e2", 6]
}


func get_location_name_by_id(location_id):
	if location_id in location_data.keys():
		return location_data[location_id][0]
	return ""


func _ready():
	db = SQLite.new()
	db.path = database_path
	db.open_db()
	create_tables()


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
			"image_id" : {"data_type" : "int"}
		}
		db.create_table("items", items_table)
		var locations_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "text"},
			"parent_id" : {"data_type" : "id"}
		}
		db.create_table("locations", locations_table)
		var category_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "text"},
			"parent_id" : {"data_type" : "id"}
		}
		db.create_table("categories", category_table)
		var images_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"image" : {"data_type" : "blob"},
		}
		db.create_table("images", images_table)


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
	var image := preload("res://addons/y.png")
	var pba = image.get_image().save_jpg_to_buffer()
	var data = {"image" : pba}
	db.insert_row("images", data)


func load_image_example():
	db.select_rows("images", "id = '1'", ["*"])
	for res in db.query_result:
		var image = Image.new()
		image.load_jpg_from_buffer(res.image)
		var texture = ImageTexture.create_from_image(image)
		
