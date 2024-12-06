@tool
extends WorldEnvironment
class_name AcerolaEnvironment

@export var reload : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var exposure : PostProcessShader = PostProcessShader.new()
	exposure.shader_file_path = "res://Shaders/color_correct.glsl"
	exposure.exposure = Vector3(2, 1, 1)
	print("readying")
	
	var compositorEffects : Array = Array()
	compositorEffects.push_back(exposure)

	var exposure2 : PostProcessShader = PostProcessShader.new()
	exposure2.shader_file_path = "res://Shaders/color_correct.glsl"
	exposure2.exposure = Vector3(1, 3, 1)
	compositorEffects.push_back(exposure2)
	compositor.set_compositor_effects(compositorEffects)
	compositor.notify_property_list_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if reload:
		_ready()
		reload = false
		notify_property_list_changed()
