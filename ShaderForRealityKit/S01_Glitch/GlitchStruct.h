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

struct RGBSplitArgumentsV5
{
    float time;
    float amplitude;//0~5
    float speed;//0~1
};

#endif /* GlitchStruct_h */
