extends Control
var profile_selection_elements = []
var profile_elem_prefab = preload("res://objects/profile_selection_element.tscn")
@export var profiles_holder : Control
@onready var main_node = get_tree().get_root().get_node("Main")
var new_profile_id = -1

func _ready():
	Global.profiles_loaded.connect(refrash_profile_list)


func show_stock_data_components(to_show = true):
	new_profile_id = -1



func clear_list():
	profile_selection_elements.clear()
	for o in profiles_holder.get_children():
		o.queue_free()


func refrash_profile_list():
	clear_list()
	var profiles = Global.profiles
	for i in range(profiles.size()):
		add_profile_list_element(i)
		

func add_profile_list_element(profile_id):
	var prof_element = profile_elem_prefab.instantiate()
	prof_element.profile_selection_dialogue = self
	prof_element.set_profile(profile_id, Global.profiles[profile_id])
	prof_element.set_selected(Global.current_profile_id == profile_id)
	profiles_holder.add_child(prof_element, true)


func select_profile(profile_id):
	new_profile_id = profile_id
	update_selection()
	#Global.current_profile_id = profile_id


func update_selection():
	for pb in profiles_holder.get_children():
		if pb.has_method("select_profile_element"):
			pb.select_profile_element(new_profile_id == pb.profile_id)


func _on_cancel_button_pressed():
	main_node.shoe_profile_selection_dialogue(false)


func _on_save_item_button_pressed() -> void:
	if new_profile_id >= 0 && new_profile_id != Global.current_profile_id:
		Global.current_profile_id = new_profile_id
		Global.save_config()
		Global.restart()
	main_node.shoe_profile_selection_dialogue(false)


func _on_add_button_pressed() -> void:
	main_node.create_profile()
