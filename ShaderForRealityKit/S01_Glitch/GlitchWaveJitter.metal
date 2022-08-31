//
//  GlitchWaveJitter.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/31.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
#include "XNoiseLibrary.h"
using namespace metal;

[[kernel]]
void postProcessWaveJitterHorizontal(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant WaveJitterArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Speed = args->speed;
    half _Amount = args->amount;
    int type = args->type;
    half _RGBSplitIndensity = args->RGBSplitIndensity;
    half2 _Resolution = half2(args->resolution);
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    float time = _TimeX * _Speed;
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 1;
    }
    
    // 计算抖动
    float uv_y = uv.y * _Resolution.y;
    float noise_wave_1 = snoise(float2(uv_y * 0.01, time * 20)) * (strength * _Amount * 32.0);
    float noise_wave_2 = snoise(float2(uv_y * 0.02, time * 10)) * (strength * _Amount * 4.0);
    float noise_wave_x = noise_wave_1 * noise_wave_2 / _Resolution.x;
    float uv_x = uv.x + noise_wave_x;
    float rgbSplit_uv_x = (_RGBSplitIndensity * 50 + (20.0 * strength + 1.0)) * noise_wave_x / _Resolution.x;
    
    // 计算分离后的坐标
    half2 offsetG = half2(uv_x, uv.y) * inSize;
    half2 offsetRB = half2(uv_x + rgbSplit_uv_x, uv.y) * inSize;
    uint2 gxy = uint2(clamp(offsetG, 0, inSize-1));
    uint2 rbxy = uint2(clamp(offsetRB, 0, inSize-1));
    // 读取颜色
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorRB = inColor.read(rbxy).rgb;
    
    half4 finalColor = half4(colorRB.r, colorG.g, colorRB.b, 1);
   
    outColor.write(finalColor, gid);
}

[[kernel]]
void postProcessWaveJitterVertical(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant WaveJitterArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Speed = args->speed;
    half _Amount = args->amount;
    int type = args->type;
    half _RGBSplitIndensity = args->RGBSplitIndensity;
    half2 _Resolution = half2(args->resolution);
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    float time = _TimeX * _Speed;
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 1;
    }
    
    // 计算抖动
    float uv_x = uv.x * _Resolution.x;
    float noise_wave_1 = snoise(float2(uv_x * 0.01, time * 20)) * (strength * _Amount * 32.0);
    float noise_wave_2 = snoise(float2(uv_x * 0.02, time * 10)) * (strength * _Amount * 4.0);
    float noise_wave_y = noise_wave_1 * noise_wave_2 / _Resolution.x;
    float uv_y = uv.y + noise_wave_y;
    float rgbSplit_uv_y = (_RGBSplitIndensity * 50 + (20.0 * strength + 1.0)) * noise_wave_y / _Resolution.y;
    
    // 计算分离后的坐标
    half2 offsetG = half2(uv.x, uv_y) * inSize;
    half2 offsetRB = half2(uv.x, uv_y + rgbSplit_uv_y) * inSize;
    uint2 gxy = uint2(clamp(offsetG, 0, inSize-1));
    uint2 rbxy = uint2(clamp(offsetRB, 0, inSize-1));
    // 读取颜色
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorRB = inColor.read(rbxy).rgb;
    
    half4 finalColor = half4(colorRB.r, colorG.g, colorRB.b, 1);
   
    outColor.write(finalColor, gid);
}
