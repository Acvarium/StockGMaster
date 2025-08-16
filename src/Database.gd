extends Node

signal item_data_loaded
signal locations_data_loaded
signal categories_data_loaded
signal tags_data_loaded

var db : SQLite = null
@export var name_text : TextEdit
@export var score_text : TextEdit

const verbosity_level : int = SQLite.VERBOSE
#var database_path = "res://data/data.db"

const db_file_name = "data.db"
#var base_data_paths = ["res://data/", "user://default/"]
var supported_image_ext = ["jpg", "png"]

var locations_data = {}
var items_data = {}
var categories_data = {}
var tags_data = {}


func _ready() -> void:
	Global.profiles_loaded.connect(load_data)


func get_db_path():
	if OS.get_name() == "Android":
		return get_data_path() + db_file_name
	return get_data_path() + db_file_name


func get_image_paths():
	var image_dir_path = Global.get_image_folder_path()
	var image_names = []
	var d = DirAccess.open(image_dir_path)
	if d == null:
		DirAccess.make_dir_absolute(image_dir_path)
	var dir = DirAccess.open(image_dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name : String  = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if supported_image_ext.has(file_name.to_lower().get_extension()):
					image_names.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	image_names.sort()
	return image_names


func get_data_path():
	return Global.get_data_path()


func move_all_stocks_from_loc_to(from_location_id, to_location_id):
	db.update_rows("item_stocks", "location_id = '" + str(from_location_id) + "'", {"location_id" : to_location_id})


func move_all_items_from_cat_to(from_cat_id, to_cat_id):
	db.update_rows("items", "category_id = '" + str(from_cat_id) + "'", {"category_id" : to_cat_id})


func move_all_locations_from_parent_up(from_location):
	var parent_id = 0
	if from_location in locations_data.keys() and "parent_id" in locations_data[from_location] and \
			locations_data[from_location]["parent_id"] != null:
		parent_id = locations_data[from_location]["parent_id"]
	db.update_rows("locations", "parent_id = '" + str(from_location) + "'", {"parent_id" : parent_id})


func move_all_categories_from_parent_up(from_cat):
	var parent_id = 0
	if from_cat in categories_data.keys() and "parent_id" in categories_data[from_cat] and \
			categories_data[from_cat]["parent_id"] != null:
		parent_id = categories_data[from_cat]["parent_id"]
	db.update_rows("categories", "parent_id = '" + str(from_cat) + "'", {"parent_id" : parent_id})


func get_number_of_items_with_tags(tag_ids):
	var items_counted = 0
	for i in range(tag_ids.size()):
		items_counted += \
			db.select_rows("item_tags", "tag_id = '" + str(tag_ids[i]) + "'", ["*"]).size()
	return items_counted


func get_number_of_items_with_category(category_id):
	return db.select_rows("items", "category_id = '" + str(category_id) + "'", ["*"]).size()
	

func get_tags_for_item(id):
	var current_item_tags_db = db.select_rows("item_tags", "item_id = '" + str(id) + "'", ["*"])
	var current_item_tags = {}
	for i in range(current_item_tags_db.size()):
		var current_item_tag_data = current_item_tags_db[i]
		current_item_tags[current_item_tag_data.id] = {"id": current_item_tag_data.tag_id, "name": tags_data[current_item_tag_data.tag_id].name}
	return current_item_tags


func get_attachmetns_for_item(id):
	var current_item_attachments_db = db.select_rows("item_attachments", "item_id = '" + str(id) + "'", ["*"])
	return current_item_attachments_db


func get_tag_ids_for_item(item_id):
	var current_item_tags_db = db.select_rows("item_tags", "item_id = '" + str(item_id) + "'", ["tag_id"])
	var current_item_tag_ids = []
	for data in current_item_tags_db:
		current_item_tag_ids.append(data.tag_id)
	return current_item_tag_ids


func delete_location(location_id):
	db.delete_rows("locations", "id = '" + str(location_id) + "'")


func delete_category(cat_id):
	db.delete_rows("categories", "id = '" + str(cat_id) + "'")


func delete_item(item_index):
	db.delete_rows("items", "id = '" + str(item_index) + "'")
	db.delete_rows("item_stocks", "item_id = '" + str(item_index) + "'")


func delete_stock(stock_id):
	db.delete_rows("item_stocks", "id = '" + str(stock_id) + "'")


func save_item_tags(item_index, current_tag_ids):
	var current_item_tags_db = db.select_rows("item_tags", "item_id = '" + str(item_index) + "'", ["*"])
	var tag_id_exists = []
	for i in range(current_item_tags_db.size()):
		if not current_item_tags_db[i].tag_id in current_tag_ids:
			db.delete_rows("item_tags", "id = '" + str(current_item_tags_db[i].id) + "'")
		else:
			tag_id_exists.append(current_item_tags_db[i].tag_id)
	for t in current_tag_ids:
		if not t in tag_id_exists:
			db.insert_row("item_tags", {"item_id": item_index, "tag_id": t})


func save_item_image_path(item_index, item_image_path):
	db.update_rows("items", "id = '" + str(item_index) + "'", {"image_path" : item_image_path})
	items_data[item_index].image_path = item_image_path


func delete_tags(tag_ids):
	for i in tag_ids:
		db.delete_rows("item_tags", "tag_id = '" + str(i) + "'")
		db.delete_rows("tags", "id = '" + str(i) + "'")


func get_unit_name_by_id(_id):
	var unit_name_data = db.select_rows("unit_names", "id = " + str(_id), ["name"])
	if unit_name_data.size() > 0 and "name" in unit_name_data[0].keys():
		return unit_name_data[0].name
	return ""

#func get_image_folder_path():
	#return get_data_path() + "/images/"



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
	return db.query_result[0].id


func get_new_tag_id():
	db.query("SELECT * FROM 'tags' ORDER BY id DESC LIMIT 1;")
	return db.query_result[0].id


func pull_items_data():
	items_data.clear()
	var stock_db_data = db.select_rows("item_stocks", "", ["*"])
	var attachment_db_data = db.select_rows("item_attachments", "", ["*"])
	
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
	
	for i in range(attachment_db_data.size()):
		var current_attachment = attachment_db_data[i]
		if "item_id" in current_attachment.keys() and current_attachment["item_id"] in items_data.keys():
			if not "attachments" in items_data[current_attachment["item_id"]].keys():
				items_data[current_attachment["item_id"]].attachments = [current_attachment]
			else:
				items_data[current_attachment["item_id"]].attachments.append(current_attachment)
	item_data_loaded.emit()
	

func load_data():
	var dir = DirAccess.open("res://textures/")
	if dir:
		dir.list_dir_begin()
		var file_name : String  = dir.get_next()
		while file_name != "":
			#if not dir.current_is_dir():
				#print(file_name)
			file_name = dir.get_next()
	
	var d = DirAccess.open(get_data_path())
	if d == null:
		DirAccess.make_dir_absolute(get_data_path())
	db = SQLite.new()
	db.path = get_db_path()
	db.open_db()
	create_tables()
	update_tables()
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


func get_number_of_items_with_images(list_of_image_paths):
	var items_count = 0
	for image_path in list_of_image_paths:
		db.select_rows("items", "image_path = '" + image_path + "'", ["*"])
		items_count += db.query_result.size()
	return items_count


func delete_images(list_of_image_paths):
	for image_path in list_of_image_paths:
		db.update_rows("items", "image_path = '" + image_path + "'", {"image_path" : ""})
		DirAccess.remove_absolute(Global.get_image_folder_path() + image_path)


func delete_attachments(attachments_paths):
	for _path in attachments_paths:
		db.delete_rows("item_attachments", "path = '" + _path + "'")
		DirAccess.remove_absolute(Global.get_attachments_folder_path() + _path)


func update_tables():
	var tables = get_tables()
	if not "item_attachments" in tables:
		var item_attachments_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"item_id" : {"data_type" : "int"},
			"path" : {"data_type" : "TEXT"},
			"description" : {"data_type" : "TEXT"},
		}
		db.create_table("item_attachments", item_attachments_table)


