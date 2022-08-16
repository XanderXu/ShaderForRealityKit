//
//  GlitchRGBSplit.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/16.
//

import Foundation
import RealityKit
import MetalKit

class GlitchRGBSplit {
    enum Version {
        case `default`
        case V2
        case V3
        case V4
        case V5
        
        var functionName: String {
            switch self {
            case .default:
                return "postProcessRGBSplit"
            case .V2:
                return "postProcessRGBSplitV2"
            case .V3:
                return "postProcessRGBSplitV3"
            case .V4:
                return "postProcessRGBSplitV4"
            case .V5:
                return "postProcessRGBSplitV5"
            }
        }
    }
    
    var noiseTexture: MTLTexture?
    var version: Version = .default
    func loadPostProcessRGBSplit(device: MTLDevice, version: Version = .default) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        if version == .V5 {
            let textureLoader = MTKTextureLoader(device: device)
            noiseTexture = try? textureLoader.newTexture(name: "X-Noise256", scaleFactor: 1, bundle: nil)
            // 其他的 MTLTexture 加载方式，Data 加载，cgImage 加载
            //        let textureLoader = MTKTextureLoader(device: device)
            //        let path = Bundle.main.path(forResource: "X-Noise256", ofType: "png")!
            //        let data = NSData(contentsOfFile: path)! as Data
            //        noiseTexture = try? textureLoader.newTexture(data: data, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
            
            //        if let cgImage = UIImage(named: "X-Noise256")?.cgImage {
            //            noiseTexture = try? textureLoader.newTexture(cgImage: cgImage)
            //        }
        }
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomRGBSplitArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        switch version {
        case .default:
            var args = RGBSplitArguments(time: Float(context.time), fading: 1, amount: 1, speed: 1, centerFading: 0, amountR: simd_float2(x: 1, y: 0), amountB: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArguments>.stride, index: 0)
        case .V2:
            var args = RGBSplitArgumentsV2(time: Float(context.time), amount: 1, speed: 2, amplitude: 3, direction: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV2>.stride, index: 0)
        case .V3:
            var args = RGBSplitArgumentsV3(time: Float(context.time), amount: 30, speed: 15, frequency: 3, type: .init(rawValue: 0), direction: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV3>.stride, index: 0)
        case .V4:
            var args = RGBSplitArgumentsV4(time: Float(context.time), indensity: 0.5*0.1, speed: 10, direction: simd_float2(x: 1, y: 0))
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV4>.stride, index: 0)
        case .V5:
            encoder.setTexture(noiseTexture, index: 2)
            var args = RGBSplitArgumentsV5(time: Float(context.time), amplitude: 3, speed: 0.1)
            encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV5>.stride, index: 0)
        }
    }
}
