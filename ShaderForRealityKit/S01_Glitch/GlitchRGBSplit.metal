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
    // 参数传递
    half _Fading = args->fading;
    half _Amount = args->amount;
    half _Speed = args->speed;
    half _CenterFading = args->centerFading;
    half2 _AmountR = half2(args->amountR);
    half2 _AmountB = half2(args->amountB);
    half _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half2 uv = half2(gid) / inSize;
    half time = _TimeX * 6 * _Speed;
    // 计算抖动曲线
    half splitAmount = (1.0h + sin(time)) * 0.5h;
    splitAmount *= 1.0h + sin(time * 2) * 0.5h;
    splitAmount = pow(splitAmount, 3.0h);
    splitAmount *= 0.05h;
    splitAmount *= _Fading * _Amount;
    // 中心到边缘抖动幅度渐变
    half distance = length(uv - half2(0.5h, 0.5h));
    splitAmount *= mix(1.0h, distance, _CenterFading);
    
    // 计算分离后的坐标
    half2 offset = splitAmount * inSize;
    uint2 rxy = uint2(clamp(half2(gid) + offset * _AmountR, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * _AmountB, 0, inSize-1));
    // 读取颜色
    half3 colorR = inColor.read(rxy).rgb;
    half4 sceneColor = inColor.read(gid);
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half4 splitColor = half4(colorR.r, sceneColor.g, colorB.b, 1);
    half4 finalColor = mix(sceneColor, splitColor, _Fading);
    
    outColor.write(finalColor, gid);
}

[[kernel]]
void postProcessRGBSplitV2(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           constant RGBSplitArgumentsV2 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Amount = args->amount;
    half _Speed = args->speed;
    half _Amplitude = args->amplitude;
    half2 _Direction = half2(args->direction);
    half _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half time = _TimeX * _Speed;
    // 计算抖动曲线
    half splitAmount = (1.0h + sin(time * 6.0h)) * 0.5h;
    splitAmount *= 1.0h + sin(time * 16.0h) * 0.5h;
    splitAmount *= 1.0h + sin(time * 19.0h) * 0.5h;
    splitAmount *= 1.0h + sin(time * 27.0h) * 0.5h;
    splitAmount = pow(splitAmount, _Amplitude);
    splitAmount *= (0.05h * _Amount);
    
    // 计算分离后的坐标
    half2 offset = splitAmount * inSize;
    uint2 rxy = uint2(clamp(half2(gid) + offset * _Direction, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * _Direction, 0, inSize-1));
    // 读取颜色
    half3 colorR = inColor.read(rxy).rgb;
    half4 sceneColor = inColor.read(gid);
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(colorR.r, sceneColor.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}

[[kernel]]
void postProcessRGBSplitV3(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           constant RGBSplitArgumentsV3 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Amount = args->amount;
    half _Speed = args->speed;
    half _Frequency = args->frequency;
    int type = args->type;
    half2 _Direction = half2(args->direction);
    half _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half time = _TimeX * _Speed;
    
    // 计算抖动曲线
    half strength = 0.5h + 0.5h * cos(_TimeX * _Frequency);
    if (type == 1) {
        strength = 1;
    }
    _Amount *= 0.001h * strength;
    half splitAmountR= sin(time * 0.2h) * _Amount;
    half splitAmountB= sin(time * 0.1h) * _Amount;
    
    // 计算分离后的坐标
    half2 offsetR = splitAmountR * inSize;
    half2 offsetB = splitAmountB * inSize;
    uint2 rxy = uint2(clamp(half2(gid) + offsetR * _Direction, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offsetB * _Direction, 0, inSize-1));
    // 读取颜色
    half3 colorR = inColor.read(rxy).rgb;
    half4 sceneColor = inColor.read(gid);
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(colorR.r, sceneColor.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}

float randomNoise(float x, float y)
{
    return fract(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
}
[[kernel]]
void postProcessRGBSplitV4(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           constant RGBSplitArgumentsV4 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _Indensity = args->indensity;
    half2 _Direction = half2(args->direction);
    float _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    float time = _TimeX * _Speed;
    // 计算抖动曲线
    half splitAmount = _Indensity * half(randomNoise(time, 2));
    
    // 计算分离后的坐标
    half2 offset = splitAmount * inSize;
    uint2 rxy = uint2(clamp(half2(gid) + offset * _Direction, 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * _Direction, 0, inSize-1));
    // 读取颜色
    half3 colorR = inColor.read(rxy).rgb;
    half4 sceneColor = inColor.read(gid);
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(colorR.r, sceneColor.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}

inline half4 Pow4(half4 v, half p)
{
    return half4(pow(v.xyz, p), v.w);
}

[[kernel]]
void postProcessRGBSplitV5(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           texture2d<half, access::read> noise [[texture(2)]],
                           constant RGBSplitArgumentsV5 *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    // 参数传递
    half _Speed = args->speed;
    half _Amplitude = args->amplitude;
    half _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half time = _TimeX * _Speed;
    
    // 计算抖动曲线
    half2 noiseUV = half2(fract(time), fract(2.0h * time / 25.0h));
    half4 noiseColor = noise.read(uint2(noiseUV * half2(noise.get_width(), noise.get_height())));
    half4 splitAmount = Pow4(noiseColor, 8.0h) * half4(_Amplitude, _Amplitude, _Amplitude, 1.0h);

    splitAmount *= 2.0h * splitAmount.w - 1.0h;
    
    // 计算分离后的坐标
    half2 offsetXY = splitAmount.xy * inSize;
    half2 offsetYZ = splitAmount.yz * inSize;
    half2 offsetZX = splitAmount.zx * inSize;
    uint2 rxy = uint2(clamp(half2(gid) + offsetXY * half2(1,-1), 0, inSize-1));
    uint2 gxy = uint2(clamp(half2(gid) + offsetYZ * half2(1,-1), 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) + offsetZX * half2(1,-1), 0, inSize-1));
    // 读取颜色
    half3 colorR = inColor.read(rxy).rgb;
    half3 sceneColor = inColor.read(gxy).rgb;
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(colorR.r, sceneColor.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}
