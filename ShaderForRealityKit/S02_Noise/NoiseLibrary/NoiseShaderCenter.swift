//
//  NoiseShaderCenter.swift
//  S02_Noise
//
//  Created by xu on 2023/6/21.
//

import RealityKit

extension CustomMaterial {
    static var NoiseCenter: NoiseShaderCenter.Type {
        return NoiseShaderCenter.self
    }
}
struct NoiseShaderCenter {
    static let randomNoiseShader = CustomMaterial.SurfaceShader(named: "randomNoiseSurface", in: MetalLibLoader.library)
    static let sinNoiseShader = CustomMaterial.SurfaceShader(named: "sinNoiseSurface", in: MetalLibLoader.library)
}





