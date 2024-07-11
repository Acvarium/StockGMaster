extends Control
var profile_selection_elements = []
var profile_elem_prefab = preload("res://objects/profile_selection_element.tscn")
@export var profiles_holder : Control

func _ready():
	refrash_profile_list()


func clear_list():
	profile_selection_elements.clear()
	for o in profiles_holder.get_children():
		o.queue_free()


func refrash_profile_list():
	clear_list()
	for i in range(Global.profile_names.size()):
		add_profile_list_element(i)
		

func add_profile_list_element(profile_id):
	var prof_element = profile_elem_prefab.instantiate()
	prof_element.set_profile_id(profile_id)
	prof_element.set_selected(Global.current_profile_id == profile_id)
	profiles_holder.add_child(prof_element, true)


func select_profile(profile_id):
	Global.current_profile_id = profile_id
	
