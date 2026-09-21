// EnemyBulletEntity.swift
// ShootingGame - 敵弾の 3D モデル生成

import RealityKit
import UIKit

/// 敵弾の 3D モデルを生成するファクトリ
@MainActor enum EnemyBulletEntity {
  
  private static let template: Entity = build()

      /// テンプレートを複製して返す (メッシュ・マテリアルは共有)
      static func make() -> Entity { template.clone(recursive: true) }

    private static func build() -> Entity {
        let root = Entity()

        // ---- 弾本体: 赤いオーブ ----
        let bulletMat = UnlitMaterial(color: UIColor(red: 1.0, green: 0.25, blue: 0.1, alpha: 1.0))
        let bulletMesh = MeshResource.generateSphere(radius: 0.12)
        let bulletBody = ModelEntity(mesh: bulletMesh, materials: [bulletMat])
        root.addChild(bulletBody)

        // ---- 内側の明るいコア ----
        let coreMat = UnlitMaterial(color: UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0))
        let coreMesh = MeshResource.generateSphere(radius: 0.06)
        let core = ModelEntity(mesh: coreMesh, materials: [coreMat])
        root.addChild(core)

        // ---- 発光ライト (赤) ----
        

        return root
    }
}
