extends Control
var image_holder_prefab = preload("res://objects/ImagePreviewHolder.tscn")
@onready var image_grid : GridContainer = $ItemsPanel/ScrollContainer/ImageGridContainer


func clear_images():
	for image_prev in image_grid.get_children():
		image_prev.queue_free()


func load_images(image_paths):
	clear_images()
	for im in image_paths:
		var new_image_holder = image_holder_prefab.instantiate()
		image_grid.add_child(new_image_holder)
		new_image_holder.load_image(im)


func _ready() -> void:
	clear_images()