func create_tables():
	var tables = get_tables()
	if not "items" in tables:
		var items_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"name" : {"data_type" : "TEXT"},
			"description" : {"data_type" : "TEXT"},
			"category_id" : {"data_type" : "int"},
			"mark" : {"data_type" : "int"},
			"variant_of_id" : {"data_type" : "int"},
			"unit_name_id" : {"data_type" : "int"},
			"image_path" : {"data_type" : "TEXT"},
			"image_rect_id" : {"data_type" : "int"},
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
			"image_path" : {"data_type" : "TEXT"},
			"image_rect_id" : {"data_type" : "int"},
		}
		db.create_table("locations", locations_table)

		var rect_table = {
			"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
			"x" : {"data_type" : "int"},
			"y" : {"data_type" : "int"},
			"w" : {"data_type" : "int"},
			"h" : {"data_type" : "int"},
		}
		db.create_table("rect", rect_table)
		
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
		return new_item_data.id
#TODO add the rest of the data
	else:
		new_item_data.erase('id')
		db.insert_row("items", new_item_data)
		return get_new_item_id()

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


func add_attachment(item_id, file_path):
	var new_attachment_data = {}
	new_attachment_data.item_id = item_id
	new_attachment_data.path = file_path
	db.insert_row("item_attachments", new_attachment_data)


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



