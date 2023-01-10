//
//  SurfaceShader.metal
//  S02_Noise
//
//  Created by CoderXu on 2023/1/10.
//

#include <metal_stdlib>
using namespace metal;
//导入 RealityKit 的头文件
#include <RealityKit/RealityKit.h>
#include "NoiseLibrary.h"

[[visible]]//shader 的修饰符
void sinNoiseSurface(realitykit::surface_parameters params)
{
    float4 customVector = params.uniforms().custom_parameter();
    float time = params.uniforms().time();
    float2 uv = params.geometry().uv0();
    // Flip the texture coordinates y-axis. This is only needed for entities
    // loaded from USDZ or .reality files.
    uv = float2(uv.x, 1-uv.y);
    
    float r = sinNoise(uv.x + time*0.01 * customVector.x);
    params.surface().set_base_color(half3(r,r,r));
    params.surface().set_roughness(1.0);
}


[[visible]]//shader 的修饰符
void randomNoiseSurface(realitykit::surface_parameters params)
{
    float4 customVector = params.uniforms().custom_parameter();
    float time = params.uniforms().time();
    float2 uv = params.geometry().uv0();
    // Flip the texture coordinates y-axis. This is only needed for entities
    // loaded from USDZ or .reality files.
    uv = float2(uv.x, 1-uv.y);
    
    float r = randomNoise(uv + float2(sin(time*0.01)) * customVector.x);
    params.surface().set_base_color(half3(r,r,r));
    params.surface().set_roughness(1.0);
}
