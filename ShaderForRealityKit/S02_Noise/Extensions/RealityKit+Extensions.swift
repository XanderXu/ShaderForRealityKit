/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Game-specific extensions on RealityKit classes.
*/

import RealityKit



extension Entity {
    var descendants: [Entity] {
        children + children.flatMap { $0.descendants }
    }
}


extension Entity {
    func modifyMaterials(_ closure: (Material) throws -> Material) rethrows {
        try children.forEach { try $0.modifyMaterials(closure) }
        
        guard var comp = components[ModelComponent.self] as? ModelComponent else { return }
        comp.materials = try comp.materials.map { try closure($0) }
        components[ModelComponent.self] = comp
    }
}
