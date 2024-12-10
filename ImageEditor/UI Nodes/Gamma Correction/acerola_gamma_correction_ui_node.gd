@tool
extends BoxContainer
class_name GammaCorrectionUI

var gammaSlider : LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gammaSlider = find_child("LineEdit")

func get_gamma() -> float:
	return float(gammaSlider.text)
