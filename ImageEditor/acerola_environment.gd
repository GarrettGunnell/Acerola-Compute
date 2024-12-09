@tool
extends WorldEnvironment
class_name AcerolaEnvironment

@export var reload : bool

@export var effects_list : VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	if effects_list == null: return

	var effects_set = effects_list.get_children()

	var compositorEffects : Array = Array()
	for effect in effects_set:
		var exposureShader = PostProcessShader.new()
		exposureShader.shader_file_path = "res://Shaders/color_correct.glsl"
		exposureShader.exposure = effect.get_exposure()

		compositorEffects.push_back(exposureShader)

	compositor.set_compositor_effects(compositorEffects)
	compositor.notify_property_list_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if effects_list == null: return

	var effects_set = effects_list.get_children()

	var compositorEffects : Array = Array()
	for effect in effects_set:
		var exposureShader = PostProcessShader.new()
		exposureShader.shader_file_path = "res://Shaders/color_correct.glsl"
		exposureShader.exposure = effect.get_exposure()

		compositorEffects.push_back(exposureShader)

	compositor.set_compositor_effects(compositorEffects)
	compositor.notify_property_list_changed()

	if reload:
		_ready()
		reload = false
		notify_property_list_changed()
