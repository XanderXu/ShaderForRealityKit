//
//  ViewController.swift
//  S01_Glitch
//
//  Created by CoderXu on 2022/8/7.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var computePipeline: MTLComputePipelineState?
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

//        if let invertKernel = library.makeFunction(name: "postProcessRGBSplit") {
//            // Create a pipeline state object and store it in a property.
//            computePipeline = try? device.makeComputePipelineState(function: invertKernel)
//        }
        if let invertKernel = library.makeFunction(name: "postProcessRGBSplitV2") {
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
        var args = RGBSplitArgumentsV2(time: Float(context.time), amount: 1, speed: 2, amplitude: 3, direction: simd_float2(x: 1, y: 0))
        encoder.setBytes(&args, length: MemoryLayout<RGBSplitArgumentsV2>.stride, index: 0)
        
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
