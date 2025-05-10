extends Panel
@onready var current_page_LE : LineEdit = $PagesHBox/PageNumControl/CurrentPageLE
@onready var number_of_pages_Label : Label = $PagesHBox/PageNumControl/NumberOfPagesLabel


func _ready() -> void:
	pass


func _on_current_page_le_text_changed(new_text: String) -> void:
	var current_caret_column = current_page_LE.caret_column
	current_page_LE.text = str(int(current_page_LE.text))
	if current_caret_column > current_page_LE.text.length():
		current_page_LE.caret_column = current_page_LE.text.length()
	else:
		current_page_LE.caret_column = current_caret_column

	
