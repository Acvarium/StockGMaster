extends VBoxContainer
@export var unfold_item_list : Array[NodePath]
@export var control_children = false
var unfold_items = []

func _ready():
	if !control_children:
		for i in range(unfold_item_list.size()):
			if has_node(unfold_item_list[i]) and get_node(unfold_item_list[i]).has_method("set_unfold_control"):
				unfold_items.append(get_node(unfold_item_list[i]))
				get_node(unfold_item_list[i]).set_unfold_control(self)


func unfold(item, to_unfold):
	if item and !to_unfold:
		item.unfold(false)
	else:
		if !control_children:
			for i in unfold_items:
				i.unfold(i == item)
		else:
			for c in get_children():
				if c.has_method("unfold"):
					c.unfold(c == item)


func refresh_unfold():
	if !control_children:
		for i in unfold_items:
			if i.get_unfolded():
				i.unfold(true, true, true)
	else:
		for c in get_children():
			if c.has_method("get_unfolded") and c.get_unfolded():
				c.unfold(true, true, true)
					

func fold_all():
	unfold(null, false)
