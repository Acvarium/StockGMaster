extends PanelContainer
const texture_base_path = "res://textures/file_icons/"
var file_path : String
var tag_id : int = -1

func set_file_path(_path):
	file_path = _path
	$HB/Label.text = _path
	var extension = _path.get_extension().to_lower()
	set_icon_by_ext(extension)
	var file_exists = FileAccess.file_exists(Global.get_attachments_folder_path() + file_path)
	if file_path != file_path.get_file():
		file_exists = FileAccess.file_exists(file_path)
	if file_exists:
		modulate.a = 1
	else:
		modulate.a = 0.5


func get_button():
	return $Button

func set_color(new_color : Color):
	modulate.r = new_color.r
	modulate.g = new_color.g
	modulate.b = new_color.b
	

func get_pressed():
	return $Button.button_pressed


func set_selectable(value):
	$Button.toggle_mode = value


func set_icon_by_ext(ext):
	if ext == "mp4" or ext == "mkv" or ext == "mov":
		ext = "video"
	elif ext == "mp3" or ext == "wav" or ext == "ogg":
		ext = "music"
	
	if FileAccess.file_exists(texture_base_path + ext + ".svg"):
		set_icon(ext + ".svg")


func set_icon(icon_path):
	$HB/Control/Icon.texture = load(texture_base_path + icon_path)


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.double_click and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		Global.open_file_at(Global.get_attachments_folder_path() + file_path)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		Global.open_file_popup.emit(Global.get_attachments_folder_path() + file_path, event.global_position)
