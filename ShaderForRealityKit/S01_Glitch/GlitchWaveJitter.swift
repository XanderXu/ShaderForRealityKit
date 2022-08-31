//
//  GlitchWaveJitter.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/31.
//

import Foundation
import RealityKit
import MetalKit

class GlitchWaveJitter {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessWaveJitterHorizontal"
            case .Vertical:
                return "postProcessWaveJitterVertical"
            }
        }
    }
    var intervalType: IntervalType = .init(rawValue: 1)
    private var randomFrequency: Float = 1
    private var frameCount: Int = 0
    private(set) var version: Version = .Horizontal
    func loadPostProcess(device: MTLDevice, version: Version = .Horizontal) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        var frequency: Float = 5
        if intervalType.rawValue == 2 {
            if frameCount > Int(frequency) {
                frameCount = 0
                frequency = Float.random(in: 0...frequency)
            }
            frameCount += 1
        }
        
        var args = WaveJitterArguments(time: Float(context.time), speed: 0.25, type: intervalType, frequency: frequency, amount: 1, RGBSplitIndensity: 20, resolution: simd_float2(x: 480, y: 640))
        encoder.setBytes(&args, length: MemoryLayout<WaveJitterArguments>.stride, index: 0)
    }
}
