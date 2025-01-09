extends Object
class_name ACompute


var kernels = Array()
var rd : RenderingDevice
var uniform_set : RID
var shader_file : String
var shader_info : RID
var push_constant : PackedByteArray


func set_uniform_set(_uniform_set: RID) -> void:
	uniform_set = _uniform_set


func set_push_constant(_push_constant: PackedByteArray) -> void:
	push_constant = PackedByteArray(_push_constant)


func get_kernel(index: int) -> RID:
	return kernels[index]


func _init(shader_name: String) -> void:
	rd = RenderingServer.get_rendering_device()

	shader_file = shader_name

	print("Creating new ACompute object from: " + shader_file + " file")

	shader_info = AcerolaShaderCompiler.get_compute_kernel_compilation(shader_file, 0)

	for kernel in AcerolaShaderCompiler.get_compute_kernel_compilations(shader_file):
		kernels.push_back(rd.compute_pipeline_create(kernel))


func dispatch(kernel_index: int, x_groups: int, y_groups: int, z_groups: int) -> void:
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, kernels[kernel_index])
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
	rd.compute_list_end()


func free() -> void:
	for kernel in kernels:
		rd.free_rid(kernel)

	rd.free_rid(uniform_set)