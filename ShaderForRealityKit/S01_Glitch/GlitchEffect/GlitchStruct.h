//
//  GlitchStruct.h
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/6.
//

#include <simd/simd.h>
#ifndef GlitchStruct_h
#define GlitchStruct_h



///
/// Because Metal is based on C++, defining a C++ struct in a header and adding a bridging header to the
/// project allows both Swift and Metal to use the same struct definition. Using a C++ struct accessed by both
/// Metal shaders and swift.
struct RGBSplitArguments
{
    float time;
    float fading;//0~1
    float amount;//0~5
    float speed;//0~10
    float centerFading;//0~1
    simd_float2 amountR;//0~5
    simd_float2 amountB;//0~5
};

struct RGBSplitArgumentsV2
{
    float time;
    float amount;//0~5
    float speed;//0~2
    float amplitude;//1~6
    simd_float2 direction;//0~1
};
enum IntervalType
{
    Periodic=0,//周期性重复
    Infinite,//持续最大值
    Random//随机数
};

struct RGBSplitArgumentsV3
{
    float time;
    float amount;//0~200
    float speed;//0~15
    float frequency;//0.1~25
    enum IntervalType type;
    simd_float2 direction;//0~1
};
struct RGBSplitArgumentsV4
{
    float time;
    float intensity;//-0.1~0.1
    float speed;//0~100
    simd_float2 direction;//0~1
};

struct RGBSplitArgumentsV5
{
    float time;
    float amplitude;//0~5
    float speed;//0~1
};

struct ImageBlockArguments
{
    float time;
    float speed;//0~50
    float blockSize;//0~50
};

struct ImageBlockArgumentsV2
{
    float time;
    float speed;//0~50
    float blockSize;//0~50
    simd_float2 maxRGBSplit;//0-25
};

struct ImageBlockArgumentsV3
{
    float time;
    float speed;//0~1
    float amount;//0~10
    float fade;//0~1
    float RGBSplitIntensity;//0-50
    float blockLayer1_Intensity;//0-50
    simd_float2 blockLayer1_UV;//0-50
};

struct ImageBlockArgumentsV4
{
    float time;
    float speed;//0~1
    float amount;//0~10
    float fade;//0~1
    float RGBSplitIntensity;//0-50
    float blockLayer1_Intensity;//0-50
    float blockLayer2_Intensity;//0-50
    simd_float2 blockLayer1_UV;//0-50
    simd_float2 blockLayer2_UV;//0-50
};

struct LineBlockArguments
{
    float time;
    float speed;//[Range(0f, 1f)]
    enum IntervalType type;
    float frequency; //[Range(0f, 25f)]
    float amount;//[Range(0f, 1f)]
    float linesWidth;//[Range(0.1f, 10f)]
    float offset;//[Range(0f, 13f)]
    float alpha;//[Range(0f, 1f)]
};

struct TileJitterArguments
{
    float time;
    float speed;//[Range(0f, 1f)]
    enum IntervalType type;
    float frequency; //[Range(0f, 25f)]
    float amount;//[Range(0f, 100f)]
    float splittingNumber;//[Range(0f, 50f)]
    simd_float2 direction;//0~1
};

struct ScanLineJitterArguments
{
    float time;
    enum IntervalType type;
    float frequency; //[Range(0f, 25f)]
    float amount;
    float threshold;
};

struct AnalogNoiseArguments
{
    float time;
    float speed; //[Range(0f, 1f)]
    float fading;//[Range(0f, 1f)]
    float luminanceJitterThreshold;//[Range(0f, 1f)]
};

struct ScreenJumpArguments
{
    float jumpIntensity;//[Range(0.0f, 1.0f)]
    float jumpTime; 
};

struct ScreenShakeArguments
{
    float time;
    float intensity;//[Range(0.0f, 0.25f)]
};

struct WaveJitterArguments
{
    float time;
    float speed; //[Range(0f, 1f)]
    enum IntervalType type;
    float frequency; //[Range(0f, 50f)]
    float amount;//[Range(0f, 2f)]
    float RGBSplitIntensity;//0-25
    simd_float2 resolution;//640,480
};

struct DigitalStripeArguments
{
    float intensity;//[Range(0.0f, 1.0f)]
//    float frequncy;//[Range(1, 10)]
//    float stripeLength;//[Range(0f, 0.99f)]
//    simd_int2 noiseTextureSize;//[Range(8, 256)]
    int needStripColorAdjust;
    simd_float3 stripColorAdjustColor;
    float stripColorAdjustIntensity;//[Range(0, 10)]
};
#endif /* GlitchStruct_h */
