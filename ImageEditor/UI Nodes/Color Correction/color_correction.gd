@tool
extends BoxContainer
class_name ColorCorrectionUI

var exposure_settings : VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exposure_settings = find_child("Exposure Settings")

func get_exposure() -> Vector4:
	return exposure_settings.get_exposure()
