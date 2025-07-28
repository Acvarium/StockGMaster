extends Control
var current_image_path = ""
var is_selected = false
var is_active = false
var image_selection_dialogue : Control
var is_none_image = false

func _ready():
	pass

func set_image_path(image_path):
	current_image_path = image_path
	

func load_image(image):
	var texture = ImageTexture.create_from_image(image)
	$Panel/TextureRect.texture = texture


func select(to_select = false):
	is_selected = to_select
	$SelectedPanel.visible = is_selected


func activate(to_activate = false):
	is_active = to_activate
	$ActivePanel.visible = is_active


func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if Input.is_physical_key_pressed(KEY_CTRL):
			image_selection_dialogue.select_image(self, true)
		else:
			image_selection_dialogue.select_image(self)
