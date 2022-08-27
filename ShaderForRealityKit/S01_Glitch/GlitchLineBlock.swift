//
//  GlitchLineBlock.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/27.
//

import Foundation
import RealityKit
import MetalKit

class GlitchLineBlock {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessLineBlockHorizontal"
            case .Vertical:
                return "postProcessLineBlockVertical"
            }
        }
    }
    var intervalType: IntervalType = .init(rawValue: 2)
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
        var frequency: Float = 3
        if intervalType.rawValue == 2 {
            if frameCount > Int(frequency) {
                frameCount = 0
                frequency = Float.random(in: 0...frequency)
            }
            frameCount += 1
        }
        var args = LineBlockArguments(time: Float(context.time), speed: 0.8, type: intervalType, frequency: frequency, amount: 0.5, linesWidth: 1, offset: 1, alpha: 1)
        encoder.setBytes(&args, length: MemoryLayout<LineBlockArguments>.stride, index: 0)
    }
}
