//
//  GlitchAnalogNoise.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

inline float randomNoise(float2 c)
{
    return fract(sin(dot(c, float2(12.9898, 78.233))) * 43758.5453);
}

[[kernel]]
void postProcessGlitchAnalogNoise(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant AnalogNoiseArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    float _TimeX = args->time;
    half _Fading = args->fading;
    half _LuminanceJitterThreshold = args->luminanceJitterThreshold;
    float time = _TimeX * _Speed;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    
    half3 sceneColor = inColor.read(gid).rgb;
    half3 noiseColor = sceneColor;
    // 计算颜色亮度，即黑白度，做为噪点颜色基准
    half luminance = dot(noiseColor, half3(0.22h, 0.707h, 0.071h));
    if (randomNoise(float2(time)) > _LuminanceJitterThreshold)
    {
        noiseColor = half3(luminance);
    }
    // 生成噪点颜色
    float noiseX = randomNoise(time + uv / float2(-213, 5.53));
    float noiseY = randomNoise(time - uv / float2(213, -5.53));
    float noiseZ = randomNoise(time + uv / float2(213, 5.53));
    // 添加到基准上
    noiseColor += 0.25 * half3(noiseX,noiseY,noiseZ) - 0.125;
    
    noiseColor = mix(sceneColor, noiseColor, _Fading);
    
    outColor.write(half4(noiseColor,1), gid);
}
