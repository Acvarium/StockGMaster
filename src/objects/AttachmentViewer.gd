extends HFlowContainer
var att_element_prefab = preload("res://objects/AttachmentElement.tscn")


func clear_att():
	for a in get_children():
		a.queue_free()


func refrash_att_list(_data):
	clear_att()
	if _data != null:
		for a in _data:
			var new_att = att_element_prefab.instantiate()
			new_att.set_file_path(a.path)
			add_child(new_att)
