// PlayerEntity.swift
// ShootingGame - 自機の 3D モデル生成

import RealityKit
import UIKit

/// 自機の 3D モデルを生成するファクトリ
/// 将来的に Blender の .usdz をロードする場合はこのファイルだけ変更する
enum PlayerEntity {

    /// 自機エンティティを生成して返す
    static func make() -> Entity {
        let root = Entity()

        // ---- 機体本体 (細長い六角柱) ----
        var bodyMat = PhysicallyBasedMaterial()
        bodyMat.baseColor = .init(tint: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0))
        bodyMat.metallic  = .init(floatLiteral: 0.8)
        bodyMat.roughness = .init(floatLiteral: 0.2)

        let bodyMesh = MeshResource.generateBox(width: 0.5, height: 0.12, depth: 0.9, cornerRadius: 0.08)
        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [bodyMat])
        root.addChild(bodyEntity)

        // ---- 左翼 ----
        let wingMesh = MeshResource.generateBox(width: 0.7, height: 0.06, depth: 0.35, cornerRadius: 0.04)
        var wingMat = PhysicallyBasedMaterial()
        wingMat.baseColor = .init(tint: UIColor(red: 0.15, green: 0.45, blue: 0.85, alpha: 1.0))
        wingMat.metallic  = .init(floatLiteral: 0.7)
        wingMat.roughness = .init(floatLiteral: 0.25)

        let leftWing = ModelEntity(mesh: wingMesh, materials: [wingMat])
        leftWing.position = SIMD3<Float>(-0.55, 0, 0.1)
        root.addChild(leftWing)

        // ---- 右翼 ----
        let rightWing = ModelEntity(mesh: wingMesh, materials: [wingMat])
        rightWing.position = SIMD3<Float>(0.55, 0, 0.1)
        root.addChild(rightWing)

        // ---- コックピット (半球状の暗いガラス) ----
        var cockpitMat = PhysicallyBasedMaterial()
        cockpitMat.baseColor = .init(tint: UIColor(red: 0.05, green: 0.15, blue: 0.4, alpha: 1.0))
        cockpitMat.metallic  = .init(floatLiteral: 0.0)
        cockpitMat.roughness = .init(floatLiteral: 0.05)

        let cockpitMesh = MeshResource.generateSphere(radius: 0.14)
        let cockpitEntity = ModelEntity(mesh: cockpitMesh, materials: [cockpitMat])
        cockpitEntity.position = SIMD3<Float>(0, 0.09, -0.15)
        root.addChild(cockpitEntity)

        // ---- エンジンノズル (左右) ----
        let nozzleMesh = MeshResource.generateCylinder(height: 0.15, radius: 0.07)
        var nozzleMat = PhysicallyBasedMaterial()
        nozzleMat.baseColor = .init(tint: .darkGray)
        nozzleMat.metallic  = .init(floatLiteral: 1.0)
        nozzleMat.roughness = .init(floatLiteral: 0.1)

        for xOff: Float in [-0.18, 0.18] {
            let nozzle = ModelEntity(mesh: nozzleMesh, materials: [nozzleMat])
            // シリンダーは Y 軸方向なのでXZ回転して後方向きにする
            nozzle.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            nozzle.position = SIMD3<Float>(xOff, -0.02, 0.5)
            root.addChild(nozzle)
        }

        // ---- エンジン炎 (PointLight) ----
        

        return root
    }
}
