// UpgradeItemEntity.swift
// ShootingGame - アップグレードアイテムの 3D モデル生成

import RealityKit
import UIKit

/// アップグレードアイテム（弾数増加）の 3D モデルを生成するファクトリ
@MainActor enum UpgradeItemEntity {
  private static let template: Entity = build()

      /// テンプレートを複製して返す (メッシュ・マテリアルは共有)
      static func make() -> Entity { template.clone(recursive: true) }
  private static func build() -> Entity {
        let root = Entity()

        // ---- 外枠: 菱形に見せるための回転ボックス ----
        var outerMat = PhysicallyBasedMaterial()
        outerMat.baseColor = .init(tint: UIColor(red: 0.9, green: 0.85, blue: 0.1, alpha: 1.0))
        outerMat.metallic  = .init(floatLiteral: 0.9)
        outerMat.roughness = .init(floatLiteral: 0.1)
        outerMat.emissiveColor = .init(color: UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0))
        outerMat.emissiveIntensity = 0.5

        let outerMesh = MeshResource.generateBox(width: 0.42, height: 0.42, depth: 0.42, cornerRadius: 0.06)
        let outer = ModelEntity(mesh: outerMesh, materials: [outerMat])
        // ダイヤ形に見せるため 45° 傾ける
        outer.orientation = simd_quatf(angle: .pi / 4, axis: [0, 0, 1]) *
                            simd_quatf(angle: .pi / 4, axis: [1, 0, 0])
        root.addChild(outer)

        // ---- 内側のコア (光る球) ----
        var coreMat = UnlitMaterial(color: UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0))
        let coreMesh = MeshResource.generateSphere(radius: 0.12)
        let core = ModelEntity(mesh: coreMesh, materials: [coreMat])
        root.addChild(core)

        // ---- 黄色い発光ライト ----
        

        return root
    }
}
