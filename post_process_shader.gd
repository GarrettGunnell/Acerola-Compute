@tool
extends CompositorEffect
class_name PostProcessShader

const template_shader : String  = "#version 450

// Invocations in the (x, y, z) dimension (thread group sizes)
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// Our push constant (cbuffer??)
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 reserved;
} params;

// main function/kernel?
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	
	if (uv.x >= size.x || uv.y >= size.y) return;
	
	vec4 color = imageLoad(color_image, uv);
	
	color *= params.reserved.x;
	
	imageStore(color_image, uv, color);
}
"

@export_group("Shader Settings")
@export_range(0, 2) var exposure = 1.0


var rd : RenderingDevice
var shader : RID
var pipeline : RID

var mutex : Mutex  = Mutex.new()
var shader_is_dirty : bool = true

func _init():
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			rd.free_rid(shader)


func _check_shader() -> bool:
	if not rd:
		return false
	
	var new_shader_code : String = ""
	
	mutex.lock()
	if shader_is_dirty:
		new_shader_code = template_shader
		shader_is_dirty = false
	mutex.unlock()

	if new_shader_code.is_empty():
		return pipeline.is_valid()
		
	new_shader_code = template_shader
	
	if shader.is_valid():
		rd.free_rid(shader)
		shader = RID()
		pipeline = RID()
		
	var shader_source : RDShaderSource = RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL	
	shader_source.source_compute = new_shader_code
	var shader_spirv : RDShaderSPIRV = rd.shader_compile_spirv_from_source(shader_source)
	
	if shader_spirv.compile_error_compute != "":
		push_error(shader_spirv.compile_error_compute)
		push_error("In: " + new_shader_code)
		return false
		
	shader = rd.shader_create_from_spirv(shader_spirv)
	if not shader.is_valid():
		return false
		
	pipeline = rd.compute_pipeline_create(shader)
	return pipeline.is_valid()
	
func _render_callback(p_effect_callback_type, p_render_data):
	if rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and _check_shader():
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
			push_constant.push_back(exposure)
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
