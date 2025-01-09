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

		var byte_array = PackedInt32Array([kernel_size, 0, 0, 0]).to_byte_array()

		var uniform_buffer = rd.uniform_buffer_create(byte_array.size(), byte_array)

		
		blurCompute.set_texture(0, input_image)
		blurCompute.set_uniform_buffer(1, uniform_buffer)
		blurCompute.set_push_constant(push_constant.to_byte_array())

		blurCompute.dispatch(0, x_groups, y_groups, z_groups)
		blurCompute.dispatch(1, x_groups, y_groups, z_groups)

		rd.free_rid(uniform_buffer)
