//
//  GlitchScreenJump.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

import Foundation
import RealityKit
import MetalKit

class GlitchScreenJump {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessScreenJumpHorizontal"
            case .Vertical:
                return "postProcessScreenJumpVertical"
            }
        }
    }
    
    private var lastTime: TimeInterval = 0
    private var screenJumpTime: Float = 0
    private(set) var version: Version = .Horizontal
    func loadPostProcess(device: MTLDevice, version: Version = .Horizontal) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        let jumpIntensity: Float = 0.35
        screenJumpTime += Float(context.time - lastTime) * jumpIntensity * 9.8
        var args = ScreenJumpArguments(jumpIntensity: 0.35, jumpTime: screenJumpTime)
        encoder.setBytes(&args, length: MemoryLayout<ScreenJumpArguments>.stride, index: 0)
        lastTime = context.time
    }
}
