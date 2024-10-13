#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[stage_in]])
{
    VertexOut out;
    out.position = vertex_in.position;
    out.uv = vertex_in.uv;

    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]])
{
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    return texture.sample(textureSampler, in.uv);
}
