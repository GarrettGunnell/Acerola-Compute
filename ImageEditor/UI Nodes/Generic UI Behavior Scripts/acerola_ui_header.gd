extends PanelContainer

@export var collapsibleContainer : CollapsibleContainer

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			collapsibleContainer.open_tween_toggle()
