#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
	float3 color [[attribute(1)]];
};

struct VertexOut {
	float4 position [[position]];
	float3 color;
};

struct GBufferOut {
	float4 position [[color(0)]];
	float3 color [[color(1)]];
};

vertex VertexOut gbuffer_vertex_shader(VertexIn vertex_in [[stage_in]]) {
	VertexOut out;
	out.position = float4(vertex_in.position, 1.0);
	out.color = vertex_in.color;
	return out;
}

fragment GBufferOut gbuffer_fragment_shader(VertexOut fragment_in [[stage_in]]) {
	GBufferOut out;
	out.position = fragment_in.position;
	out.color = fragment_in.color;
	return out;
}
