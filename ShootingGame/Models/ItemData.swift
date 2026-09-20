// ItemData.swift
// ShootingGame - アップグレードアイテムの状態を保持するデータ構造体

import Foundation
import RealityKit
import simd

/// アップグレードアイテム1個分のゲームデータ
struct ItemData: Identifiable {
    let id: UUID
    let entity: Entity
    var position: SIMD3<Float>
    /// 回転アニメーション用累積角度
    var rotationAngle: Float = 0.0

    init(entity: Entity, position: SIMD3<Float>) {
        self.id       = UUID()
        self.entity   = entity
        self.position = position
    }
}
