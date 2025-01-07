#version 450

// Invocations in the (x, y, z) dimension (thread group sizes)
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// layout(binding = 1) uniform UniformBufferObject {
// 	int _KernelSize;
// };

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

	vec3 colorSum = vec3(0);

	int kernelSize = 10;

	for (int x = -kernelSize; x <= kernelSize; ++x) {
		colorSum += imageLoad(color_image, ivec2(uv.x + x, uv.y)).rgb;
	}
	
	vec4 color = vec4(colorSum / (kernelSize * 2), 1.0);
	
	imageStore(color_image, uv, color);
}