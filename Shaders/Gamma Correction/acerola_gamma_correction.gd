@tool
extends CompositorEffect
class_name GammaCompositorEffect

@export_group("Shader Settings")
@export var gamma : float = 1.0


var rd : RenderingDevice
var shader : RID
var pipeline : RID

func _init(shader_rid):
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	
	shader = shader_rid
	pipeline = rd.compute_pipeline_create(shader)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		rd.free_rid(pipeline)

	
func _render_callback(p_effect_callback_type, p_render_data):
	if enabled and rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and pipeline.is_valid():
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
				
				var uniform : RDUniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform.binding = 0
				uniform.add_id(input_image)
				var uniform_set = UniformSetCacheRD.get_cache(shader, 0, [uniform])
				
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
