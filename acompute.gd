extends Object
class_name ACompute


var kernels = Array()
var rd : RenderingDevice
var uniform_set : RID
var shader_file : String
var shader_info : RID
var push_constant : PackedByteArray
var uniform_set_cache : Array


func get_kernel(index: int) -> RID:
	return kernels[index]


func set_uniform_set(_uniform_set: RID) -> void:
	uniform_set = _uniform_set


func set_push_constant(_push_constant: PackedByteArray) -> void:
	push_constant = PackedByteArray(_push_constant)


func set_texture(binding: int, texture: RID) -> void:
	var u : RDUniform = RDUniform.new()
	u.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u.binding = binding
	u.add_id(texture)

	cache_uniform(u)

func set_uniform_buffer(binding: int, uniform_buffer: RID) -> void:
	var u : RDUniform = RDUniform.new()
	u.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	u.binding = binding
	u.add_id(uniform_buffer)

	cache_uniform(u)


func cache_uniform(u: RDUniform) -> void:
	if uniform_set_cache.size() - 1 < u.binding:
		uniform_set_cache.resize(u.binding + 1)

	uniform_set_cache[u.binding] = u


func _init(shader_name: String) -> void:
	rd = RenderingServer.get_rendering_device()

	uniform_set_cache = Array()

	shader_file = shader_name

	shader_info = AcerolaShaderCompiler.get_compute_kernel_compilation(shader_file, 0)

	for kernel in AcerolaShaderCompiler.get_compute_kernel_compilations(shader_file):
		kernels.push_back(rd.compute_pipeline_create(kernel))


func dispatch(kernel_index: int, x_groups: int, y_groups: int, z_groups: int) -> void:
	uniform_set = UniformSetCacheRD.get_cache(shader_info, 0, uniform_set_cache)

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
