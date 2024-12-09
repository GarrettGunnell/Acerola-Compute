@tool
extends WorldEnvironment
class_name AcerolaEnvironment

@export var reload : bool

@export var colorCorrectionSettings : ColorCorrectionUI

var exposureShader : PostProcessShader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exposureShader = PostProcessShader.new()
	exposureShader.shader_file_path = "res://Shaders/color_correct.glsl"
	exposureShader.exposure = Vector4(1, 1, 1, 1)
	
	var compositorEffects : Array = Array()
	compositorEffects.push_back(exposureShader)

	compositor.set_compositor_effects(compositorEffects)
	compositor.notify_property_list_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	exposureShader.exposure = colorCorrectionSettings.get_exposure()
	var compositorEffects : Array = Array()
	compositorEffects.push_back(exposureShader)

	compositor.set_compositor_effects(compositorEffects)
	compositor.notify_property_list_changed()

	if reload:
		_ready()
		reload = false
		notify_property_list_changed()
