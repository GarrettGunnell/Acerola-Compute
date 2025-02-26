@tool
extends CompositorEffect
class_name ExposureCompositorEffect

@export_group("Shader Settings")
@export var exposure = Vector4(2, 1, 1, 1)

var rd : RenderingDevice
var exposure_compute : ACompute

func _init():
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()

	# To make use of an existing ACompute shader we use its filename to access it, in this case, the example compute shader file is 'exposure_example.acompute'
	exposure_compute = ACompute.new('exposure_example')


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# ACompute will handle the freeing of any resources attached to it
		exposure_compute.free()


func _render_callback(p_effect_callback_type, p_render_data):
	if not enabled: return
	if p_effect_callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT: return
	
	if not rd:
		push_error("No rendering device")
		return
	
	var render_scene_buffers : RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()

	if not render_scene_buffers:
		push_error("No buffer to render to")
		return

	
	var size = render_scene_buffers.get_internal_size()
	if size.x == 0 and size.y == 0:
		push_error("Rendering to 0x0 buffer")
		return
	
	var x_groups = (size.x - 1) / 8 + 1
	var y_groups = (size.y - 1) / 8 + 1
	var z_groups = 1
	
	# Vulkan has a feature known as push constants which are like uniform sets but for very small amounts of data
	var push_constant : PackedFloat32Array = PackedFloat32Array([size.x, size.y, 0.0, 0.0])
	
	for view in range(render_scene_buffers.get_view_count()):
		var input_image = render_scene_buffers.get_color_layer(view)

		# Pack the exposure vector into a byte array
		var uniform_array = PackedFloat32Array([exposure.x, exposure.y, exposure.z, exposure.w]).to_byte_array()

		# ACompute handles uniform caching under the hood, as long as the exposure value doesn't change or the render target doesn't change, these functions will only do work once
		exposure_compute.set_texture(0, input_image)
		exposure_compute.set_uniform_buffer(1, uniform_array)
		exposure_compute.set_push_constant(push_constant.to_byte_array())

		# Dispatch the compute kernel
		exposure_compute.dispatch(0, x_groups, y_groups, z_groups)
