extends Control
var action_receiver = null
var current_attachment_data : Array
@onready var main_node = get_tree().get_root().get_node("Main")
@export var attachment_viewer : Control
@export var del_button : Button
var undo_action = false

func _ready() -> void:
	Global.edit_attachments_for_item.connect(edit_attachments_for_item)


func edit_attachments_for_item(receiver, att_data : Array):
	action_receiver = receiver
	current_attachment_data = att_data.duplicate(true)
	refrash_current_att_list()
	show()
	
	
func add_files_from_paths(paths):
	for i in range(paths.size()):
		current_attachment_data.append({"id" : (-1 - i), "path" : paths[i]})
	refrash_current_att_list()


func refrash_current_att_list():
	attachment_viewer.refrash_tags_list(current_attachment_data)


func _on_cancel_button_pressed() -> void:
	hide()


func _on_add_att_pressed() -> void:
	main_node.open_file_selection_dialogue(self)


func _on_confirm_button_pressed() -> void:
	if action_receiver != null:
		action_receiver.update_attachments(current_attachment_data)
	current_attachment_data.clear()
	hide()


func _on_del_att_pressed() -> void:
	var selected = attachment_viewer.get_selected_ids()
	for a in current_attachment_data:
		if a.id in selected:
			a.delete = not undo_action
	refrash_current_att_list()
	await get_tree().create_timer(0.02).timeout
	_on_attachment_viewer_tag_pressed_sig()


func _on_attachment_viewer_tag_pressed_sig() -> void:
	var selected = attachment_viewer.get_selected_ids()
	undo_action = selected.size() > 0
	for a in current_attachment_data:
		if a.id in selected:
			if not "delete" in a.keys() or a.delete != true:
				undo_action = false
				break
	if undo_action:
		del_button.text = "Undo"
	else:
		del_button.text = "Del"
