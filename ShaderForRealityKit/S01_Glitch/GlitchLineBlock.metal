//
//  GlitchLineBlock.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/27.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

float randomNoise(float2 c)
{
    return fract(sin(dot(c.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float trunc(float x, float num_levels)
{
    return floor(x * num_levels) / num_levels;
}

float2 trunc(float2 x, float2 num_levels)
{
    return floor(x * num_levels) / num_levels;
}

float3 rgb2yuv(float3 rgb)
{
    float3 yuv;
    yuv.x = dot(rgb, float3(0.299, 0.587, 0.114));
    yuv.y = dot(rgb, float3(-0.14713, -0.28886, 0.436));
    yuv.z = dot(rgb, float3(0.615, -0.51499, -0.10001));
    return yuv;
}

float3 yuv2rgb(float3 yuv)
{
    float3 rgb;
    rgb.r = yuv.x + yuv.z * 1.13983;
    rgb.g = yuv.x + dot(float2(-0.39465, -0.58060), yuv.yz);
    rgb.b = yuv.x + yuv.y * 2.03211;
    return rgb;
}

[[kernel]]
void postProcessLineBlockHorizontal(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant LineBlockArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Amount = args->amount;
    half _Offset = args->offset;
    half _LinesWidth = args->linesWidth;
    half _Alpha = args->alpha;
    int type = args->type;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    float time = _TimeX * _Speed;
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 10;
    }
    time *= strength;
    
    
    // [1] 生成随机强度梯度线条
    float truncTime = trunc(time, 4.0);
    float uv_trunc = randomNoise(trunc(uv.yy, float2(8, 8)) + 100.0 * truncTime);
    float uv_randomTrunc = 6.0 * trunc(time, 24.0 * uv_trunc);
    
    // [2] 生成随机非均匀宽度线条
    float blockLine_random = 0.5 * randomNoise(trunc(uv.yy + uv_randomTrunc, float2(8 * _LinesWidth, 8 * _LinesWidth)));
    blockLine_random += 0.5 * randomNoise(trunc(uv.yy + uv_randomTrunc, float2(7, 7)));
    blockLine_random = blockLine_random * 2.0 - 1.0;
    blockLine_random = sign(blockLine_random) * saturate((abs(blockLine_random) - _Amount) / (0.4));
    blockLine_random = mix(0, blockLine_random, float(_Offset));
    
    // [3] 生成源色调的blockLine Glitch
    float2 uv_blockLine = uv;
    uv_blockLine = saturate(uv_blockLine + float2(0.1 * blockLine_random, 0));
    uint2 xy = uint2(clamp(half2(uv_blockLine) * inSize, 0, inSize-1));
    half4 blockLineColor = inColor.read(xy);
    
    // [4] 将RGB转到YUV空间，并做色调偏移
    // RGB -> YUV
    float3 blockLineColor_yuv = rgb2yuv(float3(blockLineColor.rgb));
    // adjust Chrominance | 色度
    blockLineColor_yuv.y /= 1.0 - 3.0 * abs(blockLine_random) * saturate(0.5 - blockLine_random);
    // adjust Chroma | 浓度
    blockLineColor_yuv.z += 0.125 * blockLine_random * saturate(blockLine_random - 0.5);
    half3 blockLineColor_rgb = half3(yuv2rgb(blockLineColor_yuv));
    
    // [5] 与源场景图进行混合
    half3 sceneColor = inColor.read(gid).rgb;
    half3 finalColor = mix(sceneColor, blockLineColor_rgb, _Alpha);
    
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessLineBlockVertical(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant LineBlockArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _Frequency = args->frequency;
    float _TimeX = args->time;
    half _Amount = args->amount;
    half _Offset = args->offset;
    half _LinesWidth = args->linesWidth;
    half _Alpha = args->alpha;
    int type = args->type;
    
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float2 uv = float2(gid) / float2(inSize);
    float time = _TimeX * _Speed;
    half strength = 0.5h + 0.5h * half(cos(_TimeX * _Frequency));
    if (type == 1) {
        strength = 10;
    }
    time *= strength;
    
    
    // [1] 生成随机强度梯度线条
    float truncTime = trunc(time, 4.0);
    float uv_trunc = randomNoise(trunc(uv.xx, float2(8, 8)) + 100.0 * truncTime);
    float uv_randomTrunc = 6.0 * trunc(time, 24.0 * uv_trunc);
    
    // [2] 生成随机非均匀宽度线条
    float blockLine_random = 0.5 * randomNoise(trunc(uv.xx + uv_randomTrunc, float2(8 * _LinesWidth, 8 * _LinesWidth)));
    blockLine_random += 0.5 * randomNoise(trunc(uv.xx + uv_randomTrunc, float2(7, 7)));
    blockLine_random = blockLine_random * 2.0 - 1.0;
    blockLine_random = sign(blockLine_random) * saturate((abs(blockLine_random) - _Amount) / (0.4));
    blockLine_random = mix(0, blockLine_random, float(_Offset));
    
    // [3] 生成源色调的blockLine Glitch
    float2 uv_blockLine = uv;
    uv_blockLine = saturate(uv_blockLine + float2(0.1 * blockLine_random, 0));
    uint2 xy = uint2(clamp(half2(uv_blockLine) * inSize, 0, inSize-1));
    half4 blockLineColor = inColor.read(xy);
    
    // [4] 将RGB转到YUV空间，并做色调偏移
    // RGB -> YUV
    float3 blockLineColor_yuv = rgb2yuv(float3(blockLineColor.rgb));
    // adjust Chrominance | 色度
    blockLineColor_yuv.y /= 1.0 - 3.0 * abs(blockLine_random) * saturate(0.5 - blockLine_random);
    // adjust Chroma | 浓度
    blockLineColor_yuv.z += 0.125 * blockLine_random * saturate(blockLine_random - 0.5);
    half3 blockLineColor_rgb = half3(yuv2rgb(blockLineColor_yuv));
    
    // [5] 与源场景图进行混合
    half3 sceneColor = inColor.read(gid).rgb;
    half3 finalColor = mix(sceneColor, blockLineColor_rgb, _Alpha);
    
    outColor.write(half4(finalColor,1), gid);
}
