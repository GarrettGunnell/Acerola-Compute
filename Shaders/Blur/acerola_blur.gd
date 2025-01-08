@tool
extends CompositorEffect
class_name BlurCompositorEffect

@export_group("Shader Settings")
@export var gamma : float = 1.0


var rd : RenderingDevice
var horizontalBlurShader : RID
var verticalBlurShader : RID
var horizontalPipeline : RID
var verticalPipeline : RID
var uniformBuffer : RID

func _init():
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	
	horizontalBlurShader = AcerolaShaderCompiler.get_compute_kernel_compilation('blur', 0)
	horizontalPipeline = rd.compute_pipeline_create(horizontalBlurShader)
	verticalBlurShader = AcerolaShaderCompiler.get_compute_kernel_compilation('blur', 1)
	verticalPipeline = rd.compute_pipeline_create(verticalBlurShader)

	var byte_array = PackedInt32Array([10, 3, 5, 7]).to_byte_array()

	uniformBuffer = rd.uniform_buffer_create(byte_array.size(), byte_array)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		rd.free_rid(horizontalPipeline)
		rd.free_rid(verticalPipeline)
		rd.free_rid(uniformBuffer)
	
func _render_callback(p_effect_callback_type, p_render_data):
	if enabled and rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and horizontalPipeline.is_valid():

		# if horizontalBlurShader != AcerolaShaderCompiler.get_shader_compilation('acerolafx_horizontal_blur'):
		# 	horizontalBlurShader = AcerolaShaderCompiler.get_shader_compilation('acerolafx_horizontal_blur')
		# 	horizontalPipeline = rd.compute_pipeline_create(horizontalBlurShader)

		# if verticalBlurShader != AcerolaShaderCompiler.get_shader_compilation('acerolafx_vertical_blur'):
		# 	verticalBlurShader = AcerolaShaderCompiler.get_shader_compilation('acerolafx_vertical_blur')
		# 	verticalPipeline = rd.compute_pipeline_create(verticalBlurShader)


		var render_scene_buffers : RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			var size = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return
				
			var x_groups = (size.x - 1) / 8 + 1
			var y_groups = (size.y - 1) / 8 + 1
			var z_groups = 1
			
			var push_constant : PackedFloat32Array = PackedFloat32Array()
			push_constant.push_back(size.x)
			push_constant.push_back(size.y)
			push_constant.push_back(gamma)
			push_constant.push_back(0.0)
			
			var view_count = render_scene_buffers.get_view_count()
			for view in range(view_count):
				var input_image = render_scene_buffers.get_color_layer(view)
				
				var currentFrame : RDUniform = RDUniform.new()
				currentFrame.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				currentFrame.binding = 0
				currentFrame.add_id(input_image)

				var uniformBuffer1 : RDUniform = RDUniform.new()
				uniformBuffer1.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
				uniformBuffer1.binding = 1
				uniformBuffer1.add_id(uniformBuffer)
				var uniform_set = UniformSetCacheRD.get_cache(horizontalBlurShader, 0, [currentFrame, uniformBuffer1])
				
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, horizontalPipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_bind_compute_pipeline(compute_list, verticalPipeline)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
