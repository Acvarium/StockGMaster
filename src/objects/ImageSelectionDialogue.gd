extends Control
var image_holder_prefab = preload("res://objects/ImagePreviewHolder.tscn")
@onready var image_grid : GridContainer = $ItemsPanel/ScrollContainer/ImageGridContainer


func clear_images():
	for image_prev in image_grid.get_children():
		image_prev.queue_free()


func load_images(image_paths):
	clear_images()
	

func _ready() -> void:
	clear_images()
