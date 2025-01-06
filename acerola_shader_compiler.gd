@tool
extends Node

var shader_file_regex = RegEx.new()

var shader_files : Array = Array()

var rd : RenderingDevice

var shader_compilations = {}
var shader_code_cache = {}

func find_files(dir_name) -> void:
	var dir = DirAccess.open(dir_name)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				find_files(dir_name + '/' + file_name)
			else:
				if file_name.get_extension() == 'glsl'and shader_file_regex.search(file_name):
					shader_files.push_back(dir_name + '/' + file_name)
			
			file_name = dir.get_next()


func compile_shader(shader_file_path) -> void:
	var shader_name = shader_file_path.split("/")[-1].split(".glsl")[0]

	if shader_compilations.has(shader_name):
		if shader_compilations[shader_name].is_valid():
			print("Freeing: " + shader_name)
			rd.free_rid(shader_compilations[shader_name])
	
	var shader_code = FileAccess.open(shader_file_path, FileAccess.READ).get_as_text()
	shader_code_cache[shader_name] = shader_code

	var shader_compilation = RID()

	var shader_source : RDShaderSource = RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	shader_source.source_compute = shader_code
	var shader_spirv : RDShaderSPIRV = rd.shader_compile_spirv_from_source(shader_source)

	if shader_spirv.compile_error_compute != "":
		push_error(shader_spirv.compile_error_compute)
		push_error("In: " + shader_code)
		return
		
	print("Compiling: " + shader_name)
	shader_compilation = rd.shader_create_from_spirv(shader_spirv)

	if not shader_compilation.is_valid():
		return

	shader_compilations[shader_name] = shader_compilation


func _init() -> void:
	rd = RenderingServer.get_rendering_device()
	
	shader_file_regex.compile("acerolafx")
	
	find_files("res://")


	for shader_file in shader_files:
		compile_shader(shader_file)

	print(shader_files)
	print(shader_compilations)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for shader_file in shader_files:
		var shader_name = shader_file.split("/")[-1].split(".glsl")[0]
		var shader_code = FileAccess.open(shader_file, FileAccess.READ).get_as_text()
		if shader_code != shader_code_cache[shader_name]:
			compile_shader(shader_file)


func _notification(what):
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_WM_CLOSE_REQUEST:
		var shader_names = shader_compilations.keys()

		for shader_name in shader_names:
			var shader = shader_compilations[shader_name]
			if shader.is_valid():
				print("Freeing: " + shader_name)
				rd.free_rid(shader)


func get_shader_compilation(shader_name: String) -> RID:
	return shader_compilations[shader_name]
