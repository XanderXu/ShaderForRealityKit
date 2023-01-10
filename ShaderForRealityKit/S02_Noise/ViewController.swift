//
//  ViewController.swift
//  S02_Noise
//
//  Created by CoderXu on 2023/1/10.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var animatedNoise: Float = 0
    var boxModelEntity: ModelEntity?
    var planeModelEnity: ModelEntity?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        if let modelEntity = boxAnchor.findEntity(named: "simpBld_root") as? ModelEntity {
            addNoiseShader(to: modelEntity)
            boxModelEntity = modelEntity
        }
        
        let planeEntity = ModelEntity(mesh: MeshResource.generatePlane(width: 0.2, height: 0.2), materials: [PhysicallyBasedMaterial()])
        planeEntity.position = simd_float3(0, 0.25, 0)
        addNoiseShader(to: planeEntity)
        boxAnchor.addChild(planeEntity)
        planeModelEnity = planeEntity
    }
    func addNoiseShader(to modelEntity: ModelEntity) {
        let surfaceShader = CustomMaterial.SurfaceShader(named: "sinNoiseSurface", in: MetalLibLoader.library)
        modelEntity.modifyMaterials { material in
            var customMaterial: CustomMaterial = try! CustomMaterial(
                from: material,
                surfaceShader: surfaceShader
            )
            customMaterial.custom.value = SIMD4<Float>(0, 0, 0, 0)
            return customMaterial
        }
    }
     
    @IBAction func switchChange(_ sender: UISwitch) {
        if sender.isOn {
            animatedNoise = 1
        } else {
            animatedNoise = 0
        }
        boxModelEntity?.modifyMaterials { material in
            guard var customMaterial = material as? CustomMaterial else { return material }
            customMaterial.custom.value = SIMD4<Float>(self.animatedNoise, 0, 0, 0)
            return customMaterial
        }
        planeModelEnity?.modifyMaterials { material in
            guard var customMaterial = material as? CustomMaterial else { return material }
            customMaterial.custom.value = SIMD4<Float>(self.animatedNoise, 0, 0, 0)
            return customMaterial
        }
    }
}
