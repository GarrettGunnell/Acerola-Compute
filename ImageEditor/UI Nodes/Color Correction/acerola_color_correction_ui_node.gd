@tool
extends BoxContainer
class_name ColorCorrectionUI

var exposure_settings : VBoxContainer

var enabled = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exposure_settings = find_child("Exposure Settings")


func get_exposure() -> Vector4:
	return exposure_settings.get_exposure()

func is_enabled() -> bool:
	return enabled


func _on_effect_name_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			enabled = !enabled
