import RealityKit
import UIKit

@MainActor
enum PlayerBulletEntity {

    private static let template: Entity = build()

    /// テンプレートを複製して返す (メッシュ・マテリアルは共有)
    static func make() -> Entity { template.clone(recursive: true) }

    private static func build() -> Entity {
        let root = Entity()

        let bulletMat = UnlitMaterial(color: UIColor(red: 0.4, green: 0.95, blue: 1.0, alpha: 1.0))
        let bulletMesh = MeshResource.generateBox(width: 0.06, height: 0.06, depth: 0.35, cornerRadius: 0.03)
        root.addChild(ModelEntity(mesh: bulletMesh, materials: [bulletMat]))

        let tipMat = UnlitMaterial(color: UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 1.0))
        let tip = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.055), materials: [tipMat])
        tip.position = SIMD3<Float>(0, 0, -0.18)
        root.addChild(tip)

        return root   // PointLight は削除
    }
}
