//
//  GlitchImageBlock.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/16.
//

import Foundation
import RealityKit
import MetalKit

class GlitchImageBlock {
    enum Version {
        case V1
        case V2
        case V3
        case V4
        
        var functionName: String {
            switch self {
            case .V1:
                return "postProcessImageBlock"
            case .V2:
                return "postProcessImageBlockV2"
            case .V3:
                return "postProcessImageBlockV3"
            case .V4:
                return "postProcessImageBlockV4"
            }
        }
    }
    
    private(set) var version: Version = .V1
    func loadPostProcess(device: MTLDevice, version: Version = .V1) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        switch version {
        case .V1:
            var args = ImageBlockArguments(time: Float(context.time), speed: 10, blockSize: 8)
            encoder.setBytes(&args, length: MemoryLayout<ImageBlockArguments>.stride, index: 0)
        case .V2:
            var args = ImageBlockArgumentsV2(time: Float(context.time), speed: 10, blockSize: 8, maxRGBSplit: simd_float2(x: 1, y: 1))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV2>.stride, index: 0)
        case .V3:
            var args = ImageBlockArgumentsV3(time: Float(context.time), speed: 0.5, amount: 1, fade: 1, RGBSplitIntensity: 2, blockLayer1_Intensity: 8, blockLayer1_UV: simd_float2(x: 4, y: 16))
            encoder.setBytes(&args, length: MemoryLayout<ImageBlockArgumentsV3>.stride, index: 0)
        case .V4:
            var args = ImageBlockArgumentsV4(time: Float(context.time), speed: 0.5, amount: 1, fade: 1, RGBSplitIntensity: 2, blockLayer1_Intensity: 8, blockLayer2_Intensity: 4, blockLayer1_UV: simd_float2(x: 9, y: 9), blockLayer2_UV: simd_float2(x: 5, y: 5))
            encoder.setBytes(&args, length: MemoryLayout<ImageBlockArgumentsV4>.stride, index: 0)
        }
    }
}
