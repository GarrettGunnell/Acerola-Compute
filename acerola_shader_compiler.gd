@tool
extends Node

var shader_file_regex = RegEx.new()

var shader_files : Array = Array()
var compute_shader_files : Array = Array()

var rd : RenderingDevice

var shader_compilations = {}
var shader_code_cache = {}

var compute_shader_kernel_compilations = {}

func find_files(dir_name) -> void:
	var dir = DirAccess.open(dir_name)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				find_files(dir_name + '/' + file_name)
			else:
				# if file_name.get_extension() == 'glsl'and shader_file_regex.search(file_name):
				# 	shader_files.push_back(dir_name + '/' + file_name)

				if file_name.get_extension() == 'acompute':
					compute_shader_files.push_back(dir_name + '/' + file_name)
			
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


func compile_compute_shader(compute_shader_file_path) -> void:
	var compute_shader_name = compute_shader_file_path.get_file().split(".")[0]

	print("Compiling Compute Shader: " + compute_shader_name)

	var file = FileAccess.open(compute_shader_file_path, FileAccess.READ)
	var raw_shader_code_string = file.get_as_text()
	shader_code_cache[compute_shader_file_path] = raw_shader_code_string

	var raw_shader_code = raw_shader_code_string.split("\n")
	
	var kernel_names = Array()

	# Strip out kernel names
	while file.get_position() < file.get_length():
		var line = file.get_line()

		if line.begins_with("#kernel "):
			var kernel_name = line.split("#kernel")[1].strip_edges()
			# print("Kernel Found: " + kernel_name)
			kernel_names.push_back(kernel_name)
			raw_shader_code.remove_at(0)
		else:
			break

	# If no kernels defined at top of file, fail to compile
	if kernel_names.size() == 0:
		push_error("Failed to compile: " + compute_shader_file_path)
		push_error("Reason: No kernels found")
		return


	# If no code after kernel definitions or if nothing in file at all, fail to compile
	if file.get_position() >= file.get_length():
		push_error("Failed to compile: " + compute_shader_file_path)
		push_error("Reason: No shader code found")
		return

	# Verify kernels exist
	raw_shader_code_string = "\n".join(raw_shader_code)
	for kernel_name in kernel_names:
		if not raw_shader_code_string.contains(kernel_name):
			push_error("Failed to compile: " + compute_shader_file_path)
			push_error("Reason: " + kernel_name + " kernel not found!")

	var kernel_to_thread_group_count = {}

	# Find kernels and extract thread groups
	for i in raw_shader_code.size():
		var line = raw_shader_code[i]

		for kernel_name in kernel_names:
			if line.contains(kernel_name):
				# print("Found kernel " + kernel_name  + " at line " + str(i + kernel_names.size() + 1))

				# find thread group count by searching previous line of code from kernel function
				var newLine = raw_shader_code[i - 1].strip_edges()
				if newLine.contains('numthreads'):
					var thread_groups = newLine.split('(')[-1].split(')')[0].split(',')
					if thread_groups.size() != 3:
						push_error("Failed to compile: " + compute_shader_file_path)
						push_error("Reason: kernel thread group syntax error")

					kernel_to_thread_group_count[kernel_name] = Array()
					for n in thread_groups.size():
						kernel_to_thread_group_count[kernel_name].push_back((thread_groups[n].strip_edges()))

					raw_shader_code.set(i - 1, "")

					# print(kernel_to_thread_group_count[kernel_name])
				else:
					push_error("Failed to compile: " + compute_shader_file_path)
					push_error("Reason: kernel thread group count not found")
					return

	# Compile kernels
	compute_shader_kernel_compilations[compute_shader_name] = Array()
	for kernel_name in kernel_names:
		var shader_code = PackedStringArray(raw_shader_code)

		# Insert GLSL thread group layout for the kernel
		var thread_group = kernel_to_thread_group_count[kernel_name]
		shader_code.insert(0, "layout(local_size_x = " + thread_group[0] + ", local_size_y = " + thread_group[1] + ", local_size_z = " + thread_group[2] + ") in;")

		# Insert GLSL version at top of file
		shader_code.insert(0, "#version 450")

		# Replace kernel name with main
		var shader_code_string = "\n".join(shader_code).replace(kernel_name, "main")

		# Compile shader

		var shader_compilation = RID()

		var shader_source : RDShaderSource = RDShaderSource.new()
		shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
		shader_source.source_compute = shader_code_string
		var shader_spirv : RDShaderSPIRV = rd.shader_compile_spirv_from_source(shader_source)

		if shader_spirv.compile_error_compute != "":
			push_error(shader_spirv.compile_error_compute)
			push_error("In: " + shader_code_string)
			return
			
		print("Compiling Kernel: " + kernel_name)
		shader_compilation = rd.shader_create_from_spirv(shader_spirv)

		if not shader_compilation.is_valid():
			return

		compute_shader_kernel_compilations[compute_shader_name].push_back(shader_compilation)

		# print(shader_code_string)

	# print("\n".join(raw_shader_code))


func _init() -> void:
	rd = RenderingServer.get_rendering_device()
	
	shader_file_regex.compile("acerolafx")
	
	find_files("res://")


	for shader_file in shader_files:
		compile_shader(shader_file)

	# print(shader_files)
	# print(shader_compilations)
	print(compute_shader_files)

	for compute_shader_file in compute_shader_files:
		compile_compute_shader(compute_shader_file)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for compute_shader_file in compute_shader_files:
		var shader_code = FileAccess.open(compute_shader_file, FileAccess.READ).get_as_text()
		if shader_code != shader_code_cache[compute_shader_file]:
			for compute_shader in compute_shader_kernel_compilations.keys():
				for kernel in compute_shader_kernel_compilations[compute_shader]:
					rd.free_rid(kernel)

			compile_compute_shader(compute_shader_file)


func _notification(what):
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_WM_CLOSE_REQUEST:
		var shader_names = shader_compilations.keys()

		for shader_name in shader_names:
			var shader = shader_compilations[shader_name]
			if shader.is_valid():
				print("Freeing: " + shader_name)
				rd.free_rid(shader)

		for compute_shader in compute_shader_kernel_compilations.keys():
			for kernel in compute_shader_kernel_compilations[compute_shader]:
				rd.free_rid(kernel)


func get_shader_compilation(shader_name: String) -> RID:
	return shader_compilations[shader_name]

func get_compute_kernel_compilation(shader_name, kernel_index):
	return compute_shader_kernel_compilations[shader_name][kernel_index]
