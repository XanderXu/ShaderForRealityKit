//
//  ViewController.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/7.
//

import UIKit
import RealityKit
import MetalKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var computePipeline: MTLComputePipelineState?
    var noiseTexture: MTLTexture?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        arView.renderCallbacks.prepareWithDevice = loadPostprocessingShader
        arView.renderCallbacks.postProcess = postProcess
    }
    
}
extension ViewController {
    func loadPostprocessingShader(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        let textureLoader = MTKTextureLoader(device: device)
        let path = Bundle.main.path(forResource: "X-Noise256", ofType: "png")!
        let data = NSData(contentsOfFile: path)! as Data
        noiseTexture = try? textureLoader.newTexture(data: data, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
        
//        if let invertKernel = library.makeFunction(name: "postProcessRGBSplit") {
//            // Create a pipeline state object and store it in a property.
//            computePipeline = try? device.makeComputePipelineState(function: invertKernel)
//        }
        if let invertKernel = library.makeFunction(name: "postProcessRGBSplitV5") {
            // Create a pipeline state object and store it in a property.
            computePipeline = try? device.makeComputePipelineState(function: invertKernel)
        }
    }
    func postProcess(context: ARView.PostProcessContext) {
        guard let encoder = context.commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        guard let computePipeline = computePipeline else {
            return
        }

        encoder.setComputePipelineState(computePipeline)
        encoder.setTexture(context.sourceColorTexture, index: 0)
        encoder.setTexture(context.targetColorTexture, index: 1)
//        var args = RGBSplitArguments(time: Float(context.time), fading: 1, amount: 1, speed: 1, centerFading: 0, amountR: simd_float2(x: 1, y: 0), amountB: simd_float2(x: 1, y: 0))
//        encoder.setBytes(&args, length: MemoryLayout<RGBSplitArguments>.stride, index: 0)
//        var args = RGBSplitArgumentsV2(time: Float(context.time), amount: 1, speed: 2, amplitude: 3, direction: simd_float2(x: 1, y: 0))
//        encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV2>.stride, index: 0)
        
//        var args = RGBSplitArgumentsV3(time: Float(context.time), amount: 30, speed: 15, frequency: 3, type: .init(rawValue: 0), direction: simd_float2(x: 1, y: 0))
//        encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV3>.stride, index: 0)
        encoder.setTexture(noiseTexture, index: 2)
        var args = RGBSplitArgumentsV5(time: Float(context.time), amplitude: 3, speed: 0.1)
        encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV5>.stride, index: 0)
        
        let threadsPerGrid = MTLSize(width: context.sourceColorTexture.width,
                                     height: context.sourceColorTexture.height,
                                     depth: 1)

        let w = computePipeline.threadExecutionWidth
        let h = computePipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        encoder.dispatchThreads(threadsPerGrid,
                                threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
