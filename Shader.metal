// Shader.metal

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float3 position [[attribute(0)]];
	float3 color [[attribute(1)]];
};

struct Fragment {
	float4 position [[position]];
	float3 color;
};

vertex Fragment vertex_shader(Vertex vertex_in [[stage_in]]) {
	Fragment out;
	out.position = float4(vertex_in.position, 1.0);
	out.color = vertex_in.color;
	return out;
}

fragment float4 fragment_shader(Fragment fragment_in [[stage_in]]) {
    return float4(fragment_in.color, 1.0);
}
