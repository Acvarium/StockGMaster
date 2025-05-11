extends Panel
@onready var current_page_LE : LineEdit = $PagesHBox/PageNumControl/CurrentPageLE
@onready var number_of_pages_Label : Label = $PagesHBox/PageNumControl/NumberOfPagesLabel
signal page_changed(new_page)

var current_page : int = 1
var last_page : int = 100


func _ready() -> void:
	inc_page(0)


func set_last_page(new_last_page : int, to_reset_current = false):
	last_page = new_last_page
	if to_reset_current:
		current_page = 1 
	inc_page(0)
	

func _on_current_page_le_text_changed(new_text: String) -> void:
	var current_caret_column = current_page_LE.caret_column
	current_page_LE.text = str(int(current_page_LE.text))
	if current_caret_column > current_page_LE.text.length():
		current_page_LE.caret_column = current_page_LE.text.length()
	else:
		current_page_LE.caret_column = current_caret_column


func update_page_view():
	$PagesHBox/PageNumControl/CurrentPageLE.text = str(current_page)
	$PagesHBox/PageNumControl/NumberOfPagesLabel.text = str(last_page)


func inc_page(value : int):
	var next_page = current_page + value
	if next_page < 1:
		next_page = last_page
	elif next_page > last_page:
		next_page = 1
	current_page = next_page
	update_page_view()
	page_changed.emit(current_page)


func _on_next_page_button_pressed() -> void:
	inc_page(1)


func _on_prev_page_button_pressed() -> void:
	inc_page(-1)


func _on_first_page_button_pressed() -> void:
	current_page = 1
	inc_page(0)
	

func _on_last_page_button_pressed() -> void:
	current_page = last_page
	inc_page(0)
