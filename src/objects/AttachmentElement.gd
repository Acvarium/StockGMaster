extends PanelContainer
const texture_base_path = "res://textures/file_icons/"

func set_file_path(_path):
	$HB/Label.text = _path
	var extension = _path.get_extension().to_lower()
	print(extension)
	set_icon_by_ext(extension)
	

func set_icon_by_ext(ext):
	if ext == "mp4" or ext == "mkv" or ext == "mov":
		ext = "video"
	elif ext == "mp3" or ext == "wav" or ext == "ogg":
		ext = "music"
	
	if FileAccess.file_exists(texture_base_path + ext + ".svg"):
		set_icon(ext + ".svg")


func set_icon(icon_path):
	$HB/Control/Icon.texture = load(texture_base_path + icon_path)
