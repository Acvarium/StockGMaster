extends ScrollContainer

var dragging := false
var last_mouse_pos := Vector2.ZERO


func _ready() -> void:
	gui_input.connect(_gui_input)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				last_mouse_pos = event.position
				accept_event()
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position

		scroll_horizontal -= int(delta.x)
		scroll_vertical -= int(delta.y)
		accept_event()
