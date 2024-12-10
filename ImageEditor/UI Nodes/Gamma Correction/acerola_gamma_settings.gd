@tool
extends VBoxContainer

var gammaSlider : LineEdit

var gamma : float = 1.0

func _ready() -> void:
	gammaSlider = find_child("LineEdit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	gamma = float(gammaSlider.text)

func get_gamma() -> float:
	return gamma;
