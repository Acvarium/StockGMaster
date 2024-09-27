extends Control
var image_holder_prefab = preload("res://objects/ImagePreviewHolder.tscn")
@onready var image_grid : GridContainer = $ItemsPanel/ScrollContainer/ImageGridContainer
@onready var main_node = get_tree().get_root().get_node("Main")

func clear_images():
	for image_prev in image_grid.get_children():
		image_prev.queue_free()


func load_images(image_paths):
	clear_images()
	
	for im in [""] + image_paths:
		var new_image_holder = image_holder_prefab.instantiate()
		image_grid.add_child(new_image_holder)
		new_image_holder.set_image_path(im)
		if im != "":
			new_image_holder.load_image(main_node.get_image_folder_path() + im)
		new_image_holder.image_selection_dialogue = self


func select_image(image_item_to_select):
	for image_prev in image_grid.get_children():
		image_prev.select(image_item_to_select == image_prev)


func get_selected_image_path():
	for image_prev in image_grid.get_children():
		if image_prev.is_selected:
			return image_prev.current_image_path
	return ""


func _ready() -> void:
	clear_images()
