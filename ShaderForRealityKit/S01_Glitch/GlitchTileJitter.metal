//
//  GlitchTileJitter.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/28.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

[[kernel]]
void postProcessTileJitterHorizontal(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant TileJitterArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Amount = args->amount;
    int type = args->type;
    half _SplittingNumber = args->splittingNumber;
    float2 _Direction = args->direction;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    float time = _TimeX * _Speed;
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 1;
    }
    
    // 计算错位后的坐标
    if (fmod(uv.x * _SplittingNumber, 2) < 1.0) {
        uv += _Direction * 1/float(inSize.x) * cos(time) * _Amount * strength;
    }
    half2 offsetUV = half2(uv) * inSize;
    uint2 xy = uint2(clamp(offsetUV, 0, inSize-1));
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessTileJitterVertical(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant TileJitterArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Amount = args->amount;
    int type = args->type;
    half _SplittingNumber = args->splittingNumber;
    float2 _Direction = args->direction;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    float time = _TimeX * _Speed;
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 1;
    }
    
    // 计算错位后的坐标
    if (fmod(uv.y * _SplittingNumber, 2) < 1.0) {
        uv += _Direction * 1/float(inSize.y) * cos(time) * _Amount * strength;
    }
    half2 offsetUV = half2(uv) * inSize;
    uint2 xy = uint2(clamp(offsetUV, 0, inSize-1));
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}
