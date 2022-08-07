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
                         constant RGBSplitArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    half _Fading = args->fading;
    half _Amount = args->amount;
    half _Speed = args->speed;
    half _CenterFading = args->centerFading;
    half2 _AmountR = half2(args->amountR);
    half2 _AmountB = half2(args->amountB);
    half _TimeX = args->time;
    
    uint2 inSize = uint2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    half time = _TimeX * 6 * _Speed;
    
    half splitAmount = (1.0 + sin(time)) * 0.5;
    splitAmount *= 1.0 + sin(time * 2) * 0.5;
    splitAmount = pow(splitAmount, 3.0h);
    splitAmount *= 0.05;
    half distance = length(uv - half2(0.5, 0.5));
    splitAmount *= _Fading * _Amount;
    splitAmount *= mix(1.0h, distance, _CenterFading);
    
    half2 offset = splitAmount * half2(inSize);
//    uint2 rxy = clamp(gid + uint2(offset * _AmountR), uint2(1), inSize-1);
//    uint2 bxy = clamp(gid - uint2(offset * _AmountB), uint2(1), inSize-1);
    uint2 rxy = min(gid + uint2(offset * _AmountR), inSize-1);
    uint2 bxy = max(gid - uint2(offset * _AmountB), 1);
    
    half3 colorR = inColor.read(rxy).rgb;
    half4 sceneColor = inColor.read(gid);
    half3 colorB = inColor.read(bxy).rgb;
    
    half4 splitColor = half4(colorR.r, sceneColor.g, colorB.b, 1);
    half4 finalColor = mix(sceneColor, splitColor, _Fading);
    
    outColor.write(finalColor, gid);
}

