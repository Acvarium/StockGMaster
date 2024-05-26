extends Control
@export var tag_space : HFlowContainer
var tag_element_prefab = preload("res://objects/tag_element.tscn")


func _ready():
	pass # Replace with function body.


func clear_tags():
	for t in tag_space.get_children():
		t.queue_free()


func refrash_items_list(tag_data):
	clear_tags()
	for t in tag_data:
		var new_tag = tag_element_prefab.instantiate()
		new_tag.set_text(tag_data[t].name)
		new_tag.tag_id = t
		tag_space.add_child(new_tag)
		
