//
//  GlitchTileJitter.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/28.
//

import Foundation
import RealityKit
import MetalKit

class GlitchTileJitter {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessTileJitterHorizontal"
            case .Vertical:
                return "postProcessTileJitterVertical"
            }
        }
    }
    var intervalType: IntervalType = .init(rawValue: 1)
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
        var frequency: Float = 3
        if intervalType.rawValue == 2 {
            if frameCount > Int(frequency) {
                frameCount = 0
                frequency = Float.random(in: 0...frequency)
            }
            frameCount += 1
        }
        var args = TileJitterArguments(time: Float(context.time), speed: 0.35*100, type: intervalType, frequency: frequency, amount: 20, splittingNumber: 8, direction: simd_float2(x: 1, y: 0))
        encoder.setBytes(&args, length: MemoryLayout<TileJitterArguments>.stride, index: 0)
    }
}
