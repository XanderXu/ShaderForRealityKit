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
        noiseTexture = generateRandomNoiseTexture(device: device, width: 64, height: 64)
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
        var args = DigitalStripeArguments(intensity: 0.25, frequncy: frequency, stripeLength: 0.89, noiseTextureSize: simd_int2(x: 20, y: 20), needStripColorAdjust: 1, StripColorAdjustColor: simd_float3(x: 0.1, y: 0.1, z: 0.1), StripColorAdjustIndensity: 2)
        encoder.setBytes(&args, length: MemoryLayout<DigitalStripeArguments>.stride, index: 0)
        encoder.setTexture(noiseTexture, index: 2)
        
    }
    func generateRandomNoiseTexture(device: MTLDevice, width: Int, height: Int) -> MTLTexture? {
        let desc = MTLTextureDescriptor()
        desc.pixelFormat = .bgra8Unorm;
        desc.width = width
        desc.height = height
        let noiseTexture = device.makeSharedTexture(descriptor: desc)
        
        let bytesPerRow = 4 * width;
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: width, height: height, depth: 1))
//        noiseTexture?.replace(region: region, mipmapLevel: 0, withBytes: UnsafeRawPointer()!, bytesPerRow: bytesPerRow)
        return noiseTexture
    }
//    - (void) generateRandomFloatData: (id<MTLBuffer>) buffer
//    {
//        float* dataPtr = buffer.contents;
//
//        for (unsigned long index = 0; index < arrayLength; index++)
//        {
//            dataPtr[index] = (float)rand()/(float)(RAND_MAX);
//        }
//    }
}
