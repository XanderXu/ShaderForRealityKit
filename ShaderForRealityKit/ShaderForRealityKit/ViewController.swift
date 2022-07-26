//
//  ViewController.swift
//  ShaderForRealityKit
//
//  Created by CoderXu on 2022/7/26.
//

import UIKit
import RealityKit
import MetalPerformanceShaders

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var device: MTLDevice!
    var ciContext: CIContext?
    var bloomTexture: MTLTexture!
    var inFlight = false//每次只处理一帧
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        arView.renderCallbacks.prepareWithDevice = { [weak self] device in
            self?.prepareWithDevice(device)
        }
        arView.renderCallbacks.postProcess = { [weak self] context in
            self?.postProcess(context)
        }
    }
    
    func prepareWithDevice(_ device: MTLDevice) {
        self.device = device
        self.ciContext = CIContext(mtlDevice: device)
    }
    
    func postProcess(_ context: ARView.PostProcessContext) {
        
    }
}
extension ViewController {
    func filterProcess(_ context: ARView.PostProcessContext) {
        let sourceColor = CIImage(mtlTexture: context.sourceColorTexture)!
        
        //创建热点滤镜
        guard let thermal = CIFilter(name: "CIThermal") else { return }
        thermal.setValue(sourceColor, forKey: "inputImage")
        //        thermal?.inputImage = sourceColor
        
        //创建CIRenderDestination
        let destination = CIRenderDestination(mtlTexture: context.targetColorTexture,
                                              commandBuffer: context.commandBuffer)
        //保持图像朝向
        destination.isFlipped = false
        
        _ = try? self.ciContext?.startTask(toRender: thermal.outputImage!, to: destination)
    }
    func mpsProcess(_ context: ARView.PostProcessContext) {
        if self.bloomTexture == nil {
            self.bloomTexture = self.makeTexture(matching: context.sourceColorTexture)
        }
        //将亮度0.2以下的区域置为0
        let brightness = MPSImageThresholdToZero(device: context.device,
                                                 thresholdValue: 0.2,
                                                 linearGrayColorTransform: nil)
        brightness.encode(commandBuffer: context.commandBuffer,
                          sourceTexture: context.sourceColorTexture,
                          destinationTexture: bloomTexture!)
        //剩余区域进行模糊
        let gaussianBlur = MPSImageGaussianBlur(device: context.device, sigma: 9.0)
        gaussianBlur.encode(commandBuffer: context.commandBuffer,
                            inPlaceTexture: &bloomTexture!)
        //将颜色与 bloom 叠加，最后写入到 targetColorTexture 中
        let add = MPSImageAdd(device: context.device)
        add.encode(commandBuffer: context.commandBuffer,
                   primaryTexture: context.sourceColorTexture,
                   secondaryTexture: bloomTexture!,
                   destinationTexture: context.targetColorTexture)
    }
    func makeTexture(matching texture: MTLTexture) -> MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = texture.width
        descriptor.height = texture.height
        descriptor.pixelFormat = texture.pixelFormat
        descriptor.usage = [.shaderRead, .shaderWrite]
        
        return device.makeTexture(descriptor: descriptor)!
    }
}
