//
//  NoiseLibrary.h
//  S02_Noise
//
//  Created by CoderXu on 2023/1/10.
//

#ifndef NoiseLibrary_h
#define NoiseLibrary_h
float sinNoise(float x)
{
    return fract(sin(x)*100000.0);
}
float randomNoise(float2 seed)
{
    //float2(12.9898,78.233)、43758.5453都是经验参数，得出的效果很好
    return fract(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453123);
}
#endif /* NoiseLibrary_h */
