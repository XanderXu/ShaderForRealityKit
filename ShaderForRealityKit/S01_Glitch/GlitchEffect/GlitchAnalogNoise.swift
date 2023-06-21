//
//  GlitchAnalogNoise.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

import Foundation
import RealityKit
import MetalKit

class GlitchAnalogNoise {
    enum Version {
        case V1
        var functionName: String {
            switch self {
            case .V1:
                return "postProcessGlitchAnalogNoise"
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
        
        var args = AnalogNoiseArguments(time: Float(context.time), speed: 0.5, fading: 0.5, luminanceJitterThreshold: 0.8)
        encoder.setBytes(&args, length: MemoryLayout<AnalogNoiseArguments>.stride, index: 0)
    }
}
