#include <metal_stdlib>
using namespace metal;

struct PassVertexOut {
	float4 position [[position]];
	float2 texcoord [[user(texcoord)]];
};

vertex PassVertexOut pass_vertex_shader(uint vertex_id [[vertex_id]]) {
	float2 positions[4] = {
		float2(-1.0, -1.0),
		float2(1.0, -1.0),
		float2(-1.0, 1.0),
		float2(1.0, 1.0)
	};

	PassVertexOut out;
	out.position = float4(positions[vertex_id], 0.0, 1.0);
	out.texcoord = (positions[vertex_id] + 1) / 2;
	return out;
}

fragment float4 pass_fragment(float2 texcoord [[user(texcoord)]]) {
	return float4(texcoord, 0.0, 1.0);
}
