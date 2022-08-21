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
            var args = RGBSplitArgumentsV2(time: Float(context.time), amount: 1, speed: 2, amplitude: 3, direction: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV2>.stride, index: 0)
        case .V3:
            var args = RGBSplitArgumentsV3(time: Float(context.time), amount: 30, speed: 15, frequency: 3, type: .init(rawValue: 0), direction: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV3>.stride, index: 0)
        case .V4:
            var args = RGBSplitArgumentsV4(time: Float(context.time), indensity: 0.5*0.1, speed: 10, direction: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV4>.stride, index: 0)
        }
    }
}