func get_all_child_ids(table_name: String, parent_ids: Array) -> Array:
	var all_ids = parent_ids.duplicate()
	var queue = parent_ids.duplicate()
	while not queue.is_empty():
		var current_id = queue.pop_front()
		var rows = db.select_rows(table_name, "parent_id = %s" % current_id, ["id"])
		for row in rows:
			var child_id = row["id"]
			if child_id not in all_ids:
				all_ids.append(child_id)
				queue.append(child_id)
	return all_ids

#------------------------
func get_filtered_items(tag_ids: Array = [], category_ids: Array = [], location_ids: Array = []) -> Dictionary:
	var all_category_ids := get_all_subcategories(category_ids)
	var all_location_ids := get_all_sublocations(location_ids)

	var tag_id_strs := []
	for tag_id in tag_ids:
		tag_id_strs.append(str(tag_id))

	var category_id_strs := []
	for cat_id in all_category_ids:
		category_id_strs.append(str(cat_id))

	var location_id_strs := []
	for loc_id in all_location_ids:
		location_id_strs.append(str(loc_id))

	var conditions := []

	if tag_id_strs.size() > 0:
		conditions.append("items.id IN (SELECT item_id FROM item_tags WHERE tag_id IN (" + ",".join(tag_id_strs) + "))")

	if category_id_strs.size() > 0:
		conditions.append("category_id IN (" + ",".join(category_id_strs) + ")")

	if location_id_strs.size() > 0:
		conditions.append("items.id IN (SELECT item_id FROM item_stocks WHERE location_id IN (" + ",".join(location_id_strs) + "))")

	var where_clause := ""
	if conditions.size() > 0:
		where_clause = "WHERE " + " AND ".join(conditions)

	var query := """
		SELECT items.*, item_stocks.id as stock_id, item_stocks.location_id, item_stocks.quantity, item_stocks.amount, item_stocks.mark
		FROM items
		LEFT JOIN item_stocks ON item_stocks.item_id = items.id
	""" + where_clause + ";"

	db.query(query)
	var result = db.query_result

	var data := {}
	for row in result:
		var item_id = row["id"]
		if not data.has(item_id):
			var item_data = row.duplicate()
			item_data.erase("stock_id")
			item_data.erase("location_id")
			item_data.erase("quantity")
			item_data.erase("amount")
			item_data.erase("mark")
			item_data["stocks"] = []
			data[item_id] = item_data

		if row.has("stock_id") and row["stock_id"] != null:
			var stock = {
				"id": row["stock_id"],
				"item_id": item_id,
				"location_id": row["location_id"],
				"quantity": row["quantity"],
				"amount": row["amount"],
				"mark": row["mark"]
			}
			data[item_id]["stocks"].append(stock)

	return data


func get_all_subcategories(category_ids: Array) -> Array:
	var result := category_ids.duplicate()
	var to_check := category_ids.duplicate()
	while to_check.size() > 0:
		var current_id = to_check.pop_back()
		var rows = db.select_rows("categories", "parent_id = " + str(current_id), ["id"])
		for row in rows:
			var child_id = row["id"]
			if not result.has(child_id):
				result.append(child_id)
				to_check.append(child_id)
	return result


func get_all_sublocations(location_ids: Array) -> Array:
	var result := location_ids.duplicate()
	var to_check := location_ids.duplicate()
	while to_check.size() > 0:
		var current_id = to_check.pop_back()
		var rows = db.select_rows("locations", "parent_id = " + str(current_id), ["id"])
		for row in rows:
			var child_id = row["id"]
			if not result.has(child_id):
				result.append(child_id)
				to_check.append(child_id)
	return result
