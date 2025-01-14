@tool
extends CompositorEffect
class_name GammaCompositorEffect

@export_group("Shader Settings")
@export var gamma : float = 1.0


var rd : RenderingDevice
var gamma_compute : ACompute

func _init():
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	
	gamma_compute = ACompute.new('gamma')

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		gamma_compute.free()

	
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
	
	var push_constant : PackedFloat32Array = PackedFloat32Array([size.x, size.y, 0.0, 0.0])
	
	for view in range(render_scene_buffers.get_view_count()):
		var input_image = render_scene_buffers.get_color_layer(view)

		var uniform_array = PackedFloat32Array([gamma, 0, 0, 0]).to_byte_array()

		var uniform_buffer = rd.uniform_buffer_create(uniform_array.size(), uniform_array)

		gamma_compute.set_texture(0, input_image)
		gamma_compute.set_uniform_buffer(1, uniform_buffer)
		gamma_compute.set_push_constant(push_constant.to_byte_array())

		gamma_compute.dispatch(0, x_groups, y_groups, z_groups)

		rd.free_rid(uniform_buffer)
