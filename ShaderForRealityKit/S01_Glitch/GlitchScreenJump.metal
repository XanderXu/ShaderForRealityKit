//
//  GlitchScreenJump.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

[[kernel]]
void postProcessScreenJumpHorizontal(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ScreenJumpArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    float _JumpTime = args->jumpTime;
    float _JumpIntensity = args->jumpIntensity;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    
    // 计算错位后的坐标
    float jump = mix(uv.x, fract(uv.x + _JumpTime), _JumpIntensity);
    
    half2 offsetUV = fract(half2(jump, uv.y)) * inSize;
    uint2 xy = uint2(offsetUV);
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessScreenJumpVertical(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ScreenJumpArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    float _JumpTime = args->jumpTime;
    float _JumpIntensity = args->jumpIntensity;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    
    // 计算错位后的坐标
    float jump = mix(uv.y, fract(uv.y + _JumpTime), _JumpIntensity);
    
    half2 offsetUV = fract(half2(uv.x, jump)) * inSize;
    uint2 xy = uint2(offsetUV);
    half3 finalColor = inColor.read(xy).rgb;
   
    outColor.write(half4(finalColor,1), gid);
}
