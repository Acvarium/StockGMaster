extends VBoxContainer
@export var unfold_item_list : Array[NodePath]
var unfold_items = []


func _ready():
	for i in range(unfold_item_list.size()):
		if has_node(unfold_item_list[i]) and get_node(unfold_item_list[i]).has_method("set_unfold_control"):
			unfold_items.append(get_node(unfold_item_list[i]))
			get_node(unfold_item_list[i]).set_unfold_control(self)


func unfold(item, to_unfold):
	if !to_unfold:
		item.unfold(false)
	else:
		for i in unfold_items:
			i.unfold(i == item)
