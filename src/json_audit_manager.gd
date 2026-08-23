extends Node
class_name AuditManager
var audit_data := {}

func update_data():
	audit_data = load_all_json_audits()


func load_all_json_audits() -> Dictionary:
	var audit_data: Dictionary = {}
	var dir_path: String = Global.json_audit_dir
	
	if dir_path.is_empty() or not DirAccess.dir_exists_absolute(dir_path):
		return audit_data
		
	var dir = DirAccess.open(dir_path)
	if not dir:
		return audit_data
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var full_path = dir_path.path_join(file_name)
			var file = FileAccess.open(full_path, FileAccess.READ)
			
			if file:
				var json_string = file.get_as_text()
				file.close()
				
				var json = JSON.new()
				var error = json.parse(json_string)
				
				if error == OK:
					var file_key = file_name.get_basename()
					audit_data[file_key] = json.data
				else:
					push_error("Помилка парсингу JSON у файлі %s: %s" % [file_name, json.get_error_message()])
					
		file_name = dir.get_next()
		
	dir.list_dir_end()
	return audit_data


func fuzzy_search_items(query: String, max_distance: int = 2) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var clean_query = query.strip_edges().to_lower()
	
	if clean_query.is_empty():
		return results

	for file_key in audit_data:
		var entry = audit_data[file_key]
		if not entry is Dictionary or not entry.has("items") or not entry.has("location"):
			continue
			
		var location = entry["location"]
		var items = entry["items"]
		
		for item in items:
			var item_name = str(item)
			var clean_item = item_name.to_lower()
			
			if clean_query in clean_item:
				results.append({"item": item_name, "location": location})
				continue
				
			var words = clean_item.split(" ")
			var matched = false
			
			for word in words:
				if abs(word.length() - clean_query.length()) <= max_distance:
					if _levenshtein_distance(clean_query, word) <= max_distance:
						matched = true
						break
			
			if matched:
				results.append({"item": item_name, "location": location})

	return results


func _levenshtein_distance(s1: String, s2: String) -> int:
	var len1 = s1.length()
	var len2 = s2.length()
	
	var matrix = []
	for i in range(len1 + 1):
		var row = []
		row.resize(len2 + 1)
		matrix.append(row)
		
	for i in range(len1 + 1):
		matrix[i][0] = i
	for j in range(len2 + 1):
		matrix[0][j] = j
		
	for i in range(1, len1 + 1):
		for j in range(1, len2 + 1):
			var cost = 0 if s1[i - 1] == s2[j - 1] else 1
			matrix[i][j] = min(
				matrix[i - 1][j] + 1,      # видалення
				min(
					matrix[i][j - 1] + 1,  # вставка
					matrix[i - 1][j - 1] + cost # заміна
				)
			)
			
	return matrix[len1][len2]
