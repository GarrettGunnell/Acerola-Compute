@tool
extends WorldEnvironment
class_name AcerolaEnvironment

@export var reload : bool

@export var effects_list : VBoxContainer

func instantiate_shader_pipeline_from_effect(effect) -> CompositorEffect:
	if effect is ColorCorrectionUI:
		var color_correction_shader = ColorCorrectionCompositorEffect.new()
		color_correction_shader.exposure = effect.get_exposure()

		return color_correction_shader
	elif effect is GammaCorrectionUI:
		var gamma_correction_shader = GammaCompositorEffect.new()
		gamma_correction_shader.gamma = effect.get_gamma()

		return gamma_correction_shader

	return null
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	if effects_list == null: return

	var effects_set = effects_list.get_children()

	var compositor_effects : Array = Array()
	for effect in effects_set:
		compositor_effects.push_back(instantiate_shader_pipeline_from_effect(effect))

	compositor.set_compositor_effects(compositor_effects)
	compositor.notify_property_list_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if effects_list == null: return

	var effects_set = effects_list.get_children()

	var compositor_effects : Array = Array()
	for effect in effects_set:
		compositor_effects.push_back(instantiate_shader_pipeline_from_effect(effect))

	compositor.set_compositor_effects(compositor_effects)
	compositor.notify_property_list_changed()
