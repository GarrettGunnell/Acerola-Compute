@tool
extends BoxContainer
class_name GammaCorrectionUI

var gammaSlider : LineEdit

var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gammaSlider = find_child("LineEdit")

func get_gamma() -> float:
	return float(gammaSlider.text)


func is_enabled() -> bool:
	return enabled

func _on_effect_name_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			enabled = !enabled
