// StarfieldEffect.swift
// ShootingGame - 背景の星フィールド生成

import RealityKit
import UIKit

/// 宇宙空間の背景を表現する星フィールドを生成するファクトリ
enum StarfieldEffect {

    private static let starCount = 120

    /// 星フィールドエンティティを生成して anchor に追加する
    static func attach(to anchor: AnchorEntity) {
        let container = Entity()
        container.position = SIMD3<Float>(0, -0.5, 0) // ゲーム平面より少し下

        var mat = UnlitMaterial(color: UIColor(white: 1.0, alpha: 0.85))
        let bigStarMat = UnlitMaterial(color: UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0))
      // ループの前:
      let unitMesh = MeshResource.generateSphere(radius: 0.05)
        for _ in 0..<starCount {
            let size    = Float.random(in: 0.02...0.07)
            let isBig   = size > 0.055
            let mesh    = MeshResource.generateSphere(radius: size)
          let scale = Float.random(in: 0.4...1.4)
          let star = ModelEntity(mesh: unitMesh, materials: [scale > 1.1 ? bigStarMat : mat])
          star.scale = SIMD3<Float>(repeating: scale)

            let x = Float.random(in: -GameConfig.playfieldHalfWidth * 1.3...GameConfig.playfieldHalfWidth * 1.3)
            let z = Float.random(in: -GameConfig.playfieldHalfHeight * 1.2...GameConfig.playfieldHalfHeight * 1.2)
            star.position = SIMD3<Float>(x, 0, z)
            container.addChild(star)
        }

        anchor.addChild(container)
    }
}
