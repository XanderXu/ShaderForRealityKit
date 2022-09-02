//
//  GlitchScreenShake.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

import Foundation
import RealityKit
import MetalKit

class GlitchScreenShake {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessScreenShakeHorizontal"
            case .Vertical:
                return "postProcessScreenShakeVertical"
            }
        }
    }
    
    private(set) var version: Version = .Horizontal
    func loadPostProcess(device: MTLDevice, version: Version = .Horizontal) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        let intensity: Float = 0.5 * 0.25
        var args = ScreenShakeArguments(time: Float(context.time/20), intensity: intensity)
        encoder.setBytes(&args, length: MemoryLayout<ScreenShakeArguments>.stride, index: 0)
    }
}
