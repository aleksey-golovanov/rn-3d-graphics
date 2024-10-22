#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 uv;
};

struct Uniforms {
    float4x4 rotationX;
    float4x4 rotationY;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]])
{
    float4 position = uniforms.rotationX * uniforms.rotationY * float4(vertex_in.position);
    
    VertexOut out;
    
    out.position = position;
    out.normal = vertex_in.normal;
    out.uv = vertex_in.uv;

    return out;
}

constant float3 ambientIntensity = 0.1;
constant float3 lightVector(1, 0, 1);
constant float3 lightColor(1, 1, 1);

fragment float4 fragment_main(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]])
{
    // texture
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);

    float3 baseColor = texture.sample(textureSampler, in.uv).rgb;
    
    // diffuse light
    float3 N = normalize(in.normal.xyz);
    float3 L = normalize(lightVector);
    
    float3 diffuseIntensity = saturate(dot(N, L));
    
    // final color with diffuse and ambient light
    float3 finalColor = saturate(ambientIntensity + diffuseIntensity) * lightColor * baseColor;
    
    return float4(finalColor, 1);
}
