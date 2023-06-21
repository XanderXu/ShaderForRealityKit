//
//  GlitchScreenShake.metal
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
void postProcessScreenShakeHorizontal(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ScreenShakeArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    float _Time = args->time;
    float _Intensity = args->intensity;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    
    // 计算错位后的坐标
    float shake = (randomNoise(float2(_Time, 2)) - 0.5) * _Intensity;
    
    half2 offsetUV = fract(half2(uv.x + shake, uv.y)) * inSize;
    uint2 xy = uint2(offsetUV);
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessScreenShakeVertical(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ScreenShakeArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    float _Time = args->time;
    float _Intensity = args->intensity;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    
    // 计算错位后的坐标
    float shake = (randomNoise(float2(_Time, 2)) - 0.5) * _Intensity;
    
    half2 offsetUV = fract(half2(uv.x, uv.y + shake)) * inSize;
    uint2 xy = uint2(offsetUV);
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}
