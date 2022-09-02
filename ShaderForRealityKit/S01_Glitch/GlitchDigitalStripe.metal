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
void postProcessDigitalStripe(uint2 gid [[thread_position_in_grid]],
                           texture2d<half, access::read> inColor [[texture(0)]],
                           texture2d<half, access::write> outColor [[texture(1)]],
                           texture2d<half, access::read> noise [[texture(2)]],
                              constant DigitalStripeArguments *args [[buffer(0)]])
{
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {
        return;
    }
    
}
