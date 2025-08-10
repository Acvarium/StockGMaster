extends PopupMenu
var current_file_path : String

func _ready() -> void:
	Global.open_file_popup.connect(open_event)


func open_event(file_path, event_pos):
	current_file_path = file_path
	position = event_pos
	print(file_path)
	popup()


func _on_id_pressed(id: int) -> void:
	if id == 0:
		Global.open_file_at(current_file_path)
	elif id == 1:
		var folder_path = Global.get_attachments_folder_path()
		Global.open_file_at(folder_path)
		
	hide()
