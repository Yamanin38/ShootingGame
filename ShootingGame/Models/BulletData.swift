// BulletData.swift
// ShootingGame - 弾の状態を保持するデータ構造体

import Foundation
import RealityKit
import simd

/// 弾1発分のゲームデータ
struct BulletData: Identifiable {
    let id: UUID
    /// RealityKit シーン上のエンティティ
    let entity: Entity
    /// ワールド座標
    var position: SIMD3<Float>
    /// 1秒あたりの移動ベクトル
    let velocity: SIMD3<Float>
    /// true = 自機弾, false = 敵弾
    let isPlayerBullet: Bool

    init(entity: Entity, position: SIMD3<Float>, velocity: SIMD3<Float>, isPlayerBullet: Bool) {
        self.id             = UUID()
        self.entity         = entity
        self.position       = position
        self.velocity       = velocity
        self.isPlayerBullet = isPlayerBullet
    }
}
