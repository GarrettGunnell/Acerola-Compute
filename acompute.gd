extends Object
class_name ACompute


var kernels = Array()
var rd : RenderingDevice
var uniform_set : RID
var shader_file : String


func get_kernel(index: int) -> RID:
	return kernels[index]


func _init(shader_name: String) -> void:
	rd = RenderingServer.get_rendering_device()

	shader_file = shader_name

	print("Creating new ACompute object from: " + shader_file + " file")

	for kernel in AcerolaShaderCompiler.get_compute_kernel_compilations('blur'):
		kernels.push_back(rd.compute_pipeline_create(kernel))


func free() -> void:
	for kernel in kernels:
		rd.free_rid(kernel)
