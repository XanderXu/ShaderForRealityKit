//
//  GlitchImageBlock.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/16.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

inline float randomNoise(float2 seed)
{
    return fract(sin(dot(seed, float2(17.13, 3.71))) * 43758.5453123);
}

inline float randomNoise(float seed)
{
    return randomNoise(float2(seed, 1.0));
}

[[kernel]]
void postProcessImageBlock(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ImageBlockArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _BlockSize = args->blockSize;
    float _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    float time = _TimeX * _Speed;
    // 计算错位图块
    half block = randomNoise(float2(floor(uv * _BlockSize) * floor(time)));
    half displaceNoise = pow(block, 8.0h) * pow(block, 3.0h);
    half2 noiseXY = 0.1h * half2(randomNoise(13.0), randomNoise(7.0));
    // 计算错位后的坐标
    half2 offset = displaceNoise * inSize;
    uint2 gxy = uint2(clamp(half2(gid) + offset * noiseXY.y, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * noiseXY.x, 0, inSize-1));
    // 读取颜色
    half4 sceneColor = inColor.read(gid);
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(sceneColor.r, colorG.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}


[[kernel]]
void postProcessImageBlockV2(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ImageBlockArgumentsV2 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _BlockSize = args->blockSize;
    float _TimeX = args->time;
    half2 _MaxRGBSplit = half2(args->maxRGBSplit);
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    float time = _TimeX * _Speed;
    // 计算错位图块
    half block = randomNoise(float2(floor(uv * _BlockSize) * floor(time)));
    half displaceNoise = pow(block, 8.0h) * pow(block, 3.0h);
    half splitRGBNoise = pow(half(randomNoise(7.2341)), 17.0h);
    half2 offsetXY = displaceNoise - splitRGBNoise * _MaxRGBSplit;
    half2 noiseXY = 0.1h * half2(randomNoise(13.0), randomNoise(7.0));
    // 计算错位后的坐标
    half2 offset = offsetXY * inSize;
    uint2 gxy = uint2(clamp(half2(gid) + offset * noiseXY, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * noiseXY, 0, inSize-1));
    // 读取颜色
    half4 sceneColor = inColor.read(gid);
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(sceneColor.r, colorG.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessImageBlockV3(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ImageBlockArgumentsV3 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    float _TimeX = args->time;
    half _Amount = args->amount;
    half _Fade = args->fade;
    half _RGBSplit_Indensity = args->RGBSplitIndensity;
    half _BlockLayer1_Indensity = args->blockLayer1_Indensity;
    half2 _BlockLayer1_UV = half2(args->blockLayer1_UV);
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    float time = _TimeX * _Speed;
    // 计算错位图块
    half blockLayer1 = randomNoise(float2(floor(uv * _BlockLayer1_UV) * floor(time * 30)));
    half lineNoise1 = pow(blockLayer1, _BlockLayer1_Indensity);
    half rgbSplitNoise = pow(half(randomNoise(5.1379)), 7.1h) * _RGBSplit_Indensity;
    half lineNoise = lineNoise1 * _Amount - rgbSplitNoise;
    half2 noiseXY = 0.1h * half2(randomNoise(5.0), randomNoise(31.0));
    // 计算错位后的坐标
    half2 offset = lineNoise * inSize;
    uint2 gxy = uint2(clamp(half2(gid) + offset * noiseXY.x, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * noiseXY.y, 0, inSize-1));
    // 读取颜色
    half4 sceneColor = inColor.read(gid);
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(sceneColor.r, colorG.g, colorB.b);
    finalColor = mix(sceneColor.rgb, finalColor, _Fade);
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessImageBlockV4(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant ImageBlockArgumentsV4 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    float _TimeX = args->time;
    half _Amount = args->amount;
    half _Fade = args->fade;
    half _RGBSplit_Indensity = args->RGBSplitIndensity;
    half _BlockLayer1_Indensity = args->blockLayer1_Indensity;
    half2 _BlockLayer1_UV = half2(args->blockLayer1_UV);
    half _BlockLayer2_Indensity = args->blockLayer2_Indensity;
    half2 _BlockLayer2_UV = half2(args->blockLayer2_UV);
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / half2(inSize);
    float time = _TimeX * _Speed;
    // 计算错位图块
    half blockLayer1 = randomNoise(float2(floor(uv * _BlockLayer1_UV) * floor(time * 30)));
    half lineNoise1 = pow(blockLayer1, _BlockLayer1_Indensity);
    half blockLayer2 = randomNoise(float2(floor(uv * _BlockLayer2_UV) * floor(time * 30)));
    half lineNoise2 = pow(blockLayer2, _BlockLayer2_Indensity);
    
    half rgbSplitNoise = pow(randomNoise(5.1379), 7.1) * _RGBSplit_Indensity;
    half lineNoise = lineNoise1 * lineNoise2 * _Amount - rgbSplitNoise;
    half2 noiseXY = 0.1h * half2(randomNoise(7.0), randomNoise(23.0));
    // 计算错位后的坐标
    half2 offset = lineNoise * inSize;
    uint2 gxy = uint2(clamp(half2(gid) + offset * noiseXY.x, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * noiseXY.y, 0, inSize-1));
    // 读取颜色
    half4 sceneColor = inColor.read(gid);
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(sceneColor.r, colorG.g, colorB.b);
    finalColor = mix(sceneColor.rgb, finalColor, _Fade);
    outColor.write(half4(finalColor,1), gid);
}
