extends Control

var action_recever = null
var what_to_do = Global.WhatToDo.None

func _ready():
	hide()


func _on_cancel_tree_selection_pressed():
	reset_values()
	hide()


func confirme_action(recever, conf_what_to_do):
	action_recever = recever
	what_to_do = conf_what_to_do
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
