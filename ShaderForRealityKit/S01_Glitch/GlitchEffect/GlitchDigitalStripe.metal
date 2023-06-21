//
//  GlitchDigitalStripe.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

[[kernel]]
void postProcessDigitalStripeHorizontal(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           texture2d<half, access::read> noise [[texture(2)]],
                              constant DigitalStripeArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    
    // 参数传递
    int _NeedStripColorAdjust = args->needStripColorAdjust;
    half _Intensity = args->intensity;
    half3 _StripColorAdjustColor = half3(args->stripColorAdjustColor);
    half _StripColorAdjustIntensity = args->stripColorAdjustIntensity;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    // 基础数据准备
    half4 stripNoise = noise.read(uint2(uv * half2(noise.get_width(), noise.get_height())));
    half threshold = 1.001 - _Intensity * 1.001;

    // uv偏移
    half uvShift = step(threshold, pow(abs(stripNoise.x), 3));
    half2 uv2 = fract(uv + stripNoise.yz * uvShift);
    // 计算错位后的坐标
    half2 offset = uv2 * inSize;
    uint2 xy = uint2(clamp(offset, 0, inSize-1));
    half4 source = inColor.read(xy);

    if (_NeedStripColorAdjust == 0) {
        outColor.write(source, gid);
    } else {
        // 基于废弃帧插值
        half stripIntensity = step(threshold, pow(abs(stripNoise.w), 3)) * _StripColorAdjustIntensity;
        half3 color = mix(source.rgb, _StripColorAdjustColor, stripIntensity);
        outColor.write(half4(color, 1), gid);
    }
}

[[kernel]]
void postProcessDigitalStripeVertical(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           texture2d<half, access::read> noise [[texture(2)]],
                              constant DigitalStripeArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    
    // 参数传递
    int _NeedStripColorAdjust = args->needStripColorAdjust;
    half _Intensity = args->intensity;
    half3 _StripColorAdjustColor = half3(args->stripColorAdjustColor);
    half _StripColorAdjustIntensity = args->stripColorAdjustIntensity;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    // 基础数据准备
    half4 stripNoise = noise.read(uint2(uv.yx * half2(noise.get_height(), noise.get_width())));
    half threshold = 1.001 - _Intensity * 1.001;

    // uv偏移
    half uvShift = step(threshold, pow(abs(stripNoise.x), 3));
    half2 uv2 = fract(uv + stripNoise.yz * uvShift);
    // 计算错位后的坐标
    half2 offset = uv2 * inSize;
    uint2 xy = uint2(clamp(offset, 0, inSize-1));
    half4 source = inColor.read(xy);

    if (_NeedStripColorAdjust == 0) {
        outColor.write(source, gid);
    } else {
        // 基于废弃帧插值
        half stripIntensity = step(threshold, pow(abs(stripNoise.w), 3)) * _StripColorAdjustIntensity;
        half3 color = mix(source.rgb, _StripColorAdjustColor, stripIntensity);
        outColor.write(half4(color, 1), gid);
    }
}
