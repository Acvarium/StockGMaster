extends Label
@export var aspect : float = 0.5

func _ready():
	get_tree().get_root().get_viewport().size_changed.connect(window_resized)
	window_resized()
	
	
func window_resized():
	await get_tree().process_frame
	set("theme_override_font_sizes/font_size", size.y * aspect)
