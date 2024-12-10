@tool
extends LineEdit


func _on_h_slider_value_changed(value: float) -> void:
	text = str(value).pad_decimals(2)


func _on_text_submitted(new_text: String) -> void:
	text = str(float(new_text)).pad_decimals(2)


func _on_focus_exited() -> void:
	text_submitted.emit(text)
