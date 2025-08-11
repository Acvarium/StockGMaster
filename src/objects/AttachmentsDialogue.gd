extends Control
var action_recever = null
var current_item_id = -1
var current_attachment_data = {}
@onready var main_node = get_tree().get_root().get_node("Main")
@export var attachment_viewer : Control


func _ready() -> void:
	Global.edit_attachments_for_item.connect(edit_attachments_for_item)


func edit_attachments_for_item(recever, item_id):
	action_recever = recever
	current_item_id = item_id
	current_attachment_data.clear()
	current_attachment_data = main_node.get_attachmetns_for_item(current_item_id)
	attachment_viewer.refrash_tags_list(current_attachment_data)
	show()
	


func _on_cancel_button_pressed() -> void:
	hide()
