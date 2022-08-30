//
//  GlitchScanLineJitter.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/28.
//

import Foundation
import RealityKit
import MetalKit

class GlitchScanLineJitter {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessScanLineJitterHorizontal"
            case .Vertical:
                return "postProcessScanLineJitterVertical"
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
        var frequency: Float = 3
        if intervalType.rawValue == 2 {
            if frameCount > Int(frequency) {
                frameCount = 0
                frequency = Float.random(in: 0...frequency)
            }
            frameCount += 1
        }
        let JitterIndensity: Float = 0.4//0～1
        let displacement = 0.005 + pow(JitterIndensity, 3) * 0.1
        let threshold = max(0, 1.0 - JitterIndensity * 1.2)
        var args = ScanLineJitterArguments(time: Float(context.time), type: intervalType, frequency: frequency, amount: displacement, threshold: threshold)
        encoder.setBytes(&args, length: MemoryLayout<ScanLineJitterArguments>.stride, index: 0)
    }
}
