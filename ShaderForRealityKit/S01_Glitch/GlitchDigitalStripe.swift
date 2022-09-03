//
//  GlitchDigitalStripe.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/30.
//

import Foundation
import RealityKit
import MetalKit

class GlitchDigitalStripe {
    enum Version {
        case Horizontal
        case Vertical
        
        var functionName: String {
            switch self {
            case .Horizontal:
                return "postProcessDigitalStripeHorizontal"
            case .Vertical:
                return "postProcessDigitalStripeVertical"
            }
        }
    }
    
    private(set) var noiseTexture: MTLTexture?
    private(set) var version: Version = .Horizontal
    private var frameCount: Int = 0
    func loadPostProcess(device: MTLDevice, version: Version = .Horizontal) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        let desc = MTLTextureDescriptor()
        desc.pixelFormat = .rgba8Unorm;
        desc.width = 20
        desc.height = 20
        noiseTexture = device.makeTexture(descriptor: desc)
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        let frequency: Float = 8
        if frameCount % Int(frequency) == 0 {
            updateRandomNoiseTexture(noiseTexture)
            frameCount = 0
        }
        encoder.setTexture(noiseTexture, index: 2)
        frameCount += 1
        
        var args = DigitalStripeArguments(intensity: 0.25, needStripColorAdjust: 1, stripColorAdjustColor: simd_float3(x: 0.1, y: 0.1, z: 0.1), stripColorAdjustIntensity: 2)
        encoder.setBytes(&args, length: MemoryLayout<DigitalStripeArguments>.stride, index: 0)
        
    }
    func updateRandomNoiseTexture(_ texture: MTLTexture?) {
        guard let texture = texture else {
            return
        }
        let count: Int = texture.width * texture.height * 4
        let stride = MemoryLayout<UInt8>.stride
        let aligment = MemoryLayout<UInt8>.alignment
        let byteCount = stride * count
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: aligment)
        var r = UInt8.random(in: 0...255)
        var g = UInt8.random(in: 0...255)
        var b = UInt8.random(in: 0...255)
        var a = UInt8.random(in: 0...255)
        for i in 0..<texture.width * texture.height {
            if Float.random(in: 0...1) > 0.89 {
                //print(i,r,g,b,a)
                r = UInt8.random(in: 0...255)
                g = UInt8.random(in: 0...255)
                b = UInt8.random(in: 0...255)
                a = UInt8.random(in: 0...255)
            }
            pointer.advanced(by: i*stride*4).storeBytes(of: r, as: UInt8.self)
            pointer.advanced(by: i*stride*4+1*stride).storeBytes(of: g, as: UInt8.self)
            pointer.advanced(by: i*stride*4+2*stride).storeBytes(of: b, as: UInt8.self)
            pointer.advanced(by: i*stride*4+3*stride).storeBytes(of: a, as: UInt8.self)
        }
        
        let bytesPerRow = 4 * texture.width * stride
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: texture.width, height: texture.height, depth: 1))
        texture.replace(region: region, mipmapLevel: 0, withBytes: pointer, bytesPerRow: bytesPerRow)
        pointer.deallocate()
    }
    
}
