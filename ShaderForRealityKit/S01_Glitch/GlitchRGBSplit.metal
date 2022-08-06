//
//  GlitchRGBSplit.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/6.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

[[kernel]]
void postProcessRGBSplit(uint2 gid [[thread_position_in_grid]],
                       texture2d<half, access::read> inColor [[texture(0)]],
                       texture2d<half, access::write> outColor [[texture(1)]],
                         constant GlitchArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    half _Fading = 1;//0~1
    half _Amount = 1;//0~5
    half _Speed = 1;//0~10
    half _CenterFading = 1;//0~1
    half _AmountR = 1;//0~5
    half _AmountB = 1;//0~5
    half _TimeX = args->time;
    
    float2 uv = float2(gid.x/inColor.get_width(), gid.y/inColor.get_height());
    half time = _TimeX * 6 * _Speed;
    
    half splitAmount = (1.0 + sin(time)) * 0.5;
    splitAmount *= 1.0 + sin(time * 2) * 0.5;
    splitAmount = pow(splitAmount, 3.0h);
    splitAmount *= 0.05;
    half distance = length(uv - float2(0.5, 0.5));
    splitAmount *= _Fading * _Amount;
    splitAmount *= mix(1.0h, distance, _CenterFading);
    
    float offsetX = splitAmount * inColor.get_width();
    uint x = min(gid.x + uint(offsetX * _AmountR), inColor.get_width()-1);
    half3 colorR = inColor.read(uint2(x, gid.y)).rgb;
    half4 sceneColor = inColor.read(gid);
    half3 colorB = inColor.read(uint2(gid.x - offsetX * _AmountB, gid.y)).rgb;
    
    half3 splitColor = half3(colorR.r, sceneColor.g, colorB.b);
    half3 finalColor = mix(sceneColor.rgb, splitColor, _Fading);
    
    outColor.write(half4(finalColor,1.0h), gid);
}

