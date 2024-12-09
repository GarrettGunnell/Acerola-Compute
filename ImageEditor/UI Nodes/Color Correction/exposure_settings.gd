@tool
extends VBoxContainer

var exposureSliders : Array

var exposure : Vector4 = Vector4(1, 1, 1, 1)

func _ready() -> void:
	exposureSliders = find_children("LineEdit", "", true, true)
	for i in exposureSliders:
		print(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	exposure.x = float(exposureSliders[0].text)
	exposure.y = float(exposureSliders[1].text)
	exposure.z = float(exposureSliders[2].text)
	exposure.w = float(exposureSliders[3].text)

func get_exposure() -> Vector4:
	return exposure;
