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
    Periodic=0,
    Infinite,
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
    float indensity;//-0.1~0.1
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
    float RGBSplitIndensity;//0-50
    float blockLayer1_Indensity;//0-50
    simd_float2 blockLayer1_UV;//0-50
};

struct ImageBlockArgumentsV4
{
    float time;
    float speed;//0~1
    float amount;//0~10
    float fade;//0~1
    float RGBSplitIndensity;//0-50
    float blockLayer1_Indensity;//0-50
    float blockLayer2_Indensity;//0-50
    simd_float2 blockLayer1_UV;//0-50
    simd_float2 blockLayer2_UV;//0-50
};



#endif /* GlitchStruct_h */
