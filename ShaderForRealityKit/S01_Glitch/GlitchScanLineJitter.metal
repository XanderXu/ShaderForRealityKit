//
//  GlitchScanLineJitter.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/28.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

inline float randomNoise(float x, float y)
{
    return fract(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
}

[[kernel]]
void postProcessScanLineJitterHorizontal(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ScanLineJitterArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Amount = args->amount;
    int type = args->type;
    half _Threshold = args->threshold;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 1;
    }
    
    // 计算错位后的坐标
    float jitter = randomNoise(uv.y, _TimeX/20) * 2 - 1;
    jitter *= step(float(_Threshold), abs(jitter)) * _Amount * strength;
    uv = fract(uv + float2(jitter, 0));
    
    half2 offsetUV = half2(uv) * inSize;
    uint2 xy = uint2(offsetUV);//clamp(offsetUV, 0, inSize-1));
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessScanLineJitterVertical(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ScanLineJitterArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Amount = args->amount;
    int type = args->type;
    half _Threshold = args->threshold;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 1;
    }
    
    // 计算错位后的坐标
    float jitter = randomNoise(uv.x, _TimeX/20) * 2 - 1;
    jitter *= step(float(_Threshold), abs(jitter)) * _Amount * strength;
    uv = fract(uv + float2(0, jitter));
    
    half2 offsetUV = half2(uv) * inSize;
    uint2 xy = uint2(offsetUV);//clamp(offsetUV, 0, inSize-1));
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}
