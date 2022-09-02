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
        case V1
        
        var functionName: String {
            switch self {
            case .V1:
                return "postProcessDigitalStripe"
            }
        }
    }
    
    private(set) var noiseTexture: MTLTexture?
    private(set) var version: Version = .V1
    var intervalType: IntervalType = .init(rawValue: 2)
    private var frameCount: Int = 0
    func loadPostProcess(device: MTLDevice, version: Version = .V1) -> MTLFunction? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        self.version = version
        let desc = MTLTextureDescriptor()
        desc.pixelFormat = .bgra8Unorm;
        desc.width = 20
        desc.height = 20
        noiseTexture = device.makeTexture(descriptor: desc)
        return library.makeFunction(name: version.functionName)
    }
    
    func setCustomArguments(encoder: MTLComputeCommandEncoder, context: ARView.PostProcessContext) {
        var frequency: Float = 8
        if frameCount % Int(frequency) == 0 {
            updateRandomNoiseTexture(noiseTexture)
            encoder.setTexture(noiseTexture, index: 2)
        }
        if intervalType.rawValue == 2 {
            if frameCount > Int(frequency) {
                frameCount = 0
                frequency = Float.random(in: 0...frequency)
            }
            frameCount += 1
        }
        var args = DigitalStripeArguments(intensity: 0.25, needStripColorAdjust: 1, stripColorAdjustColor: simd_float3(x: 0.1, y: 0.1, z: 0.1), stripColorAdjustIntensity: 2)
        encoder.setBytes(&args, length: MemoryLayout<DigitalStripeArguments>.stride, index: 0)
        
    }
    func updateRandomNoiseTexture(_ texture: MTLTexture?) {
        guard let texture = texture else {
            return
        }
        let count: Int = texture.width * texture.height * 4
        let stride = MemoryLayout<Float>.stride
        let aligment = MemoryLayout<Float>.alignment
        let byteCount = stride * count
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: aligment)
        var r = Float.random(in: 0...1)
        var g = Float.random(in: 0...1)
        var b = Float.random(in: 0...1)
        var a = Float.random(in: 0...1)
        for i in 0..<texture.width * texture.height {
            if Float.random(in: 0...1) > 0.89 {
                print(i,r,g,b,a)
                r = 1//Float.random(in: 0...1)
                g = 1//Float.random(in: 0...1)
                b = 1//Float.random(in: 0...1)
                a = 1//Float.random(in: 0...1)
            }
            pointer.advanced(by: i*stride*4).storeBytes(of: r, as: Float.self)
            pointer.advanced(by: i*stride*4+1*stride).storeBytes(of: g, as: Float.self)
            pointer.advanced(by: i*stride*4+2*stride).storeBytes(of: b, as: Float.self)
            pointer.advanced(by: i*stride*4+3*stride).storeBytes(of: a, as: Float.self)
        }
        
        let bytesPerRow = 4 * texture.width * stride
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: texture.width, height: texture.height, depth: 1))
        texture.replace(region: region, mipmapLevel: 0, withBytes: pointer, bytesPerRow: bytesPerRow)
        pointer.deallocate()
    }
    
}
