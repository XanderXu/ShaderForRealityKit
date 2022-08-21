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
    let glitch = GlitchImageBlock()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        arView.renderCallbacks.prepareWithDevice = loadPostprocessingShader
        arView.renderCallbacks.postProcess = postProcess
    }

    func loadPostprocessingShader(device: MTLDevice) {
        if let kernel = glitch.loadPostProcess(device: device, version: .V1) {
            computePipeline = try? device.makeComputePipelineState(function: kernel)
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
        
        glitch.setCustomArguments(encoder: encoder, context: context)
        
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

