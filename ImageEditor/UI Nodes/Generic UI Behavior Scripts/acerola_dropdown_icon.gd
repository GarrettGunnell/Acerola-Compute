@tool
extends Label

var open = false;

func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			open = !open
			if open:
				text = ">"
			else:
				text = "v"
