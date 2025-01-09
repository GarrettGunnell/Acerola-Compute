@tool
extends CompositorEffect
class_name BlurCompositorEffect

@export_group("Shader Settings")
@export var kernel_size : int = 1


var rd : RenderingDevice
var horizontalBlurShader : RID

var blurCompute : ACompute

func _init():
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	
	horizontalBlurShader = AcerolaShaderCompiler.get_compute_kernel_compilation('blur', 0)

	blurCompute = ACompute.new('blur')


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		blurCompute.free()


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
	
	var push_constant : PackedFloat32Array = PackedFloat32Array()
	push_constant.push_back(size.x)
	push_constant.push_back(size.y)
	push_constant.push_back(0.0)
	push_constant.push_back(0.0)
	
	var view_count = render_scene_buffers.get_view_count()
	for view in range(view_count):
		var input_image = render_scene_buffers.get_color_layer(view)

		var currentFrame : RDUniform = RDUniform.new()
		currentFrame.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		currentFrame.binding = 0
		currentFrame.add_id(input_image)

		var byte_array = PackedInt32Array([kernel_size, 3, 5, 7]).to_byte_array()

		var uniform_buffer = rd.uniform_buffer_create(byte_array.size(), byte_array)

		var uniformBuffer : RDUniform = RDUniform.new()
		uniformBuffer.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		uniformBuffer.binding = 1
		uniformBuffer.add_id(uniform_buffer)
		var uniform_set = UniformSetCacheRD.get_cache(horizontalBlurShader, 0, [currentFrame, uniformBuffer])
		
		blurCompute.set_uniform_set(uniform_set)
		blurCompute.set_push_constant(push_constant.to_byte_array())

		blurCompute.dispatch(0, x_groups, y_groups, z_groups)
		blurCompute.dispatch(1, x_groups, y_groups, z_groups)


		# var compute_list := rd.compute_list_begin()
		# rd.compute_list_bind_compute_pipeline(compute_list, blurCompute.get_kernel(0))
		# rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		# rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
		# rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
		# rd.compute_list_bind_compute_pipeline(compute_list, blurCompute.get_kernel(1))
		# rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
		# rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
		# rd.compute_list_end()

		rd.free_rid(uniform_buffer)
