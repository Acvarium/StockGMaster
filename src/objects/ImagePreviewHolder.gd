extends Control
var current_image_path = ""

func _ready():
	pass


func load_image(image_path):
	current_image_path = image_path
	var image = Image.load_from_file(image_path)
	var texture = ImageTexture.create_from_image(image)
	$TextureRect.texture = texture
