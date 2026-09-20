// PlayerBulletEntity.swift
// ShootingGame - 自機弾の 3D モデル生成

import RealityKit
import UIKit

/// 自機弾の 3D モデルを生成するファクトリ
enum PlayerBulletEntity {

    static func make() -> Entity {
        let root = Entity()

        // ---- 弾本体: 細長いカプセル ----
        let bulletMat = UnlitMaterial(color: UIColor(red: 0.4, green: 0.95, blue: 1.0, alpha: 1.0))
        let bulletMesh = MeshResource.generateBox(width: 0.06, height: 0.06, depth: 0.35, cornerRadius: 0.03)
        let bulletBody = ModelEntity(mesh: bulletMesh, materials: [bulletMat])
        root.addChild(bulletBody)

        // ---- 弾頭: 小球 ----
        let tipMat = UnlitMaterial(color: UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 1.0))
        let tipMesh = MeshResource.generateSphere(radius: 0.055)
        let tip = ModelEntity(mesh: tipMesh, materials: [tipMat])
        tip.position = SIMD3<Float>(0, 0, -0.18)
        root.addChild(tip)

        // ---- 発光ライト ----
        var pl = PointLightComponent()
        pl.color     = UIColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0)
        pl.intensity = 800
        pl.attenuationRadius = 1.0
        let lightEnt = Entity()
        lightEnt.components.set(pl)
        root.addChild(lightEnt)

        return root
    }
}
