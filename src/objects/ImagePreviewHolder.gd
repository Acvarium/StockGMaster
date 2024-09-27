extends Control
var current_image_path = ""
var is_selected = false
var image_selection_dialogue : Control

func _ready():
	pass

func set_image_path(image_path):
	current_image_path = image_path
	

func load_image(image_path):
	current_image_path = image_path
	var image = Image.load_from_file(image_path)
	var texture = ImageTexture.create_from_image(image)
	$Panel/TextureRect.texture = texture


func select(to_select = false):
	is_selected = to_select
	$SelectedPanel.visible = is_selected


func _on_button_pressed():
	image_selection_dialogue.select_image(self)
		
