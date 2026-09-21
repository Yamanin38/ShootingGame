// EnemyEntity.swift
// ShootingGame - 敵機の 3D モデル生成

import RealityKit
import UIKit

/// 敵機の 3D モデルを生成するファクトリ
@MainActor enum EnemyEntity {
  private static let template: Entity = build()

      /// テンプレートを複製して返す (メッシュ・マテリアルは共有)
      static func make() -> Entity { template.clone(recursive: true) }
    private static func build() -> Entity {
        let root = Entity()

        // ---- 機体ディスク (扁平な六角形イメージ) ----
        var bodyMat = PhysicallyBasedMaterial()
        bodyMat.baseColor = .init(tint: UIColor(red: 1.0, green: 0.25, blue: 0.15, alpha: 1.0))
        bodyMat.metallic  = .init(floatLiteral: 0.6)
        bodyMat.roughness = .init(floatLiteral: 0.3)
        bodyMat.emissiveColor = .init(color: UIColor(red: 0.8, green: 0.1, blue: 0.0, alpha: 1.0))
        bodyMat.emissiveIntensity = 0.4

        let bodyMesh = MeshResource.generateBox(width: 0.8, height: 0.18, depth: 0.8, cornerRadius: 0.15)
        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [bodyMat])
        root.addChild(bodyEntity)

        // ---- 前方ブレード (前突起) ----
        var bladeMat = PhysicallyBasedMaterial()
        bladeMat.baseColor = .init(tint: UIColor(red: 0.8, green: 0.1, blue: 0.0, alpha: 1.0))
        bladeMat.metallic  = .init(floatLiteral: 0.9)
        bladeMat.roughness = .init(floatLiteral: 0.1)

        let bladeMesh = MeshResource.generateBox(width: 0.15, height: 0.08, depth: 0.4, cornerRadius: 0.04)
        let blade = ModelEntity(mesh: bladeMesh, materials: [bladeMat])
        blade.position = SIMD3<Float>(0, 0, 0.55)
        root.addChild(blade)

        // ---- 左右の翼スパイク ----
        let spikeMesh = MeshResource.generateBox(width: 0.5, height: 0.06, depth: 0.18, cornerRadius: 0.03)
        for xOff: Float in [-0.6, 0.6] {
            let spike = ModelEntity(mesh: spikeMesh, materials: [bladeMat])
            spike.position = SIMD3<Float>(xOff, 0, 0)
            root.addChild(spike)
        }

        // ---- コア (光るセンター) ----
        var coreMat = UnlitMaterial(color: UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0))
        let coreMesh = MeshResource.generateSphere(radius: 0.12)
        let core = ModelEntity(mesh: coreMesh, materials: [coreMat])
        core.position = SIMD3<Float>(0, 0.06, 0)
        root.addChild(core)

        // ---- 赤い周囲ライト ----
        let lightEnt = Entity()
        

        // 機体を自機の方向(Z+)へ向かせるため180度回転
        root.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])

        return root
    }
}
