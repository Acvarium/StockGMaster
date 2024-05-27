extends Control
@export var warning_label : Label
@export var title_label : Label
@export var conf_button : Button
@export var canc_button : Button
@export var acc_button : Button

var action_recever = null
var what_to_do = Global.WhatToDo.None
var base_title_label = "Are you sure?"

func _ready():
	hide()


func _on_cancel_tree_selection_pressed():
	reset_values()
	hide()


func confirme_action_dialogue(recever, conf_what_to_do, warning_message : String = ""):
	warning_label.text = warning_message
	warning_label.visible = !warning_message.is_empty()
	action_recever = recever
	what_to_do = conf_what_to_do
	title_label.text = base_title_label
	conf_button.visible = true
	canc_button.visible = true
	acc_button.visible = false
	show()


func warning_dialogue(warning_message, title : String = ""):
	title_label.text = base_title_label
	if title != "":
		title_label.text = title
	
	warning_label.text = warning_message
	warning_label.visible = true
	conf_button.visible = false
	canc_button.visible = false
	acc_button.visible = true
	show()
	


func reset_values():
	what_to_do = Global.WhatToDo.None
	action_recever = null


func _on_confirm_button_pressed():
	if action_recever and what_to_do != Global.WhatToDo.None:
		action_recever.confirme_action(what_to_do)
	reset_values()
	hide()


func _on_cancel_button_pressed():
	reset_values()
	hide()


func _on_accept_button_pressed():
	reset_values()
	hide()
