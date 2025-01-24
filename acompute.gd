@tool
extends Object
class_name ACompute


var kernels = Array()
var rd : RenderingDevice
var shader_name : String
var shader_id : RID
var push_constant : PackedByteArray
var uniform_set_gpu_id : RID
var uniform_set_cache : Array
var current_bound_uniform_set_cpu_copy : Array

var refresh_uniforms = true

# Contains the contents of the uniform array itself
var uniform_buffer_cache = {}
# Contains the RIDs for the gpu versions of the uniform array
var uniform_buffer_id_cache = {}

func get_kernel(index: int) -> RID:
	return kernels[index]


func set_push_constant(_push_constant: PackedByteArray) -> void:
	push_constant = PackedByteArray(_push_constant)


func set_texture(binding: int, texture: RID) -> void:
	var u : RDUniform = RDUniform.new()
	u.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u.binding = binding
	u.add_id(texture)

	cache_uniform(u)


func set_uniform_buffer(binding: int, uniform_array: PackedByteArray) -> void:
	# Check if buffer exists already and hasn't changed
	if uniform_buffer_cache.has(binding):
		if uniform_array == uniform_buffer_cache.get(binding):
			return

	# Check if buffer exists in gpu memory and release if so
	if uniform_buffer_id_cache.has(binding):
		rd.free_rid(uniform_buffer_id_cache.get(binding))

	var uniform_buffer_id = rd.uniform_buffer_create(uniform_array.size(), uniform_array)
	
	var u : RDUniform = RDUniform.new()
	u.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	u.binding = binding
	u.add_id(uniform_buffer_id)

	# Cache array contents and RID
	uniform_buffer_cache[binding] = PackedByteArray(uniform_array)
	uniform_buffer_id_cache[binding] = uniform_buffer_id

	cache_uniform(u)


func cache_uniform(u: RDUniform) -> void:
	if uniform_set_cache.size() - 1 < u.binding:
		refresh_uniforms = true
		uniform_set_cache.resize(u.binding + 1)

	# If uniform has had its info changed then set flag to refresh gpu side uniform data
	if uniform_set_cache[u.binding]:
		var old_uniform_ids = uniform_set_cache[u.binding].get_ids()
		var new_uniform_ids = u.get_ids()
		
		if old_uniform_ids.size() != new_uniform_ids.size(): 
			refresh_uniforms = true
		else:
			for i in old_uniform_ids.size():
				if old_uniform_ids[i].get_id() != new_uniform_ids[i].get_id():
					refresh_uniforms = true
					break


	uniform_set_cache[u.binding] = u


func _init(_shader_name: String) -> void:
	rd = RenderingServer.get_rendering_device()

	uniform_set_cache = Array()

	shader_name = _shader_name

	shader_id = AcerolaShaderCompiler.get_compute_kernel_compilation(shader_name, 0)

	for kernel in AcerolaShaderCompiler.get_compute_kernel_compilations(shader_name):
		kernels.push_back(rd.compute_pipeline_create(kernel))


func dispatch(kernel_index: int, x_groups: int, y_groups: int, z_groups: int) -> void:
	var global_shader_id = AcerolaShaderCompiler.get_compute_kernel_compilation(shader_name, 0)

	# Recreate kernel pipelines if shader was recompiled
	if shader_id != global_shader_id:
		shader_id = global_shader_id
		kernels.clear()
		for kernel in AcerolaShaderCompiler.get_compute_kernel_compilations(shader_name):
			kernels.push_back(rd.compute_pipeline_create(kernel))

	# Reallocate GPU memory if uniforms need updating
	if refresh_uniforms:
		if uniform_set_gpu_id.is_valid(): rd.free_rid(uniform_set_gpu_id)
		uniform_set_gpu_id = rd.uniform_set_create(uniform_set_cache, global_shader_id, 0)
		refresh_uniforms = false
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, kernels[0])
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_gpu_id, 0)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
	rd.compute_list_add_barrier(compute_list)
	rd.compute_list_bind_compute_pipeline(compute_list, kernels[1])
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
	rd.compute_list_end()


func free() -> void:
	for kernel in kernels:
		rd.free_rid(kernel)

	for binding in uniform_buffer_id_cache.keys():
		rd.free_rid(uniform_buffer_id_cache[binding])

	if uniform_set_gpu_id.is_valid(): rd.free_rid(uniform_set_gpu_id)
