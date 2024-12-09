@tool
extends HSlider


func _on_line_edit_text_submitted(new_text: String) -> void:
	value = float(new_text)
