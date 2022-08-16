//
//  GlitchImageBlock.metal
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/16.
//

#include <metal_stdlib>
#include "GlitchStruct.h"
using namespace metal;

inline half randomNoise(half2 seed)
{
    return fract(sin(dot(seed, half2(17.13, 3.71))) * 43758.5453123);
}

inline half randomNoise(half seed)
{
    return randomNoise(half2(seed, 1.0));
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
    half _TimeX = args->time;
    // uv 与 time 转换
    half2 inSize = half2(inColor.get_width(), inColor.get_height());
    half time = _TimeX * _Speed;
    // 计算错位图块
    half2 block = randomNoise(floor(half2(gid) / inSize * _BlockSize) * floor(time));
    half displaceNoise = pow(block.x, 8.0h) * pow(block.x, 3.0h);
    
    // 计算错位后的坐标
    half2 offset = displaceNoise * inSize;
    uint2 gxy = uint2(clamp(half2(gid) + offset * 0.05 * randomNoise(7.0), 0, inSize-1));
    uint2 bxy = uint2(clamp(half2(gid) - offset * 0.05 * randomNoise(13.0), 0, inSize-1));
    // 读取颜色
    half4 sceneColor = inColor.read(gid);
    half3 colorG = inColor.read(gxy).rgb;
    half3 colorB = inColor.read(bxy).rgb;
    // 混合分离出来的颜色
    half3 finalColor = half3(sceneColor.r, colorG.g, colorB.b);
    
    outColor.write(half4(finalColor,1), gid);
}