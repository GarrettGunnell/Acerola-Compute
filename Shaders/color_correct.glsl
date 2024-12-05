#version 450

// Invocations in the (x, y, z) dimension (thread group sizes)
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// Our push constant (cbuffer??)
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 reserved;
	vec4 exposure;
} params;

// main function/kernel?
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	
	if (uv.x >= size.x || uv.y >= size.y) return;
	
	vec4 color = imageLoad(color_image, uv);
	
	color.rgb *= params.exposure.rgb + params.reserved.x + params.reserved.y;
	
	imageStore(color_image, uv, color);
}